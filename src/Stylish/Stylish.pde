//ws2812b setup
#include <WS2812B.h>
#define NUM_LEDS 16

WS2812B strip = WS2812B(NUM_LEDS);


#include <MozziGuts.h>
#include <Oscil.h> // oscillator template
#include <tables/sin2048_int8.h> // sine table for oscillator
#include <tables/saw2048_int8.h> // saw table for oscillator
#include <tables/square_no_alias_2048_int8.h> // square table for oscillator

#include <mozzi_midi.h>
// use: Oscil <table_size, update_rate> oscilName (wavetable), look in .h file of table #included above
//Oscil <SIN2048_NUM_CELLS, AUDIO_RATE> osc1(SIN2048_DATA);
Oscil <SQUARE_NO_ALIAS_2048_NUM_CELLS, AUDIO_RATE> osc1(SQUARE_NO_ALIAS_2048_DATA);
//Oscil <SAW2048_NUM_CELLS, AUDIO_RATE> osc1(SAW2048_DATA);
Oscil <SAW2048_NUM_CELLS, AUDIO_RATE> osc2(SAW2048_DATA);

#define NUM_PATCHES (25)

uint8_t gain=0;
uint8_t patch_number=0;
uint8_t last_patch_number=0;
uint8_t parameter_number=0;
bool patch_number_changed = false;
uint8_t current_mode_button = 0;

// patch structure
// 26 parameters packed into 
class patch_t
{
private:
  uint8_t values[16];
public:
  bool Set( uint8_t param, uint8_t value )
  {
    uint8_t bitindex = param * 5;
    uint8 bitsize = 5;
    if ( param == 25 )
    {
      bitsize = 3;
    }
    uint8_t byteindex = bitindex >> 3; // divide by 8 to get the byte in "values" array
    int shift0 = 8 - ( ( bitindex & 0x7 ) + bitsize ); // keep low 4 bits for "modulus 8" behavior to get bit index 
    uint8_t mask0= ( 1<< bitsize)  - 1; // make mask for low bits;
    value &= mask0; //mask off excess bits
    uint8_t val0 = value;
    if ( shift0 >= 0 ) // shift left if positive, right if negative
    {
      val0 <<= shift0;
      mask0 <<= shift0; // shift the mask to clear out values too
      values[ byteindex ] &= ~mask0; //clear old bits
      values[ byteindex ] |= val0;   //set new value bits
      return( false ); // no error
    }
    //else if shift is negative, will need two bytes
    val0 >>= (-shift0); //shift value and mask right... extra bits will be chopped off
    mask0 >>= (-shift0); // shift the mask to clear out values too
    values[ byteindex ]&=~mask0; //clear old bits
    values[ byteindex ]|=val0;   //set new value bits
    //now for 2nd byte stuff
    int shift1 = 8 - (bitsize + shift0 + 1);     //need bits in the next byte! Invert our shift. Whatever bits we shifted out, we now shift in
    uint8_t val1 = value << shift1;       //shift left, extra bits fall out the top  
    uint8_t mask1 = ( 1 << bitsize ) - 1; //rebuild mask
    mask1 <<= shift1;                     //shift it to kill current value
    byteindex++;                          //operate on 2nd byte
    values[ byteindex ]&=~mask1;          //clear old value bits
    values[ byteindex ]|=val1;            //set new value bits to 2nd byte
    return( false );                      //no errors, return
  };
  uint8_t Get( uint8_t param )
  {
    uint8_t bitindex = param * 5;
    uint8 bitsize = 5;
    if ( param == 25 )
    {
      bitsize = 3;
    }
    uint8_t byteindex = bitindex >> 3; // divide by 8 to get the byte in "values" array
    int shift0 = 8 - ( ( bitindex & 0x7 ) + bitsize ); // keep low 4 bits for "modulus 8" behavior to get bit index 
    uint8_t mask= ( 1<< bitsize)  - 1; // make mask for low bits;
    uint8_t val = 0;
    if ( shift0 >= 0 ) // shift left if positive, right if negative
    {
      val = values[ byteindex ] >> shift0;
      val &= mask;
      
      return( val ); // no error
    }
    //else
    val = values[ byteindex ] << -shift0;
    val &= mask;
    val &= mask << -shift0; //zeros shift in
    byteindex++;
    int shift1 = 8 - (bitsize + shift0 + 1);     //need bits in the next byte! Invert our shift. Whatever bits we shifted out, we now shift in
    uint8_t val1 = values[ byteindex ] >> shift1;
    val1 &= mask >> shift1;
    val|=val1;
    return( val );  
  }
};

patch_t Patch[NUM_PATCHES];
  

//order of operations:
// tap button for thing to change - ring will be a solid color, different for each button
// when released, ring will flash that color, waiting for input value
// keyboard is used to select value, and will light up LED corresponding to value while held.
// when released, ring will flash faster than before, keyboard can still be used to change value
// when original button is pressed again, value is kept, ring flashes once and fades out
// if another button is pushed, change is aborted and ring flashes red, value reverts.
// for parameters, it is a two stage process, parameter number, then parameter value.
// after parameter number is selected, further presses will change parameter value

enum eUI_States {
  S_PLAY,               //just play notes
  S_PATCH_SELECT,       //selecting patch. Takes 1 parameter (play sound) and verify with patch select button, (other button cancels)
  S_PATCH_WRITE,        //writing patch.   Takes 1 parameter (play sound) and verify with patch write button, (other button cancels)
  S_PARAMETER_SELECT,   //changing parameter. Step 1, select parameter #, automatically advances to next state: change parameter value (other button cancels)
  S_PARAMETER_VALUE,    //changing parameter. Step 2. select the value, play the sound with updated value, verify change with parameter button (other button cancels)
  S_MODE_CHANGE,        //changing mode. Step 1. Select the mode parameter number, automatically advances to next state: change mode value (other button cancels)
  S_MODE_VALUE,         //changing mode. Step 2, select the value for mode parameter. verify change with mode button (other button cancels)
  S_NUM_STATES
};

enum eUI_SubStates {
  SS_UP,
  SS_PLAY_DOWN,
  SS_SELECT_DOWN,
  SS_SELECT_WAIT_FOR_VALUE,
  SS_SELECT_PLAYING_VALUE_AUDITION,
  SS_SELECT_DONE_SELECTING_DOWN,
  SS_SELECT_ABORT_DOWN,
  SS_NUM_STATES
};

enum eANIM_Bits {
  eANIM_NONE     = 0,
  eANIM_FLASH    = 1,
  eANIM_DIAL     = 2,
  eANIM_FADE     = 4,
  eANIM_SPARKLES = 8
};


eUI_States state = S_PLAY;
eUI_SubStates subState = SS_UP;
// use #define for CONTROL_RATE, not a constant
#define CONTROL_RATE 64 // Hz

//stylus keyboard 
uint8_t keyboard_pins[]={PB12,PB13,PB14,PB15,PA8,PA9,PA10,PA6,PB11,PA15,PB3,PB4,PB5,PB6,PB7,PB9,PC13,PC14,PC15,PA0,PA1,PA2,PA3,PA4,PA5,
/*buttons */             PB1,PB0,PB10/*,PA6*/};

#define NUM_NOTES (25)
#define NUM_BUTTONS (3) /*mode button being used for keyboard atm...*/
#define NUM_PINS (NUM_NOTES+NUM_BUTTONS)
#define NOT_PRESSED (0xFF)
#define REQUIRED_STABLE_CYCLES (100)

enum {PATCH_BUTTON=NUM_NOTES, WRITE_BUTTON, VALUE_BUTTON, MODE_BUTTON};

#define MODE_BUTTON_HACK_MASK ((1<<WRITE_BUTTON)|(1<<VALUE_BUTTON))
#define MODE_BUTTON_MASK (1<<MODE_BUTTON)

typedef void ( *KeyCallback)(uint8_t key);

uint32_t raw_key_bits=0;
uint32_t key_bits=0;
uint8_t key_down = NOT_PRESSED;
uint8_t last_key_down = NOT_PRESSED;
uint8_t raw_key_down = NOT_PRESSED;
uint8_t last_key_played = NOT_PRESSED;
KeyCallback KeyDownCallback=NULL;
KeyCallback KeyUpCallback=NULL;
uint32_t stable_counter=0;

void SetKeyDownCallback(KeyCallback key_down_callback)
{
  KeyDownCallback = key_down_callback;
}

void SetKeyUpCallback(KeyCallback key_up_callback)
{
  KeyUpCallback = key_up_callback;
}


void StylusKeyboardSetup()
{
  Serial.println("Stylus Keyboard Setup");
  __IO uint32 *mapr = &AFIO_BASE->MAPR;
  afio_cfg_debug_ports(AFIO_DEBUG_SW_ONLY/*AFIO_DEBUG_NONE*/);
  
  for(int i=0; i < NUM_PINS; i++ )
  {
      pinMode( keyboard_pins[i], INPUT_PULLUP );      
      
  }
}


uint8_t StylusKeyboardUpdate()
{
  uint32_t last_key_bits = key_bits;
  uint8_t raw_last_key_down = raw_key_down;
  uint32_t key_bit=1;
  raw_key_bits = 0;
  raw_key_down = NOT_PRESSED;
   
  for(int i=0; i<NUM_PINS;i++)
  {
      if (!digitalRead(keyboard_pins[i]))
      {
        raw_key_bits|=key_bit;
        raw_key_down = i;
      }      
      key_bit<<=1;
  }
  //if WRITE and VALUE buttons are pressed, is really MODE button.
  //fix the raw array to reflect this.
  if ( ( raw_key_bits & MODE_BUTTON_MASK ) == MODE_BUTTON_MASK )
  {
    raw_key_bits ^= MODE_BUTTON_HACK_MASK;
    raw_key_bits |= MODE_BUTTON_MASK;
  }
  
  if ( raw_key_down!=raw_last_key_down)
  {
    stable_counter = 0;
  }
  else if ( stable_counter <= REQUIRED_STABLE_CYCLES )
  {
    stable_counter++;
    if ( stable_counter == REQUIRED_STABLE_CYCLES )
    {
      key_bits = raw_key_bits;
      last_key_down = key_down;
      key_down = raw_key_down;
      if ( key_down != NOT_PRESSED)
      {
        if ( KeyDownCallback)
        {
          (*KeyDownCallback)(key_down);
        }
      }
      if (last_key_down!=NOT_PRESSED)
      {
        if ( KeyUpCallback)
        {
          (*KeyUpCallback)(last_key_down);
        }
        
      }
      
    }
  }
    
  return(key_down);  
}

uint8_t GetStylusKeyDown()
{
  return(key_down);
}

uint32_t GetStylusKeyBits()
{
  return(key_bits);
}

void SoundKeyDown(uint8_t key)
{
  last_key_played = key;
  osc1.setFreq(mtof(float(key+36)));
  osc2.setFreq(mtof(float(key+43)));
  gain = 255;        
}

void SoundKeyUp()
{
  key_down = NOT_PRESSED;
}

void SoundRetrigger()
{
  SoundKeyDown( last_key_played );
}


uint8_t GetUIValue()
{
  switch ( state )
  {
    case S_PLAY:
      return (key_down);
      break;
    case S_PATCH_SELECT:
      return( patch_number );
      break;
    case S_PATCH_WRITE:
      return( patch_number );
      break;
    case S_PARAMETER_SELECT:
      return( parameter_number );
      break;
    case S_PARAMETER_VALUE:
      //return( 
      break;
    case S_MODE_CHANGE:
      break;
    case S_MODE_VALUE:
      break;
    case S_NUM_STATES:
    default:
      break;      
  }
}


uint8_t SubStateKeyDown(uint8_t key)
{
  switch ( subState )
  {
    case SS_UP:
    case SS_PLAY_DOWN:
    case SS_SELECT_DOWN:
      // waiting for up
      // nothing else should happen here... nothing else SHOULD be able to happen here
      //if it does, should I do something?
      break;    
    case SS_SELECT_WAIT_FOR_VALUE:
      if ( key <= NUM_NOTES )
      {
          SoundKeyDown(key);
      }
      else if ( key == current_mode_button )  //pressed current mode button, so write value
      {
      }
      else  //selected some other button, abort
      {
      }
      break;
    case SS_SELECT_PLAYING_VALUE_AUDITION:
    case SS_SELECT_DONE_SELECTING_DOWN:
    case SS_SELECT_ABORT_DOWN:
    case SS_NUM_STATES:
    default:
      break;
  }
}

void SubStateKeyUp(uint8_t key)
{
  switch ( subState )
  {
    case SS_UP:
    case SS_PLAY_DOWN:
    case SS_SELECT_DOWN:
      subState = SS_SELECT_WAIT_FOR_VALUE;
      break;
    case SS_SELECT_WAIT_FOR_VALUE:
    case SS_SELECT_PLAYING_VALUE_AUDITION:
    case SS_SELECT_DONE_SELECTING_DOWN:
    case SS_SELECT_ABORT_DOWN:
    case SS_NUM_STATES:
    default:
      break;
  }
}


void ReceiveKeyDown(uint8_t key )
{

  Serial.print("Key Down ");
  Serial.print(key,DEC);
  Serial.println(".");
  
  switch (state )
  {
    case S_PLAY:
      if ( key <= NUM_NOTES )
      {
        SoundKeyDown(key);
      }
      else
      {
        switch( key )
        {
          case PATCH_BUTTON:        
            last_patch_number = patch_number;   // save the patch number in case of abort
            patch_number_changed = false;       // clear patch change flag
            current_mode_button = PATCH_BUTTON; // save button for comparison in substate code
            state = S_PATCH_SELECT;             // set state
            subState = SS_SELECT_DOWN;          // set substate
            break;
          case WRITE_BUTTON: 
            last_patch_number = patch_number;   // save the patch number in case of abort
            current_mode_button = WRITE_BUTTON; // save button for comparison in substate code
            state = S_PATCH_WRITE;              // set state
            subState = SS_SELECT_DOWN;          // set substate
            break;
          case VALUE_BUTTON: 
            current_mode_button = VALUE_BUTTON; // save button for comparison in substate code
            state = S_PARAMETER_SELECT;         // set state
            subState = SS_SELECT_DOWN;          // set substate
            break;
          case MODE_BUTTON:
            current_mode_button = MODE_BUTTON;  // save button for comparison in substate code
            state = S_MODE_CHANGE;              // set state
            subState = SS_SELECT_DOWN;          // set substate
            break;
        }
      }
      break;
    case S_PATCH_SELECT:
      SubStateKeyDown(key);
      break;
    case S_PATCH_WRITE:
      SubStateKeyDown(key);
      break;
    case S_PARAMETER_SELECT:
      SubStateKeyDown(key);
      break;
    case S_PARAMETER_VALUE:
      SubStateKeyDown(key);
      break;
    case S_MODE_CHANGE:
      SubStateKeyDown(key);
      break;
    case S_MODE_VALUE:
      SubStateKeyDown(key);
      break;
    default:
      break;
  }  
}

void ReceiveKeyUp(uint8_t key )
{
  Serial.print("Key Up ");
  Serial.print(key,DEC);
  Serial.println(".");
  SubStateKeyUp(key);
}

//Mozzi

void updateControl(){
  // put changing controls in here
}


int updateAudio(){
  return ((osc1.next()+osc2.next())*gain)>>9; // return an int signal centred around 0
}


#define SPEED_DIVIDE (1000)

void setup() {
  //Setup Serial at max baud rate and wait till terminal connects before starting output
  Serial.begin(115200);  
  while (!Serial)
  {
    digitalWrite(33,!digitalRead(33));// Turn the LED from off to on, or on to off
    delay(100);         // fast blink
  }  
  for(uint8_t i=0xA0; i<=0xb3;i++)
  {
    uint8_t utf8char[]={0xe2,0x91,i};
    Serial.write(utf8char,3);
  }
  
  for(uint8_t patchNum=0;patchNum<26;patchNum++)
  {
    for( uint8_t paramNum=0; paramNum<27;paramNum++)
    {
      Patch[patchNum].Set(paramNum,paramNum);
      Serial.print("PatchNum:");
      Serial.print(patchNum, DEC);
      Serial.print("  ParamNum:");
      Serial.print(paramNum, DEC);
      Serial.print("  Value:");
      Serial.println(Patch[patchNum].Get(paramNum), DEC);
    }
    
  }

  strip.begin();// Sets up the SPI
  strip.show();// Clears the strip, as by default the strip data is set to all LED's off.
  strip.setBrightness(8);

  startMozzi(CONTROL_RATE); // :)
  osc1.setFreq(440); // set the frequency
  osc2.setFreq(440); // set the frequency


  //Init Stylus keyboard library
  Serial.println("Stylus Keypad Test");
  StylusKeyboardSetup();
  SetKeyDownCallback(&ReceiveKeyDown);
  SetKeyUpCallback(&ReceiveKeyUp);
  //init WS2812B strip
  
  
}

uint64_t counter = 0;

void loop() 
{
  StylusKeyboardUpdate();
  uint8_t key = GetStylusKeyDown();

  if ((counter%SPEED_DIVIDE)==0)
  {
    uint64_t small_counter = counter/SPEED_DIVIDE;
//    Serial.print(small_counter,DEC);
//    Serial.print(" ");
    uint32_t bits=GetStylusKeyBits();
    uint32_t bit = 1;
    for(int i=0;i<NUM_PINS;i++)
    {
      if ( bits & bit )
      {
//        Serial.print("#");
      }
      else
      {
//        Serial.print(".");
      }
      bit<<=1;
    }
//    Serial.println("\e[1;A");
    
    //led strip test
    for(int i=0; i< strip.numPixels(); i++) 
    {
      uint8_t r=0,g=0,b=0;
      if ((small_counter%strip.numPixels())==i)
      {
        r=127;
      }
      uint8_t keywrap = key % NUM_LEDS;
      if ( key < NUM_LEDS )
      {
        if ( i == key)
        {
          g=127;
        }
      }
      else
      {
        if ( i == keywrap)
        {
          b=127;
          g=32;
        }
      }
      strip.setPixelColor( i, r, g, b );
    }
    strip.show();
    if ( key==NOT_PRESSED )
    {
      if ( gain > 8 )
      {
        gain-=8;
      }
      else
      {
        gain = 0;
      }
    }
  }  
  
  counter++;
  audioHook();
}
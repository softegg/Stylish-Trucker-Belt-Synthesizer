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
uint8_t gain=0;

enum eUI_States {
  S_PLAY,
  S_PATCH_SELECT,
  S_PATCH_WRITE,
  S_PARAMETER_SELECT,
  S_PARAMETER_VALUE_CHANGE,
  S_MODE_CHANGE,
  S_MODE_VALUE,
  S_NUM_STATES
};

eUI_States state=S_PLAY;

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
#define LED_SPIN_BRIGHT (255)
//(16)
//

typedef void ( *KeyCallback)(uint8_t key);

uint32_t raw_key_bits=0;
uint32_t key_bits=0;
uint8_t key_down = NOT_PRESSED;
uint8_t last_key_down = NOT_PRESSED;
uint8_t raw_key_down = NOT_PRESSED;
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

void ReceiveKeyDown(uint8_t key )
{

  Serial.print("Key Down ");
  Serial.print(key,DEC);
  Serial.println(".");
  
  if ( key <= NUM_NOTES )
  {
    osc1.setFreq(mtof(float(key+36)));//+24)));
    osc2.setFreq(mtof(float(key+43)));
    gain = 255;        
  }
  else
  {
    
  }
}

void ReceiveKeyUp(uint8_t key )
{
  Serial.print("Key Up ");
  Serial.print(key,DEC);
  Serial.println(".");
}

//Mozzi

void updateControl(){
  // put changing controls in here
}


int updateAudio(){
//  return ((osc1.next()/*+osc2.next()*/)*gain)>>8;//9; // return an int signal centred around 0
  return ((osc1.next()+osc2.next())*gain)>>9; // return an int signal centred around 0
}


#define SPEED_DIVIDE (1000)

void setup() {
  //Setup Serial at max baud rate and wait till terminal connects before starting output
  Serial.begin(115200);  
  //while (!Serial)
  //{
  //  digitalWrite(33,!digitalRead(33));// Turn the LED from off to on, or on to off
  //  delay(100);         // fast blink
  //}  
  for(uint8_t i=0xA0; i<=0xb3;i++)
  {
    uint8_t utf8char[]={0xe2,0x91,i};
    Serial.write(utf8char,3);
  }

  strip.begin();// Sets up the SPI
  strip.show();// Clears the strip, as by default the strip data is set to all LED's off.
  //strip.setBrightness(8);

  startMozzi(CONTROL_RATE); // :)
  osc1.setFreq(440); // set the frequency
//  osc2.setFreq(440); // set the frequency


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
    Serial.print(small_counter,DEC);
    Serial.print(" ");
    uint32_t bits=GetStylusKeyBits();
    uint32_t bit = 1;
    #if 0
    for(int i=0;i<NUM_PINS;i++)
    {
      if ( bits & bit )
      {
        Serial.print("#");
      }
      else
      {
        Serial.print(".");
      }
      bit<<=1;
    }
    Serial.println("\e[1;A");
    #endif
    
    //led strip test
    for(int i=0; i< strip.numPixels(); i++) 
    {
      uint8_t r=0,g=0,b=0;
      if ((small_counter%strip.numPixels())==i)
      {
        r = LED_SPIN_BRIGHT;
      }
      uint8_t keywrap = last_key_down % NUM_LEDS;
      if ( last_key_down < NUM_LEDS )
      {
        if ( i == last_key_down)
        {
          g = gain >> 2;
        }
      }
      else
      {
        if ( i == keywrap)
        {
          b = gain >> 2;
          g = gain >> 4;
        }
      }
      strip.setPixelColor( i, r, g, b );
    }
    strip.show();
    if ( key==NOT_PRESSED )
    {
      if ( gain > 8 )
      {
        gain -= 8;
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
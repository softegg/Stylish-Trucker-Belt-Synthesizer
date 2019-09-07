//ws2812b setup
#include <WS2812B.h>
#define NUM_LEDS 16

WS2812B strip = WS2812B(NUM_LEDS);

#include "rgb.h"


#include <MozziGuts.h>
#include <Oscil.h> // oscillator template
#include <tables/sin2048_int8.h> // sine table for oscillator
#include <tables/saw2048_int8.h> // saw table for oscillator
#include <tables/square_no_alias_2048_int8.h> // square table for oscillator

#include <mozzi_midi.h>
//#include "printf.h"
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
uint8_t mode_parameter_number=0;
uint8_t mode_value=0;
uint8_t parameter_value=0;

uint8_t last_ui_value=0;

// patch structure
// 26 parameters packed into 
#define NUM_PATCH_PARAMETERS (26)
#define LAST_PATCH_PARAMETER_NUMBER (NUM_PATCH_PARAMETERS-1)

uint8_t LocalPatchData[ NUM_PATCH_PARAMETERS ];
uint8_t LocalPatchDataBackup[ NUM_PATCH_PARAMETERS ];

class patch_t
{
private:
	uint8_t values[16];
public:
	bool Set(uint8_t param, uint8_t value)
	{
		uint8_t bitindex = param * 5;
		uint8_t bitsize = 5;
		if (param == LAST_PATCH_PARAMETER_NUMBER)
		{
			bitsize = 3;
		}
		uint8_t byteindex = bitindex >> 3; // divide by 8 to get the byte in "values" array

		int shift = 16 - ((bitindex & 0x7) + bitsize); // keep low 4 bits for "modulus 8" behavior to get bit index 

		uint16_t work = value << shift;  // shift value into position using 16 bit int.
		uint16_t mask = (1 << bitsize) - 1;  // create a mask for the proper number of bits
		mask <<= shift;                   //shift the mask into position
//		printf("param: %d value:%d bitsize:%d bitindex: %d byteindex:%d shift:%d mask:%016lld work:%016lld ~mask:%016lld ", param, value, bitsize, bitindex, byteindex, shift, ToBinary(mask),ToBinary(work),ToBinary(~mask));

		uint16_t old = (values[byteindex] << 8) | values[byteindex + 1]; //get the data currently in position
//		printf("old:%016lld ", ToBinary(old));
		old &= ~mask; //mask off the area where the data needs to go.
//		printf("old(masked):%016lld ", ToBinary(old));

		work |= old;  //install the old data around the shifted value in the work data
//		printf("work(combined):%016lld ", ToBinary(work));

		values[byteindex] = work >> 8;        //
		values[byteindex + 1] = work & 0xFF;

//		printf(" values[%d,%d]=%02x,%02x\n", byteindex, byteindex + 1, values[byteindex], values[byteindex + 1]);

		return(false);                      //no errors, return
	};
	uint8_t Get(uint8_t param)
	{
		uint8_t bitindex = param * 5;
		uint8_t bitsize = 5;
		if (param == LAST_PATCH_PARAMETER_NUMBER)
		{
			bitsize = 3;
		}
		uint8_t byteindex = bitindex >> 3; // divide by 8 to get the byte in "values" array
		int shift = 16 - ((bitindex & 0x7) + bitsize); // keep low 4 bits for "modulus 8" behavior to get bit index 

		uint16_t work = (values[byteindex] << 8) | values[byteindex + 1]; //get the data currently in position
		work >>= shift;
		uint16_t mask = (1 << bitsize) - 1;  // create a mask for the proper number of bits
		work &= mask;
//		printf("Get: %d\n", work);
		return (work);
	};
  
  void GetAllToLocal()
  {
    for( uint8_t i=0; i < NUM_PATCH_PARAMETERS; i++ )
    {
      LocalPatchData[i] = Get( i );
    }
  }
  
  void SetAllFromLocal()
  {
    for( uint8_t i=0; i < NUM_PATCH_PARAMETERS; i++ )
    {
      Set( i, LocalPatchData[i] );
    }
  }
};

patch_t Patch[NUM_PATCHES];

#define NUMBER_MODE_VALUES (25)

uint8_t ModeData[NUMBER_MODE_VALUES];

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

char * UI_State_Strings[]={
  "S_PLAY",
  "S_PATCH_SELECT",       
  "S_PATCH_WRITE",        
  "S_PARAMETER_SELECT",   
  "S_PARAMETER_VALUE",    
  "S_MODE_CHANGE",        
  "S_MODE_VALUE",         
  "S_NUM_STATES"  
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

char * UI_SubState_Strings[] = {
  "SS_UP",
  "SS_PLAY_DOWN",
  "SS_SELECT_DOWN",
  "SS_SELECT_WAIT_FOR_VALUE",
  "SS_SELECT_PLAYING_VALUE_AUDITION",
  "SS_SELECT_DONE_SELECTING_DOWN",
  "SS_SELECT_ABORT_DOWN",
  "SS_NUM_STATES"
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
/*buttons */             PB10,PB1,PB0,/*,PA6*/};

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

void Set_UI_State(eUI_States _state)
{
  state = _state;
  Serial.printf("Set State: %s\r\n", UI_State_Strings[ state ] );
}

eUI_States Get_UI_State(bool echo = true);

eUI_States Get_UI_State(bool echo)
{
  if ( echo )
  {
    Serial.printf("Get State: %s\r\n", UI_State_Strings[ state ] );
  }
  return( state );
}

void Set_UI_SubState(eUI_SubStates _subState)
{
  subState = _subState;
  Serial.printf("Set SubState: %s\r\n", UI_SubState_Strings[ subState ] );
};

eUI_SubStates Get_UI_SubState(bool echo = true);

eUI_SubStates Get_UI_SubState(bool echo)
{
  if ( echo )
  {
    Serial.printf("Get SubState: %s\r\n", UI_SubState_Strings[ subState ] );
  }
  return( subState );
};


void StylusKeyboardSetup()
{
  Serial.printf("Stylus Keyboard Setup\r\n");
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
  if ( ( raw_key_bits & MODE_BUTTON_HACK_MASK ) == MODE_BUTTON_HACK_MASK )
  {
    raw_key_bits &= ~MODE_BUTTON_HACK_MASK;
    raw_key_bits |= MODE_BUTTON_MASK;
    raw_key_down = MODE_BUTTON;
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
  switch ( Get_UI_State() )
  {
    case S_PLAY:
      Serial.printf("GetUIValue: PLAY key_down = %d\r\n",key_down);
      return (key_down);
      break;
    case S_PATCH_SELECT:
      Serial.printf("GetUIValue: PATCH_SELECT patch_number = %d\r\n",patch_number);
      return( patch_number );
      break;
    case S_PATCH_WRITE:
      Serial.printf("GetUIValue: PATCH_WRITE patch_number = %d\r\n",patch_number);
      return( patch_number );
      break;
    case S_PARAMETER_SELECT:
      Serial.printf("GetUIValue: PARAMETER_SELECT parameter_number = %d\r\n",parameter_number);
      return( parameter_number );
      break;
    case S_PARAMETER_VALUE:
      Serial.printf("GetUIValue: PARAMETER_VALUE(%d)=%d\r\n",parameter_number, LocalPatchData[ parameter_number ] );
      return( LocalPatchData[ parameter_number ] );
      break;
    case S_MODE_CHANGE:
      Serial.printf("GetUIValue: MODE_CHANGE mode_parameter_number = %d\r\n",mode_parameter_number);
      return( mode_parameter_number );
      break;
    case S_MODE_VALUE:
      Serial.printf("GetUIValue: MODE_VALUE(%d)=%d\r\n",mode_parameter_number, ModeData[ mode_parameter_number ] );
      return( ModeData[ mode_parameter_number ] );
      break;
    case S_NUM_STATES:
    default:
      Serial.printf("ERROR: GetUIValue with invalid UI State\r\n");
      Get_UI_State();
      return(0);
      break;      
  }
}

void SetUIValue(uint8_t value )
{
  switch ( Get_UI_State() )
  {
    case S_PLAY:
      key_down = value;
      Serial.printf("SetUIValue: PLAY key_down = %d\r\n",key_down);
      break;
    case S_PATCH_SELECT:      
      patch_number = value;
      Serial.printf("SetUIValue: PATCH_SELECT patch_number = %d\r\n", patch_number);
      //copy to synth local unpacked parameters here
      Patch[patch_number].GetAllToLocal();
      break;
    case S_PATCH_WRITE:
      patch_number = value;
      Serial.printf("SetUIValue: PATCH_WRITE patch_number = %d\r\n", patch_number);
      //copy current patch parameters into new patch area.
      Patch[patch_number].SetAllFromLocal();
      break;
    case S_PARAMETER_SELECT:
      parameter_number = value;
      Serial.printf("GetUIValue: PARAMETER_SELECT parameter_number = %d\r\n", parameter_number);
      break;
    case S_PARAMETER_VALUE:
      Serial.printf("SetUIValue: PARAMETER_VALUE(%d)=%d\r\n", parameter_number, value);
      //set local patch value
      LocalPatchData[ parameter_number ] = value;
      parameter_value = value;
      break;
    case S_MODE_CHANGE:
      mode_parameter_number = value;
      Serial.printf("SetUIValue: MODE_CHANGE mode_parameter_number = %d\r\n", mode_parameter_number);
      break;
    case S_MODE_VALUE:
      ModeData[ mode_parameter_number ] = value;
      mode_value = value;
      Serial.printf("SetUIValue: MODE_VALUE(%d)=%d\r\n", mode_parameter_number, ModeData[ mode_parameter_number ] );
      break;
    case S_NUM_STATES:
    default:
      Serial.printf("ERROR: GetUIValue with invalid UI State\r\n");
      Get_UI_State();
      break;      
  }
}

void SaveUIValue()
{
  last_ui_value = GetUIValue();
  
  //for patch write, it will overwrite local patch data to play sound.
  //keep a copy of the patch for write / abort
  if ( Get_UI_State() == S_PATCH_WRITE )
  {
    memcpy(LocalPatchDataBackup, LocalPatchData, sizeof(LocalPatchData));
  }
}

void RestoreUIValue()
{
  SetUIValue( last_ui_value );

  //for patch write, it will overwrite local patch data to play sound.
  //move the patch data backup back to local memory.
  if ( Get_UI_State() == S_PATCH_WRITE )
  {
    memcpy(LocalPatchData, LocalPatchDataBackup, sizeof(LocalPatchData));
  }
}


uint8_t SubStateKeyDown(uint8_t key)
{
  switch ( Get_UI_SubState() )
  {
    case SS_UP:
    case SS_PLAY_DOWN:
    case SS_SELECT_DOWN:
      // waiting for up
      // nothing else should happen here... nothing else SHOULD be able to happen here
      //if it does, should I do something?
      break;    
    case SS_SELECT_WAIT_FOR_VALUE:
      if ( key < NUM_NOTES )
      {
        //Serial.print("Patch selected:");
        //Serial.println(patch_number);
        //patch_number = key;
        SetUIValue(key);
        //set patch data here
        SoundKeyDown(key);
        Set_UI_SubState(SS_SELECT_PLAYING_VALUE_AUDITION);
      }
      else if ( key == current_mode_button )  //pressed current mode button, so write value
      {
        //Serial.print("Patch confirmed:");
        //Serial.println(patch_number);
        //last_patch_number = patch_number;
        SaveUIValue();
        Set_UI_SubState(SS_SELECT_DONE_SELECTING_DOWN);
      }
      else  //selected some other button, abort
      {
        //Serial.print("Patch aborted:");
        //patch_number = last_patch_number;
        //Serial.println(patch_number);
        RestoreUIValue();
        Set_UI_SubState( SS_SELECT_ABORT_DOWN );          // set substate      
      }
      break;
      
    //below are set on key down, so probably shouldn't end up here.
    case SS_SELECT_PLAYING_VALUE_AUDITION:
    case SS_SELECT_DONE_SELECTING_DOWN:
    case SS_SELECT_ABORT_DOWN:
      Serial.printf("ERROR! Got SubStateKeyDown on a state that shouln't get it!\r\n");
      Get_UI_SubState();
      break;
    case SS_NUM_STATES:
    default:
      Serial.printf("ERROR! BAD SUBSTATE In SubStateKeyUp!\r\n");
      Serial.println(Get_UI_SubState());
      break;
  }
}

//pick the next state for two stage UI operations.
void NextStateFirstStage()
{
  switch ( Get_UI_State() )
  {
    case S_PARAMETER_SELECT:
      Set_UI_State( S_PARAMETER_VALUE );
      Set_UI_SubState( SS_SELECT_WAIT_FOR_VALUE );
      break;
    case S_MODE_CHANGE:
      Set_UI_State( S_MODE_VALUE );
      Set_UI_SubState( SS_SELECT_WAIT_FOR_VALUE );
      break;
    case S_PARAMETER_VALUE:
    case S_MODE_VALUE:
    case S_PATCH_SELECT:
    case S_PATCH_WRITE:
      Set_UI_SubState( SS_SELECT_WAIT_FOR_VALUE );
      break;
    case S_PLAY:
    default:
      Set_UI_State( S_PLAY );
      Set_UI_SubState( SS_UP );
      break;
  }  
}

//pick the next state for two stage UI operations.
void NextStateDoneSelectingUp()
{
  switch ( Get_UI_State() )
  {
    case S_PARAMETER_SELECT:
      Set_UI_State( S_PARAMETER_VALUE );
      Set_UI_SubState( SS_SELECT_WAIT_FOR_VALUE );
      break;
    case S_MODE_CHANGE:
      Set_UI_State( S_MODE_VALUE );
      Set_UI_SubState( SS_SELECT_WAIT_FOR_VALUE );
      break;
    case S_PARAMETER_VALUE:
    case S_MODE_VALUE:
    case S_PATCH_SELECT:
    case S_PATCH_WRITE:
    case S_PLAY:
    default:
      Set_UI_State( S_PLAY );
      Set_UI_SubState( SS_UP );
      break;
  }  
}

void SubStateKeyUp(uint8_t key)
{
  switch ( Get_UI_SubState() )
  {
    case SS_UP:
    case SS_PLAY_DOWN:
      Set_UI_SubState( SS_UP );
    case SS_SELECT_DOWN:
      Set_UI_SubState( SS_SELECT_WAIT_FOR_VALUE );
      break;
    case SS_SELECT_WAIT_FOR_VALUE:
      //this should always end up at PLAYING_VALUE, DONE_SELECTING, or SELECT_ABORT
      break;
    case SS_SELECT_PLAYING_VALUE_AUDITION:
      NextStateFirstStage();
      break;
    case SS_SELECT_DONE_SELECTING_DOWN:      
      NextStateDoneSelectingUp();
      break;    
    case SS_SELECT_ABORT_DOWN:
      //abort always goes to play.
      //I guess there needs to be cleanup here?
      Set_UI_State( S_PLAY );
      Set_UI_SubState( SS_UP );      
    case SS_NUM_STATES:
    default:
      Serial.printf("ERROR! BAD SUBSTATE In SubStateKeyUp! %d\r\n", Get_UI_SubState());
      Set_UI_State( S_PLAY );
      Set_UI_SubState( SS_UP );
      break;
  }
}


void ReceiveKeyDown(uint8_t key )
{

  Serial.print("Key Down ");
  Serial.print(key,DEC);
  Serial.println(".");
  
  switch ( Get_UI_State() )
  {
    case S_PLAY:
      if ( key < NUM_NOTES )
      {
        SoundKeyDown(key);
      }
      else
      {
        Serial.printf("Button down!\r\n");
        switch( key )
        {
          case PATCH_BUTTON:        
          Serial.printf("Patch!\r\n");
            //last_patch_number = patch_number;   // save the patch number in case of abort
            //patch_number_changed = false;       // clear patch change flag
            SaveUIValue();
            current_mode_button = PATCH_BUTTON; // save button for comparison in substate code
            Set_UI_State( S_PATCH_SELECT );             // set state
            Set_UI_SubState( SS_SELECT_DOWN );          // set substate
            break;
          case WRITE_BUTTON: 
            Serial.printf("Write!\r\n");
            //last_patch_number = patch_number;   // save the patch number in case of abort
            SaveUIValue();            
            current_mode_button = WRITE_BUTTON; // save button for comparison in substate code
            Set_UI_State( S_PATCH_WRITE );              // set state
            subState = SS_SELECT_DOWN;          // set substate
            break;
          case VALUE_BUTTON: 
            Serial.printf("Value!\r\n");
            current_mode_button = VALUE_BUTTON; // save button for comparison in substate code
            Set_UI_State( S_PARAMETER_SELECT );         // set state
            Set_UI_SubState( SS_SELECT_DOWN );          // set substate
            break;
          case MODE_BUTTON:
            Serial.printf("Mode!\r\n");
            current_mode_button = MODE_BUTTON;  // save button for comparison in substate code
            Set_UI_State( S_MODE_CHANGE );              // set state
            Set_UI_SubState( SS_SELECT_DOWN );          // set substate
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
#define FLASH_SPEED_DIVIDE (5000)

void setup() {
  //Setup Serial at max baud rate and wait till terminal connects before starting output
  Serial.begin(115200);  
  while (!Serial)
  {
    digitalWrite(33,!digitalRead(33));// Turn the LED from off to on, or on to off
    delay(100);         // fast blink
  }  
  
  strip.begin();// Sets up the SPI
  strip.show();// Clears the strip, as by default the strip data is set to all LED's off.
  strip.setBrightness(8);

  startMozzi(CONTROL_RATE); // :)
  osc1.setFreq(440); // set the frequency
  osc2.setFreq(440); // set the frequency


  //Init Stylus keyboard library
  StylusKeyboardSetup();
  SetKeyDownCallback(&ReceiveKeyDown);
  SetKeyUpCallback(&ReceiveKeyUp);
  //init WS2812B strip
  
  
}

uint64_t counter = 0;

rgb_t Rainbow(uint8_t value, uint8_t max) 
{
  int index = value;
  index *=255;
  index /=max;
  index %=256;

  if(index < 85) 
  {
    rgb_t out(index * 3, 255 - index * 3, 0);
    return( out );
  } 
  else 
  {
    if(index < 170) 
    {
     index -= 85;
     rgb_t out(255 - index * 3, 0, index * 3);
     return( out );
    } 
    else 
    {
     index -= 170;
     rgb_t out(0, index * 3, 255 - index * 3);
     return( out );
    }
  }
}

const rgb_t rgb_BLACK={0,0,0};
const rgb_t rgb_WHITE={32,32,32};
const rgb_t rgb_GREY={4,4,4};
const rgb_t rgb_RED={16,0,0};
const rgb_t rgb_GREEN={0,255,0};
const rgb_t rgb_BLUE={0,0,255};
const rgb_t rgb_YELLOW={32,32,0};
const rgb_t rgb_PURPLE={255,0,255};
const rgb_t rgb_CYAN={0,32,63};

rgb_t workPixels[ NUM_LEDS ];

void AnimPixelsClear()
{
  memset(workPixels,0,sizeof(workPixels));
};

void AnimPixelsFadeSub(uint8_t decrement)
{
  for( uint8_t i=0; i< NUM_LEDS; i++)
  {
    workPixels[i]-=rgb_t(decrement,decrement,decrement);
  }
}

void AnimPixelsSpread(uint16_t mult)
{
  for( uint8_t i=0; i< NUM_LEDS; i++)
  {
    rgb_t pixel = workPixels[i] ;
    pixel *= mult;
    workPixels[i] = pixel;
  }
}

void AnimPixelSet( uint8_t num, rgb_t &val )
{
  workPixels[num]= val;

};

void AnimPixelAddRange(const uint8_t start, uint8_t end, const rgb_t &val )
{
  for( uint8_t i=start; i<=end; i++ )
  {
    workPixels[i%NUM_LEDS]+=val;
  }
};

//shows a value from 0 to max by lighting up that portion of LEDs
// tip color is "val", trail is "tail"
void AnimPixelAddValue(const uint8_t value, const uint8_t max, const rgb_t &color, const rgb_t &tail)
{
  int top = (NUM_LEDS * (int)value) / (int)max;
  top %= NUM_LEDS;
  for( uint8_t i=0; i < top; i++)
  {
    workPixels[i]+=tail;
  }
  workPixels[top]+=color;
};

void AnimSetStrip()
{
  for(int i=0; i< strip.numPixels(); i++) 
  {
    strip.setPixelColor((i+(NUM_LEDS/2))%NUM_LEDS, workPixels[i].r, workPixels[i].g, workPixels[i].b);
    //Serial.printf("%d->%d,%d,%d\r\n",i, workPixels[i].r, workPixels[i].g, workPixels[i].b);
  }
  strip.show();
};

void AnimUpdate()
{
  eUI_States _state = Get_UI_State( false );


  //bool flash = ((counter%FLASH_SPEED_DIVIDE)==0);
  int flash = (counter / FLASH_SPEED_DIVIDE) % 4;
  
  if (( _state == S_PARAMETER_VALUE ) || ( _state == S_MODE_VALUE ) )
  {
    flash = (counter / FLASH_SPEED_DIVIDE) % 6;
  }
  
    
  if ((counter%SPEED_DIVIDE)==0)
  {
    //Serial.printf("counter: %d DIVIDE %d FLASH %d %d\r\n",counter, counter/SPEED_DIVIDE, counter/FLASH_SPEED_DIVIDE, flash);
    //AnimPixelsClear();
    //AnimPixelsFadeSub(16);
    AnimPixelsSpread(160);
    if ((flash==0) || ( _state == S_PLAY ) )
    {
      switch ( _state )
      {
        case S_PLAY:
        {
          if (gain > 0 )
          {
            //AnimPixelAddValue(key_down,NUM_NOTES,rgb_RED,rgb_BLACK);
            //AnimPixelAddValue(last_key_down,NUM_NOTES,rgb_BLUE,rgb_BLACK);
            //AnimPixelAddValue(raw_key_down,NUM_NOTES,rgb_GREEN,rgb_BLACK);
            rgb_t color = Rainbow(last_key_played,NUM_NOTES);
            color *= (uint16_t) gain;
            AnimPixelAddValue(last_key_played,NUM_NOTES,color,rgb_BLACK);
          }
          else
          {
            uint8_t small_counter = counter / SPEED_DIVIDE;
            
            //small_counter %= NUM_LEDS;
            rgb_t color = Rainbow(small_counter,NUM_LEDS-2);
            AnimPixelAddValue(small_counter,NUM_LEDS,color,rgb_BLACK);
            
          }
            
          break;
        }
        case S_PATCH_SELECT:
          AnimPixelAddRange(0,NUM_LEDS-1,rgb_BLUE);
          break;
        case S_PATCH_WRITE:
          AnimPixelAddRange(0,NUM_LEDS,rgb_RED);
          break;
        case S_PARAMETER_SELECT:
          AnimPixelAddRange(0,NUM_LEDS/2,rgb_GREEN);
          break;
        case S_PARAMETER_VALUE:
          AnimPixelAddRange(NUM_LEDS/2,NUM_LEDS,rgb_GREEN);
          break;
        case S_MODE_CHANGE:
          AnimPixelAddRange(0,NUM_LEDS/2,rgb_YELLOW);
          break;
        case S_MODE_VALUE:
          AnimPixelAddRange(NUM_LEDS/2,NUM_LEDS,rgb_YELLOW);
          break;
        default:
          break;
      }  
    }
    else if ( flash==2)
    {
    //Serial.printf("counter: %d DIVIDE %d FLASH %d\r\n",counter, counter/SPEED_DIVIDE, counter/FLASH_SPEED_DIVIDE);
      switch ( _state )
      {
        case S_PLAY:
        {
          break;
        }
        case S_PATCH_SELECT:
          AnimPixelAddValue(patch_number,NUM_NOTES,rgb_WHITE,rgb_GREY);
          break;
        case S_PATCH_WRITE:
          AnimPixelAddValue(patch_number,NUM_NOTES,rgb_WHITE,rgb_GREY);
          break;
        case S_PARAMETER_SELECT:
          break;
        case S_PARAMETER_VALUE:
          AnimPixelAddValue(parameter_number,NUM_NOTES,rgb_WHITE,rgb_GREY);
          break;
        case S_MODE_CHANGE:
          break;
        case S_MODE_VALUE:
          AnimPixelAddValue(mode_parameter_number,NUM_NOTES,rgb_WHITE,rgb_GREY);
          break;
        default:
          break;
      }  
    }
    else if ( flash==4)
    {
    //Serial.printf("counter: %d DIVIDE %d FLASH %d\r\n",counter, counter/SPEED_DIVIDE, counter/FLASH_SPEED_DIVIDE);
      switch ( _state )
      {
        case S_PLAY:
        {
          break;
        }
        case S_PATCH_SELECT:
          AnimPixelAddValue(patch_number,NUM_NOTES,rgb_WHITE,rgb_GREY);
          break;
        case S_PATCH_WRITE:
          AnimPixelAddValue(patch_number,NUM_NOTES,rgb_WHITE,rgb_GREY);
          break;
        case S_PARAMETER_SELECT:
          break;
        case S_PARAMETER_VALUE:
          AnimPixelAddValue(parameter_value,NUM_NOTES,rgb_WHITE,rgb_GREY);
          break;
        case S_MODE_CHANGE:
          break;
        case S_MODE_VALUE:
          AnimPixelAddValue(mode_value,NUM_NOTES,rgb_WHITE,rgb_GREY);
          break;
        default:
          break;
      }  
    }
    AnimSetStrip();
  }
};

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
    for(int i=0;i<NUM_PINS+1;i++)
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
    AnimUpdate();
    
    //led strip test
/*
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
*/
    
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
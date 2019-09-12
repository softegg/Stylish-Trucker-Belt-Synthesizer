//ws2812b setup
#include <WS2812B.h>
#define NUM_LEDS 16

WS2812B strip = WS2812B(NUM_LEDS);

#include "rgb.h"
#include "flashwriter_user.h"


#include <MozziGuts.h>
#include <Oscil.h> // oscillator template
#include <tables/saw2048_int8.h> // saw table for oscillator
#include <tables/square_no_alias_2048_int8.h> // square table for oscillator
#include <tables/triangle2048_int8.h> // sine table for oscillator
#include <tables/sin2048_int8.h> // sine table for oscillator
#include <LowPassFilter.h>

#include <mozzi_midi.h>
#include <mozzi_rand.h>
#include <ADSR.h>

#define FLASH_TOP (0x080020000)

//#define DEBUG_PRINTF Serial.printf
//#define DEBUG_APRINTLN Serial.println
//#define DEBUG_APRINT Serial.print
#define DEBUG_PRINTF( __xxx__, ...)
#define DEBUG_APRINTLN( __xxx__, ...)
#define DEBUG_APRINT( __xxx__, ...)


//#include "printf.h"
// use: Oscil <table_size, update_rate> oscilName (wavetable), look in .h file of table #included above
Oscil <SIN2048_NUM_CELLS, CONTROL_RATE> lfo(SIN2048_DATA);
Oscil <SQUARE_NO_ALIAS_2048_NUM_CELLS, AUDIO_RATE> osc1(SQUARE_NO_ALIAS_2048_DATA);
//Oscil <SAW2048_NUM_CELLS, AUDIO_RATE> osc1(SAW2048_DATA);
Oscil <SAW2048_NUM_CELLS, AUDIO_RATE> osc2(SAW2048_DATA);

// use #define for CONTROL_RATE, not a constant
//#define CONTROL_RATE 64 // Hz

#define CONTROL_RATE 256 // faster than usual to help smooth CONTROL_RATE adsr interpolation (next())

ADSR <CONTROL_RATE, CONTROL_RATE> envelope;

LowPassFilter lpf;

#define NUM_PATCHES (25)

uint8_t gain=0;
uint8_t note1_ofs=36;
uint8_t note2_ofs=43;
float   fine_freq1=-0.1;
float   fine_freq2=0.1;
uint8_t noise_max;
uint8_t filter_q=0;
uint8_t filter_f=0;
uint8_t lfo_rising_speed=0;
uint8_t pulse_width=0;
uint8_t env_to_pitch1=0.0f;
uint8_t env_to_pitch2=0.0f;
uint8_t env_to_pwm=0;
uint8_t env_to_noise=0;
uint8_t lfo_to_filter=0;
float lfo_to_pitch=0.0f;
uint8_t lfo_to_volume=0;
uint8_t lfo_to_pwm=0;
uint8_t lfo_to_noise=0;
uint8_t balance=0;
float   lfo_pitch_add=0.0f;
float   env_sustain_pitch_sub=0.0f;

float osc1_freq=0.0f;
float osc2_freq=0.0f;
uint8_t noise_gain=255;


uint8_t patch_number=0;
uint8_t last_patch_number=0;
uint8_t parameter_number=0;
bool patch_number_changed = false;
uint8_t current_mode_button = 0;
uint8_t mode_parameter_number=0;
uint8_t mode_value=0;
uint8_t parameter_value=0;

uint8_t last_ui_value=0;
bool note_off_processed = false;


// patch structure
// 26 parameters packed into 
#define NUM_PATCH_PARAMETERS (26)
#define LAST_PATCH_PARAMETER_NUMBER (NUM_PATCH_PARAMETERS-1)

enum e_PATCH_WAVEFORMS
{
  PPW_SAW,
  PPW_SQUARE,
  PPW_TRI,
  PPW_SINE,
};

enum ePATCH_PARAMS
{
  PP_WAVE1,       // waveform + octave
   PP_NOTE1,       // note
  PP_WAVE2,       // waveform + octave
   PP_NOTE2,       // note
  PP_NOISE,       // amount of noise  
  
  PP_DETUNE,      // fine pitch difference between oscillators   
   PP_ATTACK,      // ADSR envelope
  PP_DECAY,       // ADSR envelope
   PP_SUSTAIN,     // ADSR envelope
  PP_RELEASE,     // ADSR envelope  
   PP_FILTER_Q,    // Filter resonance  
  PP_FILTER_F,    // filter frequency  
  
  
  PP_LFO_WAVE,    // Waveform for LFO
   PP_LFO_FREQ,    // Frequency for LFO
  PP_LFO_RAMP,    // start speed of LFO
   PP_PULSE_WIDTH, // pulse width for square waves  
  PP_ENV_FILTER,  // amount of envelope applied to filter  
  
  PP_ENV_PITCH,   // amount of envelope applied to pitch of oscillators
   PP_ENV_PULSE_WIDTH, //amount of envelope to pulse width
  PP_ENV_NOISE,   // amount of envelope to noise
   PP_LFO_FILTER,  // amount of LFO applied to filter
  PP_LFO_PITCH,   // amount of LFO applied to pitch
   PP_LFO_VOLUME,  // amount of LFO applied to volume
  PP_LFO_PULSE_WIDTH, //amount of LFO to pulse width
  
  
  PP_LFO_NOISE,   // amount of LFO to noise
  PP_BALANCE,     // relative volume of wave 1 to wave 2
  PP_NUM_PARAMETERS  
};

__attribute__ ((aligned (4))) uint8_t LocalPatchData[ NUM_PATCH_PARAMETERS ];
__attribute__ ((aligned (4))) uint8_t LocalPatchDataBackup[ NUM_PATCH_PARAMETERS ];

__attribute__ ((aligned (4))) uint8_t internal_patch_data[25][16]={
{0x18,0x06,0x70,0x10,0x10,0xc5,0x40,0x99,0x00,0x03,0x00,0x00,0x64,0x00,0x00,0x00},
{0xa8,0x2a,0xc4,0x90,0x10,0xc0,0x00,0x99,0x00,0x03,0x00,0x00,0x60,0x00,0x00,0x00},
{0x48,0x12,0x7f,0x00,0x23,0x59,0xc0,0x99,0x00,0x03,0x00,0x00,0x60,0x00,0x00,0x00},
{0x48,0x12,0xcf,0x11,0x50,0xc5,0x40,0x99,0x00,0x03,0x00,0x00,0x60,0x00,0x00,0x00},
{0x48,0x12,0x7f,0x10,0x10,0xc5,0x41,0x59,0x00,0x03,0x00,0x00,0x60,0x00,0x00,0x00},
{0x50,0x14,0x00,0x0c,0x15,0xc1,0x53,0x6c,0x00,0x00,0xc0,0x00,0x60,0x00,0x00,0x00},
{0x70,0x2a,0x74,0x90,0x10,0xc5,0x81,0x89,0x00,0x03,0xc0,0x00,0x64,0x00,0x00,0x00},
{0x2e,0x0a,0x5f,0x11,0x10,0xc1,0x40,0x09,0x00,0x03,0x00,0x00,0x64,0x30,0x00,0x00},
{0x48,0x12,0x77,0x12,0x70,0xc5,0x47,0x79,0x00,0x03,0x00,0x00,0x60,0x00,0x00,0x00},
{0x50,0x14,0x00,0x0c,0x15,0x4c,0xd3,0x8c,0x1c,0x00,0xc0,0x00,0x69,0xc4,0x00,0x00},
{0x10,0x1d,0x0f,0x02,0xb7,0x85,0xc0,0x9a,0x84,0x03,0x00,0x00,0x64,0x00,0x00,0x00},
{0x30,0x0c,0x0f,0x10,0x02,0x00,0xb1,0x49,0x00,0x03,0x00,0x00,0x64,0x00,0x00,0x00},
{0x30,0x0c,0x0c,0x10,0x0b,0x02,0xf0,0x09,0x00,0x03,0x00,0x00,0x64,0x00,0x00,0x00},
{0x18,0x06,0x07,0x0a,0x70,0xc4,0x41,0x73,0x9c,0x03,0xc0,0x00,0x64,0x60,0x00,0x00},
{0x18,0x06,0x70,0x10,0x17,0x2d,0x41,0x8a,0xb4,0x03,0xc0,0x00,0x64,0x1c,0x00,0x00},
{0x18,0x06,0x00,0x10,0x10,0xc5,0x4f,0x80,0x28,0x03,0x00,0x00,0x64,0x03,0x18,0x00},
{0x18,0x06,0x70,0x10,0x10,0xc5,0x40,0x99,0x00,0x03,0x03,0x00,0x64,0x00,0x00,0x00},
{0x30,0x0c,0x0c,0x10,0x17,0x02,0xf0,0x09,0x00,0x03,0x00,0x00,0x64,0x00,0x00,0x00},
{0x20,0x12,0x0f,0x04,0x10,0xc5,0x40,0x97,0x24,0x03,0xc0,0x00,0x60,0x24,0x00,0x00},
{0x48,0x14,0x4f,0x04,0x10,0xc0,0x00,0x93,0x9c,0x03,0xc0,0x01,0x20,0x5c,0x00,0x00},
{0x78,0x22,0xcf,0x10,0x09,0x02,0x40,0x99,0x00,0x03,0x00,0x00,0x64,0x00,0x00,0x00},
{0x20,0x08,0xc0,0x10,0x11,0x04,0xc1,0x18,0x94,0x03,0xc0,0x00,0x64,0xcc,0x00,0x00},
{0x00,0x00,0x7c,0x10,0x10,0xc5,0x40,0x9a,0x80,0x03,0x06,0x00,0x64,0x80,0x00,0x00},
{0x28,0x1c,0x00,0x11,0x70,0xc3,0x01,0x88,0x9c,0x03,0xc0,0x00,0x63,0x80,0x00,0x00},
{0x48,0x16,0x00,0x04,0x53,0x80,0x00,0x59,0x28,0x03,0x00,0x00,0x60,0x14,0x00,0x00},
};

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
  
  void Echo()
  {
    uint32_t patch_num_calculate = ( (uint32_t) this - (uint32_t) internal_patch_data ) / 16;
    
    DEBUG_PRINTF("Patch[%d].values=\r\n{",patch_num_calculate);
    for( uint8_t i=0; i < 16; i++ )
    {
      DEBUG_PRINTF("0x%02X,",values[i]);
    }
    DEBUG_PRINTF("\r\n");
  }
  
  void GetAllToLocal()
  {
    DEBUG_PRINTF("GetAllToLocal\r\n");
    for( uint8_t i=0; i < NUM_PATCH_PARAMETERS; i++ )
    {
      LocalPatchData[i] = Get( i );
    }
    Echo();
  }
  
  void SetAllFromLocal()
  {
    DEBUG_PRINTF("SetAllFromLocal\r\n");
    for( uint8_t i=0; i < NUM_PATCH_PARAMETERS; i++ )
    {
      Set( i, LocalPatchData[i] );
    }
   
    Echo();
  }  
};



patch_t * Patch = (patch_t *) internal_patch_data;
//[NUM_PATCHES];

uint32_t * FlashAddress = NULL;

#define NUMBER_MODE_VALUES (25)

__attribute__ ((aligned (4))) uint8_t ModeData[NUMBER_MODE_VALUES];

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
uint16_t env_to_filter=0;
char MAGIC[] = "STYLISH1";

void SetFlashAddress()
{
  setupFLASH();    
  FlashAddress = (uint32_t *) (getFlashEnd() - getFlashPageSize());
  DEBUG_PRINTF("FlashAddress: 0x%08X\r\n",(uint32_t)FlashAddress);
};

void WritePatchesToFlash()
{
  uint32_t * writeAddress = FlashAddress;
  //write to flash
  flashUnlock();
  flashErasePage( (uint32_t) writeAddress );
  
  uint32_t * source = (uint32_t *)internal_patch_data;
  DEBUG_PRINTF("WritePatchesToFlash: 0x%l08X <- 0x%l08x\r\n",(uint32_t)FlashAddress,(uint32_t)source);
  DEBUG_APRINTLN((uint32_t)FlashAddress,HEX);
  DEBUG_APRINTLN((uint32_t)source,HEX);
  
  for( uint16_t i=0; i < sizeof(patch_t)*NUM_PATCHES/4; i++ )
  {
    flashWriteWord((u32)(writeAddress++), *(u32 *)(source +i));      
  } 
  //write magic number
  source = (u32*) MAGIC;
  flashWriteWord((u32)(writeAddress++), *(u32 *)(source++));      
  flashWriteWord((u32)(writeAddress++), *(u32 *)(source++));      
  flashLock();    
};

void ReadPatchesFromFlash()
{
  uint32_t * magic = (uint32_t *) MAGIC;
  uint32_t byte_count = (sizeof(patch_t)*NUM_PATCHES);
  DEBUG_PRINTF("ReadPatchesFromFlash: 0x%l08X -> 0x%l08x  (%d)\r\n",FlashAddress,internal_patch_data, byte_count);
  if (( FlashAddress[byte_count/4]==magic[0]) && ( FlashAddress[(byte_count/4)+1]==magic[1]))
  {
    DEBUG_PRINTF("MAGIC detected!\r\n");
  }
  else return;  
  
  DEBUG_APRINTLN((uint32_t)FlashAddress,HEX);
  DEBUG_APRINTLN((uint32_t)internal_patch_data,HEX);
  memcpy(internal_patch_data,FlashAddress, byte_count );
  
  uint8_t * patch_data = (uint8_t*) internal_patch_data;
  for(int i=0; i< byte_count; i++){
    DEBUG_PRINTF("0x%02x,",*patch_data++);
    if ( ((i+1)%16) == 0 )
    {
      DEBUG_PRINTF("\r\n");
    }
  }
/*  
  for( int i=0; i< NUM_PATCHES; i++)
  {
    patch_number = i;
    Patch[i].GetAllToLocal();
    uint8_t oct = LocalPatchData[PP_WAVE1]/3;
    uint8_t wave = LocalPatchData[PP_WAVE1]%3;
    if (oct>5) oct=5;
    LocalPatchData[PP_WAVE1]=oct+wave*6;
    oct = LocalPatchData[PP_WAVE2]/3;
    wave = LocalPatchData[PP_WAVE2]%3;
    if (oct>5) oct=5;
    LocalPatchData[PP_WAVE1]=oct+wave*6;    
  }
  WritePatchesToFlash();
*/  
};


int8_t Noise()
{
  uint16_t noise_now = noise_gain * noise_max;
  noise_now >>=8;

  return( rand(noise_now) );
}

const unsigned int AttackTimes[25]={/*0,*/ 10,20,40,60, 80,100,110,120,130, 140,160,180,200,250, 300,400,500,600,700, 800,900,1000,2500,5000, 8000};
const unsigned int DecayTimes[25] ={/*0,*/ 10,20,40,60, 80,100,110,120,130, 140,160,180,200,250, 300,400,500,600,700, 800,900,1000,2500,5000, 8000};
const float LFOFreqencies[25]={0.1f,0.2f,0.3f,0.4f,0.5f, 0.6f,0.7f,0.8f,0.9,1.0f, 1.5f,1.6667f,2.0f,2.2167f,2.3333f, 2.6667f,3.0f,3.3333f, 3.6667f,4.0f, 6.0f,8.0f,10.0f,15.0f,20.0f};
const float LFOPitches[25]={0.00f,0.025f,0.05f,0.075f,0.1f,  0.15f,0.2f,0.25f,0.3f,0.35f, 0.4f,0.45f,0.5f,0.55f,0.6f, 0.7f,0.75f,0.8f,0.9f,1.0f,  2.0f,3.0f,5.0f,7.0f,12.0f};
const float EnvPitch1[25] ={0.0f, 0.035f,0.07f,0.1f,0.2f,0.4f, 0.8f,1.0f,3.0f,4.0f,5.0f, 7.0f,12.0f,0.035f,0.07f,0.1f, 0.2f,0.4f,0.8f,1.0f,3.0f, 4.0f,5.0f,7.0f,12.0f};
const float EnvPitch2[25]={0.0f, 0.035f,0.07f,0.1f,0.2f,0.4f, 0.8f,1.0f,3.0f,4.0f,5.0f, 7.0f,12.0f,0.000f,0.00f,0.0f, 0.0f,0.0f,0.0f,0.0f,0.0f, 0.0f,0.0f,0.0f,00.0f};

uint8_t MapValToByte( uint8_t value, uint8_t min=0, uint8_t max=255 );

uint8_t MapValToByte( uint8_t value, uint8_t min, uint8_t max )
{
  //return ( (value*10)+(value*3/5) );
  float work = (float)max - (float) min;
  work /=25.0f;
  work *= (float) value;
  work += (float) min;
  if ( work > 255.0f ) work = 255.0f;
  else if (work < 0.0f ) work = 0.0f;
  return( (uint8_t) work );  
}


//sets values in local patch data (unpacked) array
//and updates system stuff to implement the change
void SetLocalPatchData(uint8_t param, uint8_t value)
{
  LocalPatchData[param]=value;
  switch(param)
  {
    case PP_WAVE1:       // waveform + octave
    case PP_NOTE1:       // note
    {
      uint8_t oct = LocalPatchData[PP_WAVE1]%6;
      uint8_t wave = LocalPatchData[PP_WAVE1]/6;
      DEBUG_PRINTF("PP_WAVE1 or PP_NOTE1 oct=%d wave=%d\r\n",oct,wave);
      switch ( wave )
      {
        case PPW_SAW:
          osc1.setTable( SAW2048_DATA );
          break;
        case PPW_SQUARE:
          osc1.setTable( SQUARE_NO_ALIAS_2048_DATA );
          break;
        case PPW_TRI:
          osc1.setTable( TRIANGLE2048_DATA );
          break;
        case PPW_SINE:
        default:
          osc1.setTable( SIN2048_DATA );
          break;
      }
      note1_ofs = (LocalPatchData[PP_NOTE1]+1)+oct*12;      
      break;
    }
    case PP_WAVE2:       // waveform + octave
    case PP_NOTE2:       // note
    {
      uint8_t oct = LocalPatchData[PP_WAVE2]%6;
      uint8_t wave = LocalPatchData[PP_WAVE2]/6;
      DEBUG_PRINTF("PP_WAVE2 or PP_NOTE2 oct=%d wave=%d\r\n",oct,wave);
      switch ( wave )
      {
        case PPW_SAW:
          osc2.setTable( SAW2048_DATA );
          break;
        case PPW_SQUARE:
          osc2.setTable( SQUARE_NO_ALIAS_2048_DATA );
          break;
        case PPW_TRI:
          osc2.setTable( TRIANGLE2048_DATA );
          break;
        case PPW_SINE:
        default:
          osc2.setTable( SIN2048_DATA );
          break;
      }
      note2_ofs = (LocalPatchData[PP_NOTE2]+1)+oct*12;      
      break;
    }
    case PP_NOISE:       // amount of noise
      noise_max = value * 10; // close enough...
      DEBUG_PRINTF("Noise:%d noise_max:%d\r\n",value,noise_max);
      break;  
    case PP_DETUNE:      // fine pitch difference between oscillators   
    {
      float detune_amt = (float) value / 51.0f;
      fine_freq1 = detune_amt;
      fine_freq2 = -1.0 *detune_amt;
      break;
    }
    case PP_ATTACK:      // ADSR envelope
      envelope.setAttackLevel(255);
      envelope.setAttackTime(AttackTimes[value]);
      DEBUG_PRINTF("Attack: %d = %dms\r\n",value, AttackTimes[value]);      
      break;
    case PP_DECAY:       // ADSR envelope
      envelope.setDecayLevel(MapValToByte(LocalPatchData[PP_SUSTAIN]));
      envelope.setDecayTime(DecayTimes[value]);    
      DEBUG_PRINTF("Decay: %d = %dms\r\n",value, AttackTimes[value]);      
      break;
    case PP_SUSTAIN:     // ADSR envelope
    {
      uint8_t level = MapValToByte(value);
      envelope.setSustainLevel( level );
      envelope.setDecayLevel( level );
      envelope.setSustainTime(0xFFFFFFFF);
      DEBUG_PRINTF("Sustain: %d = %d\r\n",value, level);      
      env_sustain_pitch_sub = (float) level;
      break;
    }
    case PP_RELEASE:     // ADSR envelope
      envelope.setReleaseLevel(0);
      envelope.setReleaseTime(DecayTimes[value]);
      DEBUG_PRINTF("Release: %d = %dms\r\n",value, AttackTimes[value]);            
      break;
    case PP_FILTER_Q:    // Filter resonance
      filter_q = MapValToByte(value,255,1);
      lpf.setResonance(filter_q);
      DEBUG_PRINTF("Filter Resonance:%d %d\r\n",value,filter_q);
      break;
    case PP_FILTER_F:    // filter frequency  
      filter_f = MapValToByte(value,255,1);
      lpf.setCutoffFreq(filter_f);
      DEBUG_PRINTF("Filter Frequency:%d %d\r\n",value, filter_f);
      break;
    case PP_LFO_WAVE:    // Waveform for LFO
    {      
      uint8_t wave = value/6;
      uint8_t val2 = value%6;
      switch ( wave )
      {
        case PPW_SAW:
          lfo.setTable( SAW2048_DATA );
          lfo_pitch_add = 0.0f;
          break;
        case PPW_SQUARE:
          lfo.setTable( SQUARE_NO_ALIAS_2048_DATA );
          lfo_pitch_add = 1.0f;
          break;
        case PPW_TRI:
          lfo.setTable( TRIANGLE2048_DATA );
          lfo_pitch_add = 0.0f;
          break;          
        case PPW_SINE:
        default:
          lfo.setTable( SIN2048_DATA );
          lfo_pitch_add = 0.0f;
          break;
      }
      break;
    }
    case PP_LFO_FREQ:    // Frequency for LFO
    {
      lfo.setFreq(LFOFreqencies[value]);
      break;
    }
    case PP_LFO_RAMP:    // start rising speed of LFO
      lfo_rising_speed= MapValToByte(value,0,255);
      DEBUG_PRINTF("LFO rising speed: %d %d\r\n",value, lfo_rising_speed);
      break;
    case PP_PULSE_WIDTH: // pulse width for square waves
      pulse_width= MapValToByte(value,0,255);
      DEBUG_PRINTF("Pulse Width: %d %d\r\n",value, pulse_width);
      break;
    case PP_ENV_FILTER:  // amount of envelope applied to filter  
      env_to_filter= MapValToByte(value,0,255);
      DEBUG_PRINTF("Envelope to Filter: %d %d\r\n",value, env_to_filter);
      break;
    case PP_ENV_PITCH:   // amount of envelope applied to pitch of oscillators
      env_to_pitch1= EnvPitch1[value];
      env_to_pitch2= EnvPitch2[value];
      DEBUG_PRINTF("Envelope to Pitch: %d",value);
      DEBUG_APRINT(env_to_pitch1);
      DEBUG_PRINTF(",");
      DEBUG_APRINT(env_to_pitch2);
      DEBUG_PRINTF("\r\n");
      break;
    case PP_ENV_PULSE_WIDTH: //amount of envelope to pulse width
      env_to_pwm= MapValToByte(value,0,255);
      DEBUG_PRINTF("Envelope to PWM: %d %d\r\n",value, env_to_pwm);
      break;
    case PP_ENV_NOISE:   // amount of envelope to noise
      env_to_noise= MapValToByte(value,0,255);
      DEBUG_PRINTF("Envelope to Noise: %d %d\r\n",value, env_to_noise);
      break;
    case PP_LFO_FILTER:  // amount of LFO applied to filter
      lfo_to_filter= MapValToByte(value,0,255);
      DEBUG_PRINTF("LFO to Filter: %d %d\r\n",value, lfo_to_filter);
      break;
    case PP_LFO_PITCH:   // amount of LFO applied to pitch
      lfo_to_pitch= LFOPitches[value];
      DEBUG_PRINTF("LFO to Pitch: %d %f\r\n",value, lfo_to_pitch);
      break;
    case PP_LFO_VOLUME:  // amount of LFO applied to volume
      lfo_to_volume= MapValToByte(value,0,255);
      DEBUG_PRINTF("LFO to Volumd: %d %d\r\n",value, lfo_to_volume);
      break;
    case PP_LFO_PULSE_WIDTH: //amount of LFO to pulse width
      lfo_to_pwm= MapValToByte(value,0,255);
      DEBUG_PRINTF("LFO to PWM: %d %d\r\n",value, lfo_to_pwm);
      break;
    case PP_LFO_NOISE:   // amount of LFO to noise
      lfo_to_noise= MapValToByte(value,0,255);
      DEBUG_PRINTF("LFO to noise: %d %d\r\n",value, lfo_to_noise);
      break;
    case PP_BALANCE:     // relative volume of wave 1 to wave 2
      balance= MapValToByte(value,0,255);
      DEBUG_PRINTF("Balance: %d %d\r\n",value, balance);
      break;
    case PP_NUM_PARAMETERS:
    default:
      break;
  }
}

//process every parameter in the local patch data
void UpdateAllLocalPatchData()
{
  for (uint8_t i=0; i < NUM_PATCH_PARAMETERS; i++ )
  {
    SetLocalPatchData( i, LocalPatchData[ i ] );
  }
}

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
  DEBUG_PRINTF("Set State: %s\r\n", UI_State_Strings[ state ] );
}

eUI_States Get_UI_State(bool echo = true);

eUI_States Get_UI_State(bool echo)
{
  if ( echo )
  {
    DEBUG_PRINTF("Get State: %s\r\n", UI_State_Strings[ state ] );
  }
  return( state );
}

void Set_UI_SubState(eUI_SubStates _subState)
{
  subState = _subState;
  DEBUG_PRINTF("Set SubState: %s\r\n", UI_SubState_Strings[ subState ] );
};

eUI_SubStates Get_UI_SubState(bool echo = true);

eUI_SubStates Get_UI_SubState(bool echo)
{
  if ( echo )
  {
    DEBUG_PRINTF("Get SubState: %s\r\n", UI_SubState_Strings[ subState ] );
  }
  return( subState );
};


void StylusKeyboardSetup()
{
  DEBUG_PRINTF("Stylus Keyboard Setup\r\n");
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
  osc1_freq = mtof(float(key+note1_ofs+fine_freq1));
  osc2_freq = mtof(float(key+note2_ofs+fine_freq2));
  osc1.setFreq(osc1_freq);
  osc2.setFreq(osc2_freq);
  envelope.noteOn();
  DEBUG_PRINTF("Note on:%d \r\n",key);
//  gain = 255;        
}

void SoundKeyUp()
{
  //key_down = NOT_PRESSED;
  envelope.noteOff();
  //DEBUG_PRINTF("Note off\r\n");
}

void SoundRetrigger()
{
  SoundKeyDown( last_key_played );
}


//fetch the value for current UI state
uint8_t GetUIValue()
{
  switch ( Get_UI_State() )
  {
    case S_PLAY:
      DEBUG_PRINTF("GetUIValue: PLAY key_down = %d\r\n",key_down);
      return (key_down);
      break;
    case S_PATCH_SELECT:
      DEBUG_PRINTF("GetUIValue: PATCH_SELECT patch_number = %d\r\n",patch_number);
      return( patch_number );
      break;
    case S_PATCH_WRITE:
      DEBUG_PRINTF("GetUIValue: PATCH_WRITE patch_number = %d\r\n",patch_number);
      return( patch_number );
      break;
    case S_PARAMETER_SELECT:
      DEBUG_PRINTF("GetUIValue: PARAMETER_SELECT parameter_number = %d\r\n",parameter_number);
      return( parameter_number );
      break;
    case S_PARAMETER_VALUE:
      DEBUG_PRINTF("GetUIValue: PARAMETER_VALUE(%d)=%d\r\n",parameter_number, LocalPatchData[ parameter_number ] );
      return( LocalPatchData[ parameter_number ] );
      break;
    case S_MODE_CHANGE:
      DEBUG_PRINTF("GetUIValue: MODE_CHANGE mode_parameter_number = %d\r\n",mode_parameter_number);
      return( mode_parameter_number );
      break;
    case S_MODE_VALUE:
      DEBUG_PRINTF("GetUIValue: MODE_VALUE(%d)=%d\r\n",mode_parameter_number, ModeData[ mode_parameter_number ] );
      return( ModeData[ mode_parameter_number ] );
      break;
    case S_NUM_STATES:
    default:
      DEBUG_PRINTF("ERROR: GetUIValue with invalid UI State\r\n");
      Get_UI_State();
      return(0);
      break;      
  }
}

//set the value for current UI state on value change
void SetUIValue(uint8_t value )
{
  switch ( Get_UI_State() )
  {
    case S_PLAY:
      key_down = value;
      DEBUG_PRINTF("SetUIValue: PLAY key_down = %d\r\n",key_down);
      break;
    case S_PATCH_SELECT:      
      patch_number = value;
      DEBUG_PRINTF("SetUIValue: PATCH_SELECT patch_number = %d\r\n", patch_number);
      //copy to synth local unpacked parameters here
      Patch[patch_number].GetAllToLocal();
      UpdateAllLocalPatchData();
      break;
    case S_PATCH_WRITE:
      patch_number = value;
      DEBUG_PRINTF("SetUIValue: PATCH_WRITE patch_number = %d\r\n", patch_number);
      //copy current patch parameters into new patch area.
      Patch[patch_number].GetAllToLocal();
      UpdateAllLocalPatchData();
//      Patch[patch_number].SetAllFromLocal();
      break;
    case S_PARAMETER_SELECT:
      parameter_number = value;
      parameter_value = LocalPatchData[ parameter_number ];
      DEBUG_PRINTF("SetUIValue: PARAMETER_SELECT parameter_number = %d\r\n", parameter_number);
      break;
    case S_PARAMETER_VALUE:
      DEBUG_PRINTF("SetUIValue: PARAMETER_VALUE(%d)=%d\r\n", parameter_number, value);
      //set local patch value
      //LocalPatchData[ parameter_number ] = value;
      SetLocalPatchData( parameter_number, value );
      parameter_value = value;
      break;
    case S_MODE_CHANGE:
      mode_parameter_number = value;
      mode_value = ModeData[ mode_parameter_number ]/10;
      DEBUG_PRINTF("SetUIValue: MODE_CHANGE mode_parameter_number = %d\r\n", mode_parameter_number);
      break;
    case S_MODE_VALUE:
      ModeData[ mode_parameter_number ] = MapValToByte(value,0,255);
      mode_value = value;
      DEBUG_PRINTF("SetUIValue: MODE_VALUE(%d)=%d\r\n", mode_parameter_number, ModeData[ mode_parameter_number ] );
      break;
    case S_NUM_STATES:
    default:
      DEBUG_PRINTF("ERROR: SetUIValue with invalid UI State\r\n");
      Get_UI_State();
      break;      
  }
}

//backup value of current UI state in case abort.
void SaveUIValue()
{
  last_ui_value = GetUIValue();
  
  //for patch write, it will overwrite local patch data to play sound.
  //keep a copy of the patch for write / abort
  if ( Get_UI_State() == S_PATCH_WRITE )
  {
    DEBUG_PRINTF("save_ui_value: Backup Local Patch Data\r\n");
    memcpy(LocalPatchDataBackup, LocalPatchData, sizeof(LocalPatchData));
    //UpdateAllLocalPatchData();
  }
}

//restore value of current UI state in case abort
void RestoreUIValue()
{
  SetUIValue( last_ui_value );

  //for patch write, it will overwrite local patch data to play sound.
  //move the patch data backup back to local memory.
  if ( Get_UI_State() == S_PATCH_WRITE )
  {
    memcpy(LocalPatchData, LocalPatchDataBackup, sizeof(LocalPatchData));
    UpdateAllLocalPatchData();
  }
}

//when state is completed successfully, do this
void FinalizeUIValue()
{
 switch ( Get_UI_State() )
  {
    case S_PLAY:
      DEBUG_PRINTF("FinalizeUIValue: PLAY\r\n");
      //not really anything to do here?
      break;
    case S_PATCH_SELECT:            
      DEBUG_PRINTF("FinalizeUIValue: PATCH_SELECT patch_number = %d\r\n", patch_number);
      //patch data should already have been loaded by earlier state, so nothing to do to keep it
      break;
    case S_PATCH_WRITE:
      DEBUG_PRINTF("FinalizeUIValue: PATCH_WRITE patch_number = %d\r\n", patch_number);
      //copy the backup patch data back to the local storage
      memcpy(LocalPatchData, LocalPatchDataBackup, sizeof(LocalPatchData));
      DEBUG_PRINTF("LocalPatchData={");
      for( uint8_t i=0; i< NUM_PATCH_PARAMETERS; i++ )
      {
        DEBUG_PRINTF("%d,",LocalPatchData[i]);        
      }
      DEBUG_PRINTF("\r\n");
      //process the local patch data so synth can run it.
      UpdateAllLocalPatchData();      
      //store into the packed patch data
      Patch[patch_number].SetAllFromLocal();     
      WritePatchesToFlash();
      break;
    case S_PARAMETER_SELECT:
      DEBUG_PRINTF("FinalizeUIValue: PARAMETER_SELECT parameter_number = %d\r\n", parameter_number);
      //nothing to do
      break;
    case S_PARAMETER_VALUE:
      DEBUG_PRINTF("FinalizeUIValue: PARAMETER_VALUE(%d)=%d\r\n", parameter_number, parameter_value);
      //nothing to do
      break;
    case S_MODE_CHANGE:
      DEBUG_PRINTF("FinalizeUIValue: MODE_CHANGE mode_parameter_number = %d\r\n", mode_parameter_number);
      //nothing to do
      break;
    case S_MODE_VALUE:
      DEBUG_PRINTF("FinalizeUIValue: MODE_VALUE(%d)=%d\r\n", mode_parameter_number, ModeData[ mode_parameter_number ] );
      //nothing to do
      break;
    case S_NUM_STATES:
    default:
      DEBUG_PRINTF("ERROR: FinalizeUIValue with invalid UI State\r\n");
      Get_UI_State();
      break;      
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
        //DEBUG_APRINT("Patch selected:");
        //DEBUG_APRINTLN(patch_number);
        //patch_number = key;
        SetUIValue(key);
        //set patch data here
        SoundKeyDown(key);
        Set_UI_SubState(SS_SELECT_PLAYING_VALUE_AUDITION);
      }
      else if ( key == current_mode_button )  //pressed current mode button, so write value
      {
        //DEBUG_APRINT("Patch confirmed:");
        //DEBUG_APRINTLN(patch_number);
        //last_patch_number = patch_number;
        //SaveUIValue();
        FinalizeUIValue();
        Set_UI_SubState(SS_SELECT_DONE_SELECTING_DOWN);
      }
      else  //selected some other button, abort
      {
        //DEBUG_APRINT("Patch aborted:");
        //patch_number = last_patch_number;
        //DEBUG_APRINTLN(patch_number);
        RestoreUIValue();
        Set_UI_SubState( SS_SELECT_ABORT_DOWN );          // set substate      
      }
      break;
      
    //below are set on key down, so probably shouldn't end up here.
    case SS_SELECT_PLAYING_VALUE_AUDITION:
    case SS_SELECT_DONE_SELECTING_DOWN:
    case SS_SELECT_ABORT_DOWN:
      DEBUG_PRINTF("ERROR! Got SubStateKeyDown on a state that shouln't get it!\r\n");
      Get_UI_SubState();
      break;
    case SS_NUM_STATES:
    default:
      DEBUG_PRINTF("ERROR! BAD SUBSTATE In SubStateKeyUp!\r\n");
      DEBUG_APRINTLN(Get_UI_SubState());
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
      DEBUG_PRINTF("ERROR! BAD SUBSTATE In SubStateKeyUp! %d\r\n", Get_UI_SubState());
      Set_UI_State( S_PLAY );
      Set_UI_SubState( SS_UP );
      break;
  }
}


void ReceiveKeyDown(uint8_t key )
{

  DEBUG_APRINT("Key Down ");
  DEBUG_APRINT(key,DEC);
  DEBUG_APRINTLN(".");
  
  switch ( Get_UI_State() )
  {
    case S_PLAY:
      if ( key < NUM_NOTES )
      {
        SoundKeyDown(key);
      }
      else
      {
        DEBUG_PRINTF("Button down!\r\n");
        switch( key )
        {
          case PATCH_BUTTON:        
          DEBUG_PRINTF("Patch!\r\n");
            //last_patch_number = patch_number;   // save the patch number in case of abort
            //patch_number_changed = false;       // clear patch change flag
            current_mode_button = PATCH_BUTTON; // save button for comparison in substate code
            Set_UI_State( S_PATCH_SELECT );             // set state
            Set_UI_SubState( SS_SELECT_DOWN );          // set substate
            SaveUIValue();
            break;
          case WRITE_BUTTON: 
            DEBUG_PRINTF("Write!\r\n");
            //last_patch_number = patch_number;   // save the patch number in case of abort
            current_mode_button = WRITE_BUTTON; // save button for comparison in substate code
            Set_UI_State( S_PATCH_WRITE );              // set state
            Set_UI_SubState( SS_SELECT_DOWN );          // set substate
            SaveUIValue();            
            break;
          case VALUE_BUTTON: 
            DEBUG_PRINTF("Value!\r\n");
            current_mode_button = VALUE_BUTTON; // save button for comparison in substate code
            Set_UI_State( S_PARAMETER_SELECT );         // set state
            Set_UI_SubState( SS_SELECT_DOWN );          // set substate
            break;
          case MODE_BUTTON:
            DEBUG_PRINTF("Mode!\r\n");
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
  DEBUG_APRINT("Key Up ");
  DEBUG_APRINT(key,DEC);
  DEBUG_APRINTLN(".");
  SubStateKeyUp(key);
  //SoundKeyUp();
}

//Mozzi

void updateControl(){
  // put changing controls in here
  envelope.update();
  uint8_t env = envelope.next();
  
  gain= env;
  
  int8_t lfo_raw = lfo.next();
  
  int16_t filter_lfo = (int16_t)lfo_raw * lfo_to_filter;
  filter_lfo>>=8;
  
  int32_t lfo_gain = lfo_raw+128;
  if ( lfo_gain > 255) lfo_gain = 255;
  if ( lfo_gain < 0 ) lfo_gain = 0;

  noise_gain *= lfo_to_noise;
  noise_gain>>=8;
  noise_gain = 255 - noise_gain;
 
  lfo_gain *=lfo_to_volume;
  lfo_gain>>=8;
  lfo_gain =255- lfo_gain;
  
  uint16_t gain_calc = (uint16_t) gain * lfo_gain;
  gain = gain_calc >> 8;
  
  //filter math
  uint32_t filter_calc = env_to_filter+filter_lfo;
  filter_calc *= (uint16_t) env;
  filter_calc >>=8;
  filter_calc+= (uint16) filter_f;
  if ( filter_calc > 255 )
    filter_calc=255;
  
  float lfo_amt = (float) lfo_raw;
  lfo_amt/=256.0f;
    
  float lfo_pitch = lfo_to_pitch * (lfo_amt+ lfo_pitch_add);

  //sustain is note pitch for pitch env
  float pitchenvmod = ((float)env - env_sustain_pitch_sub)/256.0f; 

  float env_pitch1mod = (env_to_pitch1 * pitchenvmod);
  float env_pitch2mod = (env_to_pitch2 * pitchenvmod);

  osc1_freq = mtof(float(last_key_played+note1_ofs+fine_freq1+lfo_pitch+env_pitch1mod));
  osc2_freq = mtof(float(last_key_played+note2_ofs+fine_freq2+lfo_pitch+env_pitch2mod));
  osc1.setFreq(osc1_freq);
  osc2.setFreq(osc2_freq);

    
  lpf.setCutoffFreq(filter_calc);
}


int updateAudio(){
  int osc2value = osc2.next();
  return lpf.next(((osc1.next()+osc2value+(osc2value*Noise()>>7))*gain)>>9); // return an int signal centred around 0
}


#define SPEED_DIVIDE (1000)
#define FLASH_SPEED_DIVIDE (5000)

//#define WAIT_FOR_SERIAL (true)

void setup() {
  //Setup Serial at max baud rate and wait till terminal connects before starting output
  ModeData[0]=224;
  Serial.begin(115200);  
  
#ifdef WAIT_FOR_SERIAL  
  while (!Serial)
  {
    digitalWrite(33,!digitalRead(33));// Turn the LED from off to on, or on to off
    delay(100);         // fast blink
  }  
#endif  
  SetFlashAddress();  

  
  strip.begin();// Sets up the SPI
  strip.show();// Clears the strip, as by default the strip data is set to all LED's off.
  strip.setBrightness(8);

  startMozzi(CONTROL_RATE); // :)
  osc1.setFreq(440); // set the frequency
  osc2.setFreq(440); // set the frequency

  ReadPatchesFromFlash();
  Patch[patch_number].GetAllToLocal();
  UpdateAllLocalPatchData();
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
    uint16_t LED_bright = 256-ModeData[0];
    rgb_t cur_pixel = workPixels[i];
    cur_pixel *= LED_bright;
    
    strip.setPixelColor((i+(NUM_LEDS/2))%NUM_LEDS, cur_pixel.r, cur_pixel.g, cur_pixel.b);
    //DEBUG_PRINTF("%d->%d,%d,%d\r\n",i, workPixels[i].r, workPixels[i].g, workPixels[i].b);
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
    //DEBUG_PRINTF("counter: %d DIVIDE %d FLASH %d %d\r\n",counter, counter/SPEED_DIVIDE, counter/FLASH_SPEED_DIVIDE, flash);
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
    //DEBUG_PRINTF("counter: %d DIVIDE %d FLASH %d\r\n",counter, counter/SPEED_DIVIDE, counter/FLASH_SPEED_DIVIDE);
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
    //DEBUG_PRINTF("counter: %d DIVIDE %d FLASH %d\r\n",counter, counter/SPEED_DIVIDE, counter/FLASH_SPEED_DIVIDE);
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
    DEBUG_APRINT(small_counter,DEC);
    DEBUG_APRINT(" ");
    uint32_t bits=GetStylusKeyBits();
    uint32_t bit = 1;
    for(int i=0;i<NUM_PINS+1;i++)
    {
      if ( bits & bit )
      {
        DEBUG_APRINT("#");
      }
      else
      {
        DEBUG_APRINT(".");
      }
      bit<<=1;
    }
    DEBUG_APRINTLN("\e[1;A");
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
    
    if ( key == NOT_PRESSED )
    {
      //if (!note_off_processed )
      {
        SoundKeyUp();
        note_off_processed = true;
      }
/*      if ( gain > 8 )
      {
        gain-=8;
      }
      else
      {
        gain = 0;
      }
*/    
    }
    else
    {
      note_off_processed = false;
    }
  }  
  
  counter++;
  audioHook();
}
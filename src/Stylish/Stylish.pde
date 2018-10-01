#include <WS2812B.h>

#include <MozziGuts.h>
#include <Oscil.h> // oscillator template
#include <tables/sin2048_int8.h> // sine table for oscillator
#include <RollingAverage.h>
#include <ControlDelay.h>
#include <mozzi_midi.h>


uint8_t keyboard_pins[]={PB12,PB13,PB14,PB15,PA8,PA9,PA10,PA6,PB11,PA15,PB3,PB4,PB5,PB6,PB7,PB9,PC13,PC14,PC15,PA0,PA1,PA2,PA3,PA4,PA5,
/*buttons */             PB1,PB0,PB10,PA6};

#define NUM_NOTES (25)
#define NUM_BUTTONS (4)
#define NUM_PINS (NUM_NOTES+NUM_BUTTONS)
#define NOT_PRESSED (0xFF)
#define REQUIRED_STABLE_CYCLES (2000)

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
   
  for(int i=0; i<NUM_NOTES;i++)
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
}

void ReceiveKeyUp(uint8_t key )
{
  Serial.print("Key Up ");
  Serial.print(key,DEC);
  Serial.println(".");
}


void setup() {
  Serial.begin(115200);  
  while (!Serial)
  {
    digitalWrite(33,!digitalRead(33));// Turn the LED from off to on, or on to off
    delay(100);         // fast blink
  }  
  Serial.println("Stylus Keypad Test");
  StylusKeyboardSetup();
  SetKeyDownCallback(&ReceiveKeyDown);
  SetKeyUpCallback(&ReceiveKeyUp);
}

uint64_t counter = 0;

void loop() 
{
  StylusKeyboardUpdate();
  if ((counter%4000)==0)
  {
    Serial.print(counter/4000,DEC);
    Serial.print(" ");
    uint32_t bits=GetStylusKeyBits();
    uint32_t bit = 1;
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
    Serial.println(" ");
  }
  
  counter++;
}
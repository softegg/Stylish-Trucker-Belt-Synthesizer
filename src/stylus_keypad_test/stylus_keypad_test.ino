//#include <gpio.h>
int note_pins[]={PB12,PB13,PB14,PB15,PA8,PA9,PA10,PA6,PB11,PA15,PB3,PB4,PB5,PB6,PB7,PB9,PC13,PC14,PC15,PA0,PA1,PA2,PA3,PA4,PA5};
int button_pins[]={PB1,PB0,PB10,PA6};
#define NUM_NOTES (25)
#define NUM_BUTTONS (4)


void setup() {
  Serial.begin(115200);  
  while (!Serial)
  {
    digitalWrite(33,!digitalRead(33));// Turn the LED from off to on, or on to off
    delay(100);         // fast blink
  }  
  Serial.println("Stylus Keypad Test");
  __IO uint32 *mapr = &AFIO_BASE->MAPR;
  uint16_t reg = *mapr;
  Serial.print("reg:");
  Serial.println(reg,HEX);
  afio_cfg_debug_ports(AFIO_DEBUG_SW_ONLY/*AFIO_DEBUG_NONE*/);
  afio_remap(AFIO_REMAP_USART3_PARTIAL);
  
  for(int i=0; i<NUM_NOTES;i++)
  {
      pinMode( note_pins[i], INPUT_PULLUP );      
      
  }
  for(int i=0; i<NUM_BUTTONS;i++)
  {
      pinMode( button_pins[i], INPUT_PULLUP );      
  }

}


int note=-1, oldnote=-1,button=-1,oldbutton=-1;
uint32_t counter = 0;

void loop() 
{
  note = -1;
  for(int i=0; i<NUM_NOTES;i++)
  {
      if (!digitalRead(note_pins[i]))
      {
        note = i;
        Serial.print("#");
      }      
      else
      {
        Serial.print(".");
      }
  }
  Serial.print(" ---- ");
  button=-1;
  for(int i=0; i<NUM_BUTTONS;i++)
  {
    if (!digitalRead(button_pins[i]))
    {
      button = i;
      Serial.print("#");
    }
    else
    {
      Serial.print(".");
    }
  }
  Serial.print("Counter ");
  Serial.println(counter,DEC);

  if (note!=oldnote)
  {
    if ( note != -1)
    {
      Serial.print("Note ");
      Serial.print(note,DEC);
      Serial.println(" pressed.");
      oldnote = note;
    }
    else
    {
      Serial.print("Note ");
      Serial.print(oldnote,DEC);
      Serial.println(" released.");
      oldnote = note;
    }
  }
  if (button!=oldbutton)
  {
    if ( button != -1)
    {
      Serial.print("Button ");
      Serial.print(button,DEC);
      Serial.println(" pressed.");
      oldbutton = button;
    }
    else
    {
      Serial.print("Button ");
      Serial.print(oldbutton,DEC);
      Serial.println(" released.");
      oldbutton = button;
    }
  }
  delay(200);
  counter++;
}
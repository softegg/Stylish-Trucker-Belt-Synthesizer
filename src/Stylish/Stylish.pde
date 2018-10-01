//about to gut this, gonna test to make sure commit is good...
//#include <Adafruit_NeoPixel-ANDnXOR.h>
#include <WS2812B.h>

#include <MozziGuts.h>
#include <Oscil.h> // oscillator template
#include <tables/sin2048_int8.h> // sine table for oscillator
#include <RollingAverage.h>
#include <ControlDelay.h>
#include <mozzi_midi.h>
#define INPUT_PIN 0 // analog control input

unsigned int echo_cells_1 = 32;
unsigned int echo_cells_2 = 60;
unsigned int echo_cells_3 = 127;

#define CONTROL_RATE 64
ControlDelay <128, int> kDelay; // 2seconds

// oscils to compare bumpy to averaged control input
Oscil <SIN2048_NUM_CELLS, AUDIO_RATE> aSin0(SIN2048_DATA);
Oscil <SIN2048_NUM_CELLS, AUDIO_RATE> aSin1(SIN2048_DATA);
Oscil <SIN2048_NUM_CELLS, AUDIO_RATE> aSin2(SIN2048_DATA);
Oscil <SIN2048_NUM_CELLS, AUDIO_RATE> aSin3(SIN2048_DATA);

// use: RollingAverage <number_type, how_many_to_average> myThing
RollingAverage <int, 32> kAverage; // how_many_to_average has to be power of 2
int averaged;

#if 0
#define PIN 6

// Parameter 1 = number of pixels in strip
// Parameter 2 = pin number (most are valid)
// Parameter 3 = pixel type flags, add together as needed:
//   NEO_KHZ800  800 KHz bitstream (most NeoPixel products w/WS2812 LEDs)
//   NEO_KHZ400  400 KHz (classic 'v1' (not v2) FLORA pixels, WS2811 drivers)
//   NEO_GRB     Pixels are wired for GRB bitstream (most NeoPixel products)
//   NEO_RGB     Pixels are wired for RGB bitstream (v1 FLORA pixels, not v2)
Adafruit_NeoPixel strip = Adafruit_NeoPixel(12, PIN, NEO_GRB + NEO_KHZ800);
int speed = 0;
#else
#define NUM_LEDS 16
/*
 * Note. Library uses SPI1
 * Connect the WS2812B data input to MOSI on your board.
 * 
 */
WS2812B strip = WS2812B(NUM_LEDS);
// Note. Gamma is not really supported in the library, its only included as some functions used in this example require Gamma
uint8_t LEDGamma[] = {
    0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
    0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  1,  1,  1,  1,
    1,  1,  1,  1,  1,  1,  1,  1,  1,  2,  2,  2,  2,  2,  2,  2,
    2,  3,  3,  3,  3,  3,  3,  3,  4,  4,  4,  4,  4,  5,  5,  5,
    5,  6,  6,  6,  6,  7,  7,  7,  7,  8,  8,  8,  9,  9,  9, 10,
   10, 10, 11, 11, 11, 12, 12, 13, 13, 13, 14, 14, 15, 15, 16, 16,
   17, 17, 18, 18, 19, 19, 20, 20, 21, 21, 22, 22, 23, 24, 24, 25,
   25, 26, 27, 27, 28, 29, 29, 30, 31, 32, 32, 33, 34, 35, 35, 36,
   37, 38, 39, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 50,
   51, 52, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 66, 67, 68,
   69, 70, 72, 73, 74, 75, 77, 78, 79, 81, 82, 83, 85, 86, 87, 89,
   90, 92, 93, 95, 96, 98, 99,101,102,104,105,107,109,110,112,114,
  115,117,119,120,122,124,126,127,129,131,133,135,137,138,140,142,
  144,146,148,150,152,154,156,158,160,162,164,167,169,171,173,175,
  177,180,182,184,186,189,191,193,196,198,200,203,205,208,210,213,
215,218,220,223,225,228,231,233,236,239,241,244,247,249,252,255 };
#endif
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
  Serial.println("Stylish!");

  kDelay.set(echo_cells_1);
  startMozzi();

  //pinMode(PA0,INPUT_ANALOG);
  //pinMode(PA1,INPUT_ANALOG);
  //speed = analogRead(PA0);  
  strip.begin();
  strip.show(); // Initialize all pixels to 'off'
  strip.setBrightness(32);
  
  //afio_cfg_debug_ports(AFIO_DEBUG_SW_ONLY/*AFIO_DEBUG_NONE*/);

  for(int i=0; i<NUM_NOTES;i++)
  {
      pinMode( note_pins[i], INPUT_PULLUP );      
      
  }
  for(int i=0; i<NUM_BUTTONS;i++)
  {
      pinMode( button_pins[i], INPUT_PULLUP );      
  }
  Serial.println("Init Complete!");

}
int analog_in=0;

void my_delay(unsigned long time)
{
  unsigned long end_time = millis()+time;
  while( millis() < end_time )
  {
    Serial.println(millis(),DEC);

    //analog_in = analogRead(PA0);
    //strip.setBrightness(analog_in>>4);
    //speed = analogRead(PA1)>>4;
    audioHook();
  }
}

int note = 0;
int button = 0;

void updateControl(){
  
  Serial.println("UpdateControl");
  strip.setPixelColor(note&0xF, 0,0,0);
  Serial.println("A");
  strip.setPixelColor(button, 0,0,0);
  Serial.println("B");
  note = -1;
  button = -1;
  
  Serial.println("C");
  for(int i=0; i<NUM_NOTES;i++)
  {
    Serial.println("D");
      if (!digitalRead(note_pins[i]))
      {
        note = i;
      }      
  }
  Serial.println("E");
  
  for(int i=0; i<NUM_BUTTONS;i++)
  {
    Serial.println("F");
    if (!digitalRead(button_pins[i]))
    {
      Serial.println("G");
      button = i;
      Serial.print("button ");
      Serial.print(button,DEC);
      Serial.println("pressed.");
        strip.setPixelColor(button, 255,0,0);

    }
  }
  Serial.println("H");
  if ( note > -1 )
  {
    Serial.println("I");
    uint8_t button_color = 0;
    if ( note == button)
    {
      button_color = 255;
    }
    Serial.println("J");
    if ( note < 16)
    {
      strip.setPixelColor(note&0xf, button_color,0,255);
    }
    else {
      strip.setPixelColor(note&0xf, button_color,255,0);
    }
    Serial.println("K");
    for( int i=0; i<NUM_NOTES;i++)
    {
      if ( i==note)
      {
        Serial.print("*");        
      }
      else
      {
        Serial.print(".");
      }
    }
    Serial.println(" ");
    note+=24;
    averaged = mtof(float(note));
    Serial.println("L");
  }
  Serial.println("M");
  //int bumpy_input = mozziAnalogRead(INPUT_PIN);
  //averaged = kAverage.next(bumpy_input);
  aSin0.setFreq(averaged);
  Serial.println("N");
  aSin1.setFreq(kDelay.next(averaged));
  Serial.println("O");
  aSin2.setFreq(kDelay.read(echo_cells_2));
  Serial.println("P");
  aSin3.setFreq(kDelay.read(echo_cells_3));
  Serial.println("Q");
}


int updateAudio(){
  return 3*((int)aSin0.next()+aSin1.next()+(aSin2.next()>>1)
    +(aSin3.next()>>2)) >>3;
}

void loop() {
  Serial.println("loop in");
#if 0
  audioHook();
  strip.show();
  my_delay(200);
#endif  
#if 1
  Serial.println("1");
  colorWipe(strip.Color(0, 255, 0), 20); // Green
  Serial.println("2");
  colorWipe(strip.Color(255, 0, 0), 20); // Red
  Serial.println("3");
  colorWipe(strip.Color(0, 0, 255), 20); // Blue
  Serial.println("4");
  rainbow(10);
  Serial.println("5");
  rainbowCycle(10);
  Serial.println("6");
  theaterChase(strip.Color(255, 0, 0), 20); // Red
  Serial.println("7");
  theaterChase(strip.Color(0, 255, 0), 20); // Green
  Serial.println("8");
  theaterChase(strip.Color(0, 0, 255), 20); // Blue
  Serial.println("9");
  theaterChaseRainbow(10);
  Serial.println("10");
  whiteOverRainbow(20,75,5);  
  Serial.println("11");
  pulseWhite(5); 
  Serial.println("12");
  my_delay(250);
  Serial.println("13");
  fullWhite();
  Serial.println("14");
  my_delay(250);
  Serial.println("15");
  rainbowFade2White(3,3,1);
  Serial.println("16");
#endif
}

// Fill the dots one after the other with a color
void colorWipe(uint32_t c, uint8_t wait) 
{
  for(uint16_t i=0; i<strip.numPixels(); i++) 
  {
      Serial.println("a");
      strip.setPixelColor(i, c);
      Serial.println("b");
      strip.show();
      Serial.println("c");
      my_delay(wait);
      Serial.println("d");
  }
}

void rainbow(uint8_t wait) {
  uint16_t i, j;

  for(j=0; j<256; j++) {
    for(i=0; i<strip.numPixels(); i++) 
  {
      strip.setPixelColor(i, Wheel((i+j) & 255));
    }
    strip.show();
    my_delay(wait);
  }
}



// Slightly different, this makes the rainbow equally distributed throughout
void rainbowCycle(uint8_t wait) 
{
  uint16_t i, j;

  for(j=0; j<256*5; j++) 
  { // 5 cycles of all colors on wheel
    for(i=0; i< strip.numPixels(); i++) 
  {
      strip.setPixelColor(i, Wheel(((i * 256 / strip.numPixels()) + j) & 255));
    }
    strip.show();
    my_delay(wait);
  }
}

// Input a value 0 to 255 to get a color value.
// The colours are a transition r - g - b - back to r.
uint32_t Wheel(byte WheelPos) 
{
  if(WheelPos < 85) 
  {
    return strip.Color(WheelPos * 3, 255 - WheelPos * 3, 0);
  } 
  else 
  {
    if(WheelPos < 170) 
    {
     WheelPos -= 85;
     return strip.Color(255 - WheelPos * 3, 0, WheelPos * 3);
    } 
    else 
    {
     WheelPos -= 170;
     return strip.Color(0, WheelPos * 3, 255 - WheelPos * 3);
    }
  }
}

//Theatre-style crawling lights.
void theaterChase(uint32_t c, uint8_t wait) {
  for (int j=0; j<10; j++) {  //do 10 cycles of chasing
    for (int q=0; q < 3; q++) {
      for (uint16_t i=0; i < strip.numPixels(); i=i+3) {
        strip.setPixelColor(i+q, c);    //turn every third pixel on
      }
      strip.show();

      my_delay(wait);

      for (uint16_t i=0; i < strip.numPixels(); i=i+3) {
        strip.setPixelColor(i+q, 0);        //turn every third pixel off
      }
    }
  }
}

//Theatre-style crawling lights with rainbow effect
void theaterChaseRainbow(uint8_t wait) {
  for (int j=0; j < 256; j++) {     // cycle all 256 colors in the wheel
    for (int q=0; q < 3; q++) {
      for (uint16_t i=0; i < strip.numPixels(); i=i+3) {
        strip.setPixelColor(i+q, Wheel( (i+j) % 255));    //turn every third pixel on
      }
      strip.show();

      my_delay(wait);

      for (uint16_t i=0; i < strip.numPixels(); i=i+3) {
        strip.setPixelColor(i+q, 0);        //turn every third pixel off
      }
    }
  }
}

void pulseWhite(uint8_t wait) {
  for(int j = 0; j < 256 ; j++){
      for(uint16_t i=0; i<strip.numPixels(); i++) {
          strip.setPixelColor(i, strip.Color(0,0,0, LEDGamma[j] ) );
        }
        my_delay(wait);
        strip.show();
      }

  for(int j = 255; j >= 0 ; j--){
      for(uint16_t i=0; i<strip.numPixels(); i++) {
          strip.setPixelColor(i, strip.Color(0,0,0, LEDGamma[j] ) );
        }
        my_delay(wait);
        strip.show();
      }
}


void rainbowFade2White(uint8_t wait, int rainbowLoops, int whiteLoops) {
  float fadeMax = 100.0;
  int fadeVal = 0;
  uint32_t wheelVal;
  int redVal, greenVal, blueVal;

  for(int k = 0 ; k < rainbowLoops ; k ++){
    
    for(int j=0; j<256; j++) { // 5 cycles of all colors on wheel

      for(int i=0; i< strip.numPixels(); i++) {

        wheelVal = Wheel(((i * 256 / strip.numPixels()) + j) & 255);

        redVal = red(wheelVal) * float(fadeVal/fadeMax);
        greenVal = green(wheelVal) * float(fadeVal/fadeMax);
        blueVal = blue(wheelVal) * float(fadeVal/fadeMax);

        strip.setPixelColor( i, strip.Color( redVal, greenVal, blueVal ) );

      }

      //First loop, fade in!
      if(k == 0 && fadeVal < fadeMax-1) {
          fadeVal++;
      }

      //Last loop, fade out!
      else if(k == rainbowLoops - 1 && j > 255 - fadeMax ){
          fadeVal--;
      }

        strip.show();
        my_delay(wait);
    }
  
  }



  my_delay(500);


  for(int k = 0 ; k < whiteLoops ; k ++){

    for(int j = 0; j < 256 ; j++){

        for(uint16_t i=0; i < strip.numPixels(); i++) {
            strip.setPixelColor(i, strip.Color(0,0,0, LEDGamma[j] ) );
          }
          strip.show();
        }

        my_delay(2000);
    for(int j = 255; j >= 0 ; j--){

        for(uint16_t i=0; i < strip.numPixels(); i++) {
            strip.setPixelColor(i, strip.Color(0,0,0, LEDGamma[j] ) );
          }
          strip.show();
        }
  }

  my_delay(500);


}

void whiteOverRainbow(uint8_t wait, uint8_t whiteSpeed, uint8_t whiteLength ) {
  
  if(whiteLength >= strip.numPixels()) whiteLength = strip.numPixels() - 1;

  int head = whiteLength - 1;
  int tail = 0;

  int loops = 3;
  int loopNum = 0;

  static unsigned long lastTime = 0;


  while(true){
    for(int j=0; j<256; j++) {
      for(uint16_t i=0; i<strip.numPixels(); i++) {
        if((i >= tail && i <= head) || (tail > head && i >= tail) || (tail > head && i <= head) ){
          strip.setPixelColor(i, strip.Color(0,0,0, 255 ) );
        }
        else{
          strip.setPixelColor(i, Wheel(((i * 256 / strip.numPixels()) + j) & 255));
        }
        
      }

      if(millis() - lastTime > whiteSpeed) {
        head++;
        tail++;
        if(head == strip.numPixels()){
          loopNum++;
        }
        lastTime = millis();
      }

      if(loopNum == loops) return;
    
      head%=strip.numPixels();
      tail%=strip.numPixels();
        strip.show();
        my_delay(wait);
    }
  }
  
}
void fullWhite() {
  
    for(uint16_t i=0; i<strip.numPixels(); i++) {
        strip.setPixelColor(i, strip.Color(0,0,0, 255 ) );
    }
      strip.show();
}

uint8_t red(uint32_t c) {
  return (c >> 16);
}
uint8_t green(uint32_t c) {
  return (c >> 8);
}
uint8_t blue(uint32_t c) {
  return (c);
}


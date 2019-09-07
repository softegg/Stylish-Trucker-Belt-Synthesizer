#include <arduino.h>
#include "rgb.h"

    rgb_t& rgb_t::operator+=(const rgb_t& in){
      int val = (int)this->r + (int)in.r;
      if (val > 255) val=255;
      this->r = val;  

      val = (int)this->g + (int)in.g;
      if (val > 255) val=255;
      this->g = val;  

      val = (int)this->b + (int)in.b;
      if (val > 255) val=255;
      this->b = val;  
      return *this;
    };
    
    //multiply by uint16_t is fixed point unsigned 8.8 multiply
    rgb_t& rgb_t::operator*=(const uint16_t& in){
      int val = (int)this->r * (int)in;
      val>>=8;
      if (val > 255) val=255;
      this->r = val;  

      val = (int)this->g * (int)in;
      val>>=8;
      if (val > 255) val=255;
      this->g = val;  

      val = (int)this->b * (int)in;
      val>>=8;
      if (val > 255) val=255;
      this->b = val;  
      return *this;
    };

    rgb_t& rgb_t::operator-=(const rgb_t& in){
      int val = (int)this->r - (int)in.r;
      if (val <0) val=0;
      this->r = val;  

      val = (int)this->g - (int)in.g;
      if (val <0) val=0;
      this->g = val;  

      val = (int)this->b - (int)in.b;
      if (val <0) val=0;
      this->b = val;  
      return *this;
    };

    const rgb_t rgb_t::operator+(const rgb_t& in){
      rgb_t out;
      int val = (int)this->r + (int)in.r;
      if (val > 255) val=255;
      out.r = val;  

      val = (int)this->g + (int)in.g;
      if (val > 255) val=255;
      out.g = val;  

      val = (int)this->b + (int)in.b;
      if (val > 255) val=255;
      out.b = val;  
      return( out );
    };
    
    const rgb_t rgb_t::operator-(const rgb_t& in){
      rgb_t out;
      int val = (int)this->r - (int)in.r;
      if (val < 0) val=0;
      out.r = val;  

      val = (int)this->g - (int)in.g;
      if (val <0) val=0;
      out.g = val;  

      val = (int)this->b - (int)in.b;
      if (val <0) val=0;
      out.b = val;  
      return( out );
    };
    
    const rgb_t rgb_t::operator*(const uint8_t& in){
      rgb_t out;
      int val = (int)this->r * (int)in;
      if (val > 255) val=255;
      out.r = val;  

      val = (int)this->g * (int)in;
      if (val > 255) val=255;
      out.g = val;  

      val = (int)this->b * (int)in;
      if (val > 255) val=255;
      out.b = val;  
      return( out );
    };

    const rgb_t rgb_t::operator/(const uint8_t& in){
      rgb_t out;
      out.r = (int)this->r / (int)in;

      out.g = (int)this->g / (int)in;

      out.b = (int)this->b / (int)in;
      return( out );
    };
    
    rgb_t::rgb_t( const uint8_t _r, const uint8_t _g, const uint8_t _b )
    {
      r=_r;g=_g;b=_b;
    };

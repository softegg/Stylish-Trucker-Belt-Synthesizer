//RGB math class

class rgb_t {
  public:
    uint8 r,g,b;
    rgb_t& operator+=(const rgb_t& in);
    
    //multiply by uint16_t is fixed point unsigned 8.8 multiply
    rgb_t& operator*=(const uint16_t& in);

    rgb_t& operator-=(const rgb_t& in);

    const rgb_t operator+(const rgb_t& in);
    
    const rgb_t operator-(const rgb_t& in);
    
    const rgb_t operator*(const uint8_t& in);
    
    const rgb_t operator/(const uint8_t& in);
    
    rgb_t( const uint8_t _r=0, const uint8_t _g=0, const uint8_t _b=0 );     
};

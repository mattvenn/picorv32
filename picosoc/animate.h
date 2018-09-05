#ifndef __animate_h__
#define __animate_h__

#define reg_ws2812 (*(volatile uint32_t*)0x04000000)

uint32_t millis();
typedef struct cRGB {
  uint8_t r;
  uint8_t g;
  uint8_t b;
} cRGB;
void set_ws2812(cRGB val, uint8_t num);
cRGB hsvToRgb(uint16_t h, uint16_t s, uint16_t v);
void LEDRainbowWaveEffect ();

#endif

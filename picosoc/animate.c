#include <stdint.h>
#include "animate.h"

#define LED_COUNT 8

uint16_t rainbow_hue = 0;
uint8_t rainbow_saturation = 255;
uint8_t rainbow_wave_steps = 1;
uint8_t rainbow_value = 50;

uint32_t millis()
{
    return 100;
}

void set_ws2812(cRGB val, uint8_t num)
{
    reg_ws2812 = num + (val.b << 8) + (val.r << 16) + (val.g << 24);
}

void LEDRainbowWaveEffect () {

  for (uint8_t i = 0; i < LED_COUNT; i++) {
    uint16_t key_hue = rainbow_hue + 32 * (i);
    if (key_hue >= 255) {
      key_hue -= 255;
    }
    cRGB rainbow = hsvToRgb(key_hue, rainbow_saturation, rainbow_value);
    set_ws2812(rainbow, i);
  }
  rainbow_hue += rainbow_wave_steps;
  if (rainbow_hue >= 255) {
    rainbow_hue -= 255;
  }
}



cRGB hsvToRgb(uint16_t h, uint16_t s, uint16_t v) {
  cRGB color;

  /* HSV to RGB conversion function with only integer
   * math */
  uint16_t region, fpart, p, q, t;

  if (s == 0) {
    /* color is grayscale */
    color.r = color.g = color.b = v;
    return color;
  }

  /* make hue 0-5 */
  region = (h * 6) >> 8;
  /* find remainder part, make it from 0-255 */
  fpart = (h * 6) - (region << 8);

  /* calculate temp vars, doing integer multiplication */
  p = (v * (255 - s)) >> 8;
  q = (v * (255 - ((s * fpart) >> 8))) >> 8;
  t = (v * (255 - ((s * (255 - fpart)) >> 8))) >> 8;

  /* assign temp vars based on color cone region */
  switch (region) {
  case 0:
    color.r = v;
    color.g = t;
    color.b = p;
    break;
  case 1:
    color.r = q;
    color.g = v;
    color.b = p;
    break;
  case 2:
    color.r = p;
    color.g = v;
    color.b = t;
    break;
  case 3:
    color.r = p;
    color.g = q;
    color.b = v;
    break;
  case 4:
    color.r = t;
    color.g = p;
    color.b = v;
    break;
  default:
    color.r = v;
    color.g = p;
    color.b = q;
    break;
  }

  return color;
}


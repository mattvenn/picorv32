/*
 Simple demo based off of Picosoc by Claire Wolf
 */

#include <stdint.h>
#include <stdbool.h>

#ifdef ICEBREAKER
#  define MEM_TOTAL 0x20000 /* 128 KB */
#elif HX8KDEMO
#  define MEM_TOTAL 0x200 /* 2 KB */
#else
#  error "Set -DICEBREAKER or -DHX8KDEMO when compiling firmware.c"
#endif

// a pointer to this is a null pointer, but the compiler does not
// know that because "sram" is a linker symbol from sections.lds.
extern uint32_t sram;

#define reg_wb (*(volatile uint32_t*)0x03000000) // wishbone reg

// --------------------------------------------------------

void blink_up()
{
    uint8_t leds = 1;
    for(int i = 0; i < 8 ; i ++)
    {
        reg_wb = leds;
        leds = leds << 1;
        for(int i = 0; i < 1000; i ++) { ;; }
    }
}


void blink_down()
{
    uint8_t leds = 128;
    for(int i = 0; i < 8 ; i ++)
    {
        reg_wb = leds;
        leds = leds >> 1;
        for(int i = 0; i < 1000; i ++) { ;; }
    }

}

void blink_all(int num)
{
    for(int i = 0; i < num; i ++)
    {
        reg_wb = 255;
        for(int i = 0; i < 2000; i ++) { ;; }
        reg_wb = 0;
        for(int i = 0; i < 2000; i ++) { ;; }

    }
}
void main()
{
    reg_wb = 0; 
    uint8_t led_counter = 0;
    for(led_counter = 0; led_counter <= 10 ; led_counter ++)
    {
        for(int i = 0; i < 1000; i ++) { ;; }
        reg_wb = led_counter;
    }

    
    uint8_t buttons = 0;
    while(1) {
        // read the value of the buttons
        buttons = reg_wb;
        if(buttons & (1 << 0))
            blink_up();
        if(buttons & (1 << 1))
            blink_down();
        if(buttons & (1 << 2))
            blink_all(10);
        }
}

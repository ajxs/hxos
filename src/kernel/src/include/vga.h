#ifndef TTY_H
#define TTY_H 1

#define FRAMEBUFFER_ADDR        0xC03FF000
#define FRAMEBUFFER_LENGTH      2000
#define FRAMEBUFFER_WIDTH       80
#define FRAMEBUFFER_HEIGHT      25

#define VGA_COLOR_BLACK         0
#define VGA_COLOR_BLUE          1
#define VGA_COLOR_GREEN         2
#define VGA_COLOR_CYAN          3
#define VGA_COLOR_RED           4
#define VGA_COLOR_MAGENTA       5
#define VGA_COLOR_BROWN         6
#define VGA_COLOR_LIGHT_GREY    7
#define VGA_COLOR_DARK_GREY     8
#define VGA_COLOR_LIGHT_BLUE    9
#define VGA_COLOR_LIGHT_GREEN   10
#define VGA_COLOR_LIGHT_CYAN    11
#define VGA_COLOR_LIGHT_RED     12
#define VGA_COLOR_LIGHT_MAGENTA 13
#define VGA_COLOR_LIGHT_BROWN   14
#define VGA_COLOR_WHITE         15

/**
 * VGA_COLOR_CODE
 * Encodes the foreground and background colors into a full
 * VGA color code.
 */
#define VGA_COLOR_CODE(fg, bg)  fg | (bg << 4)

#endif

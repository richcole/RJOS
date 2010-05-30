#include "kern_proto.h"

typedef unsigned long int uint64;
typedef unsigned short int uint16;

extern void kernel() {
  console_clear(); 
  greeting();
  hang();
}

static void hang() {
  while(1);
};

static void strcpy(char *dest, char *src) {
  while(*src) {
    *dest = *src;
    dest++;
    src++;
  }
}

static void console_print(char color, char *src) {
  char *dest = 0xb8000;
  while(*src) {
    *dest++ = *src++;
    *dest++ = color;
  }
}

static void greeting() {
  char console_white = 0xf;
  console_print(console_white, "Welcome to RJOS");
}

static void memset(char *s, unsigned int length, char v) {
  char *e = s + length;
  while(s < e) {
    *s++ = v;
  }
};

static void console_clear() {
  char *console = (char *)0xb8000;
  memset(console, 2 * 80 * 25, 0);
}





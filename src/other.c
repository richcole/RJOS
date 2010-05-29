static void memset(char *s, unsigned int length, char v) {
  uint64 w = v;
  uint64 d = 
    (w << 0) | (w << 8) | (w << 16) | (w << 24) |
    (w << 32) | (w << 40) | (w << 48) | (w << 56)
    ;

  // word align
  while(length > 0 && ((char)(uint64 *)s & (char)0b111) != 0) {
    *s = v; 
    s++; 
    length--; 
  }

  // copy contents
  uint64 *l = (uint64 *)s;
  while(length > 8) {
    *l = d;
    l++; length -= 8;
  }
  
  // copy to the end
  s = (char *)l;
  while(length > 0) {
    *s = v;
    length--; 
    s++;
  }
};

static void console_clear() {
  static char *console = (char *)0xb8000;
  memset(console, 2 * 80 * 25, 0);
}

static void strcpy(char *dest, char *src) {
  while(*src) {
    *dest = *src;
    dest++;
    src++;
  }
}

static void console_print(char color, char *src) {
  static char *console = (char *)0xb8000;
  uint16* dest = (uint16 *)console;
  dest = (((uint16) color) << 8);
  while(*src) {
    *dest = *dest | ((uint16) src);
    dest++; 
    src++;
  }
}

static void greeting() {
  static char console_white = 0xf;
  console_print(console_white, "Welcome to RJOS");
}

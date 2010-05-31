#include "kern.h"

uint8   console_white;

extern void kernel() {
  console_white = 0xf;
  console_clear(); 
  greeting();
  pci_scan();
  hang();
}

void hang() {
  while(1);
};

void strcpy(char *dest, char *src) {
  while(*src) {
    *dest = *src;
    dest++;
    src++;
  }
}

void console_print(uint16 x, uint16 y, char color, char *src) {
  char *console = (char *)0xb8000;
  char *dest = console + (((y * 80) + x)*2);
  while(*src) {
    *dest++ = *src++;
    *dest++ = color;
  }
}

void greeting() {
  console_print(0, 0, console_white, "Welcome to RJOS");
}

void memset(char *s, unsigned int length, char v) {
  char *e = s + length; 
  while(s < e) {
    *s++ = v;
  }
};

void console_clear() {
  char *console = (char *)0xb8000;
  memset(console, 2 * 80 * 25, 0);
}

inline void out8(uint16 port, uint8 val) {
  asm volatile("outb %0,%1"::"a"(val), "Nd" (port));
}

inline void out16(uint16 port, uint16 val) {
  asm volatile("outw %0,%1"::"a"(val), "Nd" (port));
}

inline void out32(uint16 port, uint32 val) {
  asm volatile("outl %0,%1"::"a"(val), "Nd" (port));
}

inline uint32 in32(uint16 port) {
  uint32 val;
  asm volatile("inl %1,%0":"=a"(val):"Nd" (port));
  return val;
}

uint8 hex_char(uint8 value) {
  if (value < 10) {
    return '0' + (value & 0xf);
  }
  else {
    return 'A' + ((value & 0xf) - 10);
  }
}

void debug32(uint32 value)
{
  uint16 debug_address  = 0xe9;
  out8(debug_address, ' ');
  out8(debug_address, '0');
  out8(debug_address, 'x');
  out8(debug_address, hex_char(value >> 28));
  out8(debug_address, hex_char(value >> 24));
  out8(debug_address, hex_char(value >> 20));
  out8(debug_address, hex_char(value >> 16));
  out8(debug_address, hex_char(value >> 12));
  out8(debug_address, hex_char(value >> 8));
  out8(debug_address, hex_char(value >> 4));
  out8(debug_address, hex_char(value >> 0));
};

uint32 read_pci_reg(uint16 bus, uint16 slot, uint16 func, uint16 reg) {
  uint16 config_address = 0xcf8;
  uint16 config_data    = 0xcfc;
  uint32 address = 
    (((uint32) bus)        << 16  ) | 
    (((uint32) slot)       << 11  ) | 
    (((uint32) func)       << 8   ) | 
    (((uint32) reg)        << 2   ) |
    (((uint32) 0x1)        << 31  ) ;
  out32(config_address, address);
  return in32(config_data);
}

void console_print_hex(uint8 x, uint8 y, uint8 color, uint32 value) {
  char buf[20];
  hex_string(buf, sizeof(buf), value);
  console_print(x, y, console_white, buf);
}

void pci_scan() {
  uint16 bus    = 0;
  uint16 slot   = 0;
  uint16 func   = 0;
  uint16 reg    = 1;
  uint32 result = 0;
  uint16 index  = 1;
  for(bus=0;bus<2;++bus) {
    for(slot=0;slot<256;++slot) {
      for(func=0;func<1;++func) {
        result = read_pci_reg(bus, slot, func, reg);
        if ( result != 0xffffffff ) {
          console_print(0, index, console_white, "bus");
          console_print_hex(4, index, console_white, bus);
          console_print(12, index, console_white, "slot");
          console_print_hex(16, index, console_white, slot);
          console_print(21, index, console_white, "device/vendor");
          console_print_hex(35, index, console_white, result);
          index += 1;
        }
      }
    }
  }
}

void reverse(char *s, char *e) {
  char tmp;
  --e; 
  while(s < e) {
    tmp = *s;
    *s = *e;
    *e = tmp;
    ++s; --e;
  }
}

void hex_string(char *buf, uint64 buf_len, uint32 val)
{
  if ( buf_len == 0 ) return;
  char *p = buf;
  char *p_end = p + buf_len - 1;
  if ( val == 0 ) {
    *p++ = '0';
  }
  else {
    while(val > 0) {
      char x = val % 16;
      if (x > 9) {
        *p++ = 'A' + (x - 10);
      }
      else {
        *p++ = '0' + x;
      }
      val /= 16;
    }
  }
  if ( p < p_end ) {
    *p++ = 'x';
    *p++ = '0';
  }
  reverse(buf, p);
  *p++ = 0;
}






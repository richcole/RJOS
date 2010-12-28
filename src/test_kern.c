#include <stdio.h>
#include "kern.h"

int main() {
  char buf[20];
  hex_string(buf, sizeof(buf), 0x20);
  fprintf(stderr, "%s\n", buf);
  return 0;
};

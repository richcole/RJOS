void kernel() {
  static char *p = (char *)0xb8000;
  static char *q = "Welcome to RJOS";
  while(*q) {
    *p = *q;
    p++; q++;
    *p = 0x0f;
    p++;
  }
  p[0] = 'W';
  p[1] = 0x0f;
  p[2] = 'e';
  p[3] = 0x0f;
  while(1);
}

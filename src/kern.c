void kernel() {
  static char *p = (char *)0xb8000;
  static char *q = "Welcome to RJOS";
  while(*q) {
    *p = *q;
    p++; q++;
    *p = 0x0f;
    p++;
  }
  while(1);
}

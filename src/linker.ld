OUTPUT_FORMAT(binary)
OUTPUT_ARCH(i386:x86-64)
ENTRY(kernel)
SECTIONS {
  . = 0x0200;
  .text : {
    *(.text)
  }
  .data : {
    *(.data)
  }
  .bss : {
    *(.bss)
  }
}


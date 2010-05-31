OUTPUT_FORMAT(binary)
OUTPUT_ARCH(i386:x86-64)
ENTRY(start)
SECTIONS {
  . = 0xd000;
  .text : {
    build/start.o(.text)
    build/kern.o(.text)
  }
  .data : {
    build/start.o(.data)
    build/kern.o(.data)
  }
  .bss : { 
    build/start.o(.bss)
    build/kern.o(.bss)
  }
}


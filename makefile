
# this makefile changed to GNU
ifdef SystemRoot
   RM = del /Q
   FixPath = $(subst /,\,$1)
else
   ifeq ($(shell uname), Linux)
      RM = rm -f
      FixPath = $1
   endif
endif

	CC= sdcc
	LD= sdld
	AS= sdas311
	H2B= hex2bin
	WAV= sweep.bin

all: sphlibdemo.bin


sphlibdemo.bin: demo.bin spidata.bin
	cat demo.bin  zero64k.bi1 > zz.bin
	head -c 4096 zz.bin > zz.bi1
	cat  zz.bi1  spidata.bin > sphlibdemo.bin
	del zz.bin 


demo.bin: demo.ihx
	$(H2B) demo.ihx

demo.ihx: demo.rel 
	$(LD) -u -m -i -y demo demo -l ms311sdcc.lib -l ms311sph.lib

demo.rel: demo.asm 
	$(AS) -l -o -s -y demo.asm

demo.asm: demo.c Makefile spidata.h
	$(CC) -pMS311 -OB -OF --debug demo.c

clean:
	$(RM) sphlibdemo.bin
	$(RM) demo.rel
	$(RM) demo.asm


main.elf:     file format elf32-msp430


Disassembly of section .text:

00000000 <__crt0_begin>:
   0:	38 40 00 c0 	mov	#-16384,r8	;#0xc000
   4:	11 42 fa ff 	mov	&0xfffa,r1	;0xfffa
   8:	02 43       	clr	r2		;
   a:	01 58       	add	r8,	r1	;
   c:	21 83       	decd	r1		;
   e:	b2 40 00 47 	mov	#18176,	&0xffb8	;#0x4700
  12:	b8 ff 
  14:	39 40 80 ff 	mov	#-128,	r9	;#0xff80

00000018 <__crt0_clr_io>:
  18:	09 93       	cmp	#0,	r9	;r3 As==00
  1a:	04 24       	jz	$+10     	;abs 0x24
  1c:	89 43 00 00 	mov	#0,	0(r9)	;r3 As==00
  20:	29 53       	incd	r9		;
  22:	fa 3f       	jmp	$-10     	;abs 0x18

00000024 <__crt0_clr_dmem>:
  24:	01 98       	cmp	r8,	r1	;
  26:	04 24       	jz	$+10     	;abs 0x30
  28:	88 43 00 00 	mov	#0,	0(r8)	;r3 As==00
  2c:	28 53       	incd	r8		;
  2e:	fa 3f       	jmp	$-10     	;abs 0x24

00000030 <__crt0_clr_dmem_end>:
  30:	35 40 f2 01 	mov	#498,	r5	;#0x01f2
  34:	36 40 f2 01 	mov	#498,	r6	;#0x01f2
  38:	37 40 08 c0 	mov	#-16376,r7	;#0xc008

0000003c <__crt0_cpy_data>:
  3c:	06 95       	cmp	r5,	r6	;
  3e:	04 24       	jz	$+10     	;abs 0x48
  40:	b7 45 00 00 	mov	@r5+,	0(r7)	;
  44:	27 53       	incd	r7		;
  46:	fa 3f       	jmp	$-10     	;abs 0x3c

00000048 <__crt0_cpy_data_end>:
  48:	32 40 00 40 	mov	#16384,	r2	;#0x4000
  4c:	04 43       	clr	r4		;
  4e:	0a 43       	clr	r10		;
  50:	0b 43       	clr	r11		;
  52:	0c 43       	clr	r12		;
  54:	0d 43       	clr	r13		;
  56:	0e 43       	clr	r14		;
  58:	0f 43       	clr	r15		;

0000005a <__crt0_start_main>:
  5a:	b0 12 6c 00 	call	#108		;#0x006c

0000005e <__crt0_this_is_the_end>:
  5e:	02 43       	clr	r2		;
  60:	b2 40 00 47 	mov	#18176,	&0xffb8	;#0x4700
  64:	b8 ff 
  66:	32 40 10 00 	mov	#16,	r2	;#0x0010
  6a:	03 43       	nop			

0000006c <main>:
  6c:	0a 12       	push	r10		;
  6e:	3c 40 00 4b 	mov	#19200,	r12	;#0x4b00
  72:	4d 43       	clr.b	r13		;
  74:	b0 12 cc 00 	call	#204		;#0x00cc
  78:	3c 40 d2 01 	mov	#466,	r12	;#0x01d2
  7c:	b0 12 4a 01 	call	#330		;#0x014a
  80:	4c 43       	clr.b	r12		;

00000082 <.L2>:
  82:	0a 4c       	mov	r12,	r10	;
  84:	1a 53       	inc	r10		;
  86:	3c f0 ff 00 	and	#255,	r12	;#0x00ff
  8a:	b0 12 c6 00 	call	#198		;#0x00c6
  8e:	7c 40 c8 00 	mov.b	#200,	r12	;#0x00c8
  92:	b0 12 9a 00 	call	#154		;#0x009a
  96:	0c 4a       	mov	r10,	r12	;
  98:	f4 3f       	jmp	$-22     	;abs 0x82

0000009a <neo430_cpu_delay_ms>:
  9a:	0a 12       	push	r10		;
  9c:	1a 42 fe ff 	mov	&0xfffe,r10	;0xfffe
  a0:	0b 43       	clr	r11		;
  a2:	0e 4c       	mov	r12,	r14	;
  a4:	4f 43       	clr.b	r15		;
  a6:	0c 4a       	mov	r10,	r12	;
  a8:	0d 4b       	mov	r11,	r13	;
  aa:	0c 5c       	rla	r12		;
  ac:	0d 6d       	rlc	r13		;
  ae:	b0 12 88 01 	call	#392		;#0x0188

000000b2 <.L17>:
  b2:	3c 53       	add	#-1,	r12	;r3 As==11
  b4:	3d 63       	addc	#-1,	r13	;r3 As==11
  b6:	3c 93       	cmp	#-1,	r12	;r3 As==11
  b8:	04 20       	jnz	$+10     	;abs 0xc2
  ba:	3d 93       	cmp	#-1,	r13	;r3 As==11
  bc:	02 20       	jnz	$+6      	;abs 0xc2
  be:	3a 41       	pop	r10		;
  c0:	30 41       	ret			

000000c2 <.L18>:
  c2:	03 43       	nop			
  c4:	f6 3f       	jmp	$-18     	;abs 0xb2

000000c6 <neo430_gpio_port_set>:
  c6:	82 4c ac ff 	mov	r12,	&0xffac	;
  ca:	30 41       	ret			

000000cc <neo430_uart_setup>:
  cc:	0a 12       	push	r10		;
  ce:	1e 42 fc ff 	mov	&0xfffc,r14	;0xfffc
  d2:	1f 42 fe ff 	mov	&0xfffe,r15	;0xfffe
  d6:	0c 5c       	rla	r12		;
  d8:	0d 6d       	rlc	r13		;
  da:	4a 43       	clr.b	r10		;

000000dc <.L2>:
  dc:	0f 9d       	cmp	r13,	r15	;
  de:	04 28       	jnc	$+10     	;abs 0xe8
  e0:	0d 9f       	cmp	r15,	r13	;
  e2:	13 20       	jnz	$+40     	;abs 0x10a
  e4:	0e 9c       	cmp	r12,	r14	;
  e6:	11 2c       	jc	$+36     	;abs 0x10a

000000e8 <.L9>:
  e8:	4c 43       	clr.b	r12		;

000000ea <.L5>:
  ea:	7d 40 ff 00 	mov.b	#255,	r13	;#0x00ff
  ee:	0d 9a       	cmp	r10,	r13	;
  f0:	10 28       	jnc	$+34     	;abs 0x112
  f2:	82 43 a0 ff 	mov	#0,	&0xffa0	;r3 As==00
  f6:	7d 42       	mov.b	#8,	r13	;r2 As==11
  f8:	b0 12 82 01 	call	#386		;#0x0182
  fc:	0a dc       	bis	r12,	r10	;
  fe:	3a d0 00 10 	bis	#4096,	r10	;#0x1000
 102:	82 4a a0 ff 	mov	r10,	&0xffa0	;
 106:	3a 41       	pop	r10		;
 108:	30 41       	ret			

0000010a <.L3>:
 10a:	0e 8c       	sub	r12,	r14	;
 10c:	0f 7d       	subc	r13,	r15	;
 10e:	1a 53       	inc	r10		;
 110:	e5 3f       	jmp	$-52     	;abs 0xdc

00000112 <.L8>:
 112:	4d 4c       	mov.b	r12,	r13	;
 114:	7d 50 fe ff 	add.b	#-2,	r13	;#0xfffe
 118:	7d b0 fd ff 	bit.b	#-3,	r13	;#0xfffd
 11c:	0a 20       	jnz	$+22     	;abs 0x132
 11e:	12 c3       	clrc			
 120:	0a 10       	rrc	r10		;
 122:	12 c3       	clrc			
 124:	0a 10       	rrc	r10		;
 126:	12 c3       	clrc			
 128:	0a 10       	rrc	r10		;

0000012a <.L7>:
 12a:	5c 53       	inc.b	r12		;
 12c:	3c f0 ff 00 	and	#255,	r12	;#0x00ff
 130:	dc 3f       	jmp	$-70     	;abs 0xea

00000132 <.L6>:
 132:	12 c3       	clrc			
 134:	0a 10       	rrc	r10		;
 136:	f9 3f       	jmp	$-12     	;abs 0x12a

00000138 <neo430_uart_putc>:
 138:	3c f0 ff 00 	and	#255,	r12	;#0x00ff

0000013c <.L15>:
 13c:	1d 42 a0 ff 	mov	&0xffa0,r13	;0xffa0
 140:	0d 93       	cmp	#0,	r13	;r3 As==00
 142:	fc 3b       	jl	$-6      	;abs 0x13c
 144:	82 4c a2 ff 	mov	r12,	&0xffa2	;
 148:	30 41       	ret			

0000014a <neo430_uart_br_print>:
 14a:	0a 12       	push	r10		;
 14c:	09 12       	push	r9		;
 14e:	0a 4c       	mov	r12,	r10	;

00000150 <.L26>:
 150:	79 4a       	mov.b	@r10+,	r9	;
 152:	09 93       	cmp	#0,	r9	;r3 As==00
 154:	01 20       	jnz	$+4      	;abs 0x158
 156:	10 3c       	jmp	$+34     	;abs 0x178

00000158 <.L28>:
 158:	39 90 0a 00 	cmp	#10,	r9	;#0x000a
 15c:	04 20       	jnz	$+10     	;abs 0x166
 15e:	7c 40 0d 00 	mov.b	#13,	r12	;#0x000d
 162:	b0 12 38 01 	call	#312		;#0x0138

00000166 <.L27>:
 166:	4c 49       	mov.b	r9,	r12	;
 168:	b0 12 38 01 	call	#312		;#0x0138
 16c:	f1 3f       	jmp	$-28     	;abs 0x150

0000016e <__mspabi_func_epilog_7>:
 16e:	34 41       	pop	r4		;

00000170 <__mspabi_func_epilog_6>:
 170:	35 41       	pop	r5		;

00000172 <__mspabi_func_epilog_5>:
 172:	36 41       	pop	r6		;

00000174 <__mspabi_func_epilog_4>:
 174:	37 41       	pop	r7		;

00000176 <__mspabi_func_epilog_3>:
 176:	38 41       	pop	r8		;

00000178 <__mspabi_func_epilog_2>:
 178:	39 41       	pop	r9		;

0000017a <__mspabi_func_epilog_1>:
 17a:	3a 41       	pop	r10		;
 17c:	30 41       	ret			

0000017e <.L1^B1>:
 17e:	3d 53       	add	#-1,	r13	;r3 As==11
 180:	0c 5c       	rla	r12		;

00000182 <__mspabi_slli>:
 182:	0d 93       	cmp	#0,	r13	;r3 As==00
 184:	fc 23       	jnz	$-6      	;abs 0x17e
 186:	30 41       	ret			

00000188 <__mspabi_mpyl>:
 188:	0a 12       	push	r10		;

0000018a <.LCFI10>:
 18a:	09 12       	push	r9		;

0000018c <.LCFI11>:
 18c:	08 12       	push	r8		;

0000018e <.LCFI12>:
 18e:	07 12       	push	r7		;

00000190 <.LCFI13>:
 190:	06 12       	push	r6		;

00000192 <.LCFI14>:
 192:	0a 4c       	mov	r12,	r10	;
 194:	0b 4d       	mov	r13,	r11	;

00000196 <.LVL27>:
 196:	78 40 21 00 	mov.b	#33,	r8	;#0x0021

0000019a <.Loc.30.2>:
 19a:	4c 43       	clr.b	r12		;

0000019c <.LVL28>:
 19c:	4d 43       	clr.b	r13		;

0000019e <.L6>:
 19e:	09 4e       	mov	r14,	r9	;
 1a0:	09 df       	bis	r15,	r9	;
 1a2:	09 93       	cmp	#0,	r9	;r3 As==00
 1a4:	05 24       	jz	$+12     	;abs 0x1b0
 1a6:	49 48       	mov.b	r8,	r9	;
 1a8:	79 53       	add.b	#-1,	r9	;r3 As==11
 1aa:	48 49       	mov.b	r9,	r8	;

000001ac <.LVL30>:
 1ac:	49 93       	cmp.b	#0,	r9	;r3 As==00
 1ae:	01 20       	jnz	$+4      	;abs 0x1b2

000001b0 <.L5>:
 1b0:	e0 3f       	jmp	$-62     	;abs 0x172

000001b2 <.L10>:
 1b2:	09 4e       	mov	r14,	r9	;
 1b4:	59 f3       	and.b	#1,	r9	;r3 As==01

000001b6 <.Loc.36.2>:
 1b6:	09 93       	cmp	#0,	r9	;r3 As==00
 1b8:	02 24       	jz	$+6      	;abs 0x1be

000001ba <.Loc.37.2>:
 1ba:	0c 5a       	add	r10,	r12	;

000001bc <.LVL31>:
 1bc:	0d 6b       	addc	r11,	r13	;

000001be <.L7>:
 1be:	06 4a       	mov	r10,	r6	;
 1c0:	07 4b       	mov	r11,	r7	;
 1c2:	06 5a       	add	r10,	r6	;
 1c4:	07 6b       	addc	r11,	r7	;
 1c6:	0a 46       	mov	r6,	r10	;

000001c8 <.LVL33>:
 1c8:	0b 47       	mov	r7,	r11	;

000001ca <.LVL34>:
 1ca:	12 c3       	clrc			
 1cc:	0f 10       	rrc	r15		;
 1ce:	0e 10       	rrc	r14		;

000001d0 <.LVL35>:
 1d0:	e6 3f       	jmp	$-50     	;abs 0x19e

Disassembly of section .rodata:

000001d2 <_etext-0x20>:
 1d2:	0a 20       	jnz	$+22     	;abs 0x1e8
 1d4:	4d 59       	add.b	r9,	r13	;
 1d6:	20 42       	br	#4		;r2 As==10
 1d8:	6c 69       	addc.b	@r9,	r12	;
 1da:	6e 6b       	addc.b	@r11,	r14	;
 1dc:	69 6e       	addc.b	@r14,	r9	;
 1de:	67 20       	jnz	$+208    	;abs 0x2ae
 1e0:	4c 45       	mov.b	r5,	r12	;
 1e2:	44 20       	jnz	$+138    	;abs 0x26c
 1e4:	64 65       	addc.b	@r5,	r4	;
 1e6:	6d 6f       	addc.b	@r15,	r13	;
 1e8:	20 70       	subc	@r0,	r0	;
 1ea:	72 6f       	addc.b	@r15+,	r2	;
 1ec:	67 72       	subc.b	#4,	r7	;r2 As==10
 1ee:	61 6d       	addc.b	@r13,	r1	;
 1f0:	0a 00       	mova	@r0,	r10	;

Disassembly of section .MP430.attributes:

00000000 <.MP430.attributes>:
   0:	41 16       	popm.a	#5,	r5	;20-bit words
   2:	00 00       	beq			
   4:	00 6d       	addc	r13,	r0	;
   6:	
Disassembly of section .comment:

00000000 <.comment>:
   0:	47 43       	clr.b	r7		;
   2:	43 3a       	jl	$-888    	;abs 0xfffffffffffffc8a
   4:	20 28       	jnc	$+66     	;abs 0x46
   6:	4d 69       	addc.b	r9,	r13	;
   8:	74 74       	subc.b	@r4+,	r4	;
   a:	6f 20       	jnz	$+224    	;abs 0xea
   c:	
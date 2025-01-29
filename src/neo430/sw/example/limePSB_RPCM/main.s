
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
  30:	35 40 ac 10 	mov	#4268,	r5	;#0x10ac
  34:	36 40 b0 10 	mov	#4272,	r6	;#0x10b0
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
  5a:	b0 12 a8 00 	call	#168		;#0x00a8

0000005e <__crt0_this_is_the_end>:
  5e:	02 43       	clr	r2		;
  60:	b2 40 00 47 	mov	#18176,	&0xffb8	;#0x4700
  64:	b8 ff 
  66:	32 40 10 00 	mov	#16,	r2	;#0x0010
  6a:	03 43       	nop			

0000006c <ext_irq_ch0_handler>:
  6c:	3c 40 0c c0 	mov	#-16372,r12	;#0xc00c
  70:	b0 12 40 04 	call	#1088		;#0x0440
  74:	30 41       	ret			

00000076 <Control_TCXO_DAC>:
  76:	0a 12       	push	r10		;
  78:	09 12       	push	r9		;
  7a:	08 12       	push	r8		;
  7c:	48 4c       	mov.b	r12,	r8	;
  7e:	0a 4d       	mov	r13,	r10	;
  80:	4c 43       	clr.b	r12		;
  82:	b0 12 8e 05 	call	#1422		;#0x058e
  86:	39 40 b2 05 	mov	#1458,	r9	;#0x05b2
  8a:	0c 48       	mov	r8,	r12	;
  8c:	7c f0 03 00 	and.b	#3,	r12	;
  90:	89 12       	call	r9		;
  92:	0c 4a       	mov	r10,	r12	;
  94:	7d 42       	mov.b	#8,	r13	;r2 As==11
  96:	b0 12 ac 0c 	call	#3244		;#0x0cac
  9a:	89 12       	call	r9		;
  9c:	4c 4a       	mov.b	r10,	r12	;
  9e:	89 12       	call	r9		;
  a0:	b0 12 aa 05 	call	#1450		;#0x05aa
  a4:	30 40 7c 0c 	br	#0x0c7c		;

000000a8 <main>:
  a8:	0a 12       	push	r10		;
  aa:	09 12       	push	r9		;
  ac:	08 12       	push	r8		;
  ae:	07 12       	push	r7		;
  b0:	06 12       	push	r6		;
  b2:	05 12       	push	r5		;
  b4:	04 12       	push	r4		;
  b6:	31 80 12 00 	sub	#18,	r1	;#0x0012
  ba:	4c 43       	clr.b	r12		;
  bc:	b0 12 6c 05 	call	#1388		;#0x056c
  c0:	b2 d0 80 00 	bis	#128,	&0xffa4	;#0x0080
  c4:	a4 ff 
  c6:	a2 b3 f2 ff 	bit	#2,	&0xfff2	;r3 As==10
  ca:	fa 24       	jz	$+502    	;abs 0x2c0
  cc:	1c 42 f2 ff 	mov	&0xfff2,r12	;0xfff2
  d0:	0c 93       	cmp	#0,	r12	;r3 As==00
  d2:	f6 34       	jge	$+494    	;abs 0x2c0
  d4:	b1 40 6c 00 	mov	#108,	0(r1)	;#0x006c
  d8:	00 00 
  da:	81 43 02 00 	mov	#0,	2(r1)	;r3 As==00
  de:	81 43 04 00 	mov	#0,	4(r1)	;r3 As==00
  e2:	81 43 06 00 	mov	#0,	6(r1)	;r3 As==00
  e6:	81 43 08 00 	mov	#0,	8(r1)	;r3 As==00
  ea:	81 43 0a 00 	mov	#0,	10(r1)	;r3 As==00, 0x000a
  ee:	81 43 0c 00 	mov	#0,	12(r1)	;r3 As==00, 0x000c
  f2:	81 43 0e 00 	mov	#0,	14(r1)	;r3 As==00, 0x000e
  f6:	d1 43 10 00 	mov.b	#1,	16(r1)	;r3 As==01, 0x0010
  fa:	0c 41       	mov	r1,	r12	;
  fc:	b0 12 fe 04 	call	#1278		;#0x04fe
 100:	b0 12 f8 04 	call	#1272		;#0x04f8
 104:	b0 12 d0 04 	call	#1232		;#0x04d0
 108:	c2 43 0c c0 	mov.b	#0,	&0xc00c	;r3 As==00
 10c:	3d 40 fa 77 	mov	#30714,	r13	;#0x77fa
 110:	7c 42       	mov.b	#8,	r12	;r2 As==11
 112:	b0 12 1c 04 	call	#1052		;#0x041c
 116:	3d 40 fa 77 	mov	#30714,	r13	;#0x77fa
 11a:	4c 43       	clr.b	r12		;
 11c:	b0 12 76 00 	call	#118		;#0x0076
 120:	49 43       	clr.b	r9		;
 122:	48 43       	clr.b	r8		;
 124:	46 43       	clr.b	r6		;
 126:	47 43       	clr.b	r7		;
 128:	4d 43       	clr.b	r13		;
 12a:	4a 43       	clr.b	r10		;

0000012c <.L5>:
 12c:	1c 42 aa ff 	mov	&0xffaa,r12	;0xffaa
 130:	5c f3       	and.b	#1,	r12	;r3 As==01
 132:	45 4c       	mov.b	r12,	r5	;
 134:	4c 9d       	cmp.b	r13,	r12	;
 136:	07 24       	jz	$+16     	;abs 0x146
 138:	05 93       	cmp	#0,	r5	;r3 As==00
 13a:	16 24       	jz	$+46     	;abs 0x168
 13c:	b0 12 ac 04 	call	#1196		;#0x04ac
 140:	d2 43 0c c0 	mov.b	#1,	&0xc00c	;r3 As==01

00000144 <.L26>:
 144:	4a 43       	clr.b	r10		;

00000146 <.L6>:
 146:	5c 42 0c c0 	mov.b	&0xc00c,r12	;0xc00c
 14a:	0c 93       	cmp	#0,	r12	;r3 As==00
 14c:	1b 24       	jz	$+56     	;abs 0x184
 14e:	c2 43 0c c0 	mov.b	#0,	&0xc00c	;r3 As==00
 152:	2a 93       	cmp	#2,	r10	;r3 As==10
 154:	34 24       	jz	$+106    	;abs 0x1be
 156:	6c 43       	mov.b	#2,	r12	;r3 As==10
 158:	0c 9a       	cmp	r10,	r12	;
 15a:	0b 28       	jnc	$+24     	;abs 0x172
 15c:	0a 93       	cmp	#0,	r10	;r3 As==00
 15e:	14 24       	jz	$+42     	;abs 0x188
 160:	1a 93       	cmp	#1,	r10	;r3 As==01
 162:	1e 24       	jz	$+62     	;abs 0x1a0

00000164 <.L29>:
 164:	6a 43       	mov.b	#2,	r10	;r3 As==10
 166:	08 3c       	jmp	$+18     	;abs 0x178

00000168 <.L7>:
 168:	b0 12 be 04 	call	#1214		;#0x04be
 16c:	c2 43 0c c0 	mov.b	#0,	&0xc00c	;r3 As==00
 170:	e9 3f       	jmp	$-44     	;abs 0x144

00000172 <.L10>:
 172:	3a 90 03 00 	cmp	#3,	r10	;
 176:	55 24       	jz	$+172    	;abs 0x222

00000178 <.L13>:
 178:	4c 43       	clr.b	r12		;
 17a:	b0 12 2a 03 	call	#810		;#0x032a
 17e:	5c 43       	mov.b	#1,	r12	;r3 As==01
 180:	b0 12 48 03 	call	#840		;#0x0348

00000184 <.L8>:
 184:	0d 45       	mov	r5,	r13	;
 186:	d2 3f       	jmp	$-90     	;abs 0x12c

00000188 <.L11>:
 188:	4d 43       	clr.b	r13		;
 18a:	7c 42       	mov.b	#8,	r12	;r2 As==11
 18c:	b0 12 1c 04 	call	#1052		;#0x041c
 190:	82 43 08 c0 	mov	#0,	&0xc008	;r3 As==00
 194:	4d 43       	clr.b	r13		;
 196:	4c 43       	clr.b	r12		;
 198:	b0 12 76 00 	call	#118		;#0x0076
 19c:	5a 43       	mov.b	#1,	r10	;r3 As==01
 19e:	ec 3f       	jmp	$-38     	;abs 0x178

000001a0 <.L12>:
 1a0:	16 42 0e c0 	mov	&0xc00e,r6	;0xc00e
 1a4:	17 42 10 c0 	mov	&0xc010,r7	;0xc010
 1a8:	3d 43       	mov	#-1,	r13	;r3 As==11
 1aa:	7c 42       	mov.b	#8,	r12	;r2 As==11
 1ac:	b0 12 1c 04 	call	#1052		;#0x041c
 1b0:	b2 43 08 c0 	mov	#-1,	&0xc008	;r3 As==11
 1b4:	3d 43       	mov	#-1,	r13	;r3 As==11
 1b6:	4c 43       	clr.b	r12		;
 1b8:	b0 12 76 00 	call	#118		;#0x0076
 1bc:	d3 3f       	jmp	$-88     	;abs 0x164

000001be <.L9>:
 1be:	5d 43       	mov.b	#1,	r13	;r3 As==01
 1c0:	7c 40 1c 00 	mov.b	#28,	r12	;#0x001c
 1c4:	b0 12 fc 02 	call	#764		;#0x02fc
 1c8:	1c 42 0e c0 	mov	&0xc00e,r12	;0xc00e
 1cc:	1d 42 10 c0 	mov	&0xc010,r13	;0xc010
 1d0:	3a 40 70 0a 	mov	#2672,	r10	;#0x0a70
 1d4:	0c 86       	sub	r6,	r12	;
 1d6:	0d 77       	subc	r7,	r13	;
 1d8:	8a 12       	call	r10		;
 1da:	0e 4c       	mov	r12,	r14	;
 1dc:	0f 4d       	mov	r13,	r15	;
 1de:	3c 40 00 ff 	mov	#-256,	r12	;#0xff00
 1e2:	3d 40 7f 47 	mov	#18303,	r13	;#0x477f
 1e6:	b0 12 2c 09 	call	#2348		;#0x092c
 1ea:	09 4c       	mov	r12,	r9	;
 1ec:	08 4d       	mov	r13,	r8	;
 1ee:	0c 46       	mov	r6,	r12	;
 1f0:	0d 47       	mov	r7,	r13	;
 1f2:	8a 12       	call	r10		;
 1f4:	0e 49       	mov	r9,	r14	;
 1f6:	0f 48       	mov	r8,	r15	;
 1f8:	b0 12 dc 06 	call	#1756		;#0x06dc
 1fc:	b0 12 06 06 	call	#1542		;#0x0606
 200:	0a 4c       	mov	r12,	r10	;
 202:	0d 43       	clr	r13		;
 204:	0d 8a       	sub	r10,	r13	;
 206:	7c 42       	mov.b	#8,	r12	;r2 As==11
 208:	b0 12 1c 04 	call	#1052		;#0x041c
 20c:	4c 43       	clr.b	r12		;
 20e:	0c 8a       	sub	r10,	r12	;
 210:	82 4c 08 c0 	mov	r12,	&0xc008	;
 214:	0d 4c       	mov	r12,	r13	;
 216:	4c 43       	clr.b	r12		;
 218:	b0 12 76 00 	call	#118		;#0x0076
 21c:	7a 40 03 00 	mov.b	#3,	r10	;
 220:	ab 3f       	jmp	$-168    	;abs 0x178

00000222 <.L14>:
 222:	5c 42 12 c0 	mov.b	&0xc012,r12	;0xc012
 226:	0c 93       	cmp	#0,	r12	;r3 As==00
 228:	1e 24       	jz	$+62     	;abs 0x266
 22a:	14 42 0a c0 	mov	&0xc00a,r4	;0xc00a
 22e:	1c 42 0e c0 	mov	&0xc00e,r12	;0xc00e
 232:	1d 42 10 c0 	mov	&0xc010,r13	;0xc010
 236:	b0 12 70 0a 	call	#2672		;#0x0a70
 23a:	0e 49       	mov	r9,	r14	;
 23c:	0f 48       	mov	r8,	r15	;
 23e:	b0 12 dc 06 	call	#1756		;#0x06dc
 242:	b0 12 06 06 	call	#1542		;#0x0606

00000246 <.L27>:
 246:	0d 44       	mov	r4,	r13	;
 248:	0d 8c       	sub	r12,	r13	;
 24a:	82 4d 0a c0 	mov	r13,	&0xc00a	;
 24e:	7c 42       	mov.b	#8,	r12	;r2 As==11
 250:	b0 12 1c 04 	call	#1052		;#0x041c
 254:	92 42 0a c0 	mov	&0xc00a,&0xc008	;0xc00a
 258:	08 c0 
 25a:	1d 42 0a c0 	mov	&0xc00a,r13	;0xc00a
 25e:	4c 43       	clr.b	r12		;
 260:	b0 12 76 00 	call	#118		;#0x0076
 264:	89 3f       	jmp	$-236    	;abs 0x178

00000266 <.L15>:
 266:	5c 42 18 c0 	mov.b	&0xc018,r12	;0xc018
 26a:	0c 93       	cmp	#0,	r12	;r3 As==00
 26c:	14 24       	jz	$+42     	;abs 0x296
 26e:	14 42 0a c0 	mov	&0xc00a,r4	;0xc00a
 272:	1c 42 14 c0 	mov	&0xc014,r12	;0xc014
 276:	1d 42 16 c0 	mov	&0xc016,r13	;0xc016
 27a:	b0 12 70 0a 	call	#2672		;#0x0a70
 27e:	0e 49       	mov	r9,	r14	;
 280:	0f 48       	mov	r8,	r15	;
 282:	b0 12 dc 06 	call	#1756		;#0x06dc
 286:	b0 12 06 06 	call	#1542		;#0x0606
 28a:	7e 40 0a 00 	mov.b	#10,	r14	;#0x000a

0000028e <.L28>:
 28e:	4f 43       	clr.b	r15		;
 290:	b0 12 2a 0c 	call	#3114		;#0x0c2a
 294:	d8 3f       	jmp	$-78     	;abs 0x246

00000296 <.L16>:
 296:	5c 42 1e c0 	mov.b	&0xc01e,r12	;0xc01e
 29a:	0c 93       	cmp	#0,	r12	;r3 As==00
 29c:	6d 27       	jz	$-292    	;abs 0x178
 29e:	14 42 0a c0 	mov	&0xc00a,r4	;0xc00a
 2a2:	1c 42 1a c0 	mov	&0xc01a,r12	;0xc01a
 2a6:	1d 42 1c c0 	mov	&0xc01c,r13	;0xc01c
 2aa:	b0 12 70 0a 	call	#2672		;#0x0a70
 2ae:	0e 49       	mov	r9,	r14	;
 2b0:	0f 48       	mov	r8,	r15	;
 2b2:	b0 12 dc 06 	call	#1756		;#0x06dc
 2b6:	b0 12 06 06 	call	#1542		;#0x0606
 2ba:	7e 40 64 00 	mov.b	#100,	r14	;#0x0064
 2be:	e7 3f       	jmp	$-48     	;abs 0x28e

000002c0 <.L4>:
 2c0:	5c 43       	mov.b	#1,	r12	;r3 As==01
 2c2:	31 50 12 00 	add	#18,	r1	;#0x0012
 2c6:	30 40 74 0c 	br	#0x0c74		;

000002ca <vctcxo_tamer_read>:
 2ca:	0a 12       	push	r10		;
 2cc:	3c f0 ff 00 	and	#255,	r12	;#0x00ff
 2d0:	0d 43       	clr	r13		;
 2d2:	b0 12 c4 05 	call	#1476		;#0x05c4
 2d6:	7a 40 65 00 	mov.b	#101,	r10	;#0x0065

000002da <.L3>:
 2da:	b0 12 f6 05 	call	#1526		;#0x05f6
 2de:	0c 93       	cmp	#0,	r12	;r3 As==00
 2e0:	08 24       	jz	$+18     	;abs 0x2f2
 2e2:	3a 53       	add	#-1,	r10	;r3 As==11
 2e4:	0a 93       	cmp	#0,	r10	;r3 As==00
 2e6:	f9 23       	jnz	$-12     	;abs 0x2da
 2e8:	b0 12 00 06 	call	#1536		;#0x0600
 2ec:	4c 43       	clr.b	r12		;

000002ee <.L4>:
 2ee:	3a 41       	pop	r10		;
 2f0:	30 41       	ret			

000002f2 <.L2>:
 2f2:	b0 12 ec 05 	call	#1516		;#0x05ec
 2f6:	3c f0 ff 00 	and	#255,	r12	;#0x00ff
 2fa:	f9 3f       	jmp	$-12     	;abs 0x2ee

000002fc <vctcxo_tamer_write>:
 2fc:	0a 12       	push	r10		;
 2fe:	3c f0 ff 00 	and	#255,	r12	;#0x00ff
 302:	3d f0 ff 00 	and	#255,	r13	;#0x00ff
 306:	0e 4d       	mov	r13,	r14	;
 308:	0f 43       	clr	r15		;
 30a:	0d 43       	clr	r13		;
 30c:	b0 12 d4 05 	call	#1492		;#0x05d4
 310:	7a 40 65 00 	mov.b	#101,	r10	;#0x0065

00000314 <.L8>:
 314:	b0 12 f6 05 	call	#1526		;#0x05f6
 318:	0c 93       	cmp	#0,	r12	;r3 As==00
 31a:	05 24       	jz	$+12     	;abs 0x326
 31c:	3a 53       	add	#-1,	r10	;r3 As==11
 31e:	0a 93       	cmp	#0,	r10	;r3 As==00
 320:	f9 23       	jnz	$-12     	;abs 0x314
 322:	b0 12 00 06 	call	#1536		;#0x0600

00000326 <.L6>:
 326:	3a 41       	pop	r10		;
 328:	30 41       	ret			

0000032a <vctcxo_tamer_reset_counters>:
 32a:	5d 42 20 c0 	mov.b	&0xc020,r13	;0xc020
 32e:	4c 93       	cmp.b	#0,	r12	;r3 As==00
 330:	09 24       	jz	$+20     	;abs 0x344
 332:	5d d3       	bis.b	#1,	r13	;r3 As==01

00000334 <.L16>:
 334:	c2 4d 20 c0 	mov.b	r13,	&0xc020	;
 338:	5d 42 20 c0 	mov.b	&0xc020,r13	;0xc020
 33c:	4c 43       	clr.b	r12		;
 33e:	b0 12 fc 02 	call	#764		;#0x02fc
 342:	30 41       	ret			

00000344 <.L14>:
 344:	5d c3       	bic.b	#1,	r13	;r3 As==01
 346:	f6 3f       	jmp	$-18     	;abs 0x334

00000348 <vctcxo_tamer_enable_isr>:
 348:	5d 42 20 c0 	mov.b	&0xc020,r13	;0xc020
 34c:	4c 93       	cmp.b	#0,	r12	;r3 As==00
 34e:	0a 24       	jz	$+22     	;abs 0x364
 350:	7d d0 10 00 	bis.b	#16,	r13	;#0x0010

00000354 <.L20>:
 354:	c2 4d 20 c0 	mov.b	r13,	&0xc020	;
 358:	5d 42 20 c0 	mov.b	&0xc020,r13	;0xc020
 35c:	4c 43       	clr.b	r12		;
 35e:	b0 12 fc 02 	call	#764		;#0x02fc
 362:	30 41       	ret			

00000364 <.L18>:
 364:	7d f0 ef ff 	and.b	#-17,	r13	;#0xffef
 368:	f5 3f       	jmp	$-20     	;abs 0x354

0000036a <vctcxo_tamer_clear_isr>:
 36a:	5d 42 20 c0 	mov.b	&0xc020,r13	;0xc020
 36e:	7d d0 20 00 	bis.b	#32,	r13	;#0x0020
 372:	4c 43       	clr.b	r12		;
 374:	b0 12 fc 02 	call	#764		;#0x02fc
 378:	30 41       	ret			

0000037a <vctcxo_tamer_set_tune_mode>:
 37a:	0a 12       	push	r10		;
 37c:	09 12       	push	r9		;
 37e:	08 12       	push	r8		;
 380:	0a 4c       	mov	r12,	r10	;
 382:	6c 43       	mov.b	#2,	r12	;r3 As==10
 384:	0c 9a       	cmp	r10,	r12	;
 386:	1e 28       	jnc	$+62     	;abs 0x3c4
 388:	38 40 48 03 	mov	#840,	r8	;#0x0348
 38c:	4c 43       	clr.b	r12		;
 38e:	88 12       	call	r8		;
 390:	59 42 20 c0 	mov.b	&0xc020,r9	;0xc020
 394:	79 f0 3f 00 	and.b	#63,	r9	;#0x003f
 398:	0c 4a       	mov	r10,	r12	;
 39a:	7d 40 06 00 	mov.b	#6,	r13	;
 39e:	b0 12 88 0c 	call	#3208		;#0x0c88
 3a2:	4d 49       	mov.b	r9,	r13	;
 3a4:	4d dc       	bis.b	r12,	r13	;
 3a6:	c2 4d 20 c0 	mov.b	r13,	&0xc020	;
 3aa:	4c 43       	clr.b	r12		;
 3ac:	b0 12 fc 02 	call	#764		;#0x02fc
 3b0:	39 40 2a 03 	mov	#810,	r9	;#0x032a
 3b4:	5c 43       	mov.b	#1,	r12	;r3 As==01
 3b6:	89 12       	call	r9		;
 3b8:	0a 93       	cmp	#0,	r10	;r3 As==00
 3ba:	04 24       	jz	$+10     	;abs 0x3c4
 3bc:	4c 43       	clr.b	r12		;
 3be:	89 12       	call	r9		;
 3c0:	5c 43       	mov.b	#1,	r12	;r3 As==01
 3c2:	88 12       	call	r8		;

000003c4 <.L22>:
 3c4:	30 40 7c 0c 	br	#0x0c7c		;

000003c8 <vctcxo_tamer_read_count>:
 3c8:	0a 12       	push	r10		;
 3ca:	09 12       	push	r9		;
 3cc:	08 12       	push	r8		;
 3ce:	07 12       	push	r7		;
 3d0:	06 12       	push	r6		;
 3d2:	48 4c       	mov.b	r12,	r8	;
 3d4:	39 40 ca 02 	mov	#714,	r9	;#0x02ca
 3d8:	4c 48       	mov.b	r8,	r12	;
 3da:	89 12       	call	r9		;
 3dc:	46 4c       	mov.b	r12,	r6	;
 3de:	07 43       	clr	r7		;
 3e0:	4c 48       	mov.b	r8,	r12	;
 3e2:	5c 53       	inc.b	r12		;
 3e4:	89 12       	call	r9		;
 3e6:	47 4c       	mov.b	r12,	r7	;
 3e8:	4c 48       	mov.b	r8,	r12	;
 3ea:	6c 53       	incd.b	r12		;
 3ec:	89 12       	call	r9		;
 3ee:	4a 4c       	mov.b	r12,	r10	;
 3f0:	4c 47       	mov.b	r7,	r12	;
 3f2:	0d 43       	clr	r13		;
 3f4:	7e 42       	mov.b	#8,	r14	;r2 As==11
 3f6:	b0 12 94 0c 	call	#3220		;#0x0c94
 3fa:	3a f0 ff 00 	and	#255,	r10	;#0x00ff
 3fe:	0a dd       	bis	r13,	r10	;
 400:	06 dc       	bis	r12,	r6	;
 402:	4c 48       	mov.b	r8,	r12	;
 404:	7c 50 03 00 	add.b	#3,	r12	;
 408:	89 12       	call	r9		;
 40a:	0d 43       	clr	r13		;
 40c:	7e 40 18 00 	mov.b	#24,	r14	;#0x0018
 410:	b0 12 94 0c 	call	#3220		;#0x0c94
 414:	0c d6       	bis	r6,	r12	;
 416:	0d da       	bis	r10,	r13	;
 418:	30 40 78 0c 	br	#0x0c78		;

0000041c <vctcxo_trim_dac_write>:
 41c:	0a 12       	push	r10		;
 41e:	09 12       	push	r9		;
 420:	0a 4d       	mov	r13,	r10	;
 422:	39 40 fc 02 	mov	#764,	r9	;#0x02fc
 426:	7c 40 20 00 	mov.b	#32,	r12	;#0x0020
 42a:	89 12       	call	r9		;
 42c:	0c 4a       	mov	r10,	r12	;
 42e:	7d 42       	mov.b	#8,	r13	;r2 As==11
 430:	b0 12 ac 0c 	call	#3244		;#0x0cac
 434:	4d 4c       	mov.b	r12,	r13	;
 436:	7c 40 21 00 	mov.b	#33,	r12	;#0x0021
 43a:	89 12       	call	r9		;
 43c:	30 40 7e 0c 	br	#0x0c7e		;

00000440 <vctcxo_tamer_isr>:
 440:	0a 12       	push	r10		;
 442:	09 12       	push	r9		;
 444:	0a 4c       	mov	r12,	r10	;
 446:	4c 43       	clr.b	r12		;
 448:	b0 12 48 03 	call	#840		;#0x0348
 44c:	5c 43       	mov.b	#1,	r12	;r3 As==01
 44e:	b0 12 2a 03 	call	#810		;#0x032a
 452:	39 40 c8 03 	mov	#968,	r9	;#0x03c8
 456:	6c 42       	mov.b	#4,	r12	;r2 As==10
 458:	89 12       	call	r9		;
 45a:	8a 4c 02 00 	mov	r12,	2(r10)	;
 45e:	8a 4d 04 00 	mov	r13,	4(r10)	;
 462:	7c 40 0c 00 	mov.b	#12,	r12	;#0x000c
 466:	89 12       	call	r9		;
 468:	8a 4c 08 00 	mov	r12,	8(r10)	;
 46c:	8a 4d 0a 00 	mov	r13,	10(r10)	; 0x000a
 470:	7c 40 14 00 	mov.b	#20,	r12	;#0x0014
 474:	89 12       	call	r9		;
 476:	8a 4c 0e 00 	mov	r12,	14(r10)	; 0x000e
 47a:	8a 4d 10 00 	mov	r13,	16(r10)	; 0x0010
 47e:	5c 43       	mov.b	#1,	r12	;r3 As==01
 480:	b0 12 ca 02 	call	#714		;#0x02ca
 484:	4d 4c       	mov.b	r12,	r13	;
 486:	5c f3       	and.b	#1,	r12	;r3 As==01
 488:	ca 4c 06 00 	mov.b	r12,	6(r10)	;
 48c:	0c 4d       	mov	r13,	r12	;
 48e:	0c 11       	rra	r12		;
 490:	5c f3       	and.b	#1,	r12	;r3 As==01
 492:	ca 4c 0c 00 	mov.b	r12,	12(r10)	; 0x000c
 496:	0d 11       	rra	r13		;
 498:	0d 11       	rra	r13		;
 49a:	5d f3       	and.b	#1,	r13	;r3 As==01
 49c:	ca 4d 12 00 	mov.b	r13,	18(r10)	; 0x0012
 4a0:	b0 12 6a 03 	call	#874		;#0x036a
 4a4:	da 43 00 00 	mov.b	#1,	0(r10)	;r3 As==01
 4a8:	30 40 7e 0c 	br	#0x0c7e		;

000004ac <vctcxo_tamer_init>:
 4ac:	4d 43       	clr.b	r13		;
 4ae:	7c 40 1c 00 	mov.b	#28,	r12	;#0x001c
 4b2:	b0 12 fc 02 	call	#764		;#0x02fc
 4b6:	5c 43       	mov.b	#1,	r12	;r3 As==01
 4b8:	b0 12 7a 03 	call	#890		;#0x037a
 4bc:	30 41       	ret			

000004be <vctcxo_tamer_dis>:
 4be:	4c 43       	clr.b	r12		;
 4c0:	b0 12 7a 03 	call	#890		;#0x037a
 4c4:	4d 43       	clr.b	r13		;
 4c6:	7c 40 1c 00 	mov.b	#28,	r12	;#0x001c
 4ca:	b0 12 fc 02 	call	#764		;#0x02fc
 4ce:	30 41       	ret			

000004d0 <neo430_eint>:
 4d0:	32 d2       	eint			
 4d2:	03 43       	nop			
 4d4:	30 41       	ret			

000004d6 <_exirq_irq_handler_>:
 4d6:	0d 12       	push	r13		;
 4d8:	0c 12       	push	r12		;
 4da:	3d 40 ee ff 	mov	#-18,	r13	;#0xffee
 4de:	2c 4d       	mov	@r13,	r12	;
 4e0:	bd d0 20 00 	bis	#32,	0(r13)	;#0x0020
 4e4:	00 00 
 4e6:	7c f0 07 00 	and.b	#7,	r12	;
 4ea:	0c 5c       	rla	r12		;
 4ec:	1c 4c 22 c0 	mov	-16350(r12),r12	;0xffffc022
 4f0:	8c 12       	call	r12		;
 4f2:	3c 41       	pop	r12		;
 4f4:	3d 41       	pop	r13		;
 4f6:	00 13       	reti			

000004f8 <neo430_exirq_enable>:
 4f8:	b2 d2 ee ff 	bis	#8,	&0xffee	;r2 As==11
 4fc:	30 41       	ret			

000004fe <neo430_exirq_config>:
 4fe:	0a 12       	push	r10		;
 500:	09 12       	push	r9		;
 502:	08 12       	push	r8		;
 504:	07 12       	push	r7		;
 506:	06 12       	push	r6		;
 508:	05 12       	push	r5		;
 50a:	25 4c       	mov	@r12,	r5	;
 50c:	16 4c 02 00 	mov	2(r12),	r6	;
 510:	17 4c 04 00 	mov	4(r12),	r7	;
 514:	18 4c 06 00 	mov	6(r12),	r8	;
 518:	19 4c 08 00 	mov	8(r12),	r9	;
 51c:	1b 4c 0a 00 	mov	10(r12),r11	;0x0000a
 520:	1f 4c 0c 00 	mov	12(r12),r15	;0x0000c
 524:	1e 4c 0e 00 	mov	14(r12),r14	;0x0000e
 528:	5c 4c 10 00 	mov.b	16(r12),r12	;0x00010
 52c:	3a 40 ee ff 	mov	#-18,	r10	;#0xffee
 530:	8a 43 00 00 	mov	#0,	0(r10)	;r3 As==00
 534:	3d 40 22 c0 	mov	#-16350,r13	;#0xc022
 538:	8d 45 00 00 	mov	r5,	0(r13)	;
 53c:	8d 46 02 00 	mov	r6,	2(r13)	;
 540:	8d 47 04 00 	mov	r7,	4(r13)	;
 544:	8d 48 06 00 	mov	r8,	6(r13)	;
 548:	8d 49 08 00 	mov	r9,	8(r13)	;
 54c:	8d 4b 0a 00 	mov	r11,	10(r13)	; 0x000a
 550:	8d 4f 0c 00 	mov	r15,	12(r13)	; 0x000c
 554:	8d 4e 0e 00 	mov	r14,	14(r13)	; 0x000e
 558:	b2 40 d6 04 	mov	#1238,	&0xc006	;#0x04d6
 55c:	06 c0 
 55e:	7d 42       	mov.b	#8,	r13	;r2 As==11
 560:	b0 12 88 0c 	call	#3208		;#0x0c88
 564:	8a 4c 00 00 	mov	r12,	0(r10)	;
 568:	30 40 76 0c 	br	#0x0c76		;

0000056c <neo430_spi_enable>:
 56c:	0a 12       	push	r10		;
 56e:	3a 40 a4 ff 	mov	#-92,	r10	;#0xffa4
 572:	8a 43 00 00 	mov	#0,	0(r10)	;r3 As==00
 576:	3c f0 ff 00 	and	#255,	r12	;#0x00ff
 57a:	7d 40 09 00 	mov.b	#9,	r13	;
 57e:	b0 12 88 0c 	call	#3208		;#0x0c88
 582:	3c d0 40 00 	bis	#64,	r12	;#0x0040
 586:	8a 4c 00 00 	mov	r12,	0(r10)	;
 58a:	3a 41       	pop	r10		;
 58c:	30 41       	ret			

0000058e <neo430_spi_cs_en>:
 58e:	0a 12       	push	r10		;
 590:	09 12       	push	r9		;
 592:	4d 4c       	mov.b	r12,	r13	;
 594:	3a 40 a4 ff 	mov	#-92,	r10	;#0xffa4
 598:	29 4a       	mov	@r10,	r9	;
 59a:	5c 43       	mov.b	#1,	r12	;r3 As==01
 59c:	b0 12 88 0c 	call	#3208		;#0x0c88
 5a0:	0c d9       	bis	r9,	r12	;
 5a2:	8a 4c 00 00 	mov	r12,	0(r10)	;
 5a6:	30 40 7e 0c 	br	#0x0c7e		;

000005aa <neo430_spi_cs_dis>:
 5aa:	b2 f0 c0 ff 	and	#-64,	&0xffa4	;#0xffc0
 5ae:	a4 ff 
 5b0:	30 41       	ret			

000005b2 <neo430_spi_trans>:
 5b2:	82 4c a6 ff 	mov	r12,	&0xffa6	;

000005b6 <.L6>:
 5b6:	1c 42 a4 ff 	mov	&0xffa4,r12	;0xffa4
 5ba:	0c 93       	cmp	#0,	r12	;r3 As==00
 5bc:	fc 3b       	jl	$-6      	;abs 0x5b6
 5be:	1c 42 a6 ff 	mov	&0xffa6,r12	;0xffa6
 5c2:	30 41       	ret			

000005c4 <neo430_wishbone32_read_start>:
 5c4:	b2 40 0f 00 	mov	#15,	&0xff90	;#0x000f
 5c8:	90 ff 
 5ca:	82 4c 92 ff 	mov	r12,	&0xff92	;
 5ce:	82 4d 94 ff 	mov	r13,	&0xff94	;
 5d2:	30 41       	ret			

000005d4 <neo430_wishbone32_write_start>:
 5d4:	b2 40 0f 00 	mov	#15,	&0xff90	;#0x000f
 5d8:	90 ff 
 5da:	82 4e 9a ff 	mov	r14,	&0xff9a	;
 5de:	82 4f 9c ff 	mov	r15,	&0xff9c	;
 5e2:	82 4c 96 ff 	mov	r12,	&0xff96	;
 5e6:	82 4d 98 ff 	mov	r13,	&0xff98	;
 5ea:	30 41       	ret			

000005ec <neo430_wishbone32_get_data>:
 5ec:	1c 42 9a ff 	mov	&0xff9a,r12	;0xff9a
 5f0:	1d 42 9c ff 	mov	&0xff9c,r13	;0xff9c
 5f4:	30 41       	ret			

000005f6 <neo430_wishbone_busy>:
 5f6:	1c 42 90 ff 	mov	&0xff90,r12	;0xff90
 5fa:	3c f0 00 80 	and	#-32768,r12	;#0x8000
 5fe:	30 41       	ret			

00000600 <neo430_wishbone_terminate>:
 600:	82 43 90 ff 	mov	#0,	&0xff90	;r3 As==00
 604:	30 41       	ret			

00000606 <lroundf>:
 606:	0a 12       	push	r10		;

00000608 <.LCFI0>:
 608:	09 12       	push	r9		;

0000060a <.LCFI1>:
 60a:	08 12       	push	r8		;

0000060c <.LCFI2>:
 60c:	07 12       	push	r7		;

0000060e <.LCFI3>:
 60e:	06 12       	push	r6		;

00000610 <.LCFI4>:
 610:	05 12       	push	r5		;

00000612 <.LCFI5>:
 612:	07 4c       	mov	r12,	r7	;
 614:	06 4d       	mov	r13,	r6	;

00000616 <.LBB2>:
 616:	05 4c       	mov	r12,	r5	;
 618:	0a 4d       	mov	r13,	r10	;

0000061a <.LBE2>:
 61a:	7e 40 17 00 	mov.b	#23,	r14	;#0x0017
 61e:	b0 12 ba 0c 	call	#3258		;#0x0cba

00000622 <.LVL2>:
 622:	4f 43       	clr.b	r15		;
 624:	4e 4c       	mov.b	r12,	r14	;

00000626 <.Loc.27.1>:
 626:	3e 50 81 ff 	add	#-127,	r14	;#0xff81
 62a:	3f 63       	addc	#-1,	r15	;r3 As==11

0000062c <.Loc.27.1>:
 62c:	0c 4e       	mov	r14,	r12	;

0000062e <.LVL3>:
 62e:	38 43       	mov	#-1,	r8	;r3 As==11
 630:	39 43       	mov	#-1,	r9	;r3 As==11
 632:	06 93       	cmp	#0,	r6	;r3 As==00
 634:	02 38       	jl	$+6      	;abs 0x63a
 636:	58 43       	mov.b	#1,	r8	;r3 As==01
 638:	49 43       	clr.b	r9		;

0000063a <.L2>:
 63a:	4d 43       	clr.b	r13		;
 63c:	0d 9f       	cmp	r15,	r13	;
 63e:	06 38       	jl	$+14     	;abs 0x64c
 640:	0f 93       	cmp	#0,	r15	;r3 As==00
 642:	09 20       	jnz	$+20     	;abs 0x656
 644:	7d 40 1e 00 	mov.b	#30,	r13	;#0x001e
 648:	0d 9c       	cmp	r12,	r13	;
 64a:	0f 2c       	jc	$+32     	;abs 0x66a

0000064c <.L4>:
 64c:	0c 47       	mov	r7,	r12	;

0000064e <.LVL5>:
 64e:	0d 46       	mov	r6,	r13	;
 650:	b0 12 16 0b 	call	#2838		;#0x0b16

00000654 <.LVL6>:
 654:	2b 3c       	jmp	$+88     	;abs 0x6ac

00000656 <.L14>:
 656:	0f 93       	cmp	#0,	r15	;r3 As==00
 658:	08 34       	jge	$+18     	;abs 0x66a

0000065a <.Loc.35.1>:
 65a:	3c 93       	cmp	#-1,	r12	;r3 As==11
 65c:	3c 20       	jnz	$+122    	;abs 0x6d6
 65e:	3f 93       	cmp	#-1,	r15	;r3 As==11
 660:	3a 20       	jnz	$+118    	;abs 0x6d6

00000662 <.L1>:
 662:	0c 48       	mov	r8,	r12	;
 664:	0d 49       	mov	r9,	r13	;
 666:	30 40 76 0c 	br	#0x0c76		;

0000066a <.L6>:
 66a:	7a f0 7f 00 	and.b	#127,	r10	;#0x007f

0000066e <.Loc.30.1>:
 66e:	07 45       	mov	r5,	r7	;
 670:	06 4a       	mov	r10,	r6	;
 672:	36 d0 80 00 	bis	#128,	r6	;#0x0080

00000676 <.Loc.36.1>:
 676:	0a 4e       	mov	r14,	r10	;

00000678 <.Loc.36.1>:
 678:	4d 43       	clr.b	r13		;
 67a:	0d 9f       	cmp	r15,	r13	;
 67c:	06 38       	jl	$+14     	;abs 0x68a

0000067e <.LVL11>:
 67e:	0f 93       	cmp	#0,	r15	;r3 As==00
 680:	18 20       	jnz	$+50     	;abs 0x6b2
 682:	7d 40 16 00 	mov.b	#22,	r13	;#0x0016
 686:	0d 9c       	cmp	r12,	r13	;
 688:	14 2c       	jc	$+42     	;abs 0x6b2

0000068a <.L15>:
 68a:	3a 50 e9 ff 	add	#-23,	r10	;#0xffe9

0000068e <.LVL12>:
 68e:	0c 47       	mov	r7,	r12	;

00000690 <.LVL13>:
 690:	0d 46       	mov	r6,	r13	;
 692:	0e 4a       	mov	r10,	r14	;
 694:	3e b0 00 80 	bit	#-32768,r14	;#0x8000
 698:	0f 7f       	subc	r15,	r15	;
 69a:	3f e3       	inv	r15		;

0000069c <.LVL14>:
 69c:	b0 12 94 0c 	call	#3220		;#0x0c94

000006a0 <.L16>:
 6a0:	0e 4c       	mov	r12,	r14	;
 6a2:	0f 4d       	mov	r13,	r15	;

000006a4 <.LVL16>:
 6a4:	0c 48       	mov	r8,	r12	;
 6a6:	0d 49       	mov	r9,	r13	;
 6a8:	b0 12 58 0f 	call	#3928		;#0x0f58

000006ac <.L17>:
 6ac:	08 4c       	mov	r12,	r8	;

000006ae <.LVL18>:
 6ae:	09 4d       	mov	r13,	r9	;
 6b0:	d8 3f       	jmp	$-78     	;abs 0x662

000006b2 <.L9>:
 6b2:	4c 43       	clr.b	r12		;
 6b4:	7d 40 40 00 	mov.b	#64,	r13	;#0x0040
 6b8:	0e 4a       	mov	r10,	r14	;
 6ba:	3e b0 00 80 	bit	#-32768,r14	;#0x8000
 6be:	0f 7f       	subc	r15,	r15	;
 6c0:	3f e3       	inv	r15		;
 6c2:	b0 12 a0 0c 	call	#3232		;#0x0ca0

000006c6 <.LVL21>:
 6c6:	0c 57       	add	r7,	r12	;
 6c8:	0d 66       	addc	r6,	r13	;
 6ca:	3e 40 17 00 	mov	#23,	r14	;#0x0017
 6ce:	0e 8a       	sub	r10,	r14	;
 6d0:	b0 12 ba 0c 	call	#3258		;#0x0cba
 6d4:	e5 3f       	jmp	$-52     	;abs 0x6a0

000006d6 <.L13>:
 6d6:	48 43       	clr.b	r8		;

000006d8 <.LVL24>:
 6d8:	49 43       	clr.b	r9		;
 6da:	c3 3f       	jmp	$-120    	;abs 0x662

000006dc <__mspabi_mpyf>:
 6dc:	0a 12       	push	r10		;

000006de <.LCFI0>:
 6de:	09 12       	push	r9		;

000006e0 <.LCFI1>:
 6e0:	08 12       	push	r8		;

000006e2 <.LCFI2>:
 6e2:	07 12       	push	r7		;

000006e4 <L0^A>:
 6e4:	06 12       	push	r6		;

000006e6 <.LCFI4>:
 6e6:	05 12       	push	r5		;

000006e8 <.LCFI5>:
 6e8:	04 12       	push	r4		;

000006ea <.LCFI6>:
 6ea:	31 80 30 00 	sub	#48,	r1	;#0x0030

000006ee <.LCFI7>:
 6ee:	81 4c 0a 00 	mov	r12,	10(r1)	; 0x000a
 6f2:	81 4d 0c 00 	mov	r13,	12(r1)	; 0x000c

000006f6 <.Loc.936.1>:
 6f6:	81 4e 0e 00 	mov	r14,	14(r1)	; 0x000e
 6fa:	81 4f 10 00 	mov	r15,	16(r1)	; 0x0010

000006fe <.Loc.938.1>:
 6fe:	3a 40 68 0e 	mov	#3688,	r10	;#0x0e68
 702:	0d 41       	mov	r1,	r13	;
 704:	3d 50 12 00 	add	#18,	r13	;#0x0012
 708:	0c 41       	mov	r1,	r12	;

0000070a <.LVL1>:
 70a:	3c 50 0a 00 	add	#10,	r12	;#0x000a
 70e:	8a 12       	call	r10		;

00000710 <.LVL2>:
 710:	0d 41       	mov	r1,	r13	;
 712:	3d 50 1c 00 	add	#28,	r13	;#0x001c
 716:	0c 41       	mov	r1,	r12	;
 718:	3c 50 0e 00 	add	#14,	r12	;#0x000e
 71c:	8a 12       	call	r10		;

0000071e <.LBB30>:
 71e:	19 41 12 00 	mov	18(r1),	r9	;0x00012

00000722 <.LBB45>:
 722:	56 43       	mov.b	#1,	r6	;r3 As==01
 724:	06 99       	cmp	r9,	r6	;
 726:	11 28       	jnc	$+36     	;abs 0x74a

00000728 <.L6>:
 728:	1c 41 14 00 	mov	20(r1),	r12	;0x00014
 72c:	1c e1 1e 00 	xor	30(r1),	r12	;0x0001e
 730:	0d 43       	clr	r13		;
 732:	0d 8c       	sub	r12,	r13	;
 734:	0c dd       	bis	r13,	r12	;
 736:	7d 40 0f 00 	mov.b	#15,	r13	;#0x000f
 73a:	b0 12 ac 0c 	call	#3244		;#0x0cac

0000073e <.L52>:
 73e:	81 4c 14 00 	mov	r12,	20(r1)	; 0x0014

00000742 <.Loc.801.1>:
 742:	0c 41       	mov	r1,	r12	;
 744:	3c 50 12 00 	add	#18,	r12	;#0x0012
 748:	1c 3c       	jmp	$+58     	;abs 0x782

0000074a <.L2>:
 74a:	1a 41 1c 00 	mov	28(r1),	r10	;0x0001c

0000074e <.LBB46>:
 74e:	57 43       	mov.b	#1,	r7	;r3 As==01
 750:	07 9a       	cmp	r10,	r7	;
 752:	11 28       	jnc	$+36     	;abs 0x776

00000754 <.L8>:
 754:	1c 41 14 00 	mov	20(r1),	r12	;0x00014
 758:	1c e1 1e 00 	xor	30(r1),	r12	;0x0001e
 75c:	0d 43       	clr	r13		;
 75e:	0d 8c       	sub	r12,	r13	;
 760:	0c dd       	bis	r13,	r12	;
 762:	7d 40 0f 00 	mov.b	#15,	r13	;#0x000f
 766:	b0 12 ac 0c 	call	#3244		;#0x0cac

0000076a <.Loc.779.1>:
 76a:	81 4c 1e 00 	mov	r12,	30(r1)	; 0x001e

0000076e <.L53>:
 76e:	0c 41       	mov	r1,	r12	;
 770:	3c 50 1c 00 	add	#28,	r12	;#0x001c
 774:	06 3c       	jmp	$+14     	;abs 0x782

00000776 <.L4>:
 776:	29 92       	cmp	#4,	r9	;r2 As==10
 778:	0a 20       	jnz	$+22     	;abs 0x78e

0000077a <.LBB48>:
 77a:	3c 40 a2 0f 	mov	#4002,	r12	;#0x0fa2

0000077e <.Loc.784.1>:
 77e:	2a 93       	cmp	#2,	r10	;r3 As==10
 780:	d3 23       	jnz	$-88     	;abs 0x728

00000782 <.L3>:
 782:	b0 12 08 0d 	call	#3336		;#0x0d08

00000786 <.LVL13>:
 786:	31 50 30 00 	add	#48,	r1	;#0x0030

0000078a <.LCFI8>:
 78a:	30 40 74 0c 	br	#0x0c74		;

0000078e <.L5>:
 78e:	2a 92       	cmp	#4,	r10	;r2 As==10
 790:	05 20       	jnz	$+12     	;abs 0x79c

00000792 <.LBB51>:
 792:	3c 40 a2 0f 	mov	#4002,	r12	;#0x0fa2

00000796 <.Loc.791.1>:
 796:	29 93       	cmp	#2,	r9	;r3 As==10
 798:	f4 27       	jz	$-22     	;abs 0x782
 79a:	dc 3f       	jmp	$-70     	;abs 0x754

0000079c <.L7>:
 79c:	1c 41 1e 00 	mov	30(r1),	r12	;0x0001e
 7a0:	1c e1 14 00 	xor	20(r1),	r12	;0x00014
 7a4:	0d 43       	clr	r13		;
 7a6:	0d 8c       	sub	r12,	r13	;
 7a8:	0c dd       	bis	r13,	r12	;
 7aa:	7d 40 0f 00 	mov.b	#15,	r13	;#0x000f
 7ae:	b0 12 ac 0c 	call	#3244		;#0x0cac
 7b2:	81 4c 06 00 	mov	r12,	6(r1)	;

000007b6 <.LBB52>:
 7b6:	29 93       	cmp	#2,	r9	;r3 As==10
 7b8:	c2 27       	jz	$-122    	;abs 0x73e

000007ba <.LBB53>:
 7ba:	2a 93       	cmp	#2,	r10	;r3 As==10
 7bc:	04 20       	jnz	$+10     	;abs 0x7c6

000007be <.Loc.805.1>:
 7be:	91 41 06 00 	mov	6(r1),	30(r1)	; 0x001e
 7c2:	1e 00 
 7c4:	d4 3f       	jmp	$-86     	;abs 0x76e

000007c6 <.L10>:
 7c6:	91 41 18 00 	mov	24(r1),	2(r1)	;0x00018
 7ca:	02 00 
 7cc:	91 41 1a 00 	mov	26(r1),	4(r1)	;0x0001a
 7d0:	04 00 

000007d2 <.Loc.815.1>:
 7d2:	1c 41 22 00 	mov	34(r1),	r12	;0x00022
 7d6:	1d 41 24 00 	mov	36(r1),	r13	;0x00024

000007da <.LVL20>:
 7da:	b1 40 20 00 	mov	#32,	0(r1)	;#0x0020
 7de:	00 00 

000007e0 <.LBE32>:
 7e0:	4e 43       	clr.b	r14		;
 7e2:	4f 43       	clr.b	r15		;

000007e4 <.LBB34>:
 7e4:	08 4e       	mov	r14,	r8	;
 7e6:	09 4f       	mov	r15,	r9	;

000007e8 <.LBE34>:
 7e8:	0a 4e       	mov	r14,	r10	;
 7ea:	0b 4f       	mov	r15,	r11	;

000007ec <.L17>:
 7ec:	17 41 02 00 	mov	2(r1),	r7	;
 7f0:	57 f3       	and.b	#1,	r7	;r3 As==01

000007f2 <.Loc.824.1>:
 7f2:	07 93       	cmp	#0,	r7	;r3 As==00
 7f4:	1a 24       	jz	$+54     	;abs 0x82a

000007f6 <.Loc.826.1>:
 7f6:	0a 5c       	add	r12,	r10	;

000007f8 <.LVL22>:
 7f8:	0b 6d       	addc	r13,	r11	;

000007fa <.LVL23>:
 7fa:	05 48       	mov	r8,	r5	;
 7fc:	05 5e       	add	r14,	r5	;
 7fe:	06 49       	mov	r9,	r6	;
 800:	06 6f       	addc	r15,	r6	;
 802:	81 46 08 00 	mov	r6,	8(r1)	;

00000806 <.Loc.826.1>:
 806:	57 43       	mov.b	#1,	r7	;r3 As==01
 808:	46 43       	clr.b	r6		;
 80a:	04 4b       	mov	r11,	r4	;
 80c:	0b 9d       	cmp	r13,	r11	;
 80e:	08 28       	jnc	$+18     	;abs 0x820
 810:	04 4d       	mov	r13,	r4	;
 812:	0d 9b       	cmp	r11,	r13	;
 814:	03 20       	jnz	$+8      	;abs 0x81c
 816:	04 4a       	mov	r10,	r4	;
 818:	0a 9c       	cmp	r12,	r10	;
 81a:	02 28       	jnc	$+6      	;abs 0x820

0000081c <.L14>:
 81c:	47 43       	clr.b	r7		;
 81e:	46 43       	clr.b	r6		;

00000820 <.L13>:
 820:	0e 47       	mov	r7,	r14	;

00000822 <.LVL24>:
 822:	0e 55       	add	r5,	r14	;
 824:	1f 41 08 00 	mov	8(r1),	r15	;
 828:	0f 66       	addc	r6,	r15	;

0000082a <.L11>:
 82a:	06 48       	mov	r8,	r6	;
 82c:	07 49       	mov	r9,	r7	;
 82e:	06 58       	add	r8,	r6	;
 830:	07 69       	addc	r9,	r7	;
 832:	08 46       	mov	r6,	r8	;

00000834 <.LVL26>:
 834:	09 47       	mov	r7,	r9	;

00000836 <.LVL27>:
 836:	0d 93       	cmp	#0,	r13	;r3 As==00
 838:	02 34       	jge	$+6      	;abs 0x83e

0000083a <.Loc.832.1>:
 83a:	16 d3       	bis	#1,	r6	;r3 As==01
 83c:	08 46       	mov	r6,	r8	;

0000083e <.L15>:
 83e:	06 4c       	mov	r12,	r6	;
 840:	07 4d       	mov	r13,	r7	;
 842:	06 5c       	add	r12,	r6	;
 844:	07 6d       	addc	r13,	r7	;
 846:	0c 46       	mov	r6,	r12	;

00000848 <.LVL29>:
 848:	0d 47       	mov	r7,	r13	;

0000084a <.LVL30>:
 84a:	12 c3       	clrc			
 84c:	11 10 04 00 	rrc	4(r1)		;
 850:	11 10 02 00 	rrc	2(r1)		;

00000854 <.LBE33>:
 854:	b1 53 00 00 	add	#-1,	0(r1)	;r3 As==11

00000858 <.LVL32>:
 858:	81 93 00 00 	cmp	#0,	0(r1)	;r3 As==00
 85c:	c7 23       	jnz	$-112    	;abs 0x7ec

0000085e <.LBE35>:
 85e:	1d 41 16 00 	mov	22(r1),	r13	;0x00016
 862:	1d 51 20 00 	add	32(r1),	r13	;0x00020

00000866 <.Loc.876.1>:
 866:	2d 53       	incd	r13		;

00000868 <.Loc.875.1>:
 868:	81 4d 2a 00 	mov	r13,	42(r1)	; 0x002a

0000086c <.Loc.877.1>:
 86c:	91 41 06 00 	mov	6(r1),	40(r1)	; 0x0028
 870:	28 00 

00000872 <.Loc.878.1>:
 872:	4c 43       	clr.b	r12		;

00000874 <.L18>:
 874:	09 4f       	mov	r15,	r9	;
 876:	0f 93       	cmp	#0,	r15	;r3 As==00
 878:	1f 38       	jl	$+64     	;abs 0x8b8
 87a:	0c 93       	cmp	#0,	r12	;r3 As==00
 87c:	02 24       	jz	$+6      	;abs 0x882
 87e:	81 4d 2a 00 	mov	r13,	42(r1)	; 0x002a

00000882 <.L23>:
 882:	1c 41 2a 00 	mov	42(r1),	r12	;0x0002a

00000886 <.Loc.895.1>:
 886:	4d 43       	clr.b	r13		;

00000888 <.L24>:
 888:	38 40 ff 3f 	mov	#16383,	r8	;#0x3fff
 88c:	08 9f       	cmp	r15,	r8	;
 88e:	27 28       	jnc	$+80     	;abs 0x8de

00000890 <.Loc.890.1>:
 890:	06 4e       	mov	r14,	r6	;
 892:	07 4f       	mov	r15,	r7	;
 894:	06 5e       	add	r14,	r6	;
 896:	07 6f       	addc	r15,	r7	;
 898:	0e 46       	mov	r6,	r14	;

0000089a <.LVL34>:
 89a:	0f 47       	mov	r7,	r15	;

0000089c <.LVL35>:
 89c:	0b 93       	cmp	#0,	r11	;r3 As==00
 89e:	03 34       	jge	$+8      	;abs 0x8a6

000008a0 <.Loc.894.1>:
 8a0:	09 4e       	mov	r14,	r9	;
 8a2:	19 d3       	bis	#1,	r9	;r3 As==01
 8a4:	0e 49       	mov	r9,	r14	;

000008a6 <.L25>:
 8a6:	07 4a       	mov	r10,	r7	;
 8a8:	08 4b       	mov	r11,	r8	;
 8aa:	07 5a       	add	r10,	r7	;
 8ac:	08 6b       	addc	r11,	r8	;
 8ae:	0a 47       	mov	r7,	r10	;

000008b0 <.LVL37>:
 8b0:	0b 48       	mov	r8,	r11	;

000008b2 <.LVL38>:
 8b2:	3c 53       	add	#-1,	r12	;r3 As==11
 8b4:	5d 43       	mov.b	#1,	r13	;r3 As==01
 8b6:	e8 3f       	jmp	$-46     	;abs 0x888

000008b8 <.L21>:
 8b8:	0c 4e       	mov	r14,	r12	;
 8ba:	5c f3       	and.b	#1,	r12	;r3 As==01

000008bc <.Loc.881.1>:
 8bc:	0c 93       	cmp	#0,	r12	;r3 As==00
 8be:	09 24       	jz	$+20     	;abs 0x8d2

000008c0 <.Loc.883.1>:
 8c0:	08 4a       	mov	r10,	r8	;
 8c2:	09 4b       	mov	r11,	r9	;
 8c4:	12 c3       	clrc			
 8c6:	09 10       	rrc	r9		;
 8c8:	08 10       	rrc	r8		;

000008ca <.LVL39>:
 8ca:	0a 48       	mov	r8,	r10	;
 8cc:	0b 49       	mov	r9,	r11	;
 8ce:	3b d0 00 80 	bis	#-32768,r11	;#0x8000

000008d2 <.L19>:
 8d2:	12 c3       	clrc			
 8d4:	0f 10       	rrc	r15		;
 8d6:	0e 10       	rrc	r14		;
 8d8:	1d 53       	inc	r13		;
 8da:	5c 43       	mov.b	#1,	r12	;r3 As==01
 8dc:	cb 3f       	jmp	$-104    	;abs 0x874

000008de <.L34>:
 8de:	0d 93       	cmp	#0,	r13	;r3 As==00
 8e0:	02 24       	jz	$+6      	;abs 0x8e6
 8e2:	81 4c 2a 00 	mov	r12,	42(r1)	; 0x002a

000008e6 <.L29>:
 8e6:	0c 4e       	mov	r14,	r12	;
 8e8:	7c f0 7f 00 	and.b	#127,	r12	;#0x007f

000008ec <.Loc.898.1>:
 8ec:	3c 90 40 00 	cmp	#64,	r12	;#0x0040
 8f0:	12 20       	jnz	$+38     	;abs 0x916

000008f2 <.Loc.900.1>:
 8f2:	0c 4e       	mov	r14,	r12	;
 8f4:	7c f0 80 00 	and.b	#128,	r12	;#0x0080

000008f8 <.Loc.900.1>:
 8f8:	0c 93       	cmp	#0,	r12	;r3 As==00
 8fa:	0d 20       	jnz	$+28     	;abs 0x916

000008fc <.Loc.909.1>:
 8fc:	0c 4a       	mov	r10,	r12	;
 8fe:	0c db       	bis	r11,	r12	;
 900:	0c 93       	cmp	#0,	r12	;r3 As==00
 902:	09 24       	jz	$+20     	;abs 0x916

00000904 <.Loc.915.1>:
 904:	0d 4e       	mov	r14,	r13	;
 906:	3d 50 40 00 	add	#64,	r13	;#0x0040
 90a:	0c 4f       	mov	r15,	r12	;
 90c:	0c 63       	adc	r12		;

0000090e <.LVL42>:
 90e:	0e 4d       	mov	r13,	r14	;
 910:	3e f0 80 ff 	and	#-128,	r14	;#0xff80
 914:	0f 4c       	mov	r12,	r15	;

00000916 <.L30>:
 916:	81 4e 2c 00 	mov	r14,	44(r1)	; 0x002c
 91a:	81 4f 2e 00 	mov	r15,	46(r1)	; 0x002e

0000091e <.Loc.922.1>:
 91e:	b1 40 03 00 	mov	#3,	38(r1)	; 0x0026
 922:	26 00 

00000924 <.Loc.923.1>:
 924:	0c 41       	mov	r1,	r12	;
 926:	3c 50 26 00 	add	#38,	r12	;#0x0026
 92a:	2b 3f       	jmp	$-424    	;abs 0x782

0000092c <__mspabi_divf>:
 92c:	0a 12       	push	r10		;

0000092e <.LCFI0>:
 92e:	09 12       	push	r9		;

00000930 <.LCFI1>:
 930:	08 12       	push	r8		;

00000932 <.LCFI2>:
 932:	07 12       	push	r7		;

00000934 <.LCFI3>:
 934:	06 12       	push	r6		;

00000936 <.LCFI4>:
 936:	05 12       	push	r5		;

00000938 <.LCFI5>:
 938:	31 80   	sub	#28,	r1	;#0x001c

0000093a <L0^A>:
 93a:	1c 00       	mova	@r0+,	r12	;

0000093c <.LCFI6>:
 93c:	81 4c 00 00 	mov	r12,	0(r1)	;
 940:	81 4d 02 00 	mov	r13,	2(r1)	;

00000944 <.Loc.1054.1>:
 944:	81 4e 04 00 	mov	r14,	4(r1)	;
 948:	81 4f 06 00 	mov	r15,	6(r1)	;

0000094c <.Loc.1056.1>:
 94c:	3a 40 68 0e 	mov	#3688,	r10	;#0x0e68
 950:	0d 41       	mov	r1,	r13	;
 952:	3d 52       	add	#8,	r13	;r2 As==11
 954:	0c 41       	mov	r1,	r12	;

00000956 <.LVL1>:
 956:	8a 12       	call	r10		;

00000958 <.LVL2>:
 958:	0d 41       	mov	r1,	r13	;
 95a:	3d 50 12 00 	add	#18,	r13	;#0x0012
 95e:	0c 41       	mov	r1,	r12	;
 960:	2c 52       	add	#4,	r12	;r2 As==10
 962:	8a 12       	call	r10		;

00000964 <.LBB20>:
 964:	1e 41 08 00 	mov	8(r1),	r14	;

00000968 <.LBB29>:
 968:	55 43       	mov.b	#1,	r5	;r3 As==01
 96a:	05 9e       	cmp	r14,	r5	;
 96c:	03 28       	jnc	$+8      	;abs 0x974

0000096e <.L23>:
 96e:	0c 41       	mov	r1,	r12	;
 970:	3c 52       	add	#8,	r12	;r2 As==11
 972:	15 3c       	jmp	$+44     	;abs 0x99e

00000974 <.L2>:
 974:	1d 41 12 00 	mov	18(r1),	r13	;0x00012

00000978 <.LBB30>:
 978:	0c 41       	mov	r1,	r12	;
 97a:	3c 50 12 00 	add	#18,	r12	;#0x0012

0000097e <.Loc.961.1>:
 97e:	56 43       	mov.b	#1,	r6	;r3 As==01
 980:	06 9d       	cmp	r13,	r6	;
 982:	0d 2c       	jc	$+28     	;abs 0x99e

00000984 <.Loc.966.1>:
 984:	91 e1 14 00 	xor	20(r1),	10(r1)	;0x00014, 0x000a
 988:	0a 00 

0000098a <.LBB31>:
 98a:	0c 4e       	mov	r14,	r12	;
 98c:	3c 50 fe ff 	add	#-2,	r12	;#0xfffe
 990:	3c b0 fd ff 	bit	#-3,	r12	;#0xfffd
 994:	09 20       	jnz	$+20     	;abs 0x9a8

00000996 <.Loc.970.1>:
 996:	3c 40 a2 0f 	mov	#4002,	r12	;#0x0fa2

0000099a <.Loc.970.1>:
 99a:	0e 9d       	cmp	r13,	r14	;
 99c:	e8 23       	jnz	$-46     	;abs 0x96e

0000099e <.L3>:
 99e:	b0 12 08 0d 	call	#3336		;#0x0d08

000009a2 <.LVL10>:
 9a2:	31 50 1c 00 	add	#28,	r1	;#0x001c

000009a6 <.LCFI7>:
 9a6:	67 3d       	jmp	$+720    	;abs 0xc76

000009a8 <.L4>:
 9a8:	2d 92       	cmp	#4,	r13	;r2 As==10
 9aa:	07 20       	jnz	$+16     	;abs 0x9ba

000009ac <.Loc.977.1>:
 9ac:	81 43 0e 00 	mov	#0,	14(r1)	;r3 As==00, 0x000e
 9b0:	81 43 10 00 	mov	#0,	16(r1)	;r3 As==00, 0x0010

000009b4 <.Loc.978.1>:
 9b4:	81 43 0c 00 	mov	#0,	12(r1)	;r3 As==00, 0x000c

000009b8 <.Loc.979.1>:
 9b8:	da 3f       	jmp	$-74     	;abs 0x96e

000009ba <.L6>:
 9ba:	2d 93       	cmp	#2,	r13	;r3 As==10
 9bc:	03 20       	jnz	$+8      	;abs 0x9c4

000009be <.Loc.983.1>:
 9be:	a1 42 08 00 	mov	#4,	8(r1)	;r2 As==10

000009c2 <.Loc.984.1>:
 9c2:	d5 3f       	jmp	$-84     	;abs 0x96e

000009c4 <.L7>:
 9c4:	1e 41 0c 00 	mov	12(r1),	r14	;0x0000c
 9c8:	1e 81 16 00 	sub	22(r1),	r14	;0x00016

000009cc <.Loc.994.1>:
 9cc:	81 4e 0c 00 	mov	r14,	12(r1)	; 0x000c

000009d0 <.Loc.995.1>:
 9d0:	1c 41 0e 00 	mov	14(r1),	r12	;0x0000e
 9d4:	1d 41 10 00 	mov	16(r1),	r13	;0x00010

000009d8 <.LVL13>:
 9d8:	1a 41 18 00 	mov	24(r1),	r10	;0x00018
 9dc:	1b 41 1a 00 	mov	26(r1),	r11	;0x0001a

000009e0 <.LVL14>:
 9e0:	0d 9b       	cmp	r11,	r13	;
 9e2:	04 28       	jnc	$+10     	;abs 0x9ec
 9e4:	0b 9d       	cmp	r13,	r11	;
 9e6:	0b 20       	jnz	$+24     	;abs 0x9fe
 9e8:	0c 9a       	cmp	r10,	r12	;
 9ea:	09 2c       	jc	$+20     	;abs 0x9fe

000009ec <.L17>:
 9ec:	08 4c       	mov	r12,	r8	;
 9ee:	09 4d       	mov	r13,	r9	;
 9f0:	08 5c       	add	r12,	r8	;
 9f2:	09 6d       	addc	r13,	r9	;
 9f4:	0c 48       	mov	r8,	r12	;

000009f6 <.LVL15>:
 9f6:	0d 49       	mov	r9,	r13	;

000009f8 <.LVL16>:
 9f8:	3e 53       	add	#-1,	r14	;r3 As==11
 9fa:	81 4e 0c 00 	mov	r14,	12(r1)	; 0x000c

000009fe <.L8>:
 9fe:	77 40 1f 00 	mov.b	#31,	r7	;#0x001f

00000a02 <.LBB35>:
 a02:	4e 43       	clr.b	r14		;
 a04:	4f 43       	clr.b	r15		;

00000a06 <.Loc.1004.1>:
 a06:	48 43       	clr.b	r8		;
 a08:	39 40 00 40 	mov	#16384,	r9	;#0x4000

00000a0c <.L12>:
 a0c:	0d 9b       	cmp	r11,	r13	;
 a0e:	0c 28       	jnc	$+26     	;abs 0xa28
 a10:	0b 9d       	cmp	r13,	r11	;
 a12:	02 20       	jnz	$+6      	;abs 0xa18
 a14:	0c 9a       	cmp	r10,	r12	;
 a16:	08 28       	jnc	$+18     	;abs 0xa28

00000a18 <.L18>:
 a18:	05 4e       	mov	r14,	r5	;
 a1a:	05 d8       	bis	r8,	r5	;
 a1c:	06 4f       	mov	r15,	r6	;
 a1e:	06 d9       	bis	r9,	r6	;
 a20:	0e 45       	mov	r5,	r14	;

00000a22 <.LVL19>:
 a22:	0f 46       	mov	r6,	r15	;

00000a24 <.LVL20>:
 a24:	0c 8a       	sub	r10,	r12	;
 a26:	0d 7b       	subc	r11,	r13	;

00000a28 <.L10>:
 a28:	12 c3       	clrc			
 a2a:	09 10       	rrc	r9		;
 a2c:	08 10       	rrc	r8		;

00000a2e <.Loc.1015.1>:
 a2e:	05 4c       	mov	r12,	r5	;
 a30:	06 4d       	mov	r13,	r6	;
 a32:	05 5c       	add	r12,	r5	;
 a34:	06 6d       	addc	r13,	r6	;
 a36:	0c 45       	mov	r5,	r12	;

00000a38 <.LVL23>:
 a38:	0d 46       	mov	r6,	r13	;

00000a3a <.LVL24>:
 a3a:	37 53       	add	#-1,	r7	;r3 As==11
 a3c:	07 93       	cmp	#0,	r7	;r3 As==00
 a3e:	e6 23       	jnz	$-50     	;abs 0xa0c

00000a40 <.Loc.1018.1>:
 a40:	0a 4e       	mov	r14,	r10	;

00000a42 <.LVL25>:
 a42:	7a f0 7f 00 	and.b	#127,	r10	;#0x007f

00000a46 <.Loc.1018.1>:
 a46:	3a 90 40 00 	cmp	#64,	r10	;#0x0040
 a4a:	0d 20       	jnz	$+28     	;abs 0xa66

00000a4c <.Loc.1020.1>:
 a4c:	0a 4e       	mov	r14,	r10	;
 a4e:	7a f0 80 00 	and.b	#128,	r10	;#0x0080

00000a52 <.Loc.1020.1>:
 a52:	0a 93       	cmp	#0,	r10	;r3 As==00
 a54:	08 20       	jnz	$+18     	;abs 0xa66

00000a56 <.Loc.1027.1>:
 a56:	0c d6       	bis	r6,	r12	;

00000a58 <.LVL26>:
 a58:	0c 93       	cmp	#0,	r12	;r3 As==00
 a5a:	05 24       	jz	$+12     	;abs 0xa66

00000a5c <.Loc.1033.1>:
 a5c:	3e 50 40 00 	add	#64,	r14	;#0x0040

00000a60 <.LVL27>:
 a60:	0f 63       	adc	r15		;

00000a62 <.LVL28>:
 a62:	3e f0 80 ff 	and	#-128,	r14	;#0xff80

00000a66 <.L13>:
 a66:	81 4e 0e 00 	mov	r14,	14(r1)	; 0x000e
 a6a:	81 4f 10 00 	mov	r15,	16(r1)	; 0x0010
 a6e:	7f 3f       	jmp	$-256    	;abs 0x96e

00000a70 <__mspabi_fltlif>:
 a70:	09 12       	push	r9		;

00000a72 <.LCFI0>:
 a72:	08 12       	push	r8		;

00000a74 <.LCFI1>:
 a74:	07 12       	push	r7		;

00000a76 <.LCFI2>:
 a76:	06 12       	push	r6		;

00000a78 <.LCFI3>:
 a78:	31 80   	sub	#10,	r1	;#0x000a

00000a7a <L0^A>:
 a7a:	0a 00       	mova	@r0,	r10	;

00000a7c <.LCFI4>:
 a7c:	08 4c       	mov	r12,	r8	;
 a7e:	09 4d       	mov	r13,	r9	;

00000a80 <.Loc.1318.1>:
 a80:	b1 40 03 00 	mov	#3,	0(r1)	;
 a84:	00 00 

00000a86 <.Loc.1321.1>:
 a86:	0c 4d       	mov	r13,	r12	;

00000a88 <.LVL1>:
 a88:	7d 40 0f 00 	mov.b	#15,	r13	;#0x000f
 a8c:	b0 12 ac 0c 	call	#3244		;#0x0cac

00000a90 <.Loc.1321.1>:
 a90:	81 4c 02 00 	mov	r12,	2(r1)	;

00000a94 <.Loc.1322.1>:
 a94:	0c 48       	mov	r8,	r12	;
 a96:	0c d9       	bis	r9,	r12	;
 a98:	0c 93       	cmp	#0,	r12	;r3 As==00
 a9a:	0c 20       	jnz	$+26     	;abs 0xab4

00000a9c <.Loc.1324.1>:
 a9c:	a1 43 00 00 	mov	#2,	0(r1)	;r3 As==10

00000aa0 <.L3>:
 aa0:	0c 41       	mov	r1,	r12	;
 aa2:	b0 12 08 0d 	call	#3336		;#0x0d08

00000aa6 <.L1>:
 aa6:	31 50 0a 00 	add	#10,	r1	;#0x000a

00000aaa <.LCFI5>:
 aaa:	36 41       	pop	r6		;

00000aac <.LCFI6>:
 aac:	37 41       	pop	r7		;

00000aae <.LCFI7>:
 aae:	38 41       	pop	r8		;

00000ab0 <.LCFI8>:
 ab0:	39 41       	pop	r9		;

00000ab2 <.LCFI9>:
 ab2:	30 41       	ret			

00000ab4 <.L2>:
 ab4:	b1 40 1e 00 	mov	#30,	4(r1)	;#0x001e
 ab8:	04 00 

00000aba <.Loc.1331.1>:
 aba:	09 93       	cmp	#0,	r9	;r3 As==00
 abc:	16 34       	jge	$+46     	;abs 0xaea

00000abe <.Loc.1335.1>:
 abe:	08 93       	cmp	#0,	r8	;r3 As==00
 ac0:	03 20       	jnz	$+8      	;abs 0xac8
 ac2:	39 90 00 80 	cmp	#-32768,r9	;#0x8000
 ac6:	23 24       	jz	$+72     	;abs 0xb0e

00000ac8 <.L11>:
 ac8:	46 43       	clr.b	r6		;
 aca:	47 43       	clr.b	r7		;
 acc:	06 88       	sub	r8,	r6	;
 ace:	07 79       	subc	r9,	r7	;

00000ad0 <.L8>:
 ad0:	0c 46       	mov	r6,	r12	;
 ad2:	0d 47       	mov	r7,	r13	;
 ad4:	b0 12 c0 0c 	call	#3264		;#0x0cc0

00000ad8 <.LBE6>:
 ad8:	09 4c       	mov	r12,	r9	;
 ada:	39 53       	add	#-1,	r9	;r3 As==11

00000adc <.LVL6>:
 adc:	1c 93       	cmp	#1,	r12	;r3 As==01
 ade:	08 20       	jnz	$+18     	;abs 0xaf0

00000ae0 <.Loc.1344.1>:
 ae0:	81 46 06 00 	mov	r6,	6(r1)	;
 ae4:	81 47 08 00 	mov	r7,	8(r1)	;
 ae8:	db 3f       	jmp	$-72     	;abs 0xaa0

00000aea <.L4>:
 aea:	06 48       	mov	r8,	r6	;
 aec:	07 49       	mov	r9,	r7	;

00000aee <.LVL8>:
 aee:	f0 3f       	jmp	$-30     	;abs 0xad0

00000af0 <.L9>:
 af0:	0c 46       	mov	r6,	r12	;
 af2:	0d 47       	mov	r7,	r13	;
 af4:	0e 49       	mov	r9,	r14	;
 af6:	b0 12 94 0c 	call	#3220		;#0x0c94
 afa:	81 4c 06 00 	mov	r12,	6(r1)	;
 afe:	81 4d 08 00 	mov	r13,	8(r1)	;

00000b02 <.Loc.1349.1>:
 b02:	7c 40 1e 00 	mov.b	#30,	r12	;#0x001e
 b06:	0c 89       	sub	r9,	r12	;
 b08:	81 4c 04 00 	mov	r12,	4(r1)	;
 b0c:	c9 3f       	jmp	$-108    	;abs 0xaa0

00000b0e <.L12>:
 b0e:	4c 43       	clr.b	r12		;
 b10:	3d 40 00 cf 	mov	#-12544,r13	;#0xcf00
 b14:	c8 3f       	jmp	$-110    	;abs 0xaa6

00000b16 <__mspabi_fixfli>:
 b16:	0a 12       	push	r10		;

00000b18 <.LCFI0>:
 b18:	31 80 0e 00 	sub	#14,	r1	;#0x000e

00000b1c <.LCFI1>:
 b1c:	81 4c   	mov	r12,	0(r1)	;

00000b1e <L0^A>:
 b1e:	00 00       	beq			
 b20:	81 4d 02 00 	mov	r13,	2(r1)	;

00000b24 <.Loc.1401.1>:
 b24:	0d 41       	mov	r1,	r13	;
 b26:	2d 52       	add	#4,	r13	;r2 As==10
 b28:	0c 41       	mov	r1,	r12	;

00000b2a <.LVL1>:
 b2a:	b0 12 68 0e 	call	#3688		;#0x0e68

00000b2e <.LVL2>:
 b2e:	1e 41 04 00 	mov	4(r1),	r14	;

00000b32 <.Loc.1405.1>:
 b32:	4c 43       	clr.b	r12		;
 b34:	4d 43       	clr.b	r13		;

00000b36 <.Loc.1405.1>:
 b36:	6f 43       	mov.b	#2,	r15	;r3 As==10
 b38:	0f 9e       	cmp	r14,	r15	;
 b3a:	1d 2c       	jc	$+60     	;abs 0xb76

00000b3c <.Loc.1408.1>:
 b3c:	2e 92       	cmp	#4,	r14	;r2 As==10
 b3e:	0a 20       	jnz	$+22     	;abs 0xb54

00000b40 <.Loc.1409.1>:
 b40:	3c 43       	mov	#-1,	r12	;r3 As==11
 b42:	3d 40 ff 7f 	mov	#32767,	r13	;#0x7fff
 b46:	81 93 06 00 	cmp	#0,	6(r1)	;r3 As==00
 b4a:	15 24       	jz	$+44     	;abs 0xb76

00000b4c <.L12>:
 b4c:	4c 43       	clr.b	r12		;
 b4e:	3d 40 00 80 	mov	#-32768,r13	;#0x8000
 b52:	11 3c       	jmp	$+36     	;abs 0xb76

00000b54 <.L3>:
 b54:	1e 41 08 00 	mov	8(r1),	r14	;

00000b58 <.Loc.1406.1>:
 b58:	4c 43       	clr.b	r12		;
 b5a:	4d 43       	clr.b	r13		;

00000b5c <.Loc.1411.1>:
 b5c:	0e 93       	cmp	#0,	r14	;r3 As==00
 b5e:	0b 38       	jl	$+24     	;abs 0xb76

00000b60 <.Loc.1413.1>:
 b60:	1a 41 06 00 	mov	6(r1),	r10	;

00000b64 <.Loc.1413.1>:
 b64:	7c 40 1e 00 	mov.b	#30,	r12	;#0x001e
 b68:	0c 9e       	cmp	r14,	r12	;
 b6a:	09 34       	jge	$+20     	;abs 0xb7e

00000b6c <.Loc.1409.1>:
 b6c:	3c 43       	mov	#-1,	r12	;r3 As==11
 b6e:	3d 40 ff 7f 	mov	#32767,	r13	;#0x7fff

00000b72 <.Loc.1414.1>:
 b72:	0a 93       	cmp	#0,	r10	;r3 As==00
 b74:	eb 23       	jnz	$-40     	;abs 0xb4c

00000b76 <.L1>:
 b76:	31 50 0e 00 	add	#14,	r1	;#0x000e

00000b7a <.LCFI2>:
 b7a:	3a 41       	pop	r10		;

00000b7c <.LCFI3>:
 b7c:	30 41       	ret			

00000b7e <.L4>:
 b7e:	1c 41 0a 00 	mov	10(r1),	r12	;0x0000a
 b82:	1d 41 0c 00 	mov	12(r1),	r13	;0x0000c
 b86:	7f 40 1e 00 	mov.b	#30,	r15	;#0x001e
 b8a:	0f 8e       	sub	r14,	r15	;
 b8c:	0e 4f       	mov	r15,	r14	;
 b8e:	b0 12 ba 0c 	call	#3258		;#0x0cba

00000b92 <.LVL7>:
 b92:	0a 93       	cmp	#0,	r10	;r3 As==00
 b94:	f0 27       	jz	$-30     	;abs 0xb76

00000b96 <.Loc.1416.1>:
 b96:	4e 43       	clr.b	r14		;
 b98:	4f 43       	clr.b	r15		;
 b9a:	0e 8c       	sub	r12,	r14	;
 b9c:	0f 7d       	subc	r13,	r15	;
 b9e:	0c 4e       	mov	r14,	r12	;

00000ba0 <.LVL8>:
 ba0:	0d 4f       	mov	r15,	r13	;
 ba2:	e9 3f       	jmp	$-44     	;abs 0xb76

00000ba4 <udivmodsi4>:
 ba4:	0a 12       	push	r10		;

00000ba6 <.LCFI0>:
 ba6:	09 12       	push	r9		;

00000ba8 <L0^A>:
 ba8:	08 12       	push	r8		;

00000baa <.LCFI2>:
 baa:	07 12       	push	r7		;

00000bac <.LCFI3>:
 bac:	06 12       	push	r6		;

00000bae <.LCFI4>:
 bae:	0a 4c       	mov	r12,	r10	;
 bb0:	0b 4d       	mov	r13,	r11	;

00000bb2 <.LVL1>:
 bb2:	7c 40 21 00 	mov.b	#33,	r12	;#0x0021

00000bb6 <.LVL2>:
 bb6:	58 43       	mov.b	#1,	r8	;r3 As==01
 bb8:	49 43       	clr.b	r9		;

00000bba <.L2>:
 bba:	0f 9b       	cmp	r11,	r15	;
 bbc:	04 28       	jnc	$+10     	;abs 0xbc6
 bbe:	0b 9f       	cmp	r15,	r11	;
 bc0:	07 20       	jnz	$+16     	;abs 0xbd0
 bc2:	0e 9a       	cmp	r10,	r14	;
 bc4:	05 2c       	jc	$+12     	;abs 0xbd0

00000bc6 <.L15>:
 bc6:	3c 53       	add	#-1,	r12	;r3 As==11

00000bc8 <.Loc.38.1>:
 bc8:	0c 93       	cmp	#0,	r12	;r3 As==00
 bca:	2c 24       	jz	$+90     	;abs 0xc24

00000bcc <.Loc.38.1>:
 bcc:	0f 93       	cmp	#0,	r15	;r3 As==00
 bce:	0c 34       	jge	$+26     	;abs 0xbe8

00000bd0 <.L13>:
 bd0:	4c 43       	clr.b	r12		;
 bd2:	4d 43       	clr.b	r13		;

00000bd4 <.L8>:
 bd4:	07 48       	mov	r8,	r7	;
 bd6:	07 d9       	bis	r9,	r7	;
 bd8:	07 93       	cmp	#0,	r7	;r3 As==00
 bda:	13 20       	jnz	$+40     	;abs 0xc02

00000bdc <.L5>:
 bdc:	81 93 0c 00 	cmp	#0,	12(r1)	;r3 As==00, 0x000c
 be0:	02 24       	jz	$+6      	;abs 0xbe6
 be2:	0c 4a       	mov	r10,	r12	;
 be4:	0d 4b       	mov	r11,	r13	;

00000be6 <.L1>:
 be6:	48 3c       	jmp	$+146    	;abs 0xc78

00000be8 <.L6>:
 be8:	06 4e       	mov	r14,	r6	;
 bea:	07 4f       	mov	r15,	r7	;
 bec:	06 5e       	add	r14,	r6	;
 bee:	07 6f       	addc	r15,	r7	;
 bf0:	0e 46       	mov	r6,	r14	;

00000bf2 <.LVL7>:
 bf2:	0f 47       	mov	r7,	r15	;

00000bf4 <.LVL8>:
 bf4:	06 48       	mov	r8,	r6	;
 bf6:	07 49       	mov	r9,	r7	;
 bf8:	06 58       	add	r8,	r6	;
 bfa:	07 69       	addc	r9,	r7	;
 bfc:	08 46       	mov	r6,	r8	;

00000bfe <.LVL9>:
 bfe:	09 47       	mov	r7,	r9	;

00000c00 <.LVL10>:
 c00:	dc 3f       	jmp	$-70     	;abs 0xbba

00000c02 <.L11>:
 c02:	0b 9f       	cmp	r15,	r11	;
 c04:	08 28       	jnc	$+18     	;abs 0xc16
 c06:	0f 9b       	cmp	r11,	r15	;
 c08:	02 20       	jnz	$+6      	;abs 0xc0e
 c0a:	0a 9e       	cmp	r14,	r10	;
 c0c:	04 28       	jnc	$+10     	;abs 0xc16

00000c0e <.L16>:
 c0e:	0a 8e       	sub	r14,	r10	;
 c10:	0b 7f       	subc	r15,	r11	;

00000c12 <.Loc.48.1>:
 c12:	0c d8       	bis	r8,	r12	;

00000c14 <.LVL13>:
 c14:	0d d9       	bis	r9,	r13	;

00000c16 <.L9>:
 c16:	12 c3       	clrc			
 c18:	09 10       	rrc	r9		;
 c1a:	08 10       	rrc	r8		;

00000c1c <.Loc.51.1>:
 c1c:	12 c3       	clrc			
 c1e:	0f 10       	rrc	r15		;
 c20:	0e 10       	rrc	r14		;
 c22:	d8 3f       	jmp	$-78     	;abs 0xbd4

00000c24 <.L14>:
 c24:	4c 43       	clr.b	r12		;
 c26:	4d 43       	clr.b	r13		;
 c28:	d9 3f       	jmp	$-76     	;abs 0xbdc

00000c2a <__mspabi_divli>:
 c2a:	0a 12       	push	r10		;

00000c2c <.LCFI6>:
 c2c:	09 12       	push	r9		;

00000c2e <.LCFI7>:
 c2e:	08 12       	push	r8		;

00000c30 <.LCFI8>:
 c30:	21 83       	decd	r1		;

00000c32 <L0^A>:
 c32:	4a 43       	clr.b	r10		;

00000c34 <.Loc.64.1>:
 c34:	0d 93       	cmp	#0,	r13	;r3 As==00
 c36:	07 34       	jge	$+16     	;abs 0xc46

00000c38 <.Loc.66.1>:
 c38:	48 43       	clr.b	r8		;
 c3a:	49 43       	clr.b	r9		;
 c3c:	08 8c       	sub	r12,	r8	;
 c3e:	09 7d       	subc	r13,	r9	;
 c40:	0c 48       	mov	r8,	r12	;

00000c42 <.LVL20>:
 c42:	0d 49       	mov	r9,	r13	;

00000c44 <.LVL21>:
 c44:	5a 43       	mov.b	#1,	r10	;r3 As==01

00000c46 <.L21>:
 c46:	0f 93       	cmp	#0,	r15	;r3 As==00
 c48:	07 34       	jge	$+16     	;abs 0xc58

00000c4a <.Loc.72.1>:
 c4a:	48 43       	clr.b	r8		;
 c4c:	49 43       	clr.b	r9		;
 c4e:	08 8e       	sub	r14,	r8	;
 c50:	09 7f       	subc	r15,	r9	;
 c52:	0e 48       	mov	r8,	r14	;

00000c54 <.LVL23>:
 c54:	0f 49       	mov	r9,	r15	;

00000c56 <.LVL24>:
 c56:	1a e3       	xor	#1,	r10	;r3 As==01

00000c58 <.L23>:
 c58:	81 43 00 00 	mov	#0,	0(r1)	;r3 As==00
 c5c:	b0 12 a4 0b 	call	#2980		;#0x0ba4

00000c60 <.LVL26>:
 c60:	0a 93       	cmp	#0,	r10	;r3 As==00
 c62:	06 24       	jz	$+14     	;abs 0xc70

00000c64 <.LVL27>:
 c64:	49 43       	clr.b	r9		;
 c66:	4a 43       	clr.b	r10		;
 c68:	09 8c       	sub	r12,	r9	;
 c6a:	0a 7d       	subc	r13,	r10	;
 c6c:	0c 49       	mov	r9,	r12	;

00000c6e <.LVL28>:
 c6e:	0d 4a       	mov	r10,	r13	;

00000c70 <.L20>:
 c70:	21 53       	incd	r1		;

00000c72 <.LCFI10>:
 c72:	04 3c       	jmp	$+10     	;abs 0xc7c

00000c74 <__mspabi_func_epilog_7>:
 c74:	34 41       	pop	r4		;

00000c76 <__mspabi_func_epilog_6>:
 c76:	35 41       	pop	r5		;

00000c78 <__mspabi_func_epilog_5>:
 c78:	36 41       	pop	r6		;

00000c7a <__mspabi_func_epilog_4>:
 c7a:	37 41       	pop	r7		;

00000c7c <__mspabi_func_epilog_3>:
 c7c:	38 41       	pop	r8		;

00000c7e <__mspabi_func_epilog_2>:
 c7e:	39 41       	pop	r9		;

00000c80 <__mspabi_func_epilog_1>:
 c80:	3a 41       	pop	r10		;
 c82:	30 41       	ret			

00000c84 <.L1^B1>:
 c84:	3d 53       	add	#-1,	r13	;r3 As==11
 c86:	0c 5c       	rla	r12		;

00000c88 <__mspabi_slli>:
 c88:	0d 93       	cmp	#0,	r13	;r3 As==00
 c8a:	fc 23       	jnz	$-6      	;abs 0xc84
 c8c:	30 41       	ret			

00000c8e <.L1^B2>:
 c8e:	3e 53       	add	#-1,	r14	;r3 As==11
 c90:	0c 5c       	rla	r12		;
 c92:	0d 6d       	rlc	r13		;

00000c94 <__mspabi_slll>:
 c94:	0e 93       	cmp	#0,	r14	;r3 As==00
 c96:	fb 23       	jnz	$-8      	;abs 0xc8e
 c98:	30 41       	ret			

00000c9a <.L1^B2>:
 c9a:	3e 53       	add	#-1,	r14	;r3 As==11
 c9c:	0d 11       	rra	r13		;
 c9e:	0c 10       	rrc	r12		;

00000ca0 <__mspabi_sral>:
 ca0:	0e 93       	cmp	#0,	r14	;r3 As==00
 ca2:	fb 23       	jnz	$-8      	;abs 0xc9a
 ca4:	30 41       	ret			

00000ca6 <.L1^B1>:
 ca6:	3d 53       	add	#-1,	r13	;r3 As==11
 ca8:	12 c3       	clrc			
 caa:	0c 10       	rrc	r12		;

00000cac <__mspabi_srli>:
 cac:	0d 93       	cmp	#0,	r13	;r3 As==00
 cae:	fb 23       	jnz	$-8      	;abs 0xca6
 cb0:	30 41       	ret			

00000cb2 <.L1^B2>:
 cb2:	3e 53       	add	#-1,	r14	;r3 As==11
 cb4:	12 c3       	clrc			
 cb6:	0d 10       	rrc	r13		;
 cb8:	0c 10       	rrc	r12		;

00000cba <__mspabi_srll>:
 cba:	0e 93       	cmp	#0,	r14	;r3 As==00
 cbc:	fa 23       	jnz	$-10     	;abs 0xcb2
 cbe:	30 41       	ret			

00000cc0 <__clzsi2>:
 cc0:	0a 12       	push	r10		;

00000cc2 <.LCFI0>:
 cc2:	09 12       	push	r9		;

00000cc4 <.LCFI1>:
 cc4:	08 12       	push	r8		;

00000cc6 <.LBB2>:
 cc6:	0d 93       	cmp	#0,	r13	;r3 As==00
 cc8:	08 20       	jnz	$+18     	;abs 0xcda
 cca:	7e 42       	mov.b	#8,	r14	;r2 As==11
 ccc:	4f 43       	clr.b	r15		;
 cce:	7a 40 ff 00 	mov.b	#255,	r10	;#0x00ff
 cd2:	0a 9c       	cmp	r12,	r10	;
 cd4:	0c 28       	jnc	$+26     	;abs 0xcee
 cd6:	4e 43       	clr.b	r14		;
 cd8:	09 3c       	jmp	$+20     	;abs 0xcec

00000cda <.L2>:
 cda:	7e 40 18 00 	mov.b	#24,	r14	;#0x0018
 cde:	4f 43       	clr.b	r15		;
 ce0:	7a 40 ff 00 	mov.b	#255,	r10	;#0x00ff
 ce4:	0a 9d       	cmp	r13,	r10	;
 ce6:	03 28       	jnc	$+8      	;abs 0xcee
 ce8:	7e 40 10 00 	mov.b	#16,	r14	;#0x0010

00000cec <.L12>:
 cec:	4f 43       	clr.b	r15		;

00000cee <.L4>:
 cee:	78 40 20 00 	mov.b	#32,	r8	;#0x0020
 cf2:	49 43       	clr.b	r9		;
 cf4:	08 8e       	sub	r14,	r8	;
 cf6:	09 7f       	subc	r15,	r9	;
 cf8:	b0 12 ba 0c 	call	#3258		;#0x0cba

00000cfc <.LBE3>:
 cfc:	0d 48       	mov	r8,	r13	;
 cfe:	5c 4c ac 0f 	mov.b	4012(r12),r12	;0x00fac
 d02:	0d 8c       	sub	r12,	r13	;
 d04:	0c 4d       	mov	r13,	r12	;
 d06:	ba 3f       	jmp	$-138    	;abs 0xc7c

00000d08 <__pack_f>:
 d08:	0a 12       	push	r10		;

00000d0a <.LCFI0>:
 d0a:	09 12       	push	r9		;

00000d0c <L0^A>:
 d0c:	08 12       	push	r8		;

00000d0e <.LCFI2>:
 d0e:	07 12       	push	r7		;

00000d10 <.LCFI3>:
 d10:	06 12       	push	r6		;

00000d12 <.LCFI4>:
 d12:	05 12       	push	r5		;

00000d14 <.LCFI5>:
 d14:	18 4c 06 00 	mov	6(r12),	r8	;
 d18:	19 4c 08 00 	mov	8(r12),	r9	;

00000d1c <.LVL1>:
 d1c:	16 4c 02 00 	mov	2(r12),	r6	;

00000d20 <.LVL2>:
 d20:	2d 4c       	mov	@r12,	r13	;

00000d22 <.Loc.151.1>:
 d22:	5e 43       	mov.b	#1,	r14	;r3 As==01
 d24:	0e 9d       	cmp	r13,	r14	;
 d26:	20 28       	jnc	$+66     	;abs 0xd68

00000d28 <.LVL4>:
 d28:	0c 48       	mov	r8,	r12	;

00000d2a <.LVL5>:
 d2a:	0d 49       	mov	r9,	r13	;
 d2c:	7e 40 07 00 	mov.b	#7,	r14	;
 d30:	b0 12 ba 0c 	call	#3258		;#0x0cba

00000d34 <.LVL6>:
 d34:	7d f0 3f 00 	and.b	#63,	r13	;#0x003f

00000d38 <.Loc.211.1>:
 d38:	08 4c       	mov	r12,	r8	;
 d3a:	09 4d       	mov	r13,	r9	;
 d3c:	39 d0 40 00 	bis	#64,	r9	;#0x0040

00000d40 <.LVL8>:
 d40:	7a 40 ff 00 	mov.b	#255,	r10	;#0x00ff

00000d44 <.L3>:
 d44:	79 f0 7f 00 	and.b	#127,	r9	;#0x007f
 d48:	0c 4a       	mov	r10,	r12	;
 d4a:	7d 40 07 00 	mov.b	#7,	r13	;
 d4e:	b0 12 88 0c 	call	#3208		;#0x0c88
 d52:	0a 4c       	mov	r12,	r10	;

00000d54 <.LVL11>:
 d54:	0a d9       	bis	r9,	r10	;
 d56:	0c 46       	mov	r6,	r12	;
 d58:	7d 40 0f 00 	mov.b	#15,	r13	;#0x000f
 d5c:	b0 12 88 0c 	call	#3208		;#0x0c88
 d60:	0d 4c       	mov	r12,	r13	;

00000d62 <.Loc.423.1>:
 d62:	0c 48       	mov	r8,	r12	;
 d64:	0d da       	bis	r10,	r13	;
 d66:	87 3f       	jmp	$-240    	;abs 0xc76

00000d68 <.L2>:
 d68:	2d 92       	cmp	#4,	r13	;r2 As==10
 d6a:	7b 24       	jz	$+248    	;abs 0xe62

00000d6c <.Loc.168.1>:
 d6c:	2d 93       	cmp	#2,	r13	;r3 As==10
 d6e:	75 24       	jz	$+236    	;abs 0xe5a

00000d70 <.Loc.234.1>:
 d70:	0d 48       	mov	r8,	r13	;
 d72:	0d d9       	bis	r9,	r13	;

00000d74 <.Loc.231.1>:
 d74:	4a 43       	clr.b	r10		;

00000d76 <.Loc.234.1>:
 d76:	0d 93       	cmp	#0,	r13	;r3 As==00
 d78:	e5 27       	jz	$-52     	;abs 0xd44

00000d7a <.Loc.240.1>:
 d7a:	1a 4c 04 00 	mov	4(r12),	r10	;

00000d7e <.Loc.240.1>:
 d7e:	3a 90 82 ff 	cmp	#-126,	r10	;#0xff82
 d82:	49 34       	jge	$+148    	;abs 0xe16

00000d84 <.LBB10>:
 d84:	3c 40 82 ff 	mov	#-126,	r12	;#0xff82
 d88:	0c 8a       	sub	r10,	r12	;

00000d8a <.LVL15>:
 d8a:	7d 40 19 00 	mov.b	#25,	r13	;#0x0019
 d8e:	0d 9c       	cmp	r12,	r13	;
 d90:	3d 38       	jl	$+124    	;abs 0xe0c

00000d92 <.LBB11>:
 d92:	0c 48       	mov	r8,	r12	;

00000d94 <.LVL17>:
 d94:	0d 49       	mov	r9,	r13	;
 d96:	3e 40 82 ff 	mov	#-126,	r14	;#0xff82
 d9a:	0e 8a       	sub	r10,	r14	;

00000d9c <.LVL18>:
 d9c:	b0 12 ba 0c 	call	#3258		;#0x0cba

00000da0 <.LVL19>:
 da0:	05 4c       	mov	r12,	r5	;
 da2:	07 4d       	mov	r13,	r7	;

00000da4 <.Loc.264.1>:
 da4:	3c 43       	mov	#-1,	r12	;r3 As==11
 da6:	3d 43       	mov	#-1,	r13	;r3 As==11
 da8:	3e 40 82 ff 	mov	#-126,	r14	;#0xff82
 dac:	0e 8a       	sub	r10,	r14	;

00000dae <.LVL20>:
 dae:	b0 12 94 0c 	call	#3220		;#0x0c94

00000db2 <.LVL21>:
 db2:	0e 48       	mov	r8,	r14	;
 db4:	0e cc       	bic	r12,	r14	;
 db6:	0c 4e       	mov	r14,	r12	;
 db8:	0e 49       	mov	r9,	r14	;
 dba:	0e cd       	bic	r13,	r14	;

00000dbc <.Loc.264.1>:
 dbc:	0c de       	bis	r14,	r12	;
 dbe:	0d 43       	clr	r13		;
 dc0:	0d 8c       	sub	r12,	r13	;
 dc2:	0c dd       	bis	r13,	r12	;
 dc4:	7d 40 0f 00 	mov.b	#15,	r13	;#0x000f
 dc8:	b0 12 ac 0c 	call	#3244		;#0x0cac

00000dcc <.Loc.265.1>:
 dcc:	0e 45       	mov	r5,	r14	;
 dce:	0e dc       	bis	r12,	r14	;
 dd0:	0f 47       	mov	r7,	r15	;

00000dd2 <.LBE11>:
 dd2:	0c 4e       	mov	r14,	r12	;
 dd4:	7c f0 7f 00 	and.b	#127,	r12	;#0x007f

00000dd8 <.Loc.267.1>:
 dd8:	3c 90 40 00 	cmp	#64,	r12	;#0x0040
 ddc:	19 20       	jnz	$+52     	;abs 0xe10

00000dde <.Loc.269.1>:
 dde:	0c 4e       	mov	r14,	r12	;
 de0:	7c f0 80 00 	and.b	#128,	r12	;#0x0080

00000de4 <.Loc.269.1>:
 de4:	0c 93       	cmp	#0,	r12	;r3 As==00
 de6:	03 24       	jz	$+8      	;abs 0xdee

00000de8 <.Loc.270.1>:
 de8:	3e 50 40 00 	add	#64,	r14	;#0x0040

00000dec <.L28>:
 dec:	0f 63       	adc	r15		;

00000dee <.L7>:
 dee:	5a 43       	mov.b	#1,	r10	;r3 As==01

00000df0 <.LVL26>:
 df0:	3c 40 ff 3f 	mov	#16383,	r12	;#0x3fff
 df4:	0c 9f       	cmp	r15,	r12	;
 df6:	01 28       	jnc	$+4      	;abs 0xdfa
 df8:	4a 43       	clr.b	r10		;

00000dfa <.L9>:
 dfa:	0c 4e       	mov	r14,	r12	;
 dfc:	0d 4f       	mov	r15,	r13	;

00000dfe <.L31>:
 dfe:	7e 40 07 00 	mov.b	#7,	r14	;
 e02:	b0 12 ba 0c 	call	#3258		;#0x0cba
 e06:	08 4c       	mov	r12,	r8	;
 e08:	09 4d       	mov	r13,	r9	;

00000e0a <.LVL30>:
 e0a:	9c 3f       	jmp	$-198    	;abs 0xd44

00000e0c <.L20>:
 e0c:	4e 43       	clr.b	r14		;
 e0e:	4f 43       	clr.b	r15		;

00000e10 <.L6>:
 e10:	3e 50 3f 00 	add	#63,	r14	;#0x003f

00000e14 <.LVL33>:
 e14:	eb 3f       	jmp	$-40     	;abs 0xdec

00000e16 <.L5>:
 e16:	7d 40 7f 00 	mov.b	#127,	r13	;#0x007f
 e1a:	0d 9a       	cmp	r10,	r13	;
 e1c:	22 38       	jl	$+70     	;abs 0xe62

00000e1e <.LVL35>:
 e1e:	0c 48       	mov	r8,	r12	;

00000e20 <.LVL36>:
 e20:	7c f0 7f 00 	and.b	#127,	r12	;#0x007f

00000e24 <.Loc.297.1>:
 e24:	3c 90 40 00 	cmp	#64,	r12	;#0x0040
 e28:	0f 20       	jnz	$+32     	;abs 0xe48

00000e2a <.Loc.299.1>:
 e2a:	0c 48       	mov	r8,	r12	;
 e2c:	7c f0 80 00 	and.b	#128,	r12	;#0x0080

00000e30 <.Loc.299.1>:
 e30:	0c 93       	cmp	#0,	r12	;r3 As==00
 e32:	03 24       	jz	$+8      	;abs 0xe3a

00000e34 <.Loc.300.1>:
 e34:	38 50 40 00 	add	#64,	r8	;#0x0040

00000e38 <.L29>:
 e38:	09 63       	adc	r9		;

00000e3a <.L12>:
 e3a:	09 93       	cmp	#0,	r9	;r3 As==00
 e3c:	08 38       	jl	$+18     	;abs 0xe4e

00000e3e <.Loc.293.1>:
 e3e:	3a 50 7f 00 	add	#127,	r10	;#0x007f

00000e42 <.L16>:
 e42:	0c 48       	mov	r8,	r12	;
 e44:	0d 49       	mov	r9,	r13	;
 e46:	db 3f       	jmp	$-72     	;abs 0xdfe

00000e48 <.L11>:
 e48:	38 50 3f 00 	add	#63,	r8	;#0x003f

00000e4c <.LVL41>:
 e4c:	f5 3f       	jmp	$-20     	;abs 0xe38

00000e4e <.L14>:
 e4e:	12 c3       	clrc			
 e50:	09 10       	rrc	r9		;
 e52:	08 10       	rrc	r8		;

00000e54 <.Loc.310.1>:
 e54:	3a 50 80 00 	add	#128,	r10	;#0x0080

00000e58 <.LVL44>:
 e58:	f4 3f       	jmp	$-22     	;abs 0xe42

00000e5a <.L18>:
 e5a:	4a 43       	clr.b	r10		;

00000e5c <.L30>:
 e5c:	48 43       	clr.b	r8		;

00000e5e <.LVL47>:
 e5e:	49 43       	clr.b	r9		;
 e60:	71 3f       	jmp	$-284    	;abs 0xd44

00000e62 <.L21>:
 e62:	7a 40 ff 00 	mov.b	#255,	r10	;#0x00ff
 e66:	fa 3f       	jmp	$-10     	;abs 0xe5c

00000e68 <__unpack_f>:
 e68:	0a 12       	push	r10		;

00000e6a <.LCFI0>:
 e6a:	09 12       	push	r9		;

00000e6c <.LCFI1>:
 e6c:	08 12       	push	r8		;

00000e6e <.LCFI2>:
 e6e:	07 12       	push	r7		;

00000e70 <.LCFI3>:
 e70:	06 12       	push	r6		;

00000e72 <.LCFI4>:
 e72:	05 12       	push	r5		;

00000e74 <.LCFI5>:
 e74:	04 12       	push	r4		;

00000e76 <.LCFI6>:
 e76:	09 4c       	mov	r12,	r9	;

00000e78 <L0^A>:
 e78:	0a 4d       	mov	r13,	r10	;

00000e7a <.Loc.434.1>:
 e7a:	28 4c       	mov	@r12,	r8	;
 e7c:	55 4c 02 00 	mov.b	2(r12),	r5	;
 e80:	07 45       	mov	r5,	r7	;
 e82:	77 f0 7f 00 	and.b	#127,	r7	;#0x007f

00000e86 <.Loc.454.1>:
 e86:	06 48       	mov	r8,	r6	;

00000e88 <.LVL1>:
 e88:	1c 4c 02 00 	mov	2(r12),	r12	;

00000e8c <.LVL2>:
 e8c:	7d 40 07 00 	mov.b	#7,	r13	;

00000e90 <.LVL3>:
 e90:	b0 12 ac 0c 	call	#3244		;#0x0cac

00000e94 <.Loc.455.1>:
 e94:	44 4c       	mov.b	r12,	r4	;

00000e96 <.LVL5>:
 e96:	5c 49 03 00 	mov.b	3(r9),	r12	;
 e9a:	7d 40 07 00 	mov.b	#7,	r13	;
 e9e:	b0 12 ac 0c 	call	#3244		;#0x0cac

00000ea2 <.LVL6>:
 ea2:	3c f0 ff 00 	and	#255,	r12	;#0x00ff
 ea6:	8a 4c 02 00 	mov	r12,	2(r10)	;

00000eaa <.Loc.509.1>:
 eaa:	04 93       	cmp	#0,	r4	;r3 As==00
 eac:	25 20       	jnz	$+76     	;abs 0xef8

00000eae <.Loc.512.1>:
 eae:	0c 48       	mov	r8,	r12	;
 eb0:	0c d7       	bis	r7,	r12	;
 eb2:	0c 93       	cmp	#0,	r12	;r3 As==00
 eb4:	03 20       	jnz	$+8      	;abs 0xebc

00000eb6 <.Loc.519.1>:
 eb6:	aa 43 00 00 	mov	#2,	0(r10)	;r3 As==10

00000eba <.L1>:
 eba:	dc 3e       	jmp	$-582    	;abs 0xc74

00000ebc <.L3>:
 ebc:	0c 48       	mov	r8,	r12	;
 ebe:	0d 47       	mov	r7,	r13	;
 ec0:	7e 40 07 00 	mov.b	#7,	r14	;
 ec4:	b0 12 94 0c 	call	#3220		;#0x0c94

00000ec8 <.LVL9>:
 ec8:	ba 40 03 00 	mov	#3,	0(r10)	;
 ecc:	00 00 

00000ece <.Loc.529.1>:
 ece:	3e 40 81 ff 	mov	#-127,	r14	;#0xff81

00000ed2 <.L13>:
 ed2:	08 4c       	mov	r12,	r8	;
 ed4:	09 4d       	mov	r13,	r9	;
 ed6:	08 5c       	add	r12,	r8	;
 ed8:	09 6d       	addc	r13,	r9	;
 eda:	0c 48       	mov	r8,	r12	;

00000edc <.LVL11>:
 edc:	0d 49       	mov	r9,	r13	;

00000ede <.LVL12>:
 ede:	0f 4e       	mov	r14,	r15	;

00000ee0 <.Loc.531.1>:
 ee0:	3e 53       	add	#-1,	r14	;r3 As==11
 ee2:	39 40 ff 3f 	mov	#16383,	r9	;#0x3fff
 ee6:	09 9d       	cmp	r13,	r9	;
 ee8:	f4 2f       	jc	$-22     	;abs 0xed2
 eea:	8a 4f 04 00 	mov	r15,	4(r10)	;

00000eee <.Loc.537.1>:
 eee:	8a 48 06 00 	mov	r8,	6(r10)	;

00000ef2 <.L14>:
 ef2:	8a 4d 08 00 	mov	r13,	8(r10)	;

00000ef6 <.Loc.576.1>:
 ef6:	e1 3f       	jmp	$-60     	;abs 0xeba

00000ef8 <.L2>:
 ef8:	34 90 ff 00 	cmp	#255,	r4	;#0x00ff
 efc:	1b 20       	jnz	$+56     	;abs 0xf34

00000efe <.Loc.543.1>:
 efe:	08 d7       	bis	r7,	r8	;
 f00:	08 93       	cmp	#0,	r8	;r3 As==00
 f02:	03 20       	jnz	$+8      	;abs 0xf0a

00000f04 <.Loc.546.1>:
 f04:	aa 42 00 00 	mov	#4,	0(r10)	;r2 As==10
 f08:	d8 3f       	jmp	$-78     	;abs 0xeba

00000f0a <.L8>:
 f0a:	35 b0 40 00 	bit	#64,	r5	;#0x0040
 f0e:	0f 24       	jz	$+32     	;abs 0xf2e

00000f10 <.Loc.557.1>:
 f10:	9a 43 00 00 	mov	#1,	0(r10)	;r3 As==01

00000f14 <.L11>:
 f14:	0c 46       	mov	r6,	r12	;
 f16:	0d 47       	mov	r7,	r13	;
 f18:	7e 40 07 00 	mov.b	#7,	r14	;
 f1c:	b0 12 94 0c 	call	#3220		;#0x0c94
 f20:	3c f0 80 ff 	and	#-128,	r12	;#0xff80
 f24:	8a 4c 06 00 	mov	r12,	6(r10)	;
 f28:	3d f0 ff df 	and	#-8193,	r13	;#0xdfff
 f2c:	e2 3f       	jmp	$-58     	;abs 0xef2

00000f2e <.L9>:
 f2e:	8a 43 00 00 	mov	#0,	0(r10)	;r3 As==00
 f32:	f0 3f       	jmp	$-30     	;abs 0xf14

00000f34 <.L7>:
 f34:	34 50 81 ff 	add	#-127,	r4	;#0xff81

00000f38 <.LVL18>:
 f38:	8a 44 04 00 	mov	r4,	4(r10)	;

00000f3c <.Loc.573.1>:
 f3c:	ba 40 03 00 	mov	#3,	0(r10)	;
 f40:	00 00 

00000f42 <.Loc.574.1>:
 f42:	0c 48       	mov	r8,	r12	;
 f44:	0d 47       	mov	r7,	r13	;
 f46:	7e 40 07 00 	mov.b	#7,	r14	;
 f4a:	b0 12 94 0c 	call	#3220		;#0x0c94

00000f4e <.Loc.574.1>:
 f4e:	8a 4c 06 00 	mov	r12,	6(r10)	;
 f52:	3d d0 00 40 	bis	#16384,	r13	;#0x4000
 f56:	cd 3f       	jmp	$-100    	;abs 0xef2

00000f58 <__mspabi_mpyl>:
 f58:	0a 12       	push	r10		;

00000f5a <.LCFI10>:
 f5a:	09 12       	push	r9		;

00000f5c <.LCFI11>:
 f5c:	08 12       	push	r8		;

00000f5e <.LCFI12>:
 f5e:	07 12       	push	r7		;

00000f60 <.LCFI13>:
 f60:	06 12       	push	r6		;

00000f62 <.LCFI14>:
 f62:	0a 4c       	mov	r12,	r10	;

00000f64 <L0^A>:
 f64:	0b 4d       	mov	r13,	r11	;

00000f66 <.LVL27>:
 f66:	78 40 21 00 	mov.b	#33,	r8	;#0x0021

00000f6a <.Loc.30.2>:
 f6a:	4c 43       	clr.b	r12		;

00000f6c <.LVL28>:
 f6c:	4d 43       	clr.b	r13		;

00000f6e <.L6>:
 f6e:	09 4e       	mov	r14,	r9	;
 f70:	09 df       	bis	r15,	r9	;
 f72:	09 93       	cmp	#0,	r9	;r3 As==00
 f74:	05 24       	jz	$+12     	;abs 0xf80
 f76:	49 48       	mov.b	r8,	r9	;
 f78:	79 53       	add.b	#-1,	r9	;r3 As==11
 f7a:	48 49       	mov.b	r9,	r8	;

00000f7c <.LVL30>:
 f7c:	49 93       	cmp.b	#0,	r9	;r3 As==00
 f7e:	01 20       	jnz	$+4      	;abs 0xf82

00000f80 <.L5>:
 f80:	7b 3e       	jmp	$-776    	;abs 0xc78

00000f82 <.L10>:
 f82:	09 4e       	mov	r14,	r9	;
 f84:	59 f3       	and.b	#1,	r9	;r3 As==01

00000f86 <.Loc.36.2>:
 f86:	09 93       	cmp	#0,	r9	;r3 As==00
 f88:	02 24       	jz	$+6      	;abs 0xf8e

00000f8a <.Loc.37.2>:
 f8a:	0c 5a       	add	r10,	r12	;

00000f8c <.LVL31>:
 f8c:	0d 6b       	addc	r11,	r13	;

00000f8e <.L7>:
 f8e:	06 4a       	mov	r10,	r6	;
 f90:	07 4b       	mov	r11,	r7	;
 f92:	06 5a       	add	r10,	r6	;
 f94:	07 6b       	addc	r11,	r7	;
 f96:	0a 46       	mov	r6,	r10	;

00000f98 <.LVL33>:
 f98:	0b 47       	mov	r7,	r11	;

00000f9a <.LVL34>:
 f9a:	12 c3       	clrc			
 f9c:	0f 10       	rrc	r15		;
 f9e:	0e 10       	rrc	r14		;

00000fa0 <.LVL35>:
 fa0:	e6 3f       	jmp	$-50     	;abs 0xf6e

Disassembly of section .rodata:

00000fa2 <__thenan_sf>:
     fa2:	00 00       	beq			
     fa4:	00 00       	beq			
     fa6:	00 00       	beq			
     fa8:	00 00       	beq			
     faa:	00 00       	beq			

00000fac <__clz_tab>:
     fac:	00 01       	bra	@r1		;
     fae:	02 02       	mova	@r2,	r2	;
     fb0:	03 03       	mova	@r3,	r3	;
     fb2:	03 03       	mova	@r3,	r3	;
     fb4:	04 04       	mova	@r4,	r4	;
     fb6:	04 04       	mova	@r4,	r4	;
     fb8:	04 04       	mova	@r4,	r4	;
     fba:	04 04       	mova	@r4,	r4	;
     fbc:	05 05       	mova	@r5,	r5	;
     fbe:	05 05       	mova	@r5,	r5	;
     fc0:	05 05       	mova	@r5,	r5	;
     fc2:	05 05       	mova	@r5,	r5	;
     fc4:	05 05       	mova	@r5,	r5	;
     fc6:	05 05       	mova	@r5,	r5	;
     fc8:	05 05       	mova	@r5,	r5	;
     fca:	05 05       	mova	@r5,	r5	;
     fcc:	06 06       	mova	@r6,	r6	;
     fce:	06 06       	mova	@r6,	r6	;
     fd0:	06 06       	mova	@r6,	r6	;
     fd2:	06 06       	mova	@r6,	r6	;
     fd4:	06 06       	mova	@r6,	r6	;
     fd6:	06 06       	mova	@r6,	r6	;
     fd8:	06 06       	mova	@r6,	r6	;
     fda:	06 06       	mova	@r6,	r6	;
     fdc:	06 06       	mova	@r6,	r6	;
     fde:	06 06       	mova	@r6,	r6	;
     fe0:	06 06       	mova	@r6,	r6	;
     fe2:	06 06       	mova	@r6,	r6	;
     fe4:	06 06       	mova	@r6,	r6	;
     fe6:	06 06       	mova	@r6,	r6	;
     fe8:	06 06       	mova	@r6,	r6	;
     fea:	06 06       	mova	@r6,	r6	;
     fec:	07 07       	mova	@r7,	r7	;
     fee:	07 07       	mova	@r7,	r7	;
     ff0:	07 07       	mova	@r7,	r7	;
     ff2:	07 07       	mova	@r7,	r7	;
     ff4:	07 07       	mova	@r7,	r7	;
     ff6:	07 07       	mova	@r7,	r7	;
     ff8:	07 07       	mova	@r7,	r7	;
     ffa:	07 07       	mova	@r7,	r7	;
     ffc:	07 07       	mova	@r7,	r7	;
     ffe:	07 07       	mova	@r7,	r7	;
    1000:	07 07       	mova	@r7,	r7	;
    1002:	07 07       	mova	@r7,	r7	;
    1004:	07 07       	mova	@r7,	r7	;
    1006:	07 07       	mova	@r7,	r7	;
    1008:	07 07       	mova	@r7,	r7	;
    100a:	07 07       	mova	@r7,	r7	;
    100c:	07 07       	mova	@r7,	r7	;
    100e:	07 07       	mova	@r7,	r7	;
    1010:	07 07       	mova	@r7,	r7	;
    1012:	07 07       	mova	@r7,	r7	;
    1014:	07 07       	mova	@r7,	r7	;
    1016:	07 07       	mova	@r7,	r7	;
    1018:	07 07       	mova	@r7,	r7	;
    101a:	07 07       	mova	@r7,	r7	;
    101c:	07 07       	mova	@r7,	r7	;
    101e:	07 07       	mova	@r7,	r7	;
    1020:	07 07       	mova	@r7,	r7	;
    1022:	07 07       	mova	@r7,	r7	;
    1024:	07 07       	mova	@r7,	r7	;
    1026:	07 07       	mova	@r7,	r7	;
    1028:	07 07       	mova	@r7,	r7	;
    102a:	07 07       	mova	@r7,	r7	;
    102c:	08 08       	mova	@r8,	r8	;
    102e:	08 08       	mova	@r8,	r8	;
    1030:	08 08       	mova	@r8,	r8	;
    1032:	08 08       	mova	@r8,	r8	;
    1034:	08 08       	mova	@r8,	r8	;
    1036:	08 08       	mova	@r8,	r8	;
    1038:	08 08       	mova	@r8,	r8	;
    103a:	08 08       	mova	@r8,	r8	;
    103c:	08 08       	mova	@r8,	r8	;
    103e:	08 08       	mova	@r8,	r8	;
    1040:	08 08       	mova	@r8,	r8	;
    1042:	08 08       	mova	@r8,	r8	;
    1044:	08 08       	mova	@r8,	r8	;
    1046:	08 08       	mova	@r8,	r8	;
    1048:	08 08       	mova	@r8,	r8	;
    104a:	08 08       	mova	@r8,	r8	;
    104c:	08 08       	mova	@r8,	r8	;
    104e:	08 08       	mova	@r8,	r8	;
    1050:	08 08       	mova	@r8,	r8	;
    1052:	08 08       	mova	@r8,	r8	;
    1054:	08 08       	mova	@r8,	r8	;
    1056:	08 08       	mova	@r8,	r8	;
    1058:	08 08       	mova	@r8,	r8	;
    105a:	08 08       	mova	@r8,	r8	;
    105c:	08 08       	mova	@r8,	r8	;
    105e:	08 08       	mova	@r8,	r8	;
    1060:	08 08       	mova	@r8,	r8	;
    1062:	08 08       	mova	@r8,	r8	;
    1064:	08 08       	mova	@r8,	r8	;
    1066:	08 08       	mova	@r8,	r8	;
    1068:	08 08       	mova	@r8,	r8	;
    106a:	08 08       	mova	@r8,	r8	;
    106c:	08 08       	mova	@r8,	r8	;
    106e:	08 08       	mova	@r8,	r8	;
    1070:	08 08       	mova	@r8,	r8	;
    1072:	08 08       	mova	@r8,	r8	;
    1074:	08 08       	mova	@r8,	r8	;
    1076:	08 08       	mova	@r8,	r8	;
    1078:	08 08       	mova	@r8,	r8	;
    107a:	08 08       	mova	@r8,	r8	;
    107c:	08 08       	mova	@r8,	r8	;
    107e:	08 08       	mova	@r8,	r8	;
    1080:	08 08       	mova	@r8,	r8	;
    1082:	08 08       	mova	@r8,	r8	;
    1084:	08 08       	mova	@r8,	r8	;
    1086:	08 08       	mova	@r8,	r8	;
    1088:	08 08       	mova	@r8,	r8	;
    108a:	08 08       	mova	@r8,	r8	;
    108c:	08 08       	mova	@r8,	r8	;
    108e:	08 08       	mova	@r8,	r8	;
    1090:	08 08       	mova	@r8,	r8	;
    1092:	08 08       	mova	@r8,	r8	;
    1094:	08 08       	mova	@r8,	r8	;
    1096:	08 08       	mova	@r8,	r8	;
    1098:	08 08       	mova	@r8,	r8	;
    109a:	08 08       	mova	@r8,	r8	;
    109c:	08 08       	mova	@r8,	r8	;
    109e:	08 08       	mova	@r8,	r8	;
    10a0:	08 08       	mova	@r8,	r8	;
    10a2:	08 08       	mova	@r8,	r8	;
    10a4:	08 08       	mova	@r8,	r8	;
    10a6:	08 08       	mova	@r8,	r8	;
    10a8:	08 08       	mova	@r8,	r8	;
    10aa:	08 08       	mova	@r8,	r8	;

Disassembly of section .data:

0000c008 <dac_val>:
    c008:	fa 77   	subc.b	@r7+,	30714(r10); 0x77fa

0000c00a <vctcxo_trim_dac_value>:
    c00a:	
Disassembly of section .bss:

0000c00c <vctcxo_tamer_pkt>:
    c00c:	00 00       	beq			
    c00e:	00 00       	beq			
    c010:	00 00       	beq			
    c012:	00 00       	beq			
    c014:	00 00       	beq			
    c016:	00 00       	beq			
    c018:	00 00       	beq			
    c01a:	00 00       	beq			
    c01c:	00 00       	beq			
    c01e:	00 00       	beq			

0000c020 <vctcxo_tamer_ctrl_reg>:
    c020:	00 00       	beq			

0000c022 <neo430_exirq_vectors>:
    c022:	00 00       	beq			
    c024:	00 00       	beq			
    c026:	00 00       	beq			
    c028:	00 00       	beq			
    c02a:	00 00       	beq			
    c02c:	00 00       	beq			
    c02e:	00 00       	beq			
    c030:	00 00       	beq			

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

kernel/kernel:     formato del fichero elf64-littleriscv


Desensamblado de la sección .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	8d013103          	ld	sp,-1840(sp) # 800088d0 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	076000ef          	jal	ra,8000008c <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007859b          	sext.w	a1,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873703          	ld	a4,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	9732                	add	a4,a4,a2
    80000046:	e398                	sd	a4,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00259693          	slli	a3,a1,0x2
    8000004c:	96ae                	add	a3,a3,a1
    8000004e:	068e                	slli	a3,a3,0x3
    80000050:	00009717          	auipc	a4,0x9
    80000054:	8e070713          	addi	a4,a4,-1824 # 80008930 <timer_scratch>
    80000058:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005a:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005c:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005e:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000062:	00006797          	auipc	a5,0x6
    80000066:	bae78793          	addi	a5,a5,-1106 # 80005c10 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000076:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000082:	30479073          	csrw	mie,a5
}
    80000086:	6422                	ld	s0,8(sp)
    80000088:	0141                	addi	sp,sp,16
    8000008a:	8082                	ret

000000008000008c <start>:
{
    8000008c:	1141                	addi	sp,sp,-16
    8000008e:	e406                	sd	ra,8(sp)
    80000090:	e022                	sd	s0,0(sp)
    80000092:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000094:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000098:	7779                	lui	a4,0xffffe
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdc85f>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	dcc78793          	addi	a5,a5,-564 # 80000e78 <main>
    800000b4:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b8:	4781                	li	a5,0
    800000ba:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000be:	67c1                	lui	a5,0x10
    800000c0:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c2:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c6:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000ca:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000ce:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d2:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d6:	57fd                	li	a5,-1
    800000d8:	83a9                	srli	a5,a5,0xa
    800000da:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000de:	47bd                	li	a5,15
    800000e0:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e4:	00000097          	auipc	ra,0x0
    800000e8:	f38080e7          	jalr	-200(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ec:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f4:	30200073          	mret
}
    800000f8:	60a2                	ld	ra,8(sp)
    800000fa:	6402                	ld	s0,0(sp)
    800000fc:	0141                	addi	sp,sp,16
    800000fe:	8082                	ret

0000000080000100 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000100:	715d                	addi	sp,sp,-80
    80000102:	e486                	sd	ra,72(sp)
    80000104:	e0a2                	sd	s0,64(sp)
    80000106:	fc26                	sd	s1,56(sp)
    80000108:	f84a                	sd	s2,48(sp)
    8000010a:	f44e                	sd	s3,40(sp)
    8000010c:	f052                	sd	s4,32(sp)
    8000010e:	ec56                	sd	s5,24(sp)
    80000110:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000112:	04c05763          	blez	a2,80000160 <consolewrite+0x60>
    80000116:	8a2a                	mv	s4,a0
    80000118:	84ae                	mv	s1,a1
    8000011a:	89b2                	mv	s3,a2
    8000011c:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000011e:	5afd                	li	s5,-1
    80000120:	4685                	li	a3,1
    80000122:	8626                	mv	a2,s1
    80000124:	85d2                	mv	a1,s4
    80000126:	fbf40513          	addi	a0,s0,-65
    8000012a:	00002097          	auipc	ra,0x2
    8000012e:	392080e7          	jalr	914(ra) # 800024bc <either_copyin>
    80000132:	01550d63          	beq	a0,s5,8000014c <consolewrite+0x4c>
      break;
    uartputc(c);
    80000136:	fbf44503          	lbu	a0,-65(s0)
    8000013a:	00000097          	auipc	ra,0x0
    8000013e:	784080e7          	jalr	1924(ra) # 800008be <uartputc>
  for(i = 0; i < n; i++){
    80000142:	2905                	addiw	s2,s2,1
    80000144:	0485                	addi	s1,s1,1
    80000146:	fd299de3          	bne	s3,s2,80000120 <consolewrite+0x20>
    8000014a:	894e                	mv	s2,s3
  }

  return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	addi	sp,sp,80
    8000015e:	8082                	ret
  for(i = 0; i < n; i++){
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4c>

0000000080000164 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	7159                	addi	sp,sp,-112
    80000166:	f486                	sd	ra,104(sp)
    80000168:	f0a2                	sd	s0,96(sp)
    8000016a:	eca6                	sd	s1,88(sp)
    8000016c:	e8ca                	sd	s2,80(sp)
    8000016e:	e4ce                	sd	s3,72(sp)
    80000170:	e0d2                	sd	s4,64(sp)
    80000172:	fc56                	sd	s5,56(sp)
    80000174:	f85a                	sd	s6,48(sp)
    80000176:	f45e                	sd	s7,40(sp)
    80000178:	f062                	sd	s8,32(sp)
    8000017a:	ec66                	sd	s9,24(sp)
    8000017c:	e86a                	sd	s10,16(sp)
    8000017e:	1880                	addi	s0,sp,112
    80000180:	8aaa                	mv	s5,a0
    80000182:	8a2e                	mv	s4,a1
    80000184:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000186:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000018a:	00011517          	auipc	a0,0x11
    8000018e:	8e650513          	addi	a0,a0,-1818 # 80010a70 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	a44080e7          	jalr	-1468(ra) # 80000bd6 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019a:	00011497          	auipc	s1,0x11
    8000019e:	8d648493          	addi	s1,s1,-1834 # 80010a70 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a2:	00011917          	auipc	s2,0x11
    800001a6:	96690913          	addi	s2,s2,-1690 # 80010b08 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

    if(c == C('D')){  // end-of-file
    800001aa:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001ac:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001ae:	4ca9                	li	s9,10
  while(n > 0){
    800001b0:	07305b63          	blez	s3,80000226 <consoleread+0xc2>
    while(cons.r == cons.w){
    800001b4:	0984a783          	lw	a5,152(s1)
    800001b8:	09c4a703          	lw	a4,156(s1)
    800001bc:	02f71763          	bne	a4,a5,800001ea <consoleread+0x86>
      if(killed(myproc())){
    800001c0:	00001097          	auipc	ra,0x1
    800001c4:	7ec080e7          	jalr	2028(ra) # 800019ac <myproc>
    800001c8:	00002097          	auipc	ra,0x2
    800001cc:	13e080e7          	jalr	318(ra) # 80002306 <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
      sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	e88080e7          	jalr	-376(ra) # 8000205e <sleep>
    while(cons.r == cons.w){
    800001de:	0984a783          	lw	a5,152(s1)
    800001e2:	09c4a703          	lw	a4,156(s1)
    800001e6:	fcf70de3          	beq	a4,a5,800001c0 <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001ea:	0017871b          	addiw	a4,a5,1
    800001ee:	08e4ac23          	sw	a4,152(s1)
    800001f2:	07f7f713          	andi	a4,a5,127
    800001f6:	9726                	add	a4,a4,s1
    800001f8:	01874703          	lbu	a4,24(a4)
    800001fc:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    80000200:	077d0563          	beq	s10,s7,8000026a <consoleread+0x106>
    cbuf = c;
    80000204:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000208:	4685                	li	a3,1
    8000020a:	f9f40613          	addi	a2,s0,-97
    8000020e:	85d2                	mv	a1,s4
    80000210:	8556                	mv	a0,s5
    80000212:	00002097          	auipc	ra,0x2
    80000216:	254080e7          	jalr	596(ra) # 80002466 <either_copyout>
    8000021a:	01850663          	beq	a0,s8,80000226 <consoleread+0xc2>
    dst++;
    8000021e:	0a05                	addi	s4,s4,1
    --n;
    80000220:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    80000222:	f99d17e3          	bne	s10,s9,800001b0 <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000226:	00011517          	auipc	a0,0x11
    8000022a:	84a50513          	addi	a0,a0,-1974 # 80010a70 <cons>
    8000022e:	00001097          	auipc	ra,0x1
    80000232:	a5c080e7          	jalr	-1444(ra) # 80000c8a <release>

  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	a811                	j	8000024e <consoleread+0xea>
        release(&cons.lock);
    8000023c:	00011517          	auipc	a0,0x11
    80000240:	83450513          	addi	a0,a0,-1996 # 80010a70 <cons>
    80000244:	00001097          	auipc	ra,0x1
    80000248:	a46080e7          	jalr	-1466(ra) # 80000c8a <release>
        return -1;
    8000024c:	557d                	li	a0,-1
}
    8000024e:	70a6                	ld	ra,104(sp)
    80000250:	7406                	ld	s0,96(sp)
    80000252:	64e6                	ld	s1,88(sp)
    80000254:	6946                	ld	s2,80(sp)
    80000256:	69a6                	ld	s3,72(sp)
    80000258:	6a06                	ld	s4,64(sp)
    8000025a:	7ae2                	ld	s5,56(sp)
    8000025c:	7b42                	ld	s6,48(sp)
    8000025e:	7ba2                	ld	s7,40(sp)
    80000260:	7c02                	ld	s8,32(sp)
    80000262:	6ce2                	ld	s9,24(sp)
    80000264:	6d42                	ld	s10,16(sp)
    80000266:	6165                	addi	sp,sp,112
    80000268:	8082                	ret
      if(n < target){
    8000026a:	0009871b          	sext.w	a4,s3
    8000026e:	fb677ce3          	bgeu	a4,s6,80000226 <consoleread+0xc2>
        cons.r--;
    80000272:	00011717          	auipc	a4,0x11
    80000276:	88f72b23          	sw	a5,-1898(a4) # 80010b08 <cons+0x98>
    8000027a:	b775                	j	80000226 <consoleread+0xc2>

000000008000027c <consputc>:
{
    8000027c:	1141                	addi	sp,sp,-16
    8000027e:	e406                	sd	ra,8(sp)
    80000280:	e022                	sd	s0,0(sp)
    80000282:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000284:	10000793          	li	a5,256
    80000288:	00f50a63          	beq	a0,a5,8000029c <consputc+0x20>
    uartputc_sync(c);
    8000028c:	00000097          	auipc	ra,0x0
    80000290:	560080e7          	jalr	1376(ra) # 800007ec <uartputc_sync>
}
    80000294:	60a2                	ld	ra,8(sp)
    80000296:	6402                	ld	s0,0(sp)
    80000298:	0141                	addi	sp,sp,16
    8000029a:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000029c:	4521                	li	a0,8
    8000029e:	00000097          	auipc	ra,0x0
    800002a2:	54e080e7          	jalr	1358(ra) # 800007ec <uartputc_sync>
    800002a6:	02000513          	li	a0,32
    800002aa:	00000097          	auipc	ra,0x0
    800002ae:	542080e7          	jalr	1346(ra) # 800007ec <uartputc_sync>
    800002b2:	4521                	li	a0,8
    800002b4:	00000097          	auipc	ra,0x0
    800002b8:	538080e7          	jalr	1336(ra) # 800007ec <uartputc_sync>
    800002bc:	bfe1                	j	80000294 <consputc+0x18>

00000000800002be <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002be:	1101                	addi	sp,sp,-32
    800002c0:	ec06                	sd	ra,24(sp)
    800002c2:	e822                	sd	s0,16(sp)
    800002c4:	e426                	sd	s1,8(sp)
    800002c6:	e04a                	sd	s2,0(sp)
    800002c8:	1000                	addi	s0,sp,32
    800002ca:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002cc:	00010517          	auipc	a0,0x10
    800002d0:	7a450513          	addi	a0,a0,1956 # 80010a70 <cons>
    800002d4:	00001097          	auipc	ra,0x1
    800002d8:	902080e7          	jalr	-1790(ra) # 80000bd6 <acquire>

  switch(c){
    800002dc:	47d5                	li	a5,21
    800002de:	0af48663          	beq	s1,a5,8000038a <consoleintr+0xcc>
    800002e2:	0297ca63          	blt	a5,s1,80000316 <consoleintr+0x58>
    800002e6:	47a1                	li	a5,8
    800002e8:	0ef48763          	beq	s1,a5,800003d6 <consoleintr+0x118>
    800002ec:	47c1                	li	a5,16
    800002ee:	10f49a63          	bne	s1,a5,80000402 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002f2:	00002097          	auipc	ra,0x2
    800002f6:	220080e7          	jalr	544(ra) # 80002512 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002fa:	00010517          	auipc	a0,0x10
    800002fe:	77650513          	addi	a0,a0,1910 # 80010a70 <cons>
    80000302:	00001097          	auipc	ra,0x1
    80000306:	988080e7          	jalr	-1656(ra) # 80000c8a <release>
}
    8000030a:	60e2                	ld	ra,24(sp)
    8000030c:	6442                	ld	s0,16(sp)
    8000030e:	64a2                	ld	s1,8(sp)
    80000310:	6902                	ld	s2,0(sp)
    80000312:	6105                	addi	sp,sp,32
    80000314:	8082                	ret
  switch(c){
    80000316:	07f00793          	li	a5,127
    8000031a:	0af48e63          	beq	s1,a5,800003d6 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    8000031e:	00010717          	auipc	a4,0x10
    80000322:	75270713          	addi	a4,a4,1874 # 80010a70 <cons>
    80000326:	0a072783          	lw	a5,160(a4)
    8000032a:	09872703          	lw	a4,152(a4)
    8000032e:	9f99                	subw	a5,a5,a4
    80000330:	07f00713          	li	a4,127
    80000334:	fcf763e3          	bltu	a4,a5,800002fa <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000338:	47b5                	li	a5,13
    8000033a:	0cf48763          	beq	s1,a5,80000408 <consoleintr+0x14a>
      consputc(c);
    8000033e:	8526                	mv	a0,s1
    80000340:	00000097          	auipc	ra,0x0
    80000344:	f3c080e7          	jalr	-196(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000348:	00010797          	auipc	a5,0x10
    8000034c:	72878793          	addi	a5,a5,1832 # 80010a70 <cons>
    80000350:	0a07a683          	lw	a3,160(a5)
    80000354:	0016871b          	addiw	a4,a3,1
    80000358:	0007061b          	sext.w	a2,a4
    8000035c:	0ae7a023          	sw	a4,160(a5)
    80000360:	07f6f693          	andi	a3,a3,127
    80000364:	97b6                	add	a5,a5,a3
    80000366:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    8000036a:	47a9                	li	a5,10
    8000036c:	0cf48563          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000370:	4791                	li	a5,4
    80000372:	0cf48263          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000376:	00010797          	auipc	a5,0x10
    8000037a:	7927a783          	lw	a5,1938(a5) # 80010b08 <cons+0x98>
    8000037e:	9f1d                	subw	a4,a4,a5
    80000380:	08000793          	li	a5,128
    80000384:	f6f71be3          	bne	a4,a5,800002fa <consoleintr+0x3c>
    80000388:	a07d                	j	80000436 <consoleintr+0x178>
    while(cons.e != cons.w &&
    8000038a:	00010717          	auipc	a4,0x10
    8000038e:	6e670713          	addi	a4,a4,1766 # 80010a70 <cons>
    80000392:	0a072783          	lw	a5,160(a4)
    80000396:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000039a:	00010497          	auipc	s1,0x10
    8000039e:	6d648493          	addi	s1,s1,1750 # 80010a70 <cons>
    while(cons.e != cons.w &&
    800003a2:	4929                	li	s2,10
    800003a4:	f4f70be3          	beq	a4,a5,800002fa <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003a8:	37fd                	addiw	a5,a5,-1
    800003aa:	07f7f713          	andi	a4,a5,127
    800003ae:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003b0:	01874703          	lbu	a4,24(a4)
    800003b4:	f52703e3          	beq	a4,s2,800002fa <consoleintr+0x3c>
      cons.e--;
    800003b8:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003bc:	10000513          	li	a0,256
    800003c0:	00000097          	auipc	ra,0x0
    800003c4:	ebc080e7          	jalr	-324(ra) # 8000027c <consputc>
    while(cons.e != cons.w &&
    800003c8:	0a04a783          	lw	a5,160(s1)
    800003cc:	09c4a703          	lw	a4,156(s1)
    800003d0:	fcf71ce3          	bne	a4,a5,800003a8 <consoleintr+0xea>
    800003d4:	b71d                	j	800002fa <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003d6:	00010717          	auipc	a4,0x10
    800003da:	69a70713          	addi	a4,a4,1690 # 80010a70 <cons>
    800003de:	0a072783          	lw	a5,160(a4)
    800003e2:	09c72703          	lw	a4,156(a4)
    800003e6:	f0f70ae3          	beq	a4,a5,800002fa <consoleintr+0x3c>
      cons.e--;
    800003ea:	37fd                	addiw	a5,a5,-1
    800003ec:	00010717          	auipc	a4,0x10
    800003f0:	72f72223          	sw	a5,1828(a4) # 80010b10 <cons+0xa0>
      consputc(BACKSPACE);
    800003f4:	10000513          	li	a0,256
    800003f8:	00000097          	auipc	ra,0x0
    800003fc:	e84080e7          	jalr	-380(ra) # 8000027c <consputc>
    80000400:	bded                	j	800002fa <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000402:	ee048ce3          	beqz	s1,800002fa <consoleintr+0x3c>
    80000406:	bf21                	j	8000031e <consoleintr+0x60>
      consputc(c);
    80000408:	4529                	li	a0,10
    8000040a:	00000097          	auipc	ra,0x0
    8000040e:	e72080e7          	jalr	-398(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000412:	00010797          	auipc	a5,0x10
    80000416:	65e78793          	addi	a5,a5,1630 # 80010a70 <cons>
    8000041a:	0a07a703          	lw	a4,160(a5)
    8000041e:	0017069b          	addiw	a3,a4,1
    80000422:	0006861b          	sext.w	a2,a3
    80000426:	0ad7a023          	sw	a3,160(a5)
    8000042a:	07f77713          	andi	a4,a4,127
    8000042e:	97ba                	add	a5,a5,a4
    80000430:	4729                	li	a4,10
    80000432:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000436:	00010797          	auipc	a5,0x10
    8000043a:	6cc7ab23          	sw	a2,1750(a5) # 80010b0c <cons+0x9c>
        wakeup(&cons.r);
    8000043e:	00010517          	auipc	a0,0x10
    80000442:	6ca50513          	addi	a0,a0,1738 # 80010b08 <cons+0x98>
    80000446:	00002097          	auipc	ra,0x2
    8000044a:	c7c080e7          	jalr	-900(ra) # 800020c2 <wakeup>
    8000044e:	b575                	j	800002fa <consoleintr+0x3c>

0000000080000450 <consoleinit>:

void
consoleinit(void)
{
    80000450:	1141                	addi	sp,sp,-16
    80000452:	e406                	sd	ra,8(sp)
    80000454:	e022                	sd	s0,0(sp)
    80000456:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000458:	00008597          	auipc	a1,0x8
    8000045c:	bb858593          	addi	a1,a1,-1096 # 80008010 <etext+0x10>
    80000460:	00010517          	auipc	a0,0x10
    80000464:	61050513          	addi	a0,a0,1552 # 80010a70 <cons>
    80000468:	00000097          	auipc	ra,0x0
    8000046c:	6de080e7          	jalr	1758(ra) # 80000b46 <initlock>

  uartinit();
    80000470:	00000097          	auipc	ra,0x0
    80000474:	32c080e7          	jalr	812(ra) # 8000079c <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000478:	00021797          	auipc	a5,0x21
    8000047c:	99078793          	addi	a5,a5,-1648 # 80020e08 <devsw>
    80000480:	00000717          	auipc	a4,0x0
    80000484:	ce470713          	addi	a4,a4,-796 # 80000164 <consoleread>
    80000488:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000048a:	00000717          	auipc	a4,0x0
    8000048e:	c7670713          	addi	a4,a4,-906 # 80000100 <consolewrite>
    80000492:	ef98                	sd	a4,24(a5)
}
    80000494:	60a2                	ld	ra,8(sp)
    80000496:	6402                	ld	s0,0(sp)
    80000498:	0141                	addi	sp,sp,16
    8000049a:	8082                	ret

000000008000049c <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    8000049c:	7179                	addi	sp,sp,-48
    8000049e:	f406                	sd	ra,40(sp)
    800004a0:	f022                	sd	s0,32(sp)
    800004a2:	ec26                	sd	s1,24(sp)
    800004a4:	e84a                	sd	s2,16(sp)
    800004a6:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004a8:	c219                	beqz	a2,800004ae <printint+0x12>
    800004aa:	08054763          	bltz	a0,80000538 <printint+0x9c>
    x = -xx;
  else
    x = xx;
    800004ae:	2501                	sext.w	a0,a0
    800004b0:	4881                	li	a7,0
    800004b2:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004b6:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b8:	2581                	sext.w	a1,a1
    800004ba:	00008617          	auipc	a2,0x8
    800004be:	b8660613          	addi	a2,a2,-1146 # 80008040 <digits>
    800004c2:	883a                	mv	a6,a4
    800004c4:	2705                	addiw	a4,a4,1
    800004c6:	02b577bb          	remuw	a5,a0,a1
    800004ca:	1782                	slli	a5,a5,0x20
    800004cc:	9381                	srli	a5,a5,0x20
    800004ce:	97b2                	add	a5,a5,a2
    800004d0:	0007c783          	lbu	a5,0(a5)
    800004d4:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d8:	0005079b          	sext.w	a5,a0
    800004dc:	02b5553b          	divuw	a0,a0,a1
    800004e0:	0685                	addi	a3,a3,1
    800004e2:	feb7f0e3          	bgeu	a5,a1,800004c2 <printint+0x26>

  if(sign)
    800004e6:	00088c63          	beqz	a7,800004fe <printint+0x62>
    buf[i++] = '-';
    800004ea:	fe070793          	addi	a5,a4,-32
    800004ee:	00878733          	add	a4,a5,s0
    800004f2:	02d00793          	li	a5,45
    800004f6:	fef70823          	sb	a5,-16(a4)
    800004fa:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004fe:	02e05763          	blez	a4,8000052c <printint+0x90>
    80000502:	fd040793          	addi	a5,s0,-48
    80000506:	00e784b3          	add	s1,a5,a4
    8000050a:	fff78913          	addi	s2,a5,-1
    8000050e:	993a                	add	s2,s2,a4
    80000510:	377d                	addiw	a4,a4,-1
    80000512:	1702                	slli	a4,a4,0x20
    80000514:	9301                	srli	a4,a4,0x20
    80000516:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    8000051a:	fff4c503          	lbu	a0,-1(s1)
    8000051e:	00000097          	auipc	ra,0x0
    80000522:	d5e080e7          	jalr	-674(ra) # 8000027c <consputc>
  while(--i >= 0)
    80000526:	14fd                	addi	s1,s1,-1
    80000528:	ff2499e3          	bne	s1,s2,8000051a <printint+0x7e>
}
    8000052c:	70a2                	ld	ra,40(sp)
    8000052e:	7402                	ld	s0,32(sp)
    80000530:	64e2                	ld	s1,24(sp)
    80000532:	6942                	ld	s2,16(sp)
    80000534:	6145                	addi	sp,sp,48
    80000536:	8082                	ret
    x = -xx;
    80000538:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000053c:	4885                	li	a7,1
    x = -xx;
    8000053e:	bf95                	j	800004b2 <printint+0x16>

0000000080000540 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000540:	1101                	addi	sp,sp,-32
    80000542:	ec06                	sd	ra,24(sp)
    80000544:	e822                	sd	s0,16(sp)
    80000546:	e426                	sd	s1,8(sp)
    80000548:	1000                	addi	s0,sp,32
    8000054a:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000054c:	00010797          	auipc	a5,0x10
    80000550:	5e07a223          	sw	zero,1508(a5) # 80010b30 <pr+0x18>
  printf("panic: ");
    80000554:	00008517          	auipc	a0,0x8
    80000558:	ac450513          	addi	a0,a0,-1340 # 80008018 <etext+0x18>
    8000055c:	00000097          	auipc	ra,0x0
    80000560:	02e080e7          	jalr	46(ra) # 8000058a <printf>
  printf(s);
    80000564:	8526                	mv	a0,s1
    80000566:	00000097          	auipc	ra,0x0
    8000056a:	024080e7          	jalr	36(ra) # 8000058a <printf>
  printf("\n");
    8000056e:	00008517          	auipc	a0,0x8
    80000572:	fb250513          	addi	a0,a0,-78 # 80008520 <syscalls+0xd0>
    80000576:	00000097          	auipc	ra,0x0
    8000057a:	014080e7          	jalr	20(ra) # 8000058a <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057e:	4785                	li	a5,1
    80000580:	00008717          	auipc	a4,0x8
    80000584:	36f72823          	sw	a5,880(a4) # 800088f0 <panicked>
  for(;;)
    80000588:	a001                	j	80000588 <panic+0x48>

000000008000058a <printf>:
{
    8000058a:	7131                	addi	sp,sp,-192
    8000058c:	fc86                	sd	ra,120(sp)
    8000058e:	f8a2                	sd	s0,112(sp)
    80000590:	f4a6                	sd	s1,104(sp)
    80000592:	f0ca                	sd	s2,96(sp)
    80000594:	ecce                	sd	s3,88(sp)
    80000596:	e8d2                	sd	s4,80(sp)
    80000598:	e4d6                	sd	s5,72(sp)
    8000059a:	e0da                	sd	s6,64(sp)
    8000059c:	fc5e                	sd	s7,56(sp)
    8000059e:	f862                	sd	s8,48(sp)
    800005a0:	f466                	sd	s9,40(sp)
    800005a2:	f06a                	sd	s10,32(sp)
    800005a4:	ec6e                	sd	s11,24(sp)
    800005a6:	0100                	addi	s0,sp,128
    800005a8:	8a2a                	mv	s4,a0
    800005aa:	e40c                	sd	a1,8(s0)
    800005ac:	e810                	sd	a2,16(s0)
    800005ae:	ec14                	sd	a3,24(s0)
    800005b0:	f018                	sd	a4,32(s0)
    800005b2:	f41c                	sd	a5,40(s0)
    800005b4:	03043823          	sd	a6,48(s0)
    800005b8:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005bc:	00010d97          	auipc	s11,0x10
    800005c0:	574dad83          	lw	s11,1396(s11) # 80010b30 <pr+0x18>
  if(locking)
    800005c4:	020d9b63          	bnez	s11,800005fa <printf+0x70>
  if (fmt == 0)
    800005c8:	040a0263          	beqz	s4,8000060c <printf+0x82>
  va_start(ap, fmt);
    800005cc:	00840793          	addi	a5,s0,8
    800005d0:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d4:	000a4503          	lbu	a0,0(s4)
    800005d8:	14050f63          	beqz	a0,80000736 <printf+0x1ac>
    800005dc:	4981                	li	s3,0
    if(c != '%'){
    800005de:	02500a93          	li	s5,37
    switch(c){
    800005e2:	07000b93          	li	s7,112
  consputc('x');
    800005e6:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e8:	00008b17          	auipc	s6,0x8
    800005ec:	a58b0b13          	addi	s6,s6,-1448 # 80008040 <digits>
    switch(c){
    800005f0:	07300c93          	li	s9,115
    800005f4:	06400c13          	li	s8,100
    800005f8:	a82d                	j	80000632 <printf+0xa8>
    acquire(&pr.lock);
    800005fa:	00010517          	auipc	a0,0x10
    800005fe:	51e50513          	addi	a0,a0,1310 # 80010b18 <pr>
    80000602:	00000097          	auipc	ra,0x0
    80000606:	5d4080e7          	jalr	1492(ra) # 80000bd6 <acquire>
    8000060a:	bf7d                	j	800005c8 <printf+0x3e>
    panic("null fmt");
    8000060c:	00008517          	auipc	a0,0x8
    80000610:	a1c50513          	addi	a0,a0,-1508 # 80008028 <etext+0x28>
    80000614:	00000097          	auipc	ra,0x0
    80000618:	f2c080e7          	jalr	-212(ra) # 80000540 <panic>
      consputc(c);
    8000061c:	00000097          	auipc	ra,0x0
    80000620:	c60080e7          	jalr	-928(ra) # 8000027c <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000624:	2985                	addiw	s3,s3,1
    80000626:	013a07b3          	add	a5,s4,s3
    8000062a:	0007c503          	lbu	a0,0(a5)
    8000062e:	10050463          	beqz	a0,80000736 <printf+0x1ac>
    if(c != '%'){
    80000632:	ff5515e3          	bne	a0,s5,8000061c <printf+0x92>
    c = fmt[++i] & 0xff;
    80000636:	2985                	addiw	s3,s3,1
    80000638:	013a07b3          	add	a5,s4,s3
    8000063c:	0007c783          	lbu	a5,0(a5)
    80000640:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000644:	cbed                	beqz	a5,80000736 <printf+0x1ac>
    switch(c){
    80000646:	05778a63          	beq	a5,s7,8000069a <printf+0x110>
    8000064a:	02fbf663          	bgeu	s7,a5,80000676 <printf+0xec>
    8000064e:	09978863          	beq	a5,s9,800006de <printf+0x154>
    80000652:	07800713          	li	a4,120
    80000656:	0ce79563          	bne	a5,a4,80000720 <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    8000065a:	f8843783          	ld	a5,-120(s0)
    8000065e:	00878713          	addi	a4,a5,8
    80000662:	f8e43423          	sd	a4,-120(s0)
    80000666:	4605                	li	a2,1
    80000668:	85ea                	mv	a1,s10
    8000066a:	4388                	lw	a0,0(a5)
    8000066c:	00000097          	auipc	ra,0x0
    80000670:	e30080e7          	jalr	-464(ra) # 8000049c <printint>
      break;
    80000674:	bf45                	j	80000624 <printf+0x9a>
    switch(c){
    80000676:	09578f63          	beq	a5,s5,80000714 <printf+0x18a>
    8000067a:	0b879363          	bne	a5,s8,80000720 <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    8000067e:	f8843783          	ld	a5,-120(s0)
    80000682:	00878713          	addi	a4,a5,8
    80000686:	f8e43423          	sd	a4,-120(s0)
    8000068a:	4605                	li	a2,1
    8000068c:	45a9                	li	a1,10
    8000068e:	4388                	lw	a0,0(a5)
    80000690:	00000097          	auipc	ra,0x0
    80000694:	e0c080e7          	jalr	-500(ra) # 8000049c <printint>
      break;
    80000698:	b771                	j	80000624 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    8000069a:	f8843783          	ld	a5,-120(s0)
    8000069e:	00878713          	addi	a4,a5,8
    800006a2:	f8e43423          	sd	a4,-120(s0)
    800006a6:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006aa:	03000513          	li	a0,48
    800006ae:	00000097          	auipc	ra,0x0
    800006b2:	bce080e7          	jalr	-1074(ra) # 8000027c <consputc>
  consputc('x');
    800006b6:	07800513          	li	a0,120
    800006ba:	00000097          	auipc	ra,0x0
    800006be:	bc2080e7          	jalr	-1086(ra) # 8000027c <consputc>
    800006c2:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c4:	03c95793          	srli	a5,s2,0x3c
    800006c8:	97da                	add	a5,a5,s6
    800006ca:	0007c503          	lbu	a0,0(a5)
    800006ce:	00000097          	auipc	ra,0x0
    800006d2:	bae080e7          	jalr	-1106(ra) # 8000027c <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d6:	0912                	slli	s2,s2,0x4
    800006d8:	34fd                	addiw	s1,s1,-1
    800006da:	f4ed                	bnez	s1,800006c4 <printf+0x13a>
    800006dc:	b7a1                	j	80000624 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006de:	f8843783          	ld	a5,-120(s0)
    800006e2:	00878713          	addi	a4,a5,8
    800006e6:	f8e43423          	sd	a4,-120(s0)
    800006ea:	6384                	ld	s1,0(a5)
    800006ec:	cc89                	beqz	s1,80000706 <printf+0x17c>
      for(; *s; s++)
    800006ee:	0004c503          	lbu	a0,0(s1)
    800006f2:	d90d                	beqz	a0,80000624 <printf+0x9a>
        consputc(*s);
    800006f4:	00000097          	auipc	ra,0x0
    800006f8:	b88080e7          	jalr	-1144(ra) # 8000027c <consputc>
      for(; *s; s++)
    800006fc:	0485                	addi	s1,s1,1
    800006fe:	0004c503          	lbu	a0,0(s1)
    80000702:	f96d                	bnez	a0,800006f4 <printf+0x16a>
    80000704:	b705                	j	80000624 <printf+0x9a>
        s = "(null)";
    80000706:	00008497          	auipc	s1,0x8
    8000070a:	91a48493          	addi	s1,s1,-1766 # 80008020 <etext+0x20>
      for(; *s; s++)
    8000070e:	02800513          	li	a0,40
    80000712:	b7cd                	j	800006f4 <printf+0x16a>
      consputc('%');
    80000714:	8556                	mv	a0,s5
    80000716:	00000097          	auipc	ra,0x0
    8000071a:	b66080e7          	jalr	-1178(ra) # 8000027c <consputc>
      break;
    8000071e:	b719                	j	80000624 <printf+0x9a>
      consputc('%');
    80000720:	8556                	mv	a0,s5
    80000722:	00000097          	auipc	ra,0x0
    80000726:	b5a080e7          	jalr	-1190(ra) # 8000027c <consputc>
      consputc(c);
    8000072a:	8526                	mv	a0,s1
    8000072c:	00000097          	auipc	ra,0x0
    80000730:	b50080e7          	jalr	-1200(ra) # 8000027c <consputc>
      break;
    80000734:	bdc5                	j	80000624 <printf+0x9a>
  if(locking)
    80000736:	020d9163          	bnez	s11,80000758 <printf+0x1ce>
}
    8000073a:	70e6                	ld	ra,120(sp)
    8000073c:	7446                	ld	s0,112(sp)
    8000073e:	74a6                	ld	s1,104(sp)
    80000740:	7906                	ld	s2,96(sp)
    80000742:	69e6                	ld	s3,88(sp)
    80000744:	6a46                	ld	s4,80(sp)
    80000746:	6aa6                	ld	s5,72(sp)
    80000748:	6b06                	ld	s6,64(sp)
    8000074a:	7be2                	ld	s7,56(sp)
    8000074c:	7c42                	ld	s8,48(sp)
    8000074e:	7ca2                	ld	s9,40(sp)
    80000750:	7d02                	ld	s10,32(sp)
    80000752:	6de2                	ld	s11,24(sp)
    80000754:	6129                	addi	sp,sp,192
    80000756:	8082                	ret
    release(&pr.lock);
    80000758:	00010517          	auipc	a0,0x10
    8000075c:	3c050513          	addi	a0,a0,960 # 80010b18 <pr>
    80000760:	00000097          	auipc	ra,0x0
    80000764:	52a080e7          	jalr	1322(ra) # 80000c8a <release>
}
    80000768:	bfc9                	j	8000073a <printf+0x1b0>

000000008000076a <printfinit>:
    ;
}

void
printfinit(void)
{
    8000076a:	1101                	addi	sp,sp,-32
    8000076c:	ec06                	sd	ra,24(sp)
    8000076e:	e822                	sd	s0,16(sp)
    80000770:	e426                	sd	s1,8(sp)
    80000772:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000774:	00010497          	auipc	s1,0x10
    80000778:	3a448493          	addi	s1,s1,932 # 80010b18 <pr>
    8000077c:	00008597          	auipc	a1,0x8
    80000780:	8bc58593          	addi	a1,a1,-1860 # 80008038 <etext+0x38>
    80000784:	8526                	mv	a0,s1
    80000786:	00000097          	auipc	ra,0x0
    8000078a:	3c0080e7          	jalr	960(ra) # 80000b46 <initlock>
  pr.locking = 1;
    8000078e:	4785                	li	a5,1
    80000790:	cc9c                	sw	a5,24(s1)
}
    80000792:	60e2                	ld	ra,24(sp)
    80000794:	6442                	ld	s0,16(sp)
    80000796:	64a2                	ld	s1,8(sp)
    80000798:	6105                	addi	sp,sp,32
    8000079a:	8082                	ret

000000008000079c <uartinit>:

void uartstart();

void
uartinit(void)
{
    8000079c:	1141                	addi	sp,sp,-16
    8000079e:	e406                	sd	ra,8(sp)
    800007a0:	e022                	sd	s0,0(sp)
    800007a2:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007a4:	100007b7          	lui	a5,0x10000
    800007a8:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007ac:	f8000713          	li	a4,-128
    800007b0:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007b4:	470d                	li	a4,3
    800007b6:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007ba:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007be:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007c2:	469d                	li	a3,7
    800007c4:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007c8:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007cc:	00008597          	auipc	a1,0x8
    800007d0:	88c58593          	addi	a1,a1,-1908 # 80008058 <digits+0x18>
    800007d4:	00010517          	auipc	a0,0x10
    800007d8:	36450513          	addi	a0,a0,868 # 80010b38 <uart_tx_lock>
    800007dc:	00000097          	auipc	ra,0x0
    800007e0:	36a080e7          	jalr	874(ra) # 80000b46 <initlock>
}
    800007e4:	60a2                	ld	ra,8(sp)
    800007e6:	6402                	ld	s0,0(sp)
    800007e8:	0141                	addi	sp,sp,16
    800007ea:	8082                	ret

00000000800007ec <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007ec:	1101                	addi	sp,sp,-32
    800007ee:	ec06                	sd	ra,24(sp)
    800007f0:	e822                	sd	s0,16(sp)
    800007f2:	e426                	sd	s1,8(sp)
    800007f4:	1000                	addi	s0,sp,32
    800007f6:	84aa                	mv	s1,a0
  push_off();
    800007f8:	00000097          	auipc	ra,0x0
    800007fc:	392080e7          	jalr	914(ra) # 80000b8a <push_off>

  if(panicked){
    80000800:	00008797          	auipc	a5,0x8
    80000804:	0f07a783          	lw	a5,240(a5) # 800088f0 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000808:	10000737          	lui	a4,0x10000
  if(panicked){
    8000080c:	c391                	beqz	a5,80000810 <uartputc_sync+0x24>
    for(;;)
    8000080e:	a001                	j	8000080e <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000810:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000814:	0207f793          	andi	a5,a5,32
    80000818:	dfe5                	beqz	a5,80000810 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    8000081a:	0ff4f513          	zext.b	a0,s1
    8000081e:	100007b7          	lui	a5,0x10000
    80000822:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000826:	00000097          	auipc	ra,0x0
    8000082a:	404080e7          	jalr	1028(ra) # 80000c2a <pop_off>
}
    8000082e:	60e2                	ld	ra,24(sp)
    80000830:	6442                	ld	s0,16(sp)
    80000832:	64a2                	ld	s1,8(sp)
    80000834:	6105                	addi	sp,sp,32
    80000836:	8082                	ret

0000000080000838 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000838:	00008797          	auipc	a5,0x8
    8000083c:	0c07b783          	ld	a5,192(a5) # 800088f8 <uart_tx_r>
    80000840:	00008717          	auipc	a4,0x8
    80000844:	0c073703          	ld	a4,192(a4) # 80008900 <uart_tx_w>
    80000848:	06f70a63          	beq	a4,a5,800008bc <uartstart+0x84>
{
    8000084c:	7139                	addi	sp,sp,-64
    8000084e:	fc06                	sd	ra,56(sp)
    80000850:	f822                	sd	s0,48(sp)
    80000852:	f426                	sd	s1,40(sp)
    80000854:	f04a                	sd	s2,32(sp)
    80000856:	ec4e                	sd	s3,24(sp)
    80000858:	e852                	sd	s4,16(sp)
    8000085a:	e456                	sd	s5,8(sp)
    8000085c:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000085e:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000862:	00010a17          	auipc	s4,0x10
    80000866:	2d6a0a13          	addi	s4,s4,726 # 80010b38 <uart_tx_lock>
    uart_tx_r += 1;
    8000086a:	00008497          	auipc	s1,0x8
    8000086e:	08e48493          	addi	s1,s1,142 # 800088f8 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000872:	00008997          	auipc	s3,0x8
    80000876:	08e98993          	addi	s3,s3,142 # 80008900 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000087a:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000087e:	02077713          	andi	a4,a4,32
    80000882:	c705                	beqz	a4,800008aa <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000884:	01f7f713          	andi	a4,a5,31
    80000888:	9752                	add	a4,a4,s4
    8000088a:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    8000088e:	0785                	addi	a5,a5,1
    80000890:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    80000892:	8526                	mv	a0,s1
    80000894:	00002097          	auipc	ra,0x2
    80000898:	82e080e7          	jalr	-2002(ra) # 800020c2 <wakeup>
    
    WriteReg(THR, c);
    8000089c:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    800008a0:	609c                	ld	a5,0(s1)
    800008a2:	0009b703          	ld	a4,0(s3)
    800008a6:	fcf71ae3          	bne	a4,a5,8000087a <uartstart+0x42>
  }
}
    800008aa:	70e2                	ld	ra,56(sp)
    800008ac:	7442                	ld	s0,48(sp)
    800008ae:	74a2                	ld	s1,40(sp)
    800008b0:	7902                	ld	s2,32(sp)
    800008b2:	69e2                	ld	s3,24(sp)
    800008b4:	6a42                	ld	s4,16(sp)
    800008b6:	6aa2                	ld	s5,8(sp)
    800008b8:	6121                	addi	sp,sp,64
    800008ba:	8082                	ret
    800008bc:	8082                	ret

00000000800008be <uartputc>:
{
    800008be:	7179                	addi	sp,sp,-48
    800008c0:	f406                	sd	ra,40(sp)
    800008c2:	f022                	sd	s0,32(sp)
    800008c4:	ec26                	sd	s1,24(sp)
    800008c6:	e84a                	sd	s2,16(sp)
    800008c8:	e44e                	sd	s3,8(sp)
    800008ca:	e052                	sd	s4,0(sp)
    800008cc:	1800                	addi	s0,sp,48
    800008ce:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008d0:	00010517          	auipc	a0,0x10
    800008d4:	26850513          	addi	a0,a0,616 # 80010b38 <uart_tx_lock>
    800008d8:	00000097          	auipc	ra,0x0
    800008dc:	2fe080e7          	jalr	766(ra) # 80000bd6 <acquire>
  if(panicked){
    800008e0:	00008797          	auipc	a5,0x8
    800008e4:	0107a783          	lw	a5,16(a5) # 800088f0 <panicked>
    800008e8:	e7c9                	bnez	a5,80000972 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008ea:	00008717          	auipc	a4,0x8
    800008ee:	01673703          	ld	a4,22(a4) # 80008900 <uart_tx_w>
    800008f2:	00008797          	auipc	a5,0x8
    800008f6:	0067b783          	ld	a5,6(a5) # 800088f8 <uart_tx_r>
    800008fa:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fe:	00010997          	auipc	s3,0x10
    80000902:	23a98993          	addi	s3,s3,570 # 80010b38 <uart_tx_lock>
    80000906:	00008497          	auipc	s1,0x8
    8000090a:	ff248493          	addi	s1,s1,-14 # 800088f8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090e:	00008917          	auipc	s2,0x8
    80000912:	ff290913          	addi	s2,s2,-14 # 80008900 <uart_tx_w>
    80000916:	00e79f63          	bne	a5,a4,80000934 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000091a:	85ce                	mv	a1,s3
    8000091c:	8526                	mv	a0,s1
    8000091e:	00001097          	auipc	ra,0x1
    80000922:	740080e7          	jalr	1856(ra) # 8000205e <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000926:	00093703          	ld	a4,0(s2)
    8000092a:	609c                	ld	a5,0(s1)
    8000092c:	02078793          	addi	a5,a5,32
    80000930:	fee785e3          	beq	a5,a4,8000091a <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000934:	00010497          	auipc	s1,0x10
    80000938:	20448493          	addi	s1,s1,516 # 80010b38 <uart_tx_lock>
    8000093c:	01f77793          	andi	a5,a4,31
    80000940:	97a6                	add	a5,a5,s1
    80000942:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000946:	0705                	addi	a4,a4,1
    80000948:	00008797          	auipc	a5,0x8
    8000094c:	fae7bc23          	sd	a4,-72(a5) # 80008900 <uart_tx_w>
  uartstart();
    80000950:	00000097          	auipc	ra,0x0
    80000954:	ee8080e7          	jalr	-280(ra) # 80000838 <uartstart>
  release(&uart_tx_lock);
    80000958:	8526                	mv	a0,s1
    8000095a:	00000097          	auipc	ra,0x0
    8000095e:	330080e7          	jalr	816(ra) # 80000c8a <release>
}
    80000962:	70a2                	ld	ra,40(sp)
    80000964:	7402                	ld	s0,32(sp)
    80000966:	64e2                	ld	s1,24(sp)
    80000968:	6942                	ld	s2,16(sp)
    8000096a:	69a2                	ld	s3,8(sp)
    8000096c:	6a02                	ld	s4,0(sp)
    8000096e:	6145                	addi	sp,sp,48
    80000970:	8082                	ret
    for(;;)
    80000972:	a001                	j	80000972 <uartputc+0xb4>

0000000080000974 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000974:	1141                	addi	sp,sp,-16
    80000976:	e422                	sd	s0,8(sp)
    80000978:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    8000097a:	100007b7          	lui	a5,0x10000
    8000097e:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000982:	8b85                	andi	a5,a5,1
    80000984:	cb81                	beqz	a5,80000994 <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    80000986:	100007b7          	lui	a5,0x10000
    8000098a:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    8000098e:	6422                	ld	s0,8(sp)
    80000990:	0141                	addi	sp,sp,16
    80000992:	8082                	ret
    return -1;
    80000994:	557d                	li	a0,-1
    80000996:	bfe5                	j	8000098e <uartgetc+0x1a>

0000000080000998 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000998:	1101                	addi	sp,sp,-32
    8000099a:	ec06                	sd	ra,24(sp)
    8000099c:	e822                	sd	s0,16(sp)
    8000099e:	e426                	sd	s1,8(sp)
    800009a0:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009a2:	54fd                	li	s1,-1
    800009a4:	a029                	j	800009ae <uartintr+0x16>
      break;
    consoleintr(c);
    800009a6:	00000097          	auipc	ra,0x0
    800009aa:	918080e7          	jalr	-1768(ra) # 800002be <consoleintr>
    int c = uartgetc();
    800009ae:	00000097          	auipc	ra,0x0
    800009b2:	fc6080e7          	jalr	-58(ra) # 80000974 <uartgetc>
    if(c == -1)
    800009b6:	fe9518e3          	bne	a0,s1,800009a6 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009ba:	00010497          	auipc	s1,0x10
    800009be:	17e48493          	addi	s1,s1,382 # 80010b38 <uart_tx_lock>
    800009c2:	8526                	mv	a0,s1
    800009c4:	00000097          	auipc	ra,0x0
    800009c8:	212080e7          	jalr	530(ra) # 80000bd6 <acquire>
  uartstart();
    800009cc:	00000097          	auipc	ra,0x0
    800009d0:	e6c080e7          	jalr	-404(ra) # 80000838 <uartstart>
  release(&uart_tx_lock);
    800009d4:	8526                	mv	a0,s1
    800009d6:	00000097          	auipc	ra,0x0
    800009da:	2b4080e7          	jalr	692(ra) # 80000c8a <release>
}
    800009de:	60e2                	ld	ra,24(sp)
    800009e0:	6442                	ld	s0,16(sp)
    800009e2:	64a2                	ld	s1,8(sp)
    800009e4:	6105                	addi	sp,sp,32
    800009e6:	8082                	ret

00000000800009e8 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009e8:	1101                	addi	sp,sp,-32
    800009ea:	ec06                	sd	ra,24(sp)
    800009ec:	e822                	sd	s0,16(sp)
    800009ee:	e426                	sd	s1,8(sp)
    800009f0:	e04a                	sd	s2,0(sp)
    800009f2:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009f4:	03451793          	slli	a5,a0,0x34
    800009f8:	ebb9                	bnez	a5,80000a4e <kfree+0x66>
    800009fa:	84aa                	mv	s1,a0
    800009fc:	00021797          	auipc	a5,0x21
    80000a00:	5a478793          	addi	a5,a5,1444 # 80021fa0 <end>
    80000a04:	04f56563          	bltu	a0,a5,80000a4e <kfree+0x66>
    80000a08:	47c5                	li	a5,17
    80000a0a:	07ee                	slli	a5,a5,0x1b
    80000a0c:	04f57163          	bgeu	a0,a5,80000a4e <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a10:	6605                	lui	a2,0x1
    80000a12:	4585                	li	a1,1
    80000a14:	00000097          	auipc	ra,0x0
    80000a18:	2be080e7          	jalr	702(ra) # 80000cd2 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a1c:	00010917          	auipc	s2,0x10
    80000a20:	15490913          	addi	s2,s2,340 # 80010b70 <kmem>
    80000a24:	854a                	mv	a0,s2
    80000a26:	00000097          	auipc	ra,0x0
    80000a2a:	1b0080e7          	jalr	432(ra) # 80000bd6 <acquire>
  r->next = kmem.freelist;
    80000a2e:	01893783          	ld	a5,24(s2)
    80000a32:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a34:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a38:	854a                	mv	a0,s2
    80000a3a:	00000097          	auipc	ra,0x0
    80000a3e:	250080e7          	jalr	592(ra) # 80000c8a <release>
}
    80000a42:	60e2                	ld	ra,24(sp)
    80000a44:	6442                	ld	s0,16(sp)
    80000a46:	64a2                	ld	s1,8(sp)
    80000a48:	6902                	ld	s2,0(sp)
    80000a4a:	6105                	addi	sp,sp,32
    80000a4c:	8082                	ret
    panic("kfree");
    80000a4e:	00007517          	auipc	a0,0x7
    80000a52:	61250513          	addi	a0,a0,1554 # 80008060 <digits+0x20>
    80000a56:	00000097          	auipc	ra,0x0
    80000a5a:	aea080e7          	jalr	-1302(ra) # 80000540 <panic>

0000000080000a5e <freerange>:
{
    80000a5e:	7179                	addi	sp,sp,-48
    80000a60:	f406                	sd	ra,40(sp)
    80000a62:	f022                	sd	s0,32(sp)
    80000a64:	ec26                	sd	s1,24(sp)
    80000a66:	e84a                	sd	s2,16(sp)
    80000a68:	e44e                	sd	s3,8(sp)
    80000a6a:	e052                	sd	s4,0(sp)
    80000a6c:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a6e:	6785                	lui	a5,0x1
    80000a70:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000a74:	00e504b3          	add	s1,a0,a4
    80000a78:	777d                	lui	a4,0xfffff
    80000a7a:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a7c:	94be                	add	s1,s1,a5
    80000a7e:	0095ee63          	bltu	a1,s1,80000a9a <freerange+0x3c>
    80000a82:	892e                	mv	s2,a1
    kfree(p);
    80000a84:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a86:	6985                	lui	s3,0x1
    kfree(p);
    80000a88:	01448533          	add	a0,s1,s4
    80000a8c:	00000097          	auipc	ra,0x0
    80000a90:	f5c080e7          	jalr	-164(ra) # 800009e8 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a94:	94ce                	add	s1,s1,s3
    80000a96:	fe9979e3          	bgeu	s2,s1,80000a88 <freerange+0x2a>
}
    80000a9a:	70a2                	ld	ra,40(sp)
    80000a9c:	7402                	ld	s0,32(sp)
    80000a9e:	64e2                	ld	s1,24(sp)
    80000aa0:	6942                	ld	s2,16(sp)
    80000aa2:	69a2                	ld	s3,8(sp)
    80000aa4:	6a02                	ld	s4,0(sp)
    80000aa6:	6145                	addi	sp,sp,48
    80000aa8:	8082                	ret

0000000080000aaa <kinit>:
{
    80000aaa:	1141                	addi	sp,sp,-16
    80000aac:	e406                	sd	ra,8(sp)
    80000aae:	e022                	sd	s0,0(sp)
    80000ab0:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ab2:	00007597          	auipc	a1,0x7
    80000ab6:	5b658593          	addi	a1,a1,1462 # 80008068 <digits+0x28>
    80000aba:	00010517          	auipc	a0,0x10
    80000abe:	0b650513          	addi	a0,a0,182 # 80010b70 <kmem>
    80000ac2:	00000097          	auipc	ra,0x0
    80000ac6:	084080e7          	jalr	132(ra) # 80000b46 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000aca:	45c5                	li	a1,17
    80000acc:	05ee                	slli	a1,a1,0x1b
    80000ace:	00021517          	auipc	a0,0x21
    80000ad2:	4d250513          	addi	a0,a0,1234 # 80021fa0 <end>
    80000ad6:	00000097          	auipc	ra,0x0
    80000ada:	f88080e7          	jalr	-120(ra) # 80000a5e <freerange>
}
    80000ade:	60a2                	ld	ra,8(sp)
    80000ae0:	6402                	ld	s0,0(sp)
    80000ae2:	0141                	addi	sp,sp,16
    80000ae4:	8082                	ret

0000000080000ae6 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ae6:	1101                	addi	sp,sp,-32
    80000ae8:	ec06                	sd	ra,24(sp)
    80000aea:	e822                	sd	s0,16(sp)
    80000aec:	e426                	sd	s1,8(sp)
    80000aee:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000af0:	00010497          	auipc	s1,0x10
    80000af4:	08048493          	addi	s1,s1,128 # 80010b70 <kmem>
    80000af8:	8526                	mv	a0,s1
    80000afa:	00000097          	auipc	ra,0x0
    80000afe:	0dc080e7          	jalr	220(ra) # 80000bd6 <acquire>
  r = kmem.freelist;
    80000b02:	6c84                	ld	s1,24(s1)
  if(r)
    80000b04:	c885                	beqz	s1,80000b34 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b06:	609c                	ld	a5,0(s1)
    80000b08:	00010517          	auipc	a0,0x10
    80000b0c:	06850513          	addi	a0,a0,104 # 80010b70 <kmem>
    80000b10:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b12:	00000097          	auipc	ra,0x0
    80000b16:	178080e7          	jalr	376(ra) # 80000c8a <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b1a:	6605                	lui	a2,0x1
    80000b1c:	4595                	li	a1,5
    80000b1e:	8526                	mv	a0,s1
    80000b20:	00000097          	auipc	ra,0x0
    80000b24:	1b2080e7          	jalr	434(ra) # 80000cd2 <memset>
  return (void*)r;
}
    80000b28:	8526                	mv	a0,s1
    80000b2a:	60e2                	ld	ra,24(sp)
    80000b2c:	6442                	ld	s0,16(sp)
    80000b2e:	64a2                	ld	s1,8(sp)
    80000b30:	6105                	addi	sp,sp,32
    80000b32:	8082                	ret
  release(&kmem.lock);
    80000b34:	00010517          	auipc	a0,0x10
    80000b38:	03c50513          	addi	a0,a0,60 # 80010b70 <kmem>
    80000b3c:	00000097          	auipc	ra,0x0
    80000b40:	14e080e7          	jalr	334(ra) # 80000c8a <release>
  if(r)
    80000b44:	b7d5                	j	80000b28 <kalloc+0x42>

0000000080000b46 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b46:	1141                	addi	sp,sp,-16
    80000b48:	e422                	sd	s0,8(sp)
    80000b4a:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b4c:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b4e:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b52:	00053823          	sd	zero,16(a0)
}
    80000b56:	6422                	ld	s0,8(sp)
    80000b58:	0141                	addi	sp,sp,16
    80000b5a:	8082                	ret

0000000080000b5c <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b5c:	411c                	lw	a5,0(a0)
    80000b5e:	e399                	bnez	a5,80000b64 <holding+0x8>
    80000b60:	4501                	li	a0,0
  return r;
}
    80000b62:	8082                	ret
{
    80000b64:	1101                	addi	sp,sp,-32
    80000b66:	ec06                	sd	ra,24(sp)
    80000b68:	e822                	sd	s0,16(sp)
    80000b6a:	e426                	sd	s1,8(sp)
    80000b6c:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b6e:	6904                	ld	s1,16(a0)
    80000b70:	00001097          	auipc	ra,0x1
    80000b74:	e20080e7          	jalr	-480(ra) # 80001990 <mycpu>
    80000b78:	40a48533          	sub	a0,s1,a0
    80000b7c:	00153513          	seqz	a0,a0
}
    80000b80:	60e2                	ld	ra,24(sp)
    80000b82:	6442                	ld	s0,16(sp)
    80000b84:	64a2                	ld	s1,8(sp)
    80000b86:	6105                	addi	sp,sp,32
    80000b88:	8082                	ret

0000000080000b8a <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b8a:	1101                	addi	sp,sp,-32
    80000b8c:	ec06                	sd	ra,24(sp)
    80000b8e:	e822                	sd	s0,16(sp)
    80000b90:	e426                	sd	s1,8(sp)
    80000b92:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b94:	100024f3          	csrr	s1,sstatus
    80000b98:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b9c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b9e:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000ba2:	00001097          	auipc	ra,0x1
    80000ba6:	dee080e7          	jalr	-530(ra) # 80001990 <mycpu>
    80000baa:	5d3c                	lw	a5,120(a0)
    80000bac:	cf89                	beqz	a5,80000bc6 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bae:	00001097          	auipc	ra,0x1
    80000bb2:	de2080e7          	jalr	-542(ra) # 80001990 <mycpu>
    80000bb6:	5d3c                	lw	a5,120(a0)
    80000bb8:	2785                	addiw	a5,a5,1
    80000bba:	dd3c                	sw	a5,120(a0)
}
    80000bbc:	60e2                	ld	ra,24(sp)
    80000bbe:	6442                	ld	s0,16(sp)
    80000bc0:	64a2                	ld	s1,8(sp)
    80000bc2:	6105                	addi	sp,sp,32
    80000bc4:	8082                	ret
    mycpu()->intena = old;
    80000bc6:	00001097          	auipc	ra,0x1
    80000bca:	dca080e7          	jalr	-566(ra) # 80001990 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bce:	8085                	srli	s1,s1,0x1
    80000bd0:	8885                	andi	s1,s1,1
    80000bd2:	dd64                	sw	s1,124(a0)
    80000bd4:	bfe9                	j	80000bae <push_off+0x24>

0000000080000bd6 <acquire>:
{
    80000bd6:	1101                	addi	sp,sp,-32
    80000bd8:	ec06                	sd	ra,24(sp)
    80000bda:	e822                	sd	s0,16(sp)
    80000bdc:	e426                	sd	s1,8(sp)
    80000bde:	1000                	addi	s0,sp,32
    80000be0:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000be2:	00000097          	auipc	ra,0x0
    80000be6:	fa8080e7          	jalr	-88(ra) # 80000b8a <push_off>
  if(holding(lk))
    80000bea:	8526                	mv	a0,s1
    80000bec:	00000097          	auipc	ra,0x0
    80000bf0:	f70080e7          	jalr	-144(ra) # 80000b5c <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf4:	4705                	li	a4,1
  if(holding(lk))
    80000bf6:	e115                	bnez	a0,80000c1a <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf8:	87ba                	mv	a5,a4
    80000bfa:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bfe:	2781                	sext.w	a5,a5
    80000c00:	ffe5                	bnez	a5,80000bf8 <acquire+0x22>
  __sync_synchronize();
    80000c02:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c06:	00001097          	auipc	ra,0x1
    80000c0a:	d8a080e7          	jalr	-630(ra) # 80001990 <mycpu>
    80000c0e:	e888                	sd	a0,16(s1)
}
    80000c10:	60e2                	ld	ra,24(sp)
    80000c12:	6442                	ld	s0,16(sp)
    80000c14:	64a2                	ld	s1,8(sp)
    80000c16:	6105                	addi	sp,sp,32
    80000c18:	8082                	ret
    panic("acquire");
    80000c1a:	00007517          	auipc	a0,0x7
    80000c1e:	45650513          	addi	a0,a0,1110 # 80008070 <digits+0x30>
    80000c22:	00000097          	auipc	ra,0x0
    80000c26:	91e080e7          	jalr	-1762(ra) # 80000540 <panic>

0000000080000c2a <pop_off>:

void
pop_off(void)
{
    80000c2a:	1141                	addi	sp,sp,-16
    80000c2c:	e406                	sd	ra,8(sp)
    80000c2e:	e022                	sd	s0,0(sp)
    80000c30:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c32:	00001097          	auipc	ra,0x1
    80000c36:	d5e080e7          	jalr	-674(ra) # 80001990 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c3a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c3e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c40:	e78d                	bnez	a5,80000c6a <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c42:	5d3c                	lw	a5,120(a0)
    80000c44:	02f05b63          	blez	a5,80000c7a <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c48:	37fd                	addiw	a5,a5,-1
    80000c4a:	0007871b          	sext.w	a4,a5
    80000c4e:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c50:	eb09                	bnez	a4,80000c62 <pop_off+0x38>
    80000c52:	5d7c                	lw	a5,124(a0)
    80000c54:	c799                	beqz	a5,80000c62 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c56:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c5a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c5e:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c62:	60a2                	ld	ra,8(sp)
    80000c64:	6402                	ld	s0,0(sp)
    80000c66:	0141                	addi	sp,sp,16
    80000c68:	8082                	ret
    panic("pop_off - interruptible");
    80000c6a:	00007517          	auipc	a0,0x7
    80000c6e:	40e50513          	addi	a0,a0,1038 # 80008078 <digits+0x38>
    80000c72:	00000097          	auipc	ra,0x0
    80000c76:	8ce080e7          	jalr	-1842(ra) # 80000540 <panic>
    panic("pop_off");
    80000c7a:	00007517          	auipc	a0,0x7
    80000c7e:	41650513          	addi	a0,a0,1046 # 80008090 <digits+0x50>
    80000c82:	00000097          	auipc	ra,0x0
    80000c86:	8be080e7          	jalr	-1858(ra) # 80000540 <panic>

0000000080000c8a <release>:
{
    80000c8a:	1101                	addi	sp,sp,-32
    80000c8c:	ec06                	sd	ra,24(sp)
    80000c8e:	e822                	sd	s0,16(sp)
    80000c90:	e426                	sd	s1,8(sp)
    80000c92:	1000                	addi	s0,sp,32
    80000c94:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c96:	00000097          	auipc	ra,0x0
    80000c9a:	ec6080e7          	jalr	-314(ra) # 80000b5c <holding>
    80000c9e:	c115                	beqz	a0,80000cc2 <release+0x38>
  lk->cpu = 0;
    80000ca0:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ca4:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ca8:	0f50000f          	fence	iorw,ow
    80000cac:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cb0:	00000097          	auipc	ra,0x0
    80000cb4:	f7a080e7          	jalr	-134(ra) # 80000c2a <pop_off>
}
    80000cb8:	60e2                	ld	ra,24(sp)
    80000cba:	6442                	ld	s0,16(sp)
    80000cbc:	64a2                	ld	s1,8(sp)
    80000cbe:	6105                	addi	sp,sp,32
    80000cc0:	8082                	ret
    panic("release");
    80000cc2:	00007517          	auipc	a0,0x7
    80000cc6:	3d650513          	addi	a0,a0,982 # 80008098 <digits+0x58>
    80000cca:	00000097          	auipc	ra,0x0
    80000cce:	876080e7          	jalr	-1930(ra) # 80000540 <panic>

0000000080000cd2 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cd2:	1141                	addi	sp,sp,-16
    80000cd4:	e422                	sd	s0,8(sp)
    80000cd6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cd8:	ca19                	beqz	a2,80000cee <memset+0x1c>
    80000cda:	87aa                	mv	a5,a0
    80000cdc:	1602                	slli	a2,a2,0x20
    80000cde:	9201                	srli	a2,a2,0x20
    80000ce0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000ce4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000ce8:	0785                	addi	a5,a5,1
    80000cea:	fee79de3          	bne	a5,a4,80000ce4 <memset+0x12>
  }
  return dst;
}
    80000cee:	6422                	ld	s0,8(sp)
    80000cf0:	0141                	addi	sp,sp,16
    80000cf2:	8082                	ret

0000000080000cf4 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cf4:	1141                	addi	sp,sp,-16
    80000cf6:	e422                	sd	s0,8(sp)
    80000cf8:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cfa:	ca05                	beqz	a2,80000d2a <memcmp+0x36>
    80000cfc:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000d00:	1682                	slli	a3,a3,0x20
    80000d02:	9281                	srli	a3,a3,0x20
    80000d04:	0685                	addi	a3,a3,1
    80000d06:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d08:	00054783          	lbu	a5,0(a0)
    80000d0c:	0005c703          	lbu	a4,0(a1)
    80000d10:	00e79863          	bne	a5,a4,80000d20 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d14:	0505                	addi	a0,a0,1
    80000d16:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d18:	fed518e3          	bne	a0,a3,80000d08 <memcmp+0x14>
  }

  return 0;
    80000d1c:	4501                	li	a0,0
    80000d1e:	a019                	j	80000d24 <memcmp+0x30>
      return *s1 - *s2;
    80000d20:	40e7853b          	subw	a0,a5,a4
}
    80000d24:	6422                	ld	s0,8(sp)
    80000d26:	0141                	addi	sp,sp,16
    80000d28:	8082                	ret
  return 0;
    80000d2a:	4501                	li	a0,0
    80000d2c:	bfe5                	j	80000d24 <memcmp+0x30>

0000000080000d2e <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d2e:	1141                	addi	sp,sp,-16
    80000d30:	e422                	sd	s0,8(sp)
    80000d32:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d34:	c205                	beqz	a2,80000d54 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d36:	02a5e263          	bltu	a1,a0,80000d5a <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d3a:	1602                	slli	a2,a2,0x20
    80000d3c:	9201                	srli	a2,a2,0x20
    80000d3e:	00c587b3          	add	a5,a1,a2
{
    80000d42:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d44:	0585                	addi	a1,a1,1
    80000d46:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdd061>
    80000d48:	fff5c683          	lbu	a3,-1(a1)
    80000d4c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d50:	fef59ae3          	bne	a1,a5,80000d44 <memmove+0x16>

  return dst;
}
    80000d54:	6422                	ld	s0,8(sp)
    80000d56:	0141                	addi	sp,sp,16
    80000d58:	8082                	ret
  if(s < d && s + n > d){
    80000d5a:	02061693          	slli	a3,a2,0x20
    80000d5e:	9281                	srli	a3,a3,0x20
    80000d60:	00d58733          	add	a4,a1,a3
    80000d64:	fce57be3          	bgeu	a0,a4,80000d3a <memmove+0xc>
    d += n;
    80000d68:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d6a:	fff6079b          	addiw	a5,a2,-1
    80000d6e:	1782                	slli	a5,a5,0x20
    80000d70:	9381                	srli	a5,a5,0x20
    80000d72:	fff7c793          	not	a5,a5
    80000d76:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d78:	177d                	addi	a4,a4,-1
    80000d7a:	16fd                	addi	a3,a3,-1
    80000d7c:	00074603          	lbu	a2,0(a4)
    80000d80:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d84:	fee79ae3          	bne	a5,a4,80000d78 <memmove+0x4a>
    80000d88:	b7f1                	j	80000d54 <memmove+0x26>

0000000080000d8a <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d8a:	1141                	addi	sp,sp,-16
    80000d8c:	e406                	sd	ra,8(sp)
    80000d8e:	e022                	sd	s0,0(sp)
    80000d90:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d92:	00000097          	auipc	ra,0x0
    80000d96:	f9c080e7          	jalr	-100(ra) # 80000d2e <memmove>
}
    80000d9a:	60a2                	ld	ra,8(sp)
    80000d9c:	6402                	ld	s0,0(sp)
    80000d9e:	0141                	addi	sp,sp,16
    80000da0:	8082                	ret

0000000080000da2 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000da2:	1141                	addi	sp,sp,-16
    80000da4:	e422                	sd	s0,8(sp)
    80000da6:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000da8:	ce11                	beqz	a2,80000dc4 <strncmp+0x22>
    80000daa:	00054783          	lbu	a5,0(a0)
    80000dae:	cf89                	beqz	a5,80000dc8 <strncmp+0x26>
    80000db0:	0005c703          	lbu	a4,0(a1)
    80000db4:	00f71a63          	bne	a4,a5,80000dc8 <strncmp+0x26>
    n--, p++, q++;
    80000db8:	367d                	addiw	a2,a2,-1
    80000dba:	0505                	addi	a0,a0,1
    80000dbc:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dbe:	f675                	bnez	a2,80000daa <strncmp+0x8>
  if(n == 0)
    return 0;
    80000dc0:	4501                	li	a0,0
    80000dc2:	a809                	j	80000dd4 <strncmp+0x32>
    80000dc4:	4501                	li	a0,0
    80000dc6:	a039                	j	80000dd4 <strncmp+0x32>
  if(n == 0)
    80000dc8:	ca09                	beqz	a2,80000dda <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dca:	00054503          	lbu	a0,0(a0)
    80000dce:	0005c783          	lbu	a5,0(a1)
    80000dd2:	9d1d                	subw	a0,a0,a5
}
    80000dd4:	6422                	ld	s0,8(sp)
    80000dd6:	0141                	addi	sp,sp,16
    80000dd8:	8082                	ret
    return 0;
    80000dda:	4501                	li	a0,0
    80000ddc:	bfe5                	j	80000dd4 <strncmp+0x32>

0000000080000dde <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dde:	1141                	addi	sp,sp,-16
    80000de0:	e422                	sd	s0,8(sp)
    80000de2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000de4:	872a                	mv	a4,a0
    80000de6:	8832                	mv	a6,a2
    80000de8:	367d                	addiw	a2,a2,-1
    80000dea:	01005963          	blez	a6,80000dfc <strncpy+0x1e>
    80000dee:	0705                	addi	a4,a4,1
    80000df0:	0005c783          	lbu	a5,0(a1)
    80000df4:	fef70fa3          	sb	a5,-1(a4)
    80000df8:	0585                	addi	a1,a1,1
    80000dfa:	f7f5                	bnez	a5,80000de6 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000dfc:	86ba                	mv	a3,a4
    80000dfe:	00c05c63          	blez	a2,80000e16 <strncpy+0x38>
    *s++ = 0;
    80000e02:	0685                	addi	a3,a3,1
    80000e04:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e08:	40d707bb          	subw	a5,a4,a3
    80000e0c:	37fd                	addiw	a5,a5,-1
    80000e0e:	010787bb          	addw	a5,a5,a6
    80000e12:	fef048e3          	bgtz	a5,80000e02 <strncpy+0x24>
  return os;
}
    80000e16:	6422                	ld	s0,8(sp)
    80000e18:	0141                	addi	sp,sp,16
    80000e1a:	8082                	ret

0000000080000e1c <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e1c:	1141                	addi	sp,sp,-16
    80000e1e:	e422                	sd	s0,8(sp)
    80000e20:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e22:	02c05363          	blez	a2,80000e48 <safestrcpy+0x2c>
    80000e26:	fff6069b          	addiw	a3,a2,-1
    80000e2a:	1682                	slli	a3,a3,0x20
    80000e2c:	9281                	srli	a3,a3,0x20
    80000e2e:	96ae                	add	a3,a3,a1
    80000e30:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e32:	00d58963          	beq	a1,a3,80000e44 <safestrcpy+0x28>
    80000e36:	0585                	addi	a1,a1,1
    80000e38:	0785                	addi	a5,a5,1
    80000e3a:	fff5c703          	lbu	a4,-1(a1)
    80000e3e:	fee78fa3          	sb	a4,-1(a5)
    80000e42:	fb65                	bnez	a4,80000e32 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e44:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e48:	6422                	ld	s0,8(sp)
    80000e4a:	0141                	addi	sp,sp,16
    80000e4c:	8082                	ret

0000000080000e4e <strlen>:

int
strlen(const char *s)
{
    80000e4e:	1141                	addi	sp,sp,-16
    80000e50:	e422                	sd	s0,8(sp)
    80000e52:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e54:	00054783          	lbu	a5,0(a0)
    80000e58:	cf91                	beqz	a5,80000e74 <strlen+0x26>
    80000e5a:	0505                	addi	a0,a0,1
    80000e5c:	87aa                	mv	a5,a0
    80000e5e:	4685                	li	a3,1
    80000e60:	9e89                	subw	a3,a3,a0
    80000e62:	00f6853b          	addw	a0,a3,a5
    80000e66:	0785                	addi	a5,a5,1
    80000e68:	fff7c703          	lbu	a4,-1(a5)
    80000e6c:	fb7d                	bnez	a4,80000e62 <strlen+0x14>
    ;
  return n;
}
    80000e6e:	6422                	ld	s0,8(sp)
    80000e70:	0141                	addi	sp,sp,16
    80000e72:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e74:	4501                	li	a0,0
    80000e76:	bfe5                	j	80000e6e <strlen+0x20>

0000000080000e78 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e78:	1141                	addi	sp,sp,-16
    80000e7a:	e406                	sd	ra,8(sp)
    80000e7c:	e022                	sd	s0,0(sp)
    80000e7e:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e80:	00001097          	auipc	ra,0x1
    80000e84:	b00080e7          	jalr	-1280(ra) # 80001980 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e88:	00008717          	auipc	a4,0x8
    80000e8c:	a8070713          	addi	a4,a4,-1408 # 80008908 <started>
  if(cpuid() == 0){
    80000e90:	c139                	beqz	a0,80000ed6 <main+0x5e>
    while(started == 0)
    80000e92:	431c                	lw	a5,0(a4)
    80000e94:	2781                	sext.w	a5,a5
    80000e96:	dff5                	beqz	a5,80000e92 <main+0x1a>
      ;
    __sync_synchronize();
    80000e98:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e9c:	00001097          	auipc	ra,0x1
    80000ea0:	ae4080e7          	jalr	-1308(ra) # 80001980 <cpuid>
    80000ea4:	85aa                	mv	a1,a0
    80000ea6:	00007517          	auipc	a0,0x7
    80000eaa:	21250513          	addi	a0,a0,530 # 800080b8 <digits+0x78>
    80000eae:	fffff097          	auipc	ra,0xfffff
    80000eb2:	6dc080e7          	jalr	1756(ra) # 8000058a <printf>
    kvminithart();    // turn on paging
    80000eb6:	00000097          	auipc	ra,0x0
    80000eba:	0d8080e7          	jalr	216(ra) # 80000f8e <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ebe:	00001097          	auipc	ra,0x1
    80000ec2:	798080e7          	jalr	1944(ra) # 80002656 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec6:	00005097          	auipc	ra,0x5
    80000eca:	d8a080e7          	jalr	-630(ra) # 80005c50 <plicinithart>
  }

  scheduler();        
    80000ece:	00001097          	auipc	ra,0x1
    80000ed2:	fd4080e7          	jalr	-44(ra) # 80001ea2 <scheduler>
    consoleinit();
    80000ed6:	fffff097          	auipc	ra,0xfffff
    80000eda:	57a080e7          	jalr	1402(ra) # 80000450 <consoleinit>
    printfinit();
    80000ede:	00000097          	auipc	ra,0x0
    80000ee2:	88c080e7          	jalr	-1908(ra) # 8000076a <printfinit>
    printf("\n");
    80000ee6:	00007517          	auipc	a0,0x7
    80000eea:	63a50513          	addi	a0,a0,1594 # 80008520 <syscalls+0xd0>
    80000eee:	fffff097          	auipc	ra,0xfffff
    80000ef2:	69c080e7          	jalr	1692(ra) # 8000058a <printf>
    printf("xv6 kernel is booting\n");
    80000ef6:	00007517          	auipc	a0,0x7
    80000efa:	1aa50513          	addi	a0,a0,426 # 800080a0 <digits+0x60>
    80000efe:	fffff097          	auipc	ra,0xfffff
    80000f02:	68c080e7          	jalr	1676(ra) # 8000058a <printf>
    printf("\n");
    80000f06:	00007517          	auipc	a0,0x7
    80000f0a:	61a50513          	addi	a0,a0,1562 # 80008520 <syscalls+0xd0>
    80000f0e:	fffff097          	auipc	ra,0xfffff
    80000f12:	67c080e7          	jalr	1660(ra) # 8000058a <printf>
    kinit();         // physical page allocator
    80000f16:	00000097          	auipc	ra,0x0
    80000f1a:	b94080e7          	jalr	-1132(ra) # 80000aaa <kinit>
    kvminit();       // create kernel page table
    80000f1e:	00000097          	auipc	ra,0x0
    80000f22:	326080e7          	jalr	806(ra) # 80001244 <kvminit>
    kvminithart();   // turn on paging
    80000f26:	00000097          	auipc	ra,0x0
    80000f2a:	068080e7          	jalr	104(ra) # 80000f8e <kvminithart>
    procinit();      // process table
    80000f2e:	00001097          	auipc	ra,0x1
    80000f32:	99e080e7          	jalr	-1634(ra) # 800018cc <procinit>
    trapinit();      // trap vectors
    80000f36:	00001097          	auipc	ra,0x1
    80000f3a:	6f8080e7          	jalr	1784(ra) # 8000262e <trapinit>
    trapinithart();  // install kernel trap vector
    80000f3e:	00001097          	auipc	ra,0x1
    80000f42:	718080e7          	jalr	1816(ra) # 80002656 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f46:	00005097          	auipc	ra,0x5
    80000f4a:	cf4080e7          	jalr	-780(ra) # 80005c3a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f4e:	00005097          	auipc	ra,0x5
    80000f52:	d02080e7          	jalr	-766(ra) # 80005c50 <plicinithart>
    binit();         // buffer cache
    80000f56:	00002097          	auipc	ra,0x2
    80000f5a:	e96080e7          	jalr	-362(ra) # 80002dec <binit>
    iinit();         // inode table
    80000f5e:	00002097          	auipc	ra,0x2
    80000f62:	536080e7          	jalr	1334(ra) # 80003494 <iinit>
    fileinit();      // file table
    80000f66:	00003097          	auipc	ra,0x3
    80000f6a:	4dc080e7          	jalr	1244(ra) # 80004442 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f6e:	00005097          	auipc	ra,0x5
    80000f72:	dea080e7          	jalr	-534(ra) # 80005d58 <virtio_disk_init>
    userinit();      // first user process
    80000f76:	00001097          	auipc	ra,0x1
    80000f7a:	d0e080e7          	jalr	-754(ra) # 80001c84 <userinit>
    __sync_synchronize();
    80000f7e:	0ff0000f          	fence
    started = 1;
    80000f82:	4785                	li	a5,1
    80000f84:	00008717          	auipc	a4,0x8
    80000f88:	98f72223          	sw	a5,-1660(a4) # 80008908 <started>
    80000f8c:	b789                	j	80000ece <main+0x56>

0000000080000f8e <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f8e:	1141                	addi	sp,sp,-16
    80000f90:	e422                	sd	s0,8(sp)
    80000f92:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f94:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f98:	00008797          	auipc	a5,0x8
    80000f9c:	9787b783          	ld	a5,-1672(a5) # 80008910 <kernel_pagetable>
    80000fa0:	83b1                	srli	a5,a5,0xc
    80000fa2:	577d                	li	a4,-1
    80000fa4:	177e                	slli	a4,a4,0x3f
    80000fa6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fa8:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000fac:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000fb0:	6422                	ld	s0,8(sp)
    80000fb2:	0141                	addi	sp,sp,16
    80000fb4:	8082                	ret

0000000080000fb6 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fb6:	7139                	addi	sp,sp,-64
    80000fb8:	fc06                	sd	ra,56(sp)
    80000fba:	f822                	sd	s0,48(sp)
    80000fbc:	f426                	sd	s1,40(sp)
    80000fbe:	f04a                	sd	s2,32(sp)
    80000fc0:	ec4e                	sd	s3,24(sp)
    80000fc2:	e852                	sd	s4,16(sp)
    80000fc4:	e456                	sd	s5,8(sp)
    80000fc6:	e05a                	sd	s6,0(sp)
    80000fc8:	0080                	addi	s0,sp,64
    80000fca:	84aa                	mv	s1,a0
    80000fcc:	89ae                	mv	s3,a1
    80000fce:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fd0:	57fd                	li	a5,-1
    80000fd2:	83e9                	srli	a5,a5,0x1a
    80000fd4:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fd6:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fd8:	04b7f263          	bgeu	a5,a1,8000101c <walk+0x66>
    panic("walk");
    80000fdc:	00007517          	auipc	a0,0x7
    80000fe0:	0f450513          	addi	a0,a0,244 # 800080d0 <digits+0x90>
    80000fe4:	fffff097          	auipc	ra,0xfffff
    80000fe8:	55c080e7          	jalr	1372(ra) # 80000540 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000fec:	060a8663          	beqz	s5,80001058 <walk+0xa2>
    80000ff0:	00000097          	auipc	ra,0x0
    80000ff4:	af6080e7          	jalr	-1290(ra) # 80000ae6 <kalloc>
    80000ff8:	84aa                	mv	s1,a0
    80000ffa:	c529                	beqz	a0,80001044 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000ffc:	6605                	lui	a2,0x1
    80000ffe:	4581                	li	a1,0
    80001000:	00000097          	auipc	ra,0x0
    80001004:	cd2080e7          	jalr	-814(ra) # 80000cd2 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001008:	00c4d793          	srli	a5,s1,0xc
    8000100c:	07aa                	slli	a5,a5,0xa
    8000100e:	0017e793          	ori	a5,a5,1
    80001012:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001016:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdd057>
    80001018:	036a0063          	beq	s4,s6,80001038 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000101c:	0149d933          	srl	s2,s3,s4
    80001020:	1ff97913          	andi	s2,s2,511
    80001024:	090e                	slli	s2,s2,0x3
    80001026:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001028:	00093483          	ld	s1,0(s2)
    8000102c:	0014f793          	andi	a5,s1,1
    80001030:	dfd5                	beqz	a5,80000fec <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001032:	80a9                	srli	s1,s1,0xa
    80001034:	04b2                	slli	s1,s1,0xc
    80001036:	b7c5                	j	80001016 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001038:	00c9d513          	srli	a0,s3,0xc
    8000103c:	1ff57513          	andi	a0,a0,511
    80001040:	050e                	slli	a0,a0,0x3
    80001042:	9526                	add	a0,a0,s1
}
    80001044:	70e2                	ld	ra,56(sp)
    80001046:	7442                	ld	s0,48(sp)
    80001048:	74a2                	ld	s1,40(sp)
    8000104a:	7902                	ld	s2,32(sp)
    8000104c:	69e2                	ld	s3,24(sp)
    8000104e:	6a42                	ld	s4,16(sp)
    80001050:	6aa2                	ld	s5,8(sp)
    80001052:	6b02                	ld	s6,0(sp)
    80001054:	6121                	addi	sp,sp,64
    80001056:	8082                	ret
        return 0;
    80001058:	4501                	li	a0,0
    8000105a:	b7ed                	j	80001044 <walk+0x8e>

000000008000105c <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000105c:	57fd                	li	a5,-1
    8000105e:	83e9                	srli	a5,a5,0x1a
    80001060:	00b7f463          	bgeu	a5,a1,80001068 <walkaddr+0xc>
    return 0;
    80001064:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001066:	8082                	ret
{
    80001068:	1141                	addi	sp,sp,-16
    8000106a:	e406                	sd	ra,8(sp)
    8000106c:	e022                	sd	s0,0(sp)
    8000106e:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001070:	4601                	li	a2,0
    80001072:	00000097          	auipc	ra,0x0
    80001076:	f44080e7          	jalr	-188(ra) # 80000fb6 <walk>
  if(pte == 0)
    8000107a:	c105                	beqz	a0,8000109a <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000107c:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000107e:	0117f693          	andi	a3,a5,17
    80001082:	4745                	li	a4,17
    return 0;
    80001084:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001086:	00e68663          	beq	a3,a4,80001092 <walkaddr+0x36>
}
    8000108a:	60a2                	ld	ra,8(sp)
    8000108c:	6402                	ld	s0,0(sp)
    8000108e:	0141                	addi	sp,sp,16
    80001090:	8082                	ret
  pa = PTE2PA(*pte);
    80001092:	83a9                	srli	a5,a5,0xa
    80001094:	00c79513          	slli	a0,a5,0xc
  return pa;
    80001098:	bfcd                	j	8000108a <walkaddr+0x2e>
    return 0;
    8000109a:	4501                	li	a0,0
    8000109c:	b7fd                	j	8000108a <walkaddr+0x2e>

000000008000109e <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000109e:	715d                	addi	sp,sp,-80
    800010a0:	e486                	sd	ra,72(sp)
    800010a2:	e0a2                	sd	s0,64(sp)
    800010a4:	fc26                	sd	s1,56(sp)
    800010a6:	f84a                	sd	s2,48(sp)
    800010a8:	f44e                	sd	s3,40(sp)
    800010aa:	f052                	sd	s4,32(sp)
    800010ac:	ec56                	sd	s5,24(sp)
    800010ae:	e85a                	sd	s6,16(sp)
    800010b0:	e45e                	sd	s7,8(sp)
    800010b2:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010b4:	c639                	beqz	a2,80001102 <mappages+0x64>
    800010b6:	8aaa                	mv	s5,a0
    800010b8:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010ba:	777d                	lui	a4,0xfffff
    800010bc:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800010c0:	fff58993          	addi	s3,a1,-1
    800010c4:	99b2                	add	s3,s3,a2
    800010c6:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800010ca:	893e                	mv	s2,a5
    800010cc:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010d0:	6b85                	lui	s7,0x1
    800010d2:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010d6:	4605                	li	a2,1
    800010d8:	85ca                	mv	a1,s2
    800010da:	8556                	mv	a0,s5
    800010dc:	00000097          	auipc	ra,0x0
    800010e0:	eda080e7          	jalr	-294(ra) # 80000fb6 <walk>
    800010e4:	cd1d                	beqz	a0,80001122 <mappages+0x84>
    if(*pte & PTE_V)
    800010e6:	611c                	ld	a5,0(a0)
    800010e8:	8b85                	andi	a5,a5,1
    800010ea:	e785                	bnez	a5,80001112 <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010ec:	80b1                	srli	s1,s1,0xc
    800010ee:	04aa                	slli	s1,s1,0xa
    800010f0:	0164e4b3          	or	s1,s1,s6
    800010f4:	0014e493          	ori	s1,s1,1
    800010f8:	e104                	sd	s1,0(a0)
    if(a == last)
    800010fa:	05390063          	beq	s2,s3,8000113a <mappages+0x9c>
    a += PGSIZE;
    800010fe:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001100:	bfc9                	j	800010d2 <mappages+0x34>
    panic("mappages: size");
    80001102:	00007517          	auipc	a0,0x7
    80001106:	fd650513          	addi	a0,a0,-42 # 800080d8 <digits+0x98>
    8000110a:	fffff097          	auipc	ra,0xfffff
    8000110e:	436080e7          	jalr	1078(ra) # 80000540 <panic>
      panic("mappages: remap");
    80001112:	00007517          	auipc	a0,0x7
    80001116:	fd650513          	addi	a0,a0,-42 # 800080e8 <digits+0xa8>
    8000111a:	fffff097          	auipc	ra,0xfffff
    8000111e:	426080e7          	jalr	1062(ra) # 80000540 <panic>
      return -1;
    80001122:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001124:	60a6                	ld	ra,72(sp)
    80001126:	6406                	ld	s0,64(sp)
    80001128:	74e2                	ld	s1,56(sp)
    8000112a:	7942                	ld	s2,48(sp)
    8000112c:	79a2                	ld	s3,40(sp)
    8000112e:	7a02                	ld	s4,32(sp)
    80001130:	6ae2                	ld	s5,24(sp)
    80001132:	6b42                	ld	s6,16(sp)
    80001134:	6ba2                	ld	s7,8(sp)
    80001136:	6161                	addi	sp,sp,80
    80001138:	8082                	ret
  return 0;
    8000113a:	4501                	li	a0,0
    8000113c:	b7e5                	j	80001124 <mappages+0x86>

000000008000113e <kvmmap>:
{
    8000113e:	1141                	addi	sp,sp,-16
    80001140:	e406                	sd	ra,8(sp)
    80001142:	e022                	sd	s0,0(sp)
    80001144:	0800                	addi	s0,sp,16
    80001146:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001148:	86b2                	mv	a3,a2
    8000114a:	863e                	mv	a2,a5
    8000114c:	00000097          	auipc	ra,0x0
    80001150:	f52080e7          	jalr	-174(ra) # 8000109e <mappages>
    80001154:	e509                	bnez	a0,8000115e <kvmmap+0x20>
}
    80001156:	60a2                	ld	ra,8(sp)
    80001158:	6402                	ld	s0,0(sp)
    8000115a:	0141                	addi	sp,sp,16
    8000115c:	8082                	ret
    panic("kvmmap");
    8000115e:	00007517          	auipc	a0,0x7
    80001162:	f9a50513          	addi	a0,a0,-102 # 800080f8 <digits+0xb8>
    80001166:	fffff097          	auipc	ra,0xfffff
    8000116a:	3da080e7          	jalr	986(ra) # 80000540 <panic>

000000008000116e <kvmmake>:
{
    8000116e:	1101                	addi	sp,sp,-32
    80001170:	ec06                	sd	ra,24(sp)
    80001172:	e822                	sd	s0,16(sp)
    80001174:	e426                	sd	s1,8(sp)
    80001176:	e04a                	sd	s2,0(sp)
    80001178:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000117a:	00000097          	auipc	ra,0x0
    8000117e:	96c080e7          	jalr	-1684(ra) # 80000ae6 <kalloc>
    80001182:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001184:	6605                	lui	a2,0x1
    80001186:	4581                	li	a1,0
    80001188:	00000097          	auipc	ra,0x0
    8000118c:	b4a080e7          	jalr	-1206(ra) # 80000cd2 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001190:	4719                	li	a4,6
    80001192:	6685                	lui	a3,0x1
    80001194:	10000637          	lui	a2,0x10000
    80001198:	100005b7          	lui	a1,0x10000
    8000119c:	8526                	mv	a0,s1
    8000119e:	00000097          	auipc	ra,0x0
    800011a2:	fa0080e7          	jalr	-96(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011a6:	4719                	li	a4,6
    800011a8:	6685                	lui	a3,0x1
    800011aa:	10001637          	lui	a2,0x10001
    800011ae:	100015b7          	lui	a1,0x10001
    800011b2:	8526                	mv	a0,s1
    800011b4:	00000097          	auipc	ra,0x0
    800011b8:	f8a080e7          	jalr	-118(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011bc:	4719                	li	a4,6
    800011be:	004006b7          	lui	a3,0x400
    800011c2:	0c000637          	lui	a2,0xc000
    800011c6:	0c0005b7          	lui	a1,0xc000
    800011ca:	8526                	mv	a0,s1
    800011cc:	00000097          	auipc	ra,0x0
    800011d0:	f72080e7          	jalr	-142(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011d4:	00007917          	auipc	s2,0x7
    800011d8:	e2c90913          	addi	s2,s2,-468 # 80008000 <etext>
    800011dc:	4729                	li	a4,10
    800011de:	80007697          	auipc	a3,0x80007
    800011e2:	e2268693          	addi	a3,a3,-478 # 8000 <_entry-0x7fff8000>
    800011e6:	4605                	li	a2,1
    800011e8:	067e                	slli	a2,a2,0x1f
    800011ea:	85b2                	mv	a1,a2
    800011ec:	8526                	mv	a0,s1
    800011ee:	00000097          	auipc	ra,0x0
    800011f2:	f50080e7          	jalr	-176(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011f6:	4719                	li	a4,6
    800011f8:	46c5                	li	a3,17
    800011fa:	06ee                	slli	a3,a3,0x1b
    800011fc:	412686b3          	sub	a3,a3,s2
    80001200:	864a                	mv	a2,s2
    80001202:	85ca                	mv	a1,s2
    80001204:	8526                	mv	a0,s1
    80001206:	00000097          	auipc	ra,0x0
    8000120a:	f38080e7          	jalr	-200(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000120e:	4729                	li	a4,10
    80001210:	6685                	lui	a3,0x1
    80001212:	00006617          	auipc	a2,0x6
    80001216:	dee60613          	addi	a2,a2,-530 # 80007000 <_trampoline>
    8000121a:	040005b7          	lui	a1,0x4000
    8000121e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001220:	05b2                	slli	a1,a1,0xc
    80001222:	8526                	mv	a0,s1
    80001224:	00000097          	auipc	ra,0x0
    80001228:	f1a080e7          	jalr	-230(ra) # 8000113e <kvmmap>
  proc_mapstacks(kpgtbl);
    8000122c:	8526                	mv	a0,s1
    8000122e:	00000097          	auipc	ra,0x0
    80001232:	608080e7          	jalr	1544(ra) # 80001836 <proc_mapstacks>
}
    80001236:	8526                	mv	a0,s1
    80001238:	60e2                	ld	ra,24(sp)
    8000123a:	6442                	ld	s0,16(sp)
    8000123c:	64a2                	ld	s1,8(sp)
    8000123e:	6902                	ld	s2,0(sp)
    80001240:	6105                	addi	sp,sp,32
    80001242:	8082                	ret

0000000080001244 <kvminit>:
{
    80001244:	1141                	addi	sp,sp,-16
    80001246:	e406                	sd	ra,8(sp)
    80001248:	e022                	sd	s0,0(sp)
    8000124a:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000124c:	00000097          	auipc	ra,0x0
    80001250:	f22080e7          	jalr	-222(ra) # 8000116e <kvmmake>
    80001254:	00007797          	auipc	a5,0x7
    80001258:	6aa7be23          	sd	a0,1724(a5) # 80008910 <kernel_pagetable>
}
    8000125c:	60a2                	ld	ra,8(sp)
    8000125e:	6402                	ld	s0,0(sp)
    80001260:	0141                	addi	sp,sp,16
    80001262:	8082                	ret

0000000080001264 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001264:	715d                	addi	sp,sp,-80
    80001266:	e486                	sd	ra,72(sp)
    80001268:	e0a2                	sd	s0,64(sp)
    8000126a:	fc26                	sd	s1,56(sp)
    8000126c:	f84a                	sd	s2,48(sp)
    8000126e:	f44e                	sd	s3,40(sp)
    80001270:	f052                	sd	s4,32(sp)
    80001272:	ec56                	sd	s5,24(sp)
    80001274:	e85a                	sd	s6,16(sp)
    80001276:	e45e                	sd	s7,8(sp)
    80001278:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000127a:	03459793          	slli	a5,a1,0x34
    8000127e:	e795                	bnez	a5,800012aa <uvmunmap+0x46>
    80001280:	8a2a                	mv	s4,a0
    80001282:	892e                	mv	s2,a1
    80001284:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001286:	0632                	slli	a2,a2,0xc
    80001288:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000128c:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000128e:	6b05                	lui	s6,0x1
    80001290:	0735e263          	bltu	a1,s3,800012f4 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001294:	60a6                	ld	ra,72(sp)
    80001296:	6406                	ld	s0,64(sp)
    80001298:	74e2                	ld	s1,56(sp)
    8000129a:	7942                	ld	s2,48(sp)
    8000129c:	79a2                	ld	s3,40(sp)
    8000129e:	7a02                	ld	s4,32(sp)
    800012a0:	6ae2                	ld	s5,24(sp)
    800012a2:	6b42                	ld	s6,16(sp)
    800012a4:	6ba2                	ld	s7,8(sp)
    800012a6:	6161                	addi	sp,sp,80
    800012a8:	8082                	ret
    panic("uvmunmap: not aligned");
    800012aa:	00007517          	auipc	a0,0x7
    800012ae:	e5650513          	addi	a0,a0,-426 # 80008100 <digits+0xc0>
    800012b2:	fffff097          	auipc	ra,0xfffff
    800012b6:	28e080e7          	jalr	654(ra) # 80000540 <panic>
      panic("uvmunmap: walk");
    800012ba:	00007517          	auipc	a0,0x7
    800012be:	e5e50513          	addi	a0,a0,-418 # 80008118 <digits+0xd8>
    800012c2:	fffff097          	auipc	ra,0xfffff
    800012c6:	27e080e7          	jalr	638(ra) # 80000540 <panic>
      panic("uvmunmap: not mapped");
    800012ca:	00007517          	auipc	a0,0x7
    800012ce:	e5e50513          	addi	a0,a0,-418 # 80008128 <digits+0xe8>
    800012d2:	fffff097          	auipc	ra,0xfffff
    800012d6:	26e080e7          	jalr	622(ra) # 80000540 <panic>
      panic("uvmunmap: not a leaf");
    800012da:	00007517          	auipc	a0,0x7
    800012de:	e6650513          	addi	a0,a0,-410 # 80008140 <digits+0x100>
    800012e2:	fffff097          	auipc	ra,0xfffff
    800012e6:	25e080e7          	jalr	606(ra) # 80000540 <panic>
    *pte = 0;
    800012ea:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012ee:	995a                	add	s2,s2,s6
    800012f0:	fb3972e3          	bgeu	s2,s3,80001294 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012f4:	4601                	li	a2,0
    800012f6:	85ca                	mv	a1,s2
    800012f8:	8552                	mv	a0,s4
    800012fa:	00000097          	auipc	ra,0x0
    800012fe:	cbc080e7          	jalr	-836(ra) # 80000fb6 <walk>
    80001302:	84aa                	mv	s1,a0
    80001304:	d95d                	beqz	a0,800012ba <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001306:	6108                	ld	a0,0(a0)
    80001308:	00157793          	andi	a5,a0,1
    8000130c:	dfdd                	beqz	a5,800012ca <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000130e:	3ff57793          	andi	a5,a0,1023
    80001312:	fd7784e3          	beq	a5,s7,800012da <uvmunmap+0x76>
    if(do_free){
    80001316:	fc0a8ae3          	beqz	s5,800012ea <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    8000131a:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    8000131c:	0532                	slli	a0,a0,0xc
    8000131e:	fffff097          	auipc	ra,0xfffff
    80001322:	6ca080e7          	jalr	1738(ra) # 800009e8 <kfree>
    80001326:	b7d1                	j	800012ea <uvmunmap+0x86>

0000000080001328 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001328:	1101                	addi	sp,sp,-32
    8000132a:	ec06                	sd	ra,24(sp)
    8000132c:	e822                	sd	s0,16(sp)
    8000132e:	e426                	sd	s1,8(sp)
    80001330:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001332:	fffff097          	auipc	ra,0xfffff
    80001336:	7b4080e7          	jalr	1972(ra) # 80000ae6 <kalloc>
    8000133a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000133c:	c519                	beqz	a0,8000134a <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000133e:	6605                	lui	a2,0x1
    80001340:	4581                	li	a1,0
    80001342:	00000097          	auipc	ra,0x0
    80001346:	990080e7          	jalr	-1648(ra) # 80000cd2 <memset>
  return pagetable;
}
    8000134a:	8526                	mv	a0,s1
    8000134c:	60e2                	ld	ra,24(sp)
    8000134e:	6442                	ld	s0,16(sp)
    80001350:	64a2                	ld	s1,8(sp)
    80001352:	6105                	addi	sp,sp,32
    80001354:	8082                	ret

0000000080001356 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80001356:	7179                	addi	sp,sp,-48
    80001358:	f406                	sd	ra,40(sp)
    8000135a:	f022                	sd	s0,32(sp)
    8000135c:	ec26                	sd	s1,24(sp)
    8000135e:	e84a                	sd	s2,16(sp)
    80001360:	e44e                	sd	s3,8(sp)
    80001362:	e052                	sd	s4,0(sp)
    80001364:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001366:	6785                	lui	a5,0x1
    80001368:	04f67863          	bgeu	a2,a5,800013b8 <uvmfirst+0x62>
    8000136c:	8a2a                	mv	s4,a0
    8000136e:	89ae                	mv	s3,a1
    80001370:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    80001372:	fffff097          	auipc	ra,0xfffff
    80001376:	774080e7          	jalr	1908(ra) # 80000ae6 <kalloc>
    8000137a:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000137c:	6605                	lui	a2,0x1
    8000137e:	4581                	li	a1,0
    80001380:	00000097          	auipc	ra,0x0
    80001384:	952080e7          	jalr	-1710(ra) # 80000cd2 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001388:	4779                	li	a4,30
    8000138a:	86ca                	mv	a3,s2
    8000138c:	6605                	lui	a2,0x1
    8000138e:	4581                	li	a1,0
    80001390:	8552                	mv	a0,s4
    80001392:	00000097          	auipc	ra,0x0
    80001396:	d0c080e7          	jalr	-756(ra) # 8000109e <mappages>
  memmove(mem, src, sz);
    8000139a:	8626                	mv	a2,s1
    8000139c:	85ce                	mv	a1,s3
    8000139e:	854a                	mv	a0,s2
    800013a0:	00000097          	auipc	ra,0x0
    800013a4:	98e080e7          	jalr	-1650(ra) # 80000d2e <memmove>
}
    800013a8:	70a2                	ld	ra,40(sp)
    800013aa:	7402                	ld	s0,32(sp)
    800013ac:	64e2                	ld	s1,24(sp)
    800013ae:	6942                	ld	s2,16(sp)
    800013b0:	69a2                	ld	s3,8(sp)
    800013b2:	6a02                	ld	s4,0(sp)
    800013b4:	6145                	addi	sp,sp,48
    800013b6:	8082                	ret
    panic("uvmfirst: more than a page");
    800013b8:	00007517          	auipc	a0,0x7
    800013bc:	da050513          	addi	a0,a0,-608 # 80008158 <digits+0x118>
    800013c0:	fffff097          	auipc	ra,0xfffff
    800013c4:	180080e7          	jalr	384(ra) # 80000540 <panic>

00000000800013c8 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013c8:	1101                	addi	sp,sp,-32
    800013ca:	ec06                	sd	ra,24(sp)
    800013cc:	e822                	sd	s0,16(sp)
    800013ce:	e426                	sd	s1,8(sp)
    800013d0:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013d2:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013d4:	00b67d63          	bgeu	a2,a1,800013ee <uvmdealloc+0x26>
    800013d8:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013da:	6785                	lui	a5,0x1
    800013dc:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800013de:	00f60733          	add	a4,a2,a5
    800013e2:	76fd                	lui	a3,0xfffff
    800013e4:	8f75                	and	a4,a4,a3
    800013e6:	97ae                	add	a5,a5,a1
    800013e8:	8ff5                	and	a5,a5,a3
    800013ea:	00f76863          	bltu	a4,a5,800013fa <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013ee:	8526                	mv	a0,s1
    800013f0:	60e2                	ld	ra,24(sp)
    800013f2:	6442                	ld	s0,16(sp)
    800013f4:	64a2                	ld	s1,8(sp)
    800013f6:	6105                	addi	sp,sp,32
    800013f8:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800013fa:	8f99                	sub	a5,a5,a4
    800013fc:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800013fe:	4685                	li	a3,1
    80001400:	0007861b          	sext.w	a2,a5
    80001404:	85ba                	mv	a1,a4
    80001406:	00000097          	auipc	ra,0x0
    8000140a:	e5e080e7          	jalr	-418(ra) # 80001264 <uvmunmap>
    8000140e:	b7c5                	j	800013ee <uvmdealloc+0x26>

0000000080001410 <uvmalloc>:
  if(newsz < oldsz)
    80001410:	0ab66563          	bltu	a2,a1,800014ba <uvmalloc+0xaa>
{
    80001414:	7139                	addi	sp,sp,-64
    80001416:	fc06                	sd	ra,56(sp)
    80001418:	f822                	sd	s0,48(sp)
    8000141a:	f426                	sd	s1,40(sp)
    8000141c:	f04a                	sd	s2,32(sp)
    8000141e:	ec4e                	sd	s3,24(sp)
    80001420:	e852                	sd	s4,16(sp)
    80001422:	e456                	sd	s5,8(sp)
    80001424:	e05a                	sd	s6,0(sp)
    80001426:	0080                	addi	s0,sp,64
    80001428:	8aaa                	mv	s5,a0
    8000142a:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000142c:	6785                	lui	a5,0x1
    8000142e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001430:	95be                	add	a1,a1,a5
    80001432:	77fd                	lui	a5,0xfffff
    80001434:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001438:	08c9f363          	bgeu	s3,a2,800014be <uvmalloc+0xae>
    8000143c:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000143e:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001442:	fffff097          	auipc	ra,0xfffff
    80001446:	6a4080e7          	jalr	1700(ra) # 80000ae6 <kalloc>
    8000144a:	84aa                	mv	s1,a0
    if(mem == 0){
    8000144c:	c51d                	beqz	a0,8000147a <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    8000144e:	6605                	lui	a2,0x1
    80001450:	4581                	li	a1,0
    80001452:	00000097          	auipc	ra,0x0
    80001456:	880080e7          	jalr	-1920(ra) # 80000cd2 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000145a:	875a                	mv	a4,s6
    8000145c:	86a6                	mv	a3,s1
    8000145e:	6605                	lui	a2,0x1
    80001460:	85ca                	mv	a1,s2
    80001462:	8556                	mv	a0,s5
    80001464:	00000097          	auipc	ra,0x0
    80001468:	c3a080e7          	jalr	-966(ra) # 8000109e <mappages>
    8000146c:	e90d                	bnez	a0,8000149e <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000146e:	6785                	lui	a5,0x1
    80001470:	993e                	add	s2,s2,a5
    80001472:	fd4968e3          	bltu	s2,s4,80001442 <uvmalloc+0x32>
  return newsz;
    80001476:	8552                	mv	a0,s4
    80001478:	a809                	j	8000148a <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    8000147a:	864e                	mv	a2,s3
    8000147c:	85ca                	mv	a1,s2
    8000147e:	8556                	mv	a0,s5
    80001480:	00000097          	auipc	ra,0x0
    80001484:	f48080e7          	jalr	-184(ra) # 800013c8 <uvmdealloc>
      return 0;
    80001488:	4501                	li	a0,0
}
    8000148a:	70e2                	ld	ra,56(sp)
    8000148c:	7442                	ld	s0,48(sp)
    8000148e:	74a2                	ld	s1,40(sp)
    80001490:	7902                	ld	s2,32(sp)
    80001492:	69e2                	ld	s3,24(sp)
    80001494:	6a42                	ld	s4,16(sp)
    80001496:	6aa2                	ld	s5,8(sp)
    80001498:	6b02                	ld	s6,0(sp)
    8000149a:	6121                	addi	sp,sp,64
    8000149c:	8082                	ret
      kfree(mem);
    8000149e:	8526                	mv	a0,s1
    800014a0:	fffff097          	auipc	ra,0xfffff
    800014a4:	548080e7          	jalr	1352(ra) # 800009e8 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014a8:	864e                	mv	a2,s3
    800014aa:	85ca                	mv	a1,s2
    800014ac:	8556                	mv	a0,s5
    800014ae:	00000097          	auipc	ra,0x0
    800014b2:	f1a080e7          	jalr	-230(ra) # 800013c8 <uvmdealloc>
      return 0;
    800014b6:	4501                	li	a0,0
    800014b8:	bfc9                	j	8000148a <uvmalloc+0x7a>
    return oldsz;
    800014ba:	852e                	mv	a0,a1
}
    800014bc:	8082                	ret
  return newsz;
    800014be:	8532                	mv	a0,a2
    800014c0:	b7e9                	j	8000148a <uvmalloc+0x7a>

00000000800014c2 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014c2:	7179                	addi	sp,sp,-48
    800014c4:	f406                	sd	ra,40(sp)
    800014c6:	f022                	sd	s0,32(sp)
    800014c8:	ec26                	sd	s1,24(sp)
    800014ca:	e84a                	sd	s2,16(sp)
    800014cc:	e44e                	sd	s3,8(sp)
    800014ce:	e052                	sd	s4,0(sp)
    800014d0:	1800                	addi	s0,sp,48
    800014d2:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014d4:	84aa                	mv	s1,a0
    800014d6:	6905                	lui	s2,0x1
    800014d8:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014da:	4985                	li	s3,1
    800014dc:	a829                	j	800014f6 <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014de:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800014e0:	00c79513          	slli	a0,a5,0xc
    800014e4:	00000097          	auipc	ra,0x0
    800014e8:	fde080e7          	jalr	-34(ra) # 800014c2 <freewalk>
      pagetable[i] = 0;
    800014ec:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014f0:	04a1                	addi	s1,s1,8
    800014f2:	03248163          	beq	s1,s2,80001514 <freewalk+0x52>
    pte_t pte = pagetable[i];
    800014f6:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014f8:	00f7f713          	andi	a4,a5,15
    800014fc:	ff3701e3          	beq	a4,s3,800014de <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001500:	8b85                	andi	a5,a5,1
    80001502:	d7fd                	beqz	a5,800014f0 <freewalk+0x2e>
      panic("freewalk: leaf");
    80001504:	00007517          	auipc	a0,0x7
    80001508:	c7450513          	addi	a0,a0,-908 # 80008178 <digits+0x138>
    8000150c:	fffff097          	auipc	ra,0xfffff
    80001510:	034080e7          	jalr	52(ra) # 80000540 <panic>
    }
  }
  kfree((void*)pagetable);
    80001514:	8552                	mv	a0,s4
    80001516:	fffff097          	auipc	ra,0xfffff
    8000151a:	4d2080e7          	jalr	1234(ra) # 800009e8 <kfree>
}
    8000151e:	70a2                	ld	ra,40(sp)
    80001520:	7402                	ld	s0,32(sp)
    80001522:	64e2                	ld	s1,24(sp)
    80001524:	6942                	ld	s2,16(sp)
    80001526:	69a2                	ld	s3,8(sp)
    80001528:	6a02                	ld	s4,0(sp)
    8000152a:	6145                	addi	sp,sp,48
    8000152c:	8082                	ret

000000008000152e <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000152e:	1101                	addi	sp,sp,-32
    80001530:	ec06                	sd	ra,24(sp)
    80001532:	e822                	sd	s0,16(sp)
    80001534:	e426                	sd	s1,8(sp)
    80001536:	1000                	addi	s0,sp,32
    80001538:	84aa                	mv	s1,a0
  if(sz > 0)
    8000153a:	e999                	bnez	a1,80001550 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000153c:	8526                	mv	a0,s1
    8000153e:	00000097          	auipc	ra,0x0
    80001542:	f84080e7          	jalr	-124(ra) # 800014c2 <freewalk>
}
    80001546:	60e2                	ld	ra,24(sp)
    80001548:	6442                	ld	s0,16(sp)
    8000154a:	64a2                	ld	s1,8(sp)
    8000154c:	6105                	addi	sp,sp,32
    8000154e:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001550:	6785                	lui	a5,0x1
    80001552:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001554:	95be                	add	a1,a1,a5
    80001556:	4685                	li	a3,1
    80001558:	00c5d613          	srli	a2,a1,0xc
    8000155c:	4581                	li	a1,0
    8000155e:	00000097          	auipc	ra,0x0
    80001562:	d06080e7          	jalr	-762(ra) # 80001264 <uvmunmap>
    80001566:	bfd9                	j	8000153c <uvmfree+0xe>

0000000080001568 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001568:	c679                	beqz	a2,80001636 <uvmcopy+0xce>
{
    8000156a:	715d                	addi	sp,sp,-80
    8000156c:	e486                	sd	ra,72(sp)
    8000156e:	e0a2                	sd	s0,64(sp)
    80001570:	fc26                	sd	s1,56(sp)
    80001572:	f84a                	sd	s2,48(sp)
    80001574:	f44e                	sd	s3,40(sp)
    80001576:	f052                	sd	s4,32(sp)
    80001578:	ec56                	sd	s5,24(sp)
    8000157a:	e85a                	sd	s6,16(sp)
    8000157c:	e45e                	sd	s7,8(sp)
    8000157e:	0880                	addi	s0,sp,80
    80001580:	8b2a                	mv	s6,a0
    80001582:	8aae                	mv	s5,a1
    80001584:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001586:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001588:	4601                	li	a2,0
    8000158a:	85ce                	mv	a1,s3
    8000158c:	855a                	mv	a0,s6
    8000158e:	00000097          	auipc	ra,0x0
    80001592:	a28080e7          	jalr	-1496(ra) # 80000fb6 <walk>
    80001596:	c531                	beqz	a0,800015e2 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001598:	6118                	ld	a4,0(a0)
    8000159a:	00177793          	andi	a5,a4,1
    8000159e:	cbb1                	beqz	a5,800015f2 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800015a0:	00a75593          	srli	a1,a4,0xa
    800015a4:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015a8:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015ac:	fffff097          	auipc	ra,0xfffff
    800015b0:	53a080e7          	jalr	1338(ra) # 80000ae6 <kalloc>
    800015b4:	892a                	mv	s2,a0
    800015b6:	c939                	beqz	a0,8000160c <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015b8:	6605                	lui	a2,0x1
    800015ba:	85de                	mv	a1,s7
    800015bc:	fffff097          	auipc	ra,0xfffff
    800015c0:	772080e7          	jalr	1906(ra) # 80000d2e <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015c4:	8726                	mv	a4,s1
    800015c6:	86ca                	mv	a3,s2
    800015c8:	6605                	lui	a2,0x1
    800015ca:	85ce                	mv	a1,s3
    800015cc:	8556                	mv	a0,s5
    800015ce:	00000097          	auipc	ra,0x0
    800015d2:	ad0080e7          	jalr	-1328(ra) # 8000109e <mappages>
    800015d6:	e515                	bnez	a0,80001602 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015d8:	6785                	lui	a5,0x1
    800015da:	99be                	add	s3,s3,a5
    800015dc:	fb49e6e3          	bltu	s3,s4,80001588 <uvmcopy+0x20>
    800015e0:	a081                	j	80001620 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015e2:	00007517          	auipc	a0,0x7
    800015e6:	ba650513          	addi	a0,a0,-1114 # 80008188 <digits+0x148>
    800015ea:	fffff097          	auipc	ra,0xfffff
    800015ee:	f56080e7          	jalr	-170(ra) # 80000540 <panic>
      panic("uvmcopy: page not present");
    800015f2:	00007517          	auipc	a0,0x7
    800015f6:	bb650513          	addi	a0,a0,-1098 # 800081a8 <digits+0x168>
    800015fa:	fffff097          	auipc	ra,0xfffff
    800015fe:	f46080e7          	jalr	-186(ra) # 80000540 <panic>
      kfree(mem);
    80001602:	854a                	mv	a0,s2
    80001604:	fffff097          	auipc	ra,0xfffff
    80001608:	3e4080e7          	jalr	996(ra) # 800009e8 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    8000160c:	4685                	li	a3,1
    8000160e:	00c9d613          	srli	a2,s3,0xc
    80001612:	4581                	li	a1,0
    80001614:	8556                	mv	a0,s5
    80001616:	00000097          	auipc	ra,0x0
    8000161a:	c4e080e7          	jalr	-946(ra) # 80001264 <uvmunmap>
  return -1;
    8000161e:	557d                	li	a0,-1
}
    80001620:	60a6                	ld	ra,72(sp)
    80001622:	6406                	ld	s0,64(sp)
    80001624:	74e2                	ld	s1,56(sp)
    80001626:	7942                	ld	s2,48(sp)
    80001628:	79a2                	ld	s3,40(sp)
    8000162a:	7a02                	ld	s4,32(sp)
    8000162c:	6ae2                	ld	s5,24(sp)
    8000162e:	6b42                	ld	s6,16(sp)
    80001630:	6ba2                	ld	s7,8(sp)
    80001632:	6161                	addi	sp,sp,80
    80001634:	8082                	ret
  return 0;
    80001636:	4501                	li	a0,0
}
    80001638:	8082                	ret

000000008000163a <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000163a:	1141                	addi	sp,sp,-16
    8000163c:	e406                	sd	ra,8(sp)
    8000163e:	e022                	sd	s0,0(sp)
    80001640:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001642:	4601                	li	a2,0
    80001644:	00000097          	auipc	ra,0x0
    80001648:	972080e7          	jalr	-1678(ra) # 80000fb6 <walk>
  if(pte == 0)
    8000164c:	c901                	beqz	a0,8000165c <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000164e:	611c                	ld	a5,0(a0)
    80001650:	9bbd                	andi	a5,a5,-17
    80001652:	e11c                	sd	a5,0(a0)
}
    80001654:	60a2                	ld	ra,8(sp)
    80001656:	6402                	ld	s0,0(sp)
    80001658:	0141                	addi	sp,sp,16
    8000165a:	8082                	ret
    panic("uvmclear");
    8000165c:	00007517          	auipc	a0,0x7
    80001660:	b6c50513          	addi	a0,a0,-1172 # 800081c8 <digits+0x188>
    80001664:	fffff097          	auipc	ra,0xfffff
    80001668:	edc080e7          	jalr	-292(ra) # 80000540 <panic>

000000008000166c <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000166c:	c6bd                	beqz	a3,800016da <copyout+0x6e>
{
    8000166e:	715d                	addi	sp,sp,-80
    80001670:	e486                	sd	ra,72(sp)
    80001672:	e0a2                	sd	s0,64(sp)
    80001674:	fc26                	sd	s1,56(sp)
    80001676:	f84a                	sd	s2,48(sp)
    80001678:	f44e                	sd	s3,40(sp)
    8000167a:	f052                	sd	s4,32(sp)
    8000167c:	ec56                	sd	s5,24(sp)
    8000167e:	e85a                	sd	s6,16(sp)
    80001680:	e45e                	sd	s7,8(sp)
    80001682:	e062                	sd	s8,0(sp)
    80001684:	0880                	addi	s0,sp,80
    80001686:	8b2a                	mv	s6,a0
    80001688:	8c2e                	mv	s8,a1
    8000168a:	8a32                	mv	s4,a2
    8000168c:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000168e:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001690:	6a85                	lui	s5,0x1
    80001692:	a015                	j	800016b6 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001694:	9562                	add	a0,a0,s8
    80001696:	0004861b          	sext.w	a2,s1
    8000169a:	85d2                	mv	a1,s4
    8000169c:	41250533          	sub	a0,a0,s2
    800016a0:	fffff097          	auipc	ra,0xfffff
    800016a4:	68e080e7          	jalr	1678(ra) # 80000d2e <memmove>

    len -= n;
    800016a8:	409989b3          	sub	s3,s3,s1
    src += n;
    800016ac:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016ae:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016b2:	02098263          	beqz	s3,800016d6 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016b6:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016ba:	85ca                	mv	a1,s2
    800016bc:	855a                	mv	a0,s6
    800016be:	00000097          	auipc	ra,0x0
    800016c2:	99e080e7          	jalr	-1634(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    800016c6:	cd01                	beqz	a0,800016de <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016c8:	418904b3          	sub	s1,s2,s8
    800016cc:	94d6                	add	s1,s1,s5
    800016ce:	fc99f3e3          	bgeu	s3,s1,80001694 <copyout+0x28>
    800016d2:	84ce                	mv	s1,s3
    800016d4:	b7c1                	j	80001694 <copyout+0x28>
  }
  return 0;
    800016d6:	4501                	li	a0,0
    800016d8:	a021                	j	800016e0 <copyout+0x74>
    800016da:	4501                	li	a0,0
}
    800016dc:	8082                	ret
      return -1;
    800016de:	557d                	li	a0,-1
}
    800016e0:	60a6                	ld	ra,72(sp)
    800016e2:	6406                	ld	s0,64(sp)
    800016e4:	74e2                	ld	s1,56(sp)
    800016e6:	7942                	ld	s2,48(sp)
    800016e8:	79a2                	ld	s3,40(sp)
    800016ea:	7a02                	ld	s4,32(sp)
    800016ec:	6ae2                	ld	s5,24(sp)
    800016ee:	6b42                	ld	s6,16(sp)
    800016f0:	6ba2                	ld	s7,8(sp)
    800016f2:	6c02                	ld	s8,0(sp)
    800016f4:	6161                	addi	sp,sp,80
    800016f6:	8082                	ret

00000000800016f8 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016f8:	caa5                	beqz	a3,80001768 <copyin+0x70>
{
    800016fa:	715d                	addi	sp,sp,-80
    800016fc:	e486                	sd	ra,72(sp)
    800016fe:	e0a2                	sd	s0,64(sp)
    80001700:	fc26                	sd	s1,56(sp)
    80001702:	f84a                	sd	s2,48(sp)
    80001704:	f44e                	sd	s3,40(sp)
    80001706:	f052                	sd	s4,32(sp)
    80001708:	ec56                	sd	s5,24(sp)
    8000170a:	e85a                	sd	s6,16(sp)
    8000170c:	e45e                	sd	s7,8(sp)
    8000170e:	e062                	sd	s8,0(sp)
    80001710:	0880                	addi	s0,sp,80
    80001712:	8b2a                	mv	s6,a0
    80001714:	8a2e                	mv	s4,a1
    80001716:	8c32                	mv	s8,a2
    80001718:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    8000171a:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000171c:	6a85                	lui	s5,0x1
    8000171e:	a01d                	j	80001744 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001720:	018505b3          	add	a1,a0,s8
    80001724:	0004861b          	sext.w	a2,s1
    80001728:	412585b3          	sub	a1,a1,s2
    8000172c:	8552                	mv	a0,s4
    8000172e:	fffff097          	auipc	ra,0xfffff
    80001732:	600080e7          	jalr	1536(ra) # 80000d2e <memmove>

    len -= n;
    80001736:	409989b3          	sub	s3,s3,s1
    dst += n;
    8000173a:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    8000173c:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001740:	02098263          	beqz	s3,80001764 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001744:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001748:	85ca                	mv	a1,s2
    8000174a:	855a                	mv	a0,s6
    8000174c:	00000097          	auipc	ra,0x0
    80001750:	910080e7          	jalr	-1776(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    80001754:	cd01                	beqz	a0,8000176c <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001756:	418904b3          	sub	s1,s2,s8
    8000175a:	94d6                	add	s1,s1,s5
    8000175c:	fc99f2e3          	bgeu	s3,s1,80001720 <copyin+0x28>
    80001760:	84ce                	mv	s1,s3
    80001762:	bf7d                	j	80001720 <copyin+0x28>
  }
  return 0;
    80001764:	4501                	li	a0,0
    80001766:	a021                	j	8000176e <copyin+0x76>
    80001768:	4501                	li	a0,0
}
    8000176a:	8082                	ret
      return -1;
    8000176c:	557d                	li	a0,-1
}
    8000176e:	60a6                	ld	ra,72(sp)
    80001770:	6406                	ld	s0,64(sp)
    80001772:	74e2                	ld	s1,56(sp)
    80001774:	7942                	ld	s2,48(sp)
    80001776:	79a2                	ld	s3,40(sp)
    80001778:	7a02                	ld	s4,32(sp)
    8000177a:	6ae2                	ld	s5,24(sp)
    8000177c:	6b42                	ld	s6,16(sp)
    8000177e:	6ba2                	ld	s7,8(sp)
    80001780:	6c02                	ld	s8,0(sp)
    80001782:	6161                	addi	sp,sp,80
    80001784:	8082                	ret

0000000080001786 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001786:	c2dd                	beqz	a3,8000182c <copyinstr+0xa6>
{
    80001788:	715d                	addi	sp,sp,-80
    8000178a:	e486                	sd	ra,72(sp)
    8000178c:	e0a2                	sd	s0,64(sp)
    8000178e:	fc26                	sd	s1,56(sp)
    80001790:	f84a                	sd	s2,48(sp)
    80001792:	f44e                	sd	s3,40(sp)
    80001794:	f052                	sd	s4,32(sp)
    80001796:	ec56                	sd	s5,24(sp)
    80001798:	e85a                	sd	s6,16(sp)
    8000179a:	e45e                	sd	s7,8(sp)
    8000179c:	0880                	addi	s0,sp,80
    8000179e:	8a2a                	mv	s4,a0
    800017a0:	8b2e                	mv	s6,a1
    800017a2:	8bb2                	mv	s7,a2
    800017a4:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017a6:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017a8:	6985                	lui	s3,0x1
    800017aa:	a02d                	j	800017d4 <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017ac:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017b0:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017b2:	37fd                	addiw	a5,a5,-1
    800017b4:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017b8:	60a6                	ld	ra,72(sp)
    800017ba:	6406                	ld	s0,64(sp)
    800017bc:	74e2                	ld	s1,56(sp)
    800017be:	7942                	ld	s2,48(sp)
    800017c0:	79a2                	ld	s3,40(sp)
    800017c2:	7a02                	ld	s4,32(sp)
    800017c4:	6ae2                	ld	s5,24(sp)
    800017c6:	6b42                	ld	s6,16(sp)
    800017c8:	6ba2                	ld	s7,8(sp)
    800017ca:	6161                	addi	sp,sp,80
    800017cc:	8082                	ret
    srcva = va0 + PGSIZE;
    800017ce:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017d2:	c8a9                	beqz	s1,80001824 <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    800017d4:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017d8:	85ca                	mv	a1,s2
    800017da:	8552                	mv	a0,s4
    800017dc:	00000097          	auipc	ra,0x0
    800017e0:	880080e7          	jalr	-1920(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    800017e4:	c131                	beqz	a0,80001828 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    800017e6:	417906b3          	sub	a3,s2,s7
    800017ea:	96ce                	add	a3,a3,s3
    800017ec:	00d4f363          	bgeu	s1,a3,800017f2 <copyinstr+0x6c>
    800017f0:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017f2:	955e                	add	a0,a0,s7
    800017f4:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017f8:	daf9                	beqz	a3,800017ce <copyinstr+0x48>
    800017fa:	87da                	mv	a5,s6
      if(*p == '\0'){
    800017fc:	41650633          	sub	a2,a0,s6
    80001800:	fff48593          	addi	a1,s1,-1
    80001804:	95da                	add	a1,a1,s6
    while(n > 0){
    80001806:	96da                	add	a3,a3,s6
      if(*p == '\0'){
    80001808:	00f60733          	add	a4,a2,a5
    8000180c:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffdd060>
    80001810:	df51                	beqz	a4,800017ac <copyinstr+0x26>
        *dst = *p;
    80001812:	00e78023          	sb	a4,0(a5)
      --max;
    80001816:	40f584b3          	sub	s1,a1,a5
      dst++;
    8000181a:	0785                	addi	a5,a5,1
    while(n > 0){
    8000181c:	fed796e3          	bne	a5,a3,80001808 <copyinstr+0x82>
      dst++;
    80001820:	8b3e                	mv	s6,a5
    80001822:	b775                	j	800017ce <copyinstr+0x48>
    80001824:	4781                	li	a5,0
    80001826:	b771                	j	800017b2 <copyinstr+0x2c>
      return -1;
    80001828:	557d                	li	a0,-1
    8000182a:	b779                	j	800017b8 <copyinstr+0x32>
  int got_null = 0;
    8000182c:	4781                	li	a5,0
  if(got_null){
    8000182e:	37fd                	addiw	a5,a5,-1
    80001830:	0007851b          	sext.w	a0,a5
}
    80001834:	8082                	ret

0000000080001836 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001836:	7139                	addi	sp,sp,-64
    80001838:	fc06                	sd	ra,56(sp)
    8000183a:	f822                	sd	s0,48(sp)
    8000183c:	f426                	sd	s1,40(sp)
    8000183e:	f04a                	sd	s2,32(sp)
    80001840:	ec4e                	sd	s3,24(sp)
    80001842:	e852                	sd	s4,16(sp)
    80001844:	e456                	sd	s5,8(sp)
    80001846:	e05a                	sd	s6,0(sp)
    80001848:	0080                	addi	s0,sp,64
    8000184a:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    8000184c:	0000f497          	auipc	s1,0xf
    80001850:	77448493          	addi	s1,s1,1908 # 80010fc0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001854:	8b26                	mv	s6,s1
    80001856:	00006a97          	auipc	s5,0x6
    8000185a:	7aaa8a93          	addi	s5,s5,1962 # 80008000 <etext>
    8000185e:	04000937          	lui	s2,0x4000
    80001862:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001864:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001866:	00015a17          	auipc	s4,0x15
    8000186a:	35aa0a13          	addi	s4,s4,858 # 80016bc0 <tickslock>
    char *pa = kalloc();
    8000186e:	fffff097          	auipc	ra,0xfffff
    80001872:	278080e7          	jalr	632(ra) # 80000ae6 <kalloc>
    80001876:	862a                	mv	a2,a0
    if(pa == 0)
    80001878:	c131                	beqz	a0,800018bc <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    8000187a:	416485b3          	sub	a1,s1,s6
    8000187e:	8591                	srai	a1,a1,0x4
    80001880:	000ab783          	ld	a5,0(s5)
    80001884:	02f585b3          	mul	a1,a1,a5
    80001888:	2585                	addiw	a1,a1,1
    8000188a:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000188e:	4719                	li	a4,6
    80001890:	6685                	lui	a3,0x1
    80001892:	40b905b3          	sub	a1,s2,a1
    80001896:	854e                	mv	a0,s3
    80001898:	00000097          	auipc	ra,0x0
    8000189c:	8a6080e7          	jalr	-1882(ra) # 8000113e <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800018a0:	17048493          	addi	s1,s1,368
    800018a4:	fd4495e3          	bne	s1,s4,8000186e <proc_mapstacks+0x38>
  }
}
    800018a8:	70e2                	ld	ra,56(sp)
    800018aa:	7442                	ld	s0,48(sp)
    800018ac:	74a2                	ld	s1,40(sp)
    800018ae:	7902                	ld	s2,32(sp)
    800018b0:	69e2                	ld	s3,24(sp)
    800018b2:	6a42                	ld	s4,16(sp)
    800018b4:	6aa2                	ld	s5,8(sp)
    800018b6:	6b02                	ld	s6,0(sp)
    800018b8:	6121                	addi	sp,sp,64
    800018ba:	8082                	ret
      panic("kalloc");
    800018bc:	00007517          	auipc	a0,0x7
    800018c0:	91c50513          	addi	a0,a0,-1764 # 800081d8 <digits+0x198>
    800018c4:	fffff097          	auipc	ra,0xfffff
    800018c8:	c7c080e7          	jalr	-900(ra) # 80000540 <panic>

00000000800018cc <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800018cc:	7139                	addi	sp,sp,-64
    800018ce:	fc06                	sd	ra,56(sp)
    800018d0:	f822                	sd	s0,48(sp)
    800018d2:	f426                	sd	s1,40(sp)
    800018d4:	f04a                	sd	s2,32(sp)
    800018d6:	ec4e                	sd	s3,24(sp)
    800018d8:	e852                	sd	s4,16(sp)
    800018da:	e456                	sd	s5,8(sp)
    800018dc:	e05a                	sd	s6,0(sp)
    800018de:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    800018e0:	00007597          	auipc	a1,0x7
    800018e4:	90058593          	addi	a1,a1,-1792 # 800081e0 <digits+0x1a0>
    800018e8:	0000f517          	auipc	a0,0xf
    800018ec:	2a850513          	addi	a0,a0,680 # 80010b90 <pid_lock>
    800018f0:	fffff097          	auipc	ra,0xfffff
    800018f4:	256080e7          	jalr	598(ra) # 80000b46 <initlock>
  initlock(&wait_lock, "wait_lock");
    800018f8:	00007597          	auipc	a1,0x7
    800018fc:	8f058593          	addi	a1,a1,-1808 # 800081e8 <digits+0x1a8>
    80001900:	0000f517          	auipc	a0,0xf
    80001904:	2a850513          	addi	a0,a0,680 # 80010ba8 <wait_lock>
    80001908:	fffff097          	auipc	ra,0xfffff
    8000190c:	23e080e7          	jalr	574(ra) # 80000b46 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001910:	0000f497          	auipc	s1,0xf
    80001914:	6b048493          	addi	s1,s1,1712 # 80010fc0 <proc>
      initlock(&p->lock, "proc");
    80001918:	00007b17          	auipc	s6,0x7
    8000191c:	8e0b0b13          	addi	s6,s6,-1824 # 800081f8 <digits+0x1b8>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001920:	8aa6                	mv	s5,s1
    80001922:	00006a17          	auipc	s4,0x6
    80001926:	6dea0a13          	addi	s4,s4,1758 # 80008000 <etext>
    8000192a:	04000937          	lui	s2,0x4000
    8000192e:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001930:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001932:	00015997          	auipc	s3,0x15
    80001936:	28e98993          	addi	s3,s3,654 # 80016bc0 <tickslock>
      initlock(&p->lock, "proc");
    8000193a:	85da                	mv	a1,s6
    8000193c:	8526                	mv	a0,s1
    8000193e:	fffff097          	auipc	ra,0xfffff
    80001942:	208080e7          	jalr	520(ra) # 80000b46 <initlock>
      p->state = UNUSED;
    80001946:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    8000194a:	415487b3          	sub	a5,s1,s5
    8000194e:	8791                	srai	a5,a5,0x4
    80001950:	000a3703          	ld	a4,0(s4)
    80001954:	02e787b3          	mul	a5,a5,a4
    80001958:	2785                	addiw	a5,a5,1
    8000195a:	00d7979b          	slliw	a5,a5,0xd
    8000195e:	40f907b3          	sub	a5,s2,a5
    80001962:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001964:	17048493          	addi	s1,s1,368
    80001968:	fd3499e3          	bne	s1,s3,8000193a <procinit+0x6e>
  }
}
    8000196c:	70e2                	ld	ra,56(sp)
    8000196e:	7442                	ld	s0,48(sp)
    80001970:	74a2                	ld	s1,40(sp)
    80001972:	7902                	ld	s2,32(sp)
    80001974:	69e2                	ld	s3,24(sp)
    80001976:	6a42                	ld	s4,16(sp)
    80001978:	6aa2                	ld	s5,8(sp)
    8000197a:	6b02                	ld	s6,0(sp)
    8000197c:	6121                	addi	sp,sp,64
    8000197e:	8082                	ret

0000000080001980 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001980:	1141                	addi	sp,sp,-16
    80001982:	e422                	sd	s0,8(sp)
    80001984:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001986:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001988:	2501                	sext.w	a0,a0
    8000198a:	6422                	ld	s0,8(sp)
    8000198c:	0141                	addi	sp,sp,16
    8000198e:	8082                	ret

0000000080001990 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80001990:	1141                	addi	sp,sp,-16
    80001992:	e422                	sd	s0,8(sp)
    80001994:	0800                	addi	s0,sp,16
    80001996:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001998:	2781                	sext.w	a5,a5
    8000199a:	079e                	slli	a5,a5,0x7
  return c;
}
    8000199c:	0000f517          	auipc	a0,0xf
    800019a0:	22450513          	addi	a0,a0,548 # 80010bc0 <cpus>
    800019a4:	953e                	add	a0,a0,a5
    800019a6:	6422                	ld	s0,8(sp)
    800019a8:	0141                	addi	sp,sp,16
    800019aa:	8082                	ret

00000000800019ac <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800019ac:	1101                	addi	sp,sp,-32
    800019ae:	ec06                	sd	ra,24(sp)
    800019b0:	e822                	sd	s0,16(sp)
    800019b2:	e426                	sd	s1,8(sp)
    800019b4:	1000                	addi	s0,sp,32
  push_off();
    800019b6:	fffff097          	auipc	ra,0xfffff
    800019ba:	1d4080e7          	jalr	468(ra) # 80000b8a <push_off>
    800019be:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019c0:	2781                	sext.w	a5,a5
    800019c2:	079e                	slli	a5,a5,0x7
    800019c4:	0000f717          	auipc	a4,0xf
    800019c8:	1cc70713          	addi	a4,a4,460 # 80010b90 <pid_lock>
    800019cc:	97ba                	add	a5,a5,a4
    800019ce:	7b84                	ld	s1,48(a5)
  pop_off();
    800019d0:	fffff097          	auipc	ra,0xfffff
    800019d4:	25a080e7          	jalr	602(ra) # 80000c2a <pop_off>
  return p;
}
    800019d8:	8526                	mv	a0,s1
    800019da:	60e2                	ld	ra,24(sp)
    800019dc:	6442                	ld	s0,16(sp)
    800019de:	64a2                	ld	s1,8(sp)
    800019e0:	6105                	addi	sp,sp,32
    800019e2:	8082                	ret

00000000800019e4 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800019e4:	1141                	addi	sp,sp,-16
    800019e6:	e406                	sd	ra,8(sp)
    800019e8:	e022                	sd	s0,0(sp)
    800019ea:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    800019ec:	00000097          	auipc	ra,0x0
    800019f0:	fc0080e7          	jalr	-64(ra) # 800019ac <myproc>
    800019f4:	fffff097          	auipc	ra,0xfffff
    800019f8:	296080e7          	jalr	662(ra) # 80000c8a <release>

  if (first) {
    800019fc:	00007797          	auipc	a5,0x7
    80001a00:	e847a783          	lw	a5,-380(a5) # 80008880 <first.1>
    80001a04:	eb89                	bnez	a5,80001a16 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a06:	00001097          	auipc	ra,0x1
    80001a0a:	c68080e7          	jalr	-920(ra) # 8000266e <usertrapret>
}
    80001a0e:	60a2                	ld	ra,8(sp)
    80001a10:	6402                	ld	s0,0(sp)
    80001a12:	0141                	addi	sp,sp,16
    80001a14:	8082                	ret
    first = 0;
    80001a16:	00007797          	auipc	a5,0x7
    80001a1a:	e607a523          	sw	zero,-406(a5) # 80008880 <first.1>
    fsinit(ROOTDEV);
    80001a1e:	4505                	li	a0,1
    80001a20:	00002097          	auipc	ra,0x2
    80001a24:	9f4080e7          	jalr	-1548(ra) # 80003414 <fsinit>
    80001a28:	bff9                	j	80001a06 <forkret+0x22>

0000000080001a2a <allocpid>:
{
    80001a2a:	1101                	addi	sp,sp,-32
    80001a2c:	ec06                	sd	ra,24(sp)
    80001a2e:	e822                	sd	s0,16(sp)
    80001a30:	e426                	sd	s1,8(sp)
    80001a32:	e04a                	sd	s2,0(sp)
    80001a34:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a36:	0000f917          	auipc	s2,0xf
    80001a3a:	15a90913          	addi	s2,s2,346 # 80010b90 <pid_lock>
    80001a3e:	854a                	mv	a0,s2
    80001a40:	fffff097          	auipc	ra,0xfffff
    80001a44:	196080e7          	jalr	406(ra) # 80000bd6 <acquire>
  pid = nextpid;
    80001a48:	00007797          	auipc	a5,0x7
    80001a4c:	e3c78793          	addi	a5,a5,-452 # 80008884 <nextpid>
    80001a50:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a52:	0014871b          	addiw	a4,s1,1
    80001a56:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a58:	854a                	mv	a0,s2
    80001a5a:	fffff097          	auipc	ra,0xfffff
    80001a5e:	230080e7          	jalr	560(ra) # 80000c8a <release>
}
    80001a62:	8526                	mv	a0,s1
    80001a64:	60e2                	ld	ra,24(sp)
    80001a66:	6442                	ld	s0,16(sp)
    80001a68:	64a2                	ld	s1,8(sp)
    80001a6a:	6902                	ld	s2,0(sp)
    80001a6c:	6105                	addi	sp,sp,32
    80001a6e:	8082                	ret

0000000080001a70 <proc_pagetable>:
{
    80001a70:	1101                	addi	sp,sp,-32
    80001a72:	ec06                	sd	ra,24(sp)
    80001a74:	e822                	sd	s0,16(sp)
    80001a76:	e426                	sd	s1,8(sp)
    80001a78:	e04a                	sd	s2,0(sp)
    80001a7a:	1000                	addi	s0,sp,32
    80001a7c:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a7e:	00000097          	auipc	ra,0x0
    80001a82:	8aa080e7          	jalr	-1878(ra) # 80001328 <uvmcreate>
    80001a86:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001a88:	c121                	beqz	a0,80001ac8 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001a8a:	4729                	li	a4,10
    80001a8c:	00005697          	auipc	a3,0x5
    80001a90:	57468693          	addi	a3,a3,1396 # 80007000 <_trampoline>
    80001a94:	6605                	lui	a2,0x1
    80001a96:	040005b7          	lui	a1,0x4000
    80001a9a:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a9c:	05b2                	slli	a1,a1,0xc
    80001a9e:	fffff097          	auipc	ra,0xfffff
    80001aa2:	600080e7          	jalr	1536(ra) # 8000109e <mappages>
    80001aa6:	02054863          	bltz	a0,80001ad6 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001aaa:	4719                	li	a4,6
    80001aac:	05893683          	ld	a3,88(s2)
    80001ab0:	6605                	lui	a2,0x1
    80001ab2:	020005b7          	lui	a1,0x2000
    80001ab6:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001ab8:	05b6                	slli	a1,a1,0xd
    80001aba:	8526                	mv	a0,s1
    80001abc:	fffff097          	auipc	ra,0xfffff
    80001ac0:	5e2080e7          	jalr	1506(ra) # 8000109e <mappages>
    80001ac4:	02054163          	bltz	a0,80001ae6 <proc_pagetable+0x76>
}
    80001ac8:	8526                	mv	a0,s1
    80001aca:	60e2                	ld	ra,24(sp)
    80001acc:	6442                	ld	s0,16(sp)
    80001ace:	64a2                	ld	s1,8(sp)
    80001ad0:	6902                	ld	s2,0(sp)
    80001ad2:	6105                	addi	sp,sp,32
    80001ad4:	8082                	ret
    uvmfree(pagetable, 0);
    80001ad6:	4581                	li	a1,0
    80001ad8:	8526                	mv	a0,s1
    80001ada:	00000097          	auipc	ra,0x0
    80001ade:	a54080e7          	jalr	-1452(ra) # 8000152e <uvmfree>
    return 0;
    80001ae2:	4481                	li	s1,0
    80001ae4:	b7d5                	j	80001ac8 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ae6:	4681                	li	a3,0
    80001ae8:	4605                	li	a2,1
    80001aea:	040005b7          	lui	a1,0x4000
    80001aee:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001af0:	05b2                	slli	a1,a1,0xc
    80001af2:	8526                	mv	a0,s1
    80001af4:	fffff097          	auipc	ra,0xfffff
    80001af8:	770080e7          	jalr	1904(ra) # 80001264 <uvmunmap>
    uvmfree(pagetable, 0);
    80001afc:	4581                	li	a1,0
    80001afe:	8526                	mv	a0,s1
    80001b00:	00000097          	auipc	ra,0x0
    80001b04:	a2e080e7          	jalr	-1490(ra) # 8000152e <uvmfree>
    return 0;
    80001b08:	4481                	li	s1,0
    80001b0a:	bf7d                	j	80001ac8 <proc_pagetable+0x58>

0000000080001b0c <proc_freepagetable>:
{
    80001b0c:	1101                	addi	sp,sp,-32
    80001b0e:	ec06                	sd	ra,24(sp)
    80001b10:	e822                	sd	s0,16(sp)
    80001b12:	e426                	sd	s1,8(sp)
    80001b14:	e04a                	sd	s2,0(sp)
    80001b16:	1000                	addi	s0,sp,32
    80001b18:	84aa                	mv	s1,a0
    80001b1a:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b1c:	4681                	li	a3,0
    80001b1e:	4605                	li	a2,1
    80001b20:	040005b7          	lui	a1,0x4000
    80001b24:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b26:	05b2                	slli	a1,a1,0xc
    80001b28:	fffff097          	auipc	ra,0xfffff
    80001b2c:	73c080e7          	jalr	1852(ra) # 80001264 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b30:	4681                	li	a3,0
    80001b32:	4605                	li	a2,1
    80001b34:	020005b7          	lui	a1,0x2000
    80001b38:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b3a:	05b6                	slli	a1,a1,0xd
    80001b3c:	8526                	mv	a0,s1
    80001b3e:	fffff097          	auipc	ra,0xfffff
    80001b42:	726080e7          	jalr	1830(ra) # 80001264 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b46:	85ca                	mv	a1,s2
    80001b48:	8526                	mv	a0,s1
    80001b4a:	00000097          	auipc	ra,0x0
    80001b4e:	9e4080e7          	jalr	-1564(ra) # 8000152e <uvmfree>
}
    80001b52:	60e2                	ld	ra,24(sp)
    80001b54:	6442                	ld	s0,16(sp)
    80001b56:	64a2                	ld	s1,8(sp)
    80001b58:	6902                	ld	s2,0(sp)
    80001b5a:	6105                	addi	sp,sp,32
    80001b5c:	8082                	ret

0000000080001b5e <freeproc>:
{
    80001b5e:	1101                	addi	sp,sp,-32
    80001b60:	ec06                	sd	ra,24(sp)
    80001b62:	e822                	sd	s0,16(sp)
    80001b64:	e426                	sd	s1,8(sp)
    80001b66:	1000                	addi	s0,sp,32
    80001b68:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001b6a:	6d28                	ld	a0,88(a0)
    80001b6c:	c509                	beqz	a0,80001b76 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001b6e:	fffff097          	auipc	ra,0xfffff
    80001b72:	e7a080e7          	jalr	-390(ra) # 800009e8 <kfree>
  p->trapframe = 0;
    80001b76:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001b7a:	68a8                	ld	a0,80(s1)
    80001b7c:	c511                	beqz	a0,80001b88 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001b7e:	64ac                	ld	a1,72(s1)
    80001b80:	00000097          	auipc	ra,0x0
    80001b84:	f8c080e7          	jalr	-116(ra) # 80001b0c <proc_freepagetable>
  p->pagetable = 0;
    80001b88:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001b8c:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001b90:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001b94:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001b98:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001b9c:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001ba0:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001ba4:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001ba8:	0004ac23          	sw	zero,24(s1)
}
    80001bac:	60e2                	ld	ra,24(sp)
    80001bae:	6442                	ld	s0,16(sp)
    80001bb0:	64a2                	ld	s1,8(sp)
    80001bb2:	6105                	addi	sp,sp,32
    80001bb4:	8082                	ret

0000000080001bb6 <allocproc>:
{
    80001bb6:	1101                	addi	sp,sp,-32
    80001bb8:	ec06                	sd	ra,24(sp)
    80001bba:	e822                	sd	s0,16(sp)
    80001bbc:	e426                	sd	s1,8(sp)
    80001bbe:	e04a                	sd	s2,0(sp)
    80001bc0:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bc2:	0000f497          	auipc	s1,0xf
    80001bc6:	3fe48493          	addi	s1,s1,1022 # 80010fc0 <proc>
    80001bca:	00015917          	auipc	s2,0x15
    80001bce:	ff690913          	addi	s2,s2,-10 # 80016bc0 <tickslock>
    acquire(&p->lock);
    80001bd2:	8526                	mv	a0,s1
    80001bd4:	fffff097          	auipc	ra,0xfffff
    80001bd8:	002080e7          	jalr	2(ra) # 80000bd6 <acquire>
    if(p->state == UNUSED) {
    80001bdc:	4c9c                	lw	a5,24(s1)
    80001bde:	cf81                	beqz	a5,80001bf6 <allocproc+0x40>
      release(&p->lock);
    80001be0:	8526                	mv	a0,s1
    80001be2:	fffff097          	auipc	ra,0xfffff
    80001be6:	0a8080e7          	jalr	168(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bea:	17048493          	addi	s1,s1,368
    80001bee:	ff2492e3          	bne	s1,s2,80001bd2 <allocproc+0x1c>
  return 0;
    80001bf2:	4481                	li	s1,0
    80001bf4:	a889                	j	80001c46 <allocproc+0x90>
  p->pid = allocpid();
    80001bf6:	00000097          	auipc	ra,0x0
    80001bfa:	e34080e7          	jalr	-460(ra) # 80001a2a <allocpid>
    80001bfe:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c00:	4785                	li	a5,1
    80001c02:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c04:	fffff097          	auipc	ra,0xfffff
    80001c08:	ee2080e7          	jalr	-286(ra) # 80000ae6 <kalloc>
    80001c0c:	892a                	mv	s2,a0
    80001c0e:	eca8                	sd	a0,88(s1)
    80001c10:	c131                	beqz	a0,80001c54 <allocproc+0x9e>
  p->pagetable = proc_pagetable(p);
    80001c12:	8526                	mv	a0,s1
    80001c14:	00000097          	auipc	ra,0x0
    80001c18:	e5c080e7          	jalr	-420(ra) # 80001a70 <proc_pagetable>
    80001c1c:	892a                	mv	s2,a0
    80001c1e:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c20:	c531                	beqz	a0,80001c6c <allocproc+0xb6>
  memset(&p->context, 0, sizeof(p->context));
    80001c22:	07000613          	li	a2,112
    80001c26:	4581                	li	a1,0
    80001c28:	06048513          	addi	a0,s1,96
    80001c2c:	fffff097          	auipc	ra,0xfffff
    80001c30:	0a6080e7          	jalr	166(ra) # 80000cd2 <memset>
  p->context.ra = (uint64)forkret;
    80001c34:	00000797          	auipc	a5,0x0
    80001c38:	db078793          	addi	a5,a5,-592 # 800019e4 <forkret>
    80001c3c:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c3e:	60bc                	ld	a5,64(s1)
    80001c40:	6705                	lui	a4,0x1
    80001c42:	97ba                	add	a5,a5,a4
    80001c44:	f4bc                	sd	a5,104(s1)
}
    80001c46:	8526                	mv	a0,s1
    80001c48:	60e2                	ld	ra,24(sp)
    80001c4a:	6442                	ld	s0,16(sp)
    80001c4c:	64a2                	ld	s1,8(sp)
    80001c4e:	6902                	ld	s2,0(sp)
    80001c50:	6105                	addi	sp,sp,32
    80001c52:	8082                	ret
    freeproc(p);
    80001c54:	8526                	mv	a0,s1
    80001c56:	00000097          	auipc	ra,0x0
    80001c5a:	f08080e7          	jalr	-248(ra) # 80001b5e <freeproc>
    release(&p->lock);
    80001c5e:	8526                	mv	a0,s1
    80001c60:	fffff097          	auipc	ra,0xfffff
    80001c64:	02a080e7          	jalr	42(ra) # 80000c8a <release>
    return 0;
    80001c68:	84ca                	mv	s1,s2
    80001c6a:	bff1                	j	80001c46 <allocproc+0x90>
    freeproc(p);
    80001c6c:	8526                	mv	a0,s1
    80001c6e:	00000097          	auipc	ra,0x0
    80001c72:	ef0080e7          	jalr	-272(ra) # 80001b5e <freeproc>
    release(&p->lock);
    80001c76:	8526                	mv	a0,s1
    80001c78:	fffff097          	auipc	ra,0xfffff
    80001c7c:	012080e7          	jalr	18(ra) # 80000c8a <release>
    return 0;
    80001c80:	84ca                	mv	s1,s2
    80001c82:	b7d1                	j	80001c46 <allocproc+0x90>

0000000080001c84 <userinit>:
{
    80001c84:	1101                	addi	sp,sp,-32
    80001c86:	ec06                	sd	ra,24(sp)
    80001c88:	e822                	sd	s0,16(sp)
    80001c8a:	e426                	sd	s1,8(sp)
    80001c8c:	1000                	addi	s0,sp,32
  p = allocproc();
    80001c8e:	00000097          	auipc	ra,0x0
    80001c92:	f28080e7          	jalr	-216(ra) # 80001bb6 <allocproc>
    80001c96:	84aa                	mv	s1,a0
  initproc = p;
    80001c98:	00007797          	auipc	a5,0x7
    80001c9c:	c8a7b023          	sd	a0,-896(a5) # 80008918 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001ca0:	03400613          	li	a2,52
    80001ca4:	00007597          	auipc	a1,0x7
    80001ca8:	bec58593          	addi	a1,a1,-1044 # 80008890 <initcode>
    80001cac:	6928                	ld	a0,80(a0)
    80001cae:	fffff097          	auipc	ra,0xfffff
    80001cb2:	6a8080e7          	jalr	1704(ra) # 80001356 <uvmfirst>
  p->sz = PGSIZE;
    80001cb6:	6785                	lui	a5,0x1
    80001cb8:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001cba:	6cb8                	ld	a4,88(s1)
    80001cbc:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001cc0:	6cb8                	ld	a4,88(s1)
    80001cc2:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001cc4:	4641                	li	a2,16
    80001cc6:	00006597          	auipc	a1,0x6
    80001cca:	53a58593          	addi	a1,a1,1338 # 80008200 <digits+0x1c0>
    80001cce:	15848513          	addi	a0,s1,344
    80001cd2:	fffff097          	auipc	ra,0xfffff
    80001cd6:	14a080e7          	jalr	330(ra) # 80000e1c <safestrcpy>
  p->cwd = namei("/");
    80001cda:	00006517          	auipc	a0,0x6
    80001cde:	53650513          	addi	a0,a0,1334 # 80008210 <digits+0x1d0>
    80001ce2:	00002097          	auipc	ra,0x2
    80001ce6:	15c080e7          	jalr	348(ra) # 80003e3e <namei>
    80001cea:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001cee:	478d                	li	a5,3
    80001cf0:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001cf2:	8526                	mv	a0,s1
    80001cf4:	fffff097          	auipc	ra,0xfffff
    80001cf8:	f96080e7          	jalr	-106(ra) # 80000c8a <release>
}
    80001cfc:	60e2                	ld	ra,24(sp)
    80001cfe:	6442                	ld	s0,16(sp)
    80001d00:	64a2                	ld	s1,8(sp)
    80001d02:	6105                	addi	sp,sp,32
    80001d04:	8082                	ret

0000000080001d06 <growproc>:
{
    80001d06:	1101                	addi	sp,sp,-32
    80001d08:	ec06                	sd	ra,24(sp)
    80001d0a:	e822                	sd	s0,16(sp)
    80001d0c:	e426                	sd	s1,8(sp)
    80001d0e:	e04a                	sd	s2,0(sp)
    80001d10:	1000                	addi	s0,sp,32
    80001d12:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001d14:	00000097          	auipc	ra,0x0
    80001d18:	c98080e7          	jalr	-872(ra) # 800019ac <myproc>
    80001d1c:	84aa                	mv	s1,a0
  sz = p->sz;
    80001d1e:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001d20:	01204c63          	bgtz	s2,80001d38 <growproc+0x32>
  } else if(n < 0){
    80001d24:	02094663          	bltz	s2,80001d50 <growproc+0x4a>
  p->sz = sz;
    80001d28:	e4ac                	sd	a1,72(s1)
  return 0;
    80001d2a:	4501                	li	a0,0
}
    80001d2c:	60e2                	ld	ra,24(sp)
    80001d2e:	6442                	ld	s0,16(sp)
    80001d30:	64a2                	ld	s1,8(sp)
    80001d32:	6902                	ld	s2,0(sp)
    80001d34:	6105                	addi	sp,sp,32
    80001d36:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001d38:	4691                	li	a3,4
    80001d3a:	00b90633          	add	a2,s2,a1
    80001d3e:	6928                	ld	a0,80(a0)
    80001d40:	fffff097          	auipc	ra,0xfffff
    80001d44:	6d0080e7          	jalr	1744(ra) # 80001410 <uvmalloc>
    80001d48:	85aa                	mv	a1,a0
    80001d4a:	fd79                	bnez	a0,80001d28 <growproc+0x22>
      return -1;
    80001d4c:	557d                	li	a0,-1
    80001d4e:	bff9                	j	80001d2c <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d50:	00b90633          	add	a2,s2,a1
    80001d54:	6928                	ld	a0,80(a0)
    80001d56:	fffff097          	auipc	ra,0xfffff
    80001d5a:	672080e7          	jalr	1650(ra) # 800013c8 <uvmdealloc>
    80001d5e:	85aa                	mv	a1,a0
    80001d60:	b7e1                	j	80001d28 <growproc+0x22>

0000000080001d62 <fork>:
{
    80001d62:	7139                	addi	sp,sp,-64
    80001d64:	fc06                	sd	ra,56(sp)
    80001d66:	f822                	sd	s0,48(sp)
    80001d68:	f426                	sd	s1,40(sp)
    80001d6a:	f04a                	sd	s2,32(sp)
    80001d6c:	ec4e                	sd	s3,24(sp)
    80001d6e:	e852                	sd	s4,16(sp)
    80001d70:	e456                	sd	s5,8(sp)
    80001d72:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001d74:	00000097          	auipc	ra,0x0
    80001d78:	c38080e7          	jalr	-968(ra) # 800019ac <myproc>
    80001d7c:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001d7e:	00000097          	auipc	ra,0x0
    80001d82:	e38080e7          	jalr	-456(ra) # 80001bb6 <allocproc>
    80001d86:	10050c63          	beqz	a0,80001e9e <fork+0x13c>
    80001d8a:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001d8c:	048ab603          	ld	a2,72(s5)
    80001d90:	692c                	ld	a1,80(a0)
    80001d92:	050ab503          	ld	a0,80(s5)
    80001d96:	fffff097          	auipc	ra,0xfffff
    80001d9a:	7d2080e7          	jalr	2002(ra) # 80001568 <uvmcopy>
    80001d9e:	04054863          	bltz	a0,80001dee <fork+0x8c>
  np->sz = p->sz;
    80001da2:	048ab783          	ld	a5,72(s5)
    80001da6:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001daa:	058ab683          	ld	a3,88(s5)
    80001dae:	87b6                	mv	a5,a3
    80001db0:	058a3703          	ld	a4,88(s4)
    80001db4:	12068693          	addi	a3,a3,288
    80001db8:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001dbc:	6788                	ld	a0,8(a5)
    80001dbe:	6b8c                	ld	a1,16(a5)
    80001dc0:	6f90                	ld	a2,24(a5)
    80001dc2:	01073023          	sd	a6,0(a4)
    80001dc6:	e708                	sd	a0,8(a4)
    80001dc8:	eb0c                	sd	a1,16(a4)
    80001dca:	ef10                	sd	a2,24(a4)
    80001dcc:	02078793          	addi	a5,a5,32
    80001dd0:	02070713          	addi	a4,a4,32
    80001dd4:	fed792e3          	bne	a5,a3,80001db8 <fork+0x56>
  np->trapframe->a0 = 0;
    80001dd8:	058a3783          	ld	a5,88(s4)
    80001ddc:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001de0:	0d0a8493          	addi	s1,s5,208
    80001de4:	0d0a0913          	addi	s2,s4,208
    80001de8:	150a8993          	addi	s3,s5,336
    80001dec:	a00d                	j	80001e0e <fork+0xac>
    freeproc(np);
    80001dee:	8552                	mv	a0,s4
    80001df0:	00000097          	auipc	ra,0x0
    80001df4:	d6e080e7          	jalr	-658(ra) # 80001b5e <freeproc>
    release(&np->lock);
    80001df8:	8552                	mv	a0,s4
    80001dfa:	fffff097          	auipc	ra,0xfffff
    80001dfe:	e90080e7          	jalr	-368(ra) # 80000c8a <release>
    return -1;
    80001e02:	597d                	li	s2,-1
    80001e04:	a059                	j	80001e8a <fork+0x128>
  for(i = 0; i < NOFILE; i++)
    80001e06:	04a1                	addi	s1,s1,8
    80001e08:	0921                	addi	s2,s2,8
    80001e0a:	01348b63          	beq	s1,s3,80001e20 <fork+0xbe>
    if(p->ofile[i])
    80001e0e:	6088                	ld	a0,0(s1)
    80001e10:	d97d                	beqz	a0,80001e06 <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e12:	00002097          	auipc	ra,0x2
    80001e16:	6c2080e7          	jalr	1730(ra) # 800044d4 <filedup>
    80001e1a:	00a93023          	sd	a0,0(s2)
    80001e1e:	b7e5                	j	80001e06 <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001e20:	150ab503          	ld	a0,336(s5)
    80001e24:	00002097          	auipc	ra,0x2
    80001e28:	830080e7          	jalr	-2000(ra) # 80003654 <idup>
    80001e2c:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e30:	4641                	li	a2,16
    80001e32:	158a8593          	addi	a1,s5,344
    80001e36:	158a0513          	addi	a0,s4,344
    80001e3a:	fffff097          	auipc	ra,0xfffff
    80001e3e:	fe2080e7          	jalr	-30(ra) # 80000e1c <safestrcpy>
  pid = np->pid;
    80001e42:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001e46:	8552                	mv	a0,s4
    80001e48:	fffff097          	auipc	ra,0xfffff
    80001e4c:	e42080e7          	jalr	-446(ra) # 80000c8a <release>
  acquire(&wait_lock);
    80001e50:	0000f497          	auipc	s1,0xf
    80001e54:	d5848493          	addi	s1,s1,-680 # 80010ba8 <wait_lock>
    80001e58:	8526                	mv	a0,s1
    80001e5a:	fffff097          	auipc	ra,0xfffff
    80001e5e:	d7c080e7          	jalr	-644(ra) # 80000bd6 <acquire>
  np->parent = p;
    80001e62:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001e66:	8526                	mv	a0,s1
    80001e68:	fffff097          	auipc	ra,0xfffff
    80001e6c:	e22080e7          	jalr	-478(ra) # 80000c8a <release>
  acquire(&np->lock);
    80001e70:	8552                	mv	a0,s4
    80001e72:	fffff097          	auipc	ra,0xfffff
    80001e76:	d64080e7          	jalr	-668(ra) # 80000bd6 <acquire>
  np->state = RUNNABLE;
    80001e7a:	478d                	li	a5,3
    80001e7c:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001e80:	8552                	mv	a0,s4
    80001e82:	fffff097          	auipc	ra,0xfffff
    80001e86:	e08080e7          	jalr	-504(ra) # 80000c8a <release>
}
    80001e8a:	854a                	mv	a0,s2
    80001e8c:	70e2                	ld	ra,56(sp)
    80001e8e:	7442                	ld	s0,48(sp)
    80001e90:	74a2                	ld	s1,40(sp)
    80001e92:	7902                	ld	s2,32(sp)
    80001e94:	69e2                	ld	s3,24(sp)
    80001e96:	6a42                	ld	s4,16(sp)
    80001e98:	6aa2                	ld	s5,8(sp)
    80001e9a:	6121                	addi	sp,sp,64
    80001e9c:	8082                	ret
    return -1;
    80001e9e:	597d                	li	s2,-1
    80001ea0:	b7ed                	j	80001e8a <fork+0x128>

0000000080001ea2 <scheduler>:
{
    80001ea2:	7139                	addi	sp,sp,-64
    80001ea4:	fc06                	sd	ra,56(sp)
    80001ea6:	f822                	sd	s0,48(sp)
    80001ea8:	f426                	sd	s1,40(sp)
    80001eaa:	f04a                	sd	s2,32(sp)
    80001eac:	ec4e                	sd	s3,24(sp)
    80001eae:	e852                	sd	s4,16(sp)
    80001eb0:	e456                	sd	s5,8(sp)
    80001eb2:	e05a                	sd	s6,0(sp)
    80001eb4:	0080                	addi	s0,sp,64
    80001eb6:	8792                	mv	a5,tp
  int id = r_tp();
    80001eb8:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001eba:	00779a93          	slli	s5,a5,0x7
    80001ebe:	0000f717          	auipc	a4,0xf
    80001ec2:	cd270713          	addi	a4,a4,-814 # 80010b90 <pid_lock>
    80001ec6:	9756                	add	a4,a4,s5
    80001ec8:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001ecc:	0000f717          	auipc	a4,0xf
    80001ed0:	cfc70713          	addi	a4,a4,-772 # 80010bc8 <cpus+0x8>
    80001ed4:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80001ed6:	498d                	li	s3,3
        p->state = RUNNING;
    80001ed8:	4b11                	li	s6,4
        c->proc = p;
    80001eda:	079e                	slli	a5,a5,0x7
    80001edc:	0000fa17          	auipc	s4,0xf
    80001ee0:	cb4a0a13          	addi	s4,s4,-844 # 80010b90 <pid_lock>
    80001ee4:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001ee6:	00015917          	auipc	s2,0x15
    80001eea:	cda90913          	addi	s2,s2,-806 # 80016bc0 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001eee:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001ef2:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001ef6:	10079073          	csrw	sstatus,a5
    80001efa:	0000f497          	auipc	s1,0xf
    80001efe:	0c648493          	addi	s1,s1,198 # 80010fc0 <proc>
    80001f02:	a811                	j	80001f16 <scheduler+0x74>
      release(&p->lock);
    80001f04:	8526                	mv	a0,s1
    80001f06:	fffff097          	auipc	ra,0xfffff
    80001f0a:	d84080e7          	jalr	-636(ra) # 80000c8a <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f0e:	17048493          	addi	s1,s1,368
    80001f12:	fd248ee3          	beq	s1,s2,80001eee <scheduler+0x4c>
      acquire(&p->lock);
    80001f16:	8526                	mv	a0,s1
    80001f18:	fffff097          	auipc	ra,0xfffff
    80001f1c:	cbe080e7          	jalr	-834(ra) # 80000bd6 <acquire>
      if(p->state == RUNNABLE) {
    80001f20:	4c9c                	lw	a5,24(s1)
    80001f22:	ff3791e3          	bne	a5,s3,80001f04 <scheduler+0x62>
        p->contador++;
    80001f26:	1684a783          	lw	a5,360(s1)
    80001f2a:	2785                	addiw	a5,a5,1
    80001f2c:	16f4a423          	sw	a5,360(s1)
        p->state = RUNNING;
    80001f30:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80001f34:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001f38:	06048593          	addi	a1,s1,96
    80001f3c:	8556                	mv	a0,s5
    80001f3e:	00000097          	auipc	ra,0x0
    80001f42:	686080e7          	jalr	1670(ra) # 800025c4 <swtch>
        c->proc = 0;
    80001f46:	020a3823          	sd	zero,48(s4)
    80001f4a:	bf6d                	j	80001f04 <scheduler+0x62>

0000000080001f4c <sched>:
{
    80001f4c:	7179                	addi	sp,sp,-48
    80001f4e:	f406                	sd	ra,40(sp)
    80001f50:	f022                	sd	s0,32(sp)
    80001f52:	ec26                	sd	s1,24(sp)
    80001f54:	e84a                	sd	s2,16(sp)
    80001f56:	e44e                	sd	s3,8(sp)
    80001f58:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001f5a:	00000097          	auipc	ra,0x0
    80001f5e:	a52080e7          	jalr	-1454(ra) # 800019ac <myproc>
    80001f62:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001f64:	fffff097          	auipc	ra,0xfffff
    80001f68:	bf8080e7          	jalr	-1032(ra) # 80000b5c <holding>
    80001f6c:	c93d                	beqz	a0,80001fe2 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001f6e:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001f70:	2781                	sext.w	a5,a5
    80001f72:	079e                	slli	a5,a5,0x7
    80001f74:	0000f717          	auipc	a4,0xf
    80001f78:	c1c70713          	addi	a4,a4,-996 # 80010b90 <pid_lock>
    80001f7c:	97ba                	add	a5,a5,a4
    80001f7e:	0a87a703          	lw	a4,168(a5)
    80001f82:	4785                	li	a5,1
    80001f84:	06f71763          	bne	a4,a5,80001ff2 <sched+0xa6>
  if(p->state == RUNNING)
    80001f88:	4c98                	lw	a4,24(s1)
    80001f8a:	4791                	li	a5,4
    80001f8c:	06f70b63          	beq	a4,a5,80002002 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f90:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001f94:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001f96:	efb5                	bnez	a5,80002012 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001f98:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001f9a:	0000f917          	auipc	s2,0xf
    80001f9e:	bf690913          	addi	s2,s2,-1034 # 80010b90 <pid_lock>
    80001fa2:	2781                	sext.w	a5,a5
    80001fa4:	079e                	slli	a5,a5,0x7
    80001fa6:	97ca                	add	a5,a5,s2
    80001fa8:	0ac7a983          	lw	s3,172(a5)
    80001fac:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001fae:	2781                	sext.w	a5,a5
    80001fb0:	079e                	slli	a5,a5,0x7
    80001fb2:	0000f597          	auipc	a1,0xf
    80001fb6:	c1658593          	addi	a1,a1,-1002 # 80010bc8 <cpus+0x8>
    80001fba:	95be                	add	a1,a1,a5
    80001fbc:	06048513          	addi	a0,s1,96
    80001fc0:	00000097          	auipc	ra,0x0
    80001fc4:	604080e7          	jalr	1540(ra) # 800025c4 <swtch>
    80001fc8:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001fca:	2781                	sext.w	a5,a5
    80001fcc:	079e                	slli	a5,a5,0x7
    80001fce:	993e                	add	s2,s2,a5
    80001fd0:	0b392623          	sw	s3,172(s2)
}
    80001fd4:	70a2                	ld	ra,40(sp)
    80001fd6:	7402                	ld	s0,32(sp)
    80001fd8:	64e2                	ld	s1,24(sp)
    80001fda:	6942                	ld	s2,16(sp)
    80001fdc:	69a2                	ld	s3,8(sp)
    80001fde:	6145                	addi	sp,sp,48
    80001fe0:	8082                	ret
    panic("sched p->lock");
    80001fe2:	00006517          	auipc	a0,0x6
    80001fe6:	23650513          	addi	a0,a0,566 # 80008218 <digits+0x1d8>
    80001fea:	ffffe097          	auipc	ra,0xffffe
    80001fee:	556080e7          	jalr	1366(ra) # 80000540 <panic>
    panic("sched locks");
    80001ff2:	00006517          	auipc	a0,0x6
    80001ff6:	23650513          	addi	a0,a0,566 # 80008228 <digits+0x1e8>
    80001ffa:	ffffe097          	auipc	ra,0xffffe
    80001ffe:	546080e7          	jalr	1350(ra) # 80000540 <panic>
    panic("sched running");
    80002002:	00006517          	auipc	a0,0x6
    80002006:	23650513          	addi	a0,a0,566 # 80008238 <digits+0x1f8>
    8000200a:	ffffe097          	auipc	ra,0xffffe
    8000200e:	536080e7          	jalr	1334(ra) # 80000540 <panic>
    panic("sched interruptible");
    80002012:	00006517          	auipc	a0,0x6
    80002016:	23650513          	addi	a0,a0,566 # 80008248 <digits+0x208>
    8000201a:	ffffe097          	auipc	ra,0xffffe
    8000201e:	526080e7          	jalr	1318(ra) # 80000540 <panic>

0000000080002022 <yield>:
{
    80002022:	1101                	addi	sp,sp,-32
    80002024:	ec06                	sd	ra,24(sp)
    80002026:	e822                	sd	s0,16(sp)
    80002028:	e426                	sd	s1,8(sp)
    8000202a:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000202c:	00000097          	auipc	ra,0x0
    80002030:	980080e7          	jalr	-1664(ra) # 800019ac <myproc>
    80002034:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002036:	fffff097          	auipc	ra,0xfffff
    8000203a:	ba0080e7          	jalr	-1120(ra) # 80000bd6 <acquire>
  p->state = RUNNABLE;
    8000203e:	478d                	li	a5,3
    80002040:	cc9c                	sw	a5,24(s1)
  sched();
    80002042:	00000097          	auipc	ra,0x0
    80002046:	f0a080e7          	jalr	-246(ra) # 80001f4c <sched>
  release(&p->lock);
    8000204a:	8526                	mv	a0,s1
    8000204c:	fffff097          	auipc	ra,0xfffff
    80002050:	c3e080e7          	jalr	-962(ra) # 80000c8a <release>
}
    80002054:	60e2                	ld	ra,24(sp)
    80002056:	6442                	ld	s0,16(sp)
    80002058:	64a2                	ld	s1,8(sp)
    8000205a:	6105                	addi	sp,sp,32
    8000205c:	8082                	ret

000000008000205e <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    8000205e:	7179                	addi	sp,sp,-48
    80002060:	f406                	sd	ra,40(sp)
    80002062:	f022                	sd	s0,32(sp)
    80002064:	ec26                	sd	s1,24(sp)
    80002066:	e84a                	sd	s2,16(sp)
    80002068:	e44e                	sd	s3,8(sp)
    8000206a:	1800                	addi	s0,sp,48
    8000206c:	89aa                	mv	s3,a0
    8000206e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002070:	00000097          	auipc	ra,0x0
    80002074:	93c080e7          	jalr	-1732(ra) # 800019ac <myproc>
    80002078:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    8000207a:	fffff097          	auipc	ra,0xfffff
    8000207e:	b5c080e7          	jalr	-1188(ra) # 80000bd6 <acquire>
  release(lk);
    80002082:	854a                	mv	a0,s2
    80002084:	fffff097          	auipc	ra,0xfffff
    80002088:	c06080e7          	jalr	-1018(ra) # 80000c8a <release>

  // Go to sleep.
  p->chan = chan;
    8000208c:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002090:	4789                	li	a5,2
    80002092:	cc9c                	sw	a5,24(s1)

  sched();
    80002094:	00000097          	auipc	ra,0x0
    80002098:	eb8080e7          	jalr	-328(ra) # 80001f4c <sched>

  // Tidy up.
  p->chan = 0;
    8000209c:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800020a0:	8526                	mv	a0,s1
    800020a2:	fffff097          	auipc	ra,0xfffff
    800020a6:	be8080e7          	jalr	-1048(ra) # 80000c8a <release>
  acquire(lk);
    800020aa:	854a                	mv	a0,s2
    800020ac:	fffff097          	auipc	ra,0xfffff
    800020b0:	b2a080e7          	jalr	-1238(ra) # 80000bd6 <acquire>
}
    800020b4:	70a2                	ld	ra,40(sp)
    800020b6:	7402                	ld	s0,32(sp)
    800020b8:	64e2                	ld	s1,24(sp)
    800020ba:	6942                	ld	s2,16(sp)
    800020bc:	69a2                	ld	s3,8(sp)
    800020be:	6145                	addi	sp,sp,48
    800020c0:	8082                	ret

00000000800020c2 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    800020c2:	7139                	addi	sp,sp,-64
    800020c4:	fc06                	sd	ra,56(sp)
    800020c6:	f822                	sd	s0,48(sp)
    800020c8:	f426                	sd	s1,40(sp)
    800020ca:	f04a                	sd	s2,32(sp)
    800020cc:	ec4e                	sd	s3,24(sp)
    800020ce:	e852                	sd	s4,16(sp)
    800020d0:	e456                	sd	s5,8(sp)
    800020d2:	0080                	addi	s0,sp,64
    800020d4:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800020d6:	0000f497          	auipc	s1,0xf
    800020da:	eea48493          	addi	s1,s1,-278 # 80010fc0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800020de:	4989                	li	s3,2
        p->state = RUNNABLE;
    800020e0:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800020e2:	00015917          	auipc	s2,0x15
    800020e6:	ade90913          	addi	s2,s2,-1314 # 80016bc0 <tickslock>
    800020ea:	a811                	j	800020fe <wakeup+0x3c>
      }
      release(&p->lock);
    800020ec:	8526                	mv	a0,s1
    800020ee:	fffff097          	auipc	ra,0xfffff
    800020f2:	b9c080e7          	jalr	-1124(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800020f6:	17048493          	addi	s1,s1,368
    800020fa:	03248663          	beq	s1,s2,80002126 <wakeup+0x64>
    if(p != myproc()){
    800020fe:	00000097          	auipc	ra,0x0
    80002102:	8ae080e7          	jalr	-1874(ra) # 800019ac <myproc>
    80002106:	fea488e3          	beq	s1,a0,800020f6 <wakeup+0x34>
      acquire(&p->lock);
    8000210a:	8526                	mv	a0,s1
    8000210c:	fffff097          	auipc	ra,0xfffff
    80002110:	aca080e7          	jalr	-1334(ra) # 80000bd6 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002114:	4c9c                	lw	a5,24(s1)
    80002116:	fd379be3          	bne	a5,s3,800020ec <wakeup+0x2a>
    8000211a:	709c                	ld	a5,32(s1)
    8000211c:	fd4798e3          	bne	a5,s4,800020ec <wakeup+0x2a>
        p->state = RUNNABLE;
    80002120:	0154ac23          	sw	s5,24(s1)
    80002124:	b7e1                	j	800020ec <wakeup+0x2a>
    }
  }
}
    80002126:	70e2                	ld	ra,56(sp)
    80002128:	7442                	ld	s0,48(sp)
    8000212a:	74a2                	ld	s1,40(sp)
    8000212c:	7902                	ld	s2,32(sp)
    8000212e:	69e2                	ld	s3,24(sp)
    80002130:	6a42                	ld	s4,16(sp)
    80002132:	6aa2                	ld	s5,8(sp)
    80002134:	6121                	addi	sp,sp,64
    80002136:	8082                	ret

0000000080002138 <reparent>:
{
    80002138:	7179                	addi	sp,sp,-48
    8000213a:	f406                	sd	ra,40(sp)
    8000213c:	f022                	sd	s0,32(sp)
    8000213e:	ec26                	sd	s1,24(sp)
    80002140:	e84a                	sd	s2,16(sp)
    80002142:	e44e                	sd	s3,8(sp)
    80002144:	e052                	sd	s4,0(sp)
    80002146:	1800                	addi	s0,sp,48
    80002148:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000214a:	0000f497          	auipc	s1,0xf
    8000214e:	e7648493          	addi	s1,s1,-394 # 80010fc0 <proc>
      pp->parent = initproc;
    80002152:	00006a17          	auipc	s4,0x6
    80002156:	7c6a0a13          	addi	s4,s4,1990 # 80008918 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000215a:	00015997          	auipc	s3,0x15
    8000215e:	a6698993          	addi	s3,s3,-1434 # 80016bc0 <tickslock>
    80002162:	a029                	j	8000216c <reparent+0x34>
    80002164:	17048493          	addi	s1,s1,368
    80002168:	01348d63          	beq	s1,s3,80002182 <reparent+0x4a>
    if(pp->parent == p){
    8000216c:	7c9c                	ld	a5,56(s1)
    8000216e:	ff279be3          	bne	a5,s2,80002164 <reparent+0x2c>
      pp->parent = initproc;
    80002172:	000a3503          	ld	a0,0(s4)
    80002176:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002178:	00000097          	auipc	ra,0x0
    8000217c:	f4a080e7          	jalr	-182(ra) # 800020c2 <wakeup>
    80002180:	b7d5                	j	80002164 <reparent+0x2c>
}
    80002182:	70a2                	ld	ra,40(sp)
    80002184:	7402                	ld	s0,32(sp)
    80002186:	64e2                	ld	s1,24(sp)
    80002188:	6942                	ld	s2,16(sp)
    8000218a:	69a2                	ld	s3,8(sp)
    8000218c:	6a02                	ld	s4,0(sp)
    8000218e:	6145                	addi	sp,sp,48
    80002190:	8082                	ret

0000000080002192 <exit>:
{
    80002192:	7179                	addi	sp,sp,-48
    80002194:	f406                	sd	ra,40(sp)
    80002196:	f022                	sd	s0,32(sp)
    80002198:	ec26                	sd	s1,24(sp)
    8000219a:	e84a                	sd	s2,16(sp)
    8000219c:	e44e                	sd	s3,8(sp)
    8000219e:	e052                	sd	s4,0(sp)
    800021a0:	1800                	addi	s0,sp,48
    800021a2:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800021a4:	00000097          	auipc	ra,0x0
    800021a8:	808080e7          	jalr	-2040(ra) # 800019ac <myproc>
    800021ac:	89aa                	mv	s3,a0
  if(p == initproc)
    800021ae:	00006797          	auipc	a5,0x6
    800021b2:	76a7b783          	ld	a5,1898(a5) # 80008918 <initproc>
    800021b6:	0d050493          	addi	s1,a0,208
    800021ba:	15050913          	addi	s2,a0,336
    800021be:	02a79363          	bne	a5,a0,800021e4 <exit+0x52>
    panic("init exiting");
    800021c2:	00006517          	auipc	a0,0x6
    800021c6:	09e50513          	addi	a0,a0,158 # 80008260 <digits+0x220>
    800021ca:	ffffe097          	auipc	ra,0xffffe
    800021ce:	376080e7          	jalr	886(ra) # 80000540 <panic>
      fileclose(f);
    800021d2:	00002097          	auipc	ra,0x2
    800021d6:	354080e7          	jalr	852(ra) # 80004526 <fileclose>
      p->ofile[fd] = 0;
    800021da:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800021de:	04a1                	addi	s1,s1,8
    800021e0:	01248563          	beq	s1,s2,800021ea <exit+0x58>
    if(p->ofile[fd]){
    800021e4:	6088                	ld	a0,0(s1)
    800021e6:	f575                	bnez	a0,800021d2 <exit+0x40>
    800021e8:	bfdd                	j	800021de <exit+0x4c>
  begin_op();
    800021ea:	00002097          	auipc	ra,0x2
    800021ee:	e74080e7          	jalr	-396(ra) # 8000405e <begin_op>
  iput(p->cwd);
    800021f2:	1509b503          	ld	a0,336(s3)
    800021f6:	00001097          	auipc	ra,0x1
    800021fa:	656080e7          	jalr	1622(ra) # 8000384c <iput>
  end_op();
    800021fe:	00002097          	auipc	ra,0x2
    80002202:	ede080e7          	jalr	-290(ra) # 800040dc <end_op>
  p->cwd = 0;
    80002206:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    8000220a:	0000f497          	auipc	s1,0xf
    8000220e:	99e48493          	addi	s1,s1,-1634 # 80010ba8 <wait_lock>
    80002212:	8526                	mv	a0,s1
    80002214:	fffff097          	auipc	ra,0xfffff
    80002218:	9c2080e7          	jalr	-1598(ra) # 80000bd6 <acquire>
  reparent(p);
    8000221c:	854e                	mv	a0,s3
    8000221e:	00000097          	auipc	ra,0x0
    80002222:	f1a080e7          	jalr	-230(ra) # 80002138 <reparent>
  wakeup(p->parent);
    80002226:	0389b503          	ld	a0,56(s3)
    8000222a:	00000097          	auipc	ra,0x0
    8000222e:	e98080e7          	jalr	-360(ra) # 800020c2 <wakeup>
  acquire(&p->lock);
    80002232:	854e                	mv	a0,s3
    80002234:	fffff097          	auipc	ra,0xfffff
    80002238:	9a2080e7          	jalr	-1630(ra) # 80000bd6 <acquire>
  p->xstate = status;
    8000223c:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002240:	4795                	li	a5,5
    80002242:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002246:	8526                	mv	a0,s1
    80002248:	fffff097          	auipc	ra,0xfffff
    8000224c:	a42080e7          	jalr	-1470(ra) # 80000c8a <release>
  sched();
    80002250:	00000097          	auipc	ra,0x0
    80002254:	cfc080e7          	jalr	-772(ra) # 80001f4c <sched>
  panic("zombie exit");
    80002258:	00006517          	auipc	a0,0x6
    8000225c:	01850513          	addi	a0,a0,24 # 80008270 <digits+0x230>
    80002260:	ffffe097          	auipc	ra,0xffffe
    80002264:	2e0080e7          	jalr	736(ra) # 80000540 <panic>

0000000080002268 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002268:	7179                	addi	sp,sp,-48
    8000226a:	f406                	sd	ra,40(sp)
    8000226c:	f022                	sd	s0,32(sp)
    8000226e:	ec26                	sd	s1,24(sp)
    80002270:	e84a                	sd	s2,16(sp)
    80002272:	e44e                	sd	s3,8(sp)
    80002274:	1800                	addi	s0,sp,48
    80002276:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002278:	0000f497          	auipc	s1,0xf
    8000227c:	d4848493          	addi	s1,s1,-696 # 80010fc0 <proc>
    80002280:	00015997          	auipc	s3,0x15
    80002284:	94098993          	addi	s3,s3,-1728 # 80016bc0 <tickslock>
    acquire(&p->lock);
    80002288:	8526                	mv	a0,s1
    8000228a:	fffff097          	auipc	ra,0xfffff
    8000228e:	94c080e7          	jalr	-1716(ra) # 80000bd6 <acquire>
    if(p->pid == pid){
    80002292:	589c                	lw	a5,48(s1)
    80002294:	01278d63          	beq	a5,s2,800022ae <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002298:	8526                	mv	a0,s1
    8000229a:	fffff097          	auipc	ra,0xfffff
    8000229e:	9f0080e7          	jalr	-1552(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800022a2:	17048493          	addi	s1,s1,368
    800022a6:	ff3491e3          	bne	s1,s3,80002288 <kill+0x20>
  }
  return -1;
    800022aa:	557d                	li	a0,-1
    800022ac:	a829                	j	800022c6 <kill+0x5e>
      p->killed = 1;
    800022ae:	4785                	li	a5,1
    800022b0:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800022b2:	4c98                	lw	a4,24(s1)
    800022b4:	4789                	li	a5,2
    800022b6:	00f70f63          	beq	a4,a5,800022d4 <kill+0x6c>
      release(&p->lock);
    800022ba:	8526                	mv	a0,s1
    800022bc:	fffff097          	auipc	ra,0xfffff
    800022c0:	9ce080e7          	jalr	-1586(ra) # 80000c8a <release>
      return 0;
    800022c4:	4501                	li	a0,0
}
    800022c6:	70a2                	ld	ra,40(sp)
    800022c8:	7402                	ld	s0,32(sp)
    800022ca:	64e2                	ld	s1,24(sp)
    800022cc:	6942                	ld	s2,16(sp)
    800022ce:	69a2                	ld	s3,8(sp)
    800022d0:	6145                	addi	sp,sp,48
    800022d2:	8082                	ret
        p->state = RUNNABLE;
    800022d4:	478d                	li	a5,3
    800022d6:	cc9c                	sw	a5,24(s1)
    800022d8:	b7cd                	j	800022ba <kill+0x52>

00000000800022da <setkilled>:

void
setkilled(struct proc *p)
{
    800022da:	1101                	addi	sp,sp,-32
    800022dc:	ec06                	sd	ra,24(sp)
    800022de:	e822                	sd	s0,16(sp)
    800022e0:	e426                	sd	s1,8(sp)
    800022e2:	1000                	addi	s0,sp,32
    800022e4:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800022e6:	fffff097          	auipc	ra,0xfffff
    800022ea:	8f0080e7          	jalr	-1808(ra) # 80000bd6 <acquire>
  p->killed = 1;
    800022ee:	4785                	li	a5,1
    800022f0:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800022f2:	8526                	mv	a0,s1
    800022f4:	fffff097          	auipc	ra,0xfffff
    800022f8:	996080e7          	jalr	-1642(ra) # 80000c8a <release>
}
    800022fc:	60e2                	ld	ra,24(sp)
    800022fe:	6442                	ld	s0,16(sp)
    80002300:	64a2                	ld	s1,8(sp)
    80002302:	6105                	addi	sp,sp,32
    80002304:	8082                	ret

0000000080002306 <killed>:

int
killed(struct proc *p)
{
    80002306:	1101                	addi	sp,sp,-32
    80002308:	ec06                	sd	ra,24(sp)
    8000230a:	e822                	sd	s0,16(sp)
    8000230c:	e426                	sd	s1,8(sp)
    8000230e:	e04a                	sd	s2,0(sp)
    80002310:	1000                	addi	s0,sp,32
    80002312:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80002314:	fffff097          	auipc	ra,0xfffff
    80002318:	8c2080e7          	jalr	-1854(ra) # 80000bd6 <acquire>
  k = p->killed;
    8000231c:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002320:	8526                	mv	a0,s1
    80002322:	fffff097          	auipc	ra,0xfffff
    80002326:	968080e7          	jalr	-1688(ra) # 80000c8a <release>
  return k;
}
    8000232a:	854a                	mv	a0,s2
    8000232c:	60e2                	ld	ra,24(sp)
    8000232e:	6442                	ld	s0,16(sp)
    80002330:	64a2                	ld	s1,8(sp)
    80002332:	6902                	ld	s2,0(sp)
    80002334:	6105                	addi	sp,sp,32
    80002336:	8082                	ret

0000000080002338 <wait>:
{
    80002338:	715d                	addi	sp,sp,-80
    8000233a:	e486                	sd	ra,72(sp)
    8000233c:	e0a2                	sd	s0,64(sp)
    8000233e:	fc26                	sd	s1,56(sp)
    80002340:	f84a                	sd	s2,48(sp)
    80002342:	f44e                	sd	s3,40(sp)
    80002344:	f052                	sd	s4,32(sp)
    80002346:	ec56                	sd	s5,24(sp)
    80002348:	e85a                	sd	s6,16(sp)
    8000234a:	e45e                	sd	s7,8(sp)
    8000234c:	e062                	sd	s8,0(sp)
    8000234e:	0880                	addi	s0,sp,80
    80002350:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002352:	fffff097          	auipc	ra,0xfffff
    80002356:	65a080e7          	jalr	1626(ra) # 800019ac <myproc>
    8000235a:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000235c:	0000f517          	auipc	a0,0xf
    80002360:	84c50513          	addi	a0,a0,-1972 # 80010ba8 <wait_lock>
    80002364:	fffff097          	auipc	ra,0xfffff
    80002368:	872080e7          	jalr	-1934(ra) # 80000bd6 <acquire>
    havekids = 0;
    8000236c:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    8000236e:	4a15                	li	s4,5
        havekids = 1;
    80002370:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002372:	00015997          	auipc	s3,0x15
    80002376:	84e98993          	addi	s3,s3,-1970 # 80016bc0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000237a:	0000fc17          	auipc	s8,0xf
    8000237e:	82ec0c13          	addi	s8,s8,-2002 # 80010ba8 <wait_lock>
    havekids = 0;
    80002382:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002384:	0000f497          	auipc	s1,0xf
    80002388:	c3c48493          	addi	s1,s1,-964 # 80010fc0 <proc>
    8000238c:	a0bd                	j	800023fa <wait+0xc2>
          pid = pp->pid;
    8000238e:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002392:	000b0e63          	beqz	s6,800023ae <wait+0x76>
    80002396:	4691                	li	a3,4
    80002398:	02c48613          	addi	a2,s1,44
    8000239c:	85da                	mv	a1,s6
    8000239e:	05093503          	ld	a0,80(s2)
    800023a2:	fffff097          	auipc	ra,0xfffff
    800023a6:	2ca080e7          	jalr	714(ra) # 8000166c <copyout>
    800023aa:	02054563          	bltz	a0,800023d4 <wait+0x9c>
          freeproc(pp);
    800023ae:	8526                	mv	a0,s1
    800023b0:	fffff097          	auipc	ra,0xfffff
    800023b4:	7ae080e7          	jalr	1966(ra) # 80001b5e <freeproc>
          release(&pp->lock);
    800023b8:	8526                	mv	a0,s1
    800023ba:	fffff097          	auipc	ra,0xfffff
    800023be:	8d0080e7          	jalr	-1840(ra) # 80000c8a <release>
          release(&wait_lock);
    800023c2:	0000e517          	auipc	a0,0xe
    800023c6:	7e650513          	addi	a0,a0,2022 # 80010ba8 <wait_lock>
    800023ca:	fffff097          	auipc	ra,0xfffff
    800023ce:	8c0080e7          	jalr	-1856(ra) # 80000c8a <release>
          return pid;
    800023d2:	a0b5                	j	8000243e <wait+0x106>
            release(&pp->lock);
    800023d4:	8526                	mv	a0,s1
    800023d6:	fffff097          	auipc	ra,0xfffff
    800023da:	8b4080e7          	jalr	-1868(ra) # 80000c8a <release>
            release(&wait_lock);
    800023de:	0000e517          	auipc	a0,0xe
    800023e2:	7ca50513          	addi	a0,a0,1994 # 80010ba8 <wait_lock>
    800023e6:	fffff097          	auipc	ra,0xfffff
    800023ea:	8a4080e7          	jalr	-1884(ra) # 80000c8a <release>
            return -1;
    800023ee:	59fd                	li	s3,-1
    800023f0:	a0b9                	j	8000243e <wait+0x106>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800023f2:	17048493          	addi	s1,s1,368
    800023f6:	03348463          	beq	s1,s3,8000241e <wait+0xe6>
      if(pp->parent == p){
    800023fa:	7c9c                	ld	a5,56(s1)
    800023fc:	ff279be3          	bne	a5,s2,800023f2 <wait+0xba>
        acquire(&pp->lock);
    80002400:	8526                	mv	a0,s1
    80002402:	ffffe097          	auipc	ra,0xffffe
    80002406:	7d4080e7          	jalr	2004(ra) # 80000bd6 <acquire>
        if(pp->state == ZOMBIE){
    8000240a:	4c9c                	lw	a5,24(s1)
    8000240c:	f94781e3          	beq	a5,s4,8000238e <wait+0x56>
        release(&pp->lock);
    80002410:	8526                	mv	a0,s1
    80002412:	fffff097          	auipc	ra,0xfffff
    80002416:	878080e7          	jalr	-1928(ra) # 80000c8a <release>
        havekids = 1;
    8000241a:	8756                	mv	a4,s5
    8000241c:	bfd9                	j	800023f2 <wait+0xba>
    if(!havekids || killed(p)){
    8000241e:	c719                	beqz	a4,8000242c <wait+0xf4>
    80002420:	854a                	mv	a0,s2
    80002422:	00000097          	auipc	ra,0x0
    80002426:	ee4080e7          	jalr	-284(ra) # 80002306 <killed>
    8000242a:	c51d                	beqz	a0,80002458 <wait+0x120>
      release(&wait_lock);
    8000242c:	0000e517          	auipc	a0,0xe
    80002430:	77c50513          	addi	a0,a0,1916 # 80010ba8 <wait_lock>
    80002434:	fffff097          	auipc	ra,0xfffff
    80002438:	856080e7          	jalr	-1962(ra) # 80000c8a <release>
      return -1;
    8000243c:	59fd                	li	s3,-1
}
    8000243e:	854e                	mv	a0,s3
    80002440:	60a6                	ld	ra,72(sp)
    80002442:	6406                	ld	s0,64(sp)
    80002444:	74e2                	ld	s1,56(sp)
    80002446:	7942                	ld	s2,48(sp)
    80002448:	79a2                	ld	s3,40(sp)
    8000244a:	7a02                	ld	s4,32(sp)
    8000244c:	6ae2                	ld	s5,24(sp)
    8000244e:	6b42                	ld	s6,16(sp)
    80002450:	6ba2                	ld	s7,8(sp)
    80002452:	6c02                	ld	s8,0(sp)
    80002454:	6161                	addi	sp,sp,80
    80002456:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002458:	85e2                	mv	a1,s8
    8000245a:	854a                	mv	a0,s2
    8000245c:	00000097          	auipc	ra,0x0
    80002460:	c02080e7          	jalr	-1022(ra) # 8000205e <sleep>
    havekids = 0;
    80002464:	bf39                	j	80002382 <wait+0x4a>

0000000080002466 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002466:	7179                	addi	sp,sp,-48
    80002468:	f406                	sd	ra,40(sp)
    8000246a:	f022                	sd	s0,32(sp)
    8000246c:	ec26                	sd	s1,24(sp)
    8000246e:	e84a                	sd	s2,16(sp)
    80002470:	e44e                	sd	s3,8(sp)
    80002472:	e052                	sd	s4,0(sp)
    80002474:	1800                	addi	s0,sp,48
    80002476:	84aa                	mv	s1,a0
    80002478:	892e                	mv	s2,a1
    8000247a:	89b2                	mv	s3,a2
    8000247c:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000247e:	fffff097          	auipc	ra,0xfffff
    80002482:	52e080e7          	jalr	1326(ra) # 800019ac <myproc>
  if(user_dst){
    80002486:	c08d                	beqz	s1,800024a8 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002488:	86d2                	mv	a3,s4
    8000248a:	864e                	mv	a2,s3
    8000248c:	85ca                	mv	a1,s2
    8000248e:	6928                	ld	a0,80(a0)
    80002490:	fffff097          	auipc	ra,0xfffff
    80002494:	1dc080e7          	jalr	476(ra) # 8000166c <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002498:	70a2                	ld	ra,40(sp)
    8000249a:	7402                	ld	s0,32(sp)
    8000249c:	64e2                	ld	s1,24(sp)
    8000249e:	6942                	ld	s2,16(sp)
    800024a0:	69a2                	ld	s3,8(sp)
    800024a2:	6a02                	ld	s4,0(sp)
    800024a4:	6145                	addi	sp,sp,48
    800024a6:	8082                	ret
    memmove((char *)dst, src, len);
    800024a8:	000a061b          	sext.w	a2,s4
    800024ac:	85ce                	mv	a1,s3
    800024ae:	854a                	mv	a0,s2
    800024b0:	fffff097          	auipc	ra,0xfffff
    800024b4:	87e080e7          	jalr	-1922(ra) # 80000d2e <memmove>
    return 0;
    800024b8:	8526                	mv	a0,s1
    800024ba:	bff9                	j	80002498 <either_copyout+0x32>

00000000800024bc <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800024bc:	7179                	addi	sp,sp,-48
    800024be:	f406                	sd	ra,40(sp)
    800024c0:	f022                	sd	s0,32(sp)
    800024c2:	ec26                	sd	s1,24(sp)
    800024c4:	e84a                	sd	s2,16(sp)
    800024c6:	e44e                	sd	s3,8(sp)
    800024c8:	e052                	sd	s4,0(sp)
    800024ca:	1800                	addi	s0,sp,48
    800024cc:	892a                	mv	s2,a0
    800024ce:	84ae                	mv	s1,a1
    800024d0:	89b2                	mv	s3,a2
    800024d2:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024d4:	fffff097          	auipc	ra,0xfffff
    800024d8:	4d8080e7          	jalr	1240(ra) # 800019ac <myproc>
  if(user_src){
    800024dc:	c08d                	beqz	s1,800024fe <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800024de:	86d2                	mv	a3,s4
    800024e0:	864e                	mv	a2,s3
    800024e2:	85ca                	mv	a1,s2
    800024e4:	6928                	ld	a0,80(a0)
    800024e6:	fffff097          	auipc	ra,0xfffff
    800024ea:	212080e7          	jalr	530(ra) # 800016f8 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800024ee:	70a2                	ld	ra,40(sp)
    800024f0:	7402                	ld	s0,32(sp)
    800024f2:	64e2                	ld	s1,24(sp)
    800024f4:	6942                	ld	s2,16(sp)
    800024f6:	69a2                	ld	s3,8(sp)
    800024f8:	6a02                	ld	s4,0(sp)
    800024fa:	6145                	addi	sp,sp,48
    800024fc:	8082                	ret
    memmove(dst, (char*)src, len);
    800024fe:	000a061b          	sext.w	a2,s4
    80002502:	85ce                	mv	a1,s3
    80002504:	854a                	mv	a0,s2
    80002506:	fffff097          	auipc	ra,0xfffff
    8000250a:	828080e7          	jalr	-2008(ra) # 80000d2e <memmove>
    return 0;
    8000250e:	8526                	mv	a0,s1
    80002510:	bff9                	j	800024ee <either_copyin+0x32>

0000000080002512 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002512:	715d                	addi	sp,sp,-80
    80002514:	e486                	sd	ra,72(sp)
    80002516:	e0a2                	sd	s0,64(sp)
    80002518:	fc26                	sd	s1,56(sp)
    8000251a:	f84a                	sd	s2,48(sp)
    8000251c:	f44e                	sd	s3,40(sp)
    8000251e:	f052                	sd	s4,32(sp)
    80002520:	ec56                	sd	s5,24(sp)
    80002522:	e85a                	sd	s6,16(sp)
    80002524:	e45e                	sd	s7,8(sp)
    80002526:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002528:	00006517          	auipc	a0,0x6
    8000252c:	ff850513          	addi	a0,a0,-8 # 80008520 <syscalls+0xd0>
    80002530:	ffffe097          	auipc	ra,0xffffe
    80002534:	05a080e7          	jalr	90(ra) # 8000058a <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002538:	0000f497          	auipc	s1,0xf
    8000253c:	be048493          	addi	s1,s1,-1056 # 80011118 <proc+0x158>
    80002540:	00014917          	auipc	s2,0x14
    80002544:	7d890913          	addi	s2,s2,2008 # 80016d18 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002548:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000254a:	00006997          	auipc	s3,0x6
    8000254e:	d3698993          	addi	s3,s3,-714 # 80008280 <digits+0x240>
    // Agregamos el contador de veces que se ejecuto.
    printf("%d %s %s %d", p->pid, state, p->name, p->contador);
    80002552:	00006a97          	auipc	s5,0x6
    80002556:	d36a8a93          	addi	s5,s5,-714 # 80008288 <digits+0x248>
    printf("\n");
    8000255a:	00006a17          	auipc	s4,0x6
    8000255e:	fc6a0a13          	addi	s4,s4,-58 # 80008520 <syscalls+0xd0>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002562:	00006b97          	auipc	s7,0x6
    80002566:	d66b8b93          	addi	s7,s7,-666 # 800082c8 <states.0>
    8000256a:	a015                	j	8000258e <procdump+0x7c>
    printf("%d %s %s %d", p->pid, state, p->name, p->contador);
    8000256c:	4a98                	lw	a4,16(a3)
    8000256e:	ed86a583          	lw	a1,-296(a3)
    80002572:	8556                	mv	a0,s5
    80002574:	ffffe097          	auipc	ra,0xffffe
    80002578:	016080e7          	jalr	22(ra) # 8000058a <printf>
    printf("\n");
    8000257c:	8552                	mv	a0,s4
    8000257e:	ffffe097          	auipc	ra,0xffffe
    80002582:	00c080e7          	jalr	12(ra) # 8000058a <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002586:	17048493          	addi	s1,s1,368
    8000258a:	03248263          	beq	s1,s2,800025ae <procdump+0x9c>
    if(p->state == UNUSED)
    8000258e:	86a6                	mv	a3,s1
    80002590:	ec04a783          	lw	a5,-320(s1)
    80002594:	dbed                	beqz	a5,80002586 <procdump+0x74>
      state = "???";
    80002596:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002598:	fcfb6ae3          	bltu	s6,a5,8000256c <procdump+0x5a>
    8000259c:	02079713          	slli	a4,a5,0x20
    800025a0:	01d75793          	srli	a5,a4,0x1d
    800025a4:	97de                	add	a5,a5,s7
    800025a6:	6390                	ld	a2,0(a5)
    800025a8:	f271                	bnez	a2,8000256c <procdump+0x5a>
      state = "???";
    800025aa:	864e                	mv	a2,s3
    800025ac:	b7c1                	j	8000256c <procdump+0x5a>
  }
}
    800025ae:	60a6                	ld	ra,72(sp)
    800025b0:	6406                	ld	s0,64(sp)
    800025b2:	74e2                	ld	s1,56(sp)
    800025b4:	7942                	ld	s2,48(sp)
    800025b6:	79a2                	ld	s3,40(sp)
    800025b8:	7a02                	ld	s4,32(sp)
    800025ba:	6ae2                	ld	s5,24(sp)
    800025bc:	6b42                	ld	s6,16(sp)
    800025be:	6ba2                	ld	s7,8(sp)
    800025c0:	6161                	addi	sp,sp,80
    800025c2:	8082                	ret

00000000800025c4 <swtch>:
    800025c4:	00153023          	sd	ra,0(a0)
    800025c8:	00253423          	sd	sp,8(a0)
    800025cc:	e900                	sd	s0,16(a0)
    800025ce:	ed04                	sd	s1,24(a0)
    800025d0:	03253023          	sd	s2,32(a0)
    800025d4:	03353423          	sd	s3,40(a0)
    800025d8:	03453823          	sd	s4,48(a0)
    800025dc:	03553c23          	sd	s5,56(a0)
    800025e0:	05653023          	sd	s6,64(a0)
    800025e4:	05753423          	sd	s7,72(a0)
    800025e8:	05853823          	sd	s8,80(a0)
    800025ec:	05953c23          	sd	s9,88(a0)
    800025f0:	07a53023          	sd	s10,96(a0)
    800025f4:	07b53423          	sd	s11,104(a0)
    800025f8:	0005b083          	ld	ra,0(a1)
    800025fc:	0085b103          	ld	sp,8(a1)
    80002600:	6980                	ld	s0,16(a1)
    80002602:	6d84                	ld	s1,24(a1)
    80002604:	0205b903          	ld	s2,32(a1)
    80002608:	0285b983          	ld	s3,40(a1)
    8000260c:	0305ba03          	ld	s4,48(a1)
    80002610:	0385ba83          	ld	s5,56(a1)
    80002614:	0405bb03          	ld	s6,64(a1)
    80002618:	0485bb83          	ld	s7,72(a1)
    8000261c:	0505bc03          	ld	s8,80(a1)
    80002620:	0585bc83          	ld	s9,88(a1)
    80002624:	0605bd03          	ld	s10,96(a1)
    80002628:	0685bd83          	ld	s11,104(a1)
    8000262c:	8082                	ret

000000008000262e <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000262e:	1141                	addi	sp,sp,-16
    80002630:	e406                	sd	ra,8(sp)
    80002632:	e022                	sd	s0,0(sp)
    80002634:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002636:	00006597          	auipc	a1,0x6
    8000263a:	cc258593          	addi	a1,a1,-830 # 800082f8 <states.0+0x30>
    8000263e:	00014517          	auipc	a0,0x14
    80002642:	58250513          	addi	a0,a0,1410 # 80016bc0 <tickslock>
    80002646:	ffffe097          	auipc	ra,0xffffe
    8000264a:	500080e7          	jalr	1280(ra) # 80000b46 <initlock>
}
    8000264e:	60a2                	ld	ra,8(sp)
    80002650:	6402                	ld	s0,0(sp)
    80002652:	0141                	addi	sp,sp,16
    80002654:	8082                	ret

0000000080002656 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002656:	1141                	addi	sp,sp,-16
    80002658:	e422                	sd	s0,8(sp)
    8000265a:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000265c:	00003797          	auipc	a5,0x3
    80002660:	52478793          	addi	a5,a5,1316 # 80005b80 <kernelvec>
    80002664:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002668:	6422                	ld	s0,8(sp)
    8000266a:	0141                	addi	sp,sp,16
    8000266c:	8082                	ret

000000008000266e <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    8000266e:	1141                	addi	sp,sp,-16
    80002670:	e406                	sd	ra,8(sp)
    80002672:	e022                	sd	s0,0(sp)
    80002674:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002676:	fffff097          	auipc	ra,0xfffff
    8000267a:	336080e7          	jalr	822(ra) # 800019ac <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000267e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002682:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002684:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002688:	00005697          	auipc	a3,0x5
    8000268c:	97868693          	addi	a3,a3,-1672 # 80007000 <_trampoline>
    80002690:	00005717          	auipc	a4,0x5
    80002694:	97070713          	addi	a4,a4,-1680 # 80007000 <_trampoline>
    80002698:	8f15                	sub	a4,a4,a3
    8000269a:	040007b7          	lui	a5,0x4000
    8000269e:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    800026a0:	07b2                	slli	a5,a5,0xc
    800026a2:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026a4:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800026a8:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800026aa:	18002673          	csrr	a2,satp
    800026ae:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800026b0:	6d30                	ld	a2,88(a0)
    800026b2:	6138                	ld	a4,64(a0)
    800026b4:	6585                	lui	a1,0x1
    800026b6:	972e                	add	a4,a4,a1
    800026b8:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800026ba:	6d38                	ld	a4,88(a0)
    800026bc:	00000617          	auipc	a2,0x0
    800026c0:	13060613          	addi	a2,a2,304 # 800027ec <usertrap>
    800026c4:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800026c6:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800026c8:	8612                	mv	a2,tp
    800026ca:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026cc:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800026d0:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800026d4:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026d8:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800026dc:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800026de:	6f18                	ld	a4,24(a4)
    800026e0:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800026e4:	6928                	ld	a0,80(a0)
    800026e6:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800026e8:	00005717          	auipc	a4,0x5
    800026ec:	9b470713          	addi	a4,a4,-1612 # 8000709c <userret>
    800026f0:	8f15                	sub	a4,a4,a3
    800026f2:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800026f4:	577d                	li	a4,-1
    800026f6:	177e                	slli	a4,a4,0x3f
    800026f8:	8d59                	or	a0,a0,a4
    800026fa:	9782                	jalr	a5
}
    800026fc:	60a2                	ld	ra,8(sp)
    800026fe:	6402                	ld	s0,0(sp)
    80002700:	0141                	addi	sp,sp,16
    80002702:	8082                	ret

0000000080002704 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002704:	1101                	addi	sp,sp,-32
    80002706:	ec06                	sd	ra,24(sp)
    80002708:	e822                	sd	s0,16(sp)
    8000270a:	e426                	sd	s1,8(sp)
    8000270c:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    8000270e:	00014497          	auipc	s1,0x14
    80002712:	4b248493          	addi	s1,s1,1202 # 80016bc0 <tickslock>
    80002716:	8526                	mv	a0,s1
    80002718:	ffffe097          	auipc	ra,0xffffe
    8000271c:	4be080e7          	jalr	1214(ra) # 80000bd6 <acquire>
  ticks++;
    80002720:	00006517          	auipc	a0,0x6
    80002724:	20050513          	addi	a0,a0,512 # 80008920 <ticks>
    80002728:	411c                	lw	a5,0(a0)
    8000272a:	2785                	addiw	a5,a5,1
    8000272c:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    8000272e:	00000097          	auipc	ra,0x0
    80002732:	994080e7          	jalr	-1644(ra) # 800020c2 <wakeup>
  release(&tickslock);
    80002736:	8526                	mv	a0,s1
    80002738:	ffffe097          	auipc	ra,0xffffe
    8000273c:	552080e7          	jalr	1362(ra) # 80000c8a <release>
}
    80002740:	60e2                	ld	ra,24(sp)
    80002742:	6442                	ld	s0,16(sp)
    80002744:	64a2                	ld	s1,8(sp)
    80002746:	6105                	addi	sp,sp,32
    80002748:	8082                	ret

000000008000274a <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    8000274a:	1101                	addi	sp,sp,-32
    8000274c:	ec06                	sd	ra,24(sp)
    8000274e:	e822                	sd	s0,16(sp)
    80002750:	e426                	sd	s1,8(sp)
    80002752:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002754:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002758:	00074d63          	bltz	a4,80002772 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    8000275c:	57fd                	li	a5,-1
    8000275e:	17fe                	slli	a5,a5,0x3f
    80002760:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002762:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002764:	06f70363          	beq	a4,a5,800027ca <devintr+0x80>
  }
}
    80002768:	60e2                	ld	ra,24(sp)
    8000276a:	6442                	ld	s0,16(sp)
    8000276c:	64a2                	ld	s1,8(sp)
    8000276e:	6105                	addi	sp,sp,32
    80002770:	8082                	ret
     (scause & 0xff) == 9){
    80002772:	0ff77793          	zext.b	a5,a4
  if((scause & 0x8000000000000000L) &&
    80002776:	46a5                	li	a3,9
    80002778:	fed792e3          	bne	a5,a3,8000275c <devintr+0x12>
    int irq = plic_claim();
    8000277c:	00003097          	auipc	ra,0x3
    80002780:	50c080e7          	jalr	1292(ra) # 80005c88 <plic_claim>
    80002784:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002786:	47a9                	li	a5,10
    80002788:	02f50763          	beq	a0,a5,800027b6 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    8000278c:	4785                	li	a5,1
    8000278e:	02f50963          	beq	a0,a5,800027c0 <devintr+0x76>
    return 1;
    80002792:	4505                	li	a0,1
    } else if(irq){
    80002794:	d8f1                	beqz	s1,80002768 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002796:	85a6                	mv	a1,s1
    80002798:	00006517          	auipc	a0,0x6
    8000279c:	b6850513          	addi	a0,a0,-1176 # 80008300 <states.0+0x38>
    800027a0:	ffffe097          	auipc	ra,0xffffe
    800027a4:	dea080e7          	jalr	-534(ra) # 8000058a <printf>
      plic_complete(irq);
    800027a8:	8526                	mv	a0,s1
    800027aa:	00003097          	auipc	ra,0x3
    800027ae:	502080e7          	jalr	1282(ra) # 80005cac <plic_complete>
    return 1;
    800027b2:	4505                	li	a0,1
    800027b4:	bf55                	j	80002768 <devintr+0x1e>
      uartintr();
    800027b6:	ffffe097          	auipc	ra,0xffffe
    800027ba:	1e2080e7          	jalr	482(ra) # 80000998 <uartintr>
    800027be:	b7ed                	j	800027a8 <devintr+0x5e>
      virtio_disk_intr();
    800027c0:	00004097          	auipc	ra,0x4
    800027c4:	9b4080e7          	jalr	-1612(ra) # 80006174 <virtio_disk_intr>
    800027c8:	b7c5                	j	800027a8 <devintr+0x5e>
    if(cpuid() == 0){
    800027ca:	fffff097          	auipc	ra,0xfffff
    800027ce:	1b6080e7          	jalr	438(ra) # 80001980 <cpuid>
    800027d2:	c901                	beqz	a0,800027e2 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    800027d4:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    800027d8:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    800027da:	14479073          	csrw	sip,a5
    return 2;
    800027de:	4509                	li	a0,2
    800027e0:	b761                	j	80002768 <devintr+0x1e>
      clockintr();
    800027e2:	00000097          	auipc	ra,0x0
    800027e6:	f22080e7          	jalr	-222(ra) # 80002704 <clockintr>
    800027ea:	b7ed                	j	800027d4 <devintr+0x8a>

00000000800027ec <usertrap>:
{
    800027ec:	1101                	addi	sp,sp,-32
    800027ee:	ec06                	sd	ra,24(sp)
    800027f0:	e822                	sd	s0,16(sp)
    800027f2:	e426                	sd	s1,8(sp)
    800027f4:	e04a                	sd	s2,0(sp)
    800027f6:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027f8:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800027fc:	1007f793          	andi	a5,a5,256
    80002800:	e3b1                	bnez	a5,80002844 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002802:	00003797          	auipc	a5,0x3
    80002806:	37e78793          	addi	a5,a5,894 # 80005b80 <kernelvec>
    8000280a:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    8000280e:	fffff097          	auipc	ra,0xfffff
    80002812:	19e080e7          	jalr	414(ra) # 800019ac <myproc>
    80002816:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002818:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000281a:	14102773          	csrr	a4,sepc
    8000281e:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002820:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002824:	47a1                	li	a5,8
    80002826:	02f70763          	beq	a4,a5,80002854 <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    8000282a:	00000097          	auipc	ra,0x0
    8000282e:	f20080e7          	jalr	-224(ra) # 8000274a <devintr>
    80002832:	892a                	mv	s2,a0
    80002834:	c151                	beqz	a0,800028b8 <usertrap+0xcc>
  if(killed(p))
    80002836:	8526                	mv	a0,s1
    80002838:	00000097          	auipc	ra,0x0
    8000283c:	ace080e7          	jalr	-1330(ra) # 80002306 <killed>
    80002840:	c929                	beqz	a0,80002892 <usertrap+0xa6>
    80002842:	a099                	j	80002888 <usertrap+0x9c>
    panic("usertrap: not from user mode");
    80002844:	00006517          	auipc	a0,0x6
    80002848:	adc50513          	addi	a0,a0,-1316 # 80008320 <states.0+0x58>
    8000284c:	ffffe097          	auipc	ra,0xffffe
    80002850:	cf4080e7          	jalr	-780(ra) # 80000540 <panic>
    if(killed(p))
    80002854:	00000097          	auipc	ra,0x0
    80002858:	ab2080e7          	jalr	-1358(ra) # 80002306 <killed>
    8000285c:	e921                	bnez	a0,800028ac <usertrap+0xc0>
    p->trapframe->epc += 4;
    8000285e:	6cb8                	ld	a4,88(s1)
    80002860:	6f1c                	ld	a5,24(a4)
    80002862:	0791                	addi	a5,a5,4
    80002864:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002866:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000286a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000286e:	10079073          	csrw	sstatus,a5
    syscall();
    80002872:	00000097          	auipc	ra,0x0
    80002876:	2d4080e7          	jalr	724(ra) # 80002b46 <syscall>
  if(killed(p))
    8000287a:	8526                	mv	a0,s1
    8000287c:	00000097          	auipc	ra,0x0
    80002880:	a8a080e7          	jalr	-1398(ra) # 80002306 <killed>
    80002884:	c911                	beqz	a0,80002898 <usertrap+0xac>
    80002886:	4901                	li	s2,0
    exit(-1);
    80002888:	557d                	li	a0,-1
    8000288a:	00000097          	auipc	ra,0x0
    8000288e:	908080e7          	jalr	-1784(ra) # 80002192 <exit>
  if(which_dev == 2)
    80002892:	4789                	li	a5,2
    80002894:	04f90f63          	beq	s2,a5,800028f2 <usertrap+0x106>
  usertrapret();
    80002898:	00000097          	auipc	ra,0x0
    8000289c:	dd6080e7          	jalr	-554(ra) # 8000266e <usertrapret>
}
    800028a0:	60e2                	ld	ra,24(sp)
    800028a2:	6442                	ld	s0,16(sp)
    800028a4:	64a2                	ld	s1,8(sp)
    800028a6:	6902                	ld	s2,0(sp)
    800028a8:	6105                	addi	sp,sp,32
    800028aa:	8082                	ret
      exit(-1);
    800028ac:	557d                	li	a0,-1
    800028ae:	00000097          	auipc	ra,0x0
    800028b2:	8e4080e7          	jalr	-1820(ra) # 80002192 <exit>
    800028b6:	b765                	j	8000285e <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028b8:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    800028bc:	5890                	lw	a2,48(s1)
    800028be:	00006517          	auipc	a0,0x6
    800028c2:	a8250513          	addi	a0,a0,-1406 # 80008340 <states.0+0x78>
    800028c6:	ffffe097          	auipc	ra,0xffffe
    800028ca:	cc4080e7          	jalr	-828(ra) # 8000058a <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028ce:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800028d2:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    800028d6:	00006517          	auipc	a0,0x6
    800028da:	a9a50513          	addi	a0,a0,-1382 # 80008370 <states.0+0xa8>
    800028de:	ffffe097          	auipc	ra,0xffffe
    800028e2:	cac080e7          	jalr	-852(ra) # 8000058a <printf>
    setkilled(p);
    800028e6:	8526                	mv	a0,s1
    800028e8:	00000097          	auipc	ra,0x0
    800028ec:	9f2080e7          	jalr	-1550(ra) # 800022da <setkilled>
    800028f0:	b769                	j	8000287a <usertrap+0x8e>
    yield();
    800028f2:	fffff097          	auipc	ra,0xfffff
    800028f6:	730080e7          	jalr	1840(ra) # 80002022 <yield>
    800028fa:	bf79                	j	80002898 <usertrap+0xac>

00000000800028fc <kerneltrap>:
{
    800028fc:	7179                	addi	sp,sp,-48
    800028fe:	f406                	sd	ra,40(sp)
    80002900:	f022                	sd	s0,32(sp)
    80002902:	ec26                	sd	s1,24(sp)
    80002904:	e84a                	sd	s2,16(sp)
    80002906:	e44e                	sd	s3,8(sp)
    80002908:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000290a:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000290e:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002912:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002916:	1004f793          	andi	a5,s1,256
    8000291a:	cb85                	beqz	a5,8000294a <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000291c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002920:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002922:	ef85                	bnez	a5,8000295a <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002924:	00000097          	auipc	ra,0x0
    80002928:	e26080e7          	jalr	-474(ra) # 8000274a <devintr>
    8000292c:	cd1d                	beqz	a0,8000296a <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    8000292e:	4789                	li	a5,2
    80002930:	06f50a63          	beq	a0,a5,800029a4 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002934:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002938:	10049073          	csrw	sstatus,s1
}
    8000293c:	70a2                	ld	ra,40(sp)
    8000293e:	7402                	ld	s0,32(sp)
    80002940:	64e2                	ld	s1,24(sp)
    80002942:	6942                	ld	s2,16(sp)
    80002944:	69a2                	ld	s3,8(sp)
    80002946:	6145                	addi	sp,sp,48
    80002948:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    8000294a:	00006517          	auipc	a0,0x6
    8000294e:	a4650513          	addi	a0,a0,-1466 # 80008390 <states.0+0xc8>
    80002952:	ffffe097          	auipc	ra,0xffffe
    80002956:	bee080e7          	jalr	-1042(ra) # 80000540 <panic>
    panic("kerneltrap: interrupts enabled");
    8000295a:	00006517          	auipc	a0,0x6
    8000295e:	a5e50513          	addi	a0,a0,-1442 # 800083b8 <states.0+0xf0>
    80002962:	ffffe097          	auipc	ra,0xffffe
    80002966:	bde080e7          	jalr	-1058(ra) # 80000540 <panic>
    printf("scause %p\n", scause);
    8000296a:	85ce                	mv	a1,s3
    8000296c:	00006517          	auipc	a0,0x6
    80002970:	a6c50513          	addi	a0,a0,-1428 # 800083d8 <states.0+0x110>
    80002974:	ffffe097          	auipc	ra,0xffffe
    80002978:	c16080e7          	jalr	-1002(ra) # 8000058a <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000297c:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002980:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002984:	00006517          	auipc	a0,0x6
    80002988:	a6450513          	addi	a0,a0,-1436 # 800083e8 <states.0+0x120>
    8000298c:	ffffe097          	auipc	ra,0xffffe
    80002990:	bfe080e7          	jalr	-1026(ra) # 8000058a <printf>
    panic("kerneltrap");
    80002994:	00006517          	auipc	a0,0x6
    80002998:	a6c50513          	addi	a0,a0,-1428 # 80008400 <states.0+0x138>
    8000299c:	ffffe097          	auipc	ra,0xffffe
    800029a0:	ba4080e7          	jalr	-1116(ra) # 80000540 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800029a4:	fffff097          	auipc	ra,0xfffff
    800029a8:	008080e7          	jalr	8(ra) # 800019ac <myproc>
    800029ac:	d541                	beqz	a0,80002934 <kerneltrap+0x38>
    800029ae:	fffff097          	auipc	ra,0xfffff
    800029b2:	ffe080e7          	jalr	-2(ra) # 800019ac <myproc>
    800029b6:	4d18                	lw	a4,24(a0)
    800029b8:	4791                	li	a5,4
    800029ba:	f6f71de3          	bne	a4,a5,80002934 <kerneltrap+0x38>
    yield();
    800029be:	fffff097          	auipc	ra,0xfffff
    800029c2:	664080e7          	jalr	1636(ra) # 80002022 <yield>
    800029c6:	b7bd                	j	80002934 <kerneltrap+0x38>

00000000800029c8 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800029c8:	1101                	addi	sp,sp,-32
    800029ca:	ec06                	sd	ra,24(sp)
    800029cc:	e822                	sd	s0,16(sp)
    800029ce:	e426                	sd	s1,8(sp)
    800029d0:	1000                	addi	s0,sp,32
    800029d2:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800029d4:	fffff097          	auipc	ra,0xfffff
    800029d8:	fd8080e7          	jalr	-40(ra) # 800019ac <myproc>
  switch (n) {
    800029dc:	4795                	li	a5,5
    800029de:	0497e163          	bltu	a5,s1,80002a20 <argraw+0x58>
    800029e2:	048a                	slli	s1,s1,0x2
    800029e4:	00006717          	auipc	a4,0x6
    800029e8:	a5470713          	addi	a4,a4,-1452 # 80008438 <states.0+0x170>
    800029ec:	94ba                	add	s1,s1,a4
    800029ee:	409c                	lw	a5,0(s1)
    800029f0:	97ba                	add	a5,a5,a4
    800029f2:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    800029f4:	6d3c                	ld	a5,88(a0)
    800029f6:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800029f8:	60e2                	ld	ra,24(sp)
    800029fa:	6442                	ld	s0,16(sp)
    800029fc:	64a2                	ld	s1,8(sp)
    800029fe:	6105                	addi	sp,sp,32
    80002a00:	8082                	ret
    return p->trapframe->a1;
    80002a02:	6d3c                	ld	a5,88(a0)
    80002a04:	7fa8                	ld	a0,120(a5)
    80002a06:	bfcd                	j	800029f8 <argraw+0x30>
    return p->trapframe->a2;
    80002a08:	6d3c                	ld	a5,88(a0)
    80002a0a:	63c8                	ld	a0,128(a5)
    80002a0c:	b7f5                	j	800029f8 <argraw+0x30>
    return p->trapframe->a3;
    80002a0e:	6d3c                	ld	a5,88(a0)
    80002a10:	67c8                	ld	a0,136(a5)
    80002a12:	b7dd                	j	800029f8 <argraw+0x30>
    return p->trapframe->a4;
    80002a14:	6d3c                	ld	a5,88(a0)
    80002a16:	6bc8                	ld	a0,144(a5)
    80002a18:	b7c5                	j	800029f8 <argraw+0x30>
    return p->trapframe->a5;
    80002a1a:	6d3c                	ld	a5,88(a0)
    80002a1c:	6fc8                	ld	a0,152(a5)
    80002a1e:	bfe9                	j	800029f8 <argraw+0x30>
  panic("argraw");
    80002a20:	00006517          	auipc	a0,0x6
    80002a24:	9f050513          	addi	a0,a0,-1552 # 80008410 <states.0+0x148>
    80002a28:	ffffe097          	auipc	ra,0xffffe
    80002a2c:	b18080e7          	jalr	-1256(ra) # 80000540 <panic>

0000000080002a30 <fetchaddr>:
{
    80002a30:	1101                	addi	sp,sp,-32
    80002a32:	ec06                	sd	ra,24(sp)
    80002a34:	e822                	sd	s0,16(sp)
    80002a36:	e426                	sd	s1,8(sp)
    80002a38:	e04a                	sd	s2,0(sp)
    80002a3a:	1000                	addi	s0,sp,32
    80002a3c:	84aa                	mv	s1,a0
    80002a3e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002a40:	fffff097          	auipc	ra,0xfffff
    80002a44:	f6c080e7          	jalr	-148(ra) # 800019ac <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002a48:	653c                	ld	a5,72(a0)
    80002a4a:	02f4f863          	bgeu	s1,a5,80002a7a <fetchaddr+0x4a>
    80002a4e:	00848713          	addi	a4,s1,8
    80002a52:	02e7e663          	bltu	a5,a4,80002a7e <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002a56:	46a1                	li	a3,8
    80002a58:	8626                	mv	a2,s1
    80002a5a:	85ca                	mv	a1,s2
    80002a5c:	6928                	ld	a0,80(a0)
    80002a5e:	fffff097          	auipc	ra,0xfffff
    80002a62:	c9a080e7          	jalr	-870(ra) # 800016f8 <copyin>
    80002a66:	00a03533          	snez	a0,a0
    80002a6a:	40a00533          	neg	a0,a0
}
    80002a6e:	60e2                	ld	ra,24(sp)
    80002a70:	6442                	ld	s0,16(sp)
    80002a72:	64a2                	ld	s1,8(sp)
    80002a74:	6902                	ld	s2,0(sp)
    80002a76:	6105                	addi	sp,sp,32
    80002a78:	8082                	ret
    return -1;
    80002a7a:	557d                	li	a0,-1
    80002a7c:	bfcd                	j	80002a6e <fetchaddr+0x3e>
    80002a7e:	557d                	li	a0,-1
    80002a80:	b7fd                	j	80002a6e <fetchaddr+0x3e>

0000000080002a82 <fetchstr>:
{
    80002a82:	7179                	addi	sp,sp,-48
    80002a84:	f406                	sd	ra,40(sp)
    80002a86:	f022                	sd	s0,32(sp)
    80002a88:	ec26                	sd	s1,24(sp)
    80002a8a:	e84a                	sd	s2,16(sp)
    80002a8c:	e44e                	sd	s3,8(sp)
    80002a8e:	1800                	addi	s0,sp,48
    80002a90:	892a                	mv	s2,a0
    80002a92:	84ae                	mv	s1,a1
    80002a94:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002a96:	fffff097          	auipc	ra,0xfffff
    80002a9a:	f16080e7          	jalr	-234(ra) # 800019ac <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002a9e:	86ce                	mv	a3,s3
    80002aa0:	864a                	mv	a2,s2
    80002aa2:	85a6                	mv	a1,s1
    80002aa4:	6928                	ld	a0,80(a0)
    80002aa6:	fffff097          	auipc	ra,0xfffff
    80002aaa:	ce0080e7          	jalr	-800(ra) # 80001786 <copyinstr>
    80002aae:	00054e63          	bltz	a0,80002aca <fetchstr+0x48>
  return strlen(buf);
    80002ab2:	8526                	mv	a0,s1
    80002ab4:	ffffe097          	auipc	ra,0xffffe
    80002ab8:	39a080e7          	jalr	922(ra) # 80000e4e <strlen>
}
    80002abc:	70a2                	ld	ra,40(sp)
    80002abe:	7402                	ld	s0,32(sp)
    80002ac0:	64e2                	ld	s1,24(sp)
    80002ac2:	6942                	ld	s2,16(sp)
    80002ac4:	69a2                	ld	s3,8(sp)
    80002ac6:	6145                	addi	sp,sp,48
    80002ac8:	8082                	ret
    return -1;
    80002aca:	557d                	li	a0,-1
    80002acc:	bfc5                	j	80002abc <fetchstr+0x3a>

0000000080002ace <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002ace:	1101                	addi	sp,sp,-32
    80002ad0:	ec06                	sd	ra,24(sp)
    80002ad2:	e822                	sd	s0,16(sp)
    80002ad4:	e426                	sd	s1,8(sp)
    80002ad6:	1000                	addi	s0,sp,32
    80002ad8:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002ada:	00000097          	auipc	ra,0x0
    80002ade:	eee080e7          	jalr	-274(ra) # 800029c8 <argraw>
    80002ae2:	c088                	sw	a0,0(s1)
}
    80002ae4:	60e2                	ld	ra,24(sp)
    80002ae6:	6442                	ld	s0,16(sp)
    80002ae8:	64a2                	ld	s1,8(sp)
    80002aea:	6105                	addi	sp,sp,32
    80002aec:	8082                	ret

0000000080002aee <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002aee:	1101                	addi	sp,sp,-32
    80002af0:	ec06                	sd	ra,24(sp)
    80002af2:	e822                	sd	s0,16(sp)
    80002af4:	e426                	sd	s1,8(sp)
    80002af6:	1000                	addi	s0,sp,32
    80002af8:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002afa:	00000097          	auipc	ra,0x0
    80002afe:	ece080e7          	jalr	-306(ra) # 800029c8 <argraw>
    80002b02:	e088                	sd	a0,0(s1)
}
    80002b04:	60e2                	ld	ra,24(sp)
    80002b06:	6442                	ld	s0,16(sp)
    80002b08:	64a2                	ld	s1,8(sp)
    80002b0a:	6105                	addi	sp,sp,32
    80002b0c:	8082                	ret

0000000080002b0e <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002b0e:	7179                	addi	sp,sp,-48
    80002b10:	f406                	sd	ra,40(sp)
    80002b12:	f022                	sd	s0,32(sp)
    80002b14:	ec26                	sd	s1,24(sp)
    80002b16:	e84a                	sd	s2,16(sp)
    80002b18:	1800                	addi	s0,sp,48
    80002b1a:	84ae                	mv	s1,a1
    80002b1c:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002b1e:	fd840593          	addi	a1,s0,-40
    80002b22:	00000097          	auipc	ra,0x0
    80002b26:	fcc080e7          	jalr	-52(ra) # 80002aee <argaddr>
  return fetchstr(addr, buf, max);
    80002b2a:	864a                	mv	a2,s2
    80002b2c:	85a6                	mv	a1,s1
    80002b2e:	fd843503          	ld	a0,-40(s0)
    80002b32:	00000097          	auipc	ra,0x0
    80002b36:	f50080e7          	jalr	-176(ra) # 80002a82 <fetchstr>
}
    80002b3a:	70a2                	ld	ra,40(sp)
    80002b3c:	7402                	ld	s0,32(sp)
    80002b3e:	64e2                	ld	s1,24(sp)
    80002b40:	6942                	ld	s2,16(sp)
    80002b42:	6145                	addi	sp,sp,48
    80002b44:	8082                	ret

0000000080002b46 <syscall>:
[SYS_pstat]   sys_pstat,
};

void
syscall(void)
{
    80002b46:	1101                	addi	sp,sp,-32
    80002b48:	ec06                	sd	ra,24(sp)
    80002b4a:	e822                	sd	s0,16(sp)
    80002b4c:	e426                	sd	s1,8(sp)
    80002b4e:	e04a                	sd	s2,0(sp)
    80002b50:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002b52:	fffff097          	auipc	ra,0xfffff
    80002b56:	e5a080e7          	jalr	-422(ra) # 800019ac <myproc>
    80002b5a:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002b5c:	05853903          	ld	s2,88(a0)
    80002b60:	0a893783          	ld	a5,168(s2)
    80002b64:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002b68:	37fd                	addiw	a5,a5,-1
    80002b6a:	4755                	li	a4,21
    80002b6c:	00f76f63          	bltu	a4,a5,80002b8a <syscall+0x44>
    80002b70:	00369713          	slli	a4,a3,0x3
    80002b74:	00006797          	auipc	a5,0x6
    80002b78:	8dc78793          	addi	a5,a5,-1828 # 80008450 <syscalls>
    80002b7c:	97ba                	add	a5,a5,a4
    80002b7e:	639c                	ld	a5,0(a5)
    80002b80:	c789                	beqz	a5,80002b8a <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002b82:	9782                	jalr	a5
    80002b84:	06a93823          	sd	a0,112(s2)
    80002b88:	a839                	j	80002ba6 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002b8a:	15848613          	addi	a2,s1,344
    80002b8e:	588c                	lw	a1,48(s1)
    80002b90:	00006517          	auipc	a0,0x6
    80002b94:	88850513          	addi	a0,a0,-1912 # 80008418 <states.0+0x150>
    80002b98:	ffffe097          	auipc	ra,0xffffe
    80002b9c:	9f2080e7          	jalr	-1550(ra) # 8000058a <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002ba0:	6cbc                	ld	a5,88(s1)
    80002ba2:	577d                	li	a4,-1
    80002ba4:	fbb8                	sd	a4,112(a5)
  }
}
    80002ba6:	60e2                	ld	ra,24(sp)
    80002ba8:	6442                	ld	s0,16(sp)
    80002baa:	64a2                	ld	s1,8(sp)
    80002bac:	6902                	ld	s2,0(sp)
    80002bae:	6105                	addi	sp,sp,32
    80002bb0:	8082                	ret

0000000080002bb2 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002bb2:	1101                	addi	sp,sp,-32
    80002bb4:	ec06                	sd	ra,24(sp)
    80002bb6:	e822                	sd	s0,16(sp)
    80002bb8:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002bba:	fec40593          	addi	a1,s0,-20
    80002bbe:	4501                	li	a0,0
    80002bc0:	00000097          	auipc	ra,0x0
    80002bc4:	f0e080e7          	jalr	-242(ra) # 80002ace <argint>
  exit(n);
    80002bc8:	fec42503          	lw	a0,-20(s0)
    80002bcc:	fffff097          	auipc	ra,0xfffff
    80002bd0:	5c6080e7          	jalr	1478(ra) # 80002192 <exit>
  return 0;  // not reached
}
    80002bd4:	4501                	li	a0,0
    80002bd6:	60e2                	ld	ra,24(sp)
    80002bd8:	6442                	ld	s0,16(sp)
    80002bda:	6105                	addi	sp,sp,32
    80002bdc:	8082                	ret

0000000080002bde <sys_getpid>:

uint64
sys_getpid(void)
{
    80002bde:	1141                	addi	sp,sp,-16
    80002be0:	e406                	sd	ra,8(sp)
    80002be2:	e022                	sd	s0,0(sp)
    80002be4:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002be6:	fffff097          	auipc	ra,0xfffff
    80002bea:	dc6080e7          	jalr	-570(ra) # 800019ac <myproc>
}
    80002bee:	5908                	lw	a0,48(a0)
    80002bf0:	60a2                	ld	ra,8(sp)
    80002bf2:	6402                	ld	s0,0(sp)
    80002bf4:	0141                	addi	sp,sp,16
    80002bf6:	8082                	ret

0000000080002bf8 <sys_fork>:

uint64
sys_fork(void)
{
    80002bf8:	1141                	addi	sp,sp,-16
    80002bfa:	e406                	sd	ra,8(sp)
    80002bfc:	e022                	sd	s0,0(sp)
    80002bfe:	0800                	addi	s0,sp,16
  return fork();
    80002c00:	fffff097          	auipc	ra,0xfffff
    80002c04:	162080e7          	jalr	354(ra) # 80001d62 <fork>
}
    80002c08:	60a2                	ld	ra,8(sp)
    80002c0a:	6402                	ld	s0,0(sp)
    80002c0c:	0141                	addi	sp,sp,16
    80002c0e:	8082                	ret

0000000080002c10 <sys_wait>:

uint64
sys_wait(void)
{
    80002c10:	1101                	addi	sp,sp,-32
    80002c12:	ec06                	sd	ra,24(sp)
    80002c14:	e822                	sd	s0,16(sp)
    80002c16:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002c18:	fe840593          	addi	a1,s0,-24
    80002c1c:	4501                	li	a0,0
    80002c1e:	00000097          	auipc	ra,0x0
    80002c22:	ed0080e7          	jalr	-304(ra) # 80002aee <argaddr>
  return wait(p);
    80002c26:	fe843503          	ld	a0,-24(s0)
    80002c2a:	fffff097          	auipc	ra,0xfffff
    80002c2e:	70e080e7          	jalr	1806(ra) # 80002338 <wait>
}
    80002c32:	60e2                	ld	ra,24(sp)
    80002c34:	6442                	ld	s0,16(sp)
    80002c36:	6105                	addi	sp,sp,32
    80002c38:	8082                	ret

0000000080002c3a <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002c3a:	7179                	addi	sp,sp,-48
    80002c3c:	f406                	sd	ra,40(sp)
    80002c3e:	f022                	sd	s0,32(sp)
    80002c40:	ec26                	sd	s1,24(sp)
    80002c42:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002c44:	fdc40593          	addi	a1,s0,-36
    80002c48:	4501                	li	a0,0
    80002c4a:	00000097          	auipc	ra,0x0
    80002c4e:	e84080e7          	jalr	-380(ra) # 80002ace <argint>
  addr = myproc()->sz;
    80002c52:	fffff097          	auipc	ra,0xfffff
    80002c56:	d5a080e7          	jalr	-678(ra) # 800019ac <myproc>
    80002c5a:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002c5c:	fdc42503          	lw	a0,-36(s0)
    80002c60:	fffff097          	auipc	ra,0xfffff
    80002c64:	0a6080e7          	jalr	166(ra) # 80001d06 <growproc>
    80002c68:	00054863          	bltz	a0,80002c78 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80002c6c:	8526                	mv	a0,s1
    80002c6e:	70a2                	ld	ra,40(sp)
    80002c70:	7402                	ld	s0,32(sp)
    80002c72:	64e2                	ld	s1,24(sp)
    80002c74:	6145                	addi	sp,sp,48
    80002c76:	8082                	ret
    return -1;
    80002c78:	54fd                	li	s1,-1
    80002c7a:	bfcd                	j	80002c6c <sys_sbrk+0x32>

0000000080002c7c <sys_sleep>:

uint64
sys_sleep(void)
{
    80002c7c:	7139                	addi	sp,sp,-64
    80002c7e:	fc06                	sd	ra,56(sp)
    80002c80:	f822                	sd	s0,48(sp)
    80002c82:	f426                	sd	s1,40(sp)
    80002c84:	f04a                	sd	s2,32(sp)
    80002c86:	ec4e                	sd	s3,24(sp)
    80002c88:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002c8a:	fcc40593          	addi	a1,s0,-52
    80002c8e:	4501                	li	a0,0
    80002c90:	00000097          	auipc	ra,0x0
    80002c94:	e3e080e7          	jalr	-450(ra) # 80002ace <argint>
  acquire(&tickslock);
    80002c98:	00014517          	auipc	a0,0x14
    80002c9c:	f2850513          	addi	a0,a0,-216 # 80016bc0 <tickslock>
    80002ca0:	ffffe097          	auipc	ra,0xffffe
    80002ca4:	f36080e7          	jalr	-202(ra) # 80000bd6 <acquire>
  ticks0 = ticks;
    80002ca8:	00006917          	auipc	s2,0x6
    80002cac:	c7892903          	lw	s2,-904(s2) # 80008920 <ticks>
  while(ticks - ticks0 < n){
    80002cb0:	fcc42783          	lw	a5,-52(s0)
    80002cb4:	cf9d                	beqz	a5,80002cf2 <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002cb6:	00014997          	auipc	s3,0x14
    80002cba:	f0a98993          	addi	s3,s3,-246 # 80016bc0 <tickslock>
    80002cbe:	00006497          	auipc	s1,0x6
    80002cc2:	c6248493          	addi	s1,s1,-926 # 80008920 <ticks>
    if(killed(myproc())){
    80002cc6:	fffff097          	auipc	ra,0xfffff
    80002cca:	ce6080e7          	jalr	-794(ra) # 800019ac <myproc>
    80002cce:	fffff097          	auipc	ra,0xfffff
    80002cd2:	638080e7          	jalr	1592(ra) # 80002306 <killed>
    80002cd6:	ed15                	bnez	a0,80002d12 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002cd8:	85ce                	mv	a1,s3
    80002cda:	8526                	mv	a0,s1
    80002cdc:	fffff097          	auipc	ra,0xfffff
    80002ce0:	382080e7          	jalr	898(ra) # 8000205e <sleep>
  while(ticks - ticks0 < n){
    80002ce4:	409c                	lw	a5,0(s1)
    80002ce6:	412787bb          	subw	a5,a5,s2
    80002cea:	fcc42703          	lw	a4,-52(s0)
    80002cee:	fce7ece3          	bltu	a5,a4,80002cc6 <sys_sleep+0x4a>
  }
  release(&tickslock);
    80002cf2:	00014517          	auipc	a0,0x14
    80002cf6:	ece50513          	addi	a0,a0,-306 # 80016bc0 <tickslock>
    80002cfa:	ffffe097          	auipc	ra,0xffffe
    80002cfe:	f90080e7          	jalr	-112(ra) # 80000c8a <release>
  return 0;
    80002d02:	4501                	li	a0,0
}
    80002d04:	70e2                	ld	ra,56(sp)
    80002d06:	7442                	ld	s0,48(sp)
    80002d08:	74a2                	ld	s1,40(sp)
    80002d0a:	7902                	ld	s2,32(sp)
    80002d0c:	69e2                	ld	s3,24(sp)
    80002d0e:	6121                	addi	sp,sp,64
    80002d10:	8082                	ret
      release(&tickslock);
    80002d12:	00014517          	auipc	a0,0x14
    80002d16:	eae50513          	addi	a0,a0,-338 # 80016bc0 <tickslock>
    80002d1a:	ffffe097          	auipc	ra,0xffffe
    80002d1e:	f70080e7          	jalr	-144(ra) # 80000c8a <release>
      return -1;
    80002d22:	557d                	li	a0,-1
    80002d24:	b7c5                	j	80002d04 <sys_sleep+0x88>

0000000080002d26 <sys_kill>:

uint64
sys_kill(void)
{
    80002d26:	1101                	addi	sp,sp,-32
    80002d28:	ec06                	sd	ra,24(sp)
    80002d2a:	e822                	sd	s0,16(sp)
    80002d2c:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002d2e:	fec40593          	addi	a1,s0,-20
    80002d32:	4501                	li	a0,0
    80002d34:	00000097          	auipc	ra,0x0
    80002d38:	d9a080e7          	jalr	-614(ra) # 80002ace <argint>
  return kill(pid);
    80002d3c:	fec42503          	lw	a0,-20(s0)
    80002d40:	fffff097          	auipc	ra,0xfffff
    80002d44:	528080e7          	jalr	1320(ra) # 80002268 <kill>
}
    80002d48:	60e2                	ld	ra,24(sp)
    80002d4a:	6442                	ld	s0,16(sp)
    80002d4c:	6105                	addi	sp,sp,32
    80002d4e:	8082                	ret

0000000080002d50 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002d50:	1101                	addi	sp,sp,-32
    80002d52:	ec06                	sd	ra,24(sp)
    80002d54:	e822                	sd	s0,16(sp)
    80002d56:	e426                	sd	s1,8(sp)
    80002d58:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002d5a:	00014517          	auipc	a0,0x14
    80002d5e:	e6650513          	addi	a0,a0,-410 # 80016bc0 <tickslock>
    80002d62:	ffffe097          	auipc	ra,0xffffe
    80002d66:	e74080e7          	jalr	-396(ra) # 80000bd6 <acquire>
  xticks = ticks;
    80002d6a:	00006497          	auipc	s1,0x6
    80002d6e:	bb64a483          	lw	s1,-1098(s1) # 80008920 <ticks>
  release(&tickslock);
    80002d72:	00014517          	auipc	a0,0x14
    80002d76:	e4e50513          	addi	a0,a0,-434 # 80016bc0 <tickslock>
    80002d7a:	ffffe097          	auipc	ra,0xffffe
    80002d7e:	f10080e7          	jalr	-240(ra) # 80000c8a <release>
  return xticks;
}
    80002d82:	02049513          	slli	a0,s1,0x20
    80002d86:	9101                	srli	a0,a0,0x20
    80002d88:	60e2                	ld	ra,24(sp)
    80002d8a:	6442                	ld	s0,16(sp)
    80002d8c:	64a2                	ld	s1,8(sp)
    80002d8e:	6105                	addi	sp,sp,32
    80002d90:	8082                	ret

0000000080002d92 <sys_pstat>:

uint64 
sys_pstat()
{
    80002d92:	1101                	addi	sp,sp,-32
    80002d94:	ec06                	sd	ra,24(sp)
    80002d96:	e822                	sd	s0,16(sp)
    80002d98:	1000                	addi	s0,sp,32
  int pid;
  argint(0, &pid);
    80002d9a:	fec40593          	addi	a1,s0,-20
    80002d9e:	4501                	li	a0,0
    80002da0:	00000097          	auipc	ra,0x0
    80002da4:	d2e080e7          	jalr	-722(ra) # 80002ace <argint>
  
  printf("Number of times run: %d \n",cpus[1].proc[pid].contador); 
    80002da8:	fec42703          	lw	a4,-20(s0)
    80002dac:	17000793          	li	a5,368
    80002db0:	02f70733          	mul	a4,a4,a5
    80002db4:	0000e797          	auipc	a5,0xe
    80002db8:	e8c7b783          	ld	a5,-372(a5) # 80010c40 <cpus+0x80>
    80002dbc:	97ba                	add	a5,a5,a4
    80002dbe:	1687a583          	lw	a1,360(a5)
    80002dc2:	00005517          	auipc	a0,0x5
    80002dc6:	74650513          	addi	a0,a0,1862 # 80008508 <syscalls+0xb8>
    80002dca:	ffffd097          	auipc	ra,0xffffd
    80002dce:	7c0080e7          	jalr	1984(ra) # 8000058a <printf>
  printf ("Priority: 0 \n");
    80002dd2:	00005517          	auipc	a0,0x5
    80002dd6:	75650513          	addi	a0,a0,1878 # 80008528 <syscalls+0xd8>
    80002dda:	ffffd097          	auipc	ra,0xffffd
    80002dde:	7b0080e7          	jalr	1968(ra) # 8000058a <printf>

return 1;
    80002de2:	4505                	li	a0,1
    80002de4:	60e2                	ld	ra,24(sp)
    80002de6:	6442                	ld	s0,16(sp)
    80002de8:	6105                	addi	sp,sp,32
    80002dea:	8082                	ret

0000000080002dec <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002dec:	7179                	addi	sp,sp,-48
    80002dee:	f406                	sd	ra,40(sp)
    80002df0:	f022                	sd	s0,32(sp)
    80002df2:	ec26                	sd	s1,24(sp)
    80002df4:	e84a                	sd	s2,16(sp)
    80002df6:	e44e                	sd	s3,8(sp)
    80002df8:	e052                	sd	s4,0(sp)
    80002dfa:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002dfc:	00005597          	auipc	a1,0x5
    80002e00:	73c58593          	addi	a1,a1,1852 # 80008538 <syscalls+0xe8>
    80002e04:	00014517          	auipc	a0,0x14
    80002e08:	dd450513          	addi	a0,a0,-556 # 80016bd8 <bcache>
    80002e0c:	ffffe097          	auipc	ra,0xffffe
    80002e10:	d3a080e7          	jalr	-710(ra) # 80000b46 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002e14:	0001c797          	auipc	a5,0x1c
    80002e18:	dc478793          	addi	a5,a5,-572 # 8001ebd8 <bcache+0x8000>
    80002e1c:	0001c717          	auipc	a4,0x1c
    80002e20:	02470713          	addi	a4,a4,36 # 8001ee40 <bcache+0x8268>
    80002e24:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002e28:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002e2c:	00014497          	auipc	s1,0x14
    80002e30:	dc448493          	addi	s1,s1,-572 # 80016bf0 <bcache+0x18>
    b->next = bcache.head.next;
    80002e34:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002e36:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002e38:	00005a17          	auipc	s4,0x5
    80002e3c:	708a0a13          	addi	s4,s4,1800 # 80008540 <syscalls+0xf0>
    b->next = bcache.head.next;
    80002e40:	2b893783          	ld	a5,696(s2)
    80002e44:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002e46:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002e4a:	85d2                	mv	a1,s4
    80002e4c:	01048513          	addi	a0,s1,16
    80002e50:	00001097          	auipc	ra,0x1
    80002e54:	4c8080e7          	jalr	1224(ra) # 80004318 <initsleeplock>
    bcache.head.next->prev = b;
    80002e58:	2b893783          	ld	a5,696(s2)
    80002e5c:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002e5e:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002e62:	45848493          	addi	s1,s1,1112
    80002e66:	fd349de3          	bne	s1,s3,80002e40 <binit+0x54>
  }
}
    80002e6a:	70a2                	ld	ra,40(sp)
    80002e6c:	7402                	ld	s0,32(sp)
    80002e6e:	64e2                	ld	s1,24(sp)
    80002e70:	6942                	ld	s2,16(sp)
    80002e72:	69a2                	ld	s3,8(sp)
    80002e74:	6a02                	ld	s4,0(sp)
    80002e76:	6145                	addi	sp,sp,48
    80002e78:	8082                	ret

0000000080002e7a <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002e7a:	7179                	addi	sp,sp,-48
    80002e7c:	f406                	sd	ra,40(sp)
    80002e7e:	f022                	sd	s0,32(sp)
    80002e80:	ec26                	sd	s1,24(sp)
    80002e82:	e84a                	sd	s2,16(sp)
    80002e84:	e44e                	sd	s3,8(sp)
    80002e86:	1800                	addi	s0,sp,48
    80002e88:	892a                	mv	s2,a0
    80002e8a:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002e8c:	00014517          	auipc	a0,0x14
    80002e90:	d4c50513          	addi	a0,a0,-692 # 80016bd8 <bcache>
    80002e94:	ffffe097          	auipc	ra,0xffffe
    80002e98:	d42080e7          	jalr	-702(ra) # 80000bd6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002e9c:	0001c497          	auipc	s1,0x1c
    80002ea0:	ff44b483          	ld	s1,-12(s1) # 8001ee90 <bcache+0x82b8>
    80002ea4:	0001c797          	auipc	a5,0x1c
    80002ea8:	f9c78793          	addi	a5,a5,-100 # 8001ee40 <bcache+0x8268>
    80002eac:	02f48f63          	beq	s1,a5,80002eea <bread+0x70>
    80002eb0:	873e                	mv	a4,a5
    80002eb2:	a021                	j	80002eba <bread+0x40>
    80002eb4:	68a4                	ld	s1,80(s1)
    80002eb6:	02e48a63          	beq	s1,a4,80002eea <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002eba:	449c                	lw	a5,8(s1)
    80002ebc:	ff279ce3          	bne	a5,s2,80002eb4 <bread+0x3a>
    80002ec0:	44dc                	lw	a5,12(s1)
    80002ec2:	ff3799e3          	bne	a5,s3,80002eb4 <bread+0x3a>
      b->refcnt++;
    80002ec6:	40bc                	lw	a5,64(s1)
    80002ec8:	2785                	addiw	a5,a5,1
    80002eca:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002ecc:	00014517          	auipc	a0,0x14
    80002ed0:	d0c50513          	addi	a0,a0,-756 # 80016bd8 <bcache>
    80002ed4:	ffffe097          	auipc	ra,0xffffe
    80002ed8:	db6080e7          	jalr	-586(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    80002edc:	01048513          	addi	a0,s1,16
    80002ee0:	00001097          	auipc	ra,0x1
    80002ee4:	472080e7          	jalr	1138(ra) # 80004352 <acquiresleep>
      return b;
    80002ee8:	a8b9                	j	80002f46 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002eea:	0001c497          	auipc	s1,0x1c
    80002eee:	f9e4b483          	ld	s1,-98(s1) # 8001ee88 <bcache+0x82b0>
    80002ef2:	0001c797          	auipc	a5,0x1c
    80002ef6:	f4e78793          	addi	a5,a5,-178 # 8001ee40 <bcache+0x8268>
    80002efa:	00f48863          	beq	s1,a5,80002f0a <bread+0x90>
    80002efe:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002f00:	40bc                	lw	a5,64(s1)
    80002f02:	cf81                	beqz	a5,80002f1a <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002f04:	64a4                	ld	s1,72(s1)
    80002f06:	fee49de3          	bne	s1,a4,80002f00 <bread+0x86>
  panic("bget: no buffers");
    80002f0a:	00005517          	auipc	a0,0x5
    80002f0e:	63e50513          	addi	a0,a0,1598 # 80008548 <syscalls+0xf8>
    80002f12:	ffffd097          	auipc	ra,0xffffd
    80002f16:	62e080e7          	jalr	1582(ra) # 80000540 <panic>
      b->dev = dev;
    80002f1a:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002f1e:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002f22:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002f26:	4785                	li	a5,1
    80002f28:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002f2a:	00014517          	auipc	a0,0x14
    80002f2e:	cae50513          	addi	a0,a0,-850 # 80016bd8 <bcache>
    80002f32:	ffffe097          	auipc	ra,0xffffe
    80002f36:	d58080e7          	jalr	-680(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    80002f3a:	01048513          	addi	a0,s1,16
    80002f3e:	00001097          	auipc	ra,0x1
    80002f42:	414080e7          	jalr	1044(ra) # 80004352 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002f46:	409c                	lw	a5,0(s1)
    80002f48:	cb89                	beqz	a5,80002f5a <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002f4a:	8526                	mv	a0,s1
    80002f4c:	70a2                	ld	ra,40(sp)
    80002f4e:	7402                	ld	s0,32(sp)
    80002f50:	64e2                	ld	s1,24(sp)
    80002f52:	6942                	ld	s2,16(sp)
    80002f54:	69a2                	ld	s3,8(sp)
    80002f56:	6145                	addi	sp,sp,48
    80002f58:	8082                	ret
    virtio_disk_rw(b, 0);
    80002f5a:	4581                	li	a1,0
    80002f5c:	8526                	mv	a0,s1
    80002f5e:	00003097          	auipc	ra,0x3
    80002f62:	fe4080e7          	jalr	-28(ra) # 80005f42 <virtio_disk_rw>
    b->valid = 1;
    80002f66:	4785                	li	a5,1
    80002f68:	c09c                	sw	a5,0(s1)
  return b;
    80002f6a:	b7c5                	j	80002f4a <bread+0xd0>

0000000080002f6c <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002f6c:	1101                	addi	sp,sp,-32
    80002f6e:	ec06                	sd	ra,24(sp)
    80002f70:	e822                	sd	s0,16(sp)
    80002f72:	e426                	sd	s1,8(sp)
    80002f74:	1000                	addi	s0,sp,32
    80002f76:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002f78:	0541                	addi	a0,a0,16
    80002f7a:	00001097          	auipc	ra,0x1
    80002f7e:	472080e7          	jalr	1138(ra) # 800043ec <holdingsleep>
    80002f82:	cd01                	beqz	a0,80002f9a <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002f84:	4585                	li	a1,1
    80002f86:	8526                	mv	a0,s1
    80002f88:	00003097          	auipc	ra,0x3
    80002f8c:	fba080e7          	jalr	-70(ra) # 80005f42 <virtio_disk_rw>
}
    80002f90:	60e2                	ld	ra,24(sp)
    80002f92:	6442                	ld	s0,16(sp)
    80002f94:	64a2                	ld	s1,8(sp)
    80002f96:	6105                	addi	sp,sp,32
    80002f98:	8082                	ret
    panic("bwrite");
    80002f9a:	00005517          	auipc	a0,0x5
    80002f9e:	5c650513          	addi	a0,a0,1478 # 80008560 <syscalls+0x110>
    80002fa2:	ffffd097          	auipc	ra,0xffffd
    80002fa6:	59e080e7          	jalr	1438(ra) # 80000540 <panic>

0000000080002faa <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002faa:	1101                	addi	sp,sp,-32
    80002fac:	ec06                	sd	ra,24(sp)
    80002fae:	e822                	sd	s0,16(sp)
    80002fb0:	e426                	sd	s1,8(sp)
    80002fb2:	e04a                	sd	s2,0(sp)
    80002fb4:	1000                	addi	s0,sp,32
    80002fb6:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002fb8:	01050913          	addi	s2,a0,16
    80002fbc:	854a                	mv	a0,s2
    80002fbe:	00001097          	auipc	ra,0x1
    80002fc2:	42e080e7          	jalr	1070(ra) # 800043ec <holdingsleep>
    80002fc6:	c92d                	beqz	a0,80003038 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80002fc8:	854a                	mv	a0,s2
    80002fca:	00001097          	auipc	ra,0x1
    80002fce:	3de080e7          	jalr	990(ra) # 800043a8 <releasesleep>

  acquire(&bcache.lock);
    80002fd2:	00014517          	auipc	a0,0x14
    80002fd6:	c0650513          	addi	a0,a0,-1018 # 80016bd8 <bcache>
    80002fda:	ffffe097          	auipc	ra,0xffffe
    80002fde:	bfc080e7          	jalr	-1028(ra) # 80000bd6 <acquire>
  b->refcnt--;
    80002fe2:	40bc                	lw	a5,64(s1)
    80002fe4:	37fd                	addiw	a5,a5,-1
    80002fe6:	0007871b          	sext.w	a4,a5
    80002fea:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002fec:	eb05                	bnez	a4,8000301c <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002fee:	68bc                	ld	a5,80(s1)
    80002ff0:	64b8                	ld	a4,72(s1)
    80002ff2:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80002ff4:	64bc                	ld	a5,72(s1)
    80002ff6:	68b8                	ld	a4,80(s1)
    80002ff8:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002ffa:	0001c797          	auipc	a5,0x1c
    80002ffe:	bde78793          	addi	a5,a5,-1058 # 8001ebd8 <bcache+0x8000>
    80003002:	2b87b703          	ld	a4,696(a5)
    80003006:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003008:	0001c717          	auipc	a4,0x1c
    8000300c:	e3870713          	addi	a4,a4,-456 # 8001ee40 <bcache+0x8268>
    80003010:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003012:	2b87b703          	ld	a4,696(a5)
    80003016:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003018:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000301c:	00014517          	auipc	a0,0x14
    80003020:	bbc50513          	addi	a0,a0,-1092 # 80016bd8 <bcache>
    80003024:	ffffe097          	auipc	ra,0xffffe
    80003028:	c66080e7          	jalr	-922(ra) # 80000c8a <release>
}
    8000302c:	60e2                	ld	ra,24(sp)
    8000302e:	6442                	ld	s0,16(sp)
    80003030:	64a2                	ld	s1,8(sp)
    80003032:	6902                	ld	s2,0(sp)
    80003034:	6105                	addi	sp,sp,32
    80003036:	8082                	ret
    panic("brelse");
    80003038:	00005517          	auipc	a0,0x5
    8000303c:	53050513          	addi	a0,a0,1328 # 80008568 <syscalls+0x118>
    80003040:	ffffd097          	auipc	ra,0xffffd
    80003044:	500080e7          	jalr	1280(ra) # 80000540 <panic>

0000000080003048 <bpin>:

void
bpin(struct buf *b) {
    80003048:	1101                	addi	sp,sp,-32
    8000304a:	ec06                	sd	ra,24(sp)
    8000304c:	e822                	sd	s0,16(sp)
    8000304e:	e426                	sd	s1,8(sp)
    80003050:	1000                	addi	s0,sp,32
    80003052:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003054:	00014517          	auipc	a0,0x14
    80003058:	b8450513          	addi	a0,a0,-1148 # 80016bd8 <bcache>
    8000305c:	ffffe097          	auipc	ra,0xffffe
    80003060:	b7a080e7          	jalr	-1158(ra) # 80000bd6 <acquire>
  b->refcnt++;
    80003064:	40bc                	lw	a5,64(s1)
    80003066:	2785                	addiw	a5,a5,1
    80003068:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000306a:	00014517          	auipc	a0,0x14
    8000306e:	b6e50513          	addi	a0,a0,-1170 # 80016bd8 <bcache>
    80003072:	ffffe097          	auipc	ra,0xffffe
    80003076:	c18080e7          	jalr	-1000(ra) # 80000c8a <release>
}
    8000307a:	60e2                	ld	ra,24(sp)
    8000307c:	6442                	ld	s0,16(sp)
    8000307e:	64a2                	ld	s1,8(sp)
    80003080:	6105                	addi	sp,sp,32
    80003082:	8082                	ret

0000000080003084 <bunpin>:

void
bunpin(struct buf *b) {
    80003084:	1101                	addi	sp,sp,-32
    80003086:	ec06                	sd	ra,24(sp)
    80003088:	e822                	sd	s0,16(sp)
    8000308a:	e426                	sd	s1,8(sp)
    8000308c:	1000                	addi	s0,sp,32
    8000308e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003090:	00014517          	auipc	a0,0x14
    80003094:	b4850513          	addi	a0,a0,-1208 # 80016bd8 <bcache>
    80003098:	ffffe097          	auipc	ra,0xffffe
    8000309c:	b3e080e7          	jalr	-1218(ra) # 80000bd6 <acquire>
  b->refcnt--;
    800030a0:	40bc                	lw	a5,64(s1)
    800030a2:	37fd                	addiw	a5,a5,-1
    800030a4:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800030a6:	00014517          	auipc	a0,0x14
    800030aa:	b3250513          	addi	a0,a0,-1230 # 80016bd8 <bcache>
    800030ae:	ffffe097          	auipc	ra,0xffffe
    800030b2:	bdc080e7          	jalr	-1060(ra) # 80000c8a <release>
}
    800030b6:	60e2                	ld	ra,24(sp)
    800030b8:	6442                	ld	s0,16(sp)
    800030ba:	64a2                	ld	s1,8(sp)
    800030bc:	6105                	addi	sp,sp,32
    800030be:	8082                	ret

00000000800030c0 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800030c0:	1101                	addi	sp,sp,-32
    800030c2:	ec06                	sd	ra,24(sp)
    800030c4:	e822                	sd	s0,16(sp)
    800030c6:	e426                	sd	s1,8(sp)
    800030c8:	e04a                	sd	s2,0(sp)
    800030ca:	1000                	addi	s0,sp,32
    800030cc:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800030ce:	00d5d59b          	srliw	a1,a1,0xd
    800030d2:	0001c797          	auipc	a5,0x1c
    800030d6:	1e27a783          	lw	a5,482(a5) # 8001f2b4 <sb+0x1c>
    800030da:	9dbd                	addw	a1,a1,a5
    800030dc:	00000097          	auipc	ra,0x0
    800030e0:	d9e080e7          	jalr	-610(ra) # 80002e7a <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800030e4:	0074f713          	andi	a4,s1,7
    800030e8:	4785                	li	a5,1
    800030ea:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800030ee:	14ce                	slli	s1,s1,0x33
    800030f0:	90d9                	srli	s1,s1,0x36
    800030f2:	00950733          	add	a4,a0,s1
    800030f6:	05874703          	lbu	a4,88(a4)
    800030fa:	00e7f6b3          	and	a3,a5,a4
    800030fe:	c69d                	beqz	a3,8000312c <bfree+0x6c>
    80003100:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003102:	94aa                	add	s1,s1,a0
    80003104:	fff7c793          	not	a5,a5
    80003108:	8f7d                	and	a4,a4,a5
    8000310a:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    8000310e:	00001097          	auipc	ra,0x1
    80003112:	126080e7          	jalr	294(ra) # 80004234 <log_write>
  brelse(bp);
    80003116:	854a                	mv	a0,s2
    80003118:	00000097          	auipc	ra,0x0
    8000311c:	e92080e7          	jalr	-366(ra) # 80002faa <brelse>
}
    80003120:	60e2                	ld	ra,24(sp)
    80003122:	6442                	ld	s0,16(sp)
    80003124:	64a2                	ld	s1,8(sp)
    80003126:	6902                	ld	s2,0(sp)
    80003128:	6105                	addi	sp,sp,32
    8000312a:	8082                	ret
    panic("freeing free block");
    8000312c:	00005517          	auipc	a0,0x5
    80003130:	44450513          	addi	a0,a0,1092 # 80008570 <syscalls+0x120>
    80003134:	ffffd097          	auipc	ra,0xffffd
    80003138:	40c080e7          	jalr	1036(ra) # 80000540 <panic>

000000008000313c <balloc>:
{
    8000313c:	711d                	addi	sp,sp,-96
    8000313e:	ec86                	sd	ra,88(sp)
    80003140:	e8a2                	sd	s0,80(sp)
    80003142:	e4a6                	sd	s1,72(sp)
    80003144:	e0ca                	sd	s2,64(sp)
    80003146:	fc4e                	sd	s3,56(sp)
    80003148:	f852                	sd	s4,48(sp)
    8000314a:	f456                	sd	s5,40(sp)
    8000314c:	f05a                	sd	s6,32(sp)
    8000314e:	ec5e                	sd	s7,24(sp)
    80003150:	e862                	sd	s8,16(sp)
    80003152:	e466                	sd	s9,8(sp)
    80003154:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003156:	0001c797          	auipc	a5,0x1c
    8000315a:	1467a783          	lw	a5,326(a5) # 8001f29c <sb+0x4>
    8000315e:	cff5                	beqz	a5,8000325a <balloc+0x11e>
    80003160:	8baa                	mv	s7,a0
    80003162:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003164:	0001cb17          	auipc	s6,0x1c
    80003168:	134b0b13          	addi	s6,s6,308 # 8001f298 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000316c:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000316e:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003170:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003172:	6c89                	lui	s9,0x2
    80003174:	a061                	j	800031fc <balloc+0xc0>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003176:	97ca                	add	a5,a5,s2
    80003178:	8e55                	or	a2,a2,a3
    8000317a:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    8000317e:	854a                	mv	a0,s2
    80003180:	00001097          	auipc	ra,0x1
    80003184:	0b4080e7          	jalr	180(ra) # 80004234 <log_write>
        brelse(bp);
    80003188:	854a                	mv	a0,s2
    8000318a:	00000097          	auipc	ra,0x0
    8000318e:	e20080e7          	jalr	-480(ra) # 80002faa <brelse>
  bp = bread(dev, bno);
    80003192:	85a6                	mv	a1,s1
    80003194:	855e                	mv	a0,s7
    80003196:	00000097          	auipc	ra,0x0
    8000319a:	ce4080e7          	jalr	-796(ra) # 80002e7a <bread>
    8000319e:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800031a0:	40000613          	li	a2,1024
    800031a4:	4581                	li	a1,0
    800031a6:	05850513          	addi	a0,a0,88
    800031aa:	ffffe097          	auipc	ra,0xffffe
    800031ae:	b28080e7          	jalr	-1240(ra) # 80000cd2 <memset>
  log_write(bp);
    800031b2:	854a                	mv	a0,s2
    800031b4:	00001097          	auipc	ra,0x1
    800031b8:	080080e7          	jalr	128(ra) # 80004234 <log_write>
  brelse(bp);
    800031bc:	854a                	mv	a0,s2
    800031be:	00000097          	auipc	ra,0x0
    800031c2:	dec080e7          	jalr	-532(ra) # 80002faa <brelse>
}
    800031c6:	8526                	mv	a0,s1
    800031c8:	60e6                	ld	ra,88(sp)
    800031ca:	6446                	ld	s0,80(sp)
    800031cc:	64a6                	ld	s1,72(sp)
    800031ce:	6906                	ld	s2,64(sp)
    800031d0:	79e2                	ld	s3,56(sp)
    800031d2:	7a42                	ld	s4,48(sp)
    800031d4:	7aa2                	ld	s5,40(sp)
    800031d6:	7b02                	ld	s6,32(sp)
    800031d8:	6be2                	ld	s7,24(sp)
    800031da:	6c42                	ld	s8,16(sp)
    800031dc:	6ca2                	ld	s9,8(sp)
    800031de:	6125                	addi	sp,sp,96
    800031e0:	8082                	ret
    brelse(bp);
    800031e2:	854a                	mv	a0,s2
    800031e4:	00000097          	auipc	ra,0x0
    800031e8:	dc6080e7          	jalr	-570(ra) # 80002faa <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800031ec:	015c87bb          	addw	a5,s9,s5
    800031f0:	00078a9b          	sext.w	s5,a5
    800031f4:	004b2703          	lw	a4,4(s6)
    800031f8:	06eaf163          	bgeu	s5,a4,8000325a <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    800031fc:	41fad79b          	sraiw	a5,s5,0x1f
    80003200:	0137d79b          	srliw	a5,a5,0x13
    80003204:	015787bb          	addw	a5,a5,s5
    80003208:	40d7d79b          	sraiw	a5,a5,0xd
    8000320c:	01cb2583          	lw	a1,28(s6)
    80003210:	9dbd                	addw	a1,a1,a5
    80003212:	855e                	mv	a0,s7
    80003214:	00000097          	auipc	ra,0x0
    80003218:	c66080e7          	jalr	-922(ra) # 80002e7a <bread>
    8000321c:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000321e:	004b2503          	lw	a0,4(s6)
    80003222:	000a849b          	sext.w	s1,s5
    80003226:	8762                	mv	a4,s8
    80003228:	faa4fde3          	bgeu	s1,a0,800031e2 <balloc+0xa6>
      m = 1 << (bi % 8);
    8000322c:	00777693          	andi	a3,a4,7
    80003230:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003234:	41f7579b          	sraiw	a5,a4,0x1f
    80003238:	01d7d79b          	srliw	a5,a5,0x1d
    8000323c:	9fb9                	addw	a5,a5,a4
    8000323e:	4037d79b          	sraiw	a5,a5,0x3
    80003242:	00f90633          	add	a2,s2,a5
    80003246:	05864603          	lbu	a2,88(a2)
    8000324a:	00c6f5b3          	and	a1,a3,a2
    8000324e:	d585                	beqz	a1,80003176 <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003250:	2705                	addiw	a4,a4,1
    80003252:	2485                	addiw	s1,s1,1
    80003254:	fd471ae3          	bne	a4,s4,80003228 <balloc+0xec>
    80003258:	b769                	j	800031e2 <balloc+0xa6>
  printf("balloc: out of blocks\n");
    8000325a:	00005517          	auipc	a0,0x5
    8000325e:	32e50513          	addi	a0,a0,814 # 80008588 <syscalls+0x138>
    80003262:	ffffd097          	auipc	ra,0xffffd
    80003266:	328080e7          	jalr	808(ra) # 8000058a <printf>
  return 0;
    8000326a:	4481                	li	s1,0
    8000326c:	bfa9                	j	800031c6 <balloc+0x8a>

000000008000326e <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    8000326e:	7179                	addi	sp,sp,-48
    80003270:	f406                	sd	ra,40(sp)
    80003272:	f022                	sd	s0,32(sp)
    80003274:	ec26                	sd	s1,24(sp)
    80003276:	e84a                	sd	s2,16(sp)
    80003278:	e44e                	sd	s3,8(sp)
    8000327a:	e052                	sd	s4,0(sp)
    8000327c:	1800                	addi	s0,sp,48
    8000327e:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003280:	47ad                	li	a5,11
    80003282:	02b7e863          	bltu	a5,a1,800032b2 <bmap+0x44>
    if((addr = ip->addrs[bn]) == 0){
    80003286:	02059793          	slli	a5,a1,0x20
    8000328a:	01e7d593          	srli	a1,a5,0x1e
    8000328e:	00b504b3          	add	s1,a0,a1
    80003292:	0504a903          	lw	s2,80(s1)
    80003296:	06091e63          	bnez	s2,80003312 <bmap+0xa4>
      addr = balloc(ip->dev);
    8000329a:	4108                	lw	a0,0(a0)
    8000329c:	00000097          	auipc	ra,0x0
    800032a0:	ea0080e7          	jalr	-352(ra) # 8000313c <balloc>
    800032a4:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800032a8:	06090563          	beqz	s2,80003312 <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    800032ac:	0524a823          	sw	s2,80(s1)
    800032b0:	a08d                	j	80003312 <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    800032b2:	ff45849b          	addiw	s1,a1,-12
    800032b6:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800032ba:	0ff00793          	li	a5,255
    800032be:	08e7e563          	bltu	a5,a4,80003348 <bmap+0xda>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800032c2:	08052903          	lw	s2,128(a0)
    800032c6:	00091d63          	bnez	s2,800032e0 <bmap+0x72>
      addr = balloc(ip->dev);
    800032ca:	4108                	lw	a0,0(a0)
    800032cc:	00000097          	auipc	ra,0x0
    800032d0:	e70080e7          	jalr	-400(ra) # 8000313c <balloc>
    800032d4:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800032d8:	02090d63          	beqz	s2,80003312 <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    800032dc:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    800032e0:	85ca                	mv	a1,s2
    800032e2:	0009a503          	lw	a0,0(s3)
    800032e6:	00000097          	auipc	ra,0x0
    800032ea:	b94080e7          	jalr	-1132(ra) # 80002e7a <bread>
    800032ee:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800032f0:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800032f4:	02049713          	slli	a4,s1,0x20
    800032f8:	01e75593          	srli	a1,a4,0x1e
    800032fc:	00b784b3          	add	s1,a5,a1
    80003300:	0004a903          	lw	s2,0(s1)
    80003304:	02090063          	beqz	s2,80003324 <bmap+0xb6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003308:	8552                	mv	a0,s4
    8000330a:	00000097          	auipc	ra,0x0
    8000330e:	ca0080e7          	jalr	-864(ra) # 80002faa <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003312:	854a                	mv	a0,s2
    80003314:	70a2                	ld	ra,40(sp)
    80003316:	7402                	ld	s0,32(sp)
    80003318:	64e2                	ld	s1,24(sp)
    8000331a:	6942                	ld	s2,16(sp)
    8000331c:	69a2                	ld	s3,8(sp)
    8000331e:	6a02                	ld	s4,0(sp)
    80003320:	6145                	addi	sp,sp,48
    80003322:	8082                	ret
      addr = balloc(ip->dev);
    80003324:	0009a503          	lw	a0,0(s3)
    80003328:	00000097          	auipc	ra,0x0
    8000332c:	e14080e7          	jalr	-492(ra) # 8000313c <balloc>
    80003330:	0005091b          	sext.w	s2,a0
      if(addr){
    80003334:	fc090ae3          	beqz	s2,80003308 <bmap+0x9a>
        a[bn] = addr;
    80003338:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    8000333c:	8552                	mv	a0,s4
    8000333e:	00001097          	auipc	ra,0x1
    80003342:	ef6080e7          	jalr	-266(ra) # 80004234 <log_write>
    80003346:	b7c9                	j	80003308 <bmap+0x9a>
  panic("bmap: out of range");
    80003348:	00005517          	auipc	a0,0x5
    8000334c:	25850513          	addi	a0,a0,600 # 800085a0 <syscalls+0x150>
    80003350:	ffffd097          	auipc	ra,0xffffd
    80003354:	1f0080e7          	jalr	496(ra) # 80000540 <panic>

0000000080003358 <iget>:
{
    80003358:	7179                	addi	sp,sp,-48
    8000335a:	f406                	sd	ra,40(sp)
    8000335c:	f022                	sd	s0,32(sp)
    8000335e:	ec26                	sd	s1,24(sp)
    80003360:	e84a                	sd	s2,16(sp)
    80003362:	e44e                	sd	s3,8(sp)
    80003364:	e052                	sd	s4,0(sp)
    80003366:	1800                	addi	s0,sp,48
    80003368:	89aa                	mv	s3,a0
    8000336a:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000336c:	0001c517          	auipc	a0,0x1c
    80003370:	f4c50513          	addi	a0,a0,-180 # 8001f2b8 <itable>
    80003374:	ffffe097          	auipc	ra,0xffffe
    80003378:	862080e7          	jalr	-1950(ra) # 80000bd6 <acquire>
  empty = 0;
    8000337c:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000337e:	0001c497          	auipc	s1,0x1c
    80003382:	f5248493          	addi	s1,s1,-174 # 8001f2d0 <itable+0x18>
    80003386:	0001e697          	auipc	a3,0x1e
    8000338a:	9da68693          	addi	a3,a3,-1574 # 80020d60 <log>
    8000338e:	a039                	j	8000339c <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003390:	02090b63          	beqz	s2,800033c6 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003394:	08848493          	addi	s1,s1,136
    80003398:	02d48a63          	beq	s1,a3,800033cc <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000339c:	449c                	lw	a5,8(s1)
    8000339e:	fef059e3          	blez	a5,80003390 <iget+0x38>
    800033a2:	4098                	lw	a4,0(s1)
    800033a4:	ff3716e3          	bne	a4,s3,80003390 <iget+0x38>
    800033a8:	40d8                	lw	a4,4(s1)
    800033aa:	ff4713e3          	bne	a4,s4,80003390 <iget+0x38>
      ip->ref++;
    800033ae:	2785                	addiw	a5,a5,1
    800033b0:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800033b2:	0001c517          	auipc	a0,0x1c
    800033b6:	f0650513          	addi	a0,a0,-250 # 8001f2b8 <itable>
    800033ba:	ffffe097          	auipc	ra,0xffffe
    800033be:	8d0080e7          	jalr	-1840(ra) # 80000c8a <release>
      return ip;
    800033c2:	8926                	mv	s2,s1
    800033c4:	a03d                	j	800033f2 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800033c6:	f7f9                	bnez	a5,80003394 <iget+0x3c>
    800033c8:	8926                	mv	s2,s1
    800033ca:	b7e9                	j	80003394 <iget+0x3c>
  if(empty == 0)
    800033cc:	02090c63          	beqz	s2,80003404 <iget+0xac>
  ip->dev = dev;
    800033d0:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800033d4:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800033d8:	4785                	li	a5,1
    800033da:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800033de:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800033e2:	0001c517          	auipc	a0,0x1c
    800033e6:	ed650513          	addi	a0,a0,-298 # 8001f2b8 <itable>
    800033ea:	ffffe097          	auipc	ra,0xffffe
    800033ee:	8a0080e7          	jalr	-1888(ra) # 80000c8a <release>
}
    800033f2:	854a                	mv	a0,s2
    800033f4:	70a2                	ld	ra,40(sp)
    800033f6:	7402                	ld	s0,32(sp)
    800033f8:	64e2                	ld	s1,24(sp)
    800033fa:	6942                	ld	s2,16(sp)
    800033fc:	69a2                	ld	s3,8(sp)
    800033fe:	6a02                	ld	s4,0(sp)
    80003400:	6145                	addi	sp,sp,48
    80003402:	8082                	ret
    panic("iget: no inodes");
    80003404:	00005517          	auipc	a0,0x5
    80003408:	1b450513          	addi	a0,a0,436 # 800085b8 <syscalls+0x168>
    8000340c:	ffffd097          	auipc	ra,0xffffd
    80003410:	134080e7          	jalr	308(ra) # 80000540 <panic>

0000000080003414 <fsinit>:
fsinit(int dev) {
    80003414:	7179                	addi	sp,sp,-48
    80003416:	f406                	sd	ra,40(sp)
    80003418:	f022                	sd	s0,32(sp)
    8000341a:	ec26                	sd	s1,24(sp)
    8000341c:	e84a                	sd	s2,16(sp)
    8000341e:	e44e                	sd	s3,8(sp)
    80003420:	1800                	addi	s0,sp,48
    80003422:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003424:	4585                	li	a1,1
    80003426:	00000097          	auipc	ra,0x0
    8000342a:	a54080e7          	jalr	-1452(ra) # 80002e7a <bread>
    8000342e:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003430:	0001c997          	auipc	s3,0x1c
    80003434:	e6898993          	addi	s3,s3,-408 # 8001f298 <sb>
    80003438:	02000613          	li	a2,32
    8000343c:	05850593          	addi	a1,a0,88
    80003440:	854e                	mv	a0,s3
    80003442:	ffffe097          	auipc	ra,0xffffe
    80003446:	8ec080e7          	jalr	-1812(ra) # 80000d2e <memmove>
  brelse(bp);
    8000344a:	8526                	mv	a0,s1
    8000344c:	00000097          	auipc	ra,0x0
    80003450:	b5e080e7          	jalr	-1186(ra) # 80002faa <brelse>
  if(sb.magic != FSMAGIC)
    80003454:	0009a703          	lw	a4,0(s3)
    80003458:	102037b7          	lui	a5,0x10203
    8000345c:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003460:	02f71263          	bne	a4,a5,80003484 <fsinit+0x70>
  initlog(dev, &sb);
    80003464:	0001c597          	auipc	a1,0x1c
    80003468:	e3458593          	addi	a1,a1,-460 # 8001f298 <sb>
    8000346c:	854a                	mv	a0,s2
    8000346e:	00001097          	auipc	ra,0x1
    80003472:	b4a080e7          	jalr	-1206(ra) # 80003fb8 <initlog>
}
    80003476:	70a2                	ld	ra,40(sp)
    80003478:	7402                	ld	s0,32(sp)
    8000347a:	64e2                	ld	s1,24(sp)
    8000347c:	6942                	ld	s2,16(sp)
    8000347e:	69a2                	ld	s3,8(sp)
    80003480:	6145                	addi	sp,sp,48
    80003482:	8082                	ret
    panic("invalid file system");
    80003484:	00005517          	auipc	a0,0x5
    80003488:	14450513          	addi	a0,a0,324 # 800085c8 <syscalls+0x178>
    8000348c:	ffffd097          	auipc	ra,0xffffd
    80003490:	0b4080e7          	jalr	180(ra) # 80000540 <panic>

0000000080003494 <iinit>:
{
    80003494:	7179                	addi	sp,sp,-48
    80003496:	f406                	sd	ra,40(sp)
    80003498:	f022                	sd	s0,32(sp)
    8000349a:	ec26                	sd	s1,24(sp)
    8000349c:	e84a                	sd	s2,16(sp)
    8000349e:	e44e                	sd	s3,8(sp)
    800034a0:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800034a2:	00005597          	auipc	a1,0x5
    800034a6:	13e58593          	addi	a1,a1,318 # 800085e0 <syscalls+0x190>
    800034aa:	0001c517          	auipc	a0,0x1c
    800034ae:	e0e50513          	addi	a0,a0,-498 # 8001f2b8 <itable>
    800034b2:	ffffd097          	auipc	ra,0xffffd
    800034b6:	694080e7          	jalr	1684(ra) # 80000b46 <initlock>
  for(i = 0; i < NINODE; i++) {
    800034ba:	0001c497          	auipc	s1,0x1c
    800034be:	e2648493          	addi	s1,s1,-474 # 8001f2e0 <itable+0x28>
    800034c2:	0001e997          	auipc	s3,0x1e
    800034c6:	8ae98993          	addi	s3,s3,-1874 # 80020d70 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800034ca:	00005917          	auipc	s2,0x5
    800034ce:	11e90913          	addi	s2,s2,286 # 800085e8 <syscalls+0x198>
    800034d2:	85ca                	mv	a1,s2
    800034d4:	8526                	mv	a0,s1
    800034d6:	00001097          	auipc	ra,0x1
    800034da:	e42080e7          	jalr	-446(ra) # 80004318 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800034de:	08848493          	addi	s1,s1,136
    800034e2:	ff3498e3          	bne	s1,s3,800034d2 <iinit+0x3e>
}
    800034e6:	70a2                	ld	ra,40(sp)
    800034e8:	7402                	ld	s0,32(sp)
    800034ea:	64e2                	ld	s1,24(sp)
    800034ec:	6942                	ld	s2,16(sp)
    800034ee:	69a2                	ld	s3,8(sp)
    800034f0:	6145                	addi	sp,sp,48
    800034f2:	8082                	ret

00000000800034f4 <ialloc>:
{
    800034f4:	715d                	addi	sp,sp,-80
    800034f6:	e486                	sd	ra,72(sp)
    800034f8:	e0a2                	sd	s0,64(sp)
    800034fa:	fc26                	sd	s1,56(sp)
    800034fc:	f84a                	sd	s2,48(sp)
    800034fe:	f44e                	sd	s3,40(sp)
    80003500:	f052                	sd	s4,32(sp)
    80003502:	ec56                	sd	s5,24(sp)
    80003504:	e85a                	sd	s6,16(sp)
    80003506:	e45e                	sd	s7,8(sp)
    80003508:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    8000350a:	0001c717          	auipc	a4,0x1c
    8000350e:	d9a72703          	lw	a4,-614(a4) # 8001f2a4 <sb+0xc>
    80003512:	4785                	li	a5,1
    80003514:	04e7fa63          	bgeu	a5,a4,80003568 <ialloc+0x74>
    80003518:	8aaa                	mv	s5,a0
    8000351a:	8bae                	mv	s7,a1
    8000351c:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000351e:	0001ca17          	auipc	s4,0x1c
    80003522:	d7aa0a13          	addi	s4,s4,-646 # 8001f298 <sb>
    80003526:	00048b1b          	sext.w	s6,s1
    8000352a:	0044d593          	srli	a1,s1,0x4
    8000352e:	018a2783          	lw	a5,24(s4)
    80003532:	9dbd                	addw	a1,a1,a5
    80003534:	8556                	mv	a0,s5
    80003536:	00000097          	auipc	ra,0x0
    8000353a:	944080e7          	jalr	-1724(ra) # 80002e7a <bread>
    8000353e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003540:	05850993          	addi	s3,a0,88
    80003544:	00f4f793          	andi	a5,s1,15
    80003548:	079a                	slli	a5,a5,0x6
    8000354a:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    8000354c:	00099783          	lh	a5,0(s3)
    80003550:	c3a1                	beqz	a5,80003590 <ialloc+0x9c>
    brelse(bp);
    80003552:	00000097          	auipc	ra,0x0
    80003556:	a58080e7          	jalr	-1448(ra) # 80002faa <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    8000355a:	0485                	addi	s1,s1,1
    8000355c:	00ca2703          	lw	a4,12(s4)
    80003560:	0004879b          	sext.w	a5,s1
    80003564:	fce7e1e3          	bltu	a5,a4,80003526 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003568:	00005517          	auipc	a0,0x5
    8000356c:	08850513          	addi	a0,a0,136 # 800085f0 <syscalls+0x1a0>
    80003570:	ffffd097          	auipc	ra,0xffffd
    80003574:	01a080e7          	jalr	26(ra) # 8000058a <printf>
  return 0;
    80003578:	4501                	li	a0,0
}
    8000357a:	60a6                	ld	ra,72(sp)
    8000357c:	6406                	ld	s0,64(sp)
    8000357e:	74e2                	ld	s1,56(sp)
    80003580:	7942                	ld	s2,48(sp)
    80003582:	79a2                	ld	s3,40(sp)
    80003584:	7a02                	ld	s4,32(sp)
    80003586:	6ae2                	ld	s5,24(sp)
    80003588:	6b42                	ld	s6,16(sp)
    8000358a:	6ba2                	ld	s7,8(sp)
    8000358c:	6161                	addi	sp,sp,80
    8000358e:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003590:	04000613          	li	a2,64
    80003594:	4581                	li	a1,0
    80003596:	854e                	mv	a0,s3
    80003598:	ffffd097          	auipc	ra,0xffffd
    8000359c:	73a080e7          	jalr	1850(ra) # 80000cd2 <memset>
      dip->type = type;
    800035a0:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800035a4:	854a                	mv	a0,s2
    800035a6:	00001097          	auipc	ra,0x1
    800035aa:	c8e080e7          	jalr	-882(ra) # 80004234 <log_write>
      brelse(bp);
    800035ae:	854a                	mv	a0,s2
    800035b0:	00000097          	auipc	ra,0x0
    800035b4:	9fa080e7          	jalr	-1542(ra) # 80002faa <brelse>
      return iget(dev, inum);
    800035b8:	85da                	mv	a1,s6
    800035ba:	8556                	mv	a0,s5
    800035bc:	00000097          	auipc	ra,0x0
    800035c0:	d9c080e7          	jalr	-612(ra) # 80003358 <iget>
    800035c4:	bf5d                	j	8000357a <ialloc+0x86>

00000000800035c6 <iupdate>:
{
    800035c6:	1101                	addi	sp,sp,-32
    800035c8:	ec06                	sd	ra,24(sp)
    800035ca:	e822                	sd	s0,16(sp)
    800035cc:	e426                	sd	s1,8(sp)
    800035ce:	e04a                	sd	s2,0(sp)
    800035d0:	1000                	addi	s0,sp,32
    800035d2:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800035d4:	415c                	lw	a5,4(a0)
    800035d6:	0047d79b          	srliw	a5,a5,0x4
    800035da:	0001c597          	auipc	a1,0x1c
    800035de:	cd65a583          	lw	a1,-810(a1) # 8001f2b0 <sb+0x18>
    800035e2:	9dbd                	addw	a1,a1,a5
    800035e4:	4108                	lw	a0,0(a0)
    800035e6:	00000097          	auipc	ra,0x0
    800035ea:	894080e7          	jalr	-1900(ra) # 80002e7a <bread>
    800035ee:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800035f0:	05850793          	addi	a5,a0,88
    800035f4:	40d8                	lw	a4,4(s1)
    800035f6:	8b3d                	andi	a4,a4,15
    800035f8:	071a                	slli	a4,a4,0x6
    800035fa:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800035fc:	04449703          	lh	a4,68(s1)
    80003600:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003604:	04649703          	lh	a4,70(s1)
    80003608:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    8000360c:	04849703          	lh	a4,72(s1)
    80003610:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003614:	04a49703          	lh	a4,74(s1)
    80003618:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    8000361c:	44f8                	lw	a4,76(s1)
    8000361e:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003620:	03400613          	li	a2,52
    80003624:	05048593          	addi	a1,s1,80
    80003628:	00c78513          	addi	a0,a5,12
    8000362c:	ffffd097          	auipc	ra,0xffffd
    80003630:	702080e7          	jalr	1794(ra) # 80000d2e <memmove>
  log_write(bp);
    80003634:	854a                	mv	a0,s2
    80003636:	00001097          	auipc	ra,0x1
    8000363a:	bfe080e7          	jalr	-1026(ra) # 80004234 <log_write>
  brelse(bp);
    8000363e:	854a                	mv	a0,s2
    80003640:	00000097          	auipc	ra,0x0
    80003644:	96a080e7          	jalr	-1686(ra) # 80002faa <brelse>
}
    80003648:	60e2                	ld	ra,24(sp)
    8000364a:	6442                	ld	s0,16(sp)
    8000364c:	64a2                	ld	s1,8(sp)
    8000364e:	6902                	ld	s2,0(sp)
    80003650:	6105                	addi	sp,sp,32
    80003652:	8082                	ret

0000000080003654 <idup>:
{
    80003654:	1101                	addi	sp,sp,-32
    80003656:	ec06                	sd	ra,24(sp)
    80003658:	e822                	sd	s0,16(sp)
    8000365a:	e426                	sd	s1,8(sp)
    8000365c:	1000                	addi	s0,sp,32
    8000365e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003660:	0001c517          	auipc	a0,0x1c
    80003664:	c5850513          	addi	a0,a0,-936 # 8001f2b8 <itable>
    80003668:	ffffd097          	auipc	ra,0xffffd
    8000366c:	56e080e7          	jalr	1390(ra) # 80000bd6 <acquire>
  ip->ref++;
    80003670:	449c                	lw	a5,8(s1)
    80003672:	2785                	addiw	a5,a5,1
    80003674:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003676:	0001c517          	auipc	a0,0x1c
    8000367a:	c4250513          	addi	a0,a0,-958 # 8001f2b8 <itable>
    8000367e:	ffffd097          	auipc	ra,0xffffd
    80003682:	60c080e7          	jalr	1548(ra) # 80000c8a <release>
}
    80003686:	8526                	mv	a0,s1
    80003688:	60e2                	ld	ra,24(sp)
    8000368a:	6442                	ld	s0,16(sp)
    8000368c:	64a2                	ld	s1,8(sp)
    8000368e:	6105                	addi	sp,sp,32
    80003690:	8082                	ret

0000000080003692 <ilock>:
{
    80003692:	1101                	addi	sp,sp,-32
    80003694:	ec06                	sd	ra,24(sp)
    80003696:	e822                	sd	s0,16(sp)
    80003698:	e426                	sd	s1,8(sp)
    8000369a:	e04a                	sd	s2,0(sp)
    8000369c:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    8000369e:	c115                	beqz	a0,800036c2 <ilock+0x30>
    800036a0:	84aa                	mv	s1,a0
    800036a2:	451c                	lw	a5,8(a0)
    800036a4:	00f05f63          	blez	a5,800036c2 <ilock+0x30>
  acquiresleep(&ip->lock);
    800036a8:	0541                	addi	a0,a0,16
    800036aa:	00001097          	auipc	ra,0x1
    800036ae:	ca8080e7          	jalr	-856(ra) # 80004352 <acquiresleep>
  if(ip->valid == 0){
    800036b2:	40bc                	lw	a5,64(s1)
    800036b4:	cf99                	beqz	a5,800036d2 <ilock+0x40>
}
    800036b6:	60e2                	ld	ra,24(sp)
    800036b8:	6442                	ld	s0,16(sp)
    800036ba:	64a2                	ld	s1,8(sp)
    800036bc:	6902                	ld	s2,0(sp)
    800036be:	6105                	addi	sp,sp,32
    800036c0:	8082                	ret
    panic("ilock");
    800036c2:	00005517          	auipc	a0,0x5
    800036c6:	f4650513          	addi	a0,a0,-186 # 80008608 <syscalls+0x1b8>
    800036ca:	ffffd097          	auipc	ra,0xffffd
    800036ce:	e76080e7          	jalr	-394(ra) # 80000540 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800036d2:	40dc                	lw	a5,4(s1)
    800036d4:	0047d79b          	srliw	a5,a5,0x4
    800036d8:	0001c597          	auipc	a1,0x1c
    800036dc:	bd85a583          	lw	a1,-1064(a1) # 8001f2b0 <sb+0x18>
    800036e0:	9dbd                	addw	a1,a1,a5
    800036e2:	4088                	lw	a0,0(s1)
    800036e4:	fffff097          	auipc	ra,0xfffff
    800036e8:	796080e7          	jalr	1942(ra) # 80002e7a <bread>
    800036ec:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800036ee:	05850593          	addi	a1,a0,88
    800036f2:	40dc                	lw	a5,4(s1)
    800036f4:	8bbd                	andi	a5,a5,15
    800036f6:	079a                	slli	a5,a5,0x6
    800036f8:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800036fa:	00059783          	lh	a5,0(a1)
    800036fe:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003702:	00259783          	lh	a5,2(a1)
    80003706:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000370a:	00459783          	lh	a5,4(a1)
    8000370e:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003712:	00659783          	lh	a5,6(a1)
    80003716:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000371a:	459c                	lw	a5,8(a1)
    8000371c:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000371e:	03400613          	li	a2,52
    80003722:	05b1                	addi	a1,a1,12
    80003724:	05048513          	addi	a0,s1,80
    80003728:	ffffd097          	auipc	ra,0xffffd
    8000372c:	606080e7          	jalr	1542(ra) # 80000d2e <memmove>
    brelse(bp);
    80003730:	854a                	mv	a0,s2
    80003732:	00000097          	auipc	ra,0x0
    80003736:	878080e7          	jalr	-1928(ra) # 80002faa <brelse>
    ip->valid = 1;
    8000373a:	4785                	li	a5,1
    8000373c:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    8000373e:	04449783          	lh	a5,68(s1)
    80003742:	fbb5                	bnez	a5,800036b6 <ilock+0x24>
      panic("ilock: no type");
    80003744:	00005517          	auipc	a0,0x5
    80003748:	ecc50513          	addi	a0,a0,-308 # 80008610 <syscalls+0x1c0>
    8000374c:	ffffd097          	auipc	ra,0xffffd
    80003750:	df4080e7          	jalr	-524(ra) # 80000540 <panic>

0000000080003754 <iunlock>:
{
    80003754:	1101                	addi	sp,sp,-32
    80003756:	ec06                	sd	ra,24(sp)
    80003758:	e822                	sd	s0,16(sp)
    8000375a:	e426                	sd	s1,8(sp)
    8000375c:	e04a                	sd	s2,0(sp)
    8000375e:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003760:	c905                	beqz	a0,80003790 <iunlock+0x3c>
    80003762:	84aa                	mv	s1,a0
    80003764:	01050913          	addi	s2,a0,16
    80003768:	854a                	mv	a0,s2
    8000376a:	00001097          	auipc	ra,0x1
    8000376e:	c82080e7          	jalr	-894(ra) # 800043ec <holdingsleep>
    80003772:	cd19                	beqz	a0,80003790 <iunlock+0x3c>
    80003774:	449c                	lw	a5,8(s1)
    80003776:	00f05d63          	blez	a5,80003790 <iunlock+0x3c>
  releasesleep(&ip->lock);
    8000377a:	854a                	mv	a0,s2
    8000377c:	00001097          	auipc	ra,0x1
    80003780:	c2c080e7          	jalr	-980(ra) # 800043a8 <releasesleep>
}
    80003784:	60e2                	ld	ra,24(sp)
    80003786:	6442                	ld	s0,16(sp)
    80003788:	64a2                	ld	s1,8(sp)
    8000378a:	6902                	ld	s2,0(sp)
    8000378c:	6105                	addi	sp,sp,32
    8000378e:	8082                	ret
    panic("iunlock");
    80003790:	00005517          	auipc	a0,0x5
    80003794:	e9050513          	addi	a0,a0,-368 # 80008620 <syscalls+0x1d0>
    80003798:	ffffd097          	auipc	ra,0xffffd
    8000379c:	da8080e7          	jalr	-600(ra) # 80000540 <panic>

00000000800037a0 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800037a0:	7179                	addi	sp,sp,-48
    800037a2:	f406                	sd	ra,40(sp)
    800037a4:	f022                	sd	s0,32(sp)
    800037a6:	ec26                	sd	s1,24(sp)
    800037a8:	e84a                	sd	s2,16(sp)
    800037aa:	e44e                	sd	s3,8(sp)
    800037ac:	e052                	sd	s4,0(sp)
    800037ae:	1800                	addi	s0,sp,48
    800037b0:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800037b2:	05050493          	addi	s1,a0,80
    800037b6:	08050913          	addi	s2,a0,128
    800037ba:	a021                	j	800037c2 <itrunc+0x22>
    800037bc:	0491                	addi	s1,s1,4
    800037be:	01248d63          	beq	s1,s2,800037d8 <itrunc+0x38>
    if(ip->addrs[i]){
    800037c2:	408c                	lw	a1,0(s1)
    800037c4:	dde5                	beqz	a1,800037bc <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    800037c6:	0009a503          	lw	a0,0(s3)
    800037ca:	00000097          	auipc	ra,0x0
    800037ce:	8f6080e7          	jalr	-1802(ra) # 800030c0 <bfree>
      ip->addrs[i] = 0;
    800037d2:	0004a023          	sw	zero,0(s1)
    800037d6:	b7dd                	j	800037bc <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    800037d8:	0809a583          	lw	a1,128(s3)
    800037dc:	e185                	bnez	a1,800037fc <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800037de:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800037e2:	854e                	mv	a0,s3
    800037e4:	00000097          	auipc	ra,0x0
    800037e8:	de2080e7          	jalr	-542(ra) # 800035c6 <iupdate>
}
    800037ec:	70a2                	ld	ra,40(sp)
    800037ee:	7402                	ld	s0,32(sp)
    800037f0:	64e2                	ld	s1,24(sp)
    800037f2:	6942                	ld	s2,16(sp)
    800037f4:	69a2                	ld	s3,8(sp)
    800037f6:	6a02                	ld	s4,0(sp)
    800037f8:	6145                	addi	sp,sp,48
    800037fa:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800037fc:	0009a503          	lw	a0,0(s3)
    80003800:	fffff097          	auipc	ra,0xfffff
    80003804:	67a080e7          	jalr	1658(ra) # 80002e7a <bread>
    80003808:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000380a:	05850493          	addi	s1,a0,88
    8000380e:	45850913          	addi	s2,a0,1112
    80003812:	a021                	j	8000381a <itrunc+0x7a>
    80003814:	0491                	addi	s1,s1,4
    80003816:	01248b63          	beq	s1,s2,8000382c <itrunc+0x8c>
      if(a[j])
    8000381a:	408c                	lw	a1,0(s1)
    8000381c:	dde5                	beqz	a1,80003814 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    8000381e:	0009a503          	lw	a0,0(s3)
    80003822:	00000097          	auipc	ra,0x0
    80003826:	89e080e7          	jalr	-1890(ra) # 800030c0 <bfree>
    8000382a:	b7ed                	j	80003814 <itrunc+0x74>
    brelse(bp);
    8000382c:	8552                	mv	a0,s4
    8000382e:	fffff097          	auipc	ra,0xfffff
    80003832:	77c080e7          	jalr	1916(ra) # 80002faa <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003836:	0809a583          	lw	a1,128(s3)
    8000383a:	0009a503          	lw	a0,0(s3)
    8000383e:	00000097          	auipc	ra,0x0
    80003842:	882080e7          	jalr	-1918(ra) # 800030c0 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003846:	0809a023          	sw	zero,128(s3)
    8000384a:	bf51                	j	800037de <itrunc+0x3e>

000000008000384c <iput>:
{
    8000384c:	1101                	addi	sp,sp,-32
    8000384e:	ec06                	sd	ra,24(sp)
    80003850:	e822                	sd	s0,16(sp)
    80003852:	e426                	sd	s1,8(sp)
    80003854:	e04a                	sd	s2,0(sp)
    80003856:	1000                	addi	s0,sp,32
    80003858:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000385a:	0001c517          	auipc	a0,0x1c
    8000385e:	a5e50513          	addi	a0,a0,-1442 # 8001f2b8 <itable>
    80003862:	ffffd097          	auipc	ra,0xffffd
    80003866:	374080e7          	jalr	884(ra) # 80000bd6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000386a:	4498                	lw	a4,8(s1)
    8000386c:	4785                	li	a5,1
    8000386e:	02f70363          	beq	a4,a5,80003894 <iput+0x48>
  ip->ref--;
    80003872:	449c                	lw	a5,8(s1)
    80003874:	37fd                	addiw	a5,a5,-1
    80003876:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003878:	0001c517          	auipc	a0,0x1c
    8000387c:	a4050513          	addi	a0,a0,-1472 # 8001f2b8 <itable>
    80003880:	ffffd097          	auipc	ra,0xffffd
    80003884:	40a080e7          	jalr	1034(ra) # 80000c8a <release>
}
    80003888:	60e2                	ld	ra,24(sp)
    8000388a:	6442                	ld	s0,16(sp)
    8000388c:	64a2                	ld	s1,8(sp)
    8000388e:	6902                	ld	s2,0(sp)
    80003890:	6105                	addi	sp,sp,32
    80003892:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003894:	40bc                	lw	a5,64(s1)
    80003896:	dff1                	beqz	a5,80003872 <iput+0x26>
    80003898:	04a49783          	lh	a5,74(s1)
    8000389c:	fbf9                	bnez	a5,80003872 <iput+0x26>
    acquiresleep(&ip->lock);
    8000389e:	01048913          	addi	s2,s1,16
    800038a2:	854a                	mv	a0,s2
    800038a4:	00001097          	auipc	ra,0x1
    800038a8:	aae080e7          	jalr	-1362(ra) # 80004352 <acquiresleep>
    release(&itable.lock);
    800038ac:	0001c517          	auipc	a0,0x1c
    800038b0:	a0c50513          	addi	a0,a0,-1524 # 8001f2b8 <itable>
    800038b4:	ffffd097          	auipc	ra,0xffffd
    800038b8:	3d6080e7          	jalr	982(ra) # 80000c8a <release>
    itrunc(ip);
    800038bc:	8526                	mv	a0,s1
    800038be:	00000097          	auipc	ra,0x0
    800038c2:	ee2080e7          	jalr	-286(ra) # 800037a0 <itrunc>
    ip->type = 0;
    800038c6:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800038ca:	8526                	mv	a0,s1
    800038cc:	00000097          	auipc	ra,0x0
    800038d0:	cfa080e7          	jalr	-774(ra) # 800035c6 <iupdate>
    ip->valid = 0;
    800038d4:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800038d8:	854a                	mv	a0,s2
    800038da:	00001097          	auipc	ra,0x1
    800038de:	ace080e7          	jalr	-1330(ra) # 800043a8 <releasesleep>
    acquire(&itable.lock);
    800038e2:	0001c517          	auipc	a0,0x1c
    800038e6:	9d650513          	addi	a0,a0,-1578 # 8001f2b8 <itable>
    800038ea:	ffffd097          	auipc	ra,0xffffd
    800038ee:	2ec080e7          	jalr	748(ra) # 80000bd6 <acquire>
    800038f2:	b741                	j	80003872 <iput+0x26>

00000000800038f4 <iunlockput>:
{
    800038f4:	1101                	addi	sp,sp,-32
    800038f6:	ec06                	sd	ra,24(sp)
    800038f8:	e822                	sd	s0,16(sp)
    800038fa:	e426                	sd	s1,8(sp)
    800038fc:	1000                	addi	s0,sp,32
    800038fe:	84aa                	mv	s1,a0
  iunlock(ip);
    80003900:	00000097          	auipc	ra,0x0
    80003904:	e54080e7          	jalr	-428(ra) # 80003754 <iunlock>
  iput(ip);
    80003908:	8526                	mv	a0,s1
    8000390a:	00000097          	auipc	ra,0x0
    8000390e:	f42080e7          	jalr	-190(ra) # 8000384c <iput>
}
    80003912:	60e2                	ld	ra,24(sp)
    80003914:	6442                	ld	s0,16(sp)
    80003916:	64a2                	ld	s1,8(sp)
    80003918:	6105                	addi	sp,sp,32
    8000391a:	8082                	ret

000000008000391c <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000391c:	1141                	addi	sp,sp,-16
    8000391e:	e422                	sd	s0,8(sp)
    80003920:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003922:	411c                	lw	a5,0(a0)
    80003924:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003926:	415c                	lw	a5,4(a0)
    80003928:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000392a:	04451783          	lh	a5,68(a0)
    8000392e:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003932:	04a51783          	lh	a5,74(a0)
    80003936:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000393a:	04c56783          	lwu	a5,76(a0)
    8000393e:	e99c                	sd	a5,16(a1)
}
    80003940:	6422                	ld	s0,8(sp)
    80003942:	0141                	addi	sp,sp,16
    80003944:	8082                	ret

0000000080003946 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003946:	457c                	lw	a5,76(a0)
    80003948:	0ed7e963          	bltu	a5,a3,80003a3a <readi+0xf4>
{
    8000394c:	7159                	addi	sp,sp,-112
    8000394e:	f486                	sd	ra,104(sp)
    80003950:	f0a2                	sd	s0,96(sp)
    80003952:	eca6                	sd	s1,88(sp)
    80003954:	e8ca                	sd	s2,80(sp)
    80003956:	e4ce                	sd	s3,72(sp)
    80003958:	e0d2                	sd	s4,64(sp)
    8000395a:	fc56                	sd	s5,56(sp)
    8000395c:	f85a                	sd	s6,48(sp)
    8000395e:	f45e                	sd	s7,40(sp)
    80003960:	f062                	sd	s8,32(sp)
    80003962:	ec66                	sd	s9,24(sp)
    80003964:	e86a                	sd	s10,16(sp)
    80003966:	e46e                	sd	s11,8(sp)
    80003968:	1880                	addi	s0,sp,112
    8000396a:	8b2a                	mv	s6,a0
    8000396c:	8bae                	mv	s7,a1
    8000396e:	8a32                	mv	s4,a2
    80003970:	84b6                	mv	s1,a3
    80003972:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003974:	9f35                	addw	a4,a4,a3
    return 0;
    80003976:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003978:	0ad76063          	bltu	a4,a3,80003a18 <readi+0xd2>
  if(off + n > ip->size)
    8000397c:	00e7f463          	bgeu	a5,a4,80003984 <readi+0x3e>
    n = ip->size - off;
    80003980:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003984:	0a0a8963          	beqz	s5,80003a36 <readi+0xf0>
    80003988:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000398a:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    8000398e:	5c7d                	li	s8,-1
    80003990:	a82d                	j	800039ca <readi+0x84>
    80003992:	020d1d93          	slli	s11,s10,0x20
    80003996:	020ddd93          	srli	s11,s11,0x20
    8000399a:	05890613          	addi	a2,s2,88
    8000399e:	86ee                	mv	a3,s11
    800039a0:	963a                	add	a2,a2,a4
    800039a2:	85d2                	mv	a1,s4
    800039a4:	855e                	mv	a0,s7
    800039a6:	fffff097          	auipc	ra,0xfffff
    800039aa:	ac0080e7          	jalr	-1344(ra) # 80002466 <either_copyout>
    800039ae:	05850d63          	beq	a0,s8,80003a08 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800039b2:	854a                	mv	a0,s2
    800039b4:	fffff097          	auipc	ra,0xfffff
    800039b8:	5f6080e7          	jalr	1526(ra) # 80002faa <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800039bc:	013d09bb          	addw	s3,s10,s3
    800039c0:	009d04bb          	addw	s1,s10,s1
    800039c4:	9a6e                	add	s4,s4,s11
    800039c6:	0559f763          	bgeu	s3,s5,80003a14 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    800039ca:	00a4d59b          	srliw	a1,s1,0xa
    800039ce:	855a                	mv	a0,s6
    800039d0:	00000097          	auipc	ra,0x0
    800039d4:	89e080e7          	jalr	-1890(ra) # 8000326e <bmap>
    800039d8:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800039dc:	cd85                	beqz	a1,80003a14 <readi+0xce>
    bp = bread(ip->dev, addr);
    800039de:	000b2503          	lw	a0,0(s6)
    800039e2:	fffff097          	auipc	ra,0xfffff
    800039e6:	498080e7          	jalr	1176(ra) # 80002e7a <bread>
    800039ea:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800039ec:	3ff4f713          	andi	a4,s1,1023
    800039f0:	40ec87bb          	subw	a5,s9,a4
    800039f4:	413a86bb          	subw	a3,s5,s3
    800039f8:	8d3e                	mv	s10,a5
    800039fa:	2781                	sext.w	a5,a5
    800039fc:	0006861b          	sext.w	a2,a3
    80003a00:	f8f679e3          	bgeu	a2,a5,80003992 <readi+0x4c>
    80003a04:	8d36                	mv	s10,a3
    80003a06:	b771                	j	80003992 <readi+0x4c>
      brelse(bp);
    80003a08:	854a                	mv	a0,s2
    80003a0a:	fffff097          	auipc	ra,0xfffff
    80003a0e:	5a0080e7          	jalr	1440(ra) # 80002faa <brelse>
      tot = -1;
    80003a12:	59fd                	li	s3,-1
  }
  return tot;
    80003a14:	0009851b          	sext.w	a0,s3
}
    80003a18:	70a6                	ld	ra,104(sp)
    80003a1a:	7406                	ld	s0,96(sp)
    80003a1c:	64e6                	ld	s1,88(sp)
    80003a1e:	6946                	ld	s2,80(sp)
    80003a20:	69a6                	ld	s3,72(sp)
    80003a22:	6a06                	ld	s4,64(sp)
    80003a24:	7ae2                	ld	s5,56(sp)
    80003a26:	7b42                	ld	s6,48(sp)
    80003a28:	7ba2                	ld	s7,40(sp)
    80003a2a:	7c02                	ld	s8,32(sp)
    80003a2c:	6ce2                	ld	s9,24(sp)
    80003a2e:	6d42                	ld	s10,16(sp)
    80003a30:	6da2                	ld	s11,8(sp)
    80003a32:	6165                	addi	sp,sp,112
    80003a34:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a36:	89d6                	mv	s3,s5
    80003a38:	bff1                	j	80003a14 <readi+0xce>
    return 0;
    80003a3a:	4501                	li	a0,0
}
    80003a3c:	8082                	ret

0000000080003a3e <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003a3e:	457c                	lw	a5,76(a0)
    80003a40:	10d7e863          	bltu	a5,a3,80003b50 <writei+0x112>
{
    80003a44:	7159                	addi	sp,sp,-112
    80003a46:	f486                	sd	ra,104(sp)
    80003a48:	f0a2                	sd	s0,96(sp)
    80003a4a:	eca6                	sd	s1,88(sp)
    80003a4c:	e8ca                	sd	s2,80(sp)
    80003a4e:	e4ce                	sd	s3,72(sp)
    80003a50:	e0d2                	sd	s4,64(sp)
    80003a52:	fc56                	sd	s5,56(sp)
    80003a54:	f85a                	sd	s6,48(sp)
    80003a56:	f45e                	sd	s7,40(sp)
    80003a58:	f062                	sd	s8,32(sp)
    80003a5a:	ec66                	sd	s9,24(sp)
    80003a5c:	e86a                	sd	s10,16(sp)
    80003a5e:	e46e                	sd	s11,8(sp)
    80003a60:	1880                	addi	s0,sp,112
    80003a62:	8aaa                	mv	s5,a0
    80003a64:	8bae                	mv	s7,a1
    80003a66:	8a32                	mv	s4,a2
    80003a68:	8936                	mv	s2,a3
    80003a6a:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003a6c:	00e687bb          	addw	a5,a3,a4
    80003a70:	0ed7e263          	bltu	a5,a3,80003b54 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003a74:	00043737          	lui	a4,0x43
    80003a78:	0ef76063          	bltu	a4,a5,80003b58 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003a7c:	0c0b0863          	beqz	s6,80003b4c <writei+0x10e>
    80003a80:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a82:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003a86:	5c7d                	li	s8,-1
    80003a88:	a091                	j	80003acc <writei+0x8e>
    80003a8a:	020d1d93          	slli	s11,s10,0x20
    80003a8e:	020ddd93          	srli	s11,s11,0x20
    80003a92:	05848513          	addi	a0,s1,88
    80003a96:	86ee                	mv	a3,s11
    80003a98:	8652                	mv	a2,s4
    80003a9a:	85de                	mv	a1,s7
    80003a9c:	953a                	add	a0,a0,a4
    80003a9e:	fffff097          	auipc	ra,0xfffff
    80003aa2:	a1e080e7          	jalr	-1506(ra) # 800024bc <either_copyin>
    80003aa6:	07850263          	beq	a0,s8,80003b0a <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003aaa:	8526                	mv	a0,s1
    80003aac:	00000097          	auipc	ra,0x0
    80003ab0:	788080e7          	jalr	1928(ra) # 80004234 <log_write>
    brelse(bp);
    80003ab4:	8526                	mv	a0,s1
    80003ab6:	fffff097          	auipc	ra,0xfffff
    80003aba:	4f4080e7          	jalr	1268(ra) # 80002faa <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003abe:	013d09bb          	addw	s3,s10,s3
    80003ac2:	012d093b          	addw	s2,s10,s2
    80003ac6:	9a6e                	add	s4,s4,s11
    80003ac8:	0569f663          	bgeu	s3,s6,80003b14 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003acc:	00a9559b          	srliw	a1,s2,0xa
    80003ad0:	8556                	mv	a0,s5
    80003ad2:	fffff097          	auipc	ra,0xfffff
    80003ad6:	79c080e7          	jalr	1948(ra) # 8000326e <bmap>
    80003ada:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003ade:	c99d                	beqz	a1,80003b14 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003ae0:	000aa503          	lw	a0,0(s5)
    80003ae4:	fffff097          	auipc	ra,0xfffff
    80003ae8:	396080e7          	jalr	918(ra) # 80002e7a <bread>
    80003aec:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003aee:	3ff97713          	andi	a4,s2,1023
    80003af2:	40ec87bb          	subw	a5,s9,a4
    80003af6:	413b06bb          	subw	a3,s6,s3
    80003afa:	8d3e                	mv	s10,a5
    80003afc:	2781                	sext.w	a5,a5
    80003afe:	0006861b          	sext.w	a2,a3
    80003b02:	f8f674e3          	bgeu	a2,a5,80003a8a <writei+0x4c>
    80003b06:	8d36                	mv	s10,a3
    80003b08:	b749                	j	80003a8a <writei+0x4c>
      brelse(bp);
    80003b0a:	8526                	mv	a0,s1
    80003b0c:	fffff097          	auipc	ra,0xfffff
    80003b10:	49e080e7          	jalr	1182(ra) # 80002faa <brelse>
  }

  if(off > ip->size)
    80003b14:	04caa783          	lw	a5,76(s5)
    80003b18:	0127f463          	bgeu	a5,s2,80003b20 <writei+0xe2>
    ip->size = off;
    80003b1c:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003b20:	8556                	mv	a0,s5
    80003b22:	00000097          	auipc	ra,0x0
    80003b26:	aa4080e7          	jalr	-1372(ra) # 800035c6 <iupdate>

  return tot;
    80003b2a:	0009851b          	sext.w	a0,s3
}
    80003b2e:	70a6                	ld	ra,104(sp)
    80003b30:	7406                	ld	s0,96(sp)
    80003b32:	64e6                	ld	s1,88(sp)
    80003b34:	6946                	ld	s2,80(sp)
    80003b36:	69a6                	ld	s3,72(sp)
    80003b38:	6a06                	ld	s4,64(sp)
    80003b3a:	7ae2                	ld	s5,56(sp)
    80003b3c:	7b42                	ld	s6,48(sp)
    80003b3e:	7ba2                	ld	s7,40(sp)
    80003b40:	7c02                	ld	s8,32(sp)
    80003b42:	6ce2                	ld	s9,24(sp)
    80003b44:	6d42                	ld	s10,16(sp)
    80003b46:	6da2                	ld	s11,8(sp)
    80003b48:	6165                	addi	sp,sp,112
    80003b4a:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b4c:	89da                	mv	s3,s6
    80003b4e:	bfc9                	j	80003b20 <writei+0xe2>
    return -1;
    80003b50:	557d                	li	a0,-1
}
    80003b52:	8082                	ret
    return -1;
    80003b54:	557d                	li	a0,-1
    80003b56:	bfe1                	j	80003b2e <writei+0xf0>
    return -1;
    80003b58:	557d                	li	a0,-1
    80003b5a:	bfd1                	j	80003b2e <writei+0xf0>

0000000080003b5c <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003b5c:	1141                	addi	sp,sp,-16
    80003b5e:	e406                	sd	ra,8(sp)
    80003b60:	e022                	sd	s0,0(sp)
    80003b62:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003b64:	4639                	li	a2,14
    80003b66:	ffffd097          	auipc	ra,0xffffd
    80003b6a:	23c080e7          	jalr	572(ra) # 80000da2 <strncmp>
}
    80003b6e:	60a2                	ld	ra,8(sp)
    80003b70:	6402                	ld	s0,0(sp)
    80003b72:	0141                	addi	sp,sp,16
    80003b74:	8082                	ret

0000000080003b76 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003b76:	7139                	addi	sp,sp,-64
    80003b78:	fc06                	sd	ra,56(sp)
    80003b7a:	f822                	sd	s0,48(sp)
    80003b7c:	f426                	sd	s1,40(sp)
    80003b7e:	f04a                	sd	s2,32(sp)
    80003b80:	ec4e                	sd	s3,24(sp)
    80003b82:	e852                	sd	s4,16(sp)
    80003b84:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003b86:	04451703          	lh	a4,68(a0)
    80003b8a:	4785                	li	a5,1
    80003b8c:	00f71a63          	bne	a4,a5,80003ba0 <dirlookup+0x2a>
    80003b90:	892a                	mv	s2,a0
    80003b92:	89ae                	mv	s3,a1
    80003b94:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b96:	457c                	lw	a5,76(a0)
    80003b98:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003b9a:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b9c:	e79d                	bnez	a5,80003bca <dirlookup+0x54>
    80003b9e:	a8a5                	j	80003c16 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003ba0:	00005517          	auipc	a0,0x5
    80003ba4:	a8850513          	addi	a0,a0,-1400 # 80008628 <syscalls+0x1d8>
    80003ba8:	ffffd097          	auipc	ra,0xffffd
    80003bac:	998080e7          	jalr	-1640(ra) # 80000540 <panic>
      panic("dirlookup read");
    80003bb0:	00005517          	auipc	a0,0x5
    80003bb4:	a9050513          	addi	a0,a0,-1392 # 80008640 <syscalls+0x1f0>
    80003bb8:	ffffd097          	auipc	ra,0xffffd
    80003bbc:	988080e7          	jalr	-1656(ra) # 80000540 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003bc0:	24c1                	addiw	s1,s1,16
    80003bc2:	04c92783          	lw	a5,76(s2)
    80003bc6:	04f4f763          	bgeu	s1,a5,80003c14 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003bca:	4741                	li	a4,16
    80003bcc:	86a6                	mv	a3,s1
    80003bce:	fc040613          	addi	a2,s0,-64
    80003bd2:	4581                	li	a1,0
    80003bd4:	854a                	mv	a0,s2
    80003bd6:	00000097          	auipc	ra,0x0
    80003bda:	d70080e7          	jalr	-656(ra) # 80003946 <readi>
    80003bde:	47c1                	li	a5,16
    80003be0:	fcf518e3          	bne	a0,a5,80003bb0 <dirlookup+0x3a>
    if(de.inum == 0)
    80003be4:	fc045783          	lhu	a5,-64(s0)
    80003be8:	dfe1                	beqz	a5,80003bc0 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003bea:	fc240593          	addi	a1,s0,-62
    80003bee:	854e                	mv	a0,s3
    80003bf0:	00000097          	auipc	ra,0x0
    80003bf4:	f6c080e7          	jalr	-148(ra) # 80003b5c <namecmp>
    80003bf8:	f561                	bnez	a0,80003bc0 <dirlookup+0x4a>
      if(poff)
    80003bfa:	000a0463          	beqz	s4,80003c02 <dirlookup+0x8c>
        *poff = off;
    80003bfe:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003c02:	fc045583          	lhu	a1,-64(s0)
    80003c06:	00092503          	lw	a0,0(s2)
    80003c0a:	fffff097          	auipc	ra,0xfffff
    80003c0e:	74e080e7          	jalr	1870(ra) # 80003358 <iget>
    80003c12:	a011                	j	80003c16 <dirlookup+0xa0>
  return 0;
    80003c14:	4501                	li	a0,0
}
    80003c16:	70e2                	ld	ra,56(sp)
    80003c18:	7442                	ld	s0,48(sp)
    80003c1a:	74a2                	ld	s1,40(sp)
    80003c1c:	7902                	ld	s2,32(sp)
    80003c1e:	69e2                	ld	s3,24(sp)
    80003c20:	6a42                	ld	s4,16(sp)
    80003c22:	6121                	addi	sp,sp,64
    80003c24:	8082                	ret

0000000080003c26 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003c26:	711d                	addi	sp,sp,-96
    80003c28:	ec86                	sd	ra,88(sp)
    80003c2a:	e8a2                	sd	s0,80(sp)
    80003c2c:	e4a6                	sd	s1,72(sp)
    80003c2e:	e0ca                	sd	s2,64(sp)
    80003c30:	fc4e                	sd	s3,56(sp)
    80003c32:	f852                	sd	s4,48(sp)
    80003c34:	f456                	sd	s5,40(sp)
    80003c36:	f05a                	sd	s6,32(sp)
    80003c38:	ec5e                	sd	s7,24(sp)
    80003c3a:	e862                	sd	s8,16(sp)
    80003c3c:	e466                	sd	s9,8(sp)
    80003c3e:	e06a                	sd	s10,0(sp)
    80003c40:	1080                	addi	s0,sp,96
    80003c42:	84aa                	mv	s1,a0
    80003c44:	8b2e                	mv	s6,a1
    80003c46:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003c48:	00054703          	lbu	a4,0(a0)
    80003c4c:	02f00793          	li	a5,47
    80003c50:	02f70363          	beq	a4,a5,80003c76 <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003c54:	ffffe097          	auipc	ra,0xffffe
    80003c58:	d58080e7          	jalr	-680(ra) # 800019ac <myproc>
    80003c5c:	15053503          	ld	a0,336(a0)
    80003c60:	00000097          	auipc	ra,0x0
    80003c64:	9f4080e7          	jalr	-1548(ra) # 80003654 <idup>
    80003c68:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003c6a:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003c6e:	4cb5                	li	s9,13
  len = path - s;
    80003c70:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003c72:	4c05                	li	s8,1
    80003c74:	a87d                	j	80003d32 <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    80003c76:	4585                	li	a1,1
    80003c78:	4505                	li	a0,1
    80003c7a:	fffff097          	auipc	ra,0xfffff
    80003c7e:	6de080e7          	jalr	1758(ra) # 80003358 <iget>
    80003c82:	8a2a                	mv	s4,a0
    80003c84:	b7dd                	j	80003c6a <namex+0x44>
      iunlockput(ip);
    80003c86:	8552                	mv	a0,s4
    80003c88:	00000097          	auipc	ra,0x0
    80003c8c:	c6c080e7          	jalr	-916(ra) # 800038f4 <iunlockput>
      return 0;
    80003c90:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003c92:	8552                	mv	a0,s4
    80003c94:	60e6                	ld	ra,88(sp)
    80003c96:	6446                	ld	s0,80(sp)
    80003c98:	64a6                	ld	s1,72(sp)
    80003c9a:	6906                	ld	s2,64(sp)
    80003c9c:	79e2                	ld	s3,56(sp)
    80003c9e:	7a42                	ld	s4,48(sp)
    80003ca0:	7aa2                	ld	s5,40(sp)
    80003ca2:	7b02                	ld	s6,32(sp)
    80003ca4:	6be2                	ld	s7,24(sp)
    80003ca6:	6c42                	ld	s8,16(sp)
    80003ca8:	6ca2                	ld	s9,8(sp)
    80003caa:	6d02                	ld	s10,0(sp)
    80003cac:	6125                	addi	sp,sp,96
    80003cae:	8082                	ret
      iunlock(ip);
    80003cb0:	8552                	mv	a0,s4
    80003cb2:	00000097          	auipc	ra,0x0
    80003cb6:	aa2080e7          	jalr	-1374(ra) # 80003754 <iunlock>
      return ip;
    80003cba:	bfe1                	j	80003c92 <namex+0x6c>
      iunlockput(ip);
    80003cbc:	8552                	mv	a0,s4
    80003cbe:	00000097          	auipc	ra,0x0
    80003cc2:	c36080e7          	jalr	-970(ra) # 800038f4 <iunlockput>
      return 0;
    80003cc6:	8a4e                	mv	s4,s3
    80003cc8:	b7e9                	j	80003c92 <namex+0x6c>
  len = path - s;
    80003cca:	40998633          	sub	a2,s3,s1
    80003cce:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80003cd2:	09acd863          	bge	s9,s10,80003d62 <namex+0x13c>
    memmove(name, s, DIRSIZ);
    80003cd6:	4639                	li	a2,14
    80003cd8:	85a6                	mv	a1,s1
    80003cda:	8556                	mv	a0,s5
    80003cdc:	ffffd097          	auipc	ra,0xffffd
    80003ce0:	052080e7          	jalr	82(ra) # 80000d2e <memmove>
    80003ce4:	84ce                	mv	s1,s3
  while(*path == '/')
    80003ce6:	0004c783          	lbu	a5,0(s1)
    80003cea:	01279763          	bne	a5,s2,80003cf8 <namex+0xd2>
    path++;
    80003cee:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003cf0:	0004c783          	lbu	a5,0(s1)
    80003cf4:	ff278de3          	beq	a5,s2,80003cee <namex+0xc8>
    ilock(ip);
    80003cf8:	8552                	mv	a0,s4
    80003cfa:	00000097          	auipc	ra,0x0
    80003cfe:	998080e7          	jalr	-1640(ra) # 80003692 <ilock>
    if(ip->type != T_DIR){
    80003d02:	044a1783          	lh	a5,68(s4)
    80003d06:	f98790e3          	bne	a5,s8,80003c86 <namex+0x60>
    if(nameiparent && *path == '\0'){
    80003d0a:	000b0563          	beqz	s6,80003d14 <namex+0xee>
    80003d0e:	0004c783          	lbu	a5,0(s1)
    80003d12:	dfd9                	beqz	a5,80003cb0 <namex+0x8a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003d14:	865e                	mv	a2,s7
    80003d16:	85d6                	mv	a1,s5
    80003d18:	8552                	mv	a0,s4
    80003d1a:	00000097          	auipc	ra,0x0
    80003d1e:	e5c080e7          	jalr	-420(ra) # 80003b76 <dirlookup>
    80003d22:	89aa                	mv	s3,a0
    80003d24:	dd41                	beqz	a0,80003cbc <namex+0x96>
    iunlockput(ip);
    80003d26:	8552                	mv	a0,s4
    80003d28:	00000097          	auipc	ra,0x0
    80003d2c:	bcc080e7          	jalr	-1076(ra) # 800038f4 <iunlockput>
    ip = next;
    80003d30:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003d32:	0004c783          	lbu	a5,0(s1)
    80003d36:	01279763          	bne	a5,s2,80003d44 <namex+0x11e>
    path++;
    80003d3a:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003d3c:	0004c783          	lbu	a5,0(s1)
    80003d40:	ff278de3          	beq	a5,s2,80003d3a <namex+0x114>
  if(*path == 0)
    80003d44:	cb9d                	beqz	a5,80003d7a <namex+0x154>
  while(*path != '/' && *path != 0)
    80003d46:	0004c783          	lbu	a5,0(s1)
    80003d4a:	89a6                	mv	s3,s1
  len = path - s;
    80003d4c:	8d5e                	mv	s10,s7
    80003d4e:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003d50:	01278963          	beq	a5,s2,80003d62 <namex+0x13c>
    80003d54:	dbbd                	beqz	a5,80003cca <namex+0xa4>
    path++;
    80003d56:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003d58:	0009c783          	lbu	a5,0(s3)
    80003d5c:	ff279ce3          	bne	a5,s2,80003d54 <namex+0x12e>
    80003d60:	b7ad                	j	80003cca <namex+0xa4>
    memmove(name, s, len);
    80003d62:	2601                	sext.w	a2,a2
    80003d64:	85a6                	mv	a1,s1
    80003d66:	8556                	mv	a0,s5
    80003d68:	ffffd097          	auipc	ra,0xffffd
    80003d6c:	fc6080e7          	jalr	-58(ra) # 80000d2e <memmove>
    name[len] = 0;
    80003d70:	9d56                	add	s10,s10,s5
    80003d72:	000d0023          	sb	zero,0(s10)
    80003d76:	84ce                	mv	s1,s3
    80003d78:	b7bd                	j	80003ce6 <namex+0xc0>
  if(nameiparent){
    80003d7a:	f00b0ce3          	beqz	s6,80003c92 <namex+0x6c>
    iput(ip);
    80003d7e:	8552                	mv	a0,s4
    80003d80:	00000097          	auipc	ra,0x0
    80003d84:	acc080e7          	jalr	-1332(ra) # 8000384c <iput>
    return 0;
    80003d88:	4a01                	li	s4,0
    80003d8a:	b721                	j	80003c92 <namex+0x6c>

0000000080003d8c <dirlink>:
{
    80003d8c:	7139                	addi	sp,sp,-64
    80003d8e:	fc06                	sd	ra,56(sp)
    80003d90:	f822                	sd	s0,48(sp)
    80003d92:	f426                	sd	s1,40(sp)
    80003d94:	f04a                	sd	s2,32(sp)
    80003d96:	ec4e                	sd	s3,24(sp)
    80003d98:	e852                	sd	s4,16(sp)
    80003d9a:	0080                	addi	s0,sp,64
    80003d9c:	892a                	mv	s2,a0
    80003d9e:	8a2e                	mv	s4,a1
    80003da0:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003da2:	4601                	li	a2,0
    80003da4:	00000097          	auipc	ra,0x0
    80003da8:	dd2080e7          	jalr	-558(ra) # 80003b76 <dirlookup>
    80003dac:	e93d                	bnez	a0,80003e22 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003dae:	04c92483          	lw	s1,76(s2)
    80003db2:	c49d                	beqz	s1,80003de0 <dirlink+0x54>
    80003db4:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003db6:	4741                	li	a4,16
    80003db8:	86a6                	mv	a3,s1
    80003dba:	fc040613          	addi	a2,s0,-64
    80003dbe:	4581                	li	a1,0
    80003dc0:	854a                	mv	a0,s2
    80003dc2:	00000097          	auipc	ra,0x0
    80003dc6:	b84080e7          	jalr	-1148(ra) # 80003946 <readi>
    80003dca:	47c1                	li	a5,16
    80003dcc:	06f51163          	bne	a0,a5,80003e2e <dirlink+0xa2>
    if(de.inum == 0)
    80003dd0:	fc045783          	lhu	a5,-64(s0)
    80003dd4:	c791                	beqz	a5,80003de0 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003dd6:	24c1                	addiw	s1,s1,16
    80003dd8:	04c92783          	lw	a5,76(s2)
    80003ddc:	fcf4ede3          	bltu	s1,a5,80003db6 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003de0:	4639                	li	a2,14
    80003de2:	85d2                	mv	a1,s4
    80003de4:	fc240513          	addi	a0,s0,-62
    80003de8:	ffffd097          	auipc	ra,0xffffd
    80003dec:	ff6080e7          	jalr	-10(ra) # 80000dde <strncpy>
  de.inum = inum;
    80003df0:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003df4:	4741                	li	a4,16
    80003df6:	86a6                	mv	a3,s1
    80003df8:	fc040613          	addi	a2,s0,-64
    80003dfc:	4581                	li	a1,0
    80003dfe:	854a                	mv	a0,s2
    80003e00:	00000097          	auipc	ra,0x0
    80003e04:	c3e080e7          	jalr	-962(ra) # 80003a3e <writei>
    80003e08:	1541                	addi	a0,a0,-16
    80003e0a:	00a03533          	snez	a0,a0
    80003e0e:	40a00533          	neg	a0,a0
}
    80003e12:	70e2                	ld	ra,56(sp)
    80003e14:	7442                	ld	s0,48(sp)
    80003e16:	74a2                	ld	s1,40(sp)
    80003e18:	7902                	ld	s2,32(sp)
    80003e1a:	69e2                	ld	s3,24(sp)
    80003e1c:	6a42                	ld	s4,16(sp)
    80003e1e:	6121                	addi	sp,sp,64
    80003e20:	8082                	ret
    iput(ip);
    80003e22:	00000097          	auipc	ra,0x0
    80003e26:	a2a080e7          	jalr	-1494(ra) # 8000384c <iput>
    return -1;
    80003e2a:	557d                	li	a0,-1
    80003e2c:	b7dd                	j	80003e12 <dirlink+0x86>
      panic("dirlink read");
    80003e2e:	00005517          	auipc	a0,0x5
    80003e32:	82250513          	addi	a0,a0,-2014 # 80008650 <syscalls+0x200>
    80003e36:	ffffc097          	auipc	ra,0xffffc
    80003e3a:	70a080e7          	jalr	1802(ra) # 80000540 <panic>

0000000080003e3e <namei>:

struct inode*
namei(char *path)
{
    80003e3e:	1101                	addi	sp,sp,-32
    80003e40:	ec06                	sd	ra,24(sp)
    80003e42:	e822                	sd	s0,16(sp)
    80003e44:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003e46:	fe040613          	addi	a2,s0,-32
    80003e4a:	4581                	li	a1,0
    80003e4c:	00000097          	auipc	ra,0x0
    80003e50:	dda080e7          	jalr	-550(ra) # 80003c26 <namex>
}
    80003e54:	60e2                	ld	ra,24(sp)
    80003e56:	6442                	ld	s0,16(sp)
    80003e58:	6105                	addi	sp,sp,32
    80003e5a:	8082                	ret

0000000080003e5c <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003e5c:	1141                	addi	sp,sp,-16
    80003e5e:	e406                	sd	ra,8(sp)
    80003e60:	e022                	sd	s0,0(sp)
    80003e62:	0800                	addi	s0,sp,16
    80003e64:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003e66:	4585                	li	a1,1
    80003e68:	00000097          	auipc	ra,0x0
    80003e6c:	dbe080e7          	jalr	-578(ra) # 80003c26 <namex>
}
    80003e70:	60a2                	ld	ra,8(sp)
    80003e72:	6402                	ld	s0,0(sp)
    80003e74:	0141                	addi	sp,sp,16
    80003e76:	8082                	ret

0000000080003e78 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003e78:	1101                	addi	sp,sp,-32
    80003e7a:	ec06                	sd	ra,24(sp)
    80003e7c:	e822                	sd	s0,16(sp)
    80003e7e:	e426                	sd	s1,8(sp)
    80003e80:	e04a                	sd	s2,0(sp)
    80003e82:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003e84:	0001d917          	auipc	s2,0x1d
    80003e88:	edc90913          	addi	s2,s2,-292 # 80020d60 <log>
    80003e8c:	01892583          	lw	a1,24(s2)
    80003e90:	02892503          	lw	a0,40(s2)
    80003e94:	fffff097          	auipc	ra,0xfffff
    80003e98:	fe6080e7          	jalr	-26(ra) # 80002e7a <bread>
    80003e9c:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003e9e:	02c92683          	lw	a3,44(s2)
    80003ea2:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003ea4:	02d05863          	blez	a3,80003ed4 <write_head+0x5c>
    80003ea8:	0001d797          	auipc	a5,0x1d
    80003eac:	ee878793          	addi	a5,a5,-280 # 80020d90 <log+0x30>
    80003eb0:	05c50713          	addi	a4,a0,92
    80003eb4:	36fd                	addiw	a3,a3,-1
    80003eb6:	02069613          	slli	a2,a3,0x20
    80003eba:	01e65693          	srli	a3,a2,0x1e
    80003ebe:	0001d617          	auipc	a2,0x1d
    80003ec2:	ed660613          	addi	a2,a2,-298 # 80020d94 <log+0x34>
    80003ec6:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80003ec8:	4390                	lw	a2,0(a5)
    80003eca:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003ecc:	0791                	addi	a5,a5,4
    80003ece:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    80003ed0:	fed79ce3          	bne	a5,a3,80003ec8 <write_head+0x50>
  }
  bwrite(buf);
    80003ed4:	8526                	mv	a0,s1
    80003ed6:	fffff097          	auipc	ra,0xfffff
    80003eda:	096080e7          	jalr	150(ra) # 80002f6c <bwrite>
  brelse(buf);
    80003ede:	8526                	mv	a0,s1
    80003ee0:	fffff097          	auipc	ra,0xfffff
    80003ee4:	0ca080e7          	jalr	202(ra) # 80002faa <brelse>
}
    80003ee8:	60e2                	ld	ra,24(sp)
    80003eea:	6442                	ld	s0,16(sp)
    80003eec:	64a2                	ld	s1,8(sp)
    80003eee:	6902                	ld	s2,0(sp)
    80003ef0:	6105                	addi	sp,sp,32
    80003ef2:	8082                	ret

0000000080003ef4 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ef4:	0001d797          	auipc	a5,0x1d
    80003ef8:	e987a783          	lw	a5,-360(a5) # 80020d8c <log+0x2c>
    80003efc:	0af05d63          	blez	a5,80003fb6 <install_trans+0xc2>
{
    80003f00:	7139                	addi	sp,sp,-64
    80003f02:	fc06                	sd	ra,56(sp)
    80003f04:	f822                	sd	s0,48(sp)
    80003f06:	f426                	sd	s1,40(sp)
    80003f08:	f04a                	sd	s2,32(sp)
    80003f0a:	ec4e                	sd	s3,24(sp)
    80003f0c:	e852                	sd	s4,16(sp)
    80003f0e:	e456                	sd	s5,8(sp)
    80003f10:	e05a                	sd	s6,0(sp)
    80003f12:	0080                	addi	s0,sp,64
    80003f14:	8b2a                	mv	s6,a0
    80003f16:	0001da97          	auipc	s5,0x1d
    80003f1a:	e7aa8a93          	addi	s5,s5,-390 # 80020d90 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f1e:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003f20:	0001d997          	auipc	s3,0x1d
    80003f24:	e4098993          	addi	s3,s3,-448 # 80020d60 <log>
    80003f28:	a00d                	j	80003f4a <install_trans+0x56>
    brelse(lbuf);
    80003f2a:	854a                	mv	a0,s2
    80003f2c:	fffff097          	auipc	ra,0xfffff
    80003f30:	07e080e7          	jalr	126(ra) # 80002faa <brelse>
    brelse(dbuf);
    80003f34:	8526                	mv	a0,s1
    80003f36:	fffff097          	auipc	ra,0xfffff
    80003f3a:	074080e7          	jalr	116(ra) # 80002faa <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f3e:	2a05                	addiw	s4,s4,1
    80003f40:	0a91                	addi	s5,s5,4
    80003f42:	02c9a783          	lw	a5,44(s3)
    80003f46:	04fa5e63          	bge	s4,a5,80003fa2 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003f4a:	0189a583          	lw	a1,24(s3)
    80003f4e:	014585bb          	addw	a1,a1,s4
    80003f52:	2585                	addiw	a1,a1,1
    80003f54:	0289a503          	lw	a0,40(s3)
    80003f58:	fffff097          	auipc	ra,0xfffff
    80003f5c:	f22080e7          	jalr	-222(ra) # 80002e7a <bread>
    80003f60:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003f62:	000aa583          	lw	a1,0(s5)
    80003f66:	0289a503          	lw	a0,40(s3)
    80003f6a:	fffff097          	auipc	ra,0xfffff
    80003f6e:	f10080e7          	jalr	-240(ra) # 80002e7a <bread>
    80003f72:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003f74:	40000613          	li	a2,1024
    80003f78:	05890593          	addi	a1,s2,88
    80003f7c:	05850513          	addi	a0,a0,88
    80003f80:	ffffd097          	auipc	ra,0xffffd
    80003f84:	dae080e7          	jalr	-594(ra) # 80000d2e <memmove>
    bwrite(dbuf);  // write dst to disk
    80003f88:	8526                	mv	a0,s1
    80003f8a:	fffff097          	auipc	ra,0xfffff
    80003f8e:	fe2080e7          	jalr	-30(ra) # 80002f6c <bwrite>
    if(recovering == 0)
    80003f92:	f80b1ce3          	bnez	s6,80003f2a <install_trans+0x36>
      bunpin(dbuf);
    80003f96:	8526                	mv	a0,s1
    80003f98:	fffff097          	auipc	ra,0xfffff
    80003f9c:	0ec080e7          	jalr	236(ra) # 80003084 <bunpin>
    80003fa0:	b769                	j	80003f2a <install_trans+0x36>
}
    80003fa2:	70e2                	ld	ra,56(sp)
    80003fa4:	7442                	ld	s0,48(sp)
    80003fa6:	74a2                	ld	s1,40(sp)
    80003fa8:	7902                	ld	s2,32(sp)
    80003faa:	69e2                	ld	s3,24(sp)
    80003fac:	6a42                	ld	s4,16(sp)
    80003fae:	6aa2                	ld	s5,8(sp)
    80003fb0:	6b02                	ld	s6,0(sp)
    80003fb2:	6121                	addi	sp,sp,64
    80003fb4:	8082                	ret
    80003fb6:	8082                	ret

0000000080003fb8 <initlog>:
{
    80003fb8:	7179                	addi	sp,sp,-48
    80003fba:	f406                	sd	ra,40(sp)
    80003fbc:	f022                	sd	s0,32(sp)
    80003fbe:	ec26                	sd	s1,24(sp)
    80003fc0:	e84a                	sd	s2,16(sp)
    80003fc2:	e44e                	sd	s3,8(sp)
    80003fc4:	1800                	addi	s0,sp,48
    80003fc6:	892a                	mv	s2,a0
    80003fc8:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003fca:	0001d497          	auipc	s1,0x1d
    80003fce:	d9648493          	addi	s1,s1,-618 # 80020d60 <log>
    80003fd2:	00004597          	auipc	a1,0x4
    80003fd6:	68e58593          	addi	a1,a1,1678 # 80008660 <syscalls+0x210>
    80003fda:	8526                	mv	a0,s1
    80003fdc:	ffffd097          	auipc	ra,0xffffd
    80003fe0:	b6a080e7          	jalr	-1174(ra) # 80000b46 <initlock>
  log.start = sb->logstart;
    80003fe4:	0149a583          	lw	a1,20(s3)
    80003fe8:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80003fea:	0109a783          	lw	a5,16(s3)
    80003fee:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003ff0:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003ff4:	854a                	mv	a0,s2
    80003ff6:	fffff097          	auipc	ra,0xfffff
    80003ffa:	e84080e7          	jalr	-380(ra) # 80002e7a <bread>
  log.lh.n = lh->n;
    80003ffe:	4d34                	lw	a3,88(a0)
    80004000:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004002:	02d05663          	blez	a3,8000402e <initlog+0x76>
    80004006:	05c50793          	addi	a5,a0,92
    8000400a:	0001d717          	auipc	a4,0x1d
    8000400e:	d8670713          	addi	a4,a4,-634 # 80020d90 <log+0x30>
    80004012:	36fd                	addiw	a3,a3,-1
    80004014:	02069613          	slli	a2,a3,0x20
    80004018:	01e65693          	srli	a3,a2,0x1e
    8000401c:	06050613          	addi	a2,a0,96
    80004020:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004022:	4390                	lw	a2,0(a5)
    80004024:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004026:	0791                	addi	a5,a5,4
    80004028:	0711                	addi	a4,a4,4
    8000402a:	fed79ce3          	bne	a5,a3,80004022 <initlog+0x6a>
  brelse(buf);
    8000402e:	fffff097          	auipc	ra,0xfffff
    80004032:	f7c080e7          	jalr	-132(ra) # 80002faa <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004036:	4505                	li	a0,1
    80004038:	00000097          	auipc	ra,0x0
    8000403c:	ebc080e7          	jalr	-324(ra) # 80003ef4 <install_trans>
  log.lh.n = 0;
    80004040:	0001d797          	auipc	a5,0x1d
    80004044:	d407a623          	sw	zero,-692(a5) # 80020d8c <log+0x2c>
  write_head(); // clear the log
    80004048:	00000097          	auipc	ra,0x0
    8000404c:	e30080e7          	jalr	-464(ra) # 80003e78 <write_head>
}
    80004050:	70a2                	ld	ra,40(sp)
    80004052:	7402                	ld	s0,32(sp)
    80004054:	64e2                	ld	s1,24(sp)
    80004056:	6942                	ld	s2,16(sp)
    80004058:	69a2                	ld	s3,8(sp)
    8000405a:	6145                	addi	sp,sp,48
    8000405c:	8082                	ret

000000008000405e <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000405e:	1101                	addi	sp,sp,-32
    80004060:	ec06                	sd	ra,24(sp)
    80004062:	e822                	sd	s0,16(sp)
    80004064:	e426                	sd	s1,8(sp)
    80004066:	e04a                	sd	s2,0(sp)
    80004068:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000406a:	0001d517          	auipc	a0,0x1d
    8000406e:	cf650513          	addi	a0,a0,-778 # 80020d60 <log>
    80004072:	ffffd097          	auipc	ra,0xffffd
    80004076:	b64080e7          	jalr	-1180(ra) # 80000bd6 <acquire>
  while(1){
    if(log.committing){
    8000407a:	0001d497          	auipc	s1,0x1d
    8000407e:	ce648493          	addi	s1,s1,-794 # 80020d60 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004082:	4979                	li	s2,30
    80004084:	a039                	j	80004092 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004086:	85a6                	mv	a1,s1
    80004088:	8526                	mv	a0,s1
    8000408a:	ffffe097          	auipc	ra,0xffffe
    8000408e:	fd4080e7          	jalr	-44(ra) # 8000205e <sleep>
    if(log.committing){
    80004092:	50dc                	lw	a5,36(s1)
    80004094:	fbed                	bnez	a5,80004086 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004096:	5098                	lw	a4,32(s1)
    80004098:	2705                	addiw	a4,a4,1
    8000409a:	0007069b          	sext.w	a3,a4
    8000409e:	0027179b          	slliw	a5,a4,0x2
    800040a2:	9fb9                	addw	a5,a5,a4
    800040a4:	0017979b          	slliw	a5,a5,0x1
    800040a8:	54d8                	lw	a4,44(s1)
    800040aa:	9fb9                	addw	a5,a5,a4
    800040ac:	00f95963          	bge	s2,a5,800040be <begin_op+0x60>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800040b0:	85a6                	mv	a1,s1
    800040b2:	8526                	mv	a0,s1
    800040b4:	ffffe097          	auipc	ra,0xffffe
    800040b8:	faa080e7          	jalr	-86(ra) # 8000205e <sleep>
    800040bc:	bfd9                	j	80004092 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800040be:	0001d517          	auipc	a0,0x1d
    800040c2:	ca250513          	addi	a0,a0,-862 # 80020d60 <log>
    800040c6:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800040c8:	ffffd097          	auipc	ra,0xffffd
    800040cc:	bc2080e7          	jalr	-1086(ra) # 80000c8a <release>
      break;
    }
  }
}
    800040d0:	60e2                	ld	ra,24(sp)
    800040d2:	6442                	ld	s0,16(sp)
    800040d4:	64a2                	ld	s1,8(sp)
    800040d6:	6902                	ld	s2,0(sp)
    800040d8:	6105                	addi	sp,sp,32
    800040da:	8082                	ret

00000000800040dc <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800040dc:	7139                	addi	sp,sp,-64
    800040de:	fc06                	sd	ra,56(sp)
    800040e0:	f822                	sd	s0,48(sp)
    800040e2:	f426                	sd	s1,40(sp)
    800040e4:	f04a                	sd	s2,32(sp)
    800040e6:	ec4e                	sd	s3,24(sp)
    800040e8:	e852                	sd	s4,16(sp)
    800040ea:	e456                	sd	s5,8(sp)
    800040ec:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800040ee:	0001d497          	auipc	s1,0x1d
    800040f2:	c7248493          	addi	s1,s1,-910 # 80020d60 <log>
    800040f6:	8526                	mv	a0,s1
    800040f8:	ffffd097          	auipc	ra,0xffffd
    800040fc:	ade080e7          	jalr	-1314(ra) # 80000bd6 <acquire>
  log.outstanding -= 1;
    80004100:	509c                	lw	a5,32(s1)
    80004102:	37fd                	addiw	a5,a5,-1
    80004104:	0007891b          	sext.w	s2,a5
    80004108:	d09c                	sw	a5,32(s1)
  if(log.committing)
    8000410a:	50dc                	lw	a5,36(s1)
    8000410c:	e7b9                	bnez	a5,8000415a <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    8000410e:	04091e63          	bnez	s2,8000416a <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004112:	0001d497          	auipc	s1,0x1d
    80004116:	c4e48493          	addi	s1,s1,-946 # 80020d60 <log>
    8000411a:	4785                	li	a5,1
    8000411c:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000411e:	8526                	mv	a0,s1
    80004120:	ffffd097          	auipc	ra,0xffffd
    80004124:	b6a080e7          	jalr	-1174(ra) # 80000c8a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004128:	54dc                	lw	a5,44(s1)
    8000412a:	06f04763          	bgtz	a5,80004198 <end_op+0xbc>
    acquire(&log.lock);
    8000412e:	0001d497          	auipc	s1,0x1d
    80004132:	c3248493          	addi	s1,s1,-974 # 80020d60 <log>
    80004136:	8526                	mv	a0,s1
    80004138:	ffffd097          	auipc	ra,0xffffd
    8000413c:	a9e080e7          	jalr	-1378(ra) # 80000bd6 <acquire>
    log.committing = 0;
    80004140:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004144:	8526                	mv	a0,s1
    80004146:	ffffe097          	auipc	ra,0xffffe
    8000414a:	f7c080e7          	jalr	-132(ra) # 800020c2 <wakeup>
    release(&log.lock);
    8000414e:	8526                	mv	a0,s1
    80004150:	ffffd097          	auipc	ra,0xffffd
    80004154:	b3a080e7          	jalr	-1222(ra) # 80000c8a <release>
}
    80004158:	a03d                	j	80004186 <end_op+0xaa>
    panic("log.committing");
    8000415a:	00004517          	auipc	a0,0x4
    8000415e:	50e50513          	addi	a0,a0,1294 # 80008668 <syscalls+0x218>
    80004162:	ffffc097          	auipc	ra,0xffffc
    80004166:	3de080e7          	jalr	990(ra) # 80000540 <panic>
    wakeup(&log);
    8000416a:	0001d497          	auipc	s1,0x1d
    8000416e:	bf648493          	addi	s1,s1,-1034 # 80020d60 <log>
    80004172:	8526                	mv	a0,s1
    80004174:	ffffe097          	auipc	ra,0xffffe
    80004178:	f4e080e7          	jalr	-178(ra) # 800020c2 <wakeup>
  release(&log.lock);
    8000417c:	8526                	mv	a0,s1
    8000417e:	ffffd097          	auipc	ra,0xffffd
    80004182:	b0c080e7          	jalr	-1268(ra) # 80000c8a <release>
}
    80004186:	70e2                	ld	ra,56(sp)
    80004188:	7442                	ld	s0,48(sp)
    8000418a:	74a2                	ld	s1,40(sp)
    8000418c:	7902                	ld	s2,32(sp)
    8000418e:	69e2                	ld	s3,24(sp)
    80004190:	6a42                	ld	s4,16(sp)
    80004192:	6aa2                	ld	s5,8(sp)
    80004194:	6121                	addi	sp,sp,64
    80004196:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004198:	0001da97          	auipc	s5,0x1d
    8000419c:	bf8a8a93          	addi	s5,s5,-1032 # 80020d90 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800041a0:	0001da17          	auipc	s4,0x1d
    800041a4:	bc0a0a13          	addi	s4,s4,-1088 # 80020d60 <log>
    800041a8:	018a2583          	lw	a1,24(s4)
    800041ac:	012585bb          	addw	a1,a1,s2
    800041b0:	2585                	addiw	a1,a1,1
    800041b2:	028a2503          	lw	a0,40(s4)
    800041b6:	fffff097          	auipc	ra,0xfffff
    800041ba:	cc4080e7          	jalr	-828(ra) # 80002e7a <bread>
    800041be:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800041c0:	000aa583          	lw	a1,0(s5)
    800041c4:	028a2503          	lw	a0,40(s4)
    800041c8:	fffff097          	auipc	ra,0xfffff
    800041cc:	cb2080e7          	jalr	-846(ra) # 80002e7a <bread>
    800041d0:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800041d2:	40000613          	li	a2,1024
    800041d6:	05850593          	addi	a1,a0,88
    800041da:	05848513          	addi	a0,s1,88
    800041de:	ffffd097          	auipc	ra,0xffffd
    800041e2:	b50080e7          	jalr	-1200(ra) # 80000d2e <memmove>
    bwrite(to);  // write the log
    800041e6:	8526                	mv	a0,s1
    800041e8:	fffff097          	auipc	ra,0xfffff
    800041ec:	d84080e7          	jalr	-636(ra) # 80002f6c <bwrite>
    brelse(from);
    800041f0:	854e                	mv	a0,s3
    800041f2:	fffff097          	auipc	ra,0xfffff
    800041f6:	db8080e7          	jalr	-584(ra) # 80002faa <brelse>
    brelse(to);
    800041fa:	8526                	mv	a0,s1
    800041fc:	fffff097          	auipc	ra,0xfffff
    80004200:	dae080e7          	jalr	-594(ra) # 80002faa <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004204:	2905                	addiw	s2,s2,1
    80004206:	0a91                	addi	s5,s5,4
    80004208:	02ca2783          	lw	a5,44(s4)
    8000420c:	f8f94ee3          	blt	s2,a5,800041a8 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004210:	00000097          	auipc	ra,0x0
    80004214:	c68080e7          	jalr	-920(ra) # 80003e78 <write_head>
    install_trans(0); // Now install writes to home locations
    80004218:	4501                	li	a0,0
    8000421a:	00000097          	auipc	ra,0x0
    8000421e:	cda080e7          	jalr	-806(ra) # 80003ef4 <install_trans>
    log.lh.n = 0;
    80004222:	0001d797          	auipc	a5,0x1d
    80004226:	b607a523          	sw	zero,-1174(a5) # 80020d8c <log+0x2c>
    write_head();    // Erase the transaction from the log
    8000422a:	00000097          	auipc	ra,0x0
    8000422e:	c4e080e7          	jalr	-946(ra) # 80003e78 <write_head>
    80004232:	bdf5                	j	8000412e <end_op+0x52>

0000000080004234 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004234:	1101                	addi	sp,sp,-32
    80004236:	ec06                	sd	ra,24(sp)
    80004238:	e822                	sd	s0,16(sp)
    8000423a:	e426                	sd	s1,8(sp)
    8000423c:	e04a                	sd	s2,0(sp)
    8000423e:	1000                	addi	s0,sp,32
    80004240:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004242:	0001d917          	auipc	s2,0x1d
    80004246:	b1e90913          	addi	s2,s2,-1250 # 80020d60 <log>
    8000424a:	854a                	mv	a0,s2
    8000424c:	ffffd097          	auipc	ra,0xffffd
    80004250:	98a080e7          	jalr	-1654(ra) # 80000bd6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004254:	02c92603          	lw	a2,44(s2)
    80004258:	47f5                	li	a5,29
    8000425a:	06c7c563          	blt	a5,a2,800042c4 <log_write+0x90>
    8000425e:	0001d797          	auipc	a5,0x1d
    80004262:	b1e7a783          	lw	a5,-1250(a5) # 80020d7c <log+0x1c>
    80004266:	37fd                	addiw	a5,a5,-1
    80004268:	04f65e63          	bge	a2,a5,800042c4 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000426c:	0001d797          	auipc	a5,0x1d
    80004270:	b147a783          	lw	a5,-1260(a5) # 80020d80 <log+0x20>
    80004274:	06f05063          	blez	a5,800042d4 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004278:	4781                	li	a5,0
    8000427a:	06c05563          	blez	a2,800042e4 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000427e:	44cc                	lw	a1,12(s1)
    80004280:	0001d717          	auipc	a4,0x1d
    80004284:	b1070713          	addi	a4,a4,-1264 # 80020d90 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004288:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000428a:	4314                	lw	a3,0(a4)
    8000428c:	04b68c63          	beq	a3,a1,800042e4 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004290:	2785                	addiw	a5,a5,1
    80004292:	0711                	addi	a4,a4,4
    80004294:	fef61be3          	bne	a2,a5,8000428a <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004298:	0621                	addi	a2,a2,8
    8000429a:	060a                	slli	a2,a2,0x2
    8000429c:	0001d797          	auipc	a5,0x1d
    800042a0:	ac478793          	addi	a5,a5,-1340 # 80020d60 <log>
    800042a4:	97b2                	add	a5,a5,a2
    800042a6:	44d8                	lw	a4,12(s1)
    800042a8:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800042aa:	8526                	mv	a0,s1
    800042ac:	fffff097          	auipc	ra,0xfffff
    800042b0:	d9c080e7          	jalr	-612(ra) # 80003048 <bpin>
    log.lh.n++;
    800042b4:	0001d717          	auipc	a4,0x1d
    800042b8:	aac70713          	addi	a4,a4,-1364 # 80020d60 <log>
    800042bc:	575c                	lw	a5,44(a4)
    800042be:	2785                	addiw	a5,a5,1
    800042c0:	d75c                	sw	a5,44(a4)
    800042c2:	a82d                	j	800042fc <log_write+0xc8>
    panic("too big a transaction");
    800042c4:	00004517          	auipc	a0,0x4
    800042c8:	3b450513          	addi	a0,a0,948 # 80008678 <syscalls+0x228>
    800042cc:	ffffc097          	auipc	ra,0xffffc
    800042d0:	274080e7          	jalr	628(ra) # 80000540 <panic>
    panic("log_write outside of trans");
    800042d4:	00004517          	auipc	a0,0x4
    800042d8:	3bc50513          	addi	a0,a0,956 # 80008690 <syscalls+0x240>
    800042dc:	ffffc097          	auipc	ra,0xffffc
    800042e0:	264080e7          	jalr	612(ra) # 80000540 <panic>
  log.lh.block[i] = b->blockno;
    800042e4:	00878693          	addi	a3,a5,8
    800042e8:	068a                	slli	a3,a3,0x2
    800042ea:	0001d717          	auipc	a4,0x1d
    800042ee:	a7670713          	addi	a4,a4,-1418 # 80020d60 <log>
    800042f2:	9736                	add	a4,a4,a3
    800042f4:	44d4                	lw	a3,12(s1)
    800042f6:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800042f8:	faf609e3          	beq	a2,a5,800042aa <log_write+0x76>
  }
  release(&log.lock);
    800042fc:	0001d517          	auipc	a0,0x1d
    80004300:	a6450513          	addi	a0,a0,-1436 # 80020d60 <log>
    80004304:	ffffd097          	auipc	ra,0xffffd
    80004308:	986080e7          	jalr	-1658(ra) # 80000c8a <release>
}
    8000430c:	60e2                	ld	ra,24(sp)
    8000430e:	6442                	ld	s0,16(sp)
    80004310:	64a2                	ld	s1,8(sp)
    80004312:	6902                	ld	s2,0(sp)
    80004314:	6105                	addi	sp,sp,32
    80004316:	8082                	ret

0000000080004318 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004318:	1101                	addi	sp,sp,-32
    8000431a:	ec06                	sd	ra,24(sp)
    8000431c:	e822                	sd	s0,16(sp)
    8000431e:	e426                	sd	s1,8(sp)
    80004320:	e04a                	sd	s2,0(sp)
    80004322:	1000                	addi	s0,sp,32
    80004324:	84aa                	mv	s1,a0
    80004326:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004328:	00004597          	auipc	a1,0x4
    8000432c:	38858593          	addi	a1,a1,904 # 800086b0 <syscalls+0x260>
    80004330:	0521                	addi	a0,a0,8
    80004332:	ffffd097          	auipc	ra,0xffffd
    80004336:	814080e7          	jalr	-2028(ra) # 80000b46 <initlock>
  lk->name = name;
    8000433a:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000433e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004342:	0204a423          	sw	zero,40(s1)
}
    80004346:	60e2                	ld	ra,24(sp)
    80004348:	6442                	ld	s0,16(sp)
    8000434a:	64a2                	ld	s1,8(sp)
    8000434c:	6902                	ld	s2,0(sp)
    8000434e:	6105                	addi	sp,sp,32
    80004350:	8082                	ret

0000000080004352 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004352:	1101                	addi	sp,sp,-32
    80004354:	ec06                	sd	ra,24(sp)
    80004356:	e822                	sd	s0,16(sp)
    80004358:	e426                	sd	s1,8(sp)
    8000435a:	e04a                	sd	s2,0(sp)
    8000435c:	1000                	addi	s0,sp,32
    8000435e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004360:	00850913          	addi	s2,a0,8
    80004364:	854a                	mv	a0,s2
    80004366:	ffffd097          	auipc	ra,0xffffd
    8000436a:	870080e7          	jalr	-1936(ra) # 80000bd6 <acquire>
  while (lk->locked) {
    8000436e:	409c                	lw	a5,0(s1)
    80004370:	cb89                	beqz	a5,80004382 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004372:	85ca                	mv	a1,s2
    80004374:	8526                	mv	a0,s1
    80004376:	ffffe097          	auipc	ra,0xffffe
    8000437a:	ce8080e7          	jalr	-792(ra) # 8000205e <sleep>
  while (lk->locked) {
    8000437e:	409c                	lw	a5,0(s1)
    80004380:	fbed                	bnez	a5,80004372 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004382:	4785                	li	a5,1
    80004384:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004386:	ffffd097          	auipc	ra,0xffffd
    8000438a:	626080e7          	jalr	1574(ra) # 800019ac <myproc>
    8000438e:	591c                	lw	a5,48(a0)
    80004390:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004392:	854a                	mv	a0,s2
    80004394:	ffffd097          	auipc	ra,0xffffd
    80004398:	8f6080e7          	jalr	-1802(ra) # 80000c8a <release>
}
    8000439c:	60e2                	ld	ra,24(sp)
    8000439e:	6442                	ld	s0,16(sp)
    800043a0:	64a2                	ld	s1,8(sp)
    800043a2:	6902                	ld	s2,0(sp)
    800043a4:	6105                	addi	sp,sp,32
    800043a6:	8082                	ret

00000000800043a8 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800043a8:	1101                	addi	sp,sp,-32
    800043aa:	ec06                	sd	ra,24(sp)
    800043ac:	e822                	sd	s0,16(sp)
    800043ae:	e426                	sd	s1,8(sp)
    800043b0:	e04a                	sd	s2,0(sp)
    800043b2:	1000                	addi	s0,sp,32
    800043b4:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800043b6:	00850913          	addi	s2,a0,8
    800043ba:	854a                	mv	a0,s2
    800043bc:	ffffd097          	auipc	ra,0xffffd
    800043c0:	81a080e7          	jalr	-2022(ra) # 80000bd6 <acquire>
  lk->locked = 0;
    800043c4:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800043c8:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800043cc:	8526                	mv	a0,s1
    800043ce:	ffffe097          	auipc	ra,0xffffe
    800043d2:	cf4080e7          	jalr	-780(ra) # 800020c2 <wakeup>
  release(&lk->lk);
    800043d6:	854a                	mv	a0,s2
    800043d8:	ffffd097          	auipc	ra,0xffffd
    800043dc:	8b2080e7          	jalr	-1870(ra) # 80000c8a <release>
}
    800043e0:	60e2                	ld	ra,24(sp)
    800043e2:	6442                	ld	s0,16(sp)
    800043e4:	64a2                	ld	s1,8(sp)
    800043e6:	6902                	ld	s2,0(sp)
    800043e8:	6105                	addi	sp,sp,32
    800043ea:	8082                	ret

00000000800043ec <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800043ec:	7179                	addi	sp,sp,-48
    800043ee:	f406                	sd	ra,40(sp)
    800043f0:	f022                	sd	s0,32(sp)
    800043f2:	ec26                	sd	s1,24(sp)
    800043f4:	e84a                	sd	s2,16(sp)
    800043f6:	e44e                	sd	s3,8(sp)
    800043f8:	1800                	addi	s0,sp,48
    800043fa:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800043fc:	00850913          	addi	s2,a0,8
    80004400:	854a                	mv	a0,s2
    80004402:	ffffc097          	auipc	ra,0xffffc
    80004406:	7d4080e7          	jalr	2004(ra) # 80000bd6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000440a:	409c                	lw	a5,0(s1)
    8000440c:	ef99                	bnez	a5,8000442a <holdingsleep+0x3e>
    8000440e:	4481                	li	s1,0
  release(&lk->lk);
    80004410:	854a                	mv	a0,s2
    80004412:	ffffd097          	auipc	ra,0xffffd
    80004416:	878080e7          	jalr	-1928(ra) # 80000c8a <release>
  return r;
}
    8000441a:	8526                	mv	a0,s1
    8000441c:	70a2                	ld	ra,40(sp)
    8000441e:	7402                	ld	s0,32(sp)
    80004420:	64e2                	ld	s1,24(sp)
    80004422:	6942                	ld	s2,16(sp)
    80004424:	69a2                	ld	s3,8(sp)
    80004426:	6145                	addi	sp,sp,48
    80004428:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    8000442a:	0284a983          	lw	s3,40(s1)
    8000442e:	ffffd097          	auipc	ra,0xffffd
    80004432:	57e080e7          	jalr	1406(ra) # 800019ac <myproc>
    80004436:	5904                	lw	s1,48(a0)
    80004438:	413484b3          	sub	s1,s1,s3
    8000443c:	0014b493          	seqz	s1,s1
    80004440:	bfc1                	j	80004410 <holdingsleep+0x24>

0000000080004442 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004442:	1141                	addi	sp,sp,-16
    80004444:	e406                	sd	ra,8(sp)
    80004446:	e022                	sd	s0,0(sp)
    80004448:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000444a:	00004597          	auipc	a1,0x4
    8000444e:	27658593          	addi	a1,a1,630 # 800086c0 <syscalls+0x270>
    80004452:	0001d517          	auipc	a0,0x1d
    80004456:	a5650513          	addi	a0,a0,-1450 # 80020ea8 <ftable>
    8000445a:	ffffc097          	auipc	ra,0xffffc
    8000445e:	6ec080e7          	jalr	1772(ra) # 80000b46 <initlock>
}
    80004462:	60a2                	ld	ra,8(sp)
    80004464:	6402                	ld	s0,0(sp)
    80004466:	0141                	addi	sp,sp,16
    80004468:	8082                	ret

000000008000446a <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000446a:	1101                	addi	sp,sp,-32
    8000446c:	ec06                	sd	ra,24(sp)
    8000446e:	e822                	sd	s0,16(sp)
    80004470:	e426                	sd	s1,8(sp)
    80004472:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004474:	0001d517          	auipc	a0,0x1d
    80004478:	a3450513          	addi	a0,a0,-1484 # 80020ea8 <ftable>
    8000447c:	ffffc097          	auipc	ra,0xffffc
    80004480:	75a080e7          	jalr	1882(ra) # 80000bd6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004484:	0001d497          	auipc	s1,0x1d
    80004488:	a3c48493          	addi	s1,s1,-1476 # 80020ec0 <ftable+0x18>
    8000448c:	0001e717          	auipc	a4,0x1e
    80004490:	9d470713          	addi	a4,a4,-1580 # 80021e60 <disk>
    if(f->ref == 0){
    80004494:	40dc                	lw	a5,4(s1)
    80004496:	cf99                	beqz	a5,800044b4 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004498:	02848493          	addi	s1,s1,40
    8000449c:	fee49ce3          	bne	s1,a4,80004494 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800044a0:	0001d517          	auipc	a0,0x1d
    800044a4:	a0850513          	addi	a0,a0,-1528 # 80020ea8 <ftable>
    800044a8:	ffffc097          	auipc	ra,0xffffc
    800044ac:	7e2080e7          	jalr	2018(ra) # 80000c8a <release>
  return 0;
    800044b0:	4481                	li	s1,0
    800044b2:	a819                	j	800044c8 <filealloc+0x5e>
      f->ref = 1;
    800044b4:	4785                	li	a5,1
    800044b6:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800044b8:	0001d517          	auipc	a0,0x1d
    800044bc:	9f050513          	addi	a0,a0,-1552 # 80020ea8 <ftable>
    800044c0:	ffffc097          	auipc	ra,0xffffc
    800044c4:	7ca080e7          	jalr	1994(ra) # 80000c8a <release>
}
    800044c8:	8526                	mv	a0,s1
    800044ca:	60e2                	ld	ra,24(sp)
    800044cc:	6442                	ld	s0,16(sp)
    800044ce:	64a2                	ld	s1,8(sp)
    800044d0:	6105                	addi	sp,sp,32
    800044d2:	8082                	ret

00000000800044d4 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800044d4:	1101                	addi	sp,sp,-32
    800044d6:	ec06                	sd	ra,24(sp)
    800044d8:	e822                	sd	s0,16(sp)
    800044da:	e426                	sd	s1,8(sp)
    800044dc:	1000                	addi	s0,sp,32
    800044de:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800044e0:	0001d517          	auipc	a0,0x1d
    800044e4:	9c850513          	addi	a0,a0,-1592 # 80020ea8 <ftable>
    800044e8:	ffffc097          	auipc	ra,0xffffc
    800044ec:	6ee080e7          	jalr	1774(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    800044f0:	40dc                	lw	a5,4(s1)
    800044f2:	02f05263          	blez	a5,80004516 <filedup+0x42>
    panic("filedup");
  f->ref++;
    800044f6:	2785                	addiw	a5,a5,1
    800044f8:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800044fa:	0001d517          	auipc	a0,0x1d
    800044fe:	9ae50513          	addi	a0,a0,-1618 # 80020ea8 <ftable>
    80004502:	ffffc097          	auipc	ra,0xffffc
    80004506:	788080e7          	jalr	1928(ra) # 80000c8a <release>
  return f;
}
    8000450a:	8526                	mv	a0,s1
    8000450c:	60e2                	ld	ra,24(sp)
    8000450e:	6442                	ld	s0,16(sp)
    80004510:	64a2                	ld	s1,8(sp)
    80004512:	6105                	addi	sp,sp,32
    80004514:	8082                	ret
    panic("filedup");
    80004516:	00004517          	auipc	a0,0x4
    8000451a:	1b250513          	addi	a0,a0,434 # 800086c8 <syscalls+0x278>
    8000451e:	ffffc097          	auipc	ra,0xffffc
    80004522:	022080e7          	jalr	34(ra) # 80000540 <panic>

0000000080004526 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004526:	7139                	addi	sp,sp,-64
    80004528:	fc06                	sd	ra,56(sp)
    8000452a:	f822                	sd	s0,48(sp)
    8000452c:	f426                	sd	s1,40(sp)
    8000452e:	f04a                	sd	s2,32(sp)
    80004530:	ec4e                	sd	s3,24(sp)
    80004532:	e852                	sd	s4,16(sp)
    80004534:	e456                	sd	s5,8(sp)
    80004536:	0080                	addi	s0,sp,64
    80004538:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000453a:	0001d517          	auipc	a0,0x1d
    8000453e:	96e50513          	addi	a0,a0,-1682 # 80020ea8 <ftable>
    80004542:	ffffc097          	auipc	ra,0xffffc
    80004546:	694080e7          	jalr	1684(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    8000454a:	40dc                	lw	a5,4(s1)
    8000454c:	06f05163          	blez	a5,800045ae <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004550:	37fd                	addiw	a5,a5,-1
    80004552:	0007871b          	sext.w	a4,a5
    80004556:	c0dc                	sw	a5,4(s1)
    80004558:	06e04363          	bgtz	a4,800045be <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000455c:	0004a903          	lw	s2,0(s1)
    80004560:	0094ca83          	lbu	s5,9(s1)
    80004564:	0104ba03          	ld	s4,16(s1)
    80004568:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    8000456c:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004570:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004574:	0001d517          	auipc	a0,0x1d
    80004578:	93450513          	addi	a0,a0,-1740 # 80020ea8 <ftable>
    8000457c:	ffffc097          	auipc	ra,0xffffc
    80004580:	70e080e7          	jalr	1806(ra) # 80000c8a <release>

  if(ff.type == FD_PIPE){
    80004584:	4785                	li	a5,1
    80004586:	04f90d63          	beq	s2,a5,800045e0 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000458a:	3979                	addiw	s2,s2,-2
    8000458c:	4785                	li	a5,1
    8000458e:	0527e063          	bltu	a5,s2,800045ce <fileclose+0xa8>
    begin_op();
    80004592:	00000097          	auipc	ra,0x0
    80004596:	acc080e7          	jalr	-1332(ra) # 8000405e <begin_op>
    iput(ff.ip);
    8000459a:	854e                	mv	a0,s3
    8000459c:	fffff097          	auipc	ra,0xfffff
    800045a0:	2b0080e7          	jalr	688(ra) # 8000384c <iput>
    end_op();
    800045a4:	00000097          	auipc	ra,0x0
    800045a8:	b38080e7          	jalr	-1224(ra) # 800040dc <end_op>
    800045ac:	a00d                	j	800045ce <fileclose+0xa8>
    panic("fileclose");
    800045ae:	00004517          	auipc	a0,0x4
    800045b2:	12250513          	addi	a0,a0,290 # 800086d0 <syscalls+0x280>
    800045b6:	ffffc097          	auipc	ra,0xffffc
    800045ba:	f8a080e7          	jalr	-118(ra) # 80000540 <panic>
    release(&ftable.lock);
    800045be:	0001d517          	auipc	a0,0x1d
    800045c2:	8ea50513          	addi	a0,a0,-1814 # 80020ea8 <ftable>
    800045c6:	ffffc097          	auipc	ra,0xffffc
    800045ca:	6c4080e7          	jalr	1732(ra) # 80000c8a <release>
  }
}
    800045ce:	70e2                	ld	ra,56(sp)
    800045d0:	7442                	ld	s0,48(sp)
    800045d2:	74a2                	ld	s1,40(sp)
    800045d4:	7902                	ld	s2,32(sp)
    800045d6:	69e2                	ld	s3,24(sp)
    800045d8:	6a42                	ld	s4,16(sp)
    800045da:	6aa2                	ld	s5,8(sp)
    800045dc:	6121                	addi	sp,sp,64
    800045de:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800045e0:	85d6                	mv	a1,s5
    800045e2:	8552                	mv	a0,s4
    800045e4:	00000097          	auipc	ra,0x0
    800045e8:	34c080e7          	jalr	844(ra) # 80004930 <pipeclose>
    800045ec:	b7cd                	j	800045ce <fileclose+0xa8>

00000000800045ee <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800045ee:	715d                	addi	sp,sp,-80
    800045f0:	e486                	sd	ra,72(sp)
    800045f2:	e0a2                	sd	s0,64(sp)
    800045f4:	fc26                	sd	s1,56(sp)
    800045f6:	f84a                	sd	s2,48(sp)
    800045f8:	f44e                	sd	s3,40(sp)
    800045fa:	0880                	addi	s0,sp,80
    800045fc:	84aa                	mv	s1,a0
    800045fe:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004600:	ffffd097          	auipc	ra,0xffffd
    80004604:	3ac080e7          	jalr	940(ra) # 800019ac <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004608:	409c                	lw	a5,0(s1)
    8000460a:	37f9                	addiw	a5,a5,-2
    8000460c:	4705                	li	a4,1
    8000460e:	04f76763          	bltu	a4,a5,8000465c <filestat+0x6e>
    80004612:	892a                	mv	s2,a0
    ilock(f->ip);
    80004614:	6c88                	ld	a0,24(s1)
    80004616:	fffff097          	auipc	ra,0xfffff
    8000461a:	07c080e7          	jalr	124(ra) # 80003692 <ilock>
    stati(f->ip, &st);
    8000461e:	fb840593          	addi	a1,s0,-72
    80004622:	6c88                	ld	a0,24(s1)
    80004624:	fffff097          	auipc	ra,0xfffff
    80004628:	2f8080e7          	jalr	760(ra) # 8000391c <stati>
    iunlock(f->ip);
    8000462c:	6c88                	ld	a0,24(s1)
    8000462e:	fffff097          	auipc	ra,0xfffff
    80004632:	126080e7          	jalr	294(ra) # 80003754 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004636:	46e1                	li	a3,24
    80004638:	fb840613          	addi	a2,s0,-72
    8000463c:	85ce                	mv	a1,s3
    8000463e:	05093503          	ld	a0,80(s2)
    80004642:	ffffd097          	auipc	ra,0xffffd
    80004646:	02a080e7          	jalr	42(ra) # 8000166c <copyout>
    8000464a:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    8000464e:	60a6                	ld	ra,72(sp)
    80004650:	6406                	ld	s0,64(sp)
    80004652:	74e2                	ld	s1,56(sp)
    80004654:	7942                	ld	s2,48(sp)
    80004656:	79a2                	ld	s3,40(sp)
    80004658:	6161                	addi	sp,sp,80
    8000465a:	8082                	ret
  return -1;
    8000465c:	557d                	li	a0,-1
    8000465e:	bfc5                	j	8000464e <filestat+0x60>

0000000080004660 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004660:	7179                	addi	sp,sp,-48
    80004662:	f406                	sd	ra,40(sp)
    80004664:	f022                	sd	s0,32(sp)
    80004666:	ec26                	sd	s1,24(sp)
    80004668:	e84a                	sd	s2,16(sp)
    8000466a:	e44e                	sd	s3,8(sp)
    8000466c:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000466e:	00854783          	lbu	a5,8(a0)
    80004672:	c3d5                	beqz	a5,80004716 <fileread+0xb6>
    80004674:	84aa                	mv	s1,a0
    80004676:	89ae                	mv	s3,a1
    80004678:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    8000467a:	411c                	lw	a5,0(a0)
    8000467c:	4705                	li	a4,1
    8000467e:	04e78963          	beq	a5,a4,800046d0 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004682:	470d                	li	a4,3
    80004684:	04e78d63          	beq	a5,a4,800046de <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004688:	4709                	li	a4,2
    8000468a:	06e79e63          	bne	a5,a4,80004706 <fileread+0xa6>
    ilock(f->ip);
    8000468e:	6d08                	ld	a0,24(a0)
    80004690:	fffff097          	auipc	ra,0xfffff
    80004694:	002080e7          	jalr	2(ra) # 80003692 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004698:	874a                	mv	a4,s2
    8000469a:	5094                	lw	a3,32(s1)
    8000469c:	864e                	mv	a2,s3
    8000469e:	4585                	li	a1,1
    800046a0:	6c88                	ld	a0,24(s1)
    800046a2:	fffff097          	auipc	ra,0xfffff
    800046a6:	2a4080e7          	jalr	676(ra) # 80003946 <readi>
    800046aa:	892a                	mv	s2,a0
    800046ac:	00a05563          	blez	a0,800046b6 <fileread+0x56>
      f->off += r;
    800046b0:	509c                	lw	a5,32(s1)
    800046b2:	9fa9                	addw	a5,a5,a0
    800046b4:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800046b6:	6c88                	ld	a0,24(s1)
    800046b8:	fffff097          	auipc	ra,0xfffff
    800046bc:	09c080e7          	jalr	156(ra) # 80003754 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800046c0:	854a                	mv	a0,s2
    800046c2:	70a2                	ld	ra,40(sp)
    800046c4:	7402                	ld	s0,32(sp)
    800046c6:	64e2                	ld	s1,24(sp)
    800046c8:	6942                	ld	s2,16(sp)
    800046ca:	69a2                	ld	s3,8(sp)
    800046cc:	6145                	addi	sp,sp,48
    800046ce:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800046d0:	6908                	ld	a0,16(a0)
    800046d2:	00000097          	auipc	ra,0x0
    800046d6:	3c6080e7          	jalr	966(ra) # 80004a98 <piperead>
    800046da:	892a                	mv	s2,a0
    800046dc:	b7d5                	j	800046c0 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800046de:	02451783          	lh	a5,36(a0)
    800046e2:	03079693          	slli	a3,a5,0x30
    800046e6:	92c1                	srli	a3,a3,0x30
    800046e8:	4725                	li	a4,9
    800046ea:	02d76863          	bltu	a4,a3,8000471a <fileread+0xba>
    800046ee:	0792                	slli	a5,a5,0x4
    800046f0:	0001c717          	auipc	a4,0x1c
    800046f4:	71870713          	addi	a4,a4,1816 # 80020e08 <devsw>
    800046f8:	97ba                	add	a5,a5,a4
    800046fa:	639c                	ld	a5,0(a5)
    800046fc:	c38d                	beqz	a5,8000471e <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    800046fe:	4505                	li	a0,1
    80004700:	9782                	jalr	a5
    80004702:	892a                	mv	s2,a0
    80004704:	bf75                	j	800046c0 <fileread+0x60>
    panic("fileread");
    80004706:	00004517          	auipc	a0,0x4
    8000470a:	fda50513          	addi	a0,a0,-38 # 800086e0 <syscalls+0x290>
    8000470e:	ffffc097          	auipc	ra,0xffffc
    80004712:	e32080e7          	jalr	-462(ra) # 80000540 <panic>
    return -1;
    80004716:	597d                	li	s2,-1
    80004718:	b765                	j	800046c0 <fileread+0x60>
      return -1;
    8000471a:	597d                	li	s2,-1
    8000471c:	b755                	j	800046c0 <fileread+0x60>
    8000471e:	597d                	li	s2,-1
    80004720:	b745                	j	800046c0 <fileread+0x60>

0000000080004722 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004722:	715d                	addi	sp,sp,-80
    80004724:	e486                	sd	ra,72(sp)
    80004726:	e0a2                	sd	s0,64(sp)
    80004728:	fc26                	sd	s1,56(sp)
    8000472a:	f84a                	sd	s2,48(sp)
    8000472c:	f44e                	sd	s3,40(sp)
    8000472e:	f052                	sd	s4,32(sp)
    80004730:	ec56                	sd	s5,24(sp)
    80004732:	e85a                	sd	s6,16(sp)
    80004734:	e45e                	sd	s7,8(sp)
    80004736:	e062                	sd	s8,0(sp)
    80004738:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    8000473a:	00954783          	lbu	a5,9(a0)
    8000473e:	10078663          	beqz	a5,8000484a <filewrite+0x128>
    80004742:	892a                	mv	s2,a0
    80004744:	8b2e                	mv	s6,a1
    80004746:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004748:	411c                	lw	a5,0(a0)
    8000474a:	4705                	li	a4,1
    8000474c:	02e78263          	beq	a5,a4,80004770 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004750:	470d                	li	a4,3
    80004752:	02e78663          	beq	a5,a4,8000477e <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004756:	4709                	li	a4,2
    80004758:	0ee79163          	bne	a5,a4,8000483a <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    8000475c:	0ac05d63          	blez	a2,80004816 <filewrite+0xf4>
    int i = 0;
    80004760:	4981                	li	s3,0
    80004762:	6b85                	lui	s7,0x1
    80004764:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004768:	6c05                	lui	s8,0x1
    8000476a:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    8000476e:	a861                	j	80004806 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004770:	6908                	ld	a0,16(a0)
    80004772:	00000097          	auipc	ra,0x0
    80004776:	22e080e7          	jalr	558(ra) # 800049a0 <pipewrite>
    8000477a:	8a2a                	mv	s4,a0
    8000477c:	a045                	j	8000481c <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000477e:	02451783          	lh	a5,36(a0)
    80004782:	03079693          	slli	a3,a5,0x30
    80004786:	92c1                	srli	a3,a3,0x30
    80004788:	4725                	li	a4,9
    8000478a:	0cd76263          	bltu	a4,a3,8000484e <filewrite+0x12c>
    8000478e:	0792                	slli	a5,a5,0x4
    80004790:	0001c717          	auipc	a4,0x1c
    80004794:	67870713          	addi	a4,a4,1656 # 80020e08 <devsw>
    80004798:	97ba                	add	a5,a5,a4
    8000479a:	679c                	ld	a5,8(a5)
    8000479c:	cbdd                	beqz	a5,80004852 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    8000479e:	4505                	li	a0,1
    800047a0:	9782                	jalr	a5
    800047a2:	8a2a                	mv	s4,a0
    800047a4:	a8a5                	j	8000481c <filewrite+0xfa>
    800047a6:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    800047aa:	00000097          	auipc	ra,0x0
    800047ae:	8b4080e7          	jalr	-1868(ra) # 8000405e <begin_op>
      ilock(f->ip);
    800047b2:	01893503          	ld	a0,24(s2)
    800047b6:	fffff097          	auipc	ra,0xfffff
    800047ba:	edc080e7          	jalr	-292(ra) # 80003692 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800047be:	8756                	mv	a4,s5
    800047c0:	02092683          	lw	a3,32(s2)
    800047c4:	01698633          	add	a2,s3,s6
    800047c8:	4585                	li	a1,1
    800047ca:	01893503          	ld	a0,24(s2)
    800047ce:	fffff097          	auipc	ra,0xfffff
    800047d2:	270080e7          	jalr	624(ra) # 80003a3e <writei>
    800047d6:	84aa                	mv	s1,a0
    800047d8:	00a05763          	blez	a0,800047e6 <filewrite+0xc4>
        f->off += r;
    800047dc:	02092783          	lw	a5,32(s2)
    800047e0:	9fa9                	addw	a5,a5,a0
    800047e2:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800047e6:	01893503          	ld	a0,24(s2)
    800047ea:	fffff097          	auipc	ra,0xfffff
    800047ee:	f6a080e7          	jalr	-150(ra) # 80003754 <iunlock>
      end_op();
    800047f2:	00000097          	auipc	ra,0x0
    800047f6:	8ea080e7          	jalr	-1814(ra) # 800040dc <end_op>

      if(r != n1){
    800047fa:	009a9f63          	bne	s5,s1,80004818 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    800047fe:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004802:	0149db63          	bge	s3,s4,80004818 <filewrite+0xf6>
      int n1 = n - i;
    80004806:	413a04bb          	subw	s1,s4,s3
    8000480a:	0004879b          	sext.w	a5,s1
    8000480e:	f8fbdce3          	bge	s7,a5,800047a6 <filewrite+0x84>
    80004812:	84e2                	mv	s1,s8
    80004814:	bf49                	j	800047a6 <filewrite+0x84>
    int i = 0;
    80004816:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004818:	013a1f63          	bne	s4,s3,80004836 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000481c:	8552                	mv	a0,s4
    8000481e:	60a6                	ld	ra,72(sp)
    80004820:	6406                	ld	s0,64(sp)
    80004822:	74e2                	ld	s1,56(sp)
    80004824:	7942                	ld	s2,48(sp)
    80004826:	79a2                	ld	s3,40(sp)
    80004828:	7a02                	ld	s4,32(sp)
    8000482a:	6ae2                	ld	s5,24(sp)
    8000482c:	6b42                	ld	s6,16(sp)
    8000482e:	6ba2                	ld	s7,8(sp)
    80004830:	6c02                	ld	s8,0(sp)
    80004832:	6161                	addi	sp,sp,80
    80004834:	8082                	ret
    ret = (i == n ? n : -1);
    80004836:	5a7d                	li	s4,-1
    80004838:	b7d5                	j	8000481c <filewrite+0xfa>
    panic("filewrite");
    8000483a:	00004517          	auipc	a0,0x4
    8000483e:	eb650513          	addi	a0,a0,-330 # 800086f0 <syscalls+0x2a0>
    80004842:	ffffc097          	auipc	ra,0xffffc
    80004846:	cfe080e7          	jalr	-770(ra) # 80000540 <panic>
    return -1;
    8000484a:	5a7d                	li	s4,-1
    8000484c:	bfc1                	j	8000481c <filewrite+0xfa>
      return -1;
    8000484e:	5a7d                	li	s4,-1
    80004850:	b7f1                	j	8000481c <filewrite+0xfa>
    80004852:	5a7d                	li	s4,-1
    80004854:	b7e1                	j	8000481c <filewrite+0xfa>

0000000080004856 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004856:	7179                	addi	sp,sp,-48
    80004858:	f406                	sd	ra,40(sp)
    8000485a:	f022                	sd	s0,32(sp)
    8000485c:	ec26                	sd	s1,24(sp)
    8000485e:	e84a                	sd	s2,16(sp)
    80004860:	e44e                	sd	s3,8(sp)
    80004862:	e052                	sd	s4,0(sp)
    80004864:	1800                	addi	s0,sp,48
    80004866:	84aa                	mv	s1,a0
    80004868:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    8000486a:	0005b023          	sd	zero,0(a1)
    8000486e:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004872:	00000097          	auipc	ra,0x0
    80004876:	bf8080e7          	jalr	-1032(ra) # 8000446a <filealloc>
    8000487a:	e088                	sd	a0,0(s1)
    8000487c:	c551                	beqz	a0,80004908 <pipealloc+0xb2>
    8000487e:	00000097          	auipc	ra,0x0
    80004882:	bec080e7          	jalr	-1044(ra) # 8000446a <filealloc>
    80004886:	00aa3023          	sd	a0,0(s4)
    8000488a:	c92d                	beqz	a0,800048fc <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    8000488c:	ffffc097          	auipc	ra,0xffffc
    80004890:	25a080e7          	jalr	602(ra) # 80000ae6 <kalloc>
    80004894:	892a                	mv	s2,a0
    80004896:	c125                	beqz	a0,800048f6 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004898:	4985                	li	s3,1
    8000489a:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000489e:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800048a2:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800048a6:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800048aa:	00004597          	auipc	a1,0x4
    800048ae:	e5658593          	addi	a1,a1,-426 # 80008700 <syscalls+0x2b0>
    800048b2:	ffffc097          	auipc	ra,0xffffc
    800048b6:	294080e7          	jalr	660(ra) # 80000b46 <initlock>
  (*f0)->type = FD_PIPE;
    800048ba:	609c                	ld	a5,0(s1)
    800048bc:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800048c0:	609c                	ld	a5,0(s1)
    800048c2:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800048c6:	609c                	ld	a5,0(s1)
    800048c8:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800048cc:	609c                	ld	a5,0(s1)
    800048ce:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800048d2:	000a3783          	ld	a5,0(s4)
    800048d6:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800048da:	000a3783          	ld	a5,0(s4)
    800048de:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800048e2:	000a3783          	ld	a5,0(s4)
    800048e6:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800048ea:	000a3783          	ld	a5,0(s4)
    800048ee:	0127b823          	sd	s2,16(a5)
  return 0;
    800048f2:	4501                	li	a0,0
    800048f4:	a025                	j	8000491c <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800048f6:	6088                	ld	a0,0(s1)
    800048f8:	e501                	bnez	a0,80004900 <pipealloc+0xaa>
    800048fa:	a039                	j	80004908 <pipealloc+0xb2>
    800048fc:	6088                	ld	a0,0(s1)
    800048fe:	c51d                	beqz	a0,8000492c <pipealloc+0xd6>
    fileclose(*f0);
    80004900:	00000097          	auipc	ra,0x0
    80004904:	c26080e7          	jalr	-986(ra) # 80004526 <fileclose>
  if(*f1)
    80004908:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    8000490c:	557d                	li	a0,-1
  if(*f1)
    8000490e:	c799                	beqz	a5,8000491c <pipealloc+0xc6>
    fileclose(*f1);
    80004910:	853e                	mv	a0,a5
    80004912:	00000097          	auipc	ra,0x0
    80004916:	c14080e7          	jalr	-1004(ra) # 80004526 <fileclose>
  return -1;
    8000491a:	557d                	li	a0,-1
}
    8000491c:	70a2                	ld	ra,40(sp)
    8000491e:	7402                	ld	s0,32(sp)
    80004920:	64e2                	ld	s1,24(sp)
    80004922:	6942                	ld	s2,16(sp)
    80004924:	69a2                	ld	s3,8(sp)
    80004926:	6a02                	ld	s4,0(sp)
    80004928:	6145                	addi	sp,sp,48
    8000492a:	8082                	ret
  return -1;
    8000492c:	557d                	li	a0,-1
    8000492e:	b7fd                	j	8000491c <pipealloc+0xc6>

0000000080004930 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004930:	1101                	addi	sp,sp,-32
    80004932:	ec06                	sd	ra,24(sp)
    80004934:	e822                	sd	s0,16(sp)
    80004936:	e426                	sd	s1,8(sp)
    80004938:	e04a                	sd	s2,0(sp)
    8000493a:	1000                	addi	s0,sp,32
    8000493c:	84aa                	mv	s1,a0
    8000493e:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004940:	ffffc097          	auipc	ra,0xffffc
    80004944:	296080e7          	jalr	662(ra) # 80000bd6 <acquire>
  if(writable){
    80004948:	02090d63          	beqz	s2,80004982 <pipeclose+0x52>
    pi->writeopen = 0;
    8000494c:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004950:	21848513          	addi	a0,s1,536
    80004954:	ffffd097          	auipc	ra,0xffffd
    80004958:	76e080e7          	jalr	1902(ra) # 800020c2 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    8000495c:	2204b783          	ld	a5,544(s1)
    80004960:	eb95                	bnez	a5,80004994 <pipeclose+0x64>
    release(&pi->lock);
    80004962:	8526                	mv	a0,s1
    80004964:	ffffc097          	auipc	ra,0xffffc
    80004968:	326080e7          	jalr	806(ra) # 80000c8a <release>
    kfree((char*)pi);
    8000496c:	8526                	mv	a0,s1
    8000496e:	ffffc097          	auipc	ra,0xffffc
    80004972:	07a080e7          	jalr	122(ra) # 800009e8 <kfree>
  } else
    release(&pi->lock);
}
    80004976:	60e2                	ld	ra,24(sp)
    80004978:	6442                	ld	s0,16(sp)
    8000497a:	64a2                	ld	s1,8(sp)
    8000497c:	6902                	ld	s2,0(sp)
    8000497e:	6105                	addi	sp,sp,32
    80004980:	8082                	ret
    pi->readopen = 0;
    80004982:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004986:	21c48513          	addi	a0,s1,540
    8000498a:	ffffd097          	auipc	ra,0xffffd
    8000498e:	738080e7          	jalr	1848(ra) # 800020c2 <wakeup>
    80004992:	b7e9                	j	8000495c <pipeclose+0x2c>
    release(&pi->lock);
    80004994:	8526                	mv	a0,s1
    80004996:	ffffc097          	auipc	ra,0xffffc
    8000499a:	2f4080e7          	jalr	756(ra) # 80000c8a <release>
}
    8000499e:	bfe1                	j	80004976 <pipeclose+0x46>

00000000800049a0 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800049a0:	711d                	addi	sp,sp,-96
    800049a2:	ec86                	sd	ra,88(sp)
    800049a4:	e8a2                	sd	s0,80(sp)
    800049a6:	e4a6                	sd	s1,72(sp)
    800049a8:	e0ca                	sd	s2,64(sp)
    800049aa:	fc4e                	sd	s3,56(sp)
    800049ac:	f852                	sd	s4,48(sp)
    800049ae:	f456                	sd	s5,40(sp)
    800049b0:	f05a                	sd	s6,32(sp)
    800049b2:	ec5e                	sd	s7,24(sp)
    800049b4:	e862                	sd	s8,16(sp)
    800049b6:	1080                	addi	s0,sp,96
    800049b8:	84aa                	mv	s1,a0
    800049ba:	8aae                	mv	s5,a1
    800049bc:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800049be:	ffffd097          	auipc	ra,0xffffd
    800049c2:	fee080e7          	jalr	-18(ra) # 800019ac <myproc>
    800049c6:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800049c8:	8526                	mv	a0,s1
    800049ca:	ffffc097          	auipc	ra,0xffffc
    800049ce:	20c080e7          	jalr	524(ra) # 80000bd6 <acquire>
  while(i < n){
    800049d2:	0b405663          	blez	s4,80004a7e <pipewrite+0xde>
  int i = 0;
    800049d6:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800049d8:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800049da:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800049de:	21c48b93          	addi	s7,s1,540
    800049e2:	a089                	j	80004a24 <pipewrite+0x84>
      release(&pi->lock);
    800049e4:	8526                	mv	a0,s1
    800049e6:	ffffc097          	auipc	ra,0xffffc
    800049ea:	2a4080e7          	jalr	676(ra) # 80000c8a <release>
      return -1;
    800049ee:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800049f0:	854a                	mv	a0,s2
    800049f2:	60e6                	ld	ra,88(sp)
    800049f4:	6446                	ld	s0,80(sp)
    800049f6:	64a6                	ld	s1,72(sp)
    800049f8:	6906                	ld	s2,64(sp)
    800049fa:	79e2                	ld	s3,56(sp)
    800049fc:	7a42                	ld	s4,48(sp)
    800049fe:	7aa2                	ld	s5,40(sp)
    80004a00:	7b02                	ld	s6,32(sp)
    80004a02:	6be2                	ld	s7,24(sp)
    80004a04:	6c42                	ld	s8,16(sp)
    80004a06:	6125                	addi	sp,sp,96
    80004a08:	8082                	ret
      wakeup(&pi->nread);
    80004a0a:	8562                	mv	a0,s8
    80004a0c:	ffffd097          	auipc	ra,0xffffd
    80004a10:	6b6080e7          	jalr	1718(ra) # 800020c2 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004a14:	85a6                	mv	a1,s1
    80004a16:	855e                	mv	a0,s7
    80004a18:	ffffd097          	auipc	ra,0xffffd
    80004a1c:	646080e7          	jalr	1606(ra) # 8000205e <sleep>
  while(i < n){
    80004a20:	07495063          	bge	s2,s4,80004a80 <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004a24:	2204a783          	lw	a5,544(s1)
    80004a28:	dfd5                	beqz	a5,800049e4 <pipewrite+0x44>
    80004a2a:	854e                	mv	a0,s3
    80004a2c:	ffffe097          	auipc	ra,0xffffe
    80004a30:	8da080e7          	jalr	-1830(ra) # 80002306 <killed>
    80004a34:	f945                	bnez	a0,800049e4 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004a36:	2184a783          	lw	a5,536(s1)
    80004a3a:	21c4a703          	lw	a4,540(s1)
    80004a3e:	2007879b          	addiw	a5,a5,512
    80004a42:	fcf704e3          	beq	a4,a5,80004a0a <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004a46:	4685                	li	a3,1
    80004a48:	01590633          	add	a2,s2,s5
    80004a4c:	faf40593          	addi	a1,s0,-81
    80004a50:	0509b503          	ld	a0,80(s3)
    80004a54:	ffffd097          	auipc	ra,0xffffd
    80004a58:	ca4080e7          	jalr	-860(ra) # 800016f8 <copyin>
    80004a5c:	03650263          	beq	a0,s6,80004a80 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004a60:	21c4a783          	lw	a5,540(s1)
    80004a64:	0017871b          	addiw	a4,a5,1
    80004a68:	20e4ae23          	sw	a4,540(s1)
    80004a6c:	1ff7f793          	andi	a5,a5,511
    80004a70:	97a6                	add	a5,a5,s1
    80004a72:	faf44703          	lbu	a4,-81(s0)
    80004a76:	00e78c23          	sb	a4,24(a5)
      i++;
    80004a7a:	2905                	addiw	s2,s2,1
    80004a7c:	b755                	j	80004a20 <pipewrite+0x80>
  int i = 0;
    80004a7e:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004a80:	21848513          	addi	a0,s1,536
    80004a84:	ffffd097          	auipc	ra,0xffffd
    80004a88:	63e080e7          	jalr	1598(ra) # 800020c2 <wakeup>
  release(&pi->lock);
    80004a8c:	8526                	mv	a0,s1
    80004a8e:	ffffc097          	auipc	ra,0xffffc
    80004a92:	1fc080e7          	jalr	508(ra) # 80000c8a <release>
  return i;
    80004a96:	bfa9                	j	800049f0 <pipewrite+0x50>

0000000080004a98 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004a98:	715d                	addi	sp,sp,-80
    80004a9a:	e486                	sd	ra,72(sp)
    80004a9c:	e0a2                	sd	s0,64(sp)
    80004a9e:	fc26                	sd	s1,56(sp)
    80004aa0:	f84a                	sd	s2,48(sp)
    80004aa2:	f44e                	sd	s3,40(sp)
    80004aa4:	f052                	sd	s4,32(sp)
    80004aa6:	ec56                	sd	s5,24(sp)
    80004aa8:	e85a                	sd	s6,16(sp)
    80004aaa:	0880                	addi	s0,sp,80
    80004aac:	84aa                	mv	s1,a0
    80004aae:	892e                	mv	s2,a1
    80004ab0:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004ab2:	ffffd097          	auipc	ra,0xffffd
    80004ab6:	efa080e7          	jalr	-262(ra) # 800019ac <myproc>
    80004aba:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004abc:	8526                	mv	a0,s1
    80004abe:	ffffc097          	auipc	ra,0xffffc
    80004ac2:	118080e7          	jalr	280(ra) # 80000bd6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004ac6:	2184a703          	lw	a4,536(s1)
    80004aca:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004ace:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004ad2:	02f71763          	bne	a4,a5,80004b00 <piperead+0x68>
    80004ad6:	2244a783          	lw	a5,548(s1)
    80004ada:	c39d                	beqz	a5,80004b00 <piperead+0x68>
    if(killed(pr)){
    80004adc:	8552                	mv	a0,s4
    80004ade:	ffffe097          	auipc	ra,0xffffe
    80004ae2:	828080e7          	jalr	-2008(ra) # 80002306 <killed>
    80004ae6:	e949                	bnez	a0,80004b78 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004ae8:	85a6                	mv	a1,s1
    80004aea:	854e                	mv	a0,s3
    80004aec:	ffffd097          	auipc	ra,0xffffd
    80004af0:	572080e7          	jalr	1394(ra) # 8000205e <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004af4:	2184a703          	lw	a4,536(s1)
    80004af8:	21c4a783          	lw	a5,540(s1)
    80004afc:	fcf70de3          	beq	a4,a5,80004ad6 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b00:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004b02:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b04:	05505463          	blez	s5,80004b4c <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80004b08:	2184a783          	lw	a5,536(s1)
    80004b0c:	21c4a703          	lw	a4,540(s1)
    80004b10:	02f70e63          	beq	a4,a5,80004b4c <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004b14:	0017871b          	addiw	a4,a5,1
    80004b18:	20e4ac23          	sw	a4,536(s1)
    80004b1c:	1ff7f793          	andi	a5,a5,511
    80004b20:	97a6                	add	a5,a5,s1
    80004b22:	0187c783          	lbu	a5,24(a5)
    80004b26:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004b2a:	4685                	li	a3,1
    80004b2c:	fbf40613          	addi	a2,s0,-65
    80004b30:	85ca                	mv	a1,s2
    80004b32:	050a3503          	ld	a0,80(s4)
    80004b36:	ffffd097          	auipc	ra,0xffffd
    80004b3a:	b36080e7          	jalr	-1226(ra) # 8000166c <copyout>
    80004b3e:	01650763          	beq	a0,s6,80004b4c <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b42:	2985                	addiw	s3,s3,1
    80004b44:	0905                	addi	s2,s2,1
    80004b46:	fd3a91e3          	bne	s5,s3,80004b08 <piperead+0x70>
    80004b4a:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004b4c:	21c48513          	addi	a0,s1,540
    80004b50:	ffffd097          	auipc	ra,0xffffd
    80004b54:	572080e7          	jalr	1394(ra) # 800020c2 <wakeup>
  release(&pi->lock);
    80004b58:	8526                	mv	a0,s1
    80004b5a:	ffffc097          	auipc	ra,0xffffc
    80004b5e:	130080e7          	jalr	304(ra) # 80000c8a <release>
  return i;
}
    80004b62:	854e                	mv	a0,s3
    80004b64:	60a6                	ld	ra,72(sp)
    80004b66:	6406                	ld	s0,64(sp)
    80004b68:	74e2                	ld	s1,56(sp)
    80004b6a:	7942                	ld	s2,48(sp)
    80004b6c:	79a2                	ld	s3,40(sp)
    80004b6e:	7a02                	ld	s4,32(sp)
    80004b70:	6ae2                	ld	s5,24(sp)
    80004b72:	6b42                	ld	s6,16(sp)
    80004b74:	6161                	addi	sp,sp,80
    80004b76:	8082                	ret
      release(&pi->lock);
    80004b78:	8526                	mv	a0,s1
    80004b7a:	ffffc097          	auipc	ra,0xffffc
    80004b7e:	110080e7          	jalr	272(ra) # 80000c8a <release>
      return -1;
    80004b82:	59fd                	li	s3,-1
    80004b84:	bff9                	j	80004b62 <piperead+0xca>

0000000080004b86 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004b86:	1141                	addi	sp,sp,-16
    80004b88:	e422                	sd	s0,8(sp)
    80004b8a:	0800                	addi	s0,sp,16
    80004b8c:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004b8e:	8905                	andi	a0,a0,1
    80004b90:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004b92:	8b89                	andi	a5,a5,2
    80004b94:	c399                	beqz	a5,80004b9a <flags2perm+0x14>
      perm |= PTE_W;
    80004b96:	00456513          	ori	a0,a0,4
    return perm;
}
    80004b9a:	6422                	ld	s0,8(sp)
    80004b9c:	0141                	addi	sp,sp,16
    80004b9e:	8082                	ret

0000000080004ba0 <exec>:

int
exec(char *path, char **argv)
{
    80004ba0:	de010113          	addi	sp,sp,-544
    80004ba4:	20113c23          	sd	ra,536(sp)
    80004ba8:	20813823          	sd	s0,528(sp)
    80004bac:	20913423          	sd	s1,520(sp)
    80004bb0:	21213023          	sd	s2,512(sp)
    80004bb4:	ffce                	sd	s3,504(sp)
    80004bb6:	fbd2                	sd	s4,496(sp)
    80004bb8:	f7d6                	sd	s5,488(sp)
    80004bba:	f3da                	sd	s6,480(sp)
    80004bbc:	efde                	sd	s7,472(sp)
    80004bbe:	ebe2                	sd	s8,464(sp)
    80004bc0:	e7e6                	sd	s9,456(sp)
    80004bc2:	e3ea                	sd	s10,448(sp)
    80004bc4:	ff6e                	sd	s11,440(sp)
    80004bc6:	1400                	addi	s0,sp,544
    80004bc8:	892a                	mv	s2,a0
    80004bca:	dea43423          	sd	a0,-536(s0)
    80004bce:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004bd2:	ffffd097          	auipc	ra,0xffffd
    80004bd6:	dda080e7          	jalr	-550(ra) # 800019ac <myproc>
    80004bda:	84aa                	mv	s1,a0

  begin_op();
    80004bdc:	fffff097          	auipc	ra,0xfffff
    80004be0:	482080e7          	jalr	1154(ra) # 8000405e <begin_op>

  if((ip = namei(path)) == 0){
    80004be4:	854a                	mv	a0,s2
    80004be6:	fffff097          	auipc	ra,0xfffff
    80004bea:	258080e7          	jalr	600(ra) # 80003e3e <namei>
    80004bee:	c93d                	beqz	a0,80004c64 <exec+0xc4>
    80004bf0:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004bf2:	fffff097          	auipc	ra,0xfffff
    80004bf6:	aa0080e7          	jalr	-1376(ra) # 80003692 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004bfa:	04000713          	li	a4,64
    80004bfe:	4681                	li	a3,0
    80004c00:	e5040613          	addi	a2,s0,-432
    80004c04:	4581                	li	a1,0
    80004c06:	8556                	mv	a0,s5
    80004c08:	fffff097          	auipc	ra,0xfffff
    80004c0c:	d3e080e7          	jalr	-706(ra) # 80003946 <readi>
    80004c10:	04000793          	li	a5,64
    80004c14:	00f51a63          	bne	a0,a5,80004c28 <exec+0x88>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004c18:	e5042703          	lw	a4,-432(s0)
    80004c1c:	464c47b7          	lui	a5,0x464c4
    80004c20:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004c24:	04f70663          	beq	a4,a5,80004c70 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004c28:	8556                	mv	a0,s5
    80004c2a:	fffff097          	auipc	ra,0xfffff
    80004c2e:	cca080e7          	jalr	-822(ra) # 800038f4 <iunlockput>
    end_op();
    80004c32:	fffff097          	auipc	ra,0xfffff
    80004c36:	4aa080e7          	jalr	1194(ra) # 800040dc <end_op>
  }
  return -1;
    80004c3a:	557d                	li	a0,-1
}
    80004c3c:	21813083          	ld	ra,536(sp)
    80004c40:	21013403          	ld	s0,528(sp)
    80004c44:	20813483          	ld	s1,520(sp)
    80004c48:	20013903          	ld	s2,512(sp)
    80004c4c:	79fe                	ld	s3,504(sp)
    80004c4e:	7a5e                	ld	s4,496(sp)
    80004c50:	7abe                	ld	s5,488(sp)
    80004c52:	7b1e                	ld	s6,480(sp)
    80004c54:	6bfe                	ld	s7,472(sp)
    80004c56:	6c5e                	ld	s8,464(sp)
    80004c58:	6cbe                	ld	s9,456(sp)
    80004c5a:	6d1e                	ld	s10,448(sp)
    80004c5c:	7dfa                	ld	s11,440(sp)
    80004c5e:	22010113          	addi	sp,sp,544
    80004c62:	8082                	ret
    end_op();
    80004c64:	fffff097          	auipc	ra,0xfffff
    80004c68:	478080e7          	jalr	1144(ra) # 800040dc <end_op>
    return -1;
    80004c6c:	557d                	li	a0,-1
    80004c6e:	b7f9                	j	80004c3c <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004c70:	8526                	mv	a0,s1
    80004c72:	ffffd097          	auipc	ra,0xffffd
    80004c76:	dfe080e7          	jalr	-514(ra) # 80001a70 <proc_pagetable>
    80004c7a:	8b2a                	mv	s6,a0
    80004c7c:	d555                	beqz	a0,80004c28 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004c7e:	e7042783          	lw	a5,-400(s0)
    80004c82:	e8845703          	lhu	a4,-376(s0)
    80004c86:	c735                	beqz	a4,80004cf2 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004c88:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004c8a:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80004c8e:	6a05                	lui	s4,0x1
    80004c90:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004c94:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80004c98:	6d85                	lui	s11,0x1
    80004c9a:	7d7d                	lui	s10,0xfffff
    80004c9c:	ac3d                	j	80004eda <exec+0x33a>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004c9e:	00004517          	auipc	a0,0x4
    80004ca2:	a6a50513          	addi	a0,a0,-1430 # 80008708 <syscalls+0x2b8>
    80004ca6:	ffffc097          	auipc	ra,0xffffc
    80004caa:	89a080e7          	jalr	-1894(ra) # 80000540 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004cae:	874a                	mv	a4,s2
    80004cb0:	009c86bb          	addw	a3,s9,s1
    80004cb4:	4581                	li	a1,0
    80004cb6:	8556                	mv	a0,s5
    80004cb8:	fffff097          	auipc	ra,0xfffff
    80004cbc:	c8e080e7          	jalr	-882(ra) # 80003946 <readi>
    80004cc0:	2501                	sext.w	a0,a0
    80004cc2:	1aa91963          	bne	s2,a0,80004e74 <exec+0x2d4>
  for(i = 0; i < sz; i += PGSIZE){
    80004cc6:	009d84bb          	addw	s1,s11,s1
    80004cca:	013d09bb          	addw	s3,s10,s3
    80004cce:	1f74f663          	bgeu	s1,s7,80004eba <exec+0x31a>
    pa = walkaddr(pagetable, va + i);
    80004cd2:	02049593          	slli	a1,s1,0x20
    80004cd6:	9181                	srli	a1,a1,0x20
    80004cd8:	95e2                	add	a1,a1,s8
    80004cda:	855a                	mv	a0,s6
    80004cdc:	ffffc097          	auipc	ra,0xffffc
    80004ce0:	380080e7          	jalr	896(ra) # 8000105c <walkaddr>
    80004ce4:	862a                	mv	a2,a0
    if(pa == 0)
    80004ce6:	dd45                	beqz	a0,80004c9e <exec+0xfe>
      n = PGSIZE;
    80004ce8:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004cea:	fd49f2e3          	bgeu	s3,s4,80004cae <exec+0x10e>
      n = sz - i;
    80004cee:	894e                	mv	s2,s3
    80004cf0:	bf7d                	j	80004cae <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004cf2:	4901                	li	s2,0
  iunlockput(ip);
    80004cf4:	8556                	mv	a0,s5
    80004cf6:	fffff097          	auipc	ra,0xfffff
    80004cfa:	bfe080e7          	jalr	-1026(ra) # 800038f4 <iunlockput>
  end_op();
    80004cfe:	fffff097          	auipc	ra,0xfffff
    80004d02:	3de080e7          	jalr	990(ra) # 800040dc <end_op>
  p = myproc();
    80004d06:	ffffd097          	auipc	ra,0xffffd
    80004d0a:	ca6080e7          	jalr	-858(ra) # 800019ac <myproc>
    80004d0e:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80004d10:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004d14:	6785                	lui	a5,0x1
    80004d16:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80004d18:	97ca                	add	a5,a5,s2
    80004d1a:	777d                	lui	a4,0xfffff
    80004d1c:	8ff9                	and	a5,a5,a4
    80004d1e:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004d22:	4691                	li	a3,4
    80004d24:	6609                	lui	a2,0x2
    80004d26:	963e                	add	a2,a2,a5
    80004d28:	85be                	mv	a1,a5
    80004d2a:	855a                	mv	a0,s6
    80004d2c:	ffffc097          	auipc	ra,0xffffc
    80004d30:	6e4080e7          	jalr	1764(ra) # 80001410 <uvmalloc>
    80004d34:	8c2a                	mv	s8,a0
  ip = 0;
    80004d36:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004d38:	12050e63          	beqz	a0,80004e74 <exec+0x2d4>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004d3c:	75f9                	lui	a1,0xffffe
    80004d3e:	95aa                	add	a1,a1,a0
    80004d40:	855a                	mv	a0,s6
    80004d42:	ffffd097          	auipc	ra,0xffffd
    80004d46:	8f8080e7          	jalr	-1800(ra) # 8000163a <uvmclear>
  stackbase = sp - PGSIZE;
    80004d4a:	7afd                	lui	s5,0xfffff
    80004d4c:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80004d4e:	df043783          	ld	a5,-528(s0)
    80004d52:	6388                	ld	a0,0(a5)
    80004d54:	c925                	beqz	a0,80004dc4 <exec+0x224>
    80004d56:	e9040993          	addi	s3,s0,-368
    80004d5a:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80004d5e:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004d60:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004d62:	ffffc097          	auipc	ra,0xffffc
    80004d66:	0ec080e7          	jalr	236(ra) # 80000e4e <strlen>
    80004d6a:	0015079b          	addiw	a5,a0,1
    80004d6e:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004d72:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004d76:	13596663          	bltu	s2,s5,80004ea2 <exec+0x302>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004d7a:	df043d83          	ld	s11,-528(s0)
    80004d7e:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80004d82:	8552                	mv	a0,s4
    80004d84:	ffffc097          	auipc	ra,0xffffc
    80004d88:	0ca080e7          	jalr	202(ra) # 80000e4e <strlen>
    80004d8c:	0015069b          	addiw	a3,a0,1
    80004d90:	8652                	mv	a2,s4
    80004d92:	85ca                	mv	a1,s2
    80004d94:	855a                	mv	a0,s6
    80004d96:	ffffd097          	auipc	ra,0xffffd
    80004d9a:	8d6080e7          	jalr	-1834(ra) # 8000166c <copyout>
    80004d9e:	10054663          	bltz	a0,80004eaa <exec+0x30a>
    ustack[argc] = sp;
    80004da2:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004da6:	0485                	addi	s1,s1,1
    80004da8:	008d8793          	addi	a5,s11,8
    80004dac:	def43823          	sd	a5,-528(s0)
    80004db0:	008db503          	ld	a0,8(s11)
    80004db4:	c911                	beqz	a0,80004dc8 <exec+0x228>
    if(argc >= MAXARG)
    80004db6:	09a1                	addi	s3,s3,8
    80004db8:	fb3c95e3          	bne	s9,s3,80004d62 <exec+0x1c2>
  sz = sz1;
    80004dbc:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004dc0:	4a81                	li	s5,0
    80004dc2:	a84d                	j	80004e74 <exec+0x2d4>
  sp = sz;
    80004dc4:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004dc6:	4481                	li	s1,0
  ustack[argc] = 0;
    80004dc8:	00349793          	slli	a5,s1,0x3
    80004dcc:	f9078793          	addi	a5,a5,-112
    80004dd0:	97a2                	add	a5,a5,s0
    80004dd2:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004dd6:	00148693          	addi	a3,s1,1
    80004dda:	068e                	slli	a3,a3,0x3
    80004ddc:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004de0:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80004de4:	01597663          	bgeu	s2,s5,80004df0 <exec+0x250>
  sz = sz1;
    80004de8:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004dec:	4a81                	li	s5,0
    80004dee:	a059                	j	80004e74 <exec+0x2d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004df0:	e9040613          	addi	a2,s0,-368
    80004df4:	85ca                	mv	a1,s2
    80004df6:	855a                	mv	a0,s6
    80004df8:	ffffd097          	auipc	ra,0xffffd
    80004dfc:	874080e7          	jalr	-1932(ra) # 8000166c <copyout>
    80004e00:	0a054963          	bltz	a0,80004eb2 <exec+0x312>
  p->trapframe->a1 = sp;
    80004e04:	058bb783          	ld	a5,88(s7)
    80004e08:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004e0c:	de843783          	ld	a5,-536(s0)
    80004e10:	0007c703          	lbu	a4,0(a5)
    80004e14:	cf11                	beqz	a4,80004e30 <exec+0x290>
    80004e16:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004e18:	02f00693          	li	a3,47
    80004e1c:	a039                	j	80004e2a <exec+0x28a>
      last = s+1;
    80004e1e:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80004e22:	0785                	addi	a5,a5,1
    80004e24:	fff7c703          	lbu	a4,-1(a5)
    80004e28:	c701                	beqz	a4,80004e30 <exec+0x290>
    if(*s == '/')
    80004e2a:	fed71ce3          	bne	a4,a3,80004e22 <exec+0x282>
    80004e2e:	bfc5                	j	80004e1e <exec+0x27e>
  safestrcpy(p->name, last, sizeof(p->name));
    80004e30:	4641                	li	a2,16
    80004e32:	de843583          	ld	a1,-536(s0)
    80004e36:	158b8513          	addi	a0,s7,344
    80004e3a:	ffffc097          	auipc	ra,0xffffc
    80004e3e:	fe2080e7          	jalr	-30(ra) # 80000e1c <safestrcpy>
  oldpagetable = p->pagetable;
    80004e42:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80004e46:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80004e4a:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004e4e:	058bb783          	ld	a5,88(s7)
    80004e52:	e6843703          	ld	a4,-408(s0)
    80004e56:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004e58:	058bb783          	ld	a5,88(s7)
    80004e5c:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004e60:	85ea                	mv	a1,s10
    80004e62:	ffffd097          	auipc	ra,0xffffd
    80004e66:	caa080e7          	jalr	-854(ra) # 80001b0c <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004e6a:	0004851b          	sext.w	a0,s1
    80004e6e:	b3f9                	j	80004c3c <exec+0x9c>
    80004e70:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004e74:	df843583          	ld	a1,-520(s0)
    80004e78:	855a                	mv	a0,s6
    80004e7a:	ffffd097          	auipc	ra,0xffffd
    80004e7e:	c92080e7          	jalr	-878(ra) # 80001b0c <proc_freepagetable>
  if(ip){
    80004e82:	da0a93e3          	bnez	s5,80004c28 <exec+0x88>
  return -1;
    80004e86:	557d                	li	a0,-1
    80004e88:	bb55                	j	80004c3c <exec+0x9c>
    80004e8a:	df243c23          	sd	s2,-520(s0)
    80004e8e:	b7dd                	j	80004e74 <exec+0x2d4>
    80004e90:	df243c23          	sd	s2,-520(s0)
    80004e94:	b7c5                	j	80004e74 <exec+0x2d4>
    80004e96:	df243c23          	sd	s2,-520(s0)
    80004e9a:	bfe9                	j	80004e74 <exec+0x2d4>
    80004e9c:	df243c23          	sd	s2,-520(s0)
    80004ea0:	bfd1                	j	80004e74 <exec+0x2d4>
  sz = sz1;
    80004ea2:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004ea6:	4a81                	li	s5,0
    80004ea8:	b7f1                	j	80004e74 <exec+0x2d4>
  sz = sz1;
    80004eaa:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004eae:	4a81                	li	s5,0
    80004eb0:	b7d1                	j	80004e74 <exec+0x2d4>
  sz = sz1;
    80004eb2:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004eb6:	4a81                	li	s5,0
    80004eb8:	bf75                	j	80004e74 <exec+0x2d4>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004eba:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004ebe:	e0843783          	ld	a5,-504(s0)
    80004ec2:	0017869b          	addiw	a3,a5,1
    80004ec6:	e0d43423          	sd	a3,-504(s0)
    80004eca:	e0043783          	ld	a5,-512(s0)
    80004ece:	0387879b          	addiw	a5,a5,56
    80004ed2:	e8845703          	lhu	a4,-376(s0)
    80004ed6:	e0e6dfe3          	bge	a3,a4,80004cf4 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004eda:	2781                	sext.w	a5,a5
    80004edc:	e0f43023          	sd	a5,-512(s0)
    80004ee0:	03800713          	li	a4,56
    80004ee4:	86be                	mv	a3,a5
    80004ee6:	e1840613          	addi	a2,s0,-488
    80004eea:	4581                	li	a1,0
    80004eec:	8556                	mv	a0,s5
    80004eee:	fffff097          	auipc	ra,0xfffff
    80004ef2:	a58080e7          	jalr	-1448(ra) # 80003946 <readi>
    80004ef6:	03800793          	li	a5,56
    80004efa:	f6f51be3          	bne	a0,a5,80004e70 <exec+0x2d0>
    if(ph.type != ELF_PROG_LOAD)
    80004efe:	e1842783          	lw	a5,-488(s0)
    80004f02:	4705                	li	a4,1
    80004f04:	fae79de3          	bne	a5,a4,80004ebe <exec+0x31e>
    if(ph.memsz < ph.filesz)
    80004f08:	e4043483          	ld	s1,-448(s0)
    80004f0c:	e3843783          	ld	a5,-456(s0)
    80004f10:	f6f4ede3          	bltu	s1,a5,80004e8a <exec+0x2ea>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004f14:	e2843783          	ld	a5,-472(s0)
    80004f18:	94be                	add	s1,s1,a5
    80004f1a:	f6f4ebe3          	bltu	s1,a5,80004e90 <exec+0x2f0>
    if(ph.vaddr % PGSIZE != 0)
    80004f1e:	de043703          	ld	a4,-544(s0)
    80004f22:	8ff9                	and	a5,a5,a4
    80004f24:	fbad                	bnez	a5,80004e96 <exec+0x2f6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004f26:	e1c42503          	lw	a0,-484(s0)
    80004f2a:	00000097          	auipc	ra,0x0
    80004f2e:	c5c080e7          	jalr	-932(ra) # 80004b86 <flags2perm>
    80004f32:	86aa                	mv	a3,a0
    80004f34:	8626                	mv	a2,s1
    80004f36:	85ca                	mv	a1,s2
    80004f38:	855a                	mv	a0,s6
    80004f3a:	ffffc097          	auipc	ra,0xffffc
    80004f3e:	4d6080e7          	jalr	1238(ra) # 80001410 <uvmalloc>
    80004f42:	dea43c23          	sd	a0,-520(s0)
    80004f46:	d939                	beqz	a0,80004e9c <exec+0x2fc>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004f48:	e2843c03          	ld	s8,-472(s0)
    80004f4c:	e2042c83          	lw	s9,-480(s0)
    80004f50:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004f54:	f60b83e3          	beqz	s7,80004eba <exec+0x31a>
    80004f58:	89de                	mv	s3,s7
    80004f5a:	4481                	li	s1,0
    80004f5c:	bb9d                	j	80004cd2 <exec+0x132>

0000000080004f5e <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004f5e:	7179                	addi	sp,sp,-48
    80004f60:	f406                	sd	ra,40(sp)
    80004f62:	f022                	sd	s0,32(sp)
    80004f64:	ec26                	sd	s1,24(sp)
    80004f66:	e84a                	sd	s2,16(sp)
    80004f68:	1800                	addi	s0,sp,48
    80004f6a:	892e                	mv	s2,a1
    80004f6c:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004f6e:	fdc40593          	addi	a1,s0,-36
    80004f72:	ffffe097          	auipc	ra,0xffffe
    80004f76:	b5c080e7          	jalr	-1188(ra) # 80002ace <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004f7a:	fdc42703          	lw	a4,-36(s0)
    80004f7e:	47bd                	li	a5,15
    80004f80:	02e7eb63          	bltu	a5,a4,80004fb6 <argfd+0x58>
    80004f84:	ffffd097          	auipc	ra,0xffffd
    80004f88:	a28080e7          	jalr	-1496(ra) # 800019ac <myproc>
    80004f8c:	fdc42703          	lw	a4,-36(s0)
    80004f90:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7ffdd07a>
    80004f94:	078e                	slli	a5,a5,0x3
    80004f96:	953e                	add	a0,a0,a5
    80004f98:	611c                	ld	a5,0(a0)
    80004f9a:	c385                	beqz	a5,80004fba <argfd+0x5c>
    return -1;
  if(pfd)
    80004f9c:	00090463          	beqz	s2,80004fa4 <argfd+0x46>
    *pfd = fd;
    80004fa0:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004fa4:	4501                	li	a0,0
  if(pf)
    80004fa6:	c091                	beqz	s1,80004faa <argfd+0x4c>
    *pf = f;
    80004fa8:	e09c                	sd	a5,0(s1)
}
    80004faa:	70a2                	ld	ra,40(sp)
    80004fac:	7402                	ld	s0,32(sp)
    80004fae:	64e2                	ld	s1,24(sp)
    80004fb0:	6942                	ld	s2,16(sp)
    80004fb2:	6145                	addi	sp,sp,48
    80004fb4:	8082                	ret
    return -1;
    80004fb6:	557d                	li	a0,-1
    80004fb8:	bfcd                	j	80004faa <argfd+0x4c>
    80004fba:	557d                	li	a0,-1
    80004fbc:	b7fd                	j	80004faa <argfd+0x4c>

0000000080004fbe <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004fbe:	1101                	addi	sp,sp,-32
    80004fc0:	ec06                	sd	ra,24(sp)
    80004fc2:	e822                	sd	s0,16(sp)
    80004fc4:	e426                	sd	s1,8(sp)
    80004fc6:	1000                	addi	s0,sp,32
    80004fc8:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004fca:	ffffd097          	auipc	ra,0xffffd
    80004fce:	9e2080e7          	jalr	-1566(ra) # 800019ac <myproc>
    80004fd2:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004fd4:	0d050793          	addi	a5,a0,208
    80004fd8:	4501                	li	a0,0
    80004fda:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004fdc:	6398                	ld	a4,0(a5)
    80004fde:	cb19                	beqz	a4,80004ff4 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80004fe0:	2505                	addiw	a0,a0,1
    80004fe2:	07a1                	addi	a5,a5,8
    80004fe4:	fed51ce3          	bne	a0,a3,80004fdc <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004fe8:	557d                	li	a0,-1
}
    80004fea:	60e2                	ld	ra,24(sp)
    80004fec:	6442                	ld	s0,16(sp)
    80004fee:	64a2                	ld	s1,8(sp)
    80004ff0:	6105                	addi	sp,sp,32
    80004ff2:	8082                	ret
      p->ofile[fd] = f;
    80004ff4:	01a50793          	addi	a5,a0,26
    80004ff8:	078e                	slli	a5,a5,0x3
    80004ffa:	963e                	add	a2,a2,a5
    80004ffc:	e204                	sd	s1,0(a2)
      return fd;
    80004ffe:	b7f5                	j	80004fea <fdalloc+0x2c>

0000000080005000 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005000:	715d                	addi	sp,sp,-80
    80005002:	e486                	sd	ra,72(sp)
    80005004:	e0a2                	sd	s0,64(sp)
    80005006:	fc26                	sd	s1,56(sp)
    80005008:	f84a                	sd	s2,48(sp)
    8000500a:	f44e                	sd	s3,40(sp)
    8000500c:	f052                	sd	s4,32(sp)
    8000500e:	ec56                	sd	s5,24(sp)
    80005010:	e85a                	sd	s6,16(sp)
    80005012:	0880                	addi	s0,sp,80
    80005014:	8b2e                	mv	s6,a1
    80005016:	89b2                	mv	s3,a2
    80005018:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000501a:	fb040593          	addi	a1,s0,-80
    8000501e:	fffff097          	auipc	ra,0xfffff
    80005022:	e3e080e7          	jalr	-450(ra) # 80003e5c <nameiparent>
    80005026:	84aa                	mv	s1,a0
    80005028:	14050f63          	beqz	a0,80005186 <create+0x186>
    return 0;

  ilock(dp);
    8000502c:	ffffe097          	auipc	ra,0xffffe
    80005030:	666080e7          	jalr	1638(ra) # 80003692 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005034:	4601                	li	a2,0
    80005036:	fb040593          	addi	a1,s0,-80
    8000503a:	8526                	mv	a0,s1
    8000503c:	fffff097          	auipc	ra,0xfffff
    80005040:	b3a080e7          	jalr	-1222(ra) # 80003b76 <dirlookup>
    80005044:	8aaa                	mv	s5,a0
    80005046:	c931                	beqz	a0,8000509a <create+0x9a>
    iunlockput(dp);
    80005048:	8526                	mv	a0,s1
    8000504a:	fffff097          	auipc	ra,0xfffff
    8000504e:	8aa080e7          	jalr	-1878(ra) # 800038f4 <iunlockput>
    ilock(ip);
    80005052:	8556                	mv	a0,s5
    80005054:	ffffe097          	auipc	ra,0xffffe
    80005058:	63e080e7          	jalr	1598(ra) # 80003692 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000505c:	000b059b          	sext.w	a1,s6
    80005060:	4789                	li	a5,2
    80005062:	02f59563          	bne	a1,a5,8000508c <create+0x8c>
    80005066:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffdd0a4>
    8000506a:	37f9                	addiw	a5,a5,-2
    8000506c:	17c2                	slli	a5,a5,0x30
    8000506e:	93c1                	srli	a5,a5,0x30
    80005070:	4705                	li	a4,1
    80005072:	00f76d63          	bltu	a4,a5,8000508c <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005076:	8556                	mv	a0,s5
    80005078:	60a6                	ld	ra,72(sp)
    8000507a:	6406                	ld	s0,64(sp)
    8000507c:	74e2                	ld	s1,56(sp)
    8000507e:	7942                	ld	s2,48(sp)
    80005080:	79a2                	ld	s3,40(sp)
    80005082:	7a02                	ld	s4,32(sp)
    80005084:	6ae2                	ld	s5,24(sp)
    80005086:	6b42                	ld	s6,16(sp)
    80005088:	6161                	addi	sp,sp,80
    8000508a:	8082                	ret
    iunlockput(ip);
    8000508c:	8556                	mv	a0,s5
    8000508e:	fffff097          	auipc	ra,0xfffff
    80005092:	866080e7          	jalr	-1946(ra) # 800038f4 <iunlockput>
    return 0;
    80005096:	4a81                	li	s5,0
    80005098:	bff9                	j	80005076 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    8000509a:	85da                	mv	a1,s6
    8000509c:	4088                	lw	a0,0(s1)
    8000509e:	ffffe097          	auipc	ra,0xffffe
    800050a2:	456080e7          	jalr	1110(ra) # 800034f4 <ialloc>
    800050a6:	8a2a                	mv	s4,a0
    800050a8:	c539                	beqz	a0,800050f6 <create+0xf6>
  ilock(ip);
    800050aa:	ffffe097          	auipc	ra,0xffffe
    800050ae:	5e8080e7          	jalr	1512(ra) # 80003692 <ilock>
  ip->major = major;
    800050b2:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    800050b6:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    800050ba:	4905                	li	s2,1
    800050bc:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    800050c0:	8552                	mv	a0,s4
    800050c2:	ffffe097          	auipc	ra,0xffffe
    800050c6:	504080e7          	jalr	1284(ra) # 800035c6 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800050ca:	000b059b          	sext.w	a1,s6
    800050ce:	03258b63          	beq	a1,s2,80005104 <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    800050d2:	004a2603          	lw	a2,4(s4)
    800050d6:	fb040593          	addi	a1,s0,-80
    800050da:	8526                	mv	a0,s1
    800050dc:	fffff097          	auipc	ra,0xfffff
    800050e0:	cb0080e7          	jalr	-848(ra) # 80003d8c <dirlink>
    800050e4:	06054f63          	bltz	a0,80005162 <create+0x162>
  iunlockput(dp);
    800050e8:	8526                	mv	a0,s1
    800050ea:	fffff097          	auipc	ra,0xfffff
    800050ee:	80a080e7          	jalr	-2038(ra) # 800038f4 <iunlockput>
  return ip;
    800050f2:	8ad2                	mv	s5,s4
    800050f4:	b749                	j	80005076 <create+0x76>
    iunlockput(dp);
    800050f6:	8526                	mv	a0,s1
    800050f8:	ffffe097          	auipc	ra,0xffffe
    800050fc:	7fc080e7          	jalr	2044(ra) # 800038f4 <iunlockput>
    return 0;
    80005100:	8ad2                	mv	s5,s4
    80005102:	bf95                	j	80005076 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005104:	004a2603          	lw	a2,4(s4)
    80005108:	00003597          	auipc	a1,0x3
    8000510c:	62058593          	addi	a1,a1,1568 # 80008728 <syscalls+0x2d8>
    80005110:	8552                	mv	a0,s4
    80005112:	fffff097          	auipc	ra,0xfffff
    80005116:	c7a080e7          	jalr	-902(ra) # 80003d8c <dirlink>
    8000511a:	04054463          	bltz	a0,80005162 <create+0x162>
    8000511e:	40d0                	lw	a2,4(s1)
    80005120:	00003597          	auipc	a1,0x3
    80005124:	61058593          	addi	a1,a1,1552 # 80008730 <syscalls+0x2e0>
    80005128:	8552                	mv	a0,s4
    8000512a:	fffff097          	auipc	ra,0xfffff
    8000512e:	c62080e7          	jalr	-926(ra) # 80003d8c <dirlink>
    80005132:	02054863          	bltz	a0,80005162 <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    80005136:	004a2603          	lw	a2,4(s4)
    8000513a:	fb040593          	addi	a1,s0,-80
    8000513e:	8526                	mv	a0,s1
    80005140:	fffff097          	auipc	ra,0xfffff
    80005144:	c4c080e7          	jalr	-948(ra) # 80003d8c <dirlink>
    80005148:	00054d63          	bltz	a0,80005162 <create+0x162>
    dp->nlink++;  // for ".."
    8000514c:	04a4d783          	lhu	a5,74(s1)
    80005150:	2785                	addiw	a5,a5,1
    80005152:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005156:	8526                	mv	a0,s1
    80005158:	ffffe097          	auipc	ra,0xffffe
    8000515c:	46e080e7          	jalr	1134(ra) # 800035c6 <iupdate>
    80005160:	b761                	j	800050e8 <create+0xe8>
  ip->nlink = 0;
    80005162:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005166:	8552                	mv	a0,s4
    80005168:	ffffe097          	auipc	ra,0xffffe
    8000516c:	45e080e7          	jalr	1118(ra) # 800035c6 <iupdate>
  iunlockput(ip);
    80005170:	8552                	mv	a0,s4
    80005172:	ffffe097          	auipc	ra,0xffffe
    80005176:	782080e7          	jalr	1922(ra) # 800038f4 <iunlockput>
  iunlockput(dp);
    8000517a:	8526                	mv	a0,s1
    8000517c:	ffffe097          	auipc	ra,0xffffe
    80005180:	778080e7          	jalr	1912(ra) # 800038f4 <iunlockput>
  return 0;
    80005184:	bdcd                	j	80005076 <create+0x76>
    return 0;
    80005186:	8aaa                	mv	s5,a0
    80005188:	b5fd                	j	80005076 <create+0x76>

000000008000518a <sys_dup>:
{
    8000518a:	7179                	addi	sp,sp,-48
    8000518c:	f406                	sd	ra,40(sp)
    8000518e:	f022                	sd	s0,32(sp)
    80005190:	ec26                	sd	s1,24(sp)
    80005192:	e84a                	sd	s2,16(sp)
    80005194:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005196:	fd840613          	addi	a2,s0,-40
    8000519a:	4581                	li	a1,0
    8000519c:	4501                	li	a0,0
    8000519e:	00000097          	auipc	ra,0x0
    800051a2:	dc0080e7          	jalr	-576(ra) # 80004f5e <argfd>
    return -1;
    800051a6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800051a8:	02054363          	bltz	a0,800051ce <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    800051ac:	fd843903          	ld	s2,-40(s0)
    800051b0:	854a                	mv	a0,s2
    800051b2:	00000097          	auipc	ra,0x0
    800051b6:	e0c080e7          	jalr	-500(ra) # 80004fbe <fdalloc>
    800051ba:	84aa                	mv	s1,a0
    return -1;
    800051bc:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800051be:	00054863          	bltz	a0,800051ce <sys_dup+0x44>
  filedup(f);
    800051c2:	854a                	mv	a0,s2
    800051c4:	fffff097          	auipc	ra,0xfffff
    800051c8:	310080e7          	jalr	784(ra) # 800044d4 <filedup>
  return fd;
    800051cc:	87a6                	mv	a5,s1
}
    800051ce:	853e                	mv	a0,a5
    800051d0:	70a2                	ld	ra,40(sp)
    800051d2:	7402                	ld	s0,32(sp)
    800051d4:	64e2                	ld	s1,24(sp)
    800051d6:	6942                	ld	s2,16(sp)
    800051d8:	6145                	addi	sp,sp,48
    800051da:	8082                	ret

00000000800051dc <sys_read>:
{
    800051dc:	7179                	addi	sp,sp,-48
    800051de:	f406                	sd	ra,40(sp)
    800051e0:	f022                	sd	s0,32(sp)
    800051e2:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800051e4:	fd840593          	addi	a1,s0,-40
    800051e8:	4505                	li	a0,1
    800051ea:	ffffe097          	auipc	ra,0xffffe
    800051ee:	904080e7          	jalr	-1788(ra) # 80002aee <argaddr>
  argint(2, &n);
    800051f2:	fe440593          	addi	a1,s0,-28
    800051f6:	4509                	li	a0,2
    800051f8:	ffffe097          	auipc	ra,0xffffe
    800051fc:	8d6080e7          	jalr	-1834(ra) # 80002ace <argint>
  if(argfd(0, 0, &f) < 0)
    80005200:	fe840613          	addi	a2,s0,-24
    80005204:	4581                	li	a1,0
    80005206:	4501                	li	a0,0
    80005208:	00000097          	auipc	ra,0x0
    8000520c:	d56080e7          	jalr	-682(ra) # 80004f5e <argfd>
    80005210:	87aa                	mv	a5,a0
    return -1;
    80005212:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005214:	0007cc63          	bltz	a5,8000522c <sys_read+0x50>
  return fileread(f, p, n);
    80005218:	fe442603          	lw	a2,-28(s0)
    8000521c:	fd843583          	ld	a1,-40(s0)
    80005220:	fe843503          	ld	a0,-24(s0)
    80005224:	fffff097          	auipc	ra,0xfffff
    80005228:	43c080e7          	jalr	1084(ra) # 80004660 <fileread>
}
    8000522c:	70a2                	ld	ra,40(sp)
    8000522e:	7402                	ld	s0,32(sp)
    80005230:	6145                	addi	sp,sp,48
    80005232:	8082                	ret

0000000080005234 <sys_write>:
{
    80005234:	7179                	addi	sp,sp,-48
    80005236:	f406                	sd	ra,40(sp)
    80005238:	f022                	sd	s0,32(sp)
    8000523a:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000523c:	fd840593          	addi	a1,s0,-40
    80005240:	4505                	li	a0,1
    80005242:	ffffe097          	auipc	ra,0xffffe
    80005246:	8ac080e7          	jalr	-1876(ra) # 80002aee <argaddr>
  argint(2, &n);
    8000524a:	fe440593          	addi	a1,s0,-28
    8000524e:	4509                	li	a0,2
    80005250:	ffffe097          	auipc	ra,0xffffe
    80005254:	87e080e7          	jalr	-1922(ra) # 80002ace <argint>
  if(argfd(0, 0, &f) < 0)
    80005258:	fe840613          	addi	a2,s0,-24
    8000525c:	4581                	li	a1,0
    8000525e:	4501                	li	a0,0
    80005260:	00000097          	auipc	ra,0x0
    80005264:	cfe080e7          	jalr	-770(ra) # 80004f5e <argfd>
    80005268:	87aa                	mv	a5,a0
    return -1;
    8000526a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000526c:	0007cc63          	bltz	a5,80005284 <sys_write+0x50>
  return filewrite(f, p, n);
    80005270:	fe442603          	lw	a2,-28(s0)
    80005274:	fd843583          	ld	a1,-40(s0)
    80005278:	fe843503          	ld	a0,-24(s0)
    8000527c:	fffff097          	auipc	ra,0xfffff
    80005280:	4a6080e7          	jalr	1190(ra) # 80004722 <filewrite>
}
    80005284:	70a2                	ld	ra,40(sp)
    80005286:	7402                	ld	s0,32(sp)
    80005288:	6145                	addi	sp,sp,48
    8000528a:	8082                	ret

000000008000528c <sys_close>:
{
    8000528c:	1101                	addi	sp,sp,-32
    8000528e:	ec06                	sd	ra,24(sp)
    80005290:	e822                	sd	s0,16(sp)
    80005292:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005294:	fe040613          	addi	a2,s0,-32
    80005298:	fec40593          	addi	a1,s0,-20
    8000529c:	4501                	li	a0,0
    8000529e:	00000097          	auipc	ra,0x0
    800052a2:	cc0080e7          	jalr	-832(ra) # 80004f5e <argfd>
    return -1;
    800052a6:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800052a8:	02054463          	bltz	a0,800052d0 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800052ac:	ffffc097          	auipc	ra,0xffffc
    800052b0:	700080e7          	jalr	1792(ra) # 800019ac <myproc>
    800052b4:	fec42783          	lw	a5,-20(s0)
    800052b8:	07e9                	addi	a5,a5,26
    800052ba:	078e                	slli	a5,a5,0x3
    800052bc:	953e                	add	a0,a0,a5
    800052be:	00053023          	sd	zero,0(a0)
  fileclose(f);
    800052c2:	fe043503          	ld	a0,-32(s0)
    800052c6:	fffff097          	auipc	ra,0xfffff
    800052ca:	260080e7          	jalr	608(ra) # 80004526 <fileclose>
  return 0;
    800052ce:	4781                	li	a5,0
}
    800052d0:	853e                	mv	a0,a5
    800052d2:	60e2                	ld	ra,24(sp)
    800052d4:	6442                	ld	s0,16(sp)
    800052d6:	6105                	addi	sp,sp,32
    800052d8:	8082                	ret

00000000800052da <sys_fstat>:
{
    800052da:	1101                	addi	sp,sp,-32
    800052dc:	ec06                	sd	ra,24(sp)
    800052de:	e822                	sd	s0,16(sp)
    800052e0:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    800052e2:	fe040593          	addi	a1,s0,-32
    800052e6:	4505                	li	a0,1
    800052e8:	ffffe097          	auipc	ra,0xffffe
    800052ec:	806080e7          	jalr	-2042(ra) # 80002aee <argaddr>
  if(argfd(0, 0, &f) < 0)
    800052f0:	fe840613          	addi	a2,s0,-24
    800052f4:	4581                	li	a1,0
    800052f6:	4501                	li	a0,0
    800052f8:	00000097          	auipc	ra,0x0
    800052fc:	c66080e7          	jalr	-922(ra) # 80004f5e <argfd>
    80005300:	87aa                	mv	a5,a0
    return -1;
    80005302:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005304:	0007ca63          	bltz	a5,80005318 <sys_fstat+0x3e>
  return filestat(f, st);
    80005308:	fe043583          	ld	a1,-32(s0)
    8000530c:	fe843503          	ld	a0,-24(s0)
    80005310:	fffff097          	auipc	ra,0xfffff
    80005314:	2de080e7          	jalr	734(ra) # 800045ee <filestat>
}
    80005318:	60e2                	ld	ra,24(sp)
    8000531a:	6442                	ld	s0,16(sp)
    8000531c:	6105                	addi	sp,sp,32
    8000531e:	8082                	ret

0000000080005320 <sys_link>:
{
    80005320:	7169                	addi	sp,sp,-304
    80005322:	f606                	sd	ra,296(sp)
    80005324:	f222                	sd	s0,288(sp)
    80005326:	ee26                	sd	s1,280(sp)
    80005328:	ea4a                	sd	s2,272(sp)
    8000532a:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000532c:	08000613          	li	a2,128
    80005330:	ed040593          	addi	a1,s0,-304
    80005334:	4501                	li	a0,0
    80005336:	ffffd097          	auipc	ra,0xffffd
    8000533a:	7d8080e7          	jalr	2008(ra) # 80002b0e <argstr>
    return -1;
    8000533e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005340:	10054e63          	bltz	a0,8000545c <sys_link+0x13c>
    80005344:	08000613          	li	a2,128
    80005348:	f5040593          	addi	a1,s0,-176
    8000534c:	4505                	li	a0,1
    8000534e:	ffffd097          	auipc	ra,0xffffd
    80005352:	7c0080e7          	jalr	1984(ra) # 80002b0e <argstr>
    return -1;
    80005356:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005358:	10054263          	bltz	a0,8000545c <sys_link+0x13c>
  begin_op();
    8000535c:	fffff097          	auipc	ra,0xfffff
    80005360:	d02080e7          	jalr	-766(ra) # 8000405e <begin_op>
  if((ip = namei(old)) == 0){
    80005364:	ed040513          	addi	a0,s0,-304
    80005368:	fffff097          	auipc	ra,0xfffff
    8000536c:	ad6080e7          	jalr	-1322(ra) # 80003e3e <namei>
    80005370:	84aa                	mv	s1,a0
    80005372:	c551                	beqz	a0,800053fe <sys_link+0xde>
  ilock(ip);
    80005374:	ffffe097          	auipc	ra,0xffffe
    80005378:	31e080e7          	jalr	798(ra) # 80003692 <ilock>
  if(ip->type == T_DIR){
    8000537c:	04449703          	lh	a4,68(s1)
    80005380:	4785                	li	a5,1
    80005382:	08f70463          	beq	a4,a5,8000540a <sys_link+0xea>
  ip->nlink++;
    80005386:	04a4d783          	lhu	a5,74(s1)
    8000538a:	2785                	addiw	a5,a5,1
    8000538c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005390:	8526                	mv	a0,s1
    80005392:	ffffe097          	auipc	ra,0xffffe
    80005396:	234080e7          	jalr	564(ra) # 800035c6 <iupdate>
  iunlock(ip);
    8000539a:	8526                	mv	a0,s1
    8000539c:	ffffe097          	auipc	ra,0xffffe
    800053a0:	3b8080e7          	jalr	952(ra) # 80003754 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800053a4:	fd040593          	addi	a1,s0,-48
    800053a8:	f5040513          	addi	a0,s0,-176
    800053ac:	fffff097          	auipc	ra,0xfffff
    800053b0:	ab0080e7          	jalr	-1360(ra) # 80003e5c <nameiparent>
    800053b4:	892a                	mv	s2,a0
    800053b6:	c935                	beqz	a0,8000542a <sys_link+0x10a>
  ilock(dp);
    800053b8:	ffffe097          	auipc	ra,0xffffe
    800053bc:	2da080e7          	jalr	730(ra) # 80003692 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800053c0:	00092703          	lw	a4,0(s2)
    800053c4:	409c                	lw	a5,0(s1)
    800053c6:	04f71d63          	bne	a4,a5,80005420 <sys_link+0x100>
    800053ca:	40d0                	lw	a2,4(s1)
    800053cc:	fd040593          	addi	a1,s0,-48
    800053d0:	854a                	mv	a0,s2
    800053d2:	fffff097          	auipc	ra,0xfffff
    800053d6:	9ba080e7          	jalr	-1606(ra) # 80003d8c <dirlink>
    800053da:	04054363          	bltz	a0,80005420 <sys_link+0x100>
  iunlockput(dp);
    800053de:	854a                	mv	a0,s2
    800053e0:	ffffe097          	auipc	ra,0xffffe
    800053e4:	514080e7          	jalr	1300(ra) # 800038f4 <iunlockput>
  iput(ip);
    800053e8:	8526                	mv	a0,s1
    800053ea:	ffffe097          	auipc	ra,0xffffe
    800053ee:	462080e7          	jalr	1122(ra) # 8000384c <iput>
  end_op();
    800053f2:	fffff097          	auipc	ra,0xfffff
    800053f6:	cea080e7          	jalr	-790(ra) # 800040dc <end_op>
  return 0;
    800053fa:	4781                	li	a5,0
    800053fc:	a085                	j	8000545c <sys_link+0x13c>
    end_op();
    800053fe:	fffff097          	auipc	ra,0xfffff
    80005402:	cde080e7          	jalr	-802(ra) # 800040dc <end_op>
    return -1;
    80005406:	57fd                	li	a5,-1
    80005408:	a891                	j	8000545c <sys_link+0x13c>
    iunlockput(ip);
    8000540a:	8526                	mv	a0,s1
    8000540c:	ffffe097          	auipc	ra,0xffffe
    80005410:	4e8080e7          	jalr	1256(ra) # 800038f4 <iunlockput>
    end_op();
    80005414:	fffff097          	auipc	ra,0xfffff
    80005418:	cc8080e7          	jalr	-824(ra) # 800040dc <end_op>
    return -1;
    8000541c:	57fd                	li	a5,-1
    8000541e:	a83d                	j	8000545c <sys_link+0x13c>
    iunlockput(dp);
    80005420:	854a                	mv	a0,s2
    80005422:	ffffe097          	auipc	ra,0xffffe
    80005426:	4d2080e7          	jalr	1234(ra) # 800038f4 <iunlockput>
  ilock(ip);
    8000542a:	8526                	mv	a0,s1
    8000542c:	ffffe097          	auipc	ra,0xffffe
    80005430:	266080e7          	jalr	614(ra) # 80003692 <ilock>
  ip->nlink--;
    80005434:	04a4d783          	lhu	a5,74(s1)
    80005438:	37fd                	addiw	a5,a5,-1
    8000543a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000543e:	8526                	mv	a0,s1
    80005440:	ffffe097          	auipc	ra,0xffffe
    80005444:	186080e7          	jalr	390(ra) # 800035c6 <iupdate>
  iunlockput(ip);
    80005448:	8526                	mv	a0,s1
    8000544a:	ffffe097          	auipc	ra,0xffffe
    8000544e:	4aa080e7          	jalr	1194(ra) # 800038f4 <iunlockput>
  end_op();
    80005452:	fffff097          	auipc	ra,0xfffff
    80005456:	c8a080e7          	jalr	-886(ra) # 800040dc <end_op>
  return -1;
    8000545a:	57fd                	li	a5,-1
}
    8000545c:	853e                	mv	a0,a5
    8000545e:	70b2                	ld	ra,296(sp)
    80005460:	7412                	ld	s0,288(sp)
    80005462:	64f2                	ld	s1,280(sp)
    80005464:	6952                	ld	s2,272(sp)
    80005466:	6155                	addi	sp,sp,304
    80005468:	8082                	ret

000000008000546a <sys_unlink>:
{
    8000546a:	7151                	addi	sp,sp,-240
    8000546c:	f586                	sd	ra,232(sp)
    8000546e:	f1a2                	sd	s0,224(sp)
    80005470:	eda6                	sd	s1,216(sp)
    80005472:	e9ca                	sd	s2,208(sp)
    80005474:	e5ce                	sd	s3,200(sp)
    80005476:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005478:	08000613          	li	a2,128
    8000547c:	f3040593          	addi	a1,s0,-208
    80005480:	4501                	li	a0,0
    80005482:	ffffd097          	auipc	ra,0xffffd
    80005486:	68c080e7          	jalr	1676(ra) # 80002b0e <argstr>
    8000548a:	18054163          	bltz	a0,8000560c <sys_unlink+0x1a2>
  begin_op();
    8000548e:	fffff097          	auipc	ra,0xfffff
    80005492:	bd0080e7          	jalr	-1072(ra) # 8000405e <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005496:	fb040593          	addi	a1,s0,-80
    8000549a:	f3040513          	addi	a0,s0,-208
    8000549e:	fffff097          	auipc	ra,0xfffff
    800054a2:	9be080e7          	jalr	-1602(ra) # 80003e5c <nameiparent>
    800054a6:	84aa                	mv	s1,a0
    800054a8:	c979                	beqz	a0,8000557e <sys_unlink+0x114>
  ilock(dp);
    800054aa:	ffffe097          	auipc	ra,0xffffe
    800054ae:	1e8080e7          	jalr	488(ra) # 80003692 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800054b2:	00003597          	auipc	a1,0x3
    800054b6:	27658593          	addi	a1,a1,630 # 80008728 <syscalls+0x2d8>
    800054ba:	fb040513          	addi	a0,s0,-80
    800054be:	ffffe097          	auipc	ra,0xffffe
    800054c2:	69e080e7          	jalr	1694(ra) # 80003b5c <namecmp>
    800054c6:	14050a63          	beqz	a0,8000561a <sys_unlink+0x1b0>
    800054ca:	00003597          	auipc	a1,0x3
    800054ce:	26658593          	addi	a1,a1,614 # 80008730 <syscalls+0x2e0>
    800054d2:	fb040513          	addi	a0,s0,-80
    800054d6:	ffffe097          	auipc	ra,0xffffe
    800054da:	686080e7          	jalr	1670(ra) # 80003b5c <namecmp>
    800054de:	12050e63          	beqz	a0,8000561a <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800054e2:	f2c40613          	addi	a2,s0,-212
    800054e6:	fb040593          	addi	a1,s0,-80
    800054ea:	8526                	mv	a0,s1
    800054ec:	ffffe097          	auipc	ra,0xffffe
    800054f0:	68a080e7          	jalr	1674(ra) # 80003b76 <dirlookup>
    800054f4:	892a                	mv	s2,a0
    800054f6:	12050263          	beqz	a0,8000561a <sys_unlink+0x1b0>
  ilock(ip);
    800054fa:	ffffe097          	auipc	ra,0xffffe
    800054fe:	198080e7          	jalr	408(ra) # 80003692 <ilock>
  if(ip->nlink < 1)
    80005502:	04a91783          	lh	a5,74(s2)
    80005506:	08f05263          	blez	a5,8000558a <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000550a:	04491703          	lh	a4,68(s2)
    8000550e:	4785                	li	a5,1
    80005510:	08f70563          	beq	a4,a5,8000559a <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005514:	4641                	li	a2,16
    80005516:	4581                	li	a1,0
    80005518:	fc040513          	addi	a0,s0,-64
    8000551c:	ffffb097          	auipc	ra,0xffffb
    80005520:	7b6080e7          	jalr	1974(ra) # 80000cd2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005524:	4741                	li	a4,16
    80005526:	f2c42683          	lw	a3,-212(s0)
    8000552a:	fc040613          	addi	a2,s0,-64
    8000552e:	4581                	li	a1,0
    80005530:	8526                	mv	a0,s1
    80005532:	ffffe097          	auipc	ra,0xffffe
    80005536:	50c080e7          	jalr	1292(ra) # 80003a3e <writei>
    8000553a:	47c1                	li	a5,16
    8000553c:	0af51563          	bne	a0,a5,800055e6 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005540:	04491703          	lh	a4,68(s2)
    80005544:	4785                	li	a5,1
    80005546:	0af70863          	beq	a4,a5,800055f6 <sys_unlink+0x18c>
  iunlockput(dp);
    8000554a:	8526                	mv	a0,s1
    8000554c:	ffffe097          	auipc	ra,0xffffe
    80005550:	3a8080e7          	jalr	936(ra) # 800038f4 <iunlockput>
  ip->nlink--;
    80005554:	04a95783          	lhu	a5,74(s2)
    80005558:	37fd                	addiw	a5,a5,-1
    8000555a:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000555e:	854a                	mv	a0,s2
    80005560:	ffffe097          	auipc	ra,0xffffe
    80005564:	066080e7          	jalr	102(ra) # 800035c6 <iupdate>
  iunlockput(ip);
    80005568:	854a                	mv	a0,s2
    8000556a:	ffffe097          	auipc	ra,0xffffe
    8000556e:	38a080e7          	jalr	906(ra) # 800038f4 <iunlockput>
  end_op();
    80005572:	fffff097          	auipc	ra,0xfffff
    80005576:	b6a080e7          	jalr	-1174(ra) # 800040dc <end_op>
  return 0;
    8000557a:	4501                	li	a0,0
    8000557c:	a84d                	j	8000562e <sys_unlink+0x1c4>
    end_op();
    8000557e:	fffff097          	auipc	ra,0xfffff
    80005582:	b5e080e7          	jalr	-1186(ra) # 800040dc <end_op>
    return -1;
    80005586:	557d                	li	a0,-1
    80005588:	a05d                	j	8000562e <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    8000558a:	00003517          	auipc	a0,0x3
    8000558e:	1ae50513          	addi	a0,a0,430 # 80008738 <syscalls+0x2e8>
    80005592:	ffffb097          	auipc	ra,0xffffb
    80005596:	fae080e7          	jalr	-82(ra) # 80000540 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000559a:	04c92703          	lw	a4,76(s2)
    8000559e:	02000793          	li	a5,32
    800055a2:	f6e7f9e3          	bgeu	a5,a4,80005514 <sys_unlink+0xaa>
    800055a6:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800055aa:	4741                	li	a4,16
    800055ac:	86ce                	mv	a3,s3
    800055ae:	f1840613          	addi	a2,s0,-232
    800055b2:	4581                	li	a1,0
    800055b4:	854a                	mv	a0,s2
    800055b6:	ffffe097          	auipc	ra,0xffffe
    800055ba:	390080e7          	jalr	912(ra) # 80003946 <readi>
    800055be:	47c1                	li	a5,16
    800055c0:	00f51b63          	bne	a0,a5,800055d6 <sys_unlink+0x16c>
    if(de.inum != 0)
    800055c4:	f1845783          	lhu	a5,-232(s0)
    800055c8:	e7a1                	bnez	a5,80005610 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800055ca:	29c1                	addiw	s3,s3,16
    800055cc:	04c92783          	lw	a5,76(s2)
    800055d0:	fcf9ede3          	bltu	s3,a5,800055aa <sys_unlink+0x140>
    800055d4:	b781                	j	80005514 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    800055d6:	00003517          	auipc	a0,0x3
    800055da:	17a50513          	addi	a0,a0,378 # 80008750 <syscalls+0x300>
    800055de:	ffffb097          	auipc	ra,0xffffb
    800055e2:	f62080e7          	jalr	-158(ra) # 80000540 <panic>
    panic("unlink: writei");
    800055e6:	00003517          	auipc	a0,0x3
    800055ea:	18250513          	addi	a0,a0,386 # 80008768 <syscalls+0x318>
    800055ee:	ffffb097          	auipc	ra,0xffffb
    800055f2:	f52080e7          	jalr	-174(ra) # 80000540 <panic>
    dp->nlink--;
    800055f6:	04a4d783          	lhu	a5,74(s1)
    800055fa:	37fd                	addiw	a5,a5,-1
    800055fc:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005600:	8526                	mv	a0,s1
    80005602:	ffffe097          	auipc	ra,0xffffe
    80005606:	fc4080e7          	jalr	-60(ra) # 800035c6 <iupdate>
    8000560a:	b781                	j	8000554a <sys_unlink+0xe0>
    return -1;
    8000560c:	557d                	li	a0,-1
    8000560e:	a005                	j	8000562e <sys_unlink+0x1c4>
    iunlockput(ip);
    80005610:	854a                	mv	a0,s2
    80005612:	ffffe097          	auipc	ra,0xffffe
    80005616:	2e2080e7          	jalr	738(ra) # 800038f4 <iunlockput>
  iunlockput(dp);
    8000561a:	8526                	mv	a0,s1
    8000561c:	ffffe097          	auipc	ra,0xffffe
    80005620:	2d8080e7          	jalr	728(ra) # 800038f4 <iunlockput>
  end_op();
    80005624:	fffff097          	auipc	ra,0xfffff
    80005628:	ab8080e7          	jalr	-1352(ra) # 800040dc <end_op>
  return -1;
    8000562c:	557d                	li	a0,-1
}
    8000562e:	70ae                	ld	ra,232(sp)
    80005630:	740e                	ld	s0,224(sp)
    80005632:	64ee                	ld	s1,216(sp)
    80005634:	694e                	ld	s2,208(sp)
    80005636:	69ae                	ld	s3,200(sp)
    80005638:	616d                	addi	sp,sp,240
    8000563a:	8082                	ret

000000008000563c <sys_open>:

uint64
sys_open(void)
{
    8000563c:	7131                	addi	sp,sp,-192
    8000563e:	fd06                	sd	ra,184(sp)
    80005640:	f922                	sd	s0,176(sp)
    80005642:	f526                	sd	s1,168(sp)
    80005644:	f14a                	sd	s2,160(sp)
    80005646:	ed4e                	sd	s3,152(sp)
    80005648:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    8000564a:	f4c40593          	addi	a1,s0,-180
    8000564e:	4505                	li	a0,1
    80005650:	ffffd097          	auipc	ra,0xffffd
    80005654:	47e080e7          	jalr	1150(ra) # 80002ace <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005658:	08000613          	li	a2,128
    8000565c:	f5040593          	addi	a1,s0,-176
    80005660:	4501                	li	a0,0
    80005662:	ffffd097          	auipc	ra,0xffffd
    80005666:	4ac080e7          	jalr	1196(ra) # 80002b0e <argstr>
    8000566a:	87aa                	mv	a5,a0
    return -1;
    8000566c:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000566e:	0a07c963          	bltz	a5,80005720 <sys_open+0xe4>

  begin_op();
    80005672:	fffff097          	auipc	ra,0xfffff
    80005676:	9ec080e7          	jalr	-1556(ra) # 8000405e <begin_op>

  if(omode & O_CREATE){
    8000567a:	f4c42783          	lw	a5,-180(s0)
    8000567e:	2007f793          	andi	a5,a5,512
    80005682:	cfc5                	beqz	a5,8000573a <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005684:	4681                	li	a3,0
    80005686:	4601                	li	a2,0
    80005688:	4589                	li	a1,2
    8000568a:	f5040513          	addi	a0,s0,-176
    8000568e:	00000097          	auipc	ra,0x0
    80005692:	972080e7          	jalr	-1678(ra) # 80005000 <create>
    80005696:	84aa                	mv	s1,a0
    if(ip == 0){
    80005698:	c959                	beqz	a0,8000572e <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    8000569a:	04449703          	lh	a4,68(s1)
    8000569e:	478d                	li	a5,3
    800056a0:	00f71763          	bne	a4,a5,800056ae <sys_open+0x72>
    800056a4:	0464d703          	lhu	a4,70(s1)
    800056a8:	47a5                	li	a5,9
    800056aa:	0ce7ed63          	bltu	a5,a4,80005784 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800056ae:	fffff097          	auipc	ra,0xfffff
    800056b2:	dbc080e7          	jalr	-580(ra) # 8000446a <filealloc>
    800056b6:	89aa                	mv	s3,a0
    800056b8:	10050363          	beqz	a0,800057be <sys_open+0x182>
    800056bc:	00000097          	auipc	ra,0x0
    800056c0:	902080e7          	jalr	-1790(ra) # 80004fbe <fdalloc>
    800056c4:	892a                	mv	s2,a0
    800056c6:	0e054763          	bltz	a0,800057b4 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800056ca:	04449703          	lh	a4,68(s1)
    800056ce:	478d                	li	a5,3
    800056d0:	0cf70563          	beq	a4,a5,8000579a <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800056d4:	4789                	li	a5,2
    800056d6:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    800056da:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    800056de:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    800056e2:	f4c42783          	lw	a5,-180(s0)
    800056e6:	0017c713          	xori	a4,a5,1
    800056ea:	8b05                	andi	a4,a4,1
    800056ec:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800056f0:	0037f713          	andi	a4,a5,3
    800056f4:	00e03733          	snez	a4,a4
    800056f8:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800056fc:	4007f793          	andi	a5,a5,1024
    80005700:	c791                	beqz	a5,8000570c <sys_open+0xd0>
    80005702:	04449703          	lh	a4,68(s1)
    80005706:	4789                	li	a5,2
    80005708:	0af70063          	beq	a4,a5,800057a8 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    8000570c:	8526                	mv	a0,s1
    8000570e:	ffffe097          	auipc	ra,0xffffe
    80005712:	046080e7          	jalr	70(ra) # 80003754 <iunlock>
  end_op();
    80005716:	fffff097          	auipc	ra,0xfffff
    8000571a:	9c6080e7          	jalr	-1594(ra) # 800040dc <end_op>

  return fd;
    8000571e:	854a                	mv	a0,s2
}
    80005720:	70ea                	ld	ra,184(sp)
    80005722:	744a                	ld	s0,176(sp)
    80005724:	74aa                	ld	s1,168(sp)
    80005726:	790a                	ld	s2,160(sp)
    80005728:	69ea                	ld	s3,152(sp)
    8000572a:	6129                	addi	sp,sp,192
    8000572c:	8082                	ret
      end_op();
    8000572e:	fffff097          	auipc	ra,0xfffff
    80005732:	9ae080e7          	jalr	-1618(ra) # 800040dc <end_op>
      return -1;
    80005736:	557d                	li	a0,-1
    80005738:	b7e5                	j	80005720 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    8000573a:	f5040513          	addi	a0,s0,-176
    8000573e:	ffffe097          	auipc	ra,0xffffe
    80005742:	700080e7          	jalr	1792(ra) # 80003e3e <namei>
    80005746:	84aa                	mv	s1,a0
    80005748:	c905                	beqz	a0,80005778 <sys_open+0x13c>
    ilock(ip);
    8000574a:	ffffe097          	auipc	ra,0xffffe
    8000574e:	f48080e7          	jalr	-184(ra) # 80003692 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005752:	04449703          	lh	a4,68(s1)
    80005756:	4785                	li	a5,1
    80005758:	f4f711e3          	bne	a4,a5,8000569a <sys_open+0x5e>
    8000575c:	f4c42783          	lw	a5,-180(s0)
    80005760:	d7b9                	beqz	a5,800056ae <sys_open+0x72>
      iunlockput(ip);
    80005762:	8526                	mv	a0,s1
    80005764:	ffffe097          	auipc	ra,0xffffe
    80005768:	190080e7          	jalr	400(ra) # 800038f4 <iunlockput>
      end_op();
    8000576c:	fffff097          	auipc	ra,0xfffff
    80005770:	970080e7          	jalr	-1680(ra) # 800040dc <end_op>
      return -1;
    80005774:	557d                	li	a0,-1
    80005776:	b76d                	j	80005720 <sys_open+0xe4>
      end_op();
    80005778:	fffff097          	auipc	ra,0xfffff
    8000577c:	964080e7          	jalr	-1692(ra) # 800040dc <end_op>
      return -1;
    80005780:	557d                	li	a0,-1
    80005782:	bf79                	j	80005720 <sys_open+0xe4>
    iunlockput(ip);
    80005784:	8526                	mv	a0,s1
    80005786:	ffffe097          	auipc	ra,0xffffe
    8000578a:	16e080e7          	jalr	366(ra) # 800038f4 <iunlockput>
    end_op();
    8000578e:	fffff097          	auipc	ra,0xfffff
    80005792:	94e080e7          	jalr	-1714(ra) # 800040dc <end_op>
    return -1;
    80005796:	557d                	li	a0,-1
    80005798:	b761                	j	80005720 <sys_open+0xe4>
    f->type = FD_DEVICE;
    8000579a:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    8000579e:	04649783          	lh	a5,70(s1)
    800057a2:	02f99223          	sh	a5,36(s3)
    800057a6:	bf25                	j	800056de <sys_open+0xa2>
    itrunc(ip);
    800057a8:	8526                	mv	a0,s1
    800057aa:	ffffe097          	auipc	ra,0xffffe
    800057ae:	ff6080e7          	jalr	-10(ra) # 800037a0 <itrunc>
    800057b2:	bfa9                	j	8000570c <sys_open+0xd0>
      fileclose(f);
    800057b4:	854e                	mv	a0,s3
    800057b6:	fffff097          	auipc	ra,0xfffff
    800057ba:	d70080e7          	jalr	-656(ra) # 80004526 <fileclose>
    iunlockput(ip);
    800057be:	8526                	mv	a0,s1
    800057c0:	ffffe097          	auipc	ra,0xffffe
    800057c4:	134080e7          	jalr	308(ra) # 800038f4 <iunlockput>
    end_op();
    800057c8:	fffff097          	auipc	ra,0xfffff
    800057cc:	914080e7          	jalr	-1772(ra) # 800040dc <end_op>
    return -1;
    800057d0:	557d                	li	a0,-1
    800057d2:	b7b9                	j	80005720 <sys_open+0xe4>

00000000800057d4 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800057d4:	7175                	addi	sp,sp,-144
    800057d6:	e506                	sd	ra,136(sp)
    800057d8:	e122                	sd	s0,128(sp)
    800057da:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800057dc:	fffff097          	auipc	ra,0xfffff
    800057e0:	882080e7          	jalr	-1918(ra) # 8000405e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800057e4:	08000613          	li	a2,128
    800057e8:	f7040593          	addi	a1,s0,-144
    800057ec:	4501                	li	a0,0
    800057ee:	ffffd097          	auipc	ra,0xffffd
    800057f2:	320080e7          	jalr	800(ra) # 80002b0e <argstr>
    800057f6:	02054963          	bltz	a0,80005828 <sys_mkdir+0x54>
    800057fa:	4681                	li	a3,0
    800057fc:	4601                	li	a2,0
    800057fe:	4585                	li	a1,1
    80005800:	f7040513          	addi	a0,s0,-144
    80005804:	fffff097          	auipc	ra,0xfffff
    80005808:	7fc080e7          	jalr	2044(ra) # 80005000 <create>
    8000580c:	cd11                	beqz	a0,80005828 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000580e:	ffffe097          	auipc	ra,0xffffe
    80005812:	0e6080e7          	jalr	230(ra) # 800038f4 <iunlockput>
  end_op();
    80005816:	fffff097          	auipc	ra,0xfffff
    8000581a:	8c6080e7          	jalr	-1850(ra) # 800040dc <end_op>
  return 0;
    8000581e:	4501                	li	a0,0
}
    80005820:	60aa                	ld	ra,136(sp)
    80005822:	640a                	ld	s0,128(sp)
    80005824:	6149                	addi	sp,sp,144
    80005826:	8082                	ret
    end_op();
    80005828:	fffff097          	auipc	ra,0xfffff
    8000582c:	8b4080e7          	jalr	-1868(ra) # 800040dc <end_op>
    return -1;
    80005830:	557d                	li	a0,-1
    80005832:	b7fd                	j	80005820 <sys_mkdir+0x4c>

0000000080005834 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005834:	7135                	addi	sp,sp,-160
    80005836:	ed06                	sd	ra,152(sp)
    80005838:	e922                	sd	s0,144(sp)
    8000583a:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    8000583c:	fffff097          	auipc	ra,0xfffff
    80005840:	822080e7          	jalr	-2014(ra) # 8000405e <begin_op>
  argint(1, &major);
    80005844:	f6c40593          	addi	a1,s0,-148
    80005848:	4505                	li	a0,1
    8000584a:	ffffd097          	auipc	ra,0xffffd
    8000584e:	284080e7          	jalr	644(ra) # 80002ace <argint>
  argint(2, &minor);
    80005852:	f6840593          	addi	a1,s0,-152
    80005856:	4509                	li	a0,2
    80005858:	ffffd097          	auipc	ra,0xffffd
    8000585c:	276080e7          	jalr	630(ra) # 80002ace <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005860:	08000613          	li	a2,128
    80005864:	f7040593          	addi	a1,s0,-144
    80005868:	4501                	li	a0,0
    8000586a:	ffffd097          	auipc	ra,0xffffd
    8000586e:	2a4080e7          	jalr	676(ra) # 80002b0e <argstr>
    80005872:	02054b63          	bltz	a0,800058a8 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005876:	f6841683          	lh	a3,-152(s0)
    8000587a:	f6c41603          	lh	a2,-148(s0)
    8000587e:	458d                	li	a1,3
    80005880:	f7040513          	addi	a0,s0,-144
    80005884:	fffff097          	auipc	ra,0xfffff
    80005888:	77c080e7          	jalr	1916(ra) # 80005000 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000588c:	cd11                	beqz	a0,800058a8 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000588e:	ffffe097          	auipc	ra,0xffffe
    80005892:	066080e7          	jalr	102(ra) # 800038f4 <iunlockput>
  end_op();
    80005896:	fffff097          	auipc	ra,0xfffff
    8000589a:	846080e7          	jalr	-1978(ra) # 800040dc <end_op>
  return 0;
    8000589e:	4501                	li	a0,0
}
    800058a0:	60ea                	ld	ra,152(sp)
    800058a2:	644a                	ld	s0,144(sp)
    800058a4:	610d                	addi	sp,sp,160
    800058a6:	8082                	ret
    end_op();
    800058a8:	fffff097          	auipc	ra,0xfffff
    800058ac:	834080e7          	jalr	-1996(ra) # 800040dc <end_op>
    return -1;
    800058b0:	557d                	li	a0,-1
    800058b2:	b7fd                	j	800058a0 <sys_mknod+0x6c>

00000000800058b4 <sys_chdir>:

uint64
sys_chdir(void)
{
    800058b4:	7135                	addi	sp,sp,-160
    800058b6:	ed06                	sd	ra,152(sp)
    800058b8:	e922                	sd	s0,144(sp)
    800058ba:	e526                	sd	s1,136(sp)
    800058bc:	e14a                	sd	s2,128(sp)
    800058be:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800058c0:	ffffc097          	auipc	ra,0xffffc
    800058c4:	0ec080e7          	jalr	236(ra) # 800019ac <myproc>
    800058c8:	892a                	mv	s2,a0
  
  begin_op();
    800058ca:	ffffe097          	auipc	ra,0xffffe
    800058ce:	794080e7          	jalr	1940(ra) # 8000405e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800058d2:	08000613          	li	a2,128
    800058d6:	f6040593          	addi	a1,s0,-160
    800058da:	4501                	li	a0,0
    800058dc:	ffffd097          	auipc	ra,0xffffd
    800058e0:	232080e7          	jalr	562(ra) # 80002b0e <argstr>
    800058e4:	04054b63          	bltz	a0,8000593a <sys_chdir+0x86>
    800058e8:	f6040513          	addi	a0,s0,-160
    800058ec:	ffffe097          	auipc	ra,0xffffe
    800058f0:	552080e7          	jalr	1362(ra) # 80003e3e <namei>
    800058f4:	84aa                	mv	s1,a0
    800058f6:	c131                	beqz	a0,8000593a <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    800058f8:	ffffe097          	auipc	ra,0xffffe
    800058fc:	d9a080e7          	jalr	-614(ra) # 80003692 <ilock>
  if(ip->type != T_DIR){
    80005900:	04449703          	lh	a4,68(s1)
    80005904:	4785                	li	a5,1
    80005906:	04f71063          	bne	a4,a5,80005946 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    8000590a:	8526                	mv	a0,s1
    8000590c:	ffffe097          	auipc	ra,0xffffe
    80005910:	e48080e7          	jalr	-440(ra) # 80003754 <iunlock>
  iput(p->cwd);
    80005914:	15093503          	ld	a0,336(s2)
    80005918:	ffffe097          	auipc	ra,0xffffe
    8000591c:	f34080e7          	jalr	-204(ra) # 8000384c <iput>
  end_op();
    80005920:	ffffe097          	auipc	ra,0xffffe
    80005924:	7bc080e7          	jalr	1980(ra) # 800040dc <end_op>
  p->cwd = ip;
    80005928:	14993823          	sd	s1,336(s2)
  return 0;
    8000592c:	4501                	li	a0,0
}
    8000592e:	60ea                	ld	ra,152(sp)
    80005930:	644a                	ld	s0,144(sp)
    80005932:	64aa                	ld	s1,136(sp)
    80005934:	690a                	ld	s2,128(sp)
    80005936:	610d                	addi	sp,sp,160
    80005938:	8082                	ret
    end_op();
    8000593a:	ffffe097          	auipc	ra,0xffffe
    8000593e:	7a2080e7          	jalr	1954(ra) # 800040dc <end_op>
    return -1;
    80005942:	557d                	li	a0,-1
    80005944:	b7ed                	j	8000592e <sys_chdir+0x7a>
    iunlockput(ip);
    80005946:	8526                	mv	a0,s1
    80005948:	ffffe097          	auipc	ra,0xffffe
    8000594c:	fac080e7          	jalr	-84(ra) # 800038f4 <iunlockput>
    end_op();
    80005950:	ffffe097          	auipc	ra,0xffffe
    80005954:	78c080e7          	jalr	1932(ra) # 800040dc <end_op>
    return -1;
    80005958:	557d                	li	a0,-1
    8000595a:	bfd1                	j	8000592e <sys_chdir+0x7a>

000000008000595c <sys_exec>:

uint64
sys_exec(void)
{
    8000595c:	7145                	addi	sp,sp,-464
    8000595e:	e786                	sd	ra,456(sp)
    80005960:	e3a2                	sd	s0,448(sp)
    80005962:	ff26                	sd	s1,440(sp)
    80005964:	fb4a                	sd	s2,432(sp)
    80005966:	f74e                	sd	s3,424(sp)
    80005968:	f352                	sd	s4,416(sp)
    8000596a:	ef56                	sd	s5,408(sp)
    8000596c:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    8000596e:	e3840593          	addi	a1,s0,-456
    80005972:	4505                	li	a0,1
    80005974:	ffffd097          	auipc	ra,0xffffd
    80005978:	17a080e7          	jalr	378(ra) # 80002aee <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    8000597c:	08000613          	li	a2,128
    80005980:	f4040593          	addi	a1,s0,-192
    80005984:	4501                	li	a0,0
    80005986:	ffffd097          	auipc	ra,0xffffd
    8000598a:	188080e7          	jalr	392(ra) # 80002b0e <argstr>
    8000598e:	87aa                	mv	a5,a0
    return -1;
    80005990:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005992:	0c07c363          	bltz	a5,80005a58 <sys_exec+0xfc>
  }
  memset(argv, 0, sizeof(argv));
    80005996:	10000613          	li	a2,256
    8000599a:	4581                	li	a1,0
    8000599c:	e4040513          	addi	a0,s0,-448
    800059a0:	ffffb097          	auipc	ra,0xffffb
    800059a4:	332080e7          	jalr	818(ra) # 80000cd2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800059a8:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    800059ac:	89a6                	mv	s3,s1
    800059ae:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800059b0:	02000a13          	li	s4,32
    800059b4:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800059b8:	00391513          	slli	a0,s2,0x3
    800059bc:	e3040593          	addi	a1,s0,-464
    800059c0:	e3843783          	ld	a5,-456(s0)
    800059c4:	953e                	add	a0,a0,a5
    800059c6:	ffffd097          	auipc	ra,0xffffd
    800059ca:	06a080e7          	jalr	106(ra) # 80002a30 <fetchaddr>
    800059ce:	02054a63          	bltz	a0,80005a02 <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    800059d2:	e3043783          	ld	a5,-464(s0)
    800059d6:	c3b9                	beqz	a5,80005a1c <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800059d8:	ffffb097          	auipc	ra,0xffffb
    800059dc:	10e080e7          	jalr	270(ra) # 80000ae6 <kalloc>
    800059e0:	85aa                	mv	a1,a0
    800059e2:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800059e6:	cd11                	beqz	a0,80005a02 <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800059e8:	6605                	lui	a2,0x1
    800059ea:	e3043503          	ld	a0,-464(s0)
    800059ee:	ffffd097          	auipc	ra,0xffffd
    800059f2:	094080e7          	jalr	148(ra) # 80002a82 <fetchstr>
    800059f6:	00054663          	bltz	a0,80005a02 <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    800059fa:	0905                	addi	s2,s2,1
    800059fc:	09a1                	addi	s3,s3,8
    800059fe:	fb491be3          	bne	s2,s4,800059b4 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a02:	f4040913          	addi	s2,s0,-192
    80005a06:	6088                	ld	a0,0(s1)
    80005a08:	c539                	beqz	a0,80005a56 <sys_exec+0xfa>
    kfree(argv[i]);
    80005a0a:	ffffb097          	auipc	ra,0xffffb
    80005a0e:	fde080e7          	jalr	-34(ra) # 800009e8 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a12:	04a1                	addi	s1,s1,8
    80005a14:	ff2499e3          	bne	s1,s2,80005a06 <sys_exec+0xaa>
  return -1;
    80005a18:	557d                	li	a0,-1
    80005a1a:	a83d                	j	80005a58 <sys_exec+0xfc>
      argv[i] = 0;
    80005a1c:	0a8e                	slli	s5,s5,0x3
    80005a1e:	fc0a8793          	addi	a5,s5,-64
    80005a22:	00878ab3          	add	s5,a5,s0
    80005a26:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005a2a:	e4040593          	addi	a1,s0,-448
    80005a2e:	f4040513          	addi	a0,s0,-192
    80005a32:	fffff097          	auipc	ra,0xfffff
    80005a36:	16e080e7          	jalr	366(ra) # 80004ba0 <exec>
    80005a3a:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a3c:	f4040993          	addi	s3,s0,-192
    80005a40:	6088                	ld	a0,0(s1)
    80005a42:	c901                	beqz	a0,80005a52 <sys_exec+0xf6>
    kfree(argv[i]);
    80005a44:	ffffb097          	auipc	ra,0xffffb
    80005a48:	fa4080e7          	jalr	-92(ra) # 800009e8 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a4c:	04a1                	addi	s1,s1,8
    80005a4e:	ff3499e3          	bne	s1,s3,80005a40 <sys_exec+0xe4>
  return ret;
    80005a52:	854a                	mv	a0,s2
    80005a54:	a011                	j	80005a58 <sys_exec+0xfc>
  return -1;
    80005a56:	557d                	li	a0,-1
}
    80005a58:	60be                	ld	ra,456(sp)
    80005a5a:	641e                	ld	s0,448(sp)
    80005a5c:	74fa                	ld	s1,440(sp)
    80005a5e:	795a                	ld	s2,432(sp)
    80005a60:	79ba                	ld	s3,424(sp)
    80005a62:	7a1a                	ld	s4,416(sp)
    80005a64:	6afa                	ld	s5,408(sp)
    80005a66:	6179                	addi	sp,sp,464
    80005a68:	8082                	ret

0000000080005a6a <sys_pipe>:

uint64
sys_pipe(void)
{
    80005a6a:	7139                	addi	sp,sp,-64
    80005a6c:	fc06                	sd	ra,56(sp)
    80005a6e:	f822                	sd	s0,48(sp)
    80005a70:	f426                	sd	s1,40(sp)
    80005a72:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005a74:	ffffc097          	auipc	ra,0xffffc
    80005a78:	f38080e7          	jalr	-200(ra) # 800019ac <myproc>
    80005a7c:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005a7e:	fd840593          	addi	a1,s0,-40
    80005a82:	4501                	li	a0,0
    80005a84:	ffffd097          	auipc	ra,0xffffd
    80005a88:	06a080e7          	jalr	106(ra) # 80002aee <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005a8c:	fc840593          	addi	a1,s0,-56
    80005a90:	fd040513          	addi	a0,s0,-48
    80005a94:	fffff097          	auipc	ra,0xfffff
    80005a98:	dc2080e7          	jalr	-574(ra) # 80004856 <pipealloc>
    return -1;
    80005a9c:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005a9e:	0c054463          	bltz	a0,80005b66 <sys_pipe+0xfc>
  fd0 = -1;
    80005aa2:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005aa6:	fd043503          	ld	a0,-48(s0)
    80005aaa:	fffff097          	auipc	ra,0xfffff
    80005aae:	514080e7          	jalr	1300(ra) # 80004fbe <fdalloc>
    80005ab2:	fca42223          	sw	a0,-60(s0)
    80005ab6:	08054b63          	bltz	a0,80005b4c <sys_pipe+0xe2>
    80005aba:	fc843503          	ld	a0,-56(s0)
    80005abe:	fffff097          	auipc	ra,0xfffff
    80005ac2:	500080e7          	jalr	1280(ra) # 80004fbe <fdalloc>
    80005ac6:	fca42023          	sw	a0,-64(s0)
    80005aca:	06054863          	bltz	a0,80005b3a <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005ace:	4691                	li	a3,4
    80005ad0:	fc440613          	addi	a2,s0,-60
    80005ad4:	fd843583          	ld	a1,-40(s0)
    80005ad8:	68a8                	ld	a0,80(s1)
    80005ada:	ffffc097          	auipc	ra,0xffffc
    80005ade:	b92080e7          	jalr	-1134(ra) # 8000166c <copyout>
    80005ae2:	02054063          	bltz	a0,80005b02 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005ae6:	4691                	li	a3,4
    80005ae8:	fc040613          	addi	a2,s0,-64
    80005aec:	fd843583          	ld	a1,-40(s0)
    80005af0:	0591                	addi	a1,a1,4
    80005af2:	68a8                	ld	a0,80(s1)
    80005af4:	ffffc097          	auipc	ra,0xffffc
    80005af8:	b78080e7          	jalr	-1160(ra) # 8000166c <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005afc:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005afe:	06055463          	bgez	a0,80005b66 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005b02:	fc442783          	lw	a5,-60(s0)
    80005b06:	07e9                	addi	a5,a5,26
    80005b08:	078e                	slli	a5,a5,0x3
    80005b0a:	97a6                	add	a5,a5,s1
    80005b0c:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005b10:	fc042783          	lw	a5,-64(s0)
    80005b14:	07e9                	addi	a5,a5,26
    80005b16:	078e                	slli	a5,a5,0x3
    80005b18:	94be                	add	s1,s1,a5
    80005b1a:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005b1e:	fd043503          	ld	a0,-48(s0)
    80005b22:	fffff097          	auipc	ra,0xfffff
    80005b26:	a04080e7          	jalr	-1532(ra) # 80004526 <fileclose>
    fileclose(wf);
    80005b2a:	fc843503          	ld	a0,-56(s0)
    80005b2e:	fffff097          	auipc	ra,0xfffff
    80005b32:	9f8080e7          	jalr	-1544(ra) # 80004526 <fileclose>
    return -1;
    80005b36:	57fd                	li	a5,-1
    80005b38:	a03d                	j	80005b66 <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005b3a:	fc442783          	lw	a5,-60(s0)
    80005b3e:	0007c763          	bltz	a5,80005b4c <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005b42:	07e9                	addi	a5,a5,26
    80005b44:	078e                	slli	a5,a5,0x3
    80005b46:	97a6                	add	a5,a5,s1
    80005b48:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005b4c:	fd043503          	ld	a0,-48(s0)
    80005b50:	fffff097          	auipc	ra,0xfffff
    80005b54:	9d6080e7          	jalr	-1578(ra) # 80004526 <fileclose>
    fileclose(wf);
    80005b58:	fc843503          	ld	a0,-56(s0)
    80005b5c:	fffff097          	auipc	ra,0xfffff
    80005b60:	9ca080e7          	jalr	-1590(ra) # 80004526 <fileclose>
    return -1;
    80005b64:	57fd                	li	a5,-1
}
    80005b66:	853e                	mv	a0,a5
    80005b68:	70e2                	ld	ra,56(sp)
    80005b6a:	7442                	ld	s0,48(sp)
    80005b6c:	74a2                	ld	s1,40(sp)
    80005b6e:	6121                	addi	sp,sp,64
    80005b70:	8082                	ret
	...

0000000080005b80 <kernelvec>:
    80005b80:	7111                	addi	sp,sp,-256
    80005b82:	e006                	sd	ra,0(sp)
    80005b84:	e40a                	sd	sp,8(sp)
    80005b86:	e80e                	sd	gp,16(sp)
    80005b88:	ec12                	sd	tp,24(sp)
    80005b8a:	f016                	sd	t0,32(sp)
    80005b8c:	f41a                	sd	t1,40(sp)
    80005b8e:	f81e                	sd	t2,48(sp)
    80005b90:	fc22                	sd	s0,56(sp)
    80005b92:	e0a6                	sd	s1,64(sp)
    80005b94:	e4aa                	sd	a0,72(sp)
    80005b96:	e8ae                	sd	a1,80(sp)
    80005b98:	ecb2                	sd	a2,88(sp)
    80005b9a:	f0b6                	sd	a3,96(sp)
    80005b9c:	f4ba                	sd	a4,104(sp)
    80005b9e:	f8be                	sd	a5,112(sp)
    80005ba0:	fcc2                	sd	a6,120(sp)
    80005ba2:	e146                	sd	a7,128(sp)
    80005ba4:	e54a                	sd	s2,136(sp)
    80005ba6:	e94e                	sd	s3,144(sp)
    80005ba8:	ed52                	sd	s4,152(sp)
    80005baa:	f156                	sd	s5,160(sp)
    80005bac:	f55a                	sd	s6,168(sp)
    80005bae:	f95e                	sd	s7,176(sp)
    80005bb0:	fd62                	sd	s8,184(sp)
    80005bb2:	e1e6                	sd	s9,192(sp)
    80005bb4:	e5ea                	sd	s10,200(sp)
    80005bb6:	e9ee                	sd	s11,208(sp)
    80005bb8:	edf2                	sd	t3,216(sp)
    80005bba:	f1f6                	sd	t4,224(sp)
    80005bbc:	f5fa                	sd	t5,232(sp)
    80005bbe:	f9fe                	sd	t6,240(sp)
    80005bc0:	d3dfc0ef          	jal	ra,800028fc <kerneltrap>
    80005bc4:	6082                	ld	ra,0(sp)
    80005bc6:	6122                	ld	sp,8(sp)
    80005bc8:	61c2                	ld	gp,16(sp)
    80005bca:	7282                	ld	t0,32(sp)
    80005bcc:	7322                	ld	t1,40(sp)
    80005bce:	73c2                	ld	t2,48(sp)
    80005bd0:	7462                	ld	s0,56(sp)
    80005bd2:	6486                	ld	s1,64(sp)
    80005bd4:	6526                	ld	a0,72(sp)
    80005bd6:	65c6                	ld	a1,80(sp)
    80005bd8:	6666                	ld	a2,88(sp)
    80005bda:	7686                	ld	a3,96(sp)
    80005bdc:	7726                	ld	a4,104(sp)
    80005bde:	77c6                	ld	a5,112(sp)
    80005be0:	7866                	ld	a6,120(sp)
    80005be2:	688a                	ld	a7,128(sp)
    80005be4:	692a                	ld	s2,136(sp)
    80005be6:	69ca                	ld	s3,144(sp)
    80005be8:	6a6a                	ld	s4,152(sp)
    80005bea:	7a8a                	ld	s5,160(sp)
    80005bec:	7b2a                	ld	s6,168(sp)
    80005bee:	7bca                	ld	s7,176(sp)
    80005bf0:	7c6a                	ld	s8,184(sp)
    80005bf2:	6c8e                	ld	s9,192(sp)
    80005bf4:	6d2e                	ld	s10,200(sp)
    80005bf6:	6dce                	ld	s11,208(sp)
    80005bf8:	6e6e                	ld	t3,216(sp)
    80005bfa:	7e8e                	ld	t4,224(sp)
    80005bfc:	7f2e                	ld	t5,232(sp)
    80005bfe:	7fce                	ld	t6,240(sp)
    80005c00:	6111                	addi	sp,sp,256
    80005c02:	10200073          	sret
    80005c06:	00000013          	nop
    80005c0a:	00000013          	nop
    80005c0e:	0001                	nop

0000000080005c10 <timervec>:
    80005c10:	34051573          	csrrw	a0,mscratch,a0
    80005c14:	e10c                	sd	a1,0(a0)
    80005c16:	e510                	sd	a2,8(a0)
    80005c18:	e914                	sd	a3,16(a0)
    80005c1a:	6d0c                	ld	a1,24(a0)
    80005c1c:	7110                	ld	a2,32(a0)
    80005c1e:	6194                	ld	a3,0(a1)
    80005c20:	96b2                	add	a3,a3,a2
    80005c22:	e194                	sd	a3,0(a1)
    80005c24:	4589                	li	a1,2
    80005c26:	14459073          	csrw	sip,a1
    80005c2a:	6914                	ld	a3,16(a0)
    80005c2c:	6510                	ld	a2,8(a0)
    80005c2e:	610c                	ld	a1,0(a0)
    80005c30:	34051573          	csrrw	a0,mscratch,a0
    80005c34:	30200073          	mret
	...

0000000080005c3a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005c3a:	1141                	addi	sp,sp,-16
    80005c3c:	e422                	sd	s0,8(sp)
    80005c3e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005c40:	0c0007b7          	lui	a5,0xc000
    80005c44:	4705                	li	a4,1
    80005c46:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005c48:	c3d8                	sw	a4,4(a5)
}
    80005c4a:	6422                	ld	s0,8(sp)
    80005c4c:	0141                	addi	sp,sp,16
    80005c4e:	8082                	ret

0000000080005c50 <plicinithart>:

void
plicinithart(void)
{
    80005c50:	1141                	addi	sp,sp,-16
    80005c52:	e406                	sd	ra,8(sp)
    80005c54:	e022                	sd	s0,0(sp)
    80005c56:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005c58:	ffffc097          	auipc	ra,0xffffc
    80005c5c:	d28080e7          	jalr	-728(ra) # 80001980 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005c60:	0085171b          	slliw	a4,a0,0x8
    80005c64:	0c0027b7          	lui	a5,0xc002
    80005c68:	97ba                	add	a5,a5,a4
    80005c6a:	40200713          	li	a4,1026
    80005c6e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005c72:	00d5151b          	slliw	a0,a0,0xd
    80005c76:	0c2017b7          	lui	a5,0xc201
    80005c7a:	97aa                	add	a5,a5,a0
    80005c7c:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005c80:	60a2                	ld	ra,8(sp)
    80005c82:	6402                	ld	s0,0(sp)
    80005c84:	0141                	addi	sp,sp,16
    80005c86:	8082                	ret

0000000080005c88 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005c88:	1141                	addi	sp,sp,-16
    80005c8a:	e406                	sd	ra,8(sp)
    80005c8c:	e022                	sd	s0,0(sp)
    80005c8e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005c90:	ffffc097          	auipc	ra,0xffffc
    80005c94:	cf0080e7          	jalr	-784(ra) # 80001980 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005c98:	00d5151b          	slliw	a0,a0,0xd
    80005c9c:	0c2017b7          	lui	a5,0xc201
    80005ca0:	97aa                	add	a5,a5,a0
  return irq;
}
    80005ca2:	43c8                	lw	a0,4(a5)
    80005ca4:	60a2                	ld	ra,8(sp)
    80005ca6:	6402                	ld	s0,0(sp)
    80005ca8:	0141                	addi	sp,sp,16
    80005caa:	8082                	ret

0000000080005cac <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005cac:	1101                	addi	sp,sp,-32
    80005cae:	ec06                	sd	ra,24(sp)
    80005cb0:	e822                	sd	s0,16(sp)
    80005cb2:	e426                	sd	s1,8(sp)
    80005cb4:	1000                	addi	s0,sp,32
    80005cb6:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005cb8:	ffffc097          	auipc	ra,0xffffc
    80005cbc:	cc8080e7          	jalr	-824(ra) # 80001980 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005cc0:	00d5151b          	slliw	a0,a0,0xd
    80005cc4:	0c2017b7          	lui	a5,0xc201
    80005cc8:	97aa                	add	a5,a5,a0
    80005cca:	c3c4                	sw	s1,4(a5)
}
    80005ccc:	60e2                	ld	ra,24(sp)
    80005cce:	6442                	ld	s0,16(sp)
    80005cd0:	64a2                	ld	s1,8(sp)
    80005cd2:	6105                	addi	sp,sp,32
    80005cd4:	8082                	ret

0000000080005cd6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005cd6:	1141                	addi	sp,sp,-16
    80005cd8:	e406                	sd	ra,8(sp)
    80005cda:	e022                	sd	s0,0(sp)
    80005cdc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005cde:	479d                	li	a5,7
    80005ce0:	04a7cc63          	blt	a5,a0,80005d38 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80005ce4:	0001c797          	auipc	a5,0x1c
    80005ce8:	17c78793          	addi	a5,a5,380 # 80021e60 <disk>
    80005cec:	97aa                	add	a5,a5,a0
    80005cee:	0187c783          	lbu	a5,24(a5)
    80005cf2:	ebb9                	bnez	a5,80005d48 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005cf4:	00451693          	slli	a3,a0,0x4
    80005cf8:	0001c797          	auipc	a5,0x1c
    80005cfc:	16878793          	addi	a5,a5,360 # 80021e60 <disk>
    80005d00:	6398                	ld	a4,0(a5)
    80005d02:	9736                	add	a4,a4,a3
    80005d04:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005d08:	6398                	ld	a4,0(a5)
    80005d0a:	9736                	add	a4,a4,a3
    80005d0c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005d10:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005d14:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005d18:	97aa                	add	a5,a5,a0
    80005d1a:	4705                	li	a4,1
    80005d1c:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005d20:	0001c517          	auipc	a0,0x1c
    80005d24:	15850513          	addi	a0,a0,344 # 80021e78 <disk+0x18>
    80005d28:	ffffc097          	auipc	ra,0xffffc
    80005d2c:	39a080e7          	jalr	922(ra) # 800020c2 <wakeup>
}
    80005d30:	60a2                	ld	ra,8(sp)
    80005d32:	6402                	ld	s0,0(sp)
    80005d34:	0141                	addi	sp,sp,16
    80005d36:	8082                	ret
    panic("free_desc 1");
    80005d38:	00003517          	auipc	a0,0x3
    80005d3c:	a4050513          	addi	a0,a0,-1472 # 80008778 <syscalls+0x328>
    80005d40:	ffffb097          	auipc	ra,0xffffb
    80005d44:	800080e7          	jalr	-2048(ra) # 80000540 <panic>
    panic("free_desc 2");
    80005d48:	00003517          	auipc	a0,0x3
    80005d4c:	a4050513          	addi	a0,a0,-1472 # 80008788 <syscalls+0x338>
    80005d50:	ffffa097          	auipc	ra,0xffffa
    80005d54:	7f0080e7          	jalr	2032(ra) # 80000540 <panic>

0000000080005d58 <virtio_disk_init>:
{
    80005d58:	1101                	addi	sp,sp,-32
    80005d5a:	ec06                	sd	ra,24(sp)
    80005d5c:	e822                	sd	s0,16(sp)
    80005d5e:	e426                	sd	s1,8(sp)
    80005d60:	e04a                	sd	s2,0(sp)
    80005d62:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005d64:	00003597          	auipc	a1,0x3
    80005d68:	a3458593          	addi	a1,a1,-1484 # 80008798 <syscalls+0x348>
    80005d6c:	0001c517          	auipc	a0,0x1c
    80005d70:	21c50513          	addi	a0,a0,540 # 80021f88 <disk+0x128>
    80005d74:	ffffb097          	auipc	ra,0xffffb
    80005d78:	dd2080e7          	jalr	-558(ra) # 80000b46 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005d7c:	100017b7          	lui	a5,0x10001
    80005d80:	4398                	lw	a4,0(a5)
    80005d82:	2701                	sext.w	a4,a4
    80005d84:	747277b7          	lui	a5,0x74727
    80005d88:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005d8c:	14f71b63          	bne	a4,a5,80005ee2 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005d90:	100017b7          	lui	a5,0x10001
    80005d94:	43dc                	lw	a5,4(a5)
    80005d96:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005d98:	4709                	li	a4,2
    80005d9a:	14e79463          	bne	a5,a4,80005ee2 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005d9e:	100017b7          	lui	a5,0x10001
    80005da2:	479c                	lw	a5,8(a5)
    80005da4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005da6:	12e79e63          	bne	a5,a4,80005ee2 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005daa:	100017b7          	lui	a5,0x10001
    80005dae:	47d8                	lw	a4,12(a5)
    80005db0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005db2:	554d47b7          	lui	a5,0x554d4
    80005db6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005dba:	12f71463          	bne	a4,a5,80005ee2 <virtio_disk_init+0x18a>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005dbe:	100017b7          	lui	a5,0x10001
    80005dc2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005dc6:	4705                	li	a4,1
    80005dc8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005dca:	470d                	li	a4,3
    80005dcc:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005dce:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005dd0:	c7ffe6b7          	lui	a3,0xc7ffe
    80005dd4:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdc7bf>
    80005dd8:	8f75                	and	a4,a4,a3
    80005dda:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005ddc:	472d                	li	a4,11
    80005dde:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80005de0:	5bbc                	lw	a5,112(a5)
    80005de2:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005de6:	8ba1                	andi	a5,a5,8
    80005de8:	10078563          	beqz	a5,80005ef2 <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005dec:	100017b7          	lui	a5,0x10001
    80005df0:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005df4:	43fc                	lw	a5,68(a5)
    80005df6:	2781                	sext.w	a5,a5
    80005df8:	10079563          	bnez	a5,80005f02 <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005dfc:	100017b7          	lui	a5,0x10001
    80005e00:	5bdc                	lw	a5,52(a5)
    80005e02:	2781                	sext.w	a5,a5
  if(max == 0)
    80005e04:	10078763          	beqz	a5,80005f12 <virtio_disk_init+0x1ba>
  if(max < NUM)
    80005e08:	471d                	li	a4,7
    80005e0a:	10f77c63          	bgeu	a4,a5,80005f22 <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    80005e0e:	ffffb097          	auipc	ra,0xffffb
    80005e12:	cd8080e7          	jalr	-808(ra) # 80000ae6 <kalloc>
    80005e16:	0001c497          	auipc	s1,0x1c
    80005e1a:	04a48493          	addi	s1,s1,74 # 80021e60 <disk>
    80005e1e:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005e20:	ffffb097          	auipc	ra,0xffffb
    80005e24:	cc6080e7          	jalr	-826(ra) # 80000ae6 <kalloc>
    80005e28:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005e2a:	ffffb097          	auipc	ra,0xffffb
    80005e2e:	cbc080e7          	jalr	-836(ra) # 80000ae6 <kalloc>
    80005e32:	87aa                	mv	a5,a0
    80005e34:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005e36:	6088                	ld	a0,0(s1)
    80005e38:	cd6d                	beqz	a0,80005f32 <virtio_disk_init+0x1da>
    80005e3a:	0001c717          	auipc	a4,0x1c
    80005e3e:	02e73703          	ld	a4,46(a4) # 80021e68 <disk+0x8>
    80005e42:	cb65                	beqz	a4,80005f32 <virtio_disk_init+0x1da>
    80005e44:	c7fd                	beqz	a5,80005f32 <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    80005e46:	6605                	lui	a2,0x1
    80005e48:	4581                	li	a1,0
    80005e4a:	ffffb097          	auipc	ra,0xffffb
    80005e4e:	e88080e7          	jalr	-376(ra) # 80000cd2 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005e52:	0001c497          	auipc	s1,0x1c
    80005e56:	00e48493          	addi	s1,s1,14 # 80021e60 <disk>
    80005e5a:	6605                	lui	a2,0x1
    80005e5c:	4581                	li	a1,0
    80005e5e:	6488                	ld	a0,8(s1)
    80005e60:	ffffb097          	auipc	ra,0xffffb
    80005e64:	e72080e7          	jalr	-398(ra) # 80000cd2 <memset>
  memset(disk.used, 0, PGSIZE);
    80005e68:	6605                	lui	a2,0x1
    80005e6a:	4581                	li	a1,0
    80005e6c:	6888                	ld	a0,16(s1)
    80005e6e:	ffffb097          	auipc	ra,0xffffb
    80005e72:	e64080e7          	jalr	-412(ra) # 80000cd2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005e76:	100017b7          	lui	a5,0x10001
    80005e7a:	4721                	li	a4,8
    80005e7c:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005e7e:	4098                	lw	a4,0(s1)
    80005e80:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005e84:	40d8                	lw	a4,4(s1)
    80005e86:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005e8a:	6498                	ld	a4,8(s1)
    80005e8c:	0007069b          	sext.w	a3,a4
    80005e90:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005e94:	9701                	srai	a4,a4,0x20
    80005e96:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005e9a:	6898                	ld	a4,16(s1)
    80005e9c:	0007069b          	sext.w	a3,a4
    80005ea0:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005ea4:	9701                	srai	a4,a4,0x20
    80005ea6:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005eaa:	4705                	li	a4,1
    80005eac:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80005eae:	00e48c23          	sb	a4,24(s1)
    80005eb2:	00e48ca3          	sb	a4,25(s1)
    80005eb6:	00e48d23          	sb	a4,26(s1)
    80005eba:	00e48da3          	sb	a4,27(s1)
    80005ebe:	00e48e23          	sb	a4,28(s1)
    80005ec2:	00e48ea3          	sb	a4,29(s1)
    80005ec6:	00e48f23          	sb	a4,30(s1)
    80005eca:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005ece:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005ed2:	0727a823          	sw	s2,112(a5)
}
    80005ed6:	60e2                	ld	ra,24(sp)
    80005ed8:	6442                	ld	s0,16(sp)
    80005eda:	64a2                	ld	s1,8(sp)
    80005edc:	6902                	ld	s2,0(sp)
    80005ede:	6105                	addi	sp,sp,32
    80005ee0:	8082                	ret
    panic("could not find virtio disk");
    80005ee2:	00003517          	auipc	a0,0x3
    80005ee6:	8c650513          	addi	a0,a0,-1850 # 800087a8 <syscalls+0x358>
    80005eea:	ffffa097          	auipc	ra,0xffffa
    80005eee:	656080e7          	jalr	1622(ra) # 80000540 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005ef2:	00003517          	auipc	a0,0x3
    80005ef6:	8d650513          	addi	a0,a0,-1834 # 800087c8 <syscalls+0x378>
    80005efa:	ffffa097          	auipc	ra,0xffffa
    80005efe:	646080e7          	jalr	1606(ra) # 80000540 <panic>
    panic("virtio disk should not be ready");
    80005f02:	00003517          	auipc	a0,0x3
    80005f06:	8e650513          	addi	a0,a0,-1818 # 800087e8 <syscalls+0x398>
    80005f0a:	ffffa097          	auipc	ra,0xffffa
    80005f0e:	636080e7          	jalr	1590(ra) # 80000540 <panic>
    panic("virtio disk has no queue 0");
    80005f12:	00003517          	auipc	a0,0x3
    80005f16:	8f650513          	addi	a0,a0,-1802 # 80008808 <syscalls+0x3b8>
    80005f1a:	ffffa097          	auipc	ra,0xffffa
    80005f1e:	626080e7          	jalr	1574(ra) # 80000540 <panic>
    panic("virtio disk max queue too short");
    80005f22:	00003517          	auipc	a0,0x3
    80005f26:	90650513          	addi	a0,a0,-1786 # 80008828 <syscalls+0x3d8>
    80005f2a:	ffffa097          	auipc	ra,0xffffa
    80005f2e:	616080e7          	jalr	1558(ra) # 80000540 <panic>
    panic("virtio disk kalloc");
    80005f32:	00003517          	auipc	a0,0x3
    80005f36:	91650513          	addi	a0,a0,-1770 # 80008848 <syscalls+0x3f8>
    80005f3a:	ffffa097          	auipc	ra,0xffffa
    80005f3e:	606080e7          	jalr	1542(ra) # 80000540 <panic>

0000000080005f42 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005f42:	7119                	addi	sp,sp,-128
    80005f44:	fc86                	sd	ra,120(sp)
    80005f46:	f8a2                	sd	s0,112(sp)
    80005f48:	f4a6                	sd	s1,104(sp)
    80005f4a:	f0ca                	sd	s2,96(sp)
    80005f4c:	ecce                	sd	s3,88(sp)
    80005f4e:	e8d2                	sd	s4,80(sp)
    80005f50:	e4d6                	sd	s5,72(sp)
    80005f52:	e0da                	sd	s6,64(sp)
    80005f54:	fc5e                	sd	s7,56(sp)
    80005f56:	f862                	sd	s8,48(sp)
    80005f58:	f466                	sd	s9,40(sp)
    80005f5a:	f06a                	sd	s10,32(sp)
    80005f5c:	ec6e                	sd	s11,24(sp)
    80005f5e:	0100                	addi	s0,sp,128
    80005f60:	8aaa                	mv	s5,a0
    80005f62:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005f64:	00c52d03          	lw	s10,12(a0)
    80005f68:	001d1d1b          	slliw	s10,s10,0x1
    80005f6c:	1d02                	slli	s10,s10,0x20
    80005f6e:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80005f72:	0001c517          	auipc	a0,0x1c
    80005f76:	01650513          	addi	a0,a0,22 # 80021f88 <disk+0x128>
    80005f7a:	ffffb097          	auipc	ra,0xffffb
    80005f7e:	c5c080e7          	jalr	-932(ra) # 80000bd6 <acquire>
  for(int i = 0; i < 3; i++){
    80005f82:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80005f84:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005f86:	0001cb97          	auipc	s7,0x1c
    80005f8a:	edab8b93          	addi	s7,s7,-294 # 80021e60 <disk>
  for(int i = 0; i < 3; i++){
    80005f8e:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005f90:	0001cc97          	auipc	s9,0x1c
    80005f94:	ff8c8c93          	addi	s9,s9,-8 # 80021f88 <disk+0x128>
    80005f98:	a08d                	j	80005ffa <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    80005f9a:	00fb8733          	add	a4,s7,a5
    80005f9e:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005fa2:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005fa4:	0207c563          	bltz	a5,80005fce <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    80005fa8:	2905                	addiw	s2,s2,1
    80005faa:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005fac:	05690c63          	beq	s2,s6,80006004 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    80005fb0:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005fb2:	0001c717          	auipc	a4,0x1c
    80005fb6:	eae70713          	addi	a4,a4,-338 # 80021e60 <disk>
    80005fba:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80005fbc:	01874683          	lbu	a3,24(a4)
    80005fc0:	fee9                	bnez	a3,80005f9a <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80005fc2:	2785                	addiw	a5,a5,1
    80005fc4:	0705                	addi	a4,a4,1
    80005fc6:	fe979be3          	bne	a5,s1,80005fbc <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    80005fca:	57fd                	li	a5,-1
    80005fcc:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80005fce:	01205d63          	blez	s2,80005fe8 <virtio_disk_rw+0xa6>
    80005fd2:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80005fd4:	000a2503          	lw	a0,0(s4)
    80005fd8:	00000097          	auipc	ra,0x0
    80005fdc:	cfe080e7          	jalr	-770(ra) # 80005cd6 <free_desc>
      for(int j = 0; j < i; j++)
    80005fe0:	2d85                	addiw	s11,s11,1
    80005fe2:	0a11                	addi	s4,s4,4
    80005fe4:	ff2d98e3          	bne	s11,s2,80005fd4 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005fe8:	85e6                	mv	a1,s9
    80005fea:	0001c517          	auipc	a0,0x1c
    80005fee:	e8e50513          	addi	a0,a0,-370 # 80021e78 <disk+0x18>
    80005ff2:	ffffc097          	auipc	ra,0xffffc
    80005ff6:	06c080e7          	jalr	108(ra) # 8000205e <sleep>
  for(int i = 0; i < 3; i++){
    80005ffa:	f8040a13          	addi	s4,s0,-128
{
    80005ffe:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006000:	894e                	mv	s2,s3
    80006002:	b77d                	j	80005fb0 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006004:	f8042503          	lw	a0,-128(s0)
    80006008:	00a50713          	addi	a4,a0,10
    8000600c:	0712                	slli	a4,a4,0x4

  if(write)
    8000600e:	0001c797          	auipc	a5,0x1c
    80006012:	e5278793          	addi	a5,a5,-430 # 80021e60 <disk>
    80006016:	00e786b3          	add	a3,a5,a4
    8000601a:	01803633          	snez	a2,s8
    8000601e:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006020:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    80006024:	01a6b823          	sd	s10,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006028:	f6070613          	addi	a2,a4,-160
    8000602c:	6394                	ld	a3,0(a5)
    8000602e:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006030:	00870593          	addi	a1,a4,8
    80006034:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006036:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006038:	0007b803          	ld	a6,0(a5)
    8000603c:	9642                	add	a2,a2,a6
    8000603e:	46c1                	li	a3,16
    80006040:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006042:	4585                	li	a1,1
    80006044:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    80006048:	f8442683          	lw	a3,-124(s0)
    8000604c:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006050:	0692                	slli	a3,a3,0x4
    80006052:	9836                	add	a6,a6,a3
    80006054:	058a8613          	addi	a2,s5,88
    80006058:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    8000605c:	0007b803          	ld	a6,0(a5)
    80006060:	96c2                	add	a3,a3,a6
    80006062:	40000613          	li	a2,1024
    80006066:	c690                	sw	a2,8(a3)
  if(write)
    80006068:	001c3613          	seqz	a2,s8
    8000606c:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006070:	00166613          	ori	a2,a2,1
    80006074:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80006078:	f8842603          	lw	a2,-120(s0)
    8000607c:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006080:	00250693          	addi	a3,a0,2
    80006084:	0692                	slli	a3,a3,0x4
    80006086:	96be                	add	a3,a3,a5
    80006088:	58fd                	li	a7,-1
    8000608a:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000608e:	0612                	slli	a2,a2,0x4
    80006090:	9832                	add	a6,a6,a2
    80006092:	f9070713          	addi	a4,a4,-112
    80006096:	973e                	add	a4,a4,a5
    80006098:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    8000609c:	6398                	ld	a4,0(a5)
    8000609e:	9732                	add	a4,a4,a2
    800060a0:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800060a2:	4609                	li	a2,2
    800060a4:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    800060a8:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800060ac:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    800060b0:	0156b423          	sd	s5,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800060b4:	6794                	ld	a3,8(a5)
    800060b6:	0026d703          	lhu	a4,2(a3)
    800060ba:	8b1d                	andi	a4,a4,7
    800060bc:	0706                	slli	a4,a4,0x1
    800060be:	96ba                	add	a3,a3,a4
    800060c0:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    800060c4:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800060c8:	6798                	ld	a4,8(a5)
    800060ca:	00275783          	lhu	a5,2(a4)
    800060ce:	2785                	addiw	a5,a5,1
    800060d0:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800060d4:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800060d8:	100017b7          	lui	a5,0x10001
    800060dc:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800060e0:	004aa783          	lw	a5,4(s5)
    sleep(b, &disk.vdisk_lock);
    800060e4:	0001c917          	auipc	s2,0x1c
    800060e8:	ea490913          	addi	s2,s2,-348 # 80021f88 <disk+0x128>
  while(b->disk == 1) {
    800060ec:	4485                	li	s1,1
    800060ee:	00b79c63          	bne	a5,a1,80006106 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    800060f2:	85ca                	mv	a1,s2
    800060f4:	8556                	mv	a0,s5
    800060f6:	ffffc097          	auipc	ra,0xffffc
    800060fa:	f68080e7          	jalr	-152(ra) # 8000205e <sleep>
  while(b->disk == 1) {
    800060fe:	004aa783          	lw	a5,4(s5)
    80006102:	fe9788e3          	beq	a5,s1,800060f2 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006106:	f8042903          	lw	s2,-128(s0)
    8000610a:	00290713          	addi	a4,s2,2
    8000610e:	0712                	slli	a4,a4,0x4
    80006110:	0001c797          	auipc	a5,0x1c
    80006114:	d5078793          	addi	a5,a5,-688 # 80021e60 <disk>
    80006118:	97ba                	add	a5,a5,a4
    8000611a:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000611e:	0001c997          	auipc	s3,0x1c
    80006122:	d4298993          	addi	s3,s3,-702 # 80021e60 <disk>
    80006126:	00491713          	slli	a4,s2,0x4
    8000612a:	0009b783          	ld	a5,0(s3)
    8000612e:	97ba                	add	a5,a5,a4
    80006130:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006134:	854a                	mv	a0,s2
    80006136:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000613a:	00000097          	auipc	ra,0x0
    8000613e:	b9c080e7          	jalr	-1124(ra) # 80005cd6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006142:	8885                	andi	s1,s1,1
    80006144:	f0ed                	bnez	s1,80006126 <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006146:	0001c517          	auipc	a0,0x1c
    8000614a:	e4250513          	addi	a0,a0,-446 # 80021f88 <disk+0x128>
    8000614e:	ffffb097          	auipc	ra,0xffffb
    80006152:	b3c080e7          	jalr	-1220(ra) # 80000c8a <release>
}
    80006156:	70e6                	ld	ra,120(sp)
    80006158:	7446                	ld	s0,112(sp)
    8000615a:	74a6                	ld	s1,104(sp)
    8000615c:	7906                	ld	s2,96(sp)
    8000615e:	69e6                	ld	s3,88(sp)
    80006160:	6a46                	ld	s4,80(sp)
    80006162:	6aa6                	ld	s5,72(sp)
    80006164:	6b06                	ld	s6,64(sp)
    80006166:	7be2                	ld	s7,56(sp)
    80006168:	7c42                	ld	s8,48(sp)
    8000616a:	7ca2                	ld	s9,40(sp)
    8000616c:	7d02                	ld	s10,32(sp)
    8000616e:	6de2                	ld	s11,24(sp)
    80006170:	6109                	addi	sp,sp,128
    80006172:	8082                	ret

0000000080006174 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006174:	1101                	addi	sp,sp,-32
    80006176:	ec06                	sd	ra,24(sp)
    80006178:	e822                	sd	s0,16(sp)
    8000617a:	e426                	sd	s1,8(sp)
    8000617c:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000617e:	0001c497          	auipc	s1,0x1c
    80006182:	ce248493          	addi	s1,s1,-798 # 80021e60 <disk>
    80006186:	0001c517          	auipc	a0,0x1c
    8000618a:	e0250513          	addi	a0,a0,-510 # 80021f88 <disk+0x128>
    8000618e:	ffffb097          	auipc	ra,0xffffb
    80006192:	a48080e7          	jalr	-1464(ra) # 80000bd6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006196:	10001737          	lui	a4,0x10001
    8000619a:	533c                	lw	a5,96(a4)
    8000619c:	8b8d                	andi	a5,a5,3
    8000619e:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800061a0:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800061a4:	689c                	ld	a5,16(s1)
    800061a6:	0204d703          	lhu	a4,32(s1)
    800061aa:	0027d783          	lhu	a5,2(a5)
    800061ae:	04f70863          	beq	a4,a5,800061fe <virtio_disk_intr+0x8a>
    __sync_synchronize();
    800061b2:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800061b6:	6898                	ld	a4,16(s1)
    800061b8:	0204d783          	lhu	a5,32(s1)
    800061bc:	8b9d                	andi	a5,a5,7
    800061be:	078e                	slli	a5,a5,0x3
    800061c0:	97ba                	add	a5,a5,a4
    800061c2:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800061c4:	00278713          	addi	a4,a5,2
    800061c8:	0712                	slli	a4,a4,0x4
    800061ca:	9726                	add	a4,a4,s1
    800061cc:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    800061d0:	e721                	bnez	a4,80006218 <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800061d2:	0789                	addi	a5,a5,2
    800061d4:	0792                	slli	a5,a5,0x4
    800061d6:	97a6                	add	a5,a5,s1
    800061d8:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    800061da:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800061de:	ffffc097          	auipc	ra,0xffffc
    800061e2:	ee4080e7          	jalr	-284(ra) # 800020c2 <wakeup>

    disk.used_idx += 1;
    800061e6:	0204d783          	lhu	a5,32(s1)
    800061ea:	2785                	addiw	a5,a5,1
    800061ec:	17c2                	slli	a5,a5,0x30
    800061ee:	93c1                	srli	a5,a5,0x30
    800061f0:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800061f4:	6898                	ld	a4,16(s1)
    800061f6:	00275703          	lhu	a4,2(a4)
    800061fa:	faf71ce3          	bne	a4,a5,800061b2 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    800061fe:	0001c517          	auipc	a0,0x1c
    80006202:	d8a50513          	addi	a0,a0,-630 # 80021f88 <disk+0x128>
    80006206:	ffffb097          	auipc	ra,0xffffb
    8000620a:	a84080e7          	jalr	-1404(ra) # 80000c8a <release>
}
    8000620e:	60e2                	ld	ra,24(sp)
    80006210:	6442                	ld	s0,16(sp)
    80006212:	64a2                	ld	s1,8(sp)
    80006214:	6105                	addi	sp,sp,32
    80006216:	8082                	ret
      panic("virtio_disk_intr status");
    80006218:	00002517          	auipc	a0,0x2
    8000621c:	64850513          	addi	a0,a0,1608 # 80008860 <syscalls+0x410>
    80006220:	ffffa097          	auipc	ra,0xffffa
    80006224:	320080e7          	jalr	800(ra) # 80000540 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0)
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0)
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
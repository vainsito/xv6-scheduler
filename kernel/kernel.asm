
kernel/kernel:     formato del fichero elf64-littleriscv


Desensamblado de la sección .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	9c013103          	ld	sp,-1600(sp) # 800089c0 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000054:	9d070713          	addi	a4,a4,-1584 # 80008a20 <timer_scratch>
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
    80000066:	01e78793          	addi	a5,a5,30 # 80006080 <timervec>
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
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdbd37>
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
    8000012e:	7ec080e7          	jalr	2028(ra) # 80002916 <either_copyin>
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
    8000018e:	9d650513          	addi	a0,a0,-1578 # 80010b60 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	a44080e7          	jalr	-1468(ra) # 80000bd6 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019a:	00011497          	auipc	s1,0x11
    8000019e:	9c648493          	addi	s1,s1,-1594 # 80010b60 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a2:	00011917          	auipc	s2,0x11
    800001a6:	a5690913          	addi	s2,s2,-1450 # 80010bf8 <cons+0x98>
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
    800001c0:	00002097          	auipc	ra,0x2
    800001c4:	a6c080e7          	jalr	-1428(ra) # 80001c2c <myproc>
    800001c8:	00002097          	auipc	ra,0x2
    800001cc:	598080e7          	jalr	1432(ra) # 80002760 <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
      sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	230080e7          	jalr	560(ra) # 80002406 <sleep>
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
    80000216:	6ae080e7          	jalr	1710(ra) # 800028c0 <either_copyout>
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
    8000022a:	93a50513          	addi	a0,a0,-1734 # 80010b60 <cons>
    8000022e:	00001097          	auipc	ra,0x1
    80000232:	a5c080e7          	jalr	-1444(ra) # 80000c8a <release>

  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	a811                	j	8000024e <consoleread+0xea>
        release(&cons.lock);
    8000023c:	00011517          	auipc	a0,0x11
    80000240:	92450513          	addi	a0,a0,-1756 # 80010b60 <cons>
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
    80000276:	98f72323          	sw	a5,-1658(a4) # 80010bf8 <cons+0x98>
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
    800002cc:	00011517          	auipc	a0,0x11
    800002d0:	89450513          	addi	a0,a0,-1900 # 80010b60 <cons>
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
    800002f6:	67a080e7          	jalr	1658(ra) # 8000296c <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002fa:	00011517          	auipc	a0,0x11
    800002fe:	86650513          	addi	a0,a0,-1946 # 80010b60 <cons>
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
    8000031e:	00011717          	auipc	a4,0x11
    80000322:	84270713          	addi	a4,a4,-1982 # 80010b60 <cons>
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
    80000348:	00011797          	auipc	a5,0x11
    8000034c:	81878793          	addi	a5,a5,-2024 # 80010b60 <cons>
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
    80000376:	00011797          	auipc	a5,0x11
    8000037a:	8827a783          	lw	a5,-1918(a5) # 80010bf8 <cons+0x98>
    8000037e:	9f1d                	subw	a4,a4,a5
    80000380:	08000793          	li	a5,128
    80000384:	f6f71be3          	bne	a4,a5,800002fa <consoleintr+0x3c>
    80000388:	a07d                	j	80000436 <consoleintr+0x178>
    while(cons.e != cons.w &&
    8000038a:	00010717          	auipc	a4,0x10
    8000038e:	7d670713          	addi	a4,a4,2006 # 80010b60 <cons>
    80000392:	0a072783          	lw	a5,160(a4)
    80000396:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000039a:	00010497          	auipc	s1,0x10
    8000039e:	7c648493          	addi	s1,s1,1990 # 80010b60 <cons>
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
    800003da:	78a70713          	addi	a4,a4,1930 # 80010b60 <cons>
    800003de:	0a072783          	lw	a5,160(a4)
    800003e2:	09c72703          	lw	a4,156(a4)
    800003e6:	f0f70ae3          	beq	a4,a5,800002fa <consoleintr+0x3c>
      cons.e--;
    800003ea:	37fd                	addiw	a5,a5,-1
    800003ec:	00011717          	auipc	a4,0x11
    800003f0:	80f72a23          	sw	a5,-2028(a4) # 80010c00 <cons+0xa0>
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
    80000416:	74e78793          	addi	a5,a5,1870 # 80010b60 <cons>
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
    8000043a:	7cc7a323          	sw	a2,1990(a5) # 80010bfc <cons+0x9c>
        wakeup(&cons.r);
    8000043e:	00010517          	auipc	a0,0x10
    80000442:	7ba50513          	addi	a0,a0,1978 # 80010bf8 <cons+0x98>
    80000446:	00002097          	auipc	ra,0x2
    8000044a:	036080e7          	jalr	54(ra) # 8000247c <wakeup>
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
    80000464:	70050513          	addi	a0,a0,1792 # 80010b60 <cons>
    80000468:	00000097          	auipc	ra,0x0
    8000046c:	6de080e7          	jalr	1758(ra) # 80000b46 <initlock>

  uartinit();
    80000470:	00000097          	auipc	ra,0x0
    80000474:	32c080e7          	jalr	812(ra) # 8000079c <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000478:	00021797          	auipc	a5,0x21
    8000047c:	4b878793          	addi	a5,a5,1208 # 80021930 <devsw>
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
    80000550:	6c07aa23          	sw	zero,1748(a5) # 80010c20 <pr+0x18>
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
    80000572:	09250513          	addi	a0,a0,146 # 80008600 <syscalls+0xf0>
    80000576:	00000097          	auipc	ra,0x0
    8000057a:	014080e7          	jalr	20(ra) # 8000058a <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057e:	4785                	li	a5,1
    80000580:	00008717          	auipc	a4,0x8
    80000584:	46f72023          	sw	a5,1120(a4) # 800089e0 <panicked>
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
    800005c0:	664dad83          	lw	s11,1636(s11) # 80010c20 <pr+0x18>
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
    800005fe:	60e50513          	addi	a0,a0,1550 # 80010c08 <pr>
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
    8000075c:	4b050513          	addi	a0,a0,1200 # 80010c08 <pr>
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
    80000778:	49448493          	addi	s1,s1,1172 # 80010c08 <pr>
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
    800007d8:	45450513          	addi	a0,a0,1108 # 80010c28 <uart_tx_lock>
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
    80000804:	1e07a783          	lw	a5,480(a5) # 800089e0 <panicked>
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
    8000083c:	1b07b783          	ld	a5,432(a5) # 800089e8 <uart_tx_r>
    80000840:	00008717          	auipc	a4,0x8
    80000844:	1b073703          	ld	a4,432(a4) # 800089f0 <uart_tx_w>
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
    80000866:	3c6a0a13          	addi	s4,s4,966 # 80010c28 <uart_tx_lock>
    uart_tx_r += 1;
    8000086a:	00008497          	auipc	s1,0x8
    8000086e:	17e48493          	addi	s1,s1,382 # 800089e8 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000872:	00008997          	auipc	s3,0x8
    80000876:	17e98993          	addi	s3,s3,382 # 800089f0 <uart_tx_w>
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
    80000898:	be8080e7          	jalr	-1048(ra) # 8000247c <wakeup>
    
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
    800008d4:	35850513          	addi	a0,a0,856 # 80010c28 <uart_tx_lock>
    800008d8:	00000097          	auipc	ra,0x0
    800008dc:	2fe080e7          	jalr	766(ra) # 80000bd6 <acquire>
  if(panicked){
    800008e0:	00008797          	auipc	a5,0x8
    800008e4:	1007a783          	lw	a5,256(a5) # 800089e0 <panicked>
    800008e8:	e7c9                	bnez	a5,80000972 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008ea:	00008717          	auipc	a4,0x8
    800008ee:	10673703          	ld	a4,262(a4) # 800089f0 <uart_tx_w>
    800008f2:	00008797          	auipc	a5,0x8
    800008f6:	0f67b783          	ld	a5,246(a5) # 800089e8 <uart_tx_r>
    800008fa:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fe:	00010997          	auipc	s3,0x10
    80000902:	32a98993          	addi	s3,s3,810 # 80010c28 <uart_tx_lock>
    80000906:	00008497          	auipc	s1,0x8
    8000090a:	0e248493          	addi	s1,s1,226 # 800089e8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090e:	00008917          	auipc	s2,0x8
    80000912:	0e290913          	addi	s2,s2,226 # 800089f0 <uart_tx_w>
    80000916:	00e79f63          	bne	a5,a4,80000934 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000091a:	85ce                	mv	a1,s3
    8000091c:	8526                	mv	a0,s1
    8000091e:	00002097          	auipc	ra,0x2
    80000922:	ae8080e7          	jalr	-1304(ra) # 80002406 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000926:	00093703          	ld	a4,0(s2)
    8000092a:	609c                	ld	a5,0(s1)
    8000092c:	02078793          	addi	a5,a5,32
    80000930:	fee785e3          	beq	a5,a4,8000091a <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000934:	00010497          	auipc	s1,0x10
    80000938:	2f448493          	addi	s1,s1,756 # 80010c28 <uart_tx_lock>
    8000093c:	01f77793          	andi	a5,a4,31
    80000940:	97a6                	add	a5,a5,s1
    80000942:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000946:	0705                	addi	a4,a4,1
    80000948:	00008797          	auipc	a5,0x8
    8000094c:	0ae7b423          	sd	a4,168(a5) # 800089f0 <uart_tx_w>
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
    800009be:	26e48493          	addi	s1,s1,622 # 80010c28 <uart_tx_lock>
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
    800009fc:	00022797          	auipc	a5,0x22
    80000a00:	0cc78793          	addi	a5,a5,204 # 80022ac8 <end>
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
    80000a20:	24490913          	addi	s2,s2,580 # 80010c60 <kmem>
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
    80000abe:	1a650513          	addi	a0,a0,422 # 80010c60 <kmem>
    80000ac2:	00000097          	auipc	ra,0x0
    80000ac6:	084080e7          	jalr	132(ra) # 80000b46 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000aca:	45c5                	li	a1,17
    80000acc:	05ee                	slli	a1,a1,0x1b
    80000ace:	00022517          	auipc	a0,0x22
    80000ad2:	ffa50513          	addi	a0,a0,-6 # 80022ac8 <end>
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
    80000af4:	17048493          	addi	s1,s1,368 # 80010c60 <kmem>
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
    80000b0c:	15850513          	addi	a0,a0,344 # 80010c60 <kmem>
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
    80000b38:	12c50513          	addi	a0,a0,300 # 80010c60 <kmem>
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
    80000b74:	0a0080e7          	jalr	160(ra) # 80001c10 <mycpu>
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
    80000ba6:	06e080e7          	jalr	110(ra) # 80001c10 <mycpu>
    80000baa:	5d3c                	lw	a5,120(a0)
    80000bac:	cf89                	beqz	a5,80000bc6 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bae:	00001097          	auipc	ra,0x1
    80000bb2:	062080e7          	jalr	98(ra) # 80001c10 <mycpu>
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
    80000bca:	04a080e7          	jalr	74(ra) # 80001c10 <mycpu>
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
    80000c0a:	00a080e7          	jalr	10(ra) # 80001c10 <mycpu>
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
    80000c36:	fde080e7          	jalr	-34(ra) # 80001c10 <mycpu>
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
    80000d46:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdc539>
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
    80000e84:	d80080e7          	jalr	-640(ra) # 80001c00 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e88:	00008717          	auipc	a4,0x8
    80000e8c:	b7070713          	addi	a4,a4,-1168 # 800089f8 <started>
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
    80000ea0:	d64080e7          	jalr	-668(ra) # 80001c00 <cpuid>
    80000ea4:	85aa                	mv	a1,a0
    80000ea6:	00007517          	auipc	a0,0x7
    80000eaa:	21250513          	addi	a0,a0,530 # 800080b8 <digits+0x78>
    80000eae:	fffff097          	auipc	ra,0xfffff
    80000eb2:	6dc080e7          	jalr	1756(ra) # 8000058a <printf>
    kvminithart();    // turn on paging
    80000eb6:	00000097          	auipc	ra,0x0
    80000eba:	0d8080e7          	jalr	216(ra) # 80000f8e <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ebe:	00002097          	auipc	ra,0x2
    80000ec2:	bf4080e7          	jalr	-1036(ra) # 80002ab2 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec6:	00005097          	auipc	ra,0x5
    80000eca:	1fa080e7          	jalr	506(ra) # 800060c0 <plicinithart>
  }

  scheduler();        
    80000ece:	00001097          	auipc	ra,0x1
    80000ed2:	2e6080e7          	jalr	742(ra) # 800021b4 <scheduler>
    consoleinit();
    80000ed6:	fffff097          	auipc	ra,0xfffff
    80000eda:	57a080e7          	jalr	1402(ra) # 80000450 <consoleinit>
    printfinit();
    80000ede:	00000097          	auipc	ra,0x0
    80000ee2:	88c080e7          	jalr	-1908(ra) # 8000076a <printfinit>
    printf("\n");
    80000ee6:	00007517          	auipc	a0,0x7
    80000eea:	71a50513          	addi	a0,a0,1818 # 80008600 <syscalls+0xf0>
    80000eee:	fffff097          	auipc	ra,0xfffff
    80000ef2:	69c080e7          	jalr	1692(ra) # 8000058a <printf>
    printf("xv6 kernel is booting\n");
    80000ef6:	00007517          	auipc	a0,0x7
    80000efa:	1aa50513          	addi	a0,a0,426 # 800080a0 <digits+0x60>
    80000efe:	fffff097          	auipc	ra,0xfffff
    80000f02:	68c080e7          	jalr	1676(ra) # 8000058a <printf>
    printf("\n");
    80000f06:	00007517          	auipc	a0,0x7
    80000f0a:	6fa50513          	addi	a0,a0,1786 # 80008600 <syscalls+0xf0>
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
    80000f32:	bc2080e7          	jalr	-1086(ra) # 80001af0 <procinit>
    trapinit();      // trap vectors
    80000f36:	00002097          	auipc	ra,0x2
    80000f3a:	b54080e7          	jalr	-1196(ra) # 80002a8a <trapinit>
    trapinithart();  // install kernel trap vector
    80000f3e:	00002097          	auipc	ra,0x2
    80000f42:	b74080e7          	jalr	-1164(ra) # 80002ab2 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f46:	00005097          	auipc	ra,0x5
    80000f4a:	164080e7          	jalr	356(ra) # 800060aa <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f4e:	00005097          	auipc	ra,0x5
    80000f52:	172080e7          	jalr	370(ra) # 800060c0 <plicinithart>
    binit();         // buffer cache
    80000f56:	00002097          	auipc	ra,0x2
    80000f5a:	314080e7          	jalr	788(ra) # 8000326a <binit>
    iinit();         // inode table
    80000f5e:	00003097          	auipc	ra,0x3
    80000f62:	9b4080e7          	jalr	-1612(ra) # 80003912 <iinit>
    fileinit();      // file table
    80000f66:	00004097          	auipc	ra,0x4
    80000f6a:	95a080e7          	jalr	-1702(ra) # 800048c0 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f6e:	00005097          	auipc	ra,0x5
    80000f72:	25a080e7          	jalr	602(ra) # 800061c8 <virtio_disk_init>
    userinit();      // first user process
    80000f76:	00001097          	auipc	ra,0x1
    80000f7a:	f9c080e7          	jalr	-100(ra) # 80001f12 <userinit>
    __sync_synchronize();
    80000f7e:	0ff0000f          	fence
    started = 1;
    80000f82:	4785                	li	a5,1
    80000f84:	00008717          	auipc	a4,0x8
    80000f88:	a6f72a23          	sw	a5,-1420(a4) # 800089f8 <started>
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
    80000f9c:	a687b783          	ld	a5,-1432(a5) # 80008a00 <kernel_pagetable>
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
    80001016:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdc52f>
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
    8000122e:	00001097          	auipc	ra,0x1
    80001232:	82c080e7          	jalr	-2004(ra) # 80001a5a <proc_mapstacks>
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
    80001258:	7aa7b623          	sd	a0,1964(a5) # 80008a00 <kernel_pagetable>
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
    8000180c:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffdc538>
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

0000000080001836 <dequeue>:
  uint total_size;                        // cant total de procesos en pqueue
  uint max_priority;
  struct spinlock qlock;
} pq;

struct proc *dequeue(void){
    80001836:	7179                	addi	sp,sp,-48
    80001838:	f406                	sd	ra,40(sp)
    8000183a:	f022                	sd	s0,32(sp)
    8000183c:	ec26                	sd	s1,24(sp)
    8000183e:	e84a                	sd	s2,16(sp)
    80001840:	e44e                	sd	s3,8(sp)
    80001842:	1800                	addi	s0,sp,48
  
  uint prio = pq.max_priority;
    80001844:	00016917          	auipc	s2,0x16
    80001848:	e8892903          	lw	s2,-376(s2) # 800176cc <pq+0x661c>

  if(pq.queue_size[prio] == 0){
    8000184c:	02091793          	slli	a5,s2,0x20
    80001850:	9381                	srli	a5,a5,0x20
    80001852:	6709                	lui	a4,0x2
    80001854:	98070713          	addi	a4,a4,-1664 # 1980 <_entry-0x7fffe680>
    80001858:	97ba                	add	a5,a5,a4
    8000185a:	078a                	slli	a5,a5,0x2
    8000185c:	00010717          	auipc	a4,0x10
    80001860:	85470713          	addi	a4,a4,-1964 # 800110b0 <pq>
    80001864:	97ba                	add	a5,a5,a4
    80001866:	47dc                	lw	a5,12(a5)
    return 0;
    80001868:	4501                	li	a0,0
  if(pq.queue_size[prio] == 0){
    8000186a:	16078363          	beqz	a5,800019d0 <dequeue+0x19a>
    8000186e:	4481                	li	s1,0
  }

  acquire(&pq.proc_queue[prio][pq.pos_prio[prio]-1]->lock);
    80001870:	86ba                	mv	a3,a4
    80001872:	02091793          	slli	a5,s2,0x20
    80001876:	9381                	srli	a5,a5,0x20
    80001878:	6989                	lui	s3,0x2
    8000187a:	98098993          	addi	s3,s3,-1664 # 1980 <_entry-0x7fffe680>
    8000187e:	99be                	add	s3,s3,a5
    80001880:	098a                	slli	s3,s3,0x2
    80001882:	99ba                	add	s3,s3,a4
    80001884:	0009a703          	lw	a4,0(s3)
    80001888:	377d                	addiw	a4,a4,-1
    8000188a:	1702                	slli	a4,a4,0x20
    8000188c:	9301                	srli	a4,a4,0x20
    8000188e:	079a                	slli	a5,a5,0x6
    80001890:	97ba                	add	a5,a5,a4
    80001892:	6705                	lui	a4,0x1
    80001894:	c0070713          	addi	a4,a4,-1024 # c00 <_entry-0x7ffff400>
    80001898:	97ba                	add	a5,a5,a4
    8000189a:	078e                	slli	a5,a5,0x3
    8000189c:	96be                	add	a3,a3,a5
    8000189e:	6288                	ld	a0,0(a3)
    800018a0:	fffff097          	auipc	ra,0xfffff
    800018a4:	336080e7          	jalr	822(ra) # 80000bd6 <acquire>

  struct proc *res;

  if (pq.queue_size[prio] == 1){
    800018a8:	00c9a583          	lw	a1,12(s3)
    800018ac:	4785                	li	a5,1
    800018ae:	0ef58a63          	beq	a1,a5,800019a2 <dequeue+0x16c>
    res = pq.proc_queue[prio][0];
    pq.proc_queue[prio][0] = 0;
    pq.pos_prio[prio]--;
    pq.queue_size[prio]--;
  } else {
    res = pq.proc_queue[prio][0];
    800018b2:	0000f697          	auipc	a3,0xf
    800018b6:	7fe68693          	addi	a3,a3,2046 # 800110b0 <pq>
    800018ba:	02091793          	slli	a5,s2,0x20
    800018be:	9381                	srli	a5,a5,0x20
    800018c0:	03078713          	addi	a4,a5,48
    800018c4:	0726                	slli	a4,a4,0x9
    800018c6:	9736                	add	a4,a4,a3
    800018c8:	6308                	ld	a0,0(a4)

    for(uint i = 0 ; i < pq.pos_prio[prio]; i++){
    800018ca:	6709                	lui	a4,0x2
    800018cc:	98070713          	addi	a4,a4,-1664 # 1980 <_entry-0x7fffe680>
    800018d0:	97ba                	add	a5,a5,a4
    800018d2:	078a                	slli	a5,a5,0x2
    800018d4:	96be                	add	a3,a3,a5
    800018d6:	4290                	lw	a2,0(a3)
    800018d8:	ce0d                	beqz	a2,80001912 <dequeue+0xdc>
    800018da:	02091713          	slli	a4,s2,0x20
    800018de:	9301                	srli	a4,a4,0x20
    800018e0:	03070793          	addi	a5,a4,48
    800018e4:	07a6                	slli	a5,a5,0x9
    800018e6:	0000f697          	auipc	a3,0xf
    800018ea:	7ca68693          	addi	a3,a3,1994 # 800110b0 <pq>
    800018ee:	97b6                	add	a5,a5,a3
    800018f0:	071a                	slli	a4,a4,0x6
    800018f2:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    800018f6:	1682                	slli	a3,a3,0x20
    800018f8:	9281                	srli	a3,a3,0x20
    800018fa:	9736                	add	a4,a4,a3
    800018fc:	070e                	slli	a4,a4,0x3
    800018fe:	00015697          	auipc	a3,0x15
    80001902:	7ba68693          	addi	a3,a3,1978 # 800170b8 <pq+0x6008>
    80001906:	9736                	add	a4,a4,a3
      pq.proc_queue[prio][i] = pq.proc_queue[prio][i+1];
    80001908:	6794                	ld	a3,8(a5)
    8000190a:	e394                	sd	a3,0(a5)
    for(uint i = 0 ; i < pq.pos_prio[prio]; i++){
    8000190c:	07a1                	addi	a5,a5,8
    8000190e:	fee79de3          	bne	a5,a4,80001908 <dequeue+0xd2>
    }
    pq.proc_queue[prio][pq.pos_prio[prio]] = 0;
    80001912:	02061713          	slli	a4,a2,0x20
    80001916:	9301                	srli	a4,a4,0x20
    80001918:	02091693          	slli	a3,s2,0x20
    8000191c:	01a6d793          	srli	a5,a3,0x1a
    80001920:	97ba                	add	a5,a5,a4
    80001922:	6705                	lui	a4,0x1
    80001924:	c0070713          	addi	a4,a4,-1024 # c00 <_entry-0x7ffff400>
    80001928:	97ba                	add	a5,a5,a4
    8000192a:	078e                	slli	a5,a5,0x3
    8000192c:	0000f717          	auipc	a4,0xf
    80001930:	78470713          	addi	a4,a4,1924 # 800110b0 <pq>
    80001934:	97ba                	add	a5,a5,a4
    80001936:	0007b023          	sd	zero,0(a5)
    
    pq.pos_prio[prio]--;  
    8000193a:	367d                	addiw	a2,a2,-1
    pq.queue_size[prio]--;
    8000193c:	35fd                	addiw	a1,a1,-1
    pq.pos_prio[prio]--;
    8000193e:	1902                	slli	s2,s2,0x20
    80001940:	02095913          	srli	s2,s2,0x20
    80001944:	6789                	lui	a5,0x2
    80001946:	98078793          	addi	a5,a5,-1664 # 1980 <_entry-0x7fffe680>
    8000194a:	993e                	add	s2,s2,a5
    8000194c:	090a                	slli	s2,s2,0x2
    8000194e:	0000f797          	auipc	a5,0xf
    80001952:	76278793          	addi	a5,a5,1890 # 800110b0 <pq>
    80001956:	97ca                	add	a5,a5,s2
    80001958:	c390                	sw	a2,0(a5)
    pq.queue_size[prio]--;
    8000195a:	c7cc                	sw	a1,12(a5)
    
  }

  pq.total_size--;
    8000195c:	00015797          	auipc	a5,0x15
    80001960:	75478793          	addi	a5,a5,1876 # 800170b0 <pq+0x6000>
    80001964:	6187a703          	lw	a4,1560(a5)
    80001968:	377d                	addiw	a4,a4,-1
    8000196a:	60e7ac23          	sw	a4,1560(a5)
  
  while(pq.max_priority != 0 && pq.queue_size[pq.max_priority] == 0){
    8000196e:	61c7a783          	lw	a5,1564(a5)
    80001972:	cfb9                	beqz	a5,800019d0 <dequeue+0x19a>
    80001974:	02079713          	slli	a4,a5,0x20
    80001978:	9301                	srli	a4,a4,0x20
    8000197a:	6689                	lui	a3,0x2
    8000197c:	98368693          	addi	a3,a3,-1661 # 1983 <_entry-0x7fffe67d>
    80001980:	9736                	add	a4,a4,a3
    80001982:	070a                	slli	a4,a4,0x2
    80001984:	0000f697          	auipc	a3,0xf
    80001988:	72c68693          	addi	a3,a3,1836 # 800110b0 <pq>
    8000198c:	9736                	add	a4,a4,a3
    8000198e:	4601                	li	a2,0
    80001990:	4585                	li	a1,1
    80001992:	4314                	lw	a3,0(a4)
    80001994:	e6a9                	bnez	a3,800019de <dequeue+0x1a8>
    pq.max_priority--;
    80001996:	37fd                	addiw	a5,a5,-1
  while(pq.max_priority != 0 && pq.queue_size[pq.max_priority] == 0){
    80001998:	1771                	addi	a4,a4,-4
    8000199a:	862e                	mv	a2,a1
    8000199c:	c795                	beqz	a5,800019c8 <dequeue+0x192>
    pq.max_priority--;
    8000199e:	84be                	mv	s1,a5
    800019a0:	bfcd                	j	80001992 <dequeue+0x15c>
    res = pq.proc_queue[prio][0];
    800019a2:	0000f697          	auipc	a3,0xf
    800019a6:	70e68693          	addi	a3,a3,1806 # 800110b0 <pq>
    800019aa:	02091793          	slli	a5,s2,0x20
    800019ae:	9381                	srli	a5,a5,0x20
    800019b0:	03078713          	addi	a4,a5,48
    800019b4:	0726                	slli	a4,a4,0x9
    800019b6:	9736                	add	a4,a4,a3
    800019b8:	6308                	ld	a0,0(a4)
    pq.proc_queue[prio][0] = 0;
    800019ba:	00073023          	sd	zero,0(a4)
    pq.pos_prio[prio]--;
    800019be:	0009a603          	lw	a2,0(s3)
    800019c2:	367d                	addiw	a2,a2,-1
    pq.queue_size[prio]--;
    800019c4:	4581                	li	a1,0
    800019c6:	bfa5                	j	8000193e <dequeue+0x108>
    800019c8:	00016797          	auipc	a5,0x16
    800019cc:	d007a223          	sw	zero,-764(a5) # 800176cc <pq+0x661c>
  }

  return res;
}
    800019d0:	70a2                	ld	ra,40(sp)
    800019d2:	7402                	ld	s0,32(sp)
    800019d4:	64e2                	ld	s1,24(sp)
    800019d6:	6942                	ld	s2,16(sp)
    800019d8:	69a2                	ld	s3,8(sp)
    800019da:	6145                	addi	sp,sp,48
    800019dc:	8082                	ret
    800019de:	da6d                	beqz	a2,800019d0 <dequeue+0x19a>
    800019e0:	00016797          	auipc	a5,0x16
    800019e4:	ce97a623          	sw	s1,-788(a5) # 800176cc <pq+0x661c>
    800019e8:	b7e5                	j	800019d0 <dequeue+0x19a>

00000000800019ea <enqueue>:

void enqueue(struct proc *pr){
    800019ea:	1141                	addi	sp,sp,-16
    800019ec:	e422                	sd	s0,8(sp)
    800019ee:	0800                	addi	s0,sp,16
  uint prio = pr->priority;
    800019f0:	16852803          	lw	a6,360(a0)

  pq.proc_queue[prio][pq.pos_prio[prio]] = pr;
    800019f4:	0000f617          	auipc	a2,0xf
    800019f8:	6bc60613          	addi	a2,a2,1724 # 800110b0 <pq>
    800019fc:	02081713          	slli	a4,a6,0x20
    80001a00:	9301                	srli	a4,a4,0x20
    80001a02:	6789                	lui	a5,0x2
    80001a04:	98078793          	addi	a5,a5,-1664 # 1980 <_entry-0x7fffe680>
    80001a08:	97ba                	add	a5,a5,a4
    80001a0a:	078a                	slli	a5,a5,0x2
    80001a0c:	97b2                	add	a5,a5,a2
    80001a0e:	4394                	lw	a3,0(a5)
    80001a10:	02069593          	slli	a1,a3,0x20
    80001a14:	9181                	srli	a1,a1,0x20
    80001a16:	071a                	slli	a4,a4,0x6
    80001a18:	972e                	add	a4,a4,a1
    80001a1a:	6585                	lui	a1,0x1
    80001a1c:	c0058593          	addi	a1,a1,-1024 # c00 <_entry-0x7ffff400>
    80001a20:	972e                	add	a4,a4,a1
    80001a22:	070e                	slli	a4,a4,0x3
    80001a24:	963a                	add	a2,a2,a4
    80001a26:	e208                	sd	a0,0(a2)
  
  pq.pos_prio[prio]++;
    80001a28:	2685                	addiw	a3,a3,1
    80001a2a:	c394                	sw	a3,0(a5)
  pq.queue_size[prio]++;
    80001a2c:	47d8                	lw	a4,12(a5)
    80001a2e:	2705                	addiw	a4,a4,1
    80001a30:	c7d8                	sw	a4,12(a5)
  pq.total_size++;
    80001a32:	00015797          	auipc	a5,0x15
    80001a36:	67e78793          	addi	a5,a5,1662 # 800170b0 <pq+0x6000>
    80001a3a:	6187a703          	lw	a4,1560(a5)
    80001a3e:	2705                	addiw	a4,a4,1
    80001a40:	60e7ac23          	sw	a4,1560(a5)

  if(prio > pq.max_priority){
    80001a44:	61c7a783          	lw	a5,1564(a5)
    80001a48:	0107f663          	bgeu	a5,a6,80001a54 <enqueue+0x6a>
    pq.max_priority = prio;
    80001a4c:	00016797          	auipc	a5,0x16
    80001a50:	c907a023          	sw	a6,-896(a5) # 800176cc <pq+0x661c>
  }
}
    80001a54:	6422                	ld	s0,8(sp)
    80001a56:	0141                	addi	sp,sp,16
    80001a58:	8082                	ret

0000000080001a5a <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001a5a:	7139                	addi	sp,sp,-64
    80001a5c:	fc06                	sd	ra,56(sp)
    80001a5e:	f822                	sd	s0,48(sp)
    80001a60:	f426                	sd	s1,40(sp)
    80001a62:	f04a                	sd	s2,32(sp)
    80001a64:	ec4e                	sd	s3,24(sp)
    80001a66:	e852                	sd	s4,16(sp)
    80001a68:	e456                	sd	s5,8(sp)
    80001a6a:	e05a                	sd	s6,0(sp)
    80001a6c:	0080                	addi	s0,sp,64
    80001a6e:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = pq.proc; p < &pq.proc[NPROC]; p++) {
    80001a70:	0000f497          	auipc	s1,0xf
    80001a74:	64048493          	addi	s1,s1,1600 # 800110b0 <pq>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - pq.proc));
    80001a78:	8b26                	mv	s6,s1
    80001a7a:	00006a97          	auipc	s5,0x6
    80001a7e:	586a8a93          	addi	s5,s5,1414 # 80008000 <etext>
    80001a82:	04000937          	lui	s2,0x4000
    80001a86:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001a88:	0932                	slli	s2,s2,0xc
  for(p = pq.proc; p < &pq.proc[NPROC]; p++) {
    80001a8a:	00015a17          	auipc	s4,0x15
    80001a8e:	626a0a13          	addi	s4,s4,1574 # 800170b0 <pq+0x6000>
    char *pa = kalloc();
    80001a92:	fffff097          	auipc	ra,0xfffff
    80001a96:	054080e7          	jalr	84(ra) # 80000ae6 <kalloc>
    80001a9a:	862a                	mv	a2,a0
    if(pa == 0)
    80001a9c:	c131                	beqz	a0,80001ae0 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - pq.proc));
    80001a9e:	416485b3          	sub	a1,s1,s6
    80001aa2:	859d                	srai	a1,a1,0x7
    80001aa4:	000ab783          	ld	a5,0(s5)
    80001aa8:	02f585b3          	mul	a1,a1,a5
    80001aac:	2585                	addiw	a1,a1,1
    80001aae:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001ab2:	4719                	li	a4,6
    80001ab4:	6685                	lui	a3,0x1
    80001ab6:	40b905b3          	sub	a1,s2,a1
    80001aba:	854e                	mv	a0,s3
    80001abc:	fffff097          	auipc	ra,0xfffff
    80001ac0:	682080e7          	jalr	1666(ra) # 8000113e <kvmmap>
  for(p = pq.proc; p < &pq.proc[NPROC]; p++) {
    80001ac4:	18048493          	addi	s1,s1,384
    80001ac8:	fd4495e3          	bne	s1,s4,80001a92 <proc_mapstacks+0x38>
  }
}
    80001acc:	70e2                	ld	ra,56(sp)
    80001ace:	7442                	ld	s0,48(sp)
    80001ad0:	74a2                	ld	s1,40(sp)
    80001ad2:	7902                	ld	s2,32(sp)
    80001ad4:	69e2                	ld	s3,24(sp)
    80001ad6:	6a42                	ld	s4,16(sp)
    80001ad8:	6aa2                	ld	s5,8(sp)
    80001ada:	6b02                	ld	s6,0(sp)
    80001adc:	6121                	addi	sp,sp,64
    80001ade:	8082                	ret
      panic("kalloc");
    80001ae0:	00006517          	auipc	a0,0x6
    80001ae4:	6f850513          	addi	a0,a0,1784 # 800081d8 <digits+0x198>
    80001ae8:	fffff097          	auipc	ra,0xfffff
    80001aec:	a58080e7          	jalr	-1448(ra) # 80000540 <panic>

0000000080001af0 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80001af0:	7139                	addi	sp,sp,-64
    80001af2:	fc06                	sd	ra,56(sp)
    80001af4:	f822                	sd	s0,48(sp)
    80001af6:	f426                	sd	s1,40(sp)
    80001af8:	f04a                	sd	s2,32(sp)
    80001afa:	ec4e                	sd	s3,24(sp)
    80001afc:	e852                	sd	s4,16(sp)
    80001afe:	e456                	sd	s5,8(sp)
    80001b00:	e05a                	sd	s6,0(sp)
    80001b02:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001b04:	00006597          	auipc	a1,0x6
    80001b08:	6dc58593          	addi	a1,a1,1756 # 800081e0 <digits+0x1a0>
    80001b0c:	0000f517          	auipc	a0,0xf
    80001b10:	17450513          	addi	a0,a0,372 # 80010c80 <pid_lock>
    80001b14:	fffff097          	auipc	ra,0xfffff
    80001b18:	032080e7          	jalr	50(ra) # 80000b46 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001b1c:	00006597          	auipc	a1,0x6
    80001b20:	6cc58593          	addi	a1,a1,1740 # 800081e8 <digits+0x1a8>
    80001b24:	0000f517          	auipc	a0,0xf
    80001b28:	17450513          	addi	a0,a0,372 # 80010c98 <wait_lock>
    80001b2c:	fffff097          	auipc	ra,0xfffff
    80001b30:	01a080e7          	jalr	26(ra) # 80000b46 <initlock>
  initlock(&pq.qlock, "pqueue_lock");
    80001b34:	00006597          	auipc	a1,0x6
    80001b38:	6c458593          	addi	a1,a1,1732 # 800081f8 <digits+0x1b8>
    80001b3c:	00016517          	auipc	a0,0x16
    80001b40:	b9450513          	addi	a0,a0,-1132 # 800176d0 <pq+0x6620>
    80001b44:	fffff097          	auipc	ra,0xfffff
    80001b48:	002080e7          	jalr	2(ra) # 80000b46 <initlock>
  for(p = pq.proc; p < &pq.proc[NPROC]; p++) {
    80001b4c:	0000f497          	auipc	s1,0xf
    80001b50:	56448493          	addi	s1,s1,1380 # 800110b0 <pq>
      initlock(&p->lock, "proc");
    80001b54:	00006b17          	auipc	s6,0x6
    80001b58:	6b4b0b13          	addi	s6,s6,1716 # 80008208 <digits+0x1c8>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - pq.proc));
    80001b5c:	8aa6                	mv	s5,s1
    80001b5e:	00006a17          	auipc	s4,0x6
    80001b62:	4a2a0a13          	addi	s4,s4,1186 # 80008000 <etext>
    80001b66:	04000937          	lui	s2,0x4000
    80001b6a:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001b6c:	0932                	slli	s2,s2,0xc
  for(p = pq.proc; p < &pq.proc[NPROC]; p++) {
    80001b6e:	00015997          	auipc	s3,0x15
    80001b72:	54298993          	addi	s3,s3,1346 # 800170b0 <pq+0x6000>
      initlock(&p->lock, "proc");
    80001b76:	85da                	mv	a1,s6
    80001b78:	8526                	mv	a0,s1
    80001b7a:	fffff097          	auipc	ra,0xfffff
    80001b7e:	fcc080e7          	jalr	-52(ra) # 80000b46 <initlock>
      p->state = UNUSED;
    80001b82:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - pq.proc));
    80001b86:	415487b3          	sub	a5,s1,s5
    80001b8a:	879d                	srai	a5,a5,0x7
    80001b8c:	000a3703          	ld	a4,0(s4)
    80001b90:	02e787b3          	mul	a5,a5,a4
    80001b94:	2785                	addiw	a5,a5,1
    80001b96:	00d7979b          	slliw	a5,a5,0xd
    80001b9a:	40f907b3          	sub	a5,s2,a5
    80001b9e:	e0bc                	sd	a5,64(s1)
  for(p = pq.proc; p < &pq.proc[NPROC]; p++) {
    80001ba0:	18048493          	addi	s1,s1,384
    80001ba4:	fd3499e3          	bne	s1,s3,80001b76 <procinit+0x86>
  }
  pq.max_priority = 0;
    80001ba8:	00015497          	auipc	s1,0x15
    80001bac:	50848493          	addi	s1,s1,1288 # 800170b0 <pq+0x6000>
    80001bb0:	6004ae23          	sw	zero,1564(s1)
  memset(pq.pos_prio,0,sizeof(pq.pos_prio));
    80001bb4:	4631                	li	a2,12
    80001bb6:	4581                	li	a1,0
    80001bb8:	00016517          	auipc	a0,0x16
    80001bbc:	af850513          	addi	a0,a0,-1288 # 800176b0 <pq+0x6600>
    80001bc0:	fffff097          	auipc	ra,0xfffff
    80001bc4:	112080e7          	jalr	274(ra) # 80000cd2 <memset>
  memset(pq.queue_size,0,sizeof(pq.queue_size));
    80001bc8:	4631                	li	a2,12
    80001bca:	4581                	li	a1,0
    80001bcc:	00016517          	auipc	a0,0x16
    80001bd0:	af050513          	addi	a0,a0,-1296 # 800176bc <pq+0x660c>
    80001bd4:	fffff097          	auipc	ra,0xfffff
    80001bd8:	0fe080e7          	jalr	254(ra) # 80000cd2 <memset>
  memset(pq.proc_queue,0,sizeof(pq.proc_queue));
    80001bdc:	60000613          	li	a2,1536
    80001be0:	4581                	li	a1,0
    80001be2:	8526                	mv	a0,s1
    80001be4:	fffff097          	auipc	ra,0xfffff
    80001be8:	0ee080e7          	jalr	238(ra) # 80000cd2 <memset>
}
    80001bec:	70e2                	ld	ra,56(sp)
    80001bee:	7442                	ld	s0,48(sp)
    80001bf0:	74a2                	ld	s1,40(sp)
    80001bf2:	7902                	ld	s2,32(sp)
    80001bf4:	69e2                	ld	s3,24(sp)
    80001bf6:	6a42                	ld	s4,16(sp)
    80001bf8:	6aa2                	ld	s5,8(sp)
    80001bfa:	6b02                	ld	s6,0(sp)
    80001bfc:	6121                	addi	sp,sp,64
    80001bfe:	8082                	ret

0000000080001c00 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001c00:	1141                	addi	sp,sp,-16
    80001c02:	e422                	sd	s0,8(sp)
    80001c04:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001c06:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001c08:	2501                	sext.w	a0,a0
    80001c0a:	6422                	ld	s0,8(sp)
    80001c0c:	0141                	addi	sp,sp,16
    80001c0e:	8082                	ret

0000000080001c10 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80001c10:	1141                	addi	sp,sp,-16
    80001c12:	e422                	sd	s0,8(sp)
    80001c14:	0800                	addi	s0,sp,16
    80001c16:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001c18:	2781                	sext.w	a5,a5
    80001c1a:	079e                	slli	a5,a5,0x7
  return c;
}
    80001c1c:	0000f517          	auipc	a0,0xf
    80001c20:	09450513          	addi	a0,a0,148 # 80010cb0 <cpus>
    80001c24:	953e                	add	a0,a0,a5
    80001c26:	6422                	ld	s0,8(sp)
    80001c28:	0141                	addi	sp,sp,16
    80001c2a:	8082                	ret

0000000080001c2c <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80001c2c:	1101                	addi	sp,sp,-32
    80001c2e:	ec06                	sd	ra,24(sp)
    80001c30:	e822                	sd	s0,16(sp)
    80001c32:	e426                	sd	s1,8(sp)
    80001c34:	1000                	addi	s0,sp,32
  push_off();
    80001c36:	fffff097          	auipc	ra,0xfffff
    80001c3a:	f54080e7          	jalr	-172(ra) # 80000b8a <push_off>
    80001c3e:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001c40:	2781                	sext.w	a5,a5
    80001c42:	079e                	slli	a5,a5,0x7
    80001c44:	0000f717          	auipc	a4,0xf
    80001c48:	03c70713          	addi	a4,a4,60 # 80010c80 <pid_lock>
    80001c4c:	97ba                	add	a5,a5,a4
    80001c4e:	7b84                	ld	s1,48(a5)
  pop_off();
    80001c50:	fffff097          	auipc	ra,0xfffff
    80001c54:	fda080e7          	jalr	-38(ra) # 80000c2a <pop_off>
  return p;
}
    80001c58:	8526                	mv	a0,s1
    80001c5a:	60e2                	ld	ra,24(sp)
    80001c5c:	6442                	ld	s0,16(sp)
    80001c5e:	64a2                	ld	s1,8(sp)
    80001c60:	6105                	addi	sp,sp,32
    80001c62:	8082                	ret

0000000080001c64 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001c64:	1141                	addi	sp,sp,-16
    80001c66:	e406                	sd	ra,8(sp)
    80001c68:	e022                	sd	s0,0(sp)
    80001c6a:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001c6c:	00000097          	auipc	ra,0x0
    80001c70:	fc0080e7          	jalr	-64(ra) # 80001c2c <myproc>
    80001c74:	fffff097          	auipc	ra,0xfffff
    80001c78:	016080e7          	jalr	22(ra) # 80000c8a <release>

  if (first) {
    80001c7c:	00007797          	auipc	a5,0x7
    80001c80:	cf47a783          	lw	a5,-780(a5) # 80008970 <first.1>
    80001c84:	eb89                	bnez	a5,80001c96 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001c86:	00001097          	auipc	ra,0x1
    80001c8a:	e44080e7          	jalr	-444(ra) # 80002aca <usertrapret>
}
    80001c8e:	60a2                	ld	ra,8(sp)
    80001c90:	6402                	ld	s0,0(sp)
    80001c92:	0141                	addi	sp,sp,16
    80001c94:	8082                	ret
    first = 0;
    80001c96:	00007797          	auipc	a5,0x7
    80001c9a:	cc07ad23          	sw	zero,-806(a5) # 80008970 <first.1>
    fsinit(ROOTDEV);
    80001c9e:	4505                	li	a0,1
    80001ca0:	00002097          	auipc	ra,0x2
    80001ca4:	bf2080e7          	jalr	-1038(ra) # 80003892 <fsinit>
    80001ca8:	bff9                	j	80001c86 <forkret+0x22>

0000000080001caa <allocpid>:
{
    80001caa:	1101                	addi	sp,sp,-32
    80001cac:	ec06                	sd	ra,24(sp)
    80001cae:	e822                	sd	s0,16(sp)
    80001cb0:	e426                	sd	s1,8(sp)
    80001cb2:	e04a                	sd	s2,0(sp)
    80001cb4:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001cb6:	0000f917          	auipc	s2,0xf
    80001cba:	fca90913          	addi	s2,s2,-54 # 80010c80 <pid_lock>
    80001cbe:	854a                	mv	a0,s2
    80001cc0:	fffff097          	auipc	ra,0xfffff
    80001cc4:	f16080e7          	jalr	-234(ra) # 80000bd6 <acquire>
  pid = nextpid;
    80001cc8:	00007797          	auipc	a5,0x7
    80001ccc:	cac78793          	addi	a5,a5,-852 # 80008974 <nextpid>
    80001cd0:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001cd2:	0014871b          	addiw	a4,s1,1
    80001cd6:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001cd8:	854a                	mv	a0,s2
    80001cda:	fffff097          	auipc	ra,0xfffff
    80001cde:	fb0080e7          	jalr	-80(ra) # 80000c8a <release>
}
    80001ce2:	8526                	mv	a0,s1
    80001ce4:	60e2                	ld	ra,24(sp)
    80001ce6:	6442                	ld	s0,16(sp)
    80001ce8:	64a2                	ld	s1,8(sp)
    80001cea:	6902                	ld	s2,0(sp)
    80001cec:	6105                	addi	sp,sp,32
    80001cee:	8082                	ret

0000000080001cf0 <proc_pagetable>:
{
    80001cf0:	1101                	addi	sp,sp,-32
    80001cf2:	ec06                	sd	ra,24(sp)
    80001cf4:	e822                	sd	s0,16(sp)
    80001cf6:	e426                	sd	s1,8(sp)
    80001cf8:	e04a                	sd	s2,0(sp)
    80001cfa:	1000                	addi	s0,sp,32
    80001cfc:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001cfe:	fffff097          	auipc	ra,0xfffff
    80001d02:	62a080e7          	jalr	1578(ra) # 80001328 <uvmcreate>
    80001d06:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001d08:	c121                	beqz	a0,80001d48 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001d0a:	4729                	li	a4,10
    80001d0c:	00005697          	auipc	a3,0x5
    80001d10:	2f468693          	addi	a3,a3,756 # 80007000 <_trampoline>
    80001d14:	6605                	lui	a2,0x1
    80001d16:	040005b7          	lui	a1,0x4000
    80001d1a:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001d1c:	05b2                	slli	a1,a1,0xc
    80001d1e:	fffff097          	auipc	ra,0xfffff
    80001d22:	380080e7          	jalr	896(ra) # 8000109e <mappages>
    80001d26:	02054863          	bltz	a0,80001d56 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001d2a:	4719                	li	a4,6
    80001d2c:	05893683          	ld	a3,88(s2)
    80001d30:	6605                	lui	a2,0x1
    80001d32:	020005b7          	lui	a1,0x2000
    80001d36:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001d38:	05b6                	slli	a1,a1,0xd
    80001d3a:	8526                	mv	a0,s1
    80001d3c:	fffff097          	auipc	ra,0xfffff
    80001d40:	362080e7          	jalr	866(ra) # 8000109e <mappages>
    80001d44:	02054163          	bltz	a0,80001d66 <proc_pagetable+0x76>
}
    80001d48:	8526                	mv	a0,s1
    80001d4a:	60e2                	ld	ra,24(sp)
    80001d4c:	6442                	ld	s0,16(sp)
    80001d4e:	64a2                	ld	s1,8(sp)
    80001d50:	6902                	ld	s2,0(sp)
    80001d52:	6105                	addi	sp,sp,32
    80001d54:	8082                	ret
    uvmfree(pagetable, 0);
    80001d56:	4581                	li	a1,0
    80001d58:	8526                	mv	a0,s1
    80001d5a:	fffff097          	auipc	ra,0xfffff
    80001d5e:	7d4080e7          	jalr	2004(ra) # 8000152e <uvmfree>
    return 0;
    80001d62:	4481                	li	s1,0
    80001d64:	b7d5                	j	80001d48 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001d66:	4681                	li	a3,0
    80001d68:	4605                	li	a2,1
    80001d6a:	040005b7          	lui	a1,0x4000
    80001d6e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001d70:	05b2                	slli	a1,a1,0xc
    80001d72:	8526                	mv	a0,s1
    80001d74:	fffff097          	auipc	ra,0xfffff
    80001d78:	4f0080e7          	jalr	1264(ra) # 80001264 <uvmunmap>
    uvmfree(pagetable, 0);
    80001d7c:	4581                	li	a1,0
    80001d7e:	8526                	mv	a0,s1
    80001d80:	fffff097          	auipc	ra,0xfffff
    80001d84:	7ae080e7          	jalr	1966(ra) # 8000152e <uvmfree>
    return 0;
    80001d88:	4481                	li	s1,0
    80001d8a:	bf7d                	j	80001d48 <proc_pagetable+0x58>

0000000080001d8c <proc_freepagetable>:
{
    80001d8c:	1101                	addi	sp,sp,-32
    80001d8e:	ec06                	sd	ra,24(sp)
    80001d90:	e822                	sd	s0,16(sp)
    80001d92:	e426                	sd	s1,8(sp)
    80001d94:	e04a                	sd	s2,0(sp)
    80001d96:	1000                	addi	s0,sp,32
    80001d98:	84aa                	mv	s1,a0
    80001d9a:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001d9c:	4681                	li	a3,0
    80001d9e:	4605                	li	a2,1
    80001da0:	040005b7          	lui	a1,0x4000
    80001da4:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001da6:	05b2                	slli	a1,a1,0xc
    80001da8:	fffff097          	auipc	ra,0xfffff
    80001dac:	4bc080e7          	jalr	1212(ra) # 80001264 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001db0:	4681                	li	a3,0
    80001db2:	4605                	li	a2,1
    80001db4:	020005b7          	lui	a1,0x2000
    80001db8:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001dba:	05b6                	slli	a1,a1,0xd
    80001dbc:	8526                	mv	a0,s1
    80001dbe:	fffff097          	auipc	ra,0xfffff
    80001dc2:	4a6080e7          	jalr	1190(ra) # 80001264 <uvmunmap>
  uvmfree(pagetable, sz);
    80001dc6:	85ca                	mv	a1,s2
    80001dc8:	8526                	mv	a0,s1
    80001dca:	fffff097          	auipc	ra,0xfffff
    80001dce:	764080e7          	jalr	1892(ra) # 8000152e <uvmfree>
}
    80001dd2:	60e2                	ld	ra,24(sp)
    80001dd4:	6442                	ld	s0,16(sp)
    80001dd6:	64a2                	ld	s1,8(sp)
    80001dd8:	6902                	ld	s2,0(sp)
    80001dda:	6105                	addi	sp,sp,32
    80001ddc:	8082                	ret

0000000080001dde <freeproc>:
{
    80001dde:	1101                	addi	sp,sp,-32
    80001de0:	ec06                	sd	ra,24(sp)
    80001de2:	e822                	sd	s0,16(sp)
    80001de4:	e426                	sd	s1,8(sp)
    80001de6:	1000                	addi	s0,sp,32
    80001de8:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001dea:	6d28                	ld	a0,88(a0)
    80001dec:	c509                	beqz	a0,80001df6 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001dee:	fffff097          	auipc	ra,0xfffff
    80001df2:	bfa080e7          	jalr	-1030(ra) # 800009e8 <kfree>
  p->trapframe = 0;
    80001df6:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001dfa:	68a8                	ld	a0,80(s1)
    80001dfc:	c511                	beqz	a0,80001e08 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001dfe:	64ac                	ld	a1,72(s1)
    80001e00:	00000097          	auipc	ra,0x0
    80001e04:	f8c080e7          	jalr	-116(ra) # 80001d8c <proc_freepagetable>
  p->pagetable = 0;
    80001e08:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001e0c:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001e10:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001e14:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001e18:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001e1c:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001e20:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001e24:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001e28:	0004ac23          	sw	zero,24(s1)
}
    80001e2c:	60e2                	ld	ra,24(sp)
    80001e2e:	6442                	ld	s0,16(sp)
    80001e30:	64a2                	ld	s1,8(sp)
    80001e32:	6105                	addi	sp,sp,32
    80001e34:	8082                	ret

0000000080001e36 <allocproc>:
{
    80001e36:	1101                	addi	sp,sp,-32
    80001e38:	ec06                	sd	ra,24(sp)
    80001e3a:	e822                	sd	s0,16(sp)
    80001e3c:	e426                	sd	s1,8(sp)
    80001e3e:	e04a                	sd	s2,0(sp)
    80001e40:	1000                	addi	s0,sp,32
  for(p = pq.proc; p < &pq.proc[NPROC]; p++) {
    80001e42:	0000f497          	auipc	s1,0xf
    80001e46:	26e48493          	addi	s1,s1,622 # 800110b0 <pq>
    80001e4a:	00015917          	auipc	s2,0x15
    80001e4e:	26690913          	addi	s2,s2,614 # 800170b0 <pq+0x6000>
    acquire(&p->lock);
    80001e52:	8526                	mv	a0,s1
    80001e54:	fffff097          	auipc	ra,0xfffff
    80001e58:	d82080e7          	jalr	-638(ra) # 80000bd6 <acquire>
    if(p->state == UNUSED) {
    80001e5c:	4c9c                	lw	a5,24(s1)
    80001e5e:	cf81                	beqz	a5,80001e76 <allocproc+0x40>
      release(&p->lock);
    80001e60:	8526                	mv	a0,s1
    80001e62:	fffff097          	auipc	ra,0xfffff
    80001e66:	e28080e7          	jalr	-472(ra) # 80000c8a <release>
  for(p = pq.proc; p < &pq.proc[NPROC]; p++) {
    80001e6a:	18048493          	addi	s1,s1,384
    80001e6e:	ff2492e3          	bne	s1,s2,80001e52 <allocproc+0x1c>
  return 0;
    80001e72:	4481                	li	s1,0
    80001e74:	a085                	j	80001ed4 <allocproc+0x9e>
  p->pid = allocpid();
    80001e76:	00000097          	auipc	ra,0x0
    80001e7a:	e34080e7          	jalr	-460(ra) # 80001caa <allocpid>
    80001e7e:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001e80:	4785                	li	a5,1
    80001e82:	cc9c                	sw	a5,24(s1)
  p->priority = NPRIO-1;
    80001e84:	4789                	li	a5,2
    80001e86:	16f4b423          	sd	a5,360(s1)
  p->contador = 0;
    80001e8a:	1604b823          	sd	zero,368(s1)
  p->lst = 0;
    80001e8e:	1604bc23          	sd	zero,376(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001e92:	fffff097          	auipc	ra,0xfffff
    80001e96:	c54080e7          	jalr	-940(ra) # 80000ae6 <kalloc>
    80001e9a:	892a                	mv	s2,a0
    80001e9c:	eca8                	sd	a0,88(s1)
    80001e9e:	c131                	beqz	a0,80001ee2 <allocproc+0xac>
  p->pagetable = proc_pagetable(p);
    80001ea0:	8526                	mv	a0,s1
    80001ea2:	00000097          	auipc	ra,0x0
    80001ea6:	e4e080e7          	jalr	-434(ra) # 80001cf0 <proc_pagetable>
    80001eaa:	892a                	mv	s2,a0
    80001eac:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001eae:	c531                	beqz	a0,80001efa <allocproc+0xc4>
  memset(&p->context, 0, sizeof(p->context));
    80001eb0:	07000613          	li	a2,112
    80001eb4:	4581                	li	a1,0
    80001eb6:	06048513          	addi	a0,s1,96
    80001eba:	fffff097          	auipc	ra,0xfffff
    80001ebe:	e18080e7          	jalr	-488(ra) # 80000cd2 <memset>
  p->context.ra = (uint64)forkret;
    80001ec2:	00000797          	auipc	a5,0x0
    80001ec6:	da278793          	addi	a5,a5,-606 # 80001c64 <forkret>
    80001eca:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001ecc:	60bc                	ld	a5,64(s1)
    80001ece:	6705                	lui	a4,0x1
    80001ed0:	97ba                	add	a5,a5,a4
    80001ed2:	f4bc                	sd	a5,104(s1)
}
    80001ed4:	8526                	mv	a0,s1
    80001ed6:	60e2                	ld	ra,24(sp)
    80001ed8:	6442                	ld	s0,16(sp)
    80001eda:	64a2                	ld	s1,8(sp)
    80001edc:	6902                	ld	s2,0(sp)
    80001ede:	6105                	addi	sp,sp,32
    80001ee0:	8082                	ret
    freeproc(p);
    80001ee2:	8526                	mv	a0,s1
    80001ee4:	00000097          	auipc	ra,0x0
    80001ee8:	efa080e7          	jalr	-262(ra) # 80001dde <freeproc>
    release(&p->lock);
    80001eec:	8526                	mv	a0,s1
    80001eee:	fffff097          	auipc	ra,0xfffff
    80001ef2:	d9c080e7          	jalr	-612(ra) # 80000c8a <release>
    return 0;
    80001ef6:	84ca                	mv	s1,s2
    80001ef8:	bff1                	j	80001ed4 <allocproc+0x9e>
    freeproc(p);
    80001efa:	8526                	mv	a0,s1
    80001efc:	00000097          	auipc	ra,0x0
    80001f00:	ee2080e7          	jalr	-286(ra) # 80001dde <freeproc>
    release(&p->lock);
    80001f04:	8526                	mv	a0,s1
    80001f06:	fffff097          	auipc	ra,0xfffff
    80001f0a:	d84080e7          	jalr	-636(ra) # 80000c8a <release>
    return 0;
    80001f0e:	84ca                	mv	s1,s2
    80001f10:	b7d1                	j	80001ed4 <allocproc+0x9e>

0000000080001f12 <userinit>:
{
    80001f12:	1101                	addi	sp,sp,-32
    80001f14:	ec06                	sd	ra,24(sp)
    80001f16:	e822                	sd	s0,16(sp)
    80001f18:	e426                	sd	s1,8(sp)
    80001f1a:	1000                	addi	s0,sp,32
  p = allocproc();
    80001f1c:	00000097          	auipc	ra,0x0
    80001f20:	f1a080e7          	jalr	-230(ra) # 80001e36 <allocproc>
    80001f24:	84aa                	mv	s1,a0
  initproc = p;
    80001f26:	00007797          	auipc	a5,0x7
    80001f2a:	aea7b123          	sd	a0,-1310(a5) # 80008a08 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001f2e:	03400613          	li	a2,52
    80001f32:	00007597          	auipc	a1,0x7
    80001f36:	a4e58593          	addi	a1,a1,-1458 # 80008980 <initcode>
    80001f3a:	6928                	ld	a0,80(a0)
    80001f3c:	fffff097          	auipc	ra,0xfffff
    80001f40:	41a080e7          	jalr	1050(ra) # 80001356 <uvmfirst>
  p->sz = PGSIZE;
    80001f44:	6785                	lui	a5,0x1
    80001f46:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001f48:	6cb8                	ld	a4,88(s1)
    80001f4a:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001f4e:	6cb8                	ld	a4,88(s1)
    80001f50:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001f52:	4641                	li	a2,16
    80001f54:	00006597          	auipc	a1,0x6
    80001f58:	2bc58593          	addi	a1,a1,700 # 80008210 <digits+0x1d0>
    80001f5c:	15848513          	addi	a0,s1,344
    80001f60:	fffff097          	auipc	ra,0xfffff
    80001f64:	ebc080e7          	jalr	-324(ra) # 80000e1c <safestrcpy>
  p->cwd = namei("/");
    80001f68:	00006517          	auipc	a0,0x6
    80001f6c:	2b850513          	addi	a0,a0,696 # 80008220 <digits+0x1e0>
    80001f70:	00002097          	auipc	ra,0x2
    80001f74:	34c080e7          	jalr	844(ra) # 800042bc <namei>
    80001f78:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001f7c:	478d                	li	a5,3
    80001f7e:	cc9c                	sw	a5,24(s1)
  acquire(&pq.qlock);
    80001f80:	00015517          	auipc	a0,0x15
    80001f84:	75050513          	addi	a0,a0,1872 # 800176d0 <pq+0x6620>
    80001f88:	fffff097          	auipc	ra,0xfffff
    80001f8c:	c4e080e7          	jalr	-946(ra) # 80000bd6 <acquire>
  enqueue(p);
    80001f90:	8526                	mv	a0,s1
    80001f92:	00000097          	auipc	ra,0x0
    80001f96:	a58080e7          	jalr	-1448(ra) # 800019ea <enqueue>
  release(&pq.qlock);
    80001f9a:	00015517          	auipc	a0,0x15
    80001f9e:	73650513          	addi	a0,a0,1846 # 800176d0 <pq+0x6620>
    80001fa2:	fffff097          	auipc	ra,0xfffff
    80001fa6:	ce8080e7          	jalr	-792(ra) # 80000c8a <release>
  printf("userinit\n");
    80001faa:	00006517          	auipc	a0,0x6
    80001fae:	27e50513          	addi	a0,a0,638 # 80008228 <digits+0x1e8>
    80001fb2:	ffffe097          	auipc	ra,0xffffe
    80001fb6:	5d8080e7          	jalr	1496(ra) # 8000058a <printf>
  release(&p->lock);
    80001fba:	8526                	mv	a0,s1
    80001fbc:	fffff097          	auipc	ra,0xfffff
    80001fc0:	cce080e7          	jalr	-818(ra) # 80000c8a <release>
}
    80001fc4:	60e2                	ld	ra,24(sp)
    80001fc6:	6442                	ld	s0,16(sp)
    80001fc8:	64a2                	ld	s1,8(sp)
    80001fca:	6105                	addi	sp,sp,32
    80001fcc:	8082                	ret

0000000080001fce <growproc>:
{
    80001fce:	1101                	addi	sp,sp,-32
    80001fd0:	ec06                	sd	ra,24(sp)
    80001fd2:	e822                	sd	s0,16(sp)
    80001fd4:	e426                	sd	s1,8(sp)
    80001fd6:	e04a                	sd	s2,0(sp)
    80001fd8:	1000                	addi	s0,sp,32
    80001fda:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001fdc:	00000097          	auipc	ra,0x0
    80001fe0:	c50080e7          	jalr	-944(ra) # 80001c2c <myproc>
    80001fe4:	84aa                	mv	s1,a0
  sz = p->sz;
    80001fe6:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001fe8:	01204c63          	bgtz	s2,80002000 <growproc+0x32>
  } else if(n < 0){
    80001fec:	02094663          	bltz	s2,80002018 <growproc+0x4a>
  p->sz = sz;
    80001ff0:	e4ac                	sd	a1,72(s1)
  return 0;
    80001ff2:	4501                	li	a0,0
}
    80001ff4:	60e2                	ld	ra,24(sp)
    80001ff6:	6442                	ld	s0,16(sp)
    80001ff8:	64a2                	ld	s1,8(sp)
    80001ffa:	6902                	ld	s2,0(sp)
    80001ffc:	6105                	addi	sp,sp,32
    80001ffe:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80002000:	4691                	li	a3,4
    80002002:	00b90633          	add	a2,s2,a1
    80002006:	6928                	ld	a0,80(a0)
    80002008:	fffff097          	auipc	ra,0xfffff
    8000200c:	408080e7          	jalr	1032(ra) # 80001410 <uvmalloc>
    80002010:	85aa                	mv	a1,a0
    80002012:	fd79                	bnez	a0,80001ff0 <growproc+0x22>
      return -1;
    80002014:	557d                	li	a0,-1
    80002016:	bff9                	j	80001ff4 <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80002018:	00b90633          	add	a2,s2,a1
    8000201c:	6928                	ld	a0,80(a0)
    8000201e:	fffff097          	auipc	ra,0xfffff
    80002022:	3aa080e7          	jalr	938(ra) # 800013c8 <uvmdealloc>
    80002026:	85aa                	mv	a1,a0
    80002028:	b7e1                	j	80001ff0 <growproc+0x22>

000000008000202a <fork>:
{
    8000202a:	7139                	addi	sp,sp,-64
    8000202c:	fc06                	sd	ra,56(sp)
    8000202e:	f822                	sd	s0,48(sp)
    80002030:	f426                	sd	s1,40(sp)
    80002032:	f04a                	sd	s2,32(sp)
    80002034:	ec4e                	sd	s3,24(sp)
    80002036:	e852                	sd	s4,16(sp)
    80002038:	e456                	sd	s5,8(sp)
    8000203a:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    8000203c:	00000097          	auipc	ra,0x0
    80002040:	bf0080e7          	jalr	-1040(ra) # 80001c2c <myproc>
    80002044:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80002046:	00000097          	auipc	ra,0x0
    8000204a:	df0080e7          	jalr	-528(ra) # 80001e36 <allocproc>
    8000204e:	16050163          	beqz	a0,800021b0 <fork+0x186>
    80002052:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80002054:	048ab603          	ld	a2,72(s5)
    80002058:	692c                	ld	a1,80(a0)
    8000205a:	050ab503          	ld	a0,80(s5)
    8000205e:	fffff097          	auipc	ra,0xfffff
    80002062:	50a080e7          	jalr	1290(ra) # 80001568 <uvmcopy>
    80002066:	04054863          	bltz	a0,800020b6 <fork+0x8c>
  np->sz = p->sz;
    8000206a:	048ab783          	ld	a5,72(s5)
    8000206e:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80002072:	058ab683          	ld	a3,88(s5)
    80002076:	87b6                	mv	a5,a3
    80002078:	0589b703          	ld	a4,88(s3)
    8000207c:	12068693          	addi	a3,a3,288
    80002080:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80002084:	6788                	ld	a0,8(a5)
    80002086:	6b8c                	ld	a1,16(a5)
    80002088:	6f90                	ld	a2,24(a5)
    8000208a:	01073023          	sd	a6,0(a4)
    8000208e:	e708                	sd	a0,8(a4)
    80002090:	eb0c                	sd	a1,16(a4)
    80002092:	ef10                	sd	a2,24(a4)
    80002094:	02078793          	addi	a5,a5,32
    80002098:	02070713          	addi	a4,a4,32
    8000209c:	fed792e3          	bne	a5,a3,80002080 <fork+0x56>
  np->trapframe->a0 = 0;
    800020a0:	0589b783          	ld	a5,88(s3)
    800020a4:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    800020a8:	0d0a8493          	addi	s1,s5,208
    800020ac:	0d098913          	addi	s2,s3,208
    800020b0:	150a8a13          	addi	s4,s5,336
    800020b4:	a00d                	j	800020d6 <fork+0xac>
    freeproc(np);
    800020b6:	854e                	mv	a0,s3
    800020b8:	00000097          	auipc	ra,0x0
    800020bc:	d26080e7          	jalr	-730(ra) # 80001dde <freeproc>
    release(&np->lock);
    800020c0:	854e                	mv	a0,s3
    800020c2:	fffff097          	auipc	ra,0xfffff
    800020c6:	bc8080e7          	jalr	-1080(ra) # 80000c8a <release>
    return -1;
    800020ca:	597d                	li	s2,-1
    800020cc:	a8c1                	j	8000219c <fork+0x172>
  for(i = 0; i < NOFILE; i++)
    800020ce:	04a1                	addi	s1,s1,8
    800020d0:	0921                	addi	s2,s2,8
    800020d2:	01448b63          	beq	s1,s4,800020e8 <fork+0xbe>
    if(p->ofile[i])
    800020d6:	6088                	ld	a0,0(s1)
    800020d8:	d97d                	beqz	a0,800020ce <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    800020da:	00003097          	auipc	ra,0x3
    800020de:	878080e7          	jalr	-1928(ra) # 80004952 <filedup>
    800020e2:	00a93023          	sd	a0,0(s2)
    800020e6:	b7e5                	j	800020ce <fork+0xa4>
  np->cwd = idup(p->cwd);
    800020e8:	150ab503          	ld	a0,336(s5)
    800020ec:	00002097          	auipc	ra,0x2
    800020f0:	9e6080e7          	jalr	-1562(ra) # 80003ad2 <idup>
    800020f4:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    800020f8:	4641                	li	a2,16
    800020fa:	158a8593          	addi	a1,s5,344
    800020fe:	15898513          	addi	a0,s3,344
    80002102:	fffff097          	auipc	ra,0xfffff
    80002106:	d1a080e7          	jalr	-742(ra) # 80000e1c <safestrcpy>
  pid = np->pid;
    8000210a:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    8000210e:	854e                	mv	a0,s3
    80002110:	fffff097          	auipc	ra,0xfffff
    80002114:	b7a080e7          	jalr	-1158(ra) # 80000c8a <release>
  acquire(&wait_lock);
    80002118:	0000f497          	auipc	s1,0xf
    8000211c:	b8048493          	addi	s1,s1,-1152 # 80010c98 <wait_lock>
    80002120:	8526                	mv	a0,s1
    80002122:	fffff097          	auipc	ra,0xfffff
    80002126:	ab4080e7          	jalr	-1356(ra) # 80000bd6 <acquire>
  np->parent = p;
    8000212a:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    8000212e:	8526                	mv	a0,s1
    80002130:	fffff097          	auipc	ra,0xfffff
    80002134:	b5a080e7          	jalr	-1190(ra) # 80000c8a <release>
  acquire(&np->lock);
    80002138:	854e                	mv	a0,s3
    8000213a:	fffff097          	auipc	ra,0xfffff
    8000213e:	a9c080e7          	jalr	-1380(ra) # 80000bd6 <acquire>
  np->state = RUNNABLE;
    80002142:	478d                	li	a5,3
    80002144:	00f9ac23          	sw	a5,24(s3)
  acquire(&pq.qlock);
    80002148:	00015517          	auipc	a0,0x15
    8000214c:	58850513          	addi	a0,a0,1416 # 800176d0 <pq+0x6620>
    80002150:	fffff097          	auipc	ra,0xfffff
    80002154:	a86080e7          	jalr	-1402(ra) # 80000bd6 <acquire>
  enqueue(np);
    80002158:	854e                	mv	a0,s3
    8000215a:	00000097          	auipc	ra,0x0
    8000215e:	890080e7          	jalr	-1904(ra) # 800019ea <enqueue>
  release(&pq.qlock);
    80002162:	00015517          	auipc	a0,0x15
    80002166:	56e50513          	addi	a0,a0,1390 # 800176d0 <pq+0x6620>
    8000216a:	fffff097          	auipc	ra,0xfffff
    8000216e:	b20080e7          	jalr	-1248(ra) # 80000c8a <release>
  printf("fork pq\n");
    80002172:	00006517          	auipc	a0,0x6
    80002176:	0c650513          	addi	a0,a0,198 # 80008238 <digits+0x1f8>
    8000217a:	ffffe097          	auipc	ra,0xffffe
    8000217e:	410080e7          	jalr	1040(ra) # 8000058a <printf>
  release(&np->lock);
    80002182:	854e                	mv	a0,s3
    80002184:	fffff097          	auipc	ra,0xfffff
    80002188:	b06080e7          	jalr	-1274(ra) # 80000c8a <release>
  printf("fork np\n");
    8000218c:	00006517          	auipc	a0,0x6
    80002190:	0bc50513          	addi	a0,a0,188 # 80008248 <digits+0x208>
    80002194:	ffffe097          	auipc	ra,0xffffe
    80002198:	3f6080e7          	jalr	1014(ra) # 8000058a <printf>
}
    8000219c:	854a                	mv	a0,s2
    8000219e:	70e2                	ld	ra,56(sp)
    800021a0:	7442                	ld	s0,48(sp)
    800021a2:	74a2                	ld	s1,40(sp)
    800021a4:	7902                	ld	s2,32(sp)
    800021a6:	69e2                	ld	s3,24(sp)
    800021a8:	6a42                	ld	s4,16(sp)
    800021aa:	6aa2                	ld	s5,8(sp)
    800021ac:	6121                	addi	sp,sp,64
    800021ae:	8082                	ret
    return -1;
    800021b0:	597d                	li	s2,-1
    800021b2:	b7ed                	j	8000219c <fork+0x172>

00000000800021b4 <scheduler>:
{
    800021b4:	715d                	addi	sp,sp,-80
    800021b6:	e486                	sd	ra,72(sp)
    800021b8:	e0a2                	sd	s0,64(sp)
    800021ba:	fc26                	sd	s1,56(sp)
    800021bc:	f84a                	sd	s2,48(sp)
    800021be:	f44e                	sd	s3,40(sp)
    800021c0:	f052                	sd	s4,32(sp)
    800021c2:	ec56                	sd	s5,24(sp)
    800021c4:	e85a                	sd	s6,16(sp)
    800021c6:	e45e                	sd	s7,8(sp)
    800021c8:	e062                	sd	s8,0(sp)
    800021ca:	0880                	addi	s0,sp,80
    800021cc:	8792                	mv	a5,tp
  int id = r_tp();
    800021ce:	2781                	sext.w	a5,a5
  c->proc = 0;
    800021d0:	00779a13          	slli	s4,a5,0x7
    800021d4:	0000f717          	auipc	a4,0xf
    800021d8:	aac70713          	addi	a4,a4,-1364 # 80010c80 <pid_lock>
    800021dc:	9752                	add	a4,a4,s4
    800021de:	02073823          	sd	zero,48(a4)
      swtch(&c->context, &p->context);
    800021e2:	0000f717          	auipc	a4,0xf
    800021e6:	ad670713          	addi	a4,a4,-1322 # 80010cb8 <cpus+0x8>
    800021ea:	9a3a                	add	s4,s4,a4
    acquire(&pq.qlock);
    800021ec:	00015917          	auipc	s2,0x15
    800021f0:	4e490913          	addi	s2,s2,1252 # 800176d0 <pq+0x6620>
      printf("scheduler pq\n");
    800021f4:	00006c17          	auipc	s8,0x6
    800021f8:	064c0c13          	addi	s8,s8,100 # 80008258 <digits+0x218>
      p->lst = ticks;
    800021fc:	00007b97          	auipc	s7,0x7
    80002200:	814b8b93          	addi	s7,s7,-2028 # 80008a10 <ticks>
      p->state = RUNNING;
    80002204:	4b11                	li	s6,4
      c->proc = p;
    80002206:	079e                	slli	a5,a5,0x7
    80002208:	0000f997          	auipc	s3,0xf
    8000220c:	a7898993          	addi	s3,s3,-1416 # 80010c80 <pid_lock>
    80002210:	99be                	add	s3,s3,a5
      printf("scheduler p\n");
    80002212:	00006a97          	auipc	s5,0x6
    80002216:	056a8a93          	addi	s5,s5,86 # 80008268 <digits+0x228>
    8000221a:	a899                	j	80002270 <scheduler+0xbc>
      release(&pq.qlock);
    8000221c:	854a                	mv	a0,s2
    8000221e:	fffff097          	auipc	ra,0xfffff
    80002222:	a6c080e7          	jalr	-1428(ra) # 80000c8a <release>
      printf("scheduler pq\n");
    80002226:	8562                	mv	a0,s8
    80002228:	ffffe097          	auipc	ra,0xffffe
    8000222c:	362080e7          	jalr	866(ra) # 8000058a <printf>
      p->contador++;
    80002230:	1704b783          	ld	a5,368(s1)
    80002234:	0785                	addi	a5,a5,1
    80002236:	16f4b823          	sd	a5,368(s1)
      p->lst = ticks;
    8000223a:	000be783          	lwu	a5,0(s7)
    8000223e:	16f4bc23          	sd	a5,376(s1)
      p->state = RUNNING;
    80002242:	0164ac23          	sw	s6,24(s1)
      c->proc = p;
    80002246:	0299b823          	sd	s1,48(s3)
      swtch(&c->context, &p->context);
    8000224a:	06048593          	addi	a1,s1,96
    8000224e:	8552                	mv	a0,s4
    80002250:	00000097          	auipc	ra,0x0
    80002254:	7d0080e7          	jalr	2000(ra) # 80002a20 <swtch>
      c->proc = 0;
    80002258:	0209b823          	sd	zero,48(s3)
      release(&p->lock);
    8000225c:	8526                	mv	a0,s1
    8000225e:	fffff097          	auipc	ra,0xfffff
    80002262:	a2c080e7          	jalr	-1492(ra) # 80000c8a <release>
      printf("scheduler p\n");
    80002266:	8556                	mv	a0,s5
    80002268:	ffffe097          	auipc	ra,0xffffe
    8000226c:	322080e7          	jalr	802(ra) # 8000058a <printf>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002270:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002274:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002278:	10079073          	csrw	sstatus,a5
    acquire(&pq.qlock);
    8000227c:	854a                	mv	a0,s2
    8000227e:	fffff097          	auipc	ra,0xfffff
    80002282:	958080e7          	jalr	-1704(ra) # 80000bd6 <acquire>
    if((p = dequeue()) != 0){
    80002286:	fffff097          	auipc	ra,0xfffff
    8000228a:	5b0080e7          	jalr	1456(ra) # 80001836 <dequeue>
    8000228e:	84aa                	mv	s1,a0
    80002290:	f551                	bnez	a0,8000221c <scheduler+0x68>
      release(&pq.qlock);
    80002292:	854a                	mv	a0,s2
    80002294:	fffff097          	auipc	ra,0xfffff
    80002298:	9f6080e7          	jalr	-1546(ra) # 80000c8a <release>
    8000229c:	bfd1                	j	80002270 <scheduler+0xbc>

000000008000229e <sched>:
{
    8000229e:	7179                	addi	sp,sp,-48
    800022a0:	f406                	sd	ra,40(sp)
    800022a2:	f022                	sd	s0,32(sp)
    800022a4:	ec26                	sd	s1,24(sp)
    800022a6:	e84a                	sd	s2,16(sp)
    800022a8:	e44e                	sd	s3,8(sp)
    800022aa:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800022ac:	00000097          	auipc	ra,0x0
    800022b0:	980080e7          	jalr	-1664(ra) # 80001c2c <myproc>
    800022b4:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800022b6:	fffff097          	auipc	ra,0xfffff
    800022ba:	8a6080e7          	jalr	-1882(ra) # 80000b5c <holding>
    800022be:	c93d                	beqz	a0,80002334 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    800022c0:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    800022c2:	2781                	sext.w	a5,a5
    800022c4:	079e                	slli	a5,a5,0x7
    800022c6:	0000f717          	auipc	a4,0xf
    800022ca:	9ba70713          	addi	a4,a4,-1606 # 80010c80 <pid_lock>
    800022ce:	97ba                	add	a5,a5,a4
    800022d0:	0a87a703          	lw	a4,168(a5)
    800022d4:	4785                	li	a5,1
    800022d6:	06f71763          	bne	a4,a5,80002344 <sched+0xa6>
  if(p->state == RUNNING)
    800022da:	4c98                	lw	a4,24(s1)
    800022dc:	4791                	li	a5,4
    800022de:	06f70b63          	beq	a4,a5,80002354 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800022e2:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800022e6:	8b89                	andi	a5,a5,2
  if(intr_get())
    800022e8:	efb5                	bnez	a5,80002364 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    800022ea:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800022ec:	0000f917          	auipc	s2,0xf
    800022f0:	99490913          	addi	s2,s2,-1644 # 80010c80 <pid_lock>
    800022f4:	2781                	sext.w	a5,a5
    800022f6:	079e                	slli	a5,a5,0x7
    800022f8:	97ca                	add	a5,a5,s2
    800022fa:	0ac7a983          	lw	s3,172(a5)
    800022fe:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002300:	2781                	sext.w	a5,a5
    80002302:	079e                	slli	a5,a5,0x7
    80002304:	0000f597          	auipc	a1,0xf
    80002308:	9b458593          	addi	a1,a1,-1612 # 80010cb8 <cpus+0x8>
    8000230c:	95be                	add	a1,a1,a5
    8000230e:	06048513          	addi	a0,s1,96
    80002312:	00000097          	auipc	ra,0x0
    80002316:	70e080e7          	jalr	1806(ra) # 80002a20 <swtch>
    8000231a:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000231c:	2781                	sext.w	a5,a5
    8000231e:	079e                	slli	a5,a5,0x7
    80002320:	993e                	add	s2,s2,a5
    80002322:	0b392623          	sw	s3,172(s2)
}
    80002326:	70a2                	ld	ra,40(sp)
    80002328:	7402                	ld	s0,32(sp)
    8000232a:	64e2                	ld	s1,24(sp)
    8000232c:	6942                	ld	s2,16(sp)
    8000232e:	69a2                	ld	s3,8(sp)
    80002330:	6145                	addi	sp,sp,48
    80002332:	8082                	ret
    panic("sched p->lock");
    80002334:	00006517          	auipc	a0,0x6
    80002338:	f4450513          	addi	a0,a0,-188 # 80008278 <digits+0x238>
    8000233c:	ffffe097          	auipc	ra,0xffffe
    80002340:	204080e7          	jalr	516(ra) # 80000540 <panic>
    panic("sched locks");
    80002344:	00006517          	auipc	a0,0x6
    80002348:	f4450513          	addi	a0,a0,-188 # 80008288 <digits+0x248>
    8000234c:	ffffe097          	auipc	ra,0xffffe
    80002350:	1f4080e7          	jalr	500(ra) # 80000540 <panic>
    panic("sched running");
    80002354:	00006517          	auipc	a0,0x6
    80002358:	f4450513          	addi	a0,a0,-188 # 80008298 <digits+0x258>
    8000235c:	ffffe097          	auipc	ra,0xffffe
    80002360:	1e4080e7          	jalr	484(ra) # 80000540 <panic>
    panic("sched interruptible");
    80002364:	00006517          	auipc	a0,0x6
    80002368:	f4450513          	addi	a0,a0,-188 # 800082a8 <digits+0x268>
    8000236c:	ffffe097          	auipc	ra,0xffffe
    80002370:	1d4080e7          	jalr	468(ra) # 80000540 <panic>

0000000080002374 <yield>:
{
    80002374:	1101                	addi	sp,sp,-32
    80002376:	ec06                	sd	ra,24(sp)
    80002378:	e822                	sd	s0,16(sp)
    8000237a:	e426                	sd	s1,8(sp)
    8000237c:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000237e:	00000097          	auipc	ra,0x0
    80002382:	8ae080e7          	jalr	-1874(ra) # 80001c2c <myproc>
    80002386:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002388:	fffff097          	auipc	ra,0xfffff
    8000238c:	84e080e7          	jalr	-1970(ra) # 80000bd6 <acquire>
  p->state = RUNNABLE;
    80002390:	478d                	li	a5,3
    80002392:	cc9c                	sw	a5,24(s1)
  if (p->priority > 0){
    80002394:	1684b783          	ld	a5,360(s1)
    80002398:	c781                	beqz	a5,800023a0 <yield+0x2c>
    p->priority--;
    8000239a:	17fd                	addi	a5,a5,-1
    8000239c:	16f4b423          	sd	a5,360(s1)
  acquire(&pq.qlock);
    800023a0:	00015517          	auipc	a0,0x15
    800023a4:	33050513          	addi	a0,a0,816 # 800176d0 <pq+0x6620>
    800023a8:	fffff097          	auipc	ra,0xfffff
    800023ac:	82e080e7          	jalr	-2002(ra) # 80000bd6 <acquire>
  enqueue(p);
    800023b0:	8526                	mv	a0,s1
    800023b2:	fffff097          	auipc	ra,0xfffff
    800023b6:	638080e7          	jalr	1592(ra) # 800019ea <enqueue>
  release(&pq.qlock);
    800023ba:	00015517          	auipc	a0,0x15
    800023be:	31650513          	addi	a0,a0,790 # 800176d0 <pq+0x6620>
    800023c2:	fffff097          	auipc	ra,0xfffff
    800023c6:	8c8080e7          	jalr	-1848(ra) # 80000c8a <release>
  printf("yield pq\n");
    800023ca:	00006517          	auipc	a0,0x6
    800023ce:	ef650513          	addi	a0,a0,-266 # 800082c0 <digits+0x280>
    800023d2:	ffffe097          	auipc	ra,0xffffe
    800023d6:	1b8080e7          	jalr	440(ra) # 8000058a <printf>
  sched();
    800023da:	00000097          	auipc	ra,0x0
    800023de:	ec4080e7          	jalr	-316(ra) # 8000229e <sched>
  release(&p->lock);
    800023e2:	8526                	mv	a0,s1
    800023e4:	fffff097          	auipc	ra,0xfffff
    800023e8:	8a6080e7          	jalr	-1882(ra) # 80000c8a <release>
  printf("yield p\n");
    800023ec:	00006517          	auipc	a0,0x6
    800023f0:	ee450513          	addi	a0,a0,-284 # 800082d0 <digits+0x290>
    800023f4:	ffffe097          	auipc	ra,0xffffe
    800023f8:	196080e7          	jalr	406(ra) # 8000058a <printf>
}
    800023fc:	60e2                	ld	ra,24(sp)
    800023fe:	6442                	ld	s0,16(sp)
    80002400:	64a2                	ld	s1,8(sp)
    80002402:	6105                	addi	sp,sp,32
    80002404:	8082                	ret

0000000080002406 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80002406:	7179                	addi	sp,sp,-48
    80002408:	f406                	sd	ra,40(sp)
    8000240a:	f022                	sd	s0,32(sp)
    8000240c:	ec26                	sd	s1,24(sp)
    8000240e:	e84a                	sd	s2,16(sp)
    80002410:	e44e                	sd	s3,8(sp)
    80002412:	1800                	addi	s0,sp,48
    80002414:	89aa                	mv	s3,a0
    80002416:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002418:	00000097          	auipc	ra,0x0
    8000241c:	814080e7          	jalr	-2028(ra) # 80001c2c <myproc>
    80002420:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002422:	ffffe097          	auipc	ra,0xffffe
    80002426:	7b4080e7          	jalr	1972(ra) # 80000bd6 <acquire>
  release(lk);
    8000242a:	854a                	mv	a0,s2
    8000242c:	fffff097          	auipc	ra,0xfffff
    80002430:	85e080e7          	jalr	-1954(ra) # 80000c8a <release>

  if (p->priority < NPRIO-1){
    80002434:	1684b783          	ld	a5,360(s1)
    80002438:	4705                	li	a4,1
    8000243a:	02f77d63          	bgeu	a4,a5,80002474 <sleep+0x6e>
    p->priority++;
  }
  // Go to sleep.
  p->chan = chan;
    8000243e:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002442:	4789                	li	a5,2
    80002444:	cc9c                	sw	a5,24(s1)

  sched();
    80002446:	00000097          	auipc	ra,0x0
    8000244a:	e58080e7          	jalr	-424(ra) # 8000229e <sched>

  // Tidy up.
  p->chan = 0;
    8000244e:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002452:	8526                	mv	a0,s1
    80002454:	fffff097          	auipc	ra,0xfffff
    80002458:	836080e7          	jalr	-1994(ra) # 80000c8a <release>
  acquire(lk);
    8000245c:	854a                	mv	a0,s2
    8000245e:	ffffe097          	auipc	ra,0xffffe
    80002462:	778080e7          	jalr	1912(ra) # 80000bd6 <acquire>
}
    80002466:	70a2                	ld	ra,40(sp)
    80002468:	7402                	ld	s0,32(sp)
    8000246a:	64e2                	ld	s1,24(sp)
    8000246c:	6942                	ld	s2,16(sp)
    8000246e:	69a2                	ld	s3,8(sp)
    80002470:	6145                	addi	sp,sp,48
    80002472:	8082                	ret
    p->priority++;
    80002474:	0785                	addi	a5,a5,1
    80002476:	16f4b423          	sd	a5,360(s1)
    8000247a:	b7d1                	j	8000243e <sleep+0x38>

000000008000247c <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    8000247c:	715d                	addi	sp,sp,-80
    8000247e:	e486                	sd	ra,72(sp)
    80002480:	e0a2                	sd	s0,64(sp)
    80002482:	fc26                	sd	s1,56(sp)
    80002484:	f84a                	sd	s2,48(sp)
    80002486:	f44e                	sd	s3,40(sp)
    80002488:	f052                	sd	s4,32(sp)
    8000248a:	ec56                	sd	s5,24(sp)
    8000248c:	e85a                	sd	s6,16(sp)
    8000248e:	e45e                	sd	s7,8(sp)
    80002490:	0880                	addi	s0,sp,80
    80002492:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = pq.proc; p < &pq.proc[NPROC]; p++) {
    80002494:	0000f497          	auipc	s1,0xf
    80002498:	c1c48493          	addi	s1,s1,-996 # 800110b0 <pq>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    8000249c:	4989                	li	s3,2
        p->state = RUNNABLE;
    8000249e:	4b8d                	li	s7,3
        acquire(&pq.qlock);
    800024a0:	00015a97          	auipc	s5,0x15
    800024a4:	230a8a93          	addi	s5,s5,560 # 800176d0 <pq+0x6620>
        enqueue(p);
        release(&pq.qlock);
        printf("wakeup pq\n");
    800024a8:	00006b17          	auipc	s6,0x6
    800024ac:	e38b0b13          	addi	s6,s6,-456 # 800082e0 <digits+0x2a0>
  for(p = pq.proc; p < &pq.proc[NPROC]; p++) {
    800024b0:	00015917          	auipc	s2,0x15
    800024b4:	c0090913          	addi	s2,s2,-1024 # 800170b0 <pq+0x6000>
    800024b8:	a811                	j	800024cc <wakeup+0x50>
      }
      release(&p->lock);
    800024ba:	8526                	mv	a0,s1
    800024bc:	ffffe097          	auipc	ra,0xffffe
    800024c0:	7ce080e7          	jalr	1998(ra) # 80000c8a <release>
  for(p = pq.proc; p < &pq.proc[NPROC]; p++) {
    800024c4:	18048493          	addi	s1,s1,384
    800024c8:	05248a63          	beq	s1,s2,8000251c <wakeup+0xa0>
    if(p != myproc()){
    800024cc:	fffff097          	auipc	ra,0xfffff
    800024d0:	760080e7          	jalr	1888(ra) # 80001c2c <myproc>
    800024d4:	fea488e3          	beq	s1,a0,800024c4 <wakeup+0x48>
      acquire(&p->lock);
    800024d8:	8526                	mv	a0,s1
    800024da:	ffffe097          	auipc	ra,0xffffe
    800024de:	6fc080e7          	jalr	1788(ra) # 80000bd6 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800024e2:	4c9c                	lw	a5,24(s1)
    800024e4:	fd379be3          	bne	a5,s3,800024ba <wakeup+0x3e>
    800024e8:	709c                	ld	a5,32(s1)
    800024ea:	fd4798e3          	bne	a5,s4,800024ba <wakeup+0x3e>
        p->state = RUNNABLE;
    800024ee:	0174ac23          	sw	s7,24(s1)
        acquire(&pq.qlock);
    800024f2:	8556                	mv	a0,s5
    800024f4:	ffffe097          	auipc	ra,0xffffe
    800024f8:	6e2080e7          	jalr	1762(ra) # 80000bd6 <acquire>
        enqueue(p);
    800024fc:	8526                	mv	a0,s1
    800024fe:	fffff097          	auipc	ra,0xfffff
    80002502:	4ec080e7          	jalr	1260(ra) # 800019ea <enqueue>
        release(&pq.qlock);
    80002506:	8556                	mv	a0,s5
    80002508:	ffffe097          	auipc	ra,0xffffe
    8000250c:	782080e7          	jalr	1922(ra) # 80000c8a <release>
        printf("wakeup pq\n");
    80002510:	855a                	mv	a0,s6
    80002512:	ffffe097          	auipc	ra,0xffffe
    80002516:	078080e7          	jalr	120(ra) # 8000058a <printf>
    8000251a:	b745                	j	800024ba <wakeup+0x3e>
    }
  }
}
    8000251c:	60a6                	ld	ra,72(sp)
    8000251e:	6406                	ld	s0,64(sp)
    80002520:	74e2                	ld	s1,56(sp)
    80002522:	7942                	ld	s2,48(sp)
    80002524:	79a2                	ld	s3,40(sp)
    80002526:	7a02                	ld	s4,32(sp)
    80002528:	6ae2                	ld	s5,24(sp)
    8000252a:	6b42                	ld	s6,16(sp)
    8000252c:	6ba2                	ld	s7,8(sp)
    8000252e:	6161                	addi	sp,sp,80
    80002530:	8082                	ret

0000000080002532 <reparent>:
{
    80002532:	7179                	addi	sp,sp,-48
    80002534:	f406                	sd	ra,40(sp)
    80002536:	f022                	sd	s0,32(sp)
    80002538:	ec26                	sd	s1,24(sp)
    8000253a:	e84a                	sd	s2,16(sp)
    8000253c:	e44e                	sd	s3,8(sp)
    8000253e:	e052                	sd	s4,0(sp)
    80002540:	1800                	addi	s0,sp,48
    80002542:	892a                	mv	s2,a0
  for(pp = pq.proc; pp < &pq.proc[NPROC]; pp++){
    80002544:	0000f497          	auipc	s1,0xf
    80002548:	b6c48493          	addi	s1,s1,-1172 # 800110b0 <pq>
      pp->parent = initproc;
    8000254c:	00006a17          	auipc	s4,0x6
    80002550:	4bca0a13          	addi	s4,s4,1212 # 80008a08 <initproc>
  for(pp = pq.proc; pp < &pq.proc[NPROC]; pp++){
    80002554:	00015997          	auipc	s3,0x15
    80002558:	b5c98993          	addi	s3,s3,-1188 # 800170b0 <pq+0x6000>
    8000255c:	a029                	j	80002566 <reparent+0x34>
    8000255e:	18048493          	addi	s1,s1,384
    80002562:	01348d63          	beq	s1,s3,8000257c <reparent+0x4a>
    if(pp->parent == p){
    80002566:	7c9c                	ld	a5,56(s1)
    80002568:	ff279be3          	bne	a5,s2,8000255e <reparent+0x2c>
      pp->parent = initproc;
    8000256c:	000a3503          	ld	a0,0(s4)
    80002570:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002572:	00000097          	auipc	ra,0x0
    80002576:	f0a080e7          	jalr	-246(ra) # 8000247c <wakeup>
    8000257a:	b7d5                	j	8000255e <reparent+0x2c>
}
    8000257c:	70a2                	ld	ra,40(sp)
    8000257e:	7402                	ld	s0,32(sp)
    80002580:	64e2                	ld	s1,24(sp)
    80002582:	6942                	ld	s2,16(sp)
    80002584:	69a2                	ld	s3,8(sp)
    80002586:	6a02                	ld	s4,0(sp)
    80002588:	6145                	addi	sp,sp,48
    8000258a:	8082                	ret

000000008000258c <exit>:
{
    8000258c:	7179                	addi	sp,sp,-48
    8000258e:	f406                	sd	ra,40(sp)
    80002590:	f022                	sd	s0,32(sp)
    80002592:	ec26                	sd	s1,24(sp)
    80002594:	e84a                	sd	s2,16(sp)
    80002596:	e44e                	sd	s3,8(sp)
    80002598:	e052                	sd	s4,0(sp)
    8000259a:	1800                	addi	s0,sp,48
    8000259c:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000259e:	fffff097          	auipc	ra,0xfffff
    800025a2:	68e080e7          	jalr	1678(ra) # 80001c2c <myproc>
    800025a6:	89aa                	mv	s3,a0
  if(p == initproc)
    800025a8:	00006797          	auipc	a5,0x6
    800025ac:	4607b783          	ld	a5,1120(a5) # 80008a08 <initproc>
    800025b0:	0d050493          	addi	s1,a0,208
    800025b4:	15050913          	addi	s2,a0,336
    800025b8:	02a79363          	bne	a5,a0,800025de <exit+0x52>
    panic("init exiting");
    800025bc:	00006517          	auipc	a0,0x6
    800025c0:	d3450513          	addi	a0,a0,-716 # 800082f0 <digits+0x2b0>
    800025c4:	ffffe097          	auipc	ra,0xffffe
    800025c8:	f7c080e7          	jalr	-132(ra) # 80000540 <panic>
      fileclose(f);
    800025cc:	00002097          	auipc	ra,0x2
    800025d0:	3d8080e7          	jalr	984(ra) # 800049a4 <fileclose>
      p->ofile[fd] = 0;
    800025d4:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800025d8:	04a1                	addi	s1,s1,8
    800025da:	01248563          	beq	s1,s2,800025e4 <exit+0x58>
    if(p->ofile[fd]){
    800025de:	6088                	ld	a0,0(s1)
    800025e0:	f575                	bnez	a0,800025cc <exit+0x40>
    800025e2:	bfdd                	j	800025d8 <exit+0x4c>
  begin_op();
    800025e4:	00002097          	auipc	ra,0x2
    800025e8:	ef8080e7          	jalr	-264(ra) # 800044dc <begin_op>
  iput(p->cwd);
    800025ec:	1509b503          	ld	a0,336(s3)
    800025f0:	00001097          	auipc	ra,0x1
    800025f4:	6da080e7          	jalr	1754(ra) # 80003cca <iput>
  end_op();
    800025f8:	00002097          	auipc	ra,0x2
    800025fc:	f62080e7          	jalr	-158(ra) # 8000455a <end_op>
  p->cwd = 0;
    80002600:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002604:	0000e497          	auipc	s1,0xe
    80002608:	69448493          	addi	s1,s1,1684 # 80010c98 <wait_lock>
    8000260c:	8526                	mv	a0,s1
    8000260e:	ffffe097          	auipc	ra,0xffffe
    80002612:	5c8080e7          	jalr	1480(ra) # 80000bd6 <acquire>
  reparent(p);
    80002616:	854e                	mv	a0,s3
    80002618:	00000097          	auipc	ra,0x0
    8000261c:	f1a080e7          	jalr	-230(ra) # 80002532 <reparent>
  wakeup(p->parent);
    80002620:	0389b503          	ld	a0,56(s3)
    80002624:	00000097          	auipc	ra,0x0
    80002628:	e58080e7          	jalr	-424(ra) # 8000247c <wakeup>
  acquire(&p->lock);
    8000262c:	854e                	mv	a0,s3
    8000262e:	ffffe097          	auipc	ra,0xffffe
    80002632:	5a8080e7          	jalr	1448(ra) # 80000bd6 <acquire>
  p->xstate = status;
    80002636:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000263a:	4795                	li	a5,5
    8000263c:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002640:	8526                	mv	a0,s1
    80002642:	ffffe097          	auipc	ra,0xffffe
    80002646:	648080e7          	jalr	1608(ra) # 80000c8a <release>
  sched();
    8000264a:	00000097          	auipc	ra,0x0
    8000264e:	c54080e7          	jalr	-940(ra) # 8000229e <sched>
  panic("zombie exit");
    80002652:	00006517          	auipc	a0,0x6
    80002656:	cae50513          	addi	a0,a0,-850 # 80008300 <digits+0x2c0>
    8000265a:	ffffe097          	auipc	ra,0xffffe
    8000265e:	ee6080e7          	jalr	-282(ra) # 80000540 <panic>

0000000080002662 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002662:	7179                	addi	sp,sp,-48
    80002664:	f406                	sd	ra,40(sp)
    80002666:	f022                	sd	s0,32(sp)
    80002668:	ec26                	sd	s1,24(sp)
    8000266a:	e84a                	sd	s2,16(sp)
    8000266c:	e44e                	sd	s3,8(sp)
    8000266e:	e052                	sd	s4,0(sp)
    80002670:	1800                	addi	s0,sp,48
    80002672:	892a                	mv	s2,a0
  struct proc *p;

  for(p = pq.proc; p < &pq.proc[NPROC]; p++){
    80002674:	0000f497          	auipc	s1,0xf
    80002678:	a3c48493          	addi	s1,s1,-1476 # 800110b0 <pq>
      release(&p->lock);
      printf("kill p1\n");
      return 0;
    }
    release(&p->lock);
    printf("kill p2\n");
    8000267c:	00006a17          	auipc	s4,0x6
    80002680:	cb4a0a13          	addi	s4,s4,-844 # 80008330 <digits+0x2f0>
  for(p = pq.proc; p < &pq.proc[NPROC]; p++){
    80002684:	00015997          	auipc	s3,0x15
    80002688:	a2c98993          	addi	s3,s3,-1492 # 800170b0 <pq+0x6000>
    acquire(&p->lock);
    8000268c:	8526                	mv	a0,s1
    8000268e:	ffffe097          	auipc	ra,0xffffe
    80002692:	548080e7          	jalr	1352(ra) # 80000bd6 <acquire>
    if(p->pid == pid){
    80002696:	589c                	lw	a5,48(s1)
    80002698:	03278263          	beq	a5,s2,800026bc <kill+0x5a>
    release(&p->lock);
    8000269c:	8526                	mv	a0,s1
    8000269e:	ffffe097          	auipc	ra,0xffffe
    800026a2:	5ec080e7          	jalr	1516(ra) # 80000c8a <release>
    printf("kill p2\n");
    800026a6:	8552                	mv	a0,s4
    800026a8:	ffffe097          	auipc	ra,0xffffe
    800026ac:	ee2080e7          	jalr	-286(ra) # 8000058a <printf>
  for(p = pq.proc; p < &pq.proc[NPROC]; p++){
    800026b0:	18048493          	addi	s1,s1,384
    800026b4:	fd349ce3          	bne	s1,s3,8000268c <kill+0x2a>
  }
  return -1;
    800026b8:	557d                	li	a0,-1
    800026ba:	a02d                	j	800026e4 <kill+0x82>
      p->killed = 1;
    800026bc:	4785                	li	a5,1
    800026be:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800026c0:	4c98                	lw	a4,24(s1)
    800026c2:	4789                	li	a5,2
    800026c4:	02f70863          	beq	a4,a5,800026f4 <kill+0x92>
      release(&p->lock);
    800026c8:	8526                	mv	a0,s1
    800026ca:	ffffe097          	auipc	ra,0xffffe
    800026ce:	5c0080e7          	jalr	1472(ra) # 80000c8a <release>
      printf("kill p1\n");
    800026d2:	00006517          	auipc	a0,0x6
    800026d6:	c4e50513          	addi	a0,a0,-946 # 80008320 <digits+0x2e0>
    800026da:	ffffe097          	auipc	ra,0xffffe
    800026de:	eb0080e7          	jalr	-336(ra) # 8000058a <printf>
      return 0;
    800026e2:	4501                	li	a0,0
}
    800026e4:	70a2                	ld	ra,40(sp)
    800026e6:	7402                	ld	s0,32(sp)
    800026e8:	64e2                	ld	s1,24(sp)
    800026ea:	6942                	ld	s2,16(sp)
    800026ec:	69a2                	ld	s3,8(sp)
    800026ee:	6a02                	ld	s4,0(sp)
    800026f0:	6145                	addi	sp,sp,48
    800026f2:	8082                	ret
        p->state = RUNNABLE;
    800026f4:	478d                	li	a5,3
    800026f6:	cc9c                	sw	a5,24(s1)
        acquire(&pq.qlock);
    800026f8:	00015517          	auipc	a0,0x15
    800026fc:	fd850513          	addi	a0,a0,-40 # 800176d0 <pq+0x6620>
    80002700:	ffffe097          	auipc	ra,0xffffe
    80002704:	4d6080e7          	jalr	1238(ra) # 80000bd6 <acquire>
        enqueue(p);
    80002708:	8526                	mv	a0,s1
    8000270a:	fffff097          	auipc	ra,0xfffff
    8000270e:	2e0080e7          	jalr	736(ra) # 800019ea <enqueue>
        release(&pq.qlock);
    80002712:	00015517          	auipc	a0,0x15
    80002716:	fbe50513          	addi	a0,a0,-66 # 800176d0 <pq+0x6620>
    8000271a:	ffffe097          	auipc	ra,0xffffe
    8000271e:	570080e7          	jalr	1392(ra) # 80000c8a <release>
        printf("kill pq\n");
    80002722:	00006517          	auipc	a0,0x6
    80002726:	bee50513          	addi	a0,a0,-1042 # 80008310 <digits+0x2d0>
    8000272a:	ffffe097          	auipc	ra,0xffffe
    8000272e:	e60080e7          	jalr	-416(ra) # 8000058a <printf>
    80002732:	bf59                	j	800026c8 <kill+0x66>

0000000080002734 <setkilled>:

void
setkilled(struct proc *p)
{
    80002734:	1101                	addi	sp,sp,-32
    80002736:	ec06                	sd	ra,24(sp)
    80002738:	e822                	sd	s0,16(sp)
    8000273a:	e426                	sd	s1,8(sp)
    8000273c:	1000                	addi	s0,sp,32
    8000273e:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002740:	ffffe097          	auipc	ra,0xffffe
    80002744:	496080e7          	jalr	1174(ra) # 80000bd6 <acquire>
  p->killed = 1;
    80002748:	4785                	li	a5,1
    8000274a:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000274c:	8526                	mv	a0,s1
    8000274e:	ffffe097          	auipc	ra,0xffffe
    80002752:	53c080e7          	jalr	1340(ra) # 80000c8a <release>
}
    80002756:	60e2                	ld	ra,24(sp)
    80002758:	6442                	ld	s0,16(sp)
    8000275a:	64a2                	ld	s1,8(sp)
    8000275c:	6105                	addi	sp,sp,32
    8000275e:	8082                	ret

0000000080002760 <killed>:

int
killed(struct proc *p)
{
    80002760:	1101                	addi	sp,sp,-32
    80002762:	ec06                	sd	ra,24(sp)
    80002764:	e822                	sd	s0,16(sp)
    80002766:	e426                	sd	s1,8(sp)
    80002768:	e04a                	sd	s2,0(sp)
    8000276a:	1000                	addi	s0,sp,32
    8000276c:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    8000276e:	ffffe097          	auipc	ra,0xffffe
    80002772:	468080e7          	jalr	1128(ra) # 80000bd6 <acquire>
  k = p->killed;
    80002776:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    8000277a:	8526                	mv	a0,s1
    8000277c:	ffffe097          	auipc	ra,0xffffe
    80002780:	50e080e7          	jalr	1294(ra) # 80000c8a <release>
  return k;
}
    80002784:	854a                	mv	a0,s2
    80002786:	60e2                	ld	ra,24(sp)
    80002788:	6442                	ld	s0,16(sp)
    8000278a:	64a2                	ld	s1,8(sp)
    8000278c:	6902                	ld	s2,0(sp)
    8000278e:	6105                	addi	sp,sp,32
    80002790:	8082                	ret

0000000080002792 <wait>:
{
    80002792:	715d                	addi	sp,sp,-80
    80002794:	e486                	sd	ra,72(sp)
    80002796:	e0a2                	sd	s0,64(sp)
    80002798:	fc26                	sd	s1,56(sp)
    8000279a:	f84a                	sd	s2,48(sp)
    8000279c:	f44e                	sd	s3,40(sp)
    8000279e:	f052                	sd	s4,32(sp)
    800027a0:	ec56                	sd	s5,24(sp)
    800027a2:	e85a                	sd	s6,16(sp)
    800027a4:	e45e                	sd	s7,8(sp)
    800027a6:	e062                	sd	s8,0(sp)
    800027a8:	0880                	addi	s0,sp,80
    800027aa:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800027ac:	fffff097          	auipc	ra,0xfffff
    800027b0:	480080e7          	jalr	1152(ra) # 80001c2c <myproc>
    800027b4:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800027b6:	0000e517          	auipc	a0,0xe
    800027ba:	4e250513          	addi	a0,a0,1250 # 80010c98 <wait_lock>
    800027be:	ffffe097          	auipc	ra,0xffffe
    800027c2:	418080e7          	jalr	1048(ra) # 80000bd6 <acquire>
    havekids = 0;
    800027c6:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    800027c8:	4a15                	li	s4,5
        havekids = 1;
    800027ca:	4a85                	li	s5,1
    for(pp = pq.proc; pp < &pq.proc[NPROC]; pp++){
    800027cc:	00015997          	auipc	s3,0x15
    800027d0:	8e498993          	addi	s3,s3,-1820 # 800170b0 <pq+0x6000>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800027d4:	0000ec17          	auipc	s8,0xe
    800027d8:	4c4c0c13          	addi	s8,s8,1220 # 80010c98 <wait_lock>
    havekids = 0;
    800027dc:	875e                	mv	a4,s7
    for(pp = pq.proc; pp < &pq.proc[NPROC]; pp++){
    800027de:	0000f497          	auipc	s1,0xf
    800027e2:	8d248493          	addi	s1,s1,-1838 # 800110b0 <pq>
    800027e6:	a0bd                	j	80002854 <wait+0xc2>
          pid = pp->pid;
    800027e8:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800027ec:	000b0e63          	beqz	s6,80002808 <wait+0x76>
    800027f0:	4691                	li	a3,4
    800027f2:	02c48613          	addi	a2,s1,44
    800027f6:	85da                	mv	a1,s6
    800027f8:	05093503          	ld	a0,80(s2)
    800027fc:	fffff097          	auipc	ra,0xfffff
    80002800:	e70080e7          	jalr	-400(ra) # 8000166c <copyout>
    80002804:	02054563          	bltz	a0,8000282e <wait+0x9c>
          freeproc(pp);
    80002808:	8526                	mv	a0,s1
    8000280a:	fffff097          	auipc	ra,0xfffff
    8000280e:	5d4080e7          	jalr	1492(ra) # 80001dde <freeproc>
          release(&pp->lock);
    80002812:	8526                	mv	a0,s1
    80002814:	ffffe097          	auipc	ra,0xffffe
    80002818:	476080e7          	jalr	1142(ra) # 80000c8a <release>
          release(&wait_lock);
    8000281c:	0000e517          	auipc	a0,0xe
    80002820:	47c50513          	addi	a0,a0,1148 # 80010c98 <wait_lock>
    80002824:	ffffe097          	auipc	ra,0xffffe
    80002828:	466080e7          	jalr	1126(ra) # 80000c8a <release>
          return pid;
    8000282c:	a0b5                	j	80002898 <wait+0x106>
            release(&pp->lock);
    8000282e:	8526                	mv	a0,s1
    80002830:	ffffe097          	auipc	ra,0xffffe
    80002834:	45a080e7          	jalr	1114(ra) # 80000c8a <release>
            release(&wait_lock);
    80002838:	0000e517          	auipc	a0,0xe
    8000283c:	46050513          	addi	a0,a0,1120 # 80010c98 <wait_lock>
    80002840:	ffffe097          	auipc	ra,0xffffe
    80002844:	44a080e7          	jalr	1098(ra) # 80000c8a <release>
            return -1;
    80002848:	59fd                	li	s3,-1
    8000284a:	a0b9                	j	80002898 <wait+0x106>
    for(pp = pq.proc; pp < &pq.proc[NPROC]; pp++){
    8000284c:	18048493          	addi	s1,s1,384
    80002850:	03348463          	beq	s1,s3,80002878 <wait+0xe6>
      if(pp->parent == p){
    80002854:	7c9c                	ld	a5,56(s1)
    80002856:	ff279be3          	bne	a5,s2,8000284c <wait+0xba>
        acquire(&pp->lock);
    8000285a:	8526                	mv	a0,s1
    8000285c:	ffffe097          	auipc	ra,0xffffe
    80002860:	37a080e7          	jalr	890(ra) # 80000bd6 <acquire>
        if(pp->state == ZOMBIE){
    80002864:	4c9c                	lw	a5,24(s1)
    80002866:	f94781e3          	beq	a5,s4,800027e8 <wait+0x56>
        release(&pp->lock);
    8000286a:	8526                	mv	a0,s1
    8000286c:	ffffe097          	auipc	ra,0xffffe
    80002870:	41e080e7          	jalr	1054(ra) # 80000c8a <release>
        havekids = 1;
    80002874:	8756                	mv	a4,s5
    80002876:	bfd9                	j	8000284c <wait+0xba>
    if(!havekids || killed(p)){
    80002878:	c719                	beqz	a4,80002886 <wait+0xf4>
    8000287a:	854a                	mv	a0,s2
    8000287c:	00000097          	auipc	ra,0x0
    80002880:	ee4080e7          	jalr	-284(ra) # 80002760 <killed>
    80002884:	c51d                	beqz	a0,800028b2 <wait+0x120>
      release(&wait_lock);
    80002886:	0000e517          	auipc	a0,0xe
    8000288a:	41250513          	addi	a0,a0,1042 # 80010c98 <wait_lock>
    8000288e:	ffffe097          	auipc	ra,0xffffe
    80002892:	3fc080e7          	jalr	1020(ra) # 80000c8a <release>
      return -1;
    80002896:	59fd                	li	s3,-1
}
    80002898:	854e                	mv	a0,s3
    8000289a:	60a6                	ld	ra,72(sp)
    8000289c:	6406                	ld	s0,64(sp)
    8000289e:	74e2                	ld	s1,56(sp)
    800028a0:	7942                	ld	s2,48(sp)
    800028a2:	79a2                	ld	s3,40(sp)
    800028a4:	7a02                	ld	s4,32(sp)
    800028a6:	6ae2                	ld	s5,24(sp)
    800028a8:	6b42                	ld	s6,16(sp)
    800028aa:	6ba2                	ld	s7,8(sp)
    800028ac:	6c02                	ld	s8,0(sp)
    800028ae:	6161                	addi	sp,sp,80
    800028b0:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800028b2:	85e2                	mv	a1,s8
    800028b4:	854a                	mv	a0,s2
    800028b6:	00000097          	auipc	ra,0x0
    800028ba:	b50080e7          	jalr	-1200(ra) # 80002406 <sleep>
    havekids = 0;
    800028be:	bf39                	j	800027dc <wait+0x4a>

00000000800028c0 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800028c0:	7179                	addi	sp,sp,-48
    800028c2:	f406                	sd	ra,40(sp)
    800028c4:	f022                	sd	s0,32(sp)
    800028c6:	ec26                	sd	s1,24(sp)
    800028c8:	e84a                	sd	s2,16(sp)
    800028ca:	e44e                	sd	s3,8(sp)
    800028cc:	e052                	sd	s4,0(sp)
    800028ce:	1800                	addi	s0,sp,48
    800028d0:	84aa                	mv	s1,a0
    800028d2:	892e                	mv	s2,a1
    800028d4:	89b2                	mv	s3,a2
    800028d6:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800028d8:	fffff097          	auipc	ra,0xfffff
    800028dc:	354080e7          	jalr	852(ra) # 80001c2c <myproc>
  if(user_dst){
    800028e0:	c08d                	beqz	s1,80002902 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800028e2:	86d2                	mv	a3,s4
    800028e4:	864e                	mv	a2,s3
    800028e6:	85ca                	mv	a1,s2
    800028e8:	6928                	ld	a0,80(a0)
    800028ea:	fffff097          	auipc	ra,0xfffff
    800028ee:	d82080e7          	jalr	-638(ra) # 8000166c <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800028f2:	70a2                	ld	ra,40(sp)
    800028f4:	7402                	ld	s0,32(sp)
    800028f6:	64e2                	ld	s1,24(sp)
    800028f8:	6942                	ld	s2,16(sp)
    800028fa:	69a2                	ld	s3,8(sp)
    800028fc:	6a02                	ld	s4,0(sp)
    800028fe:	6145                	addi	sp,sp,48
    80002900:	8082                	ret
    memmove((char *)dst, src, len);
    80002902:	000a061b          	sext.w	a2,s4
    80002906:	85ce                	mv	a1,s3
    80002908:	854a                	mv	a0,s2
    8000290a:	ffffe097          	auipc	ra,0xffffe
    8000290e:	424080e7          	jalr	1060(ra) # 80000d2e <memmove>
    return 0;
    80002912:	8526                	mv	a0,s1
    80002914:	bff9                	j	800028f2 <either_copyout+0x32>

0000000080002916 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002916:	7179                	addi	sp,sp,-48
    80002918:	f406                	sd	ra,40(sp)
    8000291a:	f022                	sd	s0,32(sp)
    8000291c:	ec26                	sd	s1,24(sp)
    8000291e:	e84a                	sd	s2,16(sp)
    80002920:	e44e                	sd	s3,8(sp)
    80002922:	e052                	sd	s4,0(sp)
    80002924:	1800                	addi	s0,sp,48
    80002926:	892a                	mv	s2,a0
    80002928:	84ae                	mv	s1,a1
    8000292a:	89b2                	mv	s3,a2
    8000292c:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000292e:	fffff097          	auipc	ra,0xfffff
    80002932:	2fe080e7          	jalr	766(ra) # 80001c2c <myproc>
  if(user_src){
    80002936:	c08d                	beqz	s1,80002958 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002938:	86d2                	mv	a3,s4
    8000293a:	864e                	mv	a2,s3
    8000293c:	85ca                	mv	a1,s2
    8000293e:	6928                	ld	a0,80(a0)
    80002940:	fffff097          	auipc	ra,0xfffff
    80002944:	db8080e7          	jalr	-584(ra) # 800016f8 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002948:	70a2                	ld	ra,40(sp)
    8000294a:	7402                	ld	s0,32(sp)
    8000294c:	64e2                	ld	s1,24(sp)
    8000294e:	6942                	ld	s2,16(sp)
    80002950:	69a2                	ld	s3,8(sp)
    80002952:	6a02                	ld	s4,0(sp)
    80002954:	6145                	addi	sp,sp,48
    80002956:	8082                	ret
    memmove(dst, (char*)src, len);
    80002958:	000a061b          	sext.w	a2,s4
    8000295c:	85ce                	mv	a1,s3
    8000295e:	854a                	mv	a0,s2
    80002960:	ffffe097          	auipc	ra,0xffffe
    80002964:	3ce080e7          	jalr	974(ra) # 80000d2e <memmove>
    return 0;
    80002968:	8526                	mv	a0,s1
    8000296a:	bff9                	j	80002948 <either_copyin+0x32>

000000008000296c <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000296c:	715d                	addi	sp,sp,-80
    8000296e:	e486                	sd	ra,72(sp)
    80002970:	e0a2                	sd	s0,64(sp)
    80002972:	fc26                	sd	s1,56(sp)
    80002974:	f84a                	sd	s2,48(sp)
    80002976:	f44e                	sd	s3,40(sp)
    80002978:	f052                	sd	s4,32(sp)
    8000297a:	ec56                	sd	s5,24(sp)
    8000297c:	e85a                	sd	s6,16(sp)
    8000297e:	e45e                	sd	s7,8(sp)
    80002980:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002982:	00006517          	auipc	a0,0x6
    80002986:	c7e50513          	addi	a0,a0,-898 # 80008600 <syscalls+0xf0>
    8000298a:	ffffe097          	auipc	ra,0xffffe
    8000298e:	c00080e7          	jalr	-1024(ra) # 8000058a <printf>
  for(p = pq.proc; p < &pq.proc[NPROC]; p++){
    80002992:	0000f497          	auipc	s1,0xf
    80002996:	87648493          	addi	s1,s1,-1930 # 80011208 <pq+0x158>
    8000299a:	00015917          	auipc	s2,0x15
    8000299e:	86e90913          	addi	s2,s2,-1938 # 80017208 <pq+0x6158>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800029a2:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800029a4:	00006997          	auipc	s3,0x6
    800029a8:	99c98993          	addi	s3,s3,-1636 # 80008340 <digits+0x300>
    // Agregamos el contador de veces que se ejecuto.
    printf("%d %s %s %d %d", p->pid, state, p->name, p->contador, p->priority);
    800029ac:	00006a97          	auipc	s5,0x6
    800029b0:	99ca8a93          	addi	s5,s5,-1636 # 80008348 <digits+0x308>
    printf("\n");
    800029b4:	00006a17          	auipc	s4,0x6
    800029b8:	c4ca0a13          	addi	s4,s4,-948 # 80008600 <syscalls+0xf0>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800029bc:	00006b97          	auipc	s7,0x6
    800029c0:	9ccb8b93          	addi	s7,s7,-1588 # 80008388 <states.0>
    800029c4:	a01d                	j	800029ea <procdump+0x7e>
    printf("%d %s %s %d %d", p->pid, state, p->name, p->contador, p->priority);
    800029c6:	6a9c                	ld	a5,16(a3)
    800029c8:	6e98                	ld	a4,24(a3)
    800029ca:	ed86a583          	lw	a1,-296(a3)
    800029ce:	8556                	mv	a0,s5
    800029d0:	ffffe097          	auipc	ra,0xffffe
    800029d4:	bba080e7          	jalr	-1094(ra) # 8000058a <printf>
    printf("\n");
    800029d8:	8552                	mv	a0,s4
    800029da:	ffffe097          	auipc	ra,0xffffe
    800029de:	bb0080e7          	jalr	-1104(ra) # 8000058a <printf>
  for(p = pq.proc; p < &pq.proc[NPROC]; p++){
    800029e2:	18048493          	addi	s1,s1,384
    800029e6:	03248263          	beq	s1,s2,80002a0a <procdump+0x9e>
    if(p->state == UNUSED)
    800029ea:	86a6                	mv	a3,s1
    800029ec:	ec04a783          	lw	a5,-320(s1)
    800029f0:	dbed                	beqz	a5,800029e2 <procdump+0x76>
      state = "???";
    800029f2:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800029f4:	fcfb69e3          	bltu	s6,a5,800029c6 <procdump+0x5a>
    800029f8:	02079713          	slli	a4,a5,0x20
    800029fc:	01d75793          	srli	a5,a4,0x1d
    80002a00:	97de                	add	a5,a5,s7
    80002a02:	6390                	ld	a2,0(a5)
    80002a04:	f269                	bnez	a2,800029c6 <procdump+0x5a>
      state = "???";
    80002a06:	864e                	mv	a2,s3
    80002a08:	bf7d                	j	800029c6 <procdump+0x5a>
  }
}
    80002a0a:	60a6                	ld	ra,72(sp)
    80002a0c:	6406                	ld	s0,64(sp)
    80002a0e:	74e2                	ld	s1,56(sp)
    80002a10:	7942                	ld	s2,48(sp)
    80002a12:	79a2                	ld	s3,40(sp)
    80002a14:	7a02                	ld	s4,32(sp)
    80002a16:	6ae2                	ld	s5,24(sp)
    80002a18:	6b42                	ld	s6,16(sp)
    80002a1a:	6ba2                	ld	s7,8(sp)
    80002a1c:	6161                	addi	sp,sp,80
    80002a1e:	8082                	ret

0000000080002a20 <swtch>:
    80002a20:	00153023          	sd	ra,0(a0)
    80002a24:	00253423          	sd	sp,8(a0)
    80002a28:	e900                	sd	s0,16(a0)
    80002a2a:	ed04                	sd	s1,24(a0)
    80002a2c:	03253023          	sd	s2,32(a0)
    80002a30:	03353423          	sd	s3,40(a0)
    80002a34:	03453823          	sd	s4,48(a0)
    80002a38:	03553c23          	sd	s5,56(a0)
    80002a3c:	05653023          	sd	s6,64(a0)
    80002a40:	05753423          	sd	s7,72(a0)
    80002a44:	05853823          	sd	s8,80(a0)
    80002a48:	05953c23          	sd	s9,88(a0)
    80002a4c:	07a53023          	sd	s10,96(a0)
    80002a50:	07b53423          	sd	s11,104(a0)
    80002a54:	0005b083          	ld	ra,0(a1)
    80002a58:	0085b103          	ld	sp,8(a1)
    80002a5c:	6980                	ld	s0,16(a1)
    80002a5e:	6d84                	ld	s1,24(a1)
    80002a60:	0205b903          	ld	s2,32(a1)
    80002a64:	0285b983          	ld	s3,40(a1)
    80002a68:	0305ba03          	ld	s4,48(a1)
    80002a6c:	0385ba83          	ld	s5,56(a1)
    80002a70:	0405bb03          	ld	s6,64(a1)
    80002a74:	0485bb83          	ld	s7,72(a1)
    80002a78:	0505bc03          	ld	s8,80(a1)
    80002a7c:	0585bc83          	ld	s9,88(a1)
    80002a80:	0605bd03          	ld	s10,96(a1)
    80002a84:	0685bd83          	ld	s11,104(a1)
    80002a88:	8082                	ret

0000000080002a8a <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002a8a:	1141                	addi	sp,sp,-16
    80002a8c:	e406                	sd	ra,8(sp)
    80002a8e:	e022                	sd	s0,0(sp)
    80002a90:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002a92:	00006597          	auipc	a1,0x6
    80002a96:	92658593          	addi	a1,a1,-1754 # 800083b8 <states.0+0x30>
    80002a9a:	00015517          	auipc	a0,0x15
    80002a9e:	c4e50513          	addi	a0,a0,-946 # 800176e8 <tickslock>
    80002aa2:	ffffe097          	auipc	ra,0xffffe
    80002aa6:	0a4080e7          	jalr	164(ra) # 80000b46 <initlock>
}
    80002aaa:	60a2                	ld	ra,8(sp)
    80002aac:	6402                	ld	s0,0(sp)
    80002aae:	0141                	addi	sp,sp,16
    80002ab0:	8082                	ret

0000000080002ab2 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002ab2:	1141                	addi	sp,sp,-16
    80002ab4:	e422                	sd	s0,8(sp)
    80002ab6:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002ab8:	00003797          	auipc	a5,0x3
    80002abc:	53878793          	addi	a5,a5,1336 # 80005ff0 <kernelvec>
    80002ac0:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002ac4:	6422                	ld	s0,8(sp)
    80002ac6:	0141                	addi	sp,sp,16
    80002ac8:	8082                	ret

0000000080002aca <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002aca:	1141                	addi	sp,sp,-16
    80002acc:	e406                	sd	ra,8(sp)
    80002ace:	e022                	sd	s0,0(sp)
    80002ad0:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002ad2:	fffff097          	auipc	ra,0xfffff
    80002ad6:	15a080e7          	jalr	346(ra) # 80001c2c <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ada:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002ade:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002ae0:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002ae4:	00004697          	auipc	a3,0x4
    80002ae8:	51c68693          	addi	a3,a3,1308 # 80007000 <_trampoline>
    80002aec:	00004717          	auipc	a4,0x4
    80002af0:	51470713          	addi	a4,a4,1300 # 80007000 <_trampoline>
    80002af4:	8f15                	sub	a4,a4,a3
    80002af6:	040007b7          	lui	a5,0x4000
    80002afa:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002afc:	07b2                	slli	a5,a5,0xc
    80002afe:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002b00:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002b04:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002b06:	18002673          	csrr	a2,satp
    80002b0a:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002b0c:	6d30                	ld	a2,88(a0)
    80002b0e:	6138                	ld	a4,64(a0)
    80002b10:	6585                	lui	a1,0x1
    80002b12:	972e                	add	a4,a4,a1
    80002b14:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002b16:	6d38                	ld	a4,88(a0)
    80002b18:	00000617          	auipc	a2,0x0
    80002b1c:	13060613          	addi	a2,a2,304 # 80002c48 <usertrap>
    80002b20:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002b22:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002b24:	8612                	mv	a2,tp
    80002b26:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b28:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002b2c:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002b30:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b34:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002b38:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002b3a:	6f18                	ld	a4,24(a4)
    80002b3c:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002b40:	6928                	ld	a0,80(a0)
    80002b42:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002b44:	00004717          	auipc	a4,0x4
    80002b48:	55870713          	addi	a4,a4,1368 # 8000709c <userret>
    80002b4c:	8f15                	sub	a4,a4,a3
    80002b4e:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002b50:	577d                	li	a4,-1
    80002b52:	177e                	slli	a4,a4,0x3f
    80002b54:	8d59                	or	a0,a0,a4
    80002b56:	9782                	jalr	a5
}
    80002b58:	60a2                	ld	ra,8(sp)
    80002b5a:	6402                	ld	s0,0(sp)
    80002b5c:	0141                	addi	sp,sp,16
    80002b5e:	8082                	ret

0000000080002b60 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002b60:	1101                	addi	sp,sp,-32
    80002b62:	ec06                	sd	ra,24(sp)
    80002b64:	e822                	sd	s0,16(sp)
    80002b66:	e426                	sd	s1,8(sp)
    80002b68:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002b6a:	00015497          	auipc	s1,0x15
    80002b6e:	b7e48493          	addi	s1,s1,-1154 # 800176e8 <tickslock>
    80002b72:	8526                	mv	a0,s1
    80002b74:	ffffe097          	auipc	ra,0xffffe
    80002b78:	062080e7          	jalr	98(ra) # 80000bd6 <acquire>
  ticks++;
    80002b7c:	00006517          	auipc	a0,0x6
    80002b80:	e9450513          	addi	a0,a0,-364 # 80008a10 <ticks>
    80002b84:	411c                	lw	a5,0(a0)
    80002b86:	2785                	addiw	a5,a5,1
    80002b88:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002b8a:	00000097          	auipc	ra,0x0
    80002b8e:	8f2080e7          	jalr	-1806(ra) # 8000247c <wakeup>
  release(&tickslock);
    80002b92:	8526                	mv	a0,s1
    80002b94:	ffffe097          	auipc	ra,0xffffe
    80002b98:	0f6080e7          	jalr	246(ra) # 80000c8a <release>
}
    80002b9c:	60e2                	ld	ra,24(sp)
    80002b9e:	6442                	ld	s0,16(sp)
    80002ba0:	64a2                	ld	s1,8(sp)
    80002ba2:	6105                	addi	sp,sp,32
    80002ba4:	8082                	ret

0000000080002ba6 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002ba6:	1101                	addi	sp,sp,-32
    80002ba8:	ec06                	sd	ra,24(sp)
    80002baa:	e822                	sd	s0,16(sp)
    80002bac:	e426                	sd	s1,8(sp)
    80002bae:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002bb0:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002bb4:	00074d63          	bltz	a4,80002bce <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002bb8:	57fd                	li	a5,-1
    80002bba:	17fe                	slli	a5,a5,0x3f
    80002bbc:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002bbe:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002bc0:	06f70363          	beq	a4,a5,80002c26 <devintr+0x80>
  }
}
    80002bc4:	60e2                	ld	ra,24(sp)
    80002bc6:	6442                	ld	s0,16(sp)
    80002bc8:	64a2                	ld	s1,8(sp)
    80002bca:	6105                	addi	sp,sp,32
    80002bcc:	8082                	ret
     (scause & 0xff) == 9){
    80002bce:	0ff77793          	zext.b	a5,a4
  if((scause & 0x8000000000000000L) &&
    80002bd2:	46a5                	li	a3,9
    80002bd4:	fed792e3          	bne	a5,a3,80002bb8 <devintr+0x12>
    int irq = plic_claim();
    80002bd8:	00003097          	auipc	ra,0x3
    80002bdc:	520080e7          	jalr	1312(ra) # 800060f8 <plic_claim>
    80002be0:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002be2:	47a9                	li	a5,10
    80002be4:	02f50763          	beq	a0,a5,80002c12 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002be8:	4785                	li	a5,1
    80002bea:	02f50963          	beq	a0,a5,80002c1c <devintr+0x76>
    return 1;
    80002bee:	4505                	li	a0,1
    } else if(irq){
    80002bf0:	d8f1                	beqz	s1,80002bc4 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002bf2:	85a6                	mv	a1,s1
    80002bf4:	00005517          	auipc	a0,0x5
    80002bf8:	7cc50513          	addi	a0,a0,1996 # 800083c0 <states.0+0x38>
    80002bfc:	ffffe097          	auipc	ra,0xffffe
    80002c00:	98e080e7          	jalr	-1650(ra) # 8000058a <printf>
      plic_complete(irq);
    80002c04:	8526                	mv	a0,s1
    80002c06:	00003097          	auipc	ra,0x3
    80002c0a:	516080e7          	jalr	1302(ra) # 8000611c <plic_complete>
    return 1;
    80002c0e:	4505                	li	a0,1
    80002c10:	bf55                	j	80002bc4 <devintr+0x1e>
      uartintr();
    80002c12:	ffffe097          	auipc	ra,0xffffe
    80002c16:	d86080e7          	jalr	-634(ra) # 80000998 <uartintr>
    80002c1a:	b7ed                	j	80002c04 <devintr+0x5e>
      virtio_disk_intr();
    80002c1c:	00004097          	auipc	ra,0x4
    80002c20:	9c8080e7          	jalr	-1592(ra) # 800065e4 <virtio_disk_intr>
    80002c24:	b7c5                	j	80002c04 <devintr+0x5e>
    if(cpuid() == 0){
    80002c26:	fffff097          	auipc	ra,0xfffff
    80002c2a:	fda080e7          	jalr	-38(ra) # 80001c00 <cpuid>
    80002c2e:	c901                	beqz	a0,80002c3e <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002c30:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002c34:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002c36:	14479073          	csrw	sip,a5
    return 2;
    80002c3a:	4509                	li	a0,2
    80002c3c:	b761                	j	80002bc4 <devintr+0x1e>
      clockintr();
    80002c3e:	00000097          	auipc	ra,0x0
    80002c42:	f22080e7          	jalr	-222(ra) # 80002b60 <clockintr>
    80002c46:	b7ed                	j	80002c30 <devintr+0x8a>

0000000080002c48 <usertrap>:
{
    80002c48:	1101                	addi	sp,sp,-32
    80002c4a:	ec06                	sd	ra,24(sp)
    80002c4c:	e822                	sd	s0,16(sp)
    80002c4e:	e426                	sd	s1,8(sp)
    80002c50:	e04a                	sd	s2,0(sp)
    80002c52:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c54:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002c58:	1007f793          	andi	a5,a5,256
    80002c5c:	e3b1                	bnez	a5,80002ca0 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002c5e:	00003797          	auipc	a5,0x3
    80002c62:	39278793          	addi	a5,a5,914 # 80005ff0 <kernelvec>
    80002c66:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002c6a:	fffff097          	auipc	ra,0xfffff
    80002c6e:	fc2080e7          	jalr	-62(ra) # 80001c2c <myproc>
    80002c72:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002c74:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c76:	14102773          	csrr	a4,sepc
    80002c7a:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c7c:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002c80:	47a1                	li	a5,8
    80002c82:	02f70763          	beq	a4,a5,80002cb0 <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    80002c86:	00000097          	auipc	ra,0x0
    80002c8a:	f20080e7          	jalr	-224(ra) # 80002ba6 <devintr>
    80002c8e:	892a                	mv	s2,a0
    80002c90:	c151                	beqz	a0,80002d14 <usertrap+0xcc>
  if(killed(p))
    80002c92:	8526                	mv	a0,s1
    80002c94:	00000097          	auipc	ra,0x0
    80002c98:	acc080e7          	jalr	-1332(ra) # 80002760 <killed>
    80002c9c:	c929                	beqz	a0,80002cee <usertrap+0xa6>
    80002c9e:	a099                	j	80002ce4 <usertrap+0x9c>
    panic("usertrap: not from user mode");
    80002ca0:	00005517          	auipc	a0,0x5
    80002ca4:	74050513          	addi	a0,a0,1856 # 800083e0 <states.0+0x58>
    80002ca8:	ffffe097          	auipc	ra,0xffffe
    80002cac:	898080e7          	jalr	-1896(ra) # 80000540 <panic>
    if(killed(p))
    80002cb0:	00000097          	auipc	ra,0x0
    80002cb4:	ab0080e7          	jalr	-1360(ra) # 80002760 <killed>
    80002cb8:	e921                	bnez	a0,80002d08 <usertrap+0xc0>
    p->trapframe->epc += 4;
    80002cba:	6cb8                	ld	a4,88(s1)
    80002cbc:	6f1c                	ld	a5,24(a4)
    80002cbe:	0791                	addi	a5,a5,4
    80002cc0:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002cc2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002cc6:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002cca:	10079073          	csrw	sstatus,a5
    syscall();
    80002cce:	00000097          	auipc	ra,0x0
    80002cd2:	2d4080e7          	jalr	724(ra) # 80002fa2 <syscall>
  if(killed(p))
    80002cd6:	8526                	mv	a0,s1
    80002cd8:	00000097          	auipc	ra,0x0
    80002cdc:	a88080e7          	jalr	-1400(ra) # 80002760 <killed>
    80002ce0:	c911                	beqz	a0,80002cf4 <usertrap+0xac>
    80002ce2:	4901                	li	s2,0
    exit(-1);
    80002ce4:	557d                	li	a0,-1
    80002ce6:	00000097          	auipc	ra,0x0
    80002cea:	8a6080e7          	jalr	-1882(ra) # 8000258c <exit>
  if(which_dev == 2)
    80002cee:	4789                	li	a5,2
    80002cf0:	04f90f63          	beq	s2,a5,80002d4e <usertrap+0x106>
  usertrapret();
    80002cf4:	00000097          	auipc	ra,0x0
    80002cf8:	dd6080e7          	jalr	-554(ra) # 80002aca <usertrapret>
}
    80002cfc:	60e2                	ld	ra,24(sp)
    80002cfe:	6442                	ld	s0,16(sp)
    80002d00:	64a2                	ld	s1,8(sp)
    80002d02:	6902                	ld	s2,0(sp)
    80002d04:	6105                	addi	sp,sp,32
    80002d06:	8082                	ret
      exit(-1);
    80002d08:	557d                	li	a0,-1
    80002d0a:	00000097          	auipc	ra,0x0
    80002d0e:	882080e7          	jalr	-1918(ra) # 8000258c <exit>
    80002d12:	b765                	j	80002cba <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002d14:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002d18:	5890                	lw	a2,48(s1)
    80002d1a:	00005517          	auipc	a0,0x5
    80002d1e:	6e650513          	addi	a0,a0,1766 # 80008400 <states.0+0x78>
    80002d22:	ffffe097          	auipc	ra,0xffffe
    80002d26:	868080e7          	jalr	-1944(ra) # 8000058a <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d2a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002d2e:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002d32:	00005517          	auipc	a0,0x5
    80002d36:	6fe50513          	addi	a0,a0,1790 # 80008430 <states.0+0xa8>
    80002d3a:	ffffe097          	auipc	ra,0xffffe
    80002d3e:	850080e7          	jalr	-1968(ra) # 8000058a <printf>
    setkilled(p);
    80002d42:	8526                	mv	a0,s1
    80002d44:	00000097          	auipc	ra,0x0
    80002d48:	9f0080e7          	jalr	-1552(ra) # 80002734 <setkilled>
    80002d4c:	b769                	j	80002cd6 <usertrap+0x8e>
    yield();
    80002d4e:	fffff097          	auipc	ra,0xfffff
    80002d52:	626080e7          	jalr	1574(ra) # 80002374 <yield>
    80002d56:	bf79                	j	80002cf4 <usertrap+0xac>

0000000080002d58 <kerneltrap>:
{
    80002d58:	7179                	addi	sp,sp,-48
    80002d5a:	f406                	sd	ra,40(sp)
    80002d5c:	f022                	sd	s0,32(sp)
    80002d5e:	ec26                	sd	s1,24(sp)
    80002d60:	e84a                	sd	s2,16(sp)
    80002d62:	e44e                	sd	s3,8(sp)
    80002d64:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d66:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d6a:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002d6e:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002d72:	1004f793          	andi	a5,s1,256
    80002d76:	cb85                	beqz	a5,80002da6 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d78:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002d7c:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002d7e:	ef85                	bnez	a5,80002db6 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002d80:	00000097          	auipc	ra,0x0
    80002d84:	e26080e7          	jalr	-474(ra) # 80002ba6 <devintr>
    80002d88:	cd1d                	beqz	a0,80002dc6 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002d8a:	4789                	li	a5,2
    80002d8c:	06f50a63          	beq	a0,a5,80002e00 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002d90:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002d94:	10049073          	csrw	sstatus,s1
}
    80002d98:	70a2                	ld	ra,40(sp)
    80002d9a:	7402                	ld	s0,32(sp)
    80002d9c:	64e2                	ld	s1,24(sp)
    80002d9e:	6942                	ld	s2,16(sp)
    80002da0:	69a2                	ld	s3,8(sp)
    80002da2:	6145                	addi	sp,sp,48
    80002da4:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002da6:	00005517          	auipc	a0,0x5
    80002daa:	6aa50513          	addi	a0,a0,1706 # 80008450 <states.0+0xc8>
    80002dae:	ffffd097          	auipc	ra,0xffffd
    80002db2:	792080e7          	jalr	1938(ra) # 80000540 <panic>
    panic("kerneltrap: interrupts enabled");
    80002db6:	00005517          	auipc	a0,0x5
    80002dba:	6c250513          	addi	a0,a0,1730 # 80008478 <states.0+0xf0>
    80002dbe:	ffffd097          	auipc	ra,0xffffd
    80002dc2:	782080e7          	jalr	1922(ra) # 80000540 <panic>
    printf("scause %p\n", scause);
    80002dc6:	85ce                	mv	a1,s3
    80002dc8:	00005517          	auipc	a0,0x5
    80002dcc:	6d050513          	addi	a0,a0,1744 # 80008498 <states.0+0x110>
    80002dd0:	ffffd097          	auipc	ra,0xffffd
    80002dd4:	7ba080e7          	jalr	1978(ra) # 8000058a <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002dd8:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002ddc:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002de0:	00005517          	auipc	a0,0x5
    80002de4:	6c850513          	addi	a0,a0,1736 # 800084a8 <states.0+0x120>
    80002de8:	ffffd097          	auipc	ra,0xffffd
    80002dec:	7a2080e7          	jalr	1954(ra) # 8000058a <printf>
    panic("kerneltrap");
    80002df0:	00005517          	auipc	a0,0x5
    80002df4:	6d050513          	addi	a0,a0,1744 # 800084c0 <states.0+0x138>
    80002df8:	ffffd097          	auipc	ra,0xffffd
    80002dfc:	748080e7          	jalr	1864(ra) # 80000540 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002e00:	fffff097          	auipc	ra,0xfffff
    80002e04:	e2c080e7          	jalr	-468(ra) # 80001c2c <myproc>
    80002e08:	d541                	beqz	a0,80002d90 <kerneltrap+0x38>
    80002e0a:	fffff097          	auipc	ra,0xfffff
    80002e0e:	e22080e7          	jalr	-478(ra) # 80001c2c <myproc>
    80002e12:	4d18                	lw	a4,24(a0)
    80002e14:	4791                	li	a5,4
    80002e16:	f6f71de3          	bne	a4,a5,80002d90 <kerneltrap+0x38>
    yield();
    80002e1a:	fffff097          	auipc	ra,0xfffff
    80002e1e:	55a080e7          	jalr	1370(ra) # 80002374 <yield>
    80002e22:	b7bd                	j	80002d90 <kerneltrap+0x38>

0000000080002e24 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002e24:	1101                	addi	sp,sp,-32
    80002e26:	ec06                	sd	ra,24(sp)
    80002e28:	e822                	sd	s0,16(sp)
    80002e2a:	e426                	sd	s1,8(sp)
    80002e2c:	1000                	addi	s0,sp,32
    80002e2e:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002e30:	fffff097          	auipc	ra,0xfffff
    80002e34:	dfc080e7          	jalr	-516(ra) # 80001c2c <myproc>
  switch (n) {
    80002e38:	4795                	li	a5,5
    80002e3a:	0497e163          	bltu	a5,s1,80002e7c <argraw+0x58>
    80002e3e:	048a                	slli	s1,s1,0x2
    80002e40:	00005717          	auipc	a4,0x5
    80002e44:	6b870713          	addi	a4,a4,1720 # 800084f8 <states.0+0x170>
    80002e48:	94ba                	add	s1,s1,a4
    80002e4a:	409c                	lw	a5,0(s1)
    80002e4c:	97ba                	add	a5,a5,a4
    80002e4e:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002e50:	6d3c                	ld	a5,88(a0)
    80002e52:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002e54:	60e2                	ld	ra,24(sp)
    80002e56:	6442                	ld	s0,16(sp)
    80002e58:	64a2                	ld	s1,8(sp)
    80002e5a:	6105                	addi	sp,sp,32
    80002e5c:	8082                	ret
    return p->trapframe->a1;
    80002e5e:	6d3c                	ld	a5,88(a0)
    80002e60:	7fa8                	ld	a0,120(a5)
    80002e62:	bfcd                	j	80002e54 <argraw+0x30>
    return p->trapframe->a2;
    80002e64:	6d3c                	ld	a5,88(a0)
    80002e66:	63c8                	ld	a0,128(a5)
    80002e68:	b7f5                	j	80002e54 <argraw+0x30>
    return p->trapframe->a3;
    80002e6a:	6d3c                	ld	a5,88(a0)
    80002e6c:	67c8                	ld	a0,136(a5)
    80002e6e:	b7dd                	j	80002e54 <argraw+0x30>
    return p->trapframe->a4;
    80002e70:	6d3c                	ld	a5,88(a0)
    80002e72:	6bc8                	ld	a0,144(a5)
    80002e74:	b7c5                	j	80002e54 <argraw+0x30>
    return p->trapframe->a5;
    80002e76:	6d3c                	ld	a5,88(a0)
    80002e78:	6fc8                	ld	a0,152(a5)
    80002e7a:	bfe9                	j	80002e54 <argraw+0x30>
  panic("argraw");
    80002e7c:	00005517          	auipc	a0,0x5
    80002e80:	65450513          	addi	a0,a0,1620 # 800084d0 <states.0+0x148>
    80002e84:	ffffd097          	auipc	ra,0xffffd
    80002e88:	6bc080e7          	jalr	1724(ra) # 80000540 <panic>

0000000080002e8c <fetchaddr>:
{
    80002e8c:	1101                	addi	sp,sp,-32
    80002e8e:	ec06                	sd	ra,24(sp)
    80002e90:	e822                	sd	s0,16(sp)
    80002e92:	e426                	sd	s1,8(sp)
    80002e94:	e04a                	sd	s2,0(sp)
    80002e96:	1000                	addi	s0,sp,32
    80002e98:	84aa                	mv	s1,a0
    80002e9a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002e9c:	fffff097          	auipc	ra,0xfffff
    80002ea0:	d90080e7          	jalr	-624(ra) # 80001c2c <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002ea4:	653c                	ld	a5,72(a0)
    80002ea6:	02f4f863          	bgeu	s1,a5,80002ed6 <fetchaddr+0x4a>
    80002eaa:	00848713          	addi	a4,s1,8
    80002eae:	02e7e663          	bltu	a5,a4,80002eda <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002eb2:	46a1                	li	a3,8
    80002eb4:	8626                	mv	a2,s1
    80002eb6:	85ca                	mv	a1,s2
    80002eb8:	6928                	ld	a0,80(a0)
    80002eba:	fffff097          	auipc	ra,0xfffff
    80002ebe:	83e080e7          	jalr	-1986(ra) # 800016f8 <copyin>
    80002ec2:	00a03533          	snez	a0,a0
    80002ec6:	40a00533          	neg	a0,a0
}
    80002eca:	60e2                	ld	ra,24(sp)
    80002ecc:	6442                	ld	s0,16(sp)
    80002ece:	64a2                	ld	s1,8(sp)
    80002ed0:	6902                	ld	s2,0(sp)
    80002ed2:	6105                	addi	sp,sp,32
    80002ed4:	8082                	ret
    return -1;
    80002ed6:	557d                	li	a0,-1
    80002ed8:	bfcd                	j	80002eca <fetchaddr+0x3e>
    80002eda:	557d                	li	a0,-1
    80002edc:	b7fd                	j	80002eca <fetchaddr+0x3e>

0000000080002ede <fetchstr>:
{
    80002ede:	7179                	addi	sp,sp,-48
    80002ee0:	f406                	sd	ra,40(sp)
    80002ee2:	f022                	sd	s0,32(sp)
    80002ee4:	ec26                	sd	s1,24(sp)
    80002ee6:	e84a                	sd	s2,16(sp)
    80002ee8:	e44e                	sd	s3,8(sp)
    80002eea:	1800                	addi	s0,sp,48
    80002eec:	892a                	mv	s2,a0
    80002eee:	84ae                	mv	s1,a1
    80002ef0:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002ef2:	fffff097          	auipc	ra,0xfffff
    80002ef6:	d3a080e7          	jalr	-710(ra) # 80001c2c <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002efa:	86ce                	mv	a3,s3
    80002efc:	864a                	mv	a2,s2
    80002efe:	85a6                	mv	a1,s1
    80002f00:	6928                	ld	a0,80(a0)
    80002f02:	fffff097          	auipc	ra,0xfffff
    80002f06:	884080e7          	jalr	-1916(ra) # 80001786 <copyinstr>
    80002f0a:	00054e63          	bltz	a0,80002f26 <fetchstr+0x48>
  return strlen(buf);
    80002f0e:	8526                	mv	a0,s1
    80002f10:	ffffe097          	auipc	ra,0xffffe
    80002f14:	f3e080e7          	jalr	-194(ra) # 80000e4e <strlen>
}
    80002f18:	70a2                	ld	ra,40(sp)
    80002f1a:	7402                	ld	s0,32(sp)
    80002f1c:	64e2                	ld	s1,24(sp)
    80002f1e:	6942                	ld	s2,16(sp)
    80002f20:	69a2                	ld	s3,8(sp)
    80002f22:	6145                	addi	sp,sp,48
    80002f24:	8082                	ret
    return -1;
    80002f26:	557d                	li	a0,-1
    80002f28:	bfc5                	j	80002f18 <fetchstr+0x3a>

0000000080002f2a <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002f2a:	1101                	addi	sp,sp,-32
    80002f2c:	ec06                	sd	ra,24(sp)
    80002f2e:	e822                	sd	s0,16(sp)
    80002f30:	e426                	sd	s1,8(sp)
    80002f32:	1000                	addi	s0,sp,32
    80002f34:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002f36:	00000097          	auipc	ra,0x0
    80002f3a:	eee080e7          	jalr	-274(ra) # 80002e24 <argraw>
    80002f3e:	c088                	sw	a0,0(s1)
}
    80002f40:	60e2                	ld	ra,24(sp)
    80002f42:	6442                	ld	s0,16(sp)
    80002f44:	64a2                	ld	s1,8(sp)
    80002f46:	6105                	addi	sp,sp,32
    80002f48:	8082                	ret

0000000080002f4a <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002f4a:	1101                	addi	sp,sp,-32
    80002f4c:	ec06                	sd	ra,24(sp)
    80002f4e:	e822                	sd	s0,16(sp)
    80002f50:	e426                	sd	s1,8(sp)
    80002f52:	1000                	addi	s0,sp,32
    80002f54:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002f56:	00000097          	auipc	ra,0x0
    80002f5a:	ece080e7          	jalr	-306(ra) # 80002e24 <argraw>
    80002f5e:	e088                	sd	a0,0(s1)
}
    80002f60:	60e2                	ld	ra,24(sp)
    80002f62:	6442                	ld	s0,16(sp)
    80002f64:	64a2                	ld	s1,8(sp)
    80002f66:	6105                	addi	sp,sp,32
    80002f68:	8082                	ret

0000000080002f6a <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002f6a:	7179                	addi	sp,sp,-48
    80002f6c:	f406                	sd	ra,40(sp)
    80002f6e:	f022                	sd	s0,32(sp)
    80002f70:	ec26                	sd	s1,24(sp)
    80002f72:	e84a                	sd	s2,16(sp)
    80002f74:	1800                	addi	s0,sp,48
    80002f76:	84ae                	mv	s1,a1
    80002f78:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002f7a:	fd840593          	addi	a1,s0,-40
    80002f7e:	00000097          	auipc	ra,0x0
    80002f82:	fcc080e7          	jalr	-52(ra) # 80002f4a <argaddr>
  return fetchstr(addr, buf, max);
    80002f86:	864a                	mv	a2,s2
    80002f88:	85a6                	mv	a1,s1
    80002f8a:	fd843503          	ld	a0,-40(s0)
    80002f8e:	00000097          	auipc	ra,0x0
    80002f92:	f50080e7          	jalr	-176(ra) # 80002ede <fetchstr>
}
    80002f96:	70a2                	ld	ra,40(sp)
    80002f98:	7402                	ld	s0,32(sp)
    80002f9a:	64e2                	ld	s1,24(sp)
    80002f9c:	6942                	ld	s2,16(sp)
    80002f9e:	6145                	addi	sp,sp,48
    80002fa0:	8082                	ret

0000000080002fa2 <syscall>:
[SYS_pstat]   sys_pstat,
};

void
syscall(void)
{
    80002fa2:	1101                	addi	sp,sp,-32
    80002fa4:	ec06                	sd	ra,24(sp)
    80002fa6:	e822                	sd	s0,16(sp)
    80002fa8:	e426                	sd	s1,8(sp)
    80002faa:	e04a                	sd	s2,0(sp)
    80002fac:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002fae:	fffff097          	auipc	ra,0xfffff
    80002fb2:	c7e080e7          	jalr	-898(ra) # 80001c2c <myproc>
    80002fb6:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002fb8:	05853903          	ld	s2,88(a0)
    80002fbc:	0a893783          	ld	a5,168(s2)
    80002fc0:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002fc4:	37fd                	addiw	a5,a5,-1
    80002fc6:	4755                	li	a4,21
    80002fc8:	00f76f63          	bltu	a4,a5,80002fe6 <syscall+0x44>
    80002fcc:	00369713          	slli	a4,a3,0x3
    80002fd0:	00005797          	auipc	a5,0x5
    80002fd4:	54078793          	addi	a5,a5,1344 # 80008510 <syscalls>
    80002fd8:	97ba                	add	a5,a5,a4
    80002fda:	639c                	ld	a5,0(a5)
    80002fdc:	c789                	beqz	a5,80002fe6 <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002fde:	9782                	jalr	a5
    80002fe0:	06a93823          	sd	a0,112(s2)
    80002fe4:	a839                	j	80003002 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002fe6:	15848613          	addi	a2,s1,344
    80002fea:	588c                	lw	a1,48(s1)
    80002fec:	00005517          	auipc	a0,0x5
    80002ff0:	4ec50513          	addi	a0,a0,1260 # 800084d8 <states.0+0x150>
    80002ff4:	ffffd097          	auipc	ra,0xffffd
    80002ff8:	596080e7          	jalr	1430(ra) # 8000058a <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002ffc:	6cbc                	ld	a5,88(s1)
    80002ffe:	577d                	li	a4,-1
    80003000:	fbb8                	sd	a4,112(a5)
  }
}
    80003002:	60e2                	ld	ra,24(sp)
    80003004:	6442                	ld	s0,16(sp)
    80003006:	64a2                	ld	s1,8(sp)
    80003008:	6902                	ld	s2,0(sp)
    8000300a:	6105                	addi	sp,sp,32
    8000300c:	8082                	ret

000000008000300e <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    8000300e:	1101                	addi	sp,sp,-32
    80003010:	ec06                	sd	ra,24(sp)
    80003012:	e822                	sd	s0,16(sp)
    80003014:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80003016:	fec40593          	addi	a1,s0,-20
    8000301a:	4501                	li	a0,0
    8000301c:	00000097          	auipc	ra,0x0
    80003020:	f0e080e7          	jalr	-242(ra) # 80002f2a <argint>
  exit(n);
    80003024:	fec42503          	lw	a0,-20(s0)
    80003028:	fffff097          	auipc	ra,0xfffff
    8000302c:	564080e7          	jalr	1380(ra) # 8000258c <exit>
  return 0;  // not reached
}
    80003030:	4501                	li	a0,0
    80003032:	60e2                	ld	ra,24(sp)
    80003034:	6442                	ld	s0,16(sp)
    80003036:	6105                	addi	sp,sp,32
    80003038:	8082                	ret

000000008000303a <sys_getpid>:

uint64
sys_getpid(void)
{
    8000303a:	1141                	addi	sp,sp,-16
    8000303c:	e406                	sd	ra,8(sp)
    8000303e:	e022                	sd	s0,0(sp)
    80003040:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80003042:	fffff097          	auipc	ra,0xfffff
    80003046:	bea080e7          	jalr	-1046(ra) # 80001c2c <myproc>
}
    8000304a:	5908                	lw	a0,48(a0)
    8000304c:	60a2                	ld	ra,8(sp)
    8000304e:	6402                	ld	s0,0(sp)
    80003050:	0141                	addi	sp,sp,16
    80003052:	8082                	ret

0000000080003054 <sys_fork>:

uint64
sys_fork(void)
{
    80003054:	1141                	addi	sp,sp,-16
    80003056:	e406                	sd	ra,8(sp)
    80003058:	e022                	sd	s0,0(sp)
    8000305a:	0800                	addi	s0,sp,16
  return fork();
    8000305c:	fffff097          	auipc	ra,0xfffff
    80003060:	fce080e7          	jalr	-50(ra) # 8000202a <fork>
}
    80003064:	60a2                	ld	ra,8(sp)
    80003066:	6402                	ld	s0,0(sp)
    80003068:	0141                	addi	sp,sp,16
    8000306a:	8082                	ret

000000008000306c <sys_wait>:

uint64
sys_wait(void)
{
    8000306c:	1101                	addi	sp,sp,-32
    8000306e:	ec06                	sd	ra,24(sp)
    80003070:	e822                	sd	s0,16(sp)
    80003072:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80003074:	fe840593          	addi	a1,s0,-24
    80003078:	4501                	li	a0,0
    8000307a:	00000097          	auipc	ra,0x0
    8000307e:	ed0080e7          	jalr	-304(ra) # 80002f4a <argaddr>
  return wait(p);
    80003082:	fe843503          	ld	a0,-24(s0)
    80003086:	fffff097          	auipc	ra,0xfffff
    8000308a:	70c080e7          	jalr	1804(ra) # 80002792 <wait>
}
    8000308e:	60e2                	ld	ra,24(sp)
    80003090:	6442                	ld	s0,16(sp)
    80003092:	6105                	addi	sp,sp,32
    80003094:	8082                	ret

0000000080003096 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003096:	7179                	addi	sp,sp,-48
    80003098:	f406                	sd	ra,40(sp)
    8000309a:	f022                	sd	s0,32(sp)
    8000309c:	ec26                	sd	s1,24(sp)
    8000309e:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    800030a0:	fdc40593          	addi	a1,s0,-36
    800030a4:	4501                	li	a0,0
    800030a6:	00000097          	auipc	ra,0x0
    800030aa:	e84080e7          	jalr	-380(ra) # 80002f2a <argint>
  addr = myproc()->sz;
    800030ae:	fffff097          	auipc	ra,0xfffff
    800030b2:	b7e080e7          	jalr	-1154(ra) # 80001c2c <myproc>
    800030b6:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    800030b8:	fdc42503          	lw	a0,-36(s0)
    800030bc:	fffff097          	auipc	ra,0xfffff
    800030c0:	f12080e7          	jalr	-238(ra) # 80001fce <growproc>
    800030c4:	00054863          	bltz	a0,800030d4 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    800030c8:	8526                	mv	a0,s1
    800030ca:	70a2                	ld	ra,40(sp)
    800030cc:	7402                	ld	s0,32(sp)
    800030ce:	64e2                	ld	s1,24(sp)
    800030d0:	6145                	addi	sp,sp,48
    800030d2:	8082                	ret
    return -1;
    800030d4:	54fd                	li	s1,-1
    800030d6:	bfcd                	j	800030c8 <sys_sbrk+0x32>

00000000800030d8 <sys_sleep>:

uint64
sys_sleep(void)
{
    800030d8:	7139                	addi	sp,sp,-64
    800030da:	fc06                	sd	ra,56(sp)
    800030dc:	f822                	sd	s0,48(sp)
    800030de:	f426                	sd	s1,40(sp)
    800030e0:	f04a                	sd	s2,32(sp)
    800030e2:	ec4e                	sd	s3,24(sp)
    800030e4:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    800030e6:	fcc40593          	addi	a1,s0,-52
    800030ea:	4501                	li	a0,0
    800030ec:	00000097          	auipc	ra,0x0
    800030f0:	e3e080e7          	jalr	-450(ra) # 80002f2a <argint>
  acquire(&tickslock);
    800030f4:	00014517          	auipc	a0,0x14
    800030f8:	5f450513          	addi	a0,a0,1524 # 800176e8 <tickslock>
    800030fc:	ffffe097          	auipc	ra,0xffffe
    80003100:	ada080e7          	jalr	-1318(ra) # 80000bd6 <acquire>
  ticks0 = ticks;
    80003104:	00006917          	auipc	s2,0x6
    80003108:	90c92903          	lw	s2,-1780(s2) # 80008a10 <ticks>
  while(ticks - ticks0 < n){
    8000310c:	fcc42783          	lw	a5,-52(s0)
    80003110:	cf9d                	beqz	a5,8000314e <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003112:	00014997          	auipc	s3,0x14
    80003116:	5d698993          	addi	s3,s3,1494 # 800176e8 <tickslock>
    8000311a:	00006497          	auipc	s1,0x6
    8000311e:	8f648493          	addi	s1,s1,-1802 # 80008a10 <ticks>
    if(killed(myproc())){
    80003122:	fffff097          	auipc	ra,0xfffff
    80003126:	b0a080e7          	jalr	-1270(ra) # 80001c2c <myproc>
    8000312a:	fffff097          	auipc	ra,0xfffff
    8000312e:	636080e7          	jalr	1590(ra) # 80002760 <killed>
    80003132:	ed15                	bnez	a0,8000316e <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80003134:	85ce                	mv	a1,s3
    80003136:	8526                	mv	a0,s1
    80003138:	fffff097          	auipc	ra,0xfffff
    8000313c:	2ce080e7          	jalr	718(ra) # 80002406 <sleep>
  while(ticks - ticks0 < n){
    80003140:	409c                	lw	a5,0(s1)
    80003142:	412787bb          	subw	a5,a5,s2
    80003146:	fcc42703          	lw	a4,-52(s0)
    8000314a:	fce7ece3          	bltu	a5,a4,80003122 <sys_sleep+0x4a>
  }
  release(&tickslock);
    8000314e:	00014517          	auipc	a0,0x14
    80003152:	59a50513          	addi	a0,a0,1434 # 800176e8 <tickslock>
    80003156:	ffffe097          	auipc	ra,0xffffe
    8000315a:	b34080e7          	jalr	-1228(ra) # 80000c8a <release>
  return 0;
    8000315e:	4501                	li	a0,0
}
    80003160:	70e2                	ld	ra,56(sp)
    80003162:	7442                	ld	s0,48(sp)
    80003164:	74a2                	ld	s1,40(sp)
    80003166:	7902                	ld	s2,32(sp)
    80003168:	69e2                	ld	s3,24(sp)
    8000316a:	6121                	addi	sp,sp,64
    8000316c:	8082                	ret
      release(&tickslock);
    8000316e:	00014517          	auipc	a0,0x14
    80003172:	57a50513          	addi	a0,a0,1402 # 800176e8 <tickslock>
    80003176:	ffffe097          	auipc	ra,0xffffe
    8000317a:	b14080e7          	jalr	-1260(ra) # 80000c8a <release>
      return -1;
    8000317e:	557d                	li	a0,-1
    80003180:	b7c5                	j	80003160 <sys_sleep+0x88>

0000000080003182 <sys_kill>:

uint64
sys_kill(void)
{
    80003182:	1101                	addi	sp,sp,-32
    80003184:	ec06                	sd	ra,24(sp)
    80003186:	e822                	sd	s0,16(sp)
    80003188:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    8000318a:	fec40593          	addi	a1,s0,-20
    8000318e:	4501                	li	a0,0
    80003190:	00000097          	auipc	ra,0x0
    80003194:	d9a080e7          	jalr	-614(ra) # 80002f2a <argint>
  return kill(pid);
    80003198:	fec42503          	lw	a0,-20(s0)
    8000319c:	fffff097          	auipc	ra,0xfffff
    800031a0:	4c6080e7          	jalr	1222(ra) # 80002662 <kill>
}
    800031a4:	60e2                	ld	ra,24(sp)
    800031a6:	6442                	ld	s0,16(sp)
    800031a8:	6105                	addi	sp,sp,32
    800031aa:	8082                	ret

00000000800031ac <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800031ac:	1101                	addi	sp,sp,-32
    800031ae:	ec06                	sd	ra,24(sp)
    800031b0:	e822                	sd	s0,16(sp)
    800031b2:	e426                	sd	s1,8(sp)
    800031b4:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800031b6:	00014517          	auipc	a0,0x14
    800031ba:	53250513          	addi	a0,a0,1330 # 800176e8 <tickslock>
    800031be:	ffffe097          	auipc	ra,0xffffe
    800031c2:	a18080e7          	jalr	-1512(ra) # 80000bd6 <acquire>
  xticks = ticks;
    800031c6:	00006497          	auipc	s1,0x6
    800031ca:	84a4a483          	lw	s1,-1974(s1) # 80008a10 <ticks>
  release(&tickslock);
    800031ce:	00014517          	auipc	a0,0x14
    800031d2:	51a50513          	addi	a0,a0,1306 # 800176e8 <tickslock>
    800031d6:	ffffe097          	auipc	ra,0xffffe
    800031da:	ab4080e7          	jalr	-1356(ra) # 80000c8a <release>
  return xticks;
}
    800031de:	02049513          	slli	a0,s1,0x20
    800031e2:	9101                	srli	a0,a0,0x20
    800031e4:	60e2                	ld	ra,24(sp)
    800031e6:	6442                	ld	s0,16(sp)
    800031e8:	64a2                	ld	s1,8(sp)
    800031ea:	6105                	addi	sp,sp,32
    800031ec:	8082                	ret

00000000800031ee <sys_pstat>:

uint64 
sys_pstat()
{
    800031ee:	7179                	addi	sp,sp,-48
    800031f0:	f406                	sd	ra,40(sp)
    800031f2:	f022                	sd	s0,32(sp)
    800031f4:	ec26                	sd	s1,24(sp)
    800031f6:	1800                	addi	s0,sp,48
  int pid;
  argint(0, &pid);
    800031f8:	fdc40593          	addi	a1,s0,-36
    800031fc:	4501                	li	a0,0
    800031fe:	00000097          	auipc	ra,0x0
    80003202:	d2c080e7          	jalr	-724(ra) # 80002f2a <argint>
  
  struct proc *p = myproc();
    80003206:	fffff097          	auipc	ra,0xfffff
    8000320a:	a26080e7          	jalr	-1498(ra) # 80001c2c <myproc>
    8000320e:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80003210:	ffffe097          	auipc	ra,0xffffe
    80003214:	9c6080e7          	jalr	-1594(ra) # 80000bd6 <acquire>
  printf("Priority of process: %d \n",p->priority);
    80003218:	1684b583          	ld	a1,360(s1)
    8000321c:	00005517          	auipc	a0,0x5
    80003220:	3ac50513          	addi	a0,a0,940 # 800085c8 <syscalls+0xb8>
    80003224:	ffffd097          	auipc	ra,0xffffd
    80003228:	366080e7          	jalr	870(ra) # 8000058a <printf>
  printf("Number of times run: %d \n",p->contador);
    8000322c:	1704b583          	ld	a1,368(s1)
    80003230:	00005517          	auipc	a0,0x5
    80003234:	3b850513          	addi	a0,a0,952 # 800085e8 <syscalls+0xd8>
    80003238:	ffffd097          	auipc	ra,0xffffd
    8000323c:	352080e7          	jalr	850(ra) # 8000058a <printf>
  printf ("Last time executed: %d \n",p->lst);
    80003240:	1784b583          	ld	a1,376(s1)
    80003244:	00005517          	auipc	a0,0x5
    80003248:	3c450513          	addi	a0,a0,964 # 80008608 <syscalls+0xf8>
    8000324c:	ffffd097          	auipc	ra,0xffffd
    80003250:	33e080e7          	jalr	830(ra) # 8000058a <printf>
  release(&p->lock);
    80003254:	8526                	mv	a0,s1
    80003256:	ffffe097          	auipc	ra,0xffffe
    8000325a:	a34080e7          	jalr	-1484(ra) # 80000c8a <release>
return 1;
    8000325e:	4505                	li	a0,1
    80003260:	70a2                	ld	ra,40(sp)
    80003262:	7402                	ld	s0,32(sp)
    80003264:	64e2                	ld	s1,24(sp)
    80003266:	6145                	addi	sp,sp,48
    80003268:	8082                	ret

000000008000326a <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000326a:	7179                	addi	sp,sp,-48
    8000326c:	f406                	sd	ra,40(sp)
    8000326e:	f022                	sd	s0,32(sp)
    80003270:	ec26                	sd	s1,24(sp)
    80003272:	e84a                	sd	s2,16(sp)
    80003274:	e44e                	sd	s3,8(sp)
    80003276:	e052                	sd	s4,0(sp)
    80003278:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000327a:	00005597          	auipc	a1,0x5
    8000327e:	3ae58593          	addi	a1,a1,942 # 80008628 <syscalls+0x118>
    80003282:	00014517          	auipc	a0,0x14
    80003286:	47e50513          	addi	a0,a0,1150 # 80017700 <bcache>
    8000328a:	ffffe097          	auipc	ra,0xffffe
    8000328e:	8bc080e7          	jalr	-1860(ra) # 80000b46 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003292:	0001c797          	auipc	a5,0x1c
    80003296:	46e78793          	addi	a5,a5,1134 # 8001f700 <bcache+0x8000>
    8000329a:	0001c717          	auipc	a4,0x1c
    8000329e:	6ce70713          	addi	a4,a4,1742 # 8001f968 <bcache+0x8268>
    800032a2:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800032a6:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800032aa:	00014497          	auipc	s1,0x14
    800032ae:	46e48493          	addi	s1,s1,1134 # 80017718 <bcache+0x18>
    b->next = bcache.head.next;
    800032b2:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800032b4:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800032b6:	00005a17          	auipc	s4,0x5
    800032ba:	37aa0a13          	addi	s4,s4,890 # 80008630 <syscalls+0x120>
    b->next = bcache.head.next;
    800032be:	2b893783          	ld	a5,696(s2)
    800032c2:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800032c4:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800032c8:	85d2                	mv	a1,s4
    800032ca:	01048513          	addi	a0,s1,16
    800032ce:	00001097          	auipc	ra,0x1
    800032d2:	4c8080e7          	jalr	1224(ra) # 80004796 <initsleeplock>
    bcache.head.next->prev = b;
    800032d6:	2b893783          	ld	a5,696(s2)
    800032da:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800032dc:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800032e0:	45848493          	addi	s1,s1,1112
    800032e4:	fd349de3          	bne	s1,s3,800032be <binit+0x54>
  }
}
    800032e8:	70a2                	ld	ra,40(sp)
    800032ea:	7402                	ld	s0,32(sp)
    800032ec:	64e2                	ld	s1,24(sp)
    800032ee:	6942                	ld	s2,16(sp)
    800032f0:	69a2                	ld	s3,8(sp)
    800032f2:	6a02                	ld	s4,0(sp)
    800032f4:	6145                	addi	sp,sp,48
    800032f6:	8082                	ret

00000000800032f8 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800032f8:	7179                	addi	sp,sp,-48
    800032fa:	f406                	sd	ra,40(sp)
    800032fc:	f022                	sd	s0,32(sp)
    800032fe:	ec26                	sd	s1,24(sp)
    80003300:	e84a                	sd	s2,16(sp)
    80003302:	e44e                	sd	s3,8(sp)
    80003304:	1800                	addi	s0,sp,48
    80003306:	892a                	mv	s2,a0
    80003308:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    8000330a:	00014517          	auipc	a0,0x14
    8000330e:	3f650513          	addi	a0,a0,1014 # 80017700 <bcache>
    80003312:	ffffe097          	auipc	ra,0xffffe
    80003316:	8c4080e7          	jalr	-1852(ra) # 80000bd6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000331a:	0001c497          	auipc	s1,0x1c
    8000331e:	69e4b483          	ld	s1,1694(s1) # 8001f9b8 <bcache+0x82b8>
    80003322:	0001c797          	auipc	a5,0x1c
    80003326:	64678793          	addi	a5,a5,1606 # 8001f968 <bcache+0x8268>
    8000332a:	02f48f63          	beq	s1,a5,80003368 <bread+0x70>
    8000332e:	873e                	mv	a4,a5
    80003330:	a021                	j	80003338 <bread+0x40>
    80003332:	68a4                	ld	s1,80(s1)
    80003334:	02e48a63          	beq	s1,a4,80003368 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003338:	449c                	lw	a5,8(s1)
    8000333a:	ff279ce3          	bne	a5,s2,80003332 <bread+0x3a>
    8000333e:	44dc                	lw	a5,12(s1)
    80003340:	ff3799e3          	bne	a5,s3,80003332 <bread+0x3a>
      b->refcnt++;
    80003344:	40bc                	lw	a5,64(s1)
    80003346:	2785                	addiw	a5,a5,1
    80003348:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000334a:	00014517          	auipc	a0,0x14
    8000334e:	3b650513          	addi	a0,a0,950 # 80017700 <bcache>
    80003352:	ffffe097          	auipc	ra,0xffffe
    80003356:	938080e7          	jalr	-1736(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    8000335a:	01048513          	addi	a0,s1,16
    8000335e:	00001097          	auipc	ra,0x1
    80003362:	472080e7          	jalr	1138(ra) # 800047d0 <acquiresleep>
      return b;
    80003366:	a8b9                	j	800033c4 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003368:	0001c497          	auipc	s1,0x1c
    8000336c:	6484b483          	ld	s1,1608(s1) # 8001f9b0 <bcache+0x82b0>
    80003370:	0001c797          	auipc	a5,0x1c
    80003374:	5f878793          	addi	a5,a5,1528 # 8001f968 <bcache+0x8268>
    80003378:	00f48863          	beq	s1,a5,80003388 <bread+0x90>
    8000337c:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000337e:	40bc                	lw	a5,64(s1)
    80003380:	cf81                	beqz	a5,80003398 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003382:	64a4                	ld	s1,72(s1)
    80003384:	fee49de3          	bne	s1,a4,8000337e <bread+0x86>
  panic("bget: no buffers");
    80003388:	00005517          	auipc	a0,0x5
    8000338c:	2b050513          	addi	a0,a0,688 # 80008638 <syscalls+0x128>
    80003390:	ffffd097          	auipc	ra,0xffffd
    80003394:	1b0080e7          	jalr	432(ra) # 80000540 <panic>
      b->dev = dev;
    80003398:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    8000339c:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800033a0:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800033a4:	4785                	li	a5,1
    800033a6:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800033a8:	00014517          	auipc	a0,0x14
    800033ac:	35850513          	addi	a0,a0,856 # 80017700 <bcache>
    800033b0:	ffffe097          	auipc	ra,0xffffe
    800033b4:	8da080e7          	jalr	-1830(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    800033b8:	01048513          	addi	a0,s1,16
    800033bc:	00001097          	auipc	ra,0x1
    800033c0:	414080e7          	jalr	1044(ra) # 800047d0 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800033c4:	409c                	lw	a5,0(s1)
    800033c6:	cb89                	beqz	a5,800033d8 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800033c8:	8526                	mv	a0,s1
    800033ca:	70a2                	ld	ra,40(sp)
    800033cc:	7402                	ld	s0,32(sp)
    800033ce:	64e2                	ld	s1,24(sp)
    800033d0:	6942                	ld	s2,16(sp)
    800033d2:	69a2                	ld	s3,8(sp)
    800033d4:	6145                	addi	sp,sp,48
    800033d6:	8082                	ret
    virtio_disk_rw(b, 0);
    800033d8:	4581                	li	a1,0
    800033da:	8526                	mv	a0,s1
    800033dc:	00003097          	auipc	ra,0x3
    800033e0:	fd6080e7          	jalr	-42(ra) # 800063b2 <virtio_disk_rw>
    b->valid = 1;
    800033e4:	4785                	li	a5,1
    800033e6:	c09c                	sw	a5,0(s1)
  return b;
    800033e8:	b7c5                	j	800033c8 <bread+0xd0>

00000000800033ea <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800033ea:	1101                	addi	sp,sp,-32
    800033ec:	ec06                	sd	ra,24(sp)
    800033ee:	e822                	sd	s0,16(sp)
    800033f0:	e426                	sd	s1,8(sp)
    800033f2:	1000                	addi	s0,sp,32
    800033f4:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800033f6:	0541                	addi	a0,a0,16
    800033f8:	00001097          	auipc	ra,0x1
    800033fc:	472080e7          	jalr	1138(ra) # 8000486a <holdingsleep>
    80003400:	cd01                	beqz	a0,80003418 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003402:	4585                	li	a1,1
    80003404:	8526                	mv	a0,s1
    80003406:	00003097          	auipc	ra,0x3
    8000340a:	fac080e7          	jalr	-84(ra) # 800063b2 <virtio_disk_rw>
}
    8000340e:	60e2                	ld	ra,24(sp)
    80003410:	6442                	ld	s0,16(sp)
    80003412:	64a2                	ld	s1,8(sp)
    80003414:	6105                	addi	sp,sp,32
    80003416:	8082                	ret
    panic("bwrite");
    80003418:	00005517          	auipc	a0,0x5
    8000341c:	23850513          	addi	a0,a0,568 # 80008650 <syscalls+0x140>
    80003420:	ffffd097          	auipc	ra,0xffffd
    80003424:	120080e7          	jalr	288(ra) # 80000540 <panic>

0000000080003428 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003428:	1101                	addi	sp,sp,-32
    8000342a:	ec06                	sd	ra,24(sp)
    8000342c:	e822                	sd	s0,16(sp)
    8000342e:	e426                	sd	s1,8(sp)
    80003430:	e04a                	sd	s2,0(sp)
    80003432:	1000                	addi	s0,sp,32
    80003434:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003436:	01050913          	addi	s2,a0,16
    8000343a:	854a                	mv	a0,s2
    8000343c:	00001097          	auipc	ra,0x1
    80003440:	42e080e7          	jalr	1070(ra) # 8000486a <holdingsleep>
    80003444:	c92d                	beqz	a0,800034b6 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003446:	854a                	mv	a0,s2
    80003448:	00001097          	auipc	ra,0x1
    8000344c:	3de080e7          	jalr	990(ra) # 80004826 <releasesleep>

  acquire(&bcache.lock);
    80003450:	00014517          	auipc	a0,0x14
    80003454:	2b050513          	addi	a0,a0,688 # 80017700 <bcache>
    80003458:	ffffd097          	auipc	ra,0xffffd
    8000345c:	77e080e7          	jalr	1918(ra) # 80000bd6 <acquire>
  b->refcnt--;
    80003460:	40bc                	lw	a5,64(s1)
    80003462:	37fd                	addiw	a5,a5,-1
    80003464:	0007871b          	sext.w	a4,a5
    80003468:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000346a:	eb05                	bnez	a4,8000349a <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000346c:	68bc                	ld	a5,80(s1)
    8000346e:	64b8                	ld	a4,72(s1)
    80003470:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003472:	64bc                	ld	a5,72(s1)
    80003474:	68b8                	ld	a4,80(s1)
    80003476:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003478:	0001c797          	auipc	a5,0x1c
    8000347c:	28878793          	addi	a5,a5,648 # 8001f700 <bcache+0x8000>
    80003480:	2b87b703          	ld	a4,696(a5)
    80003484:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003486:	0001c717          	auipc	a4,0x1c
    8000348a:	4e270713          	addi	a4,a4,1250 # 8001f968 <bcache+0x8268>
    8000348e:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003490:	2b87b703          	ld	a4,696(a5)
    80003494:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003496:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000349a:	00014517          	auipc	a0,0x14
    8000349e:	26650513          	addi	a0,a0,614 # 80017700 <bcache>
    800034a2:	ffffd097          	auipc	ra,0xffffd
    800034a6:	7e8080e7          	jalr	2024(ra) # 80000c8a <release>
}
    800034aa:	60e2                	ld	ra,24(sp)
    800034ac:	6442                	ld	s0,16(sp)
    800034ae:	64a2                	ld	s1,8(sp)
    800034b0:	6902                	ld	s2,0(sp)
    800034b2:	6105                	addi	sp,sp,32
    800034b4:	8082                	ret
    panic("brelse");
    800034b6:	00005517          	auipc	a0,0x5
    800034ba:	1a250513          	addi	a0,a0,418 # 80008658 <syscalls+0x148>
    800034be:	ffffd097          	auipc	ra,0xffffd
    800034c2:	082080e7          	jalr	130(ra) # 80000540 <panic>

00000000800034c6 <bpin>:

void
bpin(struct buf *b) {
    800034c6:	1101                	addi	sp,sp,-32
    800034c8:	ec06                	sd	ra,24(sp)
    800034ca:	e822                	sd	s0,16(sp)
    800034cc:	e426                	sd	s1,8(sp)
    800034ce:	1000                	addi	s0,sp,32
    800034d0:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800034d2:	00014517          	auipc	a0,0x14
    800034d6:	22e50513          	addi	a0,a0,558 # 80017700 <bcache>
    800034da:	ffffd097          	auipc	ra,0xffffd
    800034de:	6fc080e7          	jalr	1788(ra) # 80000bd6 <acquire>
  b->refcnt++;
    800034e2:	40bc                	lw	a5,64(s1)
    800034e4:	2785                	addiw	a5,a5,1
    800034e6:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800034e8:	00014517          	auipc	a0,0x14
    800034ec:	21850513          	addi	a0,a0,536 # 80017700 <bcache>
    800034f0:	ffffd097          	auipc	ra,0xffffd
    800034f4:	79a080e7          	jalr	1946(ra) # 80000c8a <release>
}
    800034f8:	60e2                	ld	ra,24(sp)
    800034fa:	6442                	ld	s0,16(sp)
    800034fc:	64a2                	ld	s1,8(sp)
    800034fe:	6105                	addi	sp,sp,32
    80003500:	8082                	ret

0000000080003502 <bunpin>:

void
bunpin(struct buf *b) {
    80003502:	1101                	addi	sp,sp,-32
    80003504:	ec06                	sd	ra,24(sp)
    80003506:	e822                	sd	s0,16(sp)
    80003508:	e426                	sd	s1,8(sp)
    8000350a:	1000                	addi	s0,sp,32
    8000350c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000350e:	00014517          	auipc	a0,0x14
    80003512:	1f250513          	addi	a0,a0,498 # 80017700 <bcache>
    80003516:	ffffd097          	auipc	ra,0xffffd
    8000351a:	6c0080e7          	jalr	1728(ra) # 80000bd6 <acquire>
  b->refcnt--;
    8000351e:	40bc                	lw	a5,64(s1)
    80003520:	37fd                	addiw	a5,a5,-1
    80003522:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003524:	00014517          	auipc	a0,0x14
    80003528:	1dc50513          	addi	a0,a0,476 # 80017700 <bcache>
    8000352c:	ffffd097          	auipc	ra,0xffffd
    80003530:	75e080e7          	jalr	1886(ra) # 80000c8a <release>
}
    80003534:	60e2                	ld	ra,24(sp)
    80003536:	6442                	ld	s0,16(sp)
    80003538:	64a2                	ld	s1,8(sp)
    8000353a:	6105                	addi	sp,sp,32
    8000353c:	8082                	ret

000000008000353e <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000353e:	1101                	addi	sp,sp,-32
    80003540:	ec06                	sd	ra,24(sp)
    80003542:	e822                	sd	s0,16(sp)
    80003544:	e426                	sd	s1,8(sp)
    80003546:	e04a                	sd	s2,0(sp)
    80003548:	1000                	addi	s0,sp,32
    8000354a:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000354c:	00d5d59b          	srliw	a1,a1,0xd
    80003550:	0001d797          	auipc	a5,0x1d
    80003554:	88c7a783          	lw	a5,-1908(a5) # 8001fddc <sb+0x1c>
    80003558:	9dbd                	addw	a1,a1,a5
    8000355a:	00000097          	auipc	ra,0x0
    8000355e:	d9e080e7          	jalr	-610(ra) # 800032f8 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003562:	0074f713          	andi	a4,s1,7
    80003566:	4785                	li	a5,1
    80003568:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000356c:	14ce                	slli	s1,s1,0x33
    8000356e:	90d9                	srli	s1,s1,0x36
    80003570:	00950733          	add	a4,a0,s1
    80003574:	05874703          	lbu	a4,88(a4)
    80003578:	00e7f6b3          	and	a3,a5,a4
    8000357c:	c69d                	beqz	a3,800035aa <bfree+0x6c>
    8000357e:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003580:	94aa                	add	s1,s1,a0
    80003582:	fff7c793          	not	a5,a5
    80003586:	8f7d                	and	a4,a4,a5
    80003588:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    8000358c:	00001097          	auipc	ra,0x1
    80003590:	126080e7          	jalr	294(ra) # 800046b2 <log_write>
  brelse(bp);
    80003594:	854a                	mv	a0,s2
    80003596:	00000097          	auipc	ra,0x0
    8000359a:	e92080e7          	jalr	-366(ra) # 80003428 <brelse>
}
    8000359e:	60e2                	ld	ra,24(sp)
    800035a0:	6442                	ld	s0,16(sp)
    800035a2:	64a2                	ld	s1,8(sp)
    800035a4:	6902                	ld	s2,0(sp)
    800035a6:	6105                	addi	sp,sp,32
    800035a8:	8082                	ret
    panic("freeing free block");
    800035aa:	00005517          	auipc	a0,0x5
    800035ae:	0b650513          	addi	a0,a0,182 # 80008660 <syscalls+0x150>
    800035b2:	ffffd097          	auipc	ra,0xffffd
    800035b6:	f8e080e7          	jalr	-114(ra) # 80000540 <panic>

00000000800035ba <balloc>:
{
    800035ba:	711d                	addi	sp,sp,-96
    800035bc:	ec86                	sd	ra,88(sp)
    800035be:	e8a2                	sd	s0,80(sp)
    800035c0:	e4a6                	sd	s1,72(sp)
    800035c2:	e0ca                	sd	s2,64(sp)
    800035c4:	fc4e                	sd	s3,56(sp)
    800035c6:	f852                	sd	s4,48(sp)
    800035c8:	f456                	sd	s5,40(sp)
    800035ca:	f05a                	sd	s6,32(sp)
    800035cc:	ec5e                	sd	s7,24(sp)
    800035ce:	e862                	sd	s8,16(sp)
    800035d0:	e466                	sd	s9,8(sp)
    800035d2:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800035d4:	0001c797          	auipc	a5,0x1c
    800035d8:	7f07a783          	lw	a5,2032(a5) # 8001fdc4 <sb+0x4>
    800035dc:	cff5                	beqz	a5,800036d8 <balloc+0x11e>
    800035de:	8baa                	mv	s7,a0
    800035e0:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800035e2:	0001cb17          	auipc	s6,0x1c
    800035e6:	7deb0b13          	addi	s6,s6,2014 # 8001fdc0 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800035ea:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800035ec:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800035ee:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800035f0:	6c89                	lui	s9,0x2
    800035f2:	a061                	j	8000367a <balloc+0xc0>
        bp->data[bi/8] |= m;  // Mark block in use.
    800035f4:	97ca                	add	a5,a5,s2
    800035f6:	8e55                	or	a2,a2,a3
    800035f8:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800035fc:	854a                	mv	a0,s2
    800035fe:	00001097          	auipc	ra,0x1
    80003602:	0b4080e7          	jalr	180(ra) # 800046b2 <log_write>
        brelse(bp);
    80003606:	854a                	mv	a0,s2
    80003608:	00000097          	auipc	ra,0x0
    8000360c:	e20080e7          	jalr	-480(ra) # 80003428 <brelse>
  bp = bread(dev, bno);
    80003610:	85a6                	mv	a1,s1
    80003612:	855e                	mv	a0,s7
    80003614:	00000097          	auipc	ra,0x0
    80003618:	ce4080e7          	jalr	-796(ra) # 800032f8 <bread>
    8000361c:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000361e:	40000613          	li	a2,1024
    80003622:	4581                	li	a1,0
    80003624:	05850513          	addi	a0,a0,88
    80003628:	ffffd097          	auipc	ra,0xffffd
    8000362c:	6aa080e7          	jalr	1706(ra) # 80000cd2 <memset>
  log_write(bp);
    80003630:	854a                	mv	a0,s2
    80003632:	00001097          	auipc	ra,0x1
    80003636:	080080e7          	jalr	128(ra) # 800046b2 <log_write>
  brelse(bp);
    8000363a:	854a                	mv	a0,s2
    8000363c:	00000097          	auipc	ra,0x0
    80003640:	dec080e7          	jalr	-532(ra) # 80003428 <brelse>
}
    80003644:	8526                	mv	a0,s1
    80003646:	60e6                	ld	ra,88(sp)
    80003648:	6446                	ld	s0,80(sp)
    8000364a:	64a6                	ld	s1,72(sp)
    8000364c:	6906                	ld	s2,64(sp)
    8000364e:	79e2                	ld	s3,56(sp)
    80003650:	7a42                	ld	s4,48(sp)
    80003652:	7aa2                	ld	s5,40(sp)
    80003654:	7b02                	ld	s6,32(sp)
    80003656:	6be2                	ld	s7,24(sp)
    80003658:	6c42                	ld	s8,16(sp)
    8000365a:	6ca2                	ld	s9,8(sp)
    8000365c:	6125                	addi	sp,sp,96
    8000365e:	8082                	ret
    brelse(bp);
    80003660:	854a                	mv	a0,s2
    80003662:	00000097          	auipc	ra,0x0
    80003666:	dc6080e7          	jalr	-570(ra) # 80003428 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000366a:	015c87bb          	addw	a5,s9,s5
    8000366e:	00078a9b          	sext.w	s5,a5
    80003672:	004b2703          	lw	a4,4(s6)
    80003676:	06eaf163          	bgeu	s5,a4,800036d8 <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    8000367a:	41fad79b          	sraiw	a5,s5,0x1f
    8000367e:	0137d79b          	srliw	a5,a5,0x13
    80003682:	015787bb          	addw	a5,a5,s5
    80003686:	40d7d79b          	sraiw	a5,a5,0xd
    8000368a:	01cb2583          	lw	a1,28(s6)
    8000368e:	9dbd                	addw	a1,a1,a5
    80003690:	855e                	mv	a0,s7
    80003692:	00000097          	auipc	ra,0x0
    80003696:	c66080e7          	jalr	-922(ra) # 800032f8 <bread>
    8000369a:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000369c:	004b2503          	lw	a0,4(s6)
    800036a0:	000a849b          	sext.w	s1,s5
    800036a4:	8762                	mv	a4,s8
    800036a6:	faa4fde3          	bgeu	s1,a0,80003660 <balloc+0xa6>
      m = 1 << (bi % 8);
    800036aa:	00777693          	andi	a3,a4,7
    800036ae:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800036b2:	41f7579b          	sraiw	a5,a4,0x1f
    800036b6:	01d7d79b          	srliw	a5,a5,0x1d
    800036ba:	9fb9                	addw	a5,a5,a4
    800036bc:	4037d79b          	sraiw	a5,a5,0x3
    800036c0:	00f90633          	add	a2,s2,a5
    800036c4:	05864603          	lbu	a2,88(a2)
    800036c8:	00c6f5b3          	and	a1,a3,a2
    800036cc:	d585                	beqz	a1,800035f4 <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800036ce:	2705                	addiw	a4,a4,1
    800036d0:	2485                	addiw	s1,s1,1
    800036d2:	fd471ae3          	bne	a4,s4,800036a6 <balloc+0xec>
    800036d6:	b769                	j	80003660 <balloc+0xa6>
  printf("balloc: out of blocks\n");
    800036d8:	00005517          	auipc	a0,0x5
    800036dc:	fa050513          	addi	a0,a0,-96 # 80008678 <syscalls+0x168>
    800036e0:	ffffd097          	auipc	ra,0xffffd
    800036e4:	eaa080e7          	jalr	-342(ra) # 8000058a <printf>
  return 0;
    800036e8:	4481                	li	s1,0
    800036ea:	bfa9                	j	80003644 <balloc+0x8a>

00000000800036ec <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800036ec:	7179                	addi	sp,sp,-48
    800036ee:	f406                	sd	ra,40(sp)
    800036f0:	f022                	sd	s0,32(sp)
    800036f2:	ec26                	sd	s1,24(sp)
    800036f4:	e84a                	sd	s2,16(sp)
    800036f6:	e44e                	sd	s3,8(sp)
    800036f8:	e052                	sd	s4,0(sp)
    800036fa:	1800                	addi	s0,sp,48
    800036fc:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800036fe:	47ad                	li	a5,11
    80003700:	02b7e863          	bltu	a5,a1,80003730 <bmap+0x44>
    if((addr = ip->addrs[bn]) == 0){
    80003704:	02059793          	slli	a5,a1,0x20
    80003708:	01e7d593          	srli	a1,a5,0x1e
    8000370c:	00b504b3          	add	s1,a0,a1
    80003710:	0504a903          	lw	s2,80(s1)
    80003714:	06091e63          	bnez	s2,80003790 <bmap+0xa4>
      addr = balloc(ip->dev);
    80003718:	4108                	lw	a0,0(a0)
    8000371a:	00000097          	auipc	ra,0x0
    8000371e:	ea0080e7          	jalr	-352(ra) # 800035ba <balloc>
    80003722:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003726:	06090563          	beqz	s2,80003790 <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    8000372a:	0524a823          	sw	s2,80(s1)
    8000372e:	a08d                	j	80003790 <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003730:	ff45849b          	addiw	s1,a1,-12
    80003734:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003738:	0ff00793          	li	a5,255
    8000373c:	08e7e563          	bltu	a5,a4,800037c6 <bmap+0xda>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003740:	08052903          	lw	s2,128(a0)
    80003744:	00091d63          	bnez	s2,8000375e <bmap+0x72>
      addr = balloc(ip->dev);
    80003748:	4108                	lw	a0,0(a0)
    8000374a:	00000097          	auipc	ra,0x0
    8000374e:	e70080e7          	jalr	-400(ra) # 800035ba <balloc>
    80003752:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003756:	02090d63          	beqz	s2,80003790 <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    8000375a:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    8000375e:	85ca                	mv	a1,s2
    80003760:	0009a503          	lw	a0,0(s3)
    80003764:	00000097          	auipc	ra,0x0
    80003768:	b94080e7          	jalr	-1132(ra) # 800032f8 <bread>
    8000376c:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000376e:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003772:	02049713          	slli	a4,s1,0x20
    80003776:	01e75593          	srli	a1,a4,0x1e
    8000377a:	00b784b3          	add	s1,a5,a1
    8000377e:	0004a903          	lw	s2,0(s1)
    80003782:	02090063          	beqz	s2,800037a2 <bmap+0xb6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003786:	8552                	mv	a0,s4
    80003788:	00000097          	auipc	ra,0x0
    8000378c:	ca0080e7          	jalr	-864(ra) # 80003428 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003790:	854a                	mv	a0,s2
    80003792:	70a2                	ld	ra,40(sp)
    80003794:	7402                	ld	s0,32(sp)
    80003796:	64e2                	ld	s1,24(sp)
    80003798:	6942                	ld	s2,16(sp)
    8000379a:	69a2                	ld	s3,8(sp)
    8000379c:	6a02                	ld	s4,0(sp)
    8000379e:	6145                	addi	sp,sp,48
    800037a0:	8082                	ret
      addr = balloc(ip->dev);
    800037a2:	0009a503          	lw	a0,0(s3)
    800037a6:	00000097          	auipc	ra,0x0
    800037aa:	e14080e7          	jalr	-492(ra) # 800035ba <balloc>
    800037ae:	0005091b          	sext.w	s2,a0
      if(addr){
    800037b2:	fc090ae3          	beqz	s2,80003786 <bmap+0x9a>
        a[bn] = addr;
    800037b6:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800037ba:	8552                	mv	a0,s4
    800037bc:	00001097          	auipc	ra,0x1
    800037c0:	ef6080e7          	jalr	-266(ra) # 800046b2 <log_write>
    800037c4:	b7c9                	j	80003786 <bmap+0x9a>
  panic("bmap: out of range");
    800037c6:	00005517          	auipc	a0,0x5
    800037ca:	eca50513          	addi	a0,a0,-310 # 80008690 <syscalls+0x180>
    800037ce:	ffffd097          	auipc	ra,0xffffd
    800037d2:	d72080e7          	jalr	-654(ra) # 80000540 <panic>

00000000800037d6 <iget>:
{
    800037d6:	7179                	addi	sp,sp,-48
    800037d8:	f406                	sd	ra,40(sp)
    800037da:	f022                	sd	s0,32(sp)
    800037dc:	ec26                	sd	s1,24(sp)
    800037de:	e84a                	sd	s2,16(sp)
    800037e0:	e44e                	sd	s3,8(sp)
    800037e2:	e052                	sd	s4,0(sp)
    800037e4:	1800                	addi	s0,sp,48
    800037e6:	89aa                	mv	s3,a0
    800037e8:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800037ea:	0001c517          	auipc	a0,0x1c
    800037ee:	5f650513          	addi	a0,a0,1526 # 8001fde0 <itable>
    800037f2:	ffffd097          	auipc	ra,0xffffd
    800037f6:	3e4080e7          	jalr	996(ra) # 80000bd6 <acquire>
  empty = 0;
    800037fa:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800037fc:	0001c497          	auipc	s1,0x1c
    80003800:	5fc48493          	addi	s1,s1,1532 # 8001fdf8 <itable+0x18>
    80003804:	0001e697          	auipc	a3,0x1e
    80003808:	08468693          	addi	a3,a3,132 # 80021888 <log>
    8000380c:	a039                	j	8000381a <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000380e:	02090b63          	beqz	s2,80003844 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003812:	08848493          	addi	s1,s1,136
    80003816:	02d48a63          	beq	s1,a3,8000384a <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000381a:	449c                	lw	a5,8(s1)
    8000381c:	fef059e3          	blez	a5,8000380e <iget+0x38>
    80003820:	4098                	lw	a4,0(s1)
    80003822:	ff3716e3          	bne	a4,s3,8000380e <iget+0x38>
    80003826:	40d8                	lw	a4,4(s1)
    80003828:	ff4713e3          	bne	a4,s4,8000380e <iget+0x38>
      ip->ref++;
    8000382c:	2785                	addiw	a5,a5,1
    8000382e:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003830:	0001c517          	auipc	a0,0x1c
    80003834:	5b050513          	addi	a0,a0,1456 # 8001fde0 <itable>
    80003838:	ffffd097          	auipc	ra,0xffffd
    8000383c:	452080e7          	jalr	1106(ra) # 80000c8a <release>
      return ip;
    80003840:	8926                	mv	s2,s1
    80003842:	a03d                	j	80003870 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003844:	f7f9                	bnez	a5,80003812 <iget+0x3c>
    80003846:	8926                	mv	s2,s1
    80003848:	b7e9                	j	80003812 <iget+0x3c>
  if(empty == 0)
    8000384a:	02090c63          	beqz	s2,80003882 <iget+0xac>
  ip->dev = dev;
    8000384e:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003852:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003856:	4785                	li	a5,1
    80003858:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000385c:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003860:	0001c517          	auipc	a0,0x1c
    80003864:	58050513          	addi	a0,a0,1408 # 8001fde0 <itable>
    80003868:	ffffd097          	auipc	ra,0xffffd
    8000386c:	422080e7          	jalr	1058(ra) # 80000c8a <release>
}
    80003870:	854a                	mv	a0,s2
    80003872:	70a2                	ld	ra,40(sp)
    80003874:	7402                	ld	s0,32(sp)
    80003876:	64e2                	ld	s1,24(sp)
    80003878:	6942                	ld	s2,16(sp)
    8000387a:	69a2                	ld	s3,8(sp)
    8000387c:	6a02                	ld	s4,0(sp)
    8000387e:	6145                	addi	sp,sp,48
    80003880:	8082                	ret
    panic("iget: no inodes");
    80003882:	00005517          	auipc	a0,0x5
    80003886:	e2650513          	addi	a0,a0,-474 # 800086a8 <syscalls+0x198>
    8000388a:	ffffd097          	auipc	ra,0xffffd
    8000388e:	cb6080e7          	jalr	-842(ra) # 80000540 <panic>

0000000080003892 <fsinit>:
fsinit(int dev) {
    80003892:	7179                	addi	sp,sp,-48
    80003894:	f406                	sd	ra,40(sp)
    80003896:	f022                	sd	s0,32(sp)
    80003898:	ec26                	sd	s1,24(sp)
    8000389a:	e84a                	sd	s2,16(sp)
    8000389c:	e44e                	sd	s3,8(sp)
    8000389e:	1800                	addi	s0,sp,48
    800038a0:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800038a2:	4585                	li	a1,1
    800038a4:	00000097          	auipc	ra,0x0
    800038a8:	a54080e7          	jalr	-1452(ra) # 800032f8 <bread>
    800038ac:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800038ae:	0001c997          	auipc	s3,0x1c
    800038b2:	51298993          	addi	s3,s3,1298 # 8001fdc0 <sb>
    800038b6:	02000613          	li	a2,32
    800038ba:	05850593          	addi	a1,a0,88
    800038be:	854e                	mv	a0,s3
    800038c0:	ffffd097          	auipc	ra,0xffffd
    800038c4:	46e080e7          	jalr	1134(ra) # 80000d2e <memmove>
  brelse(bp);
    800038c8:	8526                	mv	a0,s1
    800038ca:	00000097          	auipc	ra,0x0
    800038ce:	b5e080e7          	jalr	-1186(ra) # 80003428 <brelse>
  if(sb.magic != FSMAGIC)
    800038d2:	0009a703          	lw	a4,0(s3)
    800038d6:	102037b7          	lui	a5,0x10203
    800038da:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800038de:	02f71263          	bne	a4,a5,80003902 <fsinit+0x70>
  initlog(dev, &sb);
    800038e2:	0001c597          	auipc	a1,0x1c
    800038e6:	4de58593          	addi	a1,a1,1246 # 8001fdc0 <sb>
    800038ea:	854a                	mv	a0,s2
    800038ec:	00001097          	auipc	ra,0x1
    800038f0:	b4a080e7          	jalr	-1206(ra) # 80004436 <initlog>
}
    800038f4:	70a2                	ld	ra,40(sp)
    800038f6:	7402                	ld	s0,32(sp)
    800038f8:	64e2                	ld	s1,24(sp)
    800038fa:	6942                	ld	s2,16(sp)
    800038fc:	69a2                	ld	s3,8(sp)
    800038fe:	6145                	addi	sp,sp,48
    80003900:	8082                	ret
    panic("invalid file system");
    80003902:	00005517          	auipc	a0,0x5
    80003906:	db650513          	addi	a0,a0,-586 # 800086b8 <syscalls+0x1a8>
    8000390a:	ffffd097          	auipc	ra,0xffffd
    8000390e:	c36080e7          	jalr	-970(ra) # 80000540 <panic>

0000000080003912 <iinit>:
{
    80003912:	7179                	addi	sp,sp,-48
    80003914:	f406                	sd	ra,40(sp)
    80003916:	f022                	sd	s0,32(sp)
    80003918:	ec26                	sd	s1,24(sp)
    8000391a:	e84a                	sd	s2,16(sp)
    8000391c:	e44e                	sd	s3,8(sp)
    8000391e:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003920:	00005597          	auipc	a1,0x5
    80003924:	db058593          	addi	a1,a1,-592 # 800086d0 <syscalls+0x1c0>
    80003928:	0001c517          	auipc	a0,0x1c
    8000392c:	4b850513          	addi	a0,a0,1208 # 8001fde0 <itable>
    80003930:	ffffd097          	auipc	ra,0xffffd
    80003934:	216080e7          	jalr	534(ra) # 80000b46 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003938:	0001c497          	auipc	s1,0x1c
    8000393c:	4d048493          	addi	s1,s1,1232 # 8001fe08 <itable+0x28>
    80003940:	0001e997          	auipc	s3,0x1e
    80003944:	f5898993          	addi	s3,s3,-168 # 80021898 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003948:	00005917          	auipc	s2,0x5
    8000394c:	d9090913          	addi	s2,s2,-624 # 800086d8 <syscalls+0x1c8>
    80003950:	85ca                	mv	a1,s2
    80003952:	8526                	mv	a0,s1
    80003954:	00001097          	auipc	ra,0x1
    80003958:	e42080e7          	jalr	-446(ra) # 80004796 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000395c:	08848493          	addi	s1,s1,136
    80003960:	ff3498e3          	bne	s1,s3,80003950 <iinit+0x3e>
}
    80003964:	70a2                	ld	ra,40(sp)
    80003966:	7402                	ld	s0,32(sp)
    80003968:	64e2                	ld	s1,24(sp)
    8000396a:	6942                	ld	s2,16(sp)
    8000396c:	69a2                	ld	s3,8(sp)
    8000396e:	6145                	addi	sp,sp,48
    80003970:	8082                	ret

0000000080003972 <ialloc>:
{
    80003972:	715d                	addi	sp,sp,-80
    80003974:	e486                	sd	ra,72(sp)
    80003976:	e0a2                	sd	s0,64(sp)
    80003978:	fc26                	sd	s1,56(sp)
    8000397a:	f84a                	sd	s2,48(sp)
    8000397c:	f44e                	sd	s3,40(sp)
    8000397e:	f052                	sd	s4,32(sp)
    80003980:	ec56                	sd	s5,24(sp)
    80003982:	e85a                	sd	s6,16(sp)
    80003984:	e45e                	sd	s7,8(sp)
    80003986:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003988:	0001c717          	auipc	a4,0x1c
    8000398c:	44472703          	lw	a4,1092(a4) # 8001fdcc <sb+0xc>
    80003990:	4785                	li	a5,1
    80003992:	04e7fa63          	bgeu	a5,a4,800039e6 <ialloc+0x74>
    80003996:	8aaa                	mv	s5,a0
    80003998:	8bae                	mv	s7,a1
    8000399a:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000399c:	0001ca17          	auipc	s4,0x1c
    800039a0:	424a0a13          	addi	s4,s4,1060 # 8001fdc0 <sb>
    800039a4:	00048b1b          	sext.w	s6,s1
    800039a8:	0044d593          	srli	a1,s1,0x4
    800039ac:	018a2783          	lw	a5,24(s4)
    800039b0:	9dbd                	addw	a1,a1,a5
    800039b2:	8556                	mv	a0,s5
    800039b4:	00000097          	auipc	ra,0x0
    800039b8:	944080e7          	jalr	-1724(ra) # 800032f8 <bread>
    800039bc:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800039be:	05850993          	addi	s3,a0,88
    800039c2:	00f4f793          	andi	a5,s1,15
    800039c6:	079a                	slli	a5,a5,0x6
    800039c8:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800039ca:	00099783          	lh	a5,0(s3)
    800039ce:	c3a1                	beqz	a5,80003a0e <ialloc+0x9c>
    brelse(bp);
    800039d0:	00000097          	auipc	ra,0x0
    800039d4:	a58080e7          	jalr	-1448(ra) # 80003428 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800039d8:	0485                	addi	s1,s1,1
    800039da:	00ca2703          	lw	a4,12(s4)
    800039de:	0004879b          	sext.w	a5,s1
    800039e2:	fce7e1e3          	bltu	a5,a4,800039a4 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    800039e6:	00005517          	auipc	a0,0x5
    800039ea:	cfa50513          	addi	a0,a0,-774 # 800086e0 <syscalls+0x1d0>
    800039ee:	ffffd097          	auipc	ra,0xffffd
    800039f2:	b9c080e7          	jalr	-1124(ra) # 8000058a <printf>
  return 0;
    800039f6:	4501                	li	a0,0
}
    800039f8:	60a6                	ld	ra,72(sp)
    800039fa:	6406                	ld	s0,64(sp)
    800039fc:	74e2                	ld	s1,56(sp)
    800039fe:	7942                	ld	s2,48(sp)
    80003a00:	79a2                	ld	s3,40(sp)
    80003a02:	7a02                	ld	s4,32(sp)
    80003a04:	6ae2                	ld	s5,24(sp)
    80003a06:	6b42                	ld	s6,16(sp)
    80003a08:	6ba2                	ld	s7,8(sp)
    80003a0a:	6161                	addi	sp,sp,80
    80003a0c:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003a0e:	04000613          	li	a2,64
    80003a12:	4581                	li	a1,0
    80003a14:	854e                	mv	a0,s3
    80003a16:	ffffd097          	auipc	ra,0xffffd
    80003a1a:	2bc080e7          	jalr	700(ra) # 80000cd2 <memset>
      dip->type = type;
    80003a1e:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003a22:	854a                	mv	a0,s2
    80003a24:	00001097          	auipc	ra,0x1
    80003a28:	c8e080e7          	jalr	-882(ra) # 800046b2 <log_write>
      brelse(bp);
    80003a2c:	854a                	mv	a0,s2
    80003a2e:	00000097          	auipc	ra,0x0
    80003a32:	9fa080e7          	jalr	-1542(ra) # 80003428 <brelse>
      return iget(dev, inum);
    80003a36:	85da                	mv	a1,s6
    80003a38:	8556                	mv	a0,s5
    80003a3a:	00000097          	auipc	ra,0x0
    80003a3e:	d9c080e7          	jalr	-612(ra) # 800037d6 <iget>
    80003a42:	bf5d                	j	800039f8 <ialloc+0x86>

0000000080003a44 <iupdate>:
{
    80003a44:	1101                	addi	sp,sp,-32
    80003a46:	ec06                	sd	ra,24(sp)
    80003a48:	e822                	sd	s0,16(sp)
    80003a4a:	e426                	sd	s1,8(sp)
    80003a4c:	e04a                	sd	s2,0(sp)
    80003a4e:	1000                	addi	s0,sp,32
    80003a50:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003a52:	415c                	lw	a5,4(a0)
    80003a54:	0047d79b          	srliw	a5,a5,0x4
    80003a58:	0001c597          	auipc	a1,0x1c
    80003a5c:	3805a583          	lw	a1,896(a1) # 8001fdd8 <sb+0x18>
    80003a60:	9dbd                	addw	a1,a1,a5
    80003a62:	4108                	lw	a0,0(a0)
    80003a64:	00000097          	auipc	ra,0x0
    80003a68:	894080e7          	jalr	-1900(ra) # 800032f8 <bread>
    80003a6c:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003a6e:	05850793          	addi	a5,a0,88
    80003a72:	40d8                	lw	a4,4(s1)
    80003a74:	8b3d                	andi	a4,a4,15
    80003a76:	071a                	slli	a4,a4,0x6
    80003a78:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003a7a:	04449703          	lh	a4,68(s1)
    80003a7e:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003a82:	04649703          	lh	a4,70(s1)
    80003a86:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003a8a:	04849703          	lh	a4,72(s1)
    80003a8e:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003a92:	04a49703          	lh	a4,74(s1)
    80003a96:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003a9a:	44f8                	lw	a4,76(s1)
    80003a9c:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003a9e:	03400613          	li	a2,52
    80003aa2:	05048593          	addi	a1,s1,80
    80003aa6:	00c78513          	addi	a0,a5,12
    80003aaa:	ffffd097          	auipc	ra,0xffffd
    80003aae:	284080e7          	jalr	644(ra) # 80000d2e <memmove>
  log_write(bp);
    80003ab2:	854a                	mv	a0,s2
    80003ab4:	00001097          	auipc	ra,0x1
    80003ab8:	bfe080e7          	jalr	-1026(ra) # 800046b2 <log_write>
  brelse(bp);
    80003abc:	854a                	mv	a0,s2
    80003abe:	00000097          	auipc	ra,0x0
    80003ac2:	96a080e7          	jalr	-1686(ra) # 80003428 <brelse>
}
    80003ac6:	60e2                	ld	ra,24(sp)
    80003ac8:	6442                	ld	s0,16(sp)
    80003aca:	64a2                	ld	s1,8(sp)
    80003acc:	6902                	ld	s2,0(sp)
    80003ace:	6105                	addi	sp,sp,32
    80003ad0:	8082                	ret

0000000080003ad2 <idup>:
{
    80003ad2:	1101                	addi	sp,sp,-32
    80003ad4:	ec06                	sd	ra,24(sp)
    80003ad6:	e822                	sd	s0,16(sp)
    80003ad8:	e426                	sd	s1,8(sp)
    80003ada:	1000                	addi	s0,sp,32
    80003adc:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003ade:	0001c517          	auipc	a0,0x1c
    80003ae2:	30250513          	addi	a0,a0,770 # 8001fde0 <itable>
    80003ae6:	ffffd097          	auipc	ra,0xffffd
    80003aea:	0f0080e7          	jalr	240(ra) # 80000bd6 <acquire>
  ip->ref++;
    80003aee:	449c                	lw	a5,8(s1)
    80003af0:	2785                	addiw	a5,a5,1
    80003af2:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003af4:	0001c517          	auipc	a0,0x1c
    80003af8:	2ec50513          	addi	a0,a0,748 # 8001fde0 <itable>
    80003afc:	ffffd097          	auipc	ra,0xffffd
    80003b00:	18e080e7          	jalr	398(ra) # 80000c8a <release>
}
    80003b04:	8526                	mv	a0,s1
    80003b06:	60e2                	ld	ra,24(sp)
    80003b08:	6442                	ld	s0,16(sp)
    80003b0a:	64a2                	ld	s1,8(sp)
    80003b0c:	6105                	addi	sp,sp,32
    80003b0e:	8082                	ret

0000000080003b10 <ilock>:
{
    80003b10:	1101                	addi	sp,sp,-32
    80003b12:	ec06                	sd	ra,24(sp)
    80003b14:	e822                	sd	s0,16(sp)
    80003b16:	e426                	sd	s1,8(sp)
    80003b18:	e04a                	sd	s2,0(sp)
    80003b1a:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003b1c:	c115                	beqz	a0,80003b40 <ilock+0x30>
    80003b1e:	84aa                	mv	s1,a0
    80003b20:	451c                	lw	a5,8(a0)
    80003b22:	00f05f63          	blez	a5,80003b40 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003b26:	0541                	addi	a0,a0,16
    80003b28:	00001097          	auipc	ra,0x1
    80003b2c:	ca8080e7          	jalr	-856(ra) # 800047d0 <acquiresleep>
  if(ip->valid == 0){
    80003b30:	40bc                	lw	a5,64(s1)
    80003b32:	cf99                	beqz	a5,80003b50 <ilock+0x40>
}
    80003b34:	60e2                	ld	ra,24(sp)
    80003b36:	6442                	ld	s0,16(sp)
    80003b38:	64a2                	ld	s1,8(sp)
    80003b3a:	6902                	ld	s2,0(sp)
    80003b3c:	6105                	addi	sp,sp,32
    80003b3e:	8082                	ret
    panic("ilock");
    80003b40:	00005517          	auipc	a0,0x5
    80003b44:	bb850513          	addi	a0,a0,-1096 # 800086f8 <syscalls+0x1e8>
    80003b48:	ffffd097          	auipc	ra,0xffffd
    80003b4c:	9f8080e7          	jalr	-1544(ra) # 80000540 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003b50:	40dc                	lw	a5,4(s1)
    80003b52:	0047d79b          	srliw	a5,a5,0x4
    80003b56:	0001c597          	auipc	a1,0x1c
    80003b5a:	2825a583          	lw	a1,642(a1) # 8001fdd8 <sb+0x18>
    80003b5e:	9dbd                	addw	a1,a1,a5
    80003b60:	4088                	lw	a0,0(s1)
    80003b62:	fffff097          	auipc	ra,0xfffff
    80003b66:	796080e7          	jalr	1942(ra) # 800032f8 <bread>
    80003b6a:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003b6c:	05850593          	addi	a1,a0,88
    80003b70:	40dc                	lw	a5,4(s1)
    80003b72:	8bbd                	andi	a5,a5,15
    80003b74:	079a                	slli	a5,a5,0x6
    80003b76:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003b78:	00059783          	lh	a5,0(a1)
    80003b7c:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003b80:	00259783          	lh	a5,2(a1)
    80003b84:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003b88:	00459783          	lh	a5,4(a1)
    80003b8c:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003b90:	00659783          	lh	a5,6(a1)
    80003b94:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003b98:	459c                	lw	a5,8(a1)
    80003b9a:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003b9c:	03400613          	li	a2,52
    80003ba0:	05b1                	addi	a1,a1,12
    80003ba2:	05048513          	addi	a0,s1,80
    80003ba6:	ffffd097          	auipc	ra,0xffffd
    80003baa:	188080e7          	jalr	392(ra) # 80000d2e <memmove>
    brelse(bp);
    80003bae:	854a                	mv	a0,s2
    80003bb0:	00000097          	auipc	ra,0x0
    80003bb4:	878080e7          	jalr	-1928(ra) # 80003428 <brelse>
    ip->valid = 1;
    80003bb8:	4785                	li	a5,1
    80003bba:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003bbc:	04449783          	lh	a5,68(s1)
    80003bc0:	fbb5                	bnez	a5,80003b34 <ilock+0x24>
      panic("ilock: no type");
    80003bc2:	00005517          	auipc	a0,0x5
    80003bc6:	b3e50513          	addi	a0,a0,-1218 # 80008700 <syscalls+0x1f0>
    80003bca:	ffffd097          	auipc	ra,0xffffd
    80003bce:	976080e7          	jalr	-1674(ra) # 80000540 <panic>

0000000080003bd2 <iunlock>:
{
    80003bd2:	1101                	addi	sp,sp,-32
    80003bd4:	ec06                	sd	ra,24(sp)
    80003bd6:	e822                	sd	s0,16(sp)
    80003bd8:	e426                	sd	s1,8(sp)
    80003bda:	e04a                	sd	s2,0(sp)
    80003bdc:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003bde:	c905                	beqz	a0,80003c0e <iunlock+0x3c>
    80003be0:	84aa                	mv	s1,a0
    80003be2:	01050913          	addi	s2,a0,16
    80003be6:	854a                	mv	a0,s2
    80003be8:	00001097          	auipc	ra,0x1
    80003bec:	c82080e7          	jalr	-894(ra) # 8000486a <holdingsleep>
    80003bf0:	cd19                	beqz	a0,80003c0e <iunlock+0x3c>
    80003bf2:	449c                	lw	a5,8(s1)
    80003bf4:	00f05d63          	blez	a5,80003c0e <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003bf8:	854a                	mv	a0,s2
    80003bfa:	00001097          	auipc	ra,0x1
    80003bfe:	c2c080e7          	jalr	-980(ra) # 80004826 <releasesleep>
}
    80003c02:	60e2                	ld	ra,24(sp)
    80003c04:	6442                	ld	s0,16(sp)
    80003c06:	64a2                	ld	s1,8(sp)
    80003c08:	6902                	ld	s2,0(sp)
    80003c0a:	6105                	addi	sp,sp,32
    80003c0c:	8082                	ret
    panic("iunlock");
    80003c0e:	00005517          	auipc	a0,0x5
    80003c12:	b0250513          	addi	a0,a0,-1278 # 80008710 <syscalls+0x200>
    80003c16:	ffffd097          	auipc	ra,0xffffd
    80003c1a:	92a080e7          	jalr	-1750(ra) # 80000540 <panic>

0000000080003c1e <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003c1e:	7179                	addi	sp,sp,-48
    80003c20:	f406                	sd	ra,40(sp)
    80003c22:	f022                	sd	s0,32(sp)
    80003c24:	ec26                	sd	s1,24(sp)
    80003c26:	e84a                	sd	s2,16(sp)
    80003c28:	e44e                	sd	s3,8(sp)
    80003c2a:	e052                	sd	s4,0(sp)
    80003c2c:	1800                	addi	s0,sp,48
    80003c2e:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003c30:	05050493          	addi	s1,a0,80
    80003c34:	08050913          	addi	s2,a0,128
    80003c38:	a021                	j	80003c40 <itrunc+0x22>
    80003c3a:	0491                	addi	s1,s1,4
    80003c3c:	01248d63          	beq	s1,s2,80003c56 <itrunc+0x38>
    if(ip->addrs[i]){
    80003c40:	408c                	lw	a1,0(s1)
    80003c42:	dde5                	beqz	a1,80003c3a <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003c44:	0009a503          	lw	a0,0(s3)
    80003c48:	00000097          	auipc	ra,0x0
    80003c4c:	8f6080e7          	jalr	-1802(ra) # 8000353e <bfree>
      ip->addrs[i] = 0;
    80003c50:	0004a023          	sw	zero,0(s1)
    80003c54:	b7dd                	j	80003c3a <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003c56:	0809a583          	lw	a1,128(s3)
    80003c5a:	e185                	bnez	a1,80003c7a <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003c5c:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003c60:	854e                	mv	a0,s3
    80003c62:	00000097          	auipc	ra,0x0
    80003c66:	de2080e7          	jalr	-542(ra) # 80003a44 <iupdate>
}
    80003c6a:	70a2                	ld	ra,40(sp)
    80003c6c:	7402                	ld	s0,32(sp)
    80003c6e:	64e2                	ld	s1,24(sp)
    80003c70:	6942                	ld	s2,16(sp)
    80003c72:	69a2                	ld	s3,8(sp)
    80003c74:	6a02                	ld	s4,0(sp)
    80003c76:	6145                	addi	sp,sp,48
    80003c78:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003c7a:	0009a503          	lw	a0,0(s3)
    80003c7e:	fffff097          	auipc	ra,0xfffff
    80003c82:	67a080e7          	jalr	1658(ra) # 800032f8 <bread>
    80003c86:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003c88:	05850493          	addi	s1,a0,88
    80003c8c:	45850913          	addi	s2,a0,1112
    80003c90:	a021                	j	80003c98 <itrunc+0x7a>
    80003c92:	0491                	addi	s1,s1,4
    80003c94:	01248b63          	beq	s1,s2,80003caa <itrunc+0x8c>
      if(a[j])
    80003c98:	408c                	lw	a1,0(s1)
    80003c9a:	dde5                	beqz	a1,80003c92 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003c9c:	0009a503          	lw	a0,0(s3)
    80003ca0:	00000097          	auipc	ra,0x0
    80003ca4:	89e080e7          	jalr	-1890(ra) # 8000353e <bfree>
    80003ca8:	b7ed                	j	80003c92 <itrunc+0x74>
    brelse(bp);
    80003caa:	8552                	mv	a0,s4
    80003cac:	fffff097          	auipc	ra,0xfffff
    80003cb0:	77c080e7          	jalr	1916(ra) # 80003428 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003cb4:	0809a583          	lw	a1,128(s3)
    80003cb8:	0009a503          	lw	a0,0(s3)
    80003cbc:	00000097          	auipc	ra,0x0
    80003cc0:	882080e7          	jalr	-1918(ra) # 8000353e <bfree>
    ip->addrs[NDIRECT] = 0;
    80003cc4:	0809a023          	sw	zero,128(s3)
    80003cc8:	bf51                	j	80003c5c <itrunc+0x3e>

0000000080003cca <iput>:
{
    80003cca:	1101                	addi	sp,sp,-32
    80003ccc:	ec06                	sd	ra,24(sp)
    80003cce:	e822                	sd	s0,16(sp)
    80003cd0:	e426                	sd	s1,8(sp)
    80003cd2:	e04a                	sd	s2,0(sp)
    80003cd4:	1000                	addi	s0,sp,32
    80003cd6:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003cd8:	0001c517          	auipc	a0,0x1c
    80003cdc:	10850513          	addi	a0,a0,264 # 8001fde0 <itable>
    80003ce0:	ffffd097          	auipc	ra,0xffffd
    80003ce4:	ef6080e7          	jalr	-266(ra) # 80000bd6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003ce8:	4498                	lw	a4,8(s1)
    80003cea:	4785                	li	a5,1
    80003cec:	02f70363          	beq	a4,a5,80003d12 <iput+0x48>
  ip->ref--;
    80003cf0:	449c                	lw	a5,8(s1)
    80003cf2:	37fd                	addiw	a5,a5,-1
    80003cf4:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003cf6:	0001c517          	auipc	a0,0x1c
    80003cfa:	0ea50513          	addi	a0,a0,234 # 8001fde0 <itable>
    80003cfe:	ffffd097          	auipc	ra,0xffffd
    80003d02:	f8c080e7          	jalr	-116(ra) # 80000c8a <release>
}
    80003d06:	60e2                	ld	ra,24(sp)
    80003d08:	6442                	ld	s0,16(sp)
    80003d0a:	64a2                	ld	s1,8(sp)
    80003d0c:	6902                	ld	s2,0(sp)
    80003d0e:	6105                	addi	sp,sp,32
    80003d10:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003d12:	40bc                	lw	a5,64(s1)
    80003d14:	dff1                	beqz	a5,80003cf0 <iput+0x26>
    80003d16:	04a49783          	lh	a5,74(s1)
    80003d1a:	fbf9                	bnez	a5,80003cf0 <iput+0x26>
    acquiresleep(&ip->lock);
    80003d1c:	01048913          	addi	s2,s1,16
    80003d20:	854a                	mv	a0,s2
    80003d22:	00001097          	auipc	ra,0x1
    80003d26:	aae080e7          	jalr	-1362(ra) # 800047d0 <acquiresleep>
    release(&itable.lock);
    80003d2a:	0001c517          	auipc	a0,0x1c
    80003d2e:	0b650513          	addi	a0,a0,182 # 8001fde0 <itable>
    80003d32:	ffffd097          	auipc	ra,0xffffd
    80003d36:	f58080e7          	jalr	-168(ra) # 80000c8a <release>
    itrunc(ip);
    80003d3a:	8526                	mv	a0,s1
    80003d3c:	00000097          	auipc	ra,0x0
    80003d40:	ee2080e7          	jalr	-286(ra) # 80003c1e <itrunc>
    ip->type = 0;
    80003d44:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003d48:	8526                	mv	a0,s1
    80003d4a:	00000097          	auipc	ra,0x0
    80003d4e:	cfa080e7          	jalr	-774(ra) # 80003a44 <iupdate>
    ip->valid = 0;
    80003d52:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003d56:	854a                	mv	a0,s2
    80003d58:	00001097          	auipc	ra,0x1
    80003d5c:	ace080e7          	jalr	-1330(ra) # 80004826 <releasesleep>
    acquire(&itable.lock);
    80003d60:	0001c517          	auipc	a0,0x1c
    80003d64:	08050513          	addi	a0,a0,128 # 8001fde0 <itable>
    80003d68:	ffffd097          	auipc	ra,0xffffd
    80003d6c:	e6e080e7          	jalr	-402(ra) # 80000bd6 <acquire>
    80003d70:	b741                	j	80003cf0 <iput+0x26>

0000000080003d72 <iunlockput>:
{
    80003d72:	1101                	addi	sp,sp,-32
    80003d74:	ec06                	sd	ra,24(sp)
    80003d76:	e822                	sd	s0,16(sp)
    80003d78:	e426                	sd	s1,8(sp)
    80003d7a:	1000                	addi	s0,sp,32
    80003d7c:	84aa                	mv	s1,a0
  iunlock(ip);
    80003d7e:	00000097          	auipc	ra,0x0
    80003d82:	e54080e7          	jalr	-428(ra) # 80003bd2 <iunlock>
  iput(ip);
    80003d86:	8526                	mv	a0,s1
    80003d88:	00000097          	auipc	ra,0x0
    80003d8c:	f42080e7          	jalr	-190(ra) # 80003cca <iput>
}
    80003d90:	60e2                	ld	ra,24(sp)
    80003d92:	6442                	ld	s0,16(sp)
    80003d94:	64a2                	ld	s1,8(sp)
    80003d96:	6105                	addi	sp,sp,32
    80003d98:	8082                	ret

0000000080003d9a <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003d9a:	1141                	addi	sp,sp,-16
    80003d9c:	e422                	sd	s0,8(sp)
    80003d9e:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003da0:	411c                	lw	a5,0(a0)
    80003da2:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003da4:	415c                	lw	a5,4(a0)
    80003da6:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003da8:	04451783          	lh	a5,68(a0)
    80003dac:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003db0:	04a51783          	lh	a5,74(a0)
    80003db4:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003db8:	04c56783          	lwu	a5,76(a0)
    80003dbc:	e99c                	sd	a5,16(a1)
}
    80003dbe:	6422                	ld	s0,8(sp)
    80003dc0:	0141                	addi	sp,sp,16
    80003dc2:	8082                	ret

0000000080003dc4 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003dc4:	457c                	lw	a5,76(a0)
    80003dc6:	0ed7e963          	bltu	a5,a3,80003eb8 <readi+0xf4>
{
    80003dca:	7159                	addi	sp,sp,-112
    80003dcc:	f486                	sd	ra,104(sp)
    80003dce:	f0a2                	sd	s0,96(sp)
    80003dd0:	eca6                	sd	s1,88(sp)
    80003dd2:	e8ca                	sd	s2,80(sp)
    80003dd4:	e4ce                	sd	s3,72(sp)
    80003dd6:	e0d2                	sd	s4,64(sp)
    80003dd8:	fc56                	sd	s5,56(sp)
    80003dda:	f85a                	sd	s6,48(sp)
    80003ddc:	f45e                	sd	s7,40(sp)
    80003dde:	f062                	sd	s8,32(sp)
    80003de0:	ec66                	sd	s9,24(sp)
    80003de2:	e86a                	sd	s10,16(sp)
    80003de4:	e46e                	sd	s11,8(sp)
    80003de6:	1880                	addi	s0,sp,112
    80003de8:	8b2a                	mv	s6,a0
    80003dea:	8bae                	mv	s7,a1
    80003dec:	8a32                	mv	s4,a2
    80003dee:	84b6                	mv	s1,a3
    80003df0:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003df2:	9f35                	addw	a4,a4,a3
    return 0;
    80003df4:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003df6:	0ad76063          	bltu	a4,a3,80003e96 <readi+0xd2>
  if(off + n > ip->size)
    80003dfa:	00e7f463          	bgeu	a5,a4,80003e02 <readi+0x3e>
    n = ip->size - off;
    80003dfe:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003e02:	0a0a8963          	beqz	s5,80003eb4 <readi+0xf0>
    80003e06:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003e08:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003e0c:	5c7d                	li	s8,-1
    80003e0e:	a82d                	j	80003e48 <readi+0x84>
    80003e10:	020d1d93          	slli	s11,s10,0x20
    80003e14:	020ddd93          	srli	s11,s11,0x20
    80003e18:	05890613          	addi	a2,s2,88
    80003e1c:	86ee                	mv	a3,s11
    80003e1e:	963a                	add	a2,a2,a4
    80003e20:	85d2                	mv	a1,s4
    80003e22:	855e                	mv	a0,s7
    80003e24:	fffff097          	auipc	ra,0xfffff
    80003e28:	a9c080e7          	jalr	-1380(ra) # 800028c0 <either_copyout>
    80003e2c:	05850d63          	beq	a0,s8,80003e86 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003e30:	854a                	mv	a0,s2
    80003e32:	fffff097          	auipc	ra,0xfffff
    80003e36:	5f6080e7          	jalr	1526(ra) # 80003428 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003e3a:	013d09bb          	addw	s3,s10,s3
    80003e3e:	009d04bb          	addw	s1,s10,s1
    80003e42:	9a6e                	add	s4,s4,s11
    80003e44:	0559f763          	bgeu	s3,s5,80003e92 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003e48:	00a4d59b          	srliw	a1,s1,0xa
    80003e4c:	855a                	mv	a0,s6
    80003e4e:	00000097          	auipc	ra,0x0
    80003e52:	89e080e7          	jalr	-1890(ra) # 800036ec <bmap>
    80003e56:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003e5a:	cd85                	beqz	a1,80003e92 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003e5c:	000b2503          	lw	a0,0(s6)
    80003e60:	fffff097          	auipc	ra,0xfffff
    80003e64:	498080e7          	jalr	1176(ra) # 800032f8 <bread>
    80003e68:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003e6a:	3ff4f713          	andi	a4,s1,1023
    80003e6e:	40ec87bb          	subw	a5,s9,a4
    80003e72:	413a86bb          	subw	a3,s5,s3
    80003e76:	8d3e                	mv	s10,a5
    80003e78:	2781                	sext.w	a5,a5
    80003e7a:	0006861b          	sext.w	a2,a3
    80003e7e:	f8f679e3          	bgeu	a2,a5,80003e10 <readi+0x4c>
    80003e82:	8d36                	mv	s10,a3
    80003e84:	b771                	j	80003e10 <readi+0x4c>
      brelse(bp);
    80003e86:	854a                	mv	a0,s2
    80003e88:	fffff097          	auipc	ra,0xfffff
    80003e8c:	5a0080e7          	jalr	1440(ra) # 80003428 <brelse>
      tot = -1;
    80003e90:	59fd                	li	s3,-1
  }
  return tot;
    80003e92:	0009851b          	sext.w	a0,s3
}
    80003e96:	70a6                	ld	ra,104(sp)
    80003e98:	7406                	ld	s0,96(sp)
    80003e9a:	64e6                	ld	s1,88(sp)
    80003e9c:	6946                	ld	s2,80(sp)
    80003e9e:	69a6                	ld	s3,72(sp)
    80003ea0:	6a06                	ld	s4,64(sp)
    80003ea2:	7ae2                	ld	s5,56(sp)
    80003ea4:	7b42                	ld	s6,48(sp)
    80003ea6:	7ba2                	ld	s7,40(sp)
    80003ea8:	7c02                	ld	s8,32(sp)
    80003eaa:	6ce2                	ld	s9,24(sp)
    80003eac:	6d42                	ld	s10,16(sp)
    80003eae:	6da2                	ld	s11,8(sp)
    80003eb0:	6165                	addi	sp,sp,112
    80003eb2:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003eb4:	89d6                	mv	s3,s5
    80003eb6:	bff1                	j	80003e92 <readi+0xce>
    return 0;
    80003eb8:	4501                	li	a0,0
}
    80003eba:	8082                	ret

0000000080003ebc <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003ebc:	457c                	lw	a5,76(a0)
    80003ebe:	10d7e863          	bltu	a5,a3,80003fce <writei+0x112>
{
    80003ec2:	7159                	addi	sp,sp,-112
    80003ec4:	f486                	sd	ra,104(sp)
    80003ec6:	f0a2                	sd	s0,96(sp)
    80003ec8:	eca6                	sd	s1,88(sp)
    80003eca:	e8ca                	sd	s2,80(sp)
    80003ecc:	e4ce                	sd	s3,72(sp)
    80003ece:	e0d2                	sd	s4,64(sp)
    80003ed0:	fc56                	sd	s5,56(sp)
    80003ed2:	f85a                	sd	s6,48(sp)
    80003ed4:	f45e                	sd	s7,40(sp)
    80003ed6:	f062                	sd	s8,32(sp)
    80003ed8:	ec66                	sd	s9,24(sp)
    80003eda:	e86a                	sd	s10,16(sp)
    80003edc:	e46e                	sd	s11,8(sp)
    80003ede:	1880                	addi	s0,sp,112
    80003ee0:	8aaa                	mv	s5,a0
    80003ee2:	8bae                	mv	s7,a1
    80003ee4:	8a32                	mv	s4,a2
    80003ee6:	8936                	mv	s2,a3
    80003ee8:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003eea:	00e687bb          	addw	a5,a3,a4
    80003eee:	0ed7e263          	bltu	a5,a3,80003fd2 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003ef2:	00043737          	lui	a4,0x43
    80003ef6:	0ef76063          	bltu	a4,a5,80003fd6 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003efa:	0c0b0863          	beqz	s6,80003fca <writei+0x10e>
    80003efe:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f00:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003f04:	5c7d                	li	s8,-1
    80003f06:	a091                	j	80003f4a <writei+0x8e>
    80003f08:	020d1d93          	slli	s11,s10,0x20
    80003f0c:	020ddd93          	srli	s11,s11,0x20
    80003f10:	05848513          	addi	a0,s1,88
    80003f14:	86ee                	mv	a3,s11
    80003f16:	8652                	mv	a2,s4
    80003f18:	85de                	mv	a1,s7
    80003f1a:	953a                	add	a0,a0,a4
    80003f1c:	fffff097          	auipc	ra,0xfffff
    80003f20:	9fa080e7          	jalr	-1542(ra) # 80002916 <either_copyin>
    80003f24:	07850263          	beq	a0,s8,80003f88 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003f28:	8526                	mv	a0,s1
    80003f2a:	00000097          	auipc	ra,0x0
    80003f2e:	788080e7          	jalr	1928(ra) # 800046b2 <log_write>
    brelse(bp);
    80003f32:	8526                	mv	a0,s1
    80003f34:	fffff097          	auipc	ra,0xfffff
    80003f38:	4f4080e7          	jalr	1268(ra) # 80003428 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003f3c:	013d09bb          	addw	s3,s10,s3
    80003f40:	012d093b          	addw	s2,s10,s2
    80003f44:	9a6e                	add	s4,s4,s11
    80003f46:	0569f663          	bgeu	s3,s6,80003f92 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003f4a:	00a9559b          	srliw	a1,s2,0xa
    80003f4e:	8556                	mv	a0,s5
    80003f50:	fffff097          	auipc	ra,0xfffff
    80003f54:	79c080e7          	jalr	1948(ra) # 800036ec <bmap>
    80003f58:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003f5c:	c99d                	beqz	a1,80003f92 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003f5e:	000aa503          	lw	a0,0(s5)
    80003f62:	fffff097          	auipc	ra,0xfffff
    80003f66:	396080e7          	jalr	918(ra) # 800032f8 <bread>
    80003f6a:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f6c:	3ff97713          	andi	a4,s2,1023
    80003f70:	40ec87bb          	subw	a5,s9,a4
    80003f74:	413b06bb          	subw	a3,s6,s3
    80003f78:	8d3e                	mv	s10,a5
    80003f7a:	2781                	sext.w	a5,a5
    80003f7c:	0006861b          	sext.w	a2,a3
    80003f80:	f8f674e3          	bgeu	a2,a5,80003f08 <writei+0x4c>
    80003f84:	8d36                	mv	s10,a3
    80003f86:	b749                	j	80003f08 <writei+0x4c>
      brelse(bp);
    80003f88:	8526                	mv	a0,s1
    80003f8a:	fffff097          	auipc	ra,0xfffff
    80003f8e:	49e080e7          	jalr	1182(ra) # 80003428 <brelse>
  }

  if(off > ip->size)
    80003f92:	04caa783          	lw	a5,76(s5)
    80003f96:	0127f463          	bgeu	a5,s2,80003f9e <writei+0xe2>
    ip->size = off;
    80003f9a:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003f9e:	8556                	mv	a0,s5
    80003fa0:	00000097          	auipc	ra,0x0
    80003fa4:	aa4080e7          	jalr	-1372(ra) # 80003a44 <iupdate>

  return tot;
    80003fa8:	0009851b          	sext.w	a0,s3
}
    80003fac:	70a6                	ld	ra,104(sp)
    80003fae:	7406                	ld	s0,96(sp)
    80003fb0:	64e6                	ld	s1,88(sp)
    80003fb2:	6946                	ld	s2,80(sp)
    80003fb4:	69a6                	ld	s3,72(sp)
    80003fb6:	6a06                	ld	s4,64(sp)
    80003fb8:	7ae2                	ld	s5,56(sp)
    80003fba:	7b42                	ld	s6,48(sp)
    80003fbc:	7ba2                	ld	s7,40(sp)
    80003fbe:	7c02                	ld	s8,32(sp)
    80003fc0:	6ce2                	ld	s9,24(sp)
    80003fc2:	6d42                	ld	s10,16(sp)
    80003fc4:	6da2                	ld	s11,8(sp)
    80003fc6:	6165                	addi	sp,sp,112
    80003fc8:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003fca:	89da                	mv	s3,s6
    80003fcc:	bfc9                	j	80003f9e <writei+0xe2>
    return -1;
    80003fce:	557d                	li	a0,-1
}
    80003fd0:	8082                	ret
    return -1;
    80003fd2:	557d                	li	a0,-1
    80003fd4:	bfe1                	j	80003fac <writei+0xf0>
    return -1;
    80003fd6:	557d                	li	a0,-1
    80003fd8:	bfd1                	j	80003fac <writei+0xf0>

0000000080003fda <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003fda:	1141                	addi	sp,sp,-16
    80003fdc:	e406                	sd	ra,8(sp)
    80003fde:	e022                	sd	s0,0(sp)
    80003fe0:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003fe2:	4639                	li	a2,14
    80003fe4:	ffffd097          	auipc	ra,0xffffd
    80003fe8:	dbe080e7          	jalr	-578(ra) # 80000da2 <strncmp>
}
    80003fec:	60a2                	ld	ra,8(sp)
    80003fee:	6402                	ld	s0,0(sp)
    80003ff0:	0141                	addi	sp,sp,16
    80003ff2:	8082                	ret

0000000080003ff4 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003ff4:	7139                	addi	sp,sp,-64
    80003ff6:	fc06                	sd	ra,56(sp)
    80003ff8:	f822                	sd	s0,48(sp)
    80003ffa:	f426                	sd	s1,40(sp)
    80003ffc:	f04a                	sd	s2,32(sp)
    80003ffe:	ec4e                	sd	s3,24(sp)
    80004000:	e852                	sd	s4,16(sp)
    80004002:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80004004:	04451703          	lh	a4,68(a0)
    80004008:	4785                	li	a5,1
    8000400a:	00f71a63          	bne	a4,a5,8000401e <dirlookup+0x2a>
    8000400e:	892a                	mv	s2,a0
    80004010:	89ae                	mv	s3,a1
    80004012:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80004014:	457c                	lw	a5,76(a0)
    80004016:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80004018:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000401a:	e79d                	bnez	a5,80004048 <dirlookup+0x54>
    8000401c:	a8a5                	j	80004094 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    8000401e:	00004517          	auipc	a0,0x4
    80004022:	6fa50513          	addi	a0,a0,1786 # 80008718 <syscalls+0x208>
    80004026:	ffffc097          	auipc	ra,0xffffc
    8000402a:	51a080e7          	jalr	1306(ra) # 80000540 <panic>
      panic("dirlookup read");
    8000402e:	00004517          	auipc	a0,0x4
    80004032:	70250513          	addi	a0,a0,1794 # 80008730 <syscalls+0x220>
    80004036:	ffffc097          	auipc	ra,0xffffc
    8000403a:	50a080e7          	jalr	1290(ra) # 80000540 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000403e:	24c1                	addiw	s1,s1,16
    80004040:	04c92783          	lw	a5,76(s2)
    80004044:	04f4f763          	bgeu	s1,a5,80004092 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004048:	4741                	li	a4,16
    8000404a:	86a6                	mv	a3,s1
    8000404c:	fc040613          	addi	a2,s0,-64
    80004050:	4581                	li	a1,0
    80004052:	854a                	mv	a0,s2
    80004054:	00000097          	auipc	ra,0x0
    80004058:	d70080e7          	jalr	-656(ra) # 80003dc4 <readi>
    8000405c:	47c1                	li	a5,16
    8000405e:	fcf518e3          	bne	a0,a5,8000402e <dirlookup+0x3a>
    if(de.inum == 0)
    80004062:	fc045783          	lhu	a5,-64(s0)
    80004066:	dfe1                	beqz	a5,8000403e <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80004068:	fc240593          	addi	a1,s0,-62
    8000406c:	854e                	mv	a0,s3
    8000406e:	00000097          	auipc	ra,0x0
    80004072:	f6c080e7          	jalr	-148(ra) # 80003fda <namecmp>
    80004076:	f561                	bnez	a0,8000403e <dirlookup+0x4a>
      if(poff)
    80004078:	000a0463          	beqz	s4,80004080 <dirlookup+0x8c>
        *poff = off;
    8000407c:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004080:	fc045583          	lhu	a1,-64(s0)
    80004084:	00092503          	lw	a0,0(s2)
    80004088:	fffff097          	auipc	ra,0xfffff
    8000408c:	74e080e7          	jalr	1870(ra) # 800037d6 <iget>
    80004090:	a011                	j	80004094 <dirlookup+0xa0>
  return 0;
    80004092:	4501                	li	a0,0
}
    80004094:	70e2                	ld	ra,56(sp)
    80004096:	7442                	ld	s0,48(sp)
    80004098:	74a2                	ld	s1,40(sp)
    8000409a:	7902                	ld	s2,32(sp)
    8000409c:	69e2                	ld	s3,24(sp)
    8000409e:	6a42                	ld	s4,16(sp)
    800040a0:	6121                	addi	sp,sp,64
    800040a2:	8082                	ret

00000000800040a4 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800040a4:	711d                	addi	sp,sp,-96
    800040a6:	ec86                	sd	ra,88(sp)
    800040a8:	e8a2                	sd	s0,80(sp)
    800040aa:	e4a6                	sd	s1,72(sp)
    800040ac:	e0ca                	sd	s2,64(sp)
    800040ae:	fc4e                	sd	s3,56(sp)
    800040b0:	f852                	sd	s4,48(sp)
    800040b2:	f456                	sd	s5,40(sp)
    800040b4:	f05a                	sd	s6,32(sp)
    800040b6:	ec5e                	sd	s7,24(sp)
    800040b8:	e862                	sd	s8,16(sp)
    800040ba:	e466                	sd	s9,8(sp)
    800040bc:	e06a                	sd	s10,0(sp)
    800040be:	1080                	addi	s0,sp,96
    800040c0:	84aa                	mv	s1,a0
    800040c2:	8b2e                	mv	s6,a1
    800040c4:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    800040c6:	00054703          	lbu	a4,0(a0)
    800040ca:	02f00793          	li	a5,47
    800040ce:	02f70363          	beq	a4,a5,800040f4 <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800040d2:	ffffe097          	auipc	ra,0xffffe
    800040d6:	b5a080e7          	jalr	-1190(ra) # 80001c2c <myproc>
    800040da:	15053503          	ld	a0,336(a0)
    800040de:	00000097          	auipc	ra,0x0
    800040e2:	9f4080e7          	jalr	-1548(ra) # 80003ad2 <idup>
    800040e6:	8a2a                	mv	s4,a0
  while(*path == '/')
    800040e8:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    800040ec:	4cb5                	li	s9,13
  len = path - s;
    800040ee:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800040f0:	4c05                	li	s8,1
    800040f2:	a87d                	j	800041b0 <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    800040f4:	4585                	li	a1,1
    800040f6:	4505                	li	a0,1
    800040f8:	fffff097          	auipc	ra,0xfffff
    800040fc:	6de080e7          	jalr	1758(ra) # 800037d6 <iget>
    80004100:	8a2a                	mv	s4,a0
    80004102:	b7dd                	j	800040e8 <namex+0x44>
      iunlockput(ip);
    80004104:	8552                	mv	a0,s4
    80004106:	00000097          	auipc	ra,0x0
    8000410a:	c6c080e7          	jalr	-916(ra) # 80003d72 <iunlockput>
      return 0;
    8000410e:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004110:	8552                	mv	a0,s4
    80004112:	60e6                	ld	ra,88(sp)
    80004114:	6446                	ld	s0,80(sp)
    80004116:	64a6                	ld	s1,72(sp)
    80004118:	6906                	ld	s2,64(sp)
    8000411a:	79e2                	ld	s3,56(sp)
    8000411c:	7a42                	ld	s4,48(sp)
    8000411e:	7aa2                	ld	s5,40(sp)
    80004120:	7b02                	ld	s6,32(sp)
    80004122:	6be2                	ld	s7,24(sp)
    80004124:	6c42                	ld	s8,16(sp)
    80004126:	6ca2                	ld	s9,8(sp)
    80004128:	6d02                	ld	s10,0(sp)
    8000412a:	6125                	addi	sp,sp,96
    8000412c:	8082                	ret
      iunlock(ip);
    8000412e:	8552                	mv	a0,s4
    80004130:	00000097          	auipc	ra,0x0
    80004134:	aa2080e7          	jalr	-1374(ra) # 80003bd2 <iunlock>
      return ip;
    80004138:	bfe1                	j	80004110 <namex+0x6c>
      iunlockput(ip);
    8000413a:	8552                	mv	a0,s4
    8000413c:	00000097          	auipc	ra,0x0
    80004140:	c36080e7          	jalr	-970(ra) # 80003d72 <iunlockput>
      return 0;
    80004144:	8a4e                	mv	s4,s3
    80004146:	b7e9                	j	80004110 <namex+0x6c>
  len = path - s;
    80004148:	40998633          	sub	a2,s3,s1
    8000414c:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80004150:	09acd863          	bge	s9,s10,800041e0 <namex+0x13c>
    memmove(name, s, DIRSIZ);
    80004154:	4639                	li	a2,14
    80004156:	85a6                	mv	a1,s1
    80004158:	8556                	mv	a0,s5
    8000415a:	ffffd097          	auipc	ra,0xffffd
    8000415e:	bd4080e7          	jalr	-1068(ra) # 80000d2e <memmove>
    80004162:	84ce                	mv	s1,s3
  while(*path == '/')
    80004164:	0004c783          	lbu	a5,0(s1)
    80004168:	01279763          	bne	a5,s2,80004176 <namex+0xd2>
    path++;
    8000416c:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000416e:	0004c783          	lbu	a5,0(s1)
    80004172:	ff278de3          	beq	a5,s2,8000416c <namex+0xc8>
    ilock(ip);
    80004176:	8552                	mv	a0,s4
    80004178:	00000097          	auipc	ra,0x0
    8000417c:	998080e7          	jalr	-1640(ra) # 80003b10 <ilock>
    if(ip->type != T_DIR){
    80004180:	044a1783          	lh	a5,68(s4)
    80004184:	f98790e3          	bne	a5,s8,80004104 <namex+0x60>
    if(nameiparent && *path == '\0'){
    80004188:	000b0563          	beqz	s6,80004192 <namex+0xee>
    8000418c:	0004c783          	lbu	a5,0(s1)
    80004190:	dfd9                	beqz	a5,8000412e <namex+0x8a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004192:	865e                	mv	a2,s7
    80004194:	85d6                	mv	a1,s5
    80004196:	8552                	mv	a0,s4
    80004198:	00000097          	auipc	ra,0x0
    8000419c:	e5c080e7          	jalr	-420(ra) # 80003ff4 <dirlookup>
    800041a0:	89aa                	mv	s3,a0
    800041a2:	dd41                	beqz	a0,8000413a <namex+0x96>
    iunlockput(ip);
    800041a4:	8552                	mv	a0,s4
    800041a6:	00000097          	auipc	ra,0x0
    800041aa:	bcc080e7          	jalr	-1076(ra) # 80003d72 <iunlockput>
    ip = next;
    800041ae:	8a4e                	mv	s4,s3
  while(*path == '/')
    800041b0:	0004c783          	lbu	a5,0(s1)
    800041b4:	01279763          	bne	a5,s2,800041c2 <namex+0x11e>
    path++;
    800041b8:	0485                	addi	s1,s1,1
  while(*path == '/')
    800041ba:	0004c783          	lbu	a5,0(s1)
    800041be:	ff278de3          	beq	a5,s2,800041b8 <namex+0x114>
  if(*path == 0)
    800041c2:	cb9d                	beqz	a5,800041f8 <namex+0x154>
  while(*path != '/' && *path != 0)
    800041c4:	0004c783          	lbu	a5,0(s1)
    800041c8:	89a6                	mv	s3,s1
  len = path - s;
    800041ca:	8d5e                	mv	s10,s7
    800041cc:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    800041ce:	01278963          	beq	a5,s2,800041e0 <namex+0x13c>
    800041d2:	dbbd                	beqz	a5,80004148 <namex+0xa4>
    path++;
    800041d4:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    800041d6:	0009c783          	lbu	a5,0(s3)
    800041da:	ff279ce3          	bne	a5,s2,800041d2 <namex+0x12e>
    800041de:	b7ad                	j	80004148 <namex+0xa4>
    memmove(name, s, len);
    800041e0:	2601                	sext.w	a2,a2
    800041e2:	85a6                	mv	a1,s1
    800041e4:	8556                	mv	a0,s5
    800041e6:	ffffd097          	auipc	ra,0xffffd
    800041ea:	b48080e7          	jalr	-1208(ra) # 80000d2e <memmove>
    name[len] = 0;
    800041ee:	9d56                	add	s10,s10,s5
    800041f0:	000d0023          	sb	zero,0(s10)
    800041f4:	84ce                	mv	s1,s3
    800041f6:	b7bd                	j	80004164 <namex+0xc0>
  if(nameiparent){
    800041f8:	f00b0ce3          	beqz	s6,80004110 <namex+0x6c>
    iput(ip);
    800041fc:	8552                	mv	a0,s4
    800041fe:	00000097          	auipc	ra,0x0
    80004202:	acc080e7          	jalr	-1332(ra) # 80003cca <iput>
    return 0;
    80004206:	4a01                	li	s4,0
    80004208:	b721                	j	80004110 <namex+0x6c>

000000008000420a <dirlink>:
{
    8000420a:	7139                	addi	sp,sp,-64
    8000420c:	fc06                	sd	ra,56(sp)
    8000420e:	f822                	sd	s0,48(sp)
    80004210:	f426                	sd	s1,40(sp)
    80004212:	f04a                	sd	s2,32(sp)
    80004214:	ec4e                	sd	s3,24(sp)
    80004216:	e852                	sd	s4,16(sp)
    80004218:	0080                	addi	s0,sp,64
    8000421a:	892a                	mv	s2,a0
    8000421c:	8a2e                	mv	s4,a1
    8000421e:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004220:	4601                	li	a2,0
    80004222:	00000097          	auipc	ra,0x0
    80004226:	dd2080e7          	jalr	-558(ra) # 80003ff4 <dirlookup>
    8000422a:	e93d                	bnez	a0,800042a0 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000422c:	04c92483          	lw	s1,76(s2)
    80004230:	c49d                	beqz	s1,8000425e <dirlink+0x54>
    80004232:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004234:	4741                	li	a4,16
    80004236:	86a6                	mv	a3,s1
    80004238:	fc040613          	addi	a2,s0,-64
    8000423c:	4581                	li	a1,0
    8000423e:	854a                	mv	a0,s2
    80004240:	00000097          	auipc	ra,0x0
    80004244:	b84080e7          	jalr	-1148(ra) # 80003dc4 <readi>
    80004248:	47c1                	li	a5,16
    8000424a:	06f51163          	bne	a0,a5,800042ac <dirlink+0xa2>
    if(de.inum == 0)
    8000424e:	fc045783          	lhu	a5,-64(s0)
    80004252:	c791                	beqz	a5,8000425e <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004254:	24c1                	addiw	s1,s1,16
    80004256:	04c92783          	lw	a5,76(s2)
    8000425a:	fcf4ede3          	bltu	s1,a5,80004234 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    8000425e:	4639                	li	a2,14
    80004260:	85d2                	mv	a1,s4
    80004262:	fc240513          	addi	a0,s0,-62
    80004266:	ffffd097          	auipc	ra,0xffffd
    8000426a:	b78080e7          	jalr	-1160(ra) # 80000dde <strncpy>
  de.inum = inum;
    8000426e:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004272:	4741                	li	a4,16
    80004274:	86a6                	mv	a3,s1
    80004276:	fc040613          	addi	a2,s0,-64
    8000427a:	4581                	li	a1,0
    8000427c:	854a                	mv	a0,s2
    8000427e:	00000097          	auipc	ra,0x0
    80004282:	c3e080e7          	jalr	-962(ra) # 80003ebc <writei>
    80004286:	1541                	addi	a0,a0,-16
    80004288:	00a03533          	snez	a0,a0
    8000428c:	40a00533          	neg	a0,a0
}
    80004290:	70e2                	ld	ra,56(sp)
    80004292:	7442                	ld	s0,48(sp)
    80004294:	74a2                	ld	s1,40(sp)
    80004296:	7902                	ld	s2,32(sp)
    80004298:	69e2                	ld	s3,24(sp)
    8000429a:	6a42                	ld	s4,16(sp)
    8000429c:	6121                	addi	sp,sp,64
    8000429e:	8082                	ret
    iput(ip);
    800042a0:	00000097          	auipc	ra,0x0
    800042a4:	a2a080e7          	jalr	-1494(ra) # 80003cca <iput>
    return -1;
    800042a8:	557d                	li	a0,-1
    800042aa:	b7dd                	j	80004290 <dirlink+0x86>
      panic("dirlink read");
    800042ac:	00004517          	auipc	a0,0x4
    800042b0:	49450513          	addi	a0,a0,1172 # 80008740 <syscalls+0x230>
    800042b4:	ffffc097          	auipc	ra,0xffffc
    800042b8:	28c080e7          	jalr	652(ra) # 80000540 <panic>

00000000800042bc <namei>:

struct inode*
namei(char *path)
{
    800042bc:	1101                	addi	sp,sp,-32
    800042be:	ec06                	sd	ra,24(sp)
    800042c0:	e822                	sd	s0,16(sp)
    800042c2:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800042c4:	fe040613          	addi	a2,s0,-32
    800042c8:	4581                	li	a1,0
    800042ca:	00000097          	auipc	ra,0x0
    800042ce:	dda080e7          	jalr	-550(ra) # 800040a4 <namex>
}
    800042d2:	60e2                	ld	ra,24(sp)
    800042d4:	6442                	ld	s0,16(sp)
    800042d6:	6105                	addi	sp,sp,32
    800042d8:	8082                	ret

00000000800042da <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800042da:	1141                	addi	sp,sp,-16
    800042dc:	e406                	sd	ra,8(sp)
    800042de:	e022                	sd	s0,0(sp)
    800042e0:	0800                	addi	s0,sp,16
    800042e2:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800042e4:	4585                	li	a1,1
    800042e6:	00000097          	auipc	ra,0x0
    800042ea:	dbe080e7          	jalr	-578(ra) # 800040a4 <namex>
}
    800042ee:	60a2                	ld	ra,8(sp)
    800042f0:	6402                	ld	s0,0(sp)
    800042f2:	0141                	addi	sp,sp,16
    800042f4:	8082                	ret

00000000800042f6 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800042f6:	1101                	addi	sp,sp,-32
    800042f8:	ec06                	sd	ra,24(sp)
    800042fa:	e822                	sd	s0,16(sp)
    800042fc:	e426                	sd	s1,8(sp)
    800042fe:	e04a                	sd	s2,0(sp)
    80004300:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004302:	0001d917          	auipc	s2,0x1d
    80004306:	58690913          	addi	s2,s2,1414 # 80021888 <log>
    8000430a:	01892583          	lw	a1,24(s2)
    8000430e:	02892503          	lw	a0,40(s2)
    80004312:	fffff097          	auipc	ra,0xfffff
    80004316:	fe6080e7          	jalr	-26(ra) # 800032f8 <bread>
    8000431a:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    8000431c:	02c92683          	lw	a3,44(s2)
    80004320:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004322:	02d05863          	blez	a3,80004352 <write_head+0x5c>
    80004326:	0001d797          	auipc	a5,0x1d
    8000432a:	59278793          	addi	a5,a5,1426 # 800218b8 <log+0x30>
    8000432e:	05c50713          	addi	a4,a0,92
    80004332:	36fd                	addiw	a3,a3,-1
    80004334:	02069613          	slli	a2,a3,0x20
    80004338:	01e65693          	srli	a3,a2,0x1e
    8000433c:	0001d617          	auipc	a2,0x1d
    80004340:	58060613          	addi	a2,a2,1408 # 800218bc <log+0x34>
    80004344:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004346:	4390                	lw	a2,0(a5)
    80004348:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000434a:	0791                	addi	a5,a5,4
    8000434c:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    8000434e:	fed79ce3          	bne	a5,a3,80004346 <write_head+0x50>
  }
  bwrite(buf);
    80004352:	8526                	mv	a0,s1
    80004354:	fffff097          	auipc	ra,0xfffff
    80004358:	096080e7          	jalr	150(ra) # 800033ea <bwrite>
  brelse(buf);
    8000435c:	8526                	mv	a0,s1
    8000435e:	fffff097          	auipc	ra,0xfffff
    80004362:	0ca080e7          	jalr	202(ra) # 80003428 <brelse>
}
    80004366:	60e2                	ld	ra,24(sp)
    80004368:	6442                	ld	s0,16(sp)
    8000436a:	64a2                	ld	s1,8(sp)
    8000436c:	6902                	ld	s2,0(sp)
    8000436e:	6105                	addi	sp,sp,32
    80004370:	8082                	ret

0000000080004372 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004372:	0001d797          	auipc	a5,0x1d
    80004376:	5427a783          	lw	a5,1346(a5) # 800218b4 <log+0x2c>
    8000437a:	0af05d63          	blez	a5,80004434 <install_trans+0xc2>
{
    8000437e:	7139                	addi	sp,sp,-64
    80004380:	fc06                	sd	ra,56(sp)
    80004382:	f822                	sd	s0,48(sp)
    80004384:	f426                	sd	s1,40(sp)
    80004386:	f04a                	sd	s2,32(sp)
    80004388:	ec4e                	sd	s3,24(sp)
    8000438a:	e852                	sd	s4,16(sp)
    8000438c:	e456                	sd	s5,8(sp)
    8000438e:	e05a                	sd	s6,0(sp)
    80004390:	0080                	addi	s0,sp,64
    80004392:	8b2a                	mv	s6,a0
    80004394:	0001da97          	auipc	s5,0x1d
    80004398:	524a8a93          	addi	s5,s5,1316 # 800218b8 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000439c:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000439e:	0001d997          	auipc	s3,0x1d
    800043a2:	4ea98993          	addi	s3,s3,1258 # 80021888 <log>
    800043a6:	a00d                	j	800043c8 <install_trans+0x56>
    brelse(lbuf);
    800043a8:	854a                	mv	a0,s2
    800043aa:	fffff097          	auipc	ra,0xfffff
    800043ae:	07e080e7          	jalr	126(ra) # 80003428 <brelse>
    brelse(dbuf);
    800043b2:	8526                	mv	a0,s1
    800043b4:	fffff097          	auipc	ra,0xfffff
    800043b8:	074080e7          	jalr	116(ra) # 80003428 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800043bc:	2a05                	addiw	s4,s4,1
    800043be:	0a91                	addi	s5,s5,4
    800043c0:	02c9a783          	lw	a5,44(s3)
    800043c4:	04fa5e63          	bge	s4,a5,80004420 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800043c8:	0189a583          	lw	a1,24(s3)
    800043cc:	014585bb          	addw	a1,a1,s4
    800043d0:	2585                	addiw	a1,a1,1
    800043d2:	0289a503          	lw	a0,40(s3)
    800043d6:	fffff097          	auipc	ra,0xfffff
    800043da:	f22080e7          	jalr	-222(ra) # 800032f8 <bread>
    800043de:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800043e0:	000aa583          	lw	a1,0(s5)
    800043e4:	0289a503          	lw	a0,40(s3)
    800043e8:	fffff097          	auipc	ra,0xfffff
    800043ec:	f10080e7          	jalr	-240(ra) # 800032f8 <bread>
    800043f0:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800043f2:	40000613          	li	a2,1024
    800043f6:	05890593          	addi	a1,s2,88
    800043fa:	05850513          	addi	a0,a0,88
    800043fe:	ffffd097          	auipc	ra,0xffffd
    80004402:	930080e7          	jalr	-1744(ra) # 80000d2e <memmove>
    bwrite(dbuf);  // write dst to disk
    80004406:	8526                	mv	a0,s1
    80004408:	fffff097          	auipc	ra,0xfffff
    8000440c:	fe2080e7          	jalr	-30(ra) # 800033ea <bwrite>
    if(recovering == 0)
    80004410:	f80b1ce3          	bnez	s6,800043a8 <install_trans+0x36>
      bunpin(dbuf);
    80004414:	8526                	mv	a0,s1
    80004416:	fffff097          	auipc	ra,0xfffff
    8000441a:	0ec080e7          	jalr	236(ra) # 80003502 <bunpin>
    8000441e:	b769                	j	800043a8 <install_trans+0x36>
}
    80004420:	70e2                	ld	ra,56(sp)
    80004422:	7442                	ld	s0,48(sp)
    80004424:	74a2                	ld	s1,40(sp)
    80004426:	7902                	ld	s2,32(sp)
    80004428:	69e2                	ld	s3,24(sp)
    8000442a:	6a42                	ld	s4,16(sp)
    8000442c:	6aa2                	ld	s5,8(sp)
    8000442e:	6b02                	ld	s6,0(sp)
    80004430:	6121                	addi	sp,sp,64
    80004432:	8082                	ret
    80004434:	8082                	ret

0000000080004436 <initlog>:
{
    80004436:	7179                	addi	sp,sp,-48
    80004438:	f406                	sd	ra,40(sp)
    8000443a:	f022                	sd	s0,32(sp)
    8000443c:	ec26                	sd	s1,24(sp)
    8000443e:	e84a                	sd	s2,16(sp)
    80004440:	e44e                	sd	s3,8(sp)
    80004442:	1800                	addi	s0,sp,48
    80004444:	892a                	mv	s2,a0
    80004446:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004448:	0001d497          	auipc	s1,0x1d
    8000444c:	44048493          	addi	s1,s1,1088 # 80021888 <log>
    80004450:	00004597          	auipc	a1,0x4
    80004454:	30058593          	addi	a1,a1,768 # 80008750 <syscalls+0x240>
    80004458:	8526                	mv	a0,s1
    8000445a:	ffffc097          	auipc	ra,0xffffc
    8000445e:	6ec080e7          	jalr	1772(ra) # 80000b46 <initlock>
  log.start = sb->logstart;
    80004462:	0149a583          	lw	a1,20(s3)
    80004466:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004468:	0109a783          	lw	a5,16(s3)
    8000446c:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    8000446e:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004472:	854a                	mv	a0,s2
    80004474:	fffff097          	auipc	ra,0xfffff
    80004478:	e84080e7          	jalr	-380(ra) # 800032f8 <bread>
  log.lh.n = lh->n;
    8000447c:	4d34                	lw	a3,88(a0)
    8000447e:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004480:	02d05663          	blez	a3,800044ac <initlog+0x76>
    80004484:	05c50793          	addi	a5,a0,92
    80004488:	0001d717          	auipc	a4,0x1d
    8000448c:	43070713          	addi	a4,a4,1072 # 800218b8 <log+0x30>
    80004490:	36fd                	addiw	a3,a3,-1
    80004492:	02069613          	slli	a2,a3,0x20
    80004496:	01e65693          	srli	a3,a2,0x1e
    8000449a:	06050613          	addi	a2,a0,96
    8000449e:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    800044a0:	4390                	lw	a2,0(a5)
    800044a2:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800044a4:	0791                	addi	a5,a5,4
    800044a6:	0711                	addi	a4,a4,4
    800044a8:	fed79ce3          	bne	a5,a3,800044a0 <initlog+0x6a>
  brelse(buf);
    800044ac:	fffff097          	auipc	ra,0xfffff
    800044b0:	f7c080e7          	jalr	-132(ra) # 80003428 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800044b4:	4505                	li	a0,1
    800044b6:	00000097          	auipc	ra,0x0
    800044ba:	ebc080e7          	jalr	-324(ra) # 80004372 <install_trans>
  log.lh.n = 0;
    800044be:	0001d797          	auipc	a5,0x1d
    800044c2:	3e07ab23          	sw	zero,1014(a5) # 800218b4 <log+0x2c>
  write_head(); // clear the log
    800044c6:	00000097          	auipc	ra,0x0
    800044ca:	e30080e7          	jalr	-464(ra) # 800042f6 <write_head>
}
    800044ce:	70a2                	ld	ra,40(sp)
    800044d0:	7402                	ld	s0,32(sp)
    800044d2:	64e2                	ld	s1,24(sp)
    800044d4:	6942                	ld	s2,16(sp)
    800044d6:	69a2                	ld	s3,8(sp)
    800044d8:	6145                	addi	sp,sp,48
    800044da:	8082                	ret

00000000800044dc <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800044dc:	1101                	addi	sp,sp,-32
    800044de:	ec06                	sd	ra,24(sp)
    800044e0:	e822                	sd	s0,16(sp)
    800044e2:	e426                	sd	s1,8(sp)
    800044e4:	e04a                	sd	s2,0(sp)
    800044e6:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800044e8:	0001d517          	auipc	a0,0x1d
    800044ec:	3a050513          	addi	a0,a0,928 # 80021888 <log>
    800044f0:	ffffc097          	auipc	ra,0xffffc
    800044f4:	6e6080e7          	jalr	1766(ra) # 80000bd6 <acquire>
  while(1){
    if(log.committing){
    800044f8:	0001d497          	auipc	s1,0x1d
    800044fc:	39048493          	addi	s1,s1,912 # 80021888 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004500:	4979                	li	s2,30
    80004502:	a039                	j	80004510 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004504:	85a6                	mv	a1,s1
    80004506:	8526                	mv	a0,s1
    80004508:	ffffe097          	auipc	ra,0xffffe
    8000450c:	efe080e7          	jalr	-258(ra) # 80002406 <sleep>
    if(log.committing){
    80004510:	50dc                	lw	a5,36(s1)
    80004512:	fbed                	bnez	a5,80004504 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004514:	5098                	lw	a4,32(s1)
    80004516:	2705                	addiw	a4,a4,1
    80004518:	0007069b          	sext.w	a3,a4
    8000451c:	0027179b          	slliw	a5,a4,0x2
    80004520:	9fb9                	addw	a5,a5,a4
    80004522:	0017979b          	slliw	a5,a5,0x1
    80004526:	54d8                	lw	a4,44(s1)
    80004528:	9fb9                	addw	a5,a5,a4
    8000452a:	00f95963          	bge	s2,a5,8000453c <begin_op+0x60>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000452e:	85a6                	mv	a1,s1
    80004530:	8526                	mv	a0,s1
    80004532:	ffffe097          	auipc	ra,0xffffe
    80004536:	ed4080e7          	jalr	-300(ra) # 80002406 <sleep>
    8000453a:	bfd9                	j	80004510 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000453c:	0001d517          	auipc	a0,0x1d
    80004540:	34c50513          	addi	a0,a0,844 # 80021888 <log>
    80004544:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004546:	ffffc097          	auipc	ra,0xffffc
    8000454a:	744080e7          	jalr	1860(ra) # 80000c8a <release>
      break;
    }
  }
}
    8000454e:	60e2                	ld	ra,24(sp)
    80004550:	6442                	ld	s0,16(sp)
    80004552:	64a2                	ld	s1,8(sp)
    80004554:	6902                	ld	s2,0(sp)
    80004556:	6105                	addi	sp,sp,32
    80004558:	8082                	ret

000000008000455a <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000455a:	7139                	addi	sp,sp,-64
    8000455c:	fc06                	sd	ra,56(sp)
    8000455e:	f822                	sd	s0,48(sp)
    80004560:	f426                	sd	s1,40(sp)
    80004562:	f04a                	sd	s2,32(sp)
    80004564:	ec4e                	sd	s3,24(sp)
    80004566:	e852                	sd	s4,16(sp)
    80004568:	e456                	sd	s5,8(sp)
    8000456a:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000456c:	0001d497          	auipc	s1,0x1d
    80004570:	31c48493          	addi	s1,s1,796 # 80021888 <log>
    80004574:	8526                	mv	a0,s1
    80004576:	ffffc097          	auipc	ra,0xffffc
    8000457a:	660080e7          	jalr	1632(ra) # 80000bd6 <acquire>
  log.outstanding -= 1;
    8000457e:	509c                	lw	a5,32(s1)
    80004580:	37fd                	addiw	a5,a5,-1
    80004582:	0007891b          	sext.w	s2,a5
    80004586:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004588:	50dc                	lw	a5,36(s1)
    8000458a:	e7b9                	bnez	a5,800045d8 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    8000458c:	04091e63          	bnez	s2,800045e8 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004590:	0001d497          	auipc	s1,0x1d
    80004594:	2f848493          	addi	s1,s1,760 # 80021888 <log>
    80004598:	4785                	li	a5,1
    8000459a:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000459c:	8526                	mv	a0,s1
    8000459e:	ffffc097          	auipc	ra,0xffffc
    800045a2:	6ec080e7          	jalr	1772(ra) # 80000c8a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800045a6:	54dc                	lw	a5,44(s1)
    800045a8:	06f04763          	bgtz	a5,80004616 <end_op+0xbc>
    acquire(&log.lock);
    800045ac:	0001d497          	auipc	s1,0x1d
    800045b0:	2dc48493          	addi	s1,s1,732 # 80021888 <log>
    800045b4:	8526                	mv	a0,s1
    800045b6:	ffffc097          	auipc	ra,0xffffc
    800045ba:	620080e7          	jalr	1568(ra) # 80000bd6 <acquire>
    log.committing = 0;
    800045be:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800045c2:	8526                	mv	a0,s1
    800045c4:	ffffe097          	auipc	ra,0xffffe
    800045c8:	eb8080e7          	jalr	-328(ra) # 8000247c <wakeup>
    release(&log.lock);
    800045cc:	8526                	mv	a0,s1
    800045ce:	ffffc097          	auipc	ra,0xffffc
    800045d2:	6bc080e7          	jalr	1724(ra) # 80000c8a <release>
}
    800045d6:	a03d                	j	80004604 <end_op+0xaa>
    panic("log.committing");
    800045d8:	00004517          	auipc	a0,0x4
    800045dc:	18050513          	addi	a0,a0,384 # 80008758 <syscalls+0x248>
    800045e0:	ffffc097          	auipc	ra,0xffffc
    800045e4:	f60080e7          	jalr	-160(ra) # 80000540 <panic>
    wakeup(&log);
    800045e8:	0001d497          	auipc	s1,0x1d
    800045ec:	2a048493          	addi	s1,s1,672 # 80021888 <log>
    800045f0:	8526                	mv	a0,s1
    800045f2:	ffffe097          	auipc	ra,0xffffe
    800045f6:	e8a080e7          	jalr	-374(ra) # 8000247c <wakeup>
  release(&log.lock);
    800045fa:	8526                	mv	a0,s1
    800045fc:	ffffc097          	auipc	ra,0xffffc
    80004600:	68e080e7          	jalr	1678(ra) # 80000c8a <release>
}
    80004604:	70e2                	ld	ra,56(sp)
    80004606:	7442                	ld	s0,48(sp)
    80004608:	74a2                	ld	s1,40(sp)
    8000460a:	7902                	ld	s2,32(sp)
    8000460c:	69e2                	ld	s3,24(sp)
    8000460e:	6a42                	ld	s4,16(sp)
    80004610:	6aa2                	ld	s5,8(sp)
    80004612:	6121                	addi	sp,sp,64
    80004614:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004616:	0001da97          	auipc	s5,0x1d
    8000461a:	2a2a8a93          	addi	s5,s5,674 # 800218b8 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000461e:	0001da17          	auipc	s4,0x1d
    80004622:	26aa0a13          	addi	s4,s4,618 # 80021888 <log>
    80004626:	018a2583          	lw	a1,24(s4)
    8000462a:	012585bb          	addw	a1,a1,s2
    8000462e:	2585                	addiw	a1,a1,1
    80004630:	028a2503          	lw	a0,40(s4)
    80004634:	fffff097          	auipc	ra,0xfffff
    80004638:	cc4080e7          	jalr	-828(ra) # 800032f8 <bread>
    8000463c:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000463e:	000aa583          	lw	a1,0(s5)
    80004642:	028a2503          	lw	a0,40(s4)
    80004646:	fffff097          	auipc	ra,0xfffff
    8000464a:	cb2080e7          	jalr	-846(ra) # 800032f8 <bread>
    8000464e:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004650:	40000613          	li	a2,1024
    80004654:	05850593          	addi	a1,a0,88
    80004658:	05848513          	addi	a0,s1,88
    8000465c:	ffffc097          	auipc	ra,0xffffc
    80004660:	6d2080e7          	jalr	1746(ra) # 80000d2e <memmove>
    bwrite(to);  // write the log
    80004664:	8526                	mv	a0,s1
    80004666:	fffff097          	auipc	ra,0xfffff
    8000466a:	d84080e7          	jalr	-636(ra) # 800033ea <bwrite>
    brelse(from);
    8000466e:	854e                	mv	a0,s3
    80004670:	fffff097          	auipc	ra,0xfffff
    80004674:	db8080e7          	jalr	-584(ra) # 80003428 <brelse>
    brelse(to);
    80004678:	8526                	mv	a0,s1
    8000467a:	fffff097          	auipc	ra,0xfffff
    8000467e:	dae080e7          	jalr	-594(ra) # 80003428 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004682:	2905                	addiw	s2,s2,1
    80004684:	0a91                	addi	s5,s5,4
    80004686:	02ca2783          	lw	a5,44(s4)
    8000468a:	f8f94ee3          	blt	s2,a5,80004626 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000468e:	00000097          	auipc	ra,0x0
    80004692:	c68080e7          	jalr	-920(ra) # 800042f6 <write_head>
    install_trans(0); // Now install writes to home locations
    80004696:	4501                	li	a0,0
    80004698:	00000097          	auipc	ra,0x0
    8000469c:	cda080e7          	jalr	-806(ra) # 80004372 <install_trans>
    log.lh.n = 0;
    800046a0:	0001d797          	auipc	a5,0x1d
    800046a4:	2007aa23          	sw	zero,532(a5) # 800218b4 <log+0x2c>
    write_head();    // Erase the transaction from the log
    800046a8:	00000097          	auipc	ra,0x0
    800046ac:	c4e080e7          	jalr	-946(ra) # 800042f6 <write_head>
    800046b0:	bdf5                	j	800045ac <end_op+0x52>

00000000800046b2 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800046b2:	1101                	addi	sp,sp,-32
    800046b4:	ec06                	sd	ra,24(sp)
    800046b6:	e822                	sd	s0,16(sp)
    800046b8:	e426                	sd	s1,8(sp)
    800046ba:	e04a                	sd	s2,0(sp)
    800046bc:	1000                	addi	s0,sp,32
    800046be:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800046c0:	0001d917          	auipc	s2,0x1d
    800046c4:	1c890913          	addi	s2,s2,456 # 80021888 <log>
    800046c8:	854a                	mv	a0,s2
    800046ca:	ffffc097          	auipc	ra,0xffffc
    800046ce:	50c080e7          	jalr	1292(ra) # 80000bd6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800046d2:	02c92603          	lw	a2,44(s2)
    800046d6:	47f5                	li	a5,29
    800046d8:	06c7c563          	blt	a5,a2,80004742 <log_write+0x90>
    800046dc:	0001d797          	auipc	a5,0x1d
    800046e0:	1c87a783          	lw	a5,456(a5) # 800218a4 <log+0x1c>
    800046e4:	37fd                	addiw	a5,a5,-1
    800046e6:	04f65e63          	bge	a2,a5,80004742 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800046ea:	0001d797          	auipc	a5,0x1d
    800046ee:	1be7a783          	lw	a5,446(a5) # 800218a8 <log+0x20>
    800046f2:	06f05063          	blez	a5,80004752 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800046f6:	4781                	li	a5,0
    800046f8:	06c05563          	blez	a2,80004762 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800046fc:	44cc                	lw	a1,12(s1)
    800046fe:	0001d717          	auipc	a4,0x1d
    80004702:	1ba70713          	addi	a4,a4,442 # 800218b8 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004706:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004708:	4314                	lw	a3,0(a4)
    8000470a:	04b68c63          	beq	a3,a1,80004762 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    8000470e:	2785                	addiw	a5,a5,1
    80004710:	0711                	addi	a4,a4,4
    80004712:	fef61be3          	bne	a2,a5,80004708 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004716:	0621                	addi	a2,a2,8
    80004718:	060a                	slli	a2,a2,0x2
    8000471a:	0001d797          	auipc	a5,0x1d
    8000471e:	16e78793          	addi	a5,a5,366 # 80021888 <log>
    80004722:	97b2                	add	a5,a5,a2
    80004724:	44d8                	lw	a4,12(s1)
    80004726:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004728:	8526                	mv	a0,s1
    8000472a:	fffff097          	auipc	ra,0xfffff
    8000472e:	d9c080e7          	jalr	-612(ra) # 800034c6 <bpin>
    log.lh.n++;
    80004732:	0001d717          	auipc	a4,0x1d
    80004736:	15670713          	addi	a4,a4,342 # 80021888 <log>
    8000473a:	575c                	lw	a5,44(a4)
    8000473c:	2785                	addiw	a5,a5,1
    8000473e:	d75c                	sw	a5,44(a4)
    80004740:	a82d                	j	8000477a <log_write+0xc8>
    panic("too big a transaction");
    80004742:	00004517          	auipc	a0,0x4
    80004746:	02650513          	addi	a0,a0,38 # 80008768 <syscalls+0x258>
    8000474a:	ffffc097          	auipc	ra,0xffffc
    8000474e:	df6080e7          	jalr	-522(ra) # 80000540 <panic>
    panic("log_write outside of trans");
    80004752:	00004517          	auipc	a0,0x4
    80004756:	02e50513          	addi	a0,a0,46 # 80008780 <syscalls+0x270>
    8000475a:	ffffc097          	auipc	ra,0xffffc
    8000475e:	de6080e7          	jalr	-538(ra) # 80000540 <panic>
  log.lh.block[i] = b->blockno;
    80004762:	00878693          	addi	a3,a5,8
    80004766:	068a                	slli	a3,a3,0x2
    80004768:	0001d717          	auipc	a4,0x1d
    8000476c:	12070713          	addi	a4,a4,288 # 80021888 <log>
    80004770:	9736                	add	a4,a4,a3
    80004772:	44d4                	lw	a3,12(s1)
    80004774:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004776:	faf609e3          	beq	a2,a5,80004728 <log_write+0x76>
  }
  release(&log.lock);
    8000477a:	0001d517          	auipc	a0,0x1d
    8000477e:	10e50513          	addi	a0,a0,270 # 80021888 <log>
    80004782:	ffffc097          	auipc	ra,0xffffc
    80004786:	508080e7          	jalr	1288(ra) # 80000c8a <release>
}
    8000478a:	60e2                	ld	ra,24(sp)
    8000478c:	6442                	ld	s0,16(sp)
    8000478e:	64a2                	ld	s1,8(sp)
    80004790:	6902                	ld	s2,0(sp)
    80004792:	6105                	addi	sp,sp,32
    80004794:	8082                	ret

0000000080004796 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004796:	1101                	addi	sp,sp,-32
    80004798:	ec06                	sd	ra,24(sp)
    8000479a:	e822                	sd	s0,16(sp)
    8000479c:	e426                	sd	s1,8(sp)
    8000479e:	e04a                	sd	s2,0(sp)
    800047a0:	1000                	addi	s0,sp,32
    800047a2:	84aa                	mv	s1,a0
    800047a4:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800047a6:	00004597          	auipc	a1,0x4
    800047aa:	ffa58593          	addi	a1,a1,-6 # 800087a0 <syscalls+0x290>
    800047ae:	0521                	addi	a0,a0,8
    800047b0:	ffffc097          	auipc	ra,0xffffc
    800047b4:	396080e7          	jalr	918(ra) # 80000b46 <initlock>
  lk->name = name;
    800047b8:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800047bc:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800047c0:	0204a423          	sw	zero,40(s1)
}
    800047c4:	60e2                	ld	ra,24(sp)
    800047c6:	6442                	ld	s0,16(sp)
    800047c8:	64a2                	ld	s1,8(sp)
    800047ca:	6902                	ld	s2,0(sp)
    800047cc:	6105                	addi	sp,sp,32
    800047ce:	8082                	ret

00000000800047d0 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800047d0:	1101                	addi	sp,sp,-32
    800047d2:	ec06                	sd	ra,24(sp)
    800047d4:	e822                	sd	s0,16(sp)
    800047d6:	e426                	sd	s1,8(sp)
    800047d8:	e04a                	sd	s2,0(sp)
    800047da:	1000                	addi	s0,sp,32
    800047dc:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800047de:	00850913          	addi	s2,a0,8
    800047e2:	854a                	mv	a0,s2
    800047e4:	ffffc097          	auipc	ra,0xffffc
    800047e8:	3f2080e7          	jalr	1010(ra) # 80000bd6 <acquire>
  while (lk->locked) {
    800047ec:	409c                	lw	a5,0(s1)
    800047ee:	cb89                	beqz	a5,80004800 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800047f0:	85ca                	mv	a1,s2
    800047f2:	8526                	mv	a0,s1
    800047f4:	ffffe097          	auipc	ra,0xffffe
    800047f8:	c12080e7          	jalr	-1006(ra) # 80002406 <sleep>
  while (lk->locked) {
    800047fc:	409c                	lw	a5,0(s1)
    800047fe:	fbed                	bnez	a5,800047f0 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004800:	4785                	li	a5,1
    80004802:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004804:	ffffd097          	auipc	ra,0xffffd
    80004808:	428080e7          	jalr	1064(ra) # 80001c2c <myproc>
    8000480c:	591c                	lw	a5,48(a0)
    8000480e:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004810:	854a                	mv	a0,s2
    80004812:	ffffc097          	auipc	ra,0xffffc
    80004816:	478080e7          	jalr	1144(ra) # 80000c8a <release>
}
    8000481a:	60e2                	ld	ra,24(sp)
    8000481c:	6442                	ld	s0,16(sp)
    8000481e:	64a2                	ld	s1,8(sp)
    80004820:	6902                	ld	s2,0(sp)
    80004822:	6105                	addi	sp,sp,32
    80004824:	8082                	ret

0000000080004826 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004826:	1101                	addi	sp,sp,-32
    80004828:	ec06                	sd	ra,24(sp)
    8000482a:	e822                	sd	s0,16(sp)
    8000482c:	e426                	sd	s1,8(sp)
    8000482e:	e04a                	sd	s2,0(sp)
    80004830:	1000                	addi	s0,sp,32
    80004832:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004834:	00850913          	addi	s2,a0,8
    80004838:	854a                	mv	a0,s2
    8000483a:	ffffc097          	auipc	ra,0xffffc
    8000483e:	39c080e7          	jalr	924(ra) # 80000bd6 <acquire>
  lk->locked = 0;
    80004842:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004846:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000484a:	8526                	mv	a0,s1
    8000484c:	ffffe097          	auipc	ra,0xffffe
    80004850:	c30080e7          	jalr	-976(ra) # 8000247c <wakeup>
  release(&lk->lk);
    80004854:	854a                	mv	a0,s2
    80004856:	ffffc097          	auipc	ra,0xffffc
    8000485a:	434080e7          	jalr	1076(ra) # 80000c8a <release>
}
    8000485e:	60e2                	ld	ra,24(sp)
    80004860:	6442                	ld	s0,16(sp)
    80004862:	64a2                	ld	s1,8(sp)
    80004864:	6902                	ld	s2,0(sp)
    80004866:	6105                	addi	sp,sp,32
    80004868:	8082                	ret

000000008000486a <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000486a:	7179                	addi	sp,sp,-48
    8000486c:	f406                	sd	ra,40(sp)
    8000486e:	f022                	sd	s0,32(sp)
    80004870:	ec26                	sd	s1,24(sp)
    80004872:	e84a                	sd	s2,16(sp)
    80004874:	e44e                	sd	s3,8(sp)
    80004876:	1800                	addi	s0,sp,48
    80004878:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000487a:	00850913          	addi	s2,a0,8
    8000487e:	854a                	mv	a0,s2
    80004880:	ffffc097          	auipc	ra,0xffffc
    80004884:	356080e7          	jalr	854(ra) # 80000bd6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004888:	409c                	lw	a5,0(s1)
    8000488a:	ef99                	bnez	a5,800048a8 <holdingsleep+0x3e>
    8000488c:	4481                	li	s1,0
  release(&lk->lk);
    8000488e:	854a                	mv	a0,s2
    80004890:	ffffc097          	auipc	ra,0xffffc
    80004894:	3fa080e7          	jalr	1018(ra) # 80000c8a <release>
  return r;
}
    80004898:	8526                	mv	a0,s1
    8000489a:	70a2                	ld	ra,40(sp)
    8000489c:	7402                	ld	s0,32(sp)
    8000489e:	64e2                	ld	s1,24(sp)
    800048a0:	6942                	ld	s2,16(sp)
    800048a2:	69a2                	ld	s3,8(sp)
    800048a4:	6145                	addi	sp,sp,48
    800048a6:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800048a8:	0284a983          	lw	s3,40(s1)
    800048ac:	ffffd097          	auipc	ra,0xffffd
    800048b0:	380080e7          	jalr	896(ra) # 80001c2c <myproc>
    800048b4:	5904                	lw	s1,48(a0)
    800048b6:	413484b3          	sub	s1,s1,s3
    800048ba:	0014b493          	seqz	s1,s1
    800048be:	bfc1                	j	8000488e <holdingsleep+0x24>

00000000800048c0 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800048c0:	1141                	addi	sp,sp,-16
    800048c2:	e406                	sd	ra,8(sp)
    800048c4:	e022                	sd	s0,0(sp)
    800048c6:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800048c8:	00004597          	auipc	a1,0x4
    800048cc:	ee858593          	addi	a1,a1,-280 # 800087b0 <syscalls+0x2a0>
    800048d0:	0001d517          	auipc	a0,0x1d
    800048d4:	10050513          	addi	a0,a0,256 # 800219d0 <ftable>
    800048d8:	ffffc097          	auipc	ra,0xffffc
    800048dc:	26e080e7          	jalr	622(ra) # 80000b46 <initlock>
}
    800048e0:	60a2                	ld	ra,8(sp)
    800048e2:	6402                	ld	s0,0(sp)
    800048e4:	0141                	addi	sp,sp,16
    800048e6:	8082                	ret

00000000800048e8 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800048e8:	1101                	addi	sp,sp,-32
    800048ea:	ec06                	sd	ra,24(sp)
    800048ec:	e822                	sd	s0,16(sp)
    800048ee:	e426                	sd	s1,8(sp)
    800048f0:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800048f2:	0001d517          	auipc	a0,0x1d
    800048f6:	0de50513          	addi	a0,a0,222 # 800219d0 <ftable>
    800048fa:	ffffc097          	auipc	ra,0xffffc
    800048fe:	2dc080e7          	jalr	732(ra) # 80000bd6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004902:	0001d497          	auipc	s1,0x1d
    80004906:	0e648493          	addi	s1,s1,230 # 800219e8 <ftable+0x18>
    8000490a:	0001e717          	auipc	a4,0x1e
    8000490e:	07e70713          	addi	a4,a4,126 # 80022988 <disk>
    if(f->ref == 0){
    80004912:	40dc                	lw	a5,4(s1)
    80004914:	cf99                	beqz	a5,80004932 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004916:	02848493          	addi	s1,s1,40
    8000491a:	fee49ce3          	bne	s1,a4,80004912 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000491e:	0001d517          	auipc	a0,0x1d
    80004922:	0b250513          	addi	a0,a0,178 # 800219d0 <ftable>
    80004926:	ffffc097          	auipc	ra,0xffffc
    8000492a:	364080e7          	jalr	868(ra) # 80000c8a <release>
  return 0;
    8000492e:	4481                	li	s1,0
    80004930:	a819                	j	80004946 <filealloc+0x5e>
      f->ref = 1;
    80004932:	4785                	li	a5,1
    80004934:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004936:	0001d517          	auipc	a0,0x1d
    8000493a:	09a50513          	addi	a0,a0,154 # 800219d0 <ftable>
    8000493e:	ffffc097          	auipc	ra,0xffffc
    80004942:	34c080e7          	jalr	844(ra) # 80000c8a <release>
}
    80004946:	8526                	mv	a0,s1
    80004948:	60e2                	ld	ra,24(sp)
    8000494a:	6442                	ld	s0,16(sp)
    8000494c:	64a2                	ld	s1,8(sp)
    8000494e:	6105                	addi	sp,sp,32
    80004950:	8082                	ret

0000000080004952 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004952:	1101                	addi	sp,sp,-32
    80004954:	ec06                	sd	ra,24(sp)
    80004956:	e822                	sd	s0,16(sp)
    80004958:	e426                	sd	s1,8(sp)
    8000495a:	1000                	addi	s0,sp,32
    8000495c:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000495e:	0001d517          	auipc	a0,0x1d
    80004962:	07250513          	addi	a0,a0,114 # 800219d0 <ftable>
    80004966:	ffffc097          	auipc	ra,0xffffc
    8000496a:	270080e7          	jalr	624(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    8000496e:	40dc                	lw	a5,4(s1)
    80004970:	02f05263          	blez	a5,80004994 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004974:	2785                	addiw	a5,a5,1
    80004976:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004978:	0001d517          	auipc	a0,0x1d
    8000497c:	05850513          	addi	a0,a0,88 # 800219d0 <ftable>
    80004980:	ffffc097          	auipc	ra,0xffffc
    80004984:	30a080e7          	jalr	778(ra) # 80000c8a <release>
  return f;
}
    80004988:	8526                	mv	a0,s1
    8000498a:	60e2                	ld	ra,24(sp)
    8000498c:	6442                	ld	s0,16(sp)
    8000498e:	64a2                	ld	s1,8(sp)
    80004990:	6105                	addi	sp,sp,32
    80004992:	8082                	ret
    panic("filedup");
    80004994:	00004517          	auipc	a0,0x4
    80004998:	e2450513          	addi	a0,a0,-476 # 800087b8 <syscalls+0x2a8>
    8000499c:	ffffc097          	auipc	ra,0xffffc
    800049a0:	ba4080e7          	jalr	-1116(ra) # 80000540 <panic>

00000000800049a4 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800049a4:	7139                	addi	sp,sp,-64
    800049a6:	fc06                	sd	ra,56(sp)
    800049a8:	f822                	sd	s0,48(sp)
    800049aa:	f426                	sd	s1,40(sp)
    800049ac:	f04a                	sd	s2,32(sp)
    800049ae:	ec4e                	sd	s3,24(sp)
    800049b0:	e852                	sd	s4,16(sp)
    800049b2:	e456                	sd	s5,8(sp)
    800049b4:	0080                	addi	s0,sp,64
    800049b6:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800049b8:	0001d517          	auipc	a0,0x1d
    800049bc:	01850513          	addi	a0,a0,24 # 800219d0 <ftable>
    800049c0:	ffffc097          	auipc	ra,0xffffc
    800049c4:	216080e7          	jalr	534(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    800049c8:	40dc                	lw	a5,4(s1)
    800049ca:	06f05163          	blez	a5,80004a2c <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800049ce:	37fd                	addiw	a5,a5,-1
    800049d0:	0007871b          	sext.w	a4,a5
    800049d4:	c0dc                	sw	a5,4(s1)
    800049d6:	06e04363          	bgtz	a4,80004a3c <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800049da:	0004a903          	lw	s2,0(s1)
    800049de:	0094ca83          	lbu	s5,9(s1)
    800049e2:	0104ba03          	ld	s4,16(s1)
    800049e6:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800049ea:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800049ee:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800049f2:	0001d517          	auipc	a0,0x1d
    800049f6:	fde50513          	addi	a0,a0,-34 # 800219d0 <ftable>
    800049fa:	ffffc097          	auipc	ra,0xffffc
    800049fe:	290080e7          	jalr	656(ra) # 80000c8a <release>

  if(ff.type == FD_PIPE){
    80004a02:	4785                	li	a5,1
    80004a04:	04f90d63          	beq	s2,a5,80004a5e <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004a08:	3979                	addiw	s2,s2,-2
    80004a0a:	4785                	li	a5,1
    80004a0c:	0527e063          	bltu	a5,s2,80004a4c <fileclose+0xa8>
    begin_op();
    80004a10:	00000097          	auipc	ra,0x0
    80004a14:	acc080e7          	jalr	-1332(ra) # 800044dc <begin_op>
    iput(ff.ip);
    80004a18:	854e                	mv	a0,s3
    80004a1a:	fffff097          	auipc	ra,0xfffff
    80004a1e:	2b0080e7          	jalr	688(ra) # 80003cca <iput>
    end_op();
    80004a22:	00000097          	auipc	ra,0x0
    80004a26:	b38080e7          	jalr	-1224(ra) # 8000455a <end_op>
    80004a2a:	a00d                	j	80004a4c <fileclose+0xa8>
    panic("fileclose");
    80004a2c:	00004517          	auipc	a0,0x4
    80004a30:	d9450513          	addi	a0,a0,-620 # 800087c0 <syscalls+0x2b0>
    80004a34:	ffffc097          	auipc	ra,0xffffc
    80004a38:	b0c080e7          	jalr	-1268(ra) # 80000540 <panic>
    release(&ftable.lock);
    80004a3c:	0001d517          	auipc	a0,0x1d
    80004a40:	f9450513          	addi	a0,a0,-108 # 800219d0 <ftable>
    80004a44:	ffffc097          	auipc	ra,0xffffc
    80004a48:	246080e7          	jalr	582(ra) # 80000c8a <release>
  }
}
    80004a4c:	70e2                	ld	ra,56(sp)
    80004a4e:	7442                	ld	s0,48(sp)
    80004a50:	74a2                	ld	s1,40(sp)
    80004a52:	7902                	ld	s2,32(sp)
    80004a54:	69e2                	ld	s3,24(sp)
    80004a56:	6a42                	ld	s4,16(sp)
    80004a58:	6aa2                	ld	s5,8(sp)
    80004a5a:	6121                	addi	sp,sp,64
    80004a5c:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004a5e:	85d6                	mv	a1,s5
    80004a60:	8552                	mv	a0,s4
    80004a62:	00000097          	auipc	ra,0x0
    80004a66:	34c080e7          	jalr	844(ra) # 80004dae <pipeclose>
    80004a6a:	b7cd                	j	80004a4c <fileclose+0xa8>

0000000080004a6c <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004a6c:	715d                	addi	sp,sp,-80
    80004a6e:	e486                	sd	ra,72(sp)
    80004a70:	e0a2                	sd	s0,64(sp)
    80004a72:	fc26                	sd	s1,56(sp)
    80004a74:	f84a                	sd	s2,48(sp)
    80004a76:	f44e                	sd	s3,40(sp)
    80004a78:	0880                	addi	s0,sp,80
    80004a7a:	84aa                	mv	s1,a0
    80004a7c:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004a7e:	ffffd097          	auipc	ra,0xffffd
    80004a82:	1ae080e7          	jalr	430(ra) # 80001c2c <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004a86:	409c                	lw	a5,0(s1)
    80004a88:	37f9                	addiw	a5,a5,-2
    80004a8a:	4705                	li	a4,1
    80004a8c:	04f76763          	bltu	a4,a5,80004ada <filestat+0x6e>
    80004a90:	892a                	mv	s2,a0
    ilock(f->ip);
    80004a92:	6c88                	ld	a0,24(s1)
    80004a94:	fffff097          	auipc	ra,0xfffff
    80004a98:	07c080e7          	jalr	124(ra) # 80003b10 <ilock>
    stati(f->ip, &st);
    80004a9c:	fb840593          	addi	a1,s0,-72
    80004aa0:	6c88                	ld	a0,24(s1)
    80004aa2:	fffff097          	auipc	ra,0xfffff
    80004aa6:	2f8080e7          	jalr	760(ra) # 80003d9a <stati>
    iunlock(f->ip);
    80004aaa:	6c88                	ld	a0,24(s1)
    80004aac:	fffff097          	auipc	ra,0xfffff
    80004ab0:	126080e7          	jalr	294(ra) # 80003bd2 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004ab4:	46e1                	li	a3,24
    80004ab6:	fb840613          	addi	a2,s0,-72
    80004aba:	85ce                	mv	a1,s3
    80004abc:	05093503          	ld	a0,80(s2)
    80004ac0:	ffffd097          	auipc	ra,0xffffd
    80004ac4:	bac080e7          	jalr	-1108(ra) # 8000166c <copyout>
    80004ac8:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004acc:	60a6                	ld	ra,72(sp)
    80004ace:	6406                	ld	s0,64(sp)
    80004ad0:	74e2                	ld	s1,56(sp)
    80004ad2:	7942                	ld	s2,48(sp)
    80004ad4:	79a2                	ld	s3,40(sp)
    80004ad6:	6161                	addi	sp,sp,80
    80004ad8:	8082                	ret
  return -1;
    80004ada:	557d                	li	a0,-1
    80004adc:	bfc5                	j	80004acc <filestat+0x60>

0000000080004ade <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004ade:	7179                	addi	sp,sp,-48
    80004ae0:	f406                	sd	ra,40(sp)
    80004ae2:	f022                	sd	s0,32(sp)
    80004ae4:	ec26                	sd	s1,24(sp)
    80004ae6:	e84a                	sd	s2,16(sp)
    80004ae8:	e44e                	sd	s3,8(sp)
    80004aea:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004aec:	00854783          	lbu	a5,8(a0)
    80004af0:	c3d5                	beqz	a5,80004b94 <fileread+0xb6>
    80004af2:	84aa                	mv	s1,a0
    80004af4:	89ae                	mv	s3,a1
    80004af6:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004af8:	411c                	lw	a5,0(a0)
    80004afa:	4705                	li	a4,1
    80004afc:	04e78963          	beq	a5,a4,80004b4e <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004b00:	470d                	li	a4,3
    80004b02:	04e78d63          	beq	a5,a4,80004b5c <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004b06:	4709                	li	a4,2
    80004b08:	06e79e63          	bne	a5,a4,80004b84 <fileread+0xa6>
    ilock(f->ip);
    80004b0c:	6d08                	ld	a0,24(a0)
    80004b0e:	fffff097          	auipc	ra,0xfffff
    80004b12:	002080e7          	jalr	2(ra) # 80003b10 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004b16:	874a                	mv	a4,s2
    80004b18:	5094                	lw	a3,32(s1)
    80004b1a:	864e                	mv	a2,s3
    80004b1c:	4585                	li	a1,1
    80004b1e:	6c88                	ld	a0,24(s1)
    80004b20:	fffff097          	auipc	ra,0xfffff
    80004b24:	2a4080e7          	jalr	676(ra) # 80003dc4 <readi>
    80004b28:	892a                	mv	s2,a0
    80004b2a:	00a05563          	blez	a0,80004b34 <fileread+0x56>
      f->off += r;
    80004b2e:	509c                	lw	a5,32(s1)
    80004b30:	9fa9                	addw	a5,a5,a0
    80004b32:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004b34:	6c88                	ld	a0,24(s1)
    80004b36:	fffff097          	auipc	ra,0xfffff
    80004b3a:	09c080e7          	jalr	156(ra) # 80003bd2 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004b3e:	854a                	mv	a0,s2
    80004b40:	70a2                	ld	ra,40(sp)
    80004b42:	7402                	ld	s0,32(sp)
    80004b44:	64e2                	ld	s1,24(sp)
    80004b46:	6942                	ld	s2,16(sp)
    80004b48:	69a2                	ld	s3,8(sp)
    80004b4a:	6145                	addi	sp,sp,48
    80004b4c:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004b4e:	6908                	ld	a0,16(a0)
    80004b50:	00000097          	auipc	ra,0x0
    80004b54:	3c6080e7          	jalr	966(ra) # 80004f16 <piperead>
    80004b58:	892a                	mv	s2,a0
    80004b5a:	b7d5                	j	80004b3e <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004b5c:	02451783          	lh	a5,36(a0)
    80004b60:	03079693          	slli	a3,a5,0x30
    80004b64:	92c1                	srli	a3,a3,0x30
    80004b66:	4725                	li	a4,9
    80004b68:	02d76863          	bltu	a4,a3,80004b98 <fileread+0xba>
    80004b6c:	0792                	slli	a5,a5,0x4
    80004b6e:	0001d717          	auipc	a4,0x1d
    80004b72:	dc270713          	addi	a4,a4,-574 # 80021930 <devsw>
    80004b76:	97ba                	add	a5,a5,a4
    80004b78:	639c                	ld	a5,0(a5)
    80004b7a:	c38d                	beqz	a5,80004b9c <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004b7c:	4505                	li	a0,1
    80004b7e:	9782                	jalr	a5
    80004b80:	892a                	mv	s2,a0
    80004b82:	bf75                	j	80004b3e <fileread+0x60>
    panic("fileread");
    80004b84:	00004517          	auipc	a0,0x4
    80004b88:	c4c50513          	addi	a0,a0,-948 # 800087d0 <syscalls+0x2c0>
    80004b8c:	ffffc097          	auipc	ra,0xffffc
    80004b90:	9b4080e7          	jalr	-1612(ra) # 80000540 <panic>
    return -1;
    80004b94:	597d                	li	s2,-1
    80004b96:	b765                	j	80004b3e <fileread+0x60>
      return -1;
    80004b98:	597d                	li	s2,-1
    80004b9a:	b755                	j	80004b3e <fileread+0x60>
    80004b9c:	597d                	li	s2,-1
    80004b9e:	b745                	j	80004b3e <fileread+0x60>

0000000080004ba0 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004ba0:	715d                	addi	sp,sp,-80
    80004ba2:	e486                	sd	ra,72(sp)
    80004ba4:	e0a2                	sd	s0,64(sp)
    80004ba6:	fc26                	sd	s1,56(sp)
    80004ba8:	f84a                	sd	s2,48(sp)
    80004baa:	f44e                	sd	s3,40(sp)
    80004bac:	f052                	sd	s4,32(sp)
    80004bae:	ec56                	sd	s5,24(sp)
    80004bb0:	e85a                	sd	s6,16(sp)
    80004bb2:	e45e                	sd	s7,8(sp)
    80004bb4:	e062                	sd	s8,0(sp)
    80004bb6:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004bb8:	00954783          	lbu	a5,9(a0)
    80004bbc:	10078663          	beqz	a5,80004cc8 <filewrite+0x128>
    80004bc0:	892a                	mv	s2,a0
    80004bc2:	8b2e                	mv	s6,a1
    80004bc4:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004bc6:	411c                	lw	a5,0(a0)
    80004bc8:	4705                	li	a4,1
    80004bca:	02e78263          	beq	a5,a4,80004bee <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004bce:	470d                	li	a4,3
    80004bd0:	02e78663          	beq	a5,a4,80004bfc <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004bd4:	4709                	li	a4,2
    80004bd6:	0ee79163          	bne	a5,a4,80004cb8 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004bda:	0ac05d63          	blez	a2,80004c94 <filewrite+0xf4>
    int i = 0;
    80004bde:	4981                	li	s3,0
    80004be0:	6b85                	lui	s7,0x1
    80004be2:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004be6:	6c05                	lui	s8,0x1
    80004be8:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004bec:	a861                	j	80004c84 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004bee:	6908                	ld	a0,16(a0)
    80004bf0:	00000097          	auipc	ra,0x0
    80004bf4:	22e080e7          	jalr	558(ra) # 80004e1e <pipewrite>
    80004bf8:	8a2a                	mv	s4,a0
    80004bfa:	a045                	j	80004c9a <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004bfc:	02451783          	lh	a5,36(a0)
    80004c00:	03079693          	slli	a3,a5,0x30
    80004c04:	92c1                	srli	a3,a3,0x30
    80004c06:	4725                	li	a4,9
    80004c08:	0cd76263          	bltu	a4,a3,80004ccc <filewrite+0x12c>
    80004c0c:	0792                	slli	a5,a5,0x4
    80004c0e:	0001d717          	auipc	a4,0x1d
    80004c12:	d2270713          	addi	a4,a4,-734 # 80021930 <devsw>
    80004c16:	97ba                	add	a5,a5,a4
    80004c18:	679c                	ld	a5,8(a5)
    80004c1a:	cbdd                	beqz	a5,80004cd0 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004c1c:	4505                	li	a0,1
    80004c1e:	9782                	jalr	a5
    80004c20:	8a2a                	mv	s4,a0
    80004c22:	a8a5                	j	80004c9a <filewrite+0xfa>
    80004c24:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004c28:	00000097          	auipc	ra,0x0
    80004c2c:	8b4080e7          	jalr	-1868(ra) # 800044dc <begin_op>
      ilock(f->ip);
    80004c30:	01893503          	ld	a0,24(s2)
    80004c34:	fffff097          	auipc	ra,0xfffff
    80004c38:	edc080e7          	jalr	-292(ra) # 80003b10 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004c3c:	8756                	mv	a4,s5
    80004c3e:	02092683          	lw	a3,32(s2)
    80004c42:	01698633          	add	a2,s3,s6
    80004c46:	4585                	li	a1,1
    80004c48:	01893503          	ld	a0,24(s2)
    80004c4c:	fffff097          	auipc	ra,0xfffff
    80004c50:	270080e7          	jalr	624(ra) # 80003ebc <writei>
    80004c54:	84aa                	mv	s1,a0
    80004c56:	00a05763          	blez	a0,80004c64 <filewrite+0xc4>
        f->off += r;
    80004c5a:	02092783          	lw	a5,32(s2)
    80004c5e:	9fa9                	addw	a5,a5,a0
    80004c60:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004c64:	01893503          	ld	a0,24(s2)
    80004c68:	fffff097          	auipc	ra,0xfffff
    80004c6c:	f6a080e7          	jalr	-150(ra) # 80003bd2 <iunlock>
      end_op();
    80004c70:	00000097          	auipc	ra,0x0
    80004c74:	8ea080e7          	jalr	-1814(ra) # 8000455a <end_op>

      if(r != n1){
    80004c78:	009a9f63          	bne	s5,s1,80004c96 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004c7c:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004c80:	0149db63          	bge	s3,s4,80004c96 <filewrite+0xf6>
      int n1 = n - i;
    80004c84:	413a04bb          	subw	s1,s4,s3
    80004c88:	0004879b          	sext.w	a5,s1
    80004c8c:	f8fbdce3          	bge	s7,a5,80004c24 <filewrite+0x84>
    80004c90:	84e2                	mv	s1,s8
    80004c92:	bf49                	j	80004c24 <filewrite+0x84>
    int i = 0;
    80004c94:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004c96:	013a1f63          	bne	s4,s3,80004cb4 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004c9a:	8552                	mv	a0,s4
    80004c9c:	60a6                	ld	ra,72(sp)
    80004c9e:	6406                	ld	s0,64(sp)
    80004ca0:	74e2                	ld	s1,56(sp)
    80004ca2:	7942                	ld	s2,48(sp)
    80004ca4:	79a2                	ld	s3,40(sp)
    80004ca6:	7a02                	ld	s4,32(sp)
    80004ca8:	6ae2                	ld	s5,24(sp)
    80004caa:	6b42                	ld	s6,16(sp)
    80004cac:	6ba2                	ld	s7,8(sp)
    80004cae:	6c02                	ld	s8,0(sp)
    80004cb0:	6161                	addi	sp,sp,80
    80004cb2:	8082                	ret
    ret = (i == n ? n : -1);
    80004cb4:	5a7d                	li	s4,-1
    80004cb6:	b7d5                	j	80004c9a <filewrite+0xfa>
    panic("filewrite");
    80004cb8:	00004517          	auipc	a0,0x4
    80004cbc:	b2850513          	addi	a0,a0,-1240 # 800087e0 <syscalls+0x2d0>
    80004cc0:	ffffc097          	auipc	ra,0xffffc
    80004cc4:	880080e7          	jalr	-1920(ra) # 80000540 <panic>
    return -1;
    80004cc8:	5a7d                	li	s4,-1
    80004cca:	bfc1                	j	80004c9a <filewrite+0xfa>
      return -1;
    80004ccc:	5a7d                	li	s4,-1
    80004cce:	b7f1                	j	80004c9a <filewrite+0xfa>
    80004cd0:	5a7d                	li	s4,-1
    80004cd2:	b7e1                	j	80004c9a <filewrite+0xfa>

0000000080004cd4 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004cd4:	7179                	addi	sp,sp,-48
    80004cd6:	f406                	sd	ra,40(sp)
    80004cd8:	f022                	sd	s0,32(sp)
    80004cda:	ec26                	sd	s1,24(sp)
    80004cdc:	e84a                	sd	s2,16(sp)
    80004cde:	e44e                	sd	s3,8(sp)
    80004ce0:	e052                	sd	s4,0(sp)
    80004ce2:	1800                	addi	s0,sp,48
    80004ce4:	84aa                	mv	s1,a0
    80004ce6:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004ce8:	0005b023          	sd	zero,0(a1)
    80004cec:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004cf0:	00000097          	auipc	ra,0x0
    80004cf4:	bf8080e7          	jalr	-1032(ra) # 800048e8 <filealloc>
    80004cf8:	e088                	sd	a0,0(s1)
    80004cfa:	c551                	beqz	a0,80004d86 <pipealloc+0xb2>
    80004cfc:	00000097          	auipc	ra,0x0
    80004d00:	bec080e7          	jalr	-1044(ra) # 800048e8 <filealloc>
    80004d04:	00aa3023          	sd	a0,0(s4)
    80004d08:	c92d                	beqz	a0,80004d7a <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004d0a:	ffffc097          	auipc	ra,0xffffc
    80004d0e:	ddc080e7          	jalr	-548(ra) # 80000ae6 <kalloc>
    80004d12:	892a                	mv	s2,a0
    80004d14:	c125                	beqz	a0,80004d74 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004d16:	4985                	li	s3,1
    80004d18:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004d1c:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004d20:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004d24:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004d28:	00004597          	auipc	a1,0x4
    80004d2c:	ac858593          	addi	a1,a1,-1336 # 800087f0 <syscalls+0x2e0>
    80004d30:	ffffc097          	auipc	ra,0xffffc
    80004d34:	e16080e7          	jalr	-490(ra) # 80000b46 <initlock>
  (*f0)->type = FD_PIPE;
    80004d38:	609c                	ld	a5,0(s1)
    80004d3a:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004d3e:	609c                	ld	a5,0(s1)
    80004d40:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004d44:	609c                	ld	a5,0(s1)
    80004d46:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004d4a:	609c                	ld	a5,0(s1)
    80004d4c:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004d50:	000a3783          	ld	a5,0(s4)
    80004d54:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004d58:	000a3783          	ld	a5,0(s4)
    80004d5c:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004d60:	000a3783          	ld	a5,0(s4)
    80004d64:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004d68:	000a3783          	ld	a5,0(s4)
    80004d6c:	0127b823          	sd	s2,16(a5)
  return 0;
    80004d70:	4501                	li	a0,0
    80004d72:	a025                	j	80004d9a <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004d74:	6088                	ld	a0,0(s1)
    80004d76:	e501                	bnez	a0,80004d7e <pipealloc+0xaa>
    80004d78:	a039                	j	80004d86 <pipealloc+0xb2>
    80004d7a:	6088                	ld	a0,0(s1)
    80004d7c:	c51d                	beqz	a0,80004daa <pipealloc+0xd6>
    fileclose(*f0);
    80004d7e:	00000097          	auipc	ra,0x0
    80004d82:	c26080e7          	jalr	-986(ra) # 800049a4 <fileclose>
  if(*f1)
    80004d86:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004d8a:	557d                	li	a0,-1
  if(*f1)
    80004d8c:	c799                	beqz	a5,80004d9a <pipealloc+0xc6>
    fileclose(*f1);
    80004d8e:	853e                	mv	a0,a5
    80004d90:	00000097          	auipc	ra,0x0
    80004d94:	c14080e7          	jalr	-1004(ra) # 800049a4 <fileclose>
  return -1;
    80004d98:	557d                	li	a0,-1
}
    80004d9a:	70a2                	ld	ra,40(sp)
    80004d9c:	7402                	ld	s0,32(sp)
    80004d9e:	64e2                	ld	s1,24(sp)
    80004da0:	6942                	ld	s2,16(sp)
    80004da2:	69a2                	ld	s3,8(sp)
    80004da4:	6a02                	ld	s4,0(sp)
    80004da6:	6145                	addi	sp,sp,48
    80004da8:	8082                	ret
  return -1;
    80004daa:	557d                	li	a0,-1
    80004dac:	b7fd                	j	80004d9a <pipealloc+0xc6>

0000000080004dae <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004dae:	1101                	addi	sp,sp,-32
    80004db0:	ec06                	sd	ra,24(sp)
    80004db2:	e822                	sd	s0,16(sp)
    80004db4:	e426                	sd	s1,8(sp)
    80004db6:	e04a                	sd	s2,0(sp)
    80004db8:	1000                	addi	s0,sp,32
    80004dba:	84aa                	mv	s1,a0
    80004dbc:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004dbe:	ffffc097          	auipc	ra,0xffffc
    80004dc2:	e18080e7          	jalr	-488(ra) # 80000bd6 <acquire>
  if(writable){
    80004dc6:	02090d63          	beqz	s2,80004e00 <pipeclose+0x52>
    pi->writeopen = 0;
    80004dca:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004dce:	21848513          	addi	a0,s1,536
    80004dd2:	ffffd097          	auipc	ra,0xffffd
    80004dd6:	6aa080e7          	jalr	1706(ra) # 8000247c <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004dda:	2204b783          	ld	a5,544(s1)
    80004dde:	eb95                	bnez	a5,80004e12 <pipeclose+0x64>
    release(&pi->lock);
    80004de0:	8526                	mv	a0,s1
    80004de2:	ffffc097          	auipc	ra,0xffffc
    80004de6:	ea8080e7          	jalr	-344(ra) # 80000c8a <release>
    kfree((char*)pi);
    80004dea:	8526                	mv	a0,s1
    80004dec:	ffffc097          	auipc	ra,0xffffc
    80004df0:	bfc080e7          	jalr	-1028(ra) # 800009e8 <kfree>
  } else
    release(&pi->lock);
}
    80004df4:	60e2                	ld	ra,24(sp)
    80004df6:	6442                	ld	s0,16(sp)
    80004df8:	64a2                	ld	s1,8(sp)
    80004dfa:	6902                	ld	s2,0(sp)
    80004dfc:	6105                	addi	sp,sp,32
    80004dfe:	8082                	ret
    pi->readopen = 0;
    80004e00:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004e04:	21c48513          	addi	a0,s1,540
    80004e08:	ffffd097          	auipc	ra,0xffffd
    80004e0c:	674080e7          	jalr	1652(ra) # 8000247c <wakeup>
    80004e10:	b7e9                	j	80004dda <pipeclose+0x2c>
    release(&pi->lock);
    80004e12:	8526                	mv	a0,s1
    80004e14:	ffffc097          	auipc	ra,0xffffc
    80004e18:	e76080e7          	jalr	-394(ra) # 80000c8a <release>
}
    80004e1c:	bfe1                	j	80004df4 <pipeclose+0x46>

0000000080004e1e <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004e1e:	711d                	addi	sp,sp,-96
    80004e20:	ec86                	sd	ra,88(sp)
    80004e22:	e8a2                	sd	s0,80(sp)
    80004e24:	e4a6                	sd	s1,72(sp)
    80004e26:	e0ca                	sd	s2,64(sp)
    80004e28:	fc4e                	sd	s3,56(sp)
    80004e2a:	f852                	sd	s4,48(sp)
    80004e2c:	f456                	sd	s5,40(sp)
    80004e2e:	f05a                	sd	s6,32(sp)
    80004e30:	ec5e                	sd	s7,24(sp)
    80004e32:	e862                	sd	s8,16(sp)
    80004e34:	1080                	addi	s0,sp,96
    80004e36:	84aa                	mv	s1,a0
    80004e38:	8aae                	mv	s5,a1
    80004e3a:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004e3c:	ffffd097          	auipc	ra,0xffffd
    80004e40:	df0080e7          	jalr	-528(ra) # 80001c2c <myproc>
    80004e44:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004e46:	8526                	mv	a0,s1
    80004e48:	ffffc097          	auipc	ra,0xffffc
    80004e4c:	d8e080e7          	jalr	-626(ra) # 80000bd6 <acquire>
  while(i < n){
    80004e50:	0b405663          	blez	s4,80004efc <pipewrite+0xde>
  int i = 0;
    80004e54:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004e56:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004e58:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004e5c:	21c48b93          	addi	s7,s1,540
    80004e60:	a089                	j	80004ea2 <pipewrite+0x84>
      release(&pi->lock);
    80004e62:	8526                	mv	a0,s1
    80004e64:	ffffc097          	auipc	ra,0xffffc
    80004e68:	e26080e7          	jalr	-474(ra) # 80000c8a <release>
      return -1;
    80004e6c:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004e6e:	854a                	mv	a0,s2
    80004e70:	60e6                	ld	ra,88(sp)
    80004e72:	6446                	ld	s0,80(sp)
    80004e74:	64a6                	ld	s1,72(sp)
    80004e76:	6906                	ld	s2,64(sp)
    80004e78:	79e2                	ld	s3,56(sp)
    80004e7a:	7a42                	ld	s4,48(sp)
    80004e7c:	7aa2                	ld	s5,40(sp)
    80004e7e:	7b02                	ld	s6,32(sp)
    80004e80:	6be2                	ld	s7,24(sp)
    80004e82:	6c42                	ld	s8,16(sp)
    80004e84:	6125                	addi	sp,sp,96
    80004e86:	8082                	ret
      wakeup(&pi->nread);
    80004e88:	8562                	mv	a0,s8
    80004e8a:	ffffd097          	auipc	ra,0xffffd
    80004e8e:	5f2080e7          	jalr	1522(ra) # 8000247c <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004e92:	85a6                	mv	a1,s1
    80004e94:	855e                	mv	a0,s7
    80004e96:	ffffd097          	auipc	ra,0xffffd
    80004e9a:	570080e7          	jalr	1392(ra) # 80002406 <sleep>
  while(i < n){
    80004e9e:	07495063          	bge	s2,s4,80004efe <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004ea2:	2204a783          	lw	a5,544(s1)
    80004ea6:	dfd5                	beqz	a5,80004e62 <pipewrite+0x44>
    80004ea8:	854e                	mv	a0,s3
    80004eaa:	ffffe097          	auipc	ra,0xffffe
    80004eae:	8b6080e7          	jalr	-1866(ra) # 80002760 <killed>
    80004eb2:	f945                	bnez	a0,80004e62 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004eb4:	2184a783          	lw	a5,536(s1)
    80004eb8:	21c4a703          	lw	a4,540(s1)
    80004ebc:	2007879b          	addiw	a5,a5,512
    80004ec0:	fcf704e3          	beq	a4,a5,80004e88 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004ec4:	4685                	li	a3,1
    80004ec6:	01590633          	add	a2,s2,s5
    80004eca:	faf40593          	addi	a1,s0,-81
    80004ece:	0509b503          	ld	a0,80(s3)
    80004ed2:	ffffd097          	auipc	ra,0xffffd
    80004ed6:	826080e7          	jalr	-2010(ra) # 800016f8 <copyin>
    80004eda:	03650263          	beq	a0,s6,80004efe <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004ede:	21c4a783          	lw	a5,540(s1)
    80004ee2:	0017871b          	addiw	a4,a5,1
    80004ee6:	20e4ae23          	sw	a4,540(s1)
    80004eea:	1ff7f793          	andi	a5,a5,511
    80004eee:	97a6                	add	a5,a5,s1
    80004ef0:	faf44703          	lbu	a4,-81(s0)
    80004ef4:	00e78c23          	sb	a4,24(a5)
      i++;
    80004ef8:	2905                	addiw	s2,s2,1
    80004efa:	b755                	j	80004e9e <pipewrite+0x80>
  int i = 0;
    80004efc:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004efe:	21848513          	addi	a0,s1,536
    80004f02:	ffffd097          	auipc	ra,0xffffd
    80004f06:	57a080e7          	jalr	1402(ra) # 8000247c <wakeup>
  release(&pi->lock);
    80004f0a:	8526                	mv	a0,s1
    80004f0c:	ffffc097          	auipc	ra,0xffffc
    80004f10:	d7e080e7          	jalr	-642(ra) # 80000c8a <release>
  return i;
    80004f14:	bfa9                	j	80004e6e <pipewrite+0x50>

0000000080004f16 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004f16:	715d                	addi	sp,sp,-80
    80004f18:	e486                	sd	ra,72(sp)
    80004f1a:	e0a2                	sd	s0,64(sp)
    80004f1c:	fc26                	sd	s1,56(sp)
    80004f1e:	f84a                	sd	s2,48(sp)
    80004f20:	f44e                	sd	s3,40(sp)
    80004f22:	f052                	sd	s4,32(sp)
    80004f24:	ec56                	sd	s5,24(sp)
    80004f26:	e85a                	sd	s6,16(sp)
    80004f28:	0880                	addi	s0,sp,80
    80004f2a:	84aa                	mv	s1,a0
    80004f2c:	892e                	mv	s2,a1
    80004f2e:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004f30:	ffffd097          	auipc	ra,0xffffd
    80004f34:	cfc080e7          	jalr	-772(ra) # 80001c2c <myproc>
    80004f38:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004f3a:	8526                	mv	a0,s1
    80004f3c:	ffffc097          	auipc	ra,0xffffc
    80004f40:	c9a080e7          	jalr	-870(ra) # 80000bd6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004f44:	2184a703          	lw	a4,536(s1)
    80004f48:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004f4c:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004f50:	02f71763          	bne	a4,a5,80004f7e <piperead+0x68>
    80004f54:	2244a783          	lw	a5,548(s1)
    80004f58:	c39d                	beqz	a5,80004f7e <piperead+0x68>
    if(killed(pr)){
    80004f5a:	8552                	mv	a0,s4
    80004f5c:	ffffe097          	auipc	ra,0xffffe
    80004f60:	804080e7          	jalr	-2044(ra) # 80002760 <killed>
    80004f64:	e949                	bnez	a0,80004ff6 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004f66:	85a6                	mv	a1,s1
    80004f68:	854e                	mv	a0,s3
    80004f6a:	ffffd097          	auipc	ra,0xffffd
    80004f6e:	49c080e7          	jalr	1180(ra) # 80002406 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004f72:	2184a703          	lw	a4,536(s1)
    80004f76:	21c4a783          	lw	a5,540(s1)
    80004f7a:	fcf70de3          	beq	a4,a5,80004f54 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004f7e:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004f80:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004f82:	05505463          	blez	s5,80004fca <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80004f86:	2184a783          	lw	a5,536(s1)
    80004f8a:	21c4a703          	lw	a4,540(s1)
    80004f8e:	02f70e63          	beq	a4,a5,80004fca <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004f92:	0017871b          	addiw	a4,a5,1
    80004f96:	20e4ac23          	sw	a4,536(s1)
    80004f9a:	1ff7f793          	andi	a5,a5,511
    80004f9e:	97a6                	add	a5,a5,s1
    80004fa0:	0187c783          	lbu	a5,24(a5)
    80004fa4:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004fa8:	4685                	li	a3,1
    80004faa:	fbf40613          	addi	a2,s0,-65
    80004fae:	85ca                	mv	a1,s2
    80004fb0:	050a3503          	ld	a0,80(s4)
    80004fb4:	ffffc097          	auipc	ra,0xffffc
    80004fb8:	6b8080e7          	jalr	1720(ra) # 8000166c <copyout>
    80004fbc:	01650763          	beq	a0,s6,80004fca <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004fc0:	2985                	addiw	s3,s3,1
    80004fc2:	0905                	addi	s2,s2,1
    80004fc4:	fd3a91e3          	bne	s5,s3,80004f86 <piperead+0x70>
    80004fc8:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004fca:	21c48513          	addi	a0,s1,540
    80004fce:	ffffd097          	auipc	ra,0xffffd
    80004fd2:	4ae080e7          	jalr	1198(ra) # 8000247c <wakeup>
  release(&pi->lock);
    80004fd6:	8526                	mv	a0,s1
    80004fd8:	ffffc097          	auipc	ra,0xffffc
    80004fdc:	cb2080e7          	jalr	-846(ra) # 80000c8a <release>
  return i;
}
    80004fe0:	854e                	mv	a0,s3
    80004fe2:	60a6                	ld	ra,72(sp)
    80004fe4:	6406                	ld	s0,64(sp)
    80004fe6:	74e2                	ld	s1,56(sp)
    80004fe8:	7942                	ld	s2,48(sp)
    80004fea:	79a2                	ld	s3,40(sp)
    80004fec:	7a02                	ld	s4,32(sp)
    80004fee:	6ae2                	ld	s5,24(sp)
    80004ff0:	6b42                	ld	s6,16(sp)
    80004ff2:	6161                	addi	sp,sp,80
    80004ff4:	8082                	ret
      release(&pi->lock);
    80004ff6:	8526                	mv	a0,s1
    80004ff8:	ffffc097          	auipc	ra,0xffffc
    80004ffc:	c92080e7          	jalr	-878(ra) # 80000c8a <release>
      return -1;
    80005000:	59fd                	li	s3,-1
    80005002:	bff9                	j	80004fe0 <piperead+0xca>

0000000080005004 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80005004:	1141                	addi	sp,sp,-16
    80005006:	e422                	sd	s0,8(sp)
    80005008:	0800                	addi	s0,sp,16
    8000500a:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    8000500c:	8905                	andi	a0,a0,1
    8000500e:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80005010:	8b89                	andi	a5,a5,2
    80005012:	c399                	beqz	a5,80005018 <flags2perm+0x14>
      perm |= PTE_W;
    80005014:	00456513          	ori	a0,a0,4
    return perm;
}
    80005018:	6422                	ld	s0,8(sp)
    8000501a:	0141                	addi	sp,sp,16
    8000501c:	8082                	ret

000000008000501e <exec>:

int
exec(char *path, char **argv)
{
    8000501e:	de010113          	addi	sp,sp,-544
    80005022:	20113c23          	sd	ra,536(sp)
    80005026:	20813823          	sd	s0,528(sp)
    8000502a:	20913423          	sd	s1,520(sp)
    8000502e:	21213023          	sd	s2,512(sp)
    80005032:	ffce                	sd	s3,504(sp)
    80005034:	fbd2                	sd	s4,496(sp)
    80005036:	f7d6                	sd	s5,488(sp)
    80005038:	f3da                	sd	s6,480(sp)
    8000503a:	efde                	sd	s7,472(sp)
    8000503c:	ebe2                	sd	s8,464(sp)
    8000503e:	e7e6                	sd	s9,456(sp)
    80005040:	e3ea                	sd	s10,448(sp)
    80005042:	ff6e                	sd	s11,440(sp)
    80005044:	1400                	addi	s0,sp,544
    80005046:	892a                	mv	s2,a0
    80005048:	dea43423          	sd	a0,-536(s0)
    8000504c:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005050:	ffffd097          	auipc	ra,0xffffd
    80005054:	bdc080e7          	jalr	-1060(ra) # 80001c2c <myproc>
    80005058:	84aa                	mv	s1,a0

  begin_op();
    8000505a:	fffff097          	auipc	ra,0xfffff
    8000505e:	482080e7          	jalr	1154(ra) # 800044dc <begin_op>

  if((ip = namei(path)) == 0){
    80005062:	854a                	mv	a0,s2
    80005064:	fffff097          	auipc	ra,0xfffff
    80005068:	258080e7          	jalr	600(ra) # 800042bc <namei>
    8000506c:	c93d                	beqz	a0,800050e2 <exec+0xc4>
    8000506e:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80005070:	fffff097          	auipc	ra,0xfffff
    80005074:	aa0080e7          	jalr	-1376(ra) # 80003b10 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005078:	04000713          	li	a4,64
    8000507c:	4681                	li	a3,0
    8000507e:	e5040613          	addi	a2,s0,-432
    80005082:	4581                	li	a1,0
    80005084:	8556                	mv	a0,s5
    80005086:	fffff097          	auipc	ra,0xfffff
    8000508a:	d3e080e7          	jalr	-706(ra) # 80003dc4 <readi>
    8000508e:	04000793          	li	a5,64
    80005092:	00f51a63          	bne	a0,a5,800050a6 <exec+0x88>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80005096:	e5042703          	lw	a4,-432(s0)
    8000509a:	464c47b7          	lui	a5,0x464c4
    8000509e:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800050a2:	04f70663          	beq	a4,a5,800050ee <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800050a6:	8556                	mv	a0,s5
    800050a8:	fffff097          	auipc	ra,0xfffff
    800050ac:	cca080e7          	jalr	-822(ra) # 80003d72 <iunlockput>
    end_op();
    800050b0:	fffff097          	auipc	ra,0xfffff
    800050b4:	4aa080e7          	jalr	1194(ra) # 8000455a <end_op>
  }
  return -1;
    800050b8:	557d                	li	a0,-1
}
    800050ba:	21813083          	ld	ra,536(sp)
    800050be:	21013403          	ld	s0,528(sp)
    800050c2:	20813483          	ld	s1,520(sp)
    800050c6:	20013903          	ld	s2,512(sp)
    800050ca:	79fe                	ld	s3,504(sp)
    800050cc:	7a5e                	ld	s4,496(sp)
    800050ce:	7abe                	ld	s5,488(sp)
    800050d0:	7b1e                	ld	s6,480(sp)
    800050d2:	6bfe                	ld	s7,472(sp)
    800050d4:	6c5e                	ld	s8,464(sp)
    800050d6:	6cbe                	ld	s9,456(sp)
    800050d8:	6d1e                	ld	s10,448(sp)
    800050da:	7dfa                	ld	s11,440(sp)
    800050dc:	22010113          	addi	sp,sp,544
    800050e0:	8082                	ret
    end_op();
    800050e2:	fffff097          	auipc	ra,0xfffff
    800050e6:	478080e7          	jalr	1144(ra) # 8000455a <end_op>
    return -1;
    800050ea:	557d                	li	a0,-1
    800050ec:	b7f9                	j	800050ba <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    800050ee:	8526                	mv	a0,s1
    800050f0:	ffffd097          	auipc	ra,0xffffd
    800050f4:	c00080e7          	jalr	-1024(ra) # 80001cf0 <proc_pagetable>
    800050f8:	8b2a                	mv	s6,a0
    800050fa:	d555                	beqz	a0,800050a6 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800050fc:	e7042783          	lw	a5,-400(s0)
    80005100:	e8845703          	lhu	a4,-376(s0)
    80005104:	c735                	beqz	a4,80005170 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005106:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005108:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    8000510c:	6a05                	lui	s4,0x1
    8000510e:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80005112:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80005116:	6d85                	lui	s11,0x1
    80005118:	7d7d                	lui	s10,0xfffff
    8000511a:	ac3d                	j	80005358 <exec+0x33a>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    8000511c:	00003517          	auipc	a0,0x3
    80005120:	6dc50513          	addi	a0,a0,1756 # 800087f8 <syscalls+0x2e8>
    80005124:	ffffb097          	auipc	ra,0xffffb
    80005128:	41c080e7          	jalr	1052(ra) # 80000540 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    8000512c:	874a                	mv	a4,s2
    8000512e:	009c86bb          	addw	a3,s9,s1
    80005132:	4581                	li	a1,0
    80005134:	8556                	mv	a0,s5
    80005136:	fffff097          	auipc	ra,0xfffff
    8000513a:	c8e080e7          	jalr	-882(ra) # 80003dc4 <readi>
    8000513e:	2501                	sext.w	a0,a0
    80005140:	1aa91963          	bne	s2,a0,800052f2 <exec+0x2d4>
  for(i = 0; i < sz; i += PGSIZE){
    80005144:	009d84bb          	addw	s1,s11,s1
    80005148:	013d09bb          	addw	s3,s10,s3
    8000514c:	1f74f663          	bgeu	s1,s7,80005338 <exec+0x31a>
    pa = walkaddr(pagetable, va + i);
    80005150:	02049593          	slli	a1,s1,0x20
    80005154:	9181                	srli	a1,a1,0x20
    80005156:	95e2                	add	a1,a1,s8
    80005158:	855a                	mv	a0,s6
    8000515a:	ffffc097          	auipc	ra,0xffffc
    8000515e:	f02080e7          	jalr	-254(ra) # 8000105c <walkaddr>
    80005162:	862a                	mv	a2,a0
    if(pa == 0)
    80005164:	dd45                	beqz	a0,8000511c <exec+0xfe>
      n = PGSIZE;
    80005166:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80005168:	fd49f2e3          	bgeu	s3,s4,8000512c <exec+0x10e>
      n = sz - i;
    8000516c:	894e                	mv	s2,s3
    8000516e:	bf7d                	j	8000512c <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005170:	4901                	li	s2,0
  iunlockput(ip);
    80005172:	8556                	mv	a0,s5
    80005174:	fffff097          	auipc	ra,0xfffff
    80005178:	bfe080e7          	jalr	-1026(ra) # 80003d72 <iunlockput>
  end_op();
    8000517c:	fffff097          	auipc	ra,0xfffff
    80005180:	3de080e7          	jalr	990(ra) # 8000455a <end_op>
  p = myproc();
    80005184:	ffffd097          	auipc	ra,0xffffd
    80005188:	aa8080e7          	jalr	-1368(ra) # 80001c2c <myproc>
    8000518c:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    8000518e:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80005192:	6785                	lui	a5,0x1
    80005194:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80005196:	97ca                	add	a5,a5,s2
    80005198:	777d                	lui	a4,0xfffff
    8000519a:	8ff9                	and	a5,a5,a4
    8000519c:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800051a0:	4691                	li	a3,4
    800051a2:	6609                	lui	a2,0x2
    800051a4:	963e                	add	a2,a2,a5
    800051a6:	85be                	mv	a1,a5
    800051a8:	855a                	mv	a0,s6
    800051aa:	ffffc097          	auipc	ra,0xffffc
    800051ae:	266080e7          	jalr	614(ra) # 80001410 <uvmalloc>
    800051b2:	8c2a                	mv	s8,a0
  ip = 0;
    800051b4:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800051b6:	12050e63          	beqz	a0,800052f2 <exec+0x2d4>
  uvmclear(pagetable, sz-2*PGSIZE);
    800051ba:	75f9                	lui	a1,0xffffe
    800051bc:	95aa                	add	a1,a1,a0
    800051be:	855a                	mv	a0,s6
    800051c0:	ffffc097          	auipc	ra,0xffffc
    800051c4:	47a080e7          	jalr	1146(ra) # 8000163a <uvmclear>
  stackbase = sp - PGSIZE;
    800051c8:	7afd                	lui	s5,0xfffff
    800051ca:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    800051cc:	df043783          	ld	a5,-528(s0)
    800051d0:	6388                	ld	a0,0(a5)
    800051d2:	c925                	beqz	a0,80005242 <exec+0x224>
    800051d4:	e9040993          	addi	s3,s0,-368
    800051d8:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    800051dc:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    800051de:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800051e0:	ffffc097          	auipc	ra,0xffffc
    800051e4:	c6e080e7          	jalr	-914(ra) # 80000e4e <strlen>
    800051e8:	0015079b          	addiw	a5,a0,1
    800051ec:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800051f0:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    800051f4:	13596663          	bltu	s2,s5,80005320 <exec+0x302>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800051f8:	df043d83          	ld	s11,-528(s0)
    800051fc:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80005200:	8552                	mv	a0,s4
    80005202:	ffffc097          	auipc	ra,0xffffc
    80005206:	c4c080e7          	jalr	-948(ra) # 80000e4e <strlen>
    8000520a:	0015069b          	addiw	a3,a0,1
    8000520e:	8652                	mv	a2,s4
    80005210:	85ca                	mv	a1,s2
    80005212:	855a                	mv	a0,s6
    80005214:	ffffc097          	auipc	ra,0xffffc
    80005218:	458080e7          	jalr	1112(ra) # 8000166c <copyout>
    8000521c:	10054663          	bltz	a0,80005328 <exec+0x30a>
    ustack[argc] = sp;
    80005220:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005224:	0485                	addi	s1,s1,1
    80005226:	008d8793          	addi	a5,s11,8
    8000522a:	def43823          	sd	a5,-528(s0)
    8000522e:	008db503          	ld	a0,8(s11)
    80005232:	c911                	beqz	a0,80005246 <exec+0x228>
    if(argc >= MAXARG)
    80005234:	09a1                	addi	s3,s3,8
    80005236:	fb3c95e3          	bne	s9,s3,800051e0 <exec+0x1c2>
  sz = sz1;
    8000523a:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000523e:	4a81                	li	s5,0
    80005240:	a84d                	j	800052f2 <exec+0x2d4>
  sp = sz;
    80005242:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005244:	4481                	li	s1,0
  ustack[argc] = 0;
    80005246:	00349793          	slli	a5,s1,0x3
    8000524a:	f9078793          	addi	a5,a5,-112
    8000524e:	97a2                	add	a5,a5,s0
    80005250:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80005254:	00148693          	addi	a3,s1,1
    80005258:	068e                	slli	a3,a3,0x3
    8000525a:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000525e:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005262:	01597663          	bgeu	s2,s5,8000526e <exec+0x250>
  sz = sz1;
    80005266:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000526a:	4a81                	li	s5,0
    8000526c:	a059                	j	800052f2 <exec+0x2d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000526e:	e9040613          	addi	a2,s0,-368
    80005272:	85ca                	mv	a1,s2
    80005274:	855a                	mv	a0,s6
    80005276:	ffffc097          	auipc	ra,0xffffc
    8000527a:	3f6080e7          	jalr	1014(ra) # 8000166c <copyout>
    8000527e:	0a054963          	bltz	a0,80005330 <exec+0x312>
  p->trapframe->a1 = sp;
    80005282:	058bb783          	ld	a5,88(s7)
    80005286:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000528a:	de843783          	ld	a5,-536(s0)
    8000528e:	0007c703          	lbu	a4,0(a5)
    80005292:	cf11                	beqz	a4,800052ae <exec+0x290>
    80005294:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005296:	02f00693          	li	a3,47
    8000529a:	a039                	j	800052a8 <exec+0x28a>
      last = s+1;
    8000529c:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    800052a0:	0785                	addi	a5,a5,1
    800052a2:	fff7c703          	lbu	a4,-1(a5)
    800052a6:	c701                	beqz	a4,800052ae <exec+0x290>
    if(*s == '/')
    800052a8:	fed71ce3          	bne	a4,a3,800052a0 <exec+0x282>
    800052ac:	bfc5                	j	8000529c <exec+0x27e>
  safestrcpy(p->name, last, sizeof(p->name));
    800052ae:	4641                	li	a2,16
    800052b0:	de843583          	ld	a1,-536(s0)
    800052b4:	158b8513          	addi	a0,s7,344
    800052b8:	ffffc097          	auipc	ra,0xffffc
    800052bc:	b64080e7          	jalr	-1180(ra) # 80000e1c <safestrcpy>
  oldpagetable = p->pagetable;
    800052c0:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    800052c4:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    800052c8:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800052cc:	058bb783          	ld	a5,88(s7)
    800052d0:	e6843703          	ld	a4,-408(s0)
    800052d4:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800052d6:	058bb783          	ld	a5,88(s7)
    800052da:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800052de:	85ea                	mv	a1,s10
    800052e0:	ffffd097          	auipc	ra,0xffffd
    800052e4:	aac080e7          	jalr	-1364(ra) # 80001d8c <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800052e8:	0004851b          	sext.w	a0,s1
    800052ec:	b3f9                	j	800050ba <exec+0x9c>
    800052ee:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    800052f2:	df843583          	ld	a1,-520(s0)
    800052f6:	855a                	mv	a0,s6
    800052f8:	ffffd097          	auipc	ra,0xffffd
    800052fc:	a94080e7          	jalr	-1388(ra) # 80001d8c <proc_freepagetable>
  if(ip){
    80005300:	da0a93e3          	bnez	s5,800050a6 <exec+0x88>
  return -1;
    80005304:	557d                	li	a0,-1
    80005306:	bb55                	j	800050ba <exec+0x9c>
    80005308:	df243c23          	sd	s2,-520(s0)
    8000530c:	b7dd                	j	800052f2 <exec+0x2d4>
    8000530e:	df243c23          	sd	s2,-520(s0)
    80005312:	b7c5                	j	800052f2 <exec+0x2d4>
    80005314:	df243c23          	sd	s2,-520(s0)
    80005318:	bfe9                	j	800052f2 <exec+0x2d4>
    8000531a:	df243c23          	sd	s2,-520(s0)
    8000531e:	bfd1                	j	800052f2 <exec+0x2d4>
  sz = sz1;
    80005320:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005324:	4a81                	li	s5,0
    80005326:	b7f1                	j	800052f2 <exec+0x2d4>
  sz = sz1;
    80005328:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000532c:	4a81                	li	s5,0
    8000532e:	b7d1                	j	800052f2 <exec+0x2d4>
  sz = sz1;
    80005330:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005334:	4a81                	li	s5,0
    80005336:	bf75                	j	800052f2 <exec+0x2d4>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005338:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000533c:	e0843783          	ld	a5,-504(s0)
    80005340:	0017869b          	addiw	a3,a5,1
    80005344:	e0d43423          	sd	a3,-504(s0)
    80005348:	e0043783          	ld	a5,-512(s0)
    8000534c:	0387879b          	addiw	a5,a5,56
    80005350:	e8845703          	lhu	a4,-376(s0)
    80005354:	e0e6dfe3          	bge	a3,a4,80005172 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005358:	2781                	sext.w	a5,a5
    8000535a:	e0f43023          	sd	a5,-512(s0)
    8000535e:	03800713          	li	a4,56
    80005362:	86be                	mv	a3,a5
    80005364:	e1840613          	addi	a2,s0,-488
    80005368:	4581                	li	a1,0
    8000536a:	8556                	mv	a0,s5
    8000536c:	fffff097          	auipc	ra,0xfffff
    80005370:	a58080e7          	jalr	-1448(ra) # 80003dc4 <readi>
    80005374:	03800793          	li	a5,56
    80005378:	f6f51be3          	bne	a0,a5,800052ee <exec+0x2d0>
    if(ph.type != ELF_PROG_LOAD)
    8000537c:	e1842783          	lw	a5,-488(s0)
    80005380:	4705                	li	a4,1
    80005382:	fae79de3          	bne	a5,a4,8000533c <exec+0x31e>
    if(ph.memsz < ph.filesz)
    80005386:	e4043483          	ld	s1,-448(s0)
    8000538a:	e3843783          	ld	a5,-456(s0)
    8000538e:	f6f4ede3          	bltu	s1,a5,80005308 <exec+0x2ea>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005392:	e2843783          	ld	a5,-472(s0)
    80005396:	94be                	add	s1,s1,a5
    80005398:	f6f4ebe3          	bltu	s1,a5,8000530e <exec+0x2f0>
    if(ph.vaddr % PGSIZE != 0)
    8000539c:	de043703          	ld	a4,-544(s0)
    800053a0:	8ff9                	and	a5,a5,a4
    800053a2:	fbad                	bnez	a5,80005314 <exec+0x2f6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800053a4:	e1c42503          	lw	a0,-484(s0)
    800053a8:	00000097          	auipc	ra,0x0
    800053ac:	c5c080e7          	jalr	-932(ra) # 80005004 <flags2perm>
    800053b0:	86aa                	mv	a3,a0
    800053b2:	8626                	mv	a2,s1
    800053b4:	85ca                	mv	a1,s2
    800053b6:	855a                	mv	a0,s6
    800053b8:	ffffc097          	auipc	ra,0xffffc
    800053bc:	058080e7          	jalr	88(ra) # 80001410 <uvmalloc>
    800053c0:	dea43c23          	sd	a0,-520(s0)
    800053c4:	d939                	beqz	a0,8000531a <exec+0x2fc>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800053c6:	e2843c03          	ld	s8,-472(s0)
    800053ca:	e2042c83          	lw	s9,-480(s0)
    800053ce:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800053d2:	f60b83e3          	beqz	s7,80005338 <exec+0x31a>
    800053d6:	89de                	mv	s3,s7
    800053d8:	4481                	li	s1,0
    800053da:	bb9d                	j	80005150 <exec+0x132>

00000000800053dc <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800053dc:	7179                	addi	sp,sp,-48
    800053de:	f406                	sd	ra,40(sp)
    800053e0:	f022                	sd	s0,32(sp)
    800053e2:	ec26                	sd	s1,24(sp)
    800053e4:	e84a                	sd	s2,16(sp)
    800053e6:	1800                	addi	s0,sp,48
    800053e8:	892e                	mv	s2,a1
    800053ea:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800053ec:	fdc40593          	addi	a1,s0,-36
    800053f0:	ffffe097          	auipc	ra,0xffffe
    800053f4:	b3a080e7          	jalr	-1222(ra) # 80002f2a <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800053f8:	fdc42703          	lw	a4,-36(s0)
    800053fc:	47bd                	li	a5,15
    800053fe:	02e7eb63          	bltu	a5,a4,80005434 <argfd+0x58>
    80005402:	ffffd097          	auipc	ra,0xffffd
    80005406:	82a080e7          	jalr	-2006(ra) # 80001c2c <myproc>
    8000540a:	fdc42703          	lw	a4,-36(s0)
    8000540e:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7ffdc552>
    80005412:	078e                	slli	a5,a5,0x3
    80005414:	953e                	add	a0,a0,a5
    80005416:	611c                	ld	a5,0(a0)
    80005418:	c385                	beqz	a5,80005438 <argfd+0x5c>
    return -1;
  if(pfd)
    8000541a:	00090463          	beqz	s2,80005422 <argfd+0x46>
    *pfd = fd;
    8000541e:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005422:	4501                	li	a0,0
  if(pf)
    80005424:	c091                	beqz	s1,80005428 <argfd+0x4c>
    *pf = f;
    80005426:	e09c                	sd	a5,0(s1)
}
    80005428:	70a2                	ld	ra,40(sp)
    8000542a:	7402                	ld	s0,32(sp)
    8000542c:	64e2                	ld	s1,24(sp)
    8000542e:	6942                	ld	s2,16(sp)
    80005430:	6145                	addi	sp,sp,48
    80005432:	8082                	ret
    return -1;
    80005434:	557d                	li	a0,-1
    80005436:	bfcd                	j	80005428 <argfd+0x4c>
    80005438:	557d                	li	a0,-1
    8000543a:	b7fd                	j	80005428 <argfd+0x4c>

000000008000543c <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000543c:	1101                	addi	sp,sp,-32
    8000543e:	ec06                	sd	ra,24(sp)
    80005440:	e822                	sd	s0,16(sp)
    80005442:	e426                	sd	s1,8(sp)
    80005444:	1000                	addi	s0,sp,32
    80005446:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005448:	ffffc097          	auipc	ra,0xffffc
    8000544c:	7e4080e7          	jalr	2020(ra) # 80001c2c <myproc>
    80005450:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005452:	0d050793          	addi	a5,a0,208
    80005456:	4501                	li	a0,0
    80005458:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000545a:	6398                	ld	a4,0(a5)
    8000545c:	cb19                	beqz	a4,80005472 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    8000545e:	2505                	addiw	a0,a0,1
    80005460:	07a1                	addi	a5,a5,8
    80005462:	fed51ce3          	bne	a0,a3,8000545a <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005466:	557d                	li	a0,-1
}
    80005468:	60e2                	ld	ra,24(sp)
    8000546a:	6442                	ld	s0,16(sp)
    8000546c:	64a2                	ld	s1,8(sp)
    8000546e:	6105                	addi	sp,sp,32
    80005470:	8082                	ret
      p->ofile[fd] = f;
    80005472:	01a50793          	addi	a5,a0,26
    80005476:	078e                	slli	a5,a5,0x3
    80005478:	963e                	add	a2,a2,a5
    8000547a:	e204                	sd	s1,0(a2)
      return fd;
    8000547c:	b7f5                	j	80005468 <fdalloc+0x2c>

000000008000547e <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000547e:	715d                	addi	sp,sp,-80
    80005480:	e486                	sd	ra,72(sp)
    80005482:	e0a2                	sd	s0,64(sp)
    80005484:	fc26                	sd	s1,56(sp)
    80005486:	f84a                	sd	s2,48(sp)
    80005488:	f44e                	sd	s3,40(sp)
    8000548a:	f052                	sd	s4,32(sp)
    8000548c:	ec56                	sd	s5,24(sp)
    8000548e:	e85a                	sd	s6,16(sp)
    80005490:	0880                	addi	s0,sp,80
    80005492:	8b2e                	mv	s6,a1
    80005494:	89b2                	mv	s3,a2
    80005496:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005498:	fb040593          	addi	a1,s0,-80
    8000549c:	fffff097          	auipc	ra,0xfffff
    800054a0:	e3e080e7          	jalr	-450(ra) # 800042da <nameiparent>
    800054a4:	84aa                	mv	s1,a0
    800054a6:	14050f63          	beqz	a0,80005604 <create+0x186>
    return 0;

  ilock(dp);
    800054aa:	ffffe097          	auipc	ra,0xffffe
    800054ae:	666080e7          	jalr	1638(ra) # 80003b10 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800054b2:	4601                	li	a2,0
    800054b4:	fb040593          	addi	a1,s0,-80
    800054b8:	8526                	mv	a0,s1
    800054ba:	fffff097          	auipc	ra,0xfffff
    800054be:	b3a080e7          	jalr	-1222(ra) # 80003ff4 <dirlookup>
    800054c2:	8aaa                	mv	s5,a0
    800054c4:	c931                	beqz	a0,80005518 <create+0x9a>
    iunlockput(dp);
    800054c6:	8526                	mv	a0,s1
    800054c8:	fffff097          	auipc	ra,0xfffff
    800054cc:	8aa080e7          	jalr	-1878(ra) # 80003d72 <iunlockput>
    ilock(ip);
    800054d0:	8556                	mv	a0,s5
    800054d2:	ffffe097          	auipc	ra,0xffffe
    800054d6:	63e080e7          	jalr	1598(ra) # 80003b10 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800054da:	000b059b          	sext.w	a1,s6
    800054de:	4789                	li	a5,2
    800054e0:	02f59563          	bne	a1,a5,8000550a <create+0x8c>
    800054e4:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffdc57c>
    800054e8:	37f9                	addiw	a5,a5,-2
    800054ea:	17c2                	slli	a5,a5,0x30
    800054ec:	93c1                	srli	a5,a5,0x30
    800054ee:	4705                	li	a4,1
    800054f0:	00f76d63          	bltu	a4,a5,8000550a <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800054f4:	8556                	mv	a0,s5
    800054f6:	60a6                	ld	ra,72(sp)
    800054f8:	6406                	ld	s0,64(sp)
    800054fa:	74e2                	ld	s1,56(sp)
    800054fc:	7942                	ld	s2,48(sp)
    800054fe:	79a2                	ld	s3,40(sp)
    80005500:	7a02                	ld	s4,32(sp)
    80005502:	6ae2                	ld	s5,24(sp)
    80005504:	6b42                	ld	s6,16(sp)
    80005506:	6161                	addi	sp,sp,80
    80005508:	8082                	ret
    iunlockput(ip);
    8000550a:	8556                	mv	a0,s5
    8000550c:	fffff097          	auipc	ra,0xfffff
    80005510:	866080e7          	jalr	-1946(ra) # 80003d72 <iunlockput>
    return 0;
    80005514:	4a81                	li	s5,0
    80005516:	bff9                	j	800054f4 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    80005518:	85da                	mv	a1,s6
    8000551a:	4088                	lw	a0,0(s1)
    8000551c:	ffffe097          	auipc	ra,0xffffe
    80005520:	456080e7          	jalr	1110(ra) # 80003972 <ialloc>
    80005524:	8a2a                	mv	s4,a0
    80005526:	c539                	beqz	a0,80005574 <create+0xf6>
  ilock(ip);
    80005528:	ffffe097          	auipc	ra,0xffffe
    8000552c:	5e8080e7          	jalr	1512(ra) # 80003b10 <ilock>
  ip->major = major;
    80005530:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005534:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005538:	4905                	li	s2,1
    8000553a:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    8000553e:	8552                	mv	a0,s4
    80005540:	ffffe097          	auipc	ra,0xffffe
    80005544:	504080e7          	jalr	1284(ra) # 80003a44 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005548:	000b059b          	sext.w	a1,s6
    8000554c:	03258b63          	beq	a1,s2,80005582 <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    80005550:	004a2603          	lw	a2,4(s4)
    80005554:	fb040593          	addi	a1,s0,-80
    80005558:	8526                	mv	a0,s1
    8000555a:	fffff097          	auipc	ra,0xfffff
    8000555e:	cb0080e7          	jalr	-848(ra) # 8000420a <dirlink>
    80005562:	06054f63          	bltz	a0,800055e0 <create+0x162>
  iunlockput(dp);
    80005566:	8526                	mv	a0,s1
    80005568:	fffff097          	auipc	ra,0xfffff
    8000556c:	80a080e7          	jalr	-2038(ra) # 80003d72 <iunlockput>
  return ip;
    80005570:	8ad2                	mv	s5,s4
    80005572:	b749                	j	800054f4 <create+0x76>
    iunlockput(dp);
    80005574:	8526                	mv	a0,s1
    80005576:	ffffe097          	auipc	ra,0xffffe
    8000557a:	7fc080e7          	jalr	2044(ra) # 80003d72 <iunlockput>
    return 0;
    8000557e:	8ad2                	mv	s5,s4
    80005580:	bf95                	j	800054f4 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005582:	004a2603          	lw	a2,4(s4)
    80005586:	00003597          	auipc	a1,0x3
    8000558a:	29258593          	addi	a1,a1,658 # 80008818 <syscalls+0x308>
    8000558e:	8552                	mv	a0,s4
    80005590:	fffff097          	auipc	ra,0xfffff
    80005594:	c7a080e7          	jalr	-902(ra) # 8000420a <dirlink>
    80005598:	04054463          	bltz	a0,800055e0 <create+0x162>
    8000559c:	40d0                	lw	a2,4(s1)
    8000559e:	00003597          	auipc	a1,0x3
    800055a2:	28258593          	addi	a1,a1,642 # 80008820 <syscalls+0x310>
    800055a6:	8552                	mv	a0,s4
    800055a8:	fffff097          	auipc	ra,0xfffff
    800055ac:	c62080e7          	jalr	-926(ra) # 8000420a <dirlink>
    800055b0:	02054863          	bltz	a0,800055e0 <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    800055b4:	004a2603          	lw	a2,4(s4)
    800055b8:	fb040593          	addi	a1,s0,-80
    800055bc:	8526                	mv	a0,s1
    800055be:	fffff097          	auipc	ra,0xfffff
    800055c2:	c4c080e7          	jalr	-948(ra) # 8000420a <dirlink>
    800055c6:	00054d63          	bltz	a0,800055e0 <create+0x162>
    dp->nlink++;  // for ".."
    800055ca:	04a4d783          	lhu	a5,74(s1)
    800055ce:	2785                	addiw	a5,a5,1
    800055d0:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800055d4:	8526                	mv	a0,s1
    800055d6:	ffffe097          	auipc	ra,0xffffe
    800055da:	46e080e7          	jalr	1134(ra) # 80003a44 <iupdate>
    800055de:	b761                	j	80005566 <create+0xe8>
  ip->nlink = 0;
    800055e0:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800055e4:	8552                	mv	a0,s4
    800055e6:	ffffe097          	auipc	ra,0xffffe
    800055ea:	45e080e7          	jalr	1118(ra) # 80003a44 <iupdate>
  iunlockput(ip);
    800055ee:	8552                	mv	a0,s4
    800055f0:	ffffe097          	auipc	ra,0xffffe
    800055f4:	782080e7          	jalr	1922(ra) # 80003d72 <iunlockput>
  iunlockput(dp);
    800055f8:	8526                	mv	a0,s1
    800055fa:	ffffe097          	auipc	ra,0xffffe
    800055fe:	778080e7          	jalr	1912(ra) # 80003d72 <iunlockput>
  return 0;
    80005602:	bdcd                	j	800054f4 <create+0x76>
    return 0;
    80005604:	8aaa                	mv	s5,a0
    80005606:	b5fd                	j	800054f4 <create+0x76>

0000000080005608 <sys_dup>:
{
    80005608:	7179                	addi	sp,sp,-48
    8000560a:	f406                	sd	ra,40(sp)
    8000560c:	f022                	sd	s0,32(sp)
    8000560e:	ec26                	sd	s1,24(sp)
    80005610:	e84a                	sd	s2,16(sp)
    80005612:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005614:	fd840613          	addi	a2,s0,-40
    80005618:	4581                	li	a1,0
    8000561a:	4501                	li	a0,0
    8000561c:	00000097          	auipc	ra,0x0
    80005620:	dc0080e7          	jalr	-576(ra) # 800053dc <argfd>
    return -1;
    80005624:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005626:	02054363          	bltz	a0,8000564c <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    8000562a:	fd843903          	ld	s2,-40(s0)
    8000562e:	854a                	mv	a0,s2
    80005630:	00000097          	auipc	ra,0x0
    80005634:	e0c080e7          	jalr	-500(ra) # 8000543c <fdalloc>
    80005638:	84aa                	mv	s1,a0
    return -1;
    8000563a:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000563c:	00054863          	bltz	a0,8000564c <sys_dup+0x44>
  filedup(f);
    80005640:	854a                	mv	a0,s2
    80005642:	fffff097          	auipc	ra,0xfffff
    80005646:	310080e7          	jalr	784(ra) # 80004952 <filedup>
  return fd;
    8000564a:	87a6                	mv	a5,s1
}
    8000564c:	853e                	mv	a0,a5
    8000564e:	70a2                	ld	ra,40(sp)
    80005650:	7402                	ld	s0,32(sp)
    80005652:	64e2                	ld	s1,24(sp)
    80005654:	6942                	ld	s2,16(sp)
    80005656:	6145                	addi	sp,sp,48
    80005658:	8082                	ret

000000008000565a <sys_read>:
{
    8000565a:	7179                	addi	sp,sp,-48
    8000565c:	f406                	sd	ra,40(sp)
    8000565e:	f022                	sd	s0,32(sp)
    80005660:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005662:	fd840593          	addi	a1,s0,-40
    80005666:	4505                	li	a0,1
    80005668:	ffffe097          	auipc	ra,0xffffe
    8000566c:	8e2080e7          	jalr	-1822(ra) # 80002f4a <argaddr>
  argint(2, &n);
    80005670:	fe440593          	addi	a1,s0,-28
    80005674:	4509                	li	a0,2
    80005676:	ffffe097          	auipc	ra,0xffffe
    8000567a:	8b4080e7          	jalr	-1868(ra) # 80002f2a <argint>
  if(argfd(0, 0, &f) < 0)
    8000567e:	fe840613          	addi	a2,s0,-24
    80005682:	4581                	li	a1,0
    80005684:	4501                	li	a0,0
    80005686:	00000097          	auipc	ra,0x0
    8000568a:	d56080e7          	jalr	-682(ra) # 800053dc <argfd>
    8000568e:	87aa                	mv	a5,a0
    return -1;
    80005690:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005692:	0007cc63          	bltz	a5,800056aa <sys_read+0x50>
  return fileread(f, p, n);
    80005696:	fe442603          	lw	a2,-28(s0)
    8000569a:	fd843583          	ld	a1,-40(s0)
    8000569e:	fe843503          	ld	a0,-24(s0)
    800056a2:	fffff097          	auipc	ra,0xfffff
    800056a6:	43c080e7          	jalr	1084(ra) # 80004ade <fileread>
}
    800056aa:	70a2                	ld	ra,40(sp)
    800056ac:	7402                	ld	s0,32(sp)
    800056ae:	6145                	addi	sp,sp,48
    800056b0:	8082                	ret

00000000800056b2 <sys_write>:
{
    800056b2:	7179                	addi	sp,sp,-48
    800056b4:	f406                	sd	ra,40(sp)
    800056b6:	f022                	sd	s0,32(sp)
    800056b8:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800056ba:	fd840593          	addi	a1,s0,-40
    800056be:	4505                	li	a0,1
    800056c0:	ffffe097          	auipc	ra,0xffffe
    800056c4:	88a080e7          	jalr	-1910(ra) # 80002f4a <argaddr>
  argint(2, &n);
    800056c8:	fe440593          	addi	a1,s0,-28
    800056cc:	4509                	li	a0,2
    800056ce:	ffffe097          	auipc	ra,0xffffe
    800056d2:	85c080e7          	jalr	-1956(ra) # 80002f2a <argint>
  if(argfd(0, 0, &f) < 0)
    800056d6:	fe840613          	addi	a2,s0,-24
    800056da:	4581                	li	a1,0
    800056dc:	4501                	li	a0,0
    800056de:	00000097          	auipc	ra,0x0
    800056e2:	cfe080e7          	jalr	-770(ra) # 800053dc <argfd>
    800056e6:	87aa                	mv	a5,a0
    return -1;
    800056e8:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800056ea:	0007cc63          	bltz	a5,80005702 <sys_write+0x50>
  return filewrite(f, p, n);
    800056ee:	fe442603          	lw	a2,-28(s0)
    800056f2:	fd843583          	ld	a1,-40(s0)
    800056f6:	fe843503          	ld	a0,-24(s0)
    800056fa:	fffff097          	auipc	ra,0xfffff
    800056fe:	4a6080e7          	jalr	1190(ra) # 80004ba0 <filewrite>
}
    80005702:	70a2                	ld	ra,40(sp)
    80005704:	7402                	ld	s0,32(sp)
    80005706:	6145                	addi	sp,sp,48
    80005708:	8082                	ret

000000008000570a <sys_close>:
{
    8000570a:	1101                	addi	sp,sp,-32
    8000570c:	ec06                	sd	ra,24(sp)
    8000570e:	e822                	sd	s0,16(sp)
    80005710:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005712:	fe040613          	addi	a2,s0,-32
    80005716:	fec40593          	addi	a1,s0,-20
    8000571a:	4501                	li	a0,0
    8000571c:	00000097          	auipc	ra,0x0
    80005720:	cc0080e7          	jalr	-832(ra) # 800053dc <argfd>
    return -1;
    80005724:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005726:	02054463          	bltz	a0,8000574e <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    8000572a:	ffffc097          	auipc	ra,0xffffc
    8000572e:	502080e7          	jalr	1282(ra) # 80001c2c <myproc>
    80005732:	fec42783          	lw	a5,-20(s0)
    80005736:	07e9                	addi	a5,a5,26
    80005738:	078e                	slli	a5,a5,0x3
    8000573a:	953e                	add	a0,a0,a5
    8000573c:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005740:	fe043503          	ld	a0,-32(s0)
    80005744:	fffff097          	auipc	ra,0xfffff
    80005748:	260080e7          	jalr	608(ra) # 800049a4 <fileclose>
  return 0;
    8000574c:	4781                	li	a5,0
}
    8000574e:	853e                	mv	a0,a5
    80005750:	60e2                	ld	ra,24(sp)
    80005752:	6442                	ld	s0,16(sp)
    80005754:	6105                	addi	sp,sp,32
    80005756:	8082                	ret

0000000080005758 <sys_fstat>:
{
    80005758:	1101                	addi	sp,sp,-32
    8000575a:	ec06                	sd	ra,24(sp)
    8000575c:	e822                	sd	s0,16(sp)
    8000575e:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005760:	fe040593          	addi	a1,s0,-32
    80005764:	4505                	li	a0,1
    80005766:	ffffd097          	auipc	ra,0xffffd
    8000576a:	7e4080e7          	jalr	2020(ra) # 80002f4a <argaddr>
  if(argfd(0, 0, &f) < 0)
    8000576e:	fe840613          	addi	a2,s0,-24
    80005772:	4581                	li	a1,0
    80005774:	4501                	li	a0,0
    80005776:	00000097          	auipc	ra,0x0
    8000577a:	c66080e7          	jalr	-922(ra) # 800053dc <argfd>
    8000577e:	87aa                	mv	a5,a0
    return -1;
    80005780:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005782:	0007ca63          	bltz	a5,80005796 <sys_fstat+0x3e>
  return filestat(f, st);
    80005786:	fe043583          	ld	a1,-32(s0)
    8000578a:	fe843503          	ld	a0,-24(s0)
    8000578e:	fffff097          	auipc	ra,0xfffff
    80005792:	2de080e7          	jalr	734(ra) # 80004a6c <filestat>
}
    80005796:	60e2                	ld	ra,24(sp)
    80005798:	6442                	ld	s0,16(sp)
    8000579a:	6105                	addi	sp,sp,32
    8000579c:	8082                	ret

000000008000579e <sys_link>:
{
    8000579e:	7169                	addi	sp,sp,-304
    800057a0:	f606                	sd	ra,296(sp)
    800057a2:	f222                	sd	s0,288(sp)
    800057a4:	ee26                	sd	s1,280(sp)
    800057a6:	ea4a                	sd	s2,272(sp)
    800057a8:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800057aa:	08000613          	li	a2,128
    800057ae:	ed040593          	addi	a1,s0,-304
    800057b2:	4501                	li	a0,0
    800057b4:	ffffd097          	auipc	ra,0xffffd
    800057b8:	7b6080e7          	jalr	1974(ra) # 80002f6a <argstr>
    return -1;
    800057bc:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800057be:	10054e63          	bltz	a0,800058da <sys_link+0x13c>
    800057c2:	08000613          	li	a2,128
    800057c6:	f5040593          	addi	a1,s0,-176
    800057ca:	4505                	li	a0,1
    800057cc:	ffffd097          	auipc	ra,0xffffd
    800057d0:	79e080e7          	jalr	1950(ra) # 80002f6a <argstr>
    return -1;
    800057d4:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800057d6:	10054263          	bltz	a0,800058da <sys_link+0x13c>
  begin_op();
    800057da:	fffff097          	auipc	ra,0xfffff
    800057de:	d02080e7          	jalr	-766(ra) # 800044dc <begin_op>
  if((ip = namei(old)) == 0){
    800057e2:	ed040513          	addi	a0,s0,-304
    800057e6:	fffff097          	auipc	ra,0xfffff
    800057ea:	ad6080e7          	jalr	-1322(ra) # 800042bc <namei>
    800057ee:	84aa                	mv	s1,a0
    800057f0:	c551                	beqz	a0,8000587c <sys_link+0xde>
  ilock(ip);
    800057f2:	ffffe097          	auipc	ra,0xffffe
    800057f6:	31e080e7          	jalr	798(ra) # 80003b10 <ilock>
  if(ip->type == T_DIR){
    800057fa:	04449703          	lh	a4,68(s1)
    800057fe:	4785                	li	a5,1
    80005800:	08f70463          	beq	a4,a5,80005888 <sys_link+0xea>
  ip->nlink++;
    80005804:	04a4d783          	lhu	a5,74(s1)
    80005808:	2785                	addiw	a5,a5,1
    8000580a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000580e:	8526                	mv	a0,s1
    80005810:	ffffe097          	auipc	ra,0xffffe
    80005814:	234080e7          	jalr	564(ra) # 80003a44 <iupdate>
  iunlock(ip);
    80005818:	8526                	mv	a0,s1
    8000581a:	ffffe097          	auipc	ra,0xffffe
    8000581e:	3b8080e7          	jalr	952(ra) # 80003bd2 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005822:	fd040593          	addi	a1,s0,-48
    80005826:	f5040513          	addi	a0,s0,-176
    8000582a:	fffff097          	auipc	ra,0xfffff
    8000582e:	ab0080e7          	jalr	-1360(ra) # 800042da <nameiparent>
    80005832:	892a                	mv	s2,a0
    80005834:	c935                	beqz	a0,800058a8 <sys_link+0x10a>
  ilock(dp);
    80005836:	ffffe097          	auipc	ra,0xffffe
    8000583a:	2da080e7          	jalr	730(ra) # 80003b10 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000583e:	00092703          	lw	a4,0(s2)
    80005842:	409c                	lw	a5,0(s1)
    80005844:	04f71d63          	bne	a4,a5,8000589e <sys_link+0x100>
    80005848:	40d0                	lw	a2,4(s1)
    8000584a:	fd040593          	addi	a1,s0,-48
    8000584e:	854a                	mv	a0,s2
    80005850:	fffff097          	auipc	ra,0xfffff
    80005854:	9ba080e7          	jalr	-1606(ra) # 8000420a <dirlink>
    80005858:	04054363          	bltz	a0,8000589e <sys_link+0x100>
  iunlockput(dp);
    8000585c:	854a                	mv	a0,s2
    8000585e:	ffffe097          	auipc	ra,0xffffe
    80005862:	514080e7          	jalr	1300(ra) # 80003d72 <iunlockput>
  iput(ip);
    80005866:	8526                	mv	a0,s1
    80005868:	ffffe097          	auipc	ra,0xffffe
    8000586c:	462080e7          	jalr	1122(ra) # 80003cca <iput>
  end_op();
    80005870:	fffff097          	auipc	ra,0xfffff
    80005874:	cea080e7          	jalr	-790(ra) # 8000455a <end_op>
  return 0;
    80005878:	4781                	li	a5,0
    8000587a:	a085                	j	800058da <sys_link+0x13c>
    end_op();
    8000587c:	fffff097          	auipc	ra,0xfffff
    80005880:	cde080e7          	jalr	-802(ra) # 8000455a <end_op>
    return -1;
    80005884:	57fd                	li	a5,-1
    80005886:	a891                	j	800058da <sys_link+0x13c>
    iunlockput(ip);
    80005888:	8526                	mv	a0,s1
    8000588a:	ffffe097          	auipc	ra,0xffffe
    8000588e:	4e8080e7          	jalr	1256(ra) # 80003d72 <iunlockput>
    end_op();
    80005892:	fffff097          	auipc	ra,0xfffff
    80005896:	cc8080e7          	jalr	-824(ra) # 8000455a <end_op>
    return -1;
    8000589a:	57fd                	li	a5,-1
    8000589c:	a83d                	j	800058da <sys_link+0x13c>
    iunlockput(dp);
    8000589e:	854a                	mv	a0,s2
    800058a0:	ffffe097          	auipc	ra,0xffffe
    800058a4:	4d2080e7          	jalr	1234(ra) # 80003d72 <iunlockput>
  ilock(ip);
    800058a8:	8526                	mv	a0,s1
    800058aa:	ffffe097          	auipc	ra,0xffffe
    800058ae:	266080e7          	jalr	614(ra) # 80003b10 <ilock>
  ip->nlink--;
    800058b2:	04a4d783          	lhu	a5,74(s1)
    800058b6:	37fd                	addiw	a5,a5,-1
    800058b8:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800058bc:	8526                	mv	a0,s1
    800058be:	ffffe097          	auipc	ra,0xffffe
    800058c2:	186080e7          	jalr	390(ra) # 80003a44 <iupdate>
  iunlockput(ip);
    800058c6:	8526                	mv	a0,s1
    800058c8:	ffffe097          	auipc	ra,0xffffe
    800058cc:	4aa080e7          	jalr	1194(ra) # 80003d72 <iunlockput>
  end_op();
    800058d0:	fffff097          	auipc	ra,0xfffff
    800058d4:	c8a080e7          	jalr	-886(ra) # 8000455a <end_op>
  return -1;
    800058d8:	57fd                	li	a5,-1
}
    800058da:	853e                	mv	a0,a5
    800058dc:	70b2                	ld	ra,296(sp)
    800058de:	7412                	ld	s0,288(sp)
    800058e0:	64f2                	ld	s1,280(sp)
    800058e2:	6952                	ld	s2,272(sp)
    800058e4:	6155                	addi	sp,sp,304
    800058e6:	8082                	ret

00000000800058e8 <sys_unlink>:
{
    800058e8:	7151                	addi	sp,sp,-240
    800058ea:	f586                	sd	ra,232(sp)
    800058ec:	f1a2                	sd	s0,224(sp)
    800058ee:	eda6                	sd	s1,216(sp)
    800058f0:	e9ca                	sd	s2,208(sp)
    800058f2:	e5ce                	sd	s3,200(sp)
    800058f4:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800058f6:	08000613          	li	a2,128
    800058fa:	f3040593          	addi	a1,s0,-208
    800058fe:	4501                	li	a0,0
    80005900:	ffffd097          	auipc	ra,0xffffd
    80005904:	66a080e7          	jalr	1642(ra) # 80002f6a <argstr>
    80005908:	18054163          	bltz	a0,80005a8a <sys_unlink+0x1a2>
  begin_op();
    8000590c:	fffff097          	auipc	ra,0xfffff
    80005910:	bd0080e7          	jalr	-1072(ra) # 800044dc <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005914:	fb040593          	addi	a1,s0,-80
    80005918:	f3040513          	addi	a0,s0,-208
    8000591c:	fffff097          	auipc	ra,0xfffff
    80005920:	9be080e7          	jalr	-1602(ra) # 800042da <nameiparent>
    80005924:	84aa                	mv	s1,a0
    80005926:	c979                	beqz	a0,800059fc <sys_unlink+0x114>
  ilock(dp);
    80005928:	ffffe097          	auipc	ra,0xffffe
    8000592c:	1e8080e7          	jalr	488(ra) # 80003b10 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005930:	00003597          	auipc	a1,0x3
    80005934:	ee858593          	addi	a1,a1,-280 # 80008818 <syscalls+0x308>
    80005938:	fb040513          	addi	a0,s0,-80
    8000593c:	ffffe097          	auipc	ra,0xffffe
    80005940:	69e080e7          	jalr	1694(ra) # 80003fda <namecmp>
    80005944:	14050a63          	beqz	a0,80005a98 <sys_unlink+0x1b0>
    80005948:	00003597          	auipc	a1,0x3
    8000594c:	ed858593          	addi	a1,a1,-296 # 80008820 <syscalls+0x310>
    80005950:	fb040513          	addi	a0,s0,-80
    80005954:	ffffe097          	auipc	ra,0xffffe
    80005958:	686080e7          	jalr	1670(ra) # 80003fda <namecmp>
    8000595c:	12050e63          	beqz	a0,80005a98 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005960:	f2c40613          	addi	a2,s0,-212
    80005964:	fb040593          	addi	a1,s0,-80
    80005968:	8526                	mv	a0,s1
    8000596a:	ffffe097          	auipc	ra,0xffffe
    8000596e:	68a080e7          	jalr	1674(ra) # 80003ff4 <dirlookup>
    80005972:	892a                	mv	s2,a0
    80005974:	12050263          	beqz	a0,80005a98 <sys_unlink+0x1b0>
  ilock(ip);
    80005978:	ffffe097          	auipc	ra,0xffffe
    8000597c:	198080e7          	jalr	408(ra) # 80003b10 <ilock>
  if(ip->nlink < 1)
    80005980:	04a91783          	lh	a5,74(s2)
    80005984:	08f05263          	blez	a5,80005a08 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005988:	04491703          	lh	a4,68(s2)
    8000598c:	4785                	li	a5,1
    8000598e:	08f70563          	beq	a4,a5,80005a18 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005992:	4641                	li	a2,16
    80005994:	4581                	li	a1,0
    80005996:	fc040513          	addi	a0,s0,-64
    8000599a:	ffffb097          	auipc	ra,0xffffb
    8000599e:	338080e7          	jalr	824(ra) # 80000cd2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800059a2:	4741                	li	a4,16
    800059a4:	f2c42683          	lw	a3,-212(s0)
    800059a8:	fc040613          	addi	a2,s0,-64
    800059ac:	4581                	li	a1,0
    800059ae:	8526                	mv	a0,s1
    800059b0:	ffffe097          	auipc	ra,0xffffe
    800059b4:	50c080e7          	jalr	1292(ra) # 80003ebc <writei>
    800059b8:	47c1                	li	a5,16
    800059ba:	0af51563          	bne	a0,a5,80005a64 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800059be:	04491703          	lh	a4,68(s2)
    800059c2:	4785                	li	a5,1
    800059c4:	0af70863          	beq	a4,a5,80005a74 <sys_unlink+0x18c>
  iunlockput(dp);
    800059c8:	8526                	mv	a0,s1
    800059ca:	ffffe097          	auipc	ra,0xffffe
    800059ce:	3a8080e7          	jalr	936(ra) # 80003d72 <iunlockput>
  ip->nlink--;
    800059d2:	04a95783          	lhu	a5,74(s2)
    800059d6:	37fd                	addiw	a5,a5,-1
    800059d8:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800059dc:	854a                	mv	a0,s2
    800059de:	ffffe097          	auipc	ra,0xffffe
    800059e2:	066080e7          	jalr	102(ra) # 80003a44 <iupdate>
  iunlockput(ip);
    800059e6:	854a                	mv	a0,s2
    800059e8:	ffffe097          	auipc	ra,0xffffe
    800059ec:	38a080e7          	jalr	906(ra) # 80003d72 <iunlockput>
  end_op();
    800059f0:	fffff097          	auipc	ra,0xfffff
    800059f4:	b6a080e7          	jalr	-1174(ra) # 8000455a <end_op>
  return 0;
    800059f8:	4501                	li	a0,0
    800059fa:	a84d                	j	80005aac <sys_unlink+0x1c4>
    end_op();
    800059fc:	fffff097          	auipc	ra,0xfffff
    80005a00:	b5e080e7          	jalr	-1186(ra) # 8000455a <end_op>
    return -1;
    80005a04:	557d                	li	a0,-1
    80005a06:	a05d                	j	80005aac <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005a08:	00003517          	auipc	a0,0x3
    80005a0c:	e2050513          	addi	a0,a0,-480 # 80008828 <syscalls+0x318>
    80005a10:	ffffb097          	auipc	ra,0xffffb
    80005a14:	b30080e7          	jalr	-1232(ra) # 80000540 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005a18:	04c92703          	lw	a4,76(s2)
    80005a1c:	02000793          	li	a5,32
    80005a20:	f6e7f9e3          	bgeu	a5,a4,80005992 <sys_unlink+0xaa>
    80005a24:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005a28:	4741                	li	a4,16
    80005a2a:	86ce                	mv	a3,s3
    80005a2c:	f1840613          	addi	a2,s0,-232
    80005a30:	4581                	li	a1,0
    80005a32:	854a                	mv	a0,s2
    80005a34:	ffffe097          	auipc	ra,0xffffe
    80005a38:	390080e7          	jalr	912(ra) # 80003dc4 <readi>
    80005a3c:	47c1                	li	a5,16
    80005a3e:	00f51b63          	bne	a0,a5,80005a54 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005a42:	f1845783          	lhu	a5,-232(s0)
    80005a46:	e7a1                	bnez	a5,80005a8e <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005a48:	29c1                	addiw	s3,s3,16
    80005a4a:	04c92783          	lw	a5,76(s2)
    80005a4e:	fcf9ede3          	bltu	s3,a5,80005a28 <sys_unlink+0x140>
    80005a52:	b781                	j	80005992 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005a54:	00003517          	auipc	a0,0x3
    80005a58:	dec50513          	addi	a0,a0,-532 # 80008840 <syscalls+0x330>
    80005a5c:	ffffb097          	auipc	ra,0xffffb
    80005a60:	ae4080e7          	jalr	-1308(ra) # 80000540 <panic>
    panic("unlink: writei");
    80005a64:	00003517          	auipc	a0,0x3
    80005a68:	df450513          	addi	a0,a0,-524 # 80008858 <syscalls+0x348>
    80005a6c:	ffffb097          	auipc	ra,0xffffb
    80005a70:	ad4080e7          	jalr	-1324(ra) # 80000540 <panic>
    dp->nlink--;
    80005a74:	04a4d783          	lhu	a5,74(s1)
    80005a78:	37fd                	addiw	a5,a5,-1
    80005a7a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005a7e:	8526                	mv	a0,s1
    80005a80:	ffffe097          	auipc	ra,0xffffe
    80005a84:	fc4080e7          	jalr	-60(ra) # 80003a44 <iupdate>
    80005a88:	b781                	j	800059c8 <sys_unlink+0xe0>
    return -1;
    80005a8a:	557d                	li	a0,-1
    80005a8c:	a005                	j	80005aac <sys_unlink+0x1c4>
    iunlockput(ip);
    80005a8e:	854a                	mv	a0,s2
    80005a90:	ffffe097          	auipc	ra,0xffffe
    80005a94:	2e2080e7          	jalr	738(ra) # 80003d72 <iunlockput>
  iunlockput(dp);
    80005a98:	8526                	mv	a0,s1
    80005a9a:	ffffe097          	auipc	ra,0xffffe
    80005a9e:	2d8080e7          	jalr	728(ra) # 80003d72 <iunlockput>
  end_op();
    80005aa2:	fffff097          	auipc	ra,0xfffff
    80005aa6:	ab8080e7          	jalr	-1352(ra) # 8000455a <end_op>
  return -1;
    80005aaa:	557d                	li	a0,-1
}
    80005aac:	70ae                	ld	ra,232(sp)
    80005aae:	740e                	ld	s0,224(sp)
    80005ab0:	64ee                	ld	s1,216(sp)
    80005ab2:	694e                	ld	s2,208(sp)
    80005ab4:	69ae                	ld	s3,200(sp)
    80005ab6:	616d                	addi	sp,sp,240
    80005ab8:	8082                	ret

0000000080005aba <sys_open>:

uint64
sys_open(void)
{
    80005aba:	7131                	addi	sp,sp,-192
    80005abc:	fd06                	sd	ra,184(sp)
    80005abe:	f922                	sd	s0,176(sp)
    80005ac0:	f526                	sd	s1,168(sp)
    80005ac2:	f14a                	sd	s2,160(sp)
    80005ac4:	ed4e                	sd	s3,152(sp)
    80005ac6:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005ac8:	f4c40593          	addi	a1,s0,-180
    80005acc:	4505                	li	a0,1
    80005ace:	ffffd097          	auipc	ra,0xffffd
    80005ad2:	45c080e7          	jalr	1116(ra) # 80002f2a <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005ad6:	08000613          	li	a2,128
    80005ada:	f5040593          	addi	a1,s0,-176
    80005ade:	4501                	li	a0,0
    80005ae0:	ffffd097          	auipc	ra,0xffffd
    80005ae4:	48a080e7          	jalr	1162(ra) # 80002f6a <argstr>
    80005ae8:	87aa                	mv	a5,a0
    return -1;
    80005aea:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005aec:	0a07c963          	bltz	a5,80005b9e <sys_open+0xe4>

  begin_op();
    80005af0:	fffff097          	auipc	ra,0xfffff
    80005af4:	9ec080e7          	jalr	-1556(ra) # 800044dc <begin_op>

  if(omode & O_CREATE){
    80005af8:	f4c42783          	lw	a5,-180(s0)
    80005afc:	2007f793          	andi	a5,a5,512
    80005b00:	cfc5                	beqz	a5,80005bb8 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005b02:	4681                	li	a3,0
    80005b04:	4601                	li	a2,0
    80005b06:	4589                	li	a1,2
    80005b08:	f5040513          	addi	a0,s0,-176
    80005b0c:	00000097          	auipc	ra,0x0
    80005b10:	972080e7          	jalr	-1678(ra) # 8000547e <create>
    80005b14:	84aa                	mv	s1,a0
    if(ip == 0){
    80005b16:	c959                	beqz	a0,80005bac <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005b18:	04449703          	lh	a4,68(s1)
    80005b1c:	478d                	li	a5,3
    80005b1e:	00f71763          	bne	a4,a5,80005b2c <sys_open+0x72>
    80005b22:	0464d703          	lhu	a4,70(s1)
    80005b26:	47a5                	li	a5,9
    80005b28:	0ce7ed63          	bltu	a5,a4,80005c02 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005b2c:	fffff097          	auipc	ra,0xfffff
    80005b30:	dbc080e7          	jalr	-580(ra) # 800048e8 <filealloc>
    80005b34:	89aa                	mv	s3,a0
    80005b36:	10050363          	beqz	a0,80005c3c <sys_open+0x182>
    80005b3a:	00000097          	auipc	ra,0x0
    80005b3e:	902080e7          	jalr	-1790(ra) # 8000543c <fdalloc>
    80005b42:	892a                	mv	s2,a0
    80005b44:	0e054763          	bltz	a0,80005c32 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005b48:	04449703          	lh	a4,68(s1)
    80005b4c:	478d                	li	a5,3
    80005b4e:	0cf70563          	beq	a4,a5,80005c18 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005b52:	4789                	li	a5,2
    80005b54:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005b58:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005b5c:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005b60:	f4c42783          	lw	a5,-180(s0)
    80005b64:	0017c713          	xori	a4,a5,1
    80005b68:	8b05                	andi	a4,a4,1
    80005b6a:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005b6e:	0037f713          	andi	a4,a5,3
    80005b72:	00e03733          	snez	a4,a4
    80005b76:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005b7a:	4007f793          	andi	a5,a5,1024
    80005b7e:	c791                	beqz	a5,80005b8a <sys_open+0xd0>
    80005b80:	04449703          	lh	a4,68(s1)
    80005b84:	4789                	li	a5,2
    80005b86:	0af70063          	beq	a4,a5,80005c26 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005b8a:	8526                	mv	a0,s1
    80005b8c:	ffffe097          	auipc	ra,0xffffe
    80005b90:	046080e7          	jalr	70(ra) # 80003bd2 <iunlock>
  end_op();
    80005b94:	fffff097          	auipc	ra,0xfffff
    80005b98:	9c6080e7          	jalr	-1594(ra) # 8000455a <end_op>

  return fd;
    80005b9c:	854a                	mv	a0,s2
}
    80005b9e:	70ea                	ld	ra,184(sp)
    80005ba0:	744a                	ld	s0,176(sp)
    80005ba2:	74aa                	ld	s1,168(sp)
    80005ba4:	790a                	ld	s2,160(sp)
    80005ba6:	69ea                	ld	s3,152(sp)
    80005ba8:	6129                	addi	sp,sp,192
    80005baa:	8082                	ret
      end_op();
    80005bac:	fffff097          	auipc	ra,0xfffff
    80005bb0:	9ae080e7          	jalr	-1618(ra) # 8000455a <end_op>
      return -1;
    80005bb4:	557d                	li	a0,-1
    80005bb6:	b7e5                	j	80005b9e <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005bb8:	f5040513          	addi	a0,s0,-176
    80005bbc:	ffffe097          	auipc	ra,0xffffe
    80005bc0:	700080e7          	jalr	1792(ra) # 800042bc <namei>
    80005bc4:	84aa                	mv	s1,a0
    80005bc6:	c905                	beqz	a0,80005bf6 <sys_open+0x13c>
    ilock(ip);
    80005bc8:	ffffe097          	auipc	ra,0xffffe
    80005bcc:	f48080e7          	jalr	-184(ra) # 80003b10 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005bd0:	04449703          	lh	a4,68(s1)
    80005bd4:	4785                	li	a5,1
    80005bd6:	f4f711e3          	bne	a4,a5,80005b18 <sys_open+0x5e>
    80005bda:	f4c42783          	lw	a5,-180(s0)
    80005bde:	d7b9                	beqz	a5,80005b2c <sys_open+0x72>
      iunlockput(ip);
    80005be0:	8526                	mv	a0,s1
    80005be2:	ffffe097          	auipc	ra,0xffffe
    80005be6:	190080e7          	jalr	400(ra) # 80003d72 <iunlockput>
      end_op();
    80005bea:	fffff097          	auipc	ra,0xfffff
    80005bee:	970080e7          	jalr	-1680(ra) # 8000455a <end_op>
      return -1;
    80005bf2:	557d                	li	a0,-1
    80005bf4:	b76d                	j	80005b9e <sys_open+0xe4>
      end_op();
    80005bf6:	fffff097          	auipc	ra,0xfffff
    80005bfa:	964080e7          	jalr	-1692(ra) # 8000455a <end_op>
      return -1;
    80005bfe:	557d                	li	a0,-1
    80005c00:	bf79                	j	80005b9e <sys_open+0xe4>
    iunlockput(ip);
    80005c02:	8526                	mv	a0,s1
    80005c04:	ffffe097          	auipc	ra,0xffffe
    80005c08:	16e080e7          	jalr	366(ra) # 80003d72 <iunlockput>
    end_op();
    80005c0c:	fffff097          	auipc	ra,0xfffff
    80005c10:	94e080e7          	jalr	-1714(ra) # 8000455a <end_op>
    return -1;
    80005c14:	557d                	li	a0,-1
    80005c16:	b761                	j	80005b9e <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005c18:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005c1c:	04649783          	lh	a5,70(s1)
    80005c20:	02f99223          	sh	a5,36(s3)
    80005c24:	bf25                	j	80005b5c <sys_open+0xa2>
    itrunc(ip);
    80005c26:	8526                	mv	a0,s1
    80005c28:	ffffe097          	auipc	ra,0xffffe
    80005c2c:	ff6080e7          	jalr	-10(ra) # 80003c1e <itrunc>
    80005c30:	bfa9                	j	80005b8a <sys_open+0xd0>
      fileclose(f);
    80005c32:	854e                	mv	a0,s3
    80005c34:	fffff097          	auipc	ra,0xfffff
    80005c38:	d70080e7          	jalr	-656(ra) # 800049a4 <fileclose>
    iunlockput(ip);
    80005c3c:	8526                	mv	a0,s1
    80005c3e:	ffffe097          	auipc	ra,0xffffe
    80005c42:	134080e7          	jalr	308(ra) # 80003d72 <iunlockput>
    end_op();
    80005c46:	fffff097          	auipc	ra,0xfffff
    80005c4a:	914080e7          	jalr	-1772(ra) # 8000455a <end_op>
    return -1;
    80005c4e:	557d                	li	a0,-1
    80005c50:	b7b9                	j	80005b9e <sys_open+0xe4>

0000000080005c52 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005c52:	7175                	addi	sp,sp,-144
    80005c54:	e506                	sd	ra,136(sp)
    80005c56:	e122                	sd	s0,128(sp)
    80005c58:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005c5a:	fffff097          	auipc	ra,0xfffff
    80005c5e:	882080e7          	jalr	-1918(ra) # 800044dc <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005c62:	08000613          	li	a2,128
    80005c66:	f7040593          	addi	a1,s0,-144
    80005c6a:	4501                	li	a0,0
    80005c6c:	ffffd097          	auipc	ra,0xffffd
    80005c70:	2fe080e7          	jalr	766(ra) # 80002f6a <argstr>
    80005c74:	02054963          	bltz	a0,80005ca6 <sys_mkdir+0x54>
    80005c78:	4681                	li	a3,0
    80005c7a:	4601                	li	a2,0
    80005c7c:	4585                	li	a1,1
    80005c7e:	f7040513          	addi	a0,s0,-144
    80005c82:	fffff097          	auipc	ra,0xfffff
    80005c86:	7fc080e7          	jalr	2044(ra) # 8000547e <create>
    80005c8a:	cd11                	beqz	a0,80005ca6 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005c8c:	ffffe097          	auipc	ra,0xffffe
    80005c90:	0e6080e7          	jalr	230(ra) # 80003d72 <iunlockput>
  end_op();
    80005c94:	fffff097          	auipc	ra,0xfffff
    80005c98:	8c6080e7          	jalr	-1850(ra) # 8000455a <end_op>
  return 0;
    80005c9c:	4501                	li	a0,0
}
    80005c9e:	60aa                	ld	ra,136(sp)
    80005ca0:	640a                	ld	s0,128(sp)
    80005ca2:	6149                	addi	sp,sp,144
    80005ca4:	8082                	ret
    end_op();
    80005ca6:	fffff097          	auipc	ra,0xfffff
    80005caa:	8b4080e7          	jalr	-1868(ra) # 8000455a <end_op>
    return -1;
    80005cae:	557d                	li	a0,-1
    80005cb0:	b7fd                	j	80005c9e <sys_mkdir+0x4c>

0000000080005cb2 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005cb2:	7135                	addi	sp,sp,-160
    80005cb4:	ed06                	sd	ra,152(sp)
    80005cb6:	e922                	sd	s0,144(sp)
    80005cb8:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005cba:	fffff097          	auipc	ra,0xfffff
    80005cbe:	822080e7          	jalr	-2014(ra) # 800044dc <begin_op>
  argint(1, &major);
    80005cc2:	f6c40593          	addi	a1,s0,-148
    80005cc6:	4505                	li	a0,1
    80005cc8:	ffffd097          	auipc	ra,0xffffd
    80005ccc:	262080e7          	jalr	610(ra) # 80002f2a <argint>
  argint(2, &minor);
    80005cd0:	f6840593          	addi	a1,s0,-152
    80005cd4:	4509                	li	a0,2
    80005cd6:	ffffd097          	auipc	ra,0xffffd
    80005cda:	254080e7          	jalr	596(ra) # 80002f2a <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005cde:	08000613          	li	a2,128
    80005ce2:	f7040593          	addi	a1,s0,-144
    80005ce6:	4501                	li	a0,0
    80005ce8:	ffffd097          	auipc	ra,0xffffd
    80005cec:	282080e7          	jalr	642(ra) # 80002f6a <argstr>
    80005cf0:	02054b63          	bltz	a0,80005d26 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005cf4:	f6841683          	lh	a3,-152(s0)
    80005cf8:	f6c41603          	lh	a2,-148(s0)
    80005cfc:	458d                	li	a1,3
    80005cfe:	f7040513          	addi	a0,s0,-144
    80005d02:	fffff097          	auipc	ra,0xfffff
    80005d06:	77c080e7          	jalr	1916(ra) # 8000547e <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005d0a:	cd11                	beqz	a0,80005d26 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005d0c:	ffffe097          	auipc	ra,0xffffe
    80005d10:	066080e7          	jalr	102(ra) # 80003d72 <iunlockput>
  end_op();
    80005d14:	fffff097          	auipc	ra,0xfffff
    80005d18:	846080e7          	jalr	-1978(ra) # 8000455a <end_op>
  return 0;
    80005d1c:	4501                	li	a0,0
}
    80005d1e:	60ea                	ld	ra,152(sp)
    80005d20:	644a                	ld	s0,144(sp)
    80005d22:	610d                	addi	sp,sp,160
    80005d24:	8082                	ret
    end_op();
    80005d26:	fffff097          	auipc	ra,0xfffff
    80005d2a:	834080e7          	jalr	-1996(ra) # 8000455a <end_op>
    return -1;
    80005d2e:	557d                	li	a0,-1
    80005d30:	b7fd                	j	80005d1e <sys_mknod+0x6c>

0000000080005d32 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005d32:	7135                	addi	sp,sp,-160
    80005d34:	ed06                	sd	ra,152(sp)
    80005d36:	e922                	sd	s0,144(sp)
    80005d38:	e526                	sd	s1,136(sp)
    80005d3a:	e14a                	sd	s2,128(sp)
    80005d3c:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005d3e:	ffffc097          	auipc	ra,0xffffc
    80005d42:	eee080e7          	jalr	-274(ra) # 80001c2c <myproc>
    80005d46:	892a                	mv	s2,a0
  
  begin_op();
    80005d48:	ffffe097          	auipc	ra,0xffffe
    80005d4c:	794080e7          	jalr	1940(ra) # 800044dc <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005d50:	08000613          	li	a2,128
    80005d54:	f6040593          	addi	a1,s0,-160
    80005d58:	4501                	li	a0,0
    80005d5a:	ffffd097          	auipc	ra,0xffffd
    80005d5e:	210080e7          	jalr	528(ra) # 80002f6a <argstr>
    80005d62:	04054b63          	bltz	a0,80005db8 <sys_chdir+0x86>
    80005d66:	f6040513          	addi	a0,s0,-160
    80005d6a:	ffffe097          	auipc	ra,0xffffe
    80005d6e:	552080e7          	jalr	1362(ra) # 800042bc <namei>
    80005d72:	84aa                	mv	s1,a0
    80005d74:	c131                	beqz	a0,80005db8 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005d76:	ffffe097          	auipc	ra,0xffffe
    80005d7a:	d9a080e7          	jalr	-614(ra) # 80003b10 <ilock>
  if(ip->type != T_DIR){
    80005d7e:	04449703          	lh	a4,68(s1)
    80005d82:	4785                	li	a5,1
    80005d84:	04f71063          	bne	a4,a5,80005dc4 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005d88:	8526                	mv	a0,s1
    80005d8a:	ffffe097          	auipc	ra,0xffffe
    80005d8e:	e48080e7          	jalr	-440(ra) # 80003bd2 <iunlock>
  iput(p->cwd);
    80005d92:	15093503          	ld	a0,336(s2)
    80005d96:	ffffe097          	auipc	ra,0xffffe
    80005d9a:	f34080e7          	jalr	-204(ra) # 80003cca <iput>
  end_op();
    80005d9e:	ffffe097          	auipc	ra,0xffffe
    80005da2:	7bc080e7          	jalr	1980(ra) # 8000455a <end_op>
  p->cwd = ip;
    80005da6:	14993823          	sd	s1,336(s2)
  return 0;
    80005daa:	4501                	li	a0,0
}
    80005dac:	60ea                	ld	ra,152(sp)
    80005dae:	644a                	ld	s0,144(sp)
    80005db0:	64aa                	ld	s1,136(sp)
    80005db2:	690a                	ld	s2,128(sp)
    80005db4:	610d                	addi	sp,sp,160
    80005db6:	8082                	ret
    end_op();
    80005db8:	ffffe097          	auipc	ra,0xffffe
    80005dbc:	7a2080e7          	jalr	1954(ra) # 8000455a <end_op>
    return -1;
    80005dc0:	557d                	li	a0,-1
    80005dc2:	b7ed                	j	80005dac <sys_chdir+0x7a>
    iunlockput(ip);
    80005dc4:	8526                	mv	a0,s1
    80005dc6:	ffffe097          	auipc	ra,0xffffe
    80005dca:	fac080e7          	jalr	-84(ra) # 80003d72 <iunlockput>
    end_op();
    80005dce:	ffffe097          	auipc	ra,0xffffe
    80005dd2:	78c080e7          	jalr	1932(ra) # 8000455a <end_op>
    return -1;
    80005dd6:	557d                	li	a0,-1
    80005dd8:	bfd1                	j	80005dac <sys_chdir+0x7a>

0000000080005dda <sys_exec>:

uint64
sys_exec(void)
{
    80005dda:	7145                	addi	sp,sp,-464
    80005ddc:	e786                	sd	ra,456(sp)
    80005dde:	e3a2                	sd	s0,448(sp)
    80005de0:	ff26                	sd	s1,440(sp)
    80005de2:	fb4a                	sd	s2,432(sp)
    80005de4:	f74e                	sd	s3,424(sp)
    80005de6:	f352                	sd	s4,416(sp)
    80005de8:	ef56                	sd	s5,408(sp)
    80005dea:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005dec:	e3840593          	addi	a1,s0,-456
    80005df0:	4505                	li	a0,1
    80005df2:	ffffd097          	auipc	ra,0xffffd
    80005df6:	158080e7          	jalr	344(ra) # 80002f4a <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005dfa:	08000613          	li	a2,128
    80005dfe:	f4040593          	addi	a1,s0,-192
    80005e02:	4501                	li	a0,0
    80005e04:	ffffd097          	auipc	ra,0xffffd
    80005e08:	166080e7          	jalr	358(ra) # 80002f6a <argstr>
    80005e0c:	87aa                	mv	a5,a0
    return -1;
    80005e0e:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005e10:	0c07c363          	bltz	a5,80005ed6 <sys_exec+0xfc>
  }
  memset(argv, 0, sizeof(argv));
    80005e14:	10000613          	li	a2,256
    80005e18:	4581                	li	a1,0
    80005e1a:	e4040513          	addi	a0,s0,-448
    80005e1e:	ffffb097          	auipc	ra,0xffffb
    80005e22:	eb4080e7          	jalr	-332(ra) # 80000cd2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005e26:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005e2a:	89a6                	mv	s3,s1
    80005e2c:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005e2e:	02000a13          	li	s4,32
    80005e32:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005e36:	00391513          	slli	a0,s2,0x3
    80005e3a:	e3040593          	addi	a1,s0,-464
    80005e3e:	e3843783          	ld	a5,-456(s0)
    80005e42:	953e                	add	a0,a0,a5
    80005e44:	ffffd097          	auipc	ra,0xffffd
    80005e48:	048080e7          	jalr	72(ra) # 80002e8c <fetchaddr>
    80005e4c:	02054a63          	bltz	a0,80005e80 <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005e50:	e3043783          	ld	a5,-464(s0)
    80005e54:	c3b9                	beqz	a5,80005e9a <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005e56:	ffffb097          	auipc	ra,0xffffb
    80005e5a:	c90080e7          	jalr	-880(ra) # 80000ae6 <kalloc>
    80005e5e:	85aa                	mv	a1,a0
    80005e60:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005e64:	cd11                	beqz	a0,80005e80 <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005e66:	6605                	lui	a2,0x1
    80005e68:	e3043503          	ld	a0,-464(s0)
    80005e6c:	ffffd097          	auipc	ra,0xffffd
    80005e70:	072080e7          	jalr	114(ra) # 80002ede <fetchstr>
    80005e74:	00054663          	bltz	a0,80005e80 <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005e78:	0905                	addi	s2,s2,1
    80005e7a:	09a1                	addi	s3,s3,8
    80005e7c:	fb491be3          	bne	s2,s4,80005e32 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e80:	f4040913          	addi	s2,s0,-192
    80005e84:	6088                	ld	a0,0(s1)
    80005e86:	c539                	beqz	a0,80005ed4 <sys_exec+0xfa>
    kfree(argv[i]);
    80005e88:	ffffb097          	auipc	ra,0xffffb
    80005e8c:	b60080e7          	jalr	-1184(ra) # 800009e8 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e90:	04a1                	addi	s1,s1,8
    80005e92:	ff2499e3          	bne	s1,s2,80005e84 <sys_exec+0xaa>
  return -1;
    80005e96:	557d                	li	a0,-1
    80005e98:	a83d                	j	80005ed6 <sys_exec+0xfc>
      argv[i] = 0;
    80005e9a:	0a8e                	slli	s5,s5,0x3
    80005e9c:	fc0a8793          	addi	a5,s5,-64
    80005ea0:	00878ab3          	add	s5,a5,s0
    80005ea4:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005ea8:	e4040593          	addi	a1,s0,-448
    80005eac:	f4040513          	addi	a0,s0,-192
    80005eb0:	fffff097          	auipc	ra,0xfffff
    80005eb4:	16e080e7          	jalr	366(ra) # 8000501e <exec>
    80005eb8:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005eba:	f4040993          	addi	s3,s0,-192
    80005ebe:	6088                	ld	a0,0(s1)
    80005ec0:	c901                	beqz	a0,80005ed0 <sys_exec+0xf6>
    kfree(argv[i]);
    80005ec2:	ffffb097          	auipc	ra,0xffffb
    80005ec6:	b26080e7          	jalr	-1242(ra) # 800009e8 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005eca:	04a1                	addi	s1,s1,8
    80005ecc:	ff3499e3          	bne	s1,s3,80005ebe <sys_exec+0xe4>
  return ret;
    80005ed0:	854a                	mv	a0,s2
    80005ed2:	a011                	j	80005ed6 <sys_exec+0xfc>
  return -1;
    80005ed4:	557d                	li	a0,-1
}
    80005ed6:	60be                	ld	ra,456(sp)
    80005ed8:	641e                	ld	s0,448(sp)
    80005eda:	74fa                	ld	s1,440(sp)
    80005edc:	795a                	ld	s2,432(sp)
    80005ede:	79ba                	ld	s3,424(sp)
    80005ee0:	7a1a                	ld	s4,416(sp)
    80005ee2:	6afa                	ld	s5,408(sp)
    80005ee4:	6179                	addi	sp,sp,464
    80005ee6:	8082                	ret

0000000080005ee8 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005ee8:	7139                	addi	sp,sp,-64
    80005eea:	fc06                	sd	ra,56(sp)
    80005eec:	f822                	sd	s0,48(sp)
    80005eee:	f426                	sd	s1,40(sp)
    80005ef0:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005ef2:	ffffc097          	auipc	ra,0xffffc
    80005ef6:	d3a080e7          	jalr	-710(ra) # 80001c2c <myproc>
    80005efa:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005efc:	fd840593          	addi	a1,s0,-40
    80005f00:	4501                	li	a0,0
    80005f02:	ffffd097          	auipc	ra,0xffffd
    80005f06:	048080e7          	jalr	72(ra) # 80002f4a <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005f0a:	fc840593          	addi	a1,s0,-56
    80005f0e:	fd040513          	addi	a0,s0,-48
    80005f12:	fffff097          	auipc	ra,0xfffff
    80005f16:	dc2080e7          	jalr	-574(ra) # 80004cd4 <pipealloc>
    return -1;
    80005f1a:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005f1c:	0c054463          	bltz	a0,80005fe4 <sys_pipe+0xfc>
  fd0 = -1;
    80005f20:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005f24:	fd043503          	ld	a0,-48(s0)
    80005f28:	fffff097          	auipc	ra,0xfffff
    80005f2c:	514080e7          	jalr	1300(ra) # 8000543c <fdalloc>
    80005f30:	fca42223          	sw	a0,-60(s0)
    80005f34:	08054b63          	bltz	a0,80005fca <sys_pipe+0xe2>
    80005f38:	fc843503          	ld	a0,-56(s0)
    80005f3c:	fffff097          	auipc	ra,0xfffff
    80005f40:	500080e7          	jalr	1280(ra) # 8000543c <fdalloc>
    80005f44:	fca42023          	sw	a0,-64(s0)
    80005f48:	06054863          	bltz	a0,80005fb8 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005f4c:	4691                	li	a3,4
    80005f4e:	fc440613          	addi	a2,s0,-60
    80005f52:	fd843583          	ld	a1,-40(s0)
    80005f56:	68a8                	ld	a0,80(s1)
    80005f58:	ffffb097          	auipc	ra,0xffffb
    80005f5c:	714080e7          	jalr	1812(ra) # 8000166c <copyout>
    80005f60:	02054063          	bltz	a0,80005f80 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005f64:	4691                	li	a3,4
    80005f66:	fc040613          	addi	a2,s0,-64
    80005f6a:	fd843583          	ld	a1,-40(s0)
    80005f6e:	0591                	addi	a1,a1,4
    80005f70:	68a8                	ld	a0,80(s1)
    80005f72:	ffffb097          	auipc	ra,0xffffb
    80005f76:	6fa080e7          	jalr	1786(ra) # 8000166c <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005f7a:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005f7c:	06055463          	bgez	a0,80005fe4 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005f80:	fc442783          	lw	a5,-60(s0)
    80005f84:	07e9                	addi	a5,a5,26
    80005f86:	078e                	slli	a5,a5,0x3
    80005f88:	97a6                	add	a5,a5,s1
    80005f8a:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005f8e:	fc042783          	lw	a5,-64(s0)
    80005f92:	07e9                	addi	a5,a5,26
    80005f94:	078e                	slli	a5,a5,0x3
    80005f96:	94be                	add	s1,s1,a5
    80005f98:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005f9c:	fd043503          	ld	a0,-48(s0)
    80005fa0:	fffff097          	auipc	ra,0xfffff
    80005fa4:	a04080e7          	jalr	-1532(ra) # 800049a4 <fileclose>
    fileclose(wf);
    80005fa8:	fc843503          	ld	a0,-56(s0)
    80005fac:	fffff097          	auipc	ra,0xfffff
    80005fb0:	9f8080e7          	jalr	-1544(ra) # 800049a4 <fileclose>
    return -1;
    80005fb4:	57fd                	li	a5,-1
    80005fb6:	a03d                	j	80005fe4 <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005fb8:	fc442783          	lw	a5,-60(s0)
    80005fbc:	0007c763          	bltz	a5,80005fca <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005fc0:	07e9                	addi	a5,a5,26
    80005fc2:	078e                	slli	a5,a5,0x3
    80005fc4:	97a6                	add	a5,a5,s1
    80005fc6:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005fca:	fd043503          	ld	a0,-48(s0)
    80005fce:	fffff097          	auipc	ra,0xfffff
    80005fd2:	9d6080e7          	jalr	-1578(ra) # 800049a4 <fileclose>
    fileclose(wf);
    80005fd6:	fc843503          	ld	a0,-56(s0)
    80005fda:	fffff097          	auipc	ra,0xfffff
    80005fde:	9ca080e7          	jalr	-1590(ra) # 800049a4 <fileclose>
    return -1;
    80005fe2:	57fd                	li	a5,-1
}
    80005fe4:	853e                	mv	a0,a5
    80005fe6:	70e2                	ld	ra,56(sp)
    80005fe8:	7442                	ld	s0,48(sp)
    80005fea:	74a2                	ld	s1,40(sp)
    80005fec:	6121                	addi	sp,sp,64
    80005fee:	8082                	ret

0000000080005ff0 <kernelvec>:
    80005ff0:	7111                	addi	sp,sp,-256
    80005ff2:	e006                	sd	ra,0(sp)
    80005ff4:	e40a                	sd	sp,8(sp)
    80005ff6:	e80e                	sd	gp,16(sp)
    80005ff8:	ec12                	sd	tp,24(sp)
    80005ffa:	f016                	sd	t0,32(sp)
    80005ffc:	f41a                	sd	t1,40(sp)
    80005ffe:	f81e                	sd	t2,48(sp)
    80006000:	fc22                	sd	s0,56(sp)
    80006002:	e0a6                	sd	s1,64(sp)
    80006004:	e4aa                	sd	a0,72(sp)
    80006006:	e8ae                	sd	a1,80(sp)
    80006008:	ecb2                	sd	a2,88(sp)
    8000600a:	f0b6                	sd	a3,96(sp)
    8000600c:	f4ba                	sd	a4,104(sp)
    8000600e:	f8be                	sd	a5,112(sp)
    80006010:	fcc2                	sd	a6,120(sp)
    80006012:	e146                	sd	a7,128(sp)
    80006014:	e54a                	sd	s2,136(sp)
    80006016:	e94e                	sd	s3,144(sp)
    80006018:	ed52                	sd	s4,152(sp)
    8000601a:	f156                	sd	s5,160(sp)
    8000601c:	f55a                	sd	s6,168(sp)
    8000601e:	f95e                	sd	s7,176(sp)
    80006020:	fd62                	sd	s8,184(sp)
    80006022:	e1e6                	sd	s9,192(sp)
    80006024:	e5ea                	sd	s10,200(sp)
    80006026:	e9ee                	sd	s11,208(sp)
    80006028:	edf2                	sd	t3,216(sp)
    8000602a:	f1f6                	sd	t4,224(sp)
    8000602c:	f5fa                	sd	t5,232(sp)
    8000602e:	f9fe                	sd	t6,240(sp)
    80006030:	d29fc0ef          	jal	ra,80002d58 <kerneltrap>
    80006034:	6082                	ld	ra,0(sp)
    80006036:	6122                	ld	sp,8(sp)
    80006038:	61c2                	ld	gp,16(sp)
    8000603a:	7282                	ld	t0,32(sp)
    8000603c:	7322                	ld	t1,40(sp)
    8000603e:	73c2                	ld	t2,48(sp)
    80006040:	7462                	ld	s0,56(sp)
    80006042:	6486                	ld	s1,64(sp)
    80006044:	6526                	ld	a0,72(sp)
    80006046:	65c6                	ld	a1,80(sp)
    80006048:	6666                	ld	a2,88(sp)
    8000604a:	7686                	ld	a3,96(sp)
    8000604c:	7726                	ld	a4,104(sp)
    8000604e:	77c6                	ld	a5,112(sp)
    80006050:	7866                	ld	a6,120(sp)
    80006052:	688a                	ld	a7,128(sp)
    80006054:	692a                	ld	s2,136(sp)
    80006056:	69ca                	ld	s3,144(sp)
    80006058:	6a6a                	ld	s4,152(sp)
    8000605a:	7a8a                	ld	s5,160(sp)
    8000605c:	7b2a                	ld	s6,168(sp)
    8000605e:	7bca                	ld	s7,176(sp)
    80006060:	7c6a                	ld	s8,184(sp)
    80006062:	6c8e                	ld	s9,192(sp)
    80006064:	6d2e                	ld	s10,200(sp)
    80006066:	6dce                	ld	s11,208(sp)
    80006068:	6e6e                	ld	t3,216(sp)
    8000606a:	7e8e                	ld	t4,224(sp)
    8000606c:	7f2e                	ld	t5,232(sp)
    8000606e:	7fce                	ld	t6,240(sp)
    80006070:	6111                	addi	sp,sp,256
    80006072:	10200073          	sret
    80006076:	00000013          	nop
    8000607a:	00000013          	nop
    8000607e:	0001                	nop

0000000080006080 <timervec>:
    80006080:	34051573          	csrrw	a0,mscratch,a0
    80006084:	e10c                	sd	a1,0(a0)
    80006086:	e510                	sd	a2,8(a0)
    80006088:	e914                	sd	a3,16(a0)
    8000608a:	6d0c                	ld	a1,24(a0)
    8000608c:	7110                	ld	a2,32(a0)
    8000608e:	6194                	ld	a3,0(a1)
    80006090:	96b2                	add	a3,a3,a2
    80006092:	e194                	sd	a3,0(a1)
    80006094:	4589                	li	a1,2
    80006096:	14459073          	csrw	sip,a1
    8000609a:	6914                	ld	a3,16(a0)
    8000609c:	6510                	ld	a2,8(a0)
    8000609e:	610c                	ld	a1,0(a0)
    800060a0:	34051573          	csrrw	a0,mscratch,a0
    800060a4:	30200073          	mret
	...

00000000800060aa <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800060aa:	1141                	addi	sp,sp,-16
    800060ac:	e422                	sd	s0,8(sp)
    800060ae:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800060b0:	0c0007b7          	lui	a5,0xc000
    800060b4:	4705                	li	a4,1
    800060b6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800060b8:	c3d8                	sw	a4,4(a5)
}
    800060ba:	6422                	ld	s0,8(sp)
    800060bc:	0141                	addi	sp,sp,16
    800060be:	8082                	ret

00000000800060c0 <plicinithart>:

void
plicinithart(void)
{
    800060c0:	1141                	addi	sp,sp,-16
    800060c2:	e406                	sd	ra,8(sp)
    800060c4:	e022                	sd	s0,0(sp)
    800060c6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800060c8:	ffffc097          	auipc	ra,0xffffc
    800060cc:	b38080e7          	jalr	-1224(ra) # 80001c00 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800060d0:	0085171b          	slliw	a4,a0,0x8
    800060d4:	0c0027b7          	lui	a5,0xc002
    800060d8:	97ba                	add	a5,a5,a4
    800060da:	40200713          	li	a4,1026
    800060de:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800060e2:	00d5151b          	slliw	a0,a0,0xd
    800060e6:	0c2017b7          	lui	a5,0xc201
    800060ea:	97aa                	add	a5,a5,a0
    800060ec:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800060f0:	60a2                	ld	ra,8(sp)
    800060f2:	6402                	ld	s0,0(sp)
    800060f4:	0141                	addi	sp,sp,16
    800060f6:	8082                	ret

00000000800060f8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800060f8:	1141                	addi	sp,sp,-16
    800060fa:	e406                	sd	ra,8(sp)
    800060fc:	e022                	sd	s0,0(sp)
    800060fe:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006100:	ffffc097          	auipc	ra,0xffffc
    80006104:	b00080e7          	jalr	-1280(ra) # 80001c00 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006108:	00d5151b          	slliw	a0,a0,0xd
    8000610c:	0c2017b7          	lui	a5,0xc201
    80006110:	97aa                	add	a5,a5,a0
  return irq;
}
    80006112:	43c8                	lw	a0,4(a5)
    80006114:	60a2                	ld	ra,8(sp)
    80006116:	6402                	ld	s0,0(sp)
    80006118:	0141                	addi	sp,sp,16
    8000611a:	8082                	ret

000000008000611c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000611c:	1101                	addi	sp,sp,-32
    8000611e:	ec06                	sd	ra,24(sp)
    80006120:	e822                	sd	s0,16(sp)
    80006122:	e426                	sd	s1,8(sp)
    80006124:	1000                	addi	s0,sp,32
    80006126:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006128:	ffffc097          	auipc	ra,0xffffc
    8000612c:	ad8080e7          	jalr	-1320(ra) # 80001c00 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006130:	00d5151b          	slliw	a0,a0,0xd
    80006134:	0c2017b7          	lui	a5,0xc201
    80006138:	97aa                	add	a5,a5,a0
    8000613a:	c3c4                	sw	s1,4(a5)
}
    8000613c:	60e2                	ld	ra,24(sp)
    8000613e:	6442                	ld	s0,16(sp)
    80006140:	64a2                	ld	s1,8(sp)
    80006142:	6105                	addi	sp,sp,32
    80006144:	8082                	ret

0000000080006146 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006146:	1141                	addi	sp,sp,-16
    80006148:	e406                	sd	ra,8(sp)
    8000614a:	e022                	sd	s0,0(sp)
    8000614c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000614e:	479d                	li	a5,7
    80006150:	04a7cc63          	blt	a5,a0,800061a8 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80006154:	0001d797          	auipc	a5,0x1d
    80006158:	83478793          	addi	a5,a5,-1996 # 80022988 <disk>
    8000615c:	97aa                	add	a5,a5,a0
    8000615e:	0187c783          	lbu	a5,24(a5)
    80006162:	ebb9                	bnez	a5,800061b8 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006164:	00451693          	slli	a3,a0,0x4
    80006168:	0001d797          	auipc	a5,0x1d
    8000616c:	82078793          	addi	a5,a5,-2016 # 80022988 <disk>
    80006170:	6398                	ld	a4,0(a5)
    80006172:	9736                	add	a4,a4,a3
    80006174:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80006178:	6398                	ld	a4,0(a5)
    8000617a:	9736                	add	a4,a4,a3
    8000617c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006180:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006184:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80006188:	97aa                	add	a5,a5,a0
    8000618a:	4705                	li	a4,1
    8000618c:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80006190:	0001d517          	auipc	a0,0x1d
    80006194:	81050513          	addi	a0,a0,-2032 # 800229a0 <disk+0x18>
    80006198:	ffffc097          	auipc	ra,0xffffc
    8000619c:	2e4080e7          	jalr	740(ra) # 8000247c <wakeup>
}
    800061a0:	60a2                	ld	ra,8(sp)
    800061a2:	6402                	ld	s0,0(sp)
    800061a4:	0141                	addi	sp,sp,16
    800061a6:	8082                	ret
    panic("free_desc 1");
    800061a8:	00002517          	auipc	a0,0x2
    800061ac:	6c050513          	addi	a0,a0,1728 # 80008868 <syscalls+0x358>
    800061b0:	ffffa097          	auipc	ra,0xffffa
    800061b4:	390080e7          	jalr	912(ra) # 80000540 <panic>
    panic("free_desc 2");
    800061b8:	00002517          	auipc	a0,0x2
    800061bc:	6c050513          	addi	a0,a0,1728 # 80008878 <syscalls+0x368>
    800061c0:	ffffa097          	auipc	ra,0xffffa
    800061c4:	380080e7          	jalr	896(ra) # 80000540 <panic>

00000000800061c8 <virtio_disk_init>:
{
    800061c8:	1101                	addi	sp,sp,-32
    800061ca:	ec06                	sd	ra,24(sp)
    800061cc:	e822                	sd	s0,16(sp)
    800061ce:	e426                	sd	s1,8(sp)
    800061d0:	e04a                	sd	s2,0(sp)
    800061d2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800061d4:	00002597          	auipc	a1,0x2
    800061d8:	6b458593          	addi	a1,a1,1716 # 80008888 <syscalls+0x378>
    800061dc:	0001d517          	auipc	a0,0x1d
    800061e0:	8d450513          	addi	a0,a0,-1836 # 80022ab0 <disk+0x128>
    800061e4:	ffffb097          	auipc	ra,0xffffb
    800061e8:	962080e7          	jalr	-1694(ra) # 80000b46 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800061ec:	100017b7          	lui	a5,0x10001
    800061f0:	4398                	lw	a4,0(a5)
    800061f2:	2701                	sext.w	a4,a4
    800061f4:	747277b7          	lui	a5,0x74727
    800061f8:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800061fc:	14f71b63          	bne	a4,a5,80006352 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006200:	100017b7          	lui	a5,0x10001
    80006204:	43dc                	lw	a5,4(a5)
    80006206:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006208:	4709                	li	a4,2
    8000620a:	14e79463          	bne	a5,a4,80006352 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000620e:	100017b7          	lui	a5,0x10001
    80006212:	479c                	lw	a5,8(a5)
    80006214:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006216:	12e79e63          	bne	a5,a4,80006352 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000621a:	100017b7          	lui	a5,0x10001
    8000621e:	47d8                	lw	a4,12(a5)
    80006220:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006222:	554d47b7          	lui	a5,0x554d4
    80006226:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000622a:	12f71463          	bne	a4,a5,80006352 <virtio_disk_init+0x18a>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000622e:	100017b7          	lui	a5,0x10001
    80006232:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006236:	4705                	li	a4,1
    80006238:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000623a:	470d                	li	a4,3
    8000623c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000623e:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006240:	c7ffe6b7          	lui	a3,0xc7ffe
    80006244:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdbc97>
    80006248:	8f75                	and	a4,a4,a3
    8000624a:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000624c:	472d                	li	a4,11
    8000624e:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80006250:	5bbc                	lw	a5,112(a5)
    80006252:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006256:	8ba1                	andi	a5,a5,8
    80006258:	10078563          	beqz	a5,80006362 <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000625c:	100017b7          	lui	a5,0x10001
    80006260:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006264:	43fc                	lw	a5,68(a5)
    80006266:	2781                	sext.w	a5,a5
    80006268:	10079563          	bnez	a5,80006372 <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000626c:	100017b7          	lui	a5,0x10001
    80006270:	5bdc                	lw	a5,52(a5)
    80006272:	2781                	sext.w	a5,a5
  if(max == 0)
    80006274:	10078763          	beqz	a5,80006382 <virtio_disk_init+0x1ba>
  if(max < NUM)
    80006278:	471d                	li	a4,7
    8000627a:	10f77c63          	bgeu	a4,a5,80006392 <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    8000627e:	ffffb097          	auipc	ra,0xffffb
    80006282:	868080e7          	jalr	-1944(ra) # 80000ae6 <kalloc>
    80006286:	0001c497          	auipc	s1,0x1c
    8000628a:	70248493          	addi	s1,s1,1794 # 80022988 <disk>
    8000628e:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006290:	ffffb097          	auipc	ra,0xffffb
    80006294:	856080e7          	jalr	-1962(ra) # 80000ae6 <kalloc>
    80006298:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000629a:	ffffb097          	auipc	ra,0xffffb
    8000629e:	84c080e7          	jalr	-1972(ra) # 80000ae6 <kalloc>
    800062a2:	87aa                	mv	a5,a0
    800062a4:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800062a6:	6088                	ld	a0,0(s1)
    800062a8:	cd6d                	beqz	a0,800063a2 <virtio_disk_init+0x1da>
    800062aa:	0001c717          	auipc	a4,0x1c
    800062ae:	6e673703          	ld	a4,1766(a4) # 80022990 <disk+0x8>
    800062b2:	cb65                	beqz	a4,800063a2 <virtio_disk_init+0x1da>
    800062b4:	c7fd                	beqz	a5,800063a2 <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    800062b6:	6605                	lui	a2,0x1
    800062b8:	4581                	li	a1,0
    800062ba:	ffffb097          	auipc	ra,0xffffb
    800062be:	a18080e7          	jalr	-1512(ra) # 80000cd2 <memset>
  memset(disk.avail, 0, PGSIZE);
    800062c2:	0001c497          	auipc	s1,0x1c
    800062c6:	6c648493          	addi	s1,s1,1734 # 80022988 <disk>
    800062ca:	6605                	lui	a2,0x1
    800062cc:	4581                	li	a1,0
    800062ce:	6488                	ld	a0,8(s1)
    800062d0:	ffffb097          	auipc	ra,0xffffb
    800062d4:	a02080e7          	jalr	-1534(ra) # 80000cd2 <memset>
  memset(disk.used, 0, PGSIZE);
    800062d8:	6605                	lui	a2,0x1
    800062da:	4581                	li	a1,0
    800062dc:	6888                	ld	a0,16(s1)
    800062de:	ffffb097          	auipc	ra,0xffffb
    800062e2:	9f4080e7          	jalr	-1548(ra) # 80000cd2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800062e6:	100017b7          	lui	a5,0x10001
    800062ea:	4721                	li	a4,8
    800062ec:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800062ee:	4098                	lw	a4,0(s1)
    800062f0:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800062f4:	40d8                	lw	a4,4(s1)
    800062f6:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800062fa:	6498                	ld	a4,8(s1)
    800062fc:	0007069b          	sext.w	a3,a4
    80006300:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006304:	9701                	srai	a4,a4,0x20
    80006306:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000630a:	6898                	ld	a4,16(s1)
    8000630c:	0007069b          	sext.w	a3,a4
    80006310:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006314:	9701                	srai	a4,a4,0x20
    80006316:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000631a:	4705                	li	a4,1
    8000631c:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    8000631e:	00e48c23          	sb	a4,24(s1)
    80006322:	00e48ca3          	sb	a4,25(s1)
    80006326:	00e48d23          	sb	a4,26(s1)
    8000632a:	00e48da3          	sb	a4,27(s1)
    8000632e:	00e48e23          	sb	a4,28(s1)
    80006332:	00e48ea3          	sb	a4,29(s1)
    80006336:	00e48f23          	sb	a4,30(s1)
    8000633a:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    8000633e:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006342:	0727a823          	sw	s2,112(a5)
}
    80006346:	60e2                	ld	ra,24(sp)
    80006348:	6442                	ld	s0,16(sp)
    8000634a:	64a2                	ld	s1,8(sp)
    8000634c:	6902                	ld	s2,0(sp)
    8000634e:	6105                	addi	sp,sp,32
    80006350:	8082                	ret
    panic("could not find virtio disk");
    80006352:	00002517          	auipc	a0,0x2
    80006356:	54650513          	addi	a0,a0,1350 # 80008898 <syscalls+0x388>
    8000635a:	ffffa097          	auipc	ra,0xffffa
    8000635e:	1e6080e7          	jalr	486(ra) # 80000540 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006362:	00002517          	auipc	a0,0x2
    80006366:	55650513          	addi	a0,a0,1366 # 800088b8 <syscalls+0x3a8>
    8000636a:	ffffa097          	auipc	ra,0xffffa
    8000636e:	1d6080e7          	jalr	470(ra) # 80000540 <panic>
    panic("virtio disk should not be ready");
    80006372:	00002517          	auipc	a0,0x2
    80006376:	56650513          	addi	a0,a0,1382 # 800088d8 <syscalls+0x3c8>
    8000637a:	ffffa097          	auipc	ra,0xffffa
    8000637e:	1c6080e7          	jalr	454(ra) # 80000540 <panic>
    panic("virtio disk has no queue 0");
    80006382:	00002517          	auipc	a0,0x2
    80006386:	57650513          	addi	a0,a0,1398 # 800088f8 <syscalls+0x3e8>
    8000638a:	ffffa097          	auipc	ra,0xffffa
    8000638e:	1b6080e7          	jalr	438(ra) # 80000540 <panic>
    panic("virtio disk max queue too short");
    80006392:	00002517          	auipc	a0,0x2
    80006396:	58650513          	addi	a0,a0,1414 # 80008918 <syscalls+0x408>
    8000639a:	ffffa097          	auipc	ra,0xffffa
    8000639e:	1a6080e7          	jalr	422(ra) # 80000540 <panic>
    panic("virtio disk kalloc");
    800063a2:	00002517          	auipc	a0,0x2
    800063a6:	59650513          	addi	a0,a0,1430 # 80008938 <syscalls+0x428>
    800063aa:	ffffa097          	auipc	ra,0xffffa
    800063ae:	196080e7          	jalr	406(ra) # 80000540 <panic>

00000000800063b2 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800063b2:	7119                	addi	sp,sp,-128
    800063b4:	fc86                	sd	ra,120(sp)
    800063b6:	f8a2                	sd	s0,112(sp)
    800063b8:	f4a6                	sd	s1,104(sp)
    800063ba:	f0ca                	sd	s2,96(sp)
    800063bc:	ecce                	sd	s3,88(sp)
    800063be:	e8d2                	sd	s4,80(sp)
    800063c0:	e4d6                	sd	s5,72(sp)
    800063c2:	e0da                	sd	s6,64(sp)
    800063c4:	fc5e                	sd	s7,56(sp)
    800063c6:	f862                	sd	s8,48(sp)
    800063c8:	f466                	sd	s9,40(sp)
    800063ca:	f06a                	sd	s10,32(sp)
    800063cc:	ec6e                	sd	s11,24(sp)
    800063ce:	0100                	addi	s0,sp,128
    800063d0:	8aaa                	mv	s5,a0
    800063d2:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800063d4:	00c52d03          	lw	s10,12(a0)
    800063d8:	001d1d1b          	slliw	s10,s10,0x1
    800063dc:	1d02                	slli	s10,s10,0x20
    800063de:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    800063e2:	0001c517          	auipc	a0,0x1c
    800063e6:	6ce50513          	addi	a0,a0,1742 # 80022ab0 <disk+0x128>
    800063ea:	ffffa097          	auipc	ra,0xffffa
    800063ee:	7ec080e7          	jalr	2028(ra) # 80000bd6 <acquire>
  for(int i = 0; i < 3; i++){
    800063f2:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800063f4:	44a1                	li	s1,8
      disk.free[i] = 0;
    800063f6:	0001cb97          	auipc	s7,0x1c
    800063fa:	592b8b93          	addi	s7,s7,1426 # 80022988 <disk>
  for(int i = 0; i < 3; i++){
    800063fe:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006400:	0001cc97          	auipc	s9,0x1c
    80006404:	6b0c8c93          	addi	s9,s9,1712 # 80022ab0 <disk+0x128>
    80006408:	a08d                	j	8000646a <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    8000640a:	00fb8733          	add	a4,s7,a5
    8000640e:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006412:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006414:	0207c563          	bltz	a5,8000643e <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    80006418:	2905                	addiw	s2,s2,1
    8000641a:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    8000641c:	05690c63          	beq	s2,s6,80006474 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    80006420:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006422:	0001c717          	auipc	a4,0x1c
    80006426:	56670713          	addi	a4,a4,1382 # 80022988 <disk>
    8000642a:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000642c:	01874683          	lbu	a3,24(a4)
    80006430:	fee9                	bnez	a3,8000640a <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80006432:	2785                	addiw	a5,a5,1
    80006434:	0705                	addi	a4,a4,1
    80006436:	fe979be3          	bne	a5,s1,8000642c <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    8000643a:	57fd                	li	a5,-1
    8000643c:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    8000643e:	01205d63          	blez	s2,80006458 <virtio_disk_rw+0xa6>
    80006442:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006444:	000a2503          	lw	a0,0(s4)
    80006448:	00000097          	auipc	ra,0x0
    8000644c:	cfe080e7          	jalr	-770(ra) # 80006146 <free_desc>
      for(int j = 0; j < i; j++)
    80006450:	2d85                	addiw	s11,s11,1
    80006452:	0a11                	addi	s4,s4,4
    80006454:	ff2d98e3          	bne	s11,s2,80006444 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006458:	85e6                	mv	a1,s9
    8000645a:	0001c517          	auipc	a0,0x1c
    8000645e:	54650513          	addi	a0,a0,1350 # 800229a0 <disk+0x18>
    80006462:	ffffc097          	auipc	ra,0xffffc
    80006466:	fa4080e7          	jalr	-92(ra) # 80002406 <sleep>
  for(int i = 0; i < 3; i++){
    8000646a:	f8040a13          	addi	s4,s0,-128
{
    8000646e:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006470:	894e                	mv	s2,s3
    80006472:	b77d                	j	80006420 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006474:	f8042503          	lw	a0,-128(s0)
    80006478:	00a50713          	addi	a4,a0,10
    8000647c:	0712                	slli	a4,a4,0x4

  if(write)
    8000647e:	0001c797          	auipc	a5,0x1c
    80006482:	50a78793          	addi	a5,a5,1290 # 80022988 <disk>
    80006486:	00e786b3          	add	a3,a5,a4
    8000648a:	01803633          	snez	a2,s8
    8000648e:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006490:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    80006494:	01a6b823          	sd	s10,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006498:	f6070613          	addi	a2,a4,-160
    8000649c:	6394                	ld	a3,0(a5)
    8000649e:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800064a0:	00870593          	addi	a1,a4,8
    800064a4:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    800064a6:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800064a8:	0007b803          	ld	a6,0(a5)
    800064ac:	9642                	add	a2,a2,a6
    800064ae:	46c1                	li	a3,16
    800064b0:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800064b2:	4585                	li	a1,1
    800064b4:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    800064b8:	f8442683          	lw	a3,-124(s0)
    800064bc:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800064c0:	0692                	slli	a3,a3,0x4
    800064c2:	9836                	add	a6,a6,a3
    800064c4:	058a8613          	addi	a2,s5,88
    800064c8:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    800064cc:	0007b803          	ld	a6,0(a5)
    800064d0:	96c2                	add	a3,a3,a6
    800064d2:	40000613          	li	a2,1024
    800064d6:	c690                	sw	a2,8(a3)
  if(write)
    800064d8:	001c3613          	seqz	a2,s8
    800064dc:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800064e0:	00166613          	ori	a2,a2,1
    800064e4:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    800064e8:	f8842603          	lw	a2,-120(s0)
    800064ec:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800064f0:	00250693          	addi	a3,a0,2
    800064f4:	0692                	slli	a3,a3,0x4
    800064f6:	96be                	add	a3,a3,a5
    800064f8:	58fd                	li	a7,-1
    800064fa:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800064fe:	0612                	slli	a2,a2,0x4
    80006500:	9832                	add	a6,a6,a2
    80006502:	f9070713          	addi	a4,a4,-112
    80006506:	973e                	add	a4,a4,a5
    80006508:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    8000650c:	6398                	ld	a4,0(a5)
    8000650e:	9732                	add	a4,a4,a2
    80006510:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006512:	4609                	li	a2,2
    80006514:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    80006518:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000651c:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    80006520:	0156b423          	sd	s5,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006524:	6794                	ld	a3,8(a5)
    80006526:	0026d703          	lhu	a4,2(a3)
    8000652a:	8b1d                	andi	a4,a4,7
    8000652c:	0706                	slli	a4,a4,0x1
    8000652e:	96ba                	add	a3,a3,a4
    80006530:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006534:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006538:	6798                	ld	a4,8(a5)
    8000653a:	00275783          	lhu	a5,2(a4)
    8000653e:	2785                	addiw	a5,a5,1
    80006540:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006544:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006548:	100017b7          	lui	a5,0x10001
    8000654c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006550:	004aa783          	lw	a5,4(s5)
    sleep(b, &disk.vdisk_lock);
    80006554:	0001c917          	auipc	s2,0x1c
    80006558:	55c90913          	addi	s2,s2,1372 # 80022ab0 <disk+0x128>
  while(b->disk == 1) {
    8000655c:	4485                	li	s1,1
    8000655e:	00b79c63          	bne	a5,a1,80006576 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006562:	85ca                	mv	a1,s2
    80006564:	8556                	mv	a0,s5
    80006566:	ffffc097          	auipc	ra,0xffffc
    8000656a:	ea0080e7          	jalr	-352(ra) # 80002406 <sleep>
  while(b->disk == 1) {
    8000656e:	004aa783          	lw	a5,4(s5)
    80006572:	fe9788e3          	beq	a5,s1,80006562 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006576:	f8042903          	lw	s2,-128(s0)
    8000657a:	00290713          	addi	a4,s2,2
    8000657e:	0712                	slli	a4,a4,0x4
    80006580:	0001c797          	auipc	a5,0x1c
    80006584:	40878793          	addi	a5,a5,1032 # 80022988 <disk>
    80006588:	97ba                	add	a5,a5,a4
    8000658a:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000658e:	0001c997          	auipc	s3,0x1c
    80006592:	3fa98993          	addi	s3,s3,1018 # 80022988 <disk>
    80006596:	00491713          	slli	a4,s2,0x4
    8000659a:	0009b783          	ld	a5,0(s3)
    8000659e:	97ba                	add	a5,a5,a4
    800065a0:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800065a4:	854a                	mv	a0,s2
    800065a6:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800065aa:	00000097          	auipc	ra,0x0
    800065ae:	b9c080e7          	jalr	-1124(ra) # 80006146 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800065b2:	8885                	andi	s1,s1,1
    800065b4:	f0ed                	bnez	s1,80006596 <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800065b6:	0001c517          	auipc	a0,0x1c
    800065ba:	4fa50513          	addi	a0,a0,1274 # 80022ab0 <disk+0x128>
    800065be:	ffffa097          	auipc	ra,0xffffa
    800065c2:	6cc080e7          	jalr	1740(ra) # 80000c8a <release>
}
    800065c6:	70e6                	ld	ra,120(sp)
    800065c8:	7446                	ld	s0,112(sp)
    800065ca:	74a6                	ld	s1,104(sp)
    800065cc:	7906                	ld	s2,96(sp)
    800065ce:	69e6                	ld	s3,88(sp)
    800065d0:	6a46                	ld	s4,80(sp)
    800065d2:	6aa6                	ld	s5,72(sp)
    800065d4:	6b06                	ld	s6,64(sp)
    800065d6:	7be2                	ld	s7,56(sp)
    800065d8:	7c42                	ld	s8,48(sp)
    800065da:	7ca2                	ld	s9,40(sp)
    800065dc:	7d02                	ld	s10,32(sp)
    800065de:	6de2                	ld	s11,24(sp)
    800065e0:	6109                	addi	sp,sp,128
    800065e2:	8082                	ret

00000000800065e4 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800065e4:	1101                	addi	sp,sp,-32
    800065e6:	ec06                	sd	ra,24(sp)
    800065e8:	e822                	sd	s0,16(sp)
    800065ea:	e426                	sd	s1,8(sp)
    800065ec:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800065ee:	0001c497          	auipc	s1,0x1c
    800065f2:	39a48493          	addi	s1,s1,922 # 80022988 <disk>
    800065f6:	0001c517          	auipc	a0,0x1c
    800065fa:	4ba50513          	addi	a0,a0,1210 # 80022ab0 <disk+0x128>
    800065fe:	ffffa097          	auipc	ra,0xffffa
    80006602:	5d8080e7          	jalr	1496(ra) # 80000bd6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006606:	10001737          	lui	a4,0x10001
    8000660a:	533c                	lw	a5,96(a4)
    8000660c:	8b8d                	andi	a5,a5,3
    8000660e:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006610:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006614:	689c                	ld	a5,16(s1)
    80006616:	0204d703          	lhu	a4,32(s1)
    8000661a:	0027d783          	lhu	a5,2(a5)
    8000661e:	04f70863          	beq	a4,a5,8000666e <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006622:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006626:	6898                	ld	a4,16(s1)
    80006628:	0204d783          	lhu	a5,32(s1)
    8000662c:	8b9d                	andi	a5,a5,7
    8000662e:	078e                	slli	a5,a5,0x3
    80006630:	97ba                	add	a5,a5,a4
    80006632:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006634:	00278713          	addi	a4,a5,2
    80006638:	0712                	slli	a4,a4,0x4
    8000663a:	9726                	add	a4,a4,s1
    8000663c:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006640:	e721                	bnez	a4,80006688 <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006642:	0789                	addi	a5,a5,2
    80006644:	0792                	slli	a5,a5,0x4
    80006646:	97a6                	add	a5,a5,s1
    80006648:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000664a:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000664e:	ffffc097          	auipc	ra,0xffffc
    80006652:	e2e080e7          	jalr	-466(ra) # 8000247c <wakeup>

    disk.used_idx += 1;
    80006656:	0204d783          	lhu	a5,32(s1)
    8000665a:	2785                	addiw	a5,a5,1
    8000665c:	17c2                	slli	a5,a5,0x30
    8000665e:	93c1                	srli	a5,a5,0x30
    80006660:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006664:	6898                	ld	a4,16(s1)
    80006666:	00275703          	lhu	a4,2(a4)
    8000666a:	faf71ce3          	bne	a4,a5,80006622 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    8000666e:	0001c517          	auipc	a0,0x1c
    80006672:	44250513          	addi	a0,a0,1090 # 80022ab0 <disk+0x128>
    80006676:	ffffa097          	auipc	ra,0xffffa
    8000667a:	614080e7          	jalr	1556(ra) # 80000c8a <release>
}
    8000667e:	60e2                	ld	ra,24(sp)
    80006680:	6442                	ld	s0,16(sp)
    80006682:	64a2                	ld	s1,8(sp)
    80006684:	6105                	addi	sp,sp,32
    80006686:	8082                	ret
      panic("virtio_disk_intr status");
    80006688:	00002517          	auipc	a0,0x2
    8000668c:	2c850513          	addi	a0,a0,712 # 80008950 <syscalls+0x440>
    80006690:	ffffa097          	auipc	ra,0xffffa
    80006694:	eb0080e7          	jalr	-336(ra) # 80000540 <panic>
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

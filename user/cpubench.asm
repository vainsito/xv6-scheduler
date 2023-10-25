
user/_cpubench:     formato del fichero elf64-littleriscv


Desensamblado de la sección .text:

0000000000000000 <main>:
  }
}

int
main(int argc, char *argv[])
{
   0:	7119                	addi	sp,sp,-128
   2:	fc86                	sd	ra,120(sp)
   4:	f8a2                	sd	s0,112(sp)
   6:	f4a6                	sd	s1,104(sp)
   8:	f0ca                	sd	s2,96(sp)
   a:	ecce                	sd	s3,88(sp)
   c:	e8d2                	sd	s4,80(sp)
   e:	e4d6                	sd	s5,72(sp)
  10:	e0da                	sd	s6,64(sp)
  12:	fc5e                	sd	s7,56(sp)
  14:	f862                	sd	s8,48(sp)
  16:	f466                	sd	s9,40(sp)
  18:	f06a                	sd	s10,32(sp)
  1a:	ec6e                	sd	s11,24(sp)
  1c:	a422                	fsd	fs0,8(sp)
  1e:	0100                	addi	s0,sp,128
  int pid = getpid();
  20:	00000097          	auipc	ra,0x0
  24:	4ac080e7          	jalr	1196(ra) # 4cc <getpid>
  28:	84aa                	mv	s1,a0
  for (y = 0; y < N; ++y) {
  2a:	00001b97          	auipc	s7,0x1
  2e:	fe6b8b93          	addi	s7,s7,-26 # 1010 <c>
  int pid = getpid();
  32:	855e                	mv	a0,s7
  34:	00011597          	auipc	a1,0x11
  38:	fdc58593          	addi	a1,a1,-36 # 11010 <b>
  3c:	00021617          	auipc	a2,0x21
  40:	fd460613          	addi	a2,a2,-44 # 21010 <a>
  for (y = 0; y < N; ++y) {
  44:	4681                	li	a3,0
  46:	08000e13          	li	t3,128
  4a:	a811                	j	5e <main+0x5e>
  4c:	2685                	addiw	a3,a3,1
  4e:	20060613          	addi	a2,a2,512
  52:	20058593          	addi	a1,a1,512
  56:	20050513          	addi	a0,a0,512
  5a:	03c68d63          	beq	a3,t3,94 <main+0x94>
    for (x = 0; x < N; ++x) {
  5e:	0006879b          	sext.w	a5,a3
{
  62:	832a                	mv	t1,a0
  64:	88ae                	mv	a7,a1
  66:	8832                	mv	a6,a2
  68:	873e                	mv	a4,a5
    for (x = 0; x < N; ++x) {
  6a:	f807879b          	addiw	a5,a5,-128
      a[y][x] = y - x;
  6e:	d00777d3          	fcvt.s.w	fa5,a4
  72:	00f82027          	fsw	fa5,0(a6)
      b[y][x] = x - y;
  76:	40e00ebb          	negw	t4,a4
  7a:	d00ef7d3          	fcvt.s.w	fa5,t4
  7e:	00f8a027          	fsw	fa5,0(a7)
      c[y][x] = 0.0f;
  82:	00032023          	sw	zero,0(t1)
    for (x = 0; x < N; ++x) {
  86:	377d                	addiw	a4,a4,-1
  88:	0811                	addi	a6,a6,4
  8a:	0891                	addi	a7,a7,4
  8c:	0311                	addi	t1,t1,4
  8e:	fee790e3          	bne	a5,a4,6e <main+0x6e>
  92:	bf6d                	j	4c <main+0x4c>
  __asm__ __volatile__ ("rdtime %0": "=r" (n));
  94:	c01026f3          	rdtime	a3
  return n >> 20;
  98:	82d1                	srli	a3,a3,0x14
  __asm__ __volatile__ ("rdtime %0": "=r" (n));
  9a:	c0102af3          	rdtime	s5
  return n >> 20;
  9e:	014ada93          	srli	s5,s5,0x14
  __asm__ __volatile__ ("rdtime %0": "=r" (n));
  a2:	c01027f3          	rdtime	a5
  return n >> 20;
  a6:	83d1                	srli	a5,a5,0x14
  
  init();
  uint64 start = time();
  uint64 startglobal = time();
  uint64 endglobal = time();
  uint64 elapsedglobal = endglobal - startglobal;
  a8:	415787b3          	sub	a5,a5,s5
 
  uint64 ops = 0;
  uint64 total_ops = 0;
  while(elapsedglobal< 2000) {
  ac:	7cf00713          	li	a4,1999
  b0:	0ef76663          	bltu	a4,a5,19c <main+0x19c>
  uint64 total_ops = 0;
  b4:	4a01                	li	s4,0
  uint64 ops = 0;
  b6:	4981                	li	s3,0
  float beta = 1.0f;
  b8:	00001797          	auipc	a5,0x1
  bc:	8b87a407          	flw	fs0,-1864(a5) # 970 <malloc+0xea>
    uint64 end = time();
    uint64 elapsed = end - start;
    if (elapsed >= MINTICKS) {
  c0:	06300d13          	li	s10,99
        int measurement = (ops * MINTICKS / elapsed) / 1000000;
  c4:	06400c93          	li	s9,100
  c8:	000f4c37          	lui	s8,0xf4
  cc:	240c0c13          	addi	s8,s8,576 # f4240 <base+0xc3230>
        printf("%d: %d MFLOP%dT\n", pid, measurement, MINTICKS);
  d0:	00001d97          	auipc	s11,0x1
  d4:	8b0d8d93          	addi	s11,s11,-1872 # 980 <malloc+0xfa>
  d8:	6941                	lui	s2,0x10
  da:	20090913          	addi	s2,s2,512 # 10200 <c+0xf1f0>
  de:	995e                	add	s2,s2,s7
  e0:	a05d                	j	186 <main+0x186>
        int measurement = (ops * MINTICKS / elapsed) / 1000000;
  e2:	03998633          	mul	a2,s3,s9
  e6:	02f65633          	divu	a2,a2,a5
  ea:	03865633          	divu	a2,a2,s8
        printf("%d: %d MFLOP%dT\n", pid, measurement, MINTICKS);
  ee:	86e6                	mv	a3,s9
  f0:	2601                	sext.w	a2,a2
  f2:	85a6                	mv	a1,s1
  f4:	856e                	mv	a0,s11
  f6:	00000097          	auipc	ra,0x0
  fa:	6d8080e7          	jalr	1752(ra) # 7ce <printf>

        start = end;
        total_ops+=ops;
  fe:	9a4e                	add	s4,s4,s3
        start = end;
 100:	86da                	mv	a3,s6
        ops = 0;
 102:	4981                	li	s3,0
 104:	a849                	j	196 <main+0x196>
 106:	00ee2027          	fsw	fa4,0(t3)
    for (x = 0; x < N; ++x) {
 10a:	0711                	addi	a4,a4,4
 10c:	0811                	addi	a6,a6,4
 10e:	02f70763          	beq	a4,a5,13c <main+0x13c>
      for (k = 0; k < N; ++k) {
 112:	8e3a                	mv	t3,a4
 114:	00072707          	flw	fa4,0(a4)
        ops = 0;
 118:	88c2                	mv	a7,a6
 11a:	862a                	mv	a2,a0
        c[y][x] += beta * a[y][k] * b[k][x];
 11c:	00062787          	flw	fa5,0(a2)
 120:	10f477d3          	fmul.s	fa5,fs0,fa5
 124:	0008a687          	flw	fa3,0(a7)
 128:	10d7f7d3          	fmul.s	fa5,fa5,fa3
 12c:	00f77753          	fadd.s	fa4,fa4,fa5
      for (k = 0; k < N; ++k) {
 130:	0611                	addi	a2,a2,4
 132:	20088893          	addi	a7,a7,512
 136:	fe6613e3          	bne	a2,t1,11c <main+0x11c>
 13a:	b7f1                	j	106 <main+0x106>
  for (y = 0; y < N; ++y) {
 13c:	20078793          	addi	a5,a5,512
 140:	01278c63          	beq	a5,s2,158 <main+0x158>
 144:	851a                	mv	a0,t1
    for (x = 0; x < N; ++x) {
 146:	e0078713          	addi	a4,a5,-512
        ops = 0;
 14a:	00011817          	auipc	a6,0x11
 14e:	ec680813          	addi	a6,a6,-314 # 11010 <b>
 152:	20050313          	addi	t1,a0,512
 156:	bf75                	j	112 <main+0x112>
    }

    for(int i = 0; i < TIMES; ++i) {
        matmul(beta);
        beta = -beta;
 158:	20841453          	fneg.s	fs0,fs0
    for(int i = 0; i < TIMES; ++i) {
 15c:	35fd                	addiw	a1,a1,-1
 15e:	c981                	beqz	a1,16e <main+0x16e>
  for (y = 0; y < N; ++y) {
 160:	200b8793          	addi	a5,s7,512
 164:	00021517          	auipc	a0,0x21
 168:	eac50513          	addi	a0,a0,-340 # 21010 <a>
 16c:	bfe9                	j	146 <main+0x146>
        ops += 3 * N * N * N;
 16e:	0c0007b7          	lui	a5,0xc000
 172:	99be                	add	s3,s3,a5
  __asm__ __volatile__ ("rdtime %0": "=r" (n));
 174:	c01027f3          	rdtime	a5
  return n >> 20;
 178:	83d1                	srli	a5,a5,0x14
    }
    endglobal = time();
    elapsedglobal = endglobal - startglobal;
 17a:	415787b3          	sub	a5,a5,s5
  while(elapsedglobal< 2000) {
 17e:	7cf00713          	li	a4,1999
 182:	00f76e63          	bltu	a4,a5,19e <main+0x19e>
  __asm__ __volatile__ ("rdtime %0": "=r" (n));
 186:	c0102b73          	rdtime	s6
  return n >> 20;
 18a:	014b5b13          	srli	s6,s6,0x14
    uint64 elapsed = end - start;
 18e:	40db07b3          	sub	a5,s6,a3
    if (elapsed >= MINTICKS) {
 192:	f4fd68e3          	bltu	s10,a5,e2 <main+0xe2>
    for(int i = 0; i < TIMES; ++i) {
 196:	02000593          	li	a1,32
 19a:	b7d9                	j	160 <main+0x160>
  uint64 total_ops = 0;
 19c:	4a01                	li	s4,0

  }

  printf("Termino cpubench %d: total ops %lu --> ",pid, total_ops);
 19e:	8652                	mv	a2,s4
 1a0:	85a6                	mv	a1,s1
 1a2:	00000517          	auipc	a0,0x0
 1a6:	7f650513          	addi	a0,a0,2038 # 998 <malloc+0x112>
 1aa:	00000097          	auipc	ra,0x0
 1ae:	624080e7          	jalr	1572(ra) # 7ce <printf>
  pstat(pid);
 1b2:	8526                	mv	a0,s1
 1b4:	00000097          	auipc	ra,0x0
 1b8:	338080e7          	jalr	824(ra) # 4ec <pstat>
  exit(0);
 1bc:	4501                	li	a0,0
 1be:	00000097          	auipc	ra,0x0
 1c2:	28e080e7          	jalr	654(ra) # 44c <exit>

00000000000001c6 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 1c6:	1141                	addi	sp,sp,-16
 1c8:	e406                	sd	ra,8(sp)
 1ca:	e022                	sd	s0,0(sp)
 1cc:	0800                	addi	s0,sp,16
  extern int main();
  main();
 1ce:	00000097          	auipc	ra,0x0
 1d2:	e32080e7          	jalr	-462(ra) # 0 <main>
  exit(0);
 1d6:	4501                	li	a0,0
 1d8:	00000097          	auipc	ra,0x0
 1dc:	274080e7          	jalr	628(ra) # 44c <exit>

00000000000001e0 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 1e0:	1141                	addi	sp,sp,-16
 1e2:	e422                	sd	s0,8(sp)
 1e4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1e6:	87aa                	mv	a5,a0
 1e8:	0585                	addi	a1,a1,1
 1ea:	0785                	addi	a5,a5,1 # c000001 <base+0xbfceff1>
 1ec:	fff5c703          	lbu	a4,-1(a1)
 1f0:	fee78fa3          	sb	a4,-1(a5)
 1f4:	fb75                	bnez	a4,1e8 <strcpy+0x8>
    ;
  return os;
}
 1f6:	6422                	ld	s0,8(sp)
 1f8:	0141                	addi	sp,sp,16
 1fa:	8082                	ret

00000000000001fc <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1fc:	1141                	addi	sp,sp,-16
 1fe:	e422                	sd	s0,8(sp)
 200:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 202:	00054783          	lbu	a5,0(a0)
 206:	cb91                	beqz	a5,21a <strcmp+0x1e>
 208:	0005c703          	lbu	a4,0(a1)
 20c:	00f71763          	bne	a4,a5,21a <strcmp+0x1e>
    p++, q++;
 210:	0505                	addi	a0,a0,1
 212:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 214:	00054783          	lbu	a5,0(a0)
 218:	fbe5                	bnez	a5,208 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 21a:	0005c503          	lbu	a0,0(a1)
}
 21e:	40a7853b          	subw	a0,a5,a0
 222:	6422                	ld	s0,8(sp)
 224:	0141                	addi	sp,sp,16
 226:	8082                	ret

0000000000000228 <strlen>:

uint
strlen(const char *s)
{
 228:	1141                	addi	sp,sp,-16
 22a:	e422                	sd	s0,8(sp)
 22c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 22e:	00054783          	lbu	a5,0(a0)
 232:	cf91                	beqz	a5,24e <strlen+0x26>
 234:	0505                	addi	a0,a0,1
 236:	87aa                	mv	a5,a0
 238:	4685                	li	a3,1
 23a:	9e89                	subw	a3,a3,a0
 23c:	00f6853b          	addw	a0,a3,a5
 240:	0785                	addi	a5,a5,1
 242:	fff7c703          	lbu	a4,-1(a5)
 246:	fb7d                	bnez	a4,23c <strlen+0x14>
    ;
  return n;
}
 248:	6422                	ld	s0,8(sp)
 24a:	0141                	addi	sp,sp,16
 24c:	8082                	ret
  for(n = 0; s[n]; n++)
 24e:	4501                	li	a0,0
 250:	bfe5                	j	248 <strlen+0x20>

0000000000000252 <memset>:

void*
memset(void *dst, int c, uint n)
{
 252:	1141                	addi	sp,sp,-16
 254:	e422                	sd	s0,8(sp)
 256:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 258:	ca19                	beqz	a2,26e <memset+0x1c>
 25a:	87aa                	mv	a5,a0
 25c:	1602                	slli	a2,a2,0x20
 25e:	9201                	srli	a2,a2,0x20
 260:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 264:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 268:	0785                	addi	a5,a5,1
 26a:	fee79de3          	bne	a5,a4,264 <memset+0x12>
  }
  return dst;
}
 26e:	6422                	ld	s0,8(sp)
 270:	0141                	addi	sp,sp,16
 272:	8082                	ret

0000000000000274 <strchr>:

char*
strchr(const char *s, char c)
{
 274:	1141                	addi	sp,sp,-16
 276:	e422                	sd	s0,8(sp)
 278:	0800                	addi	s0,sp,16
  for(; *s; s++)
 27a:	00054783          	lbu	a5,0(a0)
 27e:	cb99                	beqz	a5,294 <strchr+0x20>
    if(*s == c)
 280:	00f58763          	beq	a1,a5,28e <strchr+0x1a>
  for(; *s; s++)
 284:	0505                	addi	a0,a0,1
 286:	00054783          	lbu	a5,0(a0)
 28a:	fbfd                	bnez	a5,280 <strchr+0xc>
      return (char*)s;
  return 0;
 28c:	4501                	li	a0,0
}
 28e:	6422                	ld	s0,8(sp)
 290:	0141                	addi	sp,sp,16
 292:	8082                	ret
  return 0;
 294:	4501                	li	a0,0
 296:	bfe5                	j	28e <strchr+0x1a>

0000000000000298 <gets>:

char*
gets(char *buf, int max)
{
 298:	711d                	addi	sp,sp,-96
 29a:	ec86                	sd	ra,88(sp)
 29c:	e8a2                	sd	s0,80(sp)
 29e:	e4a6                	sd	s1,72(sp)
 2a0:	e0ca                	sd	s2,64(sp)
 2a2:	fc4e                	sd	s3,56(sp)
 2a4:	f852                	sd	s4,48(sp)
 2a6:	f456                	sd	s5,40(sp)
 2a8:	f05a                	sd	s6,32(sp)
 2aa:	ec5e                	sd	s7,24(sp)
 2ac:	1080                	addi	s0,sp,96
 2ae:	8baa                	mv	s7,a0
 2b0:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2b2:	892a                	mv	s2,a0
 2b4:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2b6:	4aa9                	li	s5,10
 2b8:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2ba:	89a6                	mv	s3,s1
 2bc:	2485                	addiw	s1,s1,1
 2be:	0344d863          	bge	s1,s4,2ee <gets+0x56>
    cc = read(0, &c, 1);
 2c2:	4605                	li	a2,1
 2c4:	faf40593          	addi	a1,s0,-81
 2c8:	4501                	li	a0,0
 2ca:	00000097          	auipc	ra,0x0
 2ce:	19a080e7          	jalr	410(ra) # 464 <read>
    if(cc < 1)
 2d2:	00a05e63          	blez	a0,2ee <gets+0x56>
    buf[i++] = c;
 2d6:	faf44783          	lbu	a5,-81(s0)
 2da:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2de:	01578763          	beq	a5,s5,2ec <gets+0x54>
 2e2:	0905                	addi	s2,s2,1
 2e4:	fd679be3          	bne	a5,s6,2ba <gets+0x22>
  for(i=0; i+1 < max; ){
 2e8:	89a6                	mv	s3,s1
 2ea:	a011                	j	2ee <gets+0x56>
 2ec:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2ee:	99de                	add	s3,s3,s7
 2f0:	00098023          	sb	zero,0(s3)
  return buf;
}
 2f4:	855e                	mv	a0,s7
 2f6:	60e6                	ld	ra,88(sp)
 2f8:	6446                	ld	s0,80(sp)
 2fa:	64a6                	ld	s1,72(sp)
 2fc:	6906                	ld	s2,64(sp)
 2fe:	79e2                	ld	s3,56(sp)
 300:	7a42                	ld	s4,48(sp)
 302:	7aa2                	ld	s5,40(sp)
 304:	7b02                	ld	s6,32(sp)
 306:	6be2                	ld	s7,24(sp)
 308:	6125                	addi	sp,sp,96
 30a:	8082                	ret

000000000000030c <stat>:

int
stat(const char *n, struct stat *st)
{
 30c:	1101                	addi	sp,sp,-32
 30e:	ec06                	sd	ra,24(sp)
 310:	e822                	sd	s0,16(sp)
 312:	e426                	sd	s1,8(sp)
 314:	e04a                	sd	s2,0(sp)
 316:	1000                	addi	s0,sp,32
 318:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 31a:	4581                	li	a1,0
 31c:	00000097          	auipc	ra,0x0
 320:	170080e7          	jalr	368(ra) # 48c <open>
  if(fd < 0)
 324:	02054563          	bltz	a0,34e <stat+0x42>
 328:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 32a:	85ca                	mv	a1,s2
 32c:	00000097          	auipc	ra,0x0
 330:	178080e7          	jalr	376(ra) # 4a4 <fstat>
 334:	892a                	mv	s2,a0
  close(fd);
 336:	8526                	mv	a0,s1
 338:	00000097          	auipc	ra,0x0
 33c:	13c080e7          	jalr	316(ra) # 474 <close>
  return r;
}
 340:	854a                	mv	a0,s2
 342:	60e2                	ld	ra,24(sp)
 344:	6442                	ld	s0,16(sp)
 346:	64a2                	ld	s1,8(sp)
 348:	6902                	ld	s2,0(sp)
 34a:	6105                	addi	sp,sp,32
 34c:	8082                	ret
    return -1;
 34e:	597d                	li	s2,-1
 350:	bfc5                	j	340 <stat+0x34>

0000000000000352 <atoi>:

int
atoi(const char *s)
{
 352:	1141                	addi	sp,sp,-16
 354:	e422                	sd	s0,8(sp)
 356:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 358:	00054683          	lbu	a3,0(a0)
 35c:	fd06879b          	addiw	a5,a3,-48
 360:	0ff7f793          	zext.b	a5,a5
 364:	4625                	li	a2,9
 366:	02f66863          	bltu	a2,a5,396 <atoi+0x44>
 36a:	872a                	mv	a4,a0
  n = 0;
 36c:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 36e:	0705                	addi	a4,a4,1
 370:	0025179b          	slliw	a5,a0,0x2
 374:	9fa9                	addw	a5,a5,a0
 376:	0017979b          	slliw	a5,a5,0x1
 37a:	9fb5                	addw	a5,a5,a3
 37c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 380:	00074683          	lbu	a3,0(a4)
 384:	fd06879b          	addiw	a5,a3,-48
 388:	0ff7f793          	zext.b	a5,a5
 38c:	fef671e3          	bgeu	a2,a5,36e <atoi+0x1c>
  return n;
}
 390:	6422                	ld	s0,8(sp)
 392:	0141                	addi	sp,sp,16
 394:	8082                	ret
  n = 0;
 396:	4501                	li	a0,0
 398:	bfe5                	j	390 <atoi+0x3e>

000000000000039a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 39a:	1141                	addi	sp,sp,-16
 39c:	e422                	sd	s0,8(sp)
 39e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3a0:	02b57463          	bgeu	a0,a1,3c8 <memmove+0x2e>
    while(n-- > 0)
 3a4:	00c05f63          	blez	a2,3c2 <memmove+0x28>
 3a8:	1602                	slli	a2,a2,0x20
 3aa:	9201                	srli	a2,a2,0x20
 3ac:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 3b0:	872a                	mv	a4,a0
      *dst++ = *src++;
 3b2:	0585                	addi	a1,a1,1
 3b4:	0705                	addi	a4,a4,1
 3b6:	fff5c683          	lbu	a3,-1(a1)
 3ba:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3be:	fee79ae3          	bne	a5,a4,3b2 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3c2:	6422                	ld	s0,8(sp)
 3c4:	0141                	addi	sp,sp,16
 3c6:	8082                	ret
    dst += n;
 3c8:	00c50733          	add	a4,a0,a2
    src += n;
 3cc:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 3ce:	fec05ae3          	blez	a2,3c2 <memmove+0x28>
 3d2:	fff6079b          	addiw	a5,a2,-1
 3d6:	1782                	slli	a5,a5,0x20
 3d8:	9381                	srli	a5,a5,0x20
 3da:	fff7c793          	not	a5,a5
 3de:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3e0:	15fd                	addi	a1,a1,-1
 3e2:	177d                	addi	a4,a4,-1
 3e4:	0005c683          	lbu	a3,0(a1)
 3e8:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3ec:	fee79ae3          	bne	a5,a4,3e0 <memmove+0x46>
 3f0:	bfc9                	j	3c2 <memmove+0x28>

00000000000003f2 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3f2:	1141                	addi	sp,sp,-16
 3f4:	e422                	sd	s0,8(sp)
 3f6:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3f8:	ca05                	beqz	a2,428 <memcmp+0x36>
 3fa:	fff6069b          	addiw	a3,a2,-1
 3fe:	1682                	slli	a3,a3,0x20
 400:	9281                	srli	a3,a3,0x20
 402:	0685                	addi	a3,a3,1
 404:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 406:	00054783          	lbu	a5,0(a0)
 40a:	0005c703          	lbu	a4,0(a1)
 40e:	00e79863          	bne	a5,a4,41e <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 412:	0505                	addi	a0,a0,1
    p2++;
 414:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 416:	fed518e3          	bne	a0,a3,406 <memcmp+0x14>
  }
  return 0;
 41a:	4501                	li	a0,0
 41c:	a019                	j	422 <memcmp+0x30>
      return *p1 - *p2;
 41e:	40e7853b          	subw	a0,a5,a4
}
 422:	6422                	ld	s0,8(sp)
 424:	0141                	addi	sp,sp,16
 426:	8082                	ret
  return 0;
 428:	4501                	li	a0,0
 42a:	bfe5                	j	422 <memcmp+0x30>

000000000000042c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 42c:	1141                	addi	sp,sp,-16
 42e:	e406                	sd	ra,8(sp)
 430:	e022                	sd	s0,0(sp)
 432:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 434:	00000097          	auipc	ra,0x0
 438:	f66080e7          	jalr	-154(ra) # 39a <memmove>
}
 43c:	60a2                	ld	ra,8(sp)
 43e:	6402                	ld	s0,0(sp)
 440:	0141                	addi	sp,sp,16
 442:	8082                	ret

0000000000000444 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 444:	4885                	li	a7,1
 ecall
 446:	00000073          	ecall
 ret
 44a:	8082                	ret

000000000000044c <exit>:
.global exit
exit:
 li a7, SYS_exit
 44c:	4889                	li	a7,2
 ecall
 44e:	00000073          	ecall
 ret
 452:	8082                	ret

0000000000000454 <wait>:
.global wait
wait:
 li a7, SYS_wait
 454:	488d                	li	a7,3
 ecall
 456:	00000073          	ecall
 ret
 45a:	8082                	ret

000000000000045c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 45c:	4891                	li	a7,4
 ecall
 45e:	00000073          	ecall
 ret
 462:	8082                	ret

0000000000000464 <read>:
.global read
read:
 li a7, SYS_read
 464:	4895                	li	a7,5
 ecall
 466:	00000073          	ecall
 ret
 46a:	8082                	ret

000000000000046c <write>:
.global write
write:
 li a7, SYS_write
 46c:	48c1                	li	a7,16
 ecall
 46e:	00000073          	ecall
 ret
 472:	8082                	ret

0000000000000474 <close>:
.global close
close:
 li a7, SYS_close
 474:	48d5                	li	a7,21
 ecall
 476:	00000073          	ecall
 ret
 47a:	8082                	ret

000000000000047c <kill>:
.global kill
kill:
 li a7, SYS_kill
 47c:	4899                	li	a7,6
 ecall
 47e:	00000073          	ecall
 ret
 482:	8082                	ret

0000000000000484 <exec>:
.global exec
exec:
 li a7, SYS_exec
 484:	489d                	li	a7,7
 ecall
 486:	00000073          	ecall
 ret
 48a:	8082                	ret

000000000000048c <open>:
.global open
open:
 li a7, SYS_open
 48c:	48bd                	li	a7,15
 ecall
 48e:	00000073          	ecall
 ret
 492:	8082                	ret

0000000000000494 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 494:	48c5                	li	a7,17
 ecall
 496:	00000073          	ecall
 ret
 49a:	8082                	ret

000000000000049c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 49c:	48c9                	li	a7,18
 ecall
 49e:	00000073          	ecall
 ret
 4a2:	8082                	ret

00000000000004a4 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4a4:	48a1                	li	a7,8
 ecall
 4a6:	00000073          	ecall
 ret
 4aa:	8082                	ret

00000000000004ac <link>:
.global link
link:
 li a7, SYS_link
 4ac:	48cd                	li	a7,19
 ecall
 4ae:	00000073          	ecall
 ret
 4b2:	8082                	ret

00000000000004b4 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4b4:	48d1                	li	a7,20
 ecall
 4b6:	00000073          	ecall
 ret
 4ba:	8082                	ret

00000000000004bc <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4bc:	48a5                	li	a7,9
 ecall
 4be:	00000073          	ecall
 ret
 4c2:	8082                	ret

00000000000004c4 <dup>:
.global dup
dup:
 li a7, SYS_dup
 4c4:	48a9                	li	a7,10
 ecall
 4c6:	00000073          	ecall
 ret
 4ca:	8082                	ret

00000000000004cc <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4cc:	48ad                	li	a7,11
 ecall
 4ce:	00000073          	ecall
 ret
 4d2:	8082                	ret

00000000000004d4 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 4d4:	48b1                	li	a7,12
 ecall
 4d6:	00000073          	ecall
 ret
 4da:	8082                	ret

00000000000004dc <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 4dc:	48b5                	li	a7,13
 ecall
 4de:	00000073          	ecall
 ret
 4e2:	8082                	ret

00000000000004e4 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4e4:	48b9                	li	a7,14
 ecall
 4e6:	00000073          	ecall
 ret
 4ea:	8082                	ret

00000000000004ec <pstat>:
.global pstat
pstat:
 li a7, SYS_pstat
 4ec:	48d9                	li	a7,22
 ecall
 4ee:	00000073          	ecall
 ret
 4f2:	8082                	ret

00000000000004f4 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4f4:	1101                	addi	sp,sp,-32
 4f6:	ec06                	sd	ra,24(sp)
 4f8:	e822                	sd	s0,16(sp)
 4fa:	1000                	addi	s0,sp,32
 4fc:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 500:	4605                	li	a2,1
 502:	fef40593          	addi	a1,s0,-17
 506:	00000097          	auipc	ra,0x0
 50a:	f66080e7          	jalr	-154(ra) # 46c <write>
}
 50e:	60e2                	ld	ra,24(sp)
 510:	6442                	ld	s0,16(sp)
 512:	6105                	addi	sp,sp,32
 514:	8082                	ret

0000000000000516 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 516:	7139                	addi	sp,sp,-64
 518:	fc06                	sd	ra,56(sp)
 51a:	f822                	sd	s0,48(sp)
 51c:	f426                	sd	s1,40(sp)
 51e:	f04a                	sd	s2,32(sp)
 520:	ec4e                	sd	s3,24(sp)
 522:	0080                	addi	s0,sp,64
 524:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 526:	c299                	beqz	a3,52c <printint+0x16>
 528:	0805c963          	bltz	a1,5ba <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 52c:	2581                	sext.w	a1,a1
  neg = 0;
 52e:	4881                	li	a7,0
 530:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 534:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 536:	2601                	sext.w	a2,a2
 538:	00000517          	auipc	a0,0x0
 53c:	4e850513          	addi	a0,a0,1256 # a20 <digits>
 540:	883a                	mv	a6,a4
 542:	2705                	addiw	a4,a4,1
 544:	02c5f7bb          	remuw	a5,a1,a2
 548:	1782                	slli	a5,a5,0x20
 54a:	9381                	srli	a5,a5,0x20
 54c:	97aa                	add	a5,a5,a0
 54e:	0007c783          	lbu	a5,0(a5)
 552:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 556:	0005879b          	sext.w	a5,a1
 55a:	02c5d5bb          	divuw	a1,a1,a2
 55e:	0685                	addi	a3,a3,1
 560:	fec7f0e3          	bgeu	a5,a2,540 <printint+0x2a>
  if(neg)
 564:	00088c63          	beqz	a7,57c <printint+0x66>
    buf[i++] = '-';
 568:	fd070793          	addi	a5,a4,-48
 56c:	00878733          	add	a4,a5,s0
 570:	02d00793          	li	a5,45
 574:	fef70823          	sb	a5,-16(a4)
 578:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 57c:	02e05863          	blez	a4,5ac <printint+0x96>
 580:	fc040793          	addi	a5,s0,-64
 584:	00e78933          	add	s2,a5,a4
 588:	fff78993          	addi	s3,a5,-1
 58c:	99ba                	add	s3,s3,a4
 58e:	377d                	addiw	a4,a4,-1
 590:	1702                	slli	a4,a4,0x20
 592:	9301                	srli	a4,a4,0x20
 594:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 598:	fff94583          	lbu	a1,-1(s2)
 59c:	8526                	mv	a0,s1
 59e:	00000097          	auipc	ra,0x0
 5a2:	f56080e7          	jalr	-170(ra) # 4f4 <putc>
  while(--i >= 0)
 5a6:	197d                	addi	s2,s2,-1
 5a8:	ff3918e3          	bne	s2,s3,598 <printint+0x82>
}
 5ac:	70e2                	ld	ra,56(sp)
 5ae:	7442                	ld	s0,48(sp)
 5b0:	74a2                	ld	s1,40(sp)
 5b2:	7902                	ld	s2,32(sp)
 5b4:	69e2                	ld	s3,24(sp)
 5b6:	6121                	addi	sp,sp,64
 5b8:	8082                	ret
    x = -xx;
 5ba:	40b005bb          	negw	a1,a1
    neg = 1;
 5be:	4885                	li	a7,1
    x = -xx;
 5c0:	bf85                	j	530 <printint+0x1a>

00000000000005c2 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5c2:	7119                	addi	sp,sp,-128
 5c4:	fc86                	sd	ra,120(sp)
 5c6:	f8a2                	sd	s0,112(sp)
 5c8:	f4a6                	sd	s1,104(sp)
 5ca:	f0ca                	sd	s2,96(sp)
 5cc:	ecce                	sd	s3,88(sp)
 5ce:	e8d2                	sd	s4,80(sp)
 5d0:	e4d6                	sd	s5,72(sp)
 5d2:	e0da                	sd	s6,64(sp)
 5d4:	fc5e                	sd	s7,56(sp)
 5d6:	f862                	sd	s8,48(sp)
 5d8:	f466                	sd	s9,40(sp)
 5da:	f06a                	sd	s10,32(sp)
 5dc:	ec6e                	sd	s11,24(sp)
 5de:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5e0:	0005c903          	lbu	s2,0(a1)
 5e4:	18090f63          	beqz	s2,782 <vprintf+0x1c0>
 5e8:	8aaa                	mv	s5,a0
 5ea:	8b32                	mv	s6,a2
 5ec:	00158493          	addi	s1,a1,1
  state = 0;
 5f0:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5f2:	02500a13          	li	s4,37
 5f6:	4c55                	li	s8,21
 5f8:	00000c97          	auipc	s9,0x0
 5fc:	3d0c8c93          	addi	s9,s9,976 # 9c8 <malloc+0x142>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 600:	02800d93          	li	s11,40
  putc(fd, 'x');
 604:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 606:	00000b97          	auipc	s7,0x0
 60a:	41ab8b93          	addi	s7,s7,1050 # a20 <digits>
 60e:	a839                	j	62c <vprintf+0x6a>
        putc(fd, c);
 610:	85ca                	mv	a1,s2
 612:	8556                	mv	a0,s5
 614:	00000097          	auipc	ra,0x0
 618:	ee0080e7          	jalr	-288(ra) # 4f4 <putc>
 61c:	a019                	j	622 <vprintf+0x60>
    } else if(state == '%'){
 61e:	01498d63          	beq	s3,s4,638 <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 622:	0485                	addi	s1,s1,1
 624:	fff4c903          	lbu	s2,-1(s1)
 628:	14090d63          	beqz	s2,782 <vprintf+0x1c0>
    if(state == 0){
 62c:	fe0999e3          	bnez	s3,61e <vprintf+0x5c>
      if(c == '%'){
 630:	ff4910e3          	bne	s2,s4,610 <vprintf+0x4e>
        state = '%';
 634:	89d2                	mv	s3,s4
 636:	b7f5                	j	622 <vprintf+0x60>
      if(c == 'd'){
 638:	11490c63          	beq	s2,s4,750 <vprintf+0x18e>
 63c:	f9d9079b          	addiw	a5,s2,-99
 640:	0ff7f793          	zext.b	a5,a5
 644:	10fc6e63          	bltu	s8,a5,760 <vprintf+0x19e>
 648:	f9d9079b          	addiw	a5,s2,-99
 64c:	0ff7f713          	zext.b	a4,a5
 650:	10ec6863          	bltu	s8,a4,760 <vprintf+0x19e>
 654:	00271793          	slli	a5,a4,0x2
 658:	97e6                	add	a5,a5,s9
 65a:	439c                	lw	a5,0(a5)
 65c:	97e6                	add	a5,a5,s9
 65e:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 660:	008b0913          	addi	s2,s6,8
 664:	4685                	li	a3,1
 666:	4629                	li	a2,10
 668:	000b2583          	lw	a1,0(s6)
 66c:	8556                	mv	a0,s5
 66e:	00000097          	auipc	ra,0x0
 672:	ea8080e7          	jalr	-344(ra) # 516 <printint>
 676:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 678:	4981                	li	s3,0
 67a:	b765                	j	622 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 67c:	008b0913          	addi	s2,s6,8
 680:	4681                	li	a3,0
 682:	4629                	li	a2,10
 684:	000b2583          	lw	a1,0(s6)
 688:	8556                	mv	a0,s5
 68a:	00000097          	auipc	ra,0x0
 68e:	e8c080e7          	jalr	-372(ra) # 516 <printint>
 692:	8b4a                	mv	s6,s2
      state = 0;
 694:	4981                	li	s3,0
 696:	b771                	j	622 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 698:	008b0913          	addi	s2,s6,8
 69c:	4681                	li	a3,0
 69e:	866a                	mv	a2,s10
 6a0:	000b2583          	lw	a1,0(s6)
 6a4:	8556                	mv	a0,s5
 6a6:	00000097          	auipc	ra,0x0
 6aa:	e70080e7          	jalr	-400(ra) # 516 <printint>
 6ae:	8b4a                	mv	s6,s2
      state = 0;
 6b0:	4981                	li	s3,0
 6b2:	bf85                	j	622 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 6b4:	008b0793          	addi	a5,s6,8
 6b8:	f8f43423          	sd	a5,-120(s0)
 6bc:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 6c0:	03000593          	li	a1,48
 6c4:	8556                	mv	a0,s5
 6c6:	00000097          	auipc	ra,0x0
 6ca:	e2e080e7          	jalr	-466(ra) # 4f4 <putc>
  putc(fd, 'x');
 6ce:	07800593          	li	a1,120
 6d2:	8556                	mv	a0,s5
 6d4:	00000097          	auipc	ra,0x0
 6d8:	e20080e7          	jalr	-480(ra) # 4f4 <putc>
 6dc:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6de:	03c9d793          	srli	a5,s3,0x3c
 6e2:	97de                	add	a5,a5,s7
 6e4:	0007c583          	lbu	a1,0(a5)
 6e8:	8556                	mv	a0,s5
 6ea:	00000097          	auipc	ra,0x0
 6ee:	e0a080e7          	jalr	-502(ra) # 4f4 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6f2:	0992                	slli	s3,s3,0x4
 6f4:	397d                	addiw	s2,s2,-1
 6f6:	fe0914e3          	bnez	s2,6de <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 6fa:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 6fe:	4981                	li	s3,0
 700:	b70d                	j	622 <vprintf+0x60>
        s = va_arg(ap, char*);
 702:	008b0913          	addi	s2,s6,8
 706:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 70a:	02098163          	beqz	s3,72c <vprintf+0x16a>
        while(*s != 0){
 70e:	0009c583          	lbu	a1,0(s3)
 712:	c5ad                	beqz	a1,77c <vprintf+0x1ba>
          putc(fd, *s);
 714:	8556                	mv	a0,s5
 716:	00000097          	auipc	ra,0x0
 71a:	dde080e7          	jalr	-546(ra) # 4f4 <putc>
          s++;
 71e:	0985                	addi	s3,s3,1
        while(*s != 0){
 720:	0009c583          	lbu	a1,0(s3)
 724:	f9e5                	bnez	a1,714 <vprintf+0x152>
        s = va_arg(ap, char*);
 726:	8b4a                	mv	s6,s2
      state = 0;
 728:	4981                	li	s3,0
 72a:	bde5                	j	622 <vprintf+0x60>
          s = "(null)";
 72c:	00000997          	auipc	s3,0x0
 730:	29498993          	addi	s3,s3,660 # 9c0 <malloc+0x13a>
        while(*s != 0){
 734:	85ee                	mv	a1,s11
 736:	bff9                	j	714 <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 738:	008b0913          	addi	s2,s6,8
 73c:	000b4583          	lbu	a1,0(s6)
 740:	8556                	mv	a0,s5
 742:	00000097          	auipc	ra,0x0
 746:	db2080e7          	jalr	-590(ra) # 4f4 <putc>
 74a:	8b4a                	mv	s6,s2
      state = 0;
 74c:	4981                	li	s3,0
 74e:	bdd1                	j	622 <vprintf+0x60>
        putc(fd, c);
 750:	85d2                	mv	a1,s4
 752:	8556                	mv	a0,s5
 754:	00000097          	auipc	ra,0x0
 758:	da0080e7          	jalr	-608(ra) # 4f4 <putc>
      state = 0;
 75c:	4981                	li	s3,0
 75e:	b5d1                	j	622 <vprintf+0x60>
        putc(fd, '%');
 760:	85d2                	mv	a1,s4
 762:	8556                	mv	a0,s5
 764:	00000097          	auipc	ra,0x0
 768:	d90080e7          	jalr	-624(ra) # 4f4 <putc>
        putc(fd, c);
 76c:	85ca                	mv	a1,s2
 76e:	8556                	mv	a0,s5
 770:	00000097          	auipc	ra,0x0
 774:	d84080e7          	jalr	-636(ra) # 4f4 <putc>
      state = 0;
 778:	4981                	li	s3,0
 77a:	b565                	j	622 <vprintf+0x60>
        s = va_arg(ap, char*);
 77c:	8b4a                	mv	s6,s2
      state = 0;
 77e:	4981                	li	s3,0
 780:	b54d                	j	622 <vprintf+0x60>
    }
  }
}
 782:	70e6                	ld	ra,120(sp)
 784:	7446                	ld	s0,112(sp)
 786:	74a6                	ld	s1,104(sp)
 788:	7906                	ld	s2,96(sp)
 78a:	69e6                	ld	s3,88(sp)
 78c:	6a46                	ld	s4,80(sp)
 78e:	6aa6                	ld	s5,72(sp)
 790:	6b06                	ld	s6,64(sp)
 792:	7be2                	ld	s7,56(sp)
 794:	7c42                	ld	s8,48(sp)
 796:	7ca2                	ld	s9,40(sp)
 798:	7d02                	ld	s10,32(sp)
 79a:	6de2                	ld	s11,24(sp)
 79c:	6109                	addi	sp,sp,128
 79e:	8082                	ret

00000000000007a0 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7a0:	715d                	addi	sp,sp,-80
 7a2:	ec06                	sd	ra,24(sp)
 7a4:	e822                	sd	s0,16(sp)
 7a6:	1000                	addi	s0,sp,32
 7a8:	e010                	sd	a2,0(s0)
 7aa:	e414                	sd	a3,8(s0)
 7ac:	e818                	sd	a4,16(s0)
 7ae:	ec1c                	sd	a5,24(s0)
 7b0:	03043023          	sd	a6,32(s0)
 7b4:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7b8:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7bc:	8622                	mv	a2,s0
 7be:	00000097          	auipc	ra,0x0
 7c2:	e04080e7          	jalr	-508(ra) # 5c2 <vprintf>
}
 7c6:	60e2                	ld	ra,24(sp)
 7c8:	6442                	ld	s0,16(sp)
 7ca:	6161                	addi	sp,sp,80
 7cc:	8082                	ret

00000000000007ce <printf>:

void
printf(const char *fmt, ...)
{
 7ce:	711d                	addi	sp,sp,-96
 7d0:	ec06                	sd	ra,24(sp)
 7d2:	e822                	sd	s0,16(sp)
 7d4:	1000                	addi	s0,sp,32
 7d6:	e40c                	sd	a1,8(s0)
 7d8:	e810                	sd	a2,16(s0)
 7da:	ec14                	sd	a3,24(s0)
 7dc:	f018                	sd	a4,32(s0)
 7de:	f41c                	sd	a5,40(s0)
 7e0:	03043823          	sd	a6,48(s0)
 7e4:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7e8:	00840613          	addi	a2,s0,8
 7ec:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7f0:	85aa                	mv	a1,a0
 7f2:	4505                	li	a0,1
 7f4:	00000097          	auipc	ra,0x0
 7f8:	dce080e7          	jalr	-562(ra) # 5c2 <vprintf>
}
 7fc:	60e2                	ld	ra,24(sp)
 7fe:	6442                	ld	s0,16(sp)
 800:	6125                	addi	sp,sp,96
 802:	8082                	ret

0000000000000804 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 804:	1141                	addi	sp,sp,-16
 806:	e422                	sd	s0,8(sp)
 808:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 80a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 80e:	00000797          	auipc	a5,0x0
 812:	7f27b783          	ld	a5,2034(a5) # 1000 <freep>
 816:	a02d                	j	840 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 818:	4618                	lw	a4,8(a2)
 81a:	9f2d                	addw	a4,a4,a1
 81c:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 820:	6398                	ld	a4,0(a5)
 822:	6310                	ld	a2,0(a4)
 824:	a83d                	j	862 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 826:	ff852703          	lw	a4,-8(a0)
 82a:	9f31                	addw	a4,a4,a2
 82c:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 82e:	ff053683          	ld	a3,-16(a0)
 832:	a091                	j	876 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 834:	6398                	ld	a4,0(a5)
 836:	00e7e463          	bltu	a5,a4,83e <free+0x3a>
 83a:	00e6ea63          	bltu	a3,a4,84e <free+0x4a>
{
 83e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 840:	fed7fae3          	bgeu	a5,a3,834 <free+0x30>
 844:	6398                	ld	a4,0(a5)
 846:	00e6e463          	bltu	a3,a4,84e <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 84a:	fee7eae3          	bltu	a5,a4,83e <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 84e:	ff852583          	lw	a1,-8(a0)
 852:	6390                	ld	a2,0(a5)
 854:	02059813          	slli	a6,a1,0x20
 858:	01c85713          	srli	a4,a6,0x1c
 85c:	9736                	add	a4,a4,a3
 85e:	fae60de3          	beq	a2,a4,818 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 862:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 866:	4790                	lw	a2,8(a5)
 868:	02061593          	slli	a1,a2,0x20
 86c:	01c5d713          	srli	a4,a1,0x1c
 870:	973e                	add	a4,a4,a5
 872:	fae68ae3          	beq	a3,a4,826 <free+0x22>
    p->s.ptr = bp->s.ptr;
 876:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 878:	00000717          	auipc	a4,0x0
 87c:	78f73423          	sd	a5,1928(a4) # 1000 <freep>
}
 880:	6422                	ld	s0,8(sp)
 882:	0141                	addi	sp,sp,16
 884:	8082                	ret

0000000000000886 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 886:	7139                	addi	sp,sp,-64
 888:	fc06                	sd	ra,56(sp)
 88a:	f822                	sd	s0,48(sp)
 88c:	f426                	sd	s1,40(sp)
 88e:	f04a                	sd	s2,32(sp)
 890:	ec4e                	sd	s3,24(sp)
 892:	e852                	sd	s4,16(sp)
 894:	e456                	sd	s5,8(sp)
 896:	e05a                	sd	s6,0(sp)
 898:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 89a:	02051493          	slli	s1,a0,0x20
 89e:	9081                	srli	s1,s1,0x20
 8a0:	04bd                	addi	s1,s1,15
 8a2:	8091                	srli	s1,s1,0x4
 8a4:	0014899b          	addiw	s3,s1,1
 8a8:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8aa:	00000517          	auipc	a0,0x0
 8ae:	75653503          	ld	a0,1878(a0) # 1000 <freep>
 8b2:	c515                	beqz	a0,8de <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8b4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8b6:	4798                	lw	a4,8(a5)
 8b8:	02977f63          	bgeu	a4,s1,8f6 <malloc+0x70>
 8bc:	8a4e                	mv	s4,s3
 8be:	0009871b          	sext.w	a4,s3
 8c2:	6685                	lui	a3,0x1
 8c4:	00d77363          	bgeu	a4,a3,8ca <malloc+0x44>
 8c8:	6a05                	lui	s4,0x1
 8ca:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8ce:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8d2:	00000917          	auipc	s2,0x0
 8d6:	72e90913          	addi	s2,s2,1838 # 1000 <freep>
  if(p == (char*)-1)
 8da:	5afd                	li	s5,-1
 8dc:	a895                	j	950 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 8de:	00030797          	auipc	a5,0x30
 8e2:	73278793          	addi	a5,a5,1842 # 31010 <base>
 8e6:	00000717          	auipc	a4,0x0
 8ea:	70f73d23          	sd	a5,1818(a4) # 1000 <freep>
 8ee:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8f0:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8f4:	b7e1                	j	8bc <malloc+0x36>
      if(p->s.size == nunits)
 8f6:	02e48c63          	beq	s1,a4,92e <malloc+0xa8>
        p->s.size -= nunits;
 8fa:	4137073b          	subw	a4,a4,s3
 8fe:	c798                	sw	a4,8(a5)
        p += p->s.size;
 900:	02071693          	slli	a3,a4,0x20
 904:	01c6d713          	srli	a4,a3,0x1c
 908:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 90a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 90e:	00000717          	auipc	a4,0x0
 912:	6ea73923          	sd	a0,1778(a4) # 1000 <freep>
      return (void*)(p + 1);
 916:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 91a:	70e2                	ld	ra,56(sp)
 91c:	7442                	ld	s0,48(sp)
 91e:	74a2                	ld	s1,40(sp)
 920:	7902                	ld	s2,32(sp)
 922:	69e2                	ld	s3,24(sp)
 924:	6a42                	ld	s4,16(sp)
 926:	6aa2                	ld	s5,8(sp)
 928:	6b02                	ld	s6,0(sp)
 92a:	6121                	addi	sp,sp,64
 92c:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 92e:	6398                	ld	a4,0(a5)
 930:	e118                	sd	a4,0(a0)
 932:	bff1                	j	90e <malloc+0x88>
  hp->s.size = nu;
 934:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 938:	0541                	addi	a0,a0,16
 93a:	00000097          	auipc	ra,0x0
 93e:	eca080e7          	jalr	-310(ra) # 804 <free>
  return freep;
 942:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 946:	d971                	beqz	a0,91a <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 948:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 94a:	4798                	lw	a4,8(a5)
 94c:	fa9775e3          	bgeu	a4,s1,8f6 <malloc+0x70>
    if(p == freep)
 950:	00093703          	ld	a4,0(s2)
 954:	853e                	mv	a0,a5
 956:	fef719e3          	bne	a4,a5,948 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 95a:	8552                	mv	a0,s4
 95c:	00000097          	auipc	ra,0x0
 960:	b78080e7          	jalr	-1160(ra) # 4d4 <sbrk>
  if(p == (char*)-1)
 964:	fd5518e3          	bne	a0,s5,934 <malloc+0xae>
        return 0;
 968:	4501                	li	a0,0
 96a:	bf45                	j	91a <malloc+0x94>

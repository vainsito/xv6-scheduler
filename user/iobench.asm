
user/_iobench:     formato del fichero elf64-littleriscv


Desensamblado de la sección .text:

0000000000000000 <main>:
  return n >> 20;
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
  1c:	0100                	addi	s0,sp,128
  int rfd, wfd;
  int pid = getpid();
  1e:	00000097          	auipc	ra,0x0
  22:	49c080e7          	jalr	1180(ra) # 4ba <getpid>
  26:	f8a43023          	sd	a0,-128(s0)
  int i;

  path[0] = '0' + (pid / 10);
  2a:	00001697          	auipc	a3,0x1
  2e:	fd668693          	addi	a3,a3,-42 # 1000 <path>
  32:	47a9                	li	a5,10
  34:	02f5473b          	divw	a4,a0,a5
  38:	0307071b          	addiw	a4,a4,48
  3c:	00e68023          	sb	a4,0(a3)
  path[1] = '0' + (pid % 10);
  40:	02f567bb          	remw	a5,a0,a5
  44:	0307879b          	addiw	a5,a5,48
  48:	00f680a3          	sb	a5,1(a3)

  memset(data, 'a', sizeof(data));
  4c:	0a000613          	li	a2,160
  50:	06100593          	li	a1,97
  54:	00001517          	auipc	a0,0x1
  58:	fcc50513          	addi	a0,a0,-52 # 1020 <data>
  5c:	00000097          	auipc	ra,0x0
  60:	1e4080e7          	jalr	484(ra) # 240 <memset>
  __asm__ __volatile__ ("rdtime %0": "=r" (n));
  64:	c0102d73          	rdtime	s10
  68:	c0102df3          	rdtime	s11
  return n >> 20;
  6c:	014ddd93          	srli	s11,s11,0x14
  __asm__ __volatile__ ("rdtime %0": "=r" (n));
  70:	c01027f3          	rdtime	a5
  return n >> 20;
  74:	83d1                	srli	a5,a5,0x14
  int opsw = 0,opsr = 0;
  uint64 total_ops=0;

  uint64 startglobal = time();
  uint64 endglobal = time();
  uint64 elapsedglobal = endglobal - startglobal;
  76:	41b787b3          	sub	a5,a5,s11

  while(elapsedglobal< 2000) {
  7a:	7cf00713          	li	a4,1999
  7e:	10f76263          	bltu	a4,a5,182 <main+0x182>
  82:	014d5d13          	srli	s10,s10,0x14
  uint64 total_ops=0;
  86:	f8043423          	sd	zero,-120(s0)
  int opsw = 0,opsr = 0;
  8a:	4c01                	li	s8,0
  8c:	4b81                	li	s7,0
    uint64 end = time();
    uint64 elapsed = end - start;
    
    wfd = open(path, O_CREATE | O_WRONLY);
  8e:	00001c97          	auipc	s9,0x1
  92:	f72c8c93          	addi	s9,s9,-142 # 1000 <path>
    
    for(i = 0; i < TIMES; ++i) {
      write(wfd, data, OPSIZE);
  96:	00001917          	auipc	s2,0x1
  9a:	f8a90913          	addi	s2,s2,-118 # 1020 <data>
  9e:	a811                	j	b2 <main+0xb2>
  __asm__ __volatile__ ("rdtime %0": "=r" (n));
  a0:	c01027f3          	rdtime	a5
  return n >> 20;
  a4:	83d1                	srli	a5,a5,0x14
        opsr = 0;
        
    }
    
    endglobal = time();
    elapsedglobal = endglobal - startglobal;
  a6:	41b787b3          	sub	a5,a5,s11
  while(elapsedglobal< 2000) {
  aa:	7cf00713          	li	a4,1999
  ae:	0cf76c63          	bltu	a4,a5,186 <main+0x186>
  __asm__ __volatile__ ("rdtime %0": "=r" (n));
  b2:	c0102a73          	rdtime	s4
  return n >> 20;
  b6:	014a5a13          	srli	s4,s4,0x14
    uint64 elapsed = end - start;
  ba:	41aa0b33          	sub	s6,s4,s10
    wfd = open(path, O_CREATE | O_WRONLY);
  be:	20100593          	li	a1,513
  c2:	8566                	mv	a0,s9
  c4:	00000097          	auipc	ra,0x0
  c8:	3b6080e7          	jalr	950(ra) # 47a <open>
  cc:	89aa                	mv	s3,a0
  ce:	02000493          	li	s1,32
      write(wfd, data, OPSIZE);
  d2:	0a000613          	li	a2,160
  d6:	85ca                	mv	a1,s2
  d8:	854e                	mv	a0,s3
  da:	00000097          	auipc	ra,0x0
  de:	380080e7          	jalr	896(ra) # 45a <write>
    for(i = 0; i < TIMES; ++i) {
  e2:	34fd                	addiw	s1,s1,-1
  e4:	f4fd                	bnez	s1,d2 <main+0xd2>
    close(wfd);
  e6:	854e                	mv	a0,s3
  e8:	00000097          	auipc	ra,0x0
  ec:	37a080e7          	jalr	890(ra) # 462 <close>
    opsw += 2 * TIMES;
  f0:	040b8a9b          	addiw	s5,s7,64
  f4:	000a8b9b          	sext.w	s7,s5
    rfd = open(path, O_RDONLY);
  f8:	4581                	li	a1,0
  fa:	8566                	mv	a0,s9
  fc:	00000097          	auipc	ra,0x0
 100:	37e080e7          	jalr	894(ra) # 47a <open>
 104:	89aa                	mv	s3,a0
 106:	02000493          	li	s1,32
      read(rfd, data, OPSIZE);
 10a:	0a000613          	li	a2,160
 10e:	85ca                	mv	a1,s2
 110:	854e                	mv	a0,s3
 112:	00000097          	auipc	ra,0x0
 116:	340080e7          	jalr	832(ra) # 452 <read>
    for(i = 0; i < TIMES; ++i) {
 11a:	34fd                	addiw	s1,s1,-1
 11c:	f4fd                	bnez	s1,10a <main+0x10a>
    close(rfd);
 11e:	854e                	mv	a0,s3
 120:	00000097          	auipc	ra,0x0
 124:	342080e7          	jalr	834(ra) # 462 <close>
    opsr += 2 * TIMES;
 128:	040c049b          	addiw	s1,s8,64
 12c:	00048c1b          	sext.w	s8,s1
    if (elapsed >= MINTICKS) {
 130:	06300793          	li	a5,99
 134:	f767f6e3          	bgeu	a5,s6,a0 <main+0xa0>
                      , (int) (opsr * MINTICKS / elapsed), MINTICKS);
 138:	06400793          	li	a5,100
 13c:	0297873b          	mulw	a4,a5,s1
 140:	03675733          	divu	a4,a4,s6
                      , (int) (opsw * MINTICKS / elapsed), MINTICKS
 144:	0357863b          	mulw	a2,a5,s5
 148:	03665633          	divu	a2,a2,s6
        printf("\t\t\t\t\t%d: %d OPW%dT, %d OPR%dT\n", pid
 14c:	06400793          	li	a5,100
 150:	2701                	sext.w	a4,a4
 152:	06400693          	li	a3,100
 156:	2601                	sext.w	a2,a2
 158:	f8043583          	ld	a1,-128(s0)
 15c:	00001517          	auipc	a0,0x1
 160:	80450513          	addi	a0,a0,-2044 # 960 <malloc+0xec>
 164:	00000097          	auipc	ra,0x0
 168:	658080e7          	jalr	1624(ra) # 7bc <printf>
        total_ops+=opsr+opsw;
 16c:	009a8abb          	addw	s5,s5,s1
 170:	f8843783          	ld	a5,-120(s0)
 174:	97d6                	add	a5,a5,s5
 176:	f8f43423          	sd	a5,-120(s0)
        start = end;
 17a:	8d52                	mv	s10,s4
        opsr = 0;
 17c:	4c01                	li	s8,0
        opsw = 0;
 17e:	4b81                	li	s7,0
 180:	b705                	j	a0 <main+0xa0>
  uint64 total_ops=0;
 182:	f8043423          	sd	zero,-120(s0)


  }
  printf("Termino iobench %d: total ops %lu -->\t",pid, total_ops);
 186:	f8843603          	ld	a2,-120(s0)
 18a:	f8043483          	ld	s1,-128(s0)
 18e:	85a6                	mv	a1,s1
 190:	00000517          	auipc	a0,0x0
 194:	7f050513          	addi	a0,a0,2032 # 980 <malloc+0x10c>
 198:	00000097          	auipc	ra,0x0
 19c:	624080e7          	jalr	1572(ra) # 7bc <printf>
  pstat(pid);
 1a0:	8526                	mv	a0,s1
 1a2:	00000097          	auipc	ra,0x0
 1a6:	338080e7          	jalr	824(ra) # 4da <pstat>
  exit(0);
 1aa:	4501                	li	a0,0
 1ac:	00000097          	auipc	ra,0x0
 1b0:	28e080e7          	jalr	654(ra) # 43a <exit>

00000000000001b4 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 1b4:	1141                	addi	sp,sp,-16
 1b6:	e406                	sd	ra,8(sp)
 1b8:	e022                	sd	s0,0(sp)
 1ba:	0800                	addi	s0,sp,16
  extern int main();
  main();
 1bc:	00000097          	auipc	ra,0x0
 1c0:	e44080e7          	jalr	-444(ra) # 0 <main>
  exit(0);
 1c4:	4501                	li	a0,0
 1c6:	00000097          	auipc	ra,0x0
 1ca:	274080e7          	jalr	628(ra) # 43a <exit>

00000000000001ce <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 1ce:	1141                	addi	sp,sp,-16
 1d0:	e422                	sd	s0,8(sp)
 1d2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1d4:	87aa                	mv	a5,a0
 1d6:	0585                	addi	a1,a1,1
 1d8:	0785                	addi	a5,a5,1
 1da:	fff5c703          	lbu	a4,-1(a1)
 1de:	fee78fa3          	sb	a4,-1(a5)
 1e2:	fb75                	bnez	a4,1d6 <strcpy+0x8>
    ;
  return os;
}
 1e4:	6422                	ld	s0,8(sp)
 1e6:	0141                	addi	sp,sp,16
 1e8:	8082                	ret

00000000000001ea <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1ea:	1141                	addi	sp,sp,-16
 1ec:	e422                	sd	s0,8(sp)
 1ee:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1f0:	00054783          	lbu	a5,0(a0)
 1f4:	cb91                	beqz	a5,208 <strcmp+0x1e>
 1f6:	0005c703          	lbu	a4,0(a1)
 1fa:	00f71763          	bne	a4,a5,208 <strcmp+0x1e>
    p++, q++;
 1fe:	0505                	addi	a0,a0,1
 200:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 202:	00054783          	lbu	a5,0(a0)
 206:	fbe5                	bnez	a5,1f6 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 208:	0005c503          	lbu	a0,0(a1)
}
 20c:	40a7853b          	subw	a0,a5,a0
 210:	6422                	ld	s0,8(sp)
 212:	0141                	addi	sp,sp,16
 214:	8082                	ret

0000000000000216 <strlen>:

uint
strlen(const char *s)
{
 216:	1141                	addi	sp,sp,-16
 218:	e422                	sd	s0,8(sp)
 21a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 21c:	00054783          	lbu	a5,0(a0)
 220:	cf91                	beqz	a5,23c <strlen+0x26>
 222:	0505                	addi	a0,a0,1
 224:	87aa                	mv	a5,a0
 226:	4685                	li	a3,1
 228:	9e89                	subw	a3,a3,a0
 22a:	00f6853b          	addw	a0,a3,a5
 22e:	0785                	addi	a5,a5,1
 230:	fff7c703          	lbu	a4,-1(a5)
 234:	fb7d                	bnez	a4,22a <strlen+0x14>
    ;
  return n;
}
 236:	6422                	ld	s0,8(sp)
 238:	0141                	addi	sp,sp,16
 23a:	8082                	ret
  for(n = 0; s[n]; n++)
 23c:	4501                	li	a0,0
 23e:	bfe5                	j	236 <strlen+0x20>

0000000000000240 <memset>:

void*
memset(void *dst, int c, uint n)
{
 240:	1141                	addi	sp,sp,-16
 242:	e422                	sd	s0,8(sp)
 244:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 246:	ca19                	beqz	a2,25c <memset+0x1c>
 248:	87aa                	mv	a5,a0
 24a:	1602                	slli	a2,a2,0x20
 24c:	9201                	srli	a2,a2,0x20
 24e:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 252:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 256:	0785                	addi	a5,a5,1
 258:	fee79de3          	bne	a5,a4,252 <memset+0x12>
  }
  return dst;
}
 25c:	6422                	ld	s0,8(sp)
 25e:	0141                	addi	sp,sp,16
 260:	8082                	ret

0000000000000262 <strchr>:

char*
strchr(const char *s, char c)
{
 262:	1141                	addi	sp,sp,-16
 264:	e422                	sd	s0,8(sp)
 266:	0800                	addi	s0,sp,16
  for(; *s; s++)
 268:	00054783          	lbu	a5,0(a0)
 26c:	cb99                	beqz	a5,282 <strchr+0x20>
    if(*s == c)
 26e:	00f58763          	beq	a1,a5,27c <strchr+0x1a>
  for(; *s; s++)
 272:	0505                	addi	a0,a0,1
 274:	00054783          	lbu	a5,0(a0)
 278:	fbfd                	bnez	a5,26e <strchr+0xc>
      return (char*)s;
  return 0;
 27a:	4501                	li	a0,0
}
 27c:	6422                	ld	s0,8(sp)
 27e:	0141                	addi	sp,sp,16
 280:	8082                	ret
  return 0;
 282:	4501                	li	a0,0
 284:	bfe5                	j	27c <strchr+0x1a>

0000000000000286 <gets>:

char*
gets(char *buf, int max)
{
 286:	711d                	addi	sp,sp,-96
 288:	ec86                	sd	ra,88(sp)
 28a:	e8a2                	sd	s0,80(sp)
 28c:	e4a6                	sd	s1,72(sp)
 28e:	e0ca                	sd	s2,64(sp)
 290:	fc4e                	sd	s3,56(sp)
 292:	f852                	sd	s4,48(sp)
 294:	f456                	sd	s5,40(sp)
 296:	f05a                	sd	s6,32(sp)
 298:	ec5e                	sd	s7,24(sp)
 29a:	1080                	addi	s0,sp,96
 29c:	8baa                	mv	s7,a0
 29e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2a0:	892a                	mv	s2,a0
 2a2:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2a4:	4aa9                	li	s5,10
 2a6:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2a8:	89a6                	mv	s3,s1
 2aa:	2485                	addiw	s1,s1,1
 2ac:	0344d863          	bge	s1,s4,2dc <gets+0x56>
    cc = read(0, &c, 1);
 2b0:	4605                	li	a2,1
 2b2:	faf40593          	addi	a1,s0,-81
 2b6:	4501                	li	a0,0
 2b8:	00000097          	auipc	ra,0x0
 2bc:	19a080e7          	jalr	410(ra) # 452 <read>
    if(cc < 1)
 2c0:	00a05e63          	blez	a0,2dc <gets+0x56>
    buf[i++] = c;
 2c4:	faf44783          	lbu	a5,-81(s0)
 2c8:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2cc:	01578763          	beq	a5,s5,2da <gets+0x54>
 2d0:	0905                	addi	s2,s2,1
 2d2:	fd679be3          	bne	a5,s6,2a8 <gets+0x22>
  for(i=0; i+1 < max; ){
 2d6:	89a6                	mv	s3,s1
 2d8:	a011                	j	2dc <gets+0x56>
 2da:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2dc:	99de                	add	s3,s3,s7
 2de:	00098023          	sb	zero,0(s3)
  return buf;
}
 2e2:	855e                	mv	a0,s7
 2e4:	60e6                	ld	ra,88(sp)
 2e6:	6446                	ld	s0,80(sp)
 2e8:	64a6                	ld	s1,72(sp)
 2ea:	6906                	ld	s2,64(sp)
 2ec:	79e2                	ld	s3,56(sp)
 2ee:	7a42                	ld	s4,48(sp)
 2f0:	7aa2                	ld	s5,40(sp)
 2f2:	7b02                	ld	s6,32(sp)
 2f4:	6be2                	ld	s7,24(sp)
 2f6:	6125                	addi	sp,sp,96
 2f8:	8082                	ret

00000000000002fa <stat>:

int
stat(const char *n, struct stat *st)
{
 2fa:	1101                	addi	sp,sp,-32
 2fc:	ec06                	sd	ra,24(sp)
 2fe:	e822                	sd	s0,16(sp)
 300:	e426                	sd	s1,8(sp)
 302:	e04a                	sd	s2,0(sp)
 304:	1000                	addi	s0,sp,32
 306:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 308:	4581                	li	a1,0
 30a:	00000097          	auipc	ra,0x0
 30e:	170080e7          	jalr	368(ra) # 47a <open>
  if(fd < 0)
 312:	02054563          	bltz	a0,33c <stat+0x42>
 316:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 318:	85ca                	mv	a1,s2
 31a:	00000097          	auipc	ra,0x0
 31e:	178080e7          	jalr	376(ra) # 492 <fstat>
 322:	892a                	mv	s2,a0
  close(fd);
 324:	8526                	mv	a0,s1
 326:	00000097          	auipc	ra,0x0
 32a:	13c080e7          	jalr	316(ra) # 462 <close>
  return r;
}
 32e:	854a                	mv	a0,s2
 330:	60e2                	ld	ra,24(sp)
 332:	6442                	ld	s0,16(sp)
 334:	64a2                	ld	s1,8(sp)
 336:	6902                	ld	s2,0(sp)
 338:	6105                	addi	sp,sp,32
 33a:	8082                	ret
    return -1;
 33c:	597d                	li	s2,-1
 33e:	bfc5                	j	32e <stat+0x34>

0000000000000340 <atoi>:

int
atoi(const char *s)
{
 340:	1141                	addi	sp,sp,-16
 342:	e422                	sd	s0,8(sp)
 344:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 346:	00054683          	lbu	a3,0(a0)
 34a:	fd06879b          	addiw	a5,a3,-48
 34e:	0ff7f793          	zext.b	a5,a5
 352:	4625                	li	a2,9
 354:	02f66863          	bltu	a2,a5,384 <atoi+0x44>
 358:	872a                	mv	a4,a0
  n = 0;
 35a:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 35c:	0705                	addi	a4,a4,1
 35e:	0025179b          	slliw	a5,a0,0x2
 362:	9fa9                	addw	a5,a5,a0
 364:	0017979b          	slliw	a5,a5,0x1
 368:	9fb5                	addw	a5,a5,a3
 36a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 36e:	00074683          	lbu	a3,0(a4)
 372:	fd06879b          	addiw	a5,a3,-48
 376:	0ff7f793          	zext.b	a5,a5
 37a:	fef671e3          	bgeu	a2,a5,35c <atoi+0x1c>
  return n;
}
 37e:	6422                	ld	s0,8(sp)
 380:	0141                	addi	sp,sp,16
 382:	8082                	ret
  n = 0;
 384:	4501                	li	a0,0
 386:	bfe5                	j	37e <atoi+0x3e>

0000000000000388 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 388:	1141                	addi	sp,sp,-16
 38a:	e422                	sd	s0,8(sp)
 38c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 38e:	02b57463          	bgeu	a0,a1,3b6 <memmove+0x2e>
    while(n-- > 0)
 392:	00c05f63          	blez	a2,3b0 <memmove+0x28>
 396:	1602                	slli	a2,a2,0x20
 398:	9201                	srli	a2,a2,0x20
 39a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 39e:	872a                	mv	a4,a0
      *dst++ = *src++;
 3a0:	0585                	addi	a1,a1,1
 3a2:	0705                	addi	a4,a4,1
 3a4:	fff5c683          	lbu	a3,-1(a1)
 3a8:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3ac:	fee79ae3          	bne	a5,a4,3a0 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3b0:	6422                	ld	s0,8(sp)
 3b2:	0141                	addi	sp,sp,16
 3b4:	8082                	ret
    dst += n;
 3b6:	00c50733          	add	a4,a0,a2
    src += n;
 3ba:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 3bc:	fec05ae3          	blez	a2,3b0 <memmove+0x28>
 3c0:	fff6079b          	addiw	a5,a2,-1
 3c4:	1782                	slli	a5,a5,0x20
 3c6:	9381                	srli	a5,a5,0x20
 3c8:	fff7c793          	not	a5,a5
 3cc:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3ce:	15fd                	addi	a1,a1,-1
 3d0:	177d                	addi	a4,a4,-1
 3d2:	0005c683          	lbu	a3,0(a1)
 3d6:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3da:	fee79ae3          	bne	a5,a4,3ce <memmove+0x46>
 3de:	bfc9                	j	3b0 <memmove+0x28>

00000000000003e0 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3e0:	1141                	addi	sp,sp,-16
 3e2:	e422                	sd	s0,8(sp)
 3e4:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3e6:	ca05                	beqz	a2,416 <memcmp+0x36>
 3e8:	fff6069b          	addiw	a3,a2,-1
 3ec:	1682                	slli	a3,a3,0x20
 3ee:	9281                	srli	a3,a3,0x20
 3f0:	0685                	addi	a3,a3,1
 3f2:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3f4:	00054783          	lbu	a5,0(a0)
 3f8:	0005c703          	lbu	a4,0(a1)
 3fc:	00e79863          	bne	a5,a4,40c <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 400:	0505                	addi	a0,a0,1
    p2++;
 402:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 404:	fed518e3          	bne	a0,a3,3f4 <memcmp+0x14>
  }
  return 0;
 408:	4501                	li	a0,0
 40a:	a019                	j	410 <memcmp+0x30>
      return *p1 - *p2;
 40c:	40e7853b          	subw	a0,a5,a4
}
 410:	6422                	ld	s0,8(sp)
 412:	0141                	addi	sp,sp,16
 414:	8082                	ret
  return 0;
 416:	4501                	li	a0,0
 418:	bfe5                	j	410 <memcmp+0x30>

000000000000041a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 41a:	1141                	addi	sp,sp,-16
 41c:	e406                	sd	ra,8(sp)
 41e:	e022                	sd	s0,0(sp)
 420:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 422:	00000097          	auipc	ra,0x0
 426:	f66080e7          	jalr	-154(ra) # 388 <memmove>
}
 42a:	60a2                	ld	ra,8(sp)
 42c:	6402                	ld	s0,0(sp)
 42e:	0141                	addi	sp,sp,16
 430:	8082                	ret

0000000000000432 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 432:	4885                	li	a7,1
 ecall
 434:	00000073          	ecall
 ret
 438:	8082                	ret

000000000000043a <exit>:
.global exit
exit:
 li a7, SYS_exit
 43a:	4889                	li	a7,2
 ecall
 43c:	00000073          	ecall
 ret
 440:	8082                	ret

0000000000000442 <wait>:
.global wait
wait:
 li a7, SYS_wait
 442:	488d                	li	a7,3
 ecall
 444:	00000073          	ecall
 ret
 448:	8082                	ret

000000000000044a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 44a:	4891                	li	a7,4
 ecall
 44c:	00000073          	ecall
 ret
 450:	8082                	ret

0000000000000452 <read>:
.global read
read:
 li a7, SYS_read
 452:	4895                	li	a7,5
 ecall
 454:	00000073          	ecall
 ret
 458:	8082                	ret

000000000000045a <write>:
.global write
write:
 li a7, SYS_write
 45a:	48c1                	li	a7,16
 ecall
 45c:	00000073          	ecall
 ret
 460:	8082                	ret

0000000000000462 <close>:
.global close
close:
 li a7, SYS_close
 462:	48d5                	li	a7,21
 ecall
 464:	00000073          	ecall
 ret
 468:	8082                	ret

000000000000046a <kill>:
.global kill
kill:
 li a7, SYS_kill
 46a:	4899                	li	a7,6
 ecall
 46c:	00000073          	ecall
 ret
 470:	8082                	ret

0000000000000472 <exec>:
.global exec
exec:
 li a7, SYS_exec
 472:	489d                	li	a7,7
 ecall
 474:	00000073          	ecall
 ret
 478:	8082                	ret

000000000000047a <open>:
.global open
open:
 li a7, SYS_open
 47a:	48bd                	li	a7,15
 ecall
 47c:	00000073          	ecall
 ret
 480:	8082                	ret

0000000000000482 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 482:	48c5                	li	a7,17
 ecall
 484:	00000073          	ecall
 ret
 488:	8082                	ret

000000000000048a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 48a:	48c9                	li	a7,18
 ecall
 48c:	00000073          	ecall
 ret
 490:	8082                	ret

0000000000000492 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 492:	48a1                	li	a7,8
 ecall
 494:	00000073          	ecall
 ret
 498:	8082                	ret

000000000000049a <link>:
.global link
link:
 li a7, SYS_link
 49a:	48cd                	li	a7,19
 ecall
 49c:	00000073          	ecall
 ret
 4a0:	8082                	ret

00000000000004a2 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4a2:	48d1                	li	a7,20
 ecall
 4a4:	00000073          	ecall
 ret
 4a8:	8082                	ret

00000000000004aa <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4aa:	48a5                	li	a7,9
 ecall
 4ac:	00000073          	ecall
 ret
 4b0:	8082                	ret

00000000000004b2 <dup>:
.global dup
dup:
 li a7, SYS_dup
 4b2:	48a9                	li	a7,10
 ecall
 4b4:	00000073          	ecall
 ret
 4b8:	8082                	ret

00000000000004ba <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4ba:	48ad                	li	a7,11
 ecall
 4bc:	00000073          	ecall
 ret
 4c0:	8082                	ret

00000000000004c2 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 4c2:	48b1                	li	a7,12
 ecall
 4c4:	00000073          	ecall
 ret
 4c8:	8082                	ret

00000000000004ca <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 4ca:	48b5                	li	a7,13
 ecall
 4cc:	00000073          	ecall
 ret
 4d0:	8082                	ret

00000000000004d2 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4d2:	48b9                	li	a7,14
 ecall
 4d4:	00000073          	ecall
 ret
 4d8:	8082                	ret

00000000000004da <pstat>:
.global pstat
pstat:
 li a7, SYS_pstat
 4da:	48d9                	li	a7,22
 ecall
 4dc:	00000073          	ecall
 ret
 4e0:	8082                	ret

00000000000004e2 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4e2:	1101                	addi	sp,sp,-32
 4e4:	ec06                	sd	ra,24(sp)
 4e6:	e822                	sd	s0,16(sp)
 4e8:	1000                	addi	s0,sp,32
 4ea:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4ee:	4605                	li	a2,1
 4f0:	fef40593          	addi	a1,s0,-17
 4f4:	00000097          	auipc	ra,0x0
 4f8:	f66080e7          	jalr	-154(ra) # 45a <write>
}
 4fc:	60e2                	ld	ra,24(sp)
 4fe:	6442                	ld	s0,16(sp)
 500:	6105                	addi	sp,sp,32
 502:	8082                	ret

0000000000000504 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 504:	7139                	addi	sp,sp,-64
 506:	fc06                	sd	ra,56(sp)
 508:	f822                	sd	s0,48(sp)
 50a:	f426                	sd	s1,40(sp)
 50c:	f04a                	sd	s2,32(sp)
 50e:	ec4e                	sd	s3,24(sp)
 510:	0080                	addi	s0,sp,64
 512:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 514:	c299                	beqz	a3,51a <printint+0x16>
 516:	0805c963          	bltz	a1,5a8 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 51a:	2581                	sext.w	a1,a1
  neg = 0;
 51c:	4881                	li	a7,0
 51e:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 522:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 524:	2601                	sext.w	a2,a2
 526:	00000517          	auipc	a0,0x0
 52a:	4e250513          	addi	a0,a0,1250 # a08 <digits>
 52e:	883a                	mv	a6,a4
 530:	2705                	addiw	a4,a4,1
 532:	02c5f7bb          	remuw	a5,a1,a2
 536:	1782                	slli	a5,a5,0x20
 538:	9381                	srli	a5,a5,0x20
 53a:	97aa                	add	a5,a5,a0
 53c:	0007c783          	lbu	a5,0(a5)
 540:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 544:	0005879b          	sext.w	a5,a1
 548:	02c5d5bb          	divuw	a1,a1,a2
 54c:	0685                	addi	a3,a3,1
 54e:	fec7f0e3          	bgeu	a5,a2,52e <printint+0x2a>
  if(neg)
 552:	00088c63          	beqz	a7,56a <printint+0x66>
    buf[i++] = '-';
 556:	fd070793          	addi	a5,a4,-48
 55a:	00878733          	add	a4,a5,s0
 55e:	02d00793          	li	a5,45
 562:	fef70823          	sb	a5,-16(a4)
 566:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 56a:	02e05863          	blez	a4,59a <printint+0x96>
 56e:	fc040793          	addi	a5,s0,-64
 572:	00e78933          	add	s2,a5,a4
 576:	fff78993          	addi	s3,a5,-1
 57a:	99ba                	add	s3,s3,a4
 57c:	377d                	addiw	a4,a4,-1
 57e:	1702                	slli	a4,a4,0x20
 580:	9301                	srli	a4,a4,0x20
 582:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 586:	fff94583          	lbu	a1,-1(s2)
 58a:	8526                	mv	a0,s1
 58c:	00000097          	auipc	ra,0x0
 590:	f56080e7          	jalr	-170(ra) # 4e2 <putc>
  while(--i >= 0)
 594:	197d                	addi	s2,s2,-1
 596:	ff3918e3          	bne	s2,s3,586 <printint+0x82>
}
 59a:	70e2                	ld	ra,56(sp)
 59c:	7442                	ld	s0,48(sp)
 59e:	74a2                	ld	s1,40(sp)
 5a0:	7902                	ld	s2,32(sp)
 5a2:	69e2                	ld	s3,24(sp)
 5a4:	6121                	addi	sp,sp,64
 5a6:	8082                	ret
    x = -xx;
 5a8:	40b005bb          	negw	a1,a1
    neg = 1;
 5ac:	4885                	li	a7,1
    x = -xx;
 5ae:	bf85                	j	51e <printint+0x1a>

00000000000005b0 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5b0:	7119                	addi	sp,sp,-128
 5b2:	fc86                	sd	ra,120(sp)
 5b4:	f8a2                	sd	s0,112(sp)
 5b6:	f4a6                	sd	s1,104(sp)
 5b8:	f0ca                	sd	s2,96(sp)
 5ba:	ecce                	sd	s3,88(sp)
 5bc:	e8d2                	sd	s4,80(sp)
 5be:	e4d6                	sd	s5,72(sp)
 5c0:	e0da                	sd	s6,64(sp)
 5c2:	fc5e                	sd	s7,56(sp)
 5c4:	f862                	sd	s8,48(sp)
 5c6:	f466                	sd	s9,40(sp)
 5c8:	f06a                	sd	s10,32(sp)
 5ca:	ec6e                	sd	s11,24(sp)
 5cc:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5ce:	0005c903          	lbu	s2,0(a1)
 5d2:	18090f63          	beqz	s2,770 <vprintf+0x1c0>
 5d6:	8aaa                	mv	s5,a0
 5d8:	8b32                	mv	s6,a2
 5da:	00158493          	addi	s1,a1,1
  state = 0;
 5de:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5e0:	02500a13          	li	s4,37
 5e4:	4c55                	li	s8,21
 5e6:	00000c97          	auipc	s9,0x0
 5ea:	3cac8c93          	addi	s9,s9,970 # 9b0 <malloc+0x13c>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 5ee:	02800d93          	li	s11,40
  putc(fd, 'x');
 5f2:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5f4:	00000b97          	auipc	s7,0x0
 5f8:	414b8b93          	addi	s7,s7,1044 # a08 <digits>
 5fc:	a839                	j	61a <vprintf+0x6a>
        putc(fd, c);
 5fe:	85ca                	mv	a1,s2
 600:	8556                	mv	a0,s5
 602:	00000097          	auipc	ra,0x0
 606:	ee0080e7          	jalr	-288(ra) # 4e2 <putc>
 60a:	a019                	j	610 <vprintf+0x60>
    } else if(state == '%'){
 60c:	01498d63          	beq	s3,s4,626 <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 610:	0485                	addi	s1,s1,1
 612:	fff4c903          	lbu	s2,-1(s1)
 616:	14090d63          	beqz	s2,770 <vprintf+0x1c0>
    if(state == 0){
 61a:	fe0999e3          	bnez	s3,60c <vprintf+0x5c>
      if(c == '%'){
 61e:	ff4910e3          	bne	s2,s4,5fe <vprintf+0x4e>
        state = '%';
 622:	89d2                	mv	s3,s4
 624:	b7f5                	j	610 <vprintf+0x60>
      if(c == 'd'){
 626:	11490c63          	beq	s2,s4,73e <vprintf+0x18e>
 62a:	f9d9079b          	addiw	a5,s2,-99
 62e:	0ff7f793          	zext.b	a5,a5
 632:	10fc6e63          	bltu	s8,a5,74e <vprintf+0x19e>
 636:	f9d9079b          	addiw	a5,s2,-99
 63a:	0ff7f713          	zext.b	a4,a5
 63e:	10ec6863          	bltu	s8,a4,74e <vprintf+0x19e>
 642:	00271793          	slli	a5,a4,0x2
 646:	97e6                	add	a5,a5,s9
 648:	439c                	lw	a5,0(a5)
 64a:	97e6                	add	a5,a5,s9
 64c:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 64e:	008b0913          	addi	s2,s6,8
 652:	4685                	li	a3,1
 654:	4629                	li	a2,10
 656:	000b2583          	lw	a1,0(s6)
 65a:	8556                	mv	a0,s5
 65c:	00000097          	auipc	ra,0x0
 660:	ea8080e7          	jalr	-344(ra) # 504 <printint>
 664:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 666:	4981                	li	s3,0
 668:	b765                	j	610 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 66a:	008b0913          	addi	s2,s6,8
 66e:	4681                	li	a3,0
 670:	4629                	li	a2,10
 672:	000b2583          	lw	a1,0(s6)
 676:	8556                	mv	a0,s5
 678:	00000097          	auipc	ra,0x0
 67c:	e8c080e7          	jalr	-372(ra) # 504 <printint>
 680:	8b4a                	mv	s6,s2
      state = 0;
 682:	4981                	li	s3,0
 684:	b771                	j	610 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 686:	008b0913          	addi	s2,s6,8
 68a:	4681                	li	a3,0
 68c:	866a                	mv	a2,s10
 68e:	000b2583          	lw	a1,0(s6)
 692:	8556                	mv	a0,s5
 694:	00000097          	auipc	ra,0x0
 698:	e70080e7          	jalr	-400(ra) # 504 <printint>
 69c:	8b4a                	mv	s6,s2
      state = 0;
 69e:	4981                	li	s3,0
 6a0:	bf85                	j	610 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 6a2:	008b0793          	addi	a5,s6,8
 6a6:	f8f43423          	sd	a5,-120(s0)
 6aa:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 6ae:	03000593          	li	a1,48
 6b2:	8556                	mv	a0,s5
 6b4:	00000097          	auipc	ra,0x0
 6b8:	e2e080e7          	jalr	-466(ra) # 4e2 <putc>
  putc(fd, 'x');
 6bc:	07800593          	li	a1,120
 6c0:	8556                	mv	a0,s5
 6c2:	00000097          	auipc	ra,0x0
 6c6:	e20080e7          	jalr	-480(ra) # 4e2 <putc>
 6ca:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6cc:	03c9d793          	srli	a5,s3,0x3c
 6d0:	97de                	add	a5,a5,s7
 6d2:	0007c583          	lbu	a1,0(a5)
 6d6:	8556                	mv	a0,s5
 6d8:	00000097          	auipc	ra,0x0
 6dc:	e0a080e7          	jalr	-502(ra) # 4e2 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6e0:	0992                	slli	s3,s3,0x4
 6e2:	397d                	addiw	s2,s2,-1
 6e4:	fe0914e3          	bnez	s2,6cc <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 6e8:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 6ec:	4981                	li	s3,0
 6ee:	b70d                	j	610 <vprintf+0x60>
        s = va_arg(ap, char*);
 6f0:	008b0913          	addi	s2,s6,8
 6f4:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 6f8:	02098163          	beqz	s3,71a <vprintf+0x16a>
        while(*s != 0){
 6fc:	0009c583          	lbu	a1,0(s3)
 700:	c5ad                	beqz	a1,76a <vprintf+0x1ba>
          putc(fd, *s);
 702:	8556                	mv	a0,s5
 704:	00000097          	auipc	ra,0x0
 708:	dde080e7          	jalr	-546(ra) # 4e2 <putc>
          s++;
 70c:	0985                	addi	s3,s3,1
        while(*s != 0){
 70e:	0009c583          	lbu	a1,0(s3)
 712:	f9e5                	bnez	a1,702 <vprintf+0x152>
        s = va_arg(ap, char*);
 714:	8b4a                	mv	s6,s2
      state = 0;
 716:	4981                	li	s3,0
 718:	bde5                	j	610 <vprintf+0x60>
          s = "(null)";
 71a:	00000997          	auipc	s3,0x0
 71e:	28e98993          	addi	s3,s3,654 # 9a8 <malloc+0x134>
        while(*s != 0){
 722:	85ee                	mv	a1,s11
 724:	bff9                	j	702 <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 726:	008b0913          	addi	s2,s6,8
 72a:	000b4583          	lbu	a1,0(s6)
 72e:	8556                	mv	a0,s5
 730:	00000097          	auipc	ra,0x0
 734:	db2080e7          	jalr	-590(ra) # 4e2 <putc>
 738:	8b4a                	mv	s6,s2
      state = 0;
 73a:	4981                	li	s3,0
 73c:	bdd1                	j	610 <vprintf+0x60>
        putc(fd, c);
 73e:	85d2                	mv	a1,s4
 740:	8556                	mv	a0,s5
 742:	00000097          	auipc	ra,0x0
 746:	da0080e7          	jalr	-608(ra) # 4e2 <putc>
      state = 0;
 74a:	4981                	li	s3,0
 74c:	b5d1                	j	610 <vprintf+0x60>
        putc(fd, '%');
 74e:	85d2                	mv	a1,s4
 750:	8556                	mv	a0,s5
 752:	00000097          	auipc	ra,0x0
 756:	d90080e7          	jalr	-624(ra) # 4e2 <putc>
        putc(fd, c);
 75a:	85ca                	mv	a1,s2
 75c:	8556                	mv	a0,s5
 75e:	00000097          	auipc	ra,0x0
 762:	d84080e7          	jalr	-636(ra) # 4e2 <putc>
      state = 0;
 766:	4981                	li	s3,0
 768:	b565                	j	610 <vprintf+0x60>
        s = va_arg(ap, char*);
 76a:	8b4a                	mv	s6,s2
      state = 0;
 76c:	4981                	li	s3,0
 76e:	b54d                	j	610 <vprintf+0x60>
    }
  }
}
 770:	70e6                	ld	ra,120(sp)
 772:	7446                	ld	s0,112(sp)
 774:	74a6                	ld	s1,104(sp)
 776:	7906                	ld	s2,96(sp)
 778:	69e6                	ld	s3,88(sp)
 77a:	6a46                	ld	s4,80(sp)
 77c:	6aa6                	ld	s5,72(sp)
 77e:	6b06                	ld	s6,64(sp)
 780:	7be2                	ld	s7,56(sp)
 782:	7c42                	ld	s8,48(sp)
 784:	7ca2                	ld	s9,40(sp)
 786:	7d02                	ld	s10,32(sp)
 788:	6de2                	ld	s11,24(sp)
 78a:	6109                	addi	sp,sp,128
 78c:	8082                	ret

000000000000078e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 78e:	715d                	addi	sp,sp,-80
 790:	ec06                	sd	ra,24(sp)
 792:	e822                	sd	s0,16(sp)
 794:	1000                	addi	s0,sp,32
 796:	e010                	sd	a2,0(s0)
 798:	e414                	sd	a3,8(s0)
 79a:	e818                	sd	a4,16(s0)
 79c:	ec1c                	sd	a5,24(s0)
 79e:	03043023          	sd	a6,32(s0)
 7a2:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7a6:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7aa:	8622                	mv	a2,s0
 7ac:	00000097          	auipc	ra,0x0
 7b0:	e04080e7          	jalr	-508(ra) # 5b0 <vprintf>
}
 7b4:	60e2                	ld	ra,24(sp)
 7b6:	6442                	ld	s0,16(sp)
 7b8:	6161                	addi	sp,sp,80
 7ba:	8082                	ret

00000000000007bc <printf>:

void
printf(const char *fmt, ...)
{
 7bc:	711d                	addi	sp,sp,-96
 7be:	ec06                	sd	ra,24(sp)
 7c0:	e822                	sd	s0,16(sp)
 7c2:	1000                	addi	s0,sp,32
 7c4:	e40c                	sd	a1,8(s0)
 7c6:	e810                	sd	a2,16(s0)
 7c8:	ec14                	sd	a3,24(s0)
 7ca:	f018                	sd	a4,32(s0)
 7cc:	f41c                	sd	a5,40(s0)
 7ce:	03043823          	sd	a6,48(s0)
 7d2:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7d6:	00840613          	addi	a2,s0,8
 7da:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7de:	85aa                	mv	a1,a0
 7e0:	4505                	li	a0,1
 7e2:	00000097          	auipc	ra,0x0
 7e6:	dce080e7          	jalr	-562(ra) # 5b0 <vprintf>
}
 7ea:	60e2                	ld	ra,24(sp)
 7ec:	6442                	ld	s0,16(sp)
 7ee:	6125                	addi	sp,sp,96
 7f0:	8082                	ret

00000000000007f2 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7f2:	1141                	addi	sp,sp,-16
 7f4:	e422                	sd	s0,8(sp)
 7f6:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7f8:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7fc:	00001797          	auipc	a5,0x1
 800:	8147b783          	ld	a5,-2028(a5) # 1010 <freep>
 804:	a02d                	j	82e <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 806:	4618                	lw	a4,8(a2)
 808:	9f2d                	addw	a4,a4,a1
 80a:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 80e:	6398                	ld	a4,0(a5)
 810:	6310                	ld	a2,0(a4)
 812:	a83d                	j	850 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 814:	ff852703          	lw	a4,-8(a0)
 818:	9f31                	addw	a4,a4,a2
 81a:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 81c:	ff053683          	ld	a3,-16(a0)
 820:	a091                	j	864 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 822:	6398                	ld	a4,0(a5)
 824:	00e7e463          	bltu	a5,a4,82c <free+0x3a>
 828:	00e6ea63          	bltu	a3,a4,83c <free+0x4a>
{
 82c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 82e:	fed7fae3          	bgeu	a5,a3,822 <free+0x30>
 832:	6398                	ld	a4,0(a5)
 834:	00e6e463          	bltu	a3,a4,83c <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 838:	fee7eae3          	bltu	a5,a4,82c <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 83c:	ff852583          	lw	a1,-8(a0)
 840:	6390                	ld	a2,0(a5)
 842:	02059813          	slli	a6,a1,0x20
 846:	01c85713          	srli	a4,a6,0x1c
 84a:	9736                	add	a4,a4,a3
 84c:	fae60de3          	beq	a2,a4,806 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 850:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 854:	4790                	lw	a2,8(a5)
 856:	02061593          	slli	a1,a2,0x20
 85a:	01c5d713          	srli	a4,a1,0x1c
 85e:	973e                	add	a4,a4,a5
 860:	fae68ae3          	beq	a3,a4,814 <free+0x22>
    p->s.ptr = bp->s.ptr;
 864:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 866:	00000717          	auipc	a4,0x0
 86a:	7af73523          	sd	a5,1962(a4) # 1010 <freep>
}
 86e:	6422                	ld	s0,8(sp)
 870:	0141                	addi	sp,sp,16
 872:	8082                	ret

0000000000000874 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 874:	7139                	addi	sp,sp,-64
 876:	fc06                	sd	ra,56(sp)
 878:	f822                	sd	s0,48(sp)
 87a:	f426                	sd	s1,40(sp)
 87c:	f04a                	sd	s2,32(sp)
 87e:	ec4e                	sd	s3,24(sp)
 880:	e852                	sd	s4,16(sp)
 882:	e456                	sd	s5,8(sp)
 884:	e05a                	sd	s6,0(sp)
 886:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 888:	02051493          	slli	s1,a0,0x20
 88c:	9081                	srli	s1,s1,0x20
 88e:	04bd                	addi	s1,s1,15
 890:	8091                	srli	s1,s1,0x4
 892:	0014899b          	addiw	s3,s1,1
 896:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 898:	00000517          	auipc	a0,0x0
 89c:	77853503          	ld	a0,1912(a0) # 1010 <freep>
 8a0:	c515                	beqz	a0,8cc <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8a2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8a4:	4798                	lw	a4,8(a5)
 8a6:	02977f63          	bgeu	a4,s1,8e4 <malloc+0x70>
 8aa:	8a4e                	mv	s4,s3
 8ac:	0009871b          	sext.w	a4,s3
 8b0:	6685                	lui	a3,0x1
 8b2:	00d77363          	bgeu	a4,a3,8b8 <malloc+0x44>
 8b6:	6a05                	lui	s4,0x1
 8b8:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8bc:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8c0:	00000917          	auipc	s2,0x0
 8c4:	75090913          	addi	s2,s2,1872 # 1010 <freep>
  if(p == (char*)-1)
 8c8:	5afd                	li	s5,-1
 8ca:	a895                	j	93e <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 8cc:	00000797          	auipc	a5,0x0
 8d0:	7f478793          	addi	a5,a5,2036 # 10c0 <base>
 8d4:	00000717          	auipc	a4,0x0
 8d8:	72f73e23          	sd	a5,1852(a4) # 1010 <freep>
 8dc:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8de:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8e2:	b7e1                	j	8aa <malloc+0x36>
      if(p->s.size == nunits)
 8e4:	02e48c63          	beq	s1,a4,91c <malloc+0xa8>
        p->s.size -= nunits;
 8e8:	4137073b          	subw	a4,a4,s3
 8ec:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8ee:	02071693          	slli	a3,a4,0x20
 8f2:	01c6d713          	srli	a4,a3,0x1c
 8f6:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8f8:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8fc:	00000717          	auipc	a4,0x0
 900:	70a73a23          	sd	a0,1812(a4) # 1010 <freep>
      return (void*)(p + 1);
 904:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 908:	70e2                	ld	ra,56(sp)
 90a:	7442                	ld	s0,48(sp)
 90c:	74a2                	ld	s1,40(sp)
 90e:	7902                	ld	s2,32(sp)
 910:	69e2                	ld	s3,24(sp)
 912:	6a42                	ld	s4,16(sp)
 914:	6aa2                	ld	s5,8(sp)
 916:	6b02                	ld	s6,0(sp)
 918:	6121                	addi	sp,sp,64
 91a:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 91c:	6398                	ld	a4,0(a5)
 91e:	e118                	sd	a4,0(a0)
 920:	bff1                	j	8fc <malloc+0x88>
  hp->s.size = nu;
 922:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 926:	0541                	addi	a0,a0,16
 928:	00000097          	auipc	ra,0x0
 92c:	eca080e7          	jalr	-310(ra) # 7f2 <free>
  return freep;
 930:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 934:	d971                	beqz	a0,908 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 936:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 938:	4798                	lw	a4,8(a5)
 93a:	fa9775e3          	bgeu	a4,s1,8e4 <malloc+0x70>
    if(p == freep)
 93e:	00093703          	ld	a4,0(s2)
 942:	853e                	mv	a0,a5
 944:	fef719e3          	bne	a4,a5,936 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 948:	8552                	mv	a0,s4
 94a:	00000097          	auipc	ra,0x0
 94e:	b78080e7          	jalr	-1160(ra) # 4c2 <sbrk>
  if(p == (char*)-1)
 952:	fd5518e3          	bne	a0,s5,922 <malloc+0xae>
        return 0;
 956:	4501                	li	a0,0
 958:	bf45                	j	908 <malloc+0x94>


bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c020b2b7          	lui	t0,0xc020b
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	037a                	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000a:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc020000e:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200012:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200016:	137e                	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc0200018:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc020001c:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200020:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200024:	c020b137          	lui	sp,0xc020b

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200028:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc020002c:	03228293          	addi	t0,t0,50 # ffffffffc0200032 <kern_init>
    jr t0
ffffffffc0200030:	8282                	jr	t0

ffffffffc0200032 <kern_init>:
void grade_backtrace(void);

int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	00093517          	auipc	a0,0x93
ffffffffc0200036:	a7650513          	addi	a0,a0,-1418 # ffffffffc0292aa8 <buf>
ffffffffc020003a:	0009e617          	auipc	a2,0x9e
ffffffffc020003e:	fce60613          	addi	a2,a2,-50 # ffffffffc029e008 <end>
kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16 # ffffffffc020aff0 <bootstack+0x1ff0>
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	7d6060ef          	jal	ffffffffc0206820 <memset>
    cons_init();                // init the console
ffffffffc020004e:	524000ef          	jal	ffffffffc0200572 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200052:	00006597          	auipc	a1,0x6
ffffffffc0200056:	7fe58593          	addi	a1,a1,2046 # ffffffffc0206850 <etext+0x6>
ffffffffc020005a:	00007517          	auipc	a0,0x7
ffffffffc020005e:	81650513          	addi	a0,a0,-2026 # ffffffffc0206870 <etext+0x26>
ffffffffc0200062:	11e000ef          	jal	ffffffffc0200180 <cprintf>

    print_kerninfo();
ffffffffc0200066:	1ae000ef          	jal	ffffffffc0200214 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006a:	261020ef          	jal	ffffffffc0202aca <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc020006e:	5d8000ef          	jal	ffffffffc0200646 <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200072:	5d6000ef          	jal	ffffffffc0200648 <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc0200076:	70c040ef          	jal	ffffffffc0204782 <vmm_init>
    proc_init();                // init process table
ffffffffc020007a:	6ef050ef          	jal	ffffffffc0205f68 <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc020007e:	566000ef          	jal	ffffffffc02005e4 <ide_init>
    swap_init();                // init swap
ffffffffc0200082:	6c0030ef          	jal	ffffffffc0203742 <swap_init>

    clock_init();               // init clock interrupt
ffffffffc0200086:	49a000ef          	jal	ffffffffc0200520 <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008a:	5b0000ef          	jal	ffffffffc020063a <intr_enable>
    
    cpu_idle();                 // run idle process
ffffffffc020008e:	074060ef          	jal	ffffffffc0206102 <cpu_idle>

ffffffffc0200092 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0200092:	715d                	addi	sp,sp,-80
ffffffffc0200094:	e486                	sd	ra,72(sp)
ffffffffc0200096:	e0a2                	sd	s0,64(sp)
ffffffffc0200098:	fc26                	sd	s1,56(sp)
ffffffffc020009a:	f84a                	sd	s2,48(sp)
ffffffffc020009c:	f44e                	sd	s3,40(sp)
ffffffffc020009e:	f052                	sd	s4,32(sp)
ffffffffc02000a0:	ec56                	sd	s5,24(sp)
ffffffffc02000a2:	e85a                	sd	s6,16(sp)
    if (prompt != NULL) {
ffffffffc02000a4:	c901                	beqz	a0,ffffffffc02000b4 <readline+0x22>
ffffffffc02000a6:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc02000a8:	00006517          	auipc	a0,0x6
ffffffffc02000ac:	7d050513          	addi	a0,a0,2000 # ffffffffc0206878 <etext+0x2e>
ffffffffc02000b0:	0d0000ef          	jal	ffffffffc0200180 <cprintf>
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
            cputchar(c);
            buf[i ++] = c;
ffffffffc02000b4:	4401                	li	s0,0
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000b6:	44fd                	li	s1,31
        }
        else if (c == '\b' && i > 0) {
ffffffffc02000b8:	4921                	li	s2,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02000ba:	4a29                	li	s4,10
ffffffffc02000bc:	4ab5                	li	s5,13
            buf[i ++] = c;
ffffffffc02000be:	00093b17          	auipc	s6,0x93
ffffffffc02000c2:	9eab0b13          	addi	s6,s6,-1558 # ffffffffc0292aa8 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000c6:	3fe00993          	li	s3,1022
        c = getchar();
ffffffffc02000ca:	13a000ef          	jal	ffffffffc0200204 <getchar>
        if (c < 0) {
ffffffffc02000ce:	00054a63          	bltz	a0,ffffffffc02000e2 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000d2:	00a4da63          	bge	s1,a0,ffffffffc02000e6 <readline+0x54>
ffffffffc02000d6:	0289d263          	bge	s3,s0,ffffffffc02000fa <readline+0x68>
        c = getchar();
ffffffffc02000da:	12a000ef          	jal	ffffffffc0200204 <getchar>
        if (c < 0) {
ffffffffc02000de:	fe055ae3          	bgez	a0,ffffffffc02000d2 <readline+0x40>
            return NULL;
ffffffffc02000e2:	4501                	li	a0,0
ffffffffc02000e4:	a091                	j	ffffffffc0200128 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc02000e6:	03251463          	bne	a0,s2,ffffffffc020010e <readline+0x7c>
ffffffffc02000ea:	04804963          	bgtz	s0,ffffffffc020013c <readline+0xaa>
        c = getchar();
ffffffffc02000ee:	116000ef          	jal	ffffffffc0200204 <getchar>
        if (c < 0) {
ffffffffc02000f2:	fe0548e3          	bltz	a0,ffffffffc02000e2 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000f6:	fea4d8e3          	bge	s1,a0,ffffffffc02000e6 <readline+0x54>
            cputchar(c);
ffffffffc02000fa:	e42a                	sd	a0,8(sp)
ffffffffc02000fc:	0b8000ef          	jal	ffffffffc02001b4 <cputchar>
            buf[i ++] = c;
ffffffffc0200100:	6522                	ld	a0,8(sp)
ffffffffc0200102:	008b07b3          	add	a5,s6,s0
ffffffffc0200106:	2405                	addiw	s0,s0,1
ffffffffc0200108:	00a78023          	sb	a0,0(a5)
ffffffffc020010c:	bf7d                	j	ffffffffc02000ca <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc020010e:	01450463          	beq	a0,s4,ffffffffc0200116 <readline+0x84>
ffffffffc0200112:	fb551ce3          	bne	a0,s5,ffffffffc02000ca <readline+0x38>
            cputchar(c);
ffffffffc0200116:	09e000ef          	jal	ffffffffc02001b4 <cputchar>
            buf[i] = '\0';
ffffffffc020011a:	00093517          	auipc	a0,0x93
ffffffffc020011e:	98e50513          	addi	a0,a0,-1650 # ffffffffc0292aa8 <buf>
ffffffffc0200122:	942a                	add	s0,s0,a0
ffffffffc0200124:	00040023          	sb	zero,0(s0)
            return buf;
        }
    }
}
ffffffffc0200128:	60a6                	ld	ra,72(sp)
ffffffffc020012a:	6406                	ld	s0,64(sp)
ffffffffc020012c:	74e2                	ld	s1,56(sp)
ffffffffc020012e:	7942                	ld	s2,48(sp)
ffffffffc0200130:	79a2                	ld	s3,40(sp)
ffffffffc0200132:	7a02                	ld	s4,32(sp)
ffffffffc0200134:	6ae2                	ld	s5,24(sp)
ffffffffc0200136:	6b42                	ld	s6,16(sp)
ffffffffc0200138:	6161                	addi	sp,sp,80
ffffffffc020013a:	8082                	ret
            cputchar(c);
ffffffffc020013c:	4521                	li	a0,8
ffffffffc020013e:	076000ef          	jal	ffffffffc02001b4 <cputchar>
            i --;
ffffffffc0200142:	347d                	addiw	s0,s0,-1
ffffffffc0200144:	b759                	j	ffffffffc02000ca <readline+0x38>

ffffffffc0200146 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200146:	1141                	addi	sp,sp,-16
ffffffffc0200148:	e022                	sd	s0,0(sp)
ffffffffc020014a:	e406                	sd	ra,8(sp)
ffffffffc020014c:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020014e:	426000ef          	jal	ffffffffc0200574 <cons_putc>
    (*cnt) ++;
ffffffffc0200152:	401c                	lw	a5,0(s0)
}
ffffffffc0200154:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200156:	2785                	addiw	a5,a5,1
ffffffffc0200158:	c01c                	sw	a5,0(s0)
}
ffffffffc020015a:	6402                	ld	s0,0(sp)
ffffffffc020015c:	0141                	addi	sp,sp,16
ffffffffc020015e:	8082                	ret

ffffffffc0200160 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200160:	1101                	addi	sp,sp,-32
ffffffffc0200162:	862a                	mv	a2,a0
ffffffffc0200164:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200166:	00000517          	auipc	a0,0x0
ffffffffc020016a:	fe050513          	addi	a0,a0,-32 # ffffffffc0200146 <cputch>
ffffffffc020016e:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200170:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc0200172:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200174:	29c060ef          	jal	ffffffffc0206410 <vprintfmt>
    return cnt;
}
ffffffffc0200178:	60e2                	ld	ra,24(sp)
ffffffffc020017a:	4532                	lw	a0,12(sp)
ffffffffc020017c:	6105                	addi	sp,sp,32
ffffffffc020017e:	8082                	ret

ffffffffc0200180 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc0200180:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc0200182:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
ffffffffc0200186:	f42e                	sd	a1,40(sp)
ffffffffc0200188:	f832                	sd	a2,48(sp)
ffffffffc020018a:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc020018c:	862a                	mv	a2,a0
ffffffffc020018e:	004c                	addi	a1,sp,4
ffffffffc0200190:	00000517          	auipc	a0,0x0
ffffffffc0200194:	fb650513          	addi	a0,a0,-74 # ffffffffc0200146 <cputch>
ffffffffc0200198:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc020019a:	ec06                	sd	ra,24(sp)
ffffffffc020019c:	e0ba                	sd	a4,64(sp)
ffffffffc020019e:	e4be                	sd	a5,72(sp)
ffffffffc02001a0:	e8c2                	sd	a6,80(sp)
ffffffffc02001a2:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02001a4:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02001a6:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02001a8:	268060ef          	jal	ffffffffc0206410 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02001ac:	60e2                	ld	ra,24(sp)
ffffffffc02001ae:	4512                	lw	a0,4(sp)
ffffffffc02001b0:	6125                	addi	sp,sp,96
ffffffffc02001b2:	8082                	ret

ffffffffc02001b4 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02001b4:	a6c1                	j	ffffffffc0200574 <cons_putc>

ffffffffc02001b6 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02001b6:	1101                	addi	sp,sp,-32
ffffffffc02001b8:	ec06                	sd	ra,24(sp)
ffffffffc02001ba:	e822                	sd	s0,16(sp)
ffffffffc02001bc:	87aa                	mv	a5,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02001be:	00054503          	lbu	a0,0(a0)
ffffffffc02001c2:	c905                	beqz	a0,ffffffffc02001f2 <cputs+0x3c>
ffffffffc02001c4:	e426                	sd	s1,8(sp)
ffffffffc02001c6:	00178493          	addi	s1,a5,1
ffffffffc02001ca:	8426                	mv	s0,s1
    cons_putc(c);
ffffffffc02001cc:	3a8000ef          	jal	ffffffffc0200574 <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc02001d0:	00044503          	lbu	a0,0(s0)
ffffffffc02001d4:	87a2                	mv	a5,s0
ffffffffc02001d6:	0405                	addi	s0,s0,1
ffffffffc02001d8:	f975                	bnez	a0,ffffffffc02001cc <cputs+0x16>
    (*cnt) ++;
ffffffffc02001da:	9f85                	subw	a5,a5,s1
    cons_putc(c);
ffffffffc02001dc:	4529                	li	a0,10
    (*cnt) ++;
ffffffffc02001de:	0027841b          	addiw	s0,a5,2
ffffffffc02001e2:	64a2                	ld	s1,8(sp)
    cons_putc(c);
ffffffffc02001e4:	390000ef          	jal	ffffffffc0200574 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc02001e8:	60e2                	ld	ra,24(sp)
ffffffffc02001ea:	8522                	mv	a0,s0
ffffffffc02001ec:	6442                	ld	s0,16(sp)
ffffffffc02001ee:	6105                	addi	sp,sp,32
ffffffffc02001f0:	8082                	ret
    cons_putc(c);
ffffffffc02001f2:	4529                	li	a0,10
ffffffffc02001f4:	380000ef          	jal	ffffffffc0200574 <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc02001f8:	4405                	li	s0,1
}
ffffffffc02001fa:	60e2                	ld	ra,24(sp)
ffffffffc02001fc:	8522                	mv	a0,s0
ffffffffc02001fe:	6442                	ld	s0,16(sp)
ffffffffc0200200:	6105                	addi	sp,sp,32
ffffffffc0200202:	8082                	ret

ffffffffc0200204 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc0200204:	1141                	addi	sp,sp,-16
ffffffffc0200206:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc0200208:	3a0000ef          	jal	ffffffffc02005a8 <cons_getc>
ffffffffc020020c:	dd75                	beqz	a0,ffffffffc0200208 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc020020e:	60a2                	ld	ra,8(sp)
ffffffffc0200210:	0141                	addi	sp,sp,16
ffffffffc0200212:	8082                	ret

ffffffffc0200214 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200214:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200216:	00006517          	auipc	a0,0x6
ffffffffc020021a:	66a50513          	addi	a0,a0,1642 # ffffffffc0206880 <etext+0x36>
void print_kerninfo(void) {
ffffffffc020021e:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200220:	f61ff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200224:	00000597          	auipc	a1,0x0
ffffffffc0200228:	e0e58593          	addi	a1,a1,-498 # ffffffffc0200032 <kern_init>
ffffffffc020022c:	00006517          	auipc	a0,0x6
ffffffffc0200230:	67450513          	addi	a0,a0,1652 # ffffffffc02068a0 <etext+0x56>
ffffffffc0200234:	f4dff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc0200238:	00006597          	auipc	a1,0x6
ffffffffc020023c:	61258593          	addi	a1,a1,1554 # ffffffffc020684a <etext>
ffffffffc0200240:	00006517          	auipc	a0,0x6
ffffffffc0200244:	68050513          	addi	a0,a0,1664 # ffffffffc02068c0 <etext+0x76>
ffffffffc0200248:	f39ff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020024c:	00093597          	auipc	a1,0x93
ffffffffc0200250:	85c58593          	addi	a1,a1,-1956 # ffffffffc0292aa8 <buf>
ffffffffc0200254:	00006517          	auipc	a0,0x6
ffffffffc0200258:	68c50513          	addi	a0,a0,1676 # ffffffffc02068e0 <etext+0x96>
ffffffffc020025c:	f25ff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200260:	0009e597          	auipc	a1,0x9e
ffffffffc0200264:	da858593          	addi	a1,a1,-600 # ffffffffc029e008 <end>
ffffffffc0200268:	00006517          	auipc	a0,0x6
ffffffffc020026c:	69850513          	addi	a0,a0,1688 # ffffffffc0206900 <etext+0xb6>
ffffffffc0200270:	f11ff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200274:	0009e797          	auipc	a5,0x9e
ffffffffc0200278:	19378793          	addi	a5,a5,403 # ffffffffc029e407 <end+0x3ff>
ffffffffc020027c:	00000717          	auipc	a4,0x0
ffffffffc0200280:	db670713          	addi	a4,a4,-586 # ffffffffc0200032 <kern_init>
ffffffffc0200284:	8f99                	sub	a5,a5,a4
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200286:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020028a:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020028c:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200290:	95be                	add	a1,a1,a5
ffffffffc0200292:	85a9                	srai	a1,a1,0xa
ffffffffc0200294:	00006517          	auipc	a0,0x6
ffffffffc0200298:	68c50513          	addi	a0,a0,1676 # ffffffffc0206920 <etext+0xd6>
}
ffffffffc020029c:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020029e:	b5cd                	j	ffffffffc0200180 <cprintf>

ffffffffc02002a0 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02002a0:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc02002a2:	00006617          	auipc	a2,0x6
ffffffffc02002a6:	6ae60613          	addi	a2,a2,1710 # ffffffffc0206950 <etext+0x106>
ffffffffc02002aa:	04d00593          	li	a1,77
ffffffffc02002ae:	00006517          	auipc	a0,0x6
ffffffffc02002b2:	6ba50513          	addi	a0,a0,1722 # ffffffffc0206968 <etext+0x11e>
void print_stackframe(void) {
ffffffffc02002b6:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02002b8:	1bc000ef          	jal	ffffffffc0200474 <__panic>

ffffffffc02002bc <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002bc:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002be:	00006617          	auipc	a2,0x6
ffffffffc02002c2:	6c260613          	addi	a2,a2,1730 # ffffffffc0206980 <etext+0x136>
ffffffffc02002c6:	00006597          	auipc	a1,0x6
ffffffffc02002ca:	6da58593          	addi	a1,a1,1754 # ffffffffc02069a0 <etext+0x156>
ffffffffc02002ce:	00006517          	auipc	a0,0x6
ffffffffc02002d2:	6da50513          	addi	a0,a0,1754 # ffffffffc02069a8 <etext+0x15e>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002d6:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002d8:	ea9ff0ef          	jal	ffffffffc0200180 <cprintf>
ffffffffc02002dc:	00006617          	auipc	a2,0x6
ffffffffc02002e0:	6dc60613          	addi	a2,a2,1756 # ffffffffc02069b8 <etext+0x16e>
ffffffffc02002e4:	00006597          	auipc	a1,0x6
ffffffffc02002e8:	6fc58593          	addi	a1,a1,1788 # ffffffffc02069e0 <etext+0x196>
ffffffffc02002ec:	00006517          	auipc	a0,0x6
ffffffffc02002f0:	6bc50513          	addi	a0,a0,1724 # ffffffffc02069a8 <etext+0x15e>
ffffffffc02002f4:	e8dff0ef          	jal	ffffffffc0200180 <cprintf>
ffffffffc02002f8:	00006617          	auipc	a2,0x6
ffffffffc02002fc:	6f860613          	addi	a2,a2,1784 # ffffffffc02069f0 <etext+0x1a6>
ffffffffc0200300:	00006597          	auipc	a1,0x6
ffffffffc0200304:	71058593          	addi	a1,a1,1808 # ffffffffc0206a10 <etext+0x1c6>
ffffffffc0200308:	00006517          	auipc	a0,0x6
ffffffffc020030c:	6a050513          	addi	a0,a0,1696 # ffffffffc02069a8 <etext+0x15e>
ffffffffc0200310:	e71ff0ef          	jal	ffffffffc0200180 <cprintf>
    }
    return 0;
}
ffffffffc0200314:	60a2                	ld	ra,8(sp)
ffffffffc0200316:	4501                	li	a0,0
ffffffffc0200318:	0141                	addi	sp,sp,16
ffffffffc020031a:	8082                	ret

ffffffffc020031c <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc020031c:	1141                	addi	sp,sp,-16
ffffffffc020031e:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200320:	ef5ff0ef          	jal	ffffffffc0200214 <print_kerninfo>
    return 0;
}
ffffffffc0200324:	60a2                	ld	ra,8(sp)
ffffffffc0200326:	4501                	li	a0,0
ffffffffc0200328:	0141                	addi	sp,sp,16
ffffffffc020032a:	8082                	ret

ffffffffc020032c <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc020032c:	1141                	addi	sp,sp,-16
ffffffffc020032e:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200330:	f71ff0ef          	jal	ffffffffc02002a0 <print_stackframe>
    return 0;
}
ffffffffc0200334:	60a2                	ld	ra,8(sp)
ffffffffc0200336:	4501                	li	a0,0
ffffffffc0200338:	0141                	addi	sp,sp,16
ffffffffc020033a:	8082                	ret

ffffffffc020033c <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc020033c:	7115                	addi	sp,sp,-224
ffffffffc020033e:	f15a                	sd	s6,160(sp)
ffffffffc0200340:	8b2a                	mv	s6,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200342:	00006517          	auipc	a0,0x6
ffffffffc0200346:	6de50513          	addi	a0,a0,1758 # ffffffffc0206a20 <etext+0x1d6>
kmonitor(struct trapframe *tf) {
ffffffffc020034a:	ed86                	sd	ra,216(sp)
ffffffffc020034c:	e9a2                	sd	s0,208(sp)
ffffffffc020034e:	e5a6                	sd	s1,200(sp)
ffffffffc0200350:	e1ca                	sd	s2,192(sp)
ffffffffc0200352:	fd4e                	sd	s3,184(sp)
ffffffffc0200354:	f952                	sd	s4,176(sp)
ffffffffc0200356:	f556                	sd	s5,168(sp)
ffffffffc0200358:	ed5e                	sd	s7,152(sp)
ffffffffc020035a:	e962                	sd	s8,144(sp)
ffffffffc020035c:	e566                	sd	s9,136(sp)
ffffffffc020035e:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200360:	e21ff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200364:	00006517          	auipc	a0,0x6
ffffffffc0200368:	6e450513          	addi	a0,a0,1764 # ffffffffc0206a48 <etext+0x1fe>
ffffffffc020036c:	e15ff0ef          	jal	ffffffffc0200180 <cprintf>
    if (tf != NULL) {
ffffffffc0200370:	000b0563          	beqz	s6,ffffffffc020037a <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200374:	855a                	mv	a0,s6
ffffffffc0200376:	4ba000ef          	jal	ffffffffc0200830 <print_trapframe>
ffffffffc020037a:	00008c17          	auipc	s8,0x8
ffffffffc020037e:	7c6c0c13          	addi	s8,s8,1990 # ffffffffc0208b40 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200382:	00006917          	auipc	s2,0x6
ffffffffc0200386:	6ee90913          	addi	s2,s2,1774 # ffffffffc0206a70 <etext+0x226>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020038a:	00006497          	auipc	s1,0x6
ffffffffc020038e:	6ee48493          	addi	s1,s1,1774 # ffffffffc0206a78 <etext+0x22e>
        if (argc == MAXARGS - 1) {
ffffffffc0200392:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200394:	00006a97          	auipc	s5,0x6
ffffffffc0200398:	6eca8a93          	addi	s5,s5,1772 # ffffffffc0206a80 <etext+0x236>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020039c:	4a0d                	li	s4,3
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020039e:	00006b97          	auipc	s7,0x6
ffffffffc02003a2:	702b8b93          	addi	s7,s7,1794 # ffffffffc0206aa0 <etext+0x256>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02003a6:	854a                	mv	a0,s2
ffffffffc02003a8:	cebff0ef          	jal	ffffffffc0200092 <readline>
ffffffffc02003ac:	842a                	mv	s0,a0
ffffffffc02003ae:	dd65                	beqz	a0,ffffffffc02003a6 <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003b0:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02003b4:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003b6:	e59d                	bnez	a1,ffffffffc02003e4 <kmonitor+0xa8>
    if (argc == 0) {
ffffffffc02003b8:	fe0c87e3          	beqz	s9,ffffffffc02003a6 <kmonitor+0x6a>
ffffffffc02003bc:	00008d17          	auipc	s10,0x8
ffffffffc02003c0:	784d0d13          	addi	s10,s10,1924 # ffffffffc0208b40 <commands>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003c4:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003c6:	6582                	ld	a1,0(sp)
ffffffffc02003c8:	000d3503          	ld	a0,0(s10)
ffffffffc02003cc:	406060ef          	jal	ffffffffc02067d2 <strcmp>
ffffffffc02003d0:	c53d                	beqz	a0,ffffffffc020043e <kmonitor+0x102>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003d2:	2405                	addiw	s0,s0,1
ffffffffc02003d4:	0d61                	addi	s10,s10,24
ffffffffc02003d6:	ff4418e3          	bne	s0,s4,ffffffffc02003c6 <kmonitor+0x8a>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc02003da:	6582                	ld	a1,0(sp)
ffffffffc02003dc:	855e                	mv	a0,s7
ffffffffc02003de:	da3ff0ef          	jal	ffffffffc0200180 <cprintf>
    return 0;
ffffffffc02003e2:	b7d1                	j	ffffffffc02003a6 <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003e4:	8526                	mv	a0,s1
ffffffffc02003e6:	424060ef          	jal	ffffffffc020680a <strchr>
ffffffffc02003ea:	c901                	beqz	a0,ffffffffc02003fa <kmonitor+0xbe>
ffffffffc02003ec:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc02003f0:	00040023          	sb	zero,0(s0)
ffffffffc02003f4:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003f6:	d1e9                	beqz	a1,ffffffffc02003b8 <kmonitor+0x7c>
ffffffffc02003f8:	b7f5                	j	ffffffffc02003e4 <kmonitor+0xa8>
        if (*buf == '\0') {
ffffffffc02003fa:	00044783          	lbu	a5,0(s0)
ffffffffc02003fe:	dfcd                	beqz	a5,ffffffffc02003b8 <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc0200400:	033c8a63          	beq	s9,s3,ffffffffc0200434 <kmonitor+0xf8>
        argv[argc ++] = buf;
ffffffffc0200404:	003c9793          	slli	a5,s9,0x3
ffffffffc0200408:	08078793          	addi	a5,a5,128
ffffffffc020040c:	978a                	add	a5,a5,sp
ffffffffc020040e:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200412:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200416:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200418:	e591                	bnez	a1,ffffffffc0200424 <kmonitor+0xe8>
ffffffffc020041a:	bf79                	j	ffffffffc02003b8 <kmonitor+0x7c>
ffffffffc020041c:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc0200420:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200422:	d9d9                	beqz	a1,ffffffffc02003b8 <kmonitor+0x7c>
ffffffffc0200424:	8526                	mv	a0,s1
ffffffffc0200426:	3e4060ef          	jal	ffffffffc020680a <strchr>
ffffffffc020042a:	d96d                	beqz	a0,ffffffffc020041c <kmonitor+0xe0>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020042c:	00044583          	lbu	a1,0(s0)
ffffffffc0200430:	d5c1                	beqz	a1,ffffffffc02003b8 <kmonitor+0x7c>
ffffffffc0200432:	bf4d                	j	ffffffffc02003e4 <kmonitor+0xa8>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200434:	45c1                	li	a1,16
ffffffffc0200436:	8556                	mv	a0,s5
ffffffffc0200438:	d49ff0ef          	jal	ffffffffc0200180 <cprintf>
ffffffffc020043c:	b7e1                	j	ffffffffc0200404 <kmonitor+0xc8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc020043e:	00141793          	slli	a5,s0,0x1
ffffffffc0200442:	97a2                	add	a5,a5,s0
ffffffffc0200444:	078e                	slli	a5,a5,0x3
ffffffffc0200446:	97e2                	add	a5,a5,s8
ffffffffc0200448:	6b9c                	ld	a5,16(a5)
ffffffffc020044a:	865a                	mv	a2,s6
ffffffffc020044c:	002c                	addi	a1,sp,8
ffffffffc020044e:	fffc851b          	addiw	a0,s9,-1
ffffffffc0200452:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200454:	f40559e3          	bgez	a0,ffffffffc02003a6 <kmonitor+0x6a>
}
ffffffffc0200458:	60ee                	ld	ra,216(sp)
ffffffffc020045a:	644e                	ld	s0,208(sp)
ffffffffc020045c:	64ae                	ld	s1,200(sp)
ffffffffc020045e:	690e                	ld	s2,192(sp)
ffffffffc0200460:	79ea                	ld	s3,184(sp)
ffffffffc0200462:	7a4a                	ld	s4,176(sp)
ffffffffc0200464:	7aaa                	ld	s5,168(sp)
ffffffffc0200466:	7b0a                	ld	s6,160(sp)
ffffffffc0200468:	6bea                	ld	s7,152(sp)
ffffffffc020046a:	6c4a                	ld	s8,144(sp)
ffffffffc020046c:	6caa                	ld	s9,136(sp)
ffffffffc020046e:	6d0a                	ld	s10,128(sp)
ffffffffc0200470:	612d                	addi	sp,sp,224
ffffffffc0200472:	8082                	ret

ffffffffc0200474 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200474:	0009e317          	auipc	t1,0x9e
ffffffffc0200478:	afc30313          	addi	t1,t1,-1284 # ffffffffc029df70 <is_panic>
ffffffffc020047c:	00033e03          	ld	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200480:	715d                	addi	sp,sp,-80
ffffffffc0200482:	ec06                	sd	ra,24(sp)
ffffffffc0200484:	f436                	sd	a3,40(sp)
ffffffffc0200486:	f83a                	sd	a4,48(sp)
ffffffffc0200488:	fc3e                	sd	a5,56(sp)
ffffffffc020048a:	e0c2                	sd	a6,64(sp)
ffffffffc020048c:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc020048e:	020e1c63          	bnez	t3,ffffffffc02004c6 <__panic+0x52>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200492:	4785                	li	a5,1
ffffffffc0200494:	00f33023          	sd	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc0200498:	e822                	sd	s0,16(sp)
ffffffffc020049a:	103c                	addi	a5,sp,40
ffffffffc020049c:	8432                	mv	s0,a2
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020049e:	862e                	mv	a2,a1
ffffffffc02004a0:	85aa                	mv	a1,a0
ffffffffc02004a2:	00006517          	auipc	a0,0x6
ffffffffc02004a6:	61650513          	addi	a0,a0,1558 # ffffffffc0206ab8 <etext+0x26e>
    va_start(ap, fmt);
ffffffffc02004aa:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004ac:	cd5ff0ef          	jal	ffffffffc0200180 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02004b0:	65a2                	ld	a1,8(sp)
ffffffffc02004b2:	8522                	mv	a0,s0
ffffffffc02004b4:	cadff0ef          	jal	ffffffffc0200160 <vcprintf>
    cprintf("\n");
ffffffffc02004b8:	00006517          	auipc	a0,0x6
ffffffffc02004bc:	62050513          	addi	a0,a0,1568 # ffffffffc0206ad8 <etext+0x28e>
ffffffffc02004c0:	cc1ff0ef          	jal	ffffffffc0200180 <cprintf>
ffffffffc02004c4:	6442                	ld	s0,16(sp)
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc02004c6:	4501                	li	a0,0
ffffffffc02004c8:	4581                	li	a1,0
ffffffffc02004ca:	4601                	li	a2,0
ffffffffc02004cc:	48a1                	li	a7,8
ffffffffc02004ce:	00000073          	ecall
    va_end(ap);

panic_dead:
    // No debug monitor here
    sbi_shutdown();
    intr_disable();
ffffffffc02004d2:	16e000ef          	jal	ffffffffc0200640 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc02004d6:	4501                	li	a0,0
ffffffffc02004d8:	e65ff0ef          	jal	ffffffffc020033c <kmonitor>
    while (1) {
ffffffffc02004dc:	bfed                	j	ffffffffc02004d6 <__panic+0x62>

ffffffffc02004de <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc02004de:	715d                	addi	sp,sp,-80
ffffffffc02004e0:	e822                	sd	s0,16(sp)
ffffffffc02004e2:	fc3e                	sd	a5,56(sp)
ffffffffc02004e4:	8432                	mv	s0,a2
    va_list ap;
    va_start(ap, fmt);
ffffffffc02004e6:	103c                	addi	a5,sp,40
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02004e8:	862e                	mv	a2,a1
ffffffffc02004ea:	85aa                	mv	a1,a0
ffffffffc02004ec:	00006517          	auipc	a0,0x6
ffffffffc02004f0:	5f450513          	addi	a0,a0,1524 # ffffffffc0206ae0 <etext+0x296>
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc02004f4:	ec06                	sd	ra,24(sp)
ffffffffc02004f6:	f436                	sd	a3,40(sp)
ffffffffc02004f8:	f83a                	sd	a4,48(sp)
ffffffffc02004fa:	e0c2                	sd	a6,64(sp)
ffffffffc02004fc:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02004fe:	e43e                	sd	a5,8(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc0200500:	c81ff0ef          	jal	ffffffffc0200180 <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200504:	65a2                	ld	a1,8(sp)
ffffffffc0200506:	8522                	mv	a0,s0
ffffffffc0200508:	c59ff0ef          	jal	ffffffffc0200160 <vcprintf>
    cprintf("\n");
ffffffffc020050c:	00006517          	auipc	a0,0x6
ffffffffc0200510:	5cc50513          	addi	a0,a0,1484 # ffffffffc0206ad8 <etext+0x28e>
ffffffffc0200514:	c6dff0ef          	jal	ffffffffc0200180 <cprintf>
    va_end(ap);
}
ffffffffc0200518:	60e2                	ld	ra,24(sp)
ffffffffc020051a:	6442                	ld	s0,16(sp)
ffffffffc020051c:	6161                	addi	sp,sp,80
ffffffffc020051e:	8082                	ret

ffffffffc0200520 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc0200520:	67e1                	lui	a5,0x18
ffffffffc0200522:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_exit_out_size+0xeb00>
ffffffffc0200526:	0009e717          	auipc	a4,0x9e
ffffffffc020052a:	a4f73923          	sd	a5,-1454(a4) # ffffffffc029df78 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020052e:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc0200532:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200534:	953e                	add	a0,a0,a5
ffffffffc0200536:	4601                	li	a2,0
ffffffffc0200538:	4881                	li	a7,0
ffffffffc020053a:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc020053e:	02000793          	li	a5,32
ffffffffc0200542:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc0200546:	00006517          	auipc	a0,0x6
ffffffffc020054a:	5ba50513          	addi	a0,a0,1466 # ffffffffc0206b00 <etext+0x2b6>
    ticks = 0;
ffffffffc020054e:	0009e797          	auipc	a5,0x9e
ffffffffc0200552:	a207b923          	sd	zero,-1486(a5) # ffffffffc029df80 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200556:	b12d                	j	ffffffffc0200180 <cprintf>

ffffffffc0200558 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200558:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020055c:	0009e797          	auipc	a5,0x9e
ffffffffc0200560:	a1c7b783          	ld	a5,-1508(a5) # ffffffffc029df78 <timebase>
ffffffffc0200564:	953e                	add	a0,a0,a5
ffffffffc0200566:	4581                	li	a1,0
ffffffffc0200568:	4601                	li	a2,0
ffffffffc020056a:	4881                	li	a7,0
ffffffffc020056c:	00000073          	ecall
ffffffffc0200570:	8082                	ret

ffffffffc0200572 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200572:	8082                	ret

ffffffffc0200574 <cons_putc>:
#include <sched.h>
#include <riscv.h>
#include <assert.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200574:	100027f3          	csrr	a5,sstatus
ffffffffc0200578:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc020057a:	0ff57513          	zext.b	a0,a0
ffffffffc020057e:	e799                	bnez	a5,ffffffffc020058c <cons_putc+0x18>
ffffffffc0200580:	4581                	li	a1,0
ffffffffc0200582:	4601                	li	a2,0
ffffffffc0200584:	4885                	li	a7,1
ffffffffc0200586:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc020058a:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc020058c:	1101                	addi	sp,sp,-32
ffffffffc020058e:	ec06                	sd	ra,24(sp)
ffffffffc0200590:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200592:	0ae000ef          	jal	ffffffffc0200640 <intr_disable>
ffffffffc0200596:	6522                	ld	a0,8(sp)
ffffffffc0200598:	4581                	li	a1,0
ffffffffc020059a:	4601                	li	a2,0
ffffffffc020059c:	4885                	li	a7,1
ffffffffc020059e:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc02005a2:	60e2                	ld	ra,24(sp)
ffffffffc02005a4:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02005a6:	a851                	j	ffffffffc020063a <intr_enable>

ffffffffc02005a8 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02005a8:	100027f3          	csrr	a5,sstatus
ffffffffc02005ac:	8b89                	andi	a5,a5,2
ffffffffc02005ae:	eb89                	bnez	a5,ffffffffc02005c0 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc02005b0:	4501                	li	a0,0
ffffffffc02005b2:	4581                	li	a1,0
ffffffffc02005b4:	4601                	li	a2,0
ffffffffc02005b6:	4889                	li	a7,2
ffffffffc02005b8:	00000073          	ecall
ffffffffc02005bc:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc02005be:	8082                	ret
int cons_getc(void) {
ffffffffc02005c0:	1101                	addi	sp,sp,-32
ffffffffc02005c2:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc02005c4:	07c000ef          	jal	ffffffffc0200640 <intr_disable>
ffffffffc02005c8:	4501                	li	a0,0
ffffffffc02005ca:	4581                	li	a1,0
ffffffffc02005cc:	4601                	li	a2,0
ffffffffc02005ce:	4889                	li	a7,2
ffffffffc02005d0:	00000073          	ecall
ffffffffc02005d4:	2501                	sext.w	a0,a0
ffffffffc02005d6:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02005d8:	062000ef          	jal	ffffffffc020063a <intr_enable>
}
ffffffffc02005dc:	60e2                	ld	ra,24(sp)
ffffffffc02005de:	6522                	ld	a0,8(sp)
ffffffffc02005e0:	6105                	addi	sp,sp,32
ffffffffc02005e2:	8082                	ret

ffffffffc02005e4 <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc02005e4:	8082                	ret

ffffffffc02005e6 <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc02005e6:	00253513          	sltiu	a0,a0,2
ffffffffc02005ea:	8082                	ret

ffffffffc02005ec <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc02005ec:	03800513          	li	a0,56
ffffffffc02005f0:	8082                	ret

ffffffffc02005f2 <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02005f2:	00093797          	auipc	a5,0x93
ffffffffc02005f6:	8b678793          	addi	a5,a5,-1866 # ffffffffc0292ea8 <ide>
    int iobase = secno * SECTSIZE;
ffffffffc02005fa:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc02005fe:	1141                	addi	sp,sp,-16
ffffffffc0200600:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200602:	95be                	add	a1,a1,a5
ffffffffc0200604:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc0200608:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc020060a:	228060ef          	jal	ffffffffc0206832 <memcpy>
    return 0;
}
ffffffffc020060e:	60a2                	ld	ra,8(sp)
ffffffffc0200610:	4501                	li	a0,0
ffffffffc0200612:	0141                	addi	sp,sp,16
ffffffffc0200614:	8082                	ret

ffffffffc0200616 <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
    int iobase = secno * SECTSIZE;
ffffffffc0200616:	0095979b          	slliw	a5,a1,0x9
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc020061a:	00093517          	auipc	a0,0x93
ffffffffc020061e:	88e50513          	addi	a0,a0,-1906 # ffffffffc0292ea8 <ide>
                   size_t nsecs) {
ffffffffc0200622:	1141                	addi	sp,sp,-16
ffffffffc0200624:	85b2                	mv	a1,a2
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200626:	953e                	add	a0,a0,a5
ffffffffc0200628:	00969613          	slli	a2,a3,0x9
                   size_t nsecs) {
ffffffffc020062c:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc020062e:	204060ef          	jal	ffffffffc0206832 <memcpy>
    return 0;
}
ffffffffc0200632:	60a2                	ld	ra,8(sp)
ffffffffc0200634:	4501                	li	a0,0
ffffffffc0200636:	0141                	addi	sp,sp,16
ffffffffc0200638:	8082                	ret

ffffffffc020063a <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc020063a:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc020063e:	8082                	ret

ffffffffc0200640 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200640:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200644:	8082                	ret

ffffffffc0200646 <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc0200646:	8082                	ret

ffffffffc0200648 <idt_init>:
void
idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc0200648:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc020064c:	00000797          	auipc	a5,0x0
ffffffffc0200650:	64478793          	addi	a5,a5,1604 # ffffffffc0200c90 <__alltraps>
ffffffffc0200654:	10579073          	csrw	stvec,a5
    /* Allow kernel to access user memory */
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc0200658:	000407b7          	lui	a5,0x40
ffffffffc020065c:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200660:	8082                	ret

ffffffffc0200662 <print_regs>:
    cprintf("  tval 0x%08x\n", tf->tval);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs* gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200662:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs* gpr) {
ffffffffc0200664:	1141                	addi	sp,sp,-16
ffffffffc0200666:	e022                	sd	s0,0(sp)
ffffffffc0200668:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020066a:	00006517          	auipc	a0,0x6
ffffffffc020066e:	4b650513          	addi	a0,a0,1206 # ffffffffc0206b20 <etext+0x2d6>
void print_regs(struct pushregs* gpr) {
ffffffffc0200672:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200674:	b0dff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200678:	640c                	ld	a1,8(s0)
ffffffffc020067a:	00006517          	auipc	a0,0x6
ffffffffc020067e:	4be50513          	addi	a0,a0,1214 # ffffffffc0206b38 <etext+0x2ee>
ffffffffc0200682:	affff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200686:	680c                	ld	a1,16(s0)
ffffffffc0200688:	00006517          	auipc	a0,0x6
ffffffffc020068c:	4c850513          	addi	a0,a0,1224 # ffffffffc0206b50 <etext+0x306>
ffffffffc0200690:	af1ff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc0200694:	6c0c                	ld	a1,24(s0)
ffffffffc0200696:	00006517          	auipc	a0,0x6
ffffffffc020069a:	4d250513          	addi	a0,a0,1234 # ffffffffc0206b68 <etext+0x31e>
ffffffffc020069e:	ae3ff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02006a2:	700c                	ld	a1,32(s0)
ffffffffc02006a4:	00006517          	auipc	a0,0x6
ffffffffc02006a8:	4dc50513          	addi	a0,a0,1244 # ffffffffc0206b80 <etext+0x336>
ffffffffc02006ac:	ad5ff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02006b0:	740c                	ld	a1,40(s0)
ffffffffc02006b2:	00006517          	auipc	a0,0x6
ffffffffc02006b6:	4e650513          	addi	a0,a0,1254 # ffffffffc0206b98 <etext+0x34e>
ffffffffc02006ba:	ac7ff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006be:	780c                	ld	a1,48(s0)
ffffffffc02006c0:	00006517          	auipc	a0,0x6
ffffffffc02006c4:	4f050513          	addi	a0,a0,1264 # ffffffffc0206bb0 <etext+0x366>
ffffffffc02006c8:	ab9ff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006cc:	7c0c                	ld	a1,56(s0)
ffffffffc02006ce:	00006517          	auipc	a0,0x6
ffffffffc02006d2:	4fa50513          	addi	a0,a0,1274 # ffffffffc0206bc8 <etext+0x37e>
ffffffffc02006d6:	aabff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006da:	602c                	ld	a1,64(s0)
ffffffffc02006dc:	00006517          	auipc	a0,0x6
ffffffffc02006e0:	50450513          	addi	a0,a0,1284 # ffffffffc0206be0 <etext+0x396>
ffffffffc02006e4:	a9dff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02006e8:	642c                	ld	a1,72(s0)
ffffffffc02006ea:	00006517          	auipc	a0,0x6
ffffffffc02006ee:	50e50513          	addi	a0,a0,1294 # ffffffffc0206bf8 <etext+0x3ae>
ffffffffc02006f2:	a8fff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02006f6:	682c                	ld	a1,80(s0)
ffffffffc02006f8:	00006517          	auipc	a0,0x6
ffffffffc02006fc:	51850513          	addi	a0,a0,1304 # ffffffffc0206c10 <etext+0x3c6>
ffffffffc0200700:	a81ff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200704:	6c2c                	ld	a1,88(s0)
ffffffffc0200706:	00006517          	auipc	a0,0x6
ffffffffc020070a:	52250513          	addi	a0,a0,1314 # ffffffffc0206c28 <etext+0x3de>
ffffffffc020070e:	a73ff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200712:	702c                	ld	a1,96(s0)
ffffffffc0200714:	00006517          	auipc	a0,0x6
ffffffffc0200718:	52c50513          	addi	a0,a0,1324 # ffffffffc0206c40 <etext+0x3f6>
ffffffffc020071c:	a65ff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200720:	742c                	ld	a1,104(s0)
ffffffffc0200722:	00006517          	auipc	a0,0x6
ffffffffc0200726:	53650513          	addi	a0,a0,1334 # ffffffffc0206c58 <etext+0x40e>
ffffffffc020072a:	a57ff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc020072e:	782c                	ld	a1,112(s0)
ffffffffc0200730:	00006517          	auipc	a0,0x6
ffffffffc0200734:	54050513          	addi	a0,a0,1344 # ffffffffc0206c70 <etext+0x426>
ffffffffc0200738:	a49ff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020073c:	7c2c                	ld	a1,120(s0)
ffffffffc020073e:	00006517          	auipc	a0,0x6
ffffffffc0200742:	54a50513          	addi	a0,a0,1354 # ffffffffc0206c88 <etext+0x43e>
ffffffffc0200746:	a3bff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020074a:	604c                	ld	a1,128(s0)
ffffffffc020074c:	00006517          	auipc	a0,0x6
ffffffffc0200750:	55450513          	addi	a0,a0,1364 # ffffffffc0206ca0 <etext+0x456>
ffffffffc0200754:	a2dff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200758:	644c                	ld	a1,136(s0)
ffffffffc020075a:	00006517          	auipc	a0,0x6
ffffffffc020075e:	55e50513          	addi	a0,a0,1374 # ffffffffc0206cb8 <etext+0x46e>
ffffffffc0200762:	a1fff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200766:	684c                	ld	a1,144(s0)
ffffffffc0200768:	00006517          	auipc	a0,0x6
ffffffffc020076c:	56850513          	addi	a0,a0,1384 # ffffffffc0206cd0 <etext+0x486>
ffffffffc0200770:	a11ff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200774:	6c4c                	ld	a1,152(s0)
ffffffffc0200776:	00006517          	auipc	a0,0x6
ffffffffc020077a:	57250513          	addi	a0,a0,1394 # ffffffffc0206ce8 <etext+0x49e>
ffffffffc020077e:	a03ff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200782:	704c                	ld	a1,160(s0)
ffffffffc0200784:	00006517          	auipc	a0,0x6
ffffffffc0200788:	57c50513          	addi	a0,a0,1404 # ffffffffc0206d00 <etext+0x4b6>
ffffffffc020078c:	9f5ff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200790:	744c                	ld	a1,168(s0)
ffffffffc0200792:	00006517          	auipc	a0,0x6
ffffffffc0200796:	58650513          	addi	a0,a0,1414 # ffffffffc0206d18 <etext+0x4ce>
ffffffffc020079a:	9e7ff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc020079e:	784c                	ld	a1,176(s0)
ffffffffc02007a0:	00006517          	auipc	a0,0x6
ffffffffc02007a4:	59050513          	addi	a0,a0,1424 # ffffffffc0206d30 <etext+0x4e6>
ffffffffc02007a8:	9d9ff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02007ac:	7c4c                	ld	a1,184(s0)
ffffffffc02007ae:	00006517          	auipc	a0,0x6
ffffffffc02007b2:	59a50513          	addi	a0,a0,1434 # ffffffffc0206d48 <etext+0x4fe>
ffffffffc02007b6:	9cbff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007ba:	606c                	ld	a1,192(s0)
ffffffffc02007bc:	00006517          	auipc	a0,0x6
ffffffffc02007c0:	5a450513          	addi	a0,a0,1444 # ffffffffc0206d60 <etext+0x516>
ffffffffc02007c4:	9bdff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007c8:	646c                	ld	a1,200(s0)
ffffffffc02007ca:	00006517          	auipc	a0,0x6
ffffffffc02007ce:	5ae50513          	addi	a0,a0,1454 # ffffffffc0206d78 <etext+0x52e>
ffffffffc02007d2:	9afff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007d6:	686c                	ld	a1,208(s0)
ffffffffc02007d8:	00006517          	auipc	a0,0x6
ffffffffc02007dc:	5b850513          	addi	a0,a0,1464 # ffffffffc0206d90 <etext+0x546>
ffffffffc02007e0:	9a1ff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007e4:	6c6c                	ld	a1,216(s0)
ffffffffc02007e6:	00006517          	auipc	a0,0x6
ffffffffc02007ea:	5c250513          	addi	a0,a0,1474 # ffffffffc0206da8 <etext+0x55e>
ffffffffc02007ee:	993ff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02007f2:	706c                	ld	a1,224(s0)
ffffffffc02007f4:	00006517          	auipc	a0,0x6
ffffffffc02007f8:	5cc50513          	addi	a0,a0,1484 # ffffffffc0206dc0 <etext+0x576>
ffffffffc02007fc:	985ff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200800:	746c                	ld	a1,232(s0)
ffffffffc0200802:	00006517          	auipc	a0,0x6
ffffffffc0200806:	5d650513          	addi	a0,a0,1494 # ffffffffc0206dd8 <etext+0x58e>
ffffffffc020080a:	977ff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc020080e:	786c                	ld	a1,240(s0)
ffffffffc0200810:	00006517          	auipc	a0,0x6
ffffffffc0200814:	5e050513          	addi	a0,a0,1504 # ffffffffc0206df0 <etext+0x5a6>
ffffffffc0200818:	969ff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020081c:	7c6c                	ld	a1,248(s0)
}
ffffffffc020081e:	6402                	ld	s0,0(sp)
ffffffffc0200820:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200822:	00006517          	auipc	a0,0x6
ffffffffc0200826:	5e650513          	addi	a0,a0,1510 # ffffffffc0206e08 <etext+0x5be>
}
ffffffffc020082a:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020082c:	955ff06f          	j	ffffffffc0200180 <cprintf>

ffffffffc0200830 <print_trapframe>:
print_trapframe(struct trapframe *tf) {
ffffffffc0200830:	1141                	addi	sp,sp,-16
ffffffffc0200832:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200834:	85aa                	mv	a1,a0
print_trapframe(struct trapframe *tf) {
ffffffffc0200836:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200838:	00006517          	auipc	a0,0x6
ffffffffc020083c:	5e850513          	addi	a0,a0,1512 # ffffffffc0206e20 <etext+0x5d6>
print_trapframe(struct trapframe *tf) {
ffffffffc0200840:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200842:	93fff0ef          	jal	ffffffffc0200180 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200846:	8522                	mv	a0,s0
ffffffffc0200848:	e1bff0ef          	jal	ffffffffc0200662 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020084c:	10043583          	ld	a1,256(s0)
ffffffffc0200850:	00006517          	auipc	a0,0x6
ffffffffc0200854:	5e850513          	addi	a0,a0,1512 # ffffffffc0206e38 <etext+0x5ee>
ffffffffc0200858:	929ff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020085c:	10843583          	ld	a1,264(s0)
ffffffffc0200860:	00006517          	auipc	a0,0x6
ffffffffc0200864:	5f050513          	addi	a0,a0,1520 # ffffffffc0206e50 <etext+0x606>
ffffffffc0200868:	919ff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc020086c:	11043583          	ld	a1,272(s0)
ffffffffc0200870:	00006517          	auipc	a0,0x6
ffffffffc0200874:	5f850513          	addi	a0,a0,1528 # ffffffffc0206e68 <etext+0x61e>
ffffffffc0200878:	909ff0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020087c:	11843583          	ld	a1,280(s0)
}
ffffffffc0200880:	6402                	ld	s0,0(sp)
ffffffffc0200882:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200884:	00006517          	auipc	a0,0x6
ffffffffc0200888:	5f450513          	addi	a0,a0,1524 # ffffffffc0206e78 <etext+0x62e>
}
ffffffffc020088c:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020088e:	8f3ff06f          	j	ffffffffc0200180 <cprintf>

ffffffffc0200892 <pgfault_handler>:
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int
pgfault_handler(struct trapframe *tf) {
ffffffffc0200892:	1101                	addi	sp,sp,-32
ffffffffc0200894:	e426                	sd	s1,8(sp)
    extern struct mm_struct *check_mm_struct;
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc0200896:	0009d497          	auipc	s1,0x9d
ffffffffc020089a:	74a48493          	addi	s1,s1,1866 # ffffffffc029dfe0 <check_mm_struct>
ffffffffc020089e:	609c                	ld	a5,0(s1)
pgfault_handler(struct trapframe *tf) {
ffffffffc02008a0:	e822                	sd	s0,16(sp)
ffffffffc02008a2:	ec06                	sd	ra,24(sp)
ffffffffc02008a4:	842a                	mv	s0,a0
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc02008a6:	cfb9                	beqz	a5,ffffffffc0200904 <pgfault_handler+0x72>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008a8:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008ac:	11053583          	ld	a1,272(a0)
ffffffffc02008b0:	05500613          	li	a2,85
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008b4:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008b8:	c399                	beqz	a5,ffffffffc02008be <pgfault_handler+0x2c>
ffffffffc02008ba:	04b00613          	li	a2,75
ffffffffc02008be:	11843703          	ld	a4,280(s0)
ffffffffc02008c2:	47bd                	li	a5,15
ffffffffc02008c4:	05200693          	li	a3,82
ffffffffc02008c8:	04f70e63          	beq	a4,a5,ffffffffc0200924 <pgfault_handler+0x92>
ffffffffc02008cc:	00006517          	auipc	a0,0x6
ffffffffc02008d0:	5c450513          	addi	a0,a0,1476 # ffffffffc0206e90 <etext+0x646>
ffffffffc02008d4:	8adff0ef          	jal	ffffffffc0200180 <cprintf>
            print_pgfault(tf);
        }
    struct mm_struct *mm;
    if (check_mm_struct != NULL) {
ffffffffc02008d8:	6088                	ld	a0,0(s1)
ffffffffc02008da:	c50d                	beqz	a0,ffffffffc0200904 <pgfault_handler+0x72>
        assert(current == idleproc);
ffffffffc02008dc:	0009d717          	auipc	a4,0x9d
ffffffffc02008e0:	71473703          	ld	a4,1812(a4) # ffffffffc029dff0 <current>
ffffffffc02008e4:	0009d797          	auipc	a5,0x9d
ffffffffc02008e8:	71c7b783          	ld	a5,1820(a5) # ffffffffc029e000 <idleproc>
ffffffffc02008ec:	02f71f63          	bne	a4,a5,ffffffffc020092a <pgfault_handler+0x98>
            print_pgfault(tf);
            panic("unhandled page fault.\n");
        }
        mm = current->mm;
    }
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc02008f0:	11043603          	ld	a2,272(s0)
ffffffffc02008f4:	11843583          	ld	a1,280(s0)
}
ffffffffc02008f8:	6442                	ld	s0,16(sp)
ffffffffc02008fa:	60e2                	ld	ra,24(sp)
ffffffffc02008fc:	64a2                	ld	s1,8(sp)
ffffffffc02008fe:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200900:	3c80406f          	j	ffffffffc0204cc8 <do_pgfault>
        if (current == NULL) {
ffffffffc0200904:	0009d797          	auipc	a5,0x9d
ffffffffc0200908:	6ec7b783          	ld	a5,1772(a5) # ffffffffc029dff0 <current>
ffffffffc020090c:	cf9d                	beqz	a5,ffffffffc020094a <pgfault_handler+0xb8>
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc020090e:	11043603          	ld	a2,272(s0)
ffffffffc0200912:	11843583          	ld	a1,280(s0)
}
ffffffffc0200916:	6442                	ld	s0,16(sp)
ffffffffc0200918:	60e2                	ld	ra,24(sp)
ffffffffc020091a:	64a2                	ld	s1,8(sp)
        mm = current->mm;
ffffffffc020091c:	7788                	ld	a0,40(a5)
}
ffffffffc020091e:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200920:	3a80406f          	j	ffffffffc0204cc8 <do_pgfault>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200924:	05700693          	li	a3,87
ffffffffc0200928:	b755                	j	ffffffffc02008cc <pgfault_handler+0x3a>
        assert(current == idleproc);
ffffffffc020092a:	00006697          	auipc	a3,0x6
ffffffffc020092e:	58668693          	addi	a3,a3,1414 # ffffffffc0206eb0 <etext+0x666>
ffffffffc0200932:	00006617          	auipc	a2,0x6
ffffffffc0200936:	59660613          	addi	a2,a2,1430 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc020093a:	06b00593          	li	a1,107
ffffffffc020093e:	00006517          	auipc	a0,0x6
ffffffffc0200942:	5a250513          	addi	a0,a0,1442 # ffffffffc0206ee0 <etext+0x696>
ffffffffc0200946:	b2fff0ef          	jal	ffffffffc0200474 <__panic>
            print_trapframe(tf);
ffffffffc020094a:	8522                	mv	a0,s0
ffffffffc020094c:	ee5ff0ef          	jal	ffffffffc0200830 <print_trapframe>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200950:	10043783          	ld	a5,256(s0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200954:	11043583          	ld	a1,272(s0)
ffffffffc0200958:	05500613          	li	a2,85
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc020095c:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200960:	c399                	beqz	a5,ffffffffc0200966 <pgfault_handler+0xd4>
ffffffffc0200962:	04b00613          	li	a2,75
ffffffffc0200966:	11843703          	ld	a4,280(s0)
ffffffffc020096a:	47bd                	li	a5,15
ffffffffc020096c:	05200693          	li	a3,82
ffffffffc0200970:	00f71463          	bne	a4,a5,ffffffffc0200978 <pgfault_handler+0xe6>
ffffffffc0200974:	05700693          	li	a3,87
ffffffffc0200978:	00006517          	auipc	a0,0x6
ffffffffc020097c:	51850513          	addi	a0,a0,1304 # ffffffffc0206e90 <etext+0x646>
ffffffffc0200980:	801ff0ef          	jal	ffffffffc0200180 <cprintf>
            panic("unhandled page fault.\n");
ffffffffc0200984:	00006617          	auipc	a2,0x6
ffffffffc0200988:	57460613          	addi	a2,a2,1396 # ffffffffc0206ef8 <etext+0x6ae>
ffffffffc020098c:	07200593          	li	a1,114
ffffffffc0200990:	00006517          	auipc	a0,0x6
ffffffffc0200994:	55050513          	addi	a0,a0,1360 # ffffffffc0206ee0 <etext+0x696>
ffffffffc0200998:	addff0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc020099c <interrupt_handler>:
static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
    switch (cause) {
ffffffffc020099c:	11853783          	ld	a5,280(a0)
ffffffffc02009a0:	472d                	li	a4,11
ffffffffc02009a2:	0786                	slli	a5,a5,0x1
ffffffffc02009a4:	8385                	srli	a5,a5,0x1
ffffffffc02009a6:	08f76363          	bltu	a4,a5,ffffffffc0200a2c <interrupt_handler+0x90>
ffffffffc02009aa:	00008717          	auipc	a4,0x8
ffffffffc02009ae:	1de70713          	addi	a4,a4,478 # ffffffffc0208b88 <commands+0x48>
ffffffffc02009b2:	078a                	slli	a5,a5,0x2
ffffffffc02009b4:	97ba                	add	a5,a5,a4
ffffffffc02009b6:	439c                	lw	a5,0(a5)
ffffffffc02009b8:	97ba                	add	a5,a5,a4
ffffffffc02009ba:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02009bc:	00006517          	auipc	a0,0x6
ffffffffc02009c0:	5b450513          	addi	a0,a0,1460 # ffffffffc0206f70 <etext+0x726>
ffffffffc02009c4:	fbcff06f          	j	ffffffffc0200180 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02009c8:	00006517          	auipc	a0,0x6
ffffffffc02009cc:	58850513          	addi	a0,a0,1416 # ffffffffc0206f50 <etext+0x706>
ffffffffc02009d0:	fb0ff06f          	j	ffffffffc0200180 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02009d4:	00006517          	auipc	a0,0x6
ffffffffc02009d8:	53c50513          	addi	a0,a0,1340 # ffffffffc0206f10 <etext+0x6c6>
ffffffffc02009dc:	fa4ff06f          	j	ffffffffc0200180 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02009e0:	00006517          	auipc	a0,0x6
ffffffffc02009e4:	55050513          	addi	a0,a0,1360 # ffffffffc0206f30 <etext+0x6e6>
ffffffffc02009e8:	f98ff06f          	j	ffffffffc0200180 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02009ec:	1141                	addi	sp,sp,-16
ffffffffc02009ee:	e406                	sd	ra,8(sp)
            // "All bits besides SSIP and USIP in the sip register are
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc02009f0:	b69ff0ef          	jal	ffffffffc0200558 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0 && current) {
ffffffffc02009f4:	0009d697          	auipc	a3,0x9d
ffffffffc02009f8:	58c68693          	addi	a3,a3,1420 # ffffffffc029df80 <ticks>
ffffffffc02009fc:	629c                	ld	a5,0(a3)
ffffffffc02009fe:	06400713          	li	a4,100
ffffffffc0200a02:	0785                	addi	a5,a5,1
ffffffffc0200a04:	02e7f733          	remu	a4,a5,a4
ffffffffc0200a08:	e29c                	sd	a5,0(a3)
ffffffffc0200a0a:	eb01                	bnez	a4,ffffffffc0200a1a <interrupt_handler+0x7e>
ffffffffc0200a0c:	0009d797          	auipc	a5,0x9d
ffffffffc0200a10:	5e47b783          	ld	a5,1508(a5) # ffffffffc029dff0 <current>
ffffffffc0200a14:	c399                	beqz	a5,ffffffffc0200a1a <interrupt_handler+0x7e>
                // print_ticks();
                current->need_resched = 1;
ffffffffc0200a16:	4705                	li	a4,1
ffffffffc0200a18:	ef98                	sd	a4,24(a5)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a1a:	60a2                	ld	ra,8(sp)
ffffffffc0200a1c:	0141                	addi	sp,sp,16
ffffffffc0200a1e:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200a20:	00006517          	auipc	a0,0x6
ffffffffc0200a24:	57050513          	addi	a0,a0,1392 # ffffffffc0206f90 <etext+0x746>
ffffffffc0200a28:	f58ff06f          	j	ffffffffc0200180 <cprintf>
            print_trapframe(tf);
ffffffffc0200a2c:	b511                	j	ffffffffc0200830 <print_trapframe>

ffffffffc0200a2e <exception_handler>:
void kernel_execve_ret(struct trapframe *tf,uintptr_t kstacktop);
void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200a2e:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc0200a32:	1101                	addi	sp,sp,-32
ffffffffc0200a34:	e822                	sd	s0,16(sp)
ffffffffc0200a36:	ec06                	sd	ra,24(sp)
    switch (tf->cause) {
ffffffffc0200a38:	473d                	li	a4,15
void exception_handler(struct trapframe *tf) {
ffffffffc0200a3a:	842a                	mv	s0,a0
    switch (tf->cause) {
ffffffffc0200a3c:	18f76663          	bltu	a4,a5,ffffffffc0200bc8 <exception_handler+0x19a>
ffffffffc0200a40:	00008717          	auipc	a4,0x8
ffffffffc0200a44:	17870713          	addi	a4,a4,376 # ffffffffc0208bb8 <commands+0x78>
ffffffffc0200a48:	078a                	slli	a5,a5,0x2
ffffffffc0200a4a:	97ba                	add	a5,a5,a4
ffffffffc0200a4c:	439c                	lw	a5,0(a5)
ffffffffc0200a4e:	97ba                	add	a5,a5,a4
ffffffffc0200a50:	8782                	jr	a5
            //对于ecall, 我们希望sepc寄存器要指向产生异常的指令(ecall)的下一条指令
            //否则就会回到ecall执行再执行一次ecall, 无限循环
            syscall();// 进行系统调用处理
            break;
        case CAUSE_SUPERVISOR_ECALL:
            cprintf("Environment call from S-mode\n");
ffffffffc0200a52:	00006517          	auipc	a0,0x6
ffffffffc0200a56:	64e50513          	addi	a0,a0,1614 # ffffffffc02070a0 <etext+0x856>
ffffffffc0200a5a:	f26ff0ef          	jal	ffffffffc0200180 <cprintf>
            tf->epc += 4;
ffffffffc0200a5e:	10843783          	ld	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a62:	60e2                	ld	ra,24(sp)
            tf->epc += 4;
ffffffffc0200a64:	0791                	addi	a5,a5,4
ffffffffc0200a66:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200a6a:	6442                	ld	s0,16(sp)
ffffffffc0200a6c:	6105                	addi	sp,sp,32
            syscall();
ffffffffc0200a6e:	09f0506f          	j	ffffffffc020630c <syscall>
            cprintf("Environment call from H-mode\n");
ffffffffc0200a72:	00006517          	auipc	a0,0x6
ffffffffc0200a76:	64e50513          	addi	a0,a0,1614 # ffffffffc02070c0 <etext+0x876>
}
ffffffffc0200a7a:	6442                	ld	s0,16(sp)
ffffffffc0200a7c:	60e2                	ld	ra,24(sp)
ffffffffc0200a7e:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200a80:	f00ff06f          	j	ffffffffc0200180 <cprintf>
            cprintf("Environment call from M-mode\n");
ffffffffc0200a84:	00006517          	auipc	a0,0x6
ffffffffc0200a88:	65c50513          	addi	a0,a0,1628 # ffffffffc02070e0 <etext+0x896>
ffffffffc0200a8c:	b7fd                	j	ffffffffc0200a7a <exception_handler+0x4c>
            cprintf("Instruction page fault\n");
ffffffffc0200a8e:	00006517          	auipc	a0,0x6
ffffffffc0200a92:	67250513          	addi	a0,a0,1650 # ffffffffc0207100 <etext+0x8b6>
ffffffffc0200a96:	b7d5                	j	ffffffffc0200a7a <exception_handler+0x4c>
            cprintf("Load page fault\n");
ffffffffc0200a98:	00006517          	auipc	a0,0x6
ffffffffc0200a9c:	68050513          	addi	a0,a0,1664 # ffffffffc0207118 <etext+0x8ce>
ffffffffc0200aa0:	e426                	sd	s1,8(sp)
ffffffffc0200aa2:	edeff0ef          	jal	ffffffffc0200180 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200aa6:	8522                	mv	a0,s0
ffffffffc0200aa8:	debff0ef          	jal	ffffffffc0200892 <pgfault_handler>
ffffffffc0200aac:	84aa                	mv	s1,a0
ffffffffc0200aae:	12051f63          	bnez	a0,ffffffffc0200bec <exception_handler+0x1be>
ffffffffc0200ab2:	64a2                	ld	s1,8(sp)
}
ffffffffc0200ab4:	60e2                	ld	ra,24(sp)
ffffffffc0200ab6:	6442                	ld	s0,16(sp)
ffffffffc0200ab8:	6105                	addi	sp,sp,32
ffffffffc0200aba:	8082                	ret
            cprintf("Store/AMO page fault\n");
ffffffffc0200abc:	00006517          	auipc	a0,0x6
ffffffffc0200ac0:	67450513          	addi	a0,a0,1652 # ffffffffc0207130 <etext+0x8e6>
ffffffffc0200ac4:	e426                	sd	s1,8(sp)
ffffffffc0200ac6:	ebaff0ef          	jal	ffffffffc0200180 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200aca:	8522                	mv	a0,s0
ffffffffc0200acc:	dc7ff0ef          	jal	ffffffffc0200892 <pgfault_handler>
ffffffffc0200ad0:	84aa                	mv	s1,a0
ffffffffc0200ad2:	d165                	beqz	a0,ffffffffc0200ab2 <exception_handler+0x84>
                print_trapframe(tf);
ffffffffc0200ad4:	8522                	mv	a0,s0
ffffffffc0200ad6:	d5bff0ef          	jal	ffffffffc0200830 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200ada:	86a6                	mv	a3,s1
ffffffffc0200adc:	00006617          	auipc	a2,0x6
ffffffffc0200ae0:	57460613          	addi	a2,a2,1396 # ffffffffc0207050 <etext+0x806>
ffffffffc0200ae4:	0fa00593          	li	a1,250
ffffffffc0200ae8:	00006517          	auipc	a0,0x6
ffffffffc0200aec:	3f850513          	addi	a0,a0,1016 # ffffffffc0206ee0 <etext+0x696>
ffffffffc0200af0:	985ff0ef          	jal	ffffffffc0200474 <__panic>
            cprintf("Instruction address misaligned\n");
ffffffffc0200af4:	00006517          	auipc	a0,0x6
ffffffffc0200af8:	4bc50513          	addi	a0,a0,1212 # ffffffffc0206fb0 <etext+0x766>
ffffffffc0200afc:	bfbd                	j	ffffffffc0200a7a <exception_handler+0x4c>
            cprintf("Instruction access fault\n");
ffffffffc0200afe:	00006517          	auipc	a0,0x6
ffffffffc0200b02:	4d250513          	addi	a0,a0,1234 # ffffffffc0206fd0 <etext+0x786>
ffffffffc0200b06:	bf95                	j	ffffffffc0200a7a <exception_handler+0x4c>
            cprintf("Illegal instruction\n");
ffffffffc0200b08:	00006517          	auipc	a0,0x6
ffffffffc0200b0c:	4e850513          	addi	a0,a0,1256 # ffffffffc0206ff0 <etext+0x7a6>
ffffffffc0200b10:	b7ad                	j	ffffffffc0200a7a <exception_handler+0x4c>
            cprintf("Breakpoint\n");
ffffffffc0200b12:	00006517          	auipc	a0,0x6
ffffffffc0200b16:	4f650513          	addi	a0,a0,1270 # ffffffffc0207008 <etext+0x7be>
ffffffffc0200b1a:	e66ff0ef          	jal	ffffffffc0200180 <cprintf>
            if(tf->gpr.a7 == 10){
ffffffffc0200b1e:	6458                	ld	a4,136(s0)
ffffffffc0200b20:	47a9                	li	a5,10
ffffffffc0200b22:	f8f719e3          	bne	a4,a5,ffffffffc0200ab4 <exception_handler+0x86>
                tf->epc += 4;//注意返回时要执行ebreak的下一条指令
ffffffffc0200b26:	10843783          	ld	a5,264(s0)
ffffffffc0200b2a:	0791                	addi	a5,a5,4
ffffffffc0200b2c:	10f43423          	sd	a5,264(s0)
                syscall();
ffffffffc0200b30:	7dc050ef          	jal	ffffffffc020630c <syscall>
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b34:	0009d797          	auipc	a5,0x9d
ffffffffc0200b38:	4bc7b783          	ld	a5,1212(a5) # ffffffffc029dff0 <current>
ffffffffc0200b3c:	6b9c                	ld	a5,16(a5)
ffffffffc0200b3e:	8522                	mv	a0,s0
}
ffffffffc0200b40:	6442                	ld	s0,16(sp)
ffffffffc0200b42:	60e2                	ld	ra,24(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b44:	6589                	lui	a1,0x2
ffffffffc0200b46:	95be                	add	a1,a1,a5
}
ffffffffc0200b48:	6105                	addi	sp,sp,32
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b4a:	ac11                	j	ffffffffc0200d5e <kernel_execve_ret>
            cprintf("Load address misaligned\n");
ffffffffc0200b4c:	00006517          	auipc	a0,0x6
ffffffffc0200b50:	4cc50513          	addi	a0,a0,1228 # ffffffffc0207018 <etext+0x7ce>
ffffffffc0200b54:	b71d                	j	ffffffffc0200a7a <exception_handler+0x4c>
            cprintf("Load access fault\n");
ffffffffc0200b56:	00006517          	auipc	a0,0x6
ffffffffc0200b5a:	4e250513          	addi	a0,a0,1250 # ffffffffc0207038 <etext+0x7ee>
ffffffffc0200b5e:	e426                	sd	s1,8(sp)
ffffffffc0200b60:	e20ff0ef          	jal	ffffffffc0200180 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200b64:	8522                	mv	a0,s0
ffffffffc0200b66:	d2dff0ef          	jal	ffffffffc0200892 <pgfault_handler>
ffffffffc0200b6a:	84aa                	mv	s1,a0
ffffffffc0200b6c:	d139                	beqz	a0,ffffffffc0200ab2 <exception_handler+0x84>
                print_trapframe(tf);
ffffffffc0200b6e:	8522                	mv	a0,s0
ffffffffc0200b70:	cc1ff0ef          	jal	ffffffffc0200830 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200b74:	86a6                	mv	a3,s1
ffffffffc0200b76:	00006617          	auipc	a2,0x6
ffffffffc0200b7a:	4da60613          	addi	a2,a2,1242 # ffffffffc0207050 <etext+0x806>
ffffffffc0200b7e:	0cd00593          	li	a1,205
ffffffffc0200b82:	00006517          	auipc	a0,0x6
ffffffffc0200b86:	35e50513          	addi	a0,a0,862 # ffffffffc0206ee0 <etext+0x696>
ffffffffc0200b8a:	8ebff0ef          	jal	ffffffffc0200474 <__panic>
            cprintf("Store/AMO access fault\n");
ffffffffc0200b8e:	00006517          	auipc	a0,0x6
ffffffffc0200b92:	4fa50513          	addi	a0,a0,1274 # ffffffffc0207088 <etext+0x83e>
ffffffffc0200b96:	e426                	sd	s1,8(sp)
ffffffffc0200b98:	de8ff0ef          	jal	ffffffffc0200180 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200b9c:	8522                	mv	a0,s0
ffffffffc0200b9e:	cf5ff0ef          	jal	ffffffffc0200892 <pgfault_handler>
ffffffffc0200ba2:	84aa                	mv	s1,a0
ffffffffc0200ba4:	f00507e3          	beqz	a0,ffffffffc0200ab2 <exception_handler+0x84>
                print_trapframe(tf);
ffffffffc0200ba8:	8522                	mv	a0,s0
ffffffffc0200baa:	c87ff0ef          	jal	ffffffffc0200830 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200bae:	86a6                	mv	a3,s1
ffffffffc0200bb0:	00006617          	auipc	a2,0x6
ffffffffc0200bb4:	4a060613          	addi	a2,a2,1184 # ffffffffc0207050 <etext+0x806>
ffffffffc0200bb8:	0d700593          	li	a1,215
ffffffffc0200bbc:	00006517          	auipc	a0,0x6
ffffffffc0200bc0:	32450513          	addi	a0,a0,804 # ffffffffc0206ee0 <etext+0x696>
ffffffffc0200bc4:	8b1ff0ef          	jal	ffffffffc0200474 <__panic>
            print_trapframe(tf);
ffffffffc0200bc8:	8522                	mv	a0,s0
}
ffffffffc0200bca:	6442                	ld	s0,16(sp)
ffffffffc0200bcc:	60e2                	ld	ra,24(sp)
ffffffffc0200bce:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200bd0:	b185                	j	ffffffffc0200830 <print_trapframe>
            panic("AMO address misaligned\n");
ffffffffc0200bd2:	00006617          	auipc	a2,0x6
ffffffffc0200bd6:	49e60613          	addi	a2,a2,1182 # ffffffffc0207070 <etext+0x826>
ffffffffc0200bda:	0d100593          	li	a1,209
ffffffffc0200bde:	00006517          	auipc	a0,0x6
ffffffffc0200be2:	30250513          	addi	a0,a0,770 # ffffffffc0206ee0 <etext+0x696>
ffffffffc0200be6:	e426                	sd	s1,8(sp)
ffffffffc0200be8:	88dff0ef          	jal	ffffffffc0200474 <__panic>
                print_trapframe(tf);
ffffffffc0200bec:	8522                	mv	a0,s0
ffffffffc0200bee:	c43ff0ef          	jal	ffffffffc0200830 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200bf2:	86a6                	mv	a3,s1
ffffffffc0200bf4:	00006617          	auipc	a2,0x6
ffffffffc0200bf8:	45c60613          	addi	a2,a2,1116 # ffffffffc0207050 <etext+0x806>
ffffffffc0200bfc:	0f300593          	li	a1,243
ffffffffc0200c00:	00006517          	auipc	a0,0x6
ffffffffc0200c04:	2e050513          	addi	a0,a0,736 # ffffffffc0206ee0 <etext+0x696>
ffffffffc0200c08:	86dff0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc0200c0c <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
ffffffffc0200c0c:	1101                	addi	sp,sp,-32
ffffffffc0200c0e:	e822                	sd	s0,16(sp)
    // dispatch based on what type of trap occurred
//    cputs("some trap");
    if (current == NULL) {
ffffffffc0200c10:	0009d417          	auipc	s0,0x9d
ffffffffc0200c14:	3e040413          	addi	s0,s0,992 # ffffffffc029dff0 <current>
ffffffffc0200c18:	6018                	ld	a4,0(s0)
trap(struct trapframe *tf) {
ffffffffc0200c1a:	ec06                	sd	ra,24(sp)
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c1c:	11853683          	ld	a3,280(a0)
    if (current == NULL) {
ffffffffc0200c20:	c329                	beqz	a4,ffffffffc0200c62 <trap+0x56>
ffffffffc0200c22:	e426                	sd	s1,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c24:	10053483          	ld	s1,256(a0)
ffffffffc0200c28:	e04a                	sd	s2,0(sp)
        trap_dispatch(tf);
    } else {
        struct trapframe *otf = current->tf;
ffffffffc0200c2a:	0a073903          	ld	s2,160(a4)
        current->tf = tf;
ffffffffc0200c2e:	f348                	sd	a0,160(a4)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c30:	1004f493          	andi	s1,s1,256
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c34:	0206c463          	bltz	a3,ffffffffc0200c5c <trap+0x50>
        exception_handler(tf);
ffffffffc0200c38:	df7ff0ef          	jal	ffffffffc0200a2e <exception_handler>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0200c3c:	601c                	ld	a5,0(s0)
ffffffffc0200c3e:	0b27b023          	sd	s2,160(a5)
        if (!in_kernel) {
ffffffffc0200c42:	e499                	bnez	s1,ffffffffc0200c50 <trap+0x44>
            if (current->flags & PF_EXITING) {
ffffffffc0200c44:	0b07a703          	lw	a4,176(a5)
ffffffffc0200c48:	8b05                	andi	a4,a4,1
ffffffffc0200c4a:	ef0d                	bnez	a4,ffffffffc0200c84 <trap+0x78>
                do_exit(-E_KILLED);
            }
            if (current->need_resched) {
ffffffffc0200c4c:	6f9c                	ld	a5,24(a5)
ffffffffc0200c4e:	e785                	bnez	a5,ffffffffc0200c76 <trap+0x6a>
                schedule();
            }
        }
    }
}
ffffffffc0200c50:	60e2                	ld	ra,24(sp)
ffffffffc0200c52:	6442                	ld	s0,16(sp)
ffffffffc0200c54:	64a2                	ld	s1,8(sp)
ffffffffc0200c56:	6902                	ld	s2,0(sp)
ffffffffc0200c58:	6105                	addi	sp,sp,32
ffffffffc0200c5a:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200c5c:	d41ff0ef          	jal	ffffffffc020099c <interrupt_handler>
ffffffffc0200c60:	bff1                	j	ffffffffc0200c3c <trap+0x30>
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c62:	0006c663          	bltz	a3,ffffffffc0200c6e <trap+0x62>
}
ffffffffc0200c66:	6442                	ld	s0,16(sp)
ffffffffc0200c68:	60e2                	ld	ra,24(sp)
ffffffffc0200c6a:	6105                	addi	sp,sp,32
        exception_handler(tf);
ffffffffc0200c6c:	b3c9                	j	ffffffffc0200a2e <exception_handler>
}
ffffffffc0200c6e:	6442                	ld	s0,16(sp)
ffffffffc0200c70:	60e2                	ld	ra,24(sp)
ffffffffc0200c72:	6105                	addi	sp,sp,32
        interrupt_handler(tf);
ffffffffc0200c74:	b325                	j	ffffffffc020099c <interrupt_handler>
}
ffffffffc0200c76:	6442                	ld	s0,16(sp)
                schedule();
ffffffffc0200c78:	64a2                	ld	s1,8(sp)
ffffffffc0200c7a:	6902                	ld	s2,0(sp)
}
ffffffffc0200c7c:	60e2                	ld	ra,24(sp)
ffffffffc0200c7e:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200c80:	5a00506f          	j	ffffffffc0206220 <schedule>
                do_exit(-E_KILLED);
ffffffffc0200c84:	555d                	li	a0,-9
ffffffffc0200c86:	03b040ef          	jal	ffffffffc02054c0 <do_exit>
            if (current->need_resched) {
ffffffffc0200c8a:	601c                	ld	a5,0(s0)
ffffffffc0200c8c:	b7c1                	j	ffffffffc0200c4c <trap+0x40>
	...

ffffffffc0200c90 <__alltraps>:
    LOAD x2, 2*REGBYTES(sp) #如果是用户态产生的中断，此时sp恢复为用户栈指针
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200c90:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0200c94:	00011463          	bnez	sp,ffffffffc0200c9c <__alltraps+0xc>
ffffffffc0200c98:	14002173          	csrr	sp,sscratch
ffffffffc0200c9c:	712d                	addi	sp,sp,-288
ffffffffc0200c9e:	e002                	sd	zero,0(sp)
ffffffffc0200ca0:	e406                	sd	ra,8(sp)
ffffffffc0200ca2:	ec0e                	sd	gp,24(sp)
ffffffffc0200ca4:	f012                	sd	tp,32(sp)
ffffffffc0200ca6:	f416                	sd	t0,40(sp)
ffffffffc0200ca8:	f81a                	sd	t1,48(sp)
ffffffffc0200caa:	fc1e                	sd	t2,56(sp)
ffffffffc0200cac:	e0a2                	sd	s0,64(sp)
ffffffffc0200cae:	e4a6                	sd	s1,72(sp)
ffffffffc0200cb0:	e8aa                	sd	a0,80(sp)
ffffffffc0200cb2:	ecae                	sd	a1,88(sp)
ffffffffc0200cb4:	f0b2                	sd	a2,96(sp)
ffffffffc0200cb6:	f4b6                	sd	a3,104(sp)
ffffffffc0200cb8:	f8ba                	sd	a4,112(sp)
ffffffffc0200cba:	fcbe                	sd	a5,120(sp)
ffffffffc0200cbc:	e142                	sd	a6,128(sp)
ffffffffc0200cbe:	e546                	sd	a7,136(sp)
ffffffffc0200cc0:	e94a                	sd	s2,144(sp)
ffffffffc0200cc2:	ed4e                	sd	s3,152(sp)
ffffffffc0200cc4:	f152                	sd	s4,160(sp)
ffffffffc0200cc6:	f556                	sd	s5,168(sp)
ffffffffc0200cc8:	f95a                	sd	s6,176(sp)
ffffffffc0200cca:	fd5e                	sd	s7,184(sp)
ffffffffc0200ccc:	e1e2                	sd	s8,192(sp)
ffffffffc0200cce:	e5e6                	sd	s9,200(sp)
ffffffffc0200cd0:	e9ea                	sd	s10,208(sp)
ffffffffc0200cd2:	edee                	sd	s11,216(sp)
ffffffffc0200cd4:	f1f2                	sd	t3,224(sp)
ffffffffc0200cd6:	f5f6                	sd	t4,232(sp)
ffffffffc0200cd8:	f9fa                	sd	t5,240(sp)
ffffffffc0200cda:	fdfe                	sd	t6,248(sp)
ffffffffc0200cdc:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200ce0:	100024f3          	csrr	s1,sstatus
ffffffffc0200ce4:	14102973          	csrr	s2,sepc
ffffffffc0200ce8:	143029f3          	csrr	s3,stval
ffffffffc0200cec:	14202a73          	csrr	s4,scause
ffffffffc0200cf0:	e822                	sd	s0,16(sp)
ffffffffc0200cf2:	e226                	sd	s1,256(sp)
ffffffffc0200cf4:	e64a                	sd	s2,264(sp)
ffffffffc0200cf6:	ea4e                	sd	s3,272(sp)
ffffffffc0200cf8:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200cfa:	850a                	mv	a0,sp
    jal trap
ffffffffc0200cfc:	f11ff0ef          	jal	ffffffffc0200c0c <trap>

ffffffffc0200d00 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200d00:	6492                	ld	s1,256(sp)
ffffffffc0200d02:	6932                	ld	s2,264(sp)
ffffffffc0200d04:	1004f413          	andi	s0,s1,256
ffffffffc0200d08:	e401                	bnez	s0,ffffffffc0200d10 <__trapret+0x10>
ffffffffc0200d0a:	1200                	addi	s0,sp,288
ffffffffc0200d0c:	14041073          	csrw	sscratch,s0
ffffffffc0200d10:	10049073          	csrw	sstatus,s1
ffffffffc0200d14:	14191073          	csrw	sepc,s2
ffffffffc0200d18:	60a2                	ld	ra,8(sp)
ffffffffc0200d1a:	61e2                	ld	gp,24(sp)
ffffffffc0200d1c:	7202                	ld	tp,32(sp)
ffffffffc0200d1e:	72a2                	ld	t0,40(sp)
ffffffffc0200d20:	7342                	ld	t1,48(sp)
ffffffffc0200d22:	73e2                	ld	t2,56(sp)
ffffffffc0200d24:	6406                	ld	s0,64(sp)
ffffffffc0200d26:	64a6                	ld	s1,72(sp)
ffffffffc0200d28:	6546                	ld	a0,80(sp)
ffffffffc0200d2a:	65e6                	ld	a1,88(sp)
ffffffffc0200d2c:	7606                	ld	a2,96(sp)
ffffffffc0200d2e:	76a6                	ld	a3,104(sp)
ffffffffc0200d30:	7746                	ld	a4,112(sp)
ffffffffc0200d32:	77e6                	ld	a5,120(sp)
ffffffffc0200d34:	680a                	ld	a6,128(sp)
ffffffffc0200d36:	68aa                	ld	a7,136(sp)
ffffffffc0200d38:	694a                	ld	s2,144(sp)
ffffffffc0200d3a:	69ea                	ld	s3,152(sp)
ffffffffc0200d3c:	7a0a                	ld	s4,160(sp)
ffffffffc0200d3e:	7aaa                	ld	s5,168(sp)
ffffffffc0200d40:	7b4a                	ld	s6,176(sp)
ffffffffc0200d42:	7bea                	ld	s7,184(sp)
ffffffffc0200d44:	6c0e                	ld	s8,192(sp)
ffffffffc0200d46:	6cae                	ld	s9,200(sp)
ffffffffc0200d48:	6d4e                	ld	s10,208(sp)
ffffffffc0200d4a:	6dee                	ld	s11,216(sp)
ffffffffc0200d4c:	7e0e                	ld	t3,224(sp)
ffffffffc0200d4e:	7eae                	ld	t4,232(sp)
ffffffffc0200d50:	7f4e                	ld	t5,240(sp)
ffffffffc0200d52:	7fee                	ld	t6,248(sp)
ffffffffc0200d54:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200d56:	10200073          	sret

ffffffffc0200d5a <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200d5a:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200d5c:	b755                	j	ffffffffc0200d00 <__trapret>

ffffffffc0200d5e <kernel_execve_ret>:

    .global kernel_execve_ret
kernel_execve_ret:
    // adjust sp to beneath kstacktop of current process
    addi a1, a1, -36*REGBYTES
ffffffffc0200d5e:	ee058593          	addi	a1,a1,-288 # 1ee0 <_binary_obj___user_softint_out_size-0x6758>

    // copy from previous trapframe to new trapframe
    LOAD s1, 35*REGBYTES(a0)
ffffffffc0200d62:	11853483          	ld	s1,280(a0)
    STORE s1, 35*REGBYTES(a1)
ffffffffc0200d66:	1095bc23          	sd	s1,280(a1)
    LOAD s1, 34*REGBYTES(a0)
ffffffffc0200d6a:	11053483          	ld	s1,272(a0)
    STORE s1, 34*REGBYTES(a1)
ffffffffc0200d6e:	1095b823          	sd	s1,272(a1)
    LOAD s1, 33*REGBYTES(a0)
ffffffffc0200d72:	10853483          	ld	s1,264(a0)
    STORE s1, 33*REGBYTES(a1)
ffffffffc0200d76:	1095b423          	sd	s1,264(a1)
    LOAD s1, 32*REGBYTES(a0)
ffffffffc0200d7a:	10053483          	ld	s1,256(a0)
    STORE s1, 32*REGBYTES(a1)
ffffffffc0200d7e:	1095b023          	sd	s1,256(a1)
    LOAD s1, 31*REGBYTES(a0)
ffffffffc0200d82:	7d64                	ld	s1,248(a0)
    STORE s1, 31*REGBYTES(a1)
ffffffffc0200d84:	fde4                	sd	s1,248(a1)
    LOAD s1, 30*REGBYTES(a0)
ffffffffc0200d86:	7964                	ld	s1,240(a0)
    STORE s1, 30*REGBYTES(a1)
ffffffffc0200d88:	f9e4                	sd	s1,240(a1)
    LOAD s1, 29*REGBYTES(a0)
ffffffffc0200d8a:	7564                	ld	s1,232(a0)
    STORE s1, 29*REGBYTES(a1)
ffffffffc0200d8c:	f5e4                	sd	s1,232(a1)
    LOAD s1, 28*REGBYTES(a0)
ffffffffc0200d8e:	7164                	ld	s1,224(a0)
    STORE s1, 28*REGBYTES(a1)
ffffffffc0200d90:	f1e4                	sd	s1,224(a1)
    LOAD s1, 27*REGBYTES(a0)
ffffffffc0200d92:	6d64                	ld	s1,216(a0)
    STORE s1, 27*REGBYTES(a1)
ffffffffc0200d94:	ede4                	sd	s1,216(a1)
    LOAD s1, 26*REGBYTES(a0)
ffffffffc0200d96:	6964                	ld	s1,208(a0)
    STORE s1, 26*REGBYTES(a1)
ffffffffc0200d98:	e9e4                	sd	s1,208(a1)
    LOAD s1, 25*REGBYTES(a0)
ffffffffc0200d9a:	6564                	ld	s1,200(a0)
    STORE s1, 25*REGBYTES(a1)
ffffffffc0200d9c:	e5e4                	sd	s1,200(a1)
    LOAD s1, 24*REGBYTES(a0)
ffffffffc0200d9e:	6164                	ld	s1,192(a0)
    STORE s1, 24*REGBYTES(a1)
ffffffffc0200da0:	e1e4                	sd	s1,192(a1)
    LOAD s1, 23*REGBYTES(a0)
ffffffffc0200da2:	7d44                	ld	s1,184(a0)
    STORE s1, 23*REGBYTES(a1)
ffffffffc0200da4:	fdc4                	sd	s1,184(a1)
    LOAD s1, 22*REGBYTES(a0)
ffffffffc0200da6:	7944                	ld	s1,176(a0)
    STORE s1, 22*REGBYTES(a1)
ffffffffc0200da8:	f9c4                	sd	s1,176(a1)
    LOAD s1, 21*REGBYTES(a0)
ffffffffc0200daa:	7544                	ld	s1,168(a0)
    STORE s1, 21*REGBYTES(a1)
ffffffffc0200dac:	f5c4                	sd	s1,168(a1)
    LOAD s1, 20*REGBYTES(a0)
ffffffffc0200dae:	7144                	ld	s1,160(a0)
    STORE s1, 20*REGBYTES(a1)
ffffffffc0200db0:	f1c4                	sd	s1,160(a1)
    LOAD s1, 19*REGBYTES(a0)
ffffffffc0200db2:	6d44                	ld	s1,152(a0)
    STORE s1, 19*REGBYTES(a1)
ffffffffc0200db4:	edc4                	sd	s1,152(a1)
    LOAD s1, 18*REGBYTES(a0)
ffffffffc0200db6:	6944                	ld	s1,144(a0)
    STORE s1, 18*REGBYTES(a1)
ffffffffc0200db8:	e9c4                	sd	s1,144(a1)
    LOAD s1, 17*REGBYTES(a0)
ffffffffc0200dba:	6544                	ld	s1,136(a0)
    STORE s1, 17*REGBYTES(a1)
ffffffffc0200dbc:	e5c4                	sd	s1,136(a1)
    LOAD s1, 16*REGBYTES(a0)
ffffffffc0200dbe:	6144                	ld	s1,128(a0)
    STORE s1, 16*REGBYTES(a1)
ffffffffc0200dc0:	e1c4                	sd	s1,128(a1)
    LOAD s1, 15*REGBYTES(a0)
ffffffffc0200dc2:	7d24                	ld	s1,120(a0)
    STORE s1, 15*REGBYTES(a1)
ffffffffc0200dc4:	fda4                	sd	s1,120(a1)
    LOAD s1, 14*REGBYTES(a0)
ffffffffc0200dc6:	7924                	ld	s1,112(a0)
    STORE s1, 14*REGBYTES(a1)
ffffffffc0200dc8:	f9a4                	sd	s1,112(a1)
    LOAD s1, 13*REGBYTES(a0)
ffffffffc0200dca:	7524                	ld	s1,104(a0)
    STORE s1, 13*REGBYTES(a1)
ffffffffc0200dcc:	f5a4                	sd	s1,104(a1)
    LOAD s1, 12*REGBYTES(a0)
ffffffffc0200dce:	7124                	ld	s1,96(a0)
    STORE s1, 12*REGBYTES(a1)
ffffffffc0200dd0:	f1a4                	sd	s1,96(a1)
    LOAD s1, 11*REGBYTES(a0)
ffffffffc0200dd2:	6d24                	ld	s1,88(a0)
    STORE s1, 11*REGBYTES(a1)
ffffffffc0200dd4:	eda4                	sd	s1,88(a1)
    LOAD s1, 10*REGBYTES(a0)
ffffffffc0200dd6:	6924                	ld	s1,80(a0)
    STORE s1, 10*REGBYTES(a1)
ffffffffc0200dd8:	e9a4                	sd	s1,80(a1)
    LOAD s1, 9*REGBYTES(a0)
ffffffffc0200dda:	6524                	ld	s1,72(a0)
    STORE s1, 9*REGBYTES(a1)
ffffffffc0200ddc:	e5a4                	sd	s1,72(a1)
    LOAD s1, 8*REGBYTES(a0)
ffffffffc0200dde:	6124                	ld	s1,64(a0)
    STORE s1, 8*REGBYTES(a1)
ffffffffc0200de0:	e1a4                	sd	s1,64(a1)
    LOAD s1, 7*REGBYTES(a0)
ffffffffc0200de2:	7d04                	ld	s1,56(a0)
    STORE s1, 7*REGBYTES(a1)
ffffffffc0200de4:	fd84                	sd	s1,56(a1)
    LOAD s1, 6*REGBYTES(a0)
ffffffffc0200de6:	7904                	ld	s1,48(a0)
    STORE s1, 6*REGBYTES(a1)
ffffffffc0200de8:	f984                	sd	s1,48(a1)
    LOAD s1, 5*REGBYTES(a0)
ffffffffc0200dea:	7504                	ld	s1,40(a0)
    STORE s1, 5*REGBYTES(a1)
ffffffffc0200dec:	f584                	sd	s1,40(a1)
    LOAD s1, 4*REGBYTES(a0)
ffffffffc0200dee:	7104                	ld	s1,32(a0)
    STORE s1, 4*REGBYTES(a1)
ffffffffc0200df0:	f184                	sd	s1,32(a1)
    LOAD s1, 3*REGBYTES(a0)
ffffffffc0200df2:	6d04                	ld	s1,24(a0)
    STORE s1, 3*REGBYTES(a1)
ffffffffc0200df4:	ed84                	sd	s1,24(a1)
    LOAD s1, 2*REGBYTES(a0)
ffffffffc0200df6:	6904                	ld	s1,16(a0)
    STORE s1, 2*REGBYTES(a1)
ffffffffc0200df8:	e984                	sd	s1,16(a1)
    LOAD s1, 1*REGBYTES(a0)
ffffffffc0200dfa:	6504                	ld	s1,8(a0)
    STORE s1, 1*REGBYTES(a1)
ffffffffc0200dfc:	e584                	sd	s1,8(a1)
    LOAD s1, 0*REGBYTES(a0)
ffffffffc0200dfe:	6104                	ld	s1,0(a0)
    STORE s1, 0*REGBYTES(a1)
ffffffffc0200e00:	e184                	sd	s1,0(a1)

    // acutually adjust sp
    move sp, a1
ffffffffc0200e02:	812e                	mv	sp,a1
ffffffffc0200e04:	bdf5                	j	ffffffffc0200d00 <__trapret>

ffffffffc0200e06 <cow_copy_range>:
        }
    }
    return 0;
}

int cow_copy_range(pde_t *to, pde_t *from, uintptr_t start, uintptr_t end) {
ffffffffc0200e06:	711d                	addi	sp,sp,-96
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0200e08:	00d667b3          	or	a5,a2,a3
int cow_copy_range(pde_t *to, pde_t *from, uintptr_t start, uintptr_t end) {
ffffffffc0200e0c:	ec86                	sd	ra,88(sp)
ffffffffc0200e0e:	e8a2                	sd	s0,80(sp)
ffffffffc0200e10:	e4a6                	sd	s1,72(sp)
ffffffffc0200e12:	e0ca                	sd	s2,64(sp)
ffffffffc0200e14:	fc4e                	sd	s3,56(sp)
ffffffffc0200e16:	f852                	sd	s4,48(sp)
ffffffffc0200e18:	f456                	sd	s5,40(sp)
ffffffffc0200e1a:	f05a                	sd	s6,32(sp)
ffffffffc0200e1c:	ec5e                	sd	s7,24(sp)
ffffffffc0200e1e:	e862                	sd	s8,16(sp)
ffffffffc0200e20:	e466                	sd	s9,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0200e22:	17d2                	slli	a5,a5,0x34
ffffffffc0200e24:	12079463          	bnez	a5,ffffffffc0200f4c <cow_copy_range+0x146>
    assert(USER_ACCESS(start, end));
ffffffffc0200e28:	002007b7          	lui	a5,0x200
ffffffffc0200e2c:	8432                	mv	s0,a2
ffffffffc0200e2e:	0ef66f63          	bltu	a2,a5,ffffffffc0200f2c <cow_copy_range+0x126>
ffffffffc0200e32:	84b6                	mv	s1,a3
ffffffffc0200e34:	0ed67c63          	bgeu	a2,a3,ffffffffc0200f2c <cow_copy_range+0x126>
ffffffffc0200e38:	4785                	li	a5,1
ffffffffc0200e3a:	07fe                	slli	a5,a5,0x1f
ffffffffc0200e3c:	0ed7e863          	bltu	a5,a3,ffffffffc0200f2c <cow_copy_range+0x126>
ffffffffc0200e40:	8a2a                	mv	s4,a0
ffffffffc0200e42:	892e                	mv	s2,a1
            assert(page != NULL);
            int ret = 0;
            ret = page_insert(to, page, start, perm);
            assert(ret == 0);
        }
        start += PGSIZE;
ffffffffc0200e44:	6985                	lui	s3,0x1
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0200e46:	0009db97          	auipc	s7,0x9d
ffffffffc0200e4a:	16ab8b93          	addi	s7,s7,362 # ffffffffc029dfb0 <npage>
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0200e4e:	0009db17          	auipc	s6,0x9d
ffffffffc0200e52:	16ab0b13          	addi	s6,s6,362 # ffffffffc029dfb8 <pages>
ffffffffc0200e56:	00008a97          	auipc	s5,0x8
ffffffffc0200e5a:	0faa8a93          	addi	s5,s5,250 # ffffffffc0208f50 <nbase>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0200e5e:	00200cb7          	lui	s9,0x200
ffffffffc0200e62:	ffe00c37          	lui	s8,0xffe00
        pte_t *ptep = get_pte(from, start, 0);
ffffffffc0200e66:	4601                	li	a2,0
ffffffffc0200e68:	85a2                	mv	a1,s0
ffffffffc0200e6a:	854a                	mv	a0,s2
ffffffffc0200e6c:	49e010ef          	jal	ffffffffc020230a <get_pte>
        if (ptep == NULL) {
ffffffffc0200e70:	cd35                	beqz	a0,ffffffffc0200eec <cow_copy_range+0xe6>
        if (*ptep & PTE_V) {
ffffffffc0200e72:	6114                	ld	a3,0(a0)
ffffffffc0200e74:	0016f793          	andi	a5,a3,1
ffffffffc0200e78:	e39d                	bnez	a5,ffffffffc0200e9e <cow_copy_range+0x98>
        start += PGSIZE;
ffffffffc0200e7a:	944e                	add	s0,s0,s3
    } while (start != 0 && start < end);
ffffffffc0200e7c:	c019                	beqz	s0,ffffffffc0200e82 <cow_copy_range+0x7c>
ffffffffc0200e7e:	fe9464e3          	bltu	s0,s1,ffffffffc0200e66 <cow_copy_range+0x60>
    return 0;
}
ffffffffc0200e82:	60e6                	ld	ra,88(sp)
ffffffffc0200e84:	6446                	ld	s0,80(sp)
ffffffffc0200e86:	64a6                	ld	s1,72(sp)
ffffffffc0200e88:	6906                	ld	s2,64(sp)
ffffffffc0200e8a:	79e2                	ld	s3,56(sp)
ffffffffc0200e8c:	7a42                	ld	s4,48(sp)
ffffffffc0200e8e:	7aa2                	ld	s5,40(sp)
ffffffffc0200e90:	7b02                	ld	s6,32(sp)
ffffffffc0200e92:	6be2                	ld	s7,24(sp)
ffffffffc0200e94:	6c42                	ld	s8,16(sp)
ffffffffc0200e96:	6ca2                	ld	s9,8(sp)
ffffffffc0200e98:	4501                	li	a0,0
ffffffffc0200e9a:	6125                	addi	sp,sp,96
ffffffffc0200e9c:	8082                	ret
            *ptep &= ~PTE_W;
ffffffffc0200e9e:	ffb6f793          	andi	a5,a3,-5
ffffffffc0200ea2:	e11c                	sd	a5,0(a0)
    if (PPN(pa) >= npage) {
ffffffffc0200ea4:	000bb703          	ld	a4,0(s7)
static inline struct Page *
pte2page(pte_t pte) {
    if (!(pte & PTE_V)) {
        panic("pte2page called with invalid pte");
    }
    return pa2page(PTE_ADDR(pte));
ffffffffc0200ea8:	078a                	slli	a5,a5,0x2
ffffffffc0200eaa:	83b1                	srli	a5,a5,0xc
            uint32_t perm = (*ptep & PTE_USER & ~PTE_W);
ffffffffc0200eac:	8aed                	andi	a3,a3,27
    if (PPN(pa) >= npage) {
ffffffffc0200eae:	06e7f363          	bgeu	a5,a4,ffffffffc0200f14 <cow_copy_range+0x10e>
    return &pages[PPN(pa) - nbase];
ffffffffc0200eb2:	000ab703          	ld	a4,0(s5)
ffffffffc0200eb6:	000b3583          	ld	a1,0(s6)
ffffffffc0200eba:	8f99                	sub	a5,a5,a4
ffffffffc0200ebc:	079a                	slli	a5,a5,0x6
ffffffffc0200ebe:	95be                	add	a1,a1,a5
            assert(page != NULL);
ffffffffc0200ec0:	c995                	beqz	a1,ffffffffc0200ef4 <cow_copy_range+0xee>
            ret = page_insert(to, page, start, perm);
ffffffffc0200ec2:	8622                	mv	a2,s0
ffffffffc0200ec4:	8552                	mv	a0,s4
ffffffffc0200ec6:	311010ef          	jal	ffffffffc02029d6 <page_insert>
            assert(ret == 0);
ffffffffc0200eca:	d945                	beqz	a0,ffffffffc0200e7a <cow_copy_range+0x74>
ffffffffc0200ecc:	00006697          	auipc	a3,0x6
ffffffffc0200ed0:	31468693          	addi	a3,a3,788 # ffffffffc02071e0 <etext+0x996>
ffffffffc0200ed4:	00006617          	auipc	a2,0x6
ffffffffc0200ed8:	ff460613          	addi	a2,a2,-12 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0200edc:	06b00593          	li	a1,107
ffffffffc0200ee0:	00006517          	auipc	a0,0x6
ffffffffc0200ee4:	29850513          	addi	a0,a0,664 # ffffffffc0207178 <etext+0x92e>
ffffffffc0200ee8:	d8cff0ef          	jal	ffffffffc0200474 <__panic>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0200eec:	9466                	add	s0,s0,s9
ffffffffc0200eee:	01847433          	and	s0,s0,s8
            continue;
ffffffffc0200ef2:	b769                	j	ffffffffc0200e7c <cow_copy_range+0x76>
            assert(page != NULL);
ffffffffc0200ef4:	00006697          	auipc	a3,0x6
ffffffffc0200ef8:	2dc68693          	addi	a3,a3,732 # ffffffffc02071d0 <etext+0x986>
ffffffffc0200efc:	00006617          	auipc	a2,0x6
ffffffffc0200f00:	fcc60613          	addi	a2,a2,-52 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0200f04:	06800593          	li	a1,104
ffffffffc0200f08:	00006517          	auipc	a0,0x6
ffffffffc0200f0c:	27050513          	addi	a0,a0,624 # ffffffffc0207178 <etext+0x92e>
ffffffffc0200f10:	d64ff0ef          	jal	ffffffffc0200474 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0200f14:	00006617          	auipc	a2,0x6
ffffffffc0200f18:	28c60613          	addi	a2,a2,652 # ffffffffc02071a0 <etext+0x956>
ffffffffc0200f1c:	06300593          	li	a1,99
ffffffffc0200f20:	00006517          	auipc	a0,0x6
ffffffffc0200f24:	2a050513          	addi	a0,a0,672 # ffffffffc02071c0 <etext+0x976>
ffffffffc0200f28:	d4cff0ef          	jal	ffffffffc0200474 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0200f2c:	00006697          	auipc	a3,0x6
ffffffffc0200f30:	25c68693          	addi	a3,a3,604 # ffffffffc0207188 <etext+0x93e>
ffffffffc0200f34:	00006617          	auipc	a2,0x6
ffffffffc0200f38:	f9460613          	addi	a2,a2,-108 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0200f3c:	05d00593          	li	a1,93
ffffffffc0200f40:	00006517          	auipc	a0,0x6
ffffffffc0200f44:	23850513          	addi	a0,a0,568 # ffffffffc0207178 <etext+0x92e>
ffffffffc0200f48:	d2cff0ef          	jal	ffffffffc0200474 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0200f4c:	00006697          	auipc	a3,0x6
ffffffffc0200f50:	1fc68693          	addi	a3,a3,508 # ffffffffc0207148 <etext+0x8fe>
ffffffffc0200f54:	00006617          	auipc	a2,0x6
ffffffffc0200f58:	f7460613          	addi	a2,a2,-140 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0200f5c:	05c00593          	li	a1,92
ffffffffc0200f60:	00006517          	auipc	a0,0x6
ffffffffc0200f64:	21850513          	addi	a0,a0,536 # ffffffffc0207178 <etext+0x92e>
ffffffffc0200f68:	d0cff0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc0200f6c <cow_copy_mmap>:
cow_copy_mmap(struct mm_struct *to, struct mm_struct *from) {
ffffffffc0200f6c:	1101                	addi	sp,sp,-32
ffffffffc0200f6e:	ec06                	sd	ra,24(sp)
ffffffffc0200f70:	e822                	sd	s0,16(sp)
ffffffffc0200f72:	e426                	sd	s1,8(sp)
ffffffffc0200f74:	e04a                	sd	s2,0(sp)
    assert(to != NULL && from != NULL);
ffffffffc0200f76:	cd31                	beqz	a0,ffffffffc0200fd2 <cow_copy_mmap+0x66>
ffffffffc0200f78:	892a                	mv	s2,a0
ffffffffc0200f7a:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc0200f7c:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc0200f7e:	e98d                	bnez	a1,ffffffffc0200fb0 <cow_copy_mmap+0x44>
ffffffffc0200f80:	a889                	j	ffffffffc0200fd2 <cow_copy_mmap+0x66>
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc0200f82:	ff043583          	ld	a1,-16(s0)
ffffffffc0200f86:	ff842603          	lw	a2,-8(s0)
ffffffffc0200f8a:	fe843503          	ld	a0,-24(s0)
ffffffffc0200f8e:	520030ef          	jal	ffffffffc02044ae <vma_create>
ffffffffc0200f92:	85aa                	mv	a1,a0
        if (nvma == NULL) {
ffffffffc0200f94:	c905                	beqz	a0,ffffffffc0200fc4 <cow_copy_mmap+0x58>
        insert_vma_struct(to, nvma);
ffffffffc0200f96:	854a                	mv	a0,s2
ffffffffc0200f98:	584030ef          	jal	ffffffffc020451c <insert_vma_struct>
        if (cow_copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end) != 0) {
ffffffffc0200f9c:	ff043683          	ld	a3,-16(s0)
ffffffffc0200fa0:	fe843603          	ld	a2,-24(s0)
ffffffffc0200fa4:	6c8c                	ld	a1,24(s1)
ffffffffc0200fa6:	01893503          	ld	a0,24(s2)
ffffffffc0200faa:	e5dff0ef          	jal	ffffffffc0200e06 <cow_copy_range>
ffffffffc0200fae:	e919                	bnez	a0,ffffffffc0200fc4 <cow_copy_mmap+0x58>
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
ffffffffc0200fb0:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list) {
ffffffffc0200fb2:	fc8498e3          	bne	s1,s0,ffffffffc0200f82 <cow_copy_mmap+0x16>
}
ffffffffc0200fb6:	60e2                	ld	ra,24(sp)
ffffffffc0200fb8:	6442                	ld	s0,16(sp)
ffffffffc0200fba:	64a2                	ld	s1,8(sp)
ffffffffc0200fbc:	6902                	ld	s2,0(sp)
    return 0;
ffffffffc0200fbe:	4501                	li	a0,0
}
ffffffffc0200fc0:	6105                	addi	sp,sp,32
ffffffffc0200fc2:	8082                	ret
ffffffffc0200fc4:	60e2                	ld	ra,24(sp)
ffffffffc0200fc6:	6442                	ld	s0,16(sp)
ffffffffc0200fc8:	64a2                	ld	s1,8(sp)
ffffffffc0200fca:	6902                	ld	s2,0(sp)
            return -E_NO_MEM;
ffffffffc0200fcc:	5571                	li	a0,-4
}
ffffffffc0200fce:	6105                	addi	sp,sp,32
ffffffffc0200fd0:	8082                	ret
    assert(to != NULL && from != NULL);
ffffffffc0200fd2:	00006697          	auipc	a3,0x6
ffffffffc0200fd6:	21e68693          	addi	a3,a3,542 # ffffffffc02071f0 <etext+0x9a6>
ffffffffc0200fda:	00006617          	auipc	a2,0x6
ffffffffc0200fde:	eee60613          	addi	a2,a2,-274 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0200fe2:	04a00593          	li	a1,74
ffffffffc0200fe6:	00006517          	auipc	a0,0x6
ffffffffc0200fea:	19250513          	addi	a0,a0,402 # ffffffffc0207178 <etext+0x92e>
ffffffffc0200fee:	c86ff0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc0200ff2 <cow_copy_mm>:
cow_copy_mm(struct proc_struct *proc) {
ffffffffc0200ff2:	715d                	addi	sp,sp,-80
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc0200ff4:	0009d797          	auipc	a5,0x9d
ffffffffc0200ff8:	ffc7b783          	ld	a5,-4(a5) # ffffffffc029dff0 <current>
cow_copy_mm(struct proc_struct *proc) {
ffffffffc0200ffc:	fc26                	sd	s1,56(sp)
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc0200ffe:	7784                	ld	s1,40(a5)
cow_copy_mm(struct proc_struct *proc) {
ffffffffc0201000:	e486                	sd	ra,72(sp)
ffffffffc0201002:	e0a2                	sd	s0,64(sp)
    if (oldmm == NULL) {
ffffffffc0201004:	c4e5                	beqz	s1,ffffffffc02010ec <cow_copy_mm+0xfa>
ffffffffc0201006:	f84a                	sd	s2,48(sp)
ffffffffc0201008:	f44e                	sd	s3,40(sp)
ffffffffc020100a:	89aa                	mv	s3,a0
    if ((mm = mm_create()) == NULL) {
ffffffffc020100c:	45a030ef          	jal	ffffffffc0204466 <mm_create>
ffffffffc0201010:	892a                	mv	s2,a0
ffffffffc0201012:	c565                	beqz	a0,ffffffffc02010fa <cow_copy_mm+0x108>
    if ((page = alloc_page()) == NULL) {
ffffffffc0201014:	4505                	li	a0,1
ffffffffc0201016:	1ea010ef          	jal	ffffffffc0202200 <alloc_pages>
ffffffffc020101a:	12050d63          	beqz	a0,ffffffffc0201154 <cow_copy_mm+0x162>
    return page - pages + nbase;
ffffffffc020101e:	f052                	sd	s4,32(sp)
ffffffffc0201020:	0009da17          	auipc	s4,0x9d
ffffffffc0201024:	f98a0a13          	addi	s4,s4,-104 # ffffffffc029dfb8 <pages>
ffffffffc0201028:	000a3683          	ld	a3,0(s4)
ffffffffc020102c:	ec56                	sd	s5,24(sp)
ffffffffc020102e:	00008a97          	auipc	s5,0x8
ffffffffc0201032:	f22a8a93          	addi	s5,s5,-222 # ffffffffc0208f50 <nbase>
ffffffffc0201036:	000ab703          	ld	a4,0(s5)
ffffffffc020103a:	40d506b3          	sub	a3,a0,a3
ffffffffc020103e:	e85a                	sd	s6,16(sp)
ffffffffc0201040:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0201042:	0009db17          	auipc	s6,0x9d
ffffffffc0201046:	f6eb0b13          	addi	s6,s6,-146 # ffffffffc029dfb0 <npage>
    return page - pages + nbase;
ffffffffc020104a:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc020104c:	000b3703          	ld	a4,0(s6)
ffffffffc0201050:	00c69793          	slli	a5,a3,0xc
ffffffffc0201054:	83b1                	srli	a5,a5,0xc
ffffffffc0201056:	e45e                	sd	s7,8(sp)
    return page2ppn(page) << PGSHIFT;
ffffffffc0201058:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020105a:	0ee7ff63          	bgeu	a5,a4,ffffffffc0201158 <cow_copy_mm+0x166>
ffffffffc020105e:	0009db97          	auipc	s7,0x9d
ffffffffc0201062:	f4ab8b93          	addi	s7,s7,-182 # ffffffffc029dfa8 <va_pa_offset>
ffffffffc0201066:	000bb783          	ld	a5,0(s7)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc020106a:	6605                	lui	a2,0x1
ffffffffc020106c:	0009d597          	auipc	a1,0x9d
ffffffffc0201070:	f345b583          	ld	a1,-204(a1) # ffffffffc029dfa0 <boot_pgdir>
ffffffffc0201074:	00f68433          	add	s0,a3,a5
ffffffffc0201078:	8522                	mv	a0,s0
ffffffffc020107a:	7b8050ef          	jal	ffffffffc0206832 <memcpy>
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020107e:	4785                	li	a5,1
    mm->pgdir = pgdir;
ffffffffc0201080:	00893c23          	sd	s0,24(s2)
}

static inline void
lock_mm(struct mm_struct *mm) {
    if (mm != NULL) {
        lock(&(mm->mm_lock));
ffffffffc0201084:	03848413          	addi	s0,s1,56
ffffffffc0201088:	40f437af          	amoor.d	a5,a5,(s0)
    return !test_and_set_bit(0, lock);
}

static inline void
lock(lock_t *lock) {
    while (!try_lock(lock)) {
ffffffffc020108c:	8b85                	andi	a5,a5,1
ffffffffc020108e:	cb91                	beqz	a5,ffffffffc02010a2 <cow_copy_mm+0xb0>
ffffffffc0201090:	e062                	sd	s8,0(sp)
ffffffffc0201092:	4c05                	li	s8,1
        schedule();
ffffffffc0201094:	18c050ef          	jal	ffffffffc0206220 <schedule>
ffffffffc0201098:	418437af          	amoor.d	a5,s8,(s0)
    while (!try_lock(lock)) {
ffffffffc020109c:	8b85                	andi	a5,a5,1
ffffffffc020109e:	fbfd                	bnez	a5,ffffffffc0201094 <cow_copy_mm+0xa2>
ffffffffc02010a0:	6c02                	ld	s8,0(sp)
        ret = cow_copy_mmap(mm, oldmm);
ffffffffc02010a2:	85a6                	mv	a1,s1
ffffffffc02010a4:	854a                	mv	a0,s2
ffffffffc02010a6:	ec7ff0ef          	jal	ffffffffc0200f6c <cow_copy_mmap>
ffffffffc02010aa:	842a                	mv	s0,a0
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02010ac:	57f9                	li	a5,-2
ffffffffc02010ae:	03848713          	addi	a4,s1,56
ffffffffc02010b2:	60f737af          	amoand.d	a5,a5,(a4)
ffffffffc02010b6:	8b85                	andi	a5,a5,1
    }
}

static inline void
unlock(lock_t *lock) {
    if (!test_and_clear_bit(0, lock)) {
ffffffffc02010b8:	cbf1                	beqz	a5,ffffffffc020118c <cow_copy_mm+0x19a>
    if (ret != 0) {
ffffffffc02010ba:	e139                	bnez	a0,ffffffffc0201100 <cow_copy_mm+0x10e>
    mm->mm_count += 1;
ffffffffc02010bc:	03092783          	lw	a5,48(s2)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc02010c0:	01893683          	ld	a3,24(s2)
ffffffffc02010c4:	c0200737          	lui	a4,0xc0200
ffffffffc02010c8:	2785                	addiw	a5,a5,1
ffffffffc02010ca:	02f92823          	sw	a5,48(s2)
    proc->mm = mm;
ffffffffc02010ce:	0329b423          	sd	s2,40(s3) # 1028 <_binary_obj___user_softint_out_size-0x7610>
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc02010d2:	0ae6e063          	bltu	a3,a4,ffffffffc0201172 <cow_copy_mm+0x180>
ffffffffc02010d6:	000bb783          	ld	a5,0(s7)
ffffffffc02010da:	7942                	ld	s2,48(sp)
ffffffffc02010dc:	7a02                	ld	s4,32(sp)
ffffffffc02010de:	8e9d                	sub	a3,a3,a5
ffffffffc02010e0:	0ad9b423          	sd	a3,168(s3)
ffffffffc02010e4:	6ae2                	ld	s5,24(sp)
ffffffffc02010e6:	79a2                	ld	s3,40(sp)
ffffffffc02010e8:	6b42                	ld	s6,16(sp)
ffffffffc02010ea:	6ba2                	ld	s7,8(sp)
        return 0;
ffffffffc02010ec:	4401                	li	s0,0
}
ffffffffc02010ee:	60a6                	ld	ra,72(sp)
ffffffffc02010f0:	8522                	mv	a0,s0
ffffffffc02010f2:	6406                	ld	s0,64(sp)
ffffffffc02010f4:	74e2                	ld	s1,56(sp)
ffffffffc02010f6:	6161                	addi	sp,sp,80
ffffffffc02010f8:	8082                	ret
ffffffffc02010fa:	7942                	ld	s2,48(sp)
ffffffffc02010fc:	79a2                	ld	s3,40(sp)
ffffffffc02010fe:	b7fd                	j	ffffffffc02010ec <cow_copy_mm+0xfa>
    exit_mmap(mm);
ffffffffc0201100:	854a                	mv	a0,s2
ffffffffc0201102:	60a030ef          	jal	ffffffffc020470c <exit_mmap>
    return pa2page(PADDR(kva));
ffffffffc0201106:	01893683          	ld	a3,24(s2)
ffffffffc020110a:	c02007b7          	lui	a5,0xc0200
ffffffffc020110e:	0af6e963          	bltu	a3,a5,ffffffffc02011c0 <cow_copy_mm+0x1ce>
ffffffffc0201112:	000bb703          	ld	a4,0(s7)
    if (PPN(pa) >= npage) {
ffffffffc0201116:	000b3783          	ld	a5,0(s6)
    return pa2page(PADDR(kva));
ffffffffc020111a:	8e99                	sub	a3,a3,a4
    if (PPN(pa) >= npage) {
ffffffffc020111c:	82b1                	srli	a3,a3,0xc
ffffffffc020111e:	08f6f463          	bgeu	a3,a5,ffffffffc02011a6 <cow_copy_mm+0x1b4>
    return &pages[PPN(pa) - nbase];
ffffffffc0201122:	000ab783          	ld	a5,0(s5)
ffffffffc0201126:	000a3503          	ld	a0,0(s4)
    free_page(kva2page(mm->pgdir));
ffffffffc020112a:	4585                	li	a1,1
ffffffffc020112c:	8e9d                	sub	a3,a3,a5
ffffffffc020112e:	069a                	slli	a3,a3,0x6
ffffffffc0201130:	9536                	add	a0,a0,a3
ffffffffc0201132:	15e010ef          	jal	ffffffffc0202290 <free_pages>
}
ffffffffc0201136:	7a02                	ld	s4,32(sp)
ffffffffc0201138:	6ae2                	ld	s5,24(sp)
ffffffffc020113a:	6b42                	ld	s6,16(sp)
ffffffffc020113c:	6ba2                	ld	s7,8(sp)
    mm_destroy(mm);
ffffffffc020113e:	854a                	mv	a0,s2
ffffffffc0201140:	4ac030ef          	jal	ffffffffc02045ec <mm_destroy>
}
ffffffffc0201144:	60a6                	ld	ra,72(sp)
ffffffffc0201146:	8522                	mv	a0,s0
ffffffffc0201148:	6406                	ld	s0,64(sp)
    mm_destroy(mm);
ffffffffc020114a:	7942                	ld	s2,48(sp)
ffffffffc020114c:	79a2                	ld	s3,40(sp)
}
ffffffffc020114e:	74e2                	ld	s1,56(sp)
ffffffffc0201150:	6161                	addi	sp,sp,80
ffffffffc0201152:	8082                	ret
    int ret = 0;
ffffffffc0201154:	4401                	li	s0,0
ffffffffc0201156:	b7e5                	j	ffffffffc020113e <cow_copy_mm+0x14c>
    return KADDR(page2pa(page));
ffffffffc0201158:	00006617          	auipc	a2,0x6
ffffffffc020115c:	0b860613          	addi	a2,a2,184 # ffffffffc0207210 <etext+0x9c6>
ffffffffc0201160:	06a00593          	li	a1,106
ffffffffc0201164:	00006517          	auipc	a0,0x6
ffffffffc0201168:	05c50513          	addi	a0,a0,92 # ffffffffc02071c0 <etext+0x976>
ffffffffc020116c:	e062                	sd	s8,0(sp)
ffffffffc020116e:	b06ff0ef          	jal	ffffffffc0200474 <__panic>
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0201172:	00006617          	auipc	a2,0x6
ffffffffc0201176:	0ee60613          	addi	a2,a2,238 # ffffffffc0207260 <etext+0xa16>
ffffffffc020117a:	03d00593          	li	a1,61
ffffffffc020117e:	00006517          	auipc	a0,0x6
ffffffffc0201182:	ffa50513          	addi	a0,a0,-6 # ffffffffc0207178 <etext+0x92e>
ffffffffc0201186:	e062                	sd	s8,0(sp)
ffffffffc0201188:	aecff0ef          	jal	ffffffffc0200474 <__panic>
        panic("Unlock failed.\n");
ffffffffc020118c:	00006617          	auipc	a2,0x6
ffffffffc0201190:	0ac60613          	addi	a2,a2,172 # ffffffffc0207238 <etext+0x9ee>
ffffffffc0201194:	03100593          	li	a1,49
ffffffffc0201198:	00006517          	auipc	a0,0x6
ffffffffc020119c:	0b050513          	addi	a0,a0,176 # ffffffffc0207248 <etext+0x9fe>
ffffffffc02011a0:	e062                	sd	s8,0(sp)
ffffffffc02011a2:	ad2ff0ef          	jal	ffffffffc0200474 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02011a6:	00006617          	auipc	a2,0x6
ffffffffc02011aa:	ffa60613          	addi	a2,a2,-6 # ffffffffc02071a0 <etext+0x956>
ffffffffc02011ae:	06300593          	li	a1,99
ffffffffc02011b2:	00006517          	auipc	a0,0x6
ffffffffc02011b6:	00e50513          	addi	a0,a0,14 # ffffffffc02071c0 <etext+0x976>
ffffffffc02011ba:	e062                	sd	s8,0(sp)
ffffffffc02011bc:	ab8ff0ef          	jal	ffffffffc0200474 <__panic>
    return pa2page(PADDR(kva));
ffffffffc02011c0:	00006617          	auipc	a2,0x6
ffffffffc02011c4:	0a060613          	addi	a2,a2,160 # ffffffffc0207260 <etext+0xa16>
ffffffffc02011c8:	06f00593          	li	a1,111
ffffffffc02011cc:	00006517          	auipc	a0,0x6
ffffffffc02011d0:	ff450513          	addi	a0,a0,-12 # ffffffffc02071c0 <etext+0x976>
ffffffffc02011d4:	e062                	sd	s8,0(sp)
ffffffffc02011d6:	a9eff0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc02011da <cow_pgfault>:

int 
cow_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc02011da:	715d                	addi	sp,sp,-80
    cprintf("COW page fault at 0x%x\n", addr);
ffffffffc02011dc:	85b2                	mv	a1,a2
cow_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc02011de:	f84a                	sd	s2,48(sp)
ffffffffc02011e0:	892a                	mv	s2,a0
    cprintf("COW page fault at 0x%x\n", addr);
ffffffffc02011e2:	00006517          	auipc	a0,0x6
ffffffffc02011e6:	0a650513          	addi	a0,a0,166 # ffffffffc0207288 <etext+0xa3e>
cow_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc02011ea:	e486                	sd	ra,72(sp)
ffffffffc02011ec:	fc26                	sd	s1,56(sp)
ffffffffc02011ee:	e0a2                	sd	s0,64(sp)
ffffffffc02011f0:	84b2                	mv	s1,a2
ffffffffc02011f2:	f44e                	sd	s3,40(sp)
ffffffffc02011f4:	f052                	sd	s4,32(sp)
ffffffffc02011f6:	ec56                	sd	s5,24(sp)
ffffffffc02011f8:	e85a                	sd	s6,16(sp)
ffffffffc02011fa:	e45e                	sd	s7,8(sp)
ffffffffc02011fc:	e062                	sd	s8,0(sp)
    cprintf("COW page fault at 0x%x\n", addr);
ffffffffc02011fe:	f83fe0ef          	jal	ffffffffc0200180 <cprintf>
    int ret = 0;
    pte_t *ptep = NULL;
    ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0201202:	01893503          	ld	a0,24(s2)
ffffffffc0201206:	4601                	li	a2,0
ffffffffc0201208:	85a6                	mv	a1,s1
ffffffffc020120a:	100010ef          	jal	ffffffffc020230a <get_pte>
    uint32_t perm = (*ptep & PTE_USER) | PTE_W;
ffffffffc020120e:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201210:	0017f713          	andi	a4,a5,1
ffffffffc0201214:	12070d63          	beqz	a4,ffffffffc020134e <cow_pgfault+0x174>
    if (PPN(pa) >= npage) {
ffffffffc0201218:	0009db97          	auipc	s7,0x9d
ffffffffc020121c:	d98b8b93          	addi	s7,s7,-616 # ffffffffc029dfb0 <npage>
ffffffffc0201220:	000bb703          	ld	a4,0(s7)
ffffffffc0201224:	01b7fa13          	andi	s4,a5,27
    return pa2page(PTE_ADDR(pte));
ffffffffc0201228:	078a                	slli	a5,a5,0x2
ffffffffc020122a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020122c:	10e7f563          	bgeu	a5,a4,ffffffffc0201336 <cow_pgfault+0x15c>
    return &pages[PPN(pa) - nbase];
ffffffffc0201230:	0009dc17          	auipc	s8,0x9d
ffffffffc0201234:	d88c0c13          	addi	s8,s8,-632 # ffffffffc029dfb8 <pages>
ffffffffc0201238:	000c3403          	ld	s0,0(s8)
ffffffffc020123c:	00008b17          	auipc	s6,0x8
ffffffffc0201240:	d14b3b03          	ld	s6,-748(s6) # ffffffffc0208f50 <nbase>
ffffffffc0201244:	416787b3          	sub	a5,a5,s6
ffffffffc0201248:	079a                	slli	a5,a5,0x6
ffffffffc020124a:	89aa                	mv	s3,a0
    struct Page *page = pte2page(*ptep);
    struct Page *npage = alloc_page();
ffffffffc020124c:	4505                	li	a0,1
ffffffffc020124e:	943e                	add	s0,s0,a5
ffffffffc0201250:	7b1000ef          	jal	ffffffffc0202200 <alloc_pages>
ffffffffc0201254:	8aaa                	mv	s5,a0
    assert(page != NULL);
ffffffffc0201256:	c061                	beqz	s0,ffffffffc0201316 <cow_pgfault+0x13c>
    assert(npage != NULL);
ffffffffc0201258:	cd59                	beqz	a0,ffffffffc02012f6 <cow_pgfault+0x11c>
    return page - pages + nbase;
ffffffffc020125a:	000c3783          	ld	a5,0(s8)
    return KADDR(page2pa(page));
ffffffffc020125e:	577d                	li	a4,-1
ffffffffc0201260:	000bb603          	ld	a2,0(s7)
    return page - pages + nbase;
ffffffffc0201264:	40f406b3          	sub	a3,s0,a5
ffffffffc0201268:	8699                	srai	a3,a3,0x6
ffffffffc020126a:	96da                	add	a3,a3,s6
    return KADDR(page2pa(page));
ffffffffc020126c:	8331                	srli	a4,a4,0xc
ffffffffc020126e:	00e6f5b3          	and	a1,a3,a4
    return page2ppn(page) << PGSHIFT;
ffffffffc0201272:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201274:	06c5f563          	bgeu	a1,a2,ffffffffc02012de <cow_pgfault+0x104>
    return page - pages + nbase;
ffffffffc0201278:	40f507b3          	sub	a5,a0,a5
ffffffffc020127c:	8799                	srai	a5,a5,0x6
ffffffffc020127e:	97da                	add	a5,a5,s6
    return KADDR(page2pa(page));
ffffffffc0201280:	0009d517          	auipc	a0,0x9d
ffffffffc0201284:	d2853503          	ld	a0,-728(a0) # ffffffffc029dfa8 <va_pa_offset>
ffffffffc0201288:	8f7d                	and	a4,a4,a5
ffffffffc020128a:	00a685b3          	add	a1,a3,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc020128e:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0201290:	04c77663          	bgeu	a4,a2,ffffffffc02012dc <cow_pgfault+0x102>
    uintptr_t* src = page2kva(page);
    uintptr_t* dst = page2kva(npage);
    memcpy(dst, src, PGSIZE);
ffffffffc0201294:	953e                	add	a0,a0,a5
ffffffffc0201296:	6605                	lui	a2,0x1
ffffffffc0201298:	59a050ef          	jal	ffffffffc0206832 <memcpy>
    uintptr_t start = ROUNDDOWN(addr, PGSIZE);
    *ptep = 0;
    ret = page_insert(mm->pgdir, npage, start, perm);
ffffffffc020129c:	01893503          	ld	a0,24(s2)
ffffffffc02012a0:	004a6a13          	ori	s4,s4,4
ffffffffc02012a4:	767d                	lui	a2,0xfffff
ffffffffc02012a6:	86d2                	mv	a3,s4
ffffffffc02012a8:	8e65                	and	a2,a2,s1
ffffffffc02012aa:	85d6                	mv	a1,s5
    *ptep = 0;
ffffffffc02012ac:	0009b023          	sd	zero,0(s3)
    ret = page_insert(mm->pgdir, npage, start, perm);
ffffffffc02012b0:	726010ef          	jal	ffffffffc02029d6 <page_insert>
ffffffffc02012b4:	842a                	mv	s0,a0
    ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc02012b6:	01893503          	ld	a0,24(s2)
ffffffffc02012ba:	85a6                	mv	a1,s1
ffffffffc02012bc:	4601                	li	a2,0
ffffffffc02012be:	04c010ef          	jal	ffffffffc020230a <get_pte>
    return ret;
ffffffffc02012c2:	60a6                	ld	ra,72(sp)
ffffffffc02012c4:	8522                	mv	a0,s0
ffffffffc02012c6:	6406                	ld	s0,64(sp)
ffffffffc02012c8:	74e2                	ld	s1,56(sp)
ffffffffc02012ca:	7942                	ld	s2,48(sp)
ffffffffc02012cc:	79a2                	ld	s3,40(sp)
ffffffffc02012ce:	7a02                	ld	s4,32(sp)
ffffffffc02012d0:	6ae2                	ld	s5,24(sp)
ffffffffc02012d2:	6b42                	ld	s6,16(sp)
ffffffffc02012d4:	6ba2                	ld	s7,8(sp)
ffffffffc02012d6:	6c02                	ld	s8,0(sp)
ffffffffc02012d8:	6161                	addi	sp,sp,80
ffffffffc02012da:	8082                	ret
ffffffffc02012dc:	86be                	mv	a3,a5
ffffffffc02012de:	00006617          	auipc	a2,0x6
ffffffffc02012e2:	f3260613          	addi	a2,a2,-206 # ffffffffc0207210 <etext+0x9c6>
ffffffffc02012e6:	06a00593          	li	a1,106
ffffffffc02012ea:	00006517          	auipc	a0,0x6
ffffffffc02012ee:	ed650513          	addi	a0,a0,-298 # ffffffffc02071c0 <etext+0x976>
ffffffffc02012f2:	982ff0ef          	jal	ffffffffc0200474 <__panic>
    assert(npage != NULL);
ffffffffc02012f6:	00006697          	auipc	a3,0x6
ffffffffc02012fa:	fd268693          	addi	a3,a3,-46 # ffffffffc02072c8 <etext+0xa7e>
ffffffffc02012fe:	00006617          	auipc	a2,0x6
ffffffffc0201302:	bca60613          	addi	a2,a2,-1078 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0201306:	07c00593          	li	a1,124
ffffffffc020130a:	00006517          	auipc	a0,0x6
ffffffffc020130e:	e6e50513          	addi	a0,a0,-402 # ffffffffc0207178 <etext+0x92e>
ffffffffc0201312:	962ff0ef          	jal	ffffffffc0200474 <__panic>
    assert(page != NULL);
ffffffffc0201316:	00006697          	auipc	a3,0x6
ffffffffc020131a:	eba68693          	addi	a3,a3,-326 # ffffffffc02071d0 <etext+0x986>
ffffffffc020131e:	00006617          	auipc	a2,0x6
ffffffffc0201322:	baa60613          	addi	a2,a2,-1110 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0201326:	07b00593          	li	a1,123
ffffffffc020132a:	00006517          	auipc	a0,0x6
ffffffffc020132e:	e4e50513          	addi	a0,a0,-434 # ffffffffc0207178 <etext+0x92e>
ffffffffc0201332:	942ff0ef          	jal	ffffffffc0200474 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0201336:	00006617          	auipc	a2,0x6
ffffffffc020133a:	e6a60613          	addi	a2,a2,-406 # ffffffffc02071a0 <etext+0x956>
ffffffffc020133e:	06300593          	li	a1,99
ffffffffc0201342:	00006517          	auipc	a0,0x6
ffffffffc0201346:	e7e50513          	addi	a0,a0,-386 # ffffffffc02071c0 <etext+0x976>
ffffffffc020134a:	92aff0ef          	jal	ffffffffc0200474 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc020134e:	00006617          	auipc	a2,0x6
ffffffffc0201352:	f5260613          	addi	a2,a2,-174 # ffffffffc02072a0 <etext+0xa56>
ffffffffc0201356:	07500593          	li	a1,117
ffffffffc020135a:	00006517          	auipc	a0,0x6
ffffffffc020135e:	e6650513          	addi	a0,a0,-410 # ffffffffc02071c0 <etext+0x976>
ffffffffc0201362:	912ff0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc0201366 <default_init>:
    elm->prev = elm->next = elm;
ffffffffc0201366:	00099797          	auipc	a5,0x99
ffffffffc020136a:	b4278793          	addi	a5,a5,-1214 # ffffffffc0299ea8 <free_area>
ffffffffc020136e:	e79c                	sd	a5,8(a5)
ffffffffc0201370:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0201372:	0007a823          	sw	zero,16(a5)
}
ffffffffc0201376:	8082                	ret

ffffffffc0201378 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0201378:	00099517          	auipc	a0,0x99
ffffffffc020137c:	b4056503          	lwu	a0,-1216(a0) # ffffffffc0299eb8 <free_area+0x10>
ffffffffc0201380:	8082                	ret

ffffffffc0201382 <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0201382:	715d                	addi	sp,sp,-80
ffffffffc0201384:	e0a2                	sd	s0,64(sp)
    return listelm->next;
ffffffffc0201386:	00099417          	auipc	s0,0x99
ffffffffc020138a:	b2240413          	addi	s0,s0,-1246 # ffffffffc0299ea8 <free_area>
ffffffffc020138e:	641c                	ld	a5,8(s0)
ffffffffc0201390:	e486                	sd	ra,72(sp)
ffffffffc0201392:	fc26                	sd	s1,56(sp)
ffffffffc0201394:	f84a                	sd	s2,48(sp)
ffffffffc0201396:	f44e                	sd	s3,40(sp)
ffffffffc0201398:	f052                	sd	s4,32(sp)
ffffffffc020139a:	ec56                	sd	s5,24(sp)
ffffffffc020139c:	e85a                	sd	s6,16(sp)
ffffffffc020139e:	e45e                	sd	s7,8(sp)
ffffffffc02013a0:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc02013a2:	2a878963          	beq	a5,s0,ffffffffc0201654 <default_check+0x2d2>
    int count = 0, total = 0;
ffffffffc02013a6:	4481                	li	s1,0
ffffffffc02013a8:	4901                	li	s2,0
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02013aa:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc02013ae:	8b09                	andi	a4,a4,2
ffffffffc02013b0:	2a070663          	beqz	a4,ffffffffc020165c <default_check+0x2da>
        count ++, total += p->property;
ffffffffc02013b4:	ff87a703          	lw	a4,-8(a5)
ffffffffc02013b8:	679c                	ld	a5,8(a5)
ffffffffc02013ba:	2905                	addiw	s2,s2,1
ffffffffc02013bc:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc02013be:	fe8796e3          	bne	a5,s0,ffffffffc02013aa <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc02013c2:	89a6                	mv	s3,s1
ffffffffc02013c4:	70d000ef          	jal	ffffffffc02022d0 <nr_free_pages>
ffffffffc02013c8:	6f351a63          	bne	a0,s3,ffffffffc0201abc <default_check+0x73a>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02013cc:	4505                	li	a0,1
ffffffffc02013ce:	633000ef          	jal	ffffffffc0202200 <alloc_pages>
ffffffffc02013d2:	8aaa                	mv	s5,a0
ffffffffc02013d4:	42050463          	beqz	a0,ffffffffc02017fc <default_check+0x47a>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02013d8:	4505                	li	a0,1
ffffffffc02013da:	627000ef          	jal	ffffffffc0202200 <alloc_pages>
ffffffffc02013de:	89aa                	mv	s3,a0
ffffffffc02013e0:	6e050e63          	beqz	a0,ffffffffc0201adc <default_check+0x75a>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02013e4:	4505                	li	a0,1
ffffffffc02013e6:	61b000ef          	jal	ffffffffc0202200 <alloc_pages>
ffffffffc02013ea:	8a2a                	mv	s4,a0
ffffffffc02013ec:	48050863          	beqz	a0,ffffffffc020187c <default_check+0x4fa>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02013f0:	293a8663          	beq	s5,s3,ffffffffc020167c <default_check+0x2fa>
ffffffffc02013f4:	28aa8463          	beq	s5,a0,ffffffffc020167c <default_check+0x2fa>
ffffffffc02013f8:	28a98263          	beq	s3,a0,ffffffffc020167c <default_check+0x2fa>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02013fc:	000aa783          	lw	a5,0(s5)
ffffffffc0201400:	28079e63          	bnez	a5,ffffffffc020169c <default_check+0x31a>
ffffffffc0201404:	0009a783          	lw	a5,0(s3)
ffffffffc0201408:	28079a63          	bnez	a5,ffffffffc020169c <default_check+0x31a>
ffffffffc020140c:	411c                	lw	a5,0(a0)
ffffffffc020140e:	28079763          	bnez	a5,ffffffffc020169c <default_check+0x31a>
    return page - pages + nbase;
ffffffffc0201412:	0009d797          	auipc	a5,0x9d
ffffffffc0201416:	ba67b783          	ld	a5,-1114(a5) # ffffffffc029dfb8 <pages>
ffffffffc020141a:	40fa8733          	sub	a4,s5,a5
ffffffffc020141e:	00008617          	auipc	a2,0x8
ffffffffc0201422:	b3263603          	ld	a2,-1230(a2) # ffffffffc0208f50 <nbase>
ffffffffc0201426:	8719                	srai	a4,a4,0x6
ffffffffc0201428:	9732                	add	a4,a4,a2
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc020142a:	0009d697          	auipc	a3,0x9d
ffffffffc020142e:	b866b683          	ld	a3,-1146(a3) # ffffffffc029dfb0 <npage>
ffffffffc0201432:	06b2                	slli	a3,a3,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201434:	0732                	slli	a4,a4,0xc
ffffffffc0201436:	28d77363          	bgeu	a4,a3,ffffffffc02016bc <default_check+0x33a>
    return page - pages + nbase;
ffffffffc020143a:	40f98733          	sub	a4,s3,a5
ffffffffc020143e:	8719                	srai	a4,a4,0x6
ffffffffc0201440:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0201442:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201444:	4ad77c63          	bgeu	a4,a3,ffffffffc02018fc <default_check+0x57a>
    return page - pages + nbase;
ffffffffc0201448:	40f507b3          	sub	a5,a0,a5
ffffffffc020144c:	8799                	srai	a5,a5,0x6
ffffffffc020144e:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0201450:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0201452:	30d7f563          	bgeu	a5,a3,ffffffffc020175c <default_check+0x3da>
    assert(alloc_page() == NULL);
ffffffffc0201456:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0201458:	00043c03          	ld	s8,0(s0)
ffffffffc020145c:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0201460:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0201464:	e400                	sd	s0,8(s0)
ffffffffc0201466:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0201468:	00099797          	auipc	a5,0x99
ffffffffc020146c:	a407a823          	sw	zero,-1456(a5) # ffffffffc0299eb8 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0201470:	591000ef          	jal	ffffffffc0202200 <alloc_pages>
ffffffffc0201474:	2c051463          	bnez	a0,ffffffffc020173c <default_check+0x3ba>
    free_page(p0);
ffffffffc0201478:	4585                	li	a1,1
ffffffffc020147a:	8556                	mv	a0,s5
ffffffffc020147c:	615000ef          	jal	ffffffffc0202290 <free_pages>
    free_page(p1);
ffffffffc0201480:	4585                	li	a1,1
ffffffffc0201482:	854e                	mv	a0,s3
ffffffffc0201484:	60d000ef          	jal	ffffffffc0202290 <free_pages>
    free_page(p2);
ffffffffc0201488:	4585                	li	a1,1
ffffffffc020148a:	8552                	mv	a0,s4
ffffffffc020148c:	605000ef          	jal	ffffffffc0202290 <free_pages>
    assert(nr_free == 3);
ffffffffc0201490:	4818                	lw	a4,16(s0)
ffffffffc0201492:	478d                	li	a5,3
ffffffffc0201494:	28f71463          	bne	a4,a5,ffffffffc020171c <default_check+0x39a>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201498:	4505                	li	a0,1
ffffffffc020149a:	567000ef          	jal	ffffffffc0202200 <alloc_pages>
ffffffffc020149e:	89aa                	mv	s3,a0
ffffffffc02014a0:	24050e63          	beqz	a0,ffffffffc02016fc <default_check+0x37a>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02014a4:	4505                	li	a0,1
ffffffffc02014a6:	55b000ef          	jal	ffffffffc0202200 <alloc_pages>
ffffffffc02014aa:	8aaa                	mv	s5,a0
ffffffffc02014ac:	3a050863          	beqz	a0,ffffffffc020185c <default_check+0x4da>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02014b0:	4505                	li	a0,1
ffffffffc02014b2:	54f000ef          	jal	ffffffffc0202200 <alloc_pages>
ffffffffc02014b6:	8a2a                	mv	s4,a0
ffffffffc02014b8:	38050263          	beqz	a0,ffffffffc020183c <default_check+0x4ba>
    assert(alloc_page() == NULL);
ffffffffc02014bc:	4505                	li	a0,1
ffffffffc02014be:	543000ef          	jal	ffffffffc0202200 <alloc_pages>
ffffffffc02014c2:	34051d63          	bnez	a0,ffffffffc020181c <default_check+0x49a>
    free_page(p0);
ffffffffc02014c6:	4585                	li	a1,1
ffffffffc02014c8:	854e                	mv	a0,s3
ffffffffc02014ca:	5c7000ef          	jal	ffffffffc0202290 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc02014ce:	641c                	ld	a5,8(s0)
ffffffffc02014d0:	20878663          	beq	a5,s0,ffffffffc02016dc <default_check+0x35a>
    assert((p = alloc_page()) == p0);
ffffffffc02014d4:	4505                	li	a0,1
ffffffffc02014d6:	52b000ef          	jal	ffffffffc0202200 <alloc_pages>
ffffffffc02014da:	30a99163          	bne	s3,a0,ffffffffc02017dc <default_check+0x45a>
    assert(alloc_page() == NULL);
ffffffffc02014de:	4505                	li	a0,1
ffffffffc02014e0:	521000ef          	jal	ffffffffc0202200 <alloc_pages>
ffffffffc02014e4:	2c051c63          	bnez	a0,ffffffffc02017bc <default_check+0x43a>
    assert(nr_free == 0);
ffffffffc02014e8:	481c                	lw	a5,16(s0)
ffffffffc02014ea:	2a079963          	bnez	a5,ffffffffc020179c <default_check+0x41a>
    free_page(p);
ffffffffc02014ee:	854e                	mv	a0,s3
ffffffffc02014f0:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc02014f2:	01843023          	sd	s8,0(s0)
ffffffffc02014f6:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc02014fa:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc02014fe:	593000ef          	jal	ffffffffc0202290 <free_pages>
    free_page(p1);
ffffffffc0201502:	4585                	li	a1,1
ffffffffc0201504:	8556                	mv	a0,s5
ffffffffc0201506:	58b000ef          	jal	ffffffffc0202290 <free_pages>
    free_page(p2);
ffffffffc020150a:	4585                	li	a1,1
ffffffffc020150c:	8552                	mv	a0,s4
ffffffffc020150e:	583000ef          	jal	ffffffffc0202290 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0201512:	4515                	li	a0,5
ffffffffc0201514:	4ed000ef          	jal	ffffffffc0202200 <alloc_pages>
ffffffffc0201518:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc020151a:	26050163          	beqz	a0,ffffffffc020177c <default_check+0x3fa>
ffffffffc020151e:	651c                	ld	a5,8(a0)
    assert(!PageProperty(p0));
ffffffffc0201520:	8b89                	andi	a5,a5,2
ffffffffc0201522:	52079d63          	bnez	a5,ffffffffc0201a5c <default_check+0x6da>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0201526:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0201528:	00043b83          	ld	s7,0(s0)
ffffffffc020152c:	00843b03          	ld	s6,8(s0)
ffffffffc0201530:	e000                	sd	s0,0(s0)
ffffffffc0201532:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0201534:	4cd000ef          	jal	ffffffffc0202200 <alloc_pages>
ffffffffc0201538:	50051263          	bnez	a0,ffffffffc0201a3c <default_check+0x6ba>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc020153c:	08098a13          	addi	s4,s3,128
ffffffffc0201540:	8552                	mv	a0,s4
ffffffffc0201542:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0201544:	01042c03          	lw	s8,16(s0)
    nr_free = 0;
ffffffffc0201548:	00099797          	auipc	a5,0x99
ffffffffc020154c:	9607a823          	sw	zero,-1680(a5) # ffffffffc0299eb8 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0201550:	541000ef          	jal	ffffffffc0202290 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0201554:	4511                	li	a0,4
ffffffffc0201556:	4ab000ef          	jal	ffffffffc0202200 <alloc_pages>
ffffffffc020155a:	4c051163          	bnez	a0,ffffffffc0201a1c <default_check+0x69a>
ffffffffc020155e:	0889b783          	ld	a5,136(s3)
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201562:	8b89                	andi	a5,a5,2
ffffffffc0201564:	48078c63          	beqz	a5,ffffffffc02019fc <default_check+0x67a>
ffffffffc0201568:	0909a703          	lw	a4,144(s3)
ffffffffc020156c:	478d                	li	a5,3
ffffffffc020156e:	48f71763          	bne	a4,a5,ffffffffc02019fc <default_check+0x67a>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201572:	450d                	li	a0,3
ffffffffc0201574:	48d000ef          	jal	ffffffffc0202200 <alloc_pages>
ffffffffc0201578:	8aaa                	mv	s5,a0
ffffffffc020157a:	46050163          	beqz	a0,ffffffffc02019dc <default_check+0x65a>
    assert(alloc_page() == NULL);
ffffffffc020157e:	4505                	li	a0,1
ffffffffc0201580:	481000ef          	jal	ffffffffc0202200 <alloc_pages>
ffffffffc0201584:	42051c63          	bnez	a0,ffffffffc02019bc <default_check+0x63a>
    assert(p0 + 2 == p1);
ffffffffc0201588:	415a1a63          	bne	s4,s5,ffffffffc020199c <default_check+0x61a>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc020158c:	4585                	li	a1,1
ffffffffc020158e:	854e                	mv	a0,s3
ffffffffc0201590:	501000ef          	jal	ffffffffc0202290 <free_pages>
    free_pages(p1, 3);
ffffffffc0201594:	458d                	li	a1,3
ffffffffc0201596:	8552                	mv	a0,s4
ffffffffc0201598:	4f9000ef          	jal	ffffffffc0202290 <free_pages>
ffffffffc020159c:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc02015a0:	04098a93          	addi	s5,s3,64
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02015a4:	8b89                	andi	a5,a5,2
ffffffffc02015a6:	3c078b63          	beqz	a5,ffffffffc020197c <default_check+0x5fa>
ffffffffc02015aa:	0109a703          	lw	a4,16(s3)
ffffffffc02015ae:	4785                	li	a5,1
ffffffffc02015b0:	3cf71663          	bne	a4,a5,ffffffffc020197c <default_check+0x5fa>
ffffffffc02015b4:	008a3783          	ld	a5,8(s4)
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02015b8:	8b89                	andi	a5,a5,2
ffffffffc02015ba:	3a078163          	beqz	a5,ffffffffc020195c <default_check+0x5da>
ffffffffc02015be:	010a2703          	lw	a4,16(s4)
ffffffffc02015c2:	478d                	li	a5,3
ffffffffc02015c4:	38f71c63          	bne	a4,a5,ffffffffc020195c <default_check+0x5da>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02015c8:	4505                	li	a0,1
ffffffffc02015ca:	437000ef          	jal	ffffffffc0202200 <alloc_pages>
ffffffffc02015ce:	36a99763          	bne	s3,a0,ffffffffc020193c <default_check+0x5ba>
    free_page(p0);
ffffffffc02015d2:	4585                	li	a1,1
ffffffffc02015d4:	4bd000ef          	jal	ffffffffc0202290 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02015d8:	4509                	li	a0,2
ffffffffc02015da:	427000ef          	jal	ffffffffc0202200 <alloc_pages>
ffffffffc02015de:	32aa1f63          	bne	s4,a0,ffffffffc020191c <default_check+0x59a>

    free_pages(p0, 2);
ffffffffc02015e2:	4589                	li	a1,2
ffffffffc02015e4:	4ad000ef          	jal	ffffffffc0202290 <free_pages>
    free_page(p2);
ffffffffc02015e8:	4585                	li	a1,1
ffffffffc02015ea:	8556                	mv	a0,s5
ffffffffc02015ec:	4a5000ef          	jal	ffffffffc0202290 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02015f0:	4515                	li	a0,5
ffffffffc02015f2:	40f000ef          	jal	ffffffffc0202200 <alloc_pages>
ffffffffc02015f6:	89aa                	mv	s3,a0
ffffffffc02015f8:	48050263          	beqz	a0,ffffffffc0201a7c <default_check+0x6fa>
    assert(alloc_page() == NULL);
ffffffffc02015fc:	4505                	li	a0,1
ffffffffc02015fe:	403000ef          	jal	ffffffffc0202200 <alloc_pages>
ffffffffc0201602:	2c051d63          	bnez	a0,ffffffffc02018dc <default_check+0x55a>

    assert(nr_free == 0);
ffffffffc0201606:	481c                	lw	a5,16(s0)
ffffffffc0201608:	2a079a63          	bnez	a5,ffffffffc02018bc <default_check+0x53a>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc020160c:	4595                	li	a1,5
ffffffffc020160e:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0201610:	01842823          	sw	s8,16(s0)
    free_list = free_list_store;
ffffffffc0201614:	01743023          	sd	s7,0(s0)
ffffffffc0201618:	01643423          	sd	s6,8(s0)
    free_pages(p0, 5);
ffffffffc020161c:	475000ef          	jal	ffffffffc0202290 <free_pages>
    return listelm->next;
ffffffffc0201620:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201622:	00878963          	beq	a5,s0,ffffffffc0201634 <default_check+0x2b2>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0201626:	ff87a703          	lw	a4,-8(a5)
ffffffffc020162a:	679c                	ld	a5,8(a5)
ffffffffc020162c:	397d                	addiw	s2,s2,-1
ffffffffc020162e:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201630:	fe879be3          	bne	a5,s0,ffffffffc0201626 <default_check+0x2a4>
    }
    assert(count == 0);
ffffffffc0201634:	26091463          	bnez	s2,ffffffffc020189c <default_check+0x51a>
    assert(total == 0);
ffffffffc0201638:	46049263          	bnez	s1,ffffffffc0201a9c <default_check+0x71a>
}
ffffffffc020163c:	60a6                	ld	ra,72(sp)
ffffffffc020163e:	6406                	ld	s0,64(sp)
ffffffffc0201640:	74e2                	ld	s1,56(sp)
ffffffffc0201642:	7942                	ld	s2,48(sp)
ffffffffc0201644:	79a2                	ld	s3,40(sp)
ffffffffc0201646:	7a02                	ld	s4,32(sp)
ffffffffc0201648:	6ae2                	ld	s5,24(sp)
ffffffffc020164a:	6b42                	ld	s6,16(sp)
ffffffffc020164c:	6ba2                	ld	s7,8(sp)
ffffffffc020164e:	6c02                	ld	s8,0(sp)
ffffffffc0201650:	6161                	addi	sp,sp,80
ffffffffc0201652:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201654:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0201656:	4481                	li	s1,0
ffffffffc0201658:	4901                	li	s2,0
ffffffffc020165a:	b3ad                	j	ffffffffc02013c4 <default_check+0x42>
        assert(PageProperty(p));
ffffffffc020165c:	00006697          	auipc	a3,0x6
ffffffffc0201660:	c7c68693          	addi	a3,a3,-900 # ffffffffc02072d8 <etext+0xa8e>
ffffffffc0201664:	00006617          	auipc	a2,0x6
ffffffffc0201668:	86460613          	addi	a2,a2,-1948 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc020166c:	0f000593          	li	a1,240
ffffffffc0201670:	00006517          	auipc	a0,0x6
ffffffffc0201674:	c7850513          	addi	a0,a0,-904 # ffffffffc02072e8 <etext+0xa9e>
ffffffffc0201678:	dfdfe0ef          	jal	ffffffffc0200474 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc020167c:	00006697          	auipc	a3,0x6
ffffffffc0201680:	d0468693          	addi	a3,a3,-764 # ffffffffc0207380 <etext+0xb36>
ffffffffc0201684:	00006617          	auipc	a2,0x6
ffffffffc0201688:	84460613          	addi	a2,a2,-1980 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc020168c:	0bd00593          	li	a1,189
ffffffffc0201690:	00006517          	auipc	a0,0x6
ffffffffc0201694:	c5850513          	addi	a0,a0,-936 # ffffffffc02072e8 <etext+0xa9e>
ffffffffc0201698:	dddfe0ef          	jal	ffffffffc0200474 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc020169c:	00006697          	auipc	a3,0x6
ffffffffc02016a0:	d0c68693          	addi	a3,a3,-756 # ffffffffc02073a8 <etext+0xb5e>
ffffffffc02016a4:	00006617          	auipc	a2,0x6
ffffffffc02016a8:	82460613          	addi	a2,a2,-2012 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc02016ac:	0be00593          	li	a1,190
ffffffffc02016b0:	00006517          	auipc	a0,0x6
ffffffffc02016b4:	c3850513          	addi	a0,a0,-968 # ffffffffc02072e8 <etext+0xa9e>
ffffffffc02016b8:	dbdfe0ef          	jal	ffffffffc0200474 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02016bc:	00006697          	auipc	a3,0x6
ffffffffc02016c0:	d2c68693          	addi	a3,a3,-724 # ffffffffc02073e8 <etext+0xb9e>
ffffffffc02016c4:	00006617          	auipc	a2,0x6
ffffffffc02016c8:	80460613          	addi	a2,a2,-2044 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc02016cc:	0c000593          	li	a1,192
ffffffffc02016d0:	00006517          	auipc	a0,0x6
ffffffffc02016d4:	c1850513          	addi	a0,a0,-1000 # ffffffffc02072e8 <etext+0xa9e>
ffffffffc02016d8:	d9dfe0ef          	jal	ffffffffc0200474 <__panic>
    assert(!list_empty(&free_list));
ffffffffc02016dc:	00006697          	auipc	a3,0x6
ffffffffc02016e0:	d9468693          	addi	a3,a3,-620 # ffffffffc0207470 <etext+0xc26>
ffffffffc02016e4:	00005617          	auipc	a2,0x5
ffffffffc02016e8:	7e460613          	addi	a2,a2,2020 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc02016ec:	0d900593          	li	a1,217
ffffffffc02016f0:	00006517          	auipc	a0,0x6
ffffffffc02016f4:	bf850513          	addi	a0,a0,-1032 # ffffffffc02072e8 <etext+0xa9e>
ffffffffc02016f8:	d7dfe0ef          	jal	ffffffffc0200474 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02016fc:	00006697          	auipc	a3,0x6
ffffffffc0201700:	c2468693          	addi	a3,a3,-988 # ffffffffc0207320 <etext+0xad6>
ffffffffc0201704:	00005617          	auipc	a2,0x5
ffffffffc0201708:	7c460613          	addi	a2,a2,1988 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc020170c:	0d200593          	li	a1,210
ffffffffc0201710:	00006517          	auipc	a0,0x6
ffffffffc0201714:	bd850513          	addi	a0,a0,-1064 # ffffffffc02072e8 <etext+0xa9e>
ffffffffc0201718:	d5dfe0ef          	jal	ffffffffc0200474 <__panic>
    assert(nr_free == 3);
ffffffffc020171c:	00006697          	auipc	a3,0x6
ffffffffc0201720:	d4468693          	addi	a3,a3,-700 # ffffffffc0207460 <etext+0xc16>
ffffffffc0201724:	00005617          	auipc	a2,0x5
ffffffffc0201728:	7a460613          	addi	a2,a2,1956 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc020172c:	0d000593          	li	a1,208
ffffffffc0201730:	00006517          	auipc	a0,0x6
ffffffffc0201734:	bb850513          	addi	a0,a0,-1096 # ffffffffc02072e8 <etext+0xa9e>
ffffffffc0201738:	d3dfe0ef          	jal	ffffffffc0200474 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020173c:	00006697          	auipc	a3,0x6
ffffffffc0201740:	d0c68693          	addi	a3,a3,-756 # ffffffffc0207448 <etext+0xbfe>
ffffffffc0201744:	00005617          	auipc	a2,0x5
ffffffffc0201748:	78460613          	addi	a2,a2,1924 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc020174c:	0cb00593          	li	a1,203
ffffffffc0201750:	00006517          	auipc	a0,0x6
ffffffffc0201754:	b9850513          	addi	a0,a0,-1128 # ffffffffc02072e8 <etext+0xa9e>
ffffffffc0201758:	d1dfe0ef          	jal	ffffffffc0200474 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc020175c:	00006697          	auipc	a3,0x6
ffffffffc0201760:	ccc68693          	addi	a3,a3,-820 # ffffffffc0207428 <etext+0xbde>
ffffffffc0201764:	00005617          	auipc	a2,0x5
ffffffffc0201768:	76460613          	addi	a2,a2,1892 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc020176c:	0c200593          	li	a1,194
ffffffffc0201770:	00006517          	auipc	a0,0x6
ffffffffc0201774:	b7850513          	addi	a0,a0,-1160 # ffffffffc02072e8 <etext+0xa9e>
ffffffffc0201778:	cfdfe0ef          	jal	ffffffffc0200474 <__panic>
    assert(p0 != NULL);
ffffffffc020177c:	00006697          	auipc	a3,0x6
ffffffffc0201780:	d3c68693          	addi	a3,a3,-708 # ffffffffc02074b8 <etext+0xc6e>
ffffffffc0201784:	00005617          	auipc	a2,0x5
ffffffffc0201788:	74460613          	addi	a2,a2,1860 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc020178c:	0f800593          	li	a1,248
ffffffffc0201790:	00006517          	auipc	a0,0x6
ffffffffc0201794:	b5850513          	addi	a0,a0,-1192 # ffffffffc02072e8 <etext+0xa9e>
ffffffffc0201798:	cddfe0ef          	jal	ffffffffc0200474 <__panic>
    assert(nr_free == 0);
ffffffffc020179c:	00006697          	auipc	a3,0x6
ffffffffc02017a0:	d0c68693          	addi	a3,a3,-756 # ffffffffc02074a8 <etext+0xc5e>
ffffffffc02017a4:	00005617          	auipc	a2,0x5
ffffffffc02017a8:	72460613          	addi	a2,a2,1828 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc02017ac:	0df00593          	li	a1,223
ffffffffc02017b0:	00006517          	auipc	a0,0x6
ffffffffc02017b4:	b3850513          	addi	a0,a0,-1224 # ffffffffc02072e8 <etext+0xa9e>
ffffffffc02017b8:	cbdfe0ef          	jal	ffffffffc0200474 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02017bc:	00006697          	auipc	a3,0x6
ffffffffc02017c0:	c8c68693          	addi	a3,a3,-884 # ffffffffc0207448 <etext+0xbfe>
ffffffffc02017c4:	00005617          	auipc	a2,0x5
ffffffffc02017c8:	70460613          	addi	a2,a2,1796 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc02017cc:	0dd00593          	li	a1,221
ffffffffc02017d0:	00006517          	auipc	a0,0x6
ffffffffc02017d4:	b1850513          	addi	a0,a0,-1256 # ffffffffc02072e8 <etext+0xa9e>
ffffffffc02017d8:	c9dfe0ef          	jal	ffffffffc0200474 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc02017dc:	00006697          	auipc	a3,0x6
ffffffffc02017e0:	cac68693          	addi	a3,a3,-852 # ffffffffc0207488 <etext+0xc3e>
ffffffffc02017e4:	00005617          	auipc	a2,0x5
ffffffffc02017e8:	6e460613          	addi	a2,a2,1764 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc02017ec:	0dc00593          	li	a1,220
ffffffffc02017f0:	00006517          	auipc	a0,0x6
ffffffffc02017f4:	af850513          	addi	a0,a0,-1288 # ffffffffc02072e8 <etext+0xa9e>
ffffffffc02017f8:	c7dfe0ef          	jal	ffffffffc0200474 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02017fc:	00006697          	auipc	a3,0x6
ffffffffc0201800:	b2468693          	addi	a3,a3,-1244 # ffffffffc0207320 <etext+0xad6>
ffffffffc0201804:	00005617          	auipc	a2,0x5
ffffffffc0201808:	6c460613          	addi	a2,a2,1732 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc020180c:	0b900593          	li	a1,185
ffffffffc0201810:	00006517          	auipc	a0,0x6
ffffffffc0201814:	ad850513          	addi	a0,a0,-1320 # ffffffffc02072e8 <etext+0xa9e>
ffffffffc0201818:	c5dfe0ef          	jal	ffffffffc0200474 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020181c:	00006697          	auipc	a3,0x6
ffffffffc0201820:	c2c68693          	addi	a3,a3,-980 # ffffffffc0207448 <etext+0xbfe>
ffffffffc0201824:	00005617          	auipc	a2,0x5
ffffffffc0201828:	6a460613          	addi	a2,a2,1700 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc020182c:	0d600593          	li	a1,214
ffffffffc0201830:	00006517          	auipc	a0,0x6
ffffffffc0201834:	ab850513          	addi	a0,a0,-1352 # ffffffffc02072e8 <etext+0xa9e>
ffffffffc0201838:	c3dfe0ef          	jal	ffffffffc0200474 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020183c:	00006697          	auipc	a3,0x6
ffffffffc0201840:	b2468693          	addi	a3,a3,-1244 # ffffffffc0207360 <etext+0xb16>
ffffffffc0201844:	00005617          	auipc	a2,0x5
ffffffffc0201848:	68460613          	addi	a2,a2,1668 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc020184c:	0d400593          	li	a1,212
ffffffffc0201850:	00006517          	auipc	a0,0x6
ffffffffc0201854:	a9850513          	addi	a0,a0,-1384 # ffffffffc02072e8 <etext+0xa9e>
ffffffffc0201858:	c1dfe0ef          	jal	ffffffffc0200474 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020185c:	00006697          	auipc	a3,0x6
ffffffffc0201860:	ae468693          	addi	a3,a3,-1308 # ffffffffc0207340 <etext+0xaf6>
ffffffffc0201864:	00005617          	auipc	a2,0x5
ffffffffc0201868:	66460613          	addi	a2,a2,1636 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc020186c:	0d300593          	li	a1,211
ffffffffc0201870:	00006517          	auipc	a0,0x6
ffffffffc0201874:	a7850513          	addi	a0,a0,-1416 # ffffffffc02072e8 <etext+0xa9e>
ffffffffc0201878:	bfdfe0ef          	jal	ffffffffc0200474 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020187c:	00006697          	auipc	a3,0x6
ffffffffc0201880:	ae468693          	addi	a3,a3,-1308 # ffffffffc0207360 <etext+0xb16>
ffffffffc0201884:	00005617          	auipc	a2,0x5
ffffffffc0201888:	64460613          	addi	a2,a2,1604 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc020188c:	0bb00593          	li	a1,187
ffffffffc0201890:	00006517          	auipc	a0,0x6
ffffffffc0201894:	a5850513          	addi	a0,a0,-1448 # ffffffffc02072e8 <etext+0xa9e>
ffffffffc0201898:	bddfe0ef          	jal	ffffffffc0200474 <__panic>
    assert(count == 0);
ffffffffc020189c:	00006697          	auipc	a3,0x6
ffffffffc02018a0:	d6c68693          	addi	a3,a3,-660 # ffffffffc0207608 <etext+0xdbe>
ffffffffc02018a4:	00005617          	auipc	a2,0x5
ffffffffc02018a8:	62460613          	addi	a2,a2,1572 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc02018ac:	12500593          	li	a1,293
ffffffffc02018b0:	00006517          	auipc	a0,0x6
ffffffffc02018b4:	a3850513          	addi	a0,a0,-1480 # ffffffffc02072e8 <etext+0xa9e>
ffffffffc02018b8:	bbdfe0ef          	jal	ffffffffc0200474 <__panic>
    assert(nr_free == 0);
ffffffffc02018bc:	00006697          	auipc	a3,0x6
ffffffffc02018c0:	bec68693          	addi	a3,a3,-1044 # ffffffffc02074a8 <etext+0xc5e>
ffffffffc02018c4:	00005617          	auipc	a2,0x5
ffffffffc02018c8:	60460613          	addi	a2,a2,1540 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc02018cc:	11a00593          	li	a1,282
ffffffffc02018d0:	00006517          	auipc	a0,0x6
ffffffffc02018d4:	a1850513          	addi	a0,a0,-1512 # ffffffffc02072e8 <etext+0xa9e>
ffffffffc02018d8:	b9dfe0ef          	jal	ffffffffc0200474 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02018dc:	00006697          	auipc	a3,0x6
ffffffffc02018e0:	b6c68693          	addi	a3,a3,-1172 # ffffffffc0207448 <etext+0xbfe>
ffffffffc02018e4:	00005617          	auipc	a2,0x5
ffffffffc02018e8:	5e460613          	addi	a2,a2,1508 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc02018ec:	11800593          	li	a1,280
ffffffffc02018f0:	00006517          	auipc	a0,0x6
ffffffffc02018f4:	9f850513          	addi	a0,a0,-1544 # ffffffffc02072e8 <etext+0xa9e>
ffffffffc02018f8:	b7dfe0ef          	jal	ffffffffc0200474 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02018fc:	00006697          	auipc	a3,0x6
ffffffffc0201900:	b0c68693          	addi	a3,a3,-1268 # ffffffffc0207408 <etext+0xbbe>
ffffffffc0201904:	00005617          	auipc	a2,0x5
ffffffffc0201908:	5c460613          	addi	a2,a2,1476 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc020190c:	0c100593          	li	a1,193
ffffffffc0201910:	00006517          	auipc	a0,0x6
ffffffffc0201914:	9d850513          	addi	a0,a0,-1576 # ffffffffc02072e8 <etext+0xa9e>
ffffffffc0201918:	b5dfe0ef          	jal	ffffffffc0200474 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc020191c:	00006697          	auipc	a3,0x6
ffffffffc0201920:	cac68693          	addi	a3,a3,-852 # ffffffffc02075c8 <etext+0xd7e>
ffffffffc0201924:	00005617          	auipc	a2,0x5
ffffffffc0201928:	5a460613          	addi	a2,a2,1444 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc020192c:	11200593          	li	a1,274
ffffffffc0201930:	00006517          	auipc	a0,0x6
ffffffffc0201934:	9b850513          	addi	a0,a0,-1608 # ffffffffc02072e8 <etext+0xa9e>
ffffffffc0201938:	b3dfe0ef          	jal	ffffffffc0200474 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc020193c:	00006697          	auipc	a3,0x6
ffffffffc0201940:	c6c68693          	addi	a3,a3,-916 # ffffffffc02075a8 <etext+0xd5e>
ffffffffc0201944:	00005617          	auipc	a2,0x5
ffffffffc0201948:	58460613          	addi	a2,a2,1412 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc020194c:	11000593          	li	a1,272
ffffffffc0201950:	00006517          	auipc	a0,0x6
ffffffffc0201954:	99850513          	addi	a0,a0,-1640 # ffffffffc02072e8 <etext+0xa9e>
ffffffffc0201958:	b1dfe0ef          	jal	ffffffffc0200474 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc020195c:	00006697          	auipc	a3,0x6
ffffffffc0201960:	c2468693          	addi	a3,a3,-988 # ffffffffc0207580 <etext+0xd36>
ffffffffc0201964:	00005617          	auipc	a2,0x5
ffffffffc0201968:	56460613          	addi	a2,a2,1380 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc020196c:	10e00593          	li	a1,270
ffffffffc0201970:	00006517          	auipc	a0,0x6
ffffffffc0201974:	97850513          	addi	a0,a0,-1672 # ffffffffc02072e8 <etext+0xa9e>
ffffffffc0201978:	afdfe0ef          	jal	ffffffffc0200474 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc020197c:	00006697          	auipc	a3,0x6
ffffffffc0201980:	bdc68693          	addi	a3,a3,-1060 # ffffffffc0207558 <etext+0xd0e>
ffffffffc0201984:	00005617          	auipc	a2,0x5
ffffffffc0201988:	54460613          	addi	a2,a2,1348 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc020198c:	10d00593          	li	a1,269
ffffffffc0201990:	00006517          	auipc	a0,0x6
ffffffffc0201994:	95850513          	addi	a0,a0,-1704 # ffffffffc02072e8 <etext+0xa9e>
ffffffffc0201998:	addfe0ef          	jal	ffffffffc0200474 <__panic>
    assert(p0 + 2 == p1);
ffffffffc020199c:	00006697          	auipc	a3,0x6
ffffffffc02019a0:	bac68693          	addi	a3,a3,-1108 # ffffffffc0207548 <etext+0xcfe>
ffffffffc02019a4:	00005617          	auipc	a2,0x5
ffffffffc02019a8:	52460613          	addi	a2,a2,1316 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc02019ac:	10800593          	li	a1,264
ffffffffc02019b0:	00006517          	auipc	a0,0x6
ffffffffc02019b4:	93850513          	addi	a0,a0,-1736 # ffffffffc02072e8 <etext+0xa9e>
ffffffffc02019b8:	abdfe0ef          	jal	ffffffffc0200474 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02019bc:	00006697          	auipc	a3,0x6
ffffffffc02019c0:	a8c68693          	addi	a3,a3,-1396 # ffffffffc0207448 <etext+0xbfe>
ffffffffc02019c4:	00005617          	auipc	a2,0x5
ffffffffc02019c8:	50460613          	addi	a2,a2,1284 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc02019cc:	10700593          	li	a1,263
ffffffffc02019d0:	00006517          	auipc	a0,0x6
ffffffffc02019d4:	91850513          	addi	a0,a0,-1768 # ffffffffc02072e8 <etext+0xa9e>
ffffffffc02019d8:	a9dfe0ef          	jal	ffffffffc0200474 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02019dc:	00006697          	auipc	a3,0x6
ffffffffc02019e0:	b4c68693          	addi	a3,a3,-1204 # ffffffffc0207528 <etext+0xcde>
ffffffffc02019e4:	00005617          	auipc	a2,0x5
ffffffffc02019e8:	4e460613          	addi	a2,a2,1252 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc02019ec:	10600593          	li	a1,262
ffffffffc02019f0:	00006517          	auipc	a0,0x6
ffffffffc02019f4:	8f850513          	addi	a0,a0,-1800 # ffffffffc02072e8 <etext+0xa9e>
ffffffffc02019f8:	a7dfe0ef          	jal	ffffffffc0200474 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02019fc:	00006697          	auipc	a3,0x6
ffffffffc0201a00:	afc68693          	addi	a3,a3,-1284 # ffffffffc02074f8 <etext+0xcae>
ffffffffc0201a04:	00005617          	auipc	a2,0x5
ffffffffc0201a08:	4c460613          	addi	a2,a2,1220 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0201a0c:	10500593          	li	a1,261
ffffffffc0201a10:	00006517          	auipc	a0,0x6
ffffffffc0201a14:	8d850513          	addi	a0,a0,-1832 # ffffffffc02072e8 <etext+0xa9e>
ffffffffc0201a18:	a5dfe0ef          	jal	ffffffffc0200474 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0201a1c:	00006697          	auipc	a3,0x6
ffffffffc0201a20:	ac468693          	addi	a3,a3,-1340 # ffffffffc02074e0 <etext+0xc96>
ffffffffc0201a24:	00005617          	auipc	a2,0x5
ffffffffc0201a28:	4a460613          	addi	a2,a2,1188 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0201a2c:	10400593          	li	a1,260
ffffffffc0201a30:	00006517          	auipc	a0,0x6
ffffffffc0201a34:	8b850513          	addi	a0,a0,-1864 # ffffffffc02072e8 <etext+0xa9e>
ffffffffc0201a38:	a3dfe0ef          	jal	ffffffffc0200474 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201a3c:	00006697          	auipc	a3,0x6
ffffffffc0201a40:	a0c68693          	addi	a3,a3,-1524 # ffffffffc0207448 <etext+0xbfe>
ffffffffc0201a44:	00005617          	auipc	a2,0x5
ffffffffc0201a48:	48460613          	addi	a2,a2,1156 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0201a4c:	0fe00593          	li	a1,254
ffffffffc0201a50:	00006517          	auipc	a0,0x6
ffffffffc0201a54:	89850513          	addi	a0,a0,-1896 # ffffffffc02072e8 <etext+0xa9e>
ffffffffc0201a58:	a1dfe0ef          	jal	ffffffffc0200474 <__panic>
    assert(!PageProperty(p0));
ffffffffc0201a5c:	00006697          	auipc	a3,0x6
ffffffffc0201a60:	a6c68693          	addi	a3,a3,-1428 # ffffffffc02074c8 <etext+0xc7e>
ffffffffc0201a64:	00005617          	auipc	a2,0x5
ffffffffc0201a68:	46460613          	addi	a2,a2,1124 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0201a6c:	0f900593          	li	a1,249
ffffffffc0201a70:	00006517          	auipc	a0,0x6
ffffffffc0201a74:	87850513          	addi	a0,a0,-1928 # ffffffffc02072e8 <etext+0xa9e>
ffffffffc0201a78:	9fdfe0ef          	jal	ffffffffc0200474 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201a7c:	00006697          	auipc	a3,0x6
ffffffffc0201a80:	b6c68693          	addi	a3,a3,-1172 # ffffffffc02075e8 <etext+0xd9e>
ffffffffc0201a84:	00005617          	auipc	a2,0x5
ffffffffc0201a88:	44460613          	addi	a2,a2,1092 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0201a8c:	11700593          	li	a1,279
ffffffffc0201a90:	00006517          	auipc	a0,0x6
ffffffffc0201a94:	85850513          	addi	a0,a0,-1960 # ffffffffc02072e8 <etext+0xa9e>
ffffffffc0201a98:	9ddfe0ef          	jal	ffffffffc0200474 <__panic>
    assert(total == 0);
ffffffffc0201a9c:	00006697          	auipc	a3,0x6
ffffffffc0201aa0:	b7c68693          	addi	a3,a3,-1156 # ffffffffc0207618 <etext+0xdce>
ffffffffc0201aa4:	00005617          	auipc	a2,0x5
ffffffffc0201aa8:	42460613          	addi	a2,a2,1060 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0201aac:	12600593          	li	a1,294
ffffffffc0201ab0:	00006517          	auipc	a0,0x6
ffffffffc0201ab4:	83850513          	addi	a0,a0,-1992 # ffffffffc02072e8 <etext+0xa9e>
ffffffffc0201ab8:	9bdfe0ef          	jal	ffffffffc0200474 <__panic>
    assert(total == nr_free_pages());
ffffffffc0201abc:	00006697          	auipc	a3,0x6
ffffffffc0201ac0:	84468693          	addi	a3,a3,-1980 # ffffffffc0207300 <etext+0xab6>
ffffffffc0201ac4:	00005617          	auipc	a2,0x5
ffffffffc0201ac8:	40460613          	addi	a2,a2,1028 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0201acc:	0f300593          	li	a1,243
ffffffffc0201ad0:	00006517          	auipc	a0,0x6
ffffffffc0201ad4:	81850513          	addi	a0,a0,-2024 # ffffffffc02072e8 <etext+0xa9e>
ffffffffc0201ad8:	99dfe0ef          	jal	ffffffffc0200474 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201adc:	00006697          	auipc	a3,0x6
ffffffffc0201ae0:	86468693          	addi	a3,a3,-1948 # ffffffffc0207340 <etext+0xaf6>
ffffffffc0201ae4:	00005617          	auipc	a2,0x5
ffffffffc0201ae8:	3e460613          	addi	a2,a2,996 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0201aec:	0ba00593          	li	a1,186
ffffffffc0201af0:	00005517          	auipc	a0,0x5
ffffffffc0201af4:	7f850513          	addi	a0,a0,2040 # ffffffffc02072e8 <etext+0xa9e>
ffffffffc0201af8:	97dfe0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc0201afc <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0201afc:	1141                	addi	sp,sp,-16
ffffffffc0201afe:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201b00:	14058463          	beqz	a1,ffffffffc0201c48 <default_free_pages+0x14c>
    for (; p != base + n; p ++) {
ffffffffc0201b04:	00659713          	slli	a4,a1,0x6
ffffffffc0201b08:	00e506b3          	add	a3,a0,a4
    struct Page *p = base;
ffffffffc0201b0c:	87aa                	mv	a5,a0
    for (; p != base + n; p ++) {
ffffffffc0201b0e:	c30d                	beqz	a4,ffffffffc0201b30 <default_free_pages+0x34>
ffffffffc0201b10:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201b12:	8b05                	andi	a4,a4,1
ffffffffc0201b14:	10071a63          	bnez	a4,ffffffffc0201c28 <default_free_pages+0x12c>
ffffffffc0201b18:	6798                	ld	a4,8(a5)
ffffffffc0201b1a:	8b09                	andi	a4,a4,2
ffffffffc0201b1c:	10071663          	bnez	a4,ffffffffc0201c28 <default_free_pages+0x12c>
        p->flags = 0;
ffffffffc0201b20:	0007b423          	sd	zero,8(a5)
    return page->ref;
}

static inline void
set_page_ref(struct Page *page, int val) {
    page->ref = val;
ffffffffc0201b24:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201b28:	04078793          	addi	a5,a5,64
ffffffffc0201b2c:	fed792e3          	bne	a5,a3,ffffffffc0201b10 <default_free_pages+0x14>
    base->property = n;
ffffffffc0201b30:	2581                	sext.w	a1,a1
ffffffffc0201b32:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0201b34:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201b38:	4789                	li	a5,2
ffffffffc0201b3a:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0201b3e:	00098697          	auipc	a3,0x98
ffffffffc0201b42:	36a68693          	addi	a3,a3,874 # ffffffffc0299ea8 <free_area>
ffffffffc0201b46:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201b48:	669c                	ld	a5,8(a3)
ffffffffc0201b4a:	9f2d                	addw	a4,a4,a1
ffffffffc0201b4c:	ca98                	sw	a4,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0201b4e:	0ad78163          	beq	a5,a3,ffffffffc0201bf0 <default_free_pages+0xf4>
            struct Page* page = le2page(le, page_link);
ffffffffc0201b52:	fe878713          	addi	a4,a5,-24
ffffffffc0201b56:	4581                	li	a1,0
ffffffffc0201b58:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc0201b5c:	00e56a63          	bltu	a0,a4,ffffffffc0201b70 <default_free_pages+0x74>
    return listelm->next;
ffffffffc0201b60:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201b62:	04d70c63          	beq	a4,a3,ffffffffc0201bba <default_free_pages+0xbe>
    struct Page *p = base;
ffffffffc0201b66:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201b68:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201b6c:	fee57ae3          	bgeu	a0,a4,ffffffffc0201b60 <default_free_pages+0x64>
ffffffffc0201b70:	c199                	beqz	a1,ffffffffc0201b76 <default_free_pages+0x7a>
ffffffffc0201b72:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201b76:	6398                	ld	a4,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0201b78:	e390                	sd	a2,0(a5)
ffffffffc0201b7a:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201b7c:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201b7e:	ed18                	sd	a4,24(a0)
    if (le != &free_list) {
ffffffffc0201b80:	00d70d63          	beq	a4,a3,ffffffffc0201b9a <default_free_pages+0x9e>
        if (p + p->property == base) {
ffffffffc0201b84:	ff872583          	lw	a1,-8(a4) # ffffffffc01ffff8 <_binary_obj___user_exit_out_size+0xffffffffc01f6458>
        p = le2page(le, page_link);
ffffffffc0201b88:	fe870613          	addi	a2,a4,-24
        if (p + p->property == base) {
ffffffffc0201b8c:	02059813          	slli	a6,a1,0x20
ffffffffc0201b90:	01a85793          	srli	a5,a6,0x1a
ffffffffc0201b94:	97b2                	add	a5,a5,a2
ffffffffc0201b96:	02f50c63          	beq	a0,a5,ffffffffc0201bce <default_free_pages+0xd2>
    return listelm->next;
ffffffffc0201b9a:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc0201b9c:	00d78c63          	beq	a5,a3,ffffffffc0201bb4 <default_free_pages+0xb8>
        if (base + base->property == p) {
ffffffffc0201ba0:	4910                	lw	a2,16(a0)
        p = le2page(le, page_link);
ffffffffc0201ba2:	fe878693          	addi	a3,a5,-24
        if (base + base->property == p) {
ffffffffc0201ba6:	02061593          	slli	a1,a2,0x20
ffffffffc0201baa:	01a5d713          	srli	a4,a1,0x1a
ffffffffc0201bae:	972a                	add	a4,a4,a0
ffffffffc0201bb0:	04e68c63          	beq	a3,a4,ffffffffc0201c08 <default_free_pages+0x10c>
}
ffffffffc0201bb4:	60a2                	ld	ra,8(sp)
ffffffffc0201bb6:	0141                	addi	sp,sp,16
ffffffffc0201bb8:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201bba:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201bbc:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0201bbe:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201bc0:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0201bc2:	8832                	mv	a6,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201bc4:	02d70f63          	beq	a4,a3,ffffffffc0201c02 <default_free_pages+0x106>
ffffffffc0201bc8:	4585                	li	a1,1
    struct Page *p = base;
ffffffffc0201bca:	87ba                	mv	a5,a4
ffffffffc0201bcc:	bf71                	j	ffffffffc0201b68 <default_free_pages+0x6c>
            p->property += base->property;
ffffffffc0201bce:	491c                	lw	a5,16(a0)
ffffffffc0201bd0:	9fad                	addw	a5,a5,a1
ffffffffc0201bd2:	fef72c23          	sw	a5,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201bd6:	57f5                	li	a5,-3
ffffffffc0201bd8:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201bdc:	01853803          	ld	a6,24(a0)
ffffffffc0201be0:	710c                	ld	a1,32(a0)
            base = p;
ffffffffc0201be2:	8532                	mv	a0,a2
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0201be4:	00b83423          	sd	a1,8(a6)
    return listelm->next;
ffffffffc0201be8:	671c                	ld	a5,8(a4)
    next->prev = prev;
ffffffffc0201bea:	0105b023          	sd	a6,0(a1)
ffffffffc0201bee:	b77d                	j	ffffffffc0201b9c <default_free_pages+0xa0>
}
ffffffffc0201bf0:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201bf2:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0201bf6:	e398                	sd	a4,0(a5)
ffffffffc0201bf8:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0201bfa:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201bfc:	ed1c                	sd	a5,24(a0)
}
ffffffffc0201bfe:	0141                	addi	sp,sp,16
ffffffffc0201c00:	8082                	ret
ffffffffc0201c02:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc0201c04:	873e                	mv	a4,a5
ffffffffc0201c06:	bfad                	j	ffffffffc0201b80 <default_free_pages+0x84>
            base->property += p->property;
ffffffffc0201c08:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201c0c:	ff078693          	addi	a3,a5,-16
ffffffffc0201c10:	9f31                	addw	a4,a4,a2
ffffffffc0201c12:	c918                	sw	a4,16(a0)
ffffffffc0201c14:	5775                	li	a4,-3
ffffffffc0201c16:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201c1a:	6398                	ld	a4,0(a5)
ffffffffc0201c1c:	679c                	ld	a5,8(a5)
}
ffffffffc0201c1e:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0201c20:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201c22:	e398                	sd	a4,0(a5)
ffffffffc0201c24:	0141                	addi	sp,sp,16
ffffffffc0201c26:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201c28:	00006697          	auipc	a3,0x6
ffffffffc0201c2c:	a0868693          	addi	a3,a3,-1528 # ffffffffc0207630 <etext+0xde6>
ffffffffc0201c30:	00005617          	auipc	a2,0x5
ffffffffc0201c34:	29860613          	addi	a2,a2,664 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0201c38:	08300593          	li	a1,131
ffffffffc0201c3c:	00005517          	auipc	a0,0x5
ffffffffc0201c40:	6ac50513          	addi	a0,a0,1708 # ffffffffc02072e8 <etext+0xa9e>
ffffffffc0201c44:	831fe0ef          	jal	ffffffffc0200474 <__panic>
    assert(n > 0);
ffffffffc0201c48:	00006697          	auipc	a3,0x6
ffffffffc0201c4c:	9e068693          	addi	a3,a3,-1568 # ffffffffc0207628 <etext+0xdde>
ffffffffc0201c50:	00005617          	auipc	a2,0x5
ffffffffc0201c54:	27860613          	addi	a2,a2,632 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0201c58:	08000593          	li	a1,128
ffffffffc0201c5c:	00005517          	auipc	a0,0x5
ffffffffc0201c60:	68c50513          	addi	a0,a0,1676 # ffffffffc02072e8 <etext+0xa9e>
ffffffffc0201c64:	811fe0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc0201c68 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0201c68:	c949                	beqz	a0,ffffffffc0201cfa <default_alloc_pages+0x92>
    if (n > nr_free) {
ffffffffc0201c6a:	00098617          	auipc	a2,0x98
ffffffffc0201c6e:	23e60613          	addi	a2,a2,574 # ffffffffc0299ea8 <free_area>
ffffffffc0201c72:	4a0c                	lw	a1,16(a2)
ffffffffc0201c74:	872a                	mv	a4,a0
ffffffffc0201c76:	02059793          	slli	a5,a1,0x20
ffffffffc0201c7a:	9381                	srli	a5,a5,0x20
ffffffffc0201c7c:	00a7eb63          	bltu	a5,a0,ffffffffc0201c92 <default_alloc_pages+0x2a>
    list_entry_t *le = &free_list;
ffffffffc0201c80:	87b2                	mv	a5,a2
ffffffffc0201c82:	a029                	j	ffffffffc0201c8c <default_alloc_pages+0x24>
        if (p->property >= n) {
ffffffffc0201c84:	ff87e683          	lwu	a3,-8(a5)
ffffffffc0201c88:	00e6f763          	bgeu	a3,a4,ffffffffc0201c96 <default_alloc_pages+0x2e>
    return listelm->next;
ffffffffc0201c8c:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201c8e:	fec79be3          	bne	a5,a2,ffffffffc0201c84 <default_alloc_pages+0x1c>
        return NULL;
ffffffffc0201c92:	4501                	li	a0,0
}
ffffffffc0201c94:	8082                	ret
    __list_del(listelm->prev, listelm->next);
ffffffffc0201c96:	0087b883          	ld	a7,8(a5)
        if (page->property > n) {
ffffffffc0201c9a:	ff87a803          	lw	a6,-8(a5)
    return listelm->prev;
ffffffffc0201c9e:	6394                	ld	a3,0(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc0201ca0:	fe878513          	addi	a0,a5,-24
        if (page->property > n) {
ffffffffc0201ca4:	02081313          	slli	t1,a6,0x20
    prev->next = next;
ffffffffc0201ca8:	0116b423          	sd	a7,8(a3)
    next->prev = prev;
ffffffffc0201cac:	00d8b023          	sd	a3,0(a7)
ffffffffc0201cb0:	02035313          	srli	t1,t1,0x20
            p->property = page->property - n;
ffffffffc0201cb4:	0007089b          	sext.w	a7,a4
        if (page->property > n) {
ffffffffc0201cb8:	02677963          	bgeu	a4,t1,ffffffffc0201cea <default_alloc_pages+0x82>
            struct Page *p = page + n;
ffffffffc0201cbc:	071a                	slli	a4,a4,0x6
ffffffffc0201cbe:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc0201cc0:	4118083b          	subw	a6,a6,a7
ffffffffc0201cc4:	01072823          	sw	a6,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201cc8:	4589                	li	a1,2
ffffffffc0201cca:	00870813          	addi	a6,a4,8
ffffffffc0201cce:	40b8302f          	amoor.d	zero,a1,(a6)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201cd2:	0086b803          	ld	a6,8(a3)
            list_add(prev, &(p->page_link));
ffffffffc0201cd6:	01870313          	addi	t1,a4,24
        nr_free -= n;
ffffffffc0201cda:	4a0c                	lw	a1,16(a2)
    prev->next = next->prev = elm;
ffffffffc0201cdc:	00683023          	sd	t1,0(a6)
ffffffffc0201ce0:	0066b423          	sd	t1,8(a3)
    elm->next = next;
ffffffffc0201ce4:	03073023          	sd	a6,32(a4)
    elm->prev = prev;
ffffffffc0201ce8:	ef14                	sd	a3,24(a4)
ffffffffc0201cea:	411585bb          	subw	a1,a1,a7
ffffffffc0201cee:	ca0c                	sw	a1,16(a2)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201cf0:	5775                	li	a4,-3
ffffffffc0201cf2:	17c1                	addi	a5,a5,-16
ffffffffc0201cf4:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc0201cf8:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0201cfa:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0201cfc:	00006697          	auipc	a3,0x6
ffffffffc0201d00:	92c68693          	addi	a3,a3,-1748 # ffffffffc0207628 <etext+0xdde>
ffffffffc0201d04:	00005617          	auipc	a2,0x5
ffffffffc0201d08:	1c460613          	addi	a2,a2,452 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0201d0c:	06200593          	li	a1,98
ffffffffc0201d10:	00005517          	auipc	a0,0x5
ffffffffc0201d14:	5d850513          	addi	a0,a0,1496 # ffffffffc02072e8 <etext+0xa9e>
default_alloc_pages(size_t n) {
ffffffffc0201d18:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201d1a:	f5afe0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc0201d1e <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0201d1e:	1141                	addi	sp,sp,-16
ffffffffc0201d20:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201d22:	c5f1                	beqz	a1,ffffffffc0201dee <default_init_memmap+0xd0>
    for (; p != base + n; p ++) {
ffffffffc0201d24:	00659713          	slli	a4,a1,0x6
ffffffffc0201d28:	00e506b3          	add	a3,a0,a4
    struct Page *p = base;
ffffffffc0201d2c:	87aa                	mv	a5,a0
    for (; p != base + n; p ++) {
ffffffffc0201d2e:	cf11                	beqz	a4,ffffffffc0201d4a <default_init_memmap+0x2c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201d30:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0201d32:	8b05                	andi	a4,a4,1
ffffffffc0201d34:	cf49                	beqz	a4,ffffffffc0201dce <default_init_memmap+0xb0>
        p->flags = p->property = 0;
ffffffffc0201d36:	0007a823          	sw	zero,16(a5)
ffffffffc0201d3a:	0007b423          	sd	zero,8(a5)
ffffffffc0201d3e:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201d42:	04078793          	addi	a5,a5,64
ffffffffc0201d46:	fed795e3          	bne	a5,a3,ffffffffc0201d30 <default_init_memmap+0x12>
    base->property = n;
ffffffffc0201d4a:	2581                	sext.w	a1,a1
ffffffffc0201d4c:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201d4e:	4789                	li	a5,2
ffffffffc0201d50:	00850713          	addi	a4,a0,8
ffffffffc0201d54:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0201d58:	00098697          	auipc	a3,0x98
ffffffffc0201d5c:	15068693          	addi	a3,a3,336 # ffffffffc0299ea8 <free_area>
ffffffffc0201d60:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201d62:	669c                	ld	a5,8(a3)
ffffffffc0201d64:	9f2d                	addw	a4,a4,a1
ffffffffc0201d66:	ca98                	sw	a4,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0201d68:	04d78663          	beq	a5,a3,ffffffffc0201db4 <default_init_memmap+0x96>
            struct Page* page = le2page(le, page_link);
ffffffffc0201d6c:	fe878713          	addi	a4,a5,-24
ffffffffc0201d70:	4581                	li	a1,0
ffffffffc0201d72:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc0201d76:	00e56a63          	bltu	a0,a4,ffffffffc0201d8a <default_init_memmap+0x6c>
    return listelm->next;
ffffffffc0201d7a:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201d7c:	02d70263          	beq	a4,a3,ffffffffc0201da0 <default_init_memmap+0x82>
    struct Page *p = base;
ffffffffc0201d80:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201d82:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201d86:	fee57ae3          	bgeu	a0,a4,ffffffffc0201d7a <default_init_memmap+0x5c>
ffffffffc0201d8a:	c199                	beqz	a1,ffffffffc0201d90 <default_init_memmap+0x72>
ffffffffc0201d8c:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201d90:	6398                	ld	a4,0(a5)
}
ffffffffc0201d92:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201d94:	e390                	sd	a2,0(a5)
ffffffffc0201d96:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201d98:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201d9a:	ed18                	sd	a4,24(a0)
ffffffffc0201d9c:	0141                	addi	sp,sp,16
ffffffffc0201d9e:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201da0:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201da2:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0201da4:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201da6:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0201da8:	8832                	mv	a6,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201daa:	00d70e63          	beq	a4,a3,ffffffffc0201dc6 <default_init_memmap+0xa8>
ffffffffc0201dae:	4585                	li	a1,1
    struct Page *p = base;
ffffffffc0201db0:	87ba                	mv	a5,a4
ffffffffc0201db2:	bfc1                	j	ffffffffc0201d82 <default_init_memmap+0x64>
}
ffffffffc0201db4:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201db6:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0201dba:	e398                	sd	a4,0(a5)
ffffffffc0201dbc:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0201dbe:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201dc0:	ed1c                	sd	a5,24(a0)
}
ffffffffc0201dc2:	0141                	addi	sp,sp,16
ffffffffc0201dc4:	8082                	ret
ffffffffc0201dc6:	60a2                	ld	ra,8(sp)
ffffffffc0201dc8:	e290                	sd	a2,0(a3)
ffffffffc0201dca:	0141                	addi	sp,sp,16
ffffffffc0201dcc:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201dce:	00006697          	auipc	a3,0x6
ffffffffc0201dd2:	88a68693          	addi	a3,a3,-1910 # ffffffffc0207658 <etext+0xe0e>
ffffffffc0201dd6:	00005617          	auipc	a2,0x5
ffffffffc0201dda:	0f260613          	addi	a2,a2,242 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0201dde:	04900593          	li	a1,73
ffffffffc0201de2:	00005517          	auipc	a0,0x5
ffffffffc0201de6:	50650513          	addi	a0,a0,1286 # ffffffffc02072e8 <etext+0xa9e>
ffffffffc0201dea:	e8afe0ef          	jal	ffffffffc0200474 <__panic>
    assert(n > 0);
ffffffffc0201dee:	00006697          	auipc	a3,0x6
ffffffffc0201df2:	83a68693          	addi	a3,a3,-1990 # ffffffffc0207628 <etext+0xdde>
ffffffffc0201df6:	00005617          	auipc	a2,0x5
ffffffffc0201dfa:	0d260613          	addi	a2,a2,210 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0201dfe:	04600593          	li	a1,70
ffffffffc0201e02:	00005517          	auipc	a0,0x5
ffffffffc0201e06:	4e650513          	addi	a0,a0,1254 # ffffffffc02072e8 <etext+0xa9e>
ffffffffc0201e0a:	e6afe0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc0201e0e <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc0201e0e:	cd49                	beqz	a0,ffffffffc0201ea8 <slob_free+0x9a>
{
ffffffffc0201e10:	1141                	addi	sp,sp,-16
ffffffffc0201e12:	e022                	sd	s0,0(sp)
ffffffffc0201e14:	e406                	sd	ra,8(sp)
ffffffffc0201e16:	842a                	mv	s0,a0
		return;

	if (size)
ffffffffc0201e18:	eda1                	bnez	a1,ffffffffc0201e70 <slob_free+0x62>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201e1a:	100027f3          	csrr	a5,sstatus
ffffffffc0201e1e:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201e20:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201e22:	efb9                	bnez	a5,ffffffffc0201e80 <slob_free+0x72>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201e24:	00091617          	auipc	a2,0x91
ffffffffc0201e28:	c7460613          	addi	a2,a2,-908 # ffffffffc0292a98 <slobfree>
ffffffffc0201e2c:	621c                	ld	a5,0(a2)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201e2e:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201e30:	0287fa63          	bgeu	a5,s0,ffffffffc0201e64 <slob_free+0x56>
ffffffffc0201e34:	00e46463          	bltu	s0,a4,ffffffffc0201e3c <slob_free+0x2e>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201e38:	02e7ea63          	bltu	a5,a4,ffffffffc0201e6c <slob_free+0x5e>
			break;

	if (b + b->units == cur->next) {
ffffffffc0201e3c:	400c                	lw	a1,0(s0)
ffffffffc0201e3e:	00459693          	slli	a3,a1,0x4
ffffffffc0201e42:	96a2                	add	a3,a3,s0
ffffffffc0201e44:	04d70d63          	beq	a4,a3,ffffffffc0201e9e <slob_free+0x90>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc0201e48:	438c                	lw	a1,0(a5)
ffffffffc0201e4a:	e418                	sd	a4,8(s0)
ffffffffc0201e4c:	00459693          	slli	a3,a1,0x4
ffffffffc0201e50:	96be                	add	a3,a3,a5
ffffffffc0201e52:	04d40063          	beq	s0,a3,ffffffffc0201e92 <slob_free+0x84>
ffffffffc0201e56:	e780                	sd	s0,8(a5)
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;

	slobfree = cur;
ffffffffc0201e58:	e21c                	sd	a5,0(a2)
    if (flag) {
ffffffffc0201e5a:	e51d                	bnez	a0,ffffffffc0201e88 <slob_free+0x7a>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0201e5c:	60a2                	ld	ra,8(sp)
ffffffffc0201e5e:	6402                	ld	s0,0(sp)
ffffffffc0201e60:	0141                	addi	sp,sp,16
ffffffffc0201e62:	8082                	ret
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201e64:	00e7e463          	bltu	a5,a4,ffffffffc0201e6c <slob_free+0x5e>
ffffffffc0201e68:	fce46ae3          	bltu	s0,a4,ffffffffc0201e3c <slob_free+0x2e>
        return 1;
ffffffffc0201e6c:	87ba                	mv	a5,a4
ffffffffc0201e6e:	b7c1                	j	ffffffffc0201e2e <slob_free+0x20>
		b->units = SLOB_UNITS(size);
ffffffffc0201e70:	25bd                	addiw	a1,a1,15
ffffffffc0201e72:	8191                	srli	a1,a1,0x4
ffffffffc0201e74:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201e76:	100027f3          	csrr	a5,sstatus
ffffffffc0201e7a:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201e7c:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201e7e:	d3dd                	beqz	a5,ffffffffc0201e24 <slob_free+0x16>
        intr_disable();
ffffffffc0201e80:	fc0fe0ef          	jal	ffffffffc0200640 <intr_disable>
        return 1;
ffffffffc0201e84:	4505                	li	a0,1
ffffffffc0201e86:	bf79                	j	ffffffffc0201e24 <slob_free+0x16>
}
ffffffffc0201e88:	6402                	ld	s0,0(sp)
ffffffffc0201e8a:	60a2                	ld	ra,8(sp)
ffffffffc0201e8c:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0201e8e:	facfe06f          	j	ffffffffc020063a <intr_enable>
		cur->units += b->units;
ffffffffc0201e92:	4014                	lw	a3,0(s0)
		cur->next = b->next;
ffffffffc0201e94:	843a                	mv	s0,a4
		cur->units += b->units;
ffffffffc0201e96:	00b6873b          	addw	a4,a3,a1
ffffffffc0201e9a:	c398                	sw	a4,0(a5)
		cur->next = b->next;
ffffffffc0201e9c:	bf6d                	j	ffffffffc0201e56 <slob_free+0x48>
		b->units += cur->next->units;
ffffffffc0201e9e:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201ea0:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc0201ea2:	9ead                	addw	a3,a3,a1
ffffffffc0201ea4:	c014                	sw	a3,0(s0)
		b->next = cur->next->next;
ffffffffc0201ea6:	b74d                	j	ffffffffc0201e48 <slob_free+0x3a>
ffffffffc0201ea8:	8082                	ret

ffffffffc0201eaa <__slob_get_free_pages.constprop.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201eaa:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201eac:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201eae:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201eb2:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201eb4:	34c000ef          	jal	ffffffffc0202200 <alloc_pages>
  if(!page)
ffffffffc0201eb8:	c91d                	beqz	a0,ffffffffc0201eee <__slob_get_free_pages.constprop.0+0x44>
    return page - pages + nbase;
ffffffffc0201eba:	0009c797          	auipc	a5,0x9c
ffffffffc0201ebe:	0fe7b783          	ld	a5,254(a5) # ffffffffc029dfb8 <pages>
ffffffffc0201ec2:	8d1d                	sub	a0,a0,a5
ffffffffc0201ec4:	8519                	srai	a0,a0,0x6
ffffffffc0201ec6:	00007797          	auipc	a5,0x7
ffffffffc0201eca:	08a7b783          	ld	a5,138(a5) # ffffffffc0208f50 <nbase>
ffffffffc0201ece:	953e                	add	a0,a0,a5
    return KADDR(page2pa(page));
ffffffffc0201ed0:	00c51793          	slli	a5,a0,0xc
ffffffffc0201ed4:	83b1                	srli	a5,a5,0xc
ffffffffc0201ed6:	0009c717          	auipc	a4,0x9c
ffffffffc0201eda:	0da73703          	ld	a4,218(a4) # ffffffffc029dfb0 <npage>
    return page2ppn(page) << PGSHIFT;
ffffffffc0201ede:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc0201ee0:	00e7fa63          	bgeu	a5,a4,ffffffffc0201ef4 <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc0201ee4:	0009c797          	auipc	a5,0x9c
ffffffffc0201ee8:	0c47b783          	ld	a5,196(a5) # ffffffffc029dfa8 <va_pa_offset>
ffffffffc0201eec:	953e                	add	a0,a0,a5
}
ffffffffc0201eee:	60a2                	ld	ra,8(sp)
ffffffffc0201ef0:	0141                	addi	sp,sp,16
ffffffffc0201ef2:	8082                	ret
ffffffffc0201ef4:	86aa                	mv	a3,a0
ffffffffc0201ef6:	00005617          	auipc	a2,0x5
ffffffffc0201efa:	31a60613          	addi	a2,a2,794 # ffffffffc0207210 <etext+0x9c6>
ffffffffc0201efe:	06a00593          	li	a1,106
ffffffffc0201f02:	00005517          	auipc	a0,0x5
ffffffffc0201f06:	2be50513          	addi	a0,a0,702 # ffffffffc02071c0 <etext+0x976>
ffffffffc0201f0a:	d6afe0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc0201f0e <slob_alloc.constprop.0>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0201f0e:	1101                	addi	sp,sp,-32
ffffffffc0201f10:	ec06                	sd	ra,24(sp)
ffffffffc0201f12:	e822                	sd	s0,16(sp)
ffffffffc0201f14:	e426                	sd	s1,8(sp)
ffffffffc0201f16:	e04a                	sd	s2,0(sp)
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201f18:	01050713          	addi	a4,a0,16
ffffffffc0201f1c:	6785                	lui	a5,0x1
ffffffffc0201f1e:	0cf77363          	bgeu	a4,a5,ffffffffc0201fe4 <slob_alloc.constprop.0+0xd6>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0201f22:	00f50493          	addi	s1,a0,15
ffffffffc0201f26:	8091                	srli	s1,s1,0x4
ffffffffc0201f28:	2481                	sext.w	s1,s1
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201f2a:	10002673          	csrr	a2,sstatus
ffffffffc0201f2e:	8a09                	andi	a2,a2,2
ffffffffc0201f30:	e25d                	bnez	a2,ffffffffc0201fd6 <slob_alloc.constprop.0+0xc8>
	prev = slobfree;
ffffffffc0201f32:	00091917          	auipc	s2,0x91
ffffffffc0201f36:	b6690913          	addi	s2,s2,-1178 # ffffffffc0292a98 <slobfree>
ffffffffc0201f3a:	00093683          	ld	a3,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201f3e:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201f40:	4398                	lw	a4,0(a5)
ffffffffc0201f42:	08975e63          	bge	a4,s1,ffffffffc0201fde <slob_alloc.constprop.0+0xd0>
		if (cur == slobfree) {
ffffffffc0201f46:	00f68b63          	beq	a3,a5,ffffffffc0201f5c <slob_alloc.constprop.0+0x4e>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201f4a:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201f4c:	4018                	lw	a4,0(s0)
ffffffffc0201f4e:	02975a63          	bge	a4,s1,ffffffffc0201f82 <slob_alloc.constprop.0+0x74>
		if (cur == slobfree) {
ffffffffc0201f52:	00093683          	ld	a3,0(s2)
ffffffffc0201f56:	87a2                	mv	a5,s0
ffffffffc0201f58:	fef699e3          	bne	a3,a5,ffffffffc0201f4a <slob_alloc.constprop.0+0x3c>
    if (flag) {
ffffffffc0201f5c:	ee31                	bnez	a2,ffffffffc0201fb8 <slob_alloc.constprop.0+0xaa>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201f5e:	4501                	li	a0,0
ffffffffc0201f60:	f4bff0ef          	jal	ffffffffc0201eaa <__slob_get_free_pages.constprop.0>
ffffffffc0201f64:	842a                	mv	s0,a0
			if (!cur)
ffffffffc0201f66:	cd05                	beqz	a0,ffffffffc0201f9e <slob_alloc.constprop.0+0x90>
			slob_free(cur, PAGE_SIZE);
ffffffffc0201f68:	6585                	lui	a1,0x1
ffffffffc0201f6a:	ea5ff0ef          	jal	ffffffffc0201e0e <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201f6e:	10002673          	csrr	a2,sstatus
ffffffffc0201f72:	8a09                	andi	a2,a2,2
ffffffffc0201f74:	ee05                	bnez	a2,ffffffffc0201fac <slob_alloc.constprop.0+0x9e>
			cur = slobfree;
ffffffffc0201f76:	00093783          	ld	a5,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201f7a:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201f7c:	4018                	lw	a4,0(s0)
ffffffffc0201f7e:	fc974ae3          	blt	a4,s1,ffffffffc0201f52 <slob_alloc.constprop.0+0x44>
			if (cur->units == units) /* exact fit? */
ffffffffc0201f82:	04e48763          	beq	s1,a4,ffffffffc0201fd0 <slob_alloc.constprop.0+0xc2>
				prev->next = cur + units;
ffffffffc0201f86:	00449693          	slli	a3,s1,0x4
ffffffffc0201f8a:	96a2                	add	a3,a3,s0
ffffffffc0201f8c:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0201f8e:	640c                	ld	a1,8(s0)
				prev->next->units = cur->units - units;
ffffffffc0201f90:	9f05                	subw	a4,a4,s1
ffffffffc0201f92:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0201f94:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0201f96:	c004                	sw	s1,0(s0)
			slobfree = prev;
ffffffffc0201f98:	00f93023          	sd	a5,0(s2)
    if (flag) {
ffffffffc0201f9c:	e20d                	bnez	a2,ffffffffc0201fbe <slob_alloc.constprop.0+0xb0>
}
ffffffffc0201f9e:	60e2                	ld	ra,24(sp)
ffffffffc0201fa0:	8522                	mv	a0,s0
ffffffffc0201fa2:	6442                	ld	s0,16(sp)
ffffffffc0201fa4:	64a2                	ld	s1,8(sp)
ffffffffc0201fa6:	6902                	ld	s2,0(sp)
ffffffffc0201fa8:	6105                	addi	sp,sp,32
ffffffffc0201faa:	8082                	ret
        intr_disable();
ffffffffc0201fac:	e94fe0ef          	jal	ffffffffc0200640 <intr_disable>
			cur = slobfree;
ffffffffc0201fb0:	00093783          	ld	a5,0(s2)
        return 1;
ffffffffc0201fb4:	4605                	li	a2,1
ffffffffc0201fb6:	b7d1                	j	ffffffffc0201f7a <slob_alloc.constprop.0+0x6c>
        intr_enable();
ffffffffc0201fb8:	e82fe0ef          	jal	ffffffffc020063a <intr_enable>
ffffffffc0201fbc:	b74d                	j	ffffffffc0201f5e <slob_alloc.constprop.0+0x50>
ffffffffc0201fbe:	e7cfe0ef          	jal	ffffffffc020063a <intr_enable>
}
ffffffffc0201fc2:	60e2                	ld	ra,24(sp)
ffffffffc0201fc4:	8522                	mv	a0,s0
ffffffffc0201fc6:	6442                	ld	s0,16(sp)
ffffffffc0201fc8:	64a2                	ld	s1,8(sp)
ffffffffc0201fca:	6902                	ld	s2,0(sp)
ffffffffc0201fcc:	6105                	addi	sp,sp,32
ffffffffc0201fce:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0201fd0:	6418                	ld	a4,8(s0)
ffffffffc0201fd2:	e798                	sd	a4,8(a5)
ffffffffc0201fd4:	b7d1                	j	ffffffffc0201f98 <slob_alloc.constprop.0+0x8a>
        intr_disable();
ffffffffc0201fd6:	e6afe0ef          	jal	ffffffffc0200640 <intr_disable>
        return 1;
ffffffffc0201fda:	4605                	li	a2,1
ffffffffc0201fdc:	bf99                	j	ffffffffc0201f32 <slob_alloc.constprop.0+0x24>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201fde:	843e                	mv	s0,a5
	prev = slobfree;
ffffffffc0201fe0:	87b6                	mv	a5,a3
ffffffffc0201fe2:	b745                	j	ffffffffc0201f82 <slob_alloc.constprop.0+0x74>
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201fe4:	00005697          	auipc	a3,0x5
ffffffffc0201fe8:	69c68693          	addi	a3,a3,1692 # ffffffffc0207680 <etext+0xe36>
ffffffffc0201fec:	00005617          	auipc	a2,0x5
ffffffffc0201ff0:	edc60613          	addi	a2,a2,-292 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0201ff4:	06400593          	li	a1,100
ffffffffc0201ff8:	00005517          	auipc	a0,0x5
ffffffffc0201ffc:	6a850513          	addi	a0,a0,1704 # ffffffffc02076a0 <etext+0xe56>
ffffffffc0202000:	c74fe0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc0202004 <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc0202004:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc0202006:	00005517          	auipc	a0,0x5
ffffffffc020200a:	6b250513          	addi	a0,a0,1714 # ffffffffc02076b8 <etext+0xe6e>
kmalloc_init(void) {
ffffffffc020200e:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc0202010:	970fe0ef          	jal	ffffffffc0200180 <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0202014:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0202016:	00005517          	auipc	a0,0x5
ffffffffc020201a:	6ba50513          	addi	a0,a0,1722 # ffffffffc02076d0 <etext+0xe86>
}
ffffffffc020201e:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0202020:	960fe06f          	j	ffffffffc0200180 <cprintf>

ffffffffc0202024 <kallocated>:
}

size_t
kallocated(void) {
   return slob_allocated();
}
ffffffffc0202024:	4501                	li	a0,0
ffffffffc0202026:	8082                	ret

ffffffffc0202028 <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0202028:	1101                	addi	sp,sp,-32
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc020202a:	6785                	lui	a5,0x1
{
ffffffffc020202c:	e822                	sd	s0,16(sp)
ffffffffc020202e:	ec06                	sd	ra,24(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0202030:	17bd                	addi	a5,a5,-17 # fef <_binary_obj___user_softint_out_size-0x7649>
{
ffffffffc0202032:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0202034:	04a7fa63          	bgeu	a5,a0,ffffffffc0202088 <kmalloc+0x60>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0202038:	4561                	li	a0,24
ffffffffc020203a:	e426                	sd	s1,8(sp)
ffffffffc020203c:	ed3ff0ef          	jal	ffffffffc0201f0e <slob_alloc.constprop.0>
ffffffffc0202040:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc0202042:	c549                	beqz	a0,ffffffffc02020cc <kmalloc+0xa4>
ffffffffc0202044:	e04a                	sd	s2,0(sp)
	bb->order = find_order(size);
ffffffffc0202046:	0004079b          	sext.w	a5,s0
ffffffffc020204a:	6905                	lui	s2,0x1
	int order = 0;
ffffffffc020204c:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc020204e:	00f95763          	bge	s2,a5,ffffffffc020205c <kmalloc+0x34>
ffffffffc0202052:	6705                	lui	a4,0x1
ffffffffc0202054:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0202056:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc0202058:	fef74ee3          	blt	a4,a5,ffffffffc0202054 <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc020205c:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc020205e:	e4dff0ef          	jal	ffffffffc0201eaa <__slob_get_free_pages.constprop.0>
ffffffffc0202062:	e488                	sd	a0,8(s1)
	if (bb->pages) {
ffffffffc0202064:	cd21                	beqz	a0,ffffffffc02020bc <kmalloc+0x94>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202066:	100027f3          	csrr	a5,sstatus
ffffffffc020206a:	8b89                	andi	a5,a5,2
ffffffffc020206c:	e795                	bnez	a5,ffffffffc0202098 <kmalloc+0x70>
		bb->next = bigblocks;
ffffffffc020206e:	0009c797          	auipc	a5,0x9c
ffffffffc0202072:	f1a78793          	addi	a5,a5,-230 # ffffffffc029df88 <bigblocks>
ffffffffc0202076:	6398                	ld	a4,0(a5)
ffffffffc0202078:	6902                	ld	s2,0(sp)
		bigblocks = bb;
ffffffffc020207a:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc020207c:	e898                	sd	a4,16(s1)
    if (flag) {
ffffffffc020207e:	64a2                	ld	s1,8(sp)
  return __kmalloc(size, 0);
}
ffffffffc0202080:	60e2                	ld	ra,24(sp)
ffffffffc0202082:	6442                	ld	s0,16(sp)
ffffffffc0202084:	6105                	addi	sp,sp,32
ffffffffc0202086:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0202088:	0541                	addi	a0,a0,16
ffffffffc020208a:	e85ff0ef          	jal	ffffffffc0201f0e <slob_alloc.constprop.0>
ffffffffc020208e:	87aa                	mv	a5,a0
		return m ? (void *)(m + 1) : 0;
ffffffffc0202090:	0541                	addi	a0,a0,16
ffffffffc0202092:	f7fd                	bnez	a5,ffffffffc0202080 <kmalloc+0x58>
		return 0;
ffffffffc0202094:	4501                	li	a0,0
  return __kmalloc(size, 0);
ffffffffc0202096:	b7ed                	j	ffffffffc0202080 <kmalloc+0x58>
        intr_disable();
ffffffffc0202098:	da8fe0ef          	jal	ffffffffc0200640 <intr_disable>
		bb->next = bigblocks;
ffffffffc020209c:	0009c797          	auipc	a5,0x9c
ffffffffc02020a0:	eec78793          	addi	a5,a5,-276 # ffffffffc029df88 <bigblocks>
ffffffffc02020a4:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc02020a6:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc02020a8:	e898                	sd	a4,16(s1)
        intr_enable();
ffffffffc02020aa:	d90fe0ef          	jal	ffffffffc020063a <intr_enable>
}
ffffffffc02020ae:	60e2                	ld	ra,24(sp)
ffffffffc02020b0:	6442                	ld	s0,16(sp)
		return bb->pages;
ffffffffc02020b2:	6488                	ld	a0,8(s1)
ffffffffc02020b4:	6902                	ld	s2,0(sp)
ffffffffc02020b6:	64a2                	ld	s1,8(sp)
}
ffffffffc02020b8:	6105                	addi	sp,sp,32
ffffffffc02020ba:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc02020bc:	8526                	mv	a0,s1
ffffffffc02020be:	45e1                	li	a1,24
ffffffffc02020c0:	d4fff0ef          	jal	ffffffffc0201e0e <slob_free>
		return 0;
ffffffffc02020c4:	4501                	li	a0,0
	slob_free(bb, sizeof(bigblock_t));
ffffffffc02020c6:	64a2                	ld	s1,8(sp)
ffffffffc02020c8:	6902                	ld	s2,0(sp)
ffffffffc02020ca:	bf5d                	j	ffffffffc0202080 <kmalloc+0x58>
ffffffffc02020cc:	64a2                	ld	s1,8(sp)
		return 0;
ffffffffc02020ce:	4501                	li	a0,0
ffffffffc02020d0:	bf45                	j	ffffffffc0202080 <kmalloc+0x58>

ffffffffc02020d2 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc02020d2:	c169                	beqz	a0,ffffffffc0202194 <kfree+0xc2>
{
ffffffffc02020d4:	1101                	addi	sp,sp,-32
ffffffffc02020d6:	e822                	sd	s0,16(sp)
ffffffffc02020d8:	ec06                	sd	ra,24(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc02020da:	03451793          	slli	a5,a0,0x34
ffffffffc02020de:	842a                	mv	s0,a0
ffffffffc02020e0:	e7c9                	bnez	a5,ffffffffc020216a <kfree+0x98>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02020e2:	100027f3          	csrr	a5,sstatus
ffffffffc02020e6:	8b89                	andi	a5,a5,2
ffffffffc02020e8:	ebc1                	bnez	a5,ffffffffc0202178 <kfree+0xa6>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc02020ea:	0009c797          	auipc	a5,0x9c
ffffffffc02020ee:	e9e7b783          	ld	a5,-354(a5) # ffffffffc029df88 <bigblocks>
    return 0;
ffffffffc02020f2:	4601                	li	a2,0
ffffffffc02020f4:	cbbd                	beqz	a5,ffffffffc020216a <kfree+0x98>
ffffffffc02020f6:	e426                	sd	s1,8(sp)
	bigblock_t *bb, **last = &bigblocks;
ffffffffc02020f8:	0009c697          	auipc	a3,0x9c
ffffffffc02020fc:	e9068693          	addi	a3,a3,-368 # ffffffffc029df88 <bigblocks>
ffffffffc0202100:	a021                	j	ffffffffc0202108 <kfree+0x36>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0202102:	01048693          	addi	a3,s1,16
ffffffffc0202106:	c3a5                	beqz	a5,ffffffffc0202166 <kfree+0x94>
			if (bb->pages == block) {
ffffffffc0202108:	6798                	ld	a4,8(a5)
ffffffffc020210a:	84be                	mv	s1,a5
				*last = bb->next;
ffffffffc020210c:	6b9c                	ld	a5,16(a5)
			if (bb->pages == block) {
ffffffffc020210e:	fe871ae3          	bne	a4,s0,ffffffffc0202102 <kfree+0x30>
				*last = bb->next;
ffffffffc0202112:	e29c                	sd	a5,0(a3)
    if (flag) {
ffffffffc0202114:	ee2d                	bnez	a2,ffffffffc020218e <kfree+0xbc>
    return pa2page(PADDR(kva));
ffffffffc0202116:	c02007b7          	lui	a5,0xc0200
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc020211a:	4098                	lw	a4,0(s1)
ffffffffc020211c:	08f46963          	bltu	s0,a5,ffffffffc02021ae <kfree+0xdc>
ffffffffc0202120:	0009c797          	auipc	a5,0x9c
ffffffffc0202124:	e887b783          	ld	a5,-376(a5) # ffffffffc029dfa8 <va_pa_offset>
ffffffffc0202128:	8c1d                	sub	s0,s0,a5
    if (PPN(pa) >= npage) {
ffffffffc020212a:	8031                	srli	s0,s0,0xc
ffffffffc020212c:	0009c797          	auipc	a5,0x9c
ffffffffc0202130:	e847b783          	ld	a5,-380(a5) # ffffffffc029dfb0 <npage>
ffffffffc0202134:	06f47163          	bgeu	s0,a5,ffffffffc0202196 <kfree+0xc4>
    return &pages[PPN(pa) - nbase];
ffffffffc0202138:	00007797          	auipc	a5,0x7
ffffffffc020213c:	e187b783          	ld	a5,-488(a5) # ffffffffc0208f50 <nbase>
ffffffffc0202140:	8c1d                	sub	s0,s0,a5
ffffffffc0202142:	041a                	slli	s0,s0,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc0202144:	0009c517          	auipc	a0,0x9c
ffffffffc0202148:	e7453503          	ld	a0,-396(a0) # ffffffffc029dfb8 <pages>
ffffffffc020214c:	4585                	li	a1,1
ffffffffc020214e:	9522                	add	a0,a0,s0
ffffffffc0202150:	00e595bb          	sllw	a1,a1,a4
ffffffffc0202154:	13c000ef          	jal	ffffffffc0202290 <free_pages>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0202158:	6442                	ld	s0,16(sp)
ffffffffc020215a:	60e2                	ld	ra,24(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc020215c:	8526                	mv	a0,s1
ffffffffc020215e:	64a2                	ld	s1,8(sp)
ffffffffc0202160:	45e1                	li	a1,24
}
ffffffffc0202162:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0202164:	b16d                	j	ffffffffc0201e0e <slob_free>
ffffffffc0202166:	64a2                	ld	s1,8(sp)
ffffffffc0202168:	e205                	bnez	a2,ffffffffc0202188 <kfree+0xb6>
ffffffffc020216a:	ff040513          	addi	a0,s0,-16
}
ffffffffc020216e:	6442                	ld	s0,16(sp)
ffffffffc0202170:	60e2                	ld	ra,24(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0202172:	4581                	li	a1,0
}
ffffffffc0202174:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0202176:	b961                	j	ffffffffc0201e0e <slob_free>
        intr_disable();
ffffffffc0202178:	cc8fe0ef          	jal	ffffffffc0200640 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc020217c:	0009c797          	auipc	a5,0x9c
ffffffffc0202180:	e0c7b783          	ld	a5,-500(a5) # ffffffffc029df88 <bigblocks>
        return 1;
ffffffffc0202184:	4605                	li	a2,1
ffffffffc0202186:	fba5                	bnez	a5,ffffffffc02020f6 <kfree+0x24>
        intr_enable();
ffffffffc0202188:	cb2fe0ef          	jal	ffffffffc020063a <intr_enable>
ffffffffc020218c:	bff9                	j	ffffffffc020216a <kfree+0x98>
ffffffffc020218e:	cacfe0ef          	jal	ffffffffc020063a <intr_enable>
ffffffffc0202192:	b751                	j	ffffffffc0202116 <kfree+0x44>
ffffffffc0202194:	8082                	ret
        panic("pa2page called with invalid pa");
ffffffffc0202196:	00005617          	auipc	a2,0x5
ffffffffc020219a:	00a60613          	addi	a2,a2,10 # ffffffffc02071a0 <etext+0x956>
ffffffffc020219e:	06300593          	li	a1,99
ffffffffc02021a2:	00005517          	auipc	a0,0x5
ffffffffc02021a6:	01e50513          	addi	a0,a0,30 # ffffffffc02071c0 <etext+0x976>
ffffffffc02021aa:	acafe0ef          	jal	ffffffffc0200474 <__panic>
    return pa2page(PADDR(kva));
ffffffffc02021ae:	86a2                	mv	a3,s0
ffffffffc02021b0:	00005617          	auipc	a2,0x5
ffffffffc02021b4:	0b060613          	addi	a2,a2,176 # ffffffffc0207260 <etext+0xa16>
ffffffffc02021b8:	06f00593          	li	a1,111
ffffffffc02021bc:	00005517          	auipc	a0,0x5
ffffffffc02021c0:	00450513          	addi	a0,a0,4 # ffffffffc02071c0 <etext+0x976>
ffffffffc02021c4:	ab0fe0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc02021c8 <pa2page.part.0>:
pa2page(uintptr_t pa) {
ffffffffc02021c8:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc02021ca:	00005617          	auipc	a2,0x5
ffffffffc02021ce:	fd660613          	addi	a2,a2,-42 # ffffffffc02071a0 <etext+0x956>
ffffffffc02021d2:	06300593          	li	a1,99
ffffffffc02021d6:	00005517          	auipc	a0,0x5
ffffffffc02021da:	fea50513          	addi	a0,a0,-22 # ffffffffc02071c0 <etext+0x976>
pa2page(uintptr_t pa) {
ffffffffc02021de:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc02021e0:	a94fe0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc02021e4 <pte2page.part.0>:
pte2page(pte_t pte) {
ffffffffc02021e4:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc02021e6:	00005617          	auipc	a2,0x5
ffffffffc02021ea:	0ba60613          	addi	a2,a2,186 # ffffffffc02072a0 <etext+0xa56>
ffffffffc02021ee:	07500593          	li	a1,117
ffffffffc02021f2:	00005517          	auipc	a0,0x5
ffffffffc02021f6:	fce50513          	addi	a0,a0,-50 # ffffffffc02071c0 <etext+0x976>
pte2page(pte_t pte) {
ffffffffc02021fa:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc02021fc:	a78fe0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc0202200 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0202200:	7139                	addi	sp,sp,-64
ffffffffc0202202:	f426                	sd	s1,40(sp)
ffffffffc0202204:	f04a                	sd	s2,32(sp)
ffffffffc0202206:	ec4e                	sd	s3,24(sp)
ffffffffc0202208:	e852                	sd	s4,16(sp)
ffffffffc020220a:	e456                	sd	s5,8(sp)
ffffffffc020220c:	e05a                	sd	s6,0(sp)
ffffffffc020220e:	fc06                	sd	ra,56(sp)
ffffffffc0202210:	f822                	sd	s0,48(sp)
ffffffffc0202212:	84aa                	mv	s1,a0
ffffffffc0202214:	0009c917          	auipc	s2,0x9c
ffffffffc0202218:	d7c90913          	addi	s2,s2,-644 # ffffffffc029df90 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc020221c:	4a05                	li	s4,1
ffffffffc020221e:	0009ca97          	auipc	s5,0x9c
ffffffffc0202222:	da2a8a93          	addi	s5,s5,-606 # ffffffffc029dfc0 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0202226:	0005099b          	sext.w	s3,a0
ffffffffc020222a:	0009cb17          	auipc	s6,0x9c
ffffffffc020222e:	db6b0b13          	addi	s6,s6,-586 # ffffffffc029dfe0 <check_mm_struct>
ffffffffc0202232:	a015                	j	ffffffffc0202256 <alloc_pages+0x56>
            page = pmm_manager->alloc_pages(n);
ffffffffc0202234:	00093783          	ld	a5,0(s2)
ffffffffc0202238:	6f9c                	ld	a5,24(a5)
ffffffffc020223a:	9782                	jalr	a5
ffffffffc020223c:	842a                	mv	s0,a0
        swap_out(check_mm_struct, n, 0);
ffffffffc020223e:	4601                	li	a2,0
ffffffffc0202240:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0202242:	ec05                	bnez	s0,ffffffffc020227a <alloc_pages+0x7a>
ffffffffc0202244:	029a6b63          	bltu	s4,s1,ffffffffc020227a <alloc_pages+0x7a>
ffffffffc0202248:	000aa783          	lw	a5,0(s5)
ffffffffc020224c:	c79d                	beqz	a5,ffffffffc020227a <alloc_pages+0x7a>
        swap_out(check_mm_struct, n, 0);
ffffffffc020224e:	000b3503          	ld	a0,0(s6)
ffffffffc0202252:	479010ef          	jal	ffffffffc0203eca <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202256:	100027f3          	csrr	a5,sstatus
ffffffffc020225a:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc020225c:	8526                	mv	a0,s1
ffffffffc020225e:	dbf9                	beqz	a5,ffffffffc0202234 <alloc_pages+0x34>
        intr_disable();
ffffffffc0202260:	be0fe0ef          	jal	ffffffffc0200640 <intr_disable>
ffffffffc0202264:	00093783          	ld	a5,0(s2)
ffffffffc0202268:	8526                	mv	a0,s1
ffffffffc020226a:	6f9c                	ld	a5,24(a5)
ffffffffc020226c:	9782                	jalr	a5
ffffffffc020226e:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202270:	bcafe0ef          	jal	ffffffffc020063a <intr_enable>
        swap_out(check_mm_struct, n, 0);
ffffffffc0202274:	4601                	li	a2,0
ffffffffc0202276:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0202278:	d471                	beqz	s0,ffffffffc0202244 <alloc_pages+0x44>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc020227a:	70e2                	ld	ra,56(sp)
ffffffffc020227c:	8522                	mv	a0,s0
ffffffffc020227e:	7442                	ld	s0,48(sp)
ffffffffc0202280:	74a2                	ld	s1,40(sp)
ffffffffc0202282:	7902                	ld	s2,32(sp)
ffffffffc0202284:	69e2                	ld	s3,24(sp)
ffffffffc0202286:	6a42                	ld	s4,16(sp)
ffffffffc0202288:	6aa2                	ld	s5,8(sp)
ffffffffc020228a:	6b02                	ld	s6,0(sp)
ffffffffc020228c:	6121                	addi	sp,sp,64
ffffffffc020228e:	8082                	ret

ffffffffc0202290 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202290:	100027f3          	csrr	a5,sstatus
ffffffffc0202294:	8b89                	andi	a5,a5,2
ffffffffc0202296:	e799                	bnez	a5,ffffffffc02022a4 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0202298:	0009c797          	auipc	a5,0x9c
ffffffffc020229c:	cf87b783          	ld	a5,-776(a5) # ffffffffc029df90 <pmm_manager>
ffffffffc02022a0:	739c                	ld	a5,32(a5)
ffffffffc02022a2:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc02022a4:	1101                	addi	sp,sp,-32
ffffffffc02022a6:	ec06                	sd	ra,24(sp)
ffffffffc02022a8:	e822                	sd	s0,16(sp)
ffffffffc02022aa:	e426                	sd	s1,8(sp)
ffffffffc02022ac:	842a                	mv	s0,a0
ffffffffc02022ae:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc02022b0:	b90fe0ef          	jal	ffffffffc0200640 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02022b4:	0009c797          	auipc	a5,0x9c
ffffffffc02022b8:	cdc7b783          	ld	a5,-804(a5) # ffffffffc029df90 <pmm_manager>
ffffffffc02022bc:	739c                	ld	a5,32(a5)
ffffffffc02022be:	85a6                	mv	a1,s1
ffffffffc02022c0:	8522                	mv	a0,s0
ffffffffc02022c2:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc02022c4:	6442                	ld	s0,16(sp)
ffffffffc02022c6:	60e2                	ld	ra,24(sp)
ffffffffc02022c8:	64a2                	ld	s1,8(sp)
ffffffffc02022ca:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02022cc:	b6efe06f          	j	ffffffffc020063a <intr_enable>

ffffffffc02022d0 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02022d0:	100027f3          	csrr	a5,sstatus
ffffffffc02022d4:	8b89                	andi	a5,a5,2
ffffffffc02022d6:	e799                	bnez	a5,ffffffffc02022e4 <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc02022d8:	0009c797          	auipc	a5,0x9c
ffffffffc02022dc:	cb87b783          	ld	a5,-840(a5) # ffffffffc029df90 <pmm_manager>
ffffffffc02022e0:	779c                	ld	a5,40(a5)
ffffffffc02022e2:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc02022e4:	1141                	addi	sp,sp,-16
ffffffffc02022e6:	e406                	sd	ra,8(sp)
ffffffffc02022e8:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc02022ea:	b56fe0ef          	jal	ffffffffc0200640 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc02022ee:	0009c797          	auipc	a5,0x9c
ffffffffc02022f2:	ca27b783          	ld	a5,-862(a5) # ffffffffc029df90 <pmm_manager>
ffffffffc02022f6:	779c                	ld	a5,40(a5)
ffffffffc02022f8:	9782                	jalr	a5
ffffffffc02022fa:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02022fc:	b3efe0ef          	jal	ffffffffc020063a <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0202300:	60a2                	ld	ra,8(sp)
ffffffffc0202302:	8522                	mv	a0,s0
ffffffffc0202304:	6402                	ld	s0,0(sp)
ffffffffc0202306:	0141                	addi	sp,sp,16
ffffffffc0202308:	8082                	ret

ffffffffc020230a <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc020230a:	01e5d793          	srli	a5,a1,0x1e
ffffffffc020230e:	1ff7f793          	andi	a5,a5,511
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0202312:	7139                	addi	sp,sp,-64
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0202314:	078e                	slli	a5,a5,0x3
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0202316:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0202318:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V)) {
ffffffffc020231c:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc020231e:	f04a                	sd	s2,32(sp)
ffffffffc0202320:	ec4e                	sd	s3,24(sp)
ffffffffc0202322:	e852                	sd	s4,16(sp)
ffffffffc0202324:	fc06                	sd	ra,56(sp)
ffffffffc0202326:	f822                	sd	s0,48(sp)
ffffffffc0202328:	e456                	sd	s5,8(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc020232a:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc020232e:	892e                	mv	s2,a1
ffffffffc0202330:	89b2                	mv	s3,a2
ffffffffc0202332:	0009ca17          	auipc	s4,0x9c
ffffffffc0202336:	c7ea0a13          	addi	s4,s4,-898 # ffffffffc029dfb0 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc020233a:	eba5                	bnez	a5,ffffffffc02023aa <get_pte+0xa0>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc020233c:	12060e63          	beqz	a2,ffffffffc0202478 <get_pte+0x16e>
ffffffffc0202340:	4505                	li	a0,1
ffffffffc0202342:	ebfff0ef          	jal	ffffffffc0202200 <alloc_pages>
ffffffffc0202346:	842a                	mv	s0,a0
ffffffffc0202348:	12050863          	beqz	a0,ffffffffc0202478 <get_pte+0x16e>
    page->ref = val;
ffffffffc020234c:	e05a                	sd	s6,0(sp)
    return page - pages + nbase;
ffffffffc020234e:	0009cb17          	auipc	s6,0x9c
ffffffffc0202352:	c6ab0b13          	addi	s6,s6,-918 # ffffffffc029dfb8 <pages>
ffffffffc0202356:	000b3503          	ld	a0,0(s6)
ffffffffc020235a:	00080ab7          	lui	s5,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc020235e:	0009ca17          	auipc	s4,0x9c
ffffffffc0202362:	c52a0a13          	addi	s4,s4,-942 # ffffffffc029dfb0 <npage>
ffffffffc0202366:	40a40533          	sub	a0,s0,a0
ffffffffc020236a:	8519                	srai	a0,a0,0x6
ffffffffc020236c:	9556                	add	a0,a0,s5
ffffffffc020236e:	000a3703          	ld	a4,0(s4)
ffffffffc0202372:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0202376:	4685                	li	a3,1
ffffffffc0202378:	c014                	sw	a3,0(s0)
ffffffffc020237a:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020237c:	0532                	slli	a0,a0,0xc
ffffffffc020237e:	14e7f563          	bgeu	a5,a4,ffffffffc02024c8 <get_pte+0x1be>
ffffffffc0202382:	0009c797          	auipc	a5,0x9c
ffffffffc0202386:	c267b783          	ld	a5,-986(a5) # ffffffffc029dfa8 <va_pa_offset>
ffffffffc020238a:	953e                	add	a0,a0,a5
ffffffffc020238c:	6605                	lui	a2,0x1
ffffffffc020238e:	4581                	li	a1,0
ffffffffc0202390:	490040ef          	jal	ffffffffc0206820 <memset>
    return page - pages + nbase;
ffffffffc0202394:	000b3783          	ld	a5,0(s6)
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0202398:	6b02                	ld	s6,0(sp)
ffffffffc020239a:	40f406b3          	sub	a3,s0,a5
ffffffffc020239e:	8699                	srai	a3,a3,0x6
ffffffffc02023a0:	96d6                	add	a3,a3,s5
  asm volatile("sfence.vma");
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02023a2:	06aa                	slli	a3,a3,0xa
ffffffffc02023a4:	0116e693          	ori	a3,a3,17
ffffffffc02023a8:	e094                	sd	a3,0(s1)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc02023aa:	77fd                	lui	a5,0xfffff
ffffffffc02023ac:	068a                	slli	a3,a3,0x2
ffffffffc02023ae:	000a3703          	ld	a4,0(s4)
ffffffffc02023b2:	8efd                	and	a3,a3,a5
ffffffffc02023b4:	00c6d793          	srli	a5,a3,0xc
ffffffffc02023b8:	0ce7f263          	bgeu	a5,a4,ffffffffc020247c <get_pte+0x172>
ffffffffc02023bc:	0009ca97          	auipc	s5,0x9c
ffffffffc02023c0:	beca8a93          	addi	s5,s5,-1044 # ffffffffc029dfa8 <va_pa_offset>
ffffffffc02023c4:	000ab603          	ld	a2,0(s5)
ffffffffc02023c8:	01595793          	srli	a5,s2,0x15
ffffffffc02023cc:	1ff7f793          	andi	a5,a5,511
ffffffffc02023d0:	96b2                	add	a3,a3,a2
ffffffffc02023d2:	078e                	slli	a5,a5,0x3
ffffffffc02023d4:	00f68433          	add	s0,a3,a5
    if (!(*pdep0 & PTE_V)) {
ffffffffc02023d8:	6014                	ld	a3,0(s0)
ffffffffc02023da:	0016f793          	andi	a5,a3,1
ffffffffc02023de:	e3bd                	bnez	a5,ffffffffc0202444 <get_pte+0x13a>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc02023e0:	08098c63          	beqz	s3,ffffffffc0202478 <get_pte+0x16e>
ffffffffc02023e4:	4505                	li	a0,1
ffffffffc02023e6:	e1bff0ef          	jal	ffffffffc0202200 <alloc_pages>
ffffffffc02023ea:	84aa                	mv	s1,a0
ffffffffc02023ec:	c551                	beqz	a0,ffffffffc0202478 <get_pte+0x16e>
    page->ref = val;
ffffffffc02023ee:	e05a                	sd	s6,0(sp)
    return page - pages + nbase;
ffffffffc02023f0:	0009cb17          	auipc	s6,0x9c
ffffffffc02023f4:	bc8b0b13          	addi	s6,s6,-1080 # ffffffffc029dfb8 <pages>
ffffffffc02023f8:	000b3683          	ld	a3,0(s6)
ffffffffc02023fc:	000809b7          	lui	s3,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202400:	000a3703          	ld	a4,0(s4)
ffffffffc0202404:	40d506b3          	sub	a3,a0,a3
ffffffffc0202408:	8699                	srai	a3,a3,0x6
ffffffffc020240a:	96ce                	add	a3,a3,s3
ffffffffc020240c:	00c69793          	slli	a5,a3,0xc
    page->ref = val;
ffffffffc0202410:	4605                	li	a2,1
ffffffffc0202412:	c110                	sw	a2,0(a0)
ffffffffc0202414:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202416:	06b2                	slli	a3,a3,0xc
ffffffffc0202418:	08e7fc63          	bgeu	a5,a4,ffffffffc02024b0 <get_pte+0x1a6>
ffffffffc020241c:	000ab503          	ld	a0,0(s5)
ffffffffc0202420:	6605                	lui	a2,0x1
ffffffffc0202422:	4581                	li	a1,0
ffffffffc0202424:	9536                	add	a0,a0,a3
ffffffffc0202426:	3fa040ef          	jal	ffffffffc0206820 <memset>
    return page - pages + nbase;
ffffffffc020242a:	000b3783          	ld	a5,0(s6)
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
        }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc020242e:	6b02                	ld	s6,0(sp)
ffffffffc0202430:	40f486b3          	sub	a3,s1,a5
ffffffffc0202434:	8699                	srai	a3,a3,0x6
ffffffffc0202436:	96ce                	add	a3,a3,s3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202438:	06aa                	slli	a3,a3,0xa
ffffffffc020243a:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc020243e:	e014                	sd	a3,0(s0)
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0202440:	000a3703          	ld	a4,0(s4)
ffffffffc0202444:	77fd                	lui	a5,0xfffff
ffffffffc0202446:	068a                	slli	a3,a3,0x2
ffffffffc0202448:	8efd                	and	a3,a3,a5
ffffffffc020244a:	00c6d793          	srli	a5,a3,0xc
ffffffffc020244e:	04e7f463          	bgeu	a5,a4,ffffffffc0202496 <get_pte+0x18c>
ffffffffc0202452:	000ab783          	ld	a5,0(s5)
ffffffffc0202456:	00c95913          	srli	s2,s2,0xc
ffffffffc020245a:	1ff97913          	andi	s2,s2,511
ffffffffc020245e:	96be                	add	a3,a3,a5
ffffffffc0202460:	090e                	slli	s2,s2,0x3
ffffffffc0202462:	01268533          	add	a0,a3,s2
}
ffffffffc0202466:	70e2                	ld	ra,56(sp)
ffffffffc0202468:	7442                	ld	s0,48(sp)
ffffffffc020246a:	74a2                	ld	s1,40(sp)
ffffffffc020246c:	7902                	ld	s2,32(sp)
ffffffffc020246e:	69e2                	ld	s3,24(sp)
ffffffffc0202470:	6a42                	ld	s4,16(sp)
ffffffffc0202472:	6aa2                	ld	s5,8(sp)
ffffffffc0202474:	6121                	addi	sp,sp,64
ffffffffc0202476:	8082                	ret
            return NULL;
ffffffffc0202478:	4501                	li	a0,0
ffffffffc020247a:	b7f5                	j	ffffffffc0202466 <get_pte+0x15c>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc020247c:	00005617          	auipc	a2,0x5
ffffffffc0202480:	d9460613          	addi	a2,a2,-620 # ffffffffc0207210 <etext+0x9c6>
ffffffffc0202484:	0e300593          	li	a1,227
ffffffffc0202488:	00005517          	auipc	a0,0x5
ffffffffc020248c:	26850513          	addi	a0,a0,616 # ffffffffc02076f0 <etext+0xea6>
ffffffffc0202490:	e05a                	sd	s6,0(sp)
ffffffffc0202492:	fe3fd0ef          	jal	ffffffffc0200474 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0202496:	00005617          	auipc	a2,0x5
ffffffffc020249a:	d7a60613          	addi	a2,a2,-646 # ffffffffc0207210 <etext+0x9c6>
ffffffffc020249e:	0ee00593          	li	a1,238
ffffffffc02024a2:	00005517          	auipc	a0,0x5
ffffffffc02024a6:	24e50513          	addi	a0,a0,590 # ffffffffc02076f0 <etext+0xea6>
ffffffffc02024aa:	e05a                	sd	s6,0(sp)
ffffffffc02024ac:	fc9fd0ef          	jal	ffffffffc0200474 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02024b0:	00005617          	auipc	a2,0x5
ffffffffc02024b4:	d6060613          	addi	a2,a2,-672 # ffffffffc0207210 <etext+0x9c6>
ffffffffc02024b8:	0eb00593          	li	a1,235
ffffffffc02024bc:	00005517          	auipc	a0,0x5
ffffffffc02024c0:	23450513          	addi	a0,a0,564 # ffffffffc02076f0 <etext+0xea6>
ffffffffc02024c4:	fb1fd0ef          	jal	ffffffffc0200474 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02024c8:	86aa                	mv	a3,a0
ffffffffc02024ca:	00005617          	auipc	a2,0x5
ffffffffc02024ce:	d4660613          	addi	a2,a2,-698 # ffffffffc0207210 <etext+0x9c6>
ffffffffc02024d2:	0df00593          	li	a1,223
ffffffffc02024d6:	00005517          	auipc	a0,0x5
ffffffffc02024da:	21a50513          	addi	a0,a0,538 # ffffffffc02076f0 <etext+0xea6>
ffffffffc02024de:	f97fd0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc02024e2 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc02024e2:	1141                	addi	sp,sp,-16
ffffffffc02024e4:	e022                	sd	s0,0(sp)
ffffffffc02024e6:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02024e8:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc02024ea:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02024ec:	e1fff0ef          	jal	ffffffffc020230a <get_pte>
    if (ptep_store != NULL) {
ffffffffc02024f0:	c011                	beqz	s0,ffffffffc02024f4 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc02024f2:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc02024f4:	c511                	beqz	a0,ffffffffc0202500 <get_page+0x1e>
ffffffffc02024f6:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc02024f8:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc02024fa:	0017f713          	andi	a4,a5,1
ffffffffc02024fe:	e709                	bnez	a4,ffffffffc0202508 <get_page+0x26>
}
ffffffffc0202500:	60a2                	ld	ra,8(sp)
ffffffffc0202502:	6402                	ld	s0,0(sp)
ffffffffc0202504:	0141                	addi	sp,sp,16
ffffffffc0202506:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202508:	078a                	slli	a5,a5,0x2
ffffffffc020250a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020250c:	0009c717          	auipc	a4,0x9c
ffffffffc0202510:	aa473703          	ld	a4,-1372(a4) # ffffffffc029dfb0 <npage>
ffffffffc0202514:	00e7ff63          	bgeu	a5,a4,ffffffffc0202532 <get_page+0x50>
ffffffffc0202518:	60a2                	ld	ra,8(sp)
ffffffffc020251a:	6402                	ld	s0,0(sp)
    return &pages[PPN(pa) - nbase];
ffffffffc020251c:	fff80737          	lui	a4,0xfff80
ffffffffc0202520:	97ba                	add	a5,a5,a4
ffffffffc0202522:	0009c517          	auipc	a0,0x9c
ffffffffc0202526:	a9653503          	ld	a0,-1386(a0) # ffffffffc029dfb8 <pages>
ffffffffc020252a:	079a                	slli	a5,a5,0x6
ffffffffc020252c:	953e                	add	a0,a0,a5
ffffffffc020252e:	0141                	addi	sp,sp,16
ffffffffc0202530:	8082                	ret
ffffffffc0202532:	c97ff0ef          	jal	ffffffffc02021c8 <pa2page.part.0>

ffffffffc0202536 <unmap_range>:
        *ptep = 0;                  //(5) clear second page table entry
        tlb_invalidate(pgdir, la);  //(6) flush tlb
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0202536:	715d                	addi	sp,sp,-80
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202538:	00c5e7b3          	or	a5,a1,a2
void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc020253c:	e486                	sd	ra,72(sp)
ffffffffc020253e:	e0a2                	sd	s0,64(sp)
ffffffffc0202540:	fc26                	sd	s1,56(sp)
ffffffffc0202542:	f84a                	sd	s2,48(sp)
ffffffffc0202544:	f44e                	sd	s3,40(sp)
ffffffffc0202546:	f052                	sd	s4,32(sp)
ffffffffc0202548:	ec56                	sd	s5,24(sp)
ffffffffc020254a:	e85a                	sd	s6,16(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020254c:	17d2                	slli	a5,a5,0x34
ffffffffc020254e:	e7f9                	bnez	a5,ffffffffc020261c <unmap_range+0xe6>
    assert(USER_ACCESS(start, end));
ffffffffc0202550:	002007b7          	lui	a5,0x200
ffffffffc0202554:	842e                	mv	s0,a1
ffffffffc0202556:	0ef5e363          	bltu	a1,a5,ffffffffc020263c <unmap_range+0x106>
ffffffffc020255a:	8932                	mv	s2,a2
ffffffffc020255c:	0ec5f063          	bgeu	a1,a2,ffffffffc020263c <unmap_range+0x106>
ffffffffc0202560:	4785                	li	a5,1
ffffffffc0202562:	07fe                	slli	a5,a5,0x1f
ffffffffc0202564:	0cc7ec63          	bltu	a5,a2,ffffffffc020263c <unmap_range+0x106>
ffffffffc0202568:	89aa                	mv	s3,a0
            continue;
        }
        if (*ptep != 0) {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc020256a:	6a05                	lui	s4,0x1
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc020256c:	00200b37          	lui	s6,0x200
ffffffffc0202570:	ffe00ab7          	lui	s5,0xffe00
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc0202574:	4601                	li	a2,0
ffffffffc0202576:	85a2                	mv	a1,s0
ffffffffc0202578:	854e                	mv	a0,s3
ffffffffc020257a:	d91ff0ef          	jal	ffffffffc020230a <get_pte>
ffffffffc020257e:	84aa                	mv	s1,a0
        if (ptep == NULL) {
ffffffffc0202580:	c125                	beqz	a0,ffffffffc02025e0 <unmap_range+0xaa>
        if (*ptep != 0) {
ffffffffc0202582:	611c                	ld	a5,0(a0)
ffffffffc0202584:	ef99                	bnez	a5,ffffffffc02025a2 <unmap_range+0x6c>
        start += PGSIZE;
ffffffffc0202586:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc0202588:	c019                	beqz	s0,ffffffffc020258e <unmap_range+0x58>
ffffffffc020258a:	ff2465e3          	bltu	s0,s2,ffffffffc0202574 <unmap_range+0x3e>
}
ffffffffc020258e:	60a6                	ld	ra,72(sp)
ffffffffc0202590:	6406                	ld	s0,64(sp)
ffffffffc0202592:	74e2                	ld	s1,56(sp)
ffffffffc0202594:	7942                	ld	s2,48(sp)
ffffffffc0202596:	79a2                	ld	s3,40(sp)
ffffffffc0202598:	7a02                	ld	s4,32(sp)
ffffffffc020259a:	6ae2                	ld	s5,24(sp)
ffffffffc020259c:	6b42                	ld	s6,16(sp)
ffffffffc020259e:	6161                	addi	sp,sp,80
ffffffffc02025a0:	8082                	ret
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc02025a2:	0017f713          	andi	a4,a5,1
ffffffffc02025a6:	d365                	beqz	a4,ffffffffc0202586 <unmap_range+0x50>
    return pa2page(PTE_ADDR(pte));
ffffffffc02025a8:	078a                	slli	a5,a5,0x2
ffffffffc02025aa:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02025ac:	0009c717          	auipc	a4,0x9c
ffffffffc02025b0:	a0473703          	ld	a4,-1532(a4) # ffffffffc029dfb0 <npage>
ffffffffc02025b4:	0ae7f463          	bgeu	a5,a4,ffffffffc020265c <unmap_range+0x126>
    return &pages[PPN(pa) - nbase];
ffffffffc02025b8:	fff80737          	lui	a4,0xfff80
ffffffffc02025bc:	97ba                	add	a5,a5,a4
ffffffffc02025be:	079a                	slli	a5,a5,0x6
ffffffffc02025c0:	0009c517          	auipc	a0,0x9c
ffffffffc02025c4:	9f853503          	ld	a0,-1544(a0) # ffffffffc029dfb8 <pages>
ffffffffc02025c8:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc02025ca:	411c                	lw	a5,0(a0)
ffffffffc02025cc:	fff7871b          	addiw	a4,a5,-1 # 1fffff <_binary_obj___user_exit_out_size+0x1f645f>
ffffffffc02025d0:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc02025d2:	cb19                	beqz	a4,ffffffffc02025e8 <unmap_range+0xb2>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc02025d4:	0004b023          	sd	zero,0(s1)
}

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02025d8:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc02025dc:	9452                	add	s0,s0,s4
ffffffffc02025de:	b76d                	j	ffffffffc0202588 <unmap_range+0x52>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02025e0:	945a                	add	s0,s0,s6
ffffffffc02025e2:	01547433          	and	s0,s0,s5
            continue;
ffffffffc02025e6:	b74d                	j	ffffffffc0202588 <unmap_range+0x52>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02025e8:	100027f3          	csrr	a5,sstatus
ffffffffc02025ec:	8b89                	andi	a5,a5,2
ffffffffc02025ee:	eb89                	bnez	a5,ffffffffc0202600 <unmap_range+0xca>
        pmm_manager->free_pages(base, n);
ffffffffc02025f0:	0009c797          	auipc	a5,0x9c
ffffffffc02025f4:	9a07b783          	ld	a5,-1632(a5) # ffffffffc029df90 <pmm_manager>
ffffffffc02025f8:	739c                	ld	a5,32(a5)
ffffffffc02025fa:	4585                	li	a1,1
ffffffffc02025fc:	9782                	jalr	a5
    if (flag) {
ffffffffc02025fe:	bfd9                	j	ffffffffc02025d4 <unmap_range+0x9e>
        intr_disable();
ffffffffc0202600:	e42a                	sd	a0,8(sp)
ffffffffc0202602:	83efe0ef          	jal	ffffffffc0200640 <intr_disable>
ffffffffc0202606:	0009c797          	auipc	a5,0x9c
ffffffffc020260a:	98a7b783          	ld	a5,-1654(a5) # ffffffffc029df90 <pmm_manager>
ffffffffc020260e:	739c                	ld	a5,32(a5)
ffffffffc0202610:	6522                	ld	a0,8(sp)
ffffffffc0202612:	4585                	li	a1,1
ffffffffc0202614:	9782                	jalr	a5
        intr_enable();
ffffffffc0202616:	824fe0ef          	jal	ffffffffc020063a <intr_enable>
ffffffffc020261a:	bf6d                	j	ffffffffc02025d4 <unmap_range+0x9e>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020261c:	00005697          	auipc	a3,0x5
ffffffffc0202620:	b2c68693          	addi	a3,a3,-1236 # ffffffffc0207148 <etext+0x8fe>
ffffffffc0202624:	00005617          	auipc	a2,0x5
ffffffffc0202628:	8a460613          	addi	a2,a2,-1884 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc020262c:	10f00593          	li	a1,271
ffffffffc0202630:	00005517          	auipc	a0,0x5
ffffffffc0202634:	0c050513          	addi	a0,a0,192 # ffffffffc02076f0 <etext+0xea6>
ffffffffc0202638:	e3dfd0ef          	jal	ffffffffc0200474 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc020263c:	00005697          	auipc	a3,0x5
ffffffffc0202640:	b4c68693          	addi	a3,a3,-1204 # ffffffffc0207188 <etext+0x93e>
ffffffffc0202644:	00005617          	auipc	a2,0x5
ffffffffc0202648:	88460613          	addi	a2,a2,-1916 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc020264c:	11000593          	li	a1,272
ffffffffc0202650:	00005517          	auipc	a0,0x5
ffffffffc0202654:	0a050513          	addi	a0,a0,160 # ffffffffc02076f0 <etext+0xea6>
ffffffffc0202658:	e1dfd0ef          	jal	ffffffffc0200474 <__panic>
ffffffffc020265c:	b6dff0ef          	jal	ffffffffc02021c8 <pa2page.part.0>

ffffffffc0202660 <exit_range>:
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0202660:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202662:	00c5e7b3          	or	a5,a1,a2
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0202666:	fc86                	sd	ra,120(sp)
ffffffffc0202668:	f8a2                	sd	s0,112(sp)
ffffffffc020266a:	f4a6                	sd	s1,104(sp)
ffffffffc020266c:	f0ca                	sd	s2,96(sp)
ffffffffc020266e:	ecce                	sd	s3,88(sp)
ffffffffc0202670:	e8d2                	sd	s4,80(sp)
ffffffffc0202672:	e4d6                	sd	s5,72(sp)
ffffffffc0202674:	e0da                	sd	s6,64(sp)
ffffffffc0202676:	fc5e                	sd	s7,56(sp)
ffffffffc0202678:	f862                	sd	s8,48(sp)
ffffffffc020267a:	f466                	sd	s9,40(sp)
ffffffffc020267c:	f06a                	sd	s10,32(sp)
ffffffffc020267e:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202680:	17d2                	slli	a5,a5,0x34
ffffffffc0202682:	24079163          	bnez	a5,ffffffffc02028c4 <exit_range+0x264>
    assert(USER_ACCESS(start, end));
ffffffffc0202686:	002007b7          	lui	a5,0x200
ffffffffc020268a:	28f5e863          	bltu	a1,a5,ffffffffc020291a <exit_range+0x2ba>
ffffffffc020268e:	8b32                	mv	s6,a2
ffffffffc0202690:	28c5f563          	bgeu	a1,a2,ffffffffc020291a <exit_range+0x2ba>
ffffffffc0202694:	4785                	li	a5,1
ffffffffc0202696:	07fe                	slli	a5,a5,0x1f
ffffffffc0202698:	28c7e163          	bltu	a5,a2,ffffffffc020291a <exit_range+0x2ba>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc020269c:	c0000a37          	lui	s4,0xc0000
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc02026a0:	ffe007b7          	lui	a5,0xffe00
ffffffffc02026a4:	8d2a                	mv	s10,a0
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc02026a6:	0145fa33          	and	s4,a1,s4
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc02026aa:	00f5f4b3          	and	s1,a1,a5
        d1start += PDSIZE;
ffffffffc02026ae:	40000db7          	lui	s11,0x40000
    if (PPN(pa) >= npage) {
ffffffffc02026b2:	0009c617          	auipc	a2,0x9c
ffffffffc02026b6:	8fe60613          	addi	a2,a2,-1794 # ffffffffc029dfb0 <npage>
    return KADDR(page2pa(page));
ffffffffc02026ba:	0009c817          	auipc	a6,0x9c
ffffffffc02026be:	8ee80813          	addi	a6,a6,-1810 # ffffffffc029dfa8 <va_pa_offset>
    return &pages[PPN(pa) - nbase];
ffffffffc02026c2:	0009ce97          	auipc	t4,0x9c
ffffffffc02026c6:	8f6e8e93          	addi	t4,t4,-1802 # ffffffffc029dfb8 <pages>
                d0start += PTSIZE;
ffffffffc02026ca:	00200c37          	lui	s8,0x200
ffffffffc02026ce:	a819                	j	ffffffffc02026e4 <exit_range+0x84>
        d1start += PDSIZE;
ffffffffc02026d0:	01ba09b3          	add	s3,s4,s11
    } while (d1start != 0 && d1start < end);
ffffffffc02026d4:	14098763          	beqz	s3,ffffffffc0202822 <exit_range+0x1c2>
        d1start += PDSIZE;
ffffffffc02026d8:	40000a37          	lui	s4,0x40000
        d0start = d1start;
ffffffffc02026dc:	400004b7          	lui	s1,0x40000
    } while (d1start != 0 && d1start < end);
ffffffffc02026e0:	1569f163          	bgeu	s3,s6,ffffffffc0202822 <exit_range+0x1c2>
        pde1 = pgdir[PDX1(d1start)];
ffffffffc02026e4:	01ea5913          	srli	s2,s4,0x1e
ffffffffc02026e8:	1ff97913          	andi	s2,s2,511
ffffffffc02026ec:	090e                	slli	s2,s2,0x3
ffffffffc02026ee:	996a                	add	s2,s2,s10
ffffffffc02026f0:	00093a83          	ld	s5,0(s2)
        if (pde1&PTE_V){
ffffffffc02026f4:	001af793          	andi	a5,s5,1
ffffffffc02026f8:	dfe1                	beqz	a5,ffffffffc02026d0 <exit_range+0x70>
    if (PPN(pa) >= npage) {
ffffffffc02026fa:	6214                	ld	a3,0(a2)
    return pa2page(PDE_ADDR(pde));
ffffffffc02026fc:	0a8a                	slli	s5,s5,0x2
ffffffffc02026fe:	00cada93          	srli	s5,s5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202702:	20dafa63          	bgeu	s5,a3,ffffffffc0202916 <exit_range+0x2b6>
    return &pages[PPN(pa) - nbase];
ffffffffc0202706:	fff80737          	lui	a4,0xfff80
ffffffffc020270a:	9756                	add	a4,a4,s5
    return page - pages + nbase;
ffffffffc020270c:	000807b7          	lui	a5,0x80
ffffffffc0202710:	97ba                	add	a5,a5,a4
    return page2ppn(page) << PGSHIFT;
ffffffffc0202712:	00c79b93          	slli	s7,a5,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc0202716:	071a                	slli	a4,a4,0x6
    return KADDR(page2pa(page));
ffffffffc0202718:	1ed7f263          	bgeu	a5,a3,ffffffffc02028fc <exit_range+0x29c>
ffffffffc020271c:	00083783          	ld	a5,0(a6)
            free_pd0 = 1;
ffffffffc0202720:	4c85                	li	s9,1
    return &pages[PPN(pa) - nbase];
ffffffffc0202722:	fff80e37          	lui	t3,0xfff80
    return KADDR(page2pa(page));
ffffffffc0202726:	9bbe                	add	s7,s7,a5
    return page - pages + nbase;
ffffffffc0202728:	00080337          	lui	t1,0x80
ffffffffc020272c:	6885                	lui	a7,0x1
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc020272e:	01ba09b3          	add	s3,s4,s11
ffffffffc0202732:	a801                	j	ffffffffc0202742 <exit_range+0xe2>
                    free_pd0 = 0;
ffffffffc0202734:	4c81                	li	s9,0
                d0start += PTSIZE;
ffffffffc0202736:	94e2                	add	s1,s1,s8
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc0202738:	ccd1                	beqz	s1,ffffffffc02027d4 <exit_range+0x174>
ffffffffc020273a:	0934fd63          	bgeu	s1,s3,ffffffffc02027d4 <exit_range+0x174>
ffffffffc020273e:	1164f163          	bgeu	s1,s6,ffffffffc0202840 <exit_range+0x1e0>
                pde0 = pd0[PDX0(d0start)];
ffffffffc0202742:	0154d413          	srli	s0,s1,0x15
ffffffffc0202746:	1ff47413          	andi	s0,s0,511
ffffffffc020274a:	040e                	slli	s0,s0,0x3
ffffffffc020274c:	945e                	add	s0,s0,s7
ffffffffc020274e:	601c                	ld	a5,0(s0)
                if (pde0&PTE_V) {
ffffffffc0202750:	0017f693          	andi	a3,a5,1
ffffffffc0202754:	d2e5                	beqz	a3,ffffffffc0202734 <exit_range+0xd4>
    if (PPN(pa) >= npage) {
ffffffffc0202756:	00063f03          	ld	t5,0(a2)
    return pa2page(PDE_ADDR(pde));
ffffffffc020275a:	078a                	slli	a5,a5,0x2
ffffffffc020275c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020275e:	1be7fc63          	bgeu	a5,t5,ffffffffc0202916 <exit_range+0x2b6>
    return &pages[PPN(pa) - nbase];
ffffffffc0202762:	97f2                	add	a5,a5,t3
    return page - pages + nbase;
ffffffffc0202764:	00678fb3          	add	t6,a5,t1
    return &pages[PPN(pa) - nbase];
ffffffffc0202768:	000eb503          	ld	a0,0(t4)
ffffffffc020276c:	00679593          	slli	a1,a5,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc0202770:	00cf9693          	slli	a3,t6,0xc
    return KADDR(page2pa(page));
ffffffffc0202774:	17eff863          	bgeu	t6,t5,ffffffffc02028e4 <exit_range+0x284>
ffffffffc0202778:	00083783          	ld	a5,0(a6)
ffffffffc020277c:	96be                	add	a3,a3,a5
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc020277e:	01168f33          	add	t5,a3,a7
                        if (pt[i]&PTE_V){
ffffffffc0202782:	629c                	ld	a5,0(a3)
ffffffffc0202784:	8b85                	andi	a5,a5,1
ffffffffc0202786:	fbc5                	bnez	a5,ffffffffc0202736 <exit_range+0xd6>
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc0202788:	06a1                	addi	a3,a3,8
ffffffffc020278a:	ffe69ce3          	bne	a3,t5,ffffffffc0202782 <exit_range+0x122>
    return &pages[PPN(pa) - nbase];
ffffffffc020278e:	952e                	add	a0,a0,a1
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202790:	100027f3          	csrr	a5,sstatus
ffffffffc0202794:	8b89                	andi	a5,a5,2
ffffffffc0202796:	ebc5                	bnez	a5,ffffffffc0202846 <exit_range+0x1e6>
        pmm_manager->free_pages(base, n);
ffffffffc0202798:	0009b797          	auipc	a5,0x9b
ffffffffc020279c:	7f87b783          	ld	a5,2040(a5) # ffffffffc029df90 <pmm_manager>
ffffffffc02027a0:	739c                	ld	a5,32(a5)
ffffffffc02027a2:	4585                	li	a1,1
ffffffffc02027a4:	e03a                	sd	a4,0(sp)
ffffffffc02027a6:	9782                	jalr	a5
    if (flag) {
ffffffffc02027a8:	6702                	ld	a4,0(sp)
ffffffffc02027aa:	fff80e37          	lui	t3,0xfff80
ffffffffc02027ae:	00080337          	lui	t1,0x80
ffffffffc02027b2:	6885                	lui	a7,0x1
ffffffffc02027b4:	0009b617          	auipc	a2,0x9b
ffffffffc02027b8:	7fc60613          	addi	a2,a2,2044 # ffffffffc029dfb0 <npage>
ffffffffc02027bc:	0009b817          	auipc	a6,0x9b
ffffffffc02027c0:	7ec80813          	addi	a6,a6,2028 # ffffffffc029dfa8 <va_pa_offset>
ffffffffc02027c4:	0009be97          	auipc	t4,0x9b
ffffffffc02027c8:	7f4e8e93          	addi	t4,t4,2036 # ffffffffc029dfb8 <pages>
                        pd0[PDX0(d0start)] = 0;
ffffffffc02027cc:	00043023          	sd	zero,0(s0)
                d0start += PTSIZE;
ffffffffc02027d0:	94e2                	add	s1,s1,s8
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc02027d2:	f4a5                	bnez	s1,ffffffffc020273a <exit_range+0xda>
            if (free_pd0) {
ffffffffc02027d4:	ee0c8ee3          	beqz	s9,ffffffffc02026d0 <exit_range+0x70>
    if (PPN(pa) >= npage) {
ffffffffc02027d8:	621c                	ld	a5,0(a2)
ffffffffc02027da:	12fafe63          	bgeu	s5,a5,ffffffffc0202916 <exit_range+0x2b6>
    return &pages[PPN(pa) - nbase];
ffffffffc02027de:	0009b517          	auipc	a0,0x9b
ffffffffc02027e2:	7da53503          	ld	a0,2010(a0) # ffffffffc029dfb8 <pages>
ffffffffc02027e6:	953a                	add	a0,a0,a4
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02027e8:	100027f3          	csrr	a5,sstatus
ffffffffc02027ec:	8b89                	andi	a5,a5,2
ffffffffc02027ee:	efd9                	bnez	a5,ffffffffc020288c <exit_range+0x22c>
        pmm_manager->free_pages(base, n);
ffffffffc02027f0:	0009b797          	auipc	a5,0x9b
ffffffffc02027f4:	7a07b783          	ld	a5,1952(a5) # ffffffffc029df90 <pmm_manager>
ffffffffc02027f8:	739c                	ld	a5,32(a5)
ffffffffc02027fa:	4585                	li	a1,1
ffffffffc02027fc:	9782                	jalr	a5
ffffffffc02027fe:	0009be97          	auipc	t4,0x9b
ffffffffc0202802:	7bae8e93          	addi	t4,t4,1978 # ffffffffc029dfb8 <pages>
ffffffffc0202806:	0009b817          	auipc	a6,0x9b
ffffffffc020280a:	7a280813          	addi	a6,a6,1954 # ffffffffc029dfa8 <va_pa_offset>
ffffffffc020280e:	0009b617          	auipc	a2,0x9b
ffffffffc0202812:	7a260613          	addi	a2,a2,1954 # ffffffffc029dfb0 <npage>
                pgdir[PDX1(d1start)] = 0;
ffffffffc0202816:	00093023          	sd	zero,0(s2)
        d1start += PDSIZE;
ffffffffc020281a:	01ba09b3          	add	s3,s4,s11
    } while (d1start != 0 && d1start < end);
ffffffffc020281e:	ea099de3          	bnez	s3,ffffffffc02026d8 <exit_range+0x78>
}
ffffffffc0202822:	70e6                	ld	ra,120(sp)
ffffffffc0202824:	7446                	ld	s0,112(sp)
ffffffffc0202826:	74a6                	ld	s1,104(sp)
ffffffffc0202828:	7906                	ld	s2,96(sp)
ffffffffc020282a:	69e6                	ld	s3,88(sp)
ffffffffc020282c:	6a46                	ld	s4,80(sp)
ffffffffc020282e:	6aa6                	ld	s5,72(sp)
ffffffffc0202830:	6b06                	ld	s6,64(sp)
ffffffffc0202832:	7be2                	ld	s7,56(sp)
ffffffffc0202834:	7c42                	ld	s8,48(sp)
ffffffffc0202836:	7ca2                	ld	s9,40(sp)
ffffffffc0202838:	7d02                	ld	s10,32(sp)
ffffffffc020283a:	6de2                	ld	s11,24(sp)
ffffffffc020283c:	6109                	addi	sp,sp,128
ffffffffc020283e:	8082                	ret
            if (free_pd0) {
ffffffffc0202840:	e80c8ce3          	beqz	s9,ffffffffc02026d8 <exit_range+0x78>
ffffffffc0202844:	bf51                	j	ffffffffc02027d8 <exit_range+0x178>
        intr_disable();
ffffffffc0202846:	e03a                	sd	a4,0(sp)
ffffffffc0202848:	e42a                	sd	a0,8(sp)
ffffffffc020284a:	df7fd0ef          	jal	ffffffffc0200640 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020284e:	0009b797          	auipc	a5,0x9b
ffffffffc0202852:	7427b783          	ld	a5,1858(a5) # ffffffffc029df90 <pmm_manager>
ffffffffc0202856:	739c                	ld	a5,32(a5)
ffffffffc0202858:	6522                	ld	a0,8(sp)
ffffffffc020285a:	4585                	li	a1,1
ffffffffc020285c:	9782                	jalr	a5
        intr_enable();
ffffffffc020285e:	dddfd0ef          	jal	ffffffffc020063a <intr_enable>
ffffffffc0202862:	6702                	ld	a4,0(sp)
ffffffffc0202864:	0009be97          	auipc	t4,0x9b
ffffffffc0202868:	754e8e93          	addi	t4,t4,1876 # ffffffffc029dfb8 <pages>
ffffffffc020286c:	0009b817          	auipc	a6,0x9b
ffffffffc0202870:	73c80813          	addi	a6,a6,1852 # ffffffffc029dfa8 <va_pa_offset>
ffffffffc0202874:	0009b617          	auipc	a2,0x9b
ffffffffc0202878:	73c60613          	addi	a2,a2,1852 # ffffffffc029dfb0 <npage>
ffffffffc020287c:	6885                	lui	a7,0x1
ffffffffc020287e:	00080337          	lui	t1,0x80
ffffffffc0202882:	fff80e37          	lui	t3,0xfff80
                        pd0[PDX0(d0start)] = 0;
ffffffffc0202886:	00043023          	sd	zero,0(s0)
ffffffffc020288a:	b799                	j	ffffffffc02027d0 <exit_range+0x170>
        intr_disable();
ffffffffc020288c:	e02a                	sd	a0,0(sp)
ffffffffc020288e:	db3fd0ef          	jal	ffffffffc0200640 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202892:	0009b797          	auipc	a5,0x9b
ffffffffc0202896:	6fe7b783          	ld	a5,1790(a5) # ffffffffc029df90 <pmm_manager>
ffffffffc020289a:	739c                	ld	a5,32(a5)
ffffffffc020289c:	6502                	ld	a0,0(sp)
ffffffffc020289e:	4585                	li	a1,1
ffffffffc02028a0:	9782                	jalr	a5
        intr_enable();
ffffffffc02028a2:	d99fd0ef          	jal	ffffffffc020063a <intr_enable>
ffffffffc02028a6:	0009b617          	auipc	a2,0x9b
ffffffffc02028aa:	70a60613          	addi	a2,a2,1802 # ffffffffc029dfb0 <npage>
ffffffffc02028ae:	0009b817          	auipc	a6,0x9b
ffffffffc02028b2:	6fa80813          	addi	a6,a6,1786 # ffffffffc029dfa8 <va_pa_offset>
ffffffffc02028b6:	0009be97          	auipc	t4,0x9b
ffffffffc02028ba:	702e8e93          	addi	t4,t4,1794 # ffffffffc029dfb8 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc02028be:	00093023          	sd	zero,0(s2)
ffffffffc02028c2:	bfa1                	j	ffffffffc020281a <exit_range+0x1ba>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02028c4:	00005697          	auipc	a3,0x5
ffffffffc02028c8:	88468693          	addi	a3,a3,-1916 # ffffffffc0207148 <etext+0x8fe>
ffffffffc02028cc:	00004617          	auipc	a2,0x4
ffffffffc02028d0:	5fc60613          	addi	a2,a2,1532 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc02028d4:	12000593          	li	a1,288
ffffffffc02028d8:	00005517          	auipc	a0,0x5
ffffffffc02028dc:	e1850513          	addi	a0,a0,-488 # ffffffffc02076f0 <etext+0xea6>
ffffffffc02028e0:	b95fd0ef          	jal	ffffffffc0200474 <__panic>
    return KADDR(page2pa(page));
ffffffffc02028e4:	00005617          	auipc	a2,0x5
ffffffffc02028e8:	92c60613          	addi	a2,a2,-1748 # ffffffffc0207210 <etext+0x9c6>
ffffffffc02028ec:	06a00593          	li	a1,106
ffffffffc02028f0:	00005517          	auipc	a0,0x5
ffffffffc02028f4:	8d050513          	addi	a0,a0,-1840 # ffffffffc02071c0 <etext+0x976>
ffffffffc02028f8:	b7dfd0ef          	jal	ffffffffc0200474 <__panic>
ffffffffc02028fc:	86de                	mv	a3,s7
ffffffffc02028fe:	00005617          	auipc	a2,0x5
ffffffffc0202902:	91260613          	addi	a2,a2,-1774 # ffffffffc0207210 <etext+0x9c6>
ffffffffc0202906:	06a00593          	li	a1,106
ffffffffc020290a:	00005517          	auipc	a0,0x5
ffffffffc020290e:	8b650513          	addi	a0,a0,-1866 # ffffffffc02071c0 <etext+0x976>
ffffffffc0202912:	b63fd0ef          	jal	ffffffffc0200474 <__panic>
ffffffffc0202916:	8b3ff0ef          	jal	ffffffffc02021c8 <pa2page.part.0>
    assert(USER_ACCESS(start, end));
ffffffffc020291a:	00005697          	auipc	a3,0x5
ffffffffc020291e:	86e68693          	addi	a3,a3,-1938 # ffffffffc0207188 <etext+0x93e>
ffffffffc0202922:	00004617          	auipc	a2,0x4
ffffffffc0202926:	5a660613          	addi	a2,a2,1446 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc020292a:	12100593          	li	a1,289
ffffffffc020292e:	00005517          	auipc	a0,0x5
ffffffffc0202932:	dc250513          	addi	a0,a0,-574 # ffffffffc02076f0 <etext+0xea6>
ffffffffc0202936:	b3ffd0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc020293a <page_remove>:
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc020293a:	7179                	addi	sp,sp,-48
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020293c:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc020293e:	ec26                	sd	s1,24(sp)
ffffffffc0202940:	f406                	sd	ra,40(sp)
ffffffffc0202942:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202944:	9c7ff0ef          	jal	ffffffffc020230a <get_pte>
    if (ptep != NULL) {
ffffffffc0202948:	c901                	beqz	a0,ffffffffc0202958 <page_remove+0x1e>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc020294a:	611c                	ld	a5,0(a0)
ffffffffc020294c:	f022                	sd	s0,32(sp)
ffffffffc020294e:	842a                	mv	s0,a0
ffffffffc0202950:	0017f713          	andi	a4,a5,1
ffffffffc0202954:	e711                	bnez	a4,ffffffffc0202960 <page_remove+0x26>
ffffffffc0202956:	7402                	ld	s0,32(sp)
}
ffffffffc0202958:	70a2                	ld	ra,40(sp)
ffffffffc020295a:	64e2                	ld	s1,24(sp)
ffffffffc020295c:	6145                	addi	sp,sp,48
ffffffffc020295e:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202960:	078a                	slli	a5,a5,0x2
ffffffffc0202962:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202964:	0009b717          	auipc	a4,0x9b
ffffffffc0202968:	64c73703          	ld	a4,1612(a4) # ffffffffc029dfb0 <npage>
ffffffffc020296c:	06e7f363          	bgeu	a5,a4,ffffffffc02029d2 <page_remove+0x98>
    return &pages[PPN(pa) - nbase];
ffffffffc0202970:	fff80737          	lui	a4,0xfff80
ffffffffc0202974:	97ba                	add	a5,a5,a4
ffffffffc0202976:	079a                	slli	a5,a5,0x6
ffffffffc0202978:	0009b517          	auipc	a0,0x9b
ffffffffc020297c:	64053503          	ld	a0,1600(a0) # ffffffffc029dfb8 <pages>
ffffffffc0202980:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0202982:	411c                	lw	a5,0(a0)
ffffffffc0202984:	fff7871b          	addiw	a4,a5,-1
ffffffffc0202988:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc020298a:	cb11                	beqz	a4,ffffffffc020299e <page_remove+0x64>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc020298c:	00043023          	sd	zero,0(s0)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202990:	12048073          	sfence.vma	s1
ffffffffc0202994:	7402                	ld	s0,32(sp)
}
ffffffffc0202996:	70a2                	ld	ra,40(sp)
ffffffffc0202998:	64e2                	ld	s1,24(sp)
ffffffffc020299a:	6145                	addi	sp,sp,48
ffffffffc020299c:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020299e:	100027f3          	csrr	a5,sstatus
ffffffffc02029a2:	8b89                	andi	a5,a5,2
ffffffffc02029a4:	eb89                	bnez	a5,ffffffffc02029b6 <page_remove+0x7c>
        pmm_manager->free_pages(base, n);
ffffffffc02029a6:	0009b797          	auipc	a5,0x9b
ffffffffc02029aa:	5ea7b783          	ld	a5,1514(a5) # ffffffffc029df90 <pmm_manager>
ffffffffc02029ae:	739c                	ld	a5,32(a5)
ffffffffc02029b0:	4585                	li	a1,1
ffffffffc02029b2:	9782                	jalr	a5
    if (flag) {
ffffffffc02029b4:	bfe1                	j	ffffffffc020298c <page_remove+0x52>
        intr_disable();
ffffffffc02029b6:	e42a                	sd	a0,8(sp)
ffffffffc02029b8:	c89fd0ef          	jal	ffffffffc0200640 <intr_disable>
ffffffffc02029bc:	0009b797          	auipc	a5,0x9b
ffffffffc02029c0:	5d47b783          	ld	a5,1492(a5) # ffffffffc029df90 <pmm_manager>
ffffffffc02029c4:	739c                	ld	a5,32(a5)
ffffffffc02029c6:	6522                	ld	a0,8(sp)
ffffffffc02029c8:	4585                	li	a1,1
ffffffffc02029ca:	9782                	jalr	a5
        intr_enable();
ffffffffc02029cc:	c6ffd0ef          	jal	ffffffffc020063a <intr_enable>
ffffffffc02029d0:	bf75                	j	ffffffffc020298c <page_remove+0x52>
ffffffffc02029d2:	ff6ff0ef          	jal	ffffffffc02021c8 <pa2page.part.0>

ffffffffc02029d6 <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc02029d6:	7139                	addi	sp,sp,-64
ffffffffc02029d8:	e852                	sd	s4,16(sp)
ffffffffc02029da:	8a32                	mv	s4,a2
ffffffffc02029dc:	f822                	sd	s0,48(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02029de:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc02029e0:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02029e2:	85d2                	mv	a1,s4
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc02029e4:	f426                	sd	s1,40(sp)
ffffffffc02029e6:	fc06                	sd	ra,56(sp)
ffffffffc02029e8:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02029ea:	921ff0ef          	jal	ffffffffc020230a <get_pte>
    if (ptep == NULL) {
ffffffffc02029ee:	c971                	beqz	a0,ffffffffc0202ac2 <page_insert+0xec>
    page->ref += 1;
ffffffffc02029f0:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc02029f2:	611c                	ld	a5,0(a0)
ffffffffc02029f4:	ec4e                	sd	s3,24(sp)
ffffffffc02029f6:	0016871b          	addiw	a4,a3,1
ffffffffc02029fa:	c018                	sw	a4,0(s0)
ffffffffc02029fc:	0017f713          	andi	a4,a5,1
ffffffffc0202a00:	89aa                	mv	s3,a0
ffffffffc0202a02:	eb15                	bnez	a4,ffffffffc0202a36 <page_insert+0x60>
    return &pages[PPN(pa) - nbase];
ffffffffc0202a04:	0009b717          	auipc	a4,0x9b
ffffffffc0202a08:	5b473703          	ld	a4,1460(a4) # ffffffffc029dfb8 <pages>
    return page - pages + nbase;
ffffffffc0202a0c:	8c19                	sub	s0,s0,a4
ffffffffc0202a0e:	000807b7          	lui	a5,0x80
ffffffffc0202a12:	8419                	srai	s0,s0,0x6
ffffffffc0202a14:	943e                	add	s0,s0,a5
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202a16:	042a                	slli	s0,s0,0xa
ffffffffc0202a18:	8cc1                	or	s1,s1,s0
ffffffffc0202a1a:	0014e493          	ori	s1,s1,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0202a1e:	0099b023          	sd	s1,0(s3) # 80000 <_binary_obj___user_exit_out_size+0x76460>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202a22:	120a0073          	sfence.vma	s4
    return 0;
ffffffffc0202a26:	69e2                	ld	s3,24(sp)
ffffffffc0202a28:	4501                	li	a0,0
}
ffffffffc0202a2a:	70e2                	ld	ra,56(sp)
ffffffffc0202a2c:	7442                	ld	s0,48(sp)
ffffffffc0202a2e:	74a2                	ld	s1,40(sp)
ffffffffc0202a30:	6a42                	ld	s4,16(sp)
ffffffffc0202a32:	6121                	addi	sp,sp,64
ffffffffc0202a34:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202a36:	078a                	slli	a5,a5,0x2
ffffffffc0202a38:	f04a                	sd	s2,32(sp)
ffffffffc0202a3a:	e456                	sd	s5,8(sp)
ffffffffc0202a3c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202a3e:	0009b717          	auipc	a4,0x9b
ffffffffc0202a42:	57273703          	ld	a4,1394(a4) # ffffffffc029dfb0 <npage>
ffffffffc0202a46:	08e7f063          	bgeu	a5,a4,ffffffffc0202ac6 <page_insert+0xf0>
    return &pages[PPN(pa) - nbase];
ffffffffc0202a4a:	0009ba97          	auipc	s5,0x9b
ffffffffc0202a4e:	56ea8a93          	addi	s5,s5,1390 # ffffffffc029dfb8 <pages>
ffffffffc0202a52:	000ab703          	ld	a4,0(s5)
ffffffffc0202a56:	fff80637          	lui	a2,0xfff80
ffffffffc0202a5a:	00c78933          	add	s2,a5,a2
ffffffffc0202a5e:	091a                	slli	s2,s2,0x6
ffffffffc0202a60:	993a                	add	s2,s2,a4
        if (p == page) {
ffffffffc0202a62:	01240e63          	beq	s0,s2,ffffffffc0202a7e <page_insert+0xa8>
    page->ref -= 1;
ffffffffc0202a66:	00092783          	lw	a5,0(s2)
ffffffffc0202a6a:	fff7869b          	addiw	a3,a5,-1 # 7ffff <_binary_obj___user_exit_out_size+0x7645f>
ffffffffc0202a6e:	00d92023          	sw	a3,0(s2)
        if (page_ref(page) ==
ffffffffc0202a72:	ca91                	beqz	a3,ffffffffc0202a86 <page_insert+0xb0>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202a74:	120a0073          	sfence.vma	s4
ffffffffc0202a78:	7902                	ld	s2,32(sp)
ffffffffc0202a7a:	6aa2                	ld	s5,8(sp)
}
ffffffffc0202a7c:	bf41                	j	ffffffffc0202a0c <page_insert+0x36>
    return page->ref;
ffffffffc0202a7e:	7902                	ld	s2,32(sp)
ffffffffc0202a80:	6aa2                	ld	s5,8(sp)
    page->ref -= 1;
ffffffffc0202a82:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0202a84:	b761                	j	ffffffffc0202a0c <page_insert+0x36>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202a86:	100027f3          	csrr	a5,sstatus
ffffffffc0202a8a:	8b89                	andi	a5,a5,2
ffffffffc0202a8c:	ef81                	bnez	a5,ffffffffc0202aa4 <page_insert+0xce>
        pmm_manager->free_pages(base, n);
ffffffffc0202a8e:	0009b797          	auipc	a5,0x9b
ffffffffc0202a92:	5027b783          	ld	a5,1282(a5) # ffffffffc029df90 <pmm_manager>
ffffffffc0202a96:	739c                	ld	a5,32(a5)
ffffffffc0202a98:	4585                	li	a1,1
ffffffffc0202a9a:	854a                	mv	a0,s2
ffffffffc0202a9c:	9782                	jalr	a5
    return page - pages + nbase;
ffffffffc0202a9e:	000ab703          	ld	a4,0(s5)
ffffffffc0202aa2:	bfc9                	j	ffffffffc0202a74 <page_insert+0x9e>
        intr_disable();
ffffffffc0202aa4:	b9dfd0ef          	jal	ffffffffc0200640 <intr_disable>
ffffffffc0202aa8:	0009b797          	auipc	a5,0x9b
ffffffffc0202aac:	4e87b783          	ld	a5,1256(a5) # ffffffffc029df90 <pmm_manager>
ffffffffc0202ab0:	739c                	ld	a5,32(a5)
ffffffffc0202ab2:	4585                	li	a1,1
ffffffffc0202ab4:	854a                	mv	a0,s2
ffffffffc0202ab6:	9782                	jalr	a5
        intr_enable();
ffffffffc0202ab8:	b83fd0ef          	jal	ffffffffc020063a <intr_enable>
ffffffffc0202abc:	000ab703          	ld	a4,0(s5)
ffffffffc0202ac0:	bf55                	j	ffffffffc0202a74 <page_insert+0x9e>
        return -E_NO_MEM;
ffffffffc0202ac2:	5571                	li	a0,-4
ffffffffc0202ac4:	b79d                	j	ffffffffc0202a2a <page_insert+0x54>
ffffffffc0202ac6:	f02ff0ef          	jal	ffffffffc02021c8 <pa2page.part.0>

ffffffffc0202aca <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0202aca:	00006797          	auipc	a5,0x6
ffffffffc0202ace:	12e78793          	addi	a5,a5,302 # ffffffffc0208bf8 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202ad2:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0202ad4:	711d                	addi	sp,sp,-96
ffffffffc0202ad6:	ec86                	sd	ra,88(sp)
ffffffffc0202ad8:	e4a6                	sd	s1,72(sp)
ffffffffc0202ada:	fc4e                	sd	s3,56(sp)
ffffffffc0202adc:	f05a                	sd	s6,32(sp)
ffffffffc0202ade:	ec5e                	sd	s7,24(sp)
ffffffffc0202ae0:	e8a2                	sd	s0,80(sp)
ffffffffc0202ae2:	e0ca                	sd	s2,64(sp)
ffffffffc0202ae4:	f852                	sd	s4,48(sp)
ffffffffc0202ae6:	f456                	sd	s5,40(sp)
ffffffffc0202ae8:	e862                	sd	s8,16(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0202aea:	0009bb97          	auipc	s7,0x9b
ffffffffc0202aee:	4a6b8b93          	addi	s7,s7,1190 # ffffffffc029df90 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202af2:	00005517          	auipc	a0,0x5
ffffffffc0202af6:	c0e50513          	addi	a0,a0,-1010 # ffffffffc0207700 <etext+0xeb6>
    pmm_manager = &default_pmm_manager;
ffffffffc0202afa:	00fbb023          	sd	a5,0(s7)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202afe:	e82fd0ef          	jal	ffffffffc0200180 <cprintf>
    pmm_manager->init();
ffffffffc0202b02:	000bb783          	ld	a5,0(s7)
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202b06:	0009b997          	auipc	s3,0x9b
ffffffffc0202b0a:	4a298993          	addi	s3,s3,1186 # ffffffffc029dfa8 <va_pa_offset>
    npage = maxpa / PGSIZE;
ffffffffc0202b0e:	0009b497          	auipc	s1,0x9b
ffffffffc0202b12:	4a248493          	addi	s1,s1,1186 # ffffffffc029dfb0 <npage>
    pmm_manager->init();
ffffffffc0202b16:	679c                	ld	a5,8(a5)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202b18:	0009bb17          	auipc	s6,0x9b
ffffffffc0202b1c:	4a0b0b13          	addi	s6,s6,1184 # ffffffffc029dfb8 <pages>
    pmm_manager->init();
ffffffffc0202b20:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202b22:	57f5                	li	a5,-3
ffffffffc0202b24:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0202b26:	00005517          	auipc	a0,0x5
ffffffffc0202b2a:	bf250513          	addi	a0,a0,-1038 # ffffffffc0207718 <etext+0xece>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202b2e:	00f9b023          	sd	a5,0(s3)
    cprintf("physcial memory map:\n");
ffffffffc0202b32:	e4efd0ef          	jal	ffffffffc0200180 <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0202b36:	46c5                	li	a3,17
ffffffffc0202b38:	06ee                	slli	a3,a3,0x1b
ffffffffc0202b3a:	40100613          	li	a2,1025
ffffffffc0202b3e:	16fd                	addi	a3,a3,-1
ffffffffc0202b40:	0656                	slli	a2,a2,0x15
ffffffffc0202b42:	07e005b7          	lui	a1,0x7e00
ffffffffc0202b46:	00005517          	auipc	a0,0x5
ffffffffc0202b4a:	bea50513          	addi	a0,a0,-1046 # ffffffffc0207730 <etext+0xee6>
ffffffffc0202b4e:	e32fd0ef          	jal	ffffffffc0200180 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202b52:	777d                	lui	a4,0xfffff
ffffffffc0202b54:	0009c797          	auipc	a5,0x9c
ffffffffc0202b58:	4b378793          	addi	a5,a5,1203 # ffffffffc029f007 <end+0xfff>
ffffffffc0202b5c:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0202b5e:	00088737          	lui	a4,0x88
ffffffffc0202b62:	e098                	sd	a4,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202b64:	00fb3023          	sd	a5,0(s6)
ffffffffc0202b68:	4705                	li	a4,1
ffffffffc0202b6a:	07a1                	addi	a5,a5,8
ffffffffc0202b6c:	40e7b02f          	amoor.d	zero,a4,(a5)
ffffffffc0202b70:	4505                	li	a0,1
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0202b72:	fff805b7          	lui	a1,0xfff80
        SetPageReserved(pages + i);
ffffffffc0202b76:	000b3783          	ld	a5,0(s6)
ffffffffc0202b7a:	00671693          	slli	a3,a4,0x6
ffffffffc0202b7e:	97b6                	add	a5,a5,a3
ffffffffc0202b80:	07a1                	addi	a5,a5,8
ffffffffc0202b82:	40a7b02f          	amoor.d	zero,a0,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0202b86:	6090                	ld	a2,0(s1)
ffffffffc0202b88:	0705                	addi	a4,a4,1 # 88001 <_binary_obj___user_exit_out_size+0x7e461>
ffffffffc0202b8a:	00b607b3          	add	a5,a2,a1
ffffffffc0202b8e:	fef764e3          	bltu	a4,a5,ffffffffc0202b76 <pmm_init+0xac>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202b92:	000b3503          	ld	a0,0(s6)
ffffffffc0202b96:	079a                	slli	a5,a5,0x6
ffffffffc0202b98:	c0200737          	lui	a4,0xc0200
ffffffffc0202b9c:	00f506b3          	add	a3,a0,a5
ffffffffc0202ba0:	60e6e463          	bltu	a3,a4,ffffffffc02031a8 <pmm_init+0x6de>
ffffffffc0202ba4:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc0202ba8:	4745                	li	a4,17
ffffffffc0202baa:	076e                	slli	a4,a4,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202bac:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc0202bae:	4ae6e363          	bltu	a3,a4,ffffffffc0203054 <pmm_init+0x58a>
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0202bb2:	00005517          	auipc	a0,0x5
ffffffffc0202bb6:	ba650513          	addi	a0,a0,-1114 # ffffffffc0207758 <etext+0xf0e>
ffffffffc0202bba:	dc6fd0ef          	jal	ffffffffc0200180 <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0202bbe:	000bb783          	ld	a5,0(s7)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0202bc2:	0009b917          	auipc	s2,0x9b
ffffffffc0202bc6:	3de90913          	addi	s2,s2,990 # ffffffffc029dfa0 <boot_pgdir>
    pmm_manager->check();
ffffffffc0202bca:	7b9c                	ld	a5,48(a5)
ffffffffc0202bcc:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0202bce:	00005517          	auipc	a0,0x5
ffffffffc0202bd2:	ba250513          	addi	a0,a0,-1118 # ffffffffc0207770 <etext+0xf26>
ffffffffc0202bd6:	daafd0ef          	jal	ffffffffc0200180 <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0202bda:	00008697          	auipc	a3,0x8
ffffffffc0202bde:	42668693          	addi	a3,a3,1062 # ffffffffc020b000 <boot_page_table_sv39>
ffffffffc0202be2:	00d93023          	sd	a3,0(s2)
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0202be6:	c02007b7          	lui	a5,0xc0200
ffffffffc0202bea:	5cf6eb63          	bltu	a3,a5,ffffffffc02031c0 <pmm_init+0x6f6>
ffffffffc0202bee:	0009b783          	ld	a5,0(s3)
ffffffffc0202bf2:	8e9d                	sub	a3,a3,a5
ffffffffc0202bf4:	0009b797          	auipc	a5,0x9b
ffffffffc0202bf8:	3ad7b223          	sd	a3,932(a5) # ffffffffc029df98 <boot_cr3>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202bfc:	100027f3          	csrr	a5,sstatus
ffffffffc0202c00:	8b89                	andi	a5,a5,2
ffffffffc0202c02:	48079163          	bnez	a5,ffffffffc0203084 <pmm_init+0x5ba>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202c06:	000bb783          	ld	a5,0(s7)
ffffffffc0202c0a:	779c                	ld	a5,40(a5)
ffffffffc0202c0c:	9782                	jalr	a5
ffffffffc0202c0e:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202c10:	6098                	ld	a4,0(s1)
ffffffffc0202c12:	c80007b7          	lui	a5,0xc8000
ffffffffc0202c16:	83b1                	srli	a5,a5,0xc
ffffffffc0202c18:	5ee7e063          	bltu	a5,a4,ffffffffc02031f8 <pmm_init+0x72e>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0202c1c:	00093503          	ld	a0,0(s2)
ffffffffc0202c20:	5a050c63          	beqz	a0,ffffffffc02031d8 <pmm_init+0x70e>
ffffffffc0202c24:	03451793          	slli	a5,a0,0x34
ffffffffc0202c28:	5a079863          	bnez	a5,ffffffffc02031d8 <pmm_init+0x70e>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0202c2c:	4601                	li	a2,0
ffffffffc0202c2e:	4581                	li	a1,0
ffffffffc0202c30:	8b3ff0ef          	jal	ffffffffc02024e2 <get_page>
ffffffffc0202c34:	62051463          	bnez	a0,ffffffffc020325c <pmm_init+0x792>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0202c38:	4505                	li	a0,1
ffffffffc0202c3a:	dc6ff0ef          	jal	ffffffffc0202200 <alloc_pages>
ffffffffc0202c3e:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0202c40:	00093503          	ld	a0,0(s2)
ffffffffc0202c44:	4681                	li	a3,0
ffffffffc0202c46:	4601                	li	a2,0
ffffffffc0202c48:	85d2                	mv	a1,s4
ffffffffc0202c4a:	d8dff0ef          	jal	ffffffffc02029d6 <page_insert>
ffffffffc0202c4e:	5e051763          	bnez	a0,ffffffffc020323c <pmm_init+0x772>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0202c52:	00093503          	ld	a0,0(s2)
ffffffffc0202c56:	4601                	li	a2,0
ffffffffc0202c58:	4581                	li	a1,0
ffffffffc0202c5a:	eb0ff0ef          	jal	ffffffffc020230a <get_pte>
ffffffffc0202c5e:	5a050f63          	beqz	a0,ffffffffc020321c <pmm_init+0x752>
    assert(pte2page(*ptep) == p1);
ffffffffc0202c62:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202c64:	0017f713          	andi	a4,a5,1
ffffffffc0202c68:	5a070863          	beqz	a4,ffffffffc0203218 <pmm_init+0x74e>
    if (PPN(pa) >= npage) {
ffffffffc0202c6c:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202c6e:	078a                	slli	a5,a5,0x2
ffffffffc0202c70:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202c72:	52e7f963          	bgeu	a5,a4,ffffffffc02031a4 <pmm_init+0x6da>
    return &pages[PPN(pa) - nbase];
ffffffffc0202c76:	000b3683          	ld	a3,0(s6)
ffffffffc0202c7a:	fff80637          	lui	a2,0xfff80
ffffffffc0202c7e:	97b2                	add	a5,a5,a2
ffffffffc0202c80:	079a                	slli	a5,a5,0x6
ffffffffc0202c82:	97b6                	add	a5,a5,a3
ffffffffc0202c84:	10fa15e3          	bne	s4,a5,ffffffffc020358e <pmm_init+0xac4>
    assert(page_ref(p1) == 1);
ffffffffc0202c88:	000a2683          	lw	a3,0(s4) # 40000000 <_binary_obj___user_exit_out_size+0x3fff6460>
ffffffffc0202c8c:	4785                	li	a5,1
ffffffffc0202c8e:	12f69ce3          	bne	a3,a5,ffffffffc02035c6 <pmm_init+0xafc>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0202c92:	00093503          	ld	a0,0(s2)
ffffffffc0202c96:	77fd                	lui	a5,0xfffff
ffffffffc0202c98:	6114                	ld	a3,0(a0)
ffffffffc0202c9a:	068a                	slli	a3,a3,0x2
ffffffffc0202c9c:	8efd                	and	a3,a3,a5
ffffffffc0202c9e:	00c6d613          	srli	a2,a3,0xc
ffffffffc0202ca2:	10e676e3          	bgeu	a2,a4,ffffffffc02035ae <pmm_init+0xae4>
ffffffffc0202ca6:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202caa:	96e2                	add	a3,a3,s8
ffffffffc0202cac:	0006ba83          	ld	s5,0(a3)
ffffffffc0202cb0:	0a8a                	slli	s5,s5,0x2
ffffffffc0202cb2:	00fafab3          	and	s5,s5,a5
ffffffffc0202cb6:	00cad793          	srli	a5,s5,0xc
ffffffffc0202cba:	62e7f163          	bgeu	a5,a4,ffffffffc02032dc <pmm_init+0x812>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202cbe:	4601                	li	a2,0
ffffffffc0202cc0:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202cc2:	9c56                	add	s8,s8,s5
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202cc4:	e46ff0ef          	jal	ffffffffc020230a <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202cc8:	0c21                	addi	s8,s8,8 # 200008 <_binary_obj___user_exit_out_size+0x1f6468>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202cca:	5f851963          	bne	a0,s8,ffffffffc02032bc <pmm_init+0x7f2>

    p2 = alloc_page();
ffffffffc0202cce:	4505                	li	a0,1
ffffffffc0202cd0:	d30ff0ef          	jal	ffffffffc0202200 <alloc_pages>
ffffffffc0202cd4:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202cd6:	00093503          	ld	a0,0(s2)
ffffffffc0202cda:	46d1                	li	a3,20
ffffffffc0202cdc:	6605                	lui	a2,0x1
ffffffffc0202cde:	85d6                	mv	a1,s5
ffffffffc0202ce0:	cf7ff0ef          	jal	ffffffffc02029d6 <page_insert>
ffffffffc0202ce4:	58051c63          	bnez	a0,ffffffffc020327c <pmm_init+0x7b2>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202ce8:	00093503          	ld	a0,0(s2)
ffffffffc0202cec:	4601                	li	a2,0
ffffffffc0202cee:	6585                	lui	a1,0x1
ffffffffc0202cf0:	e1aff0ef          	jal	ffffffffc020230a <get_pte>
ffffffffc0202cf4:	0e0509e3          	beqz	a0,ffffffffc02035e6 <pmm_init+0xb1c>
    assert(*ptep & PTE_U);
ffffffffc0202cf8:	611c                	ld	a5,0(a0)
ffffffffc0202cfa:	0107f713          	andi	a4,a5,16
ffffffffc0202cfe:	6e070c63          	beqz	a4,ffffffffc02033f6 <pmm_init+0x92c>
    assert(*ptep & PTE_W);
ffffffffc0202d02:	8b91                	andi	a5,a5,4
ffffffffc0202d04:	6a078963          	beqz	a5,ffffffffc02033b6 <pmm_init+0x8ec>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0202d08:	00093503          	ld	a0,0(s2)
ffffffffc0202d0c:	611c                	ld	a5,0(a0)
ffffffffc0202d0e:	8bc1                	andi	a5,a5,16
ffffffffc0202d10:	68078363          	beqz	a5,ffffffffc0203396 <pmm_init+0x8cc>
    assert(page_ref(p2) == 1);
ffffffffc0202d14:	000aa703          	lw	a4,0(s5)
ffffffffc0202d18:	4785                	li	a5,1
ffffffffc0202d1a:	58f71163          	bne	a4,a5,ffffffffc020329c <pmm_init+0x7d2>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0202d1e:	4681                	li	a3,0
ffffffffc0202d20:	6605                	lui	a2,0x1
ffffffffc0202d22:	85d2                	mv	a1,s4
ffffffffc0202d24:	cb3ff0ef          	jal	ffffffffc02029d6 <page_insert>
ffffffffc0202d28:	62051763          	bnez	a0,ffffffffc0203356 <pmm_init+0x88c>
    assert(page_ref(p1) == 2);
ffffffffc0202d2c:	000a2703          	lw	a4,0(s4)
ffffffffc0202d30:	4789                	li	a5,2
ffffffffc0202d32:	60f71263          	bne	a4,a5,ffffffffc0203336 <pmm_init+0x86c>
    assert(page_ref(p2) == 0);
ffffffffc0202d36:	000aa783          	lw	a5,0(s5)
ffffffffc0202d3a:	5c079e63          	bnez	a5,ffffffffc0203316 <pmm_init+0x84c>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202d3e:	00093503          	ld	a0,0(s2)
ffffffffc0202d42:	4601                	li	a2,0
ffffffffc0202d44:	6585                	lui	a1,0x1
ffffffffc0202d46:	dc4ff0ef          	jal	ffffffffc020230a <get_pte>
ffffffffc0202d4a:	5a050663          	beqz	a0,ffffffffc02032f6 <pmm_init+0x82c>
    assert(pte2page(*ptep) == p1);
ffffffffc0202d4e:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202d50:	00177793          	andi	a5,a4,1
ffffffffc0202d54:	4c078263          	beqz	a5,ffffffffc0203218 <pmm_init+0x74e>
    if (PPN(pa) >= npage) {
ffffffffc0202d58:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202d5a:	00271793          	slli	a5,a4,0x2
ffffffffc0202d5e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202d60:	44d7f263          	bgeu	a5,a3,ffffffffc02031a4 <pmm_init+0x6da>
    return &pages[PPN(pa) - nbase];
ffffffffc0202d64:	000b3683          	ld	a3,0(s6)
ffffffffc0202d68:	fff80637          	lui	a2,0xfff80
ffffffffc0202d6c:	97b2                	add	a5,a5,a2
ffffffffc0202d6e:	079a                	slli	a5,a5,0x6
ffffffffc0202d70:	97b6                	add	a5,a5,a3
ffffffffc0202d72:	6efa1263          	bne	s4,a5,ffffffffc0203456 <pmm_init+0x98c>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202d76:	8b41                	andi	a4,a4,16
ffffffffc0202d78:	6a071f63          	bnez	a4,ffffffffc0203436 <pmm_init+0x96c>

    page_remove(boot_pgdir, 0x0);
ffffffffc0202d7c:	00093503          	ld	a0,0(s2)
ffffffffc0202d80:	4581                	li	a1,0
ffffffffc0202d82:	bb9ff0ef          	jal	ffffffffc020293a <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0202d86:	000a2703          	lw	a4,0(s4)
ffffffffc0202d8a:	4785                	li	a5,1
ffffffffc0202d8c:	68f71563          	bne	a4,a5,ffffffffc0203416 <pmm_init+0x94c>
    assert(page_ref(p2) == 0);
ffffffffc0202d90:	000aa783          	lw	a5,0(s5)
ffffffffc0202d94:	74079d63          	bnez	a5,ffffffffc02034ee <pmm_init+0xa24>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc0202d98:	00093503          	ld	a0,0(s2)
ffffffffc0202d9c:	6585                	lui	a1,0x1
ffffffffc0202d9e:	b9dff0ef          	jal	ffffffffc020293a <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0202da2:	000a2783          	lw	a5,0(s4)
ffffffffc0202da6:	72079463          	bnez	a5,ffffffffc02034ce <pmm_init+0xa04>
    assert(page_ref(p2) == 0);
ffffffffc0202daa:	000aa783          	lw	a5,0(s5)
ffffffffc0202dae:	70079063          	bnez	a5,ffffffffc02034ae <pmm_init+0x9e4>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0202db2:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0202db6:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202db8:	000a3783          	ld	a5,0(s4)
ffffffffc0202dbc:	078a                	slli	a5,a5,0x2
ffffffffc0202dbe:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202dc0:	3ee7f263          	bgeu	a5,a4,ffffffffc02031a4 <pmm_init+0x6da>
    return &pages[PPN(pa) - nbase];
ffffffffc0202dc4:	fff806b7          	lui	a3,0xfff80
ffffffffc0202dc8:	000b3503          	ld	a0,0(s6)
ffffffffc0202dcc:	97b6                	add	a5,a5,a3
ffffffffc0202dce:	079a                	slli	a5,a5,0x6
    return page->ref;
ffffffffc0202dd0:	00f506b3          	add	a3,a0,a5
ffffffffc0202dd4:	4290                	lw	a2,0(a3)
ffffffffc0202dd6:	4685                	li	a3,1
ffffffffc0202dd8:	6ad61b63          	bne	a2,a3,ffffffffc020348e <pmm_init+0x9c4>
    return page - pages + nbase;
ffffffffc0202ddc:	8799                	srai	a5,a5,0x6
ffffffffc0202dde:	00080637          	lui	a2,0x80
ffffffffc0202de2:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0202de4:	00c79693          	slli	a3,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0202de8:	68e7f763          	bgeu	a5,a4,ffffffffc0203476 <pmm_init+0x9ac>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0202dec:	0009b783          	ld	a5,0(s3)
ffffffffc0202df0:	97b6                	add	a5,a5,a3
    return pa2page(PDE_ADDR(pde));
ffffffffc0202df2:	639c                	ld	a5,0(a5)
ffffffffc0202df4:	078a                	slli	a5,a5,0x2
ffffffffc0202df6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202df8:	3ae7f663          	bgeu	a5,a4,ffffffffc02031a4 <pmm_init+0x6da>
    return &pages[PPN(pa) - nbase];
ffffffffc0202dfc:	8f91                	sub	a5,a5,a2
ffffffffc0202dfe:	079a                	slli	a5,a5,0x6
ffffffffc0202e00:	953e                	add	a0,a0,a5
ffffffffc0202e02:	100027f3          	csrr	a5,sstatus
ffffffffc0202e06:	8b89                	andi	a5,a5,2
ffffffffc0202e08:	2c079863          	bnez	a5,ffffffffc02030d8 <pmm_init+0x60e>
        pmm_manager->free_pages(base, n);
ffffffffc0202e0c:	000bb783          	ld	a5,0(s7)
ffffffffc0202e10:	4585                	li	a1,1
ffffffffc0202e12:	739c                	ld	a5,32(a5)
ffffffffc0202e14:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202e16:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0202e1a:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202e1c:	078a                	slli	a5,a5,0x2
ffffffffc0202e1e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202e20:	38e7f263          	bgeu	a5,a4,ffffffffc02031a4 <pmm_init+0x6da>
    return &pages[PPN(pa) - nbase];
ffffffffc0202e24:	000b3503          	ld	a0,0(s6)
ffffffffc0202e28:	fff80737          	lui	a4,0xfff80
ffffffffc0202e2c:	97ba                	add	a5,a5,a4
ffffffffc0202e2e:	079a                	slli	a5,a5,0x6
ffffffffc0202e30:	953e                	add	a0,a0,a5
ffffffffc0202e32:	100027f3          	csrr	a5,sstatus
ffffffffc0202e36:	8b89                	andi	a5,a5,2
ffffffffc0202e38:	28079463          	bnez	a5,ffffffffc02030c0 <pmm_init+0x5f6>
ffffffffc0202e3c:	000bb783          	ld	a5,0(s7)
ffffffffc0202e40:	4585                	li	a1,1
ffffffffc0202e42:	739c                	ld	a5,32(a5)
ffffffffc0202e44:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0202e46:	00093783          	ld	a5,0(s2)
ffffffffc0202e4a:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fd60ff8>
  asm volatile("sfence.vma");
ffffffffc0202e4e:	12000073          	sfence.vma
ffffffffc0202e52:	100027f3          	csrr	a5,sstatus
ffffffffc0202e56:	8b89                	andi	a5,a5,2
ffffffffc0202e58:	24079a63          	bnez	a5,ffffffffc02030ac <pmm_init+0x5e2>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202e5c:	000bb783          	ld	a5,0(s7)
ffffffffc0202e60:	779c                	ld	a5,40(a5)
ffffffffc0202e62:	9782                	jalr	a5
ffffffffc0202e64:	8a2a                	mv	s4,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0202e66:	71441463          	bne	s0,s4,ffffffffc020356e <pmm_init+0xaa4>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0202e6a:	00005517          	auipc	a0,0x5
ffffffffc0202e6e:	bee50513          	addi	a0,a0,-1042 # ffffffffc0207a58 <etext+0x120e>
ffffffffc0202e72:	b0efd0ef          	jal	ffffffffc0200180 <cprintf>
ffffffffc0202e76:	100027f3          	csrr	a5,sstatus
ffffffffc0202e7a:	8b89                	andi	a5,a5,2
ffffffffc0202e7c:	20079e63          	bnez	a5,ffffffffc0203098 <pmm_init+0x5ce>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202e80:	000bb783          	ld	a5,0(s7)
ffffffffc0202e84:	779c                	ld	a5,40(a5)
ffffffffc0202e86:	9782                	jalr	a5
ffffffffc0202e88:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0202e8a:	6098                	ld	a4,0(s1)
ffffffffc0202e8c:	c0200437          	lui	s0,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202e90:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0202e92:	00c71793          	slli	a5,a4,0xc
ffffffffc0202e96:	6a05                	lui	s4,0x1
ffffffffc0202e98:	02f47c63          	bgeu	s0,a5,ffffffffc0202ed0 <pmm_init+0x406>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202e9c:	00c45793          	srli	a5,s0,0xc
ffffffffc0202ea0:	00093503          	ld	a0,0(s2)
ffffffffc0202ea4:	2ee7f363          	bgeu	a5,a4,ffffffffc020318a <pmm_init+0x6c0>
ffffffffc0202ea8:	0009b583          	ld	a1,0(s3)
ffffffffc0202eac:	4601                	li	a2,0
ffffffffc0202eae:	95a2                	add	a1,a1,s0
ffffffffc0202eb0:	c5aff0ef          	jal	ffffffffc020230a <get_pte>
ffffffffc0202eb4:	2a050b63          	beqz	a0,ffffffffc020316a <pmm_init+0x6a0>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202eb8:	611c                	ld	a5,0(a0)
ffffffffc0202eba:	078a                	slli	a5,a5,0x2
ffffffffc0202ebc:	0157f7b3          	and	a5,a5,s5
ffffffffc0202ec0:	28879563          	bne	a5,s0,ffffffffc020314a <pmm_init+0x680>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0202ec4:	6098                	ld	a4,0(s1)
ffffffffc0202ec6:	9452                	add	s0,s0,s4
ffffffffc0202ec8:	00c71793          	slli	a5,a4,0xc
ffffffffc0202ecc:	fcf468e3          	bltu	s0,a5,ffffffffc0202e9c <pmm_init+0x3d2>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc0202ed0:	00093783          	ld	a5,0(s2)
ffffffffc0202ed4:	639c                	ld	a5,0(a5)
ffffffffc0202ed6:	66079c63          	bnez	a5,ffffffffc020354e <pmm_init+0xa84>

    struct Page *p;
    p = alloc_page();
ffffffffc0202eda:	4505                	li	a0,1
ffffffffc0202edc:	b24ff0ef          	jal	ffffffffc0202200 <alloc_pages>
ffffffffc0202ee0:	842a                	mv	s0,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202ee2:	00093503          	ld	a0,0(s2)
ffffffffc0202ee6:	4699                	li	a3,6
ffffffffc0202ee8:	10000613          	li	a2,256
ffffffffc0202eec:	85a2                	mv	a1,s0
ffffffffc0202eee:	ae9ff0ef          	jal	ffffffffc02029d6 <page_insert>
ffffffffc0202ef2:	62051e63          	bnez	a0,ffffffffc020352e <pmm_init+0xa64>
    assert(page_ref(p) == 1);
ffffffffc0202ef6:	4018                	lw	a4,0(s0)
ffffffffc0202ef8:	4785                	li	a5,1
ffffffffc0202efa:	60f71a63          	bne	a4,a5,ffffffffc020350e <pmm_init+0xa44>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202efe:	00093503          	ld	a0,0(s2)
ffffffffc0202f02:	6605                	lui	a2,0x1
ffffffffc0202f04:	4699                	li	a3,6
ffffffffc0202f06:	10060613          	addi	a2,a2,256 # 1100 <_binary_obj___user_softint_out_size-0x7538>
ffffffffc0202f0a:	85a2                	mv	a1,s0
ffffffffc0202f0c:	acbff0ef          	jal	ffffffffc02029d6 <page_insert>
ffffffffc0202f10:	46051363          	bnez	a0,ffffffffc0203376 <pmm_init+0x8ac>
    assert(page_ref(p) == 2);
ffffffffc0202f14:	4018                	lw	a4,0(s0)
ffffffffc0202f16:	4789                	li	a5,2
ffffffffc0202f18:	72f71763          	bne	a4,a5,ffffffffc0203646 <pmm_init+0xb7c>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0202f1c:	00005597          	auipc	a1,0x5
ffffffffc0202f20:	c7458593          	addi	a1,a1,-908 # ffffffffc0207b90 <etext+0x1346>
ffffffffc0202f24:	10000513          	li	a0,256
ffffffffc0202f28:	099030ef          	jal	ffffffffc02067c0 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202f2c:	6585                	lui	a1,0x1
ffffffffc0202f2e:	10058593          	addi	a1,a1,256 # 1100 <_binary_obj___user_softint_out_size-0x7538>
ffffffffc0202f32:	10000513          	li	a0,256
ffffffffc0202f36:	09d030ef          	jal	ffffffffc02067d2 <strcmp>
ffffffffc0202f3a:	6e051663          	bnez	a0,ffffffffc0203626 <pmm_init+0xb5c>
    return page - pages + nbase;
ffffffffc0202f3e:	000b3683          	ld	a3,0(s6)
ffffffffc0202f42:	000807b7          	lui	a5,0x80
    return KADDR(page2pa(page));
ffffffffc0202f46:	6098                	ld	a4,0(s1)
    return page - pages + nbase;
ffffffffc0202f48:	40d406b3          	sub	a3,s0,a3
ffffffffc0202f4c:	8699                	srai	a3,a3,0x6
ffffffffc0202f4e:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0202f50:	00c69793          	slli	a5,a3,0xc
ffffffffc0202f54:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202f56:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202f58:	50e7ff63          	bgeu	a5,a4,ffffffffc0203476 <pmm_init+0x9ac>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202f5c:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202f60:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202f64:	97b6                	add	a5,a5,a3
ffffffffc0202f66:	10078023          	sb	zero,256(a5) # 80100 <_binary_obj___user_exit_out_size+0x76560>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202f6a:	021030ef          	jal	ffffffffc020678a <strlen>
ffffffffc0202f6e:	68051c63          	bnez	a0,ffffffffc0203606 <pmm_init+0xb3c>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0202f72:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0202f76:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202f78:	000a3783          	ld	a5,0(s4) # 1000 <_binary_obj___user_softint_out_size-0x7638>
ffffffffc0202f7c:	078a                	slli	a5,a5,0x2
ffffffffc0202f7e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202f80:	22e7f263          	bgeu	a5,a4,ffffffffc02031a4 <pmm_init+0x6da>
    return page2ppn(page) << PGSHIFT;
ffffffffc0202f84:	00c79693          	slli	a3,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0202f88:	4ee7f763          	bgeu	a5,a4,ffffffffc0203476 <pmm_init+0x9ac>
ffffffffc0202f8c:	0009b783          	ld	a5,0(s3)
ffffffffc0202f90:	00f689b3          	add	s3,a3,a5
ffffffffc0202f94:	100027f3          	csrr	a5,sstatus
ffffffffc0202f98:	8b89                	andi	a5,a5,2
ffffffffc0202f9a:	18079d63          	bnez	a5,ffffffffc0203134 <pmm_init+0x66a>
        pmm_manager->free_pages(base, n);
ffffffffc0202f9e:	000bb783          	ld	a5,0(s7)
ffffffffc0202fa2:	4585                	li	a1,1
ffffffffc0202fa4:	8522                	mv	a0,s0
ffffffffc0202fa6:	739c                	ld	a5,32(a5)
ffffffffc0202fa8:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202faa:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc0202fae:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202fb0:	078a                	slli	a5,a5,0x2
ffffffffc0202fb2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202fb4:	1ee7f863          	bgeu	a5,a4,ffffffffc02031a4 <pmm_init+0x6da>
    return &pages[PPN(pa) - nbase];
ffffffffc0202fb8:	000b3503          	ld	a0,0(s6)
ffffffffc0202fbc:	fff80737          	lui	a4,0xfff80
ffffffffc0202fc0:	97ba                	add	a5,a5,a4
ffffffffc0202fc2:	079a                	slli	a5,a5,0x6
ffffffffc0202fc4:	953e                	add	a0,a0,a5
ffffffffc0202fc6:	100027f3          	csrr	a5,sstatus
ffffffffc0202fca:	8b89                	andi	a5,a5,2
ffffffffc0202fcc:	14079863          	bnez	a5,ffffffffc020311c <pmm_init+0x652>
ffffffffc0202fd0:	000bb783          	ld	a5,0(s7)
ffffffffc0202fd4:	4585                	li	a1,1
ffffffffc0202fd6:	739c                	ld	a5,32(a5)
ffffffffc0202fd8:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202fda:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0202fde:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202fe0:	078a                	slli	a5,a5,0x2
ffffffffc0202fe2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202fe4:	1ce7f063          	bgeu	a5,a4,ffffffffc02031a4 <pmm_init+0x6da>
    return &pages[PPN(pa) - nbase];
ffffffffc0202fe8:	000b3503          	ld	a0,0(s6)
ffffffffc0202fec:	fff80737          	lui	a4,0xfff80
ffffffffc0202ff0:	97ba                	add	a5,a5,a4
ffffffffc0202ff2:	079a                	slli	a5,a5,0x6
ffffffffc0202ff4:	953e                	add	a0,a0,a5
ffffffffc0202ff6:	100027f3          	csrr	a5,sstatus
ffffffffc0202ffa:	8b89                	andi	a5,a5,2
ffffffffc0202ffc:	10079463          	bnez	a5,ffffffffc0203104 <pmm_init+0x63a>
ffffffffc0203000:	000bb783          	ld	a5,0(s7)
ffffffffc0203004:	4585                	li	a1,1
ffffffffc0203006:	739c                	ld	a5,32(a5)
ffffffffc0203008:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc020300a:	00093783          	ld	a5,0(s2)
ffffffffc020300e:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc0203012:	12000073          	sfence.vma
ffffffffc0203016:	100027f3          	csrr	a5,sstatus
ffffffffc020301a:	8b89                	andi	a5,a5,2
ffffffffc020301c:	0c079a63          	bnez	a5,ffffffffc02030f0 <pmm_init+0x626>
        ret = pmm_manager->nr_free_pages();
ffffffffc0203020:	000bb783          	ld	a5,0(s7)
ffffffffc0203024:	779c                	ld	a5,40(a5)
ffffffffc0203026:	9782                	jalr	a5
ffffffffc0203028:	842a                	mv	s0,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc020302a:	3a8c1663          	bne	s8,s0,ffffffffc02033d6 <pmm_init+0x90c>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc020302e:	00005517          	auipc	a0,0x5
ffffffffc0203032:	bda50513          	addi	a0,a0,-1062 # ffffffffc0207c08 <etext+0x13be>
ffffffffc0203036:	94afd0ef          	jal	ffffffffc0200180 <cprintf>
}
ffffffffc020303a:	6446                	ld	s0,80(sp)
ffffffffc020303c:	60e6                	ld	ra,88(sp)
ffffffffc020303e:	64a6                	ld	s1,72(sp)
ffffffffc0203040:	6906                	ld	s2,64(sp)
ffffffffc0203042:	79e2                	ld	s3,56(sp)
ffffffffc0203044:	7a42                	ld	s4,48(sp)
ffffffffc0203046:	7aa2                	ld	s5,40(sp)
ffffffffc0203048:	7b02                	ld	s6,32(sp)
ffffffffc020304a:	6be2                	ld	s7,24(sp)
ffffffffc020304c:	6c42                	ld	s8,16(sp)
ffffffffc020304e:	6125                	addi	sp,sp,96
    kmalloc_init();
ffffffffc0203050:	fb5fe06f          	j	ffffffffc0202004 <kmalloc_init>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0203054:	6785                	lui	a5,0x1
ffffffffc0203056:	17fd                	addi	a5,a5,-1 # fff <_binary_obj___user_softint_out_size-0x7639>
ffffffffc0203058:	96be                	add	a3,a3,a5
ffffffffc020305a:	77fd                	lui	a5,0xfffff
ffffffffc020305c:	8ff5                	and	a5,a5,a3
    if (PPN(pa) >= npage) {
ffffffffc020305e:	00c7d693          	srli	a3,a5,0xc
ffffffffc0203062:	14c6f163          	bgeu	a3,a2,ffffffffc02031a4 <pmm_init+0x6da>
    pmm_manager->init_memmap(base, n);
ffffffffc0203066:	000bb603          	ld	a2,0(s7)
    return &pages[PPN(pa) - nbase];
ffffffffc020306a:	fff805b7          	lui	a1,0xfff80
ffffffffc020306e:	96ae                	add	a3,a3,a1
ffffffffc0203070:	6a10                	ld	a2,16(a2)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0203072:	8f1d                	sub	a4,a4,a5
ffffffffc0203074:	069a                	slli	a3,a3,0x6
    pmm_manager->init_memmap(base, n);
ffffffffc0203076:	00c75593          	srli	a1,a4,0xc
ffffffffc020307a:	9536                	add	a0,a0,a3
ffffffffc020307c:	9602                	jalr	a2
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc020307e:	0009b583          	ld	a1,0(s3)
}
ffffffffc0203082:	be05                	j	ffffffffc0202bb2 <pmm_init+0xe8>
        intr_disable();
ffffffffc0203084:	dbcfd0ef          	jal	ffffffffc0200640 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0203088:	000bb783          	ld	a5,0(s7)
ffffffffc020308c:	779c                	ld	a5,40(a5)
ffffffffc020308e:	9782                	jalr	a5
ffffffffc0203090:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0203092:	da8fd0ef          	jal	ffffffffc020063a <intr_enable>
ffffffffc0203096:	bead                	j	ffffffffc0202c10 <pmm_init+0x146>
        intr_disable();
ffffffffc0203098:	da8fd0ef          	jal	ffffffffc0200640 <intr_disable>
ffffffffc020309c:	000bb783          	ld	a5,0(s7)
ffffffffc02030a0:	779c                	ld	a5,40(a5)
ffffffffc02030a2:	9782                	jalr	a5
ffffffffc02030a4:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc02030a6:	d94fd0ef          	jal	ffffffffc020063a <intr_enable>
ffffffffc02030aa:	b3c5                	j	ffffffffc0202e8a <pmm_init+0x3c0>
        intr_disable();
ffffffffc02030ac:	d94fd0ef          	jal	ffffffffc0200640 <intr_disable>
ffffffffc02030b0:	000bb783          	ld	a5,0(s7)
ffffffffc02030b4:	779c                	ld	a5,40(a5)
ffffffffc02030b6:	9782                	jalr	a5
ffffffffc02030b8:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc02030ba:	d80fd0ef          	jal	ffffffffc020063a <intr_enable>
ffffffffc02030be:	b365                	j	ffffffffc0202e66 <pmm_init+0x39c>
ffffffffc02030c0:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02030c2:	d7efd0ef          	jal	ffffffffc0200640 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02030c6:	000bb783          	ld	a5,0(s7)
ffffffffc02030ca:	6522                	ld	a0,8(sp)
ffffffffc02030cc:	4585                	li	a1,1
ffffffffc02030ce:	739c                	ld	a5,32(a5)
ffffffffc02030d0:	9782                	jalr	a5
        intr_enable();
ffffffffc02030d2:	d68fd0ef          	jal	ffffffffc020063a <intr_enable>
ffffffffc02030d6:	bb85                	j	ffffffffc0202e46 <pmm_init+0x37c>
ffffffffc02030d8:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02030da:	d66fd0ef          	jal	ffffffffc0200640 <intr_disable>
ffffffffc02030de:	000bb783          	ld	a5,0(s7)
ffffffffc02030e2:	6522                	ld	a0,8(sp)
ffffffffc02030e4:	4585                	li	a1,1
ffffffffc02030e6:	739c                	ld	a5,32(a5)
ffffffffc02030e8:	9782                	jalr	a5
        intr_enable();
ffffffffc02030ea:	d50fd0ef          	jal	ffffffffc020063a <intr_enable>
ffffffffc02030ee:	b325                	j	ffffffffc0202e16 <pmm_init+0x34c>
        intr_disable();
ffffffffc02030f0:	d50fd0ef          	jal	ffffffffc0200640 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc02030f4:	000bb783          	ld	a5,0(s7)
ffffffffc02030f8:	779c                	ld	a5,40(a5)
ffffffffc02030fa:	9782                	jalr	a5
ffffffffc02030fc:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02030fe:	d3cfd0ef          	jal	ffffffffc020063a <intr_enable>
ffffffffc0203102:	b725                	j	ffffffffc020302a <pmm_init+0x560>
ffffffffc0203104:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0203106:	d3afd0ef          	jal	ffffffffc0200640 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020310a:	000bb783          	ld	a5,0(s7)
ffffffffc020310e:	6522                	ld	a0,8(sp)
ffffffffc0203110:	4585                	li	a1,1
ffffffffc0203112:	739c                	ld	a5,32(a5)
ffffffffc0203114:	9782                	jalr	a5
        intr_enable();
ffffffffc0203116:	d24fd0ef          	jal	ffffffffc020063a <intr_enable>
ffffffffc020311a:	bdc5                	j	ffffffffc020300a <pmm_init+0x540>
ffffffffc020311c:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020311e:	d22fd0ef          	jal	ffffffffc0200640 <intr_disable>
ffffffffc0203122:	000bb783          	ld	a5,0(s7)
ffffffffc0203126:	6522                	ld	a0,8(sp)
ffffffffc0203128:	4585                	li	a1,1
ffffffffc020312a:	739c                	ld	a5,32(a5)
ffffffffc020312c:	9782                	jalr	a5
        intr_enable();
ffffffffc020312e:	d0cfd0ef          	jal	ffffffffc020063a <intr_enable>
ffffffffc0203132:	b565                	j	ffffffffc0202fda <pmm_init+0x510>
        intr_disable();
ffffffffc0203134:	d0cfd0ef          	jal	ffffffffc0200640 <intr_disable>
ffffffffc0203138:	000bb783          	ld	a5,0(s7)
ffffffffc020313c:	4585                	li	a1,1
ffffffffc020313e:	8522                	mv	a0,s0
ffffffffc0203140:	739c                	ld	a5,32(a5)
ffffffffc0203142:	9782                	jalr	a5
        intr_enable();
ffffffffc0203144:	cf6fd0ef          	jal	ffffffffc020063a <intr_enable>
ffffffffc0203148:	b58d                	j	ffffffffc0202faa <pmm_init+0x4e0>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020314a:	00005697          	auipc	a3,0x5
ffffffffc020314e:	96e68693          	addi	a3,a3,-1682 # ffffffffc0207ab8 <etext+0x126e>
ffffffffc0203152:	00004617          	auipc	a2,0x4
ffffffffc0203156:	d7660613          	addi	a2,a2,-650 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc020315a:	24000593          	li	a1,576
ffffffffc020315e:	00004517          	auipc	a0,0x4
ffffffffc0203162:	59250513          	addi	a0,a0,1426 # ffffffffc02076f0 <etext+0xea6>
ffffffffc0203166:	b0efd0ef          	jal	ffffffffc0200474 <__panic>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc020316a:	00005697          	auipc	a3,0x5
ffffffffc020316e:	90e68693          	addi	a3,a3,-1778 # ffffffffc0207a78 <etext+0x122e>
ffffffffc0203172:	00004617          	auipc	a2,0x4
ffffffffc0203176:	d5660613          	addi	a2,a2,-682 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc020317a:	23f00593          	li	a1,575
ffffffffc020317e:	00004517          	auipc	a0,0x4
ffffffffc0203182:	57250513          	addi	a0,a0,1394 # ffffffffc02076f0 <etext+0xea6>
ffffffffc0203186:	aeefd0ef          	jal	ffffffffc0200474 <__panic>
ffffffffc020318a:	86a2                	mv	a3,s0
ffffffffc020318c:	00004617          	auipc	a2,0x4
ffffffffc0203190:	08460613          	addi	a2,a2,132 # ffffffffc0207210 <etext+0x9c6>
ffffffffc0203194:	23f00593          	li	a1,575
ffffffffc0203198:	00004517          	auipc	a0,0x4
ffffffffc020319c:	55850513          	addi	a0,a0,1368 # ffffffffc02076f0 <etext+0xea6>
ffffffffc02031a0:	ad4fd0ef          	jal	ffffffffc0200474 <__panic>
ffffffffc02031a4:	824ff0ef          	jal	ffffffffc02021c8 <pa2page.part.0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02031a8:	00004617          	auipc	a2,0x4
ffffffffc02031ac:	0b860613          	addi	a2,a2,184 # ffffffffc0207260 <etext+0xa16>
ffffffffc02031b0:	07f00593          	li	a1,127
ffffffffc02031b4:	00004517          	auipc	a0,0x4
ffffffffc02031b8:	53c50513          	addi	a0,a0,1340 # ffffffffc02076f0 <etext+0xea6>
ffffffffc02031bc:	ab8fd0ef          	jal	ffffffffc0200474 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc02031c0:	00004617          	auipc	a2,0x4
ffffffffc02031c4:	0a060613          	addi	a2,a2,160 # ffffffffc0207260 <etext+0xa16>
ffffffffc02031c8:	0c100593          	li	a1,193
ffffffffc02031cc:	00004517          	auipc	a0,0x4
ffffffffc02031d0:	52450513          	addi	a0,a0,1316 # ffffffffc02076f0 <etext+0xea6>
ffffffffc02031d4:	aa0fd0ef          	jal	ffffffffc0200474 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02031d8:	00004697          	auipc	a3,0x4
ffffffffc02031dc:	5d868693          	addi	a3,a3,1496 # ffffffffc02077b0 <etext+0xf66>
ffffffffc02031e0:	00004617          	auipc	a2,0x4
ffffffffc02031e4:	ce860613          	addi	a2,a2,-792 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc02031e8:	20300593          	li	a1,515
ffffffffc02031ec:	00004517          	auipc	a0,0x4
ffffffffc02031f0:	50450513          	addi	a0,a0,1284 # ffffffffc02076f0 <etext+0xea6>
ffffffffc02031f4:	a80fd0ef          	jal	ffffffffc0200474 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02031f8:	00004697          	auipc	a3,0x4
ffffffffc02031fc:	59868693          	addi	a3,a3,1432 # ffffffffc0207790 <etext+0xf46>
ffffffffc0203200:	00004617          	auipc	a2,0x4
ffffffffc0203204:	cc860613          	addi	a2,a2,-824 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0203208:	20200593          	li	a1,514
ffffffffc020320c:	00004517          	auipc	a0,0x4
ffffffffc0203210:	4e450513          	addi	a0,a0,1252 # ffffffffc02076f0 <etext+0xea6>
ffffffffc0203214:	a60fd0ef          	jal	ffffffffc0200474 <__panic>
ffffffffc0203218:	fcdfe0ef          	jal	ffffffffc02021e4 <pte2page.part.0>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc020321c:	00004697          	auipc	a3,0x4
ffffffffc0203220:	62468693          	addi	a3,a3,1572 # ffffffffc0207840 <etext+0xff6>
ffffffffc0203224:	00004617          	auipc	a2,0x4
ffffffffc0203228:	ca460613          	addi	a2,a2,-860 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc020322c:	20b00593          	li	a1,523
ffffffffc0203230:	00004517          	auipc	a0,0x4
ffffffffc0203234:	4c050513          	addi	a0,a0,1216 # ffffffffc02076f0 <etext+0xea6>
ffffffffc0203238:	a3cfd0ef          	jal	ffffffffc0200474 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc020323c:	00004697          	auipc	a3,0x4
ffffffffc0203240:	5d468693          	addi	a3,a3,1492 # ffffffffc0207810 <etext+0xfc6>
ffffffffc0203244:	00004617          	auipc	a2,0x4
ffffffffc0203248:	c8460613          	addi	a2,a2,-892 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc020324c:	20800593          	li	a1,520
ffffffffc0203250:	00004517          	auipc	a0,0x4
ffffffffc0203254:	4a050513          	addi	a0,a0,1184 # ffffffffc02076f0 <etext+0xea6>
ffffffffc0203258:	a1cfd0ef          	jal	ffffffffc0200474 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc020325c:	00004697          	auipc	a3,0x4
ffffffffc0203260:	58c68693          	addi	a3,a3,1420 # ffffffffc02077e8 <etext+0xf9e>
ffffffffc0203264:	00004617          	auipc	a2,0x4
ffffffffc0203268:	c6460613          	addi	a2,a2,-924 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc020326c:	20400593          	li	a1,516
ffffffffc0203270:	00004517          	auipc	a0,0x4
ffffffffc0203274:	48050513          	addi	a0,a0,1152 # ffffffffc02076f0 <etext+0xea6>
ffffffffc0203278:	9fcfd0ef          	jal	ffffffffc0200474 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc020327c:	00004697          	auipc	a3,0x4
ffffffffc0203280:	64c68693          	addi	a3,a3,1612 # ffffffffc02078c8 <etext+0x107e>
ffffffffc0203284:	00004617          	auipc	a2,0x4
ffffffffc0203288:	c4460613          	addi	a2,a2,-956 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc020328c:	21400593          	li	a1,532
ffffffffc0203290:	00004517          	auipc	a0,0x4
ffffffffc0203294:	46050513          	addi	a0,a0,1120 # ffffffffc02076f0 <etext+0xea6>
ffffffffc0203298:	9dcfd0ef          	jal	ffffffffc0200474 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc020329c:	00004697          	auipc	a3,0x4
ffffffffc02032a0:	6cc68693          	addi	a3,a3,1740 # ffffffffc0207968 <etext+0x111e>
ffffffffc02032a4:	00004617          	auipc	a2,0x4
ffffffffc02032a8:	c2460613          	addi	a2,a2,-988 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc02032ac:	21900593          	li	a1,537
ffffffffc02032b0:	00004517          	auipc	a0,0x4
ffffffffc02032b4:	44050513          	addi	a0,a0,1088 # ffffffffc02076f0 <etext+0xea6>
ffffffffc02032b8:	9bcfd0ef          	jal	ffffffffc0200474 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02032bc:	00004697          	auipc	a3,0x4
ffffffffc02032c0:	5e468693          	addi	a3,a3,1508 # ffffffffc02078a0 <etext+0x1056>
ffffffffc02032c4:	00004617          	auipc	a2,0x4
ffffffffc02032c8:	c0460613          	addi	a2,a2,-1020 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc02032cc:	21100593          	li	a1,529
ffffffffc02032d0:	00004517          	auipc	a0,0x4
ffffffffc02032d4:	42050513          	addi	a0,a0,1056 # ffffffffc02076f0 <etext+0xea6>
ffffffffc02032d8:	99cfd0ef          	jal	ffffffffc0200474 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02032dc:	86d6                	mv	a3,s5
ffffffffc02032de:	00004617          	auipc	a2,0x4
ffffffffc02032e2:	f3260613          	addi	a2,a2,-206 # ffffffffc0207210 <etext+0x9c6>
ffffffffc02032e6:	21000593          	li	a1,528
ffffffffc02032ea:	00004517          	auipc	a0,0x4
ffffffffc02032ee:	40650513          	addi	a0,a0,1030 # ffffffffc02076f0 <etext+0xea6>
ffffffffc02032f2:	982fd0ef          	jal	ffffffffc0200474 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02032f6:	00004697          	auipc	a3,0x4
ffffffffc02032fa:	60a68693          	addi	a3,a3,1546 # ffffffffc0207900 <etext+0x10b6>
ffffffffc02032fe:	00004617          	auipc	a2,0x4
ffffffffc0203302:	bca60613          	addi	a2,a2,-1078 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0203306:	21e00593          	li	a1,542
ffffffffc020330a:	00004517          	auipc	a0,0x4
ffffffffc020330e:	3e650513          	addi	a0,a0,998 # ffffffffc02076f0 <etext+0xea6>
ffffffffc0203312:	962fd0ef          	jal	ffffffffc0200474 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203316:	00004697          	auipc	a3,0x4
ffffffffc020331a:	6b268693          	addi	a3,a3,1714 # ffffffffc02079c8 <etext+0x117e>
ffffffffc020331e:	00004617          	auipc	a2,0x4
ffffffffc0203322:	baa60613          	addi	a2,a2,-1110 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0203326:	21d00593          	li	a1,541
ffffffffc020332a:	00004517          	auipc	a0,0x4
ffffffffc020332e:	3c650513          	addi	a0,a0,966 # ffffffffc02076f0 <etext+0xea6>
ffffffffc0203332:	942fd0ef          	jal	ffffffffc0200474 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0203336:	00004697          	auipc	a3,0x4
ffffffffc020333a:	67a68693          	addi	a3,a3,1658 # ffffffffc02079b0 <etext+0x1166>
ffffffffc020333e:	00004617          	auipc	a2,0x4
ffffffffc0203342:	b8a60613          	addi	a2,a2,-1142 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0203346:	21c00593          	li	a1,540
ffffffffc020334a:	00004517          	auipc	a0,0x4
ffffffffc020334e:	3a650513          	addi	a0,a0,934 # ffffffffc02076f0 <etext+0xea6>
ffffffffc0203352:	922fd0ef          	jal	ffffffffc0200474 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0203356:	00004697          	auipc	a3,0x4
ffffffffc020335a:	62a68693          	addi	a3,a3,1578 # ffffffffc0207980 <etext+0x1136>
ffffffffc020335e:	00004617          	auipc	a2,0x4
ffffffffc0203362:	b6a60613          	addi	a2,a2,-1174 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0203366:	21b00593          	li	a1,539
ffffffffc020336a:	00004517          	auipc	a0,0x4
ffffffffc020336e:	38650513          	addi	a0,a0,902 # ffffffffc02076f0 <etext+0xea6>
ffffffffc0203372:	902fd0ef          	jal	ffffffffc0200474 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0203376:	00004697          	auipc	a3,0x4
ffffffffc020337a:	7c268693          	addi	a3,a3,1986 # ffffffffc0207b38 <etext+0x12ee>
ffffffffc020337e:	00004617          	auipc	a2,0x4
ffffffffc0203382:	b4a60613          	addi	a2,a2,-1206 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0203386:	24a00593          	li	a1,586
ffffffffc020338a:	00004517          	auipc	a0,0x4
ffffffffc020338e:	36650513          	addi	a0,a0,870 # ffffffffc02076f0 <etext+0xea6>
ffffffffc0203392:	8e2fd0ef          	jal	ffffffffc0200474 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0203396:	00004697          	auipc	a3,0x4
ffffffffc020339a:	5ba68693          	addi	a3,a3,1466 # ffffffffc0207950 <etext+0x1106>
ffffffffc020339e:	00004617          	auipc	a2,0x4
ffffffffc02033a2:	b2a60613          	addi	a2,a2,-1238 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc02033a6:	21800593          	li	a1,536
ffffffffc02033aa:	00004517          	auipc	a0,0x4
ffffffffc02033ae:	34650513          	addi	a0,a0,838 # ffffffffc02076f0 <etext+0xea6>
ffffffffc02033b2:	8c2fd0ef          	jal	ffffffffc0200474 <__panic>
    assert(*ptep & PTE_W);
ffffffffc02033b6:	00004697          	auipc	a3,0x4
ffffffffc02033ba:	58a68693          	addi	a3,a3,1418 # ffffffffc0207940 <etext+0x10f6>
ffffffffc02033be:	00004617          	auipc	a2,0x4
ffffffffc02033c2:	b0a60613          	addi	a2,a2,-1270 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc02033c6:	21700593          	li	a1,535
ffffffffc02033ca:	00004517          	auipc	a0,0x4
ffffffffc02033ce:	32650513          	addi	a0,a0,806 # ffffffffc02076f0 <etext+0xea6>
ffffffffc02033d2:	8a2fd0ef          	jal	ffffffffc0200474 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02033d6:	00004697          	auipc	a3,0x4
ffffffffc02033da:	66268693          	addi	a3,a3,1634 # ffffffffc0207a38 <etext+0x11ee>
ffffffffc02033de:	00004617          	auipc	a2,0x4
ffffffffc02033e2:	aea60613          	addi	a2,a2,-1302 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc02033e6:	25b00593          	li	a1,603
ffffffffc02033ea:	00004517          	auipc	a0,0x4
ffffffffc02033ee:	30650513          	addi	a0,a0,774 # ffffffffc02076f0 <etext+0xea6>
ffffffffc02033f2:	882fd0ef          	jal	ffffffffc0200474 <__panic>
    assert(*ptep & PTE_U);
ffffffffc02033f6:	00004697          	auipc	a3,0x4
ffffffffc02033fa:	53a68693          	addi	a3,a3,1338 # ffffffffc0207930 <etext+0x10e6>
ffffffffc02033fe:	00004617          	auipc	a2,0x4
ffffffffc0203402:	aca60613          	addi	a2,a2,-1334 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0203406:	21600593          	li	a1,534
ffffffffc020340a:	00004517          	auipc	a0,0x4
ffffffffc020340e:	2e650513          	addi	a0,a0,742 # ffffffffc02076f0 <etext+0xea6>
ffffffffc0203412:	862fd0ef          	jal	ffffffffc0200474 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0203416:	00004697          	auipc	a3,0x4
ffffffffc020341a:	47268693          	addi	a3,a3,1138 # ffffffffc0207888 <etext+0x103e>
ffffffffc020341e:	00004617          	auipc	a2,0x4
ffffffffc0203422:	aaa60613          	addi	a2,a2,-1366 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0203426:	22300593          	li	a1,547
ffffffffc020342a:	00004517          	auipc	a0,0x4
ffffffffc020342e:	2c650513          	addi	a0,a0,710 # ffffffffc02076f0 <etext+0xea6>
ffffffffc0203432:	842fd0ef          	jal	ffffffffc0200474 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0203436:	00004697          	auipc	a3,0x4
ffffffffc020343a:	5aa68693          	addi	a3,a3,1450 # ffffffffc02079e0 <etext+0x1196>
ffffffffc020343e:	00004617          	auipc	a2,0x4
ffffffffc0203442:	a8a60613          	addi	a2,a2,-1398 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0203446:	22000593          	li	a1,544
ffffffffc020344a:	00004517          	auipc	a0,0x4
ffffffffc020344e:	2a650513          	addi	a0,a0,678 # ffffffffc02076f0 <etext+0xea6>
ffffffffc0203452:	822fd0ef          	jal	ffffffffc0200474 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0203456:	00004697          	auipc	a3,0x4
ffffffffc020345a:	41a68693          	addi	a3,a3,1050 # ffffffffc0207870 <etext+0x1026>
ffffffffc020345e:	00004617          	auipc	a2,0x4
ffffffffc0203462:	a6a60613          	addi	a2,a2,-1430 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0203466:	21f00593          	li	a1,543
ffffffffc020346a:	00004517          	auipc	a0,0x4
ffffffffc020346e:	28650513          	addi	a0,a0,646 # ffffffffc02076f0 <etext+0xea6>
ffffffffc0203472:	802fd0ef          	jal	ffffffffc0200474 <__panic>
    return KADDR(page2pa(page));
ffffffffc0203476:	00004617          	auipc	a2,0x4
ffffffffc020347a:	d9a60613          	addi	a2,a2,-614 # ffffffffc0207210 <etext+0x9c6>
ffffffffc020347e:	06a00593          	li	a1,106
ffffffffc0203482:	00004517          	auipc	a0,0x4
ffffffffc0203486:	d3e50513          	addi	a0,a0,-706 # ffffffffc02071c0 <etext+0x976>
ffffffffc020348a:	febfc0ef          	jal	ffffffffc0200474 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc020348e:	00004697          	auipc	a3,0x4
ffffffffc0203492:	58268693          	addi	a3,a3,1410 # ffffffffc0207a10 <etext+0x11c6>
ffffffffc0203496:	00004617          	auipc	a2,0x4
ffffffffc020349a:	a3260613          	addi	a2,a2,-1486 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc020349e:	22a00593          	li	a1,554
ffffffffc02034a2:	00004517          	auipc	a0,0x4
ffffffffc02034a6:	24e50513          	addi	a0,a0,590 # ffffffffc02076f0 <etext+0xea6>
ffffffffc02034aa:	fcbfc0ef          	jal	ffffffffc0200474 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02034ae:	00004697          	auipc	a3,0x4
ffffffffc02034b2:	51a68693          	addi	a3,a3,1306 # ffffffffc02079c8 <etext+0x117e>
ffffffffc02034b6:	00004617          	auipc	a2,0x4
ffffffffc02034ba:	a1260613          	addi	a2,a2,-1518 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc02034be:	22800593          	li	a1,552
ffffffffc02034c2:	00004517          	auipc	a0,0x4
ffffffffc02034c6:	22e50513          	addi	a0,a0,558 # ffffffffc02076f0 <etext+0xea6>
ffffffffc02034ca:	fabfc0ef          	jal	ffffffffc0200474 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc02034ce:	00004697          	auipc	a3,0x4
ffffffffc02034d2:	52a68693          	addi	a3,a3,1322 # ffffffffc02079f8 <etext+0x11ae>
ffffffffc02034d6:	00004617          	auipc	a2,0x4
ffffffffc02034da:	9f260613          	addi	a2,a2,-1550 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc02034de:	22700593          	li	a1,551
ffffffffc02034e2:	00004517          	auipc	a0,0x4
ffffffffc02034e6:	20e50513          	addi	a0,a0,526 # ffffffffc02076f0 <etext+0xea6>
ffffffffc02034ea:	f8bfc0ef          	jal	ffffffffc0200474 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02034ee:	00004697          	auipc	a3,0x4
ffffffffc02034f2:	4da68693          	addi	a3,a3,1242 # ffffffffc02079c8 <etext+0x117e>
ffffffffc02034f6:	00004617          	auipc	a2,0x4
ffffffffc02034fa:	9d260613          	addi	a2,a2,-1582 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc02034fe:	22400593          	li	a1,548
ffffffffc0203502:	00004517          	auipc	a0,0x4
ffffffffc0203506:	1ee50513          	addi	a0,a0,494 # ffffffffc02076f0 <etext+0xea6>
ffffffffc020350a:	f6bfc0ef          	jal	ffffffffc0200474 <__panic>
    assert(page_ref(p) == 1);
ffffffffc020350e:	00004697          	auipc	a3,0x4
ffffffffc0203512:	61268693          	addi	a3,a3,1554 # ffffffffc0207b20 <etext+0x12d6>
ffffffffc0203516:	00004617          	auipc	a2,0x4
ffffffffc020351a:	9b260613          	addi	a2,a2,-1614 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc020351e:	24900593          	li	a1,585
ffffffffc0203522:	00004517          	auipc	a0,0x4
ffffffffc0203526:	1ce50513          	addi	a0,a0,462 # ffffffffc02076f0 <etext+0xea6>
ffffffffc020352a:	f4bfc0ef          	jal	ffffffffc0200474 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc020352e:	00004697          	auipc	a3,0x4
ffffffffc0203532:	5ba68693          	addi	a3,a3,1466 # ffffffffc0207ae8 <etext+0x129e>
ffffffffc0203536:	00004617          	auipc	a2,0x4
ffffffffc020353a:	99260613          	addi	a2,a2,-1646 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc020353e:	24800593          	li	a1,584
ffffffffc0203542:	00004517          	auipc	a0,0x4
ffffffffc0203546:	1ae50513          	addi	a0,a0,430 # ffffffffc02076f0 <etext+0xea6>
ffffffffc020354a:	f2bfc0ef          	jal	ffffffffc0200474 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc020354e:	00004697          	auipc	a3,0x4
ffffffffc0203552:	58268693          	addi	a3,a3,1410 # ffffffffc0207ad0 <etext+0x1286>
ffffffffc0203556:	00004617          	auipc	a2,0x4
ffffffffc020355a:	97260613          	addi	a2,a2,-1678 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc020355e:	24400593          	li	a1,580
ffffffffc0203562:	00004517          	auipc	a0,0x4
ffffffffc0203566:	18e50513          	addi	a0,a0,398 # ffffffffc02076f0 <etext+0xea6>
ffffffffc020356a:	f0bfc0ef          	jal	ffffffffc0200474 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc020356e:	00004697          	auipc	a3,0x4
ffffffffc0203572:	4ca68693          	addi	a3,a3,1226 # ffffffffc0207a38 <etext+0x11ee>
ffffffffc0203576:	00004617          	auipc	a2,0x4
ffffffffc020357a:	95260613          	addi	a2,a2,-1710 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc020357e:	23200593          	li	a1,562
ffffffffc0203582:	00004517          	auipc	a0,0x4
ffffffffc0203586:	16e50513          	addi	a0,a0,366 # ffffffffc02076f0 <etext+0xea6>
ffffffffc020358a:	eebfc0ef          	jal	ffffffffc0200474 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc020358e:	00004697          	auipc	a3,0x4
ffffffffc0203592:	2e268693          	addi	a3,a3,738 # ffffffffc0207870 <etext+0x1026>
ffffffffc0203596:	00004617          	auipc	a2,0x4
ffffffffc020359a:	93260613          	addi	a2,a2,-1742 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc020359e:	20c00593          	li	a1,524
ffffffffc02035a2:	00004517          	auipc	a0,0x4
ffffffffc02035a6:	14e50513          	addi	a0,a0,334 # ffffffffc02076f0 <etext+0xea6>
ffffffffc02035aa:	ecbfc0ef          	jal	ffffffffc0200474 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc02035ae:	00004617          	auipc	a2,0x4
ffffffffc02035b2:	c6260613          	addi	a2,a2,-926 # ffffffffc0207210 <etext+0x9c6>
ffffffffc02035b6:	20f00593          	li	a1,527
ffffffffc02035ba:	00004517          	auipc	a0,0x4
ffffffffc02035be:	13650513          	addi	a0,a0,310 # ffffffffc02076f0 <etext+0xea6>
ffffffffc02035c2:	eb3fc0ef          	jal	ffffffffc0200474 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02035c6:	00004697          	auipc	a3,0x4
ffffffffc02035ca:	2c268693          	addi	a3,a3,706 # ffffffffc0207888 <etext+0x103e>
ffffffffc02035ce:	00004617          	auipc	a2,0x4
ffffffffc02035d2:	8fa60613          	addi	a2,a2,-1798 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc02035d6:	20d00593          	li	a1,525
ffffffffc02035da:	00004517          	auipc	a0,0x4
ffffffffc02035de:	11650513          	addi	a0,a0,278 # ffffffffc02076f0 <etext+0xea6>
ffffffffc02035e2:	e93fc0ef          	jal	ffffffffc0200474 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02035e6:	00004697          	auipc	a3,0x4
ffffffffc02035ea:	31a68693          	addi	a3,a3,794 # ffffffffc0207900 <etext+0x10b6>
ffffffffc02035ee:	00004617          	auipc	a2,0x4
ffffffffc02035f2:	8da60613          	addi	a2,a2,-1830 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc02035f6:	21500593          	li	a1,533
ffffffffc02035fa:	00004517          	auipc	a0,0x4
ffffffffc02035fe:	0f650513          	addi	a0,a0,246 # ffffffffc02076f0 <etext+0xea6>
ffffffffc0203602:	e73fc0ef          	jal	ffffffffc0200474 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0203606:	00004697          	auipc	a3,0x4
ffffffffc020360a:	5da68693          	addi	a3,a3,1498 # ffffffffc0207be0 <etext+0x1396>
ffffffffc020360e:	00004617          	auipc	a2,0x4
ffffffffc0203612:	8ba60613          	addi	a2,a2,-1862 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0203616:	25200593          	li	a1,594
ffffffffc020361a:	00004517          	auipc	a0,0x4
ffffffffc020361e:	0d650513          	addi	a0,a0,214 # ffffffffc02076f0 <etext+0xea6>
ffffffffc0203622:	e53fc0ef          	jal	ffffffffc0200474 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0203626:	00004697          	auipc	a3,0x4
ffffffffc020362a:	58268693          	addi	a3,a3,1410 # ffffffffc0207ba8 <etext+0x135e>
ffffffffc020362e:	00004617          	auipc	a2,0x4
ffffffffc0203632:	89a60613          	addi	a2,a2,-1894 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0203636:	24f00593          	li	a1,591
ffffffffc020363a:	00004517          	auipc	a0,0x4
ffffffffc020363e:	0b650513          	addi	a0,a0,182 # ffffffffc02076f0 <etext+0xea6>
ffffffffc0203642:	e33fc0ef          	jal	ffffffffc0200474 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0203646:	00004697          	auipc	a3,0x4
ffffffffc020364a:	53268693          	addi	a3,a3,1330 # ffffffffc0207b78 <etext+0x132e>
ffffffffc020364e:	00004617          	auipc	a2,0x4
ffffffffc0203652:	87a60613          	addi	a2,a2,-1926 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0203656:	24b00593          	li	a1,587
ffffffffc020365a:	00004517          	auipc	a0,0x4
ffffffffc020365e:	09650513          	addi	a0,a0,150 # ffffffffc02076f0 <etext+0xea6>
ffffffffc0203662:	e13fc0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc0203666 <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203666:	12058073          	sfence.vma	a1
}
ffffffffc020366a:	8082                	ret

ffffffffc020366c <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc020366c:	7179                	addi	sp,sp,-48
ffffffffc020366e:	e84a                	sd	s2,16(sp)
ffffffffc0203670:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0203672:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0203674:	ec26                	sd	s1,24(sp)
ffffffffc0203676:	e44e                	sd	s3,8(sp)
ffffffffc0203678:	f406                	sd	ra,40(sp)
ffffffffc020367a:	f022                	sd	s0,32(sp)
ffffffffc020367c:	84ae                	mv	s1,a1
ffffffffc020367e:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0203680:	b81fe0ef          	jal	ffffffffc0202200 <alloc_pages>
    if (page != NULL) {
ffffffffc0203684:	c12d                	beqz	a0,ffffffffc02036e6 <pgdir_alloc_page+0x7a>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0203686:	842a                	mv	s0,a0
ffffffffc0203688:	85aa                	mv	a1,a0
ffffffffc020368a:	86ce                	mv	a3,s3
ffffffffc020368c:	8626                	mv	a2,s1
ffffffffc020368e:	854a                	mv	a0,s2
ffffffffc0203690:	b46ff0ef          	jal	ffffffffc02029d6 <page_insert>
ffffffffc0203694:	ed0d                	bnez	a0,ffffffffc02036ce <pgdir_alloc_page+0x62>
        if (swap_init_ok) {
ffffffffc0203696:	0009b797          	auipc	a5,0x9b
ffffffffc020369a:	92a7a783          	lw	a5,-1750(a5) # ffffffffc029dfc0 <swap_init_ok>
ffffffffc020369e:	c385                	beqz	a5,ffffffffc02036be <pgdir_alloc_page+0x52>
            if (check_mm_struct != NULL) {
ffffffffc02036a0:	0009b517          	auipc	a0,0x9b
ffffffffc02036a4:	94053503          	ld	a0,-1728(a0) # ffffffffc029dfe0 <check_mm_struct>
ffffffffc02036a8:	c919                	beqz	a0,ffffffffc02036be <pgdir_alloc_page+0x52>
                swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc02036aa:	4681                	li	a3,0
ffffffffc02036ac:	8622                	mv	a2,s0
ffffffffc02036ae:	85a6                	mv	a1,s1
ffffffffc02036b0:	00f000ef          	jal	ffffffffc0203ebe <swap_map_swappable>
                assert(page_ref(page) == 1);
ffffffffc02036b4:	4018                	lw	a4,0(s0)
                page->pra_vaddr = la;
ffffffffc02036b6:	fc04                	sd	s1,56(s0)
                assert(page_ref(page) == 1);
ffffffffc02036b8:	4785                	li	a5,1
ffffffffc02036ba:	04f71663          	bne	a4,a5,ffffffffc0203706 <pgdir_alloc_page+0x9a>
}
ffffffffc02036be:	70a2                	ld	ra,40(sp)
ffffffffc02036c0:	8522                	mv	a0,s0
ffffffffc02036c2:	7402                	ld	s0,32(sp)
ffffffffc02036c4:	64e2                	ld	s1,24(sp)
ffffffffc02036c6:	6942                	ld	s2,16(sp)
ffffffffc02036c8:	69a2                	ld	s3,8(sp)
ffffffffc02036ca:	6145                	addi	sp,sp,48
ffffffffc02036cc:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02036ce:	100027f3          	csrr	a5,sstatus
ffffffffc02036d2:	8b89                	andi	a5,a5,2
ffffffffc02036d4:	eb99                	bnez	a5,ffffffffc02036ea <pgdir_alloc_page+0x7e>
        pmm_manager->free_pages(base, n);
ffffffffc02036d6:	0009b797          	auipc	a5,0x9b
ffffffffc02036da:	8ba7b783          	ld	a5,-1862(a5) # ffffffffc029df90 <pmm_manager>
ffffffffc02036de:	739c                	ld	a5,32(a5)
ffffffffc02036e0:	4585                	li	a1,1
ffffffffc02036e2:	8522                	mv	a0,s0
ffffffffc02036e4:	9782                	jalr	a5
            return NULL;
ffffffffc02036e6:	4401                	li	s0,0
ffffffffc02036e8:	bfd9                	j	ffffffffc02036be <pgdir_alloc_page+0x52>
        intr_disable();
ffffffffc02036ea:	f57fc0ef          	jal	ffffffffc0200640 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02036ee:	0009b797          	auipc	a5,0x9b
ffffffffc02036f2:	8a27b783          	ld	a5,-1886(a5) # ffffffffc029df90 <pmm_manager>
ffffffffc02036f6:	739c                	ld	a5,32(a5)
ffffffffc02036f8:	8522                	mv	a0,s0
ffffffffc02036fa:	4585                	li	a1,1
ffffffffc02036fc:	9782                	jalr	a5
            return NULL;
ffffffffc02036fe:	4401                	li	s0,0
        intr_enable();
ffffffffc0203700:	f3bfc0ef          	jal	ffffffffc020063a <intr_enable>
ffffffffc0203704:	bf6d                	j	ffffffffc02036be <pgdir_alloc_page+0x52>
                assert(page_ref(page) == 1);
ffffffffc0203706:	00004697          	auipc	a3,0x4
ffffffffc020370a:	52268693          	addi	a3,a3,1314 # ffffffffc0207c28 <etext+0x13de>
ffffffffc020370e:	00003617          	auipc	a2,0x3
ffffffffc0203712:	7ba60613          	addi	a2,a2,1978 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0203716:	1e300593          	li	a1,483
ffffffffc020371a:	00004517          	auipc	a0,0x4
ffffffffc020371e:	fd650513          	addi	a0,a0,-42 # ffffffffc02076f0 <etext+0xea6>
ffffffffc0203722:	d53fc0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc0203726 <pa2page.part.0>:
pa2page(uintptr_t pa) {
ffffffffc0203726:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0203728:	00004617          	auipc	a2,0x4
ffffffffc020372c:	a7860613          	addi	a2,a2,-1416 # ffffffffc02071a0 <etext+0x956>
ffffffffc0203730:	06300593          	li	a1,99
ffffffffc0203734:	00004517          	auipc	a0,0x4
ffffffffc0203738:	a8c50513          	addi	a0,a0,-1396 # ffffffffc02071c0 <etext+0x976>
pa2page(uintptr_t pa) {
ffffffffc020373c:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc020373e:	d37fc0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc0203742 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc0203742:	7135                	addi	sp,sp,-160
ffffffffc0203744:	ed06                	sd	ra,152(sp)
     swapfs_init();
ffffffffc0203746:	72a010ef          	jal	ffffffffc0204e70 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc020374a:	0009b697          	auipc	a3,0x9b
ffffffffc020374e:	87e6b683          	ld	a3,-1922(a3) # ffffffffc029dfc8 <max_swap_offset>
ffffffffc0203752:	010007b7          	lui	a5,0x1000
ffffffffc0203756:	ff968713          	addi	a4,a3,-7
ffffffffc020375a:	17e1                	addi	a5,a5,-8 # fffff8 <_binary_obj___user_exit_out_size+0xff6458>
ffffffffc020375c:	44e7eb63          	bltu	a5,a4,ffffffffc0203bb2 <swap_init+0x470>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }
     

     sm = &swap_manager_fifo;
ffffffffc0203760:	0008f797          	auipc	a5,0x8f
ffffffffc0203764:	2f878793          	addi	a5,a5,760 # ffffffffc0292a58 <swap_manager_fifo>
     int r = sm->init();
ffffffffc0203768:	6798                	ld	a4,8(a5)
ffffffffc020376a:	e14a                	sd	s2,128(sp)
ffffffffc020376c:	f0da                	sd	s6,96(sp)
     sm = &swap_manager_fifo;
ffffffffc020376e:	0009bb17          	auipc	s6,0x9b
ffffffffc0203772:	862b0b13          	addi	s6,s6,-1950 # ffffffffc029dfd0 <sm>
ffffffffc0203776:	00fb3023          	sd	a5,0(s6)
     int r = sm->init();
ffffffffc020377a:	9702                	jalr	a4
ffffffffc020377c:	892a                	mv	s2,a0
     
     if (r == 0)
ffffffffc020377e:	c519                	beqz	a0,ffffffffc020378c <swap_init+0x4a>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc0203780:	60ea                	ld	ra,152(sp)
ffffffffc0203782:	7b06                	ld	s6,96(sp)
ffffffffc0203784:	854a                	mv	a0,s2
ffffffffc0203786:	690a                	ld	s2,128(sp)
ffffffffc0203788:	610d                	addi	sp,sp,160
ffffffffc020378a:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc020378c:	000b3783          	ld	a5,0(s6)
ffffffffc0203790:	00004517          	auipc	a0,0x4
ffffffffc0203794:	4e050513          	addi	a0,a0,1248 # ffffffffc0207c70 <etext+0x1426>
ffffffffc0203798:	e922                	sd	s0,144(sp)
ffffffffc020379a:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc020379c:	4785                	li	a5,1
ffffffffc020379e:	e0ea                	sd	s10,64(sp)
ffffffffc02037a0:	fc6e                	sd	s11,56(sp)
ffffffffc02037a2:	0009b717          	auipc	a4,0x9b
ffffffffc02037a6:	80f72f23          	sw	a5,-2018(a4) # ffffffffc029dfc0 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02037aa:	e526                	sd	s1,136(sp)
ffffffffc02037ac:	fcce                	sd	s3,120(sp)
ffffffffc02037ae:	f8d2                	sd	s4,112(sp)
ffffffffc02037b0:	f4d6                	sd	s5,104(sp)
ffffffffc02037b2:	ecde                	sd	s7,88(sp)
ffffffffc02037b4:	e8e2                	sd	s8,80(sp)
ffffffffc02037b6:	e4e6                	sd	s9,72(sp)
    return listelm->next;
ffffffffc02037b8:	00096417          	auipc	s0,0x96
ffffffffc02037bc:	6f040413          	addi	s0,s0,1776 # ffffffffc0299ea8 <free_area>
ffffffffc02037c0:	9c1fc0ef          	jal	ffffffffc0200180 <cprintf>
ffffffffc02037c4:	641c                	ld	a5,8(s0)

static void
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
ffffffffc02037c6:	4d81                	li	s11,0
ffffffffc02037c8:	4d01                	li	s10,0
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc02037ca:	36878463          	beq	a5,s0,ffffffffc0203b32 <swap_init+0x3f0>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02037ce:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc02037d2:	8b09                	andi	a4,a4,2
ffffffffc02037d4:	36070163          	beqz	a4,ffffffffc0203b36 <swap_init+0x3f4>
        count ++, total += p->property;
ffffffffc02037d8:	ff87a703          	lw	a4,-8(a5)
ffffffffc02037dc:	679c                	ld	a5,8(a5)
ffffffffc02037de:	2d05                	addiw	s10,s10,1
ffffffffc02037e0:	01b70dbb          	addw	s11,a4,s11
     while ((le = list_next(le)) != &free_list) {
ffffffffc02037e4:	fe8795e3          	bne	a5,s0,ffffffffc02037ce <swap_init+0x8c>
     }
     assert(total == nr_free_pages());
ffffffffc02037e8:	84ee                	mv	s1,s11
ffffffffc02037ea:	ae7fe0ef          	jal	ffffffffc02022d0 <nr_free_pages>
ffffffffc02037ee:	46951663          	bne	a0,s1,ffffffffc0203c5a <swap_init+0x518>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc02037f2:	866e                	mv	a2,s11
ffffffffc02037f4:	85ea                	mv	a1,s10
ffffffffc02037f6:	00004517          	auipc	a0,0x4
ffffffffc02037fa:	49250513          	addi	a0,a0,1170 # ffffffffc0207c88 <etext+0x143e>
ffffffffc02037fe:	983fc0ef          	jal	ffffffffc0200180 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0203802:	465000ef          	jal	ffffffffc0204466 <mm_create>
ffffffffc0203806:	e82a                	sd	a0,16(sp)
     assert(mm != NULL);
ffffffffc0203808:	4a050963          	beqz	a0,ffffffffc0203cba <swap_init+0x578>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc020380c:	0009a797          	auipc	a5,0x9a
ffffffffc0203810:	7d478793          	addi	a5,a5,2004 # ffffffffc029dfe0 <check_mm_struct>
ffffffffc0203814:	6398                	ld	a4,0(a5)
ffffffffc0203816:	42071263          	bnez	a4,ffffffffc0203c3a <swap_init+0x4f8>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020381a:	0009a717          	auipc	a4,0x9a
ffffffffc020381e:	78670713          	addi	a4,a4,1926 # ffffffffc029dfa0 <boot_pgdir>
ffffffffc0203822:	00073a83          	ld	s5,0(a4)
     check_mm_struct = mm;
ffffffffc0203826:	6742                	ld	a4,16(sp)
ffffffffc0203828:	e398                	sd	a4,0(a5)
     assert(pgdir[0] == 0);
ffffffffc020382a:	000ab783          	ld	a5,0(s5) # fffffffffffff000 <end+0x3fd60ff8>
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020382e:	01573c23          	sd	s5,24(a4)
     assert(pgdir[0] == 0);
ffffffffc0203832:	46079463          	bnez	a5,ffffffffc0203c9a <swap_init+0x558>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0203836:	6599                	lui	a1,0x6
ffffffffc0203838:	460d                	li	a2,3
ffffffffc020383a:	6505                	lui	a0,0x1
ffffffffc020383c:	473000ef          	jal	ffffffffc02044ae <vma_create>
ffffffffc0203840:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0203842:	56050863          	beqz	a0,ffffffffc0203db2 <swap_init+0x670>

     insert_vma_struct(mm, vma);
ffffffffc0203846:	64c2                	ld	s1,16(sp)
ffffffffc0203848:	8526                	mv	a0,s1
ffffffffc020384a:	4d3000ef          	jal	ffffffffc020451c <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc020384e:	00004517          	auipc	a0,0x4
ffffffffc0203852:	4aa50513          	addi	a0,a0,1194 # ffffffffc0207cf8 <etext+0x14ae>
ffffffffc0203856:	92bfc0ef          	jal	ffffffffc0200180 <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc020385a:	6c88                	ld	a0,24(s1)
ffffffffc020385c:	4605                	li	a2,1
ffffffffc020385e:	6585                	lui	a1,0x1
ffffffffc0203860:	aabfe0ef          	jal	ffffffffc020230a <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0203864:	50050763          	beqz	a0,ffffffffc0203d72 <swap_init+0x630>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0203868:	00004517          	auipc	a0,0x4
ffffffffc020386c:	4e050513          	addi	a0,a0,1248 # ffffffffc0207d48 <etext+0x14fe>
ffffffffc0203870:	00096497          	auipc	s1,0x96
ffffffffc0203874:	67048493          	addi	s1,s1,1648 # ffffffffc0299ee0 <check_rp>
ffffffffc0203878:	909fc0ef          	jal	ffffffffc0200180 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020387c:	00096997          	auipc	s3,0x96
ffffffffc0203880:	68498993          	addi	s3,s3,1668 # ffffffffc0299f00 <swap_out_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0203884:	8ba6                	mv	s7,s1
          check_rp[i] = alloc_page();
ffffffffc0203886:	4505                	li	a0,1
ffffffffc0203888:	979fe0ef          	jal	ffffffffc0202200 <alloc_pages>
ffffffffc020388c:	00abb023          	sd	a0,0(s7)
          assert(check_rp[i] != NULL );
ffffffffc0203890:	30050163          	beqz	a0,ffffffffc0203b92 <swap_init+0x450>
ffffffffc0203894:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0203896:	8b89                	andi	a5,a5,2
ffffffffc0203898:	38079163          	bnez	a5,ffffffffc0203c1a <swap_init+0x4d8>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020389c:	0ba1                	addi	s7,s7,8
ffffffffc020389e:	ff3b94e3          	bne	s7,s3,ffffffffc0203886 <swap_init+0x144>
     }
     list_entry_t free_list_store = free_list;
ffffffffc02038a2:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc02038a4:	00096b97          	auipc	s7,0x96
ffffffffc02038a8:	63cb8b93          	addi	s7,s7,1596 # ffffffffc0299ee0 <check_rp>
    elm->prev = elm->next = elm;
ffffffffc02038ac:	e000                	sd	s0,0(s0)
     list_entry_t free_list_store = free_list;
ffffffffc02038ae:	f43e                	sd	a5,40(sp)
ffffffffc02038b0:	641c                	ld	a5,8(s0)
ffffffffc02038b2:	e400                	sd	s0,8(s0)
ffffffffc02038b4:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc02038b6:	481c                	lw	a5,16(s0)
ffffffffc02038b8:	ec3e                	sd	a5,24(sp)
     nr_free = 0;
ffffffffc02038ba:	00096797          	auipc	a5,0x96
ffffffffc02038be:	5e07af23          	sw	zero,1534(a5) # ffffffffc0299eb8 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc02038c2:	000bb503          	ld	a0,0(s7)
ffffffffc02038c6:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02038c8:	0ba1                	addi	s7,s7,8
        free_pages(check_rp[i],1);
ffffffffc02038ca:	9c7fe0ef          	jal	ffffffffc0202290 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02038ce:	ff3b9ae3          	bne	s7,s3,ffffffffc02038c2 <swap_init+0x180>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc02038d2:	01042b83          	lw	s7,16(s0)
ffffffffc02038d6:	4791                	li	a5,4
ffffffffc02038d8:	46fb9d63          	bne	s7,a5,ffffffffc0203d52 <swap_init+0x610>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc02038dc:	00004517          	auipc	a0,0x4
ffffffffc02038e0:	4f450513          	addi	a0,a0,1268 # ffffffffc0207dd0 <etext+0x1586>
ffffffffc02038e4:	89dfc0ef          	jal	ffffffffc0200180 <cprintf>
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc02038e8:	0009a797          	auipc	a5,0x9a
ffffffffc02038ec:	6e07a823          	sw	zero,1776(a5) # ffffffffc029dfd8 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc02038f0:	6785                	lui	a5,0x1
ffffffffc02038f2:	4629                	li	a2,10
ffffffffc02038f4:	00c78023          	sb	a2,0(a5) # 1000 <_binary_obj___user_softint_out_size-0x7638>
     assert(pgfault_num==1);
ffffffffc02038f8:	0009a697          	auipc	a3,0x9a
ffffffffc02038fc:	6e06a683          	lw	a3,1760(a3) # ffffffffc029dfd8 <pgfault_num>
ffffffffc0203900:	4705                	li	a4,1
ffffffffc0203902:	0009a797          	auipc	a5,0x9a
ffffffffc0203906:	6d678793          	addi	a5,a5,1750 # ffffffffc029dfd8 <pgfault_num>
ffffffffc020390a:	58e69463          	bne	a3,a4,ffffffffc0203e92 <swap_init+0x750>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc020390e:	6705                	lui	a4,0x1
ffffffffc0203910:	00c70823          	sb	a2,16(a4) # 1010 <_binary_obj___user_softint_out_size-0x7628>
     assert(pgfault_num==1);
ffffffffc0203914:	4390                	lw	a2,0(a5)
ffffffffc0203916:	40d61e63          	bne	a2,a3,ffffffffc0203d32 <swap_init+0x5f0>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc020391a:	6709                	lui	a4,0x2
ffffffffc020391c:	46ad                	li	a3,11
ffffffffc020391e:	00d70023          	sb	a3,0(a4) # 2000 <_binary_obj___user_softint_out_size-0x6638>
     assert(pgfault_num==2);
ffffffffc0203922:	4398                	lw	a4,0(a5)
ffffffffc0203924:	4589                	li	a1,2
ffffffffc0203926:	0007061b          	sext.w	a2,a4
ffffffffc020392a:	4eb71463          	bne	a4,a1,ffffffffc0203e12 <swap_init+0x6d0>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc020392e:	6709                	lui	a4,0x2
ffffffffc0203930:	00d70823          	sb	a3,16(a4) # 2010 <_binary_obj___user_softint_out_size-0x6628>
     assert(pgfault_num==2);
ffffffffc0203934:	4394                	lw	a3,0(a5)
ffffffffc0203936:	4ec69e63          	bne	a3,a2,ffffffffc0203e32 <swap_init+0x6f0>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc020393a:	670d                	lui	a4,0x3
ffffffffc020393c:	46b1                	li	a3,12
ffffffffc020393e:	00d70023          	sb	a3,0(a4) # 3000 <_binary_obj___user_softint_out_size-0x5638>
     assert(pgfault_num==3);
ffffffffc0203942:	4398                	lw	a4,0(a5)
ffffffffc0203944:	458d                	li	a1,3
ffffffffc0203946:	0007061b          	sext.w	a2,a4
ffffffffc020394a:	50b71463          	bne	a4,a1,ffffffffc0203e52 <swap_init+0x710>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc020394e:	670d                	lui	a4,0x3
ffffffffc0203950:	00d70823          	sb	a3,16(a4) # 3010 <_binary_obj___user_softint_out_size-0x5628>
     assert(pgfault_num==3);
ffffffffc0203954:	4394                	lw	a3,0(a5)
ffffffffc0203956:	50c69e63          	bne	a3,a2,ffffffffc0203e72 <swap_init+0x730>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc020395a:	6711                	lui	a4,0x4
ffffffffc020395c:	46b5                	li	a3,13
ffffffffc020395e:	00d70023          	sb	a3,0(a4) # 4000 <_binary_obj___user_softint_out_size-0x4638>
     assert(pgfault_num==4);
ffffffffc0203962:	4398                	lw	a4,0(a5)
ffffffffc0203964:	0007061b          	sext.w	a2,a4
ffffffffc0203968:	47771563          	bne	a4,s7,ffffffffc0203dd2 <swap_init+0x690>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc020396c:	6711                	lui	a4,0x4
ffffffffc020396e:	00d70823          	sb	a3,16(a4) # 4010 <_binary_obj___user_softint_out_size-0x4628>
     assert(pgfault_num==4);
ffffffffc0203972:	439c                	lw	a5,0(a5)
ffffffffc0203974:	46c79f63          	bne	a5,a2,ffffffffc0203df2 <swap_init+0x6b0>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0203978:	481c                	lw	a5,16(s0)
ffffffffc020397a:	30079063          	bnez	a5,ffffffffc0203c7a <swap_init+0x538>
ffffffffc020397e:	00096797          	auipc	a5,0x96
ffffffffc0203982:	5aa78793          	addi	a5,a5,1450 # ffffffffc0299f28 <swap_in_seq_no>
ffffffffc0203986:	00096717          	auipc	a4,0x96
ffffffffc020398a:	57a70713          	addi	a4,a4,1402 # ffffffffc0299f00 <swap_out_seq_no>
ffffffffc020398e:	00096617          	auipc	a2,0x96
ffffffffc0203992:	5c260613          	addi	a2,a2,1474 # ffffffffc0299f50 <pra_list_head>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0203996:	56fd                	li	a3,-1
ffffffffc0203998:	c394                	sw	a3,0(a5)
ffffffffc020399a:	c314                	sw	a3,0(a4)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc020399c:	0791                	addi	a5,a5,4
ffffffffc020399e:	0711                	addi	a4,a4,4
ffffffffc02039a0:	fec79ce3          	bne	a5,a2,ffffffffc0203998 <swap_init+0x256>
ffffffffc02039a4:	00096717          	auipc	a4,0x96
ffffffffc02039a8:	51c70713          	addi	a4,a4,1308 # ffffffffc0299ec0 <check_ptep>
ffffffffc02039ac:	00096a17          	auipc	s4,0x96
ffffffffc02039b0:	534a0a13          	addi	s4,s4,1332 # ffffffffc0299ee0 <check_rp>
ffffffffc02039b4:	6585                	lui	a1,0x1
    if (PPN(pa) >= npage) {
ffffffffc02039b6:	0009ab97          	auipc	s7,0x9a
ffffffffc02039ba:	5fab8b93          	addi	s7,s7,1530 # ffffffffc029dfb0 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02039be:	0009ac17          	auipc	s8,0x9a
ffffffffc02039c2:	5fac0c13          	addi	s8,s8,1530 # ffffffffc029dfb8 <pages>
ffffffffc02039c6:	00005c97          	auipc	s9,0x5
ffffffffc02039ca:	58ac8c93          	addi	s9,s9,1418 # ffffffffc0208f50 <nbase>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc02039ce:	00073023          	sd	zero,0(a4)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc02039d2:	4601                	li	a2,0
ffffffffc02039d4:	8556                	mv	a0,s5
ffffffffc02039d6:	e42e                	sd	a1,8(sp)
         check_ptep[i]=0;
ffffffffc02039d8:	e03a                	sd	a4,0(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc02039da:	931fe0ef          	jal	ffffffffc020230a <get_pte>
ffffffffc02039de:	6702                	ld	a4,0(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc02039e0:	65a2                	ld	a1,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc02039e2:	e308                	sd	a0,0(a4)
         assert(check_ptep[i] != NULL);
ffffffffc02039e4:	1e050f63          	beqz	a0,ffffffffc0203be2 <swap_init+0x4a0>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc02039e8:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02039ea:	0017f613          	andi	a2,a5,1
ffffffffc02039ee:	20060a63          	beqz	a2,ffffffffc0203c02 <swap_init+0x4c0>
    if (PPN(pa) >= npage) {
ffffffffc02039f2:	000bb603          	ld	a2,0(s7)
    return pa2page(PTE_ADDR(pte));
ffffffffc02039f6:	078a                	slli	a5,a5,0x2
ffffffffc02039f8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02039fa:	16c7f063          	bgeu	a5,a2,ffffffffc0203b5a <swap_init+0x418>
    return &pages[PPN(pa) - nbase];
ffffffffc02039fe:	000cb303          	ld	t1,0(s9)
ffffffffc0203a02:	000c3603          	ld	a2,0(s8)
ffffffffc0203a06:	000a3503          	ld	a0,0(s4)
ffffffffc0203a0a:	406787b3          	sub	a5,a5,t1
ffffffffc0203a0e:	079a                	slli	a5,a5,0x6
ffffffffc0203a10:	6685                	lui	a3,0x1
ffffffffc0203a12:	97b2                	add	a5,a5,a2
ffffffffc0203a14:	0a21                	addi	s4,s4,8
ffffffffc0203a16:	0721                	addi	a4,a4,8
ffffffffc0203a18:	95b6                	add	a1,a1,a3
ffffffffc0203a1a:	14f51c63          	bne	a0,a5,ffffffffc0203b72 <swap_init+0x430>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203a1e:	6795                	lui	a5,0x5
ffffffffc0203a20:	faf597e3          	bne	a1,a5,ffffffffc02039ce <swap_init+0x28c>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0203a24:	00004517          	auipc	a0,0x4
ffffffffc0203a28:	45450513          	addi	a0,a0,1108 # ffffffffc0207e78 <etext+0x162e>
ffffffffc0203a2c:	f54fc0ef          	jal	ffffffffc0200180 <cprintf>
    int ret = sm->check_swap();
ffffffffc0203a30:	000b3783          	ld	a5,0(s6)
ffffffffc0203a34:	7f9c                	ld	a5,56(a5)
ffffffffc0203a36:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0203a38:	34051d63          	bnez	a0,ffffffffc0203d92 <swap_init+0x650>

     nr_free = nr_free_store;
ffffffffc0203a3c:	67e2                	ld	a5,24(sp)
ffffffffc0203a3e:	c81c                	sw	a5,16(s0)
     free_list = free_list_store;
ffffffffc0203a40:	77a2                	ld	a5,40(sp)
ffffffffc0203a42:	e01c                	sd	a5,0(s0)
ffffffffc0203a44:	7782                	ld	a5,32(sp)
ffffffffc0203a46:	e41c                	sd	a5,8(s0)

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0203a48:	6088                	ld	a0,0(s1)
ffffffffc0203a4a:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203a4c:	04a1                	addi	s1,s1,8
         free_pages(check_rp[i],1);
ffffffffc0203a4e:	843fe0ef          	jal	ffffffffc0202290 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203a52:	ff349be3          	bne	s1,s3,ffffffffc0203a48 <swap_init+0x306>
     } 

     //free_page(pte2page(*temp_ptep));

     mm->pgdir = NULL;
ffffffffc0203a56:	67c2                	ld	a5,16(sp)
ffffffffc0203a58:	0007bc23          	sd	zero,24(a5) # 5018 <_binary_obj___user_softint_out_size-0x3620>
     mm_destroy(mm);
ffffffffc0203a5c:	853e                	mv	a0,a5
ffffffffc0203a5e:	38f000ef          	jal	ffffffffc02045ec <mm_destroy>
     check_mm_struct = NULL;

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0203a62:	0009a797          	auipc	a5,0x9a
ffffffffc0203a66:	53e78793          	addi	a5,a5,1342 # ffffffffc029dfa0 <boot_pgdir>
ffffffffc0203a6a:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0203a6c:	000bb703          	ld	a4,0(s7)
     check_mm_struct = NULL;
ffffffffc0203a70:	0009a697          	auipc	a3,0x9a
ffffffffc0203a74:	5606b823          	sd	zero,1392(a3) # ffffffffc029dfe0 <check_mm_struct>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203a78:	639c                	ld	a5,0(a5)
ffffffffc0203a7a:	078a                	slli	a5,a5,0x2
ffffffffc0203a7c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203a7e:	0ce7fc63          	bgeu	a5,a4,ffffffffc0203b56 <swap_init+0x414>
    return &pages[PPN(pa) - nbase];
ffffffffc0203a82:	000cb483          	ld	s1,0(s9)
ffffffffc0203a86:	000c3503          	ld	a0,0(s8)
ffffffffc0203a8a:	409786b3          	sub	a3,a5,s1
ffffffffc0203a8e:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0203a90:	8699                	srai	a3,a3,0x6
ffffffffc0203a92:	96a6                	add	a3,a3,s1
    return KADDR(page2pa(page));
ffffffffc0203a94:	00c69793          	slli	a5,a3,0xc
ffffffffc0203a98:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203a9a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203a9c:	24e7ff63          	bgeu	a5,a4,ffffffffc0203cfa <swap_init+0x5b8>
     free_page(pde2page(pd0[0]));
ffffffffc0203aa0:	0009a797          	auipc	a5,0x9a
ffffffffc0203aa4:	5087b783          	ld	a5,1288(a5) # ffffffffc029dfa8 <va_pa_offset>
ffffffffc0203aa8:	97b6                	add	a5,a5,a3
    return pa2page(PDE_ADDR(pde));
ffffffffc0203aaa:	639c                	ld	a5,0(a5)
ffffffffc0203aac:	078a                	slli	a5,a5,0x2
ffffffffc0203aae:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203ab0:	0ae7f363          	bgeu	a5,a4,ffffffffc0203b56 <swap_init+0x414>
    return &pages[PPN(pa) - nbase];
ffffffffc0203ab4:	8f85                	sub	a5,a5,s1
ffffffffc0203ab6:	079a                	slli	a5,a5,0x6
ffffffffc0203ab8:	953e                	add	a0,a0,a5
ffffffffc0203aba:	4585                	li	a1,1
ffffffffc0203abc:	fd4fe0ef          	jal	ffffffffc0202290 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203ac0:	000ab783          	ld	a5,0(s5)
    if (PPN(pa) >= npage) {
ffffffffc0203ac4:	000bb703          	ld	a4,0(s7)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203ac8:	078a                	slli	a5,a5,0x2
ffffffffc0203aca:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203acc:	08e7f563          	bgeu	a5,a4,ffffffffc0203b56 <swap_init+0x414>
    return &pages[PPN(pa) - nbase];
ffffffffc0203ad0:	000c3503          	ld	a0,0(s8)
ffffffffc0203ad4:	8f85                	sub	a5,a5,s1
ffffffffc0203ad6:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc0203ad8:	4585                	li	a1,1
ffffffffc0203ada:	953e                	add	a0,a0,a5
ffffffffc0203adc:	fb4fe0ef          	jal	ffffffffc0202290 <free_pages>
     pgdir[0] = 0;
ffffffffc0203ae0:	000ab023          	sd	zero,0(s5)
  asm volatile("sfence.vma");
ffffffffc0203ae4:	12000073          	sfence.vma
    return listelm->next;
ffffffffc0203ae8:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203aea:	00878a63          	beq	a5,s0,ffffffffc0203afe <swap_init+0x3bc>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0203aee:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203af2:	679c                	ld	a5,8(a5)
ffffffffc0203af4:	3d7d                	addiw	s10,s10,-1
ffffffffc0203af6:	40ed8dbb          	subw	s11,s11,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203afa:	fe879ae3          	bne	a5,s0,ffffffffc0203aee <swap_init+0x3ac>
     }
     assert(count==0);
ffffffffc0203afe:	200d1a63          	bnez	s10,ffffffffc0203d12 <swap_init+0x5d0>
     assert(total==0);
ffffffffc0203b02:	1c0d9c63          	bnez	s11,ffffffffc0203cda <swap_init+0x598>

     cprintf("check_swap() succeeded!\n");
ffffffffc0203b06:	00004517          	auipc	a0,0x4
ffffffffc0203b0a:	3c250513          	addi	a0,a0,962 # ffffffffc0207ec8 <etext+0x167e>
ffffffffc0203b0e:	e72fc0ef          	jal	ffffffffc0200180 <cprintf>
}
ffffffffc0203b12:	60ea                	ld	ra,152(sp)
     cprintf("check_swap() succeeded!\n");
ffffffffc0203b14:	644a                	ld	s0,144(sp)
ffffffffc0203b16:	64aa                	ld	s1,136(sp)
ffffffffc0203b18:	79e6                	ld	s3,120(sp)
ffffffffc0203b1a:	7a46                	ld	s4,112(sp)
ffffffffc0203b1c:	7aa6                	ld	s5,104(sp)
ffffffffc0203b1e:	6be6                	ld	s7,88(sp)
ffffffffc0203b20:	6c46                	ld	s8,80(sp)
ffffffffc0203b22:	6ca6                	ld	s9,72(sp)
ffffffffc0203b24:	6d06                	ld	s10,64(sp)
ffffffffc0203b26:	7de2                	ld	s11,56(sp)
}
ffffffffc0203b28:	7b06                	ld	s6,96(sp)
ffffffffc0203b2a:	854a                	mv	a0,s2
ffffffffc0203b2c:	690a                	ld	s2,128(sp)
ffffffffc0203b2e:	610d                	addi	sp,sp,160
ffffffffc0203b30:	8082                	ret
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203b32:	4481                	li	s1,0
ffffffffc0203b34:	b95d                	j	ffffffffc02037ea <swap_init+0xa8>
        assert(PageProperty(p));
ffffffffc0203b36:	00003697          	auipc	a3,0x3
ffffffffc0203b3a:	7a268693          	addi	a3,a3,1954 # ffffffffc02072d8 <etext+0xa8e>
ffffffffc0203b3e:	00003617          	auipc	a2,0x3
ffffffffc0203b42:	38a60613          	addi	a2,a2,906 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0203b46:	0bc00593          	li	a1,188
ffffffffc0203b4a:	00004517          	auipc	a0,0x4
ffffffffc0203b4e:	11650513          	addi	a0,a0,278 # ffffffffc0207c60 <etext+0x1416>
ffffffffc0203b52:	923fc0ef          	jal	ffffffffc0200474 <__panic>
ffffffffc0203b56:	bd1ff0ef          	jal	ffffffffc0203726 <pa2page.part.0>
        panic("pa2page called with invalid pa");
ffffffffc0203b5a:	00003617          	auipc	a2,0x3
ffffffffc0203b5e:	64660613          	addi	a2,a2,1606 # ffffffffc02071a0 <etext+0x956>
ffffffffc0203b62:	06300593          	li	a1,99
ffffffffc0203b66:	00003517          	auipc	a0,0x3
ffffffffc0203b6a:	65a50513          	addi	a0,a0,1626 # ffffffffc02071c0 <etext+0x976>
ffffffffc0203b6e:	907fc0ef          	jal	ffffffffc0200474 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0203b72:	00004697          	auipc	a3,0x4
ffffffffc0203b76:	2de68693          	addi	a3,a3,734 # ffffffffc0207e50 <etext+0x1606>
ffffffffc0203b7a:	00003617          	auipc	a2,0x3
ffffffffc0203b7e:	34e60613          	addi	a2,a2,846 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0203b82:	0fc00593          	li	a1,252
ffffffffc0203b86:	00004517          	auipc	a0,0x4
ffffffffc0203b8a:	0da50513          	addi	a0,a0,218 # ffffffffc0207c60 <etext+0x1416>
ffffffffc0203b8e:	8e7fc0ef          	jal	ffffffffc0200474 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0203b92:	00004697          	auipc	a3,0x4
ffffffffc0203b96:	1de68693          	addi	a3,a3,478 # ffffffffc0207d70 <etext+0x1526>
ffffffffc0203b9a:	00003617          	auipc	a2,0x3
ffffffffc0203b9e:	32e60613          	addi	a2,a2,814 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0203ba2:	0dc00593          	li	a1,220
ffffffffc0203ba6:	00004517          	auipc	a0,0x4
ffffffffc0203baa:	0ba50513          	addi	a0,a0,186 # ffffffffc0207c60 <etext+0x1416>
ffffffffc0203bae:	8c7fc0ef          	jal	ffffffffc0200474 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0203bb2:	00004617          	auipc	a2,0x4
ffffffffc0203bb6:	08e60613          	addi	a2,a2,142 # ffffffffc0207c40 <etext+0x13f6>
ffffffffc0203bba:	02800593          	li	a1,40
ffffffffc0203bbe:	00004517          	auipc	a0,0x4
ffffffffc0203bc2:	0a250513          	addi	a0,a0,162 # ffffffffc0207c60 <etext+0x1416>
ffffffffc0203bc6:	e922                	sd	s0,144(sp)
ffffffffc0203bc8:	e526                	sd	s1,136(sp)
ffffffffc0203bca:	e14a                	sd	s2,128(sp)
ffffffffc0203bcc:	fcce                	sd	s3,120(sp)
ffffffffc0203bce:	f8d2                	sd	s4,112(sp)
ffffffffc0203bd0:	f4d6                	sd	s5,104(sp)
ffffffffc0203bd2:	f0da                	sd	s6,96(sp)
ffffffffc0203bd4:	ecde                	sd	s7,88(sp)
ffffffffc0203bd6:	e8e2                	sd	s8,80(sp)
ffffffffc0203bd8:	e4e6                	sd	s9,72(sp)
ffffffffc0203bda:	e0ea                	sd	s10,64(sp)
ffffffffc0203bdc:	fc6e                	sd	s11,56(sp)
ffffffffc0203bde:	897fc0ef          	jal	ffffffffc0200474 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0203be2:	00004697          	auipc	a3,0x4
ffffffffc0203be6:	25668693          	addi	a3,a3,598 # ffffffffc0207e38 <etext+0x15ee>
ffffffffc0203bea:	00003617          	auipc	a2,0x3
ffffffffc0203bee:	2de60613          	addi	a2,a2,734 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0203bf2:	0fb00593          	li	a1,251
ffffffffc0203bf6:	00004517          	auipc	a0,0x4
ffffffffc0203bfa:	06a50513          	addi	a0,a0,106 # ffffffffc0207c60 <etext+0x1416>
ffffffffc0203bfe:	877fc0ef          	jal	ffffffffc0200474 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0203c02:	00003617          	auipc	a2,0x3
ffffffffc0203c06:	69e60613          	addi	a2,a2,1694 # ffffffffc02072a0 <etext+0xa56>
ffffffffc0203c0a:	07500593          	li	a1,117
ffffffffc0203c0e:	00003517          	auipc	a0,0x3
ffffffffc0203c12:	5b250513          	addi	a0,a0,1458 # ffffffffc02071c0 <etext+0x976>
ffffffffc0203c16:	85ffc0ef          	jal	ffffffffc0200474 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0203c1a:	00004697          	auipc	a3,0x4
ffffffffc0203c1e:	16e68693          	addi	a3,a3,366 # ffffffffc0207d88 <etext+0x153e>
ffffffffc0203c22:	00003617          	auipc	a2,0x3
ffffffffc0203c26:	2a660613          	addi	a2,a2,678 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0203c2a:	0dd00593          	li	a1,221
ffffffffc0203c2e:	00004517          	auipc	a0,0x4
ffffffffc0203c32:	03250513          	addi	a0,a0,50 # ffffffffc0207c60 <etext+0x1416>
ffffffffc0203c36:	83ffc0ef          	jal	ffffffffc0200474 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0203c3a:	00004697          	auipc	a3,0x4
ffffffffc0203c3e:	08668693          	addi	a3,a3,134 # ffffffffc0207cc0 <etext+0x1476>
ffffffffc0203c42:	00003617          	auipc	a2,0x3
ffffffffc0203c46:	28660613          	addi	a2,a2,646 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0203c4a:	0c700593          	li	a1,199
ffffffffc0203c4e:	00004517          	auipc	a0,0x4
ffffffffc0203c52:	01250513          	addi	a0,a0,18 # ffffffffc0207c60 <etext+0x1416>
ffffffffc0203c56:	81ffc0ef          	jal	ffffffffc0200474 <__panic>
     assert(total == nr_free_pages());
ffffffffc0203c5a:	00003697          	auipc	a3,0x3
ffffffffc0203c5e:	6a668693          	addi	a3,a3,1702 # ffffffffc0207300 <etext+0xab6>
ffffffffc0203c62:	00003617          	auipc	a2,0x3
ffffffffc0203c66:	26660613          	addi	a2,a2,614 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0203c6a:	0bf00593          	li	a1,191
ffffffffc0203c6e:	00004517          	auipc	a0,0x4
ffffffffc0203c72:	ff250513          	addi	a0,a0,-14 # ffffffffc0207c60 <etext+0x1416>
ffffffffc0203c76:	ffefc0ef          	jal	ffffffffc0200474 <__panic>
     assert( nr_free == 0);         
ffffffffc0203c7a:	00004697          	auipc	a3,0x4
ffffffffc0203c7e:	82e68693          	addi	a3,a3,-2002 # ffffffffc02074a8 <etext+0xc5e>
ffffffffc0203c82:	00003617          	auipc	a2,0x3
ffffffffc0203c86:	24660613          	addi	a2,a2,582 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0203c8a:	0f300593          	li	a1,243
ffffffffc0203c8e:	00004517          	auipc	a0,0x4
ffffffffc0203c92:	fd250513          	addi	a0,a0,-46 # ffffffffc0207c60 <etext+0x1416>
ffffffffc0203c96:	fdefc0ef          	jal	ffffffffc0200474 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0203c9a:	00004697          	auipc	a3,0x4
ffffffffc0203c9e:	03e68693          	addi	a3,a3,62 # ffffffffc0207cd8 <etext+0x148e>
ffffffffc0203ca2:	00003617          	auipc	a2,0x3
ffffffffc0203ca6:	22660613          	addi	a2,a2,550 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0203caa:	0cc00593          	li	a1,204
ffffffffc0203cae:	00004517          	auipc	a0,0x4
ffffffffc0203cb2:	fb250513          	addi	a0,a0,-78 # ffffffffc0207c60 <etext+0x1416>
ffffffffc0203cb6:	fbefc0ef          	jal	ffffffffc0200474 <__panic>
     assert(mm != NULL);
ffffffffc0203cba:	00004697          	auipc	a3,0x4
ffffffffc0203cbe:	ff668693          	addi	a3,a3,-10 # ffffffffc0207cb0 <etext+0x1466>
ffffffffc0203cc2:	00003617          	auipc	a2,0x3
ffffffffc0203cc6:	20660613          	addi	a2,a2,518 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0203cca:	0c400593          	li	a1,196
ffffffffc0203cce:	00004517          	auipc	a0,0x4
ffffffffc0203cd2:	f9250513          	addi	a0,a0,-110 # ffffffffc0207c60 <etext+0x1416>
ffffffffc0203cd6:	f9efc0ef          	jal	ffffffffc0200474 <__panic>
     assert(total==0);
ffffffffc0203cda:	00004697          	auipc	a3,0x4
ffffffffc0203cde:	1de68693          	addi	a3,a3,478 # ffffffffc0207eb8 <etext+0x166e>
ffffffffc0203ce2:	00003617          	auipc	a2,0x3
ffffffffc0203ce6:	1e660613          	addi	a2,a2,486 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0203cea:	11e00593          	li	a1,286
ffffffffc0203cee:	00004517          	auipc	a0,0x4
ffffffffc0203cf2:	f7250513          	addi	a0,a0,-142 # ffffffffc0207c60 <etext+0x1416>
ffffffffc0203cf6:	f7efc0ef          	jal	ffffffffc0200474 <__panic>
    return KADDR(page2pa(page));
ffffffffc0203cfa:	00003617          	auipc	a2,0x3
ffffffffc0203cfe:	51660613          	addi	a2,a2,1302 # ffffffffc0207210 <etext+0x9c6>
ffffffffc0203d02:	06a00593          	li	a1,106
ffffffffc0203d06:	00003517          	auipc	a0,0x3
ffffffffc0203d0a:	4ba50513          	addi	a0,a0,1210 # ffffffffc02071c0 <etext+0x976>
ffffffffc0203d0e:	f66fc0ef          	jal	ffffffffc0200474 <__panic>
     assert(count==0);
ffffffffc0203d12:	00004697          	auipc	a3,0x4
ffffffffc0203d16:	19668693          	addi	a3,a3,406 # ffffffffc0207ea8 <etext+0x165e>
ffffffffc0203d1a:	00003617          	auipc	a2,0x3
ffffffffc0203d1e:	1ae60613          	addi	a2,a2,430 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0203d22:	11d00593          	li	a1,285
ffffffffc0203d26:	00004517          	auipc	a0,0x4
ffffffffc0203d2a:	f3a50513          	addi	a0,a0,-198 # ffffffffc0207c60 <etext+0x1416>
ffffffffc0203d2e:	f46fc0ef          	jal	ffffffffc0200474 <__panic>
     assert(pgfault_num==1);
ffffffffc0203d32:	00004697          	auipc	a3,0x4
ffffffffc0203d36:	0c668693          	addi	a3,a3,198 # ffffffffc0207df8 <etext+0x15ae>
ffffffffc0203d3a:	00003617          	auipc	a2,0x3
ffffffffc0203d3e:	18e60613          	addi	a2,a2,398 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0203d42:	09500593          	li	a1,149
ffffffffc0203d46:	00004517          	auipc	a0,0x4
ffffffffc0203d4a:	f1a50513          	addi	a0,a0,-230 # ffffffffc0207c60 <etext+0x1416>
ffffffffc0203d4e:	f26fc0ef          	jal	ffffffffc0200474 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0203d52:	00004697          	auipc	a3,0x4
ffffffffc0203d56:	05668693          	addi	a3,a3,86 # ffffffffc0207da8 <etext+0x155e>
ffffffffc0203d5a:	00003617          	auipc	a2,0x3
ffffffffc0203d5e:	16e60613          	addi	a2,a2,366 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0203d62:	0ea00593          	li	a1,234
ffffffffc0203d66:	00004517          	auipc	a0,0x4
ffffffffc0203d6a:	efa50513          	addi	a0,a0,-262 # ffffffffc0207c60 <etext+0x1416>
ffffffffc0203d6e:	f06fc0ef          	jal	ffffffffc0200474 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0203d72:	00004697          	auipc	a3,0x4
ffffffffc0203d76:	fbe68693          	addi	a3,a3,-66 # ffffffffc0207d30 <etext+0x14e6>
ffffffffc0203d7a:	00003617          	auipc	a2,0x3
ffffffffc0203d7e:	14e60613          	addi	a2,a2,334 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0203d82:	0d700593          	li	a1,215
ffffffffc0203d86:	00004517          	auipc	a0,0x4
ffffffffc0203d8a:	eda50513          	addi	a0,a0,-294 # ffffffffc0207c60 <etext+0x1416>
ffffffffc0203d8e:	ee6fc0ef          	jal	ffffffffc0200474 <__panic>
     assert(ret==0);
ffffffffc0203d92:	00004697          	auipc	a3,0x4
ffffffffc0203d96:	10e68693          	addi	a3,a3,270 # ffffffffc0207ea0 <etext+0x1656>
ffffffffc0203d9a:	00003617          	auipc	a2,0x3
ffffffffc0203d9e:	12e60613          	addi	a2,a2,302 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0203da2:	10200593          	li	a1,258
ffffffffc0203da6:	00004517          	auipc	a0,0x4
ffffffffc0203daa:	eba50513          	addi	a0,a0,-326 # ffffffffc0207c60 <etext+0x1416>
ffffffffc0203dae:	ec6fc0ef          	jal	ffffffffc0200474 <__panic>
     assert(vma != NULL);
ffffffffc0203db2:	00004697          	auipc	a3,0x4
ffffffffc0203db6:	f3668693          	addi	a3,a3,-202 # ffffffffc0207ce8 <etext+0x149e>
ffffffffc0203dba:	00003617          	auipc	a2,0x3
ffffffffc0203dbe:	10e60613          	addi	a2,a2,270 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0203dc2:	0cf00593          	li	a1,207
ffffffffc0203dc6:	00004517          	auipc	a0,0x4
ffffffffc0203dca:	e9a50513          	addi	a0,a0,-358 # ffffffffc0207c60 <etext+0x1416>
ffffffffc0203dce:	ea6fc0ef          	jal	ffffffffc0200474 <__panic>
     assert(pgfault_num==4);
ffffffffc0203dd2:	00004697          	auipc	a3,0x4
ffffffffc0203dd6:	05668693          	addi	a3,a3,86 # ffffffffc0207e28 <etext+0x15de>
ffffffffc0203dda:	00003617          	auipc	a2,0x3
ffffffffc0203dde:	0ee60613          	addi	a2,a2,238 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0203de2:	09f00593          	li	a1,159
ffffffffc0203de6:	00004517          	auipc	a0,0x4
ffffffffc0203dea:	e7a50513          	addi	a0,a0,-390 # ffffffffc0207c60 <etext+0x1416>
ffffffffc0203dee:	e86fc0ef          	jal	ffffffffc0200474 <__panic>
     assert(pgfault_num==4);
ffffffffc0203df2:	00004697          	auipc	a3,0x4
ffffffffc0203df6:	03668693          	addi	a3,a3,54 # ffffffffc0207e28 <etext+0x15de>
ffffffffc0203dfa:	00003617          	auipc	a2,0x3
ffffffffc0203dfe:	0ce60613          	addi	a2,a2,206 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0203e02:	0a100593          	li	a1,161
ffffffffc0203e06:	00004517          	auipc	a0,0x4
ffffffffc0203e0a:	e5a50513          	addi	a0,a0,-422 # ffffffffc0207c60 <etext+0x1416>
ffffffffc0203e0e:	e66fc0ef          	jal	ffffffffc0200474 <__panic>
     assert(pgfault_num==2);
ffffffffc0203e12:	00004697          	auipc	a3,0x4
ffffffffc0203e16:	ff668693          	addi	a3,a3,-10 # ffffffffc0207e08 <etext+0x15be>
ffffffffc0203e1a:	00003617          	auipc	a2,0x3
ffffffffc0203e1e:	0ae60613          	addi	a2,a2,174 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0203e22:	09700593          	li	a1,151
ffffffffc0203e26:	00004517          	auipc	a0,0x4
ffffffffc0203e2a:	e3a50513          	addi	a0,a0,-454 # ffffffffc0207c60 <etext+0x1416>
ffffffffc0203e2e:	e46fc0ef          	jal	ffffffffc0200474 <__panic>
     assert(pgfault_num==2);
ffffffffc0203e32:	00004697          	auipc	a3,0x4
ffffffffc0203e36:	fd668693          	addi	a3,a3,-42 # ffffffffc0207e08 <etext+0x15be>
ffffffffc0203e3a:	00003617          	auipc	a2,0x3
ffffffffc0203e3e:	08e60613          	addi	a2,a2,142 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0203e42:	09900593          	li	a1,153
ffffffffc0203e46:	00004517          	auipc	a0,0x4
ffffffffc0203e4a:	e1a50513          	addi	a0,a0,-486 # ffffffffc0207c60 <etext+0x1416>
ffffffffc0203e4e:	e26fc0ef          	jal	ffffffffc0200474 <__panic>
     assert(pgfault_num==3);
ffffffffc0203e52:	00004697          	auipc	a3,0x4
ffffffffc0203e56:	fc668693          	addi	a3,a3,-58 # ffffffffc0207e18 <etext+0x15ce>
ffffffffc0203e5a:	00003617          	auipc	a2,0x3
ffffffffc0203e5e:	06e60613          	addi	a2,a2,110 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0203e62:	09b00593          	li	a1,155
ffffffffc0203e66:	00004517          	auipc	a0,0x4
ffffffffc0203e6a:	dfa50513          	addi	a0,a0,-518 # ffffffffc0207c60 <etext+0x1416>
ffffffffc0203e6e:	e06fc0ef          	jal	ffffffffc0200474 <__panic>
     assert(pgfault_num==3);
ffffffffc0203e72:	00004697          	auipc	a3,0x4
ffffffffc0203e76:	fa668693          	addi	a3,a3,-90 # ffffffffc0207e18 <etext+0x15ce>
ffffffffc0203e7a:	00003617          	auipc	a2,0x3
ffffffffc0203e7e:	04e60613          	addi	a2,a2,78 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0203e82:	09d00593          	li	a1,157
ffffffffc0203e86:	00004517          	auipc	a0,0x4
ffffffffc0203e8a:	dda50513          	addi	a0,a0,-550 # ffffffffc0207c60 <etext+0x1416>
ffffffffc0203e8e:	de6fc0ef          	jal	ffffffffc0200474 <__panic>
     assert(pgfault_num==1);
ffffffffc0203e92:	00004697          	auipc	a3,0x4
ffffffffc0203e96:	f6668693          	addi	a3,a3,-154 # ffffffffc0207df8 <etext+0x15ae>
ffffffffc0203e9a:	00003617          	auipc	a2,0x3
ffffffffc0203e9e:	02e60613          	addi	a2,a2,46 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0203ea2:	09300593          	li	a1,147
ffffffffc0203ea6:	00004517          	auipc	a0,0x4
ffffffffc0203eaa:	dba50513          	addi	a0,a0,-582 # ffffffffc0207c60 <etext+0x1416>
ffffffffc0203eae:	dc6fc0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc0203eb2 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0203eb2:	0009a797          	auipc	a5,0x9a
ffffffffc0203eb6:	11e7b783          	ld	a5,286(a5) # ffffffffc029dfd0 <sm>
ffffffffc0203eba:	6b9c                	ld	a5,16(a5)
ffffffffc0203ebc:	8782                	jr	a5

ffffffffc0203ebe <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0203ebe:	0009a797          	auipc	a5,0x9a
ffffffffc0203ec2:	1127b783          	ld	a5,274(a5) # ffffffffc029dfd0 <sm>
ffffffffc0203ec6:	739c                	ld	a5,32(a5)
ffffffffc0203ec8:	8782                	jr	a5

ffffffffc0203eca <swap_out>:
{
ffffffffc0203eca:	711d                	addi	sp,sp,-96
ffffffffc0203ecc:	ec86                	sd	ra,88(sp)
ffffffffc0203ece:	e8a2                	sd	s0,80(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0203ed0:	0e058663          	beqz	a1,ffffffffc0203fbc <swap_out+0xf2>
ffffffffc0203ed4:	e0ca                	sd	s2,64(sp)
ffffffffc0203ed6:	fc4e                	sd	s3,56(sp)
ffffffffc0203ed8:	f852                	sd	s4,48(sp)
ffffffffc0203eda:	f456                	sd	s5,40(sp)
ffffffffc0203edc:	f05a                	sd	s6,32(sp)
ffffffffc0203ede:	ec5e                	sd	s7,24(sp)
ffffffffc0203ee0:	e4a6                	sd	s1,72(sp)
ffffffffc0203ee2:	e862                	sd	s8,16(sp)
ffffffffc0203ee4:	8a2e                	mv	s4,a1
ffffffffc0203ee6:	892a                	mv	s2,a0
ffffffffc0203ee8:	8ab2                	mv	s5,a2
ffffffffc0203eea:	4401                	li	s0,0
ffffffffc0203eec:	0009a997          	auipc	s3,0x9a
ffffffffc0203ef0:	0e498993          	addi	s3,s3,228 # ffffffffc029dfd0 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203ef4:	00004b17          	auipc	s6,0x4
ffffffffc0203ef8:	054b0b13          	addi	s6,s6,84 # ffffffffc0207f48 <etext+0x16fe>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203efc:	00004b97          	auipc	s7,0x4
ffffffffc0203f00:	034b8b93          	addi	s7,s7,52 # ffffffffc0207f30 <etext+0x16e6>
ffffffffc0203f04:	a825                	j	ffffffffc0203f3c <swap_out+0x72>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203f06:	67a2                	ld	a5,8(sp)
ffffffffc0203f08:	8626                	mv	a2,s1
ffffffffc0203f0a:	85a2                	mv	a1,s0
ffffffffc0203f0c:	7f94                	ld	a3,56(a5)
ffffffffc0203f0e:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0203f10:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203f12:	82b1                	srli	a3,a3,0xc
ffffffffc0203f14:	0685                	addi	a3,a3,1
ffffffffc0203f16:	a6afc0ef          	jal	ffffffffc0200180 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203f1a:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0203f1c:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203f1e:	7d1c                	ld	a5,56(a0)
ffffffffc0203f20:	83b1                	srli	a5,a5,0xc
ffffffffc0203f22:	0785                	addi	a5,a5,1
ffffffffc0203f24:	07a2                	slli	a5,a5,0x8
ffffffffc0203f26:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0203f2a:	b66fe0ef          	jal	ffffffffc0202290 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0203f2e:	01893503          	ld	a0,24(s2)
ffffffffc0203f32:	85a6                	mv	a1,s1
ffffffffc0203f34:	f32ff0ef          	jal	ffffffffc0203666 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0203f38:	048a0d63          	beq	s4,s0,ffffffffc0203f92 <swap_out+0xc8>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0203f3c:	0009b783          	ld	a5,0(s3)
ffffffffc0203f40:	8656                	mv	a2,s5
ffffffffc0203f42:	002c                	addi	a1,sp,8
ffffffffc0203f44:	7b9c                	ld	a5,48(a5)
ffffffffc0203f46:	854a                	mv	a0,s2
ffffffffc0203f48:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0203f4a:	e12d                	bnez	a0,ffffffffc0203fac <swap_out+0xe2>
          v=page->pra_vaddr; 
ffffffffc0203f4c:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203f4e:	01893503          	ld	a0,24(s2)
ffffffffc0203f52:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0203f54:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203f56:	85a6                	mv	a1,s1
ffffffffc0203f58:	bb2fe0ef          	jal	ffffffffc020230a <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203f5c:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203f5e:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0203f60:	8b85                	andi	a5,a5,1
ffffffffc0203f62:	cfb9                	beqz	a5,ffffffffc0203fc0 <swap_out+0xf6>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0203f64:	65a2                	ld	a1,8(sp)
ffffffffc0203f66:	7d9c                	ld	a5,56(a1)
ffffffffc0203f68:	83b1                	srli	a5,a5,0xc
ffffffffc0203f6a:	0785                	addi	a5,a5,1
ffffffffc0203f6c:	00879513          	slli	a0,a5,0x8
ffffffffc0203f70:	7c7000ef          	jal	ffffffffc0204f36 <swapfs_write>
ffffffffc0203f74:	d949                	beqz	a0,ffffffffc0203f06 <swap_out+0x3c>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203f76:	855e                	mv	a0,s7
ffffffffc0203f78:	a08fc0ef          	jal	ffffffffc0200180 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203f7c:	0009b783          	ld	a5,0(s3)
ffffffffc0203f80:	6622                	ld	a2,8(sp)
ffffffffc0203f82:	4681                	li	a3,0
ffffffffc0203f84:	739c                	ld	a5,32(a5)
ffffffffc0203f86:	85a6                	mv	a1,s1
ffffffffc0203f88:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0203f8a:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203f8c:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0203f8e:	fa8a17e3          	bne	s4,s0,ffffffffc0203f3c <swap_out+0x72>
ffffffffc0203f92:	64a6                	ld	s1,72(sp)
ffffffffc0203f94:	6906                	ld	s2,64(sp)
ffffffffc0203f96:	79e2                	ld	s3,56(sp)
ffffffffc0203f98:	7a42                	ld	s4,48(sp)
ffffffffc0203f9a:	7aa2                	ld	s5,40(sp)
ffffffffc0203f9c:	7b02                	ld	s6,32(sp)
ffffffffc0203f9e:	6be2                	ld	s7,24(sp)
ffffffffc0203fa0:	6c42                	ld	s8,16(sp)
}
ffffffffc0203fa2:	60e6                	ld	ra,88(sp)
ffffffffc0203fa4:	8522                	mv	a0,s0
ffffffffc0203fa6:	6446                	ld	s0,80(sp)
ffffffffc0203fa8:	6125                	addi	sp,sp,96
ffffffffc0203faa:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0203fac:	85a2                	mv	a1,s0
ffffffffc0203fae:	00004517          	auipc	a0,0x4
ffffffffc0203fb2:	f3a50513          	addi	a0,a0,-198 # ffffffffc0207ee8 <etext+0x169e>
ffffffffc0203fb6:	9cafc0ef          	jal	ffffffffc0200180 <cprintf>
                  break;
ffffffffc0203fba:	bfe1                	j	ffffffffc0203f92 <swap_out+0xc8>
     for (i = 0; i != n; ++ i)
ffffffffc0203fbc:	4401                	li	s0,0
ffffffffc0203fbe:	b7d5                	j	ffffffffc0203fa2 <swap_out+0xd8>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203fc0:	00004697          	auipc	a3,0x4
ffffffffc0203fc4:	f5868693          	addi	a3,a3,-168 # ffffffffc0207f18 <etext+0x16ce>
ffffffffc0203fc8:	00003617          	auipc	a2,0x3
ffffffffc0203fcc:	f0060613          	addi	a2,a2,-256 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0203fd0:	06800593          	li	a1,104
ffffffffc0203fd4:	00004517          	auipc	a0,0x4
ffffffffc0203fd8:	c8c50513          	addi	a0,a0,-884 # ffffffffc0207c60 <etext+0x1416>
ffffffffc0203fdc:	c98fc0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc0203fe0 <swap_in>:
{
ffffffffc0203fe0:	7179                	addi	sp,sp,-48
ffffffffc0203fe2:	e84a                	sd	s2,16(sp)
ffffffffc0203fe4:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0203fe6:	4505                	li	a0,1
{
ffffffffc0203fe8:	ec26                	sd	s1,24(sp)
ffffffffc0203fea:	e44e                	sd	s3,8(sp)
ffffffffc0203fec:	f406                	sd	ra,40(sp)
ffffffffc0203fee:	f022                	sd	s0,32(sp)
ffffffffc0203ff0:	84ae                	mv	s1,a1
ffffffffc0203ff2:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0203ff4:	a0cfe0ef          	jal	ffffffffc0202200 <alloc_pages>
     assert(result!=NULL);
ffffffffc0203ff8:	c129                	beqz	a0,ffffffffc020403a <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0203ffa:	842a                	mv	s0,a0
ffffffffc0203ffc:	01893503          	ld	a0,24(s2)
ffffffffc0204000:	4601                	li	a2,0
ffffffffc0204002:	85a6                	mv	a1,s1
ffffffffc0204004:	b06fe0ef          	jal	ffffffffc020230a <get_pte>
ffffffffc0204008:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc020400a:	6108                	ld	a0,0(a0)
ffffffffc020400c:	85a2                	mv	a1,s0
ffffffffc020400e:	69b000ef          	jal	ffffffffc0204ea8 <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0204012:	00093583          	ld	a1,0(s2)
ffffffffc0204016:	8626                	mv	a2,s1
ffffffffc0204018:	00004517          	auipc	a0,0x4
ffffffffc020401c:	f8050513          	addi	a0,a0,-128 # ffffffffc0207f98 <etext+0x174e>
ffffffffc0204020:	81a1                	srli	a1,a1,0x8
ffffffffc0204022:	95efc0ef          	jal	ffffffffc0200180 <cprintf>
}
ffffffffc0204026:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0204028:	0089b023          	sd	s0,0(s3)
}
ffffffffc020402c:	7402                	ld	s0,32(sp)
ffffffffc020402e:	64e2                	ld	s1,24(sp)
ffffffffc0204030:	6942                	ld	s2,16(sp)
ffffffffc0204032:	69a2                	ld	s3,8(sp)
ffffffffc0204034:	4501                	li	a0,0
ffffffffc0204036:	6145                	addi	sp,sp,48
ffffffffc0204038:	8082                	ret
     assert(result!=NULL);
ffffffffc020403a:	00004697          	auipc	a3,0x4
ffffffffc020403e:	f4e68693          	addi	a3,a3,-178 # ffffffffc0207f88 <etext+0x173e>
ffffffffc0204042:	00003617          	auipc	a2,0x3
ffffffffc0204046:	e8660613          	addi	a2,a2,-378 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc020404a:	07e00593          	li	a1,126
ffffffffc020404e:	00004517          	auipc	a0,0x4
ffffffffc0204052:	c1250513          	addi	a0,a0,-1006 # ffffffffc0207c60 <etext+0x1416>
ffffffffc0204056:	c1efc0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc020405a <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc020405a:	00096797          	auipc	a5,0x96
ffffffffc020405e:	ef678793          	addi	a5,a5,-266 # ffffffffc0299f50 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc0204062:	f51c                	sd	a5,40(a0)
ffffffffc0204064:	e79c                	sd	a5,8(a5)
ffffffffc0204066:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc0204068:	4501                	li	a0,0
ffffffffc020406a:	8082                	ret

ffffffffc020406c <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc020406c:	4501                	li	a0,0
ffffffffc020406e:	8082                	ret

ffffffffc0204070 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0204070:	4501                	li	a0,0
ffffffffc0204072:	8082                	ret

ffffffffc0204074 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc0204074:	4501                	li	a0,0
ffffffffc0204076:	8082                	ret

ffffffffc0204078 <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc0204078:	711d                	addi	sp,sp,-96
ffffffffc020407a:	fc4e                	sd	s3,56(sp)
ffffffffc020407c:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc020407e:	00004517          	auipc	a0,0x4
ffffffffc0204082:	f5a50513          	addi	a0,a0,-166 # ffffffffc0207fd8 <etext+0x178e>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0204086:	698d                	lui	s3,0x3
ffffffffc0204088:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc020408a:	e4a6                	sd	s1,72(sp)
ffffffffc020408c:	ec86                	sd	ra,88(sp)
ffffffffc020408e:	e8a2                	sd	s0,80(sp)
ffffffffc0204090:	e0ca                	sd	s2,64(sp)
ffffffffc0204092:	f456                	sd	s5,40(sp)
ffffffffc0204094:	f05a                	sd	s6,32(sp)
ffffffffc0204096:	ec5e                	sd	s7,24(sp)
ffffffffc0204098:	e862                	sd	s8,16(sp)
ffffffffc020409a:	e466                	sd	s9,8(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc020409c:	8e4fc0ef          	jal	ffffffffc0200180 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02040a0:	01498023          	sb	s4,0(s3) # 3000 <_binary_obj___user_softint_out_size-0x5638>
    assert(pgfault_num==4);
ffffffffc02040a4:	0009a497          	auipc	s1,0x9a
ffffffffc02040a8:	f344a483          	lw	s1,-204(s1) # ffffffffc029dfd8 <pgfault_num>
ffffffffc02040ac:	4791                	li	a5,4
ffffffffc02040ae:	14f49963          	bne	s1,a5,ffffffffc0204200 <_fifo_check_swap+0x188>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc02040b2:	00004517          	auipc	a0,0x4
ffffffffc02040b6:	f6650513          	addi	a0,a0,-154 # ffffffffc0208018 <etext+0x17ce>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02040ba:	6a85                	lui	s5,0x1
ffffffffc02040bc:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc02040be:	8c2fc0ef          	jal	ffffffffc0200180 <cprintf>
ffffffffc02040c2:	0009a417          	auipc	s0,0x9a
ffffffffc02040c6:	f1640413          	addi	s0,s0,-234 # ffffffffc029dfd8 <pgfault_num>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02040ca:	016a8023          	sb	s6,0(s5) # 1000 <_binary_obj___user_softint_out_size-0x7638>
    assert(pgfault_num==4);
ffffffffc02040ce:	401c                	lw	a5,0(s0)
ffffffffc02040d0:	0007891b          	sext.w	s2,a5
ffffffffc02040d4:	2a979663          	bne	a5,s1,ffffffffc0204380 <_fifo_check_swap+0x308>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc02040d8:	00004517          	auipc	a0,0x4
ffffffffc02040dc:	f6850513          	addi	a0,a0,-152 # ffffffffc0208040 <etext+0x17f6>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02040e0:	6b91                	lui	s7,0x4
ffffffffc02040e2:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc02040e4:	89cfc0ef          	jal	ffffffffc0200180 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02040e8:	018b8023          	sb	s8,0(s7) # 4000 <_binary_obj___user_softint_out_size-0x4638>
    assert(pgfault_num==4);
ffffffffc02040ec:	401c                	lw	a5,0(s0)
ffffffffc02040ee:	00078c9b          	sext.w	s9,a5
ffffffffc02040f2:	27279763          	bne	a5,s2,ffffffffc0204360 <_fifo_check_swap+0x2e8>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc02040f6:	00004517          	auipc	a0,0x4
ffffffffc02040fa:	f7250513          	addi	a0,a0,-142 # ffffffffc0208068 <etext+0x181e>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02040fe:	6489                	lui	s1,0x2
ffffffffc0204100:	492d                	li	s2,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0204102:	87efc0ef          	jal	ffffffffc0200180 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0204106:	01248023          	sb	s2,0(s1) # 2000 <_binary_obj___user_softint_out_size-0x6638>
    assert(pgfault_num==4);
ffffffffc020410a:	401c                	lw	a5,0(s0)
ffffffffc020410c:	23979a63          	bne	a5,s9,ffffffffc0204340 <_fifo_check_swap+0x2c8>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0204110:	00004517          	auipc	a0,0x4
ffffffffc0204114:	f8050513          	addi	a0,a0,-128 # ffffffffc0208090 <etext+0x1846>
ffffffffc0204118:	868fc0ef          	jal	ffffffffc0200180 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc020411c:	6795                	lui	a5,0x5
ffffffffc020411e:	4739                	li	a4,14
ffffffffc0204120:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_softint_out_size-0x3638>
    assert(pgfault_num==5);
ffffffffc0204124:	401c                	lw	a5,0(s0)
ffffffffc0204126:	4715                	li	a4,5
ffffffffc0204128:	00078c9b          	sext.w	s9,a5
ffffffffc020412c:	1ee79a63          	bne	a5,a4,ffffffffc0204320 <_fifo_check_swap+0x2a8>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0204130:	00004517          	auipc	a0,0x4
ffffffffc0204134:	f3850513          	addi	a0,a0,-200 # ffffffffc0208068 <etext+0x181e>
ffffffffc0204138:	848fc0ef          	jal	ffffffffc0200180 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc020413c:	01248023          	sb	s2,0(s1)
    assert(pgfault_num==5);
ffffffffc0204140:	401c                	lw	a5,0(s0)
ffffffffc0204142:	1b979f63          	bne	a5,s9,ffffffffc0204300 <_fifo_check_swap+0x288>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0204146:	00004517          	auipc	a0,0x4
ffffffffc020414a:	ed250513          	addi	a0,a0,-302 # ffffffffc0208018 <etext+0x17ce>
ffffffffc020414e:	832fc0ef          	jal	ffffffffc0200180 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0204152:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc0204156:	4018                	lw	a4,0(s0)
ffffffffc0204158:	4799                	li	a5,6
ffffffffc020415a:	18f71363          	bne	a4,a5,ffffffffc02042e0 <_fifo_check_swap+0x268>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc020415e:	00004517          	auipc	a0,0x4
ffffffffc0204162:	f0a50513          	addi	a0,a0,-246 # ffffffffc0208068 <etext+0x181e>
ffffffffc0204166:	81afc0ef          	jal	ffffffffc0200180 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc020416a:	01248023          	sb	s2,0(s1)
    assert(pgfault_num==7);
ffffffffc020416e:	4018                	lw	a4,0(s0)
ffffffffc0204170:	479d                	li	a5,7
ffffffffc0204172:	14f71763          	bne	a4,a5,ffffffffc02042c0 <_fifo_check_swap+0x248>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0204176:	00004517          	auipc	a0,0x4
ffffffffc020417a:	e6250513          	addi	a0,a0,-414 # ffffffffc0207fd8 <etext+0x178e>
ffffffffc020417e:	802fc0ef          	jal	ffffffffc0200180 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0204182:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc0204186:	4018                	lw	a4,0(s0)
ffffffffc0204188:	47a1                	li	a5,8
ffffffffc020418a:	10f71b63          	bne	a4,a5,ffffffffc02042a0 <_fifo_check_swap+0x228>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc020418e:	00004517          	auipc	a0,0x4
ffffffffc0204192:	eb250513          	addi	a0,a0,-334 # ffffffffc0208040 <etext+0x17f6>
ffffffffc0204196:	febfb0ef          	jal	ffffffffc0200180 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc020419a:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc020419e:	4018                	lw	a4,0(s0)
ffffffffc02041a0:	47a5                	li	a5,9
ffffffffc02041a2:	0cf71f63          	bne	a4,a5,ffffffffc0204280 <_fifo_check_swap+0x208>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc02041a6:	00004517          	auipc	a0,0x4
ffffffffc02041aa:	eea50513          	addi	a0,a0,-278 # ffffffffc0208090 <etext+0x1846>
ffffffffc02041ae:	fd3fb0ef          	jal	ffffffffc0200180 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc02041b2:	6795                	lui	a5,0x5
ffffffffc02041b4:	4739                	li	a4,14
ffffffffc02041b6:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_softint_out_size-0x3638>
    assert(pgfault_num==10);
ffffffffc02041ba:	401c                	lw	a5,0(s0)
ffffffffc02041bc:	4729                	li	a4,10
ffffffffc02041be:	0007849b          	sext.w	s1,a5
ffffffffc02041c2:	08e79f63          	bne	a5,a4,ffffffffc0204260 <_fifo_check_swap+0x1e8>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc02041c6:	00004517          	auipc	a0,0x4
ffffffffc02041ca:	e5250513          	addi	a0,a0,-430 # ffffffffc0208018 <etext+0x17ce>
ffffffffc02041ce:	fb3fb0ef          	jal	ffffffffc0200180 <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc02041d2:	6785                	lui	a5,0x1
ffffffffc02041d4:	0007c783          	lbu	a5,0(a5) # 1000 <_binary_obj___user_softint_out_size-0x7638>
ffffffffc02041d8:	06979463          	bne	a5,s1,ffffffffc0204240 <_fifo_check_swap+0x1c8>
    assert(pgfault_num==11);
ffffffffc02041dc:	4018                	lw	a4,0(s0)
ffffffffc02041de:	47ad                	li	a5,11
ffffffffc02041e0:	04f71063          	bne	a4,a5,ffffffffc0204220 <_fifo_check_swap+0x1a8>
}
ffffffffc02041e4:	60e6                	ld	ra,88(sp)
ffffffffc02041e6:	6446                	ld	s0,80(sp)
ffffffffc02041e8:	64a6                	ld	s1,72(sp)
ffffffffc02041ea:	6906                	ld	s2,64(sp)
ffffffffc02041ec:	79e2                	ld	s3,56(sp)
ffffffffc02041ee:	7a42                	ld	s4,48(sp)
ffffffffc02041f0:	7aa2                	ld	s5,40(sp)
ffffffffc02041f2:	7b02                	ld	s6,32(sp)
ffffffffc02041f4:	6be2                	ld	s7,24(sp)
ffffffffc02041f6:	6c42                	ld	s8,16(sp)
ffffffffc02041f8:	6ca2                	ld	s9,8(sp)
ffffffffc02041fa:	4501                	li	a0,0
ffffffffc02041fc:	6125                	addi	sp,sp,96
ffffffffc02041fe:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0204200:	00004697          	auipc	a3,0x4
ffffffffc0204204:	c2868693          	addi	a3,a3,-984 # ffffffffc0207e28 <etext+0x15de>
ffffffffc0204208:	00003617          	auipc	a2,0x3
ffffffffc020420c:	cc060613          	addi	a2,a2,-832 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0204210:	05500593          	li	a1,85
ffffffffc0204214:	00004517          	auipc	a0,0x4
ffffffffc0204218:	dec50513          	addi	a0,a0,-532 # ffffffffc0208000 <etext+0x17b6>
ffffffffc020421c:	a58fc0ef          	jal	ffffffffc0200474 <__panic>
    assert(pgfault_num==11);
ffffffffc0204220:	00004697          	auipc	a3,0x4
ffffffffc0204224:	f2068693          	addi	a3,a3,-224 # ffffffffc0208140 <etext+0x18f6>
ffffffffc0204228:	00003617          	auipc	a2,0x3
ffffffffc020422c:	ca060613          	addi	a2,a2,-864 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0204230:	07700593          	li	a1,119
ffffffffc0204234:	00004517          	auipc	a0,0x4
ffffffffc0204238:	dcc50513          	addi	a0,a0,-564 # ffffffffc0208000 <etext+0x17b6>
ffffffffc020423c:	a38fc0ef          	jal	ffffffffc0200474 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0204240:	00004697          	auipc	a3,0x4
ffffffffc0204244:	ed868693          	addi	a3,a3,-296 # ffffffffc0208118 <etext+0x18ce>
ffffffffc0204248:	00003617          	auipc	a2,0x3
ffffffffc020424c:	c8060613          	addi	a2,a2,-896 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0204250:	07500593          	li	a1,117
ffffffffc0204254:	00004517          	auipc	a0,0x4
ffffffffc0204258:	dac50513          	addi	a0,a0,-596 # ffffffffc0208000 <etext+0x17b6>
ffffffffc020425c:	a18fc0ef          	jal	ffffffffc0200474 <__panic>
    assert(pgfault_num==10);
ffffffffc0204260:	00004697          	auipc	a3,0x4
ffffffffc0204264:	ea868693          	addi	a3,a3,-344 # ffffffffc0208108 <etext+0x18be>
ffffffffc0204268:	00003617          	auipc	a2,0x3
ffffffffc020426c:	c6060613          	addi	a2,a2,-928 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0204270:	07300593          	li	a1,115
ffffffffc0204274:	00004517          	auipc	a0,0x4
ffffffffc0204278:	d8c50513          	addi	a0,a0,-628 # ffffffffc0208000 <etext+0x17b6>
ffffffffc020427c:	9f8fc0ef          	jal	ffffffffc0200474 <__panic>
    assert(pgfault_num==9);
ffffffffc0204280:	00004697          	auipc	a3,0x4
ffffffffc0204284:	e7868693          	addi	a3,a3,-392 # ffffffffc02080f8 <etext+0x18ae>
ffffffffc0204288:	00003617          	auipc	a2,0x3
ffffffffc020428c:	c4060613          	addi	a2,a2,-960 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0204290:	07000593          	li	a1,112
ffffffffc0204294:	00004517          	auipc	a0,0x4
ffffffffc0204298:	d6c50513          	addi	a0,a0,-660 # ffffffffc0208000 <etext+0x17b6>
ffffffffc020429c:	9d8fc0ef          	jal	ffffffffc0200474 <__panic>
    assert(pgfault_num==8);
ffffffffc02042a0:	00004697          	auipc	a3,0x4
ffffffffc02042a4:	e4868693          	addi	a3,a3,-440 # ffffffffc02080e8 <etext+0x189e>
ffffffffc02042a8:	00003617          	auipc	a2,0x3
ffffffffc02042ac:	c2060613          	addi	a2,a2,-992 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc02042b0:	06d00593          	li	a1,109
ffffffffc02042b4:	00004517          	auipc	a0,0x4
ffffffffc02042b8:	d4c50513          	addi	a0,a0,-692 # ffffffffc0208000 <etext+0x17b6>
ffffffffc02042bc:	9b8fc0ef          	jal	ffffffffc0200474 <__panic>
    assert(pgfault_num==7);
ffffffffc02042c0:	00004697          	auipc	a3,0x4
ffffffffc02042c4:	e1868693          	addi	a3,a3,-488 # ffffffffc02080d8 <etext+0x188e>
ffffffffc02042c8:	00003617          	auipc	a2,0x3
ffffffffc02042cc:	c0060613          	addi	a2,a2,-1024 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc02042d0:	06a00593          	li	a1,106
ffffffffc02042d4:	00004517          	auipc	a0,0x4
ffffffffc02042d8:	d2c50513          	addi	a0,a0,-724 # ffffffffc0208000 <etext+0x17b6>
ffffffffc02042dc:	998fc0ef          	jal	ffffffffc0200474 <__panic>
    assert(pgfault_num==6);
ffffffffc02042e0:	00004697          	auipc	a3,0x4
ffffffffc02042e4:	de868693          	addi	a3,a3,-536 # ffffffffc02080c8 <etext+0x187e>
ffffffffc02042e8:	00003617          	auipc	a2,0x3
ffffffffc02042ec:	be060613          	addi	a2,a2,-1056 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc02042f0:	06700593          	li	a1,103
ffffffffc02042f4:	00004517          	auipc	a0,0x4
ffffffffc02042f8:	d0c50513          	addi	a0,a0,-756 # ffffffffc0208000 <etext+0x17b6>
ffffffffc02042fc:	978fc0ef          	jal	ffffffffc0200474 <__panic>
    assert(pgfault_num==5);
ffffffffc0204300:	00004697          	auipc	a3,0x4
ffffffffc0204304:	db868693          	addi	a3,a3,-584 # ffffffffc02080b8 <etext+0x186e>
ffffffffc0204308:	00003617          	auipc	a2,0x3
ffffffffc020430c:	bc060613          	addi	a2,a2,-1088 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0204310:	06400593          	li	a1,100
ffffffffc0204314:	00004517          	auipc	a0,0x4
ffffffffc0204318:	cec50513          	addi	a0,a0,-788 # ffffffffc0208000 <etext+0x17b6>
ffffffffc020431c:	958fc0ef          	jal	ffffffffc0200474 <__panic>
    assert(pgfault_num==5);
ffffffffc0204320:	00004697          	auipc	a3,0x4
ffffffffc0204324:	d9868693          	addi	a3,a3,-616 # ffffffffc02080b8 <etext+0x186e>
ffffffffc0204328:	00003617          	auipc	a2,0x3
ffffffffc020432c:	ba060613          	addi	a2,a2,-1120 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0204330:	06100593          	li	a1,97
ffffffffc0204334:	00004517          	auipc	a0,0x4
ffffffffc0204338:	ccc50513          	addi	a0,a0,-820 # ffffffffc0208000 <etext+0x17b6>
ffffffffc020433c:	938fc0ef          	jal	ffffffffc0200474 <__panic>
    assert(pgfault_num==4);
ffffffffc0204340:	00004697          	auipc	a3,0x4
ffffffffc0204344:	ae868693          	addi	a3,a3,-1304 # ffffffffc0207e28 <etext+0x15de>
ffffffffc0204348:	00003617          	auipc	a2,0x3
ffffffffc020434c:	b8060613          	addi	a2,a2,-1152 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0204350:	05e00593          	li	a1,94
ffffffffc0204354:	00004517          	auipc	a0,0x4
ffffffffc0204358:	cac50513          	addi	a0,a0,-852 # ffffffffc0208000 <etext+0x17b6>
ffffffffc020435c:	918fc0ef          	jal	ffffffffc0200474 <__panic>
    assert(pgfault_num==4);
ffffffffc0204360:	00004697          	auipc	a3,0x4
ffffffffc0204364:	ac868693          	addi	a3,a3,-1336 # ffffffffc0207e28 <etext+0x15de>
ffffffffc0204368:	00003617          	auipc	a2,0x3
ffffffffc020436c:	b6060613          	addi	a2,a2,-1184 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0204370:	05b00593          	li	a1,91
ffffffffc0204374:	00004517          	auipc	a0,0x4
ffffffffc0204378:	c8c50513          	addi	a0,a0,-884 # ffffffffc0208000 <etext+0x17b6>
ffffffffc020437c:	8f8fc0ef          	jal	ffffffffc0200474 <__panic>
    assert(pgfault_num==4);
ffffffffc0204380:	00004697          	auipc	a3,0x4
ffffffffc0204384:	aa868693          	addi	a3,a3,-1368 # ffffffffc0207e28 <etext+0x15de>
ffffffffc0204388:	00003617          	auipc	a2,0x3
ffffffffc020438c:	b4060613          	addi	a2,a2,-1216 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0204390:	05800593          	li	a1,88
ffffffffc0204394:	00004517          	auipc	a0,0x4
ffffffffc0204398:	c6c50513          	addi	a0,a0,-916 # ffffffffc0208000 <etext+0x17b6>
ffffffffc020439c:	8d8fc0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc02043a0 <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc02043a0:	7518                	ld	a4,40(a0)
{
ffffffffc02043a2:	1141                	addi	sp,sp,-16
ffffffffc02043a4:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc02043a6:	c30d                	beqz	a4,ffffffffc02043c8 <_fifo_swap_out_victim+0x28>
     assert(in_tick==0);
ffffffffc02043a8:	e221                	bnez	a2,ffffffffc02043e8 <_fifo_swap_out_victim+0x48>
    return listelm->prev;
ffffffffc02043aa:	631c                	ld	a5,0(a4)
    if (entry != head) {
ffffffffc02043ac:	4681                	li	a3,0
ffffffffc02043ae:	00f70863          	beq	a4,a5,ffffffffc02043be <_fifo_swap_out_victim+0x1e>
    __list_del(listelm->prev, listelm->next);
ffffffffc02043b2:	6390                	ld	a2,0(a5)
ffffffffc02043b4:	6798                	ld	a4,8(a5)
        *ptr_page = le2page(entry, pra_page_link);
ffffffffc02043b6:	fd878693          	addi	a3,a5,-40
    prev->next = next;
ffffffffc02043ba:	e618                	sd	a4,8(a2)
    next->prev = prev;
ffffffffc02043bc:	e310                	sd	a2,0(a4)
}
ffffffffc02043be:	60a2                	ld	ra,8(sp)
        *ptr_page = le2page(entry, pra_page_link);
ffffffffc02043c0:	e194                	sd	a3,0(a1)
}
ffffffffc02043c2:	4501                	li	a0,0
ffffffffc02043c4:	0141                	addi	sp,sp,16
ffffffffc02043c6:	8082                	ret
         assert(head != NULL);
ffffffffc02043c8:	00004697          	auipc	a3,0x4
ffffffffc02043cc:	d8868693          	addi	a3,a3,-632 # ffffffffc0208150 <etext+0x1906>
ffffffffc02043d0:	00003617          	auipc	a2,0x3
ffffffffc02043d4:	af860613          	addi	a2,a2,-1288 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc02043d8:	04100593          	li	a1,65
ffffffffc02043dc:	00004517          	auipc	a0,0x4
ffffffffc02043e0:	c2450513          	addi	a0,a0,-988 # ffffffffc0208000 <etext+0x17b6>
ffffffffc02043e4:	890fc0ef          	jal	ffffffffc0200474 <__panic>
     assert(in_tick==0);
ffffffffc02043e8:	00004697          	auipc	a3,0x4
ffffffffc02043ec:	d7868693          	addi	a3,a3,-648 # ffffffffc0208160 <etext+0x1916>
ffffffffc02043f0:	00003617          	auipc	a2,0x3
ffffffffc02043f4:	ad860613          	addi	a2,a2,-1320 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc02043f8:	04200593          	li	a1,66
ffffffffc02043fc:	00004517          	auipc	a0,0x4
ffffffffc0204400:	c0450513          	addi	a0,a0,-1020 # ffffffffc0208000 <etext+0x17b6>
ffffffffc0204404:	870fc0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc0204408 <_fifo_map_swappable>:
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0204408:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc020440a:	cb91                	beqz	a5,ffffffffc020441e <_fifo_map_swappable+0x16>
    __list_add(elm, listelm, listelm->next);
ffffffffc020440c:	6794                	ld	a3,8(a5)
ffffffffc020440e:	02860713          	addi	a4,a2,40
}
ffffffffc0204412:	4501                	li	a0,0
    prev->next = next->prev = elm;
ffffffffc0204414:	e298                	sd	a4,0(a3)
ffffffffc0204416:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0204418:	fa14                	sd	a3,48(a2)
    elm->prev = prev;
ffffffffc020441a:	f61c                	sd	a5,40(a2)
ffffffffc020441c:	8082                	ret
{
ffffffffc020441e:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0204420:	00004697          	auipc	a3,0x4
ffffffffc0204424:	d5068693          	addi	a3,a3,-688 # ffffffffc0208170 <etext+0x1926>
ffffffffc0204428:	00003617          	auipc	a2,0x3
ffffffffc020442c:	aa060613          	addi	a2,a2,-1376 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0204430:	03200593          	li	a1,50
ffffffffc0204434:	00004517          	auipc	a0,0x4
ffffffffc0204438:	bcc50513          	addi	a0,a0,-1076 # ffffffffc0208000 <etext+0x17b6>
{
ffffffffc020443c:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc020443e:	836fc0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc0204442 <check_vma_overlap.part.0>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0204442:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0204444:	00004697          	auipc	a3,0x4
ffffffffc0204448:	d6468693          	addi	a3,a3,-668 # ffffffffc02081a8 <etext+0x195e>
ffffffffc020444c:	00003617          	auipc	a2,0x3
ffffffffc0204450:	a7c60613          	addi	a2,a2,-1412 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0204454:	06e00593          	li	a1,110
ffffffffc0204458:	00004517          	auipc	a0,0x4
ffffffffc020445c:	d7050513          	addi	a0,a0,-656 # ffffffffc02081c8 <etext+0x197e>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0204460:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0204462:	812fc0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc0204466 <mm_create>:
mm_create(void) {
ffffffffc0204466:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0204468:	04000513          	li	a0,64
mm_create(void) {
ffffffffc020446c:	e022                	sd	s0,0(sp)
ffffffffc020446e:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0204470:	bb9fd0ef          	jal	ffffffffc0202028 <kmalloc>
ffffffffc0204474:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0204476:	c505                	beqz	a0,ffffffffc020449e <mm_create+0x38>
    elm->prev = elm->next = elm;
ffffffffc0204478:	e408                	sd	a0,8(s0)
ffffffffc020447a:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc020447c:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0204480:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0204484:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0204488:	0009a797          	auipc	a5,0x9a
ffffffffc020448c:	b387a783          	lw	a5,-1224(a5) # ffffffffc029dfc0 <swap_init_ok>
ffffffffc0204490:	ef81                	bnez	a5,ffffffffc02044a8 <mm_create+0x42>
        else mm->sm_priv = NULL;
ffffffffc0204492:	02053423          	sd	zero,40(a0)
    mm->mm_count = val;
ffffffffc0204496:	02042823          	sw	zero,48(s0)
    *lock = 0;
ffffffffc020449a:	02043c23          	sd	zero,56(s0)
}
ffffffffc020449e:	60a2                	ld	ra,8(sp)
ffffffffc02044a0:	8522                	mv	a0,s0
ffffffffc02044a2:	6402                	ld	s0,0(sp)
ffffffffc02044a4:	0141                	addi	sp,sp,16
ffffffffc02044a6:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02044a8:	a0bff0ef          	jal	ffffffffc0203eb2 <swap_init_mm>
ffffffffc02044ac:	b7ed                	j	ffffffffc0204496 <mm_create+0x30>

ffffffffc02044ae <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc02044ae:	1101                	addi	sp,sp,-32
ffffffffc02044b0:	e04a                	sd	s2,0(sp)
ffffffffc02044b2:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02044b4:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc02044b8:	e822                	sd	s0,16(sp)
ffffffffc02044ba:	e426                	sd	s1,8(sp)
ffffffffc02044bc:	ec06                	sd	ra,24(sp)
ffffffffc02044be:	84ae                	mv	s1,a1
ffffffffc02044c0:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02044c2:	b67fd0ef          	jal	ffffffffc0202028 <kmalloc>
    if (vma != NULL) {
ffffffffc02044c6:	c509                	beqz	a0,ffffffffc02044d0 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc02044c8:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc02044cc:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02044ce:	cd00                	sw	s0,24(a0)
}
ffffffffc02044d0:	60e2                	ld	ra,24(sp)
ffffffffc02044d2:	6442                	ld	s0,16(sp)
ffffffffc02044d4:	64a2                	ld	s1,8(sp)
ffffffffc02044d6:	6902                	ld	s2,0(sp)
ffffffffc02044d8:	6105                	addi	sp,sp,32
ffffffffc02044da:	8082                	ret

ffffffffc02044dc <find_vma>:
find_vma(struct mm_struct *mm, uintptr_t addr) {
ffffffffc02044dc:	86aa                	mv	a3,a0
    if (mm != NULL) {
ffffffffc02044de:	c505                	beqz	a0,ffffffffc0204506 <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc02044e0:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc02044e2:	c501                	beqz	a0,ffffffffc02044ea <find_vma+0xe>
ffffffffc02044e4:	651c                	ld	a5,8(a0)
ffffffffc02044e6:	02f5f663          	bgeu	a1,a5,ffffffffc0204512 <find_vma+0x36>
    return listelm->next;
ffffffffc02044ea:	669c                	ld	a5,8(a3)
                while ((le = list_next(le)) != list) {
ffffffffc02044ec:	00f68d63          	beq	a3,a5,ffffffffc0204506 <find_vma+0x2a>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc02044f0:	fe87b703          	ld	a4,-24(a5)
ffffffffc02044f4:	00e5e663          	bltu	a1,a4,ffffffffc0204500 <find_vma+0x24>
ffffffffc02044f8:	ff07b703          	ld	a4,-16(a5)
ffffffffc02044fc:	00e5e763          	bltu	a1,a4,ffffffffc020450a <find_vma+0x2e>
ffffffffc0204500:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0204502:	fef697e3          	bne	a3,a5,ffffffffc02044f0 <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc0204506:	4501                	li	a0,0
}
ffffffffc0204508:	8082                	ret
                    vma = le2vma(le, list_link);
ffffffffc020450a:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc020450e:	ea88                	sd	a0,16(a3)
ffffffffc0204510:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0204512:	691c                	ld	a5,16(a0)
ffffffffc0204514:	fcf5fbe3          	bgeu	a1,a5,ffffffffc02044ea <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc0204518:	ea88                	sd	a0,16(a3)
ffffffffc020451a:	8082                	ret

ffffffffc020451c <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc020451c:	6590                	ld	a2,8(a1)
ffffffffc020451e:	0105b803          	ld	a6,16(a1) # 1010 <_binary_obj___user_softint_out_size-0x7628>
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0204522:	1141                	addi	sp,sp,-16
ffffffffc0204524:	e406                	sd	ra,8(sp)
ffffffffc0204526:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0204528:	01066763          	bltu	a2,a6,ffffffffc0204536 <insert_vma_struct+0x1a>
ffffffffc020452c:	a085                	j	ffffffffc020458c <insert_vma_struct+0x70>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc020452e:	fe87b703          	ld	a4,-24(a5)
ffffffffc0204532:	04e66863          	bltu	a2,a4,ffffffffc0204582 <insert_vma_struct+0x66>
ffffffffc0204536:	86be                	mv	a3,a5
ffffffffc0204538:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc020453a:	fef51ae3          	bne	a0,a5,ffffffffc020452e <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc020453e:	02a68463          	beq	a3,a0,ffffffffc0204566 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0204542:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0204546:	fe86b883          	ld	a7,-24(a3)
ffffffffc020454a:	08e8f163          	bgeu	a7,a4,ffffffffc02045cc <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc020454e:	04e66f63          	bltu	a2,a4,ffffffffc02045ac <insert_vma_struct+0x90>
    }
    if (le_next != list) {
ffffffffc0204552:	00f50a63          	beq	a0,a5,ffffffffc0204566 <insert_vma_struct+0x4a>
ffffffffc0204556:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc020455a:	05076963          	bltu	a4,a6,ffffffffc02045ac <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc020455e:	ff07b603          	ld	a2,-16(a5)
ffffffffc0204562:	02c77363          	bgeu	a4,a2,ffffffffc0204588 <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc0204566:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc0204568:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc020456a:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc020456e:	e390                	sd	a2,0(a5)
ffffffffc0204570:	e690                	sd	a2,8(a3)
}
ffffffffc0204572:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0204574:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0204576:	f194                	sd	a3,32(a1)
    mm->map_count ++;
ffffffffc0204578:	0017079b          	addiw	a5,a4,1
ffffffffc020457c:	d11c                	sw	a5,32(a0)
}
ffffffffc020457e:	0141                	addi	sp,sp,16
ffffffffc0204580:	8082                	ret
    if (le_prev != list) {
ffffffffc0204582:	fca690e3          	bne	a3,a0,ffffffffc0204542 <insert_vma_struct+0x26>
ffffffffc0204586:	bfd1                	j	ffffffffc020455a <insert_vma_struct+0x3e>
ffffffffc0204588:	ebbff0ef          	jal	ffffffffc0204442 <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc020458c:	00004697          	auipc	a3,0x4
ffffffffc0204590:	c4c68693          	addi	a3,a3,-948 # ffffffffc02081d8 <etext+0x198e>
ffffffffc0204594:	00003617          	auipc	a2,0x3
ffffffffc0204598:	93460613          	addi	a2,a2,-1740 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc020459c:	07500593          	li	a1,117
ffffffffc02045a0:	00004517          	auipc	a0,0x4
ffffffffc02045a4:	c2850513          	addi	a0,a0,-984 # ffffffffc02081c8 <etext+0x197e>
ffffffffc02045a8:	ecdfb0ef          	jal	ffffffffc0200474 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02045ac:	00004697          	auipc	a3,0x4
ffffffffc02045b0:	c6c68693          	addi	a3,a3,-916 # ffffffffc0208218 <etext+0x19ce>
ffffffffc02045b4:	00003617          	auipc	a2,0x3
ffffffffc02045b8:	91460613          	addi	a2,a2,-1772 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc02045bc:	06d00593          	li	a1,109
ffffffffc02045c0:	00004517          	auipc	a0,0x4
ffffffffc02045c4:	c0850513          	addi	a0,a0,-1016 # ffffffffc02081c8 <etext+0x197e>
ffffffffc02045c8:	eadfb0ef          	jal	ffffffffc0200474 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc02045cc:	00004697          	auipc	a3,0x4
ffffffffc02045d0:	c2c68693          	addi	a3,a3,-980 # ffffffffc02081f8 <etext+0x19ae>
ffffffffc02045d4:	00003617          	auipc	a2,0x3
ffffffffc02045d8:	8f460613          	addi	a2,a2,-1804 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc02045dc:	06c00593          	li	a1,108
ffffffffc02045e0:	00004517          	auipc	a0,0x4
ffffffffc02045e4:	be850513          	addi	a0,a0,-1048 # ffffffffc02081c8 <etext+0x197e>
ffffffffc02045e8:	e8dfb0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc02045ec <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
    assert(mm_count(mm) == 0);
ffffffffc02045ec:	591c                	lw	a5,48(a0)
mm_destroy(struct mm_struct *mm) {
ffffffffc02045ee:	1141                	addi	sp,sp,-16
ffffffffc02045f0:	e406                	sd	ra,8(sp)
ffffffffc02045f2:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc02045f4:	e78d                	bnez	a5,ffffffffc020461e <mm_destroy+0x32>
ffffffffc02045f6:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc02045f8:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc02045fa:	00a40c63          	beq	s0,a0,ffffffffc0204612 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc02045fe:	6118                	ld	a4,0(a0)
ffffffffc0204600:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc0204602:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0204604:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0204606:	e398                	sd	a4,0(a5)
ffffffffc0204608:	acbfd0ef          	jal	ffffffffc02020d2 <kfree>
    return listelm->next;
ffffffffc020460c:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc020460e:	fea418e3          	bne	s0,a0,ffffffffc02045fe <mm_destroy+0x12>
    }
    kfree(mm); //kfree mm
ffffffffc0204612:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0204614:	6402                	ld	s0,0(sp)
ffffffffc0204616:	60a2                	ld	ra,8(sp)
ffffffffc0204618:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc020461a:	ab9fd06f          	j	ffffffffc02020d2 <kfree>
    assert(mm_count(mm) == 0);
ffffffffc020461e:	00004697          	auipc	a3,0x4
ffffffffc0204622:	c1a68693          	addi	a3,a3,-998 # ffffffffc0208238 <etext+0x19ee>
ffffffffc0204626:	00003617          	auipc	a2,0x3
ffffffffc020462a:	8a260613          	addi	a2,a2,-1886 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc020462e:	09500593          	li	a1,149
ffffffffc0204632:	00004517          	auipc	a0,0x4
ffffffffc0204636:	b9650513          	addi	a0,a0,-1130 # ffffffffc02081c8 <etext+0x197e>
ffffffffc020463a:	e3bfb0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc020463e <mm_map>:

int
mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
       struct vma_struct **vma_store) {
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc020463e:	6785                	lui	a5,0x1
ffffffffc0204640:	17fd                	addi	a5,a5,-1 # fff <_binary_obj___user_softint_out_size-0x7639>
       struct vma_struct **vma_store) {
ffffffffc0204642:	7139                	addi	sp,sp,-64
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0204644:	787d                	lui	a6,0xfffff
ffffffffc0204646:	963e                	add	a2,a2,a5
       struct vma_struct **vma_store) {
ffffffffc0204648:	f822                	sd	s0,48(sp)
ffffffffc020464a:	f426                	sd	s1,40(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc020464c:	962e                	add	a2,a2,a1
       struct vma_struct **vma_store) {
ffffffffc020464e:	fc06                	sd	ra,56(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0204650:	0105f4b3          	and	s1,a1,a6
    if (!USER_ACCESS(start, end)) {
ffffffffc0204654:	002007b7          	lui	a5,0x200
ffffffffc0204658:	01067433          	and	s0,a2,a6
ffffffffc020465c:	08f4e363          	bltu	s1,a5,ffffffffc02046e2 <mm_map+0xa4>
ffffffffc0204660:	0884f163          	bgeu	s1,s0,ffffffffc02046e2 <mm_map+0xa4>
ffffffffc0204664:	4785                	li	a5,1
ffffffffc0204666:	07fe                	slli	a5,a5,0x1f
ffffffffc0204668:	0687ed63          	bltu	a5,s0,ffffffffc02046e2 <mm_map+0xa4>
ffffffffc020466c:	ec4e                	sd	s3,24(sp)
ffffffffc020466e:	89aa                	mv	s3,a0
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc0204670:	c93d                	beqz	a0,ffffffffc02046e6 <mm_map+0xa8>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start) {
ffffffffc0204672:	85a6                	mv	a1,s1
ffffffffc0204674:	e852                	sd	s4,16(sp)
ffffffffc0204676:	e456                	sd	s5,8(sp)
ffffffffc0204678:	8a3a                	mv	s4,a4
ffffffffc020467a:	8ab6                	mv	s5,a3
ffffffffc020467c:	e61ff0ef          	jal	ffffffffc02044dc <find_vma>
ffffffffc0204680:	c501                	beqz	a0,ffffffffc0204688 <mm_map+0x4a>
ffffffffc0204682:	651c                	ld	a5,8(a0)
ffffffffc0204684:	0487ec63          	bltu	a5,s0,ffffffffc02046dc <mm_map+0x9e>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204688:	03000513          	li	a0,48
ffffffffc020468c:	f04a                	sd	s2,32(sp)
ffffffffc020468e:	99bfd0ef          	jal	ffffffffc0202028 <kmalloc>
ffffffffc0204692:	892a                	mv	s2,a0
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc0204694:	5571                	li	a0,-4
    if (vma != NULL) {
ffffffffc0204696:	02090a63          	beqz	s2,ffffffffc02046ca <mm_map+0x8c>
        vma->vm_start = vm_start;
ffffffffc020469a:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc020469e:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc02046a2:	01592c23          	sw	s5,24(s2)

    if ((vma = vma_create(start, end, vm_flags)) == NULL) {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc02046a6:	85ca                	mv	a1,s2
ffffffffc02046a8:	854e                	mv	a0,s3
ffffffffc02046aa:	e73ff0ef          	jal	ffffffffc020451c <insert_vma_struct>
    if (vma_store != NULL) {
ffffffffc02046ae:	000a0463          	beqz	s4,ffffffffc02046b6 <mm_map+0x78>
        *vma_store = vma;
ffffffffc02046b2:	012a3023          	sd	s2,0(s4)
ffffffffc02046b6:	7902                	ld	s2,32(sp)
ffffffffc02046b8:	69e2                	ld	s3,24(sp)
ffffffffc02046ba:	6a42                	ld	s4,16(sp)
ffffffffc02046bc:	6aa2                	ld	s5,8(sp)
    }
    ret = 0;
ffffffffc02046be:	4501                	li	a0,0

out:
    return ret;
}
ffffffffc02046c0:	70e2                	ld	ra,56(sp)
ffffffffc02046c2:	7442                	ld	s0,48(sp)
ffffffffc02046c4:	74a2                	ld	s1,40(sp)
ffffffffc02046c6:	6121                	addi	sp,sp,64
ffffffffc02046c8:	8082                	ret
ffffffffc02046ca:	70e2                	ld	ra,56(sp)
ffffffffc02046cc:	7442                	ld	s0,48(sp)
ffffffffc02046ce:	7902                	ld	s2,32(sp)
ffffffffc02046d0:	69e2                	ld	s3,24(sp)
ffffffffc02046d2:	6a42                	ld	s4,16(sp)
ffffffffc02046d4:	6aa2                	ld	s5,8(sp)
ffffffffc02046d6:	74a2                	ld	s1,40(sp)
ffffffffc02046d8:	6121                	addi	sp,sp,64
ffffffffc02046da:	8082                	ret
ffffffffc02046dc:	69e2                	ld	s3,24(sp)
ffffffffc02046de:	6a42                	ld	s4,16(sp)
ffffffffc02046e0:	6aa2                	ld	s5,8(sp)
        return -E_INVAL;
ffffffffc02046e2:	5575                	li	a0,-3
ffffffffc02046e4:	bff1                	j	ffffffffc02046c0 <mm_map+0x82>
    assert(mm != NULL);
ffffffffc02046e6:	00003697          	auipc	a3,0x3
ffffffffc02046ea:	5ca68693          	addi	a3,a3,1482 # ffffffffc0207cb0 <etext+0x1466>
ffffffffc02046ee:	00002617          	auipc	a2,0x2
ffffffffc02046f2:	7da60613          	addi	a2,a2,2010 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc02046f6:	0a800593          	li	a1,168
ffffffffc02046fa:	00004517          	auipc	a0,0x4
ffffffffc02046fe:	ace50513          	addi	a0,a0,-1330 # ffffffffc02081c8 <etext+0x197e>
ffffffffc0204702:	f04a                	sd	s2,32(sp)
ffffffffc0204704:	e852                	sd	s4,16(sp)
ffffffffc0204706:	e456                	sd	s5,8(sp)
ffffffffc0204708:	d6dfb0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc020470c <exit_mmap>:
    }
    return 0;
}

void
exit_mmap(struct mm_struct *mm) {
ffffffffc020470c:	1101                	addi	sp,sp,-32
ffffffffc020470e:	ec06                	sd	ra,24(sp)
ffffffffc0204710:	e822                	sd	s0,16(sp)
ffffffffc0204712:	e426                	sd	s1,8(sp)
ffffffffc0204714:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0204716:	c531                	beqz	a0,ffffffffc0204762 <exit_mmap+0x56>
ffffffffc0204718:	591c                	lw	a5,48(a0)
ffffffffc020471a:	84aa                	mv	s1,a0
ffffffffc020471c:	e3b9                	bnez	a5,ffffffffc0204762 <exit_mmap+0x56>
ffffffffc020471e:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc0204720:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list) {
ffffffffc0204724:	02850663          	beq	a0,s0,ffffffffc0204750 <exit_mmap+0x44>
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0204728:	ff043603          	ld	a2,-16(s0)
ffffffffc020472c:	fe843583          	ld	a1,-24(s0)
ffffffffc0204730:	854a                	mv	a0,s2
ffffffffc0204732:	e05fd0ef          	jal	ffffffffc0202536 <unmap_range>
ffffffffc0204736:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc0204738:	fe8498e3          	bne	s1,s0,ffffffffc0204728 <exit_mmap+0x1c>
ffffffffc020473c:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list) {
ffffffffc020473e:	00848c63          	beq	s1,s0,ffffffffc0204756 <exit_mmap+0x4a>
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0204742:	ff043603          	ld	a2,-16(s0)
ffffffffc0204746:	fe843583          	ld	a1,-24(s0)
ffffffffc020474a:	854a                	mv	a0,s2
ffffffffc020474c:	f15fd0ef          	jal	ffffffffc0202660 <exit_range>
ffffffffc0204750:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc0204752:	fe8498e3          	bne	s1,s0,ffffffffc0204742 <exit_mmap+0x36>
    }
}
ffffffffc0204756:	60e2                	ld	ra,24(sp)
ffffffffc0204758:	6442                	ld	s0,16(sp)
ffffffffc020475a:	64a2                	ld	s1,8(sp)
ffffffffc020475c:	6902                	ld	s2,0(sp)
ffffffffc020475e:	6105                	addi	sp,sp,32
ffffffffc0204760:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0204762:	00004697          	auipc	a3,0x4
ffffffffc0204766:	aee68693          	addi	a3,a3,-1298 # ffffffffc0208250 <etext+0x1a06>
ffffffffc020476a:	00002617          	auipc	a2,0x2
ffffffffc020476e:	75e60613          	addi	a2,a2,1886 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0204772:	0d700593          	li	a1,215
ffffffffc0204776:	00004517          	auipc	a0,0x4
ffffffffc020477a:	a5250513          	addi	a0,a0,-1454 # ffffffffc02081c8 <etext+0x197e>
ffffffffc020477e:	cf7fb0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc0204782 <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0204782:	7139                	addi	sp,sp,-64
ffffffffc0204784:	f822                	sd	s0,48(sp)
ffffffffc0204786:	f426                	sd	s1,40(sp)
ffffffffc0204788:	fc06                	sd	ra,56(sp)
ffffffffc020478a:	f04a                	sd	s2,32(sp)
ffffffffc020478c:	ec4e                	sd	s3,24(sp)
ffffffffc020478e:	e852                	sd	s4,16(sp)
ffffffffc0204790:	e456                	sd	s5,8(sp)

static void
check_vma_struct(void) {
    // size_t nr_free_pages_store = nr_free_pages();

    struct mm_struct *mm = mm_create();
ffffffffc0204792:	cd5ff0ef          	jal	ffffffffc0204466 <mm_create>
    assert(mm != NULL);
ffffffffc0204796:	842a                	mv	s0,a0
ffffffffc0204798:	03200493          	li	s1,50
ffffffffc020479c:	38050463          	beqz	a0,ffffffffc0204b24 <vmm_init+0x3a2>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02047a0:	03000513          	li	a0,48
ffffffffc02047a4:	885fd0ef          	jal	ffffffffc0202028 <kmalloc>
ffffffffc02047a8:	85aa                	mv	a1,a0
    if (vma != NULL) {
ffffffffc02047aa:	26050d63          	beqz	a0,ffffffffc0204a24 <vmm_init+0x2a2>
        vma->vm_end = vm_end;
ffffffffc02047ae:	00248793          	addi	a5,s1,2
        vma->vm_start = vm_start;
ffffffffc02047b2:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc02047b4:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02047b6:	00052c23          	sw	zero,24(a0)

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
ffffffffc02047ba:	14ed                	addi	s1,s1,-5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02047bc:	8522                	mv	a0,s0
ffffffffc02047be:	d5fff0ef          	jal	ffffffffc020451c <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc02047c2:	fcf9                	bnez	s1,ffffffffc02047a0 <vmm_init+0x1e>
ffffffffc02047c4:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02047c8:	1f900913          	li	s2,505
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02047cc:	03000513          	li	a0,48
ffffffffc02047d0:	859fd0ef          	jal	ffffffffc0202028 <kmalloc>
ffffffffc02047d4:	85aa                	mv	a1,a0
    if (vma != NULL) {
ffffffffc02047d6:	26050763          	beqz	a0,ffffffffc0204a44 <vmm_init+0x2c2>
        vma->vm_end = vm_end;
ffffffffc02047da:	00248793          	addi	a5,s1,2
        vma->vm_start = vm_start;
ffffffffc02047de:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc02047e0:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02047e2:	00052c23          	sw	zero,24(a0)
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02047e6:	0495                	addi	s1,s1,5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02047e8:	8522                	mv	a0,s0
ffffffffc02047ea:	d33ff0ef          	jal	ffffffffc020451c <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02047ee:	fd249fe3          	bne	s1,s2,ffffffffc02047cc <vmm_init+0x4a>
ffffffffc02047f2:	641c                	ld	a5,8(s0)
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
        assert(le != &(mm->mmap_list));
ffffffffc02047f4:	30878863          	beq	a5,s0,ffffffffc0204b04 <vmm_init+0x382>
ffffffffc02047f8:	4715                	li	a4,5
    for (i = 1; i <= step2; i ++) {
ffffffffc02047fa:	1f400593          	li	a1,500
ffffffffc02047fe:	a021                	j	ffffffffc0204806 <vmm_init+0x84>
        assert(le != &(mm->mmap_list));
ffffffffc0204800:	0715                	addi	a4,a4,5
ffffffffc0204802:	30878163          	beq	a5,s0,ffffffffc0204b04 <vmm_init+0x382>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0204806:	fe87b683          	ld	a3,-24(a5) # 1fffe8 <_binary_obj___user_exit_out_size+0x1f6448>
ffffffffc020480a:	2ae69d63          	bne	a3,a4,ffffffffc0204ac4 <vmm_init+0x342>
ffffffffc020480e:	ff07b603          	ld	a2,-16(a5)
ffffffffc0204812:	00270693          	addi	a3,a4,2
ffffffffc0204816:	2ad61763          	bne	a2,a3,ffffffffc0204ac4 <vmm_init+0x342>
ffffffffc020481a:	679c                	ld	a5,8(a5)
    for (i = 1; i <= step2; i ++) {
ffffffffc020481c:	feb712e3          	bne	a4,a1,ffffffffc0204800 <vmm_init+0x7e>
ffffffffc0204820:	4a1d                	li	s4,7
ffffffffc0204822:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0204824:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0204828:	85a6                	mv	a1,s1
ffffffffc020482a:	8522                	mv	a0,s0
ffffffffc020482c:	cb1ff0ef          	jal	ffffffffc02044dc <find_vma>
ffffffffc0204830:	89aa                	mv	s3,a0
        assert(vma1 != NULL);
ffffffffc0204832:	2a050963          	beqz	a0,ffffffffc0204ae4 <vmm_init+0x362>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0204836:	00148593          	addi	a1,s1,1
ffffffffc020483a:	8522                	mv	a0,s0
ffffffffc020483c:	ca1ff0ef          	jal	ffffffffc02044dc <find_vma>
ffffffffc0204840:	892a                	mv	s2,a0
        assert(vma2 != NULL);
ffffffffc0204842:	36050163          	beqz	a0,ffffffffc0204ba4 <vmm_init+0x422>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0204846:	85d2                	mv	a1,s4
ffffffffc0204848:	8522                	mv	a0,s0
ffffffffc020484a:	c93ff0ef          	jal	ffffffffc02044dc <find_vma>
        assert(vma3 == NULL);
ffffffffc020484e:	32051b63          	bnez	a0,ffffffffc0204b84 <vmm_init+0x402>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc0204852:	00348593          	addi	a1,s1,3
ffffffffc0204856:	8522                	mv	a0,s0
ffffffffc0204858:	c85ff0ef          	jal	ffffffffc02044dc <find_vma>
        assert(vma4 == NULL);
ffffffffc020485c:	30051463          	bnez	a0,ffffffffc0204b64 <vmm_init+0x3e2>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc0204860:	00448593          	addi	a1,s1,4
ffffffffc0204864:	8522                	mv	a0,s0
ffffffffc0204866:	c77ff0ef          	jal	ffffffffc02044dc <find_vma>
        assert(vma5 == NULL);
ffffffffc020486a:	2c051d63          	bnez	a0,ffffffffc0204b44 <vmm_init+0x3c2>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc020486e:	0089b783          	ld	a5,8(s3)
ffffffffc0204872:	22979963          	bne	a5,s1,ffffffffc0204aa4 <vmm_init+0x322>
ffffffffc0204876:	0109b783          	ld	a5,16(s3)
ffffffffc020487a:	23479563          	bne	a5,s4,ffffffffc0204aa4 <vmm_init+0x322>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc020487e:	00893783          	ld	a5,8(s2)
ffffffffc0204882:	20979163          	bne	a5,s1,ffffffffc0204a84 <vmm_init+0x302>
ffffffffc0204886:	01093783          	ld	a5,16(s2)
ffffffffc020488a:	1f479d63          	bne	a5,s4,ffffffffc0204a84 <vmm_init+0x302>
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc020488e:	0495                	addi	s1,s1,5
ffffffffc0204890:	0a15                	addi	s4,s4,5
ffffffffc0204892:	f9549be3          	bne	s1,s5,ffffffffc0204828 <vmm_init+0xa6>
ffffffffc0204896:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0204898:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc020489a:	85a6                	mv	a1,s1
ffffffffc020489c:	8522                	mv	a0,s0
ffffffffc020489e:	c3fff0ef          	jal	ffffffffc02044dc <find_vma>
        if (vma_below_5 != NULL ) {
ffffffffc02048a2:	38051163          	bnez	a0,ffffffffc0204c24 <vmm_init+0x4a2>
    for (i =4; i>=0; i--) {
ffffffffc02048a6:	14fd                	addi	s1,s1,-1
ffffffffc02048a8:	ff2499e3          	bne	s1,s2,ffffffffc020489a <vmm_init+0x118>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
        }
        assert(vma_below_5 == NULL);
    }

    mm_destroy(mm);
ffffffffc02048ac:	8522                	mv	a0,s0
ffffffffc02048ae:	d3fff0ef          	jal	ffffffffc02045ec <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc02048b2:	00004517          	auipc	a0,0x4
ffffffffc02048b6:	afe50513          	addi	a0,a0,-1282 # ffffffffc02083b0 <etext+0x1b66>
ffffffffc02048ba:	8c7fb0ef          	jal	ffffffffc0200180 <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02048be:	a13fd0ef          	jal	ffffffffc02022d0 <nr_free_pages>
ffffffffc02048c2:	892a                	mv	s2,a0

    check_mm_struct = mm_create();
ffffffffc02048c4:	ba3ff0ef          	jal	ffffffffc0204466 <mm_create>
ffffffffc02048c8:	00099797          	auipc	a5,0x99
ffffffffc02048cc:	70a7bc23          	sd	a0,1816(a5) # ffffffffc029dfe0 <check_mm_struct>
ffffffffc02048d0:	842a                	mv	s0,a0
    assert(check_mm_struct != NULL);
ffffffffc02048d2:	32050963          	beqz	a0,ffffffffc0204c04 <vmm_init+0x482>

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02048d6:	00099497          	auipc	s1,0x99
ffffffffc02048da:	6ca4b483          	ld	s1,1738(s1) # ffffffffc029dfa0 <boot_pgdir>
    assert(pgdir[0] == 0);
ffffffffc02048de:	609c                	ld	a5,0(s1)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02048e0:	ed04                	sd	s1,24(a0)
    assert(pgdir[0] == 0);
ffffffffc02048e2:	30079163          	bnez	a5,ffffffffc0204be4 <vmm_init+0x462>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02048e6:	03000513          	li	a0,48
ffffffffc02048ea:	f3efd0ef          	jal	ffffffffc0202028 <kmalloc>
ffffffffc02048ee:	89aa                	mv	s3,a0
    if (vma != NULL) {
ffffffffc02048f0:	16050a63          	beqz	a0,ffffffffc0204a64 <vmm_init+0x2e2>
        vma->vm_end = vm_end;
ffffffffc02048f4:	002007b7          	lui	a5,0x200
ffffffffc02048f8:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02048fa:	4789                	li	a5,2
ffffffffc02048fc:	cd1c                	sw	a5,24(a0)

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc02048fe:	85aa                	mv	a1,a0
        vma->vm_start = vm_start;
ffffffffc0204900:	00053423          	sd	zero,8(a0)
    insert_vma_struct(mm, vma);
ffffffffc0204904:	8522                	mv	a0,s0
ffffffffc0204906:	c17ff0ef          	jal	ffffffffc020451c <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc020490a:	10000593          	li	a1,256
ffffffffc020490e:	8522                	mv	a0,s0
ffffffffc0204910:	bcdff0ef          	jal	ffffffffc02044dc <find_vma>
ffffffffc0204914:	10000793          	li	a5,256

    int i, sum = 0;

    for (i = 0; i < 100; i ++) {
ffffffffc0204918:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc020491c:	2aa99463          	bne	s3,a0,ffffffffc0204bc4 <vmm_init+0x442>
        *(char *)(addr + i) = i;
ffffffffc0204920:	00f78023          	sb	a5,0(a5) # 200000 <_binary_obj___user_exit_out_size+0x1f6460>
    for (i = 0; i < 100; i ++) {
ffffffffc0204924:	0785                	addi	a5,a5,1
ffffffffc0204926:	fee79de3          	bne	a5,a4,ffffffffc0204920 <vmm_init+0x19e>
ffffffffc020492a:	6705                	lui	a4,0x1
ffffffffc020492c:	10000793          	li	a5,256
ffffffffc0204930:	35670713          	addi	a4,a4,854 # 1356 <_binary_obj___user_softint_out_size-0x72e2>
        sum += i;
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0204934:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc0204938:	0007c683          	lbu	a3,0(a5)
    for (i = 0; i < 100; i ++) {
ffffffffc020493c:	0785                	addi	a5,a5,1
        sum -= *(char *)(addr + i);
ffffffffc020493e:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0204940:	fec79ce3          	bne	a5,a2,ffffffffc0204938 <vmm_init+0x1b6>
    }

    assert(sum == 0);
ffffffffc0204944:	36071263          	bnez	a4,ffffffffc0204ca8 <vmm_init+0x526>
    return pa2page(PDE_ADDR(pde));
ffffffffc0204948:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc020494a:	00099a97          	auipc	s5,0x99
ffffffffc020494e:	666a8a93          	addi	s5,s5,1638 # ffffffffc029dfb0 <npage>
ffffffffc0204952:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0204956:	078a                	slli	a5,a5,0x2
ffffffffc0204958:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020495a:	32e7fb63          	bgeu	a5,a4,ffffffffc0204c90 <vmm_init+0x50e>
    return &pages[PPN(pa) - nbase];
ffffffffc020495e:	00004a17          	auipc	s4,0x4
ffffffffc0204962:	5f2a3a03          	ld	s4,1522(s4) # ffffffffc0208f50 <nbase>
ffffffffc0204966:	414786b3          	sub	a3,a5,s4
ffffffffc020496a:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc020496c:	8699                	srai	a3,a3,0x6
ffffffffc020496e:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc0204970:	00c69793          	slli	a5,a3,0xc
ffffffffc0204974:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0204976:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204978:	30e7f063          	bgeu	a5,a4,ffffffffc0204c78 <vmm_init+0x4f6>
ffffffffc020497c:	00099797          	auipc	a5,0x99
ffffffffc0204980:	62c7b783          	ld	a5,1580(a5) # ffffffffc029dfa8 <va_pa_offset>

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0204984:	4581                	li	a1,0
ffffffffc0204986:	8526                	mv	a0,s1
ffffffffc0204988:	00f689b3          	add	s3,a3,a5
ffffffffc020498c:	faffd0ef          	jal	ffffffffc020293a <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc0204990:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc0204994:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0204998:	078a                	slli	a5,a5,0x2
ffffffffc020499a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020499c:	2ee7fa63          	bgeu	a5,a4,ffffffffc0204c90 <vmm_init+0x50e>
    return &pages[PPN(pa) - nbase];
ffffffffc02049a0:	00099997          	auipc	s3,0x99
ffffffffc02049a4:	61898993          	addi	s3,s3,1560 # ffffffffc029dfb8 <pages>
ffffffffc02049a8:	0009b503          	ld	a0,0(s3)
ffffffffc02049ac:	414787b3          	sub	a5,a5,s4
ffffffffc02049b0:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc02049b2:	953e                	add	a0,a0,a5
ffffffffc02049b4:	4585                	li	a1,1
ffffffffc02049b6:	8dbfd0ef          	jal	ffffffffc0202290 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02049ba:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc02049bc:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc02049c0:	078a                	slli	a5,a5,0x2
ffffffffc02049c2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02049c4:	2ce7f663          	bgeu	a5,a4,ffffffffc0204c90 <vmm_init+0x50e>
    return &pages[PPN(pa) - nbase];
ffffffffc02049c8:	0009b503          	ld	a0,0(s3)
ffffffffc02049cc:	414787b3          	sub	a5,a5,s4
ffffffffc02049d0:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc02049d2:	4585                	li	a1,1
ffffffffc02049d4:	953e                	add	a0,a0,a5
ffffffffc02049d6:	8bbfd0ef          	jal	ffffffffc0202290 <free_pages>
    pgdir[0] = 0;
ffffffffc02049da:	0004b023          	sd	zero,0(s1)
  asm volatile("sfence.vma");
ffffffffc02049de:	12000073          	sfence.vma
    flush_tlb();

    mm->pgdir = NULL;
ffffffffc02049e2:	00043c23          	sd	zero,24(s0)
    mm_destroy(mm);
ffffffffc02049e6:	8522                	mv	a0,s0
ffffffffc02049e8:	c05ff0ef          	jal	ffffffffc02045ec <mm_destroy>
    check_mm_struct = NULL;
ffffffffc02049ec:	00099797          	auipc	a5,0x99
ffffffffc02049f0:	5e07ba23          	sd	zero,1524(a5) # ffffffffc029dfe0 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02049f4:	8ddfd0ef          	jal	ffffffffc02022d0 <nr_free_pages>
ffffffffc02049f8:	26a91063          	bne	s2,a0,ffffffffc0204c58 <vmm_init+0x4d6>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc02049fc:	00004517          	auipc	a0,0x4
ffffffffc0204a00:	a4450513          	addi	a0,a0,-1468 # ffffffffc0208440 <etext+0x1bf6>
ffffffffc0204a04:	f7cfb0ef          	jal	ffffffffc0200180 <cprintf>
}
ffffffffc0204a08:	7442                	ld	s0,48(sp)
ffffffffc0204a0a:	70e2                	ld	ra,56(sp)
ffffffffc0204a0c:	74a2                	ld	s1,40(sp)
ffffffffc0204a0e:	7902                	ld	s2,32(sp)
ffffffffc0204a10:	69e2                	ld	s3,24(sp)
ffffffffc0204a12:	6a42                	ld	s4,16(sp)
ffffffffc0204a14:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0204a16:	00004517          	auipc	a0,0x4
ffffffffc0204a1a:	a4a50513          	addi	a0,a0,-1462 # ffffffffc0208460 <etext+0x1c16>
}
ffffffffc0204a1e:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc0204a20:	f60fb06f          	j	ffffffffc0200180 <cprintf>
        assert(vma != NULL);
ffffffffc0204a24:	00003697          	auipc	a3,0x3
ffffffffc0204a28:	2c468693          	addi	a3,a3,708 # ffffffffc0207ce8 <etext+0x149e>
ffffffffc0204a2c:	00002617          	auipc	a2,0x2
ffffffffc0204a30:	49c60613          	addi	a2,a2,1180 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0204a34:	11400593          	li	a1,276
ffffffffc0204a38:	00003517          	auipc	a0,0x3
ffffffffc0204a3c:	79050513          	addi	a0,a0,1936 # ffffffffc02081c8 <etext+0x197e>
ffffffffc0204a40:	a35fb0ef          	jal	ffffffffc0200474 <__panic>
        assert(vma != NULL);
ffffffffc0204a44:	00003697          	auipc	a3,0x3
ffffffffc0204a48:	2a468693          	addi	a3,a3,676 # ffffffffc0207ce8 <etext+0x149e>
ffffffffc0204a4c:	00002617          	auipc	a2,0x2
ffffffffc0204a50:	47c60613          	addi	a2,a2,1148 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0204a54:	11a00593          	li	a1,282
ffffffffc0204a58:	00003517          	auipc	a0,0x3
ffffffffc0204a5c:	77050513          	addi	a0,a0,1904 # ffffffffc02081c8 <etext+0x197e>
ffffffffc0204a60:	a15fb0ef          	jal	ffffffffc0200474 <__panic>
    assert(vma != NULL);
ffffffffc0204a64:	00003697          	auipc	a3,0x3
ffffffffc0204a68:	28468693          	addi	a3,a3,644 # ffffffffc0207ce8 <etext+0x149e>
ffffffffc0204a6c:	00002617          	auipc	a2,0x2
ffffffffc0204a70:	45c60613          	addi	a2,a2,1116 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0204a74:	15300593          	li	a1,339
ffffffffc0204a78:	00003517          	auipc	a0,0x3
ffffffffc0204a7c:	75050513          	addi	a0,a0,1872 # ffffffffc02081c8 <etext+0x197e>
ffffffffc0204a80:	9f5fb0ef          	jal	ffffffffc0200474 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0204a84:	00004697          	auipc	a3,0x4
ffffffffc0204a88:	8bc68693          	addi	a3,a3,-1860 # ffffffffc0208340 <etext+0x1af6>
ffffffffc0204a8c:	00002617          	auipc	a2,0x2
ffffffffc0204a90:	43c60613          	addi	a2,a2,1084 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0204a94:	13400593          	li	a1,308
ffffffffc0204a98:	00003517          	auipc	a0,0x3
ffffffffc0204a9c:	73050513          	addi	a0,a0,1840 # ffffffffc02081c8 <etext+0x197e>
ffffffffc0204aa0:	9d5fb0ef          	jal	ffffffffc0200474 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0204aa4:	00004697          	auipc	a3,0x4
ffffffffc0204aa8:	86c68693          	addi	a3,a3,-1940 # ffffffffc0208310 <etext+0x1ac6>
ffffffffc0204aac:	00002617          	auipc	a2,0x2
ffffffffc0204ab0:	41c60613          	addi	a2,a2,1052 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0204ab4:	13300593          	li	a1,307
ffffffffc0204ab8:	00003517          	auipc	a0,0x3
ffffffffc0204abc:	71050513          	addi	a0,a0,1808 # ffffffffc02081c8 <etext+0x197e>
ffffffffc0204ac0:	9b5fb0ef          	jal	ffffffffc0200474 <__panic>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0204ac4:	00003697          	auipc	a3,0x3
ffffffffc0204ac8:	7c468693          	addi	a3,a3,1988 # ffffffffc0208288 <etext+0x1a3e>
ffffffffc0204acc:	00002617          	auipc	a2,0x2
ffffffffc0204ad0:	3fc60613          	addi	a2,a2,1020 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0204ad4:	12300593          	li	a1,291
ffffffffc0204ad8:	00003517          	auipc	a0,0x3
ffffffffc0204adc:	6f050513          	addi	a0,a0,1776 # ffffffffc02081c8 <etext+0x197e>
ffffffffc0204ae0:	995fb0ef          	jal	ffffffffc0200474 <__panic>
        assert(vma1 != NULL);
ffffffffc0204ae4:	00003697          	auipc	a3,0x3
ffffffffc0204ae8:	7dc68693          	addi	a3,a3,2012 # ffffffffc02082c0 <etext+0x1a76>
ffffffffc0204aec:	00002617          	auipc	a2,0x2
ffffffffc0204af0:	3dc60613          	addi	a2,a2,988 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0204af4:	12900593          	li	a1,297
ffffffffc0204af8:	00003517          	auipc	a0,0x3
ffffffffc0204afc:	6d050513          	addi	a0,a0,1744 # ffffffffc02081c8 <etext+0x197e>
ffffffffc0204b00:	975fb0ef          	jal	ffffffffc0200474 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0204b04:	00003697          	auipc	a3,0x3
ffffffffc0204b08:	76c68693          	addi	a3,a3,1900 # ffffffffc0208270 <etext+0x1a26>
ffffffffc0204b0c:	00002617          	auipc	a2,0x2
ffffffffc0204b10:	3bc60613          	addi	a2,a2,956 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0204b14:	12100593          	li	a1,289
ffffffffc0204b18:	00003517          	auipc	a0,0x3
ffffffffc0204b1c:	6b050513          	addi	a0,a0,1712 # ffffffffc02081c8 <etext+0x197e>
ffffffffc0204b20:	955fb0ef          	jal	ffffffffc0200474 <__panic>
    assert(mm != NULL);
ffffffffc0204b24:	00003697          	auipc	a3,0x3
ffffffffc0204b28:	18c68693          	addi	a3,a3,396 # ffffffffc0207cb0 <etext+0x1466>
ffffffffc0204b2c:	00002617          	auipc	a2,0x2
ffffffffc0204b30:	39c60613          	addi	a2,a2,924 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0204b34:	10d00593          	li	a1,269
ffffffffc0204b38:	00003517          	auipc	a0,0x3
ffffffffc0204b3c:	69050513          	addi	a0,a0,1680 # ffffffffc02081c8 <etext+0x197e>
ffffffffc0204b40:	935fb0ef          	jal	ffffffffc0200474 <__panic>
        assert(vma5 == NULL);
ffffffffc0204b44:	00003697          	auipc	a3,0x3
ffffffffc0204b48:	7bc68693          	addi	a3,a3,1980 # ffffffffc0208300 <etext+0x1ab6>
ffffffffc0204b4c:	00002617          	auipc	a2,0x2
ffffffffc0204b50:	37c60613          	addi	a2,a2,892 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0204b54:	13100593          	li	a1,305
ffffffffc0204b58:	00003517          	auipc	a0,0x3
ffffffffc0204b5c:	67050513          	addi	a0,a0,1648 # ffffffffc02081c8 <etext+0x197e>
ffffffffc0204b60:	915fb0ef          	jal	ffffffffc0200474 <__panic>
        assert(vma4 == NULL);
ffffffffc0204b64:	00003697          	auipc	a3,0x3
ffffffffc0204b68:	78c68693          	addi	a3,a3,1932 # ffffffffc02082f0 <etext+0x1aa6>
ffffffffc0204b6c:	00002617          	auipc	a2,0x2
ffffffffc0204b70:	35c60613          	addi	a2,a2,860 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0204b74:	12f00593          	li	a1,303
ffffffffc0204b78:	00003517          	auipc	a0,0x3
ffffffffc0204b7c:	65050513          	addi	a0,a0,1616 # ffffffffc02081c8 <etext+0x197e>
ffffffffc0204b80:	8f5fb0ef          	jal	ffffffffc0200474 <__panic>
        assert(vma3 == NULL);
ffffffffc0204b84:	00003697          	auipc	a3,0x3
ffffffffc0204b88:	75c68693          	addi	a3,a3,1884 # ffffffffc02082e0 <etext+0x1a96>
ffffffffc0204b8c:	00002617          	auipc	a2,0x2
ffffffffc0204b90:	33c60613          	addi	a2,a2,828 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0204b94:	12d00593          	li	a1,301
ffffffffc0204b98:	00003517          	auipc	a0,0x3
ffffffffc0204b9c:	63050513          	addi	a0,a0,1584 # ffffffffc02081c8 <etext+0x197e>
ffffffffc0204ba0:	8d5fb0ef          	jal	ffffffffc0200474 <__panic>
        assert(vma2 != NULL);
ffffffffc0204ba4:	00003697          	auipc	a3,0x3
ffffffffc0204ba8:	72c68693          	addi	a3,a3,1836 # ffffffffc02082d0 <etext+0x1a86>
ffffffffc0204bac:	00002617          	auipc	a2,0x2
ffffffffc0204bb0:	31c60613          	addi	a2,a2,796 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0204bb4:	12b00593          	li	a1,299
ffffffffc0204bb8:	00003517          	auipc	a0,0x3
ffffffffc0204bbc:	61050513          	addi	a0,a0,1552 # ffffffffc02081c8 <etext+0x197e>
ffffffffc0204bc0:	8b5fb0ef          	jal	ffffffffc0200474 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0204bc4:	00004697          	auipc	a3,0x4
ffffffffc0204bc8:	82468693          	addi	a3,a3,-2012 # ffffffffc02083e8 <etext+0x1b9e>
ffffffffc0204bcc:	00002617          	auipc	a2,0x2
ffffffffc0204bd0:	2fc60613          	addi	a2,a2,764 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0204bd4:	15800593          	li	a1,344
ffffffffc0204bd8:	00003517          	auipc	a0,0x3
ffffffffc0204bdc:	5f050513          	addi	a0,a0,1520 # ffffffffc02081c8 <etext+0x197e>
ffffffffc0204be0:	895fb0ef          	jal	ffffffffc0200474 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0204be4:	00003697          	auipc	a3,0x3
ffffffffc0204be8:	0f468693          	addi	a3,a3,244 # ffffffffc0207cd8 <etext+0x148e>
ffffffffc0204bec:	00002617          	auipc	a2,0x2
ffffffffc0204bf0:	2dc60613          	addi	a2,a2,732 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0204bf4:	15000593          	li	a1,336
ffffffffc0204bf8:	00003517          	auipc	a0,0x3
ffffffffc0204bfc:	5d050513          	addi	a0,a0,1488 # ffffffffc02081c8 <etext+0x197e>
ffffffffc0204c00:	875fb0ef          	jal	ffffffffc0200474 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0204c04:	00003697          	auipc	a3,0x3
ffffffffc0204c08:	7cc68693          	addi	a3,a3,1996 # ffffffffc02083d0 <etext+0x1b86>
ffffffffc0204c0c:	00002617          	auipc	a2,0x2
ffffffffc0204c10:	2bc60613          	addi	a2,a2,700 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0204c14:	14c00593          	li	a1,332
ffffffffc0204c18:	00003517          	auipc	a0,0x3
ffffffffc0204c1c:	5b050513          	addi	a0,a0,1456 # ffffffffc02081c8 <etext+0x197e>
ffffffffc0204c20:	855fb0ef          	jal	ffffffffc0200474 <__panic>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0204c24:	6914                	ld	a3,16(a0)
ffffffffc0204c26:	6510                	ld	a2,8(a0)
ffffffffc0204c28:	0004859b          	sext.w	a1,s1
ffffffffc0204c2c:	00003517          	auipc	a0,0x3
ffffffffc0204c30:	74450513          	addi	a0,a0,1860 # ffffffffc0208370 <etext+0x1b26>
ffffffffc0204c34:	d4cfb0ef          	jal	ffffffffc0200180 <cprintf>
        assert(vma_below_5 == NULL);
ffffffffc0204c38:	00003697          	auipc	a3,0x3
ffffffffc0204c3c:	76068693          	addi	a3,a3,1888 # ffffffffc0208398 <etext+0x1b4e>
ffffffffc0204c40:	00002617          	auipc	a2,0x2
ffffffffc0204c44:	28860613          	addi	a2,a2,648 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0204c48:	13c00593          	li	a1,316
ffffffffc0204c4c:	00003517          	auipc	a0,0x3
ffffffffc0204c50:	57c50513          	addi	a0,a0,1404 # ffffffffc02081c8 <etext+0x197e>
ffffffffc0204c54:	821fb0ef          	jal	ffffffffc0200474 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0204c58:	00003697          	auipc	a3,0x3
ffffffffc0204c5c:	7c068693          	addi	a3,a3,1984 # ffffffffc0208418 <etext+0x1bce>
ffffffffc0204c60:	00002617          	auipc	a2,0x2
ffffffffc0204c64:	26860613          	addi	a2,a2,616 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0204c68:	17100593          	li	a1,369
ffffffffc0204c6c:	00003517          	auipc	a0,0x3
ffffffffc0204c70:	55c50513          	addi	a0,a0,1372 # ffffffffc02081c8 <etext+0x197e>
ffffffffc0204c74:	801fb0ef          	jal	ffffffffc0200474 <__panic>
    return KADDR(page2pa(page));
ffffffffc0204c78:	00002617          	auipc	a2,0x2
ffffffffc0204c7c:	59860613          	addi	a2,a2,1432 # ffffffffc0207210 <etext+0x9c6>
ffffffffc0204c80:	06a00593          	li	a1,106
ffffffffc0204c84:	00002517          	auipc	a0,0x2
ffffffffc0204c88:	53c50513          	addi	a0,a0,1340 # ffffffffc02071c0 <etext+0x976>
ffffffffc0204c8c:	fe8fb0ef          	jal	ffffffffc0200474 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204c90:	00002617          	auipc	a2,0x2
ffffffffc0204c94:	51060613          	addi	a2,a2,1296 # ffffffffc02071a0 <etext+0x956>
ffffffffc0204c98:	06300593          	li	a1,99
ffffffffc0204c9c:	00002517          	auipc	a0,0x2
ffffffffc0204ca0:	52450513          	addi	a0,a0,1316 # ffffffffc02071c0 <etext+0x976>
ffffffffc0204ca4:	fd0fb0ef          	jal	ffffffffc0200474 <__panic>
    assert(sum == 0);
ffffffffc0204ca8:	00003697          	auipc	a3,0x3
ffffffffc0204cac:	76068693          	addi	a3,a3,1888 # ffffffffc0208408 <etext+0x1bbe>
ffffffffc0204cb0:	00002617          	auipc	a2,0x2
ffffffffc0204cb4:	21860613          	addi	a2,a2,536 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0204cb8:	16400593          	li	a1,356
ffffffffc0204cbc:	00003517          	auipc	a0,0x3
ffffffffc0204cc0:	50c50513          	addi	a0,a0,1292 # ffffffffc02081c8 <etext+0x197e>
ffffffffc0204cc4:	fb0fb0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc0204cc8 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0204cc8:	7139                	addi	sp,sp,-64
ffffffffc0204cca:	f04a                	sd	s2,32(sp)
ffffffffc0204ccc:	892e                	mv	s2,a1
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0204cce:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0204cd0:	f822                	sd	s0,48(sp)
ffffffffc0204cd2:	f426                	sd	s1,40(sp)
ffffffffc0204cd4:	fc06                	sd	ra,56(sp)
ffffffffc0204cd6:	8432                	mv	s0,a2
ffffffffc0204cd8:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0204cda:	803ff0ef          	jal	ffffffffc02044dc <find_vma>

    pgfault_num++;
ffffffffc0204cde:	00099797          	auipc	a5,0x99
ffffffffc0204ce2:	2fa7a783          	lw	a5,762(a5) # ffffffffc029dfd8 <pgfault_num>
ffffffffc0204ce6:	2785                	addiw	a5,a5,1
ffffffffc0204ce8:	00099717          	auipc	a4,0x99
ffffffffc0204cec:	2ef72823          	sw	a5,752(a4) # ffffffffc029dfd8 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0204cf0:	c94d                	beqz	a0,ffffffffc0204da2 <do_pgfault+0xda>
ffffffffc0204cf2:	651c                	ld	a5,8(a0)
ffffffffc0204cf4:	0af46763          	bltu	s0,a5,ffffffffc0204da2 <do_pgfault+0xda>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0204cf8:	4d1c                	lw	a5,24(a0)
ffffffffc0204cfa:	ec4e                	sd	s3,24(sp)
        perm |= READ_WRITE;
ffffffffc0204cfc:	49dd                	li	s3,23
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0204cfe:	8b89                	andi	a5,a5,2
ffffffffc0204d00:	c7ad                	beqz	a5,ffffffffc0204d6a <do_pgfault+0xa2>
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0204d02:	77fd                	lui	a5,0xfffff
    ret = -E_NO_MEM;

    pte_t *ptep=NULL;

    //判断页表项权限，如果有效但是不可写，跳转到COW
    if ((ptep = get_pte(mm->pgdir, addr, 0)) != NULL) {
ffffffffc0204d04:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0204d06:	8c7d                	and	s0,s0,a5
    if ((ptep = get_pte(mm->pgdir, addr, 0)) != NULL) {
ffffffffc0204d08:	4601                	li	a2,0
ffffffffc0204d0a:	85a2                	mv	a1,s0
ffffffffc0204d0c:	dfefd0ef          	jal	ffffffffc020230a <get_pte>
ffffffffc0204d10:	c501                	beqz	a0,ffffffffc0204d18 <do_pgfault+0x50>
        if((*ptep & PTE_V) & ~(*ptep & PTE_W)) {
ffffffffc0204d12:	611c                	ld	a5,0(a0)
ffffffffc0204d14:	8b85                	andi	a5,a5,1
ffffffffc0204d16:	ebbd                	bnez	a5,ffffffffc0204d8c <do_pgfault+0xc4>
        }
    }
  
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0204d18:	6c88                	ld	a0,24(s1)
ffffffffc0204d1a:	4605                	li	a2,1
ffffffffc0204d1c:	85a2                	mv	a1,s0
ffffffffc0204d1e:	decfd0ef          	jal	ffffffffc020230a <get_pte>
ffffffffc0204d22:	c145                	beqz	a0,ffffffffc0204dc2 <do_pgfault+0xfa>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc0204d24:	610c                	ld	a1,0(a0)
ffffffffc0204d26:	c5a1                	beqz	a1,ffffffffc0204d6e <do_pgfault+0xa6>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0204d28:	00099797          	auipc	a5,0x99
ffffffffc0204d2c:	2987a783          	lw	a5,664(a5) # ffffffffc029dfc0 <swap_init_ok>
ffffffffc0204d30:	c3d1                	beqz	a5,ffffffffc0204db4 <do_pgfault+0xec>
            struct Page *page = NULL;
            // 你要编写的内容在这里，请基于上文说明以及下文的英文注释完成代码编写
            //(1）According to the mm AND addr, try
            //to load the content of right disk page
            //into the memory which page managed.
            swap_in(mm,addr,&page);
ffffffffc0204d32:	0030                	addi	a2,sp,8
ffffffffc0204d34:	85a2                	mv	a1,s0
ffffffffc0204d36:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc0204d38:	e402                	sd	zero,8(sp)
            swap_in(mm,addr,&page);
ffffffffc0204d3a:	aa6ff0ef          	jal	ffffffffc0203fe0 <swap_in>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            page_insert(mm->pgdir,page,addr,perm);
ffffffffc0204d3e:	65a2                	ld	a1,8(sp)
ffffffffc0204d40:	6c88                	ld	a0,24(s1)
ffffffffc0204d42:	86ce                	mv	a3,s3
ffffffffc0204d44:	8622                	mv	a2,s0
ffffffffc0204d46:	c91fd0ef          	jal	ffffffffc02029d6 <page_insert>
            //(3) make the page swappable.
            swap_map_swappable(mm,addr,page,1);
ffffffffc0204d4a:	6622                	ld	a2,8(sp)
ffffffffc0204d4c:	4685                	li	a3,1
ffffffffc0204d4e:	85a2                	mv	a1,s0
ffffffffc0204d50:	8526                	mv	a0,s1
ffffffffc0204d52:	96cff0ef          	jal	ffffffffc0203ebe <swap_map_swappable>
            page->pra_vaddr = addr;//通常用于记录页面对应的虚拟地址
ffffffffc0204d56:	67a2                	ld	a5,8(sp)
ffffffffc0204d58:	ff80                	sd	s0,56(a5)
ffffffffc0204d5a:	69e2                	ld	s3,24(sp)
        } else {
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }
   ret = 0;
ffffffffc0204d5c:	4501                	li	a0,0
failed:
    return ret;
}
ffffffffc0204d5e:	70e2                	ld	ra,56(sp)
ffffffffc0204d60:	7442                	ld	s0,48(sp)
ffffffffc0204d62:	74a2                	ld	s1,40(sp)
ffffffffc0204d64:	7902                	ld	s2,32(sp)
ffffffffc0204d66:	6121                	addi	sp,sp,64
ffffffffc0204d68:	8082                	ret
    uint32_t perm = PTE_U;
ffffffffc0204d6a:	49c1                	li	s3,16
ffffffffc0204d6c:	bf59                	j	ffffffffc0204d02 <do_pgfault+0x3a>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0204d6e:	6c88                	ld	a0,24(s1)
ffffffffc0204d70:	864e                	mv	a2,s3
ffffffffc0204d72:	85a2                	mv	a1,s0
ffffffffc0204d74:	8f9fe0ef          	jal	ffffffffc020366c <pgdir_alloc_page>
ffffffffc0204d78:	f16d                	bnez	a0,ffffffffc0204d5a <do_pgfault+0x92>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0204d7a:	00003517          	auipc	a0,0x3
ffffffffc0204d7e:	74e50513          	addi	a0,a0,1870 # ffffffffc02084c8 <etext+0x1c7e>
ffffffffc0204d82:	bfefb0ef          	jal	ffffffffc0200180 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204d86:	69e2                	ld	s3,24(sp)
ffffffffc0204d88:	5571                	li	a0,-4
ffffffffc0204d8a:	bfd1                	j	ffffffffc0204d5e <do_pgfault+0x96>
            return cow_pgfault(mm, error_code, addr);
ffffffffc0204d8c:	8622                	mv	a2,s0
}
ffffffffc0204d8e:	7442                	ld	s0,48(sp)
            return cow_pgfault(mm, error_code, addr);
ffffffffc0204d90:	69e2                	ld	s3,24(sp)
}
ffffffffc0204d92:	70e2                	ld	ra,56(sp)
            return cow_pgfault(mm, error_code, addr);
ffffffffc0204d94:	85ca                	mv	a1,s2
ffffffffc0204d96:	8526                	mv	a0,s1
}
ffffffffc0204d98:	7902                	ld	s2,32(sp)
ffffffffc0204d9a:	74a2                	ld	s1,40(sp)
ffffffffc0204d9c:	6121                	addi	sp,sp,64
            return cow_pgfault(mm, error_code, addr);
ffffffffc0204d9e:	c3cfc06f          	j	ffffffffc02011da <cow_pgfault>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0204da2:	85a2                	mv	a1,s0
ffffffffc0204da4:	00003517          	auipc	a0,0x3
ffffffffc0204da8:	6d450513          	addi	a0,a0,1748 # ffffffffc0208478 <etext+0x1c2e>
ffffffffc0204dac:	bd4fb0ef          	jal	ffffffffc0200180 <cprintf>
    int ret = -E_INVAL;
ffffffffc0204db0:	5575                	li	a0,-3
        goto failed;
ffffffffc0204db2:	b775                	j	ffffffffc0204d5e <do_pgfault+0x96>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0204db4:	00003517          	auipc	a0,0x3
ffffffffc0204db8:	73c50513          	addi	a0,a0,1852 # ffffffffc02084f0 <etext+0x1ca6>
ffffffffc0204dbc:	bc4fb0ef          	jal	ffffffffc0200180 <cprintf>
            goto failed;
ffffffffc0204dc0:	b7d9                	j	ffffffffc0204d86 <do_pgfault+0xbe>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc0204dc2:	00003517          	auipc	a0,0x3
ffffffffc0204dc6:	6e650513          	addi	a0,a0,1766 # ffffffffc02084a8 <etext+0x1c5e>
ffffffffc0204dca:	bb6fb0ef          	jal	ffffffffc0200180 <cprintf>
        goto failed;
ffffffffc0204dce:	bf65                	j	ffffffffc0204d86 <do_pgfault+0xbe>

ffffffffc0204dd0 <user_mem_check>:

bool
user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write) {
ffffffffc0204dd0:	7179                	addi	sp,sp,-48
ffffffffc0204dd2:	f022                	sd	s0,32(sp)
ffffffffc0204dd4:	f406                	sd	ra,40(sp)
ffffffffc0204dd6:	842e                	mv	s0,a1
    // addr：内存检查的起始地址
    // len：内存检查的长度
    // write：是否进行写权限检查，如果为 true，则检查写权限；否则检查读权限

    // 如果提供了 mm（进程的内存管理结构体），即在用户空间
    if (mm != NULL) {
ffffffffc0204dd8:	c535                	beqz	a0,ffffffffc0204e44 <user_mem_check+0x74>
        // 检查该内存区段是否属于用户空间可访问的范围
        if (!USER_ACCESS(addr, addr + len)) {
ffffffffc0204dda:	002007b7          	lui	a5,0x200
ffffffffc0204dde:	04f5ee63          	bltu	a1,a5,ffffffffc0204e3a <user_mem_check+0x6a>
ffffffffc0204de2:	ec26                	sd	s1,24(sp)
ffffffffc0204de4:	00c584b3          	add	s1,a1,a2
ffffffffc0204de8:	0695fc63          	bgeu	a1,s1,ffffffffc0204e60 <user_mem_check+0x90>
ffffffffc0204dec:	4785                	li	a5,1
ffffffffc0204dee:	07fe                	slli	a5,a5,0x1f
ffffffffc0204df0:	0697e863          	bltu	a5,s1,ffffffffc0204e60 <user_mem_check+0x90>
ffffffffc0204df4:	e84a                	sd	s2,16(sp)
ffffffffc0204df6:	e44e                	sd	s3,8(sp)
ffffffffc0204df8:	e052                	sd	s4,0(sp)
ffffffffc0204dfa:	892a                	mv	s2,a0
ffffffffc0204dfc:	89b6                	mv	s3,a3

            // 如果是写操作并且该 VMA 是堆栈区域
            if (write && (vma->vm_flags & VM_STACK)) {
                // 检查堆栈是否被访问在合理的区域
                // 如果访问的地址小于堆栈起始地址 + 页面大小（PGSIZE），则返回 false
                if (start < vma->vm_start + PGSIZE) { 
ffffffffc0204dfe:	6a05                	lui	s4,0x1
ffffffffc0204e00:	a821                	j	ffffffffc0204e18 <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204e02:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE) { 
ffffffffc0204e06:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0204e08:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204e0a:	c685                	beqz	a3,ffffffffc0204e32 <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0204e0c:	c399                	beqz	a5,ffffffffc0204e12 <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE) { 
ffffffffc0204e0e:	02e46263          	bltu	s0,a4,ffffffffc0204e32 <user_mem_check+0x62>
                    return 0;  // 不允许访问堆栈的前面部分
                }
            }

            // 更新检查的起始地址为当前 VMA 的结束地址，继续检查下一个内存区域
            start = vma->vm_end;
ffffffffc0204e12:	6900                	ld	s0,16(a0)
        while (start < end) {
ffffffffc0204e14:	04947863          	bgeu	s0,s1,ffffffffc0204e64 <user_mem_check+0x94>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start) {
ffffffffc0204e18:	85a2                	mv	a1,s0
ffffffffc0204e1a:	854a                	mv	a0,s2
ffffffffc0204e1c:	ec0ff0ef          	jal	ffffffffc02044dc <find_vma>
ffffffffc0204e20:	c909                	beqz	a0,ffffffffc0204e32 <user_mem_check+0x62>
ffffffffc0204e22:	6518                	ld	a4,8(a0)
ffffffffc0204e24:	00e46763          	bltu	s0,a4,ffffffffc0204e32 <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204e28:	4d1c                	lw	a5,24(a0)
ffffffffc0204e2a:	fc099ce3          	bnez	s3,ffffffffc0204e02 <user_mem_check+0x32>
ffffffffc0204e2e:	8b85                	andi	a5,a5,1
ffffffffc0204e30:	f3ed                	bnez	a5,ffffffffc0204e12 <user_mem_check+0x42>
ffffffffc0204e32:	64e2                	ld	s1,24(sp)
ffffffffc0204e34:	6942                	ld	s2,16(sp)
ffffffffc0204e36:	69a2                	ld	s3,8(sp)
ffffffffc0204e38:	6a02                	ld	s4,0(sp)
            return 0;  // 如果不可访问，返回 false
ffffffffc0204e3a:	4501                	li	a0,0
        return 1;
    }

    // 如果 mm 为 NULL，表示当前检查的是内核空间的地址，则调用内核访问检查函数
    return KERN_ACCESS(addr, addr + len);
}
ffffffffc0204e3c:	70a2                	ld	ra,40(sp)
ffffffffc0204e3e:	7402                	ld	s0,32(sp)
ffffffffc0204e40:	6145                	addi	sp,sp,48
ffffffffc0204e42:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc0204e44:	c02007b7          	lui	a5,0xc0200
ffffffffc0204e48:	4501                	li	a0,0
ffffffffc0204e4a:	fef5e9e3          	bltu	a1,a5,ffffffffc0204e3c <user_mem_check+0x6c>
ffffffffc0204e4e:	962e                	add	a2,a2,a1
ffffffffc0204e50:	fec5f6e3          	bgeu	a1,a2,ffffffffc0204e3c <user_mem_check+0x6c>
ffffffffc0204e54:	c8000537          	lui	a0,0xc8000
ffffffffc0204e58:	0505                	addi	a0,a0,1 # ffffffffc8000001 <end+0x7d61ff9>
ffffffffc0204e5a:	00a63533          	sltu	a0,a2,a0
ffffffffc0204e5e:	bff9                	j	ffffffffc0204e3c <user_mem_check+0x6c>
ffffffffc0204e60:	64e2                	ld	s1,24(sp)
ffffffffc0204e62:	bfe1                	j	ffffffffc0204e3a <user_mem_check+0x6a>
ffffffffc0204e64:	64e2                	ld	s1,24(sp)
ffffffffc0204e66:	6942                	ld	s2,16(sp)
ffffffffc0204e68:	69a2                	ld	s3,8(sp)
ffffffffc0204e6a:	6a02                	ld	s4,0(sp)
        return 1;
ffffffffc0204e6c:	4505                	li	a0,1
ffffffffc0204e6e:	b7f9                	j	ffffffffc0204e3c <user_mem_check+0x6c>

ffffffffc0204e70 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0204e70:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204e72:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0204e74:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204e76:	f70fb0ef          	jal	ffffffffc02005e6 <ide_device_valid>
ffffffffc0204e7a:	cd01                	beqz	a0,ffffffffc0204e92 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204e7c:	4505                	li	a0,1
ffffffffc0204e7e:	f6efb0ef          	jal	ffffffffc02005ec <ide_device_size>
}
ffffffffc0204e82:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204e84:	810d                	srli	a0,a0,0x3
ffffffffc0204e86:	00099797          	auipc	a5,0x99
ffffffffc0204e8a:	14a7b123          	sd	a0,322(a5) # ffffffffc029dfc8 <max_swap_offset>
}
ffffffffc0204e8e:	0141                	addi	sp,sp,16
ffffffffc0204e90:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0204e92:	00003617          	auipc	a2,0x3
ffffffffc0204e96:	68660613          	addi	a2,a2,1670 # ffffffffc0208518 <etext+0x1cce>
ffffffffc0204e9a:	45b5                	li	a1,13
ffffffffc0204e9c:	00003517          	auipc	a0,0x3
ffffffffc0204ea0:	69c50513          	addi	a0,a0,1692 # ffffffffc0208538 <etext+0x1cee>
ffffffffc0204ea4:	dd0fb0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc0204ea8 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0204ea8:	1141                	addi	sp,sp,-16
ffffffffc0204eaa:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204eac:	00855793          	srli	a5,a0,0x8
ffffffffc0204eb0:	cbb1                	beqz	a5,ffffffffc0204f04 <swapfs_read+0x5c>
ffffffffc0204eb2:	00099717          	auipc	a4,0x99
ffffffffc0204eb6:	11673703          	ld	a4,278(a4) # ffffffffc029dfc8 <max_swap_offset>
ffffffffc0204eba:	04e7f563          	bgeu	a5,a4,ffffffffc0204f04 <swapfs_read+0x5c>
    return page - pages + nbase;
ffffffffc0204ebe:	00099717          	auipc	a4,0x99
ffffffffc0204ec2:	0fa73703          	ld	a4,250(a4) # ffffffffc029dfb8 <pages>
ffffffffc0204ec6:	8d99                	sub	a1,a1,a4
ffffffffc0204ec8:	4065d613          	srai	a2,a1,0x6
ffffffffc0204ecc:	00004717          	auipc	a4,0x4
ffffffffc0204ed0:	08473703          	ld	a4,132(a4) # ffffffffc0208f50 <nbase>
ffffffffc0204ed4:	963a                	add	a2,a2,a4
    return KADDR(page2pa(page));
ffffffffc0204ed6:	00c61713          	slli	a4,a2,0xc
ffffffffc0204eda:	8331                	srli	a4,a4,0xc
ffffffffc0204edc:	00099697          	auipc	a3,0x99
ffffffffc0204ee0:	0d46b683          	ld	a3,212(a3) # ffffffffc029dfb0 <npage>
ffffffffc0204ee4:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204ee8:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204eea:	02d77963          	bgeu	a4,a3,ffffffffc0204f1c <swapfs_read+0x74>
}
ffffffffc0204eee:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204ef0:	00099797          	auipc	a5,0x99
ffffffffc0204ef4:	0b87b783          	ld	a5,184(a5) # ffffffffc029dfa8 <va_pa_offset>
ffffffffc0204ef8:	46a1                	li	a3,8
ffffffffc0204efa:	963e                	add	a2,a2,a5
ffffffffc0204efc:	4505                	li	a0,1
}
ffffffffc0204efe:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204f00:	ef2fb06f          	j	ffffffffc02005f2 <ide_read_secs>
ffffffffc0204f04:	86aa                	mv	a3,a0
ffffffffc0204f06:	00003617          	auipc	a2,0x3
ffffffffc0204f0a:	64a60613          	addi	a2,a2,1610 # ffffffffc0208550 <etext+0x1d06>
ffffffffc0204f0e:	45d1                	li	a1,20
ffffffffc0204f10:	00003517          	auipc	a0,0x3
ffffffffc0204f14:	62850513          	addi	a0,a0,1576 # ffffffffc0208538 <etext+0x1cee>
ffffffffc0204f18:	d5cfb0ef          	jal	ffffffffc0200474 <__panic>
ffffffffc0204f1c:	86b2                	mv	a3,a2
ffffffffc0204f1e:	06a00593          	li	a1,106
ffffffffc0204f22:	00002617          	auipc	a2,0x2
ffffffffc0204f26:	2ee60613          	addi	a2,a2,750 # ffffffffc0207210 <etext+0x9c6>
ffffffffc0204f2a:	00002517          	auipc	a0,0x2
ffffffffc0204f2e:	29650513          	addi	a0,a0,662 # ffffffffc02071c0 <etext+0x976>
ffffffffc0204f32:	d42fb0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc0204f36 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0204f36:	1141                	addi	sp,sp,-16
ffffffffc0204f38:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204f3a:	00855793          	srli	a5,a0,0x8
ffffffffc0204f3e:	cbb1                	beqz	a5,ffffffffc0204f92 <swapfs_write+0x5c>
ffffffffc0204f40:	00099717          	auipc	a4,0x99
ffffffffc0204f44:	08873703          	ld	a4,136(a4) # ffffffffc029dfc8 <max_swap_offset>
ffffffffc0204f48:	04e7f563          	bgeu	a5,a4,ffffffffc0204f92 <swapfs_write+0x5c>
    return page - pages + nbase;
ffffffffc0204f4c:	00099717          	auipc	a4,0x99
ffffffffc0204f50:	06c73703          	ld	a4,108(a4) # ffffffffc029dfb8 <pages>
ffffffffc0204f54:	8d99                	sub	a1,a1,a4
ffffffffc0204f56:	4065d613          	srai	a2,a1,0x6
ffffffffc0204f5a:	00004717          	auipc	a4,0x4
ffffffffc0204f5e:	ff673703          	ld	a4,-10(a4) # ffffffffc0208f50 <nbase>
ffffffffc0204f62:	963a                	add	a2,a2,a4
    return KADDR(page2pa(page));
ffffffffc0204f64:	00c61713          	slli	a4,a2,0xc
ffffffffc0204f68:	8331                	srli	a4,a4,0xc
ffffffffc0204f6a:	00099697          	auipc	a3,0x99
ffffffffc0204f6e:	0466b683          	ld	a3,70(a3) # ffffffffc029dfb0 <npage>
ffffffffc0204f72:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204f76:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204f78:	02d77963          	bgeu	a4,a3,ffffffffc0204faa <swapfs_write+0x74>
}
ffffffffc0204f7c:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204f7e:	00099797          	auipc	a5,0x99
ffffffffc0204f82:	02a7b783          	ld	a5,42(a5) # ffffffffc029dfa8 <va_pa_offset>
ffffffffc0204f86:	46a1                	li	a3,8
ffffffffc0204f88:	963e                	add	a2,a2,a5
ffffffffc0204f8a:	4505                	li	a0,1
}
ffffffffc0204f8c:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204f8e:	e88fb06f          	j	ffffffffc0200616 <ide_write_secs>
ffffffffc0204f92:	86aa                	mv	a3,a0
ffffffffc0204f94:	00003617          	auipc	a2,0x3
ffffffffc0204f98:	5bc60613          	addi	a2,a2,1468 # ffffffffc0208550 <etext+0x1d06>
ffffffffc0204f9c:	45e5                	li	a1,25
ffffffffc0204f9e:	00003517          	auipc	a0,0x3
ffffffffc0204fa2:	59a50513          	addi	a0,a0,1434 # ffffffffc0208538 <etext+0x1cee>
ffffffffc0204fa6:	ccefb0ef          	jal	ffffffffc0200474 <__panic>
ffffffffc0204faa:	86b2                	mv	a3,a2
ffffffffc0204fac:	06a00593          	li	a1,106
ffffffffc0204fb0:	00002617          	auipc	a2,0x2
ffffffffc0204fb4:	26060613          	addi	a2,a2,608 # ffffffffc0207210 <etext+0x9c6>
ffffffffc0204fb8:	00002517          	auipc	a0,0x2
ffffffffc0204fbc:	20850513          	addi	a0,a0,520 # ffffffffc02071c0 <etext+0x976>
ffffffffc0204fc0:	cb4fb0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc0204fc4 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0204fc4:	8526                	mv	a0,s1
	jalr s0
ffffffffc0204fc6:	9402                	jalr	s0

	jal do_exit
ffffffffc0204fc8:	4f8000ef          	jal	ffffffffc02054c0 <do_exit>

ffffffffc0204fcc <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
ffffffffc0204fcc:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204fce:	10800513          	li	a0,264
alloc_proc(void) {
ffffffffc0204fd2:	e022                	sd	s0,0(sp)
ffffffffc0204fd4:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204fd6:	852fd0ef          	jal	ffffffffc0202028 <kmalloc>
ffffffffc0204fda:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc0204fdc:	cd21                	beqz	a0,ffffffffc0205034 <alloc_proc+0x68>
     *       struct trapframe *tf;                       // Trap frame for current interrupt
     *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
     *       uint32_t flags;                             // Process flag
     *       char name[PROC_NAME_LEN + 1];               // Process name
     */
    	proc->state=PROC_UNINIT;//给进程设置为未初始化状态
ffffffffc0204fde:	57fd                	li	a5,-1
ffffffffc0204fe0:	1782                	slli	a5,a5,0x20
ffffffffc0204fe2:	e11c                	sd	a5,0(a0)
    	proc->pid=-1;//为初始化进程为-1
    	proc->runs=0;
ffffffffc0204fe4:	00052423          	sw	zero,8(a0)
    	proc->kstack=0;//初始化内核栈地址为 0，稍后会在创建栈时赋值。
ffffffffc0204fe8:	00053823          	sd	zero,16(a0)
    	proc->need_resched=0;//默认不需要调度
ffffffffc0204fec:	00053c23          	sd	zero,24(a0)
    	proc->parent=NULL;//父进程为空
ffffffffc0204ff0:	02053023          	sd	zero,32(a0)
    	proc->mm=NULL;//初始化内存管理结构为 NULL，稍后需要分配具体的内存管理结构。
ffffffffc0204ff4:	02053423          	sd	zero,40(a0)
    	memset(&(proc->context),0,sizeof(struct context));//初始化上下文
ffffffffc0204ff8:	07000613          	li	a2,112
ffffffffc0204ffc:	4581                	li	a1,0
ffffffffc0204ffe:	03050513          	addi	a0,a0,48
ffffffffc0205002:	01f010ef          	jal	ffffffffc0206820 <memset>
    	proc->tf=NULL;//初始化陷阱帧为 NULL，稍后需要分配具体的陷阱帧结构。    	
        proc->cr3 = boot_cr3;      // 使用内核页目录表的基址
ffffffffc0205006:	00099797          	auipc	a5,0x99
ffffffffc020500a:	f927b783          	ld	a5,-110(a5) # ffffffffc029df98 <boot_cr3>
    	proc->tf=NULL;//初始化陷阱帧为 NULL，稍后需要分配具体的陷阱帧结构。    	
ffffffffc020500e:	0a043023          	sd	zero,160(s0)
        proc->cr3 = boot_cr3;      // 使用内核页目录表的基址
ffffffffc0205012:	f45c                	sd	a5,168(s0)
        proc->flags=0;//无特殊标志位
ffffffffc0205014:	0a042823          	sw	zero,176(s0)
        memset(&(proc->name),0,PROC_NAME_LEN + 1); // 初始化进程名为空字符串
ffffffffc0205018:	4641                	li	a2,16
ffffffffc020501a:	4581                	li	a1,0
ffffffffc020501c:	0b440513          	addi	a0,s0,180
ffffffffc0205020:	001010ef          	jal	ffffffffc0206820 <memset>
     /*
     * below fields(add in LAB5) in proc_struct need to be initialized  
     *       uint32_t wait_state;                        // waiting state
     *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
     */
    proc->wait_state = 0;
ffffffffc0205024:	0e042623          	sw	zero,236(s0)
    cptr：子进程指针。
    optr：兄弟进程指针（older sibling）。
    yptr：兄弟进程指针（younger sibling）。
    三者初始化为 NULL，稍后可以根据进程关系进行赋值。
    */
    proc->cptr = NULL;
ffffffffc0205028:	0e043823          	sd	zero,240(s0)
    proc->optr = NULL;
ffffffffc020502c:	10043023          	sd	zero,256(s0)
    proc->yptr = NULL;  
ffffffffc0205030:	0e043c23          	sd	zero,248(s0)
    }
    return proc;
}
ffffffffc0205034:	60a2                	ld	ra,8(sp)
ffffffffc0205036:	8522                	mv	a0,s0
ffffffffc0205038:	6402                	ld	s0,0(sp)
ffffffffc020503a:	0141                	addi	sp,sp,16
ffffffffc020503c:	8082                	ret

ffffffffc020503e <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
ffffffffc020503e:	00099797          	auipc	a5,0x99
ffffffffc0205042:	fb27b783          	ld	a5,-78(a5) # ffffffffc029dff0 <current>
ffffffffc0205046:	73c8                	ld	a0,160(a5)
ffffffffc0205048:	d13fb06f          	j	ffffffffc0200d5a <forkrets>

ffffffffc020504c <user_main>:
//这么一个函数。这时user_main就从内核进程变成了用户进程
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);// 如果定义了 TEST 宏，则执行指定的测试程序
    // KERNEL_EXECVE2 是一个宏，用于加载和执行 TEST 指定的程序
#else
    KERNEL_EXECVE(exit);// 否则，执行 exit 程序，通常是退出程序
ffffffffc020504c:	00099797          	auipc	a5,0x99
ffffffffc0205050:	fa47b783          	ld	a5,-92(a5) # ffffffffc029dff0 <current>
ffffffffc0205054:	43cc                	lw	a1,4(a5)
user_main(void *arg) {//于是，我们在user_main()所做的，就是执行了
ffffffffc0205056:	7139                	addi	sp,sp,-64
    KERNEL_EXECVE(exit);// 否则，执行 exit 程序，通常是退出程序
ffffffffc0205058:	00003617          	auipc	a2,0x3
ffffffffc020505c:	51860613          	addi	a2,a2,1304 # ffffffffc0208570 <etext+0x1d26>
ffffffffc0205060:	00003517          	auipc	a0,0x3
ffffffffc0205064:	51850513          	addi	a0,a0,1304 # ffffffffc0208578 <etext+0x1d2e>
user_main(void *arg) {//于是，我们在user_main()所做的，就是执行了
ffffffffc0205068:	fc06                	sd	ra,56(sp)
    KERNEL_EXECVE(exit);// 否则，执行 exit 程序，通常是退出程序
ffffffffc020506a:	916fb0ef          	jal	ffffffffc0200180 <cprintf>
ffffffffc020506e:	3fe05797          	auipc	a5,0x3fe05
ffffffffc0205072:	b3278793          	addi	a5,a5,-1230 # 9ba0 <_binary_obj___user_exit_out_size>
ffffffffc0205076:	e43e                	sd	a5,8(sp)
ffffffffc0205078:	00003517          	auipc	a0,0x3
ffffffffc020507c:	4f850513          	addi	a0,a0,1272 # ffffffffc0208570 <etext+0x1d26>
ffffffffc0205080:	00022797          	auipc	a5,0x22
ffffffffc0205084:	1b078793          	addi	a5,a5,432 # ffffffffc0227230 <_binary_obj___user_exit_out_start>
ffffffffc0205088:	f03e                	sd	a5,32(sp)
ffffffffc020508a:	f42a                	sd	a0,40(sp)
    int64_t ret = 0, len = strlen(name);
ffffffffc020508c:	e802                	sd	zero,16(sp)
ffffffffc020508e:	6fc010ef          	jal	ffffffffc020678a <strlen>
ffffffffc0205092:	ec2a                	sd	a0,24(sp)
    asm volatile(
ffffffffc0205094:	4511                	li	a0,4
ffffffffc0205096:	55a2                	lw	a1,40(sp)
ffffffffc0205098:	4662                	lw	a2,24(sp)
ffffffffc020509a:	5682                	lw	a3,32(sp)
ffffffffc020509c:	4722                	lw	a4,8(sp)
ffffffffc020509e:	48a9                	li	a7,10
ffffffffc02050a0:	9002                	ebreak
ffffffffc02050a2:	c82a                	sw	a0,16(sp)
    cprintf("ret = %d\n", ret);
ffffffffc02050a4:	65c2                	ld	a1,16(sp)
ffffffffc02050a6:	00003517          	auipc	a0,0x3
ffffffffc02050aa:	4fa50513          	addi	a0,a0,1274 # ffffffffc02085a0 <etext+0x1d56>
ffffffffc02050ae:	8d2fb0ef          	jal	ffffffffc0200180 <cprintf>
#endif
    panic("user_main execve failed.\n");// 如果 execve 调用失败，触发 panic
ffffffffc02050b2:	00003617          	auipc	a2,0x3
ffffffffc02050b6:	4fe60613          	addi	a2,a2,1278 # ffffffffc02085b0 <etext+0x1d66>
ffffffffc02050ba:	3dd00593          	li	a1,989
ffffffffc02050be:	00003517          	auipc	a0,0x3
ffffffffc02050c2:	51250513          	addi	a0,a0,1298 # ffffffffc02085d0 <etext+0x1d86>
ffffffffc02050c6:	baefb0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc02050ca <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc02050ca:	6d14                	ld	a3,24(a0)
put_pgdir(struct mm_struct *mm) {
ffffffffc02050cc:	1141                	addi	sp,sp,-16
ffffffffc02050ce:	e406                	sd	ra,8(sp)
ffffffffc02050d0:	c02007b7          	lui	a5,0xc0200
ffffffffc02050d4:	02f6ee63          	bltu	a3,a5,ffffffffc0205110 <put_pgdir+0x46>
ffffffffc02050d8:	00099797          	auipc	a5,0x99
ffffffffc02050dc:	ed07b783          	ld	a5,-304(a5) # ffffffffc029dfa8 <va_pa_offset>
ffffffffc02050e0:	8e9d                	sub	a3,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc02050e2:	82b1                	srli	a3,a3,0xc
ffffffffc02050e4:	00099797          	auipc	a5,0x99
ffffffffc02050e8:	ecc7b783          	ld	a5,-308(a5) # ffffffffc029dfb0 <npage>
ffffffffc02050ec:	02f6fe63          	bgeu	a3,a5,ffffffffc0205128 <put_pgdir+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc02050f0:	00004797          	auipc	a5,0x4
ffffffffc02050f4:	e607b783          	ld	a5,-416(a5) # ffffffffc0208f50 <nbase>
}
ffffffffc02050f8:	60a2                	ld	ra,8(sp)
ffffffffc02050fa:	8e9d                	sub	a3,a3,a5
    free_page(kva2page(mm->pgdir));
ffffffffc02050fc:	00099517          	auipc	a0,0x99
ffffffffc0205100:	ebc53503          	ld	a0,-324(a0) # ffffffffc029dfb8 <pages>
ffffffffc0205104:	069a                	slli	a3,a3,0x6
ffffffffc0205106:	4585                	li	a1,1
ffffffffc0205108:	9536                	add	a0,a0,a3
}
ffffffffc020510a:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc020510c:	984fd06f          	j	ffffffffc0202290 <free_pages>
    return pa2page(PADDR(kva));
ffffffffc0205110:	00002617          	auipc	a2,0x2
ffffffffc0205114:	15060613          	addi	a2,a2,336 # ffffffffc0207260 <etext+0xa16>
ffffffffc0205118:	06f00593          	li	a1,111
ffffffffc020511c:	00002517          	auipc	a0,0x2
ffffffffc0205120:	0a450513          	addi	a0,a0,164 # ffffffffc02071c0 <etext+0x976>
ffffffffc0205124:	b50fb0ef          	jal	ffffffffc0200474 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0205128:	00002617          	auipc	a2,0x2
ffffffffc020512c:	07860613          	addi	a2,a2,120 # ffffffffc02071a0 <etext+0x956>
ffffffffc0205130:	06300593          	li	a1,99
ffffffffc0205134:	00002517          	auipc	a0,0x2
ffffffffc0205138:	08c50513          	addi	a0,a0,140 # ffffffffc02071c0 <etext+0x976>
ffffffffc020513c:	b38fb0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc0205140 <proc_run>:
proc_run(struct proc_struct *proc) {
ffffffffc0205140:	7179                	addi	sp,sp,-48
ffffffffc0205142:	ec4a                	sd	s2,24(sp)
    if (proc != current) {
ffffffffc0205144:	00099917          	auipc	s2,0x99
ffffffffc0205148:	eac90913          	addi	s2,s2,-340 # ffffffffc029dff0 <current>
proc_run(struct proc_struct *proc) {
ffffffffc020514c:	f026                	sd	s1,32(sp)
    if (proc != current) {
ffffffffc020514e:	00093483          	ld	s1,0(s2)
proc_run(struct proc_struct *proc) {
ffffffffc0205152:	f406                	sd	ra,40(sp)
    if (proc != current) {
ffffffffc0205154:	02a48a63          	beq	s1,a0,ffffffffc0205188 <proc_run+0x48>
ffffffffc0205158:	e84e                	sd	s3,16(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020515a:	100027f3          	csrr	a5,sstatus
ffffffffc020515e:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205160:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205162:	ef9d                	bnez	a5,ffffffffc02051a0 <proc_run+0x60>

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned long cr3) {
    write_csr(satp, 0x8000000000000000 | (cr3 >> RISCV_PGSHIFT));
ffffffffc0205164:	755c                	ld	a5,168(a0)
ffffffffc0205166:	577d                	li	a4,-1
ffffffffc0205168:	177e                	slli	a4,a4,0x3f
ffffffffc020516a:	83b1                	srli	a5,a5,0xc
            current=proc;
ffffffffc020516c:	00a93023          	sd	a0,0(s2)
ffffffffc0205170:	8fd9                	or	a5,a5,a4
ffffffffc0205172:	18079073          	csrw	satp,a5
             switch_to(&(prev->context), &(proc->context));//切换上下文
ffffffffc0205176:	03050593          	addi	a1,a0,48
ffffffffc020517a:	03048513          	addi	a0,s1,48
ffffffffc020517e:	79f000ef          	jal	ffffffffc020611c <switch_to>
    if (flag) {
ffffffffc0205182:	00099863          	bnez	s3,ffffffffc0205192 <proc_run+0x52>
ffffffffc0205186:	69c2                	ld	s3,16(sp)
}
ffffffffc0205188:	70a2                	ld	ra,40(sp)
ffffffffc020518a:	7482                	ld	s1,32(sp)
ffffffffc020518c:	6962                	ld	s2,24(sp)
ffffffffc020518e:	6145                	addi	sp,sp,48
ffffffffc0205190:	8082                	ret
        intr_enable();
ffffffffc0205192:	69c2                	ld	s3,16(sp)
ffffffffc0205194:	70a2                	ld	ra,40(sp)
ffffffffc0205196:	7482                	ld	s1,32(sp)
ffffffffc0205198:	6962                	ld	s2,24(sp)
ffffffffc020519a:	6145                	addi	sp,sp,48
ffffffffc020519c:	c9efb06f          	j	ffffffffc020063a <intr_enable>
ffffffffc02051a0:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02051a2:	c9efb0ef          	jal	ffffffffc0200640 <intr_disable>
        return 1;
ffffffffc02051a6:	6522                	ld	a0,8(sp)
ffffffffc02051a8:	4985                	li	s3,1
ffffffffc02051aa:	bf6d                	j	ffffffffc0205164 <proc_run+0x24>

ffffffffc02051ac <do_fork>:
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {//创建一个新的子进程，复制当前进程的内核栈、内存管理结构和运行状态。
ffffffffc02051ac:	715d                	addi	sp,sp,-80
ffffffffc02051ae:	f84a                	sd	s2,48(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc02051b0:	00099917          	auipc	s2,0x99
ffffffffc02051b4:	e3890913          	addi	s2,s2,-456 # ffffffffc029dfe8 <nr_process>
ffffffffc02051b8:	00092703          	lw	a4,0(s2)
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {//创建一个新的子进程，复制当前进程的内核栈、内存管理结构和运行状态。
ffffffffc02051bc:	e486                	sd	ra,72(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc02051be:	6785                	lui	a5,0x1
ffffffffc02051c0:	22f75e63          	bge	a4,a5,ffffffffc02053fc <do_fork+0x250>
ffffffffc02051c4:	e0a2                	sd	s0,64(sp)
ffffffffc02051c6:	fc26                	sd	s1,56(sp)
ffffffffc02051c8:	f44e                	sd	s3,40(sp)
ffffffffc02051ca:	8432                	mv	s0,a2
    proc=alloc_proc();
ffffffffc02051cc:	89ae                	mv	s3,a1
ffffffffc02051ce:	dffff0ef          	jal	ffffffffc0204fcc <alloc_proc>
ffffffffc02051d2:	84aa                	mv	s1,a0
    if(proc==NULL){
ffffffffc02051d4:	20050f63          	beqz	a0,ffffffffc02053f2 <do_fork+0x246>
    proc->parent = current;//将子进程的父节点设置为当前进程
ffffffffc02051d8:	00099797          	auipc	a5,0x99
ffffffffc02051dc:	e187b783          	ld	a5,-488(a5) # ffffffffc029dff0 <current>
    assert(current->wait_state == 0);
ffffffffc02051e0:	0ec7a703          	lw	a4,236(a5)
    proc->parent = current;//将子进程的父节点设置为当前进程
ffffffffc02051e4:	f11c                	sd	a5,32(a0)
    assert(current->wait_state == 0);
ffffffffc02051e6:	20071d63          	bnez	a4,ffffffffc0205400 <do_fork+0x254>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc02051ea:	4509                	li	a0,2
ffffffffc02051ec:	814fd0ef          	jal	ffffffffc0202200 <alloc_pages>
    if (page != NULL) {
ffffffffc02051f0:	1e050e63          	beqz	a0,ffffffffc02053ec <do_fork+0x240>
    return page - pages + nbase;
ffffffffc02051f4:	e85a                	sd	s6,16(sp)
ffffffffc02051f6:	00099b17          	auipc	s6,0x99
ffffffffc02051fa:	dc2b0b13          	addi	s6,s6,-574 # ffffffffc029dfb8 <pages>
ffffffffc02051fe:	000b3783          	ld	a5,0(s6)
ffffffffc0205202:	f052                	sd	s4,32(sp)
ffffffffc0205204:	e45e                	sd	s7,8(sp)
ffffffffc0205206:	40f506b3          	sub	a3,a0,a5
ffffffffc020520a:	00004a17          	auipc	s4,0x4
ffffffffc020520e:	d46a3a03          	ld	s4,-698(s4) # ffffffffc0208f50 <nbase>
    return KADDR(page2pa(page));
ffffffffc0205212:	00099b97          	auipc	s7,0x99
ffffffffc0205216:	d9eb8b93          	addi	s7,s7,-610 # ffffffffc029dfb0 <npage>
    return page - pages + nbase;
ffffffffc020521a:	8699                	srai	a3,a3,0x6
ffffffffc020521c:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc020521e:	000bb703          	ld	a4,0(s7)
ffffffffc0205222:	00c69793          	slli	a5,a3,0xc
ffffffffc0205226:	ec56                	sd	s5,24(sp)
ffffffffc0205228:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020522a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020522c:	1ee7fe63          	bgeu	a5,a4,ffffffffc0205428 <do_fork+0x27c>
ffffffffc0205230:	00099a97          	auipc	s5,0x99
ffffffffc0205234:	d78a8a93          	addi	s5,s5,-648 # ffffffffc029dfa8 <va_pa_offset>
ffffffffc0205238:	000ab783          	ld	a5,0(s5)
    if(cow_copy_mm(proc) != 0) {
ffffffffc020523c:	8526                	mv	a0,s1
ffffffffc020523e:	97b6                	add	a5,a5,a3
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc0205240:	e89c                	sd	a5,16(s1)
    if(cow_copy_mm(proc) != 0) {
ffffffffc0205242:	db1fb0ef          	jal	ffffffffc0200ff2 <cow_copy_mm>
ffffffffc0205246:	16051863          	bnez	a0,ffffffffc02053b6 <do_fork+0x20a>
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc020524a:	6898                	ld	a4,16(s1)
ffffffffc020524c:	6789                	lui	a5,0x2
ffffffffc020524e:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_softint_out_size-0x6758>
ffffffffc0205252:	973e                	add	a4,a4,a5
    *(proc->tf) = *tf;
ffffffffc0205254:	8622                	mv	a2,s0
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0205256:	f0d8                	sd	a4,160(s1)
    *(proc->tf) = *tf;
ffffffffc0205258:	87ba                	mv	a5,a4
ffffffffc020525a:	12040893          	addi	a7,s0,288
ffffffffc020525e:	00063803          	ld	a6,0(a2)
ffffffffc0205262:	6608                	ld	a0,8(a2)
ffffffffc0205264:	6a0c                	ld	a1,16(a2)
ffffffffc0205266:	6e14                	ld	a3,24(a2)
ffffffffc0205268:	0107b023          	sd	a6,0(a5)
ffffffffc020526c:	e788                	sd	a0,8(a5)
ffffffffc020526e:	eb8c                	sd	a1,16(a5)
ffffffffc0205270:	ef94                	sd	a3,24(a5)
ffffffffc0205272:	02060613          	addi	a2,a2,32
ffffffffc0205276:	02078793          	addi	a5,a5,32
ffffffffc020527a:	ff1612e3          	bne	a2,a7,ffffffffc020525e <do_fork+0xb2>
    proc->tf->gpr.a0 = 0;
ffffffffc020527e:	04073823          	sd	zero,80(a4)
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0205282:	12098263          	beqz	s3,ffffffffc02053a6 <do_fork+0x1fa>
    if (++ last_pid >= MAX_PID) {
ffffffffc0205286:	0008e817          	auipc	a6,0x8e
ffffffffc020528a:	81e80813          	addi	a6,a6,-2018 # ffffffffc0292aa4 <last_pid.1>
ffffffffc020528e:	00082783          	lw	a5,0(a6)
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0205292:	01373823          	sd	s3,16(a4)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0205296:	00000697          	auipc	a3,0x0
ffffffffc020529a:	da868693          	addi	a3,a3,-600 # ffffffffc020503e <forkret>
    if (++ last_pid >= MAX_PID) {
ffffffffc020529e:	0017851b          	addiw	a0,a5,1
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02052a2:	f894                	sd	a3,48(s1)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc02052a4:	fc98                	sd	a4,56(s1)
    if (++ last_pid >= MAX_PID) {
ffffffffc02052a6:	00a82023          	sw	a0,0(a6)
ffffffffc02052aa:	6789                	lui	a5,0x2
ffffffffc02052ac:	08f55763          	bge	a0,a5,ffffffffc020533a <do_fork+0x18e>
    if (last_pid >= next_safe) {
ffffffffc02052b0:	0008d317          	auipc	t1,0x8d
ffffffffc02052b4:	7f030313          	addi	t1,t1,2032 # ffffffffc0292aa0 <next_safe.0>
ffffffffc02052b8:	00032783          	lw	a5,0(t1)
ffffffffc02052bc:	00099417          	auipc	s0,0x99
ffffffffc02052c0:	ca440413          	addi	s0,s0,-860 # ffffffffc029df60 <proc_list>
ffffffffc02052c4:	08f55363          	bge	a0,a5,ffffffffc020534a <do_fork+0x19e>
    proc->pid=get_pid();//获取当前进程PID
ffffffffc02052c8:	c0c8                	sw	a0,4(s1)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc02052ca:	45a9                	li	a1,10
ffffffffc02052cc:	2501                	sext.w	a0,a0
ffffffffc02052ce:	0be010ef          	jal	ffffffffc020638c <hash32>
ffffffffc02052d2:	02051793          	slli	a5,a0,0x20
ffffffffc02052d6:	01c7d513          	srli	a0,a5,0x1c
ffffffffc02052da:	00095797          	auipc	a5,0x95
ffffffffc02052de:	c8678793          	addi	a5,a5,-890 # ffffffffc0299f60 <hash_list>
ffffffffc02052e2:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc02052e4:	650c                	ld	a1,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc02052e6:	7094                	ld	a3,32(s1)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc02052e8:	0d848793          	addi	a5,s1,216
    prev->next = next->prev = elm;
ffffffffc02052ec:	e19c                	sd	a5,0(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc02052ee:	6410                	ld	a2,8(s0)
    prev->next = next->prev = elm;
ffffffffc02052f0:	e51c                	sd	a5,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc02052f2:	7af8                	ld	a4,240(a3)
    list_add(&proc_list, &(proc->list_link));
ffffffffc02052f4:	0c848793          	addi	a5,s1,200
    elm->next = next;
ffffffffc02052f8:	f0ec                	sd	a1,224(s1)
    elm->prev = prev;
ffffffffc02052fa:	ece8                	sd	a0,216(s1)
    prev->next = next->prev = elm;
ffffffffc02052fc:	e21c                	sd	a5,0(a2)
ffffffffc02052fe:	e41c                	sd	a5,8(s0)
    elm->next = next;
ffffffffc0205300:	e8f0                	sd	a2,208(s1)
    elm->prev = prev;
ffffffffc0205302:	e4e0                	sd	s0,200(s1)
    proc->yptr = NULL;
ffffffffc0205304:	0e04bc23          	sd	zero,248(s1)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc0205308:	10e4b023          	sd	a4,256(s1)
ffffffffc020530c:	c311                	beqz	a4,ffffffffc0205310 <do_fork+0x164>
        proc->optr->yptr = proc;
ffffffffc020530e:	ff64                	sd	s1,248(a4)
    nr_process ++;
ffffffffc0205310:	00092783          	lw	a5,0(s2)
    wakeup_proc(proc);
ffffffffc0205314:	8526                	mv	a0,s1
    proc->parent->cptr = proc;
ffffffffc0205316:	fae4                	sd	s1,240(a3)
    nr_process ++;
ffffffffc0205318:	2785                	addiw	a5,a5,1
ffffffffc020531a:	00f92023          	sw	a5,0(s2)
    wakeup_proc(proc);
ffffffffc020531e:	669000ef          	jal	ffffffffc0206186 <wakeup_proc>
    return proc->pid;
ffffffffc0205322:	40c8                	lw	a0,4(s1)
ffffffffc0205324:	6406                	ld	s0,64(sp)
ffffffffc0205326:	74e2                	ld	s1,56(sp)
ffffffffc0205328:	79a2                	ld	s3,40(sp)
ffffffffc020532a:	7a02                	ld	s4,32(sp)
ffffffffc020532c:	6ae2                	ld	s5,24(sp)
ffffffffc020532e:	6b42                	ld	s6,16(sp)
ffffffffc0205330:	6ba2                	ld	s7,8(sp)
}
ffffffffc0205332:	60a6                	ld	ra,72(sp)
ffffffffc0205334:	7942                	ld	s2,48(sp)
ffffffffc0205336:	6161                	addi	sp,sp,80
ffffffffc0205338:	8082                	ret
        last_pid = 1;
ffffffffc020533a:	4785                	li	a5,1
ffffffffc020533c:	00f82023          	sw	a5,0(a6)
        goto inside;
ffffffffc0205340:	4505                	li	a0,1
ffffffffc0205342:	0008d317          	auipc	t1,0x8d
ffffffffc0205346:	75e30313          	addi	t1,t1,1886 # ffffffffc0292aa0 <next_safe.0>
    return listelm->next;
ffffffffc020534a:	00099417          	auipc	s0,0x99
ffffffffc020534e:	c1640413          	addi	s0,s0,-1002 # ffffffffc029df60 <proc_list>
ffffffffc0205352:	00843e03          	ld	t3,8(s0)
        next_safe = MAX_PID;
ffffffffc0205356:	6789                	lui	a5,0x2
ffffffffc0205358:	00f32023          	sw	a5,0(t1)
ffffffffc020535c:	86aa                	mv	a3,a0
ffffffffc020535e:	4581                	li	a1,0
        while ((le = list_next(le)) != list) {
ffffffffc0205360:	028e0e63          	beq	t3,s0,ffffffffc020539c <do_fork+0x1f0>
ffffffffc0205364:	88ae                	mv	a7,a1
ffffffffc0205366:	87f2                	mv	a5,t3
ffffffffc0205368:	6609                	lui	a2,0x2
ffffffffc020536a:	a811                	j	ffffffffc020537e <do_fork+0x1d2>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc020536c:	00e6d663          	bge	a3,a4,ffffffffc0205378 <do_fork+0x1cc>
ffffffffc0205370:	00c75463          	bge	a4,a2,ffffffffc0205378 <do_fork+0x1cc>
                next_safe = proc->pid;
ffffffffc0205374:	863a                	mv	a2,a4
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc0205376:	4885                	li	a7,1
ffffffffc0205378:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc020537a:	00878d63          	beq	a5,s0,ffffffffc0205394 <do_fork+0x1e8>
            if (proc->pid == last_pid) {
ffffffffc020537e:	f3c7a703          	lw	a4,-196(a5) # 1f3c <_binary_obj___user_softint_out_size-0x66fc>
ffffffffc0205382:	fed715e3          	bne	a4,a3,ffffffffc020536c <do_fork+0x1c0>
                if (++ last_pid >= next_safe) {
ffffffffc0205386:	2685                	addiw	a3,a3,1
ffffffffc0205388:	02c6d163          	bge	a3,a2,ffffffffc02053aa <do_fork+0x1fe>
ffffffffc020538c:	679c                	ld	a5,8(a5)
ffffffffc020538e:	4585                	li	a1,1
        while ((le = list_next(le)) != list) {
ffffffffc0205390:	fe8797e3          	bne	a5,s0,ffffffffc020537e <do_fork+0x1d2>
ffffffffc0205394:	00088463          	beqz	a7,ffffffffc020539c <do_fork+0x1f0>
ffffffffc0205398:	00c32023          	sw	a2,0(t1)
ffffffffc020539c:	d595                	beqz	a1,ffffffffc02052c8 <do_fork+0x11c>
ffffffffc020539e:	00d82023          	sw	a3,0(a6)
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc02053a2:	8536                	mv	a0,a3
ffffffffc02053a4:	b715                	j	ffffffffc02052c8 <do_fork+0x11c>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02053a6:	89ba                	mv	s3,a4
ffffffffc02053a8:	bdf9                	j	ffffffffc0205286 <do_fork+0xda>
                    if (last_pid >= MAX_PID) {
ffffffffc02053aa:	6789                	lui	a5,0x2
ffffffffc02053ac:	00f6c363          	blt	a3,a5,ffffffffc02053b2 <do_fork+0x206>
                        last_pid = 1;
ffffffffc02053b0:	4685                	li	a3,1
                    goto repeat;
ffffffffc02053b2:	4585                	li	a1,1
ffffffffc02053b4:	b775                	j	ffffffffc0205360 <do_fork+0x1b4>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc02053b6:	6894                	ld	a3,16(s1)
    return pa2page(PADDR(kva));
ffffffffc02053b8:	c02007b7          	lui	a5,0xc0200
ffffffffc02053bc:	08f6ee63          	bltu	a3,a5,ffffffffc0205458 <do_fork+0x2ac>
ffffffffc02053c0:	000ab783          	ld	a5,0(s5)
    if (PPN(pa) >= npage) {
ffffffffc02053c4:	000bb703          	ld	a4,0(s7)
    return pa2page(PADDR(kva));
ffffffffc02053c8:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc02053cc:	83b1                	srli	a5,a5,0xc
ffffffffc02053ce:	06e7f963          	bgeu	a5,a4,ffffffffc0205440 <do_fork+0x294>
    return &pages[PPN(pa) - nbase];
ffffffffc02053d2:	000b3503          	ld	a0,0(s6)
ffffffffc02053d6:	414787b3          	sub	a5,a5,s4
ffffffffc02053da:	079a                	slli	a5,a5,0x6
ffffffffc02053dc:	4589                	li	a1,2
ffffffffc02053de:	953e                	add	a0,a0,a5
ffffffffc02053e0:	eb1fc0ef          	jal	ffffffffc0202290 <free_pages>
}
ffffffffc02053e4:	7a02                	ld	s4,32(sp)
ffffffffc02053e6:	6ae2                	ld	s5,24(sp)
ffffffffc02053e8:	6b42                	ld	s6,16(sp)
ffffffffc02053ea:	6ba2                	ld	s7,8(sp)
    kfree(proc);
ffffffffc02053ec:	8526                	mv	a0,s1
ffffffffc02053ee:	ce5fc0ef          	jal	ffffffffc02020d2 <kfree>
    goto fork_out;
ffffffffc02053f2:	6406                	ld	s0,64(sp)
ffffffffc02053f4:	74e2                	ld	s1,56(sp)
ffffffffc02053f6:	79a2                	ld	s3,40(sp)
    ret = -E_NO_MEM;
ffffffffc02053f8:	5571                	li	a0,-4
ffffffffc02053fa:	bf25                	j	ffffffffc0205332 <do_fork+0x186>
    int ret = -E_NO_FREE_PROC;
ffffffffc02053fc:	556d                	li	a0,-5
ffffffffc02053fe:	bf15                	j	ffffffffc0205332 <do_fork+0x186>
    assert(current->wait_state == 0);
ffffffffc0205400:	00003697          	auipc	a3,0x3
ffffffffc0205404:	1e868693          	addi	a3,a3,488 # ffffffffc02085e8 <etext+0x1d9e>
ffffffffc0205408:	00002617          	auipc	a2,0x2
ffffffffc020540c:	ac060613          	addi	a2,a2,-1344 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0205410:	1c900593          	li	a1,457
ffffffffc0205414:	00003517          	auipc	a0,0x3
ffffffffc0205418:	1bc50513          	addi	a0,a0,444 # ffffffffc02085d0 <etext+0x1d86>
ffffffffc020541c:	f052                	sd	s4,32(sp)
ffffffffc020541e:	ec56                	sd	s5,24(sp)
ffffffffc0205420:	e85a                	sd	s6,16(sp)
ffffffffc0205422:	e45e                	sd	s7,8(sp)
ffffffffc0205424:	850fb0ef          	jal	ffffffffc0200474 <__panic>
    return KADDR(page2pa(page));
ffffffffc0205428:	00002617          	auipc	a2,0x2
ffffffffc020542c:	de860613          	addi	a2,a2,-536 # ffffffffc0207210 <etext+0x9c6>
ffffffffc0205430:	06a00593          	li	a1,106
ffffffffc0205434:	00002517          	auipc	a0,0x2
ffffffffc0205438:	d8c50513          	addi	a0,a0,-628 # ffffffffc02071c0 <etext+0x976>
ffffffffc020543c:	838fb0ef          	jal	ffffffffc0200474 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0205440:	00002617          	auipc	a2,0x2
ffffffffc0205444:	d6060613          	addi	a2,a2,-672 # ffffffffc02071a0 <etext+0x956>
ffffffffc0205448:	06300593          	li	a1,99
ffffffffc020544c:	00002517          	auipc	a0,0x2
ffffffffc0205450:	d7450513          	addi	a0,a0,-652 # ffffffffc02071c0 <etext+0x976>
ffffffffc0205454:	820fb0ef          	jal	ffffffffc0200474 <__panic>
    return pa2page(PADDR(kva));
ffffffffc0205458:	00002617          	auipc	a2,0x2
ffffffffc020545c:	e0860613          	addi	a2,a2,-504 # ffffffffc0207260 <etext+0xa16>
ffffffffc0205460:	06f00593          	li	a1,111
ffffffffc0205464:	00002517          	auipc	a0,0x2
ffffffffc0205468:	d5c50513          	addi	a0,a0,-676 # ffffffffc02071c0 <etext+0x976>
ffffffffc020546c:	808fb0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc0205470 <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc0205470:	7129                	addi	sp,sp,-320
ffffffffc0205472:	fa22                	sd	s0,304(sp)
ffffffffc0205474:	f626                	sd	s1,296(sp)
ffffffffc0205476:	f24a                	sd	s2,288(sp)
ffffffffc0205478:	84ae                	mv	s1,a1
ffffffffc020547a:	892a                	mv	s2,a0
ffffffffc020547c:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc020547e:	4581                	li	a1,0
ffffffffc0205480:	12000613          	li	a2,288
ffffffffc0205484:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc0205486:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0205488:	398010ef          	jal	ffffffffc0206820 <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc020548c:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc020548e:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc0205490:	100027f3          	csrr	a5,sstatus
ffffffffc0205494:	edd7f793          	andi	a5,a5,-291
ffffffffc0205498:	1207e793          	ori	a5,a5,288
ffffffffc020549c:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc020549e:	860a                	mv	a2,sp
ffffffffc02054a0:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02054a4:	00000797          	auipc	a5,0x0
ffffffffc02054a8:	b2078793          	addi	a5,a5,-1248 # ffffffffc0204fc4 <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02054ac:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02054ae:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02054b0:	cfdff0ef          	jal	ffffffffc02051ac <do_fork>
}
ffffffffc02054b4:	70f2                	ld	ra,312(sp)
ffffffffc02054b6:	7452                	ld	s0,304(sp)
ffffffffc02054b8:	74b2                	ld	s1,296(sp)
ffffffffc02054ba:	7912                	ld	s2,288(sp)
ffffffffc02054bc:	6131                	addi	sp,sp,320
ffffffffc02054be:	8082                	ret

ffffffffc02054c0 <do_exit>:
do_exit(int error_code) {
ffffffffc02054c0:	7179                	addi	sp,sp,-48
ffffffffc02054c2:	f022                	sd	s0,32(sp)
    if (current == idleproc) {
ffffffffc02054c4:	00099417          	auipc	s0,0x99
ffffffffc02054c8:	b2c40413          	addi	s0,s0,-1236 # ffffffffc029dff0 <current>
ffffffffc02054cc:	601c                	ld	a5,0(s0)
do_exit(int error_code) {
ffffffffc02054ce:	f406                	sd	ra,40(sp)
    if (current == idleproc) {
ffffffffc02054d0:	00099717          	auipc	a4,0x99
ffffffffc02054d4:	b3073703          	ld	a4,-1232(a4) # ffffffffc029e000 <idleproc>
ffffffffc02054d8:	ec26                	sd	s1,24(sp)
ffffffffc02054da:	0ce78f63          	beq	a5,a4,ffffffffc02055b8 <do_exit+0xf8>
    if (current == initproc) {
ffffffffc02054de:	00099497          	auipc	s1,0x99
ffffffffc02054e2:	b1a48493          	addi	s1,s1,-1254 # ffffffffc029dff8 <initproc>
ffffffffc02054e6:	6098                	ld	a4,0(s1)
ffffffffc02054e8:	e84a                	sd	s2,16(sp)
ffffffffc02054ea:	e44e                	sd	s3,8(sp)
ffffffffc02054ec:	e052                	sd	s4,0(sp)
ffffffffc02054ee:	0ee78e63          	beq	a5,a4,ffffffffc02055ea <do_exit+0x12a>
    struct mm_struct *mm = current->mm;
ffffffffc02054f2:	0287b983          	ld	s3,40(a5)
ffffffffc02054f6:	892a                	mv	s2,a0
    if (mm != NULL) {
ffffffffc02054f8:	02098663          	beqz	s3,ffffffffc0205524 <do_exit+0x64>
ffffffffc02054fc:	00099797          	auipc	a5,0x99
ffffffffc0205500:	a9c7b783          	ld	a5,-1380(a5) # ffffffffc029df98 <boot_cr3>
ffffffffc0205504:	577d                	li	a4,-1
ffffffffc0205506:	177e                	slli	a4,a4,0x3f
ffffffffc0205508:	83b1                	srli	a5,a5,0xc
ffffffffc020550a:	8fd9                	or	a5,a5,a4
ffffffffc020550c:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc0205510:	0309a783          	lw	a5,48(s3)
ffffffffc0205514:	fff7871b          	addiw	a4,a5,-1
ffffffffc0205518:	02e9a823          	sw	a4,48(s3)
        if (mm_count_dec(mm) == 0) {
ffffffffc020551c:	cf4d                	beqz	a4,ffffffffc02055d6 <do_exit+0x116>
        current->mm = NULL;
ffffffffc020551e:	601c                	ld	a5,0(s0)
ffffffffc0205520:	0207b423          	sd	zero,40(a5)
    current->state = PROC_ZOMBIE;
ffffffffc0205524:	601c                	ld	a5,0(s0)
ffffffffc0205526:	470d                	li	a4,3
ffffffffc0205528:	c398                	sw	a4,0(a5)
    current->exit_code = error_code;  // 保存退出码
ffffffffc020552a:	0f27a423          	sw	s2,232(a5)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020552e:	100027f3          	csrr	a5,sstatus
ffffffffc0205532:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205534:	4a01                	li	s4,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205536:	e7f1                	bnez	a5,ffffffffc0205602 <do_exit+0x142>
        proc = current->parent;
ffffffffc0205538:	6018                	ld	a4,0(s0)
        if (proc->wait_state == WT_CHILD) {
ffffffffc020553a:	800007b7          	lui	a5,0x80000
ffffffffc020553e:	0785                	addi	a5,a5,1 # ffffffff80000001 <_binary_obj___user_exit_out_size+0xffffffff7fff6461>
        proc = current->parent;
ffffffffc0205540:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD) {
ffffffffc0205542:	0ec52703          	lw	a4,236(a0)
ffffffffc0205546:	0cf70263          	beq	a4,a5,ffffffffc020560a <do_exit+0x14a>
        while (current->cptr != NULL) {
ffffffffc020554a:	6018                	ld	a4,0(s0)
ffffffffc020554c:	7b7c                	ld	a5,240(a4)
ffffffffc020554e:	c3a1                	beqz	a5,ffffffffc020558e <do_exit+0xce>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc0205550:	800009b7          	lui	s3,0x80000
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205554:	490d                	li	s2,3
                if (initproc->wait_state == WT_CHILD) {
ffffffffc0205556:	0985                	addi	s3,s3,1 # ffffffff80000001 <_binary_obj___user_exit_out_size+0xffffffff7fff6461>
ffffffffc0205558:	a021                	j	ffffffffc0205560 <do_exit+0xa0>
        while (current->cptr != NULL) {
ffffffffc020555a:	6018                	ld	a4,0(s0)
ffffffffc020555c:	7b7c                	ld	a5,240(a4)
ffffffffc020555e:	cb85                	beqz	a5,ffffffffc020558e <do_exit+0xce>
            current->cptr = proc->optr;  // 将子进程从当前进程的子进程链表中移除
ffffffffc0205560:	1007b683          	ld	a3,256(a5)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc0205564:	6088                	ld	a0,0(s1)
            current->cptr = proc->optr;  // 将子进程从当前进程的子进程链表中移除
ffffffffc0205566:	fb74                	sd	a3,240(a4)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc0205568:	7978                	ld	a4,240(a0)
            proc->yptr = NULL;
ffffffffc020556a:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc020556e:	10e7b023          	sd	a4,256(a5)
ffffffffc0205572:	c311                	beqz	a4,ffffffffc0205576 <do_exit+0xb6>
                initproc->cptr->yptr = proc;  // 将 initproc 的第一个子进程指向新父进程proc
ffffffffc0205574:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205576:	4398                	lw	a4,0(a5)
            proc->parent = initproc;  // 设置新父进程为 initproc
ffffffffc0205578:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;  // 将当前子进程加入 initproc 的子进程链表
ffffffffc020557a:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc020557c:	fd271fe3          	bne	a4,s2,ffffffffc020555a <do_exit+0x9a>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc0205580:	0ec52783          	lw	a5,236(a0)
ffffffffc0205584:	fd379be3          	bne	a5,s3,ffffffffc020555a <do_exit+0x9a>
                    wakeup_proc(initproc);
ffffffffc0205588:	3ff000ef          	jal	ffffffffc0206186 <wakeup_proc>
ffffffffc020558c:	b7f9                	j	ffffffffc020555a <do_exit+0x9a>
    if (flag) {
ffffffffc020558e:	020a1263          	bnez	s4,ffffffffc02055b2 <do_exit+0xf2>
    schedule();
ffffffffc0205592:	48f000ef          	jal	ffffffffc0206220 <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc0205596:	601c                	ld	a5,0(s0)
ffffffffc0205598:	00003617          	auipc	a2,0x3
ffffffffc020559c:	09060613          	addi	a2,a2,144 # ffffffffc0208628 <etext+0x1dde>
ffffffffc02055a0:	24600593          	li	a1,582
ffffffffc02055a4:	43d4                	lw	a3,4(a5)
ffffffffc02055a6:	00003517          	auipc	a0,0x3
ffffffffc02055aa:	02a50513          	addi	a0,a0,42 # ffffffffc02085d0 <etext+0x1d86>
ffffffffc02055ae:	ec7fa0ef          	jal	ffffffffc0200474 <__panic>
        intr_enable();
ffffffffc02055b2:	888fb0ef          	jal	ffffffffc020063a <intr_enable>
ffffffffc02055b6:	bff1                	j	ffffffffc0205592 <do_exit+0xd2>
        panic("idleproc exit.\n");
ffffffffc02055b8:	00003617          	auipc	a2,0x3
ffffffffc02055bc:	05060613          	addi	a2,a2,80 # ffffffffc0208608 <etext+0x1dbe>
ffffffffc02055c0:	1fc00593          	li	a1,508
ffffffffc02055c4:	00003517          	auipc	a0,0x3
ffffffffc02055c8:	00c50513          	addi	a0,a0,12 # ffffffffc02085d0 <etext+0x1d86>
ffffffffc02055cc:	e84a                	sd	s2,16(sp)
ffffffffc02055ce:	e44e                	sd	s3,8(sp)
ffffffffc02055d0:	e052                	sd	s4,0(sp)
ffffffffc02055d2:	ea3fa0ef          	jal	ffffffffc0200474 <__panic>
            exit_mmap(mm);
ffffffffc02055d6:	854e                	mv	a0,s3
ffffffffc02055d8:	934ff0ef          	jal	ffffffffc020470c <exit_mmap>
            put_pgdir(mm);
ffffffffc02055dc:	854e                	mv	a0,s3
ffffffffc02055de:	aedff0ef          	jal	ffffffffc02050ca <put_pgdir>
            mm_destroy(mm);
ffffffffc02055e2:	854e                	mv	a0,s3
ffffffffc02055e4:	808ff0ef          	jal	ffffffffc02045ec <mm_destroy>
ffffffffc02055e8:	bf1d                	j	ffffffffc020551e <do_exit+0x5e>
        panic("initproc exit.\n");
ffffffffc02055ea:	00003617          	auipc	a2,0x3
ffffffffc02055ee:	02e60613          	addi	a2,a2,46 # ffffffffc0208618 <etext+0x1dce>
ffffffffc02055f2:	20100593          	li	a1,513
ffffffffc02055f6:	00003517          	auipc	a0,0x3
ffffffffc02055fa:	fda50513          	addi	a0,a0,-38 # ffffffffc02085d0 <etext+0x1d86>
ffffffffc02055fe:	e77fa0ef          	jal	ffffffffc0200474 <__panic>
        intr_disable();
ffffffffc0205602:	83efb0ef          	jal	ffffffffc0200640 <intr_disable>
        return 1;
ffffffffc0205606:	4a05                	li	s4,1
ffffffffc0205608:	bf05                	j	ffffffffc0205538 <do_exit+0x78>
            wakeup_proc(proc);
ffffffffc020560a:	37d000ef          	jal	ffffffffc0206186 <wakeup_proc>
ffffffffc020560e:	bf35                	j	ffffffffc020554a <do_exit+0x8a>

ffffffffc0205610 <do_wait.part.0>:
do_wait(int pid, int *code_store) {
ffffffffc0205610:	7179                	addi	sp,sp,-48
ffffffffc0205612:	ec26                	sd	s1,24(sp)
ffffffffc0205614:	e84a                	sd	s2,16(sp)
ffffffffc0205616:	e44e                	sd	s3,8(sp)
ffffffffc0205618:	f406                	sd	ra,40(sp)
ffffffffc020561a:	f022                	sd	s0,32(sp)
ffffffffc020561c:	84aa                	mv	s1,a0
ffffffffc020561e:	892e                	mv	s2,a1
ffffffffc0205620:	00099997          	auipc	s3,0x99
ffffffffc0205624:	9d098993          	addi	s3,s3,-1584 # ffffffffc029dff0 <current>
    if (pid != 0) {
ffffffffc0205628:	c105                	beqz	a0,ffffffffc0205648 <do_wait.part.0+0x38>
    if (0 < pid && pid < MAX_PID) {
ffffffffc020562a:	6789                	lui	a5,0x2
ffffffffc020562c:	fff5071b          	addiw	a4,a0,-1
ffffffffc0205630:	17f9                	addi	a5,a5,-2 # 1ffe <_binary_obj___user_softint_out_size-0x663a>
ffffffffc0205632:	2501                	sext.w	a0,a0
ffffffffc0205634:	12e7f363          	bgeu	a5,a4,ffffffffc020575a <do_wait.part.0+0x14a>
    return -E_BAD_PROC;
ffffffffc0205638:	5579                	li	a0,-2
}
ffffffffc020563a:	70a2                	ld	ra,40(sp)
ffffffffc020563c:	7402                	ld	s0,32(sp)
ffffffffc020563e:	64e2                	ld	s1,24(sp)
ffffffffc0205640:	6942                	ld	s2,16(sp)
ffffffffc0205642:	69a2                	ld	s3,8(sp)
ffffffffc0205644:	6145                	addi	sp,sp,48
ffffffffc0205646:	8082                	ret
        proc = current->cptr;
ffffffffc0205648:	0009b683          	ld	a3,0(s3)
ffffffffc020564c:	7ae0                	ld	s0,240(a3)
        for (; proc != NULL; proc = proc->optr) {
ffffffffc020564e:	d46d                	beqz	s0,ffffffffc0205638 <do_wait.part.0+0x28>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205650:	470d                	li	a4,3
ffffffffc0205652:	a021                	j	ffffffffc020565a <do_wait.part.0+0x4a>
        for (; proc != NULL; proc = proc->optr) {
ffffffffc0205654:	10043403          	ld	s0,256(s0)
ffffffffc0205658:	cc71                	beqz	s0,ffffffffc0205734 <do_wait.part.0+0x124>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc020565a:	401c                	lw	a5,0(s0)
ffffffffc020565c:	fee79ce3          	bne	a5,a4,ffffffffc0205654 <do_wait.part.0+0x44>
    if (proc == idleproc || proc == initproc) {
ffffffffc0205660:	00099797          	auipc	a5,0x99
ffffffffc0205664:	9a07b783          	ld	a5,-1632(a5) # ffffffffc029e000 <idleproc>
ffffffffc0205668:	14878c63          	beq	a5,s0,ffffffffc02057c0 <do_wait.part.0+0x1b0>
ffffffffc020566c:	00099797          	auipc	a5,0x99
ffffffffc0205670:	98c7b783          	ld	a5,-1652(a5) # ffffffffc029dff8 <initproc>
ffffffffc0205674:	14f40663          	beq	s0,a5,ffffffffc02057c0 <do_wait.part.0+0x1b0>
    if (code_store != NULL) {
ffffffffc0205678:	00090663          	beqz	s2,ffffffffc0205684 <do_wait.part.0+0x74>
        *code_store = proc->exit_code;
ffffffffc020567c:	0e842783          	lw	a5,232(s0)
ffffffffc0205680:	00f92023          	sw	a5,0(s2)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205684:	100027f3          	csrr	a5,sstatus
ffffffffc0205688:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020568a:	4601                	li	a2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020568c:	10079463          	bnez	a5,ffffffffc0205794 <do_wait.part.0+0x184>
    __list_del(listelm->prev, listelm->next);
ffffffffc0205690:	6c74                	ld	a3,216(s0)
ffffffffc0205692:	7078                	ld	a4,224(s0)
    if (proc->optr != NULL) {
ffffffffc0205694:	10043783          	ld	a5,256(s0)
    prev->next = next;
ffffffffc0205698:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc020569a:	e314                	sd	a3,0(a4)
    __list_del(listelm->prev, listelm->next);
ffffffffc020569c:	6474                	ld	a3,200(s0)
ffffffffc020569e:	6878                	ld	a4,208(s0)
    prev->next = next;
ffffffffc02056a0:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc02056a2:	e314                	sd	a3,0(a4)
ffffffffc02056a4:	c399                	beqz	a5,ffffffffc02056aa <do_wait.part.0+0x9a>
        proc->optr->yptr = proc->yptr;
ffffffffc02056a6:	7c78                	ld	a4,248(s0)
ffffffffc02056a8:	fff8                	sd	a4,248(a5)
    if (proc->yptr != NULL) {
ffffffffc02056aa:	7c78                	ld	a4,248(s0)
ffffffffc02056ac:	c36d                	beqz	a4,ffffffffc020578e <do_wait.part.0+0x17e>
        proc->yptr->optr = proc->optr;
ffffffffc02056ae:	10f73023          	sd	a5,256(a4)
    nr_process --;
ffffffffc02056b2:	00099717          	auipc	a4,0x99
ffffffffc02056b6:	93670713          	addi	a4,a4,-1738 # ffffffffc029dfe8 <nr_process>
ffffffffc02056ba:	431c                	lw	a5,0(a4)
ffffffffc02056bc:	37fd                	addiw	a5,a5,-1
ffffffffc02056be:	c31c                	sw	a5,0(a4)
    if (flag) {
ffffffffc02056c0:	e661                	bnez	a2,ffffffffc0205788 <do_wait.part.0+0x178>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc02056c2:	6814                	ld	a3,16(s0)
ffffffffc02056c4:	c02007b7          	lui	a5,0xc0200
ffffffffc02056c8:	0ef6e063          	bltu	a3,a5,ffffffffc02057a8 <do_wait.part.0+0x198>
ffffffffc02056cc:	00099797          	auipc	a5,0x99
ffffffffc02056d0:	8dc7b783          	ld	a5,-1828(a5) # ffffffffc029dfa8 <va_pa_offset>
ffffffffc02056d4:	8e9d                	sub	a3,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc02056d6:	82b1                	srli	a3,a3,0xc
ffffffffc02056d8:	00099797          	auipc	a5,0x99
ffffffffc02056dc:	8d87b783          	ld	a5,-1832(a5) # ffffffffc029dfb0 <npage>
ffffffffc02056e0:	0ef6fc63          	bgeu	a3,a5,ffffffffc02057d8 <do_wait.part.0+0x1c8>
    return &pages[PPN(pa) - nbase];
ffffffffc02056e4:	00004797          	auipc	a5,0x4
ffffffffc02056e8:	86c7b783          	ld	a5,-1940(a5) # ffffffffc0208f50 <nbase>
ffffffffc02056ec:	8e9d                	sub	a3,a3,a5
ffffffffc02056ee:	069a                	slli	a3,a3,0x6
ffffffffc02056f0:	00099517          	auipc	a0,0x99
ffffffffc02056f4:	8c853503          	ld	a0,-1848(a0) # ffffffffc029dfb8 <pages>
ffffffffc02056f8:	9536                	add	a0,a0,a3
ffffffffc02056fa:	4589                	li	a1,2
ffffffffc02056fc:	b95fc0ef          	jal	ffffffffc0202290 <free_pages>
    kfree(proc);
ffffffffc0205700:	8522                	mv	a0,s0
ffffffffc0205702:	9d1fc0ef          	jal	ffffffffc02020d2 <kfree>
}
ffffffffc0205706:	70a2                	ld	ra,40(sp)
ffffffffc0205708:	7402                	ld	s0,32(sp)
ffffffffc020570a:	64e2                	ld	s1,24(sp)
ffffffffc020570c:	6942                	ld	s2,16(sp)
ffffffffc020570e:	69a2                	ld	s3,8(sp)
    return 0;
ffffffffc0205710:	4501                	li	a0,0
}
ffffffffc0205712:	6145                	addi	sp,sp,48
ffffffffc0205714:	8082                	ret
        if (proc != NULL && proc->parent == current) {
ffffffffc0205716:	00099997          	auipc	s3,0x99
ffffffffc020571a:	8da98993          	addi	s3,s3,-1830 # ffffffffc029dff0 <current>
ffffffffc020571e:	0009b683          	ld	a3,0(s3)
ffffffffc0205722:	f4843783          	ld	a5,-184(s0)
ffffffffc0205726:	f0d799e3          	bne	a5,a3,ffffffffc0205638 <do_wait.part.0+0x28>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc020572a:	f2842703          	lw	a4,-216(s0)
ffffffffc020572e:	478d                	li	a5,3
ffffffffc0205730:	06f70663          	beq	a4,a5,ffffffffc020579c <do_wait.part.0+0x18c>
        current->wait_state = WT_CHILD;
ffffffffc0205734:	800007b7          	lui	a5,0x80000
ffffffffc0205738:	0785                	addi	a5,a5,1 # ffffffff80000001 <_binary_obj___user_exit_out_size+0xffffffff7fff6461>
        current->state = PROC_SLEEPING;
ffffffffc020573a:	4705                	li	a4,1
        current->wait_state = WT_CHILD;
ffffffffc020573c:	0ef6a623          	sw	a5,236(a3)
        current->state = PROC_SLEEPING;
ffffffffc0205740:	c298                	sw	a4,0(a3)
        schedule();
ffffffffc0205742:	2df000ef          	jal	ffffffffc0206220 <schedule>
        if (current->flags & PF_EXITING) {
ffffffffc0205746:	0009b783          	ld	a5,0(s3)
ffffffffc020574a:	0b07a783          	lw	a5,176(a5)
ffffffffc020574e:	8b85                	andi	a5,a5,1
ffffffffc0205750:	eba9                	bnez	a5,ffffffffc02057a2 <do_wait.part.0+0x192>
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205752:	0004851b          	sext.w	a0,s1
    if (pid != 0) {
ffffffffc0205756:	ee0489e3          	beqz	s1,ffffffffc0205648 <do_wait.part.0+0x38>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc020575a:	45a9                	li	a1,10
ffffffffc020575c:	431000ef          	jal	ffffffffc020638c <hash32>
ffffffffc0205760:	02051793          	slli	a5,a0,0x20
ffffffffc0205764:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0205768:	00094797          	auipc	a5,0x94
ffffffffc020576c:	7f878793          	addi	a5,a5,2040 # ffffffffc0299f60 <hash_list>
ffffffffc0205770:	953e                	add	a0,a0,a5
ffffffffc0205772:	842a                	mv	s0,a0
        while ((le = list_next(le)) != list) {
ffffffffc0205774:	a029                	j	ffffffffc020577e <do_wait.part.0+0x16e>
            if (proc->pid == pid) {
ffffffffc0205776:	f2c42783          	lw	a5,-212(s0)
ffffffffc020577a:	f8978ee3          	beq	a5,s1,ffffffffc0205716 <do_wait.part.0+0x106>
    return listelm->next;
ffffffffc020577e:	6400                	ld	s0,8(s0)
        while ((le = list_next(le)) != list) {
ffffffffc0205780:	fe851be3          	bne	a0,s0,ffffffffc0205776 <do_wait.part.0+0x166>
    return -E_BAD_PROC;
ffffffffc0205784:	5579                	li	a0,-2
ffffffffc0205786:	bd55                	j	ffffffffc020563a <do_wait.part.0+0x2a>
        intr_enable();
ffffffffc0205788:	eb3fa0ef          	jal	ffffffffc020063a <intr_enable>
ffffffffc020578c:	bf1d                	j	ffffffffc02056c2 <do_wait.part.0+0xb2>
       proc->parent->cptr = proc->optr;
ffffffffc020578e:	7018                	ld	a4,32(s0)
ffffffffc0205790:	fb7c                	sd	a5,240(a4)
ffffffffc0205792:	b705                	j	ffffffffc02056b2 <do_wait.part.0+0xa2>
        intr_disable();
ffffffffc0205794:	eadfa0ef          	jal	ffffffffc0200640 <intr_disable>
        return 1;
ffffffffc0205798:	4605                	li	a2,1
ffffffffc020579a:	bddd                	j	ffffffffc0205690 <do_wait.part.0+0x80>
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc020579c:	f2840413          	addi	s0,s0,-216
ffffffffc02057a0:	b5c1                	j	ffffffffc0205660 <do_wait.part.0+0x50>
            do_exit(-E_KILLED);
ffffffffc02057a2:	555d                	li	a0,-9
ffffffffc02057a4:	d1dff0ef          	jal	ffffffffc02054c0 <do_exit>
    return pa2page(PADDR(kva));
ffffffffc02057a8:	00002617          	auipc	a2,0x2
ffffffffc02057ac:	ab860613          	addi	a2,a2,-1352 # ffffffffc0207260 <etext+0xa16>
ffffffffc02057b0:	06f00593          	li	a1,111
ffffffffc02057b4:	00002517          	auipc	a0,0x2
ffffffffc02057b8:	a0c50513          	addi	a0,a0,-1524 # ffffffffc02071c0 <etext+0x976>
ffffffffc02057bc:	cb9fa0ef          	jal	ffffffffc0200474 <__panic>
        panic("wait idleproc or initproc.\n");
ffffffffc02057c0:	00003617          	auipc	a2,0x3
ffffffffc02057c4:	e8860613          	addi	a2,a2,-376 # ffffffffc0208648 <etext+0x1dfe>
ffffffffc02057c8:	37300593          	li	a1,883
ffffffffc02057cc:	00003517          	auipc	a0,0x3
ffffffffc02057d0:	e0450513          	addi	a0,a0,-508 # ffffffffc02085d0 <etext+0x1d86>
ffffffffc02057d4:	ca1fa0ef          	jal	ffffffffc0200474 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02057d8:	00002617          	auipc	a2,0x2
ffffffffc02057dc:	9c860613          	addi	a2,a2,-1592 # ffffffffc02071a0 <etext+0x956>
ffffffffc02057e0:	06300593          	li	a1,99
ffffffffc02057e4:	00002517          	auipc	a0,0x2
ffffffffc02057e8:	9dc50513          	addi	a0,a0,-1572 # ffffffffc02071c0 <etext+0x976>
ffffffffc02057ec:	c89fa0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc02057f0 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
ffffffffc02057f0:	1141                	addi	sp,sp,-16
ffffffffc02057f2:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();// 获取当前系统的空闲页面数量和已分配的内存量
ffffffffc02057f4:	addfc0ef          	jal	ffffffffc02022d0 <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc02057f8:	82dfc0ef          	jal	ffffffffc0202024 <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);// 新建了一个内核进程，执行函数user_main(),这个内核进程里我们将要开始执行用户进程
ffffffffc02057fc:	4601                	li	a2,0
ffffffffc02057fe:	4581                	li	a1,0
ffffffffc0205800:	00000517          	auipc	a0,0x0
ffffffffc0205804:	84c50513          	addi	a0,a0,-1972 # ffffffffc020504c <user_main>
ffffffffc0205808:	c69ff0ef          	jal	ffffffffc0205470 <kernel_thread>
    if (pid <= 0) {
ffffffffc020580c:	00a04563          	bgtz	a0,ffffffffc0205816 <init_main+0x26>
ffffffffc0205810:	a071                	j	ffffffffc020589c <init_main+0xac>
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0) {// 等待子进程退出，也就是等待user_main()退出
        schedule();
ffffffffc0205812:	20f000ef          	jal	ffffffffc0206220 <schedule>
    if (code_store != NULL) {
ffffffffc0205816:	4581                	li	a1,0
ffffffffc0205818:	4501                	li	a0,0
ffffffffc020581a:	df7ff0ef          	jal	ffffffffc0205610 <do_wait.part.0>
    while (do_wait(0, NULL) == 0) {// 等待子进程退出，也就是等待user_main()退出
ffffffffc020581e:	d975                	beqz	a0,ffffffffc0205812 <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc0205820:	00003517          	auipc	a0,0x3
ffffffffc0205824:	e6850513          	addi	a0,a0,-408 # ffffffffc0208688 <etext+0x1e3e>
ffffffffc0205828:	959fa0ef          	jal	ffffffffc0200180 <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);// 检查 initproc 相关的指针是否为空，确保初始化过程中没有错误
ffffffffc020582c:	00098797          	auipc	a5,0x98
ffffffffc0205830:	7cc7b783          	ld	a5,1996(a5) # ffffffffc029dff8 <initproc>
ffffffffc0205834:	7bf8                	ld	a4,240(a5)
ffffffffc0205836:	e339                	bnez	a4,ffffffffc020587c <init_main+0x8c>
ffffffffc0205838:	7ff8                	ld	a4,248(a5)
ffffffffc020583a:	e329                	bnez	a4,ffffffffc020587c <init_main+0x8c>
ffffffffc020583c:	1007b703          	ld	a4,256(a5)
ffffffffc0205840:	ef15                	bnez	a4,ffffffffc020587c <init_main+0x8c>
    assert(nr_process == 2);// 确保进程数量为2，通常是 init 进程和 user_main 进程
ffffffffc0205842:	00098697          	auipc	a3,0x98
ffffffffc0205846:	7a66a683          	lw	a3,1958(a3) # ffffffffc029dfe8 <nr_process>
ffffffffc020584a:	4709                	li	a4,2
ffffffffc020584c:	0ae69463          	bne	a3,a4,ffffffffc02058f4 <init_main+0x104>
ffffffffc0205850:	00098697          	auipc	a3,0x98
ffffffffc0205854:	71068693          	addi	a3,a3,1808 # ffffffffc029df60 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));// 检查进程链表的前后链接，确认 initproc 依然在链表中
ffffffffc0205858:	6698                	ld	a4,8(a3)
ffffffffc020585a:	0c878793          	addi	a5,a5,200
ffffffffc020585e:	06f71b63          	bne	a4,a5,ffffffffc02058d4 <init_main+0xe4>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0205862:	629c                	ld	a5,0(a3)
ffffffffc0205864:	04f71863          	bne	a4,a5,ffffffffc02058b4 <init_main+0xc4>

    cprintf("init check memory pass.\n");
ffffffffc0205868:	00003517          	auipc	a0,0x3
ffffffffc020586c:	f0850513          	addi	a0,a0,-248 # ffffffffc0208770 <etext+0x1f26>
ffffffffc0205870:	911fa0ef          	jal	ffffffffc0200180 <cprintf>
    return 0;
}
ffffffffc0205874:	60a2                	ld	ra,8(sp)
ffffffffc0205876:	4501                	li	a0,0
ffffffffc0205878:	0141                	addi	sp,sp,16
ffffffffc020587a:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);// 检查 initproc 相关的指针是否为空，确保初始化过程中没有错误
ffffffffc020587c:	00003697          	auipc	a3,0x3
ffffffffc0205880:	e3468693          	addi	a3,a3,-460 # ffffffffc02086b0 <etext+0x1e66>
ffffffffc0205884:	00001617          	auipc	a2,0x1
ffffffffc0205888:	64460613          	addi	a2,a2,1604 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc020588c:	3f000593          	li	a1,1008
ffffffffc0205890:	00003517          	auipc	a0,0x3
ffffffffc0205894:	d4050513          	addi	a0,a0,-704 # ffffffffc02085d0 <etext+0x1d86>
ffffffffc0205898:	bddfa0ef          	jal	ffffffffc0200474 <__panic>
        panic("create user_main failed.\n");
ffffffffc020589c:	00003617          	auipc	a2,0x3
ffffffffc02058a0:	dcc60613          	addi	a2,a2,-564 # ffffffffc0208668 <etext+0x1e1e>
ffffffffc02058a4:	3e800593          	li	a1,1000
ffffffffc02058a8:	00003517          	auipc	a0,0x3
ffffffffc02058ac:	d2850513          	addi	a0,a0,-728 # ffffffffc02085d0 <etext+0x1d86>
ffffffffc02058b0:	bc5fa0ef          	jal	ffffffffc0200474 <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc02058b4:	00003697          	auipc	a3,0x3
ffffffffc02058b8:	e8c68693          	addi	a3,a3,-372 # ffffffffc0208740 <etext+0x1ef6>
ffffffffc02058bc:	00001617          	auipc	a2,0x1
ffffffffc02058c0:	60c60613          	addi	a2,a2,1548 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc02058c4:	3f300593          	li	a1,1011
ffffffffc02058c8:	00003517          	auipc	a0,0x3
ffffffffc02058cc:	d0850513          	addi	a0,a0,-760 # ffffffffc02085d0 <etext+0x1d86>
ffffffffc02058d0:	ba5fa0ef          	jal	ffffffffc0200474 <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));// 检查进程链表的前后链接，确认 initproc 依然在链表中
ffffffffc02058d4:	00003697          	auipc	a3,0x3
ffffffffc02058d8:	e3c68693          	addi	a3,a3,-452 # ffffffffc0208710 <etext+0x1ec6>
ffffffffc02058dc:	00001617          	auipc	a2,0x1
ffffffffc02058e0:	5ec60613          	addi	a2,a2,1516 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc02058e4:	3f200593          	li	a1,1010
ffffffffc02058e8:	00003517          	auipc	a0,0x3
ffffffffc02058ec:	ce850513          	addi	a0,a0,-792 # ffffffffc02085d0 <etext+0x1d86>
ffffffffc02058f0:	b85fa0ef          	jal	ffffffffc0200474 <__panic>
    assert(nr_process == 2);// 确保进程数量为2，通常是 init 进程和 user_main 进程
ffffffffc02058f4:	00003697          	auipc	a3,0x3
ffffffffc02058f8:	e0c68693          	addi	a3,a3,-500 # ffffffffc0208700 <etext+0x1eb6>
ffffffffc02058fc:	00001617          	auipc	a2,0x1
ffffffffc0205900:	5cc60613          	addi	a2,a2,1484 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0205904:	3f100593          	li	a1,1009
ffffffffc0205908:	00003517          	auipc	a0,0x3
ffffffffc020590c:	cc850513          	addi	a0,a0,-824 # ffffffffc02085d0 <etext+0x1d86>
ffffffffc0205910:	b65fa0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc0205914 <do_execve>:
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205914:	7171                	addi	sp,sp,-176
ffffffffc0205916:	e4ee                	sd	s11,72(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0205918:	00098d97          	auipc	s11,0x98
ffffffffc020591c:	6d8d8d93          	addi	s11,s11,1752 # ffffffffc029dff0 <current>
ffffffffc0205920:	000db783          	ld	a5,0(s11)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205924:	e54e                	sd	s3,136(sp)
ffffffffc0205926:	ed26                	sd	s1,152(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0205928:	0287b983          	ld	s3,40(a5)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc020592c:	e94a                	sd	s2,144(sp)
ffffffffc020592e:	fcd6                	sd	s5,120(sp)
ffffffffc0205930:	892a                	mv	s2,a0
ffffffffc0205932:	84ae                	mv	s1,a1
ffffffffc0205934:	8ab2                	mv	s5,a2
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc0205936:	4681                	li	a3,0
ffffffffc0205938:	862e                	mv	a2,a1
ffffffffc020593a:	85aa                	mv	a1,a0
ffffffffc020593c:	854e                	mv	a0,s3
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc020593e:	f506                	sd	ra,168(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc0205940:	c90ff0ef          	jal	ffffffffc0204dd0 <user_mem_check>
ffffffffc0205944:	46050363          	beqz	a0,ffffffffc0205daa <do_execve+0x496>
    memset(local_name, 0, sizeof(local_name));  // 清零内存
ffffffffc0205948:	4641                	li	a2,16
ffffffffc020594a:	4581                	li	a1,0
ffffffffc020594c:	1808                	addi	a0,sp,48
ffffffffc020594e:	6d3000ef          	jal	ffffffffc0206820 <memset>
    if (len > PROC_NAME_LEN) {
ffffffffc0205952:	47bd                	li	a5,15
ffffffffc0205954:	8626                	mv	a2,s1
ffffffffc0205956:	1097e263          	bltu	a5,s1,ffffffffc0205a5a <do_execve+0x146>
    memcpy(local_name, name, len);  // 复制程序名到 local_name
ffffffffc020595a:	85ca                	mv	a1,s2
ffffffffc020595c:	1808                	addi	a0,sp,48
ffffffffc020595e:	6d5000ef          	jal	ffffffffc0206832 <memcpy>
    if (mm != NULL) {
ffffffffc0205962:	10098363          	beqz	s3,ffffffffc0205a68 <do_execve+0x154>
        cputs("mm != NULL");  // 调试输出
ffffffffc0205966:	00002517          	auipc	a0,0x2
ffffffffc020596a:	34a50513          	addi	a0,a0,842 # ffffffffc0207cb0 <etext+0x1466>
ffffffffc020596e:	849fa0ef          	jal	ffffffffc02001b6 <cputs>
ffffffffc0205972:	00098797          	auipc	a5,0x98
ffffffffc0205976:	6267b783          	ld	a5,1574(a5) # ffffffffc029df98 <boot_cr3>
ffffffffc020597a:	577d                	li	a4,-1
ffffffffc020597c:	177e                	slli	a4,a4,0x3f
ffffffffc020597e:	83b1                	srli	a5,a5,0xc
ffffffffc0205980:	8fd9                	or	a5,a5,a4
ffffffffc0205982:	18079073          	csrw	satp,a5
ffffffffc0205986:	0309a783          	lw	a5,48(s3)
ffffffffc020598a:	fff7871b          	addiw	a4,a5,-1
ffffffffc020598e:	02e9a823          	sw	a4,48(s3)
        if (mm_count_dec(mm) == 0) {
ffffffffc0205992:	2e070863          	beqz	a4,ffffffffc0205c82 <do_execve+0x36e>
        current->mm = NULL;
ffffffffc0205996:	000db783          	ld	a5,0(s11)
ffffffffc020599a:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL) {
ffffffffc020599e:	ac9fe0ef          	jal	ffffffffc0204466 <mm_create>
ffffffffc02059a2:	84aa                	mv	s1,a0
ffffffffc02059a4:	20050663          	beqz	a0,ffffffffc0205bb0 <do_execve+0x29c>
    if ((page = alloc_page()) == NULL) {
ffffffffc02059a8:	4505                	li	a0,1
ffffffffc02059aa:	857fc0ef          	jal	ffffffffc0202200 <alloc_pages>
ffffffffc02059ae:	40050263          	beqz	a0,ffffffffc0205db2 <do_execve+0x49e>
    return page - pages + nbase;
ffffffffc02059b2:	e8ea                	sd	s10,80(sp)
ffffffffc02059b4:	00098d17          	auipc	s10,0x98
ffffffffc02059b8:	604d0d13          	addi	s10,s10,1540 # ffffffffc029dfb8 <pages>
ffffffffc02059bc:	000d3783          	ld	a5,0(s10)
ffffffffc02059c0:	ece6                	sd	s9,88(sp)
    return KADDR(page2pa(page));
ffffffffc02059c2:	00098c97          	auipc	s9,0x98
ffffffffc02059c6:	5eec8c93          	addi	s9,s9,1518 # ffffffffc029dfb0 <npage>
    return page - pages + nbase;
ffffffffc02059ca:	40f506b3          	sub	a3,a0,a5
ffffffffc02059ce:	00003717          	auipc	a4,0x3
ffffffffc02059d2:	58273703          	ld	a4,1410(a4) # ffffffffc0208f50 <nbase>
ffffffffc02059d6:	f4de                	sd	s7,104(sp)
ffffffffc02059d8:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02059da:	5bfd                	li	s7,-1
ffffffffc02059dc:	000cb783          	ld	a5,0(s9)
    return page - pages + nbase;
ffffffffc02059e0:	96ba                	add	a3,a3,a4
ffffffffc02059e2:	e83a                	sd	a4,16(sp)
    return KADDR(page2pa(page));
ffffffffc02059e4:	00cbd713          	srli	a4,s7,0xc
ffffffffc02059e8:	f03a                	sd	a4,32(sp)
ffffffffc02059ea:	8f75                	and	a4,a4,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc02059ec:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02059ee:	3ef77563          	bgeu	a4,a5,ffffffffc0205dd8 <do_execve+0x4c4>
ffffffffc02059f2:	f8da                	sd	s6,112(sp)
ffffffffc02059f4:	00098b17          	auipc	s6,0x98
ffffffffc02059f8:	5b4b0b13          	addi	s6,s6,1460 # ffffffffc029dfa8 <va_pa_offset>
ffffffffc02059fc:	000b3783          	ld	a5,0(s6)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc0205a00:	6605                	lui	a2,0x1
ffffffffc0205a02:	00098597          	auipc	a1,0x98
ffffffffc0205a06:	59e5b583          	ld	a1,1438(a1) # ffffffffc029dfa0 <boot_pgdir>
ffffffffc0205a0a:	00f68933          	add	s2,a3,a5
ffffffffc0205a0e:	854a                	mv	a0,s2
ffffffffc0205a10:	e152                	sd	s4,128(sp)
ffffffffc0205a12:	621000ef          	jal	ffffffffc0206832 <memcpy>
    if (elf->e_magic != ELF_MAGIC) {//将二进制数据的开头解释为 ELF 文件头。
ffffffffc0205a16:	000aa703          	lw	a4,0(s5)
ffffffffc0205a1a:	464c47b7          	lui	a5,0x464c4
    mm->pgdir = pgdir;
ffffffffc0205a1e:	0124bc23          	sd	s2,24(s1)
    if (elf->e_magic != ELF_MAGIC) {//将二进制数据的开头解释为 ELF 文件头。
ffffffffc0205a22:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_exit_out_size+0x464ba9df>
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0205a26:	020aba03          	ld	s4,32(s5)
    if (elf->e_magic != ELF_MAGIC) {//将二进制数据的开头解释为 ELF 文件头。
ffffffffc0205a2a:	06f70663          	beq	a4,a5,ffffffffc0205a96 <do_execve+0x182>
        ret = -E_INVAL_ELF;
ffffffffc0205a2e:	5961                	li	s2,-8
    put_pgdir(mm);
ffffffffc0205a30:	8526                	mv	a0,s1
ffffffffc0205a32:	e98ff0ef          	jal	ffffffffc02050ca <put_pgdir>
ffffffffc0205a36:	6a0a                	ld	s4,128(sp)
ffffffffc0205a38:	7b46                	ld	s6,112(sp)
ffffffffc0205a3a:	7ba6                	ld	s7,104(sp)
ffffffffc0205a3c:	6ce6                	ld	s9,88(sp)
ffffffffc0205a3e:	6d46                	ld	s10,80(sp)
    mm_destroy(mm);
ffffffffc0205a40:	8526                	mv	a0,s1
ffffffffc0205a42:	babfe0ef          	jal	ffffffffc02045ec <mm_destroy>
    do_exit(ret);
ffffffffc0205a46:	854a                	mv	a0,s2
ffffffffc0205a48:	f122                	sd	s0,160(sp)
ffffffffc0205a4a:	e152                	sd	s4,128(sp)
ffffffffc0205a4c:	f8da                	sd	s6,112(sp)
ffffffffc0205a4e:	f4de                	sd	s7,104(sp)
ffffffffc0205a50:	f0e2                	sd	s8,96(sp)
ffffffffc0205a52:	ece6                	sd	s9,88(sp)
ffffffffc0205a54:	e8ea                	sd	s10,80(sp)
ffffffffc0205a56:	a6bff0ef          	jal	ffffffffc02054c0 <do_exit>
    if (len > PROC_NAME_LEN) {
ffffffffc0205a5a:	463d                	li	a2,15
    memcpy(local_name, name, len);  // 复制程序名到 local_name
ffffffffc0205a5c:	85ca                	mv	a1,s2
ffffffffc0205a5e:	1808                	addi	a0,sp,48
ffffffffc0205a60:	5d3000ef          	jal	ffffffffc0206832 <memcpy>
    if (mm != NULL) {
ffffffffc0205a64:	f00991e3          	bnez	s3,ffffffffc0205966 <do_execve+0x52>
    if (current->mm != NULL) {//检查当前进程的 mm（内存管理结构）是否为空。如果不是，说明当前进程已有内存空间，直接触发内核 panic。
ffffffffc0205a68:	000db783          	ld	a5,0(s11)
ffffffffc0205a6c:	779c                	ld	a5,40(a5)
ffffffffc0205a6e:	db85                	beqz	a5,ffffffffc020599e <do_execve+0x8a>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc0205a70:	00003617          	auipc	a2,0x3
ffffffffc0205a74:	d2060613          	addi	a2,a2,-736 # ffffffffc0208790 <etext+0x1f46>
ffffffffc0205a78:	25600593          	li	a1,598
ffffffffc0205a7c:	00003517          	auipc	a0,0x3
ffffffffc0205a80:	b5450513          	addi	a0,a0,-1196 # ffffffffc02085d0 <etext+0x1d86>
ffffffffc0205a84:	f122                	sd	s0,160(sp)
ffffffffc0205a86:	e152                	sd	s4,128(sp)
ffffffffc0205a88:	f8da                	sd	s6,112(sp)
ffffffffc0205a8a:	f4de                	sd	s7,104(sp)
ffffffffc0205a8c:	f0e2                	sd	s8,96(sp)
ffffffffc0205a8e:	ece6                	sd	s9,88(sp)
ffffffffc0205a90:	e8ea                	sd	s10,80(sp)
ffffffffc0205a92:	9e3fa0ef          	jal	ffffffffc0200474 <__panic>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205a96:	038ad703          	lhu	a4,56(s5)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0205a9a:	9a56                	add	s4,s4,s5
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205a9c:	f122                	sd	s0,160(sp)
ffffffffc0205a9e:	00371793          	slli	a5,a4,0x3
ffffffffc0205aa2:	8f99                	sub	a5,a5,a4
ffffffffc0205aa4:	078e                	slli	a5,a5,0x3
ffffffffc0205aa6:	97d2                	add	a5,a5,s4
ffffffffc0205aa8:	f43e                	sd	a5,40(sp)
    for (; ph < ph_end; ph ++) {
ffffffffc0205aaa:	00fa7e63          	bgeu	s4,a5,ffffffffc0205ac6 <do_execve+0x1b2>
ffffffffc0205aae:	f0e2                	sd	s8,96(sp)
        if (ph->p_type != ELF_PT_LOAD) {
ffffffffc0205ab0:	000a2783          	lw	a5,0(s4)
ffffffffc0205ab4:	4705                	li	a4,1
ffffffffc0205ab6:	0ee78f63          	beq	a5,a4,ffffffffc0205bb4 <do_execve+0x2a0>
    for (; ph < ph_end; ph ++) {
ffffffffc0205aba:	77a2                	ld	a5,40(sp)
ffffffffc0205abc:	038a0a13          	addi	s4,s4,56
ffffffffc0205ac0:	fefa68e3          	bltu	s4,a5,ffffffffc0205ab0 <do_execve+0x19c>
ffffffffc0205ac4:	7c06                	ld	s8,96(sp)
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
ffffffffc0205ac6:	4701                	li	a4,0
ffffffffc0205ac8:	46ad                	li	a3,11
ffffffffc0205aca:	00100637          	lui	a2,0x100
ffffffffc0205ace:	7ff005b7          	lui	a1,0x7ff00
ffffffffc0205ad2:	8526                	mv	a0,s1
ffffffffc0205ad4:	b6bfe0ef          	jal	ffffffffc020463e <mm_map>
ffffffffc0205ad8:	892a                	mv	s2,a0
ffffffffc0205ada:	18051f63          	bnez	a0,ffffffffc0205c78 <do_execve+0x364>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0205ade:	6c88                	ld	a0,24(s1)
ffffffffc0205ae0:	467d                	li	a2,31
ffffffffc0205ae2:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc0205ae6:	b87fd0ef          	jal	ffffffffc020366c <pgdir_alloc_page>
ffffffffc0205aea:	38050763          	beqz	a0,ffffffffc0205e78 <do_execve+0x564>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0205aee:	6c88                	ld	a0,24(s1)
ffffffffc0205af0:	467d                	li	a2,31
ffffffffc0205af2:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc0205af6:	b77fd0ef          	jal	ffffffffc020366c <pgdir_alloc_page>
ffffffffc0205afa:	34050e63          	beqz	a0,ffffffffc0205e56 <do_execve+0x542>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0205afe:	6c88                	ld	a0,24(s1)
ffffffffc0205b00:	467d                	li	a2,31
ffffffffc0205b02:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc0205b06:	b67fd0ef          	jal	ffffffffc020366c <pgdir_alloc_page>
ffffffffc0205b0a:	32050563          	beqz	a0,ffffffffc0205e34 <do_execve+0x520>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc0205b0e:	6c88                	ld	a0,24(s1)
ffffffffc0205b10:	467d                	li	a2,31
ffffffffc0205b12:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc0205b16:	b57fd0ef          	jal	ffffffffc020366c <pgdir_alloc_page>
ffffffffc0205b1a:	2e050c63          	beqz	a0,ffffffffc0205e12 <do_execve+0x4fe>
    mm->mm_count += 1;
ffffffffc0205b1e:	589c                	lw	a5,48(s1)
    current->mm = mm;
ffffffffc0205b20:	000db603          	ld	a2,0(s11)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205b24:	6c94                	ld	a3,24(s1)
ffffffffc0205b26:	2785                	addiw	a5,a5,1
ffffffffc0205b28:	d89c                	sw	a5,48(s1)
    current->mm = mm;
ffffffffc0205b2a:	f604                	sd	s1,40(a2)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205b2c:	c02007b7          	lui	a5,0xc0200
ffffffffc0205b30:	2cf6e463          	bltu	a3,a5,ffffffffc0205df8 <do_execve+0x4e4>
ffffffffc0205b34:	000b3783          	ld	a5,0(s6)
ffffffffc0205b38:	577d                	li	a4,-1
ffffffffc0205b3a:	177e                	slli	a4,a4,0x3f
ffffffffc0205b3c:	8e9d                	sub	a3,a3,a5
ffffffffc0205b3e:	00c6d793          	srli	a5,a3,0xc
ffffffffc0205b42:	f654                	sd	a3,168(a2)
ffffffffc0205b44:	8fd9                	or	a5,a5,a4
ffffffffc0205b46:	18079073          	csrw	satp,a5
    struct trapframe *tf = current->tf;
ffffffffc0205b4a:	7244                	ld	s1,160(a2)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0205b4c:	4581                	li	a1,0
ffffffffc0205b4e:	12000613          	li	a2,288
ffffffffc0205b52:	8526                	mv	a0,s1
ffffffffc0205b54:	4cd000ef          	jal	ffffffffc0206820 <memset>
    tf->epc = elf->e_entry;
ffffffffc0205b58:	018ab703          	ld	a4,24(s5)
    tf->gpr.sp = USTACKTOP;
ffffffffc0205b5c:	4785                	li	a5,1
ffffffffc0205b5e:	07fe                	slli	a5,a5,0x1f
ffffffffc0205b60:	e89c                	sd	a5,16(s1)
    tf->epc = elf->e_entry;
ffffffffc0205b62:	10e4b423          	sd	a4,264(s1)
    tf->status = (read_csr(sstatus) & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc0205b66:	100027f3          	csrr	a5,sstatus
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205b6a:	000db403          	ld	s0,0(s11)
    tf->status = (read_csr(sstatus) & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc0205b6e:	edf7f793          	andi	a5,a5,-289
ffffffffc0205b72:	0207e793          	ori	a5,a5,32
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205b76:	0b440413          	addi	s0,s0,180
    tf->status = (read_csr(sstatus) & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc0205b7a:	10f4b023          	sd	a5,256(s1)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205b7e:	4641                	li	a2,16
ffffffffc0205b80:	4581                	li	a1,0
ffffffffc0205b82:	8522                	mv	a0,s0
ffffffffc0205b84:	49d000ef          	jal	ffffffffc0206820 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205b88:	8522                	mv	a0,s0
ffffffffc0205b8a:	463d                	li	a2,15
ffffffffc0205b8c:	180c                	addi	a1,sp,48
ffffffffc0205b8e:	4a5000ef          	jal	ffffffffc0206832 <memcpy>
ffffffffc0205b92:	740a                	ld	s0,160(sp)
ffffffffc0205b94:	6a0a                	ld	s4,128(sp)
ffffffffc0205b96:	7b46                	ld	s6,112(sp)
ffffffffc0205b98:	7ba6                	ld	s7,104(sp)
ffffffffc0205b9a:	6ce6                	ld	s9,88(sp)
ffffffffc0205b9c:	6d46                	ld	s10,80(sp)
}
ffffffffc0205b9e:	70aa                	ld	ra,168(sp)
ffffffffc0205ba0:	64ea                	ld	s1,152(sp)
ffffffffc0205ba2:	69aa                	ld	s3,136(sp)
ffffffffc0205ba4:	7ae6                	ld	s5,120(sp)
ffffffffc0205ba6:	6da6                	ld	s11,72(sp)
ffffffffc0205ba8:	854a                	mv	a0,s2
ffffffffc0205baa:	694a                	ld	s2,144(sp)
ffffffffc0205bac:	614d                	addi	sp,sp,176
ffffffffc0205bae:	8082                	ret
    int ret = -E_NO_MEM;
ffffffffc0205bb0:	5971                	li	s2,-4
ffffffffc0205bb2:	bd51                	j	ffffffffc0205a46 <do_execve+0x132>
        if (ph->p_filesz > ph->p_memsz) {
ffffffffc0205bb4:	028a3603          	ld	a2,40(s4)
ffffffffc0205bb8:	020a3783          	ld	a5,32(s4)
ffffffffc0205bbc:	1ef66f63          	bltu	a2,a5,ffffffffc0205dba <do_execve+0x4a6>
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc0205bc0:	004a2783          	lw	a5,4(s4)
ffffffffc0205bc4:	0017f693          	andi	a3,a5,1
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205bc8:	0027f593          	andi	a1,a5,2
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc0205bcc:	0026971b          	slliw	a4,a3,0x2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205bd0:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc0205bd2:	068a                	slli	a3,a3,0x2
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205bd4:	e1e9                	bnez	a1,ffffffffc0205c96 <do_execve+0x382>
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205bd6:	1a079b63          	bnez	a5,ffffffffc0205d8c <do_execve+0x478>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0205bda:	47c5                	li	a5,17
ffffffffc0205bdc:	ec3e                	sd	a5,24(sp)
        if (vm_flags & VM_EXEC) perm |= PTE_X;
ffffffffc0205bde:	0046f793          	andi	a5,a3,4
ffffffffc0205be2:	c789                	beqz	a5,ffffffffc0205bec <do_execve+0x2d8>
ffffffffc0205be4:	67e2                	ld	a5,24(sp)
ffffffffc0205be6:	0087e793          	ori	a5,a5,8
ffffffffc0205bea:	ec3e                	sd	a5,24(sp)
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
ffffffffc0205bec:	010a3583          	ld	a1,16(s4)
ffffffffc0205bf0:	4701                	li	a4,0
ffffffffc0205bf2:	8526                	mv	a0,s1
ffffffffc0205bf4:	a4bfe0ef          	jal	ffffffffc020463e <mm_map>
ffffffffc0205bf8:	892a                	mv	s2,a0
ffffffffc0205bfa:	1a051e63          	bnez	a0,ffffffffc0205db6 <do_execve+0x4a2>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205bfe:	010a3c03          	ld	s8,16(s4)
        end = ph->p_va + ph->p_filesz;
ffffffffc0205c02:	020a3903          	ld	s2,32(s4)
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205c06:	008a3983          	ld	s3,8(s4)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205c0a:	77fd                	lui	a5,0xfffff
        end = ph->p_va + ph->p_filesz;
ffffffffc0205c0c:	9962                	add	s2,s2,s8
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205c0e:	00fc7bb3          	and	s7,s8,a5
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205c12:	99d6                	add	s3,s3,s5
        while (start < end) {
ffffffffc0205c14:	052c6963          	bltu	s8,s2,ffffffffc0205c66 <do_execve+0x352>
ffffffffc0205c18:	aa59                	j	ffffffffc0205dae <do_execve+0x49a>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205c1a:	6785                	lui	a5,0x1
ffffffffc0205c1c:	417c0533          	sub	a0,s8,s7
ffffffffc0205c20:	9bbe                	add	s7,s7,a5
            if (end < la) {
ffffffffc0205c22:	41890633          	sub	a2,s2,s8
ffffffffc0205c26:	01796463          	bltu	s2,s7,ffffffffc0205c2e <do_execve+0x31a>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205c2a:	418b8633          	sub	a2,s7,s8
    return page - pages + nbase;
ffffffffc0205c2e:	000d3683          	ld	a3,0(s10)
ffffffffc0205c32:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205c34:	000cb583          	ld	a1,0(s9)
    return page - pages + nbase;
ffffffffc0205c38:	40d406b3          	sub	a3,s0,a3
ffffffffc0205c3c:	8699                	srai	a3,a3,0x6
ffffffffc0205c3e:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205c40:	7782                	ld	a5,32(sp)
ffffffffc0205c42:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205c46:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205c48:	16b87c63          	bgeu	a6,a1,ffffffffc0205dc0 <do_execve+0x4ac>
ffffffffc0205c4c:	000b3803          	ld	a6,0(s6)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205c50:	85ce                	mv	a1,s3
ffffffffc0205c52:	e432                	sd	a2,8(sp)
ffffffffc0205c54:	96c2                	add	a3,a3,a6
ffffffffc0205c56:	9536                	add	a0,a0,a3
ffffffffc0205c58:	3db000ef          	jal	ffffffffc0206832 <memcpy>
            start += size, from += size;
ffffffffc0205c5c:	6622                	ld	a2,8(sp)
ffffffffc0205c5e:	9c32                	add	s8,s8,a2
ffffffffc0205c60:	99b2                	add	s3,s3,a2
        while (start < end) {
ffffffffc0205c62:	052c7363          	bgeu	s8,s2,ffffffffc0205ca8 <do_execve+0x394>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) { // 分配物理页并复制数据
ffffffffc0205c66:	6c88                	ld	a0,24(s1)
ffffffffc0205c68:	6662                	ld	a2,24(sp)
ffffffffc0205c6a:	85de                	mv	a1,s7
ffffffffc0205c6c:	a01fd0ef          	jal	ffffffffc020366c <pgdir_alloc_page>
ffffffffc0205c70:	842a                	mv	s0,a0
ffffffffc0205c72:	f545                	bnez	a0,ffffffffc0205c1a <do_execve+0x306>
ffffffffc0205c74:	7c06                	ld	s8,96(sp)
        ret = -E_NO_MEM;
ffffffffc0205c76:	5971                	li	s2,-4
    exit_mmap(mm);
ffffffffc0205c78:	8526                	mv	a0,s1
ffffffffc0205c7a:	a93fe0ef          	jal	ffffffffc020470c <exit_mmap>
ffffffffc0205c7e:	740a                	ld	s0,160(sp)
ffffffffc0205c80:	bb45                	j	ffffffffc0205a30 <do_execve+0x11c>
            exit_mmap(mm);
ffffffffc0205c82:	854e                	mv	a0,s3
ffffffffc0205c84:	a89fe0ef          	jal	ffffffffc020470c <exit_mmap>
            put_pgdir(mm);
ffffffffc0205c88:	854e                	mv	a0,s3
ffffffffc0205c8a:	c40ff0ef          	jal	ffffffffc02050ca <put_pgdir>
            mm_destroy(mm);  // 销毁 mm 结构，释放所有内存
ffffffffc0205c8e:	854e                	mv	a0,s3
ffffffffc0205c90:	95dfe0ef          	jal	ffffffffc02045ec <mm_destroy>
ffffffffc0205c94:	b309                	j	ffffffffc0205996 <do_execve+0x82>
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205c96:	10079263          	bnez	a5,ffffffffc0205d9a <do_execve+0x486>
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205c9a:	00276713          	ori	a4,a4,2
ffffffffc0205c9e:	0007069b          	sext.w	a3,a4
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205ca2:	47dd                	li	a5,23
ffffffffc0205ca4:	ec3e                	sd	a5,24(sp)
ffffffffc0205ca6:	bf25                	j	ffffffffc0205bde <do_execve+0x2ca>
        end = ph->p_va + ph->p_memsz;
ffffffffc0205ca8:	010a3903          	ld	s2,16(s4)
ffffffffc0205cac:	028a3683          	ld	a3,40(s4)
ffffffffc0205cb0:	9936                	add	s2,s2,a3
        if (start < la) {
ffffffffc0205cb2:	077c7a63          	bgeu	s8,s7,ffffffffc0205d26 <do_execve+0x412>
            if (start == end) {
ffffffffc0205cb6:	e18902e3          	beq	s2,s8,ffffffffc0205aba <do_execve+0x1a6>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205cba:	6505                	lui	a0,0x1
ffffffffc0205cbc:	9562                	add	a0,a0,s8
ffffffffc0205cbe:	41750533          	sub	a0,a0,s7
                size -= la - end;
ffffffffc0205cc2:	418909b3          	sub	s3,s2,s8
            if (end < la) {
ffffffffc0205cc6:	0d797f63          	bgeu	s2,s7,ffffffffc0205da4 <do_execve+0x490>
    return page - pages + nbase;
ffffffffc0205cca:	000d3683          	ld	a3,0(s10)
ffffffffc0205cce:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205cd0:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc0205cd4:	40d406b3          	sub	a3,s0,a3
ffffffffc0205cd8:	8699                	srai	a3,a3,0x6
ffffffffc0205cda:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205cdc:	00c69593          	slli	a1,a3,0xc
ffffffffc0205ce0:	81b1                	srli	a1,a1,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0205ce2:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205ce4:	0cc5fe63          	bgeu	a1,a2,ffffffffc0205dc0 <do_execve+0x4ac>
ffffffffc0205ce8:	000b3803          	ld	a6,0(s6)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205cec:	864e                	mv	a2,s3
ffffffffc0205cee:	4581                	li	a1,0
ffffffffc0205cf0:	96c2                	add	a3,a3,a6
ffffffffc0205cf2:	9536                	add	a0,a0,a3
ffffffffc0205cf4:	32d000ef          	jal	ffffffffc0206820 <memset>
            start += size;
ffffffffc0205cf8:	9c4e                	add	s8,s8,s3
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0205cfa:	03797463          	bgeu	s2,s7,ffffffffc0205d22 <do_execve+0x40e>
ffffffffc0205cfe:	db890ee3          	beq	s2,s8,ffffffffc0205aba <do_execve+0x1a6>
ffffffffc0205d02:	00003697          	auipc	a3,0x3
ffffffffc0205d06:	ab668693          	addi	a3,a3,-1354 # ffffffffc02087b8 <etext+0x1f6e>
ffffffffc0205d0a:	00001617          	auipc	a2,0x1
ffffffffc0205d0e:	1be60613          	addi	a2,a2,446 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0205d12:	2ba00593          	li	a1,698
ffffffffc0205d16:	00003517          	auipc	a0,0x3
ffffffffc0205d1a:	8ba50513          	addi	a0,a0,-1862 # ffffffffc02085d0 <etext+0x1d86>
ffffffffc0205d1e:	f56fa0ef          	jal	ffffffffc0200474 <__panic>
ffffffffc0205d22:	ff8b90e3          	bne	s7,s8,ffffffffc0205d02 <do_execve+0x3ee>
        while (start < end) {
ffffffffc0205d26:	d92c7ae3          	bgeu	s8,s2,ffffffffc0205aba <do_execve+0x1a6>
ffffffffc0205d2a:	56fd                	li	a3,-1
ffffffffc0205d2c:	00c6d793          	srli	a5,a3,0xc
ffffffffc0205d30:	e43e                	sd	a5,8(sp)
ffffffffc0205d32:	a0a9                	j	ffffffffc0205d7c <do_execve+0x468>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205d34:	6785                	lui	a5,0x1
ffffffffc0205d36:	417c0533          	sub	a0,s8,s7
ffffffffc0205d3a:	9bbe                	add	s7,s7,a5
            if (end < la) {
ffffffffc0205d3c:	418909b3          	sub	s3,s2,s8
ffffffffc0205d40:	01796463          	bltu	s2,s7,ffffffffc0205d48 <do_execve+0x434>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205d44:	418b89b3          	sub	s3,s7,s8
    return page - pages + nbase;
ffffffffc0205d48:	000d3683          	ld	a3,0(s10)
ffffffffc0205d4c:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205d4e:	000cb583          	ld	a1,0(s9)
    return page - pages + nbase;
ffffffffc0205d52:	40d406b3          	sub	a3,s0,a3
ffffffffc0205d56:	8699                	srai	a3,a3,0x6
ffffffffc0205d58:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205d5a:	67a2                	ld	a5,8(sp)
ffffffffc0205d5c:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205d60:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205d62:	04b87f63          	bgeu	a6,a1,ffffffffc0205dc0 <do_execve+0x4ac>
ffffffffc0205d66:	000b3803          	ld	a6,0(s6)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205d6a:	864e                	mv	a2,s3
ffffffffc0205d6c:	4581                	li	a1,0
ffffffffc0205d6e:	96c2                	add	a3,a3,a6
ffffffffc0205d70:	9536                	add	a0,a0,a3
            start += size;
ffffffffc0205d72:	9c4e                	add	s8,s8,s3
            memset(page2kva(page) + off, 0, size);
ffffffffc0205d74:	2ad000ef          	jal	ffffffffc0206820 <memset>
        while (start < end) {
ffffffffc0205d78:	d52c71e3          	bgeu	s8,s2,ffffffffc0205aba <do_execve+0x1a6>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205d7c:	6c88                	ld	a0,24(s1)
ffffffffc0205d7e:	6662                	ld	a2,24(sp)
ffffffffc0205d80:	85de                	mv	a1,s7
ffffffffc0205d82:	8ebfd0ef          	jal	ffffffffc020366c <pgdir_alloc_page>
ffffffffc0205d86:	842a                	mv	s0,a0
ffffffffc0205d88:	f555                	bnez	a0,ffffffffc0205d34 <do_execve+0x420>
ffffffffc0205d8a:	b5ed                	j	ffffffffc0205c74 <do_execve+0x360>
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205d8c:	00176713          	ori	a4,a4,1
ffffffffc0205d90:	47cd                	li	a5,19
ffffffffc0205d92:	0007069b          	sext.w	a3,a4
ffffffffc0205d96:	ec3e                	sd	a5,24(sp)
ffffffffc0205d98:	b599                	j	ffffffffc0205bde <do_execve+0x2ca>
ffffffffc0205d9a:	00376713          	ori	a4,a4,3
ffffffffc0205d9e:	0007069b          	sext.w	a3,a4
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205da2:	b701                	j	ffffffffc0205ca2 <do_execve+0x38e>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205da4:	418b89b3          	sub	s3,s7,s8
ffffffffc0205da8:	b70d                	j	ffffffffc0205cca <do_execve+0x3b6>
        return -E_INVAL;  // 如果程序名的内存不可访问，返回无效错误
ffffffffc0205daa:	5975                	li	s2,-3
ffffffffc0205dac:	bbcd                	j	ffffffffc0205b9e <do_execve+0x28a>
        while (start < end) {
ffffffffc0205dae:	8962                	mv	s2,s8
ffffffffc0205db0:	bdf5                	j	ffffffffc0205cac <do_execve+0x398>
    int ret = -E_NO_MEM;
ffffffffc0205db2:	5971                	li	s2,-4
ffffffffc0205db4:	b171                	j	ffffffffc0205a40 <do_execve+0x12c>
ffffffffc0205db6:	7c06                	ld	s8,96(sp)
ffffffffc0205db8:	b5c1                	j	ffffffffc0205c78 <do_execve+0x364>
            ret = -E_INVAL_ELF;
ffffffffc0205dba:	7c06                	ld	s8,96(sp)
ffffffffc0205dbc:	5961                	li	s2,-8
ffffffffc0205dbe:	bd6d                	j	ffffffffc0205c78 <do_execve+0x364>
ffffffffc0205dc0:	00001617          	auipc	a2,0x1
ffffffffc0205dc4:	45060613          	addi	a2,a2,1104 # ffffffffc0207210 <etext+0x9c6>
ffffffffc0205dc8:	06a00593          	li	a1,106
ffffffffc0205dcc:	00001517          	auipc	a0,0x1
ffffffffc0205dd0:	3f450513          	addi	a0,a0,1012 # ffffffffc02071c0 <etext+0x976>
ffffffffc0205dd4:	ea0fa0ef          	jal	ffffffffc0200474 <__panic>
ffffffffc0205dd8:	00001617          	auipc	a2,0x1
ffffffffc0205ddc:	43860613          	addi	a2,a2,1080 # ffffffffc0207210 <etext+0x9c6>
ffffffffc0205de0:	06a00593          	li	a1,106
ffffffffc0205de4:	00001517          	auipc	a0,0x1
ffffffffc0205de8:	3dc50513          	addi	a0,a0,988 # ffffffffc02071c0 <etext+0x976>
ffffffffc0205dec:	f122                	sd	s0,160(sp)
ffffffffc0205dee:	e152                	sd	s4,128(sp)
ffffffffc0205df0:	f8da                	sd	s6,112(sp)
ffffffffc0205df2:	f0e2                	sd	s8,96(sp)
ffffffffc0205df4:	e80fa0ef          	jal	ffffffffc0200474 <__panic>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205df8:	00001617          	auipc	a2,0x1
ffffffffc0205dfc:	46860613          	addi	a2,a2,1128 # ffffffffc0207260 <etext+0xa16>
ffffffffc0205e00:	2d800593          	li	a1,728
ffffffffc0205e04:	00002517          	auipc	a0,0x2
ffffffffc0205e08:	7cc50513          	addi	a0,a0,1996 # ffffffffc02085d0 <etext+0x1d86>
ffffffffc0205e0c:	f0e2                	sd	s8,96(sp)
ffffffffc0205e0e:	e66fa0ef          	jal	ffffffffc0200474 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc0205e12:	00003697          	auipc	a3,0x3
ffffffffc0205e16:	abe68693          	addi	a3,a3,-1346 # ffffffffc02088d0 <etext+0x2086>
ffffffffc0205e1a:	00001617          	auipc	a2,0x1
ffffffffc0205e1e:	0ae60613          	addi	a2,a2,174 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0205e22:	2d300593          	li	a1,723
ffffffffc0205e26:	00002517          	auipc	a0,0x2
ffffffffc0205e2a:	7aa50513          	addi	a0,a0,1962 # ffffffffc02085d0 <etext+0x1d86>
ffffffffc0205e2e:	f0e2                	sd	s8,96(sp)
ffffffffc0205e30:	e44fa0ef          	jal	ffffffffc0200474 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0205e34:	00003697          	auipc	a3,0x3
ffffffffc0205e38:	a5468693          	addi	a3,a3,-1452 # ffffffffc0208888 <etext+0x203e>
ffffffffc0205e3c:	00001617          	auipc	a2,0x1
ffffffffc0205e40:	08c60613          	addi	a2,a2,140 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0205e44:	2d200593          	li	a1,722
ffffffffc0205e48:	00002517          	auipc	a0,0x2
ffffffffc0205e4c:	78850513          	addi	a0,a0,1928 # ffffffffc02085d0 <etext+0x1d86>
ffffffffc0205e50:	f0e2                	sd	s8,96(sp)
ffffffffc0205e52:	e22fa0ef          	jal	ffffffffc0200474 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0205e56:	00003697          	auipc	a3,0x3
ffffffffc0205e5a:	9ea68693          	addi	a3,a3,-1558 # ffffffffc0208840 <etext+0x1ff6>
ffffffffc0205e5e:	00001617          	auipc	a2,0x1
ffffffffc0205e62:	06a60613          	addi	a2,a2,106 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0205e66:	2d100593          	li	a1,721
ffffffffc0205e6a:	00002517          	auipc	a0,0x2
ffffffffc0205e6e:	76650513          	addi	a0,a0,1894 # ffffffffc02085d0 <etext+0x1d86>
ffffffffc0205e72:	f0e2                	sd	s8,96(sp)
ffffffffc0205e74:	e00fa0ef          	jal	ffffffffc0200474 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0205e78:	00003697          	auipc	a3,0x3
ffffffffc0205e7c:	98068693          	addi	a3,a3,-1664 # ffffffffc02087f8 <etext+0x1fae>
ffffffffc0205e80:	00001617          	auipc	a2,0x1
ffffffffc0205e84:	04860613          	addi	a2,a2,72 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0205e88:	2d000593          	li	a1,720
ffffffffc0205e8c:	00002517          	auipc	a0,0x2
ffffffffc0205e90:	74450513          	addi	a0,a0,1860 # ffffffffc02085d0 <etext+0x1d86>
ffffffffc0205e94:	f0e2                	sd	s8,96(sp)
ffffffffc0205e96:	ddefa0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc0205e9a <do_yield>:
    current->need_resched = 1;
ffffffffc0205e9a:	00098797          	auipc	a5,0x98
ffffffffc0205e9e:	1567b783          	ld	a5,342(a5) # ffffffffc029dff0 <current>
ffffffffc0205ea2:	4705                	li	a4,1
ffffffffc0205ea4:	ef98                	sd	a4,24(a5)
}
ffffffffc0205ea6:	4501                	li	a0,0
ffffffffc0205ea8:	8082                	ret

ffffffffc0205eaa <do_wait>:
do_wait(int pid, int *code_store) {
ffffffffc0205eaa:	1101                	addi	sp,sp,-32
ffffffffc0205eac:	e822                	sd	s0,16(sp)
ffffffffc0205eae:	e426                	sd	s1,8(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0205eb0:	00098797          	auipc	a5,0x98
ffffffffc0205eb4:	1407b783          	ld	a5,320(a5) # ffffffffc029dff0 <current>
do_wait(int pid, int *code_store) {
ffffffffc0205eb8:	ec06                	sd	ra,24(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0205eba:	779c                	ld	a5,40(a5)
do_wait(int pid, int *code_store) {
ffffffffc0205ebc:	842e                	mv	s0,a1
ffffffffc0205ebe:	84aa                	mv	s1,a0
    if (code_store != NULL) {
ffffffffc0205ec0:	c599                	beqz	a1,ffffffffc0205ece <do_wait+0x24>
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
ffffffffc0205ec2:	4685                	li	a3,1
ffffffffc0205ec4:	4611                	li	a2,4
ffffffffc0205ec6:	853e                	mv	a0,a5
ffffffffc0205ec8:	f09fe0ef          	jal	ffffffffc0204dd0 <user_mem_check>
ffffffffc0205ecc:	c909                	beqz	a0,ffffffffc0205ede <do_wait+0x34>
ffffffffc0205ece:	85a2                	mv	a1,s0
}
ffffffffc0205ed0:	6442                	ld	s0,16(sp)
ffffffffc0205ed2:	60e2                	ld	ra,24(sp)
ffffffffc0205ed4:	8526                	mv	a0,s1
ffffffffc0205ed6:	64a2                	ld	s1,8(sp)
ffffffffc0205ed8:	6105                	addi	sp,sp,32
ffffffffc0205eda:	f36ff06f          	j	ffffffffc0205610 <do_wait.part.0>
ffffffffc0205ede:	60e2                	ld	ra,24(sp)
ffffffffc0205ee0:	6442                	ld	s0,16(sp)
ffffffffc0205ee2:	64a2                	ld	s1,8(sp)
ffffffffc0205ee4:	5575                	li	a0,-3
ffffffffc0205ee6:	6105                	addi	sp,sp,32
ffffffffc0205ee8:	8082                	ret

ffffffffc0205eea <do_kill>:
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205eea:	6789                	lui	a5,0x2
ffffffffc0205eec:	fff5071b          	addiw	a4,a0,-1
ffffffffc0205ef0:	17f9                	addi	a5,a5,-2 # 1ffe <_binary_obj___user_softint_out_size-0x663a>
ffffffffc0205ef2:	06e7e963          	bltu	a5,a4,ffffffffc0205f64 <do_kill+0x7a>
do_kill(int pid) {
ffffffffc0205ef6:	1141                	addi	sp,sp,-16
ffffffffc0205ef8:	e022                	sd	s0,0(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205efa:	45a9                	li	a1,10
ffffffffc0205efc:	842a                	mv	s0,a0
ffffffffc0205efe:	2501                	sext.w	a0,a0
do_kill(int pid) {
ffffffffc0205f00:	e406                	sd	ra,8(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205f02:	48a000ef          	jal	ffffffffc020638c <hash32>
ffffffffc0205f06:	02051793          	slli	a5,a0,0x20
ffffffffc0205f0a:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0205f0e:	00094797          	auipc	a5,0x94
ffffffffc0205f12:	05278793          	addi	a5,a5,82 # ffffffffc0299f60 <hash_list>
ffffffffc0205f16:	953e                	add	a0,a0,a5
ffffffffc0205f18:	87aa                	mv	a5,a0
        while ((le = list_next(le)) != list) {
ffffffffc0205f1a:	a029                	j	ffffffffc0205f24 <do_kill+0x3a>
            if (proc->pid == pid) {
ffffffffc0205f1c:	f2c7a703          	lw	a4,-212(a5)
ffffffffc0205f20:	00870a63          	beq	a4,s0,ffffffffc0205f34 <do_kill+0x4a>
ffffffffc0205f24:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0205f26:	fef51be3          	bne	a0,a5,ffffffffc0205f1c <do_kill+0x32>
    return -E_INVAL;
ffffffffc0205f2a:	5575                	li	a0,-3
}
ffffffffc0205f2c:	60a2                	ld	ra,8(sp)
ffffffffc0205f2e:	6402                	ld	s0,0(sp)
ffffffffc0205f30:	0141                	addi	sp,sp,16
ffffffffc0205f32:	8082                	ret
        if (!(proc->flags & PF_EXITING)) {
ffffffffc0205f34:	fd87a703          	lw	a4,-40(a5)
        return -E_KILLED;
ffffffffc0205f38:	555d                	li	a0,-9
        if (!(proc->flags & PF_EXITING)) {
ffffffffc0205f3a:	00177693          	andi	a3,a4,1
ffffffffc0205f3e:	f6fd                	bnez	a3,ffffffffc0205f2c <do_kill+0x42>
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205f40:	4bd4                	lw	a3,20(a5)
            proc->flags |= PF_EXITING;
ffffffffc0205f42:	00176713          	ori	a4,a4,1
ffffffffc0205f46:	fce7ac23          	sw	a4,-40(a5)
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205f4a:	0006c763          	bltz	a3,ffffffffc0205f58 <do_kill+0x6e>
            return 0;
ffffffffc0205f4e:	4501                	li	a0,0
}
ffffffffc0205f50:	60a2                	ld	ra,8(sp)
ffffffffc0205f52:	6402                	ld	s0,0(sp)
ffffffffc0205f54:	0141                	addi	sp,sp,16
ffffffffc0205f56:	8082                	ret
                wakeup_proc(proc);
ffffffffc0205f58:	f2878513          	addi	a0,a5,-216
ffffffffc0205f5c:	22a000ef          	jal	ffffffffc0206186 <wakeup_proc>
            return 0;
ffffffffc0205f60:	4501                	li	a0,0
ffffffffc0205f62:	b7fd                	j	ffffffffc0205f50 <do_kill+0x66>
    return -E_INVAL;
ffffffffc0205f64:	5575                	li	a0,-3
}
ffffffffc0205f66:	8082                	ret

ffffffffc0205f68 <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc0205f68:	1101                	addi	sp,sp,-32
ffffffffc0205f6a:	e426                	sd	s1,8(sp)
    elm->prev = elm->next = elm;
ffffffffc0205f6c:	00098797          	auipc	a5,0x98
ffffffffc0205f70:	ff478793          	addi	a5,a5,-12 # ffffffffc029df60 <proc_list>
ffffffffc0205f74:	ec06                	sd	ra,24(sp)
ffffffffc0205f76:	e822                	sd	s0,16(sp)
ffffffffc0205f78:	e04a                	sd	s2,0(sp)
ffffffffc0205f7a:	00094497          	auipc	s1,0x94
ffffffffc0205f7e:	fe648493          	addi	s1,s1,-26 # ffffffffc0299f60 <hash_list>
ffffffffc0205f82:	e79c                	sd	a5,8(a5)
ffffffffc0205f84:	e39c                	sd	a5,0(a5)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc0205f86:	00098717          	auipc	a4,0x98
ffffffffc0205f8a:	fda70713          	addi	a4,a4,-38 # ffffffffc029df60 <proc_list>
ffffffffc0205f8e:	87a6                	mv	a5,s1
ffffffffc0205f90:	e79c                	sd	a5,8(a5)
ffffffffc0205f92:	e39c                	sd	a5,0(a5)
ffffffffc0205f94:	07c1                	addi	a5,a5,16
ffffffffc0205f96:	fee79de3          	bne	a5,a4,ffffffffc0205f90 <proc_init+0x28>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc0205f9a:	832ff0ef          	jal	ffffffffc0204fcc <alloc_proc>
ffffffffc0205f9e:	00098917          	auipc	s2,0x98
ffffffffc0205fa2:	06290913          	addi	s2,s2,98 # ffffffffc029e000 <idleproc>
ffffffffc0205fa6:	00a93023          	sd	a0,0(s2)
ffffffffc0205faa:	10050063          	beqz	a0,ffffffffc02060aa <proc_init+0x142>
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0205fae:	4789                	li	a5,2
ffffffffc0205fb0:	e11c                	sd	a5,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205fb2:	00003797          	auipc	a5,0x3
ffffffffc0205fb6:	04e78793          	addi	a5,a5,78 # ffffffffc0209000 <bootstack>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205fba:	0b450413          	addi	s0,a0,180
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205fbe:	e91c                	sd	a5,16(a0)
    idleproc->need_resched = 1;
ffffffffc0205fc0:	4785                	li	a5,1
ffffffffc0205fc2:	ed1c                	sd	a5,24(a0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205fc4:	4641                	li	a2,16
ffffffffc0205fc6:	4581                	li	a1,0
ffffffffc0205fc8:	8522                	mv	a0,s0
ffffffffc0205fca:	057000ef          	jal	ffffffffc0206820 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205fce:	463d                	li	a2,15
ffffffffc0205fd0:	00003597          	auipc	a1,0x3
ffffffffc0205fd4:	96058593          	addi	a1,a1,-1696 # ffffffffc0208930 <etext+0x20e6>
ffffffffc0205fd8:	8522                	mv	a0,s0
ffffffffc0205fda:	059000ef          	jal	ffffffffc0206832 <memcpy>
    set_proc_name(idleproc, "idle");
    nr_process ++;
ffffffffc0205fde:	00098717          	auipc	a4,0x98
ffffffffc0205fe2:	00a70713          	addi	a4,a4,10 # ffffffffc029dfe8 <nr_process>
ffffffffc0205fe6:	431c                	lw	a5,0(a4)

    current = idleproc;
ffffffffc0205fe8:	00093683          	ld	a3,0(s2)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205fec:	4601                	li	a2,0
    nr_process ++;
ffffffffc0205fee:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205ff0:	4581                	li	a1,0
ffffffffc0205ff2:	fffff517          	auipc	a0,0xfffff
ffffffffc0205ff6:	7fe50513          	addi	a0,a0,2046 # ffffffffc02057f0 <init_main>
    nr_process ++;
ffffffffc0205ffa:	c31c                	sw	a5,0(a4)
    current = idleproc;
ffffffffc0205ffc:	00098797          	auipc	a5,0x98
ffffffffc0206000:	fed7ba23          	sd	a3,-12(a5) # ffffffffc029dff0 <current>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0206004:	c6cff0ef          	jal	ffffffffc0205470 <kernel_thread>
ffffffffc0206008:	842a                	mv	s0,a0
    if (pid <= 0) {
ffffffffc020600a:	08a05463          	blez	a0,ffffffffc0206092 <proc_init+0x12a>
    if (0 < pid && pid < MAX_PID) {
ffffffffc020600e:	6789                	lui	a5,0x2
ffffffffc0206010:	fff5071b          	addiw	a4,a0,-1
ffffffffc0206014:	17f9                	addi	a5,a5,-2 # 1ffe <_binary_obj___user_softint_out_size-0x663a>
ffffffffc0206016:	2501                	sext.w	a0,a0
ffffffffc0206018:	02e7e463          	bltu	a5,a4,ffffffffc0206040 <proc_init+0xd8>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc020601c:	45a9                	li	a1,10
ffffffffc020601e:	36e000ef          	jal	ffffffffc020638c <hash32>
ffffffffc0206022:	02051713          	slli	a4,a0,0x20
ffffffffc0206026:	01c75793          	srli	a5,a4,0x1c
ffffffffc020602a:	00f486b3          	add	a3,s1,a5
ffffffffc020602e:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc0206030:	a029                	j	ffffffffc020603a <proc_init+0xd2>
            if (proc->pid == pid) {
ffffffffc0206032:	f2c7a703          	lw	a4,-212(a5)
ffffffffc0206036:	04870b63          	beq	a4,s0,ffffffffc020608c <proc_init+0x124>
    return listelm->next;
ffffffffc020603a:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc020603c:	fef69be3          	bne	a3,a5,ffffffffc0206032 <proc_init+0xca>
    return NULL;
ffffffffc0206040:	4781                	li	a5,0
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0206042:	0b478493          	addi	s1,a5,180
ffffffffc0206046:	4641                	li	a2,16
ffffffffc0206048:	4581                	li	a1,0
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc020604a:	00098417          	auipc	s0,0x98
ffffffffc020604e:	fae40413          	addi	s0,s0,-82 # ffffffffc029dff8 <initproc>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0206052:	8526                	mv	a0,s1
    initproc = find_proc(pid);
ffffffffc0206054:	e01c                	sd	a5,0(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0206056:	7ca000ef          	jal	ffffffffc0206820 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc020605a:	463d                	li	a2,15
ffffffffc020605c:	00003597          	auipc	a1,0x3
ffffffffc0206060:	8fc58593          	addi	a1,a1,-1796 # ffffffffc0208958 <etext+0x210e>
ffffffffc0206064:	8526                	mv	a0,s1
ffffffffc0206066:	7cc000ef          	jal	ffffffffc0206832 <memcpy>
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc020606a:	00093783          	ld	a5,0(s2)
ffffffffc020606e:	cbb5                	beqz	a5,ffffffffc02060e2 <proc_init+0x17a>
ffffffffc0206070:	43dc                	lw	a5,4(a5)
ffffffffc0206072:	eba5                	bnez	a5,ffffffffc02060e2 <proc_init+0x17a>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0206074:	601c                	ld	a5,0(s0)
ffffffffc0206076:	c7b1                	beqz	a5,ffffffffc02060c2 <proc_init+0x15a>
ffffffffc0206078:	43d8                	lw	a4,4(a5)
ffffffffc020607a:	4785                	li	a5,1
ffffffffc020607c:	04f71363          	bne	a4,a5,ffffffffc02060c2 <proc_init+0x15a>
}
ffffffffc0206080:	60e2                	ld	ra,24(sp)
ffffffffc0206082:	6442                	ld	s0,16(sp)
ffffffffc0206084:	64a2                	ld	s1,8(sp)
ffffffffc0206086:	6902                	ld	s2,0(sp)
ffffffffc0206088:	6105                	addi	sp,sp,32
ffffffffc020608a:	8082                	ret
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc020608c:	f2878793          	addi	a5,a5,-216
ffffffffc0206090:	bf4d                	j	ffffffffc0206042 <proc_init+0xda>
        panic("create init_main failed.\n");
ffffffffc0206092:	00003617          	auipc	a2,0x3
ffffffffc0206096:	8a660613          	addi	a2,a2,-1882 # ffffffffc0208938 <etext+0x20ee>
ffffffffc020609a:	41300593          	li	a1,1043
ffffffffc020609e:	00002517          	auipc	a0,0x2
ffffffffc02060a2:	53250513          	addi	a0,a0,1330 # ffffffffc02085d0 <etext+0x1d86>
ffffffffc02060a6:	bcefa0ef          	jal	ffffffffc0200474 <__panic>
        panic("cannot alloc idleproc.\n");
ffffffffc02060aa:	00003617          	auipc	a2,0x3
ffffffffc02060ae:	86e60613          	addi	a2,a2,-1938 # ffffffffc0208918 <etext+0x20ce>
ffffffffc02060b2:	40500593          	li	a1,1029
ffffffffc02060b6:	00002517          	auipc	a0,0x2
ffffffffc02060ba:	51a50513          	addi	a0,a0,1306 # ffffffffc02085d0 <etext+0x1d86>
ffffffffc02060be:	bb6fa0ef          	jal	ffffffffc0200474 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc02060c2:	00003697          	auipc	a3,0x3
ffffffffc02060c6:	8c668693          	addi	a3,a3,-1850 # ffffffffc0208988 <etext+0x213e>
ffffffffc02060ca:	00001617          	auipc	a2,0x1
ffffffffc02060ce:	dfe60613          	addi	a2,a2,-514 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc02060d2:	41a00593          	li	a1,1050
ffffffffc02060d6:	00002517          	auipc	a0,0x2
ffffffffc02060da:	4fa50513          	addi	a0,a0,1274 # ffffffffc02085d0 <etext+0x1d86>
ffffffffc02060de:	b96fa0ef          	jal	ffffffffc0200474 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc02060e2:	00003697          	auipc	a3,0x3
ffffffffc02060e6:	87e68693          	addi	a3,a3,-1922 # ffffffffc0208960 <etext+0x2116>
ffffffffc02060ea:	00001617          	auipc	a2,0x1
ffffffffc02060ee:	dde60613          	addi	a2,a2,-546 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc02060f2:	41900593          	li	a1,1049
ffffffffc02060f6:	00002517          	auipc	a0,0x2
ffffffffc02060fa:	4da50513          	addi	a0,a0,1242 # ffffffffc02085d0 <etext+0x1d86>
ffffffffc02060fe:	b76fa0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc0206102 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc0206102:	1141                	addi	sp,sp,-16
ffffffffc0206104:	e022                	sd	s0,0(sp)
ffffffffc0206106:	e406                	sd	ra,8(sp)
ffffffffc0206108:	00098417          	auipc	s0,0x98
ffffffffc020610c:	ee840413          	addi	s0,s0,-280 # ffffffffc029dff0 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc0206110:	6018                	ld	a4,0(s0)
ffffffffc0206112:	6f1c                	ld	a5,24(a4)
ffffffffc0206114:	dffd                	beqz	a5,ffffffffc0206112 <cpu_idle+0x10>
            schedule();
ffffffffc0206116:	10a000ef          	jal	ffffffffc0206220 <schedule>
ffffffffc020611a:	bfdd                	j	ffffffffc0206110 <cpu_idle+0xe>

ffffffffc020611c <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc020611c:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0206120:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0206124:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0206126:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0206128:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc020612c:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0206130:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0206134:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0206138:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc020613c:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0206140:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0206144:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0206148:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc020614c:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0206150:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0206154:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc0206158:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc020615a:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc020615c:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0206160:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0206164:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc0206168:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc020616c:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0206170:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0206174:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc0206178:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc020617c:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0206180:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0206184:	8082                	ret

ffffffffc0206186 <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0206186:	4118                	lw	a4,0(a0)
wakeup_proc(struct proc_struct *proc) {
ffffffffc0206188:	1141                	addi	sp,sp,-16
ffffffffc020618a:	e406                	sd	ra,8(sp)
ffffffffc020618c:	e022                	sd	s0,0(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc020618e:	478d                	li	a5,3
ffffffffc0206190:	06f70963          	beq	a4,a5,ffffffffc0206202 <wakeup_proc+0x7c>
ffffffffc0206194:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0206196:	100027f3          	csrr	a5,sstatus
ffffffffc020619a:	8b89                	andi	a5,a5,2
ffffffffc020619c:	eb99                	bnez	a5,ffffffffc02061b2 <wakeup_proc+0x2c>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE) {
ffffffffc020619e:	4789                	li	a5,2
ffffffffc02061a0:	02f70763          	beq	a4,a5,ffffffffc02061ce <wakeup_proc+0x48>
        else {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc02061a4:	60a2                	ld	ra,8(sp)
ffffffffc02061a6:	6402                	ld	s0,0(sp)
            proc->state = PROC_RUNNABLE;
ffffffffc02061a8:	c11c                	sw	a5,0(a0)
            proc->wait_state = 0;
ffffffffc02061aa:	0e052623          	sw	zero,236(a0)
}
ffffffffc02061ae:	0141                	addi	sp,sp,16
ffffffffc02061b0:	8082                	ret
        intr_disable();
ffffffffc02061b2:	c8efa0ef          	jal	ffffffffc0200640 <intr_disable>
        if (proc->state != PROC_RUNNABLE) {
ffffffffc02061b6:	4018                	lw	a4,0(s0)
ffffffffc02061b8:	4789                	li	a5,2
ffffffffc02061ba:	02f70863          	beq	a4,a5,ffffffffc02061ea <wakeup_proc+0x64>
            proc->state = PROC_RUNNABLE;
ffffffffc02061be:	c01c                	sw	a5,0(s0)
            proc->wait_state = 0;
ffffffffc02061c0:	0e042623          	sw	zero,236(s0)
}
ffffffffc02061c4:	6402                	ld	s0,0(sp)
ffffffffc02061c6:	60a2                	ld	ra,8(sp)
ffffffffc02061c8:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc02061ca:	c70fa06f          	j	ffffffffc020063a <intr_enable>
ffffffffc02061ce:	6402                	ld	s0,0(sp)
ffffffffc02061d0:	60a2                	ld	ra,8(sp)
            warn("wakeup runnable process.\n");
ffffffffc02061d2:	00003617          	auipc	a2,0x3
ffffffffc02061d6:	81660613          	addi	a2,a2,-2026 # ffffffffc02089e8 <etext+0x219e>
ffffffffc02061da:	45c9                	li	a1,18
ffffffffc02061dc:	00002517          	auipc	a0,0x2
ffffffffc02061e0:	7f450513          	addi	a0,a0,2036 # ffffffffc02089d0 <etext+0x2186>
}
ffffffffc02061e4:	0141                	addi	sp,sp,16
            warn("wakeup runnable process.\n");
ffffffffc02061e6:	af8fa06f          	j	ffffffffc02004de <__warn>
ffffffffc02061ea:	00002617          	auipc	a2,0x2
ffffffffc02061ee:	7fe60613          	addi	a2,a2,2046 # ffffffffc02089e8 <etext+0x219e>
ffffffffc02061f2:	45c9                	li	a1,18
ffffffffc02061f4:	00002517          	auipc	a0,0x2
ffffffffc02061f8:	7dc50513          	addi	a0,a0,2012 # ffffffffc02089d0 <etext+0x2186>
ffffffffc02061fc:	ae2fa0ef          	jal	ffffffffc02004de <__warn>
    if (flag) {
ffffffffc0206200:	b7d1                	j	ffffffffc02061c4 <wakeup_proc+0x3e>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0206202:	00002697          	auipc	a3,0x2
ffffffffc0206206:	7ae68693          	addi	a3,a3,1966 # ffffffffc02089b0 <etext+0x2166>
ffffffffc020620a:	00001617          	auipc	a2,0x1
ffffffffc020620e:	cbe60613          	addi	a2,a2,-834 # ffffffffc0206ec8 <etext+0x67e>
ffffffffc0206212:	45a5                	li	a1,9
ffffffffc0206214:	00002517          	auipc	a0,0x2
ffffffffc0206218:	7bc50513          	addi	a0,a0,1980 # ffffffffc02089d0 <etext+0x2186>
ffffffffc020621c:	a58fa0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc0206220 <schedule>:

void
schedule(void) {
ffffffffc0206220:	1141                	addi	sp,sp,-16
ffffffffc0206222:	e406                	sd	ra,8(sp)
ffffffffc0206224:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0206226:	100027f3          	csrr	a5,sstatus
ffffffffc020622a:	8b89                	andi	a5,a5,2
ffffffffc020622c:	4401                	li	s0,0
ffffffffc020622e:	efbd                	bnez	a5,ffffffffc02062ac <schedule+0x8c>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc0206230:	00098897          	auipc	a7,0x98
ffffffffc0206234:	dc08b883          	ld	a7,-576(a7) # ffffffffc029dff0 <current>
ffffffffc0206238:	0008bc23          	sd	zero,24(a7)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc020623c:	00098517          	auipc	a0,0x98
ffffffffc0206240:	dc453503          	ld	a0,-572(a0) # ffffffffc029e000 <idleproc>
ffffffffc0206244:	04a88e63          	beq	a7,a0,ffffffffc02062a0 <schedule+0x80>
ffffffffc0206248:	0c888693          	addi	a3,a7,200
ffffffffc020624c:	00098617          	auipc	a2,0x98
ffffffffc0206250:	d1460613          	addi	a2,a2,-748 # ffffffffc029df60 <proc_list>
        le = last;
ffffffffc0206254:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc0206256:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc0206258:	4809                	li	a6,2
ffffffffc020625a:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc020625c:	00c78863          	beq	a5,a2,ffffffffc020626c <schedule+0x4c>
                if (next->state == PROC_RUNNABLE) {
ffffffffc0206260:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc0206264:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc0206268:	03070163          	beq	a4,a6,ffffffffc020628a <schedule+0x6a>
                    break;
                }
            }
        } while (le != last);
ffffffffc020626c:	fef697e3          	bne	a3,a5,ffffffffc020625a <schedule+0x3a>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0206270:	ed89                	bnez	a1,ffffffffc020628a <schedule+0x6a>
            next = idleproc;
        }
        next->runs ++;
ffffffffc0206272:	451c                	lw	a5,8(a0)
ffffffffc0206274:	2785                	addiw	a5,a5,1
ffffffffc0206276:	c51c                	sw	a5,8(a0)
        if (next != current) {
ffffffffc0206278:	00a88463          	beq	a7,a0,ffffffffc0206280 <schedule+0x60>
            proc_run(next);
ffffffffc020627c:	ec5fe0ef          	jal	ffffffffc0205140 <proc_run>
    if (flag) {
ffffffffc0206280:	e819                	bnez	s0,ffffffffc0206296 <schedule+0x76>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0206282:	60a2                	ld	ra,8(sp)
ffffffffc0206284:	6402                	ld	s0,0(sp)
ffffffffc0206286:	0141                	addi	sp,sp,16
ffffffffc0206288:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc020628a:	4198                	lw	a4,0(a1)
ffffffffc020628c:	4789                	li	a5,2
ffffffffc020628e:	fef712e3          	bne	a4,a5,ffffffffc0206272 <schedule+0x52>
ffffffffc0206292:	852e                	mv	a0,a1
ffffffffc0206294:	bff9                	j	ffffffffc0206272 <schedule+0x52>
}
ffffffffc0206296:	6402                	ld	s0,0(sp)
ffffffffc0206298:	60a2                	ld	ra,8(sp)
ffffffffc020629a:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc020629c:	b9efa06f          	j	ffffffffc020063a <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc02062a0:	00098617          	auipc	a2,0x98
ffffffffc02062a4:	cc060613          	addi	a2,a2,-832 # ffffffffc029df60 <proc_list>
ffffffffc02062a8:	86b2                	mv	a3,a2
ffffffffc02062aa:	b76d                	j	ffffffffc0206254 <schedule+0x34>
        intr_disable();
ffffffffc02062ac:	b94fa0ef          	jal	ffffffffc0200640 <intr_disable>
        return 1;
ffffffffc02062b0:	4405                	li	s0,1
ffffffffc02062b2:	bfbd                	j	ffffffffc0206230 <schedule+0x10>

ffffffffc02062b4 <sys_getpid>:
}

static int
sys_getpid(uint64_t arg[]) {
    // 返回当前进程的 PID
    return current->pid;
ffffffffc02062b4:	00098797          	auipc	a5,0x98
ffffffffc02062b8:	d3c7b783          	ld	a5,-708(a5) # ffffffffc029dff0 <current>
}
ffffffffc02062bc:	43c8                	lw	a0,4(a5)
ffffffffc02062be:	8082                	ret

ffffffffc02062c0 <sys_pgdir>:
    // 该系统调用暂时没有实现具体功能，但可以用来打印当前进程的页表信息
    // print_pgdir();
    
    // 返回 0，表示成功
    return 0;
}
ffffffffc02062c0:	4501                	li	a0,0
ffffffffc02062c2:	8082                	ret

ffffffffc02062c4 <sys_putc>:
    cputchar(c);
ffffffffc02062c4:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc02062c6:	1141                	addi	sp,sp,-16
ffffffffc02062c8:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc02062ca:	eebf90ef          	jal	ffffffffc02001b4 <cputchar>
}
ffffffffc02062ce:	60a2                	ld	ra,8(sp)
ffffffffc02062d0:	4501                	li	a0,0
ffffffffc02062d2:	0141                	addi	sp,sp,16
ffffffffc02062d4:	8082                	ret

ffffffffc02062d6 <sys_kill>:
    return do_kill(pid);
ffffffffc02062d6:	4108                	lw	a0,0(a0)
ffffffffc02062d8:	c13ff06f          	j	ffffffffc0205eea <do_kill>

ffffffffc02062dc <sys_yield>:
    return do_yield();
ffffffffc02062dc:	bbfff06f          	j	ffffffffc0205e9a <do_yield>

ffffffffc02062e0 <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc02062e0:	6d14                	ld	a3,24(a0)
ffffffffc02062e2:	6910                	ld	a2,16(a0)
ffffffffc02062e4:	650c                	ld	a1,8(a0)
ffffffffc02062e6:	6108                	ld	a0,0(a0)
ffffffffc02062e8:	e2cff06f          	j	ffffffffc0205914 <do_execve>

ffffffffc02062ec <sys_wait>:
    return do_wait(pid, store);
ffffffffc02062ec:	650c                	ld	a1,8(a0)
ffffffffc02062ee:	4108                	lw	a0,0(a0)
ffffffffc02062f0:	bbbff06f          	j	ffffffffc0205eaa <do_wait>

ffffffffc02062f4 <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc02062f4:	00098797          	auipc	a5,0x98
ffffffffc02062f8:	cfc7b783          	ld	a5,-772(a5) # ffffffffc029dff0 <current>
ffffffffc02062fc:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc02062fe:	4501                	li	a0,0
ffffffffc0206300:	6a0c                	ld	a1,16(a2)
ffffffffc0206302:	eabfe06f          	j	ffffffffc02051ac <do_fork>

ffffffffc0206306 <sys_exit>:
    return do_exit(error_code);
ffffffffc0206306:	4108                	lw	a0,0(a0)
ffffffffc0206308:	9b8ff06f          	j	ffffffffc02054c0 <do_exit>

ffffffffc020630c <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
ffffffffc020630c:	715d                	addi	sp,sp,-80
ffffffffc020630e:	fc26                	sd	s1,56(sp)
    // 获取当前进程的陷入帧（trapframe），用于访问当前进程的寄存器状态
    struct trapframe *tf = current->tf;
ffffffffc0206310:	00098497          	auipc	s1,0x98
ffffffffc0206314:	ce048493          	addi	s1,s1,-800 # ffffffffc029dff0 <current>
ffffffffc0206318:	6098                	ld	a4,0(s1)
syscall(void) {
ffffffffc020631a:	e0a2                	sd	s0,64(sp)
ffffffffc020631c:	f84a                	sd	s2,48(sp)
    struct trapframe *tf = current->tf;
ffffffffc020631e:	7340                	ld	s0,160(a4)
syscall(void) {
ffffffffc0206320:	e486                	sd	ra,72(sp)
    // 从 a0 寄存器获取系统调用编号
    uint64_t arg[5];  // 用于存储传递给系统调用的参数
    int num = tf->gpr.a0;  // a0 寄存器保存系统调用编号

    // 检查系统调用编号是否有效，防止越界访问 syscalls 数组
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0206322:	47fd                	li	a5,31
    int num = tf->gpr.a0;  // a0 寄存器保存系统调用编号
ffffffffc0206324:	05042903          	lw	s2,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0206328:	0327ee63          	bltu	a5,s2,ffffffffc0206364 <syscall+0x58>
        // 如果系统调用编号合法且该编号对应的系统调用存在
        if (syscalls[num] != NULL) {
ffffffffc020632c:	00391713          	slli	a4,s2,0x3
ffffffffc0206330:	00003797          	auipc	a5,0x3
ffffffffc0206334:	90078793          	addi	a5,a5,-1792 # ffffffffc0208c30 <syscalls>
ffffffffc0206338:	97ba                	add	a5,a5,a4
ffffffffc020633a:	639c                	ld	a5,0(a5)
ffffffffc020633c:	c785                	beqz	a5,ffffffffc0206364 <syscall+0x58>
            // 从寄存器中提取出参数，并存入 arg 数组
            arg[0] = tf->gpr.a1;  // a1 寄存器保存第一个参数
ffffffffc020633e:	7028                	ld	a0,96(s0)
ffffffffc0206340:	742c                	ld	a1,104(s0)
ffffffffc0206342:	7834                	ld	a3,112(s0)
ffffffffc0206344:	7c38                	ld	a4,120(s0)
ffffffffc0206346:	6c30                	ld	a2,88(s0)
ffffffffc0206348:	e82a                	sd	a0,16(sp)
ffffffffc020634a:	ec2e                	sd	a1,24(sp)
ffffffffc020634c:	e432                	sd	a2,8(sp)
ffffffffc020634e:	f036                	sd	a3,32(sp)
ffffffffc0206350:	f43a                	sd	a4,40(sp)
            arg[2] = tf->gpr.a3;  // a3 寄存器保存第三个参数
            arg[3] = tf->gpr.a4;  // a4 寄存器保存第四个参数
            arg[4] = tf->gpr.a5;  // a5 寄存器保存第五个参数
            
            // 调用系统调用函数，并将返回值存储到 a0 寄存器
            tf->gpr.a0 = syscalls[num](arg);  //把寄存器里的参数取出来，转发给系统调用编号对应的函数进行处理
ffffffffc0206352:	0028                	addi	a0,sp,8
ffffffffc0206354:	9782                	jalr	a5
    print_trapframe(tf);
    
    // 崩溃并打印错误信息，说明是一个未定义的系统调用
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc0206356:	60a6                	ld	ra,72(sp)
            tf->gpr.a0 = syscalls[num](arg);  //把寄存器里的参数取出来，转发给系统调用编号对应的函数进行处理
ffffffffc0206358:	e828                	sd	a0,80(s0)
}
ffffffffc020635a:	6406                	ld	s0,64(sp)
ffffffffc020635c:	74e2                	ld	s1,56(sp)
ffffffffc020635e:	7942                	ld	s2,48(sp)
ffffffffc0206360:	6161                	addi	sp,sp,80
ffffffffc0206362:	8082                	ret
    print_trapframe(tf);
ffffffffc0206364:	8522                	mv	a0,s0
ffffffffc0206366:	ccafa0ef          	jal	ffffffffc0200830 <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc020636a:	609c                	ld	a5,0(s1)
ffffffffc020636c:	86ca                	mv	a3,s2
ffffffffc020636e:	00002617          	auipc	a2,0x2
ffffffffc0206372:	69a60613          	addi	a2,a2,1690 # ffffffffc0208a08 <etext+0x21be>
ffffffffc0206376:	43d8                	lw	a4,4(a5)
ffffffffc0206378:	08e00593          	li	a1,142
ffffffffc020637c:	0b478793          	addi	a5,a5,180
ffffffffc0206380:	00002517          	auipc	a0,0x2
ffffffffc0206384:	6b850513          	addi	a0,a0,1720 # ffffffffc0208a38 <etext+0x21ee>
ffffffffc0206388:	8ecfa0ef          	jal	ffffffffc0200474 <__panic>

ffffffffc020638c <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc020638c:	9e3707b7          	lui	a5,0x9e370
ffffffffc0206390:	2785                	addiw	a5,a5,1 # ffffffff9e370001 <_binary_obj___user_exit_out_size+0xffffffff9e366461>
ffffffffc0206392:	02a787bb          	mulw	a5,a5,a0
    return (hash >> (32 - bits));
ffffffffc0206396:	02000513          	li	a0,32
ffffffffc020639a:	9d0d                	subw	a0,a0,a1
}
ffffffffc020639c:	00a7d53b          	srlw	a0,a5,a0
ffffffffc02063a0:	8082                	ret

ffffffffc02063a2 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02063a2:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02063a6:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc02063a8:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02063ac:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02063ae:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02063b2:	f022                	sd	s0,32(sp)
ffffffffc02063b4:	ec26                	sd	s1,24(sp)
ffffffffc02063b6:	e84a                	sd	s2,16(sp)
ffffffffc02063b8:	f406                	sd	ra,40(sp)
ffffffffc02063ba:	84aa                	mv	s1,a0
ffffffffc02063bc:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02063be:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc02063c2:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc02063c4:	05067063          	bgeu	a2,a6,ffffffffc0206404 <printnum+0x62>
ffffffffc02063c8:	e44e                	sd	s3,8(sp)
ffffffffc02063ca:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc02063cc:	4785                	li	a5,1
ffffffffc02063ce:	00e7d763          	bge	a5,a4,ffffffffc02063dc <printnum+0x3a>
            putch(padc, putdat);
ffffffffc02063d2:	85ca                	mv	a1,s2
ffffffffc02063d4:	854e                	mv	a0,s3
        while (-- width > 0)
ffffffffc02063d6:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02063d8:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02063da:	fc65                	bnez	s0,ffffffffc02063d2 <printnum+0x30>
ffffffffc02063dc:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02063de:	1a02                	slli	s4,s4,0x20
ffffffffc02063e0:	020a5a13          	srli	s4,s4,0x20
ffffffffc02063e4:	00002797          	auipc	a5,0x2
ffffffffc02063e8:	66c78793          	addi	a5,a5,1644 # ffffffffc0208a50 <etext+0x2206>
ffffffffc02063ec:	97d2                	add	a5,a5,s4
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc02063ee:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02063f0:	0007c503          	lbu	a0,0(a5)
}
ffffffffc02063f4:	70a2                	ld	ra,40(sp)
ffffffffc02063f6:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02063f8:	85ca                	mv	a1,s2
ffffffffc02063fa:	87a6                	mv	a5,s1
}
ffffffffc02063fc:	6942                	ld	s2,16(sp)
ffffffffc02063fe:	64e2                	ld	s1,24(sp)
ffffffffc0206400:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206402:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0206404:	03065633          	divu	a2,a2,a6
ffffffffc0206408:	8722                	mv	a4,s0
ffffffffc020640a:	f99ff0ef          	jal	ffffffffc02063a2 <printnum>
ffffffffc020640e:	bfc1                	j	ffffffffc02063de <printnum+0x3c>

ffffffffc0206410 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0206410:	7119                	addi	sp,sp,-128
ffffffffc0206412:	f4a6                	sd	s1,104(sp)
ffffffffc0206414:	f0ca                	sd	s2,96(sp)
ffffffffc0206416:	ecce                	sd	s3,88(sp)
ffffffffc0206418:	e8d2                	sd	s4,80(sp)
ffffffffc020641a:	e4d6                	sd	s5,72(sp)
ffffffffc020641c:	e0da                	sd	s6,64(sp)
ffffffffc020641e:	f862                	sd	s8,48(sp)
ffffffffc0206420:	fc86                	sd	ra,120(sp)
ffffffffc0206422:	f8a2                	sd	s0,112(sp)
ffffffffc0206424:	fc5e                	sd	s7,56(sp)
ffffffffc0206426:	f466                	sd	s9,40(sp)
ffffffffc0206428:	f06a                	sd	s10,32(sp)
ffffffffc020642a:	ec6e                	sd	s11,24(sp)
ffffffffc020642c:	892a                	mv	s2,a0
ffffffffc020642e:	84ae                	mv	s1,a1
ffffffffc0206430:	8c32                	mv	s8,a2
ffffffffc0206432:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206434:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206438:	05500b13          	li	s6,85
ffffffffc020643c:	00003a97          	auipc	s5,0x3
ffffffffc0206440:	8f4a8a93          	addi	s5,s5,-1804 # ffffffffc0208d30 <syscalls+0x100>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206444:	000c4503          	lbu	a0,0(s8)
ffffffffc0206448:	001c0413          	addi	s0,s8,1
ffffffffc020644c:	01350a63          	beq	a0,s3,ffffffffc0206460 <vprintfmt+0x50>
            if (ch == '\0') {
ffffffffc0206450:	cd0d                	beqz	a0,ffffffffc020648a <vprintfmt+0x7a>
            putch(ch, putdat);
ffffffffc0206452:	85a6                	mv	a1,s1
ffffffffc0206454:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206456:	00044503          	lbu	a0,0(s0)
ffffffffc020645a:	0405                	addi	s0,s0,1
ffffffffc020645c:	ff351ae3          	bne	a0,s3,ffffffffc0206450 <vprintfmt+0x40>
        char padc = ' ';
ffffffffc0206460:	02000d93          	li	s11,32
        lflag = altflag = 0;
ffffffffc0206464:	4b81                	li	s7,0
ffffffffc0206466:	4601                	li	a2,0
        width = precision = -1;
ffffffffc0206468:	5d7d                	li	s10,-1
ffffffffc020646a:	5cfd                	li	s9,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020646c:	00044683          	lbu	a3,0(s0)
ffffffffc0206470:	00140c13          	addi	s8,s0,1
ffffffffc0206474:	fdd6859b          	addiw	a1,a3,-35
ffffffffc0206478:	0ff5f593          	zext.b	a1,a1
ffffffffc020647c:	02bb6663          	bltu	s6,a1,ffffffffc02064a8 <vprintfmt+0x98>
ffffffffc0206480:	058a                	slli	a1,a1,0x2
ffffffffc0206482:	95d6                	add	a1,a1,s5
ffffffffc0206484:	4198                	lw	a4,0(a1)
ffffffffc0206486:	9756                	add	a4,a4,s5
ffffffffc0206488:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc020648a:	70e6                	ld	ra,120(sp)
ffffffffc020648c:	7446                	ld	s0,112(sp)
ffffffffc020648e:	74a6                	ld	s1,104(sp)
ffffffffc0206490:	7906                	ld	s2,96(sp)
ffffffffc0206492:	69e6                	ld	s3,88(sp)
ffffffffc0206494:	6a46                	ld	s4,80(sp)
ffffffffc0206496:	6aa6                	ld	s5,72(sp)
ffffffffc0206498:	6b06                	ld	s6,64(sp)
ffffffffc020649a:	7be2                	ld	s7,56(sp)
ffffffffc020649c:	7c42                	ld	s8,48(sp)
ffffffffc020649e:	7ca2                	ld	s9,40(sp)
ffffffffc02064a0:	7d02                	ld	s10,32(sp)
ffffffffc02064a2:	6de2                	ld	s11,24(sp)
ffffffffc02064a4:	6109                	addi	sp,sp,128
ffffffffc02064a6:	8082                	ret
            putch('%', putdat);
ffffffffc02064a8:	85a6                	mv	a1,s1
ffffffffc02064aa:	02500513          	li	a0,37
ffffffffc02064ae:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02064b0:	fff44703          	lbu	a4,-1(s0)
ffffffffc02064b4:	02500793          	li	a5,37
ffffffffc02064b8:	8c22                	mv	s8,s0
ffffffffc02064ba:	f8f705e3          	beq	a4,a5,ffffffffc0206444 <vprintfmt+0x34>
ffffffffc02064be:	02500713          	li	a4,37
ffffffffc02064c2:	ffec4783          	lbu	a5,-2(s8)
ffffffffc02064c6:	1c7d                	addi	s8,s8,-1
ffffffffc02064c8:	fee79de3          	bne	a5,a4,ffffffffc02064c2 <vprintfmt+0xb2>
ffffffffc02064cc:	bfa5                	j	ffffffffc0206444 <vprintfmt+0x34>
                ch = *fmt;
ffffffffc02064ce:	00144783          	lbu	a5,1(s0)
                if (ch < '0' || ch > '9') {
ffffffffc02064d2:	4725                	li	a4,9
                precision = precision * 10 + ch - '0';
ffffffffc02064d4:	fd068d1b          	addiw	s10,a3,-48
                if (ch < '0' || ch > '9') {
ffffffffc02064d8:	fd07859b          	addiw	a1,a5,-48
                ch = *fmt;
ffffffffc02064dc:	0007869b          	sext.w	a3,a5
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02064e0:	8462                	mv	s0,s8
                if (ch < '0' || ch > '9') {
ffffffffc02064e2:	02b76563          	bltu	a4,a1,ffffffffc020650c <vprintfmt+0xfc>
ffffffffc02064e6:	4525                	li	a0,9
                ch = *fmt;
ffffffffc02064e8:	00144783          	lbu	a5,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02064ec:	002d171b          	slliw	a4,s10,0x2
ffffffffc02064f0:	01a7073b          	addw	a4,a4,s10
ffffffffc02064f4:	0017171b          	slliw	a4,a4,0x1
ffffffffc02064f8:	9f35                	addw	a4,a4,a3
                if (ch < '0' || ch > '9') {
ffffffffc02064fa:	fd07859b          	addiw	a1,a5,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc02064fe:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0206500:	fd070d1b          	addiw	s10,a4,-48
                ch = *fmt;
ffffffffc0206504:	0007869b          	sext.w	a3,a5
                if (ch < '0' || ch > '9') {
ffffffffc0206508:	feb570e3          	bgeu	a0,a1,ffffffffc02064e8 <vprintfmt+0xd8>
            if (width < 0)
ffffffffc020650c:	f60cd0e3          	bgez	s9,ffffffffc020646c <vprintfmt+0x5c>
                width = precision, precision = -1;
ffffffffc0206510:	8cea                	mv	s9,s10
ffffffffc0206512:	5d7d                	li	s10,-1
ffffffffc0206514:	bfa1                	j	ffffffffc020646c <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206516:	8db6                	mv	s11,a3
ffffffffc0206518:	8462                	mv	s0,s8
ffffffffc020651a:	bf89                	j	ffffffffc020646c <vprintfmt+0x5c>
ffffffffc020651c:	8462                	mv	s0,s8
            altflag = 1;
ffffffffc020651e:	4b85                	li	s7,1
            goto reswitch;
ffffffffc0206520:	b7b1                	j	ffffffffc020646c <vprintfmt+0x5c>
    if (lflag >= 2) {
ffffffffc0206522:	4785                	li	a5,1
            precision = va_arg(ap, int);
ffffffffc0206524:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
ffffffffc0206528:	00c7c463          	blt	a5,a2,ffffffffc0206530 <vprintfmt+0x120>
    else if (lflag) {
ffffffffc020652c:	1a060163          	beqz	a2,ffffffffc02066ce <vprintfmt+0x2be>
        return va_arg(*ap, unsigned long);
ffffffffc0206530:	000a3603          	ld	a2,0(s4)
ffffffffc0206534:	46c1                	li	a3,16
ffffffffc0206536:	8a3a                	mv	s4,a4
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0206538:	000d879b          	sext.w	a5,s11
ffffffffc020653c:	8766                	mv	a4,s9
ffffffffc020653e:	85a6                	mv	a1,s1
ffffffffc0206540:	854a                	mv	a0,s2
ffffffffc0206542:	e61ff0ef          	jal	ffffffffc02063a2 <printnum>
            break;
ffffffffc0206546:	bdfd                	j	ffffffffc0206444 <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
ffffffffc0206548:	000a2503          	lw	a0,0(s4)
ffffffffc020654c:	85a6                	mv	a1,s1
ffffffffc020654e:	0a21                	addi	s4,s4,8
ffffffffc0206550:	9902                	jalr	s2
            break;
ffffffffc0206552:	bdcd                	j	ffffffffc0206444 <vprintfmt+0x34>
    if (lflag >= 2) {
ffffffffc0206554:	4785                	li	a5,1
            precision = va_arg(ap, int);
ffffffffc0206556:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
ffffffffc020655a:	00c7c463          	blt	a5,a2,ffffffffc0206562 <vprintfmt+0x152>
    else if (lflag) {
ffffffffc020655e:	16060363          	beqz	a2,ffffffffc02066c4 <vprintfmt+0x2b4>
        return va_arg(*ap, unsigned long);
ffffffffc0206562:	000a3603          	ld	a2,0(s4)
ffffffffc0206566:	46a9                	li	a3,10
ffffffffc0206568:	8a3a                	mv	s4,a4
ffffffffc020656a:	b7f9                	j	ffffffffc0206538 <vprintfmt+0x128>
            putch('0', putdat);
ffffffffc020656c:	85a6                	mv	a1,s1
ffffffffc020656e:	03000513          	li	a0,48
ffffffffc0206572:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0206574:	85a6                	mv	a1,s1
ffffffffc0206576:	07800513          	li	a0,120
ffffffffc020657a:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020657c:	000a3603          	ld	a2,0(s4)
            goto number;
ffffffffc0206580:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0206582:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0206584:	bf55                	j	ffffffffc0206538 <vprintfmt+0x128>
            putch(ch, putdat);
ffffffffc0206586:	85a6                	mv	a1,s1
ffffffffc0206588:	02500513          	li	a0,37
ffffffffc020658c:	9902                	jalr	s2
            break;
ffffffffc020658e:	bd5d                	j	ffffffffc0206444 <vprintfmt+0x34>
            precision = va_arg(ap, int);
ffffffffc0206590:	000a2d03          	lw	s10,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206594:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
ffffffffc0206596:	0a21                	addi	s4,s4,8
            goto process_precision;
ffffffffc0206598:	bf95                	j	ffffffffc020650c <vprintfmt+0xfc>
    if (lflag >= 2) {
ffffffffc020659a:	4785                	li	a5,1
            precision = va_arg(ap, int);
ffffffffc020659c:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
ffffffffc02065a0:	00c7c463          	blt	a5,a2,ffffffffc02065a8 <vprintfmt+0x198>
    else if (lflag) {
ffffffffc02065a4:	10060b63          	beqz	a2,ffffffffc02066ba <vprintfmt+0x2aa>
        return va_arg(*ap, unsigned long);
ffffffffc02065a8:	000a3603          	ld	a2,0(s4)
ffffffffc02065ac:	46a1                	li	a3,8
ffffffffc02065ae:	8a3a                	mv	s4,a4
ffffffffc02065b0:	b761                	j	ffffffffc0206538 <vprintfmt+0x128>
            if (width < 0)
ffffffffc02065b2:	fffcc793          	not	a5,s9
ffffffffc02065b6:	97fd                	srai	a5,a5,0x3f
ffffffffc02065b8:	00fcf7b3          	and	a5,s9,a5
ffffffffc02065bc:	00078c9b          	sext.w	s9,a5
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02065c0:	8462                	mv	s0,s8
            goto reswitch;
ffffffffc02065c2:	b56d                	j	ffffffffc020646c <vprintfmt+0x5c>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02065c4:	000a3403          	ld	s0,0(s4)
ffffffffc02065c8:	008a0793          	addi	a5,s4,8
ffffffffc02065cc:	e43e                	sd	a5,8(sp)
ffffffffc02065ce:	12040063          	beqz	s0,ffffffffc02066ee <vprintfmt+0x2de>
            if (width > 0 && padc != '-') {
ffffffffc02065d2:	0d905963          	blez	s9,ffffffffc02066a4 <vprintfmt+0x294>
ffffffffc02065d6:	02d00793          	li	a5,45
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02065da:	00140a13          	addi	s4,s0,1
            if (width > 0 && padc != '-') {
ffffffffc02065de:	12fd9763          	bne	s11,a5,ffffffffc020670c <vprintfmt+0x2fc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02065e2:	00044783          	lbu	a5,0(s0)
ffffffffc02065e6:	0007851b          	sext.w	a0,a5
ffffffffc02065ea:	cb9d                	beqz	a5,ffffffffc0206620 <vprintfmt+0x210>
ffffffffc02065ec:	547d                	li	s0,-1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02065ee:	05e00d93          	li	s11,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02065f2:	000d4563          	bltz	s10,ffffffffc02065fc <vprintfmt+0x1ec>
ffffffffc02065f6:	3d7d                	addiw	s10,s10,-1
ffffffffc02065f8:	028d0263          	beq	s10,s0,ffffffffc020661c <vprintfmt+0x20c>
                    putch('?', putdat);
ffffffffc02065fc:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02065fe:	0c0b8d63          	beqz	s7,ffffffffc02066d8 <vprintfmt+0x2c8>
ffffffffc0206602:	3781                	addiw	a5,a5,-32
ffffffffc0206604:	0cfdfa63          	bgeu	s11,a5,ffffffffc02066d8 <vprintfmt+0x2c8>
                    putch('?', putdat);
ffffffffc0206608:	03f00513          	li	a0,63
ffffffffc020660c:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020660e:	000a4783          	lbu	a5,0(s4)
ffffffffc0206612:	3cfd                	addiw	s9,s9,-1
ffffffffc0206614:	0a05                	addi	s4,s4,1
ffffffffc0206616:	0007851b          	sext.w	a0,a5
ffffffffc020661a:	ffe1                	bnez	a5,ffffffffc02065f2 <vprintfmt+0x1e2>
            for (; width > 0; width --) {
ffffffffc020661c:	01905963          	blez	s9,ffffffffc020662e <vprintfmt+0x21e>
                putch(' ', putdat);
ffffffffc0206620:	85a6                	mv	a1,s1
ffffffffc0206622:	02000513          	li	a0,32
            for (; width > 0; width --) {
ffffffffc0206626:	3cfd                	addiw	s9,s9,-1
                putch(' ', putdat);
ffffffffc0206628:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020662a:	fe0c9be3          	bnez	s9,ffffffffc0206620 <vprintfmt+0x210>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020662e:	6a22                	ld	s4,8(sp)
ffffffffc0206630:	bd11                	j	ffffffffc0206444 <vprintfmt+0x34>
    if (lflag >= 2) {
ffffffffc0206632:	4785                	li	a5,1
            precision = va_arg(ap, int);
ffffffffc0206634:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
ffffffffc0206638:	00c7c363          	blt	a5,a2,ffffffffc020663e <vprintfmt+0x22e>
    else if (lflag) {
ffffffffc020663c:	ce25                	beqz	a2,ffffffffc02066b4 <vprintfmt+0x2a4>
        return va_arg(*ap, long);
ffffffffc020663e:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0206642:	08044d63          	bltz	s0,ffffffffc02066dc <vprintfmt+0x2cc>
            num = getint(&ap, lflag);
ffffffffc0206646:	8622                	mv	a2,s0
ffffffffc0206648:	8a5e                	mv	s4,s7
ffffffffc020664a:	46a9                	li	a3,10
ffffffffc020664c:	b5f5                	j	ffffffffc0206538 <vprintfmt+0x128>
            if (err < 0) {
ffffffffc020664e:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0206652:	4661                	li	a2,24
            if (err < 0) {
ffffffffc0206654:	41f7d71b          	sraiw	a4,a5,0x1f
ffffffffc0206658:	8fb9                	xor	a5,a5,a4
ffffffffc020665a:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020665e:	02d64663          	blt	a2,a3,ffffffffc020668a <vprintfmt+0x27a>
ffffffffc0206662:	00369713          	slli	a4,a3,0x3
ffffffffc0206666:	00003797          	auipc	a5,0x3
ffffffffc020666a:	82278793          	addi	a5,a5,-2014 # ffffffffc0208e88 <error_string>
ffffffffc020666e:	97ba                	add	a5,a5,a4
ffffffffc0206670:	639c                	ld	a5,0(a5)
ffffffffc0206672:	cf81                	beqz	a5,ffffffffc020668a <vprintfmt+0x27a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0206674:	86be                	mv	a3,a5
ffffffffc0206676:	00000617          	auipc	a2,0x0
ffffffffc020667a:	20260613          	addi	a2,a2,514 # ffffffffc0206878 <etext+0x2e>
ffffffffc020667e:	85a6                	mv	a1,s1
ffffffffc0206680:	854a                	mv	a0,s2
ffffffffc0206682:	0e8000ef          	jal	ffffffffc020676a <printfmt>
            err = va_arg(ap, int);
ffffffffc0206686:	0a21                	addi	s4,s4,8
ffffffffc0206688:	bb75                	j	ffffffffc0206444 <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
ffffffffc020668a:	00002617          	auipc	a2,0x2
ffffffffc020668e:	3e660613          	addi	a2,a2,998 # ffffffffc0208a70 <etext+0x2226>
ffffffffc0206692:	85a6                	mv	a1,s1
ffffffffc0206694:	854a                	mv	a0,s2
ffffffffc0206696:	0d4000ef          	jal	ffffffffc020676a <printfmt>
            err = va_arg(ap, int);
ffffffffc020669a:	0a21                	addi	s4,s4,8
ffffffffc020669c:	b365                	j	ffffffffc0206444 <vprintfmt+0x34>
            lflag ++;
ffffffffc020669e:	2605                	addiw	a2,a2,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02066a0:	8462                	mv	s0,s8
            goto reswitch;
ffffffffc02066a2:	b3e9                	j	ffffffffc020646c <vprintfmt+0x5c>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02066a4:	00044783          	lbu	a5,0(s0)
ffffffffc02066a8:	0007851b          	sext.w	a0,a5
ffffffffc02066ac:	d3c9                	beqz	a5,ffffffffc020662e <vprintfmt+0x21e>
ffffffffc02066ae:	00140a13          	addi	s4,s0,1
ffffffffc02066b2:	bf2d                	j	ffffffffc02065ec <vprintfmt+0x1dc>
        return va_arg(*ap, int);
ffffffffc02066b4:	000a2403          	lw	s0,0(s4)
ffffffffc02066b8:	b769                	j	ffffffffc0206642 <vprintfmt+0x232>
        return va_arg(*ap, unsigned int);
ffffffffc02066ba:	000a6603          	lwu	a2,0(s4)
ffffffffc02066be:	46a1                	li	a3,8
ffffffffc02066c0:	8a3a                	mv	s4,a4
ffffffffc02066c2:	bd9d                	j	ffffffffc0206538 <vprintfmt+0x128>
ffffffffc02066c4:	000a6603          	lwu	a2,0(s4)
ffffffffc02066c8:	46a9                	li	a3,10
ffffffffc02066ca:	8a3a                	mv	s4,a4
ffffffffc02066cc:	b5b5                	j	ffffffffc0206538 <vprintfmt+0x128>
ffffffffc02066ce:	000a6603          	lwu	a2,0(s4)
ffffffffc02066d2:	46c1                	li	a3,16
ffffffffc02066d4:	8a3a                	mv	s4,a4
ffffffffc02066d6:	b58d                	j	ffffffffc0206538 <vprintfmt+0x128>
                    putch(ch, putdat);
ffffffffc02066d8:	9902                	jalr	s2
ffffffffc02066da:	bf15                	j	ffffffffc020660e <vprintfmt+0x1fe>
                putch('-', putdat);
ffffffffc02066dc:	85a6                	mv	a1,s1
ffffffffc02066de:	02d00513          	li	a0,45
ffffffffc02066e2:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02066e4:	40800633          	neg	a2,s0
ffffffffc02066e8:	8a5e                	mv	s4,s7
ffffffffc02066ea:	46a9                	li	a3,10
ffffffffc02066ec:	b5b1                	j	ffffffffc0206538 <vprintfmt+0x128>
            if (width > 0 && padc != '-') {
ffffffffc02066ee:	01905663          	blez	s9,ffffffffc02066fa <vprintfmt+0x2ea>
ffffffffc02066f2:	02d00793          	li	a5,45
ffffffffc02066f6:	04fd9263          	bne	s11,a5,ffffffffc020673a <vprintfmt+0x32a>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02066fa:	02800793          	li	a5,40
ffffffffc02066fe:	00002a17          	auipc	s4,0x2
ffffffffc0206702:	36ba0a13          	addi	s4,s4,875 # ffffffffc0208a69 <etext+0x221f>
ffffffffc0206706:	02800513          	li	a0,40
ffffffffc020670a:	b5cd                	j	ffffffffc02065ec <vprintfmt+0x1dc>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020670c:	85ea                	mv	a1,s10
ffffffffc020670e:	8522                	mv	a0,s0
ffffffffc0206710:	094000ef          	jal	ffffffffc02067a4 <strnlen>
ffffffffc0206714:	40ac8cbb          	subw	s9,s9,a0
ffffffffc0206718:	01905963          	blez	s9,ffffffffc020672a <vprintfmt+0x31a>
                    putch(padc, putdat);
ffffffffc020671c:	2d81                	sext.w	s11,s11
ffffffffc020671e:	85a6                	mv	a1,s1
ffffffffc0206720:	856e                	mv	a0,s11
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0206722:	3cfd                	addiw	s9,s9,-1
                    putch(padc, putdat);
ffffffffc0206724:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0206726:	fe0c9ce3          	bnez	s9,ffffffffc020671e <vprintfmt+0x30e>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020672a:	00044783          	lbu	a5,0(s0)
ffffffffc020672e:	0007851b          	sext.w	a0,a5
ffffffffc0206732:	ea079de3          	bnez	a5,ffffffffc02065ec <vprintfmt+0x1dc>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0206736:	6a22                	ld	s4,8(sp)
ffffffffc0206738:	b331                	j	ffffffffc0206444 <vprintfmt+0x34>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020673a:	85ea                	mv	a1,s10
ffffffffc020673c:	00002517          	auipc	a0,0x2
ffffffffc0206740:	32c50513          	addi	a0,a0,812 # ffffffffc0208a68 <etext+0x221e>
ffffffffc0206744:	060000ef          	jal	ffffffffc02067a4 <strnlen>
ffffffffc0206748:	40ac8cbb          	subw	s9,s9,a0
                p = "(null)";
ffffffffc020674c:	00002417          	auipc	s0,0x2
ffffffffc0206750:	31c40413          	addi	s0,s0,796 # ffffffffc0208a68 <etext+0x221e>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206754:	00002a17          	auipc	s4,0x2
ffffffffc0206758:	315a0a13          	addi	s4,s4,789 # ffffffffc0208a69 <etext+0x221f>
ffffffffc020675c:	02800793          	li	a5,40
ffffffffc0206760:	02800513          	li	a0,40
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0206764:	fb904ce3          	bgtz	s9,ffffffffc020671c <vprintfmt+0x30c>
ffffffffc0206768:	b551                	j	ffffffffc02065ec <vprintfmt+0x1dc>

ffffffffc020676a <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020676a:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc020676c:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0206770:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0206772:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0206774:	ec06                	sd	ra,24(sp)
ffffffffc0206776:	f83a                	sd	a4,48(sp)
ffffffffc0206778:	fc3e                	sd	a5,56(sp)
ffffffffc020677a:	e0c2                	sd	a6,64(sp)
ffffffffc020677c:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc020677e:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0206780:	c91ff0ef          	jal	ffffffffc0206410 <vprintfmt>
}
ffffffffc0206784:	60e2                	ld	ra,24(sp)
ffffffffc0206786:	6161                	addi	sp,sp,80
ffffffffc0206788:	8082                	ret

ffffffffc020678a <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc020678a:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc020678e:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc0206790:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc0206792:	cb81                	beqz	a5,ffffffffc02067a2 <strlen+0x18>
        cnt ++;
ffffffffc0206794:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc0206796:	00a707b3          	add	a5,a4,a0
ffffffffc020679a:	0007c783          	lbu	a5,0(a5)
ffffffffc020679e:	fbfd                	bnez	a5,ffffffffc0206794 <strlen+0xa>
ffffffffc02067a0:	8082                	ret
    }
    return cnt;
}
ffffffffc02067a2:	8082                	ret

ffffffffc02067a4 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc02067a4:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc02067a6:	e589                	bnez	a1,ffffffffc02067b0 <strnlen+0xc>
ffffffffc02067a8:	a811                	j	ffffffffc02067bc <strnlen+0x18>
        cnt ++;
ffffffffc02067aa:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02067ac:	00f58863          	beq	a1,a5,ffffffffc02067bc <strnlen+0x18>
ffffffffc02067b0:	00f50733          	add	a4,a0,a5
ffffffffc02067b4:	00074703          	lbu	a4,0(a4)
ffffffffc02067b8:	fb6d                	bnez	a4,ffffffffc02067aa <strnlen+0x6>
ffffffffc02067ba:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc02067bc:	852e                	mv	a0,a1
ffffffffc02067be:	8082                	ret

ffffffffc02067c0 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc02067c0:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc02067c2:	0005c703          	lbu	a4,0(a1)
ffffffffc02067c6:	0785                	addi	a5,a5,1
ffffffffc02067c8:	0585                	addi	a1,a1,1
ffffffffc02067ca:	fee78fa3          	sb	a4,-1(a5)
ffffffffc02067ce:	fb75                	bnez	a4,ffffffffc02067c2 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc02067d0:	8082                	ret

ffffffffc02067d2 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02067d2:	00054783          	lbu	a5,0(a0)
ffffffffc02067d6:	e791                	bnez	a5,ffffffffc02067e2 <strcmp+0x10>
ffffffffc02067d8:	a02d                	j	ffffffffc0206802 <strcmp+0x30>
ffffffffc02067da:	00054783          	lbu	a5,0(a0)
ffffffffc02067de:	cf89                	beqz	a5,ffffffffc02067f8 <strcmp+0x26>
ffffffffc02067e0:	85b6                	mv	a1,a3
ffffffffc02067e2:	0005c703          	lbu	a4,0(a1)
        s1 ++, s2 ++;
ffffffffc02067e6:	0505                	addi	a0,a0,1
ffffffffc02067e8:	00158693          	addi	a3,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02067ec:	fef707e3          	beq	a4,a5,ffffffffc02067da <strcmp+0x8>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02067f0:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02067f4:	9d19                	subw	a0,a0,a4
ffffffffc02067f6:	8082                	ret
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02067f8:	0015c703          	lbu	a4,1(a1)
ffffffffc02067fc:	4501                	li	a0,0
}
ffffffffc02067fe:	9d19                	subw	a0,a0,a4
ffffffffc0206800:	8082                	ret
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0206802:	0005c703          	lbu	a4,0(a1)
ffffffffc0206806:	4501                	li	a0,0
ffffffffc0206808:	b7f5                	j	ffffffffc02067f4 <strcmp+0x22>

ffffffffc020680a <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc020680a:	00054783          	lbu	a5,0(a0)
ffffffffc020680e:	c799                	beqz	a5,ffffffffc020681c <strchr+0x12>
        if (*s == c) {
ffffffffc0206810:	00f58763          	beq	a1,a5,ffffffffc020681e <strchr+0x14>
    while (*s != '\0') {
ffffffffc0206814:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0206818:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc020681a:	fbfd                	bnez	a5,ffffffffc0206810 <strchr+0x6>
    }
    return NULL;
ffffffffc020681c:	4501                	li	a0,0
}
ffffffffc020681e:	8082                	ret

ffffffffc0206820 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0206820:	ca01                	beqz	a2,ffffffffc0206830 <memset+0x10>
ffffffffc0206822:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0206824:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0206826:	0785                	addi	a5,a5,1
ffffffffc0206828:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc020682c:	fef61de3          	bne	a2,a5,ffffffffc0206826 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0206830:	8082                	ret

ffffffffc0206832 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0206832:	ca19                	beqz	a2,ffffffffc0206848 <memcpy+0x16>
ffffffffc0206834:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0206836:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0206838:	0005c703          	lbu	a4,0(a1)
ffffffffc020683c:	0585                	addi	a1,a1,1
ffffffffc020683e:	0785                	addi	a5,a5,1
ffffffffc0206840:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0206844:	feb61ae3          	bne	a2,a1,ffffffffc0206838 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0206848:	8082                	ret

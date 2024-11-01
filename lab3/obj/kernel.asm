
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02092b7          	lui	t0,0xc0209
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
ffffffffc0200024:	c0209137          	lui	sp,0xc0209

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200028:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc020002c:	03228293          	addi	t0,t0,50 # ffffffffc0200032 <kern_init>
    jr t0
ffffffffc0200030:	8282                	jr	t0

ffffffffc0200032 <kern_init>:


int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	0000a517          	auipc	a0,0xa
ffffffffc0200036:	00e50513          	addi	a0,a0,14 # ffffffffc020a040 <ide>
ffffffffc020003a:	00011617          	auipc	a2,0x11
ffffffffc020003e:	53e60613          	addi	a2,a2,1342 # ffffffffc0211578 <end>
kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16 # ffffffffc0208ff0 <bootstack+0x1ff0>
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	4ce040ef          	jal	ffffffffc0204518 <memset>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc020004e:	00004597          	auipc	a1,0x4
ffffffffc0200052:	4fa58593          	addi	a1,a1,1274 # ffffffffc0204548 <etext+0x6>
ffffffffc0200056:	00004517          	auipc	a0,0x4
ffffffffc020005a:	51250513          	addi	a0,a0,1298 # ffffffffc0204568 <etext+0x26>
ffffffffc020005e:	05c000ef          	jal	ffffffffc02000ba <cprintf>

    print_kerninfo();
ffffffffc0200062:	09e000ef          	jal	ffffffffc0200100 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc0200066:	2bb010ef          	jal	ffffffffc0201b20 <pmm_init>

    idt_init();                 // init interrupt descriptor table
ffffffffc020006a:	4e8000ef          	jal	ffffffffc0200552 <idt_init>

    vmm_init();                 // init virtual memory management新增函数, 初始化虚拟内存管理并测试
ffffffffc020006e:	72e030ef          	jal	ffffffffc020379c <vmm_init>

    ide_init();                 // init ide devices新增函数, 初始化"硬盘"
ffffffffc0200072:	40e000ef          	jal	ffffffffc0200480 <ide_init>
    swap_init();                // init swap新增函数, 初始化页面置换机制并测试
ffffffffc0200076:	147020ef          	jal	ffffffffc02029bc <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020007a:	344000ef          	jal	ffffffffc02003be <clock_init>
    // intr_enable();              // enable irq interrupt



    /* do nothing */
    while (1);
ffffffffc020007e:	a001                	j	ffffffffc020007e <kern_init+0x4c>

ffffffffc0200080 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200080:	1141                	addi	sp,sp,-16
ffffffffc0200082:	e022                	sd	s0,0(sp)
ffffffffc0200084:	e406                	sd	ra,8(sp)
ffffffffc0200086:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200088:	388000ef          	jal	ffffffffc0200410 <cons_putc>
    (*cnt) ++;
ffffffffc020008c:	401c                	lw	a5,0(s0)
}
ffffffffc020008e:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200090:	2785                	addiw	a5,a5,1
ffffffffc0200092:	c01c                	sw	a5,0(s0)
}
ffffffffc0200094:	6402                	ld	s0,0(sp)
ffffffffc0200096:	0141                	addi	sp,sp,16
ffffffffc0200098:	8082                	ret

ffffffffc020009a <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc020009a:	1101                	addi	sp,sp,-32
ffffffffc020009c:	862a                	mv	a2,a0
ffffffffc020009e:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000a0:	00000517          	auipc	a0,0x0
ffffffffc02000a4:	fe050513          	addi	a0,a0,-32 # ffffffffc0200080 <cputch>
ffffffffc02000a8:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000aa:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000ac:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000ae:	7a7030ef          	jal	ffffffffc0204054 <vprintfmt>
    return cnt;
}
ffffffffc02000b2:	60e2                	ld	ra,24(sp)
ffffffffc02000b4:	4532                	lw	a0,12(sp)
ffffffffc02000b6:	6105                	addi	sp,sp,32
ffffffffc02000b8:	8082                	ret

ffffffffc02000ba <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000ba:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000bc:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
ffffffffc02000c0:	f42e                	sd	a1,40(sp)
ffffffffc02000c2:	f832                	sd	a2,48(sp)
ffffffffc02000c4:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c6:	862a                	mv	a2,a0
ffffffffc02000c8:	004c                	addi	a1,sp,4
ffffffffc02000ca:	00000517          	auipc	a0,0x0
ffffffffc02000ce:	fb650513          	addi	a0,a0,-74 # ffffffffc0200080 <cputch>
ffffffffc02000d2:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02000d4:	ec06                	sd	ra,24(sp)
ffffffffc02000d6:	e0ba                	sd	a4,64(sp)
ffffffffc02000d8:	e4be                	sd	a5,72(sp)
ffffffffc02000da:	e8c2                	sd	a6,80(sp)
ffffffffc02000dc:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000de:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000e0:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000e2:	773030ef          	jal	ffffffffc0204054 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e6:	60e2                	ld	ra,24(sp)
ffffffffc02000e8:	4512                	lw	a0,4(sp)
ffffffffc02000ea:	6125                	addi	sp,sp,96
ffffffffc02000ec:	8082                	ret

ffffffffc02000ee <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000ee:	a60d                	j	ffffffffc0200410 <cons_putc>

ffffffffc02000f0 <getchar>:
    return cnt;
}

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc02000f0:	1141                	addi	sp,sp,-16
ffffffffc02000f2:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc02000f4:	350000ef          	jal	ffffffffc0200444 <cons_getc>
ffffffffc02000f8:	dd75                	beqz	a0,ffffffffc02000f4 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc02000fa:	60a2                	ld	ra,8(sp)
ffffffffc02000fc:	0141                	addi	sp,sp,16
ffffffffc02000fe:	8082                	ret

ffffffffc0200100 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200100:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200102:	00004517          	auipc	a0,0x4
ffffffffc0200106:	46e50513          	addi	a0,a0,1134 # ffffffffc0204570 <etext+0x2e>
void print_kerninfo(void) {
ffffffffc020010a:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020010c:	fafff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200110:	00000597          	auipc	a1,0x0
ffffffffc0200114:	f2258593          	addi	a1,a1,-222 # ffffffffc0200032 <kern_init>
ffffffffc0200118:	00004517          	auipc	a0,0x4
ffffffffc020011c:	47850513          	addi	a0,a0,1144 # ffffffffc0204590 <etext+0x4e>
ffffffffc0200120:	f9bff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc0200124:	00004597          	auipc	a1,0x4
ffffffffc0200128:	41e58593          	addi	a1,a1,1054 # ffffffffc0204542 <etext>
ffffffffc020012c:	00004517          	auipc	a0,0x4
ffffffffc0200130:	48450513          	addi	a0,a0,1156 # ffffffffc02045b0 <etext+0x6e>
ffffffffc0200134:	f87ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc0200138:	0000a597          	auipc	a1,0xa
ffffffffc020013c:	f0858593          	addi	a1,a1,-248 # ffffffffc020a040 <ide>
ffffffffc0200140:	00004517          	auipc	a0,0x4
ffffffffc0200144:	49050513          	addi	a0,a0,1168 # ffffffffc02045d0 <etext+0x8e>
ffffffffc0200148:	f73ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc020014c:	00011597          	auipc	a1,0x11
ffffffffc0200150:	42c58593          	addi	a1,a1,1068 # ffffffffc0211578 <end>
ffffffffc0200154:	00004517          	auipc	a0,0x4
ffffffffc0200158:	49c50513          	addi	a0,a0,1180 # ffffffffc02045f0 <etext+0xae>
ffffffffc020015c:	f5fff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200160:	00012797          	auipc	a5,0x12
ffffffffc0200164:	81778793          	addi	a5,a5,-2025 # ffffffffc0211977 <end+0x3ff>
ffffffffc0200168:	00000717          	auipc	a4,0x0
ffffffffc020016c:	eca70713          	addi	a4,a4,-310 # ffffffffc0200032 <kern_init>
ffffffffc0200170:	8f99                	sub	a5,a5,a4
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200172:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc0200176:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200178:	3ff5f593          	andi	a1,a1,1023
ffffffffc020017c:	95be                	add	a1,a1,a5
ffffffffc020017e:	85a9                	srai	a1,a1,0xa
ffffffffc0200180:	00004517          	auipc	a0,0x4
ffffffffc0200184:	49050513          	addi	a0,a0,1168 # ffffffffc0204610 <etext+0xce>
}
ffffffffc0200188:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020018a:	bf05                	j	ffffffffc02000ba <cprintf>

ffffffffc020018c <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc020018c:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc020018e:	00004617          	auipc	a2,0x4
ffffffffc0200192:	4b260613          	addi	a2,a2,1202 # ffffffffc0204640 <etext+0xfe>
ffffffffc0200196:	04e00593          	li	a1,78
ffffffffc020019a:	00004517          	auipc	a0,0x4
ffffffffc020019e:	4be50513          	addi	a0,a0,1214 # ffffffffc0204658 <etext+0x116>
void print_stackframe(void) {
ffffffffc02001a2:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001a4:	1bc000ef          	jal	ffffffffc0200360 <__panic>

ffffffffc02001a8 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001a8:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001aa:	00004617          	auipc	a2,0x4
ffffffffc02001ae:	4c660613          	addi	a2,a2,1222 # ffffffffc0204670 <etext+0x12e>
ffffffffc02001b2:	00004597          	auipc	a1,0x4
ffffffffc02001b6:	4de58593          	addi	a1,a1,1246 # ffffffffc0204690 <etext+0x14e>
ffffffffc02001ba:	00004517          	auipc	a0,0x4
ffffffffc02001be:	4de50513          	addi	a0,a0,1246 # ffffffffc0204698 <etext+0x156>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001c2:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001c4:	ef7ff0ef          	jal	ffffffffc02000ba <cprintf>
ffffffffc02001c8:	00004617          	auipc	a2,0x4
ffffffffc02001cc:	4e060613          	addi	a2,a2,1248 # ffffffffc02046a8 <etext+0x166>
ffffffffc02001d0:	00004597          	auipc	a1,0x4
ffffffffc02001d4:	50058593          	addi	a1,a1,1280 # ffffffffc02046d0 <etext+0x18e>
ffffffffc02001d8:	00004517          	auipc	a0,0x4
ffffffffc02001dc:	4c050513          	addi	a0,a0,1216 # ffffffffc0204698 <etext+0x156>
ffffffffc02001e0:	edbff0ef          	jal	ffffffffc02000ba <cprintf>
ffffffffc02001e4:	00004617          	auipc	a2,0x4
ffffffffc02001e8:	4fc60613          	addi	a2,a2,1276 # ffffffffc02046e0 <etext+0x19e>
ffffffffc02001ec:	00004597          	auipc	a1,0x4
ffffffffc02001f0:	51458593          	addi	a1,a1,1300 # ffffffffc0204700 <etext+0x1be>
ffffffffc02001f4:	00004517          	auipc	a0,0x4
ffffffffc02001f8:	4a450513          	addi	a0,a0,1188 # ffffffffc0204698 <etext+0x156>
ffffffffc02001fc:	ebfff0ef          	jal	ffffffffc02000ba <cprintf>
    }
    return 0;
}
ffffffffc0200200:	60a2                	ld	ra,8(sp)
ffffffffc0200202:	4501                	li	a0,0
ffffffffc0200204:	0141                	addi	sp,sp,16
ffffffffc0200206:	8082                	ret

ffffffffc0200208 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200208:	1141                	addi	sp,sp,-16
ffffffffc020020a:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc020020c:	ef5ff0ef          	jal	ffffffffc0200100 <print_kerninfo>
    return 0;
}
ffffffffc0200210:	60a2                	ld	ra,8(sp)
ffffffffc0200212:	4501                	li	a0,0
ffffffffc0200214:	0141                	addi	sp,sp,16
ffffffffc0200216:	8082                	ret

ffffffffc0200218 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200218:	1141                	addi	sp,sp,-16
ffffffffc020021a:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc020021c:	f71ff0ef          	jal	ffffffffc020018c <print_stackframe>
    return 0;
}
ffffffffc0200220:	60a2                	ld	ra,8(sp)
ffffffffc0200222:	4501                	li	a0,0
ffffffffc0200224:	0141                	addi	sp,sp,16
ffffffffc0200226:	8082                	ret

ffffffffc0200228 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200228:	7115                	addi	sp,sp,-224
ffffffffc020022a:	f15a                	sd	s6,160(sp)
ffffffffc020022c:	8b2a                	mv	s6,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020022e:	00004517          	auipc	a0,0x4
ffffffffc0200232:	4e250513          	addi	a0,a0,1250 # ffffffffc0204710 <etext+0x1ce>
kmonitor(struct trapframe *tf) {
ffffffffc0200236:	ed86                	sd	ra,216(sp)
ffffffffc0200238:	e9a2                	sd	s0,208(sp)
ffffffffc020023a:	e5a6                	sd	s1,200(sp)
ffffffffc020023c:	e1ca                	sd	s2,192(sp)
ffffffffc020023e:	fd4e                	sd	s3,184(sp)
ffffffffc0200240:	f952                	sd	s4,176(sp)
ffffffffc0200242:	f556                	sd	s5,168(sp)
ffffffffc0200244:	ed5e                	sd	s7,152(sp)
ffffffffc0200246:	e962                	sd	s8,144(sp)
ffffffffc0200248:	e566                	sd	s9,136(sp)
ffffffffc020024a:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020024c:	e6fff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200250:	00004517          	auipc	a0,0x4
ffffffffc0200254:	4e850513          	addi	a0,a0,1256 # ffffffffc0204738 <etext+0x1f6>
ffffffffc0200258:	e63ff0ef          	jal	ffffffffc02000ba <cprintf>
    if (tf != NULL) {
ffffffffc020025c:	000b0563          	beqz	s6,ffffffffc0200266 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200260:	855a                	mv	a0,s6
ffffffffc0200262:	4da000ef          	jal	ffffffffc020073c <print_trapframe>
ffffffffc0200266:	00006c17          	auipc	s8,0x6
ffffffffc020026a:	e82c0c13          	addi	s8,s8,-382 # ffffffffc02060e8 <commands>
        if ((buf = readline("")) != NULL) {
ffffffffc020026e:	00006917          	auipc	s2,0x6
ffffffffc0200272:	85290913          	addi	s2,s2,-1966 # ffffffffc0205ac0 <etext+0x157e>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200276:	00004497          	auipc	s1,0x4
ffffffffc020027a:	4ea48493          	addi	s1,s1,1258 # ffffffffc0204760 <etext+0x21e>
        if (argc == MAXARGS - 1) {
ffffffffc020027e:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200280:	00004a97          	auipc	s5,0x4
ffffffffc0200284:	4e8a8a93          	addi	s5,s5,1256 # ffffffffc0204768 <etext+0x226>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200288:	4a0d                	li	s4,3
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020028a:	00004b97          	auipc	s7,0x4
ffffffffc020028e:	4feb8b93          	addi	s7,s7,1278 # ffffffffc0204788 <etext+0x246>
        if ((buf = readline("")) != NULL) {
ffffffffc0200292:	854a                	mv	a0,s2
ffffffffc0200294:	13a040ef          	jal	ffffffffc02043ce <readline>
ffffffffc0200298:	842a                	mv	s0,a0
ffffffffc020029a:	dd65                	beqz	a0,ffffffffc0200292 <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020029c:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002a0:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002a2:	e59d                	bnez	a1,ffffffffc02002d0 <kmonitor+0xa8>
    if (argc == 0) {
ffffffffc02002a4:	fe0c87e3          	beqz	s9,ffffffffc0200292 <kmonitor+0x6a>
ffffffffc02002a8:	00006d17          	auipc	s10,0x6
ffffffffc02002ac:	e40d0d13          	addi	s10,s10,-448 # ffffffffc02060e8 <commands>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002b0:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002b2:	6582                	ld	a1,0(sp)
ffffffffc02002b4:	000d3503          	ld	a0,0(s10)
ffffffffc02002b8:	212040ef          	jal	ffffffffc02044ca <strcmp>
ffffffffc02002bc:	c53d                	beqz	a0,ffffffffc020032a <kmonitor+0x102>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002be:	2405                	addiw	s0,s0,1
ffffffffc02002c0:	0d61                	addi	s10,s10,24
ffffffffc02002c2:	ff4418e3          	bne	s0,s4,ffffffffc02002b2 <kmonitor+0x8a>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc02002c6:	6582                	ld	a1,0(sp)
ffffffffc02002c8:	855e                	mv	a0,s7
ffffffffc02002ca:	df1ff0ef          	jal	ffffffffc02000ba <cprintf>
    return 0;
ffffffffc02002ce:	b7d1                	j	ffffffffc0200292 <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002d0:	8526                	mv	a0,s1
ffffffffc02002d2:	230040ef          	jal	ffffffffc0204502 <strchr>
ffffffffc02002d6:	c901                	beqz	a0,ffffffffc02002e6 <kmonitor+0xbe>
ffffffffc02002d8:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc02002dc:	00040023          	sb	zero,0(s0)
ffffffffc02002e0:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002e2:	d1e9                	beqz	a1,ffffffffc02002a4 <kmonitor+0x7c>
ffffffffc02002e4:	b7f5                	j	ffffffffc02002d0 <kmonitor+0xa8>
        if (*buf == '\0') {
ffffffffc02002e6:	00044783          	lbu	a5,0(s0)
ffffffffc02002ea:	dfcd                	beqz	a5,ffffffffc02002a4 <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc02002ec:	033c8a63          	beq	s9,s3,ffffffffc0200320 <kmonitor+0xf8>
        argv[argc ++] = buf;
ffffffffc02002f0:	003c9793          	slli	a5,s9,0x3
ffffffffc02002f4:	08078793          	addi	a5,a5,128
ffffffffc02002f8:	978a                	add	a5,a5,sp
ffffffffc02002fa:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02002fe:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200302:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200304:	e591                	bnez	a1,ffffffffc0200310 <kmonitor+0xe8>
ffffffffc0200306:	bf79                	j	ffffffffc02002a4 <kmonitor+0x7c>
ffffffffc0200308:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc020030c:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020030e:	d9d9                	beqz	a1,ffffffffc02002a4 <kmonitor+0x7c>
ffffffffc0200310:	8526                	mv	a0,s1
ffffffffc0200312:	1f0040ef          	jal	ffffffffc0204502 <strchr>
ffffffffc0200316:	d96d                	beqz	a0,ffffffffc0200308 <kmonitor+0xe0>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200318:	00044583          	lbu	a1,0(s0)
ffffffffc020031c:	d5c1                	beqz	a1,ffffffffc02002a4 <kmonitor+0x7c>
ffffffffc020031e:	bf4d                	j	ffffffffc02002d0 <kmonitor+0xa8>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200320:	45c1                	li	a1,16
ffffffffc0200322:	8556                	mv	a0,s5
ffffffffc0200324:	d97ff0ef          	jal	ffffffffc02000ba <cprintf>
ffffffffc0200328:	b7e1                	j	ffffffffc02002f0 <kmonitor+0xc8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc020032a:	00141793          	slli	a5,s0,0x1
ffffffffc020032e:	97a2                	add	a5,a5,s0
ffffffffc0200330:	078e                	slli	a5,a5,0x3
ffffffffc0200332:	97e2                	add	a5,a5,s8
ffffffffc0200334:	6b9c                	ld	a5,16(a5)
ffffffffc0200336:	865a                	mv	a2,s6
ffffffffc0200338:	002c                	addi	a1,sp,8
ffffffffc020033a:	fffc851b          	addiw	a0,s9,-1
ffffffffc020033e:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200340:	f40559e3          	bgez	a0,ffffffffc0200292 <kmonitor+0x6a>
}
ffffffffc0200344:	60ee                	ld	ra,216(sp)
ffffffffc0200346:	644e                	ld	s0,208(sp)
ffffffffc0200348:	64ae                	ld	s1,200(sp)
ffffffffc020034a:	690e                	ld	s2,192(sp)
ffffffffc020034c:	79ea                	ld	s3,184(sp)
ffffffffc020034e:	7a4a                	ld	s4,176(sp)
ffffffffc0200350:	7aaa                	ld	s5,168(sp)
ffffffffc0200352:	7b0a                	ld	s6,160(sp)
ffffffffc0200354:	6bea                	ld	s7,152(sp)
ffffffffc0200356:	6c4a                	ld	s8,144(sp)
ffffffffc0200358:	6caa                	ld	s9,136(sp)
ffffffffc020035a:	6d0a                	ld	s10,128(sp)
ffffffffc020035c:	612d                	addi	sp,sp,224
ffffffffc020035e:	8082                	ret

ffffffffc0200360 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200360:	00011317          	auipc	t1,0x11
ffffffffc0200364:	19830313          	addi	t1,t1,408 # ffffffffc02114f8 <is_panic>
ffffffffc0200368:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc020036c:	715d                	addi	sp,sp,-80
ffffffffc020036e:	ec06                	sd	ra,24(sp)
ffffffffc0200370:	f436                	sd	a3,40(sp)
ffffffffc0200372:	f83a                	sd	a4,48(sp)
ffffffffc0200374:	fc3e                	sd	a5,56(sp)
ffffffffc0200376:	e0c2                	sd	a6,64(sp)
ffffffffc0200378:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc020037a:	020e1c63          	bnez	t3,ffffffffc02003b2 <__panic+0x52>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc020037e:	4785                	li	a5,1
ffffffffc0200380:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc0200384:	e822                	sd	s0,16(sp)
ffffffffc0200386:	103c                	addi	a5,sp,40
ffffffffc0200388:	8432                	mv	s0,a2
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020038a:	862e                	mv	a2,a1
ffffffffc020038c:	85aa                	mv	a1,a0
ffffffffc020038e:	00004517          	auipc	a0,0x4
ffffffffc0200392:	41250513          	addi	a0,a0,1042 # ffffffffc02047a0 <etext+0x25e>
    va_start(ap, fmt);
ffffffffc0200396:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200398:	d23ff0ef          	jal	ffffffffc02000ba <cprintf>
    vcprintf(fmt, ap);
ffffffffc020039c:	65a2                	ld	a1,8(sp)
ffffffffc020039e:	8522                	mv	a0,s0
ffffffffc02003a0:	cfbff0ef          	jal	ffffffffc020009a <vcprintf>
    cprintf("\n");
ffffffffc02003a4:	00005517          	auipc	a0,0x5
ffffffffc02003a8:	26c50513          	addi	a0,a0,620 # ffffffffc0205610 <etext+0x10ce>
ffffffffc02003ac:	d0fff0ef          	jal	ffffffffc02000ba <cprintf>
ffffffffc02003b0:	6442                	ld	s0,16(sp)
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02003b2:	12a000ef          	jal	ffffffffc02004dc <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc02003b6:	4501                	li	a0,0
ffffffffc02003b8:	e71ff0ef          	jal	ffffffffc0200228 <kmonitor>
    while (1) {
ffffffffc02003bc:	bfed                	j	ffffffffc02003b6 <__panic+0x56>

ffffffffc02003be <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc02003be:	67e1                	lui	a5,0x18
ffffffffc02003c0:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc02003c4:	00011717          	auipc	a4,0x11
ffffffffc02003c8:	12f73e23          	sd	a5,316(a4) # ffffffffc0211500 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02003cc:	c0102573          	rdtime	a0
static inline void sbi_set_timer(uint64_t stime_value)
{
#if __riscv_xlen == 32
	SBI_CALL_2(SBI_SET_TIMER, stime_value, stime_value >> 32);
#else
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc02003d0:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02003d2:	953e                	add	a0,a0,a5
ffffffffc02003d4:	4601                	li	a2,0
ffffffffc02003d6:	4881                	li	a7,0
ffffffffc02003d8:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc02003dc:	02000793          	li	a5,32
ffffffffc02003e0:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc02003e4:	00004517          	auipc	a0,0x4
ffffffffc02003e8:	3dc50513          	addi	a0,a0,988 # ffffffffc02047c0 <etext+0x27e>
    ticks = 0;
ffffffffc02003ec:	00011797          	auipc	a5,0x11
ffffffffc02003f0:	1007be23          	sd	zero,284(a5) # ffffffffc0211508 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc02003f4:	b1d9                	j	ffffffffc02000ba <cprintf>

ffffffffc02003f6 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02003f6:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02003fa:	00011797          	auipc	a5,0x11
ffffffffc02003fe:	1067b783          	ld	a5,262(a5) # ffffffffc0211500 <timebase>
ffffffffc0200402:	953e                	add	a0,a0,a5
ffffffffc0200404:	4581                	li	a1,0
ffffffffc0200406:	4601                	li	a2,0
ffffffffc0200408:	4881                	li	a7,0
ffffffffc020040a:	00000073          	ecall
ffffffffc020040e:	8082                	ret

ffffffffc0200410 <cons_putc>:
#include <intr.h>
#include <mmu.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200410:	100027f3          	csrr	a5,sstatus
ffffffffc0200414:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200416:	0ff57513          	zext.b	a0,a0
ffffffffc020041a:	e799                	bnez	a5,ffffffffc0200428 <cons_putc+0x18>
ffffffffc020041c:	4581                	li	a1,0
ffffffffc020041e:	4601                	li	a2,0
ffffffffc0200420:	4885                	li	a7,1
ffffffffc0200422:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc0200426:	8082                	ret

/* cons_init - initializes the console devices */
void cons_init(void) {}

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc0200428:	1101                	addi	sp,sp,-32
ffffffffc020042a:	ec06                	sd	ra,24(sp)
ffffffffc020042c:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020042e:	0ae000ef          	jal	ffffffffc02004dc <intr_disable>
ffffffffc0200432:	6522                	ld	a0,8(sp)
ffffffffc0200434:	4581                	li	a1,0
ffffffffc0200436:	4601                	li	a2,0
ffffffffc0200438:	4885                	li	a7,1
ffffffffc020043a:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc020043e:	60e2                	ld	ra,24(sp)
ffffffffc0200440:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200442:	a851                	j	ffffffffc02004d6 <intr_enable>

ffffffffc0200444 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200444:	100027f3          	csrr	a5,sstatus
ffffffffc0200448:	8b89                	andi	a5,a5,2
ffffffffc020044a:	eb89                	bnez	a5,ffffffffc020045c <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc020044c:	4501                	li	a0,0
ffffffffc020044e:	4581                	li	a1,0
ffffffffc0200450:	4601                	li	a2,0
ffffffffc0200452:	4889                	li	a7,2
ffffffffc0200454:	00000073          	ecall
ffffffffc0200458:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc020045a:	8082                	ret
int cons_getc(void) {
ffffffffc020045c:	1101                	addi	sp,sp,-32
ffffffffc020045e:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0200460:	07c000ef          	jal	ffffffffc02004dc <intr_disable>
ffffffffc0200464:	4501                	li	a0,0
ffffffffc0200466:	4581                	li	a1,0
ffffffffc0200468:	4601                	li	a2,0
ffffffffc020046a:	4889                	li	a7,2
ffffffffc020046c:	00000073          	ecall
ffffffffc0200470:	2501                	sext.w	a0,a0
ffffffffc0200472:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0200474:	062000ef          	jal	ffffffffc02004d6 <intr_enable>
}
ffffffffc0200478:	60e2                	ld	ra,24(sp)
ffffffffc020047a:	6522                	ld	a0,8(sp)
ffffffffc020047c:	6105                	addi	sp,sp,32
ffffffffc020047e:	8082                	ret

ffffffffc0200480 <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}//初始化IDE接口的函数
ffffffffc0200480:	8082                	ret

ffffffffc0200482 <ide_device_valid>:

#define MAX_IDE 2// 定义最大支持的 IDE 设备数为 2（即最多两个模拟硬盘）
#define MAX_DISK_NSECS 56// 定义磁盘扇区的最大数量为 56（每个扇区的大小为 SECTSIZE，即512字节）
static char ide[MAX_DISK_NSECS * SECTSIZE];// 定义一个数组 ide，用于模拟硬盘的数据存储空间

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }// 检查硬盘设备编号 ideno 是否有效（即是否在支持的范围内）
ffffffffc0200482:	00253513          	sltiu	a0,a0,2
ffffffffc0200486:	8082                	ret

ffffffffc0200488 <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }// 获取硬盘设备的大小（以扇区数为单位）
ffffffffc0200488:	03800513          	li	a0,56
ffffffffc020048c:	8082                	ret

ffffffffc020048e <ide_read_secs>:
// 从硬盘中读取指定扇区的数据
// 参数 ideno 为设备编号，secno 为要读取的扇区号，dst 为存储数据的目的地址，nsecs 为读取的扇区数量
int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE); // 使用 memcpy 将 ide 数组中从 iobase 开始的 nsecs 个扇区的数据复制到 dst
ffffffffc020048e:	0000a797          	auipc	a5,0xa
ffffffffc0200492:	bb278793          	addi	a5,a5,-1102 # ffffffffc020a040 <ide>
    int iobase = secno * SECTSIZE;
ffffffffc0200496:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc020049a:	1141                	addi	sp,sp,-16
ffffffffc020049c:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE); // 使用 memcpy 将 ide 数组中从 iobase 开始的 nsecs 个扇区的数据复制到 dst
ffffffffc020049e:	95be                	add	a1,a1,a5
ffffffffc02004a0:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc02004a4:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE); // 使用 memcpy 将 ide 数组中从 iobase 开始的 nsecs 个扇区的数据复制到 dst
ffffffffc02004a6:	084040ef          	jal	ffffffffc020452a <memcpy>
    return 0;
}
ffffffffc02004aa:	60a2                	ld	ra,8(sp)
ffffffffc02004ac:	4501                	li	a0,0
ffffffffc02004ae:	0141                	addi	sp,sp,16
ffffffffc02004b0:	8082                	ret

ffffffffc02004b2 <ide_write_secs>:

// 将数据写入到指定的硬盘扇区
int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
    int iobase = secno * SECTSIZE;
ffffffffc02004b2:	0095979b          	slliw	a5,a1,0x9
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);// 使用 memcpy 将 src 中的数据复制到 ide 数组的指定位置
ffffffffc02004b6:	0000a517          	auipc	a0,0xa
ffffffffc02004ba:	b8a50513          	addi	a0,a0,-1142 # ffffffffc020a040 <ide>
                   size_t nsecs) {
ffffffffc02004be:	1141                	addi	sp,sp,-16
ffffffffc02004c0:	85b2                	mv	a1,a2
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);// 使用 memcpy 将 src 中的数据复制到 ide 数组的指定位置
ffffffffc02004c2:	953e                	add	a0,a0,a5
ffffffffc02004c4:	00969613          	slli	a2,a3,0x9
                   size_t nsecs) {
ffffffffc02004c8:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);// 使用 memcpy 将 src 中的数据复制到 ide 数组的指定位置
ffffffffc02004ca:	060040ef          	jal	ffffffffc020452a <memcpy>
    return 0;
}
ffffffffc02004ce:	60a2                	ld	ra,8(sp)
ffffffffc02004d0:	4501                	li	a0,0
ffffffffc02004d2:	0141                	addi	sp,sp,16
ffffffffc02004d4:	8082                	ret

ffffffffc02004d6 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004d6:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02004da:	8082                	ret

ffffffffc02004dc <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004dc:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02004e0:	8082                	ret

ffffffffc02004e2 <pgfault_handler>:
    set_csr(sstatus, SSTATUS_SUM);
}

/* trap_in_kernel - test if trap happened in kernel */
bool trap_in_kernel(struct trapframe *tf) {
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02004e2:	10053783          	ld	a5,256(a0)
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

//  tf: 异常触发时的寄存器状态和地址信息结构体
// 返回值：成功处理返回 0，否则触发 panic
static int pgfault_handler(struct trapframe *tf) {
ffffffffc02004e6:	1141                	addi	sp,sp,-16
ffffffffc02004e8:	e022                	sd	s0,0(sp)
ffffffffc02004ea:	e406                	sd	ra,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02004ec:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc02004f0:	11053583          	ld	a1,272(a0)
static int pgfault_handler(struct trapframe *tf) {
ffffffffc02004f4:	842a                	mv	s0,a0
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc02004f6:	04b00613          	li	a2,75
ffffffffc02004fa:	e399                	bnez	a5,ffffffffc0200500 <pgfault_handler+0x1e>
ffffffffc02004fc:	05500613          	li	a2,85
ffffffffc0200500:	11843703          	ld	a4,280(s0)
ffffffffc0200504:	47bd                	li	a5,15
ffffffffc0200506:	05200693          	li	a3,82
ffffffffc020050a:	00f71463          	bne	a4,a5,ffffffffc0200512 <pgfault_handler+0x30>
ffffffffc020050e:	05700693          	li	a3,87
ffffffffc0200512:	00004517          	auipc	a0,0x4
ffffffffc0200516:	2ce50513          	addi	a0,a0,718 # ffffffffc02047e0 <etext+0x29e>
ffffffffc020051a:	ba1ff0ef          	jal	ffffffffc02000ba <cprintf>
    extern struct mm_struct *check_mm_struct;// 当前使用的mm_struct的指针，在vmm.c定义
    print_pgfault(tf);
    if (check_mm_struct != NULL) {// 如果 check_mm_struct 非空，调用 do_pgfault 处理页面错误
ffffffffc020051e:	00011517          	auipc	a0,0x11
ffffffffc0200522:	05253503          	ld	a0,82(a0) # ffffffffc0211570 <check_mm_struct>
ffffffffc0200526:	c911                	beqz	a0,ffffffffc020053a <pgfault_handler+0x58>
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200528:	11043603          	ld	a2,272(s0)
ffffffffc020052c:	11843583          	ld	a1,280(s0)
    }
    panic("unhandled page fault.\n");// 如果未能处理页面错误，触发 panic 终止程序，提示未处理的页面错误
}
ffffffffc0200530:	6402                	ld	s0,0(sp)
ffffffffc0200532:	60a2                	ld	ra,8(sp)
ffffffffc0200534:	0141                	addi	sp,sp,16
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200536:	0550306f          	j	ffffffffc0203d8a <do_pgfault>
    panic("unhandled page fault.\n");// 如果未能处理页面错误，触发 panic 终止程序，提示未处理的页面错误
ffffffffc020053a:	00004617          	auipc	a2,0x4
ffffffffc020053e:	2c660613          	addi	a2,a2,710 # ffffffffc0204800 <etext+0x2be>
ffffffffc0200542:	07e00593          	li	a1,126
ffffffffc0200546:	00004517          	auipc	a0,0x4
ffffffffc020054a:	2d250513          	addi	a0,a0,722 # ffffffffc0204818 <etext+0x2d6>
ffffffffc020054e:	e13ff0ef          	jal	ffffffffc0200360 <__panic>

ffffffffc0200552 <idt_init>:
    write_csr(sscratch, 0);
ffffffffc0200552:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc0200556:	00000797          	auipc	a5,0x0
ffffffffc020055a:	4aa78793          	addi	a5,a5,1194 # ffffffffc0200a00 <__alltraps>
ffffffffc020055e:	10579073          	csrw	stvec,a5
    set_csr(sstatus, SSTATUS_SIE);
ffffffffc0200562:	100167f3          	csrrsi	a5,sstatus,2
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc0200566:	000407b7          	lui	a5,0x40
ffffffffc020056a:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc020056e:	8082                	ret

ffffffffc0200570 <print_regs>:
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200570:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200572:	1141                	addi	sp,sp,-16
ffffffffc0200574:	e022                	sd	s0,0(sp)
ffffffffc0200576:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200578:	00004517          	auipc	a0,0x4
ffffffffc020057c:	2b850513          	addi	a0,a0,696 # ffffffffc0204830 <etext+0x2ee>
void print_regs(struct pushregs *gpr) {
ffffffffc0200580:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200582:	b39ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200586:	640c                	ld	a1,8(s0)
ffffffffc0200588:	00004517          	auipc	a0,0x4
ffffffffc020058c:	2c050513          	addi	a0,a0,704 # ffffffffc0204848 <etext+0x306>
ffffffffc0200590:	b2bff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200594:	680c                	ld	a1,16(s0)
ffffffffc0200596:	00004517          	auipc	a0,0x4
ffffffffc020059a:	2ca50513          	addi	a0,a0,714 # ffffffffc0204860 <etext+0x31e>
ffffffffc020059e:	b1dff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02005a2:	6c0c                	ld	a1,24(s0)
ffffffffc02005a4:	00004517          	auipc	a0,0x4
ffffffffc02005a8:	2d450513          	addi	a0,a0,724 # ffffffffc0204878 <etext+0x336>
ffffffffc02005ac:	b0fff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02005b0:	700c                	ld	a1,32(s0)
ffffffffc02005b2:	00004517          	auipc	a0,0x4
ffffffffc02005b6:	2de50513          	addi	a0,a0,734 # ffffffffc0204890 <etext+0x34e>
ffffffffc02005ba:	b01ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02005be:	740c                	ld	a1,40(s0)
ffffffffc02005c0:	00004517          	auipc	a0,0x4
ffffffffc02005c4:	2e850513          	addi	a0,a0,744 # ffffffffc02048a8 <etext+0x366>
ffffffffc02005c8:	af3ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02005cc:	780c                	ld	a1,48(s0)
ffffffffc02005ce:	00004517          	auipc	a0,0x4
ffffffffc02005d2:	2f250513          	addi	a0,a0,754 # ffffffffc02048c0 <etext+0x37e>
ffffffffc02005d6:	ae5ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02005da:	7c0c                	ld	a1,56(s0)
ffffffffc02005dc:	00004517          	auipc	a0,0x4
ffffffffc02005e0:	2fc50513          	addi	a0,a0,764 # ffffffffc02048d8 <etext+0x396>
ffffffffc02005e4:	ad7ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02005e8:	602c                	ld	a1,64(s0)
ffffffffc02005ea:	00004517          	auipc	a0,0x4
ffffffffc02005ee:	30650513          	addi	a0,a0,774 # ffffffffc02048f0 <etext+0x3ae>
ffffffffc02005f2:	ac9ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02005f6:	642c                	ld	a1,72(s0)
ffffffffc02005f8:	00004517          	auipc	a0,0x4
ffffffffc02005fc:	31050513          	addi	a0,a0,784 # ffffffffc0204908 <etext+0x3c6>
ffffffffc0200600:	abbff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200604:	682c                	ld	a1,80(s0)
ffffffffc0200606:	00004517          	auipc	a0,0x4
ffffffffc020060a:	31a50513          	addi	a0,a0,794 # ffffffffc0204920 <etext+0x3de>
ffffffffc020060e:	aadff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200612:	6c2c                	ld	a1,88(s0)
ffffffffc0200614:	00004517          	auipc	a0,0x4
ffffffffc0200618:	32450513          	addi	a0,a0,804 # ffffffffc0204938 <etext+0x3f6>
ffffffffc020061c:	a9fff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200620:	702c                	ld	a1,96(s0)
ffffffffc0200622:	00004517          	auipc	a0,0x4
ffffffffc0200626:	32e50513          	addi	a0,a0,814 # ffffffffc0204950 <etext+0x40e>
ffffffffc020062a:	a91ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020062e:	742c                	ld	a1,104(s0)
ffffffffc0200630:	00004517          	auipc	a0,0x4
ffffffffc0200634:	33850513          	addi	a0,a0,824 # ffffffffc0204968 <etext+0x426>
ffffffffc0200638:	a83ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc020063c:	782c                	ld	a1,112(s0)
ffffffffc020063e:	00004517          	auipc	a0,0x4
ffffffffc0200642:	34250513          	addi	a0,a0,834 # ffffffffc0204980 <etext+0x43e>
ffffffffc0200646:	a75ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020064a:	7c2c                	ld	a1,120(s0)
ffffffffc020064c:	00004517          	auipc	a0,0x4
ffffffffc0200650:	34c50513          	addi	a0,a0,844 # ffffffffc0204998 <etext+0x456>
ffffffffc0200654:	a67ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200658:	604c                	ld	a1,128(s0)
ffffffffc020065a:	00004517          	auipc	a0,0x4
ffffffffc020065e:	35650513          	addi	a0,a0,854 # ffffffffc02049b0 <etext+0x46e>
ffffffffc0200662:	a59ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200666:	644c                	ld	a1,136(s0)
ffffffffc0200668:	00004517          	auipc	a0,0x4
ffffffffc020066c:	36050513          	addi	a0,a0,864 # ffffffffc02049c8 <etext+0x486>
ffffffffc0200670:	a4bff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200674:	684c                	ld	a1,144(s0)
ffffffffc0200676:	00004517          	auipc	a0,0x4
ffffffffc020067a:	36a50513          	addi	a0,a0,874 # ffffffffc02049e0 <etext+0x49e>
ffffffffc020067e:	a3dff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200682:	6c4c                	ld	a1,152(s0)
ffffffffc0200684:	00004517          	auipc	a0,0x4
ffffffffc0200688:	37450513          	addi	a0,a0,884 # ffffffffc02049f8 <etext+0x4b6>
ffffffffc020068c:	a2fff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200690:	704c                	ld	a1,160(s0)
ffffffffc0200692:	00004517          	auipc	a0,0x4
ffffffffc0200696:	37e50513          	addi	a0,a0,894 # ffffffffc0204a10 <etext+0x4ce>
ffffffffc020069a:	a21ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc020069e:	744c                	ld	a1,168(s0)
ffffffffc02006a0:	00004517          	auipc	a0,0x4
ffffffffc02006a4:	38850513          	addi	a0,a0,904 # ffffffffc0204a28 <etext+0x4e6>
ffffffffc02006a8:	a13ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02006ac:	784c                	ld	a1,176(s0)
ffffffffc02006ae:	00004517          	auipc	a0,0x4
ffffffffc02006b2:	39250513          	addi	a0,a0,914 # ffffffffc0204a40 <etext+0x4fe>
ffffffffc02006b6:	a05ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02006ba:	7c4c                	ld	a1,184(s0)
ffffffffc02006bc:	00004517          	auipc	a0,0x4
ffffffffc02006c0:	39c50513          	addi	a0,a0,924 # ffffffffc0204a58 <etext+0x516>
ffffffffc02006c4:	9f7ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02006c8:	606c                	ld	a1,192(s0)
ffffffffc02006ca:	00004517          	auipc	a0,0x4
ffffffffc02006ce:	3a650513          	addi	a0,a0,934 # ffffffffc0204a70 <etext+0x52e>
ffffffffc02006d2:	9e9ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02006d6:	646c                	ld	a1,200(s0)
ffffffffc02006d8:	00004517          	auipc	a0,0x4
ffffffffc02006dc:	3b050513          	addi	a0,a0,944 # ffffffffc0204a88 <etext+0x546>
ffffffffc02006e0:	9dbff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02006e4:	686c                	ld	a1,208(s0)
ffffffffc02006e6:	00004517          	auipc	a0,0x4
ffffffffc02006ea:	3ba50513          	addi	a0,a0,954 # ffffffffc0204aa0 <etext+0x55e>
ffffffffc02006ee:	9cdff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02006f2:	6c6c                	ld	a1,216(s0)
ffffffffc02006f4:	00004517          	auipc	a0,0x4
ffffffffc02006f8:	3c450513          	addi	a0,a0,964 # ffffffffc0204ab8 <etext+0x576>
ffffffffc02006fc:	9bfff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200700:	706c                	ld	a1,224(s0)
ffffffffc0200702:	00004517          	auipc	a0,0x4
ffffffffc0200706:	3ce50513          	addi	a0,a0,974 # ffffffffc0204ad0 <etext+0x58e>
ffffffffc020070a:	9b1ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020070e:	746c                	ld	a1,232(s0)
ffffffffc0200710:	00004517          	auipc	a0,0x4
ffffffffc0200714:	3d850513          	addi	a0,a0,984 # ffffffffc0204ae8 <etext+0x5a6>
ffffffffc0200718:	9a3ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc020071c:	786c                	ld	a1,240(s0)
ffffffffc020071e:	00004517          	auipc	a0,0x4
ffffffffc0200722:	3e250513          	addi	a0,a0,994 # ffffffffc0204b00 <etext+0x5be>
ffffffffc0200726:	995ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020072a:	7c6c                	ld	a1,248(s0)
}
ffffffffc020072c:	6402                	ld	s0,0(sp)
ffffffffc020072e:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200730:	00004517          	auipc	a0,0x4
ffffffffc0200734:	3e850513          	addi	a0,a0,1000 # ffffffffc0204b18 <etext+0x5d6>
}
ffffffffc0200738:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020073a:	b241                	j	ffffffffc02000ba <cprintf>

ffffffffc020073c <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020073c:	1141                	addi	sp,sp,-16
ffffffffc020073e:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200740:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200742:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200744:	00004517          	auipc	a0,0x4
ffffffffc0200748:	3ec50513          	addi	a0,a0,1004 # ffffffffc0204b30 <etext+0x5ee>
void print_trapframe(struct trapframe *tf) {
ffffffffc020074c:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020074e:	96dff0ef          	jal	ffffffffc02000ba <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200752:	8522                	mv	a0,s0
ffffffffc0200754:	e1dff0ef          	jal	ffffffffc0200570 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200758:	10043583          	ld	a1,256(s0)
ffffffffc020075c:	00004517          	auipc	a0,0x4
ffffffffc0200760:	3ec50513          	addi	a0,a0,1004 # ffffffffc0204b48 <etext+0x606>
ffffffffc0200764:	957ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200768:	10843583          	ld	a1,264(s0)
ffffffffc020076c:	00004517          	auipc	a0,0x4
ffffffffc0200770:	3f450513          	addi	a0,a0,1012 # ffffffffc0204b60 <etext+0x61e>
ffffffffc0200774:	947ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200778:	11043583          	ld	a1,272(s0)
ffffffffc020077c:	00004517          	auipc	a0,0x4
ffffffffc0200780:	3fc50513          	addi	a0,a0,1020 # ffffffffc0204b78 <etext+0x636>
ffffffffc0200784:	937ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200788:	11843583          	ld	a1,280(s0)
}
ffffffffc020078c:	6402                	ld	s0,0(sp)
ffffffffc020078e:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200790:	00004517          	auipc	a0,0x4
ffffffffc0200794:	40050513          	addi	a0,a0,1024 # ffffffffc0204b90 <etext+0x64e>
}
ffffffffc0200798:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020079a:	921ff06f          	j	ffffffffc02000ba <cprintf>

ffffffffc020079e <interrupt_handler>:
static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
    switch (cause) {
ffffffffc020079e:	11853783          	ld	a5,280(a0)
ffffffffc02007a2:	472d                	li	a4,11
ffffffffc02007a4:	0786                	slli	a5,a5,0x1
ffffffffc02007a6:	8385                	srli	a5,a5,0x1
ffffffffc02007a8:	08f76d63          	bltu	a4,a5,ffffffffc0200842 <interrupt_handler+0xa4>
ffffffffc02007ac:	00006717          	auipc	a4,0x6
ffffffffc02007b0:	98470713          	addi	a4,a4,-1660 # ffffffffc0206130 <commands+0x48>
ffffffffc02007b4:	078a                	slli	a5,a5,0x2
ffffffffc02007b6:	97ba                	add	a5,a5,a4
ffffffffc02007b8:	439c                	lw	a5,0(a5)
ffffffffc02007ba:	97ba                	add	a5,a5,a4
ffffffffc02007bc:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02007be:	00004517          	auipc	a0,0x4
ffffffffc02007c2:	44a50513          	addi	a0,a0,1098 # ffffffffc0204c08 <etext+0x6c6>
ffffffffc02007c6:	8f5ff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02007ca:	00004517          	auipc	a0,0x4
ffffffffc02007ce:	41e50513          	addi	a0,a0,1054 # ffffffffc0204be8 <etext+0x6a6>
ffffffffc02007d2:	8e9ff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02007d6:	00004517          	auipc	a0,0x4
ffffffffc02007da:	3d250513          	addi	a0,a0,978 # ffffffffc0204ba8 <etext+0x666>
ffffffffc02007de:	8ddff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02007e2:	00004517          	auipc	a0,0x4
ffffffffc02007e6:	3e650513          	addi	a0,a0,998 # ffffffffc0204bc8 <etext+0x686>
ffffffffc02007ea:	8d1ff06f          	j	ffffffffc02000ba <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02007ee:	1141                	addi	sp,sp,-16
ffffffffc02007f0:	e022                	sd	s0,0(sp)
ffffffffc02007f2:	e406                	sd	ra,8(sp)
            // "All bits besides SSIP and USIP in the sip register are
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();//这个代码的原型在clock.h中定义
ffffffffc02007f4:	c03ff0ef          	jal	ffffffffc02003f6 <clock_set_next_event>
            ticks++;//也是在clock.h中被声明为volatile size_t ticks;volatile 是用来告诉编译器这个变量的值可能会被程序以外的因素改变。例如，它可能被硬件、异步事件、或其他线程改变。size_t: 这是一个无符号整型数据类型，用来表示对象的大小
ffffffffc02007f8:	00011797          	auipc	a5,0x11
ffffffffc02007fc:	d1078793          	addi	a5,a5,-752 # ffffffffc0211508 <ticks>
ffffffffc0200800:	6398                	ld	a4,0(a5)
ffffffffc0200802:	00011417          	auipc	s0,0x11
ffffffffc0200806:	d0e40413          	addi	s0,s0,-754 # ffffffffc0211510 <num>
ffffffffc020080a:	0705                	addi	a4,a4,1
ffffffffc020080c:	e398                	sd	a4,0(a5)
            if(ticks%TICK_NUM==0){
ffffffffc020080e:	639c                	ld	a5,0(a5)
ffffffffc0200810:	06400713          	li	a4,100
ffffffffc0200814:	02e7f7b3          	remu	a5,a5,a4
ffffffffc0200818:	c795                	beqz	a5,ffffffffc0200844 <interrupt_handler+0xa6>
            print_ticks();
            num++;//就在trap.c中就有定义
            }
            if(num==10){
ffffffffc020081a:	6018                	ld	a4,0(s0)
ffffffffc020081c:	47a9                	li	a5,10
ffffffffc020081e:	00f71863          	bne	a4,a5,ffffffffc020082e <interrupt_handler+0x90>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc0200822:	4501                	li	a0,0
ffffffffc0200824:	4581                	li	a1,0
ffffffffc0200826:	4601                	li	a2,0
ffffffffc0200828:	48a1                	li	a7,8
ffffffffc020082a:	00000073          	ecall
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc020082e:	60a2                	ld	ra,8(sp)
ffffffffc0200830:	6402                	ld	s0,0(sp)
ffffffffc0200832:	0141                	addi	sp,sp,16
ffffffffc0200834:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200836:	00004517          	auipc	a0,0x4
ffffffffc020083a:	40250513          	addi	a0,a0,1026 # ffffffffc0204c38 <etext+0x6f6>
ffffffffc020083e:	87dff06f          	j	ffffffffc02000ba <cprintf>
            print_trapframe(tf);
ffffffffc0200842:	bded                	j	ffffffffc020073c <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200844:	06400593          	li	a1,100
ffffffffc0200848:	00004517          	auipc	a0,0x4
ffffffffc020084c:	3e050513          	addi	a0,a0,992 # ffffffffc0204c28 <etext+0x6e6>
ffffffffc0200850:	86bff0ef          	jal	ffffffffc02000ba <cprintf>
            num++;//就在trap.c中就有定义
ffffffffc0200854:	601c                	ld	a5,0(s0)
ffffffffc0200856:	0785                	addi	a5,a5,1
ffffffffc0200858:	e01c                	sd	a5,0(s0)
ffffffffc020085a:	b7c1                	j	ffffffffc020081a <interrupt_handler+0x7c>

ffffffffc020085c <exception_handler>:


void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc020085c:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc0200860:	1101                	addi	sp,sp,-32
ffffffffc0200862:	e822                	sd	s0,16(sp)
ffffffffc0200864:	ec06                	sd	ra,24(sp)
    switch (tf->cause) {
ffffffffc0200866:	473d                	li	a4,15
void exception_handler(struct trapframe *tf) {
ffffffffc0200868:	842a                	mv	s0,a0
    switch (tf->cause) {
ffffffffc020086a:	14f76d63          	bltu	a4,a5,ffffffffc02009c4 <exception_handler+0x168>
ffffffffc020086e:	00006717          	auipc	a4,0x6
ffffffffc0200872:	8f270713          	addi	a4,a4,-1806 # ffffffffc0206160 <commands+0x78>
ffffffffc0200876:	078a                	slli	a5,a5,0x2
ffffffffc0200878:	97ba                	add	a5,a5,a4
ffffffffc020087a:	439c                	lw	a5,0(a5)
ffffffffc020087c:	97ba                	add	a5,a5,a4
ffffffffc020087e:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc0200880:	00004517          	auipc	a0,0x4
ffffffffc0200884:	57850513          	addi	a0,a0,1400 # ffffffffc0204df8 <etext+0x8b6>
ffffffffc0200888:	e426                	sd	s1,8(sp)
ffffffffc020088a:	831ff0ef          	jal	ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc020088e:	8522                	mv	a0,s0
ffffffffc0200890:	c53ff0ef          	jal	ffffffffc02004e2 <pgfault_handler>
ffffffffc0200894:	84aa                	mv	s1,a0
ffffffffc0200896:	12051c63          	bnez	a0,ffffffffc02009ce <exception_handler+0x172>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc020089a:	60e2                	ld	ra,24(sp)
ffffffffc020089c:	6442                	ld	s0,16(sp)
ffffffffc020089e:	64a2                	ld	s1,8(sp)
ffffffffc02008a0:	6105                	addi	sp,sp,32
ffffffffc02008a2:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc02008a4:	00004517          	auipc	a0,0x4
ffffffffc02008a8:	3b450513          	addi	a0,a0,948 # ffffffffc0204c58 <etext+0x716>
}
ffffffffc02008ac:	6442                	ld	s0,16(sp)
ffffffffc02008ae:	60e2                	ld	ra,24(sp)
ffffffffc02008b0:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc02008b2:	809ff06f          	j	ffffffffc02000ba <cprintf>
ffffffffc02008b6:	00004517          	auipc	a0,0x4
ffffffffc02008ba:	3c250513          	addi	a0,a0,962 # ffffffffc0204c78 <etext+0x736>
ffffffffc02008be:	b7fd                	j	ffffffffc02008ac <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc02008c0:	00004517          	auipc	a0,0x4
ffffffffc02008c4:	3d850513          	addi	a0,a0,984 # ffffffffc0204c98 <etext+0x756>
ffffffffc02008c8:	b7d5                	j	ffffffffc02008ac <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc02008ca:	00004517          	auipc	a0,0x4
ffffffffc02008ce:	3e650513          	addi	a0,a0,998 # ffffffffc0204cb0 <etext+0x76e>
ffffffffc02008d2:	bfe9                	j	ffffffffc02008ac <exception_handler+0x50>
            cprintf("Load address misaligned\n");
ffffffffc02008d4:	00004517          	auipc	a0,0x4
ffffffffc02008d8:	3ec50513          	addi	a0,a0,1004 # ffffffffc0204cc0 <etext+0x77e>
ffffffffc02008dc:	bfc1                	j	ffffffffc02008ac <exception_handler+0x50>
            cprintf("Load access fault\n");// 调用 pgfault_handler 处理页面错误，若处理失败，打印帧并触发 panic
ffffffffc02008de:	00004517          	auipc	a0,0x4
ffffffffc02008e2:	40250513          	addi	a0,a0,1026 # ffffffffc0204ce0 <etext+0x79e>
ffffffffc02008e6:	e426                	sd	s1,8(sp)
ffffffffc02008e8:	fd2ff0ef          	jal	ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02008ec:	8522                	mv	a0,s0
ffffffffc02008ee:	bf5ff0ef          	jal	ffffffffc02004e2 <pgfault_handler>
ffffffffc02008f2:	84aa                	mv	s1,a0
ffffffffc02008f4:	d15d                	beqz	a0,ffffffffc020089a <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02008f6:	8522                	mv	a0,s0
ffffffffc02008f8:	e45ff0ef          	jal	ffffffffc020073c <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02008fc:	86a6                	mv	a3,s1
ffffffffc02008fe:	00004617          	auipc	a2,0x4
ffffffffc0200902:	3fa60613          	addi	a2,a2,1018 # ffffffffc0204cf8 <etext+0x7b6>
ffffffffc0200906:	0d500593          	li	a1,213
ffffffffc020090a:	00004517          	auipc	a0,0x4
ffffffffc020090e:	f0e50513          	addi	a0,a0,-242 # ffffffffc0204818 <etext+0x2d6>
ffffffffc0200912:	a4fff0ef          	jal	ffffffffc0200360 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc0200916:	00004517          	auipc	a0,0x4
ffffffffc020091a:	40250513          	addi	a0,a0,1026 # ffffffffc0204d18 <etext+0x7d6>
ffffffffc020091e:	b779                	j	ffffffffc02008ac <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc0200920:	00004517          	auipc	a0,0x4
ffffffffc0200924:	41050513          	addi	a0,a0,1040 # ffffffffc0204d30 <etext+0x7ee>
ffffffffc0200928:	e426                	sd	s1,8(sp)
ffffffffc020092a:	f90ff0ef          	jal	ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc020092e:	8522                	mv	a0,s0
ffffffffc0200930:	bb3ff0ef          	jal	ffffffffc02004e2 <pgfault_handler>
ffffffffc0200934:	84aa                	mv	s1,a0
ffffffffc0200936:	d135                	beqz	a0,ffffffffc020089a <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200938:	8522                	mv	a0,s0
ffffffffc020093a:	e03ff0ef          	jal	ffffffffc020073c <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc020093e:	86a6                	mv	a3,s1
ffffffffc0200940:	00004617          	auipc	a2,0x4
ffffffffc0200944:	3b860613          	addi	a2,a2,952 # ffffffffc0204cf8 <etext+0x7b6>
ffffffffc0200948:	0df00593          	li	a1,223
ffffffffc020094c:	00004517          	auipc	a0,0x4
ffffffffc0200950:	ecc50513          	addi	a0,a0,-308 # ffffffffc0204818 <etext+0x2d6>
ffffffffc0200954:	a0dff0ef          	jal	ffffffffc0200360 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc0200958:	00004517          	auipc	a0,0x4
ffffffffc020095c:	3f050513          	addi	a0,a0,1008 # ffffffffc0204d48 <etext+0x806>
ffffffffc0200960:	b7b1                	j	ffffffffc02008ac <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc0200962:	00004517          	auipc	a0,0x4
ffffffffc0200966:	40650513          	addi	a0,a0,1030 # ffffffffc0204d68 <etext+0x826>
ffffffffc020096a:	b789                	j	ffffffffc02008ac <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc020096c:	00004517          	auipc	a0,0x4
ffffffffc0200970:	41c50513          	addi	a0,a0,1052 # ffffffffc0204d88 <etext+0x846>
ffffffffc0200974:	bf25                	j	ffffffffc02008ac <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc0200976:	00004517          	auipc	a0,0x4
ffffffffc020097a:	43250513          	addi	a0,a0,1074 # ffffffffc0204da8 <etext+0x866>
ffffffffc020097e:	b73d                	j	ffffffffc02008ac <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200980:	00004517          	auipc	a0,0x4
ffffffffc0200984:	44850513          	addi	a0,a0,1096 # ffffffffc0204dc8 <etext+0x886>
ffffffffc0200988:	b715                	j	ffffffffc02008ac <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc020098a:	00004517          	auipc	a0,0x4
ffffffffc020098e:	45650513          	addi	a0,a0,1110 # ffffffffc0204de0 <etext+0x89e>
ffffffffc0200992:	e426                	sd	s1,8(sp)
ffffffffc0200994:	f26ff0ef          	jal	ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200998:	8522                	mv	a0,s0
ffffffffc020099a:	b49ff0ef          	jal	ffffffffc02004e2 <pgfault_handler>
ffffffffc020099e:	84aa                	mv	s1,a0
ffffffffc02009a0:	ee050de3          	beqz	a0,ffffffffc020089a <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02009a4:	8522                	mv	a0,s0
ffffffffc02009a6:	d97ff0ef          	jal	ffffffffc020073c <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009aa:	86a6                	mv	a3,s1
ffffffffc02009ac:	00004617          	auipc	a2,0x4
ffffffffc02009b0:	34c60613          	addi	a2,a2,844 # ffffffffc0204cf8 <etext+0x7b6>
ffffffffc02009b4:	0f500593          	li	a1,245
ffffffffc02009b8:	00004517          	auipc	a0,0x4
ffffffffc02009bc:	e6050513          	addi	a0,a0,-416 # ffffffffc0204818 <etext+0x2d6>
ffffffffc02009c0:	9a1ff0ef          	jal	ffffffffc0200360 <__panic>
            print_trapframe(tf);
ffffffffc02009c4:	8522                	mv	a0,s0
}
ffffffffc02009c6:	6442                	ld	s0,16(sp)
ffffffffc02009c8:	60e2                	ld	ra,24(sp)
ffffffffc02009ca:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc02009cc:	bb85                	j	ffffffffc020073c <print_trapframe>
                print_trapframe(tf);
ffffffffc02009ce:	8522                	mv	a0,s0
ffffffffc02009d0:	d6dff0ef          	jal	ffffffffc020073c <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009d4:	86a6                	mv	a3,s1
ffffffffc02009d6:	00004617          	auipc	a2,0x4
ffffffffc02009da:	32260613          	addi	a2,a2,802 # ffffffffc0204cf8 <etext+0x7b6>
ffffffffc02009de:	0fc00593          	li	a1,252
ffffffffc02009e2:	00004517          	auipc	a0,0x4
ffffffffc02009e6:	e3650513          	addi	a0,a0,-458 # ffffffffc0204818 <etext+0x2d6>
ffffffffc02009ea:	977ff0ef          	jal	ffffffffc0200360 <__panic>

ffffffffc02009ee <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc02009ee:	11853783          	ld	a5,280(a0)
ffffffffc02009f2:	0007c363          	bltz	a5,ffffffffc02009f8 <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc02009f6:	b59d                	j	ffffffffc020085c <exception_handler>
        interrupt_handler(tf);
ffffffffc02009f8:	b35d                	j	ffffffffc020079e <interrupt_handler>
ffffffffc02009fa:	0000                	unimp
ffffffffc02009fc:	0000                	unimp
	...

ffffffffc0200a00 <__alltraps>:
    .endm

    .align 4
    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200a00:	14011073          	csrw	sscratch,sp
ffffffffc0200a04:	712d                	addi	sp,sp,-288
ffffffffc0200a06:	e406                	sd	ra,8(sp)
ffffffffc0200a08:	ec0e                	sd	gp,24(sp)
ffffffffc0200a0a:	f012                	sd	tp,32(sp)
ffffffffc0200a0c:	f416                	sd	t0,40(sp)
ffffffffc0200a0e:	f81a                	sd	t1,48(sp)
ffffffffc0200a10:	fc1e                	sd	t2,56(sp)
ffffffffc0200a12:	e0a2                	sd	s0,64(sp)
ffffffffc0200a14:	e4a6                	sd	s1,72(sp)
ffffffffc0200a16:	e8aa                	sd	a0,80(sp)
ffffffffc0200a18:	ecae                	sd	a1,88(sp)
ffffffffc0200a1a:	f0b2                	sd	a2,96(sp)
ffffffffc0200a1c:	f4b6                	sd	a3,104(sp)
ffffffffc0200a1e:	f8ba                	sd	a4,112(sp)
ffffffffc0200a20:	fcbe                	sd	a5,120(sp)
ffffffffc0200a22:	e142                	sd	a6,128(sp)
ffffffffc0200a24:	e546                	sd	a7,136(sp)
ffffffffc0200a26:	e94a                	sd	s2,144(sp)
ffffffffc0200a28:	ed4e                	sd	s3,152(sp)
ffffffffc0200a2a:	f152                	sd	s4,160(sp)
ffffffffc0200a2c:	f556                	sd	s5,168(sp)
ffffffffc0200a2e:	f95a                	sd	s6,176(sp)
ffffffffc0200a30:	fd5e                	sd	s7,184(sp)
ffffffffc0200a32:	e1e2                	sd	s8,192(sp)
ffffffffc0200a34:	e5e6                	sd	s9,200(sp)
ffffffffc0200a36:	e9ea                	sd	s10,208(sp)
ffffffffc0200a38:	edee                	sd	s11,216(sp)
ffffffffc0200a3a:	f1f2                	sd	t3,224(sp)
ffffffffc0200a3c:	f5f6                	sd	t4,232(sp)
ffffffffc0200a3e:	f9fa                	sd	t5,240(sp)
ffffffffc0200a40:	fdfe                	sd	t6,248(sp)
ffffffffc0200a42:	14002473          	csrr	s0,sscratch
ffffffffc0200a46:	100024f3          	csrr	s1,sstatus
ffffffffc0200a4a:	14102973          	csrr	s2,sepc
ffffffffc0200a4e:	143029f3          	csrr	s3,stval
ffffffffc0200a52:	14202a73          	csrr	s4,scause
ffffffffc0200a56:	e822                	sd	s0,16(sp)
ffffffffc0200a58:	e226                	sd	s1,256(sp)
ffffffffc0200a5a:	e64a                	sd	s2,264(sp)
ffffffffc0200a5c:	ea4e                	sd	s3,272(sp)
ffffffffc0200a5e:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200a60:	850a                	mv	a0,sp
    jal trap
ffffffffc0200a62:	f8dff0ef          	jal	ffffffffc02009ee <trap>

ffffffffc0200a66 <__trapret>:
    // sp should be the same as before "jal trap"
    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200a66:	6492                	ld	s1,256(sp)
ffffffffc0200a68:	6932                	ld	s2,264(sp)
ffffffffc0200a6a:	10049073          	csrw	sstatus,s1
ffffffffc0200a6e:	14191073          	csrw	sepc,s2
ffffffffc0200a72:	60a2                	ld	ra,8(sp)
ffffffffc0200a74:	61e2                	ld	gp,24(sp)
ffffffffc0200a76:	7202                	ld	tp,32(sp)
ffffffffc0200a78:	72a2                	ld	t0,40(sp)
ffffffffc0200a7a:	7342                	ld	t1,48(sp)
ffffffffc0200a7c:	73e2                	ld	t2,56(sp)
ffffffffc0200a7e:	6406                	ld	s0,64(sp)
ffffffffc0200a80:	64a6                	ld	s1,72(sp)
ffffffffc0200a82:	6546                	ld	a0,80(sp)
ffffffffc0200a84:	65e6                	ld	a1,88(sp)
ffffffffc0200a86:	7606                	ld	a2,96(sp)
ffffffffc0200a88:	76a6                	ld	a3,104(sp)
ffffffffc0200a8a:	7746                	ld	a4,112(sp)
ffffffffc0200a8c:	77e6                	ld	a5,120(sp)
ffffffffc0200a8e:	680a                	ld	a6,128(sp)
ffffffffc0200a90:	68aa                	ld	a7,136(sp)
ffffffffc0200a92:	694a                	ld	s2,144(sp)
ffffffffc0200a94:	69ea                	ld	s3,152(sp)
ffffffffc0200a96:	7a0a                	ld	s4,160(sp)
ffffffffc0200a98:	7aaa                	ld	s5,168(sp)
ffffffffc0200a9a:	7b4a                	ld	s6,176(sp)
ffffffffc0200a9c:	7bea                	ld	s7,184(sp)
ffffffffc0200a9e:	6c0e                	ld	s8,192(sp)
ffffffffc0200aa0:	6cae                	ld	s9,200(sp)
ffffffffc0200aa2:	6d4e                	ld	s10,208(sp)
ffffffffc0200aa4:	6dee                	ld	s11,216(sp)
ffffffffc0200aa6:	7e0e                	ld	t3,224(sp)
ffffffffc0200aa8:	7eae                	ld	t4,232(sp)
ffffffffc0200aaa:	7f4e                	ld	t5,240(sp)
ffffffffc0200aac:	7fee                	ld	t6,248(sp)
ffffffffc0200aae:	6142                	ld	sp,16(sp)
    // go back from supervisor call
    sret
ffffffffc0200ab0:	10200073          	sret
	...

ffffffffc0200ac0 <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200ac0:	00010797          	auipc	a5,0x10
ffffffffc0200ac4:	58078793          	addi	a5,a5,1408 # ffffffffc0211040 <free_area>
ffffffffc0200ac8:	e79c                	sd	a5,8(a5)
ffffffffc0200aca:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200acc:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200ad0:	8082                	ret

ffffffffc0200ad2 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200ad2:	00010517          	auipc	a0,0x10
ffffffffc0200ad6:	57e56503          	lwu	a0,1406(a0) # ffffffffc0211050 <free_area+0x10>
ffffffffc0200ada:	8082                	ret

ffffffffc0200adc <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200adc:	715d                	addi	sp,sp,-80
ffffffffc0200ade:	e0a2                	sd	s0,64(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200ae0:	00010417          	auipc	s0,0x10
ffffffffc0200ae4:	56040413          	addi	s0,s0,1376 # ffffffffc0211040 <free_area>
ffffffffc0200ae8:	641c                	ld	a5,8(s0)
ffffffffc0200aea:	e486                	sd	ra,72(sp)
ffffffffc0200aec:	fc26                	sd	s1,56(sp)
ffffffffc0200aee:	f84a                	sd	s2,48(sp)
ffffffffc0200af0:	f44e                	sd	s3,40(sp)
ffffffffc0200af2:	f052                	sd	s4,32(sp)
ffffffffc0200af4:	ec56                	sd	s5,24(sp)
ffffffffc0200af6:	e85a                	sd	s6,16(sp)
ffffffffc0200af8:	e45e                	sd	s7,8(sp)
ffffffffc0200afa:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200afc:	2e878063          	beq	a5,s0,ffffffffc0200ddc <default_check+0x300>
    int count = 0, total = 0;
ffffffffc0200b00:	4481                	li	s1,0
ffffffffc0200b02:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200b04:	fe87b703          	ld	a4,-24(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200b08:	8b09                	andi	a4,a4,2
ffffffffc0200b0a:	2c070d63          	beqz	a4,ffffffffc0200de4 <default_check+0x308>
        count ++, total += p->property;
ffffffffc0200b0e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200b12:	679c                	ld	a5,8(a5)
ffffffffc0200b14:	2905                	addiw	s2,s2,1
ffffffffc0200b16:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b18:	fe8796e3          	bne	a5,s0,ffffffffc0200b04 <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0200b1c:	89a6                	mv	s3,s1
ffffffffc0200b1e:	395000ef          	jal	ffffffffc02016b2 <nr_free_pages>
ffffffffc0200b22:	73351163          	bne	a0,s3,ffffffffc0201244 <default_check+0x768>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200b26:	4505                	li	a0,1
ffffffffc0200b28:	2bb000ef          	jal	ffffffffc02015e2 <alloc_pages>
ffffffffc0200b2c:	8a2a                	mv	s4,a0
ffffffffc0200b2e:	44050b63          	beqz	a0,ffffffffc0200f84 <default_check+0x4a8>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200b32:	4505                	li	a0,1
ffffffffc0200b34:	2af000ef          	jal	ffffffffc02015e2 <alloc_pages>
ffffffffc0200b38:	89aa                	mv	s3,a0
ffffffffc0200b3a:	72050563          	beqz	a0,ffffffffc0201264 <default_check+0x788>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200b3e:	4505                	li	a0,1
ffffffffc0200b40:	2a3000ef          	jal	ffffffffc02015e2 <alloc_pages>
ffffffffc0200b44:	8aaa                	mv	s5,a0
ffffffffc0200b46:	4a050f63          	beqz	a0,ffffffffc0201004 <default_check+0x528>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200b4a:	2b3a0d63          	beq	s4,s3,ffffffffc0200e04 <default_check+0x328>
ffffffffc0200b4e:	2aaa0b63          	beq	s4,a0,ffffffffc0200e04 <default_check+0x328>
ffffffffc0200b52:	2aa98963          	beq	s3,a0,ffffffffc0200e04 <default_check+0x328>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200b56:	000a2783          	lw	a5,0(s4)
ffffffffc0200b5a:	2c079563          	bnez	a5,ffffffffc0200e24 <default_check+0x348>
ffffffffc0200b5e:	0009a783          	lw	a5,0(s3)
ffffffffc0200b62:	2c079163          	bnez	a5,ffffffffc0200e24 <default_check+0x348>
ffffffffc0200b66:	411c                	lw	a5,0(a0)
ffffffffc0200b68:	2a079e63          	bnez	a5,ffffffffc0200e24 <default_check+0x348>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200b6c:	f8e397b7          	lui	a5,0xf8e39
ffffffffc0200b70:	e3978793          	addi	a5,a5,-455 # fffffffff8e38e39 <end+0x38c278c1>
ffffffffc0200b74:	07b2                	slli	a5,a5,0xc
ffffffffc0200b76:	e3978793          	addi	a5,a5,-455
ffffffffc0200b7a:	07b2                	slli	a5,a5,0xc
ffffffffc0200b7c:	00011717          	auipc	a4,0x11
ffffffffc0200b80:	9c473703          	ld	a4,-1596(a4) # ffffffffc0211540 <pages>
ffffffffc0200b84:	e3978793          	addi	a5,a5,-455
ffffffffc0200b88:	40ea06b3          	sub	a3,s4,a4
ffffffffc0200b8c:	07b2                	slli	a5,a5,0xc
ffffffffc0200b8e:	868d                	srai	a3,a3,0x3
ffffffffc0200b90:	e3978793          	addi	a5,a5,-455
ffffffffc0200b94:	02f686b3          	mul	a3,a3,a5
ffffffffc0200b98:	00005597          	auipc	a1,0x5
ffffffffc0200b9c:	7d05b583          	ld	a1,2000(a1) # ffffffffc0206368 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200ba0:	00011617          	auipc	a2,0x11
ffffffffc0200ba4:	99863603          	ld	a2,-1640(a2) # ffffffffc0211538 <npage>
ffffffffc0200ba8:	0632                	slli	a2,a2,0xc
ffffffffc0200baa:	96ae                	add	a3,a3,a1

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200bac:	06b2                	slli	a3,a3,0xc
ffffffffc0200bae:	28c6fb63          	bgeu	a3,a2,ffffffffc0200e44 <default_check+0x368>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200bb2:	40e986b3          	sub	a3,s3,a4
ffffffffc0200bb6:	868d                	srai	a3,a3,0x3
ffffffffc0200bb8:	02f686b3          	mul	a3,a3,a5
ffffffffc0200bbc:	96ae                	add	a3,a3,a1
    return page2ppn(page) << PGSHIFT;
ffffffffc0200bbe:	06b2                	slli	a3,a3,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200bc0:	4cc6f263          	bgeu	a3,a2,ffffffffc0201084 <default_check+0x5a8>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200bc4:	40e50733          	sub	a4,a0,a4
ffffffffc0200bc8:	870d                	srai	a4,a4,0x3
ffffffffc0200bca:	02f707b3          	mul	a5,a4,a5
ffffffffc0200bce:	97ae                	add	a5,a5,a1
    return page2ppn(page) << PGSHIFT;
ffffffffc0200bd0:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200bd2:	30c7f963          	bgeu	a5,a2,ffffffffc0200ee4 <default_check+0x408>
    assert(alloc_page() == NULL);
ffffffffc0200bd6:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200bd8:	00043c03          	ld	s8,0(s0)
ffffffffc0200bdc:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0200be0:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0200be4:	e400                	sd	s0,8(s0)
ffffffffc0200be6:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0200be8:	00010797          	auipc	a5,0x10
ffffffffc0200bec:	4607a423          	sw	zero,1128(a5) # ffffffffc0211050 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200bf0:	1f3000ef          	jal	ffffffffc02015e2 <alloc_pages>
ffffffffc0200bf4:	2c051863          	bnez	a0,ffffffffc0200ec4 <default_check+0x3e8>
    free_page(p0);
ffffffffc0200bf8:	4585                	li	a1,1
ffffffffc0200bfa:	8552                	mv	a0,s4
ffffffffc0200bfc:	277000ef          	jal	ffffffffc0201672 <free_pages>
    free_page(p1);
ffffffffc0200c00:	4585                	li	a1,1
ffffffffc0200c02:	854e                	mv	a0,s3
ffffffffc0200c04:	26f000ef          	jal	ffffffffc0201672 <free_pages>
    free_page(p2);
ffffffffc0200c08:	4585                	li	a1,1
ffffffffc0200c0a:	8556                	mv	a0,s5
ffffffffc0200c0c:	267000ef          	jal	ffffffffc0201672 <free_pages>
    assert(nr_free == 3);
ffffffffc0200c10:	4818                	lw	a4,16(s0)
ffffffffc0200c12:	478d                	li	a5,3
ffffffffc0200c14:	28f71863          	bne	a4,a5,ffffffffc0200ea4 <default_check+0x3c8>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200c18:	4505                	li	a0,1
ffffffffc0200c1a:	1c9000ef          	jal	ffffffffc02015e2 <alloc_pages>
ffffffffc0200c1e:	89aa                	mv	s3,a0
ffffffffc0200c20:	26050263          	beqz	a0,ffffffffc0200e84 <default_check+0x3a8>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200c24:	4505                	li	a0,1
ffffffffc0200c26:	1bd000ef          	jal	ffffffffc02015e2 <alloc_pages>
ffffffffc0200c2a:	8aaa                	mv	s5,a0
ffffffffc0200c2c:	3a050c63          	beqz	a0,ffffffffc0200fe4 <default_check+0x508>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200c30:	4505                	li	a0,1
ffffffffc0200c32:	1b1000ef          	jal	ffffffffc02015e2 <alloc_pages>
ffffffffc0200c36:	8a2a                	mv	s4,a0
ffffffffc0200c38:	38050663          	beqz	a0,ffffffffc0200fc4 <default_check+0x4e8>
    assert(alloc_page() == NULL);
ffffffffc0200c3c:	4505                	li	a0,1
ffffffffc0200c3e:	1a5000ef          	jal	ffffffffc02015e2 <alloc_pages>
ffffffffc0200c42:	36051163          	bnez	a0,ffffffffc0200fa4 <default_check+0x4c8>
    free_page(p0);
ffffffffc0200c46:	4585                	li	a1,1
ffffffffc0200c48:	854e                	mv	a0,s3
ffffffffc0200c4a:	229000ef          	jal	ffffffffc0201672 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200c4e:	641c                	ld	a5,8(s0)
ffffffffc0200c50:	20878a63          	beq	a5,s0,ffffffffc0200e64 <default_check+0x388>
    assert((p = alloc_page()) == p0);
ffffffffc0200c54:	4505                	li	a0,1
ffffffffc0200c56:	18d000ef          	jal	ffffffffc02015e2 <alloc_pages>
ffffffffc0200c5a:	30a99563          	bne	s3,a0,ffffffffc0200f64 <default_check+0x488>
    assert(alloc_page() == NULL);
ffffffffc0200c5e:	4505                	li	a0,1
ffffffffc0200c60:	183000ef          	jal	ffffffffc02015e2 <alloc_pages>
ffffffffc0200c64:	2e051063          	bnez	a0,ffffffffc0200f44 <default_check+0x468>
    assert(nr_free == 0);
ffffffffc0200c68:	481c                	lw	a5,16(s0)
ffffffffc0200c6a:	2a079d63          	bnez	a5,ffffffffc0200f24 <default_check+0x448>
    free_page(p);
ffffffffc0200c6e:	854e                	mv	a0,s3
ffffffffc0200c70:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200c72:	01843023          	sd	s8,0(s0)
ffffffffc0200c76:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0200c7a:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0200c7e:	1f5000ef          	jal	ffffffffc0201672 <free_pages>
    free_page(p1);
ffffffffc0200c82:	4585                	li	a1,1
ffffffffc0200c84:	8556                	mv	a0,s5
ffffffffc0200c86:	1ed000ef          	jal	ffffffffc0201672 <free_pages>
    free_page(p2);
ffffffffc0200c8a:	4585                	li	a1,1
ffffffffc0200c8c:	8552                	mv	a0,s4
ffffffffc0200c8e:	1e5000ef          	jal	ffffffffc0201672 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200c92:	4515                	li	a0,5
ffffffffc0200c94:	14f000ef          	jal	ffffffffc02015e2 <alloc_pages>
ffffffffc0200c98:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200c9a:	26050563          	beqz	a0,ffffffffc0200f04 <default_check+0x428>
ffffffffc0200c9e:	651c                	ld	a5,8(a0)
ffffffffc0200ca0:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200ca2:	8b85                	andi	a5,a5,1
ffffffffc0200ca4:	54079063          	bnez	a5,ffffffffc02011e4 <default_check+0x708>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200ca8:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200caa:	00043b03          	ld	s6,0(s0)
ffffffffc0200cae:	00843a83          	ld	s5,8(s0)
ffffffffc0200cb2:	e000                	sd	s0,0(s0)
ffffffffc0200cb4:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0200cb6:	12d000ef          	jal	ffffffffc02015e2 <alloc_pages>
ffffffffc0200cba:	50051563          	bnez	a0,ffffffffc02011c4 <default_check+0x6e8>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0200cbe:	09098a13          	addi	s4,s3,144
ffffffffc0200cc2:	8552                	mv	a0,s4
ffffffffc0200cc4:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0200cc6:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc0200cca:	00010797          	auipc	a5,0x10
ffffffffc0200cce:	3807a323          	sw	zero,902(a5) # ffffffffc0211050 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0200cd2:	1a1000ef          	jal	ffffffffc0201672 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200cd6:	4511                	li	a0,4
ffffffffc0200cd8:	10b000ef          	jal	ffffffffc02015e2 <alloc_pages>
ffffffffc0200cdc:	4c051463          	bnez	a0,ffffffffc02011a4 <default_check+0x6c8>
ffffffffc0200ce0:	0989b783          	ld	a5,152(s3)
ffffffffc0200ce4:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0200ce6:	8b85                	andi	a5,a5,1
ffffffffc0200ce8:	48078e63          	beqz	a5,ffffffffc0201184 <default_check+0x6a8>
ffffffffc0200cec:	0a89a703          	lw	a4,168(s3)
ffffffffc0200cf0:	478d                	li	a5,3
ffffffffc0200cf2:	48f71963          	bne	a4,a5,ffffffffc0201184 <default_check+0x6a8>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0200cf6:	450d                	li	a0,3
ffffffffc0200cf8:	0eb000ef          	jal	ffffffffc02015e2 <alloc_pages>
ffffffffc0200cfc:	8c2a                	mv	s8,a0
ffffffffc0200cfe:	46050363          	beqz	a0,ffffffffc0201164 <default_check+0x688>
    assert(alloc_page() == NULL);
ffffffffc0200d02:	4505                	li	a0,1
ffffffffc0200d04:	0df000ef          	jal	ffffffffc02015e2 <alloc_pages>
ffffffffc0200d08:	42051e63          	bnez	a0,ffffffffc0201144 <default_check+0x668>
    assert(p0 + 2 == p1);
ffffffffc0200d0c:	418a1c63          	bne	s4,s8,ffffffffc0201124 <default_check+0x648>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0200d10:	4585                	li	a1,1
ffffffffc0200d12:	854e                	mv	a0,s3
ffffffffc0200d14:	15f000ef          	jal	ffffffffc0201672 <free_pages>
    free_pages(p1, 3);
ffffffffc0200d18:	458d                	li	a1,3
ffffffffc0200d1a:	8552                	mv	a0,s4
ffffffffc0200d1c:	157000ef          	jal	ffffffffc0201672 <free_pages>
ffffffffc0200d20:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0200d24:	04898c13          	addi	s8,s3,72
ffffffffc0200d28:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0200d2a:	8b85                	andi	a5,a5,1
ffffffffc0200d2c:	3c078c63          	beqz	a5,ffffffffc0201104 <default_check+0x628>
ffffffffc0200d30:	0189a703          	lw	a4,24(s3)
ffffffffc0200d34:	4785                	li	a5,1
ffffffffc0200d36:	3cf71763          	bne	a4,a5,ffffffffc0201104 <default_check+0x628>
ffffffffc0200d3a:	008a3783          	ld	a5,8(s4)
ffffffffc0200d3e:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0200d40:	8b85                	andi	a5,a5,1
ffffffffc0200d42:	3a078163          	beqz	a5,ffffffffc02010e4 <default_check+0x608>
ffffffffc0200d46:	018a2703          	lw	a4,24(s4)
ffffffffc0200d4a:	478d                	li	a5,3
ffffffffc0200d4c:	38f71c63          	bne	a4,a5,ffffffffc02010e4 <default_check+0x608>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0200d50:	4505                	li	a0,1
ffffffffc0200d52:	091000ef          	jal	ffffffffc02015e2 <alloc_pages>
ffffffffc0200d56:	36a99763          	bne	s3,a0,ffffffffc02010c4 <default_check+0x5e8>
    free_page(p0);
ffffffffc0200d5a:	4585                	li	a1,1
ffffffffc0200d5c:	117000ef          	jal	ffffffffc0201672 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0200d60:	4509                	li	a0,2
ffffffffc0200d62:	081000ef          	jal	ffffffffc02015e2 <alloc_pages>
ffffffffc0200d66:	32aa1f63          	bne	s4,a0,ffffffffc02010a4 <default_check+0x5c8>

    free_pages(p0, 2);
ffffffffc0200d6a:	4589                	li	a1,2
ffffffffc0200d6c:	107000ef          	jal	ffffffffc0201672 <free_pages>
    free_page(p2);
ffffffffc0200d70:	4585                	li	a1,1
ffffffffc0200d72:	8562                	mv	a0,s8
ffffffffc0200d74:	0ff000ef          	jal	ffffffffc0201672 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200d78:	4515                	li	a0,5
ffffffffc0200d7a:	069000ef          	jal	ffffffffc02015e2 <alloc_pages>
ffffffffc0200d7e:	89aa                	mv	s3,a0
ffffffffc0200d80:	48050263          	beqz	a0,ffffffffc0201204 <default_check+0x728>
    assert(alloc_page() == NULL);
ffffffffc0200d84:	4505                	li	a0,1
ffffffffc0200d86:	05d000ef          	jal	ffffffffc02015e2 <alloc_pages>
ffffffffc0200d8a:	2c051d63          	bnez	a0,ffffffffc0201064 <default_check+0x588>

    assert(nr_free == 0);
ffffffffc0200d8e:	481c                	lw	a5,16(s0)
ffffffffc0200d90:	2a079a63          	bnez	a5,ffffffffc0201044 <default_check+0x568>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200d94:	4595                	li	a1,5
ffffffffc0200d96:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200d98:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc0200d9c:	01643023          	sd	s6,0(s0)
ffffffffc0200da0:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc0200da4:	0cf000ef          	jal	ffffffffc0201672 <free_pages>
    return listelm->next;
ffffffffc0200da8:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200daa:	00878963          	beq	a5,s0,ffffffffc0200dbc <default_check+0x2e0>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200dae:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200db2:	679c                	ld	a5,8(a5)
ffffffffc0200db4:	397d                	addiw	s2,s2,-1
ffffffffc0200db6:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200db8:	fe879be3          	bne	a5,s0,ffffffffc0200dae <default_check+0x2d2>
    }
    assert(count == 0);
ffffffffc0200dbc:	26091463          	bnez	s2,ffffffffc0201024 <default_check+0x548>
    assert(total == 0);
ffffffffc0200dc0:	46049263          	bnez	s1,ffffffffc0201224 <default_check+0x748>
}
ffffffffc0200dc4:	60a6                	ld	ra,72(sp)
ffffffffc0200dc6:	6406                	ld	s0,64(sp)
ffffffffc0200dc8:	74e2                	ld	s1,56(sp)
ffffffffc0200dca:	7942                	ld	s2,48(sp)
ffffffffc0200dcc:	79a2                	ld	s3,40(sp)
ffffffffc0200dce:	7a02                	ld	s4,32(sp)
ffffffffc0200dd0:	6ae2                	ld	s5,24(sp)
ffffffffc0200dd2:	6b42                	ld	s6,16(sp)
ffffffffc0200dd4:	6ba2                	ld	s7,8(sp)
ffffffffc0200dd6:	6c02                	ld	s8,0(sp)
ffffffffc0200dd8:	6161                	addi	sp,sp,80
ffffffffc0200dda:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200ddc:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200dde:	4481                	li	s1,0
ffffffffc0200de0:	4901                	li	s2,0
ffffffffc0200de2:	bb35                	j	ffffffffc0200b1e <default_check+0x42>
        assert(PageProperty(p));
ffffffffc0200de4:	00004697          	auipc	a3,0x4
ffffffffc0200de8:	02c68693          	addi	a3,a3,44 # ffffffffc0204e10 <etext+0x8ce>
ffffffffc0200dec:	00004617          	auipc	a2,0x4
ffffffffc0200df0:	03460613          	addi	a2,a2,52 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0200df4:	0f000593          	li	a1,240
ffffffffc0200df8:	00004517          	auipc	a0,0x4
ffffffffc0200dfc:	04050513          	addi	a0,a0,64 # ffffffffc0204e38 <etext+0x8f6>
ffffffffc0200e00:	d60ff0ef          	jal	ffffffffc0200360 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200e04:	00004697          	auipc	a3,0x4
ffffffffc0200e08:	0cc68693          	addi	a3,a3,204 # ffffffffc0204ed0 <etext+0x98e>
ffffffffc0200e0c:	00004617          	auipc	a2,0x4
ffffffffc0200e10:	01460613          	addi	a2,a2,20 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0200e14:	0bd00593          	li	a1,189
ffffffffc0200e18:	00004517          	auipc	a0,0x4
ffffffffc0200e1c:	02050513          	addi	a0,a0,32 # ffffffffc0204e38 <etext+0x8f6>
ffffffffc0200e20:	d40ff0ef          	jal	ffffffffc0200360 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200e24:	00004697          	auipc	a3,0x4
ffffffffc0200e28:	0d468693          	addi	a3,a3,212 # ffffffffc0204ef8 <etext+0x9b6>
ffffffffc0200e2c:	00004617          	auipc	a2,0x4
ffffffffc0200e30:	ff460613          	addi	a2,a2,-12 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0200e34:	0be00593          	li	a1,190
ffffffffc0200e38:	00004517          	auipc	a0,0x4
ffffffffc0200e3c:	00050513          	mv	a0,a0
ffffffffc0200e40:	d20ff0ef          	jal	ffffffffc0200360 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200e44:	00004697          	auipc	a3,0x4
ffffffffc0200e48:	0f468693          	addi	a3,a3,244 # ffffffffc0204f38 <etext+0x9f6>
ffffffffc0200e4c:	00004617          	auipc	a2,0x4
ffffffffc0200e50:	fd460613          	addi	a2,a2,-44 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0200e54:	0c000593          	li	a1,192
ffffffffc0200e58:	00004517          	auipc	a0,0x4
ffffffffc0200e5c:	fe050513          	addi	a0,a0,-32 # ffffffffc0204e38 <etext+0x8f6>
ffffffffc0200e60:	d00ff0ef          	jal	ffffffffc0200360 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200e64:	00004697          	auipc	a3,0x4
ffffffffc0200e68:	15c68693          	addi	a3,a3,348 # ffffffffc0204fc0 <etext+0xa7e>
ffffffffc0200e6c:	00004617          	auipc	a2,0x4
ffffffffc0200e70:	fb460613          	addi	a2,a2,-76 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0200e74:	0d900593          	li	a1,217
ffffffffc0200e78:	00004517          	auipc	a0,0x4
ffffffffc0200e7c:	fc050513          	addi	a0,a0,-64 # ffffffffc0204e38 <etext+0x8f6>
ffffffffc0200e80:	ce0ff0ef          	jal	ffffffffc0200360 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200e84:	00004697          	auipc	a3,0x4
ffffffffc0200e88:	fec68693          	addi	a3,a3,-20 # ffffffffc0204e70 <etext+0x92e>
ffffffffc0200e8c:	00004617          	auipc	a2,0x4
ffffffffc0200e90:	f9460613          	addi	a2,a2,-108 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0200e94:	0d200593          	li	a1,210
ffffffffc0200e98:	00004517          	auipc	a0,0x4
ffffffffc0200e9c:	fa050513          	addi	a0,a0,-96 # ffffffffc0204e38 <etext+0x8f6>
ffffffffc0200ea0:	cc0ff0ef          	jal	ffffffffc0200360 <__panic>
    assert(nr_free == 3);
ffffffffc0200ea4:	00004697          	auipc	a3,0x4
ffffffffc0200ea8:	10c68693          	addi	a3,a3,268 # ffffffffc0204fb0 <etext+0xa6e>
ffffffffc0200eac:	00004617          	auipc	a2,0x4
ffffffffc0200eb0:	f7460613          	addi	a2,a2,-140 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0200eb4:	0d000593          	li	a1,208
ffffffffc0200eb8:	00004517          	auipc	a0,0x4
ffffffffc0200ebc:	f8050513          	addi	a0,a0,-128 # ffffffffc0204e38 <etext+0x8f6>
ffffffffc0200ec0:	ca0ff0ef          	jal	ffffffffc0200360 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200ec4:	00004697          	auipc	a3,0x4
ffffffffc0200ec8:	0d468693          	addi	a3,a3,212 # ffffffffc0204f98 <etext+0xa56>
ffffffffc0200ecc:	00004617          	auipc	a2,0x4
ffffffffc0200ed0:	f5460613          	addi	a2,a2,-172 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0200ed4:	0cb00593          	li	a1,203
ffffffffc0200ed8:	00004517          	auipc	a0,0x4
ffffffffc0200edc:	f6050513          	addi	a0,a0,-160 # ffffffffc0204e38 <etext+0x8f6>
ffffffffc0200ee0:	c80ff0ef          	jal	ffffffffc0200360 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200ee4:	00004697          	auipc	a3,0x4
ffffffffc0200ee8:	09468693          	addi	a3,a3,148 # ffffffffc0204f78 <etext+0xa36>
ffffffffc0200eec:	00004617          	auipc	a2,0x4
ffffffffc0200ef0:	f3460613          	addi	a2,a2,-204 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0200ef4:	0c200593          	li	a1,194
ffffffffc0200ef8:	00004517          	auipc	a0,0x4
ffffffffc0200efc:	f4050513          	addi	a0,a0,-192 # ffffffffc0204e38 <etext+0x8f6>
ffffffffc0200f00:	c60ff0ef          	jal	ffffffffc0200360 <__panic>
    assert(p0 != NULL);
ffffffffc0200f04:	00004697          	auipc	a3,0x4
ffffffffc0200f08:	10468693          	addi	a3,a3,260 # ffffffffc0205008 <etext+0xac6>
ffffffffc0200f0c:	00004617          	auipc	a2,0x4
ffffffffc0200f10:	f1460613          	addi	a2,a2,-236 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0200f14:	0f800593          	li	a1,248
ffffffffc0200f18:	00004517          	auipc	a0,0x4
ffffffffc0200f1c:	f2050513          	addi	a0,a0,-224 # ffffffffc0204e38 <etext+0x8f6>
ffffffffc0200f20:	c40ff0ef          	jal	ffffffffc0200360 <__panic>
    assert(nr_free == 0);
ffffffffc0200f24:	00004697          	auipc	a3,0x4
ffffffffc0200f28:	0d468693          	addi	a3,a3,212 # ffffffffc0204ff8 <etext+0xab6>
ffffffffc0200f2c:	00004617          	auipc	a2,0x4
ffffffffc0200f30:	ef460613          	addi	a2,a2,-268 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0200f34:	0df00593          	li	a1,223
ffffffffc0200f38:	00004517          	auipc	a0,0x4
ffffffffc0200f3c:	f0050513          	addi	a0,a0,-256 # ffffffffc0204e38 <etext+0x8f6>
ffffffffc0200f40:	c20ff0ef          	jal	ffffffffc0200360 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f44:	00004697          	auipc	a3,0x4
ffffffffc0200f48:	05468693          	addi	a3,a3,84 # ffffffffc0204f98 <etext+0xa56>
ffffffffc0200f4c:	00004617          	auipc	a2,0x4
ffffffffc0200f50:	ed460613          	addi	a2,a2,-300 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0200f54:	0dd00593          	li	a1,221
ffffffffc0200f58:	00004517          	auipc	a0,0x4
ffffffffc0200f5c:	ee050513          	addi	a0,a0,-288 # ffffffffc0204e38 <etext+0x8f6>
ffffffffc0200f60:	c00ff0ef          	jal	ffffffffc0200360 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0200f64:	00004697          	auipc	a3,0x4
ffffffffc0200f68:	07468693          	addi	a3,a3,116 # ffffffffc0204fd8 <etext+0xa96>
ffffffffc0200f6c:	00004617          	auipc	a2,0x4
ffffffffc0200f70:	eb460613          	addi	a2,a2,-332 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0200f74:	0dc00593          	li	a1,220
ffffffffc0200f78:	00004517          	auipc	a0,0x4
ffffffffc0200f7c:	ec050513          	addi	a0,a0,-320 # ffffffffc0204e38 <etext+0x8f6>
ffffffffc0200f80:	be0ff0ef          	jal	ffffffffc0200360 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200f84:	00004697          	auipc	a3,0x4
ffffffffc0200f88:	eec68693          	addi	a3,a3,-276 # ffffffffc0204e70 <etext+0x92e>
ffffffffc0200f8c:	00004617          	auipc	a2,0x4
ffffffffc0200f90:	e9460613          	addi	a2,a2,-364 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0200f94:	0b900593          	li	a1,185
ffffffffc0200f98:	00004517          	auipc	a0,0x4
ffffffffc0200f9c:	ea050513          	addi	a0,a0,-352 # ffffffffc0204e38 <etext+0x8f6>
ffffffffc0200fa0:	bc0ff0ef          	jal	ffffffffc0200360 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200fa4:	00004697          	auipc	a3,0x4
ffffffffc0200fa8:	ff468693          	addi	a3,a3,-12 # ffffffffc0204f98 <etext+0xa56>
ffffffffc0200fac:	00004617          	auipc	a2,0x4
ffffffffc0200fb0:	e7460613          	addi	a2,a2,-396 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0200fb4:	0d600593          	li	a1,214
ffffffffc0200fb8:	00004517          	auipc	a0,0x4
ffffffffc0200fbc:	e8050513          	addi	a0,a0,-384 # ffffffffc0204e38 <etext+0x8f6>
ffffffffc0200fc0:	ba0ff0ef          	jal	ffffffffc0200360 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200fc4:	00004697          	auipc	a3,0x4
ffffffffc0200fc8:	eec68693          	addi	a3,a3,-276 # ffffffffc0204eb0 <etext+0x96e>
ffffffffc0200fcc:	00004617          	auipc	a2,0x4
ffffffffc0200fd0:	e5460613          	addi	a2,a2,-428 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0200fd4:	0d400593          	li	a1,212
ffffffffc0200fd8:	00004517          	auipc	a0,0x4
ffffffffc0200fdc:	e6050513          	addi	a0,a0,-416 # ffffffffc0204e38 <etext+0x8f6>
ffffffffc0200fe0:	b80ff0ef          	jal	ffffffffc0200360 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200fe4:	00004697          	auipc	a3,0x4
ffffffffc0200fe8:	eac68693          	addi	a3,a3,-340 # ffffffffc0204e90 <etext+0x94e>
ffffffffc0200fec:	00004617          	auipc	a2,0x4
ffffffffc0200ff0:	e3460613          	addi	a2,a2,-460 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0200ff4:	0d300593          	li	a1,211
ffffffffc0200ff8:	00004517          	auipc	a0,0x4
ffffffffc0200ffc:	e4050513          	addi	a0,a0,-448 # ffffffffc0204e38 <etext+0x8f6>
ffffffffc0201000:	b60ff0ef          	jal	ffffffffc0200360 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201004:	00004697          	auipc	a3,0x4
ffffffffc0201008:	eac68693          	addi	a3,a3,-340 # ffffffffc0204eb0 <etext+0x96e>
ffffffffc020100c:	00004617          	auipc	a2,0x4
ffffffffc0201010:	e1460613          	addi	a2,a2,-492 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0201014:	0bb00593          	li	a1,187
ffffffffc0201018:	00004517          	auipc	a0,0x4
ffffffffc020101c:	e2050513          	addi	a0,a0,-480 # ffffffffc0204e38 <etext+0x8f6>
ffffffffc0201020:	b40ff0ef          	jal	ffffffffc0200360 <__panic>
    assert(count == 0);
ffffffffc0201024:	00004697          	auipc	a3,0x4
ffffffffc0201028:	13468693          	addi	a3,a3,308 # ffffffffc0205158 <etext+0xc16>
ffffffffc020102c:	00004617          	auipc	a2,0x4
ffffffffc0201030:	df460613          	addi	a2,a2,-524 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0201034:	12500593          	li	a1,293
ffffffffc0201038:	00004517          	auipc	a0,0x4
ffffffffc020103c:	e0050513          	addi	a0,a0,-512 # ffffffffc0204e38 <etext+0x8f6>
ffffffffc0201040:	b20ff0ef          	jal	ffffffffc0200360 <__panic>
    assert(nr_free == 0);
ffffffffc0201044:	00004697          	auipc	a3,0x4
ffffffffc0201048:	fb468693          	addi	a3,a3,-76 # ffffffffc0204ff8 <etext+0xab6>
ffffffffc020104c:	00004617          	auipc	a2,0x4
ffffffffc0201050:	dd460613          	addi	a2,a2,-556 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0201054:	11a00593          	li	a1,282
ffffffffc0201058:	00004517          	auipc	a0,0x4
ffffffffc020105c:	de050513          	addi	a0,a0,-544 # ffffffffc0204e38 <etext+0x8f6>
ffffffffc0201060:	b00ff0ef          	jal	ffffffffc0200360 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201064:	00004697          	auipc	a3,0x4
ffffffffc0201068:	f3468693          	addi	a3,a3,-204 # ffffffffc0204f98 <etext+0xa56>
ffffffffc020106c:	00004617          	auipc	a2,0x4
ffffffffc0201070:	db460613          	addi	a2,a2,-588 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0201074:	11800593          	li	a1,280
ffffffffc0201078:	00004517          	auipc	a0,0x4
ffffffffc020107c:	dc050513          	addi	a0,a0,-576 # ffffffffc0204e38 <etext+0x8f6>
ffffffffc0201080:	ae0ff0ef          	jal	ffffffffc0200360 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201084:	00004697          	auipc	a3,0x4
ffffffffc0201088:	ed468693          	addi	a3,a3,-300 # ffffffffc0204f58 <etext+0xa16>
ffffffffc020108c:	00004617          	auipc	a2,0x4
ffffffffc0201090:	d9460613          	addi	a2,a2,-620 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0201094:	0c100593          	li	a1,193
ffffffffc0201098:	00004517          	auipc	a0,0x4
ffffffffc020109c:	da050513          	addi	a0,a0,-608 # ffffffffc0204e38 <etext+0x8f6>
ffffffffc02010a0:	ac0ff0ef          	jal	ffffffffc0200360 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02010a4:	00004697          	auipc	a3,0x4
ffffffffc02010a8:	07468693          	addi	a3,a3,116 # ffffffffc0205118 <etext+0xbd6>
ffffffffc02010ac:	00004617          	auipc	a2,0x4
ffffffffc02010b0:	d7460613          	addi	a2,a2,-652 # ffffffffc0204e20 <etext+0x8de>
ffffffffc02010b4:	11200593          	li	a1,274
ffffffffc02010b8:	00004517          	auipc	a0,0x4
ffffffffc02010bc:	d8050513          	addi	a0,a0,-640 # ffffffffc0204e38 <etext+0x8f6>
ffffffffc02010c0:	aa0ff0ef          	jal	ffffffffc0200360 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02010c4:	00004697          	auipc	a3,0x4
ffffffffc02010c8:	03468693          	addi	a3,a3,52 # ffffffffc02050f8 <etext+0xbb6>
ffffffffc02010cc:	00004617          	auipc	a2,0x4
ffffffffc02010d0:	d5460613          	addi	a2,a2,-684 # ffffffffc0204e20 <etext+0x8de>
ffffffffc02010d4:	11000593          	li	a1,272
ffffffffc02010d8:	00004517          	auipc	a0,0x4
ffffffffc02010dc:	d6050513          	addi	a0,a0,-672 # ffffffffc0204e38 <etext+0x8f6>
ffffffffc02010e0:	a80ff0ef          	jal	ffffffffc0200360 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02010e4:	00004697          	auipc	a3,0x4
ffffffffc02010e8:	fec68693          	addi	a3,a3,-20 # ffffffffc02050d0 <etext+0xb8e>
ffffffffc02010ec:	00004617          	auipc	a2,0x4
ffffffffc02010f0:	d3460613          	addi	a2,a2,-716 # ffffffffc0204e20 <etext+0x8de>
ffffffffc02010f4:	10e00593          	li	a1,270
ffffffffc02010f8:	00004517          	auipc	a0,0x4
ffffffffc02010fc:	d4050513          	addi	a0,a0,-704 # ffffffffc0204e38 <etext+0x8f6>
ffffffffc0201100:	a60ff0ef          	jal	ffffffffc0200360 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201104:	00004697          	auipc	a3,0x4
ffffffffc0201108:	fa468693          	addi	a3,a3,-92 # ffffffffc02050a8 <etext+0xb66>
ffffffffc020110c:	00004617          	auipc	a2,0x4
ffffffffc0201110:	d1460613          	addi	a2,a2,-748 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0201114:	10d00593          	li	a1,269
ffffffffc0201118:	00004517          	auipc	a0,0x4
ffffffffc020111c:	d2050513          	addi	a0,a0,-736 # ffffffffc0204e38 <etext+0x8f6>
ffffffffc0201120:	a40ff0ef          	jal	ffffffffc0200360 <__panic>
    assert(p0 + 2 == p1);
ffffffffc0201124:	00004697          	auipc	a3,0x4
ffffffffc0201128:	f7468693          	addi	a3,a3,-140 # ffffffffc0205098 <etext+0xb56>
ffffffffc020112c:	00004617          	auipc	a2,0x4
ffffffffc0201130:	cf460613          	addi	a2,a2,-780 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0201134:	10800593          	li	a1,264
ffffffffc0201138:	00004517          	auipc	a0,0x4
ffffffffc020113c:	d0050513          	addi	a0,a0,-768 # ffffffffc0204e38 <etext+0x8f6>
ffffffffc0201140:	a20ff0ef          	jal	ffffffffc0200360 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201144:	00004697          	auipc	a3,0x4
ffffffffc0201148:	e5468693          	addi	a3,a3,-428 # ffffffffc0204f98 <etext+0xa56>
ffffffffc020114c:	00004617          	auipc	a2,0x4
ffffffffc0201150:	cd460613          	addi	a2,a2,-812 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0201154:	10700593          	li	a1,263
ffffffffc0201158:	00004517          	auipc	a0,0x4
ffffffffc020115c:	ce050513          	addi	a0,a0,-800 # ffffffffc0204e38 <etext+0x8f6>
ffffffffc0201160:	a00ff0ef          	jal	ffffffffc0200360 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201164:	00004697          	auipc	a3,0x4
ffffffffc0201168:	f1468693          	addi	a3,a3,-236 # ffffffffc0205078 <etext+0xb36>
ffffffffc020116c:	00004617          	auipc	a2,0x4
ffffffffc0201170:	cb460613          	addi	a2,a2,-844 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0201174:	10600593          	li	a1,262
ffffffffc0201178:	00004517          	auipc	a0,0x4
ffffffffc020117c:	cc050513          	addi	a0,a0,-832 # ffffffffc0204e38 <etext+0x8f6>
ffffffffc0201180:	9e0ff0ef          	jal	ffffffffc0200360 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201184:	00004697          	auipc	a3,0x4
ffffffffc0201188:	ec468693          	addi	a3,a3,-316 # ffffffffc0205048 <etext+0xb06>
ffffffffc020118c:	00004617          	auipc	a2,0x4
ffffffffc0201190:	c9460613          	addi	a2,a2,-876 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0201194:	10500593          	li	a1,261
ffffffffc0201198:	00004517          	auipc	a0,0x4
ffffffffc020119c:	ca050513          	addi	a0,a0,-864 # ffffffffc0204e38 <etext+0x8f6>
ffffffffc02011a0:	9c0ff0ef          	jal	ffffffffc0200360 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc02011a4:	00004697          	auipc	a3,0x4
ffffffffc02011a8:	e8c68693          	addi	a3,a3,-372 # ffffffffc0205030 <etext+0xaee>
ffffffffc02011ac:	00004617          	auipc	a2,0x4
ffffffffc02011b0:	c7460613          	addi	a2,a2,-908 # ffffffffc0204e20 <etext+0x8de>
ffffffffc02011b4:	10400593          	li	a1,260
ffffffffc02011b8:	00004517          	auipc	a0,0x4
ffffffffc02011bc:	c8050513          	addi	a0,a0,-896 # ffffffffc0204e38 <etext+0x8f6>
ffffffffc02011c0:	9a0ff0ef          	jal	ffffffffc0200360 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02011c4:	00004697          	auipc	a3,0x4
ffffffffc02011c8:	dd468693          	addi	a3,a3,-556 # ffffffffc0204f98 <etext+0xa56>
ffffffffc02011cc:	00004617          	auipc	a2,0x4
ffffffffc02011d0:	c5460613          	addi	a2,a2,-940 # ffffffffc0204e20 <etext+0x8de>
ffffffffc02011d4:	0fe00593          	li	a1,254
ffffffffc02011d8:	00004517          	auipc	a0,0x4
ffffffffc02011dc:	c6050513          	addi	a0,a0,-928 # ffffffffc0204e38 <etext+0x8f6>
ffffffffc02011e0:	980ff0ef          	jal	ffffffffc0200360 <__panic>
    assert(!PageProperty(p0));
ffffffffc02011e4:	00004697          	auipc	a3,0x4
ffffffffc02011e8:	e3468693          	addi	a3,a3,-460 # ffffffffc0205018 <etext+0xad6>
ffffffffc02011ec:	00004617          	auipc	a2,0x4
ffffffffc02011f0:	c3460613          	addi	a2,a2,-972 # ffffffffc0204e20 <etext+0x8de>
ffffffffc02011f4:	0f900593          	li	a1,249
ffffffffc02011f8:	00004517          	auipc	a0,0x4
ffffffffc02011fc:	c4050513          	addi	a0,a0,-960 # ffffffffc0204e38 <etext+0x8f6>
ffffffffc0201200:	960ff0ef          	jal	ffffffffc0200360 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201204:	00004697          	auipc	a3,0x4
ffffffffc0201208:	f3468693          	addi	a3,a3,-204 # ffffffffc0205138 <etext+0xbf6>
ffffffffc020120c:	00004617          	auipc	a2,0x4
ffffffffc0201210:	c1460613          	addi	a2,a2,-1004 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0201214:	11700593          	li	a1,279
ffffffffc0201218:	00004517          	auipc	a0,0x4
ffffffffc020121c:	c2050513          	addi	a0,a0,-992 # ffffffffc0204e38 <etext+0x8f6>
ffffffffc0201220:	940ff0ef          	jal	ffffffffc0200360 <__panic>
    assert(total == 0);
ffffffffc0201224:	00004697          	auipc	a3,0x4
ffffffffc0201228:	f4468693          	addi	a3,a3,-188 # ffffffffc0205168 <etext+0xc26>
ffffffffc020122c:	00004617          	auipc	a2,0x4
ffffffffc0201230:	bf460613          	addi	a2,a2,-1036 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0201234:	12600593          	li	a1,294
ffffffffc0201238:	00004517          	auipc	a0,0x4
ffffffffc020123c:	c0050513          	addi	a0,a0,-1024 # ffffffffc0204e38 <etext+0x8f6>
ffffffffc0201240:	920ff0ef          	jal	ffffffffc0200360 <__panic>
    assert(total == nr_free_pages());
ffffffffc0201244:	00004697          	auipc	a3,0x4
ffffffffc0201248:	c0c68693          	addi	a3,a3,-1012 # ffffffffc0204e50 <etext+0x90e>
ffffffffc020124c:	00004617          	auipc	a2,0x4
ffffffffc0201250:	bd460613          	addi	a2,a2,-1068 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0201254:	0f300593          	li	a1,243
ffffffffc0201258:	00004517          	auipc	a0,0x4
ffffffffc020125c:	be050513          	addi	a0,a0,-1056 # ffffffffc0204e38 <etext+0x8f6>
ffffffffc0201260:	900ff0ef          	jal	ffffffffc0200360 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201264:	00004697          	auipc	a3,0x4
ffffffffc0201268:	c2c68693          	addi	a3,a3,-980 # ffffffffc0204e90 <etext+0x94e>
ffffffffc020126c:	00004617          	auipc	a2,0x4
ffffffffc0201270:	bb460613          	addi	a2,a2,-1100 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0201274:	0ba00593          	li	a1,186
ffffffffc0201278:	00004517          	auipc	a0,0x4
ffffffffc020127c:	bc050513          	addi	a0,a0,-1088 # ffffffffc0204e38 <etext+0x8f6>
ffffffffc0201280:	8e0ff0ef          	jal	ffffffffc0200360 <__panic>

ffffffffc0201284 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0201284:	1141                	addi	sp,sp,-16
ffffffffc0201286:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201288:	14058a63          	beqz	a1,ffffffffc02013dc <default_free_pages+0x158>
    for (; p != base + n; p ++) {
ffffffffc020128c:	00359713          	slli	a4,a1,0x3
ffffffffc0201290:	972e                	add	a4,a4,a1
ffffffffc0201292:	070e                	slli	a4,a4,0x3
ffffffffc0201294:	00e506b3          	add	a3,a0,a4
    struct Page *p = base;
ffffffffc0201298:	87aa                	mv	a5,a0
    for (; p != base + n; p ++) {
ffffffffc020129a:	c30d                	beqz	a4,ffffffffc02012bc <default_free_pages+0x38>
ffffffffc020129c:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020129e:	8b05                	andi	a4,a4,1
ffffffffc02012a0:	10071e63          	bnez	a4,ffffffffc02013bc <default_free_pages+0x138>
ffffffffc02012a4:	6798                	ld	a4,8(a5)
ffffffffc02012a6:	8b09                	andi	a4,a4,2
ffffffffc02012a8:	10071a63          	bnez	a4,ffffffffc02013bc <default_free_pages+0x138>
        p->flags = 0;
ffffffffc02012ac:	0007b423          	sd	zero,8(a5)
    return pa2page(PDE_ADDR(pde));
}

static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02012b0:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02012b4:	04878793          	addi	a5,a5,72
ffffffffc02012b8:	fed792e3          	bne	a5,a3,ffffffffc020129c <default_free_pages+0x18>
    base->property = n;
ffffffffc02012bc:	2581                	sext.w	a1,a1
ffffffffc02012be:	cd0c                	sw	a1,24(a0)
    SetPageProperty(base);
ffffffffc02012c0:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02012c4:	4789                	li	a5,2
ffffffffc02012c6:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc02012ca:	00010697          	auipc	a3,0x10
ffffffffc02012ce:	d7668693          	addi	a3,a3,-650 # ffffffffc0211040 <free_area>
ffffffffc02012d2:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02012d4:	669c                	ld	a5,8(a3)
ffffffffc02012d6:	9f2d                	addw	a4,a4,a1
ffffffffc02012d8:	ca98                	sw	a4,16(a3)
    if (list_empty(&free_list)) {
ffffffffc02012da:	0ad78563          	beq	a5,a3,ffffffffc0201384 <default_free_pages+0x100>
            struct Page* page = le2page(le, page_link);
ffffffffc02012de:	fe078713          	addi	a4,a5,-32
ffffffffc02012e2:	4581                	li	a1,0
ffffffffc02012e4:	02050613          	addi	a2,a0,32
            if (base < page) {
ffffffffc02012e8:	00e56a63          	bltu	a0,a4,ffffffffc02012fc <default_free_pages+0x78>
    return listelm->next;
ffffffffc02012ec:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02012ee:	06d70263          	beq	a4,a3,ffffffffc0201352 <default_free_pages+0xce>
    struct Page *p = base;
ffffffffc02012f2:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02012f4:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc02012f8:	fee57ae3          	bgeu	a0,a4,ffffffffc02012ec <default_free_pages+0x68>
ffffffffc02012fc:	c199                	beqz	a1,ffffffffc0201302 <default_free_pages+0x7e>
ffffffffc02012fe:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201302:	6398                	ld	a4,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0201304:	e390                	sd	a2,0(a5)
ffffffffc0201306:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201308:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc020130a:	f118                	sd	a4,32(a0)
    if (le != &free_list) {
ffffffffc020130c:	02d70063          	beq	a4,a3,ffffffffc020132c <default_free_pages+0xa8>
        if (p + p->property == base) {
ffffffffc0201310:	ff872803          	lw	a6,-8(a4)
        p = le2page(le, page_link);
ffffffffc0201314:	fe070593          	addi	a1,a4,-32
        if (p + p->property == base) {
ffffffffc0201318:	02081613          	slli	a2,a6,0x20
ffffffffc020131c:	9201                	srli	a2,a2,0x20
ffffffffc020131e:	00361793          	slli	a5,a2,0x3
ffffffffc0201322:	97b2                	add	a5,a5,a2
ffffffffc0201324:	078e                	slli	a5,a5,0x3
ffffffffc0201326:	97ae                	add	a5,a5,a1
ffffffffc0201328:	02f50f63          	beq	a0,a5,ffffffffc0201366 <default_free_pages+0xe2>
    return listelm->next;
ffffffffc020132c:	7518                	ld	a4,40(a0)
    if (le != &free_list) {
ffffffffc020132e:	00d70f63          	beq	a4,a3,ffffffffc020134c <default_free_pages+0xc8>
        if (base + base->property == p) {
ffffffffc0201332:	4d0c                	lw	a1,24(a0)
        p = le2page(le, page_link);
ffffffffc0201334:	fe070693          	addi	a3,a4,-32
        if (base + base->property == p) {
ffffffffc0201338:	02059613          	slli	a2,a1,0x20
ffffffffc020133c:	9201                	srli	a2,a2,0x20
ffffffffc020133e:	00361793          	slli	a5,a2,0x3
ffffffffc0201342:	97b2                	add	a5,a5,a2
ffffffffc0201344:	078e                	slli	a5,a5,0x3
ffffffffc0201346:	97aa                	add	a5,a5,a0
ffffffffc0201348:	04f68a63          	beq	a3,a5,ffffffffc020139c <default_free_pages+0x118>
}
ffffffffc020134c:	60a2                	ld	ra,8(sp)
ffffffffc020134e:	0141                	addi	sp,sp,16
ffffffffc0201350:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201352:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201354:	f514                	sd	a3,40(a0)
    return listelm->next;
ffffffffc0201356:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201358:	f11c                	sd	a5,32(a0)
                list_add(le, &(base->page_link));
ffffffffc020135a:	8832                	mv	a6,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc020135c:	02d70d63          	beq	a4,a3,ffffffffc0201396 <default_free_pages+0x112>
ffffffffc0201360:	4585                	li	a1,1
    struct Page *p = base;
ffffffffc0201362:	87ba                	mv	a5,a4
ffffffffc0201364:	bf41                	j	ffffffffc02012f4 <default_free_pages+0x70>
            p->property += base->property;
ffffffffc0201366:	4d1c                	lw	a5,24(a0)
ffffffffc0201368:	010787bb          	addw	a5,a5,a6
ffffffffc020136c:	fef72c23          	sw	a5,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201370:	57f5                	li	a5,-3
ffffffffc0201372:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201376:	7110                	ld	a2,32(a0)
ffffffffc0201378:	751c                	ld	a5,40(a0)
            base = p;
ffffffffc020137a:	852e                	mv	a0,a1
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc020137c:	e61c                	sd	a5,8(a2)
    return listelm->next;
ffffffffc020137e:	6718                	ld	a4,8(a4)
    next->prev = prev;
ffffffffc0201380:	e390                	sd	a2,0(a5)
ffffffffc0201382:	b775                	j	ffffffffc020132e <default_free_pages+0xaa>
}
ffffffffc0201384:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201386:	02050713          	addi	a4,a0,32
    prev->next = next->prev = elm;
ffffffffc020138a:	e398                	sd	a4,0(a5)
ffffffffc020138c:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc020138e:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0201390:	f11c                	sd	a5,32(a0)
}
ffffffffc0201392:	0141                	addi	sp,sp,16
ffffffffc0201394:	8082                	ret
ffffffffc0201396:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc0201398:	873e                	mv	a4,a5
ffffffffc020139a:	bf8d                	j	ffffffffc020130c <default_free_pages+0x88>
            base->property += p->property;
ffffffffc020139c:	ff872783          	lw	a5,-8(a4)
ffffffffc02013a0:	fe870693          	addi	a3,a4,-24
ffffffffc02013a4:	9fad                	addw	a5,a5,a1
ffffffffc02013a6:	cd1c                	sw	a5,24(a0)
ffffffffc02013a8:	57f5                	li	a5,-3
ffffffffc02013aa:	60f6b02f          	amoand.d	zero,a5,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02013ae:	6314                	ld	a3,0(a4)
ffffffffc02013b0:	671c                	ld	a5,8(a4)
}
ffffffffc02013b2:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02013b4:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc02013b6:	e394                	sd	a3,0(a5)
ffffffffc02013b8:	0141                	addi	sp,sp,16
ffffffffc02013ba:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02013bc:	00004697          	auipc	a3,0x4
ffffffffc02013c0:	dc468693          	addi	a3,a3,-572 # ffffffffc0205180 <etext+0xc3e>
ffffffffc02013c4:	00004617          	auipc	a2,0x4
ffffffffc02013c8:	a5c60613          	addi	a2,a2,-1444 # ffffffffc0204e20 <etext+0x8de>
ffffffffc02013cc:	08300593          	li	a1,131
ffffffffc02013d0:	00004517          	auipc	a0,0x4
ffffffffc02013d4:	a6850513          	addi	a0,a0,-1432 # ffffffffc0204e38 <etext+0x8f6>
ffffffffc02013d8:	f89fe0ef          	jal	ffffffffc0200360 <__panic>
    assert(n > 0);
ffffffffc02013dc:	00004697          	auipc	a3,0x4
ffffffffc02013e0:	d9c68693          	addi	a3,a3,-612 # ffffffffc0205178 <etext+0xc36>
ffffffffc02013e4:	00004617          	auipc	a2,0x4
ffffffffc02013e8:	a3c60613          	addi	a2,a2,-1476 # ffffffffc0204e20 <etext+0x8de>
ffffffffc02013ec:	08000593          	li	a1,128
ffffffffc02013f0:	00004517          	auipc	a0,0x4
ffffffffc02013f4:	a4850513          	addi	a0,a0,-1464 # ffffffffc0204e38 <etext+0x8f6>
ffffffffc02013f8:	f69fe0ef          	jal	ffffffffc0200360 <__panic>

ffffffffc02013fc <default_alloc_pages>:
    assert(n > 0);
ffffffffc02013fc:	c959                	beqz	a0,ffffffffc0201492 <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc02013fe:	00010617          	auipc	a2,0x10
ffffffffc0201402:	c4260613          	addi	a2,a2,-958 # ffffffffc0211040 <free_area>
ffffffffc0201406:	4a0c                	lw	a1,16(a2)
ffffffffc0201408:	86aa                	mv	a3,a0
ffffffffc020140a:	02059793          	slli	a5,a1,0x20
ffffffffc020140e:	9381                	srli	a5,a5,0x20
ffffffffc0201410:	00a7eb63          	bltu	a5,a0,ffffffffc0201426 <default_alloc_pages+0x2a>
    list_entry_t *le = &free_list;
ffffffffc0201414:	87b2                	mv	a5,a2
ffffffffc0201416:	a029                	j	ffffffffc0201420 <default_alloc_pages+0x24>
        if (p->property >= n) {
ffffffffc0201418:	ff87e703          	lwu	a4,-8(a5)
ffffffffc020141c:	00d77763          	bgeu	a4,a3,ffffffffc020142a <default_alloc_pages+0x2e>
    return listelm->next;
ffffffffc0201420:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201422:	fec79be3          	bne	a5,a2,ffffffffc0201418 <default_alloc_pages+0x1c>
        return NULL;
ffffffffc0201426:	4501                	li	a0,0
}
ffffffffc0201428:	8082                	ret
    __list_del(listelm->prev, listelm->next);
ffffffffc020142a:	6798                	ld	a4,8(a5)
    return listelm->prev;
ffffffffc020142c:	0007b803          	ld	a6,0(a5)
        if (page->property > n) {
ffffffffc0201430:	ff87a883          	lw	a7,-8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc0201434:	fe078513          	addi	a0,a5,-32
    prev->next = next;
ffffffffc0201438:	00e83423          	sd	a4,8(a6)
    next->prev = prev;
ffffffffc020143c:	01073023          	sd	a6,0(a4)
        if (page->property > n) {
ffffffffc0201440:	02089713          	slli	a4,a7,0x20
ffffffffc0201444:	9301                	srli	a4,a4,0x20
            p->property = page->property - n;
ffffffffc0201446:	0006831b          	sext.w	t1,a3
        if (page->property > n) {
ffffffffc020144a:	02e6fc63          	bgeu	a3,a4,ffffffffc0201482 <default_alloc_pages+0x86>
            struct Page *p = page + n;
ffffffffc020144e:	00369713          	slli	a4,a3,0x3
ffffffffc0201452:	9736                	add	a4,a4,a3
ffffffffc0201454:	070e                	slli	a4,a4,0x3
ffffffffc0201456:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc0201458:	406888bb          	subw	a7,a7,t1
ffffffffc020145c:	01172c23          	sw	a7,24(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201460:	4689                	li	a3,2
ffffffffc0201462:	00870593          	addi	a1,a4,8
ffffffffc0201466:	40d5b02f          	amoor.d	zero,a3,(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc020146a:	00883683          	ld	a3,8(a6)
            list_add(prev, &(p->page_link));
ffffffffc020146e:	02070893          	addi	a7,a4,32
        nr_free -= n;
ffffffffc0201472:	4a0c                	lw	a1,16(a2)
    prev->next = next->prev = elm;
ffffffffc0201474:	0116b023          	sd	a7,0(a3)
ffffffffc0201478:	01183423          	sd	a7,8(a6)
    elm->next = next;
ffffffffc020147c:	f714                	sd	a3,40(a4)
    elm->prev = prev;
ffffffffc020147e:	03073023          	sd	a6,32(a4)
ffffffffc0201482:	406585bb          	subw	a1,a1,t1
ffffffffc0201486:	ca0c                	sw	a1,16(a2)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201488:	5775                	li	a4,-3
ffffffffc020148a:	17a1                	addi	a5,a5,-24
ffffffffc020148c:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc0201490:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0201492:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0201494:	00004697          	auipc	a3,0x4
ffffffffc0201498:	ce468693          	addi	a3,a3,-796 # ffffffffc0205178 <etext+0xc36>
ffffffffc020149c:	00004617          	auipc	a2,0x4
ffffffffc02014a0:	98460613          	addi	a2,a2,-1660 # ffffffffc0204e20 <etext+0x8de>
ffffffffc02014a4:	06200593          	li	a1,98
ffffffffc02014a8:	00004517          	auipc	a0,0x4
ffffffffc02014ac:	99050513          	addi	a0,a0,-1648 # ffffffffc0204e38 <etext+0x8f6>
default_alloc_pages(size_t n) {
ffffffffc02014b0:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02014b2:	eaffe0ef          	jal	ffffffffc0200360 <__panic>

ffffffffc02014b6 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc02014b6:	1141                	addi	sp,sp,-16
ffffffffc02014b8:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02014ba:	c9e1                	beqz	a1,ffffffffc020158a <default_init_memmap+0xd4>
    for (; p != base + n; p ++) {
ffffffffc02014bc:	00359713          	slli	a4,a1,0x3
ffffffffc02014c0:	972e                	add	a4,a4,a1
ffffffffc02014c2:	070e                	slli	a4,a4,0x3
ffffffffc02014c4:	00e506b3          	add	a3,a0,a4
    struct Page *p = base;
ffffffffc02014c8:	87aa                	mv	a5,a0
    for (; p != base + n; p ++) {
ffffffffc02014ca:	cf11                	beqz	a4,ffffffffc02014e6 <default_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02014cc:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc02014ce:	8b05                	andi	a4,a4,1
ffffffffc02014d0:	cf49                	beqz	a4,ffffffffc020156a <default_init_memmap+0xb4>
        p->flags = p->property = 0;
ffffffffc02014d2:	0007ac23          	sw	zero,24(a5)
ffffffffc02014d6:	0007b423          	sd	zero,8(a5)
ffffffffc02014da:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02014de:	04878793          	addi	a5,a5,72
ffffffffc02014e2:	fed795e3          	bne	a5,a3,ffffffffc02014cc <default_init_memmap+0x16>
    base->property = n;
ffffffffc02014e6:	2581                	sext.w	a1,a1
ffffffffc02014e8:	cd0c                	sw	a1,24(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02014ea:	4789                	li	a5,2
ffffffffc02014ec:	00850713          	addi	a4,a0,8
ffffffffc02014f0:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02014f4:	00010697          	auipc	a3,0x10
ffffffffc02014f8:	b4c68693          	addi	a3,a3,-1204 # ffffffffc0211040 <free_area>
ffffffffc02014fc:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02014fe:	669c                	ld	a5,8(a3)
ffffffffc0201500:	9f2d                	addw	a4,a4,a1
ffffffffc0201502:	ca98                	sw	a4,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0201504:	04d78663          	beq	a5,a3,ffffffffc0201550 <default_init_memmap+0x9a>
            struct Page* page = le2page(le, page_link);
ffffffffc0201508:	fe078713          	addi	a4,a5,-32
ffffffffc020150c:	4581                	li	a1,0
ffffffffc020150e:	02050613          	addi	a2,a0,32
            if (base < page) {
ffffffffc0201512:	00e56a63          	bltu	a0,a4,ffffffffc0201526 <default_init_memmap+0x70>
    return listelm->next;
ffffffffc0201516:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201518:	02d70263          	beq	a4,a3,ffffffffc020153c <default_init_memmap+0x86>
    struct Page *p = base;
ffffffffc020151c:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc020151e:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc0201522:	fee57ae3          	bgeu	a0,a4,ffffffffc0201516 <default_init_memmap+0x60>
ffffffffc0201526:	c199                	beqz	a1,ffffffffc020152c <default_init_memmap+0x76>
ffffffffc0201528:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc020152c:	6398                	ld	a4,0(a5)
}
ffffffffc020152e:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201530:	e390                	sd	a2,0(a5)
ffffffffc0201532:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201534:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0201536:	f118                	sd	a4,32(a0)
ffffffffc0201538:	0141                	addi	sp,sp,16
ffffffffc020153a:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020153c:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020153e:	f514                	sd	a3,40(a0)
    return listelm->next;
ffffffffc0201540:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201542:	f11c                	sd	a5,32(a0)
                list_add(le, &(base->page_link));
ffffffffc0201544:	8832                	mv	a6,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201546:	00d70e63          	beq	a4,a3,ffffffffc0201562 <default_init_memmap+0xac>
ffffffffc020154a:	4585                	li	a1,1
    struct Page *p = base;
ffffffffc020154c:	87ba                	mv	a5,a4
ffffffffc020154e:	bfc1                	j	ffffffffc020151e <default_init_memmap+0x68>
}
ffffffffc0201550:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201552:	02050713          	addi	a4,a0,32
    prev->next = next->prev = elm;
ffffffffc0201556:	e398                	sd	a4,0(a5)
ffffffffc0201558:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc020155a:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc020155c:	f11c                	sd	a5,32(a0)
}
ffffffffc020155e:	0141                	addi	sp,sp,16
ffffffffc0201560:	8082                	ret
ffffffffc0201562:	60a2                	ld	ra,8(sp)
ffffffffc0201564:	e290                	sd	a2,0(a3)
ffffffffc0201566:	0141                	addi	sp,sp,16
ffffffffc0201568:	8082                	ret
        assert(PageReserved(p));
ffffffffc020156a:	00004697          	auipc	a3,0x4
ffffffffc020156e:	c3e68693          	addi	a3,a3,-962 # ffffffffc02051a8 <etext+0xc66>
ffffffffc0201572:	00004617          	auipc	a2,0x4
ffffffffc0201576:	8ae60613          	addi	a2,a2,-1874 # ffffffffc0204e20 <etext+0x8de>
ffffffffc020157a:	04900593          	li	a1,73
ffffffffc020157e:	00004517          	auipc	a0,0x4
ffffffffc0201582:	8ba50513          	addi	a0,a0,-1862 # ffffffffc0204e38 <etext+0x8f6>
ffffffffc0201586:	ddbfe0ef          	jal	ffffffffc0200360 <__panic>
    assert(n > 0);
ffffffffc020158a:	00004697          	auipc	a3,0x4
ffffffffc020158e:	bee68693          	addi	a3,a3,-1042 # ffffffffc0205178 <etext+0xc36>
ffffffffc0201592:	00004617          	auipc	a2,0x4
ffffffffc0201596:	88e60613          	addi	a2,a2,-1906 # ffffffffc0204e20 <etext+0x8de>
ffffffffc020159a:	04600593          	li	a1,70
ffffffffc020159e:	00004517          	auipc	a0,0x4
ffffffffc02015a2:	89a50513          	addi	a0,a0,-1894 # ffffffffc0204e38 <etext+0x8f6>
ffffffffc02015a6:	dbbfe0ef          	jal	ffffffffc0200360 <__panic>

ffffffffc02015aa <pa2page.part.0>:
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc02015aa:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc02015ac:	00004617          	auipc	a2,0x4
ffffffffc02015b0:	c2460613          	addi	a2,a2,-988 # ffffffffc02051d0 <etext+0xc8e>
ffffffffc02015b4:	06500593          	li	a1,101
ffffffffc02015b8:	00004517          	auipc	a0,0x4
ffffffffc02015bc:	c3850513          	addi	a0,a0,-968 # ffffffffc02051f0 <etext+0xcae>
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc02015c0:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc02015c2:	d9ffe0ef          	jal	ffffffffc0200360 <__panic>

ffffffffc02015c6 <pte2page.part.0>:
static inline struct Page *pte2page(pte_t pte) {//从页表项得到对应的页，这里用到了 PTE_ADDR(pte)宏，对页表项做操作，在mmu.h里定义
ffffffffc02015c6:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc02015c8:	00004617          	auipc	a2,0x4
ffffffffc02015cc:	c3860613          	addi	a2,a2,-968 # ffffffffc0205200 <etext+0xcbe>
ffffffffc02015d0:	07000593          	li	a1,112
ffffffffc02015d4:	00004517          	auipc	a0,0x4
ffffffffc02015d8:	c1c50513          	addi	a0,a0,-996 # ffffffffc02051f0 <etext+0xcae>
static inline struct Page *pte2page(pte_t pte) {//从页表项得到对应的页，这里用到了 PTE_ADDR(pte)宏，对页表项做操作，在mmu.h里定义
ffffffffc02015dc:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc02015de:	d83fe0ef          	jal	ffffffffc0200360 <__panic>

ffffffffc02015e2 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc02015e2:	7139                	addi	sp,sp,-64
ffffffffc02015e4:	f426                	sd	s1,40(sp)
ffffffffc02015e6:	f04a                	sd	s2,32(sp)
ffffffffc02015e8:	ec4e                	sd	s3,24(sp)
ffffffffc02015ea:	e852                	sd	s4,16(sp)
ffffffffc02015ec:	e456                	sd	s5,8(sp)
ffffffffc02015ee:	e05a                	sd	s6,0(sp)
ffffffffc02015f0:	fc06                	sd	ra,56(sp)
ffffffffc02015f2:	f822                	sd	s0,48(sp)
ffffffffc02015f4:	84aa                	mv	s1,a0
ffffffffc02015f6:	00010917          	auipc	s2,0x10
ffffffffc02015fa:	f2290913          	addi	s2,s2,-222 # ffffffffc0211518 <pmm_manager>
    while (1) {
        local_intr_save(intr_flag);
        { page = pmm_manager->alloc_pages(n); }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc02015fe:	4a05                	li	s4,1
ffffffffc0201600:	00010a97          	auipc	s5,0x10
ffffffffc0201604:	f48a8a93          	addi	s5,s5,-184 # ffffffffc0211548 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0201608:	0005099b          	sext.w	s3,a0
ffffffffc020160c:	00010b17          	auipc	s6,0x10
ffffffffc0201610:	f64b0b13          	addi	s6,s6,-156 # ffffffffc0211570 <check_mm_struct>
ffffffffc0201614:	a015                	j	ffffffffc0201638 <alloc_pages+0x56>
        { page = pmm_manager->alloc_pages(n); }
ffffffffc0201616:	00093783          	ld	a5,0(s2)
ffffffffc020161a:	6f9c                	ld	a5,24(a5)
ffffffffc020161c:	9782                	jalr	a5
ffffffffc020161e:	842a                	mv	s0,a0
        swap_out(check_mm_struct, n, 0);
ffffffffc0201620:	4601                	li	a2,0
ffffffffc0201622:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201624:	ec05                	bnez	s0,ffffffffc020165c <alloc_pages+0x7a>
ffffffffc0201626:	029a6b63          	bltu	s4,s1,ffffffffc020165c <alloc_pages+0x7a>
ffffffffc020162a:	000aa783          	lw	a5,0(s5)
ffffffffc020162e:	c79d                	beqz	a5,ffffffffc020165c <alloc_pages+0x7a>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201630:	000b3503          	ld	a0,0(s6)
ffffffffc0201634:	233010ef          	jal	ffffffffc0203066 <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201638:	100027f3          	csrr	a5,sstatus
ffffffffc020163c:	8b89                	andi	a5,a5,2
        { page = pmm_manager->alloc_pages(n); }
ffffffffc020163e:	8526                	mv	a0,s1
ffffffffc0201640:	dbf9                	beqz	a5,ffffffffc0201616 <alloc_pages+0x34>
        intr_disable();
ffffffffc0201642:	e9bfe0ef          	jal	ffffffffc02004dc <intr_disable>
ffffffffc0201646:	00093783          	ld	a5,0(s2)
ffffffffc020164a:	8526                	mv	a0,s1
ffffffffc020164c:	6f9c                	ld	a5,24(a5)
ffffffffc020164e:	9782                	jalr	a5
ffffffffc0201650:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201652:	e85fe0ef          	jal	ffffffffc02004d6 <intr_enable>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201656:	4601                	li	a2,0
ffffffffc0201658:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc020165a:	d471                	beqz	s0,ffffffffc0201626 <alloc_pages+0x44>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc020165c:	70e2                	ld	ra,56(sp)
ffffffffc020165e:	8522                	mv	a0,s0
ffffffffc0201660:	7442                	ld	s0,48(sp)
ffffffffc0201662:	74a2                	ld	s1,40(sp)
ffffffffc0201664:	7902                	ld	s2,32(sp)
ffffffffc0201666:	69e2                	ld	s3,24(sp)
ffffffffc0201668:	6a42                	ld	s4,16(sp)
ffffffffc020166a:	6aa2                	ld	s5,8(sp)
ffffffffc020166c:	6b02                	ld	s6,0(sp)
ffffffffc020166e:	6121                	addi	sp,sp,64
ffffffffc0201670:	8082                	ret

ffffffffc0201672 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201672:	100027f3          	csrr	a5,sstatus
ffffffffc0201676:	8b89                	andi	a5,a5,2
ffffffffc0201678:	e799                	bnez	a5,ffffffffc0201686 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;

    local_intr_save(intr_flag);
    { pmm_manager->free_pages(base, n); }
ffffffffc020167a:	00010797          	auipc	a5,0x10
ffffffffc020167e:	e9e7b783          	ld	a5,-354(a5) # ffffffffc0211518 <pmm_manager>
ffffffffc0201682:	739c                	ld	a5,32(a5)
ffffffffc0201684:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0201686:	1101                	addi	sp,sp,-32
ffffffffc0201688:	ec06                	sd	ra,24(sp)
ffffffffc020168a:	e822                	sd	s0,16(sp)
ffffffffc020168c:	e426                	sd	s1,8(sp)
ffffffffc020168e:	842a                	mv	s0,a0
ffffffffc0201690:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201692:	e4bfe0ef          	jal	ffffffffc02004dc <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc0201696:	00010797          	auipc	a5,0x10
ffffffffc020169a:	e827b783          	ld	a5,-382(a5) # ffffffffc0211518 <pmm_manager>
ffffffffc020169e:	739c                	ld	a5,32(a5)
ffffffffc02016a0:	85a6                	mv	a1,s1
ffffffffc02016a2:	8522                	mv	a0,s0
ffffffffc02016a4:	9782                	jalr	a5
    local_intr_restore(intr_flag);
}
ffffffffc02016a6:	6442                	ld	s0,16(sp)
ffffffffc02016a8:	60e2                	ld	ra,24(sp)
ffffffffc02016aa:	64a2                	ld	s1,8(sp)
ffffffffc02016ac:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02016ae:	e29fe06f          	j	ffffffffc02004d6 <intr_enable>

ffffffffc02016b2 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02016b2:	100027f3          	csrr	a5,sstatus
ffffffffc02016b6:	8b89                	andi	a5,a5,2
ffffffffc02016b8:	e799                	bnez	a5,ffffffffc02016c6 <nr_free_pages+0x14>
// of current free memory
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02016ba:	00010797          	auipc	a5,0x10
ffffffffc02016be:	e5e7b783          	ld	a5,-418(a5) # ffffffffc0211518 <pmm_manager>
ffffffffc02016c2:	779c                	ld	a5,40(a5)
ffffffffc02016c4:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc02016c6:	1141                	addi	sp,sp,-16
ffffffffc02016c8:	e406                	sd	ra,8(sp)
ffffffffc02016ca:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc02016cc:	e11fe0ef          	jal	ffffffffc02004dc <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02016d0:	00010797          	auipc	a5,0x10
ffffffffc02016d4:	e487b783          	ld	a5,-440(a5) # ffffffffc0211518 <pmm_manager>
ffffffffc02016d8:	779c                	ld	a5,40(a5)
ffffffffc02016da:	9782                	jalr	a5
ffffffffc02016dc:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02016de:	df9fe0ef          	jal	ffffffffc02004d6 <intr_enable>
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc02016e2:	60a2                	ld	ra,8(sp)
ffffffffc02016e4:	8522                	mv	a0,s0
ffffffffc02016e6:	6402                	ld	s0,0(sp)
ffffffffc02016e8:	0141                	addi	sp,sp,16
ffffffffc02016ea:	8082                	ret

ffffffffc02016ec <get_pte>:
     *   PTE_W           0x002                   // page table/directory entry
     * flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry
     * flags bit : User can access
     */
    pde_t *pdep1 = &pgdir[PDX1(la)];//找到对应的Giga Page
ffffffffc02016ec:	01e5d793          	srli	a5,a1,0x1e
ffffffffc02016f0:	1ff7f793          	andi	a5,a5,511
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02016f4:	715d                	addi	sp,sp,-80
    pde_t *pdep1 = &pgdir[PDX1(la)];//找到对应的Giga Page
ffffffffc02016f6:	078e                	slli	a5,a5,0x3
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02016f8:	f052                	sd	s4,32(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];//找到对应的Giga Page
ffffffffc02016fa:	00f50a33          	add	s4,a0,a5
    if (!(*pdep1 & PTE_V)) {//如果下一级页表不存在，那就给它分配一页，创造新页表
ffffffffc02016fe:	000a3683          	ld	a3,0(s4)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201702:	f84a                	sd	s2,48(sp)
ffffffffc0201704:	f44e                	sd	s3,40(sp)
ffffffffc0201706:	ec56                	sd	s5,24(sp)
ffffffffc0201708:	e486                	sd	ra,72(sp)
ffffffffc020170a:	e0a2                	sd	s0,64(sp)
ffffffffc020170c:	e85a                	sd	s6,16(sp)
    if (!(*pdep1 & PTE_V)) {//如果下一级页表不存在，那就给它分配一页，创造新页表
ffffffffc020170e:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201712:	892e                	mv	s2,a1
ffffffffc0201714:	8ab2                	mv	s5,a2
ffffffffc0201716:	00010997          	auipc	s3,0x10
ffffffffc020171a:	e2298993          	addi	s3,s3,-478 # ffffffffc0211538 <npage>
    if (!(*pdep1 & PTE_V)) {//如果下一级页表不存在，那就给它分配一页，创造新页表
ffffffffc020171e:	efc1                	bnez	a5,ffffffffc02017b6 <get_pte+0xca>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201720:	18060663          	beqz	a2,ffffffffc02018ac <get_pte+0x1c0>
ffffffffc0201724:	4505                	li	a0,1
ffffffffc0201726:	ebdff0ef          	jal	ffffffffc02015e2 <alloc_pages>
ffffffffc020172a:	842a                	mv	s0,a0
ffffffffc020172c:	18050063          	beqz	a0,ffffffffc02018ac <get_pte+0x1c0>
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201730:	fc26                	sd	s1,56(sp)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201732:	f8e394b7          	lui	s1,0xf8e39
ffffffffc0201736:	e3948493          	addi	s1,s1,-455 # fffffffff8e38e39 <end+0x38c278c1>
ffffffffc020173a:	e45e                	sd	s7,8(sp)
ffffffffc020173c:	04b2                	slli	s1,s1,0xc
ffffffffc020173e:	00010b97          	auipc	s7,0x10
ffffffffc0201742:	e02b8b93          	addi	s7,s7,-510 # ffffffffc0211540 <pages>
ffffffffc0201746:	000bb503          	ld	a0,0(s7)
ffffffffc020174a:	e3948493          	addi	s1,s1,-455
ffffffffc020174e:	04b2                	slli	s1,s1,0xc
ffffffffc0201750:	e3948493          	addi	s1,s1,-455
ffffffffc0201754:	40a40533          	sub	a0,s0,a0
ffffffffc0201758:	04b2                	slli	s1,s1,0xc
ffffffffc020175a:	850d                	srai	a0,a0,0x3
ffffffffc020175c:	e3948493          	addi	s1,s1,-455
ffffffffc0201760:	02950533          	mul	a0,a0,s1
ffffffffc0201764:	00080b37          	lui	s6,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201768:	00010997          	auipc	s3,0x10
ffffffffc020176c:	dd098993          	addi	s3,s3,-560 # ffffffffc0211538 <npage>
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201770:	4785                	li	a5,1
ffffffffc0201772:	0009b703          	ld	a4,0(s3)
ffffffffc0201776:	c01c                	sw	a5,0(s0)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201778:	955a                	add	a0,a0,s6
ffffffffc020177a:	00c51793          	slli	a5,a0,0xc
ffffffffc020177e:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201780:	0532                	slli	a0,a0,0xc
ffffffffc0201782:	16e7ff63          	bgeu	a5,a4,ffffffffc0201900 <get_pte+0x214>
ffffffffc0201786:	00010797          	auipc	a5,0x10
ffffffffc020178a:	daa7b783          	ld	a5,-598(a5) # ffffffffc0211530 <va_pa_offset>
ffffffffc020178e:	953e                	add	a0,a0,a5
ffffffffc0201790:	6605                	lui	a2,0x1
ffffffffc0201792:	4581                	li	a1,0
ffffffffc0201794:	585020ef          	jal	ffffffffc0204518 <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201798:	000bb783          	ld	a5,0(s7)
        //我们现在在虚拟地址空间中，所以要转化为KADDR再memset.
        //不管页表怎么构造，我们确保物理地址和虚拟地址的偏移量始终相同，那么就可以用这种方式完成对物理内存的访问。
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);//注意这里R,W,X全零
ffffffffc020179c:	6ba2                	ld	s7,8(sp)
ffffffffc020179e:	40f406b3          	sub	a3,s0,a5
ffffffffc02017a2:	868d                	srai	a3,a3,0x3
ffffffffc02017a4:	029686b3          	mul	a3,a3,s1
ffffffffc02017a8:	74e2                	ld	s1,56(sp)
ffffffffc02017aa:	96da                	add	a3,a3,s6

static inline void flush_tlb() { asm volatile("sfence.vma"); }

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02017ac:	06aa                	slli	a3,a3,0xa
ffffffffc02017ae:	0116e693          	ori	a3,a3,17
ffffffffc02017b2:	00da3023          	sd	a3,0(s4)
    }
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];//再下一级页表
ffffffffc02017b6:	77fd                	lui	a5,0xfffff
ffffffffc02017b8:	068a                	slli	a3,a3,0x2
ffffffffc02017ba:	0009b703          	ld	a4,0(s3)
ffffffffc02017be:	8efd                	and	a3,a3,a5
ffffffffc02017c0:	00c6d793          	srli	a5,a3,0xc
ffffffffc02017c4:	0ee7f663          	bgeu	a5,a4,ffffffffc02018b0 <get_pte+0x1c4>
ffffffffc02017c8:	00010b17          	auipc	s6,0x10
ffffffffc02017cc:	d68b0b13          	addi	s6,s6,-664 # ffffffffc0211530 <va_pa_offset>
ffffffffc02017d0:	000b3603          	ld	a2,0(s6)
ffffffffc02017d4:	01595793          	srli	a5,s2,0x15
ffffffffc02017d8:	1ff7f793          	andi	a5,a5,511
ffffffffc02017dc:	96b2                	add	a3,a3,a2
ffffffffc02017de:	078e                	slli	a5,a5,0x3
ffffffffc02017e0:	00f68433          	add	s0,a3,a5
//    pde_t *pdep0 = &((pde_t *)(PDE_ADDR(*pdep1)))[PDX0(la)];
    if (!(*pdep0 & PTE_V)) {//这里的逻辑和前面完全一致，页表不存在就现在分配一个
ffffffffc02017e4:	6014                	ld	a3,0(s0)
ffffffffc02017e6:	0016f793          	andi	a5,a3,1
ffffffffc02017ea:	e7d1                	bnez	a5,ffffffffc0201876 <get_pte+0x18a>
    	struct Page *page;
    	if (!create || (page = alloc_page()) == NULL) {
ffffffffc02017ec:	0c0a8063          	beqz	s5,ffffffffc02018ac <get_pte+0x1c0>
ffffffffc02017f0:	4505                	li	a0,1
ffffffffc02017f2:	fc26                	sd	s1,56(sp)
ffffffffc02017f4:	defff0ef          	jal	ffffffffc02015e2 <alloc_pages>
ffffffffc02017f8:	84aa                	mv	s1,a0
ffffffffc02017fa:	c945                	beqz	a0,ffffffffc02018aa <get_pte+0x1be>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02017fc:	f8e39a37          	lui	s4,0xf8e39
ffffffffc0201800:	e39a0a13          	addi	s4,s4,-455 # fffffffff8e38e39 <end+0x38c278c1>
ffffffffc0201804:	e45e                	sd	s7,8(sp)
ffffffffc0201806:	0a32                	slli	s4,s4,0xc
ffffffffc0201808:	00010b97          	auipc	s7,0x10
ffffffffc020180c:	d38b8b93          	addi	s7,s7,-712 # ffffffffc0211540 <pages>
ffffffffc0201810:	000bb683          	ld	a3,0(s7)
ffffffffc0201814:	e39a0a13          	addi	s4,s4,-455
ffffffffc0201818:	0a32                	slli	s4,s4,0xc
ffffffffc020181a:	e39a0a13          	addi	s4,s4,-455
ffffffffc020181e:	40d506b3          	sub	a3,a0,a3
ffffffffc0201822:	0a32                	slli	s4,s4,0xc
ffffffffc0201824:	868d                	srai	a3,a3,0x3
ffffffffc0201826:	e39a0a13          	addi	s4,s4,-455
ffffffffc020182a:	034686b3          	mul	a3,a3,s4
ffffffffc020182e:	00080ab7          	lui	s5,0x80
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201832:	4785                	li	a5,1
    		return NULL;
    	}
    	set_page_ref(page, 1);
    	uintptr_t pa = page2pa(page);
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201834:	0009b703          	ld	a4,0(s3)
ffffffffc0201838:	c11c                	sw	a5,0(a0)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020183a:	96d6                	add	a3,a3,s5
ffffffffc020183c:	00c69793          	slli	a5,a3,0xc
ffffffffc0201840:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201842:	06b2                	slli	a3,a3,0xc
ffffffffc0201844:	0ae7f263          	bgeu	a5,a4,ffffffffc02018e8 <get_pte+0x1fc>
ffffffffc0201848:	000b3503          	ld	a0,0(s6)
ffffffffc020184c:	6605                	lui	a2,0x1
ffffffffc020184e:	4581                	li	a1,0
ffffffffc0201850:	9536                	add	a0,a0,a3
ffffffffc0201852:	4c7020ef          	jal	ffffffffc0204518 <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201856:	000bb783          	ld	a5,0(s7)
 //   	memset(pa, 0, PGSIZE);
    	*pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];//找到输入的虚拟地址la对应的页表项的地址(可能是刚刚分配的)
ffffffffc020185a:	6ba2                	ld	s7,8(sp)
ffffffffc020185c:	40f486b3          	sub	a3,s1,a5
ffffffffc0201860:	868d                	srai	a3,a3,0x3
ffffffffc0201862:	034686b3          	mul	a3,a3,s4
ffffffffc0201866:	74e2                	ld	s1,56(sp)
ffffffffc0201868:	96d6                	add	a3,a3,s5
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc020186a:	06aa                	slli	a3,a3,0xa
ffffffffc020186c:	0116e693          	ori	a3,a3,17
    	*pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201870:	e014                	sd	a3,0(s0)
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];//找到输入的虚拟地址la对应的页表项的地址(可能是刚刚分配的)
ffffffffc0201872:	0009b703          	ld	a4,0(s3)
ffffffffc0201876:	77fd                	lui	a5,0xfffff
ffffffffc0201878:	068a                	slli	a3,a3,0x2
ffffffffc020187a:	8efd                	and	a3,a3,a5
ffffffffc020187c:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201880:	04e7f663          	bgeu	a5,a4,ffffffffc02018cc <get_pte+0x1e0>
ffffffffc0201884:	000b3783          	ld	a5,0(s6)
ffffffffc0201888:	00c95913          	srli	s2,s2,0xc
ffffffffc020188c:	1ff97913          	andi	s2,s2,511
ffffffffc0201890:	96be                	add	a3,a3,a5
ffffffffc0201892:	090e                	slli	s2,s2,0x3
ffffffffc0201894:	01268533          	add	a0,a3,s2
}
ffffffffc0201898:	60a6                	ld	ra,72(sp)
ffffffffc020189a:	6406                	ld	s0,64(sp)
ffffffffc020189c:	7942                	ld	s2,48(sp)
ffffffffc020189e:	79a2                	ld	s3,40(sp)
ffffffffc02018a0:	7a02                	ld	s4,32(sp)
ffffffffc02018a2:	6ae2                	ld	s5,24(sp)
ffffffffc02018a4:	6b42                	ld	s6,16(sp)
ffffffffc02018a6:	6161                	addi	sp,sp,80
ffffffffc02018a8:	8082                	ret
ffffffffc02018aa:	74e2                	ld	s1,56(sp)
            return NULL;
ffffffffc02018ac:	4501                	li	a0,0
ffffffffc02018ae:	b7ed                	j	ffffffffc0201898 <get_pte+0x1ac>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];//再下一级页表
ffffffffc02018b0:	00004617          	auipc	a2,0x4
ffffffffc02018b4:	97860613          	addi	a2,a2,-1672 # ffffffffc0205228 <etext+0xce6>
ffffffffc02018b8:	10400593          	li	a1,260
ffffffffc02018bc:	00004517          	auipc	a0,0x4
ffffffffc02018c0:	99450513          	addi	a0,a0,-1644 # ffffffffc0205250 <etext+0xd0e>
ffffffffc02018c4:	fc26                	sd	s1,56(sp)
ffffffffc02018c6:	e45e                	sd	s7,8(sp)
ffffffffc02018c8:	a99fe0ef          	jal	ffffffffc0200360 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];//找到输入的虚拟地址la对应的页表项的地址(可能是刚刚分配的)
ffffffffc02018cc:	00004617          	auipc	a2,0x4
ffffffffc02018d0:	95c60613          	addi	a2,a2,-1700 # ffffffffc0205228 <etext+0xce6>
ffffffffc02018d4:	11100593          	li	a1,273
ffffffffc02018d8:	00004517          	auipc	a0,0x4
ffffffffc02018dc:	97850513          	addi	a0,a0,-1672 # ffffffffc0205250 <etext+0xd0e>
ffffffffc02018e0:	fc26                	sd	s1,56(sp)
ffffffffc02018e2:	e45e                	sd	s7,8(sp)
ffffffffc02018e4:	a7dfe0ef          	jal	ffffffffc0200360 <__panic>
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc02018e8:	00004617          	auipc	a2,0x4
ffffffffc02018ec:	94060613          	addi	a2,a2,-1728 # ffffffffc0205228 <etext+0xce6>
ffffffffc02018f0:	10d00593          	li	a1,269
ffffffffc02018f4:	00004517          	auipc	a0,0x4
ffffffffc02018f8:	95c50513          	addi	a0,a0,-1700 # ffffffffc0205250 <etext+0xd0e>
ffffffffc02018fc:	a65fe0ef          	jal	ffffffffc0200360 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201900:	86aa                	mv	a3,a0
ffffffffc0201902:	00004617          	auipc	a2,0x4
ffffffffc0201906:	92660613          	addi	a2,a2,-1754 # ffffffffc0205228 <etext+0xce6>
ffffffffc020190a:	0ff00593          	li	a1,255
ffffffffc020190e:	00004517          	auipc	a0,0x4
ffffffffc0201912:	94250513          	addi	a0,a0,-1726 # ffffffffc0205250 <etext+0xd0e>
ffffffffc0201916:	a4bfe0ef          	jal	ffffffffc0200360 <__panic>

ffffffffc020191a <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc020191a:	1141                	addi	sp,sp,-16
ffffffffc020191c:	e022                	sd	s0,0(sp)
ffffffffc020191e:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201920:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201922:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201924:	dc9ff0ef          	jal	ffffffffc02016ec <get_pte>
    if (ptep_store != NULL) {
ffffffffc0201928:	c011                	beqz	s0,ffffffffc020192c <get_page+0x12>
        *ptep_store = ptep;
ffffffffc020192a:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc020192c:	c511                	beqz	a0,ffffffffc0201938 <get_page+0x1e>
ffffffffc020192e:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0201930:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201932:	0017f713          	andi	a4,a5,1
ffffffffc0201936:	e709                	bnez	a4,ffffffffc0201940 <get_page+0x26>
}
ffffffffc0201938:	60a2                	ld	ra,8(sp)
ffffffffc020193a:	6402                	ld	s0,0(sp)
ffffffffc020193c:	0141                	addi	sp,sp,16
ffffffffc020193e:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0201940:	078a                	slli	a5,a5,0x2
ffffffffc0201942:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201944:	00010717          	auipc	a4,0x10
ffffffffc0201948:	bf473703          	ld	a4,-1036(a4) # ffffffffc0211538 <npage>
ffffffffc020194c:	02e7f263          	bgeu	a5,a4,ffffffffc0201970 <get_page+0x56>
    return &pages[PPN(pa) - nbase];
ffffffffc0201950:	fff80737          	lui	a4,0xfff80
ffffffffc0201954:	97ba                	add	a5,a5,a4
ffffffffc0201956:	60a2                	ld	ra,8(sp)
ffffffffc0201958:	6402                	ld	s0,0(sp)
ffffffffc020195a:	00379713          	slli	a4,a5,0x3
ffffffffc020195e:	97ba                	add	a5,a5,a4
ffffffffc0201960:	00010517          	auipc	a0,0x10
ffffffffc0201964:	be053503          	ld	a0,-1056(a0) # ffffffffc0211540 <pages>
ffffffffc0201968:	078e                	slli	a5,a5,0x3
ffffffffc020196a:	953e                	add	a0,a0,a5
ffffffffc020196c:	0141                	addi	sp,sp,16
ffffffffc020196e:	8082                	ret
ffffffffc0201970:	c3bff0ef          	jal	ffffffffc02015aa <pa2page.part.0>

ffffffffc0201974 <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201974:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);// 获取与线性地址 la 对应的页表项（PTE）
ffffffffc0201976:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201978:	ec06                	sd	ra,24(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);// 获取与线性地址 la 对应的页表项（PTE）
ffffffffc020197a:	d73ff0ef          	jal	ffffffffc02016ec <get_pte>
    if (ptep != NULL) {// 如果找到了对应的页表项
ffffffffc020197e:	c901                	beqz	a0,ffffffffc020198e <page_remove+0x1a>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is检查此页表项是否有效
ffffffffc0201980:	611c                	ld	a5,0(a0)
ffffffffc0201982:	e822                	sd	s0,16(sp)
ffffffffc0201984:	842a                	mv	s0,a0
ffffffffc0201986:	0017f713          	andi	a4,a5,1
ffffffffc020198a:	e709                	bnez	a4,ffffffffc0201994 <page_remove+0x20>
ffffffffc020198c:	6442                	ld	s0,16(sp)
        page_remove_pte(pgdir, la, ptep);// 调用 page_remove_pte 来取消映射
    }
}
ffffffffc020198e:	60e2                	ld	ra,24(sp)
ffffffffc0201990:	6105                	addi	sp,sp,32
ffffffffc0201992:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0201994:	078a                	slli	a5,a5,0x2
ffffffffc0201996:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201998:	00010717          	auipc	a4,0x10
ffffffffc020199c:	ba073703          	ld	a4,-1120(a4) # ffffffffc0211538 <npage>
ffffffffc02019a0:	06e7f563          	bgeu	a5,a4,ffffffffc0201a0a <page_remove+0x96>
    return &pages[PPN(pa) - nbase];
ffffffffc02019a4:	fff80737          	lui	a4,0xfff80
ffffffffc02019a8:	97ba                	add	a5,a5,a4
ffffffffc02019aa:	00379713          	slli	a4,a5,0x3
ffffffffc02019ae:	97ba                	add	a5,a5,a4
ffffffffc02019b0:	078e                	slli	a5,a5,0x3
ffffffffc02019b2:	00010517          	auipc	a0,0x10
ffffffffc02019b6:	b8e53503          	ld	a0,-1138(a0) # ffffffffc0211540 <pages>
ffffffffc02019ba:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc02019bc:	411c                	lw	a5,0(a0)
ffffffffc02019be:	fff7871b          	addiw	a4,a5,-1 # ffffffffffffefff <end+0x3fdeda87>
ffffffffc02019c2:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc02019c4:	cb09                	beqz	a4,ffffffffc02019d6 <page_remove+0x62>
        *ptep = 0;                  //(5) clear second page table entry清除页表项
ffffffffc02019c6:	00043023          	sd	zero,0(s0)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc02019ca:	12000073          	sfence.vma
ffffffffc02019ce:	6442                	ld	s0,16(sp)
}
ffffffffc02019d0:	60e2                	ld	ra,24(sp)
ffffffffc02019d2:	6105                	addi	sp,sp,32
ffffffffc02019d4:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02019d6:	100027f3          	csrr	a5,sstatus
ffffffffc02019da:	8b89                	andi	a5,a5,2
ffffffffc02019dc:	eb89                	bnez	a5,ffffffffc02019ee <page_remove+0x7a>
    { pmm_manager->free_pages(base, n); }
ffffffffc02019de:	00010797          	auipc	a5,0x10
ffffffffc02019e2:	b3a7b783          	ld	a5,-1222(a5) # ffffffffc0211518 <pmm_manager>
ffffffffc02019e6:	739c                	ld	a5,32(a5)
ffffffffc02019e8:	4585                	li	a1,1
ffffffffc02019ea:	9782                	jalr	a5
    if (flag) {
ffffffffc02019ec:	bfe9                	j	ffffffffc02019c6 <page_remove+0x52>
        intr_disable();
ffffffffc02019ee:	e42a                	sd	a0,8(sp)
ffffffffc02019f0:	aedfe0ef          	jal	ffffffffc02004dc <intr_disable>
ffffffffc02019f4:	00010797          	auipc	a5,0x10
ffffffffc02019f8:	b247b783          	ld	a5,-1244(a5) # ffffffffc0211518 <pmm_manager>
ffffffffc02019fc:	739c                	ld	a5,32(a5)
ffffffffc02019fe:	6522                	ld	a0,8(sp)
ffffffffc0201a00:	4585                	li	a1,1
ffffffffc0201a02:	9782                	jalr	a5
        intr_enable();
ffffffffc0201a04:	ad3fe0ef          	jal	ffffffffc02004d6 <intr_enable>
ffffffffc0201a08:	bf7d                	j	ffffffffc02019c6 <page_remove+0x52>
ffffffffc0201a0a:	ba1ff0ef          	jal	ffffffffc02015aa <pa2page.part.0>

ffffffffc0201a0e <page_insert>:
//  page:  the Page which need to map需要映射的物理页面
//  la:    the linear address need to map需要映射到的线性地址
//  perm:  the permission of this Page which is setted in related pte设置给页面的权限，将在对应的页表项（PTE）中设定
// return value: always 0
// note: PT is changed, so the TLB need to be invalidate
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201a0e:	7179                	addi	sp,sp,-48
ffffffffc0201a10:	87b2                	mv	a5,a2
ffffffffc0201a12:	f022                	sd	s0,32(sp)
    //pgdir是页表基址(satp)，page对应物理页面，la是虚拟地址
    pte_t *ptep = get_pte(pgdir, la, 1);//先找到对应页表项的位置，如果原先不存在，get_pte()会分配页表项的内存
ffffffffc0201a14:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201a16:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);//先找到对应页表项的位置，如果原先不存在，get_pte()会分配页表项的内存
ffffffffc0201a18:	85be                	mv	a1,a5
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201a1a:	ec26                	sd	s1,24(sp)
ffffffffc0201a1c:	f406                	sd	ra,40(sp)
ffffffffc0201a1e:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);//先找到对应页表项的位置，如果原先不存在，get_pte()会分配页表项的内存
ffffffffc0201a20:	ccdff0ef          	jal	ffffffffc02016ec <get_pte>
    if (ptep == NULL) {
ffffffffc0201a24:	c975                	beqz	a0,ffffffffc0201b18 <page_insert+0x10a>
    page->ref += 1;
ffffffffc0201a26:	4014                	lw	a3,0(s0)
        return -E_NO_MEM;
    }
    page_ref_inc(page);//指向这个物理页面的虚拟地址增加了一个
    if (*ptep & PTE_V) {//原先存在映射
ffffffffc0201a28:	611c                	ld	a5,0(a0)
ffffffffc0201a2a:	e44e                	sd	s3,8(sp)
ffffffffc0201a2c:	0016871b          	addiw	a4,a3,1
ffffffffc0201a30:	c018                	sw	a4,0(s0)
ffffffffc0201a32:	0017f713          	andi	a4,a5,1
ffffffffc0201a36:	89aa                	mv	s3,a0
ffffffffc0201a38:	eb21                	bnez	a4,ffffffffc0201a88 <page_insert+0x7a>
    return &pages[PPN(pa) - nbase];
ffffffffc0201a3a:	00010717          	auipc	a4,0x10
ffffffffc0201a3e:	b0673703          	ld	a4,-1274(a4) # ffffffffc0211540 <pages>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201a42:	f8e397b7          	lui	a5,0xf8e39
ffffffffc0201a46:	e3978793          	addi	a5,a5,-455 # fffffffff8e38e39 <end+0x38c278c1>
ffffffffc0201a4a:	07b2                	slli	a5,a5,0xc
ffffffffc0201a4c:	e3978793          	addi	a5,a5,-455
ffffffffc0201a50:	07b2                	slli	a5,a5,0xc
ffffffffc0201a52:	e3978793          	addi	a5,a5,-455
ffffffffc0201a56:	8c19                	sub	s0,s0,a4
ffffffffc0201a58:	07b2                	slli	a5,a5,0xc
ffffffffc0201a5a:	840d                	srai	s0,s0,0x3
ffffffffc0201a5c:	e3978793          	addi	a5,a5,-455
ffffffffc0201a60:	02f407b3          	mul	a5,s0,a5
ffffffffc0201a64:	00080737          	lui	a4,0x80
ffffffffc0201a68:	97ba                	add	a5,a5,a4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201a6a:	07aa                	slli	a5,a5,0xa
ffffffffc0201a6c:	8cdd                	or	s1,s1,a5
ffffffffc0201a6e:	0014e493          	ori	s1,s1,1
            page_ref_dec(page);// 减少之前增加的引用计数（因为不需要额外的引用）
        } else {
            page_remove_pte(pgdir, la, ptep);//如果原先这个虚拟地址映射到其他物理页面，那么需要删除映射
        }
    }
    *ptep = pte_create(page2ppn(page), PTE_V | perm);// 创建新的页表项，将其指向物理页面，并设置有效位和权限
ffffffffc0201a72:	0099b023          	sd	s1,0(s3)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201a76:	12000073          	sfence.vma
    tlb_invalidate(pgdir, la);// 使 TLB 中对应线性地址的条目失效，确保 CPU 使用最新的映射关系
    return 0;
ffffffffc0201a7a:	69a2                	ld	s3,8(sp)
ffffffffc0201a7c:	4501                	li	a0,0
}
ffffffffc0201a7e:	70a2                	ld	ra,40(sp)
ffffffffc0201a80:	7402                	ld	s0,32(sp)
ffffffffc0201a82:	64e2                	ld	s1,24(sp)
ffffffffc0201a84:	6145                	addi	sp,sp,48
ffffffffc0201a86:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0201a88:	078a                	slli	a5,a5,0x2
ffffffffc0201a8a:	e84a                	sd	s2,16(sp)
ffffffffc0201a8c:	e052                	sd	s4,0(sp)
ffffffffc0201a8e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201a90:	00010717          	auipc	a4,0x10
ffffffffc0201a94:	aa873703          	ld	a4,-1368(a4) # ffffffffc0211538 <npage>
ffffffffc0201a98:	08e7f263          	bgeu	a5,a4,ffffffffc0201b1c <page_insert+0x10e>
    return &pages[PPN(pa) - nbase];
ffffffffc0201a9c:	fff80737          	lui	a4,0xfff80
ffffffffc0201aa0:	97ba                	add	a5,a5,a4
ffffffffc0201aa2:	00010a17          	auipc	s4,0x10
ffffffffc0201aa6:	a9ea0a13          	addi	s4,s4,-1378 # ffffffffc0211540 <pages>
ffffffffc0201aaa:	000a3703          	ld	a4,0(s4)
ffffffffc0201aae:	00379913          	slli	s2,a5,0x3
ffffffffc0201ab2:	993e                	add	s2,s2,a5
ffffffffc0201ab4:	090e                	slli	s2,s2,0x3
ffffffffc0201ab6:	993a                	add	s2,s2,a4
        if (p == page) {//如果这个映射原先就有
ffffffffc0201ab8:	03240263          	beq	s0,s2,ffffffffc0201adc <page_insert+0xce>
    page->ref -= 1;
ffffffffc0201abc:	00092783          	lw	a5,0(s2)
ffffffffc0201ac0:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201ac4:	00e92023          	sw	a4,0(s2)
        if (page_ref(page) ==
ffffffffc0201ac8:	cf11                	beqz	a4,ffffffffc0201ae4 <page_insert+0xd6>
        *ptep = 0;                  //(5) clear second page table entry清除页表项
ffffffffc0201aca:	0009b023          	sd	zero,0(s3)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201ace:	12000073          	sfence.vma
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201ad2:	000a3703          	ld	a4,0(s4)
ffffffffc0201ad6:	6942                	ld	s2,16(sp)
ffffffffc0201ad8:	6a02                	ld	s4,0(sp)
}
ffffffffc0201ada:	b7a5                	j	ffffffffc0201a42 <page_insert+0x34>
    return page->ref;
ffffffffc0201adc:	6942                	ld	s2,16(sp)
ffffffffc0201ade:	6a02                	ld	s4,0(sp)
    page->ref -= 1;
ffffffffc0201ae0:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0201ae2:	b785                	j	ffffffffc0201a42 <page_insert+0x34>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201ae4:	100027f3          	csrr	a5,sstatus
ffffffffc0201ae8:	8b89                	andi	a5,a5,2
ffffffffc0201aea:	eb91                	bnez	a5,ffffffffc0201afe <page_insert+0xf0>
    { pmm_manager->free_pages(base, n); }
ffffffffc0201aec:	00010797          	auipc	a5,0x10
ffffffffc0201af0:	a2c7b783          	ld	a5,-1492(a5) # ffffffffc0211518 <pmm_manager>
ffffffffc0201af4:	739c                	ld	a5,32(a5)
ffffffffc0201af6:	4585                	li	a1,1
ffffffffc0201af8:	854a                	mv	a0,s2
ffffffffc0201afa:	9782                	jalr	a5
    if (flag) {
ffffffffc0201afc:	b7f9                	j	ffffffffc0201aca <page_insert+0xbc>
        intr_disable();
ffffffffc0201afe:	9dffe0ef          	jal	ffffffffc02004dc <intr_disable>
ffffffffc0201b02:	00010797          	auipc	a5,0x10
ffffffffc0201b06:	a167b783          	ld	a5,-1514(a5) # ffffffffc0211518 <pmm_manager>
ffffffffc0201b0a:	739c                	ld	a5,32(a5)
ffffffffc0201b0c:	4585                	li	a1,1
ffffffffc0201b0e:	854a                	mv	a0,s2
ffffffffc0201b10:	9782                	jalr	a5
        intr_enable();
ffffffffc0201b12:	9c5fe0ef          	jal	ffffffffc02004d6 <intr_enable>
ffffffffc0201b16:	bf55                	j	ffffffffc0201aca <page_insert+0xbc>
        return -E_NO_MEM;
ffffffffc0201b18:	5571                	li	a0,-4
ffffffffc0201b1a:	b795                	j	ffffffffc0201a7e <page_insert+0x70>
ffffffffc0201b1c:	a8fff0ef          	jal	ffffffffc02015aa <pa2page.part.0>

ffffffffc0201b20 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0201b20:	00004797          	auipc	a5,0x4
ffffffffc0201b24:	68078793          	addi	a5,a5,1664 # ffffffffc02061a0 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201b28:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0201b2a:	7159                	addi	sp,sp,-112
ffffffffc0201b2c:	f486                	sd	ra,104(sp)
ffffffffc0201b2e:	eca6                	sd	s1,88(sp)
ffffffffc0201b30:	e4ce                	sd	s3,72(sp)
ffffffffc0201b32:	f85a                	sd	s6,48(sp)
ffffffffc0201b34:	f45e                	sd	s7,40(sp)
ffffffffc0201b36:	f0a2                	sd	s0,96(sp)
ffffffffc0201b38:	e8ca                	sd	s2,80(sp)
ffffffffc0201b3a:	e0d2                	sd	s4,64(sp)
ffffffffc0201b3c:	fc56                	sd	s5,56(sp)
ffffffffc0201b3e:	f062                	sd	s8,32(sp)
ffffffffc0201b40:	ec66                	sd	s9,24(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201b42:	00010b97          	auipc	s7,0x10
ffffffffc0201b46:	9d6b8b93          	addi	s7,s7,-1578 # ffffffffc0211518 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201b4a:	00003517          	auipc	a0,0x3
ffffffffc0201b4e:	71650513          	addi	a0,a0,1814 # ffffffffc0205260 <etext+0xd1e>
    pmm_manager = &default_pmm_manager;
ffffffffc0201b52:	00fbb023          	sd	a5,0(s7)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201b56:	d64fe0ef          	jal	ffffffffc02000ba <cprintf>
    pmm_manager->init();
ffffffffc0201b5a:	000bb783          	ld	a5,0(s7)
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201b5e:	00010997          	auipc	s3,0x10
ffffffffc0201b62:	9d298993          	addi	s3,s3,-1582 # ffffffffc0211530 <va_pa_offset>
    npage = maxpa / PGSIZE;
ffffffffc0201b66:	00010497          	auipc	s1,0x10
ffffffffc0201b6a:	9d248493          	addi	s1,s1,-1582 # ffffffffc0211538 <npage>
    pmm_manager->init();
ffffffffc0201b6e:	679c                	ld	a5,8(a5)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201b70:	00010b17          	auipc	s6,0x10
ffffffffc0201b74:	9d0b0b13          	addi	s6,s6,-1584 # ffffffffc0211540 <pages>
    pmm_manager->init();
ffffffffc0201b78:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201b7a:	57f5                	li	a5,-3
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201b7c:	4645                	li	a2,17
ffffffffc0201b7e:	40100593          	li	a1,1025
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201b82:	07fa                	slli	a5,a5,0x1e
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201b84:	07e006b7          	lui	a3,0x7e00
ffffffffc0201b88:	066e                	slli	a2,a2,0x1b
ffffffffc0201b8a:	05d6                	slli	a1,a1,0x15
ffffffffc0201b8c:	00003517          	auipc	a0,0x3
ffffffffc0201b90:	6ec50513          	addi	a0,a0,1772 # ffffffffc0205278 <etext+0xd36>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201b94:	00f9b023          	sd	a5,0(s3)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201b98:	d22fe0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("physcial memory map:\n");
ffffffffc0201b9c:	00003517          	auipc	a0,0x3
ffffffffc0201ba0:	70c50513          	addi	a0,a0,1804 # ffffffffc02052a8 <etext+0xd66>
ffffffffc0201ba4:	d16fe0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0201ba8:	46c5                	li	a3,17
ffffffffc0201baa:	06ee                	slli	a3,a3,0x1b
ffffffffc0201bac:	40100613          	li	a2,1025
ffffffffc0201bb0:	16fd                	addi	a3,a3,-1 # 7dfffff <kern_entry-0xffffffffb8400001>
ffffffffc0201bb2:	0656                	slli	a2,a2,0x15
ffffffffc0201bb4:	07e005b7          	lui	a1,0x7e00
ffffffffc0201bb8:	00003517          	auipc	a0,0x3
ffffffffc0201bbc:	70850513          	addi	a0,a0,1800 # ffffffffc02052c0 <etext+0xd7e>
ffffffffc0201bc0:	cfafe0ef          	jal	ffffffffc02000ba <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201bc4:	777d                	lui	a4,0xfffff
ffffffffc0201bc6:	00011797          	auipc	a5,0x11
ffffffffc0201bca:	9b178793          	addi	a5,a5,-1615 # ffffffffc0212577 <end+0xfff>
ffffffffc0201bce:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0201bd0:	00088737          	lui	a4,0x88
ffffffffc0201bd4:	e098                	sd	a4,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201bd6:	00fb3023          	sd	a5,0(s6)
ffffffffc0201bda:	4705                	li	a4,1
ffffffffc0201bdc:	07a1                	addi	a5,a5,8
ffffffffc0201bde:	40e7b02f          	amoor.d	zero,a4,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201be2:	04800693          	li	a3,72
ffffffffc0201be6:	4505                	li	a0,1
ffffffffc0201be8:	fff805b7          	lui	a1,0xfff80
        SetPageReserved(pages + i);
ffffffffc0201bec:	000b3783          	ld	a5,0(s6)
ffffffffc0201bf0:	97b6                	add	a5,a5,a3
ffffffffc0201bf2:	07a1                	addi	a5,a5,8
ffffffffc0201bf4:	40a7b02f          	amoor.d	zero,a0,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201bf8:	609c                	ld	a5,0(s1)
ffffffffc0201bfa:	0705                	addi	a4,a4,1 # 88001 <kern_entry-0xffffffffc0177fff>
ffffffffc0201bfc:	04868693          	addi	a3,a3,72
ffffffffc0201c00:	00b78633          	add	a2,a5,a1
ffffffffc0201c04:	fec764e3          	bltu	a4,a2,ffffffffc0201bec <pmm_init+0xcc>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201c08:	000b3503          	ld	a0,0(s6)
ffffffffc0201c0c:	00379693          	slli	a3,a5,0x3
ffffffffc0201c10:	96be                	add	a3,a3,a5
ffffffffc0201c12:	fdc00737          	lui	a4,0xfdc00
ffffffffc0201c16:	972a                	add	a4,a4,a0
ffffffffc0201c18:	068e                	slli	a3,a3,0x3
ffffffffc0201c1a:	96ba                	add	a3,a3,a4
ffffffffc0201c1c:	c0200737          	lui	a4,0xc0200
ffffffffc0201c20:	68e6e563          	bltu	a3,a4,ffffffffc02022aa <pmm_init+0x78a>
ffffffffc0201c24:	0009b703          	ld	a4,0(s3)
    if (freemem < mem_end) {
ffffffffc0201c28:	4645                	li	a2,17
ffffffffc0201c2a:	066e                	slli	a2,a2,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201c2c:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0201c2e:	50c6e363          	bltu	a3,a2,ffffffffc0202134 <pmm_init+0x614>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201c32:	000bb783          	ld	a5,0(s7)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201c36:	00010917          	auipc	s2,0x10
ffffffffc0201c3a:	8f290913          	addi	s2,s2,-1806 # ffffffffc0211528 <boot_pgdir>
    pmm_manager->check();
ffffffffc0201c3e:	7b9c                	ld	a5,48(a5)
ffffffffc0201c40:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201c42:	00003517          	auipc	a0,0x3
ffffffffc0201c46:	6ce50513          	addi	a0,a0,1742 # ffffffffc0205310 <etext+0xdce>
ffffffffc0201c4a:	c70fe0ef          	jal	ffffffffc02000ba <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201c4e:	00007697          	auipc	a3,0x7
ffffffffc0201c52:	3b268693          	addi	a3,a3,946 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc0201c56:	00d93023          	sd	a3,0(s2)
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0201c5a:	c02007b7          	lui	a5,0xc0200
ffffffffc0201c5e:	22f6eee3          	bltu	a3,a5,ffffffffc020269a <pmm_init+0xb7a>
ffffffffc0201c62:	0009b783          	ld	a5,0(s3)
ffffffffc0201c66:	8e9d                	sub	a3,a3,a5
ffffffffc0201c68:	00010797          	auipc	a5,0x10
ffffffffc0201c6c:	8ad7bc23          	sd	a3,-1864(a5) # ffffffffc0211520 <boot_cr3>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201c70:	100027f3          	csrr	a5,sstatus
ffffffffc0201c74:	8b89                	andi	a5,a5,2
ffffffffc0201c76:	4e079863          	bnez	a5,ffffffffc0202166 <pmm_init+0x646>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0201c7a:	000bb783          	ld	a5,0(s7)
ffffffffc0201c7e:	779c                	ld	a5,40(a5)
ffffffffc0201c80:	9782                	jalr	a5
ffffffffc0201c82:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201c84:	6098                	ld	a4,0(s1)
ffffffffc0201c86:	c80007b7          	lui	a5,0xc8000
ffffffffc0201c8a:	83b1                	srli	a5,a5,0xc
ffffffffc0201c8c:	66e7eb63          	bltu	a5,a4,ffffffffc0202302 <pmm_init+0x7e2>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0201c90:	00093503          	ld	a0,0(s2)
ffffffffc0201c94:	64050763          	beqz	a0,ffffffffc02022e2 <pmm_init+0x7c2>
ffffffffc0201c98:	03451793          	slli	a5,a0,0x34
ffffffffc0201c9c:	64079363          	bnez	a5,ffffffffc02022e2 <pmm_init+0x7c2>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0201ca0:	4601                	li	a2,0
ffffffffc0201ca2:	4581                	li	a1,0
ffffffffc0201ca4:	c77ff0ef          	jal	ffffffffc020191a <get_page>
ffffffffc0201ca8:	6a051f63          	bnez	a0,ffffffffc0202366 <pmm_init+0x846>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0201cac:	4505                	li	a0,1
ffffffffc0201cae:	935ff0ef          	jal	ffffffffc02015e2 <alloc_pages>
ffffffffc0201cb2:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0201cb4:	00093503          	ld	a0,0(s2)
ffffffffc0201cb8:	4681                	li	a3,0
ffffffffc0201cba:	4601                	li	a2,0
ffffffffc0201cbc:	85d2                	mv	a1,s4
ffffffffc0201cbe:	d51ff0ef          	jal	ffffffffc0201a0e <page_insert>
ffffffffc0201cc2:	68051263          	bnez	a0,ffffffffc0202346 <pmm_init+0x826>
    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0201cc6:	00093503          	ld	a0,0(s2)
ffffffffc0201cca:	4601                	li	a2,0
ffffffffc0201ccc:	4581                	li	a1,0
ffffffffc0201cce:	a1fff0ef          	jal	ffffffffc02016ec <get_pte>
ffffffffc0201cd2:	64050a63          	beqz	a0,ffffffffc0202326 <pmm_init+0x806>
    assert(pte2page(*ptep) == p1);
ffffffffc0201cd6:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201cd8:	0017f713          	andi	a4,a5,1
ffffffffc0201cdc:	64070363          	beqz	a4,ffffffffc0202322 <pmm_init+0x802>
    if (PPN(pa) >= npage) {
ffffffffc0201ce0:	6090                	ld	a2,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201ce2:	078a                	slli	a5,a5,0x2
ffffffffc0201ce4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201ce6:	5ac7f063          	bgeu	a5,a2,ffffffffc0202286 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0201cea:	fff80737          	lui	a4,0xfff80
ffffffffc0201cee:	97ba                	add	a5,a5,a4
ffffffffc0201cf0:	000b3683          	ld	a3,0(s6)
ffffffffc0201cf4:	00379713          	slli	a4,a5,0x3
ffffffffc0201cf8:	97ba                	add	a5,a5,a4
ffffffffc0201cfa:	078e                	slli	a5,a5,0x3
ffffffffc0201cfc:	97b6                	add	a5,a5,a3
ffffffffc0201cfe:	58fa1663          	bne	s4,a5,ffffffffc020228a <pmm_init+0x76a>
    assert(page_ref(p1) == 1);
ffffffffc0201d02:	000a2703          	lw	a4,0(s4)
ffffffffc0201d06:	4785                	li	a5,1
ffffffffc0201d08:	1cf711e3          	bne	a4,a5,ffffffffc02026ca <pmm_init+0xbaa>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0201d0c:	00093503          	ld	a0,0(s2)
ffffffffc0201d10:	77fd                	lui	a5,0xfffff
ffffffffc0201d12:	6114                	ld	a3,0(a0)
ffffffffc0201d14:	068a                	slli	a3,a3,0x2
ffffffffc0201d16:	8efd                	and	a3,a3,a5
ffffffffc0201d18:	00c6d713          	srli	a4,a3,0xc
ffffffffc0201d1c:	18c77be3          	bgeu	a4,a2,ffffffffc02026b2 <pmm_init+0xb92>
ffffffffc0201d20:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201d24:	96e2                	add	a3,a3,s8
ffffffffc0201d26:	0006ba83          	ld	s5,0(a3)
ffffffffc0201d2a:	0a8a                	slli	s5,s5,0x2
ffffffffc0201d2c:	00fafab3          	and	s5,s5,a5
ffffffffc0201d30:	00cad793          	srli	a5,s5,0xc
ffffffffc0201d34:	6ac7f963          	bgeu	a5,a2,ffffffffc02023e6 <pmm_init+0x8c6>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201d38:	4601                	li	a2,0
ffffffffc0201d3a:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201d3c:	9c56                	add	s8,s8,s5
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201d3e:	9afff0ef          	jal	ffffffffc02016ec <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201d42:	0c21                	addi	s8,s8,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201d44:	69851163          	bne	a0,s8,ffffffffc02023c6 <pmm_init+0x8a6>

    p2 = alloc_page();
ffffffffc0201d48:	4505                	li	a0,1
ffffffffc0201d4a:	899ff0ef          	jal	ffffffffc02015e2 <alloc_pages>
ffffffffc0201d4e:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0201d50:	00093503          	ld	a0,0(s2)
ffffffffc0201d54:	46d1                	li	a3,20
ffffffffc0201d56:	6605                	lui	a2,0x1
ffffffffc0201d58:	85d6                	mv	a1,s5
ffffffffc0201d5a:	cb5ff0ef          	jal	ffffffffc0201a0e <page_insert>
ffffffffc0201d5e:	64051463          	bnez	a0,ffffffffc02023a6 <pmm_init+0x886>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201d62:	00093503          	ld	a0,0(s2)
ffffffffc0201d66:	4601                	li	a2,0
ffffffffc0201d68:	6585                	lui	a1,0x1
ffffffffc0201d6a:	983ff0ef          	jal	ffffffffc02016ec <get_pte>
ffffffffc0201d6e:	60050c63          	beqz	a0,ffffffffc0202386 <pmm_init+0x866>
    assert(*ptep & PTE_U);
ffffffffc0201d72:	611c                	ld	a5,0(a0)
ffffffffc0201d74:	0107f713          	andi	a4,a5,16
ffffffffc0201d78:	76070463          	beqz	a4,ffffffffc02024e0 <pmm_init+0x9c0>
    assert(*ptep & PTE_W);
ffffffffc0201d7c:	8b91                	andi	a5,a5,4
ffffffffc0201d7e:	74078163          	beqz	a5,ffffffffc02024c0 <pmm_init+0x9a0>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0201d82:	00093503          	ld	a0,0(s2)
ffffffffc0201d86:	611c                	ld	a5,0(a0)
ffffffffc0201d88:	8bc1                	andi	a5,a5,16
ffffffffc0201d8a:	70078b63          	beqz	a5,ffffffffc02024a0 <pmm_init+0x980>
    assert(page_ref(p2) == 1);
ffffffffc0201d8e:	000aa703          	lw	a4,0(s5) # 80000 <kern_entry-0xffffffffc0180000>
ffffffffc0201d92:	4785                	li	a5,1
ffffffffc0201d94:	6ef71663          	bne	a4,a5,ffffffffc0202480 <pmm_init+0x960>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0201d98:	4681                	li	a3,0
ffffffffc0201d9a:	6605                	lui	a2,0x1
ffffffffc0201d9c:	85d2                	mv	a1,s4
ffffffffc0201d9e:	c71ff0ef          	jal	ffffffffc0201a0e <page_insert>
ffffffffc0201da2:	6a051f63          	bnez	a0,ffffffffc0202460 <pmm_init+0x940>
    assert(page_ref(p1) == 2);
ffffffffc0201da6:	000a2703          	lw	a4,0(s4)
ffffffffc0201daa:	4789                	li	a5,2
ffffffffc0201dac:	68f71a63          	bne	a4,a5,ffffffffc0202440 <pmm_init+0x920>
    assert(page_ref(p2) == 0);
ffffffffc0201db0:	000aa783          	lw	a5,0(s5)
ffffffffc0201db4:	66079663          	bnez	a5,ffffffffc0202420 <pmm_init+0x900>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201db8:	00093503          	ld	a0,0(s2)
ffffffffc0201dbc:	4601                	li	a2,0
ffffffffc0201dbe:	6585                	lui	a1,0x1
ffffffffc0201dc0:	92dff0ef          	jal	ffffffffc02016ec <get_pte>
ffffffffc0201dc4:	62050e63          	beqz	a0,ffffffffc0202400 <pmm_init+0x8e0>
    assert(pte2page(*ptep) == p1);
ffffffffc0201dc8:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201dca:	00177793          	andi	a5,a4,1
ffffffffc0201dce:	54078a63          	beqz	a5,ffffffffc0202322 <pmm_init+0x802>
    if (PPN(pa) >= npage) {
ffffffffc0201dd2:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201dd4:	00271793          	slli	a5,a4,0x2
ffffffffc0201dd8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201dda:	4ad7f663          	bgeu	a5,a3,ffffffffc0202286 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0201dde:	fff806b7          	lui	a3,0xfff80
ffffffffc0201de2:	97b6                	add	a5,a5,a3
ffffffffc0201de4:	000b3603          	ld	a2,0(s6)
ffffffffc0201de8:	00379693          	slli	a3,a5,0x3
ffffffffc0201dec:	97b6                	add	a5,a5,a3
ffffffffc0201dee:	078e                	slli	a5,a5,0x3
ffffffffc0201df0:	97b2                	add	a5,a5,a2
ffffffffc0201df2:	76fa1763          	bne	s4,a5,ffffffffc0202560 <pmm_init+0xa40>
    assert((*ptep & PTE_U) == 0);
ffffffffc0201df6:	8b41                	andi	a4,a4,16
ffffffffc0201df8:	74071463          	bnez	a4,ffffffffc0202540 <pmm_init+0xa20>

    page_remove(boot_pgdir, 0x0);
ffffffffc0201dfc:	00093503          	ld	a0,0(s2)
ffffffffc0201e00:	4581                	li	a1,0
ffffffffc0201e02:	b73ff0ef          	jal	ffffffffc0201974 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0201e06:	000a2703          	lw	a4,0(s4)
ffffffffc0201e0a:	4785                	li	a5,1
ffffffffc0201e0c:	70f71a63          	bne	a4,a5,ffffffffc0202520 <pmm_init+0xa00>
    assert(page_ref(p2) == 0);
ffffffffc0201e10:	000aa783          	lw	a5,0(s5)
ffffffffc0201e14:	6e079663          	bnez	a5,ffffffffc0202500 <pmm_init+0x9e0>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc0201e18:	00093503          	ld	a0,0(s2)
ffffffffc0201e1c:	6585                	lui	a1,0x1
ffffffffc0201e1e:	b57ff0ef          	jal	ffffffffc0201974 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0201e22:	000a2783          	lw	a5,0(s4)
ffffffffc0201e26:	7a079a63          	bnez	a5,ffffffffc02025da <pmm_init+0xaba>
    assert(page_ref(p2) == 0);
ffffffffc0201e2a:	000aa783          	lw	a5,0(s5)
ffffffffc0201e2e:	78079663          	bnez	a5,ffffffffc02025ba <pmm_init+0xa9a>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0201e32:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0201e36:	6090                	ld	a2,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e38:	000a3783          	ld	a5,0(s4)
ffffffffc0201e3c:	078a                	slli	a5,a5,0x2
ffffffffc0201e3e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201e40:	44c7f363          	bgeu	a5,a2,ffffffffc0202286 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e44:	fff80737          	lui	a4,0xfff80
ffffffffc0201e48:	97ba                	add	a5,a5,a4
ffffffffc0201e4a:	00379713          	slli	a4,a5,0x3
ffffffffc0201e4e:	000b3503          	ld	a0,0(s6)
ffffffffc0201e52:	973e                	add	a4,a4,a5
ffffffffc0201e54:	070e                	slli	a4,a4,0x3
static inline int page_ref(struct Page *page) { return page->ref; }
ffffffffc0201e56:	00e507b3          	add	a5,a0,a4
ffffffffc0201e5a:	4394                	lw	a3,0(a5)
ffffffffc0201e5c:	4785                	li	a5,1
ffffffffc0201e5e:	72f69e63          	bne	a3,a5,ffffffffc020259a <pmm_init+0xa7a>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201e62:	f8e397b7          	lui	a5,0xf8e39
ffffffffc0201e66:	e3978793          	addi	a5,a5,-455 # fffffffff8e38e39 <end+0x38c278c1>
ffffffffc0201e6a:	07b2                	slli	a5,a5,0xc
ffffffffc0201e6c:	e3978793          	addi	a5,a5,-455
ffffffffc0201e70:	07b2                	slli	a5,a5,0xc
ffffffffc0201e72:	e3978793          	addi	a5,a5,-455
ffffffffc0201e76:	07b2                	slli	a5,a5,0xc
ffffffffc0201e78:	870d                	srai	a4,a4,0x3
ffffffffc0201e7a:	e3978793          	addi	a5,a5,-455
ffffffffc0201e7e:	02f707b3          	mul	a5,a4,a5
ffffffffc0201e82:	00080737          	lui	a4,0x80
ffffffffc0201e86:	97ba                	add	a5,a5,a4
    return page2ppn(page) << PGSHIFT;
ffffffffc0201e88:	00c79693          	slli	a3,a5,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201e8c:	6ec7fb63          	bgeu	a5,a2,ffffffffc0202582 <pmm_init+0xa62>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0201e90:	0009b783          	ld	a5,0(s3)
ffffffffc0201e94:	97b6                	add	a5,a5,a3
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e96:	639c                	ld	a5,0(a5)
ffffffffc0201e98:	078a                	slli	a5,a5,0x2
ffffffffc0201e9a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201e9c:	3ec7f563          	bgeu	a5,a2,ffffffffc0202286 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0201ea0:	8f99                	sub	a5,a5,a4
ffffffffc0201ea2:	00379713          	slli	a4,a5,0x3
ffffffffc0201ea6:	97ba                	add	a5,a5,a4
ffffffffc0201ea8:	078e                	slli	a5,a5,0x3
ffffffffc0201eaa:	953e                	add	a0,a0,a5
ffffffffc0201eac:	100027f3          	csrr	a5,sstatus
ffffffffc0201eb0:	8b89                	andi	a5,a5,2
ffffffffc0201eb2:	30079463          	bnez	a5,ffffffffc02021ba <pmm_init+0x69a>
    { pmm_manager->free_pages(base, n); }
ffffffffc0201eb6:	000bb783          	ld	a5,0(s7)
ffffffffc0201eba:	4585                	li	a1,1
ffffffffc0201ebc:	739c                	ld	a5,32(a5)
ffffffffc0201ebe:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0201ec0:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0201ec4:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201ec6:	078a                	slli	a5,a5,0x2
ffffffffc0201ec8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201eca:	3ae7fe63          	bgeu	a5,a4,ffffffffc0202286 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0201ece:	fff80737          	lui	a4,0xfff80
ffffffffc0201ed2:	97ba                	add	a5,a5,a4
ffffffffc0201ed4:	000b3503          	ld	a0,0(s6)
ffffffffc0201ed8:	00379713          	slli	a4,a5,0x3
ffffffffc0201edc:	97ba                	add	a5,a5,a4
ffffffffc0201ede:	078e                	slli	a5,a5,0x3
ffffffffc0201ee0:	953e                	add	a0,a0,a5
ffffffffc0201ee2:	100027f3          	csrr	a5,sstatus
ffffffffc0201ee6:	8b89                	andi	a5,a5,2
ffffffffc0201ee8:	2a079d63          	bnez	a5,ffffffffc02021a2 <pmm_init+0x682>
ffffffffc0201eec:	000bb783          	ld	a5,0(s7)
ffffffffc0201ef0:	4585                	li	a1,1
ffffffffc0201ef2:	739c                	ld	a5,32(a5)
ffffffffc0201ef4:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0201ef6:	00093783          	ld	a5,0(s2)
ffffffffc0201efa:	0007b023          	sd	zero,0(a5)
ffffffffc0201efe:	100027f3          	csrr	a5,sstatus
ffffffffc0201f02:	8b89                	andi	a5,a5,2
ffffffffc0201f04:	28079563          	bnez	a5,ffffffffc020218e <pmm_init+0x66e>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0201f08:	000bb783          	ld	a5,0(s7)
ffffffffc0201f0c:	779c                	ld	a5,40(a5)
ffffffffc0201f0e:	9782                	jalr	a5
ffffffffc0201f10:	8a2a                	mv	s4,a0

    assert(nr_free_store==nr_free_pages());
ffffffffc0201f12:	77441463          	bne	s0,s4,ffffffffc020267a <pmm_init+0xb5a>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0201f16:	00003517          	auipc	a0,0x3
ffffffffc0201f1a:	6e250513          	addi	a0,a0,1762 # ffffffffc02055f8 <etext+0x10b6>
ffffffffc0201f1e:	99cfe0ef          	jal	ffffffffc02000ba <cprintf>
ffffffffc0201f22:	100027f3          	csrr	a5,sstatus
ffffffffc0201f26:	8b89                	andi	a5,a5,2
ffffffffc0201f28:	24079963          	bnez	a5,ffffffffc020217a <pmm_init+0x65a>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0201f2c:	000bb783          	ld	a5,0(s7)
ffffffffc0201f30:	779c                	ld	a5,40(a5)
ffffffffc0201f32:	9782                	jalr	a5
ffffffffc0201f34:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201f36:	6098                	ld	a4,0(s1)
ffffffffc0201f38:	c0200437          	lui	s0,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201f3c:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201f3e:	00c71793          	slli	a5,a4,0xc
ffffffffc0201f42:	6a05                	lui	s4,0x1
ffffffffc0201f44:	02f47c63          	bgeu	s0,a5,ffffffffc0201f7c <pmm_init+0x45c>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201f48:	00c45793          	srli	a5,s0,0xc
ffffffffc0201f4c:	00093503          	ld	a0,0(s2)
ffffffffc0201f50:	2ce7fe63          	bgeu	a5,a4,ffffffffc020222c <pmm_init+0x70c>
ffffffffc0201f54:	0009b583          	ld	a1,0(s3)
ffffffffc0201f58:	4601                	li	a2,0
ffffffffc0201f5a:	95a2                	add	a1,a1,s0
ffffffffc0201f5c:	f90ff0ef          	jal	ffffffffc02016ec <get_pte>
ffffffffc0201f60:	30050363          	beqz	a0,ffffffffc0202266 <pmm_init+0x746>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201f64:	611c                	ld	a5,0(a0)
ffffffffc0201f66:	078a                	slli	a5,a5,0x2
ffffffffc0201f68:	0157f7b3          	and	a5,a5,s5
ffffffffc0201f6c:	2c879d63          	bne	a5,s0,ffffffffc0202246 <pmm_init+0x726>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201f70:	6098                	ld	a4,0(s1)
ffffffffc0201f72:	9452                	add	s0,s0,s4
ffffffffc0201f74:	00c71793          	slli	a5,a4,0xc
ffffffffc0201f78:	fcf468e3          	bltu	s0,a5,ffffffffc0201f48 <pmm_init+0x428>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc0201f7c:	00093783          	ld	a5,0(s2)
ffffffffc0201f80:	639c                	ld	a5,0(a5)
ffffffffc0201f82:	6c079c63          	bnez	a5,ffffffffc020265a <pmm_init+0xb3a>

    struct Page *p;
    p = alloc_page();
ffffffffc0201f86:	4505                	li	a0,1
ffffffffc0201f88:	e5aff0ef          	jal	ffffffffc02015e2 <alloc_pages>
ffffffffc0201f8c:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201f8e:	00093503          	ld	a0,0(s2)
ffffffffc0201f92:	4699                	li	a3,6
ffffffffc0201f94:	10000613          	li	a2,256
ffffffffc0201f98:	85d2                	mv	a1,s4
ffffffffc0201f9a:	a75ff0ef          	jal	ffffffffc0201a0e <page_insert>
ffffffffc0201f9e:	68051e63          	bnez	a0,ffffffffc020263a <pmm_init+0xb1a>
    assert(page_ref(p) == 1);
ffffffffc0201fa2:	000a2703          	lw	a4,0(s4) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc0201fa6:	4785                	li	a5,1
ffffffffc0201fa8:	66f71963          	bne	a4,a5,ffffffffc020261a <pmm_init+0xafa>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0201fac:	00093503          	ld	a0,0(s2)
ffffffffc0201fb0:	6605                	lui	a2,0x1
ffffffffc0201fb2:	4699                	li	a3,6
ffffffffc0201fb4:	10060613          	addi	a2,a2,256 # 1100 <kern_entry-0xffffffffc01fef00>
ffffffffc0201fb8:	85d2                	mv	a1,s4
ffffffffc0201fba:	a55ff0ef          	jal	ffffffffc0201a0e <page_insert>
ffffffffc0201fbe:	62051e63          	bnez	a0,ffffffffc02025fa <pmm_init+0xada>
    assert(page_ref(p) == 2);
ffffffffc0201fc2:	000a2703          	lw	a4,0(s4)
ffffffffc0201fc6:	4789                	li	a5,2
ffffffffc0201fc8:	76f71163          	bne	a4,a5,ffffffffc020272a <pmm_init+0xc0a>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0201fcc:	00003597          	auipc	a1,0x3
ffffffffc0201fd0:	76458593          	addi	a1,a1,1892 # ffffffffc0205730 <etext+0x11ee>
ffffffffc0201fd4:	10000513          	li	a0,256
ffffffffc0201fd8:	4e0020ef          	jal	ffffffffc02044b8 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0201fdc:	6585                	lui	a1,0x1
ffffffffc0201fde:	10058593          	addi	a1,a1,256 # 1100 <kern_entry-0xffffffffc01fef00>
ffffffffc0201fe2:	10000513          	li	a0,256
ffffffffc0201fe6:	4e4020ef          	jal	ffffffffc02044ca <strcmp>
ffffffffc0201fea:	72051063          	bnez	a0,ffffffffc020270a <pmm_init+0xbea>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201fee:	f8e39437          	lui	s0,0xf8e39
ffffffffc0201ff2:	e3940413          	addi	s0,s0,-455 # fffffffff8e38e39 <end+0x38c278c1>
ffffffffc0201ff6:	0432                	slli	s0,s0,0xc
ffffffffc0201ff8:	000b3683          	ld	a3,0(s6)
ffffffffc0201ffc:	e3940413          	addi	s0,s0,-455
ffffffffc0202000:	0432                	slli	s0,s0,0xc
ffffffffc0202002:	e3940413          	addi	s0,s0,-455
ffffffffc0202006:	40da06b3          	sub	a3,s4,a3
ffffffffc020200a:	0432                	slli	s0,s0,0xc
ffffffffc020200c:	868d                	srai	a3,a3,0x3
ffffffffc020200e:	e3940413          	addi	s0,s0,-455
ffffffffc0202012:	028686b3          	mul	a3,a3,s0
ffffffffc0202016:	00080cb7          	lui	s9,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020201a:	6098                	ld	a4,0(s1)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020201c:	96e6                	add	a3,a3,s9
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020201e:	00c69793          	slli	a5,a3,0xc
ffffffffc0202022:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202024:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202026:	54e7fe63          	bgeu	a5,a4,ffffffffc0202582 <pmm_init+0xa62>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc020202a:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc020202e:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202032:	97b6                	add	a5,a5,a3
ffffffffc0202034:	10078023          	sb	zero,256(a5)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202038:	44a020ef          	jal	ffffffffc0204482 <strlen>
ffffffffc020203c:	6a051763          	bnez	a0,ffffffffc02026ea <pmm_init+0xbca>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0202040:	00093a83          	ld	s5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0202044:	6090                	ld	a2,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202046:	000ab783          	ld	a5,0(s5) # fffffffffffff000 <end+0x3fdeda88>
ffffffffc020204a:	078a                	slli	a5,a5,0x2
ffffffffc020204c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020204e:	22c7fc63          	bgeu	a5,a2,ffffffffc0202286 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202052:	419787b3          	sub	a5,a5,s9
ffffffffc0202056:	00379713          	slli	a4,a5,0x3
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020205a:	97ba                	add	a5,a5,a4
ffffffffc020205c:	028787b3          	mul	a5,a5,s0
ffffffffc0202060:	97e6                	add	a5,a5,s9
    return page2ppn(page) << PGSHIFT;
ffffffffc0202062:	00c79413          	slli	s0,a5,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202066:	50c7fd63          	bgeu	a5,a2,ffffffffc0202580 <pmm_init+0xa60>
ffffffffc020206a:	0009b783          	ld	a5,0(s3)
ffffffffc020206e:	943e                	add	s0,s0,a5
ffffffffc0202070:	100027f3          	csrr	a5,sstatus
ffffffffc0202074:	8b89                	andi	a5,a5,2
ffffffffc0202076:	1a079063          	bnez	a5,ffffffffc0202216 <pmm_init+0x6f6>
    { pmm_manager->free_pages(base, n); }
ffffffffc020207a:	000bb783          	ld	a5,0(s7)
ffffffffc020207e:	4585                	li	a1,1
ffffffffc0202080:	8552                	mv	a0,s4
ffffffffc0202082:	739c                	ld	a5,32(a5)
ffffffffc0202084:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202086:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0202088:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020208a:	078a                	slli	a5,a5,0x2
ffffffffc020208c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020208e:	1ee7fc63          	bgeu	a5,a4,ffffffffc0202286 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202092:	fff80737          	lui	a4,0xfff80
ffffffffc0202096:	97ba                	add	a5,a5,a4
ffffffffc0202098:	000b3503          	ld	a0,0(s6)
ffffffffc020209c:	00379713          	slli	a4,a5,0x3
ffffffffc02020a0:	97ba                	add	a5,a5,a4
ffffffffc02020a2:	078e                	slli	a5,a5,0x3
ffffffffc02020a4:	953e                	add	a0,a0,a5
ffffffffc02020a6:	100027f3          	csrr	a5,sstatus
ffffffffc02020aa:	8b89                	andi	a5,a5,2
ffffffffc02020ac:	14079963          	bnez	a5,ffffffffc02021fe <pmm_init+0x6de>
ffffffffc02020b0:	000bb783          	ld	a5,0(s7)
ffffffffc02020b4:	4585                	li	a1,1
ffffffffc02020b6:	739c                	ld	a5,32(a5)
ffffffffc02020b8:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02020ba:	000ab783          	ld	a5,0(s5)
    if (PPN(pa) >= npage) {
ffffffffc02020be:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02020c0:	078a                	slli	a5,a5,0x2
ffffffffc02020c2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02020c4:	1ce7f163          	bgeu	a5,a4,ffffffffc0202286 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc02020c8:	fff80737          	lui	a4,0xfff80
ffffffffc02020cc:	97ba                	add	a5,a5,a4
ffffffffc02020ce:	000b3503          	ld	a0,0(s6)
ffffffffc02020d2:	00379713          	slli	a4,a5,0x3
ffffffffc02020d6:	97ba                	add	a5,a5,a4
ffffffffc02020d8:	078e                	slli	a5,a5,0x3
ffffffffc02020da:	953e                	add	a0,a0,a5
ffffffffc02020dc:	100027f3          	csrr	a5,sstatus
ffffffffc02020e0:	8b89                	andi	a5,a5,2
ffffffffc02020e2:	10079263          	bnez	a5,ffffffffc02021e6 <pmm_init+0x6c6>
ffffffffc02020e6:	000bb783          	ld	a5,0(s7)
ffffffffc02020ea:	4585                	li	a1,1
ffffffffc02020ec:	739c                	ld	a5,32(a5)
ffffffffc02020ee:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc02020f0:	00093783          	ld	a5,0(s2)
ffffffffc02020f4:	0007b023          	sd	zero,0(a5)
ffffffffc02020f8:	100027f3          	csrr	a5,sstatus
ffffffffc02020fc:	8b89                	andi	a5,a5,2
ffffffffc02020fe:	0c079a63          	bnez	a5,ffffffffc02021d2 <pmm_init+0x6b2>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0202102:	000bb783          	ld	a5,0(s7)
ffffffffc0202106:	779c                	ld	a5,40(a5)
ffffffffc0202108:	9782                	jalr	a5
ffffffffc020210a:	842a                	mv	s0,a0

    assert(nr_free_store==nr_free_pages());
ffffffffc020210c:	1a8c1b63          	bne	s8,s0,ffffffffc02022c2 <pmm_init+0x7a2>
}
ffffffffc0202110:	7406                	ld	s0,96(sp)
ffffffffc0202112:	70a6                	ld	ra,104(sp)
ffffffffc0202114:	64e6                	ld	s1,88(sp)
ffffffffc0202116:	6946                	ld	s2,80(sp)
ffffffffc0202118:	69a6                	ld	s3,72(sp)
ffffffffc020211a:	6a06                	ld	s4,64(sp)
ffffffffc020211c:	7ae2                	ld	s5,56(sp)
ffffffffc020211e:	7b42                	ld	s6,48(sp)
ffffffffc0202120:	7ba2                	ld	s7,40(sp)
ffffffffc0202122:	7c02                	ld	s8,32(sp)
ffffffffc0202124:	6ce2                	ld	s9,24(sp)

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202126:	00003517          	auipc	a0,0x3
ffffffffc020212a:	68250513          	addi	a0,a0,1666 # ffffffffc02057a8 <etext+0x1266>
}
ffffffffc020212e:	6165                	addi	sp,sp,112
    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202130:	f8bfd06f          	j	ffffffffc02000ba <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0202134:	6705                	lui	a4,0x1
ffffffffc0202136:	177d                	addi	a4,a4,-1 # fff <kern_entry-0xffffffffc01ff001>
ffffffffc0202138:	96ba                	add	a3,a3,a4
ffffffffc020213a:	777d                	lui	a4,0xfffff
ffffffffc020213c:	8f75                	and	a4,a4,a3
    if (PPN(pa) >= npage) {
ffffffffc020213e:	00c75693          	srli	a3,a4,0xc
ffffffffc0202142:	14f6f263          	bgeu	a3,a5,ffffffffc0202286 <pmm_init+0x766>
    pmm_manager->init_memmap(base, n);
ffffffffc0202146:	000bb583          	ld	a1,0(s7)
    return &pages[PPN(pa) - nbase];
ffffffffc020214a:	fff807b7          	lui	a5,0xfff80
ffffffffc020214e:	96be                	add	a3,a3,a5
ffffffffc0202150:	00369793          	slli	a5,a3,0x3
ffffffffc0202154:	97b6                	add	a5,a5,a3
ffffffffc0202156:	6994                	ld	a3,16(a1)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202158:	8e19                	sub	a2,a2,a4
ffffffffc020215a:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc020215c:	00c65593          	srli	a1,a2,0xc
ffffffffc0202160:	953e                	add	a0,a0,a5
ffffffffc0202162:	9682                	jalr	a3
}
ffffffffc0202164:	b4f9                	j	ffffffffc0201c32 <pmm_init+0x112>
        intr_disable();
ffffffffc0202166:	b76fe0ef          	jal	ffffffffc02004dc <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc020216a:	000bb783          	ld	a5,0(s7)
ffffffffc020216e:	779c                	ld	a5,40(a5)
ffffffffc0202170:	9782                	jalr	a5
ffffffffc0202172:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202174:	b62fe0ef          	jal	ffffffffc02004d6 <intr_enable>
ffffffffc0202178:	b631                	j	ffffffffc0201c84 <pmm_init+0x164>
        intr_disable();
ffffffffc020217a:	b62fe0ef          	jal	ffffffffc02004dc <intr_disable>
ffffffffc020217e:	000bb783          	ld	a5,0(s7)
ffffffffc0202182:	779c                	ld	a5,40(a5)
ffffffffc0202184:	9782                	jalr	a5
ffffffffc0202186:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0202188:	b4efe0ef          	jal	ffffffffc02004d6 <intr_enable>
ffffffffc020218c:	b36d                	j	ffffffffc0201f36 <pmm_init+0x416>
        intr_disable();
ffffffffc020218e:	b4efe0ef          	jal	ffffffffc02004dc <intr_disable>
ffffffffc0202192:	000bb783          	ld	a5,0(s7)
ffffffffc0202196:	779c                	ld	a5,40(a5)
ffffffffc0202198:	9782                	jalr	a5
ffffffffc020219a:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc020219c:	b3afe0ef          	jal	ffffffffc02004d6 <intr_enable>
ffffffffc02021a0:	bb8d                	j	ffffffffc0201f12 <pmm_init+0x3f2>
ffffffffc02021a2:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02021a4:	b38fe0ef          	jal	ffffffffc02004dc <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc02021a8:	000bb783          	ld	a5,0(s7)
ffffffffc02021ac:	6522                	ld	a0,8(sp)
ffffffffc02021ae:	4585                	li	a1,1
ffffffffc02021b0:	739c                	ld	a5,32(a5)
ffffffffc02021b2:	9782                	jalr	a5
        intr_enable();
ffffffffc02021b4:	b22fe0ef          	jal	ffffffffc02004d6 <intr_enable>
ffffffffc02021b8:	bb3d                	j	ffffffffc0201ef6 <pmm_init+0x3d6>
ffffffffc02021ba:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02021bc:	b20fe0ef          	jal	ffffffffc02004dc <intr_disable>
ffffffffc02021c0:	000bb783          	ld	a5,0(s7)
ffffffffc02021c4:	6522                	ld	a0,8(sp)
ffffffffc02021c6:	4585                	li	a1,1
ffffffffc02021c8:	739c                	ld	a5,32(a5)
ffffffffc02021ca:	9782                	jalr	a5
        intr_enable();
ffffffffc02021cc:	b0afe0ef          	jal	ffffffffc02004d6 <intr_enable>
ffffffffc02021d0:	b9c5                	j	ffffffffc0201ec0 <pmm_init+0x3a0>
        intr_disable();
ffffffffc02021d2:	b0afe0ef          	jal	ffffffffc02004dc <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02021d6:	000bb783          	ld	a5,0(s7)
ffffffffc02021da:	779c                	ld	a5,40(a5)
ffffffffc02021dc:	9782                	jalr	a5
ffffffffc02021de:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02021e0:	af6fe0ef          	jal	ffffffffc02004d6 <intr_enable>
ffffffffc02021e4:	b725                	j	ffffffffc020210c <pmm_init+0x5ec>
ffffffffc02021e6:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02021e8:	af4fe0ef          	jal	ffffffffc02004dc <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc02021ec:	000bb783          	ld	a5,0(s7)
ffffffffc02021f0:	6522                	ld	a0,8(sp)
ffffffffc02021f2:	4585                	li	a1,1
ffffffffc02021f4:	739c                	ld	a5,32(a5)
ffffffffc02021f6:	9782                	jalr	a5
        intr_enable();
ffffffffc02021f8:	adefe0ef          	jal	ffffffffc02004d6 <intr_enable>
ffffffffc02021fc:	bdd5                	j	ffffffffc02020f0 <pmm_init+0x5d0>
ffffffffc02021fe:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202200:	adcfe0ef          	jal	ffffffffc02004dc <intr_disable>
ffffffffc0202204:	000bb783          	ld	a5,0(s7)
ffffffffc0202208:	6522                	ld	a0,8(sp)
ffffffffc020220a:	4585                	li	a1,1
ffffffffc020220c:	739c                	ld	a5,32(a5)
ffffffffc020220e:	9782                	jalr	a5
        intr_enable();
ffffffffc0202210:	ac6fe0ef          	jal	ffffffffc02004d6 <intr_enable>
ffffffffc0202214:	b55d                	j	ffffffffc02020ba <pmm_init+0x59a>
        intr_disable();
ffffffffc0202216:	ac6fe0ef          	jal	ffffffffc02004dc <intr_disable>
ffffffffc020221a:	000bb783          	ld	a5,0(s7)
ffffffffc020221e:	4585                	li	a1,1
ffffffffc0202220:	8552                	mv	a0,s4
ffffffffc0202222:	739c                	ld	a5,32(a5)
ffffffffc0202224:	9782                	jalr	a5
        intr_enable();
ffffffffc0202226:	ab0fe0ef          	jal	ffffffffc02004d6 <intr_enable>
ffffffffc020222a:	bdb1                	j	ffffffffc0202086 <pmm_init+0x566>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc020222c:	86a2                	mv	a3,s0
ffffffffc020222e:	00003617          	auipc	a2,0x3
ffffffffc0202232:	ffa60613          	addi	a2,a2,-6 # ffffffffc0205228 <etext+0xce6>
ffffffffc0202236:	1d000593          	li	a1,464
ffffffffc020223a:	00003517          	auipc	a0,0x3
ffffffffc020223e:	01650513          	addi	a0,a0,22 # ffffffffc0205250 <etext+0xd0e>
ffffffffc0202242:	91efe0ef          	jal	ffffffffc0200360 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202246:	00003697          	auipc	a3,0x3
ffffffffc020224a:	41268693          	addi	a3,a3,1042 # ffffffffc0205658 <etext+0x1116>
ffffffffc020224e:	00003617          	auipc	a2,0x3
ffffffffc0202252:	bd260613          	addi	a2,a2,-1070 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0202256:	1d100593          	li	a1,465
ffffffffc020225a:	00003517          	auipc	a0,0x3
ffffffffc020225e:	ff650513          	addi	a0,a0,-10 # ffffffffc0205250 <etext+0xd0e>
ffffffffc0202262:	8fefe0ef          	jal	ffffffffc0200360 <__panic>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202266:	00003697          	auipc	a3,0x3
ffffffffc020226a:	3b268693          	addi	a3,a3,946 # ffffffffc0205618 <etext+0x10d6>
ffffffffc020226e:	00003617          	auipc	a2,0x3
ffffffffc0202272:	bb260613          	addi	a2,a2,-1102 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0202276:	1d000593          	li	a1,464
ffffffffc020227a:	00003517          	auipc	a0,0x3
ffffffffc020227e:	fd650513          	addi	a0,a0,-42 # ffffffffc0205250 <etext+0xd0e>
ffffffffc0202282:	8defe0ef          	jal	ffffffffc0200360 <__panic>
ffffffffc0202286:	b24ff0ef          	jal	ffffffffc02015aa <pa2page.part.0>
    assert(pte2page(*ptep) == p1);
ffffffffc020228a:	00003697          	auipc	a3,0x3
ffffffffc020228e:	18668693          	addi	a3,a3,390 # ffffffffc0205410 <etext+0xece>
ffffffffc0202292:	00003617          	auipc	a2,0x3
ffffffffc0202296:	b8e60613          	addi	a2,a2,-1138 # ffffffffc0204e20 <etext+0x8de>
ffffffffc020229a:	19e00593          	li	a1,414
ffffffffc020229e:	00003517          	auipc	a0,0x3
ffffffffc02022a2:	fb250513          	addi	a0,a0,-78 # ffffffffc0205250 <etext+0xd0e>
ffffffffc02022a6:	8bafe0ef          	jal	ffffffffc0200360 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02022aa:	00003617          	auipc	a2,0x3
ffffffffc02022ae:	03e60613          	addi	a2,a2,62 # ffffffffc02052e8 <etext+0xda6>
ffffffffc02022b2:	07700593          	li	a1,119
ffffffffc02022b6:	00003517          	auipc	a0,0x3
ffffffffc02022ba:	f9a50513          	addi	a0,a0,-102 # ffffffffc0205250 <etext+0xd0e>
ffffffffc02022be:	8a2fe0ef          	jal	ffffffffc0200360 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02022c2:	00003697          	auipc	a3,0x3
ffffffffc02022c6:	31668693          	addi	a3,a3,790 # ffffffffc02055d8 <etext+0x1096>
ffffffffc02022ca:	00003617          	auipc	a2,0x3
ffffffffc02022ce:	b5660613          	addi	a2,a2,-1194 # ffffffffc0204e20 <etext+0x8de>
ffffffffc02022d2:	1eb00593          	li	a1,491
ffffffffc02022d6:	00003517          	auipc	a0,0x3
ffffffffc02022da:	f7a50513          	addi	a0,a0,-134 # ffffffffc0205250 <etext+0xd0e>
ffffffffc02022de:	882fe0ef          	jal	ffffffffc0200360 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02022e2:	00003697          	auipc	a3,0x3
ffffffffc02022e6:	06e68693          	addi	a3,a3,110 # ffffffffc0205350 <etext+0xe0e>
ffffffffc02022ea:	00003617          	auipc	a2,0x3
ffffffffc02022ee:	b3660613          	addi	a2,a2,-1226 # ffffffffc0204e20 <etext+0x8de>
ffffffffc02022f2:	19600593          	li	a1,406
ffffffffc02022f6:	00003517          	auipc	a0,0x3
ffffffffc02022fa:	f5a50513          	addi	a0,a0,-166 # ffffffffc0205250 <etext+0xd0e>
ffffffffc02022fe:	862fe0ef          	jal	ffffffffc0200360 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202302:	00003697          	auipc	a3,0x3
ffffffffc0202306:	02e68693          	addi	a3,a3,46 # ffffffffc0205330 <etext+0xdee>
ffffffffc020230a:	00003617          	auipc	a2,0x3
ffffffffc020230e:	b1660613          	addi	a2,a2,-1258 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0202312:	19500593          	li	a1,405
ffffffffc0202316:	00003517          	auipc	a0,0x3
ffffffffc020231a:	f3a50513          	addi	a0,a0,-198 # ffffffffc0205250 <etext+0xd0e>
ffffffffc020231e:	842fe0ef          	jal	ffffffffc0200360 <__panic>
ffffffffc0202322:	aa4ff0ef          	jal	ffffffffc02015c6 <pte2page.part.0>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0202326:	00003697          	auipc	a3,0x3
ffffffffc020232a:	0ba68693          	addi	a3,a3,186 # ffffffffc02053e0 <etext+0xe9e>
ffffffffc020232e:	00003617          	auipc	a2,0x3
ffffffffc0202332:	af260613          	addi	a2,a2,-1294 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0202336:	19d00593          	li	a1,413
ffffffffc020233a:	00003517          	auipc	a0,0x3
ffffffffc020233e:	f1650513          	addi	a0,a0,-234 # ffffffffc0205250 <etext+0xd0e>
ffffffffc0202342:	81efe0ef          	jal	ffffffffc0200360 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0202346:	00003697          	auipc	a3,0x3
ffffffffc020234a:	06a68693          	addi	a3,a3,106 # ffffffffc02053b0 <etext+0xe6e>
ffffffffc020234e:	00003617          	auipc	a2,0x3
ffffffffc0202352:	ad260613          	addi	a2,a2,-1326 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0202356:	19b00593          	li	a1,411
ffffffffc020235a:	00003517          	auipc	a0,0x3
ffffffffc020235e:	ef650513          	addi	a0,a0,-266 # ffffffffc0205250 <etext+0xd0e>
ffffffffc0202362:	ffffd0ef          	jal	ffffffffc0200360 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0202366:	00003697          	auipc	a3,0x3
ffffffffc020236a:	02268693          	addi	a3,a3,34 # ffffffffc0205388 <etext+0xe46>
ffffffffc020236e:	00003617          	auipc	a2,0x3
ffffffffc0202372:	ab260613          	addi	a2,a2,-1358 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0202376:	19700593          	li	a1,407
ffffffffc020237a:	00003517          	auipc	a0,0x3
ffffffffc020237e:	ed650513          	addi	a0,a0,-298 # ffffffffc0205250 <etext+0xd0e>
ffffffffc0202382:	fdffd0ef          	jal	ffffffffc0200360 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202386:	00003697          	auipc	a3,0x3
ffffffffc020238a:	11a68693          	addi	a3,a3,282 # ffffffffc02054a0 <etext+0xf5e>
ffffffffc020238e:	00003617          	auipc	a2,0x3
ffffffffc0202392:	a9260613          	addi	a2,a2,-1390 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0202396:	1a700593          	li	a1,423
ffffffffc020239a:	00003517          	auipc	a0,0x3
ffffffffc020239e:	eb650513          	addi	a0,a0,-330 # ffffffffc0205250 <etext+0xd0e>
ffffffffc02023a2:	fbffd0ef          	jal	ffffffffc0200360 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02023a6:	00003697          	auipc	a3,0x3
ffffffffc02023aa:	0c268693          	addi	a3,a3,194 # ffffffffc0205468 <etext+0xf26>
ffffffffc02023ae:	00003617          	auipc	a2,0x3
ffffffffc02023b2:	a7260613          	addi	a2,a2,-1422 # ffffffffc0204e20 <etext+0x8de>
ffffffffc02023b6:	1a600593          	li	a1,422
ffffffffc02023ba:	00003517          	auipc	a0,0x3
ffffffffc02023be:	e9650513          	addi	a0,a0,-362 # ffffffffc0205250 <etext+0xd0e>
ffffffffc02023c2:	f9ffd0ef          	jal	ffffffffc0200360 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02023c6:	00003697          	auipc	a3,0x3
ffffffffc02023ca:	07a68693          	addi	a3,a3,122 # ffffffffc0205440 <etext+0xefe>
ffffffffc02023ce:	00003617          	auipc	a2,0x3
ffffffffc02023d2:	a5260613          	addi	a2,a2,-1454 # ffffffffc0204e20 <etext+0x8de>
ffffffffc02023d6:	1a300593          	li	a1,419
ffffffffc02023da:	00003517          	auipc	a0,0x3
ffffffffc02023de:	e7650513          	addi	a0,a0,-394 # ffffffffc0205250 <etext+0xd0e>
ffffffffc02023e2:	f7ffd0ef          	jal	ffffffffc0200360 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02023e6:	86d6                	mv	a3,s5
ffffffffc02023e8:	00003617          	auipc	a2,0x3
ffffffffc02023ec:	e4060613          	addi	a2,a2,-448 # ffffffffc0205228 <etext+0xce6>
ffffffffc02023f0:	1a200593          	li	a1,418
ffffffffc02023f4:	00003517          	auipc	a0,0x3
ffffffffc02023f8:	e5c50513          	addi	a0,a0,-420 # ffffffffc0205250 <etext+0xd0e>
ffffffffc02023fc:	f65fd0ef          	jal	ffffffffc0200360 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202400:	00003697          	auipc	a3,0x3
ffffffffc0202404:	0a068693          	addi	a3,a3,160 # ffffffffc02054a0 <etext+0xf5e>
ffffffffc0202408:	00003617          	auipc	a2,0x3
ffffffffc020240c:	a1860613          	addi	a2,a2,-1512 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0202410:	1b000593          	li	a1,432
ffffffffc0202414:	00003517          	auipc	a0,0x3
ffffffffc0202418:	e3c50513          	addi	a0,a0,-452 # ffffffffc0205250 <etext+0xd0e>
ffffffffc020241c:	f45fd0ef          	jal	ffffffffc0200360 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202420:	00003697          	auipc	a3,0x3
ffffffffc0202424:	14868693          	addi	a3,a3,328 # ffffffffc0205568 <etext+0x1026>
ffffffffc0202428:	00003617          	auipc	a2,0x3
ffffffffc020242c:	9f860613          	addi	a2,a2,-1544 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0202430:	1af00593          	li	a1,431
ffffffffc0202434:	00003517          	auipc	a0,0x3
ffffffffc0202438:	e1c50513          	addi	a0,a0,-484 # ffffffffc0205250 <etext+0xd0e>
ffffffffc020243c:	f25fd0ef          	jal	ffffffffc0200360 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0202440:	00003697          	auipc	a3,0x3
ffffffffc0202444:	11068693          	addi	a3,a3,272 # ffffffffc0205550 <etext+0x100e>
ffffffffc0202448:	00003617          	auipc	a2,0x3
ffffffffc020244c:	9d860613          	addi	a2,a2,-1576 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0202450:	1ae00593          	li	a1,430
ffffffffc0202454:	00003517          	auipc	a0,0x3
ffffffffc0202458:	dfc50513          	addi	a0,a0,-516 # ffffffffc0205250 <etext+0xd0e>
ffffffffc020245c:	f05fd0ef          	jal	ffffffffc0200360 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0202460:	00003697          	auipc	a3,0x3
ffffffffc0202464:	0c068693          	addi	a3,a3,192 # ffffffffc0205520 <etext+0xfde>
ffffffffc0202468:	00003617          	auipc	a2,0x3
ffffffffc020246c:	9b860613          	addi	a2,a2,-1608 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0202470:	1ad00593          	li	a1,429
ffffffffc0202474:	00003517          	auipc	a0,0x3
ffffffffc0202478:	ddc50513          	addi	a0,a0,-548 # ffffffffc0205250 <etext+0xd0e>
ffffffffc020247c:	ee5fd0ef          	jal	ffffffffc0200360 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0202480:	00003697          	auipc	a3,0x3
ffffffffc0202484:	08868693          	addi	a3,a3,136 # ffffffffc0205508 <etext+0xfc6>
ffffffffc0202488:	00003617          	auipc	a2,0x3
ffffffffc020248c:	99860613          	addi	a2,a2,-1640 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0202490:	1ab00593          	li	a1,427
ffffffffc0202494:	00003517          	auipc	a0,0x3
ffffffffc0202498:	dbc50513          	addi	a0,a0,-580 # ffffffffc0205250 <etext+0xd0e>
ffffffffc020249c:	ec5fd0ef          	jal	ffffffffc0200360 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc02024a0:	00003697          	auipc	a3,0x3
ffffffffc02024a4:	05068693          	addi	a3,a3,80 # ffffffffc02054f0 <etext+0xfae>
ffffffffc02024a8:	00003617          	auipc	a2,0x3
ffffffffc02024ac:	97860613          	addi	a2,a2,-1672 # ffffffffc0204e20 <etext+0x8de>
ffffffffc02024b0:	1aa00593          	li	a1,426
ffffffffc02024b4:	00003517          	auipc	a0,0x3
ffffffffc02024b8:	d9c50513          	addi	a0,a0,-612 # ffffffffc0205250 <etext+0xd0e>
ffffffffc02024bc:	ea5fd0ef          	jal	ffffffffc0200360 <__panic>
    assert(*ptep & PTE_W);
ffffffffc02024c0:	00003697          	auipc	a3,0x3
ffffffffc02024c4:	02068693          	addi	a3,a3,32 # ffffffffc02054e0 <etext+0xf9e>
ffffffffc02024c8:	00003617          	auipc	a2,0x3
ffffffffc02024cc:	95860613          	addi	a2,a2,-1704 # ffffffffc0204e20 <etext+0x8de>
ffffffffc02024d0:	1a900593          	li	a1,425
ffffffffc02024d4:	00003517          	auipc	a0,0x3
ffffffffc02024d8:	d7c50513          	addi	a0,a0,-644 # ffffffffc0205250 <etext+0xd0e>
ffffffffc02024dc:	e85fd0ef          	jal	ffffffffc0200360 <__panic>
    assert(*ptep & PTE_U);
ffffffffc02024e0:	00003697          	auipc	a3,0x3
ffffffffc02024e4:	ff068693          	addi	a3,a3,-16 # ffffffffc02054d0 <etext+0xf8e>
ffffffffc02024e8:	00003617          	auipc	a2,0x3
ffffffffc02024ec:	93860613          	addi	a2,a2,-1736 # ffffffffc0204e20 <etext+0x8de>
ffffffffc02024f0:	1a800593          	li	a1,424
ffffffffc02024f4:	00003517          	auipc	a0,0x3
ffffffffc02024f8:	d5c50513          	addi	a0,a0,-676 # ffffffffc0205250 <etext+0xd0e>
ffffffffc02024fc:	e65fd0ef          	jal	ffffffffc0200360 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202500:	00003697          	auipc	a3,0x3
ffffffffc0202504:	06868693          	addi	a3,a3,104 # ffffffffc0205568 <etext+0x1026>
ffffffffc0202508:	00003617          	auipc	a2,0x3
ffffffffc020250c:	91860613          	addi	a2,a2,-1768 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0202510:	1b600593          	li	a1,438
ffffffffc0202514:	00003517          	auipc	a0,0x3
ffffffffc0202518:	d3c50513          	addi	a0,a0,-708 # ffffffffc0205250 <etext+0xd0e>
ffffffffc020251c:	e45fd0ef          	jal	ffffffffc0200360 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202520:	00003697          	auipc	a3,0x3
ffffffffc0202524:	f0868693          	addi	a3,a3,-248 # ffffffffc0205428 <etext+0xee6>
ffffffffc0202528:	00003617          	auipc	a2,0x3
ffffffffc020252c:	8f860613          	addi	a2,a2,-1800 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0202530:	1b500593          	li	a1,437
ffffffffc0202534:	00003517          	auipc	a0,0x3
ffffffffc0202538:	d1c50513          	addi	a0,a0,-740 # ffffffffc0205250 <etext+0xd0e>
ffffffffc020253c:	e25fd0ef          	jal	ffffffffc0200360 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202540:	00003697          	auipc	a3,0x3
ffffffffc0202544:	04068693          	addi	a3,a3,64 # ffffffffc0205580 <etext+0x103e>
ffffffffc0202548:	00003617          	auipc	a2,0x3
ffffffffc020254c:	8d860613          	addi	a2,a2,-1832 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0202550:	1b200593          	li	a1,434
ffffffffc0202554:	00003517          	auipc	a0,0x3
ffffffffc0202558:	cfc50513          	addi	a0,a0,-772 # ffffffffc0205250 <etext+0xd0e>
ffffffffc020255c:	e05fd0ef          	jal	ffffffffc0200360 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202560:	00003697          	auipc	a3,0x3
ffffffffc0202564:	eb068693          	addi	a3,a3,-336 # ffffffffc0205410 <etext+0xece>
ffffffffc0202568:	00003617          	auipc	a2,0x3
ffffffffc020256c:	8b860613          	addi	a2,a2,-1864 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0202570:	1b100593          	li	a1,433
ffffffffc0202574:	00003517          	auipc	a0,0x3
ffffffffc0202578:	cdc50513          	addi	a0,a0,-804 # ffffffffc0205250 <etext+0xd0e>
ffffffffc020257c:	de5fd0ef          	jal	ffffffffc0200360 <__panic>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202580:	86a2                	mv	a3,s0
ffffffffc0202582:	00003617          	auipc	a2,0x3
ffffffffc0202586:	ca660613          	addi	a2,a2,-858 # ffffffffc0205228 <etext+0xce6>
ffffffffc020258a:	06a00593          	li	a1,106
ffffffffc020258e:	00003517          	auipc	a0,0x3
ffffffffc0202592:	c6250513          	addi	a0,a0,-926 # ffffffffc02051f0 <etext+0xcae>
ffffffffc0202596:	dcbfd0ef          	jal	ffffffffc0200360 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc020259a:	00003697          	auipc	a3,0x3
ffffffffc020259e:	01668693          	addi	a3,a3,22 # ffffffffc02055b0 <etext+0x106e>
ffffffffc02025a2:	00003617          	auipc	a2,0x3
ffffffffc02025a6:	87e60613          	addi	a2,a2,-1922 # ffffffffc0204e20 <etext+0x8de>
ffffffffc02025aa:	1bc00593          	li	a1,444
ffffffffc02025ae:	00003517          	auipc	a0,0x3
ffffffffc02025b2:	ca250513          	addi	a0,a0,-862 # ffffffffc0205250 <etext+0xd0e>
ffffffffc02025b6:	dabfd0ef          	jal	ffffffffc0200360 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02025ba:	00003697          	auipc	a3,0x3
ffffffffc02025be:	fae68693          	addi	a3,a3,-82 # ffffffffc0205568 <etext+0x1026>
ffffffffc02025c2:	00003617          	auipc	a2,0x3
ffffffffc02025c6:	85e60613          	addi	a2,a2,-1954 # ffffffffc0204e20 <etext+0x8de>
ffffffffc02025ca:	1ba00593          	li	a1,442
ffffffffc02025ce:	00003517          	auipc	a0,0x3
ffffffffc02025d2:	c8250513          	addi	a0,a0,-894 # ffffffffc0205250 <etext+0xd0e>
ffffffffc02025d6:	d8bfd0ef          	jal	ffffffffc0200360 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc02025da:	00003697          	auipc	a3,0x3
ffffffffc02025de:	fbe68693          	addi	a3,a3,-66 # ffffffffc0205598 <etext+0x1056>
ffffffffc02025e2:	00003617          	auipc	a2,0x3
ffffffffc02025e6:	83e60613          	addi	a2,a2,-1986 # ffffffffc0204e20 <etext+0x8de>
ffffffffc02025ea:	1b900593          	li	a1,441
ffffffffc02025ee:	00003517          	auipc	a0,0x3
ffffffffc02025f2:	c6250513          	addi	a0,a0,-926 # ffffffffc0205250 <etext+0xd0e>
ffffffffc02025f6:	d6bfd0ef          	jal	ffffffffc0200360 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02025fa:	00003697          	auipc	a3,0x3
ffffffffc02025fe:	0de68693          	addi	a3,a3,222 # ffffffffc02056d8 <etext+0x1196>
ffffffffc0202602:	00003617          	auipc	a2,0x3
ffffffffc0202606:	81e60613          	addi	a2,a2,-2018 # ffffffffc0204e20 <etext+0x8de>
ffffffffc020260a:	1db00593          	li	a1,475
ffffffffc020260e:	00003517          	auipc	a0,0x3
ffffffffc0202612:	c4250513          	addi	a0,a0,-958 # ffffffffc0205250 <etext+0xd0e>
ffffffffc0202616:	d4bfd0ef          	jal	ffffffffc0200360 <__panic>
    assert(page_ref(p) == 1);
ffffffffc020261a:	00003697          	auipc	a3,0x3
ffffffffc020261e:	0a668693          	addi	a3,a3,166 # ffffffffc02056c0 <etext+0x117e>
ffffffffc0202622:	00002617          	auipc	a2,0x2
ffffffffc0202626:	7fe60613          	addi	a2,a2,2046 # ffffffffc0204e20 <etext+0x8de>
ffffffffc020262a:	1da00593          	li	a1,474
ffffffffc020262e:	00003517          	auipc	a0,0x3
ffffffffc0202632:	c2250513          	addi	a0,a0,-990 # ffffffffc0205250 <etext+0xd0e>
ffffffffc0202636:	d2bfd0ef          	jal	ffffffffc0200360 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc020263a:	00003697          	auipc	a3,0x3
ffffffffc020263e:	04e68693          	addi	a3,a3,78 # ffffffffc0205688 <etext+0x1146>
ffffffffc0202642:	00002617          	auipc	a2,0x2
ffffffffc0202646:	7de60613          	addi	a2,a2,2014 # ffffffffc0204e20 <etext+0x8de>
ffffffffc020264a:	1d900593          	li	a1,473
ffffffffc020264e:	00003517          	auipc	a0,0x3
ffffffffc0202652:	c0250513          	addi	a0,a0,-1022 # ffffffffc0205250 <etext+0xd0e>
ffffffffc0202656:	d0bfd0ef          	jal	ffffffffc0200360 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc020265a:	00003697          	auipc	a3,0x3
ffffffffc020265e:	01668693          	addi	a3,a3,22 # ffffffffc0205670 <etext+0x112e>
ffffffffc0202662:	00002617          	auipc	a2,0x2
ffffffffc0202666:	7be60613          	addi	a2,a2,1982 # ffffffffc0204e20 <etext+0x8de>
ffffffffc020266a:	1d500593          	li	a1,469
ffffffffc020266e:	00003517          	auipc	a0,0x3
ffffffffc0202672:	be250513          	addi	a0,a0,-1054 # ffffffffc0205250 <etext+0xd0e>
ffffffffc0202676:	cebfd0ef          	jal	ffffffffc0200360 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc020267a:	00003697          	auipc	a3,0x3
ffffffffc020267e:	f5e68693          	addi	a3,a3,-162 # ffffffffc02055d8 <etext+0x1096>
ffffffffc0202682:	00002617          	auipc	a2,0x2
ffffffffc0202686:	79e60613          	addi	a2,a2,1950 # ffffffffc0204e20 <etext+0x8de>
ffffffffc020268a:	1c300593          	li	a1,451
ffffffffc020268e:	00003517          	auipc	a0,0x3
ffffffffc0202692:	bc250513          	addi	a0,a0,-1086 # ffffffffc0205250 <etext+0xd0e>
ffffffffc0202696:	ccbfd0ef          	jal	ffffffffc0200360 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc020269a:	00003617          	auipc	a2,0x3
ffffffffc020269e:	c4e60613          	addi	a2,a2,-946 # ffffffffc02052e8 <etext+0xda6>
ffffffffc02026a2:	0bd00593          	li	a1,189
ffffffffc02026a6:	00003517          	auipc	a0,0x3
ffffffffc02026aa:	baa50513          	addi	a0,a0,-1110 # ffffffffc0205250 <etext+0xd0e>
ffffffffc02026ae:	cb3fd0ef          	jal	ffffffffc0200360 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc02026b2:	00003617          	auipc	a2,0x3
ffffffffc02026b6:	b7660613          	addi	a2,a2,-1162 # ffffffffc0205228 <etext+0xce6>
ffffffffc02026ba:	1a100593          	li	a1,417
ffffffffc02026be:	00003517          	auipc	a0,0x3
ffffffffc02026c2:	b9250513          	addi	a0,a0,-1134 # ffffffffc0205250 <etext+0xd0e>
ffffffffc02026c6:	c9bfd0ef          	jal	ffffffffc0200360 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02026ca:	00003697          	auipc	a3,0x3
ffffffffc02026ce:	d5e68693          	addi	a3,a3,-674 # ffffffffc0205428 <etext+0xee6>
ffffffffc02026d2:	00002617          	auipc	a2,0x2
ffffffffc02026d6:	74e60613          	addi	a2,a2,1870 # ffffffffc0204e20 <etext+0x8de>
ffffffffc02026da:	19f00593          	li	a1,415
ffffffffc02026de:	00003517          	auipc	a0,0x3
ffffffffc02026e2:	b7250513          	addi	a0,a0,-1166 # ffffffffc0205250 <etext+0xd0e>
ffffffffc02026e6:	c7bfd0ef          	jal	ffffffffc0200360 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc02026ea:	00003697          	auipc	a3,0x3
ffffffffc02026ee:	09668693          	addi	a3,a3,150 # ffffffffc0205780 <etext+0x123e>
ffffffffc02026f2:	00002617          	auipc	a2,0x2
ffffffffc02026f6:	72e60613          	addi	a2,a2,1838 # ffffffffc0204e20 <etext+0x8de>
ffffffffc02026fa:	1e300593          	li	a1,483
ffffffffc02026fe:	00003517          	auipc	a0,0x3
ffffffffc0202702:	b5250513          	addi	a0,a0,-1198 # ffffffffc0205250 <etext+0xd0e>
ffffffffc0202706:	c5bfd0ef          	jal	ffffffffc0200360 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc020270a:	00003697          	auipc	a3,0x3
ffffffffc020270e:	03e68693          	addi	a3,a3,62 # ffffffffc0205748 <etext+0x1206>
ffffffffc0202712:	00002617          	auipc	a2,0x2
ffffffffc0202716:	70e60613          	addi	a2,a2,1806 # ffffffffc0204e20 <etext+0x8de>
ffffffffc020271a:	1e000593          	li	a1,480
ffffffffc020271e:	00003517          	auipc	a0,0x3
ffffffffc0202722:	b3250513          	addi	a0,a0,-1230 # ffffffffc0205250 <etext+0xd0e>
ffffffffc0202726:	c3bfd0ef          	jal	ffffffffc0200360 <__panic>
    assert(page_ref(p) == 2);
ffffffffc020272a:	00003697          	auipc	a3,0x3
ffffffffc020272e:	fee68693          	addi	a3,a3,-18 # ffffffffc0205718 <etext+0x11d6>
ffffffffc0202732:	00002617          	auipc	a2,0x2
ffffffffc0202736:	6ee60613          	addi	a2,a2,1774 # ffffffffc0204e20 <etext+0x8de>
ffffffffc020273a:	1dc00593          	li	a1,476
ffffffffc020273e:	00003517          	auipc	a0,0x3
ffffffffc0202742:	b1250513          	addi	a0,a0,-1262 # ffffffffc0205250 <etext+0xd0e>
ffffffffc0202746:	c1bfd0ef          	jal	ffffffffc0200360 <__panic>

ffffffffc020274a <tlb_invalidate>:
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc020274a:	12000073          	sfence.vma
void tlb_invalidate(pde_t *pgdir, uintptr_t la) { flush_tlb(); }
ffffffffc020274e:	8082                	ret

ffffffffc0202750 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202750:	7179                	addi	sp,sp,-48
ffffffffc0202752:	e84a                	sd	s2,16(sp)
ffffffffc0202754:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0202756:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202758:	ec26                	sd	s1,24(sp)
ffffffffc020275a:	e44e                	sd	s3,8(sp)
ffffffffc020275c:	f406                	sd	ra,40(sp)
ffffffffc020275e:	f022                	sd	s0,32(sp)
ffffffffc0202760:	84ae                	mv	s1,a1
ffffffffc0202762:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0202764:	e7ffe0ef          	jal	ffffffffc02015e2 <alloc_pages>
    if (page != NULL) {
ffffffffc0202768:	c131                	beqz	a0,ffffffffc02027ac <pgdir_alloc_page+0x5c>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc020276a:	842a                	mv	s0,a0
ffffffffc020276c:	85aa                	mv	a1,a0
ffffffffc020276e:	86ce                	mv	a3,s3
ffffffffc0202770:	8626                	mv	a2,s1
ffffffffc0202772:	854a                	mv	a0,s2
ffffffffc0202774:	a9aff0ef          	jal	ffffffffc0201a0e <page_insert>
ffffffffc0202778:	ed11                	bnez	a0,ffffffffc0202794 <pgdir_alloc_page+0x44>
        if (swap_init_ok) {
ffffffffc020277a:	0000f797          	auipc	a5,0xf
ffffffffc020277e:	dce7a783          	lw	a5,-562(a5) # ffffffffc0211548 <swap_init_ok>
ffffffffc0202782:	e79d                	bnez	a5,ffffffffc02027b0 <pgdir_alloc_page+0x60>
}
ffffffffc0202784:	70a2                	ld	ra,40(sp)
ffffffffc0202786:	8522                	mv	a0,s0
ffffffffc0202788:	7402                	ld	s0,32(sp)
ffffffffc020278a:	64e2                	ld	s1,24(sp)
ffffffffc020278c:	6942                	ld	s2,16(sp)
ffffffffc020278e:	69a2                	ld	s3,8(sp)
ffffffffc0202790:	6145                	addi	sp,sp,48
ffffffffc0202792:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202794:	100027f3          	csrr	a5,sstatus
ffffffffc0202798:	8b89                	andi	a5,a5,2
ffffffffc020279a:	eba9                	bnez	a5,ffffffffc02027ec <pgdir_alloc_page+0x9c>
    { pmm_manager->free_pages(base, n); }
ffffffffc020279c:	0000f797          	auipc	a5,0xf
ffffffffc02027a0:	d7c7b783          	ld	a5,-644(a5) # ffffffffc0211518 <pmm_manager>
ffffffffc02027a4:	739c                	ld	a5,32(a5)
ffffffffc02027a6:	4585                	li	a1,1
ffffffffc02027a8:	8522                	mv	a0,s0
ffffffffc02027aa:	9782                	jalr	a5
            return NULL;
ffffffffc02027ac:	4401                	li	s0,0
ffffffffc02027ae:	bfd9                	j	ffffffffc0202784 <pgdir_alloc_page+0x34>
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc02027b0:	4681                	li	a3,0
ffffffffc02027b2:	8622                	mv	a2,s0
ffffffffc02027b4:	85a6                	mv	a1,s1
ffffffffc02027b6:	0000f517          	auipc	a0,0xf
ffffffffc02027ba:	dba53503          	ld	a0,-582(a0) # ffffffffc0211570 <check_mm_struct>
ffffffffc02027be:	09d000ef          	jal	ffffffffc020305a <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc02027c2:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc02027c4:	e024                	sd	s1,64(s0)
            assert(page_ref(page) == 1);
ffffffffc02027c6:	4785                	li	a5,1
ffffffffc02027c8:	faf70ee3          	beq	a4,a5,ffffffffc0202784 <pgdir_alloc_page+0x34>
ffffffffc02027cc:	00003697          	auipc	a3,0x3
ffffffffc02027d0:	ffc68693          	addi	a3,a3,-4 # ffffffffc02057c8 <etext+0x1286>
ffffffffc02027d4:	00002617          	auipc	a2,0x2
ffffffffc02027d8:	64c60613          	addi	a2,a2,1612 # ffffffffc0204e20 <etext+0x8de>
ffffffffc02027dc:	17d00593          	li	a1,381
ffffffffc02027e0:	00003517          	auipc	a0,0x3
ffffffffc02027e4:	a7050513          	addi	a0,a0,-1424 # ffffffffc0205250 <etext+0xd0e>
ffffffffc02027e8:	b79fd0ef          	jal	ffffffffc0200360 <__panic>
        intr_disable();
ffffffffc02027ec:	cf1fd0ef          	jal	ffffffffc02004dc <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc02027f0:	0000f797          	auipc	a5,0xf
ffffffffc02027f4:	d287b783          	ld	a5,-728(a5) # ffffffffc0211518 <pmm_manager>
ffffffffc02027f8:	739c                	ld	a5,32(a5)
ffffffffc02027fa:	8522                	mv	a0,s0
ffffffffc02027fc:	4585                	li	a1,1
ffffffffc02027fe:	9782                	jalr	a5
            return NULL;
ffffffffc0202800:	4401                	li	s0,0
        intr_enable();
ffffffffc0202802:	cd5fd0ef          	jal	ffffffffc02004d6 <intr_enable>
ffffffffc0202806:	bfbd                	j	ffffffffc0202784 <pgdir_alloc_page+0x34>

ffffffffc0202808 <kmalloc>:
}

void *kmalloc(size_t n) {//分配至少n个连续的字节，这里实现得不精细，占用的只能是整数个页。
ffffffffc0202808:	1141                	addi	sp,sp,-16
    void *ptr = NULL;
    struct Page *base = NULL;
    assert(n > 0 && n < 1024 * 0124);
ffffffffc020280a:	67d5                	lui	a5,0x15
void *kmalloc(size_t n) {//分配至少n个连续的字节，这里实现得不精细，占用的只能是整数个页。
ffffffffc020280c:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc020280e:	fff50713          	addi	a4,a0,-1
ffffffffc0202812:	17f9                	addi	a5,a5,-2 # 14ffe <kern_entry-0xffffffffc01eb002>
ffffffffc0202814:	06e7e363          	bltu	a5,a4,ffffffffc020287a <kmalloc+0x72>
    int num_pages = (n + PGSIZE - 1) / PGSIZE;//向上取整到整数个页
ffffffffc0202818:	6785                	lui	a5,0x1
ffffffffc020281a:	17fd                	addi	a5,a5,-1 # fff <kern_entry-0xffffffffc01ff001>
ffffffffc020281c:	953e                	add	a0,a0,a5
    base = alloc_pages(num_pages);
ffffffffc020281e:	8131                	srli	a0,a0,0xc
ffffffffc0202820:	dc3fe0ef          	jal	ffffffffc02015e2 <alloc_pages>
    assert(base != NULL);//如果分配失败就直接panic
ffffffffc0202824:	c941                	beqz	a0,ffffffffc02028b4 <kmalloc+0xac>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202826:	f8e397b7          	lui	a5,0xf8e39
ffffffffc020282a:	e3978793          	addi	a5,a5,-455 # fffffffff8e38e39 <end+0x38c278c1>
ffffffffc020282e:	07b2                	slli	a5,a5,0xc
ffffffffc0202830:	e3978793          	addi	a5,a5,-455
ffffffffc0202834:	07b2                	slli	a5,a5,0xc
ffffffffc0202836:	0000f717          	auipc	a4,0xf
ffffffffc020283a:	d0a73703          	ld	a4,-758(a4) # ffffffffc0211540 <pages>
ffffffffc020283e:	e3978793          	addi	a5,a5,-455
ffffffffc0202842:	8d19                	sub	a0,a0,a4
ffffffffc0202844:	07b2                	slli	a5,a5,0xc
ffffffffc0202846:	e3978793          	addi	a5,a5,-455
ffffffffc020284a:	850d                	srai	a0,a0,0x3
ffffffffc020284c:	02f50533          	mul	a0,a0,a5
ffffffffc0202850:	000807b7          	lui	a5,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202854:	0000f717          	auipc	a4,0xf
ffffffffc0202858:	ce473703          	ld	a4,-796(a4) # ffffffffc0211538 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020285c:	953e                	add	a0,a0,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020285e:	00c51793          	slli	a5,a0,0xc
ffffffffc0202862:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202864:	0532                	slli	a0,a0,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202866:	02e7fa63          	bgeu	a5,a4,ffffffffc020289a <kmalloc+0x92>
    ptr = page2kva(base); //分配的内存的起始位置（虚拟地址），
    return ptr;
}
ffffffffc020286a:	60a2                	ld	ra,8(sp)
ffffffffc020286c:	0000f797          	auipc	a5,0xf
ffffffffc0202870:	cc47b783          	ld	a5,-828(a5) # ffffffffc0211530 <va_pa_offset>
ffffffffc0202874:	953e                	add	a0,a0,a5
ffffffffc0202876:	0141                	addi	sp,sp,16
ffffffffc0202878:	8082                	ret
    assert(n > 0 && n < 1024 * 0124);
ffffffffc020287a:	00003697          	auipc	a3,0x3
ffffffffc020287e:	f6668693          	addi	a3,a3,-154 # ffffffffc02057e0 <etext+0x129e>
ffffffffc0202882:	00002617          	auipc	a2,0x2
ffffffffc0202886:	59e60613          	addi	a2,a2,1438 # ffffffffc0204e20 <etext+0x8de>
ffffffffc020288a:	1f300593          	li	a1,499
ffffffffc020288e:	00003517          	auipc	a0,0x3
ffffffffc0202892:	9c250513          	addi	a0,a0,-1598 # ffffffffc0205250 <etext+0xd0e>
ffffffffc0202896:	acbfd0ef          	jal	ffffffffc0200360 <__panic>
ffffffffc020289a:	86aa                	mv	a3,a0
ffffffffc020289c:	00003617          	auipc	a2,0x3
ffffffffc02028a0:	98c60613          	addi	a2,a2,-1652 # ffffffffc0205228 <etext+0xce6>
ffffffffc02028a4:	06a00593          	li	a1,106
ffffffffc02028a8:	00003517          	auipc	a0,0x3
ffffffffc02028ac:	94850513          	addi	a0,a0,-1720 # ffffffffc02051f0 <etext+0xcae>
ffffffffc02028b0:	ab1fd0ef          	jal	ffffffffc0200360 <__panic>
    assert(base != NULL);//如果分配失败就直接panic
ffffffffc02028b4:	00003697          	auipc	a3,0x3
ffffffffc02028b8:	f4c68693          	addi	a3,a3,-180 # ffffffffc0205800 <etext+0x12be>
ffffffffc02028bc:	00002617          	auipc	a2,0x2
ffffffffc02028c0:	56460613          	addi	a2,a2,1380 # ffffffffc0204e20 <etext+0x8de>
ffffffffc02028c4:	1f600593          	li	a1,502
ffffffffc02028c8:	00003517          	auipc	a0,0x3
ffffffffc02028cc:	98850513          	addi	a0,a0,-1656 # ffffffffc0205250 <etext+0xd0e>
ffffffffc02028d0:	a91fd0ef          	jal	ffffffffc0200360 <__panic>

ffffffffc02028d4 <kfree>:

void kfree(void *ptr, size_t n) {//从某个位置开始释放n个字节
ffffffffc02028d4:	1101                	addi	sp,sp,-32
    assert(n > 0 && n < 1024 * 0124);
ffffffffc02028d6:	67d5                	lui	a5,0x15
void kfree(void *ptr, size_t n) {//从某个位置开始释放n个字节
ffffffffc02028d8:	ec06                	sd	ra,24(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc02028da:	fff58713          	addi	a4,a1,-1
ffffffffc02028de:	17f9                	addi	a5,a5,-2 # 14ffe <kern_entry-0xffffffffc01eb002>
ffffffffc02028e0:	0ae7ee63          	bltu	a5,a4,ffffffffc020299c <kfree+0xc8>
    assert(ptr != NULL);
ffffffffc02028e4:	cd41                	beqz	a0,ffffffffc020297c <kfree+0xa8>
    struct Page *base = NULL;
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc02028e6:	6785                	lui	a5,0x1
ffffffffc02028e8:	17fd                	addi	a5,a5,-1 # fff <kern_entry-0xffffffffc01ff001>
ffffffffc02028ea:	95be                	add	a1,a1,a5
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc02028ec:	c02007b7          	lui	a5,0xc0200
ffffffffc02028f0:	81b1                	srli	a1,a1,0xc
ffffffffc02028f2:	06f56863          	bltu	a0,a5,ffffffffc0202962 <kfree+0x8e>
ffffffffc02028f6:	0000f797          	auipc	a5,0xf
ffffffffc02028fa:	c3a7b783          	ld	a5,-966(a5) # ffffffffc0211530 <va_pa_offset>
ffffffffc02028fe:	8d1d                	sub	a0,a0,a5
    if (PPN(pa) >= npage) {
ffffffffc0202900:	8131                	srli	a0,a0,0xc
ffffffffc0202902:	0000f797          	auipc	a5,0xf
ffffffffc0202906:	c367b783          	ld	a5,-970(a5) # ffffffffc0211538 <npage>
ffffffffc020290a:	04f57a63          	bgeu	a0,a5,ffffffffc020295e <kfree+0x8a>
    return &pages[PPN(pa) - nbase];
ffffffffc020290e:	fff807b7          	lui	a5,0xfff80
ffffffffc0202912:	953e                	add	a0,a0,a5
ffffffffc0202914:	00351793          	slli	a5,a0,0x3
ffffffffc0202918:	97aa                	add	a5,a5,a0
ffffffffc020291a:	078e                	slli	a5,a5,0x3
ffffffffc020291c:	0000f517          	auipc	a0,0xf
ffffffffc0202920:	c2453503          	ld	a0,-988(a0) # ffffffffc0211540 <pages>
ffffffffc0202924:	953e                	add	a0,a0,a5
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202926:	100027f3          	csrr	a5,sstatus
ffffffffc020292a:	8b89                	andi	a5,a5,2
ffffffffc020292c:	eb89                	bnez	a5,ffffffffc020293e <kfree+0x6a>
    { pmm_manager->free_pages(base, n); }
ffffffffc020292e:	0000f797          	auipc	a5,0xf
ffffffffc0202932:	bea7b783          	ld	a5,-1046(a5) # ffffffffc0211518 <pmm_manager>
    但是如果程序员写错了呢？调用kfree的时候传入的n和调用kmalloc传入的n不一样？
    就像你平时在windows/linux写C语言一样，会出各种奇奇怪怪的bug。
    */
    base = kva2page(ptr);
    free_pages(base, num_pages);
}
ffffffffc0202936:	60e2                	ld	ra,24(sp)
    { pmm_manager->free_pages(base, n); }
ffffffffc0202938:	739c                	ld	a5,32(a5)
}
ffffffffc020293a:	6105                	addi	sp,sp,32
    { pmm_manager->free_pages(base, n); }
ffffffffc020293c:	8782                	jr	a5
        intr_disable();
ffffffffc020293e:	e42a                	sd	a0,8(sp)
ffffffffc0202940:	e02e                	sd	a1,0(sp)
ffffffffc0202942:	b9bfd0ef          	jal	ffffffffc02004dc <intr_disable>
ffffffffc0202946:	0000f797          	auipc	a5,0xf
ffffffffc020294a:	bd27b783          	ld	a5,-1070(a5) # ffffffffc0211518 <pmm_manager>
ffffffffc020294e:	6582                	ld	a1,0(sp)
ffffffffc0202950:	6522                	ld	a0,8(sp)
ffffffffc0202952:	739c                	ld	a5,32(a5)
ffffffffc0202954:	9782                	jalr	a5
}
ffffffffc0202956:	60e2                	ld	ra,24(sp)
ffffffffc0202958:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020295a:	b7dfd06f          	j	ffffffffc02004d6 <intr_enable>
ffffffffc020295e:	c4dfe0ef          	jal	ffffffffc02015aa <pa2page.part.0>
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0202962:	86aa                	mv	a3,a0
ffffffffc0202964:	00003617          	auipc	a2,0x3
ffffffffc0202968:	98460613          	addi	a2,a2,-1660 # ffffffffc02052e8 <etext+0xda6>
ffffffffc020296c:	06c00593          	li	a1,108
ffffffffc0202970:	00003517          	auipc	a0,0x3
ffffffffc0202974:	88050513          	addi	a0,a0,-1920 # ffffffffc02051f0 <etext+0xcae>
ffffffffc0202978:	9e9fd0ef          	jal	ffffffffc0200360 <__panic>
    assert(ptr != NULL);
ffffffffc020297c:	00003697          	auipc	a3,0x3
ffffffffc0202980:	e9468693          	addi	a3,a3,-364 # ffffffffc0205810 <etext+0x12ce>
ffffffffc0202984:	00002617          	auipc	a2,0x2
ffffffffc0202988:	49c60613          	addi	a2,a2,1180 # ffffffffc0204e20 <etext+0x8de>
ffffffffc020298c:	1fd00593          	li	a1,509
ffffffffc0202990:	00003517          	auipc	a0,0x3
ffffffffc0202994:	8c050513          	addi	a0,a0,-1856 # ffffffffc0205250 <etext+0xd0e>
ffffffffc0202998:	9c9fd0ef          	jal	ffffffffc0200360 <__panic>
    assert(n > 0 && n < 1024 * 0124);
ffffffffc020299c:	00003697          	auipc	a3,0x3
ffffffffc02029a0:	e4468693          	addi	a3,a3,-444 # ffffffffc02057e0 <etext+0x129e>
ffffffffc02029a4:	00002617          	auipc	a2,0x2
ffffffffc02029a8:	47c60613          	addi	a2,a2,1148 # ffffffffc0204e20 <etext+0x8de>
ffffffffc02029ac:	1fc00593          	li	a1,508
ffffffffc02029b0:	00003517          	auipc	a0,0x3
ffffffffc02029b4:	8a050513          	addi	a0,a0,-1888 # ffffffffc0205250 <etext+0xd0e>
ffffffffc02029b8:	9a9fd0ef          	jal	ffffffffc0200360 <__panic>

ffffffffc02029bc <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc02029bc:	7135                	addi	sp,sp,-160
ffffffffc02029be:	ed06                	sd	ra,152(sp)
     swapfs_init();
ffffffffc02029c0:	494010ef          	jal	ffffffffc0203e54 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc02029c4:	0000f697          	auipc	a3,0xf
ffffffffc02029c8:	b8c6b683          	ld	a3,-1140(a3) # ffffffffc0211550 <max_swap_offset>
ffffffffc02029cc:	010007b7          	lui	a5,0x1000
ffffffffc02029d0:	ff968713          	addi	a4,a3,-7
ffffffffc02029d4:	17e1                	addi	a5,a5,-8 # fffff8 <kern_entry-0xffffffffbf200008>
ffffffffc02029d6:	40e7e463          	bltu	a5,a4,ffffffffc0202dde <swap_init+0x422>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     sm = &swap_manager_clock;//use first in first out Page Replacement Algorithm
ffffffffc02029da:	00007797          	auipc	a5,0x7
ffffffffc02029de:	62678793          	addi	a5,a5,1574 # ffffffffc020a000 <swap_manager_clock>
     //sm = &swap_manager_fifo;
     int r = sm->init();
ffffffffc02029e2:	6798                	ld	a4,8(a5)
ffffffffc02029e4:	fcce                	sd	s3,120(sp)
ffffffffc02029e6:	f0da                	sd	s6,96(sp)
     sm = &swap_manager_clock;//use first in first out Page Replacement Algorithm
ffffffffc02029e8:	0000fb17          	auipc	s6,0xf
ffffffffc02029ec:	b70b0b13          	addi	s6,s6,-1168 # ffffffffc0211558 <sm>
ffffffffc02029f0:	00fb3023          	sd	a5,0(s6)
     int r = sm->init();
ffffffffc02029f4:	9702                	jalr	a4
ffffffffc02029f6:	89aa                	mv	s3,a0
     
     if (r == 0)
ffffffffc02029f8:	c519                	beqz	a0,ffffffffc0202a06 <swap_init+0x4a>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc02029fa:	60ea                	ld	ra,152(sp)
ffffffffc02029fc:	7b06                	ld	s6,96(sp)
ffffffffc02029fe:	854e                	mv	a0,s3
ffffffffc0202a00:	79e6                	ld	s3,120(sp)
ffffffffc0202a02:	610d                	addi	sp,sp,160
ffffffffc0202a04:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202a06:	000b3783          	ld	a5,0(s6)
ffffffffc0202a0a:	00003517          	auipc	a0,0x3
ffffffffc0202a0e:	e4650513          	addi	a0,a0,-442 # ffffffffc0205850 <etext+0x130e>
ffffffffc0202a12:	e922                	sd	s0,144(sp)
ffffffffc0202a14:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc0202a16:	4785                	li	a5,1
ffffffffc0202a18:	e526                	sd	s1,136(sp)
ffffffffc0202a1a:	e0ea                	sd	s10,64(sp)
ffffffffc0202a1c:	0000f717          	auipc	a4,0xf
ffffffffc0202a20:	b2f72623          	sw	a5,-1236(a4) # ffffffffc0211548 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202a24:	e14a                	sd	s2,128(sp)
ffffffffc0202a26:	f8d2                	sd	s4,112(sp)
ffffffffc0202a28:	f4d6                	sd	s5,104(sp)
ffffffffc0202a2a:	ecde                	sd	s7,88(sp)
ffffffffc0202a2c:	e8e2                	sd	s8,80(sp)
ffffffffc0202a2e:	e4e6                	sd	s9,72(sp)
ffffffffc0202a30:	fc6e                	sd	s11,56(sp)
    return listelm->next;
ffffffffc0202a32:	0000e497          	auipc	s1,0xe
ffffffffc0202a36:	60e48493          	addi	s1,s1,1550 # ffffffffc0211040 <free_area>
ffffffffc0202a3a:	e80fd0ef          	jal	ffffffffc02000ba <cprintf>
ffffffffc0202a3e:	649c                	ld	a5,8(s1)

static void
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
ffffffffc0202a40:	4401                	li	s0,0
ffffffffc0202a42:	4d01                	li	s10,0
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202a44:	2e978363          	beq	a5,s1,ffffffffc0202d2a <swap_init+0x36e>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0202a48:	fe87b703          	ld	a4,-24(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0202a4c:	8b09                	andi	a4,a4,2
ffffffffc0202a4e:	2e070063          	beqz	a4,ffffffffc0202d2e <swap_init+0x372>
        count ++, total += p->property;
ffffffffc0202a52:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202a56:	679c                	ld	a5,8(a5)
ffffffffc0202a58:	2d05                	addiw	s10,s10,1
ffffffffc0202a5a:	9c39                	addw	s0,s0,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202a5c:	fe9796e3          	bne	a5,s1,ffffffffc0202a48 <swap_init+0x8c>
     }
     assert(total == nr_free_pages());
ffffffffc0202a60:	8922                	mv	s2,s0
ffffffffc0202a62:	c51fe0ef          	jal	ffffffffc02016b2 <nr_free_pages>
ffffffffc0202a66:	4b251463          	bne	a0,s2,ffffffffc0202f0e <swap_init+0x552>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0202a6a:	8622                	mv	a2,s0
ffffffffc0202a6c:	85ea                	mv	a1,s10
ffffffffc0202a6e:	00003517          	auipc	a0,0x3
ffffffffc0202a72:	dfa50513          	addi	a0,a0,-518 # ffffffffc0205868 <etext+0x1326>
ffffffffc0202a76:	e44fd0ef          	jal	ffffffffc02000ba <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0202a7a:	367000ef          	jal	ffffffffc02035e0 <mm_create>
ffffffffc0202a7e:	ec2a                	sd	a0,24(sp)
     assert(mm != NULL);
ffffffffc0202a80:	56050763          	beqz	a0,ffffffffc0202fee <swap_init+0x632>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc0202a84:	0000f797          	auipc	a5,0xf
ffffffffc0202a88:	aec78793          	addi	a5,a5,-1300 # ffffffffc0211570 <check_mm_struct>
ffffffffc0202a8c:	6398                	ld	a4,0(a5)
ffffffffc0202a8e:	58071063          	bnez	a4,ffffffffc020300e <swap_init+0x652>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202a92:	0000f697          	auipc	a3,0xf
ffffffffc0202a96:	a966b683          	ld	a3,-1386(a3) # ffffffffc0211528 <boot_pgdir>
     check_mm_struct = mm;
ffffffffc0202a9a:	6662                	ld	a2,24(sp)
     assert(pgdir[0] == 0);
ffffffffc0202a9c:	6298                	ld	a4,0(a3)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202a9e:	e836                	sd	a3,16(sp)
     check_mm_struct = mm;
ffffffffc0202aa0:	e390                	sd	a2,0(a5)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202aa2:	ee14                	sd	a3,24(a2)
     assert(pgdir[0] == 0);
ffffffffc0202aa4:	40071563          	bnez	a4,ffffffffc0202eae <swap_init+0x4f2>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0202aa8:	6599                	lui	a1,0x6
ffffffffc0202aaa:	460d                	li	a2,3
ffffffffc0202aac:	6505                	lui	a0,0x1
ffffffffc0202aae:	37b000ef          	jal	ffffffffc0203628 <vma_create>
ffffffffc0202ab2:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0202ab4:	40050d63          	beqz	a0,ffffffffc0202ece <swap_init+0x512>

     insert_vma_struct(mm, vma);
ffffffffc0202ab8:	6962                	ld	s2,24(sp)
ffffffffc0202aba:	854a                	mv	a0,s2
ffffffffc0202abc:	3db000ef          	jal	ffffffffc0203696 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc0202ac0:	00003517          	auipc	a0,0x3
ffffffffc0202ac4:	e1850513          	addi	a0,a0,-488 # ffffffffc02058d8 <etext+0x1396>
ffffffffc0202ac8:	df2fd0ef          	jal	ffffffffc02000ba <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0202acc:	01893503          	ld	a0,24(s2)
ffffffffc0202ad0:	4605                	li	a2,1
ffffffffc0202ad2:	6585                	lui	a1,0x1
ffffffffc0202ad4:	c19fe0ef          	jal	ffffffffc02016ec <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0202ad8:	40050b63          	beqz	a0,ffffffffc0202eee <swap_init+0x532>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202adc:	00003517          	auipc	a0,0x3
ffffffffc0202ae0:	e4c50513          	addi	a0,a0,-436 # ffffffffc0205928 <etext+0x13e6>
ffffffffc0202ae4:	0000e917          	auipc	s2,0xe
ffffffffc0202ae8:	59490913          	addi	s2,s2,1428 # ffffffffc0211078 <check_rp>
ffffffffc0202aec:	dcefd0ef          	jal	ffffffffc02000ba <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202af0:	0000ea17          	auipc	s4,0xe
ffffffffc0202af4:	5a8a0a13          	addi	s4,s4,1448 # ffffffffc0211098 <swap_out_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202af8:	8c4a                	mv	s8,s2
          check_rp[i] = alloc_page();
ffffffffc0202afa:	4505                	li	a0,1
ffffffffc0202afc:	ae7fe0ef          	jal	ffffffffc02015e2 <alloc_pages>
ffffffffc0202b00:	00ac3023          	sd	a0,0(s8)
          assert(check_rp[i] != NULL );
ffffffffc0202b04:	2a050d63          	beqz	a0,ffffffffc0202dbe <swap_init+0x402>
ffffffffc0202b08:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0202b0a:	8b89                	andi	a5,a5,2
ffffffffc0202b0c:	28079963          	bnez	a5,ffffffffc0202d9e <swap_init+0x3e2>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202b10:	0c21                	addi	s8,s8,8
ffffffffc0202b12:	ff4c14e3          	bne	s8,s4,ffffffffc0202afa <swap_init+0x13e>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0202b16:	609c                	ld	a5,0(s1)
ffffffffc0202b18:	0084bd83          	ld	s11,8(s1)
    elm->prev = elm->next = elm;
ffffffffc0202b1c:	e084                	sd	s1,0(s1)
ffffffffc0202b1e:	f03e                	sd	a5,32(sp)
     list_init(&free_list);
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
ffffffffc0202b20:	489c                	lw	a5,16(s1)
ffffffffc0202b22:	e484                	sd	s1,8(s1)
     nr_free = 0;
ffffffffc0202b24:	0000ec17          	auipc	s8,0xe
ffffffffc0202b28:	554c0c13          	addi	s8,s8,1364 # ffffffffc0211078 <check_rp>
     unsigned int nr_free_store = nr_free;
ffffffffc0202b2c:	f43e                	sd	a5,40(sp)
     nr_free = 0;
ffffffffc0202b2e:	0000e797          	auipc	a5,0xe
ffffffffc0202b32:	5207a123          	sw	zero,1314(a5) # ffffffffc0211050 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0202b36:	000c3503          	ld	a0,0(s8)
ffffffffc0202b3a:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202b3c:	0c21                	addi	s8,s8,8
        free_pages(check_rp[i],1);
ffffffffc0202b3e:	b35fe0ef          	jal	ffffffffc0201672 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202b42:	ff4c1ae3          	bne	s8,s4,ffffffffc0202b36 <swap_init+0x17a>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202b46:	0104ac03          	lw	s8,16(s1)
ffffffffc0202b4a:	4791                	li	a5,4
ffffffffc0202b4c:	4efc1163          	bne	s8,a5,ffffffffc020302e <swap_init+0x672>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0202b50:	00003517          	auipc	a0,0x3
ffffffffc0202b54:	e6050513          	addi	a0,a0,-416 # ffffffffc02059b0 <etext+0x146e>
ffffffffc0202b58:	d62fd0ef          	jal	ffffffffc02000ba <cprintf>
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0202b5c:	0000f797          	auipc	a5,0xf
ffffffffc0202b60:	a007a623          	sw	zero,-1524(a5) # ffffffffc0211568 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202b64:	6785                	lui	a5,0x1
ffffffffc0202b66:	4529                	li	a0,10
ffffffffc0202b68:	00a78023          	sb	a0,0(a5) # 1000 <kern_entry-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc0202b6c:	0000f597          	auipc	a1,0xf
ffffffffc0202b70:	9fc5a583          	lw	a1,-1540(a1) # ffffffffc0211568 <pgfault_num>
ffffffffc0202b74:	4605                	li	a2,1
ffffffffc0202b76:	0000f797          	auipc	a5,0xf
ffffffffc0202b7a:	9f278793          	addi	a5,a5,-1550 # ffffffffc0211568 <pgfault_num>
ffffffffc0202b7e:	42c59863          	bne	a1,a2,ffffffffc0202fae <swap_init+0x5f2>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0202b82:	6605                	lui	a2,0x1
ffffffffc0202b84:	00a60823          	sb	a0,16(a2) # 1010 <kern_entry-0xffffffffc01feff0>
     assert(pgfault_num==1);
ffffffffc0202b88:	4388                	lw	a0,0(a5)
ffffffffc0202b8a:	44b51263          	bne	a0,a1,ffffffffc0202fce <swap_init+0x612>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202b8e:	6609                	lui	a2,0x2
ffffffffc0202b90:	45ad                	li	a1,11
ffffffffc0202b92:	00b60023          	sb	a1,0(a2) # 2000 <kern_entry-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc0202b96:	4390                	lw	a2,0(a5)
ffffffffc0202b98:	4809                	li	a6,2
ffffffffc0202b9a:	0006051b          	sext.w	a0,a2
ffffffffc0202b9e:	39061863          	bne	a2,a6,ffffffffc0202f2e <swap_init+0x572>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0202ba2:	6609                	lui	a2,0x2
ffffffffc0202ba4:	00b60823          	sb	a1,16(a2) # 2010 <kern_entry-0xffffffffc01fdff0>
     assert(pgfault_num==2);
ffffffffc0202ba8:	438c                	lw	a1,0(a5)
ffffffffc0202baa:	3aa59263          	bne	a1,a0,ffffffffc0202f4e <swap_init+0x592>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202bae:	660d                	lui	a2,0x3
ffffffffc0202bb0:	45b1                	li	a1,12
ffffffffc0202bb2:	00b60023          	sb	a1,0(a2) # 3000 <kern_entry-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc0202bb6:	4390                	lw	a2,0(a5)
ffffffffc0202bb8:	480d                	li	a6,3
ffffffffc0202bba:	0006051b          	sext.w	a0,a2
ffffffffc0202bbe:	3b061863          	bne	a2,a6,ffffffffc0202f6e <swap_init+0x5b2>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0202bc2:	660d                	lui	a2,0x3
ffffffffc0202bc4:	00b60823          	sb	a1,16(a2) # 3010 <kern_entry-0xffffffffc01fcff0>
     assert(pgfault_num==3);
ffffffffc0202bc8:	438c                	lw	a1,0(a5)
ffffffffc0202bca:	3ca59263          	bne	a1,a0,ffffffffc0202f8e <swap_init+0x5d2>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202bce:	6611                	lui	a2,0x4
ffffffffc0202bd0:	45b5                	li	a1,13
ffffffffc0202bd2:	00b60023          	sb	a1,0(a2) # 4000 <kern_entry-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc0202bd6:	4390                	lw	a2,0(a5)
ffffffffc0202bd8:	0006051b          	sext.w	a0,a2
ffffffffc0202bdc:	25861963          	bne	a2,s8,ffffffffc0202e2e <swap_init+0x472>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0202be0:	6611                	lui	a2,0x4
ffffffffc0202be2:	00b60823          	sb	a1,16(a2) # 4010 <kern_entry-0xffffffffc01fbff0>
     assert(pgfault_num==4);
ffffffffc0202be6:	439c                	lw	a5,0(a5)
ffffffffc0202be8:	26a79363          	bne	a5,a0,ffffffffc0202e4e <swap_init+0x492>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0202bec:	489c                	lw	a5,16(s1)
ffffffffc0202bee:	28079063          	bnez	a5,ffffffffc0202e6e <swap_init+0x4b2>
ffffffffc0202bf2:	0000e797          	auipc	a5,0xe
ffffffffc0202bf6:	4ce78793          	addi	a5,a5,1230 # ffffffffc02110c0 <swap_in_seq_no>
ffffffffc0202bfa:	0000e617          	auipc	a2,0xe
ffffffffc0202bfe:	49e60613          	addi	a2,a2,1182 # ffffffffc0211098 <swap_out_seq_no>
ffffffffc0202c02:	0000e517          	auipc	a0,0xe
ffffffffc0202c06:	4e650513          	addi	a0,a0,1254 # ffffffffc02110e8 <pra_list_head2>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0202c0a:	55fd                	li	a1,-1
ffffffffc0202c0c:	c38c                	sw	a1,0(a5)
ffffffffc0202c0e:	c20c                	sw	a1,0(a2)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0202c10:	0791                	addi	a5,a5,4
ffffffffc0202c12:	0611                	addi	a2,a2,4
ffffffffc0202c14:	fea79ce3          	bne	a5,a0,ffffffffc0202c0c <swap_init+0x250>
ffffffffc0202c18:	0000e817          	auipc	a6,0xe
ffffffffc0202c1c:	44080813          	addi	a6,a6,1088 # ffffffffc0211058 <check_ptep>
ffffffffc0202c20:	0000e897          	auipc	a7,0xe
ffffffffc0202c24:	45888893          	addi	a7,a7,1112 # ffffffffc0211078 <check_rp>
ffffffffc0202c28:	6a85                	lui	s5,0x1
    if (PPN(pa) >= npage) {
ffffffffc0202c2a:	0000fb97          	auipc	s7,0xf
ffffffffc0202c2e:	90eb8b93          	addi	s7,s7,-1778 # ffffffffc0211538 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0202c32:	0000fc17          	auipc	s8,0xf
ffffffffc0202c36:	90ec0c13          	addi	s8,s8,-1778 # ffffffffc0211540 <pages>
ffffffffc0202c3a:	00003c97          	auipc	s9,0x3
ffffffffc0202c3e:	72ec8c93          	addi	s9,s9,1838 # ffffffffc0206368 <nbase>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202c42:	6542                	ld	a0,16(sp)
         check_ptep[i]=0;
ffffffffc0202c44:	00083023          	sd	zero,0(a6)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202c48:	4601                	li	a2,0
ffffffffc0202c4a:	85d6                	mv	a1,s5
ffffffffc0202c4c:	e446                	sd	a7,8(sp)
         check_ptep[i]=0;
ffffffffc0202c4e:	e042                	sd	a6,0(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202c50:	a9dfe0ef          	jal	ffffffffc02016ec <get_pte>
ffffffffc0202c54:	6802                	ld	a6,0(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0202c56:	68a2                	ld	a7,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202c58:	00a83023          	sd	a0,0(a6)
         assert(check_ptep[i] != NULL);
ffffffffc0202c5c:	1a050963          	beqz	a0,ffffffffc0202e0e <swap_init+0x452>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202c60:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202c62:	0017f613          	andi	a2,a5,1
ffffffffc0202c66:	10060463          	beqz	a2,ffffffffc0202d6e <swap_init+0x3b2>
    if (PPN(pa) >= npage) {
ffffffffc0202c6a:	000bb603          	ld	a2,0(s7)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202c6e:	078a                	slli	a5,a5,0x2
ffffffffc0202c70:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202c72:	10c7fa63          	bgeu	a5,a2,ffffffffc0202d86 <swap_init+0x3ca>
    return &pages[PPN(pa) - nbase];
ffffffffc0202c76:	000cb603          	ld	a2,0(s9)
ffffffffc0202c7a:	000c3503          	ld	a0,0(s8)
ffffffffc0202c7e:	0008bf03          	ld	t5,0(a7)
ffffffffc0202c82:	8f91                	sub	a5,a5,a2
ffffffffc0202c84:	00379613          	slli	a2,a5,0x3
ffffffffc0202c88:	97b2                	add	a5,a5,a2
ffffffffc0202c8a:	078e                	slli	a5,a5,0x3
ffffffffc0202c8c:	6705                	lui	a4,0x1
ffffffffc0202c8e:	97aa                	add	a5,a5,a0
ffffffffc0202c90:	08a1                	addi	a7,a7,8
ffffffffc0202c92:	0821                	addi	a6,a6,8
ffffffffc0202c94:	9aba                	add	s5,s5,a4
ffffffffc0202c96:	0aff1c63          	bne	t5,a5,ffffffffc0202d4e <swap_init+0x392>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202c9a:	6795                	lui	a5,0x5
ffffffffc0202c9c:	fafa93e3          	bne	s5,a5,ffffffffc0202c42 <swap_init+0x286>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0202ca0:	00003517          	auipc	a0,0x3
ffffffffc0202ca4:	db850513          	addi	a0,a0,-584 # ffffffffc0205a58 <etext+0x1516>
ffffffffc0202ca8:	c12fd0ef          	jal	ffffffffc02000ba <cprintf>
    int ret = sm->check_swap();
ffffffffc0202cac:	000b3783          	ld	a5,0(s6)
ffffffffc0202cb0:	7f9c                	ld	a5,56(a5)
ffffffffc0202cb2:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0202cb4:	1c051d63          	bnez	a0,ffffffffc0202e8e <swap_init+0x4d2>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0202cb8:	00093503          	ld	a0,0(s2)
ffffffffc0202cbc:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202cbe:	0921                	addi	s2,s2,8
         free_pages(check_rp[i],1);
ffffffffc0202cc0:	9b3fe0ef          	jal	ffffffffc0201672 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202cc4:	ff491ae3          	bne	s2,s4,ffffffffc0202cb8 <swap_init+0x2fc>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc0202cc8:	6562                	ld	a0,24(sp)
ffffffffc0202cca:	29d000ef          	jal	ffffffffc0203766 <mm_destroy>
         
     nr_free = nr_free_store;
ffffffffc0202cce:	77a2                	ld	a5,40(sp)
     free_list = free_list_store;
ffffffffc0202cd0:	01b4b423          	sd	s11,8(s1)
     nr_free = nr_free_store;
ffffffffc0202cd4:	c89c                	sw	a5,16(s1)
     free_list = free_list_store;
ffffffffc0202cd6:	7782                	ld	a5,32(sp)
ffffffffc0202cd8:	e09c                	sd	a5,0(s1)

     
     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202cda:	009d8a63          	beq	s11,s1,ffffffffc0202cee <swap_init+0x332>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0202cde:	ff8da783          	lw	a5,-8(s11)
    return listelm->next;
ffffffffc0202ce2:	008dbd83          	ld	s11,8(s11)
ffffffffc0202ce6:	3d7d                	addiw	s10,s10,-1
ffffffffc0202ce8:	9c1d                	subw	s0,s0,a5
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202cea:	fe9d9ae3          	bne	s11,s1,ffffffffc0202cde <swap_init+0x322>
     }
     cprintf("count is %d, total is %d\n",count,total);
ffffffffc0202cee:	8622                	mv	a2,s0
ffffffffc0202cf0:	85ea                	mv	a1,s10
ffffffffc0202cf2:	00003517          	auipc	a0,0x3
ffffffffc0202cf6:	d9650513          	addi	a0,a0,-618 # ffffffffc0205a88 <etext+0x1546>
ffffffffc0202cfa:	bc0fd0ef          	jal	ffffffffc02000ba <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
ffffffffc0202cfe:	00003517          	auipc	a0,0x3
ffffffffc0202d02:	daa50513          	addi	a0,a0,-598 # ffffffffc0205aa8 <etext+0x1566>
ffffffffc0202d06:	bb4fd0ef          	jal	ffffffffc02000ba <cprintf>
}
ffffffffc0202d0a:	60ea                	ld	ra,152(sp)
     cprintf("check_swap() succeeded!\n");
ffffffffc0202d0c:	644a                	ld	s0,144(sp)
ffffffffc0202d0e:	64aa                	ld	s1,136(sp)
ffffffffc0202d10:	690a                	ld	s2,128(sp)
ffffffffc0202d12:	7a46                	ld	s4,112(sp)
ffffffffc0202d14:	7aa6                	ld	s5,104(sp)
ffffffffc0202d16:	6be6                	ld	s7,88(sp)
ffffffffc0202d18:	6c46                	ld	s8,80(sp)
ffffffffc0202d1a:	6ca6                	ld	s9,72(sp)
ffffffffc0202d1c:	6d06                	ld	s10,64(sp)
ffffffffc0202d1e:	7de2                	ld	s11,56(sp)
}
ffffffffc0202d20:	7b06                	ld	s6,96(sp)
ffffffffc0202d22:	854e                	mv	a0,s3
ffffffffc0202d24:	79e6                	ld	s3,120(sp)
ffffffffc0202d26:	610d                	addi	sp,sp,160
ffffffffc0202d28:	8082                	ret
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202d2a:	4901                	li	s2,0
ffffffffc0202d2c:	bb1d                	j	ffffffffc0202a62 <swap_init+0xa6>
        assert(PageProperty(p));
ffffffffc0202d2e:	00002697          	auipc	a3,0x2
ffffffffc0202d32:	0e268693          	addi	a3,a3,226 # ffffffffc0204e10 <etext+0x8ce>
ffffffffc0202d36:	00002617          	auipc	a2,0x2
ffffffffc0202d3a:	0ea60613          	addi	a2,a2,234 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0202d3e:	0bb00593          	li	a1,187
ffffffffc0202d42:	00003517          	auipc	a0,0x3
ffffffffc0202d46:	afe50513          	addi	a0,a0,-1282 # ffffffffc0205840 <etext+0x12fe>
ffffffffc0202d4a:	e16fd0ef          	jal	ffffffffc0200360 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202d4e:	00003697          	auipc	a3,0x3
ffffffffc0202d52:	ce268693          	addi	a3,a3,-798 # ffffffffc0205a30 <etext+0x14ee>
ffffffffc0202d56:	00002617          	auipc	a2,0x2
ffffffffc0202d5a:	0ca60613          	addi	a2,a2,202 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0202d5e:	0fb00593          	li	a1,251
ffffffffc0202d62:	00003517          	auipc	a0,0x3
ffffffffc0202d66:	ade50513          	addi	a0,a0,-1314 # ffffffffc0205840 <etext+0x12fe>
ffffffffc0202d6a:	df6fd0ef          	jal	ffffffffc0200360 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202d6e:	00002617          	auipc	a2,0x2
ffffffffc0202d72:	49260613          	addi	a2,a2,1170 # ffffffffc0205200 <etext+0xcbe>
ffffffffc0202d76:	07000593          	li	a1,112
ffffffffc0202d7a:	00002517          	auipc	a0,0x2
ffffffffc0202d7e:	47650513          	addi	a0,a0,1142 # ffffffffc02051f0 <etext+0xcae>
ffffffffc0202d82:	ddefd0ef          	jal	ffffffffc0200360 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202d86:	00002617          	auipc	a2,0x2
ffffffffc0202d8a:	44a60613          	addi	a2,a2,1098 # ffffffffc02051d0 <etext+0xc8e>
ffffffffc0202d8e:	06500593          	li	a1,101
ffffffffc0202d92:	00002517          	auipc	a0,0x2
ffffffffc0202d96:	45e50513          	addi	a0,a0,1118 # ffffffffc02051f0 <etext+0xcae>
ffffffffc0202d9a:	dc6fd0ef          	jal	ffffffffc0200360 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0202d9e:	00003697          	auipc	a3,0x3
ffffffffc0202da2:	bca68693          	addi	a3,a3,-1078 # ffffffffc0205968 <etext+0x1426>
ffffffffc0202da6:	00002617          	auipc	a2,0x2
ffffffffc0202daa:	07a60613          	addi	a2,a2,122 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0202dae:	0dc00593          	li	a1,220
ffffffffc0202db2:	00003517          	auipc	a0,0x3
ffffffffc0202db6:	a8e50513          	addi	a0,a0,-1394 # ffffffffc0205840 <etext+0x12fe>
ffffffffc0202dba:	da6fd0ef          	jal	ffffffffc0200360 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0202dbe:	00003697          	auipc	a3,0x3
ffffffffc0202dc2:	b9268693          	addi	a3,a3,-1134 # ffffffffc0205950 <etext+0x140e>
ffffffffc0202dc6:	00002617          	auipc	a2,0x2
ffffffffc0202dca:	05a60613          	addi	a2,a2,90 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0202dce:	0db00593          	li	a1,219
ffffffffc0202dd2:	00003517          	auipc	a0,0x3
ffffffffc0202dd6:	a6e50513          	addi	a0,a0,-1426 # ffffffffc0205840 <etext+0x12fe>
ffffffffc0202dda:	d86fd0ef          	jal	ffffffffc0200360 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0202dde:	00003617          	auipc	a2,0x3
ffffffffc0202de2:	a4260613          	addi	a2,a2,-1470 # ffffffffc0205820 <etext+0x12de>
ffffffffc0202de6:	02700593          	li	a1,39
ffffffffc0202dea:	00003517          	auipc	a0,0x3
ffffffffc0202dee:	a5650513          	addi	a0,a0,-1450 # ffffffffc0205840 <etext+0x12fe>
ffffffffc0202df2:	e922                	sd	s0,144(sp)
ffffffffc0202df4:	e526                	sd	s1,136(sp)
ffffffffc0202df6:	e14a                	sd	s2,128(sp)
ffffffffc0202df8:	fcce                	sd	s3,120(sp)
ffffffffc0202dfa:	f8d2                	sd	s4,112(sp)
ffffffffc0202dfc:	f4d6                	sd	s5,104(sp)
ffffffffc0202dfe:	f0da                	sd	s6,96(sp)
ffffffffc0202e00:	ecde                	sd	s7,88(sp)
ffffffffc0202e02:	e8e2                	sd	s8,80(sp)
ffffffffc0202e04:	e4e6                	sd	s9,72(sp)
ffffffffc0202e06:	e0ea                	sd	s10,64(sp)
ffffffffc0202e08:	fc6e                	sd	s11,56(sp)
ffffffffc0202e0a:	d56fd0ef          	jal	ffffffffc0200360 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0202e0e:	00003697          	auipc	a3,0x3
ffffffffc0202e12:	c0a68693          	addi	a3,a3,-1014 # ffffffffc0205a18 <etext+0x14d6>
ffffffffc0202e16:	00002617          	auipc	a2,0x2
ffffffffc0202e1a:	00a60613          	addi	a2,a2,10 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0202e1e:	0fa00593          	li	a1,250
ffffffffc0202e22:	00003517          	auipc	a0,0x3
ffffffffc0202e26:	a1e50513          	addi	a0,a0,-1506 # ffffffffc0205840 <etext+0x12fe>
ffffffffc0202e2a:	d36fd0ef          	jal	ffffffffc0200360 <__panic>
     assert(pgfault_num==4);
ffffffffc0202e2e:	00003697          	auipc	a3,0x3
ffffffffc0202e32:	bda68693          	addi	a3,a3,-1062 # ffffffffc0205a08 <etext+0x14c6>
ffffffffc0202e36:	00002617          	auipc	a2,0x2
ffffffffc0202e3a:	fea60613          	addi	a2,a2,-22 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0202e3e:	09e00593          	li	a1,158
ffffffffc0202e42:	00003517          	auipc	a0,0x3
ffffffffc0202e46:	9fe50513          	addi	a0,a0,-1538 # ffffffffc0205840 <etext+0x12fe>
ffffffffc0202e4a:	d16fd0ef          	jal	ffffffffc0200360 <__panic>
     assert(pgfault_num==4);
ffffffffc0202e4e:	00003697          	auipc	a3,0x3
ffffffffc0202e52:	bba68693          	addi	a3,a3,-1094 # ffffffffc0205a08 <etext+0x14c6>
ffffffffc0202e56:	00002617          	auipc	a2,0x2
ffffffffc0202e5a:	fca60613          	addi	a2,a2,-54 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0202e5e:	0a000593          	li	a1,160
ffffffffc0202e62:	00003517          	auipc	a0,0x3
ffffffffc0202e66:	9de50513          	addi	a0,a0,-1570 # ffffffffc0205840 <etext+0x12fe>
ffffffffc0202e6a:	cf6fd0ef          	jal	ffffffffc0200360 <__panic>
     assert( nr_free == 0);         
ffffffffc0202e6e:	00002697          	auipc	a3,0x2
ffffffffc0202e72:	18a68693          	addi	a3,a3,394 # ffffffffc0204ff8 <etext+0xab6>
ffffffffc0202e76:	00002617          	auipc	a2,0x2
ffffffffc0202e7a:	faa60613          	addi	a2,a2,-86 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0202e7e:	0f200593          	li	a1,242
ffffffffc0202e82:	00003517          	auipc	a0,0x3
ffffffffc0202e86:	9be50513          	addi	a0,a0,-1602 # ffffffffc0205840 <etext+0x12fe>
ffffffffc0202e8a:	cd6fd0ef          	jal	ffffffffc0200360 <__panic>
     assert(ret==0);
ffffffffc0202e8e:	00003697          	auipc	a3,0x3
ffffffffc0202e92:	bf268693          	addi	a3,a3,-1038 # ffffffffc0205a80 <etext+0x153e>
ffffffffc0202e96:	00002617          	auipc	a2,0x2
ffffffffc0202e9a:	f8a60613          	addi	a2,a2,-118 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0202e9e:	10100593          	li	a1,257
ffffffffc0202ea2:	00003517          	auipc	a0,0x3
ffffffffc0202ea6:	99e50513          	addi	a0,a0,-1634 # ffffffffc0205840 <etext+0x12fe>
ffffffffc0202eaa:	cb6fd0ef          	jal	ffffffffc0200360 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0202eae:	00003697          	auipc	a3,0x3
ffffffffc0202eb2:	a0a68693          	addi	a3,a3,-1526 # ffffffffc02058b8 <etext+0x1376>
ffffffffc0202eb6:	00002617          	auipc	a2,0x2
ffffffffc0202eba:	f6a60613          	addi	a2,a2,-150 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0202ebe:	0cb00593          	li	a1,203
ffffffffc0202ec2:	00003517          	auipc	a0,0x3
ffffffffc0202ec6:	97e50513          	addi	a0,a0,-1666 # ffffffffc0205840 <etext+0x12fe>
ffffffffc0202eca:	c96fd0ef          	jal	ffffffffc0200360 <__panic>
     assert(vma != NULL);
ffffffffc0202ece:	00003697          	auipc	a3,0x3
ffffffffc0202ed2:	9fa68693          	addi	a3,a3,-1542 # ffffffffc02058c8 <etext+0x1386>
ffffffffc0202ed6:	00002617          	auipc	a2,0x2
ffffffffc0202eda:	f4a60613          	addi	a2,a2,-182 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0202ede:	0ce00593          	li	a1,206
ffffffffc0202ee2:	00003517          	auipc	a0,0x3
ffffffffc0202ee6:	95e50513          	addi	a0,a0,-1698 # ffffffffc0205840 <etext+0x12fe>
ffffffffc0202eea:	c76fd0ef          	jal	ffffffffc0200360 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0202eee:	00003697          	auipc	a3,0x3
ffffffffc0202ef2:	a2268693          	addi	a3,a3,-1502 # ffffffffc0205910 <etext+0x13ce>
ffffffffc0202ef6:	00002617          	auipc	a2,0x2
ffffffffc0202efa:	f2a60613          	addi	a2,a2,-214 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0202efe:	0d600593          	li	a1,214
ffffffffc0202f02:	00003517          	auipc	a0,0x3
ffffffffc0202f06:	93e50513          	addi	a0,a0,-1730 # ffffffffc0205840 <etext+0x12fe>
ffffffffc0202f0a:	c56fd0ef          	jal	ffffffffc0200360 <__panic>
     assert(total == nr_free_pages());
ffffffffc0202f0e:	00002697          	auipc	a3,0x2
ffffffffc0202f12:	f4268693          	addi	a3,a3,-190 # ffffffffc0204e50 <etext+0x90e>
ffffffffc0202f16:	00002617          	auipc	a2,0x2
ffffffffc0202f1a:	f0a60613          	addi	a2,a2,-246 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0202f1e:	0be00593          	li	a1,190
ffffffffc0202f22:	00003517          	auipc	a0,0x3
ffffffffc0202f26:	91e50513          	addi	a0,a0,-1762 # ffffffffc0205840 <etext+0x12fe>
ffffffffc0202f2a:	c36fd0ef          	jal	ffffffffc0200360 <__panic>
     assert(pgfault_num==2);
ffffffffc0202f2e:	00003697          	auipc	a3,0x3
ffffffffc0202f32:	aba68693          	addi	a3,a3,-1350 # ffffffffc02059e8 <etext+0x14a6>
ffffffffc0202f36:	00002617          	auipc	a2,0x2
ffffffffc0202f3a:	eea60613          	addi	a2,a2,-278 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0202f3e:	09600593          	li	a1,150
ffffffffc0202f42:	00003517          	auipc	a0,0x3
ffffffffc0202f46:	8fe50513          	addi	a0,a0,-1794 # ffffffffc0205840 <etext+0x12fe>
ffffffffc0202f4a:	c16fd0ef          	jal	ffffffffc0200360 <__panic>
     assert(pgfault_num==2);
ffffffffc0202f4e:	00003697          	auipc	a3,0x3
ffffffffc0202f52:	a9a68693          	addi	a3,a3,-1382 # ffffffffc02059e8 <etext+0x14a6>
ffffffffc0202f56:	00002617          	auipc	a2,0x2
ffffffffc0202f5a:	eca60613          	addi	a2,a2,-310 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0202f5e:	09800593          	li	a1,152
ffffffffc0202f62:	00003517          	auipc	a0,0x3
ffffffffc0202f66:	8de50513          	addi	a0,a0,-1826 # ffffffffc0205840 <etext+0x12fe>
ffffffffc0202f6a:	bf6fd0ef          	jal	ffffffffc0200360 <__panic>
     assert(pgfault_num==3);
ffffffffc0202f6e:	00003697          	auipc	a3,0x3
ffffffffc0202f72:	a8a68693          	addi	a3,a3,-1398 # ffffffffc02059f8 <etext+0x14b6>
ffffffffc0202f76:	00002617          	auipc	a2,0x2
ffffffffc0202f7a:	eaa60613          	addi	a2,a2,-342 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0202f7e:	09a00593          	li	a1,154
ffffffffc0202f82:	00003517          	auipc	a0,0x3
ffffffffc0202f86:	8be50513          	addi	a0,a0,-1858 # ffffffffc0205840 <etext+0x12fe>
ffffffffc0202f8a:	bd6fd0ef          	jal	ffffffffc0200360 <__panic>
     assert(pgfault_num==3);
ffffffffc0202f8e:	00003697          	auipc	a3,0x3
ffffffffc0202f92:	a6a68693          	addi	a3,a3,-1430 # ffffffffc02059f8 <etext+0x14b6>
ffffffffc0202f96:	00002617          	auipc	a2,0x2
ffffffffc0202f9a:	e8a60613          	addi	a2,a2,-374 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0202f9e:	09c00593          	li	a1,156
ffffffffc0202fa2:	00003517          	auipc	a0,0x3
ffffffffc0202fa6:	89e50513          	addi	a0,a0,-1890 # ffffffffc0205840 <etext+0x12fe>
ffffffffc0202faa:	bb6fd0ef          	jal	ffffffffc0200360 <__panic>
     assert(pgfault_num==1);
ffffffffc0202fae:	00003697          	auipc	a3,0x3
ffffffffc0202fb2:	a2a68693          	addi	a3,a3,-1494 # ffffffffc02059d8 <etext+0x1496>
ffffffffc0202fb6:	00002617          	auipc	a2,0x2
ffffffffc0202fba:	e6a60613          	addi	a2,a2,-406 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0202fbe:	09200593          	li	a1,146
ffffffffc0202fc2:	00003517          	auipc	a0,0x3
ffffffffc0202fc6:	87e50513          	addi	a0,a0,-1922 # ffffffffc0205840 <etext+0x12fe>
ffffffffc0202fca:	b96fd0ef          	jal	ffffffffc0200360 <__panic>
     assert(pgfault_num==1);
ffffffffc0202fce:	00003697          	auipc	a3,0x3
ffffffffc0202fd2:	a0a68693          	addi	a3,a3,-1526 # ffffffffc02059d8 <etext+0x1496>
ffffffffc0202fd6:	00002617          	auipc	a2,0x2
ffffffffc0202fda:	e4a60613          	addi	a2,a2,-438 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0202fde:	09400593          	li	a1,148
ffffffffc0202fe2:	00003517          	auipc	a0,0x3
ffffffffc0202fe6:	85e50513          	addi	a0,a0,-1954 # ffffffffc0205840 <etext+0x12fe>
ffffffffc0202fea:	b76fd0ef          	jal	ffffffffc0200360 <__panic>
     assert(mm != NULL);
ffffffffc0202fee:	00003697          	auipc	a3,0x3
ffffffffc0202ff2:	8a268693          	addi	a3,a3,-1886 # ffffffffc0205890 <etext+0x134e>
ffffffffc0202ff6:	00002617          	auipc	a2,0x2
ffffffffc0202ffa:	e2a60613          	addi	a2,a2,-470 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0202ffe:	0c300593          	li	a1,195
ffffffffc0203002:	00003517          	auipc	a0,0x3
ffffffffc0203006:	83e50513          	addi	a0,a0,-1986 # ffffffffc0205840 <etext+0x12fe>
ffffffffc020300a:	b56fd0ef          	jal	ffffffffc0200360 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc020300e:	00003697          	auipc	a3,0x3
ffffffffc0203012:	89268693          	addi	a3,a3,-1902 # ffffffffc02058a0 <etext+0x135e>
ffffffffc0203016:	00002617          	auipc	a2,0x2
ffffffffc020301a:	e0a60613          	addi	a2,a2,-502 # ffffffffc0204e20 <etext+0x8de>
ffffffffc020301e:	0c600593          	li	a1,198
ffffffffc0203022:	00003517          	auipc	a0,0x3
ffffffffc0203026:	81e50513          	addi	a0,a0,-2018 # ffffffffc0205840 <etext+0x12fe>
ffffffffc020302a:	b36fd0ef          	jal	ffffffffc0200360 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc020302e:	00003697          	auipc	a3,0x3
ffffffffc0203032:	95a68693          	addi	a3,a3,-1702 # ffffffffc0205988 <etext+0x1446>
ffffffffc0203036:	00002617          	auipc	a2,0x2
ffffffffc020303a:	dea60613          	addi	a2,a2,-534 # ffffffffc0204e20 <etext+0x8de>
ffffffffc020303e:	0e900593          	li	a1,233
ffffffffc0203042:	00002517          	auipc	a0,0x2
ffffffffc0203046:	7fe50513          	addi	a0,a0,2046 # ffffffffc0205840 <etext+0x12fe>
ffffffffc020304a:	b16fd0ef          	jal	ffffffffc0200360 <__panic>

ffffffffc020304e <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc020304e:	0000e797          	auipc	a5,0xe
ffffffffc0203052:	50a7b783          	ld	a5,1290(a5) # ffffffffc0211558 <sm>
ffffffffc0203056:	6b9c                	ld	a5,16(a5)
ffffffffc0203058:	8782                	jr	a5

ffffffffc020305a <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc020305a:	0000e797          	auipc	a5,0xe
ffffffffc020305e:	4fe7b783          	ld	a5,1278(a5) # ffffffffc0211558 <sm>
ffffffffc0203062:	739c                	ld	a5,32(a5)
ffffffffc0203064:	8782                	jr	a5

ffffffffc0203066 <swap_out>:
{
ffffffffc0203066:	711d                	addi	sp,sp,-96
ffffffffc0203068:	ec86                	sd	ra,88(sp)
ffffffffc020306a:	e8a2                	sd	s0,80(sp)
     for (i = 0; i != n; ++ i)
ffffffffc020306c:	0e058663          	beqz	a1,ffffffffc0203158 <swap_out+0xf2>
ffffffffc0203070:	e0ca                	sd	s2,64(sp)
ffffffffc0203072:	fc4e                	sd	s3,56(sp)
ffffffffc0203074:	f852                	sd	s4,48(sp)
ffffffffc0203076:	f456                	sd	s5,40(sp)
ffffffffc0203078:	f05a                	sd	s6,32(sp)
ffffffffc020307a:	ec5e                	sd	s7,24(sp)
ffffffffc020307c:	e4a6                	sd	s1,72(sp)
ffffffffc020307e:	e862                	sd	s8,16(sp)
ffffffffc0203080:	8a2e                	mv	s4,a1
ffffffffc0203082:	892a                	mv	s2,a0
ffffffffc0203084:	8ab2                	mv	s5,a2
ffffffffc0203086:	4401                	li	s0,0
ffffffffc0203088:	0000e997          	auipc	s3,0xe
ffffffffc020308c:	4d098993          	addi	s3,s3,1232 # ffffffffc0211558 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203090:	00003b17          	auipc	s6,0x3
ffffffffc0203094:	a98b0b13          	addi	s6,s6,-1384 # ffffffffc0205b28 <etext+0x15e6>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203098:	00003b97          	auipc	s7,0x3
ffffffffc020309c:	a78b8b93          	addi	s7,s7,-1416 # ffffffffc0205b10 <etext+0x15ce>
ffffffffc02030a0:	a825                	j	ffffffffc02030d8 <swap_out+0x72>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc02030a2:	67a2                	ld	a5,8(sp)
ffffffffc02030a4:	8626                	mv	a2,s1
ffffffffc02030a6:	85a2                	mv	a1,s0
ffffffffc02030a8:	63b4                	ld	a3,64(a5)
ffffffffc02030aa:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc02030ac:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc02030ae:	82b1                	srli	a3,a3,0xc
ffffffffc02030b0:	0685                	addi	a3,a3,1
ffffffffc02030b2:	808fd0ef          	jal	ffffffffc02000ba <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc02030b6:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc02030b8:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc02030ba:	613c                	ld	a5,64(a0)
ffffffffc02030bc:	83b1                	srli	a5,a5,0xc
ffffffffc02030be:	0785                	addi	a5,a5,1
ffffffffc02030c0:	07a2                	slli	a5,a5,0x8
ffffffffc02030c2:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc02030c6:	dacfe0ef          	jal	ffffffffc0201672 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc02030ca:	01893503          	ld	a0,24(s2)
ffffffffc02030ce:	85a6                	mv	a1,s1
ffffffffc02030d0:	e7aff0ef          	jal	ffffffffc020274a <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc02030d4:	048a0d63          	beq	s4,s0,ffffffffc020312e <swap_out+0xc8>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc02030d8:	0009b783          	ld	a5,0(s3)
ffffffffc02030dc:	8656                	mv	a2,s5
ffffffffc02030de:	002c                	addi	a1,sp,8
ffffffffc02030e0:	7b9c                	ld	a5,48(a5)
ffffffffc02030e2:	854a                	mv	a0,s2
ffffffffc02030e4:	9782                	jalr	a5
          if (r != 0) {
ffffffffc02030e6:	e12d                	bnez	a0,ffffffffc0203148 <swap_out+0xe2>
          v=page->pra_vaddr; 
ffffffffc02030e8:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc02030ea:	01893503          	ld	a0,24(s2)
ffffffffc02030ee:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc02030f0:	63a4                	ld	s1,64(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc02030f2:	85a6                	mv	a1,s1
ffffffffc02030f4:	df8fe0ef          	jal	ffffffffc02016ec <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc02030f8:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc02030fa:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc02030fc:	8b85                	andi	a5,a5,1
ffffffffc02030fe:	cfb9                	beqz	a5,ffffffffc020315c <swap_out+0xf6>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0203100:	65a2                	ld	a1,8(sp)
ffffffffc0203102:	61bc                	ld	a5,64(a1)
ffffffffc0203104:	83b1                	srli	a5,a5,0xc
ffffffffc0203106:	0785                	addi	a5,a5,1
ffffffffc0203108:	00879513          	slli	a0,a5,0x8
ffffffffc020310c:	62d000ef          	jal	ffffffffc0203f38 <swapfs_write>
ffffffffc0203110:	d949                	beqz	a0,ffffffffc02030a2 <swap_out+0x3c>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203112:	855e                	mv	a0,s7
ffffffffc0203114:	fa7fc0ef          	jal	ffffffffc02000ba <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203118:	0009b783          	ld	a5,0(s3)
ffffffffc020311c:	6622                	ld	a2,8(sp)
ffffffffc020311e:	4681                	li	a3,0
ffffffffc0203120:	739c                	ld	a5,32(a5)
ffffffffc0203122:	85a6                	mv	a1,s1
ffffffffc0203124:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0203126:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203128:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc020312a:	fa8a17e3          	bne	s4,s0,ffffffffc02030d8 <swap_out+0x72>
ffffffffc020312e:	64a6                	ld	s1,72(sp)
ffffffffc0203130:	6906                	ld	s2,64(sp)
ffffffffc0203132:	79e2                	ld	s3,56(sp)
ffffffffc0203134:	7a42                	ld	s4,48(sp)
ffffffffc0203136:	7aa2                	ld	s5,40(sp)
ffffffffc0203138:	7b02                	ld	s6,32(sp)
ffffffffc020313a:	6be2                	ld	s7,24(sp)
ffffffffc020313c:	6c42                	ld	s8,16(sp)
}
ffffffffc020313e:	60e6                	ld	ra,88(sp)
ffffffffc0203140:	8522                	mv	a0,s0
ffffffffc0203142:	6446                	ld	s0,80(sp)
ffffffffc0203144:	6125                	addi	sp,sp,96
ffffffffc0203146:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0203148:	85a2                	mv	a1,s0
ffffffffc020314a:	00003517          	auipc	a0,0x3
ffffffffc020314e:	97e50513          	addi	a0,a0,-1666 # ffffffffc0205ac8 <etext+0x1586>
ffffffffc0203152:	f69fc0ef          	jal	ffffffffc02000ba <cprintf>
                  break;
ffffffffc0203156:	bfe1                	j	ffffffffc020312e <swap_out+0xc8>
     for (i = 0; i != n; ++ i)
ffffffffc0203158:	4401                	li	s0,0
ffffffffc020315a:	b7d5                	j	ffffffffc020313e <swap_out+0xd8>
          assert((*ptep & PTE_V) != 0);
ffffffffc020315c:	00003697          	auipc	a3,0x3
ffffffffc0203160:	99c68693          	addi	a3,a3,-1636 # ffffffffc0205af8 <etext+0x15b6>
ffffffffc0203164:	00002617          	auipc	a2,0x2
ffffffffc0203168:	cbc60613          	addi	a2,a2,-836 # ffffffffc0204e20 <etext+0x8de>
ffffffffc020316c:	06700593          	li	a1,103
ffffffffc0203170:	00002517          	auipc	a0,0x2
ffffffffc0203174:	6d050513          	addi	a0,a0,1744 # ffffffffc0205840 <etext+0x12fe>
ffffffffc0203178:	9e8fd0ef          	jal	ffffffffc0200360 <__panic>

ffffffffc020317c <swap_in>:
{
ffffffffc020317c:	7179                	addi	sp,sp,-48
ffffffffc020317e:	e84a                	sd	s2,16(sp)
ffffffffc0203180:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0203182:	4505                	li	a0,1
{
ffffffffc0203184:	ec26                	sd	s1,24(sp)
ffffffffc0203186:	e44e                	sd	s3,8(sp)
ffffffffc0203188:	f406                	sd	ra,40(sp)
ffffffffc020318a:	f022                	sd	s0,32(sp)
ffffffffc020318c:	84ae                	mv	s1,a1
ffffffffc020318e:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0203190:	c52fe0ef          	jal	ffffffffc02015e2 <alloc_pages>
     assert(result!=NULL);
ffffffffc0203194:	c129                	beqz	a0,ffffffffc02031d6 <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0203196:	842a                	mv	s0,a0
ffffffffc0203198:	01893503          	ld	a0,24(s2)
ffffffffc020319c:	4601                	li	a2,0
ffffffffc020319e:	85a6                	mv	a1,s1
ffffffffc02031a0:	d4cfe0ef          	jal	ffffffffc02016ec <get_pte>
ffffffffc02031a4:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc02031a6:	6108                	ld	a0,0(a0)
ffffffffc02031a8:	85a2                	mv	a1,s0
ffffffffc02031aa:	4e3000ef          	jal	ffffffffc0203e8c <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc02031ae:	00093583          	ld	a1,0(s2)
ffffffffc02031b2:	8626                	mv	a2,s1
ffffffffc02031b4:	00003517          	auipc	a0,0x3
ffffffffc02031b8:	9c450513          	addi	a0,a0,-1596 # ffffffffc0205b78 <etext+0x1636>
ffffffffc02031bc:	81a1                	srli	a1,a1,0x8
ffffffffc02031be:	efdfc0ef          	jal	ffffffffc02000ba <cprintf>
}
ffffffffc02031c2:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc02031c4:	0089b023          	sd	s0,0(s3)
}
ffffffffc02031c8:	7402                	ld	s0,32(sp)
ffffffffc02031ca:	64e2                	ld	s1,24(sp)
ffffffffc02031cc:	6942                	ld	s2,16(sp)
ffffffffc02031ce:	69a2                	ld	s3,8(sp)
ffffffffc02031d0:	4501                	li	a0,0
ffffffffc02031d2:	6145                	addi	sp,sp,48
ffffffffc02031d4:	8082                	ret
     assert(result!=NULL);
ffffffffc02031d6:	00003697          	auipc	a3,0x3
ffffffffc02031da:	99268693          	addi	a3,a3,-1646 # ffffffffc0205b68 <etext+0x1626>
ffffffffc02031de:	00002617          	auipc	a2,0x2
ffffffffc02031e2:	c4260613          	addi	a2,a2,-958 # ffffffffc0204e20 <etext+0x8de>
ffffffffc02031e6:	07d00593          	li	a1,125
ffffffffc02031ea:	00002517          	auipc	a0,0x2
ffffffffc02031ee:	65650513          	addi	a0,a0,1622 # ffffffffc0205840 <etext+0x12fe>
ffffffffc02031f2:	96efd0ef          	jal	ffffffffc0200360 <__panic>

ffffffffc02031f6 <_clock_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc02031f6:	0000e797          	auipc	a5,0xe
ffffffffc02031fa:	ef278793          	addi	a5,a5,-270 # ffffffffc02110e8 <pra_list_head2>
     // 初始化pra_list_head为空链表
     list_init(&pra_list_head2);
     // 初始化当前指针curr_ptr指向pra_list_head，表示当前页面替换位置为链表头
     curr_ptr = &pra_list_head2;
     // 将mm的私有成员指针指向pra_list_head，用于后续的页面替换算法操作
     mm->sm_priv = &pra_list_head2;
ffffffffc02031fe:	f51c                	sd	a5,40(a0)
ffffffffc0203200:	e79c                	sd	a5,8(a5)
ffffffffc0203202:	e39c                	sd	a5,0(a5)
     curr_ptr = &pra_list_head2;
ffffffffc0203204:	0000e717          	auipc	a4,0xe
ffffffffc0203208:	34f73e23          	sd	a5,860(a4) # ffffffffc0211560 <curr_ptr>
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc020320c:	4501                	li	a0,0
ffffffffc020320e:	8082                	ret

ffffffffc0203210 <_clock_init>:

static int
_clock_init(void)
{
    return 0;
}
ffffffffc0203210:	4501                	li	a0,0
ffffffffc0203212:	8082                	ret

ffffffffc0203214 <_clock_set_unswappable>:

static int
_clock_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0203214:	4501                	li	a0,0
ffffffffc0203216:	8082                	ret

ffffffffc0203218 <_clock_tick_event>:

static int
_clock_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc0203218:	4501                	li	a0,0
ffffffffc020321a:	8082                	ret

ffffffffc020321c <_clock_check_swap>:
_clock_check_swap(void) {
ffffffffc020321c:	1141                	addi	sp,sp,-16
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc020321e:	4731                	li	a4,12
_clock_check_swap(void) {
ffffffffc0203220:	e406                	sd	ra,8(sp)
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203222:	678d                	lui	a5,0x3
ffffffffc0203224:	00e78023          	sb	a4,0(a5) # 3000 <kern_entry-0xffffffffc01fd000>
    assert(pgfault_num==4);
ffffffffc0203228:	0000e717          	auipc	a4,0xe
ffffffffc020322c:	34072703          	lw	a4,832(a4) # ffffffffc0211568 <pgfault_num>
ffffffffc0203230:	4691                	li	a3,4
ffffffffc0203232:	0ad71663          	bne	a4,a3,ffffffffc02032de <_clock_check_swap+0xc2>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203236:	6685                	lui	a3,0x1
ffffffffc0203238:	4629                	li	a2,10
ffffffffc020323a:	00c68023          	sb	a2,0(a3) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc020323e:	0000e797          	auipc	a5,0xe
ffffffffc0203242:	32a78793          	addi	a5,a5,810 # ffffffffc0211568 <pgfault_num>
    assert(pgfault_num==4);
ffffffffc0203246:	4394                	lw	a3,0(a5)
ffffffffc0203248:	0006861b          	sext.w	a2,a3
ffffffffc020324c:	20e69963          	bne	a3,a4,ffffffffc020345e <_clock_check_swap+0x242>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203250:	6711                	lui	a4,0x4
ffffffffc0203252:	46b5                	li	a3,13
ffffffffc0203254:	00d70023          	sb	a3,0(a4) # 4000 <kern_entry-0xffffffffc01fc000>
    assert(pgfault_num==4);
ffffffffc0203258:	4398                	lw	a4,0(a5)
ffffffffc020325a:	0007069b          	sext.w	a3,a4
ffffffffc020325e:	1ec71063          	bne	a4,a2,ffffffffc020343e <_clock_check_swap+0x222>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203262:	6709                	lui	a4,0x2
ffffffffc0203264:	462d                	li	a2,11
ffffffffc0203266:	00c70023          	sb	a2,0(a4) # 2000 <kern_entry-0xffffffffc01fe000>
    assert(pgfault_num==4);
ffffffffc020326a:	4398                	lw	a4,0(a5)
ffffffffc020326c:	1ad71963          	bne	a4,a3,ffffffffc020341e <_clock_check_swap+0x202>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203270:	6715                	lui	a4,0x5
ffffffffc0203272:	46b9                	li	a3,14
ffffffffc0203274:	00d70023          	sb	a3,0(a4) # 5000 <kern_entry-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc0203278:	4398                	lw	a4,0(a5)
ffffffffc020327a:	4615                	li	a2,5
ffffffffc020327c:	0007069b          	sext.w	a3,a4
ffffffffc0203280:	16c71f63          	bne	a4,a2,ffffffffc02033fe <_clock_check_swap+0x1e2>
    assert(pgfault_num==5);
ffffffffc0203284:	4398                	lw	a4,0(a5)
ffffffffc0203286:	0007061b          	sext.w	a2,a4
ffffffffc020328a:	14d71a63          	bne	a4,a3,ffffffffc02033de <_clock_check_swap+0x1c2>
    assert(pgfault_num==5);
ffffffffc020328e:	4398                	lw	a4,0(a5)
ffffffffc0203290:	0007069b          	sext.w	a3,a4
ffffffffc0203294:	12c71563          	bne	a4,a2,ffffffffc02033be <_clock_check_swap+0x1a2>
    assert(pgfault_num==5);
ffffffffc0203298:	4398                	lw	a4,0(a5)
ffffffffc020329a:	0007061b          	sext.w	a2,a4
ffffffffc020329e:	10d71063          	bne	a4,a3,ffffffffc020339e <_clock_check_swap+0x182>
    assert(pgfault_num==5);
ffffffffc02032a2:	4398                	lw	a4,0(a5)
ffffffffc02032a4:	0007069b          	sext.w	a3,a4
ffffffffc02032a8:	0cc71b63          	bne	a4,a2,ffffffffc020337e <_clock_check_swap+0x162>
    assert(pgfault_num==5);
ffffffffc02032ac:	4398                	lw	a4,0(a5)
ffffffffc02032ae:	0ad71863          	bne	a4,a3,ffffffffc020335e <_clock_check_swap+0x142>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc02032b2:	6715                	lui	a4,0x5
ffffffffc02032b4:	46b9                	li	a3,14
ffffffffc02032b6:	00d70023          	sb	a3,0(a4) # 5000 <kern_entry-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc02032ba:	4394                	lw	a3,0(a5)
ffffffffc02032bc:	4715                	li	a4,5
ffffffffc02032be:	08e69063          	bne	a3,a4,ffffffffc020333e <_clock_check_swap+0x122>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc02032c2:	6705                	lui	a4,0x1
ffffffffc02032c4:	00074683          	lbu	a3,0(a4) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc02032c8:	4729                	li	a4,10
ffffffffc02032ca:	04e69a63          	bne	a3,a4,ffffffffc020331e <_clock_check_swap+0x102>
    assert(pgfault_num==6);
ffffffffc02032ce:	4398                	lw	a4,0(a5)
ffffffffc02032d0:	4799                	li	a5,6
ffffffffc02032d2:	02f71663          	bne	a4,a5,ffffffffc02032fe <_clock_check_swap+0xe2>
}
ffffffffc02032d6:	60a2                	ld	ra,8(sp)
ffffffffc02032d8:	4501                	li	a0,0
ffffffffc02032da:	0141                	addi	sp,sp,16
ffffffffc02032dc:	8082                	ret
    assert(pgfault_num==4);
ffffffffc02032de:	00002697          	auipc	a3,0x2
ffffffffc02032e2:	72a68693          	addi	a3,a3,1834 # ffffffffc0205a08 <etext+0x14c6>
ffffffffc02032e6:	00002617          	auipc	a2,0x2
ffffffffc02032ea:	b3a60613          	addi	a2,a2,-1222 # ffffffffc0204e20 <etext+0x8de>
ffffffffc02032ee:	09100593          	li	a1,145
ffffffffc02032f2:	00003517          	auipc	a0,0x3
ffffffffc02032f6:	8c650513          	addi	a0,a0,-1850 # ffffffffc0205bb8 <etext+0x1676>
ffffffffc02032fa:	866fd0ef          	jal	ffffffffc0200360 <__panic>
    assert(pgfault_num==6);
ffffffffc02032fe:	00003697          	auipc	a3,0x3
ffffffffc0203302:	90a68693          	addi	a3,a3,-1782 # ffffffffc0205c08 <etext+0x16c6>
ffffffffc0203306:	00002617          	auipc	a2,0x2
ffffffffc020330a:	b1a60613          	addi	a2,a2,-1254 # ffffffffc0204e20 <etext+0x8de>
ffffffffc020330e:	0a800593          	li	a1,168
ffffffffc0203312:	00003517          	auipc	a0,0x3
ffffffffc0203316:	8a650513          	addi	a0,a0,-1882 # ffffffffc0205bb8 <etext+0x1676>
ffffffffc020331a:	846fd0ef          	jal	ffffffffc0200360 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc020331e:	00003697          	auipc	a3,0x3
ffffffffc0203322:	8c268693          	addi	a3,a3,-1854 # ffffffffc0205be0 <etext+0x169e>
ffffffffc0203326:	00002617          	auipc	a2,0x2
ffffffffc020332a:	afa60613          	addi	a2,a2,-1286 # ffffffffc0204e20 <etext+0x8de>
ffffffffc020332e:	0a600593          	li	a1,166
ffffffffc0203332:	00003517          	auipc	a0,0x3
ffffffffc0203336:	88650513          	addi	a0,a0,-1914 # ffffffffc0205bb8 <etext+0x1676>
ffffffffc020333a:	826fd0ef          	jal	ffffffffc0200360 <__panic>
    assert(pgfault_num==5);
ffffffffc020333e:	00003697          	auipc	a3,0x3
ffffffffc0203342:	89268693          	addi	a3,a3,-1902 # ffffffffc0205bd0 <etext+0x168e>
ffffffffc0203346:	00002617          	auipc	a2,0x2
ffffffffc020334a:	ada60613          	addi	a2,a2,-1318 # ffffffffc0204e20 <etext+0x8de>
ffffffffc020334e:	0a500593          	li	a1,165
ffffffffc0203352:	00003517          	auipc	a0,0x3
ffffffffc0203356:	86650513          	addi	a0,a0,-1946 # ffffffffc0205bb8 <etext+0x1676>
ffffffffc020335a:	806fd0ef          	jal	ffffffffc0200360 <__panic>
    assert(pgfault_num==5);
ffffffffc020335e:	00003697          	auipc	a3,0x3
ffffffffc0203362:	87268693          	addi	a3,a3,-1934 # ffffffffc0205bd0 <etext+0x168e>
ffffffffc0203366:	00002617          	auipc	a2,0x2
ffffffffc020336a:	aba60613          	addi	a2,a2,-1350 # ffffffffc0204e20 <etext+0x8de>
ffffffffc020336e:	0a300593          	li	a1,163
ffffffffc0203372:	00003517          	auipc	a0,0x3
ffffffffc0203376:	84650513          	addi	a0,a0,-1978 # ffffffffc0205bb8 <etext+0x1676>
ffffffffc020337a:	fe7fc0ef          	jal	ffffffffc0200360 <__panic>
    assert(pgfault_num==5);
ffffffffc020337e:	00003697          	auipc	a3,0x3
ffffffffc0203382:	85268693          	addi	a3,a3,-1966 # ffffffffc0205bd0 <etext+0x168e>
ffffffffc0203386:	00002617          	auipc	a2,0x2
ffffffffc020338a:	a9a60613          	addi	a2,a2,-1382 # ffffffffc0204e20 <etext+0x8de>
ffffffffc020338e:	0a100593          	li	a1,161
ffffffffc0203392:	00003517          	auipc	a0,0x3
ffffffffc0203396:	82650513          	addi	a0,a0,-2010 # ffffffffc0205bb8 <etext+0x1676>
ffffffffc020339a:	fc7fc0ef          	jal	ffffffffc0200360 <__panic>
    assert(pgfault_num==5);
ffffffffc020339e:	00003697          	auipc	a3,0x3
ffffffffc02033a2:	83268693          	addi	a3,a3,-1998 # ffffffffc0205bd0 <etext+0x168e>
ffffffffc02033a6:	00002617          	auipc	a2,0x2
ffffffffc02033aa:	a7a60613          	addi	a2,a2,-1414 # ffffffffc0204e20 <etext+0x8de>
ffffffffc02033ae:	09f00593          	li	a1,159
ffffffffc02033b2:	00003517          	auipc	a0,0x3
ffffffffc02033b6:	80650513          	addi	a0,a0,-2042 # ffffffffc0205bb8 <etext+0x1676>
ffffffffc02033ba:	fa7fc0ef          	jal	ffffffffc0200360 <__panic>
    assert(pgfault_num==5);
ffffffffc02033be:	00003697          	auipc	a3,0x3
ffffffffc02033c2:	81268693          	addi	a3,a3,-2030 # ffffffffc0205bd0 <etext+0x168e>
ffffffffc02033c6:	00002617          	auipc	a2,0x2
ffffffffc02033ca:	a5a60613          	addi	a2,a2,-1446 # ffffffffc0204e20 <etext+0x8de>
ffffffffc02033ce:	09d00593          	li	a1,157
ffffffffc02033d2:	00002517          	auipc	a0,0x2
ffffffffc02033d6:	7e650513          	addi	a0,a0,2022 # ffffffffc0205bb8 <etext+0x1676>
ffffffffc02033da:	f87fc0ef          	jal	ffffffffc0200360 <__panic>
    assert(pgfault_num==5);
ffffffffc02033de:	00002697          	auipc	a3,0x2
ffffffffc02033e2:	7f268693          	addi	a3,a3,2034 # ffffffffc0205bd0 <etext+0x168e>
ffffffffc02033e6:	00002617          	auipc	a2,0x2
ffffffffc02033ea:	a3a60613          	addi	a2,a2,-1478 # ffffffffc0204e20 <etext+0x8de>
ffffffffc02033ee:	09b00593          	li	a1,155
ffffffffc02033f2:	00002517          	auipc	a0,0x2
ffffffffc02033f6:	7c650513          	addi	a0,a0,1990 # ffffffffc0205bb8 <etext+0x1676>
ffffffffc02033fa:	f67fc0ef          	jal	ffffffffc0200360 <__panic>
    assert(pgfault_num==5);
ffffffffc02033fe:	00002697          	auipc	a3,0x2
ffffffffc0203402:	7d268693          	addi	a3,a3,2002 # ffffffffc0205bd0 <etext+0x168e>
ffffffffc0203406:	00002617          	auipc	a2,0x2
ffffffffc020340a:	a1a60613          	addi	a2,a2,-1510 # ffffffffc0204e20 <etext+0x8de>
ffffffffc020340e:	09900593          	li	a1,153
ffffffffc0203412:	00002517          	auipc	a0,0x2
ffffffffc0203416:	7a650513          	addi	a0,a0,1958 # ffffffffc0205bb8 <etext+0x1676>
ffffffffc020341a:	f47fc0ef          	jal	ffffffffc0200360 <__panic>
    assert(pgfault_num==4);
ffffffffc020341e:	00002697          	auipc	a3,0x2
ffffffffc0203422:	5ea68693          	addi	a3,a3,1514 # ffffffffc0205a08 <etext+0x14c6>
ffffffffc0203426:	00002617          	auipc	a2,0x2
ffffffffc020342a:	9fa60613          	addi	a2,a2,-1542 # ffffffffc0204e20 <etext+0x8de>
ffffffffc020342e:	09700593          	li	a1,151
ffffffffc0203432:	00002517          	auipc	a0,0x2
ffffffffc0203436:	78650513          	addi	a0,a0,1926 # ffffffffc0205bb8 <etext+0x1676>
ffffffffc020343a:	f27fc0ef          	jal	ffffffffc0200360 <__panic>
    assert(pgfault_num==4);
ffffffffc020343e:	00002697          	auipc	a3,0x2
ffffffffc0203442:	5ca68693          	addi	a3,a3,1482 # ffffffffc0205a08 <etext+0x14c6>
ffffffffc0203446:	00002617          	auipc	a2,0x2
ffffffffc020344a:	9da60613          	addi	a2,a2,-1574 # ffffffffc0204e20 <etext+0x8de>
ffffffffc020344e:	09500593          	li	a1,149
ffffffffc0203452:	00002517          	auipc	a0,0x2
ffffffffc0203456:	76650513          	addi	a0,a0,1894 # ffffffffc0205bb8 <etext+0x1676>
ffffffffc020345a:	f07fc0ef          	jal	ffffffffc0200360 <__panic>
    assert(pgfault_num==4);
ffffffffc020345e:	00002697          	auipc	a3,0x2
ffffffffc0203462:	5aa68693          	addi	a3,a3,1450 # ffffffffc0205a08 <etext+0x14c6>
ffffffffc0203466:	00002617          	auipc	a2,0x2
ffffffffc020346a:	9ba60613          	addi	a2,a2,-1606 # ffffffffc0204e20 <etext+0x8de>
ffffffffc020346e:	09300593          	li	a1,147
ffffffffc0203472:	00002517          	auipc	a0,0x2
ffffffffc0203476:	74650513          	addi	a0,a0,1862 # ffffffffc0205bb8 <etext+0x1676>
ffffffffc020347a:	ee7fc0ef          	jal	ffffffffc0200360 <__panic>

ffffffffc020347e <_clock_swap_out_victim>:
{
ffffffffc020347e:	7139                	addi	sp,sp,-64
ffffffffc0203480:	f426                	sd	s1,40(sp)
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0203482:	7504                	ld	s1,40(a0)
{
ffffffffc0203484:	fc06                	sd	ra,56(sp)
ffffffffc0203486:	f822                	sd	s0,48(sp)
ffffffffc0203488:	f04a                	sd	s2,32(sp)
ffffffffc020348a:	ec4e                	sd	s3,24(sp)
ffffffffc020348c:	e852                	sd	s4,16(sp)
ffffffffc020348e:	e456                	sd	s5,8(sp)
         assert(head != NULL);
ffffffffc0203490:	c0f9                	beqz	s1,ffffffffc0203556 <_clock_swap_out_victim+0xd8>
     assert(in_tick==0);
ffffffffc0203492:	e255                	bnez	a2,ffffffffc0203536 <_clock_swap_out_victim+0xb8>
     curr_ptr = list_prev(head);
ffffffffc0203494:	609c                	ld	a5,0(s1)
ffffffffc0203496:	0000e917          	auipc	s2,0xe
ffffffffc020349a:	0ca90913          	addi	s2,s2,202 # ffffffffc0211560 <curr_ptr>
ffffffffc020349e:	8aae                	mv	s5,a1
        cprintf("loop\n");
ffffffffc02034a0:	00002997          	auipc	s3,0x2
ffffffffc02034a4:	79898993          	addi	s3,s3,1944 # ffffffffc0205c38 <etext+0x16f6>
     curr_ptr = list_prev(head);
ffffffffc02034a8:	00f93023          	sd	a5,0(s2)
        if(p->visited==1)//为1置为0
ffffffffc02034ac:	4a05                	li	s4,1
ffffffffc02034ae:	a031                	j	ffffffffc02034ba <_clock_swap_out_victim+0x3c>
        if(p->visited==0)// 为0挑出来
ffffffffc02034b0:	fe043783          	ld	a5,-32(s0)
ffffffffc02034b4:	c795                	beqz	a5,ffffffffc02034e0 <_clock_swap_out_victim+0x62>
        if(p->visited==1)//为1置为0
ffffffffc02034b6:	05478d63          	beq	a5,s4,ffffffffc0203510 <_clock_swap_out_victim+0x92>
        cprintf("loop\n");
ffffffffc02034ba:	854e                	mv	a0,s3
ffffffffc02034bc:	bfffc0ef          	jal	ffffffffc02000ba <cprintf>
        list_entry_t* entry = curr_ptr;//从head找到链表第一个
ffffffffc02034c0:	00093403          	ld	s0,0(s2)
        if (entry == head) {
ffffffffc02034c4:	fe8496e3          	bne	s1,s0,ffffffffc02034b0 <_clock_swap_out_victim+0x32>
            *ptr_page = NULL;
ffffffffc02034c8:	000ab023          	sd	zero,0(s5) # 1000 <kern_entry-0xffffffffc01ff000>
}
ffffffffc02034cc:	70e2                	ld	ra,56(sp)
ffffffffc02034ce:	7442                	ld	s0,48(sp)
ffffffffc02034d0:	74a2                	ld	s1,40(sp)
ffffffffc02034d2:	7902                	ld	s2,32(sp)
ffffffffc02034d4:	69e2                	ld	s3,24(sp)
ffffffffc02034d6:	6a42                	ld	s4,16(sp)
ffffffffc02034d8:	6aa2                	ld	s5,8(sp)
ffffffffc02034da:	4501                	li	a0,0
ffffffffc02034dc:	6121                	addi	sp,sp,64
ffffffffc02034de:	8082                	ret
            cprintf("entry3 %p\n", entry);
ffffffffc02034e0:	85a2                	mv	a1,s0
ffffffffc02034e2:	00002517          	auipc	a0,0x2
ffffffffc02034e6:	75e50513          	addi	a0,a0,1886 # ffffffffc0205c40 <etext+0x16fe>
ffffffffc02034ea:	bd1fc0ef          	jal	ffffffffc02000ba <cprintf>
    __list_del(listelm->prev, listelm->next);
ffffffffc02034ee:	6018                	ld	a4,0(s0)
ffffffffc02034f0:	641c                	ld	a5,8(s0)
            cprintf("curr_ptr %p\n", curr_ptr);
ffffffffc02034f2:	00093583          	ld	a1,0(s2)
            *ptr_page = le2page(entry, pra_page_link); 
ffffffffc02034f6:	fd040413          	addi	s0,s0,-48
    prev->next = next;
ffffffffc02034fa:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02034fc:	e398                	sd	a4,0(a5)
ffffffffc02034fe:	008ab023          	sd	s0,0(s5)
            cprintf("curr_ptr %p\n", curr_ptr);
ffffffffc0203502:	00002517          	auipc	a0,0x2
ffffffffc0203506:	74e50513          	addi	a0,a0,1870 # ffffffffc0205c50 <etext+0x170e>
ffffffffc020350a:	bb1fc0ef          	jal	ffffffffc02000ba <cprintf>
            break;
ffffffffc020350e:	bf7d                	j	ffffffffc02034cc <_clock_swap_out_victim+0x4e>
            cprintf("entry1 %p\n", entry);
ffffffffc0203510:	85a2                	mv	a1,s0
            p->visited=0;
ffffffffc0203512:	fe043023          	sd	zero,-32(s0)
            cprintf("entry1 %p\n", entry);
ffffffffc0203516:	00002517          	auipc	a0,0x2
ffffffffc020351a:	74a50513          	addi	a0,a0,1866 # ffffffffc0205c60 <etext+0x171e>
ffffffffc020351e:	b9dfc0ef          	jal	ffffffffc02000ba <cprintf>
    return listelm->prev;
ffffffffc0203522:	600c                	ld	a1,0(s0)
            cprintf("entry2 %p\n", entry);  
ffffffffc0203524:	00002517          	auipc	a0,0x2
ffffffffc0203528:	74c50513          	addi	a0,a0,1868 # ffffffffc0205c70 <etext+0x172e>
            curr_ptr = entry;
ffffffffc020352c:	00b93023          	sd	a1,0(s2)
            cprintf("entry2 %p\n", entry);  
ffffffffc0203530:	b8bfc0ef          	jal	ffffffffc02000ba <cprintf>
ffffffffc0203534:	b759                	j	ffffffffc02034ba <_clock_swap_out_victim+0x3c>
     assert(in_tick==0);
ffffffffc0203536:	00002697          	auipc	a3,0x2
ffffffffc020353a:	6f268693          	addi	a3,a3,1778 # ffffffffc0205c28 <etext+0x16e6>
ffffffffc020353e:	00002617          	auipc	a2,0x2
ffffffffc0203542:	8e260613          	addi	a2,a2,-1822 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0203546:	04a00593          	li	a1,74
ffffffffc020354a:	00002517          	auipc	a0,0x2
ffffffffc020354e:	66e50513          	addi	a0,a0,1646 # ffffffffc0205bb8 <etext+0x1676>
ffffffffc0203552:	e0ffc0ef          	jal	ffffffffc0200360 <__panic>
         assert(head != NULL);
ffffffffc0203556:	00002697          	auipc	a3,0x2
ffffffffc020355a:	6c268693          	addi	a3,a3,1730 # ffffffffc0205c18 <etext+0x16d6>
ffffffffc020355e:	00002617          	auipc	a2,0x2
ffffffffc0203562:	8c260613          	addi	a2,a2,-1854 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0203566:	04900593          	li	a1,73
ffffffffc020356a:	00002517          	auipc	a0,0x2
ffffffffc020356e:	64e50513          	addi	a0,a0,1614 # ffffffffc0205bb8 <etext+0x1676>
ffffffffc0203572:	deffc0ef          	jal	ffffffffc0200360 <__panic>

ffffffffc0203576 <_clock_map_swappable>:
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc0203576:	0000e697          	auipc	a3,0xe
ffffffffc020357a:	fea6b683          	ld	a3,-22(a3) # ffffffffc0211560 <curr_ptr>
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc020357e:	751c                	ld	a5,40(a0)
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc0203580:	ce81                	beqz	a3,ffffffffc0203598 <_clock_map_swappable+0x22>
    __list_add(elm, listelm, listelm->next);
ffffffffc0203582:	6794                	ld	a3,8(a5)
ffffffffc0203584:	03060713          	addi	a4,a2,48
}
ffffffffc0203588:	4501                	li	a0,0
    prev->next = next->prev = elm;
ffffffffc020358a:	e298                	sd	a4,0(a3)
ffffffffc020358c:	e798                	sd	a4,8(a5)
    elm->prev = prev;
ffffffffc020358e:	fa1c                	sd	a5,48(a2)
    page->visited = 1;
ffffffffc0203590:	4785                	li	a5,1
    elm->next = next;
ffffffffc0203592:	fe14                	sd	a3,56(a2)
ffffffffc0203594:	ea1c                	sd	a5,16(a2)
}
ffffffffc0203596:	8082                	ret
{
ffffffffc0203598:	1141                	addi	sp,sp,-16
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc020359a:	00002697          	auipc	a3,0x2
ffffffffc020359e:	6e668693          	addi	a3,a3,1766 # ffffffffc0205c80 <etext+0x173e>
ffffffffc02035a2:	00002617          	auipc	a2,0x2
ffffffffc02035a6:	87e60613          	addi	a2,a2,-1922 # ffffffffc0204e20 <etext+0x8de>
ffffffffc02035aa:	03700593          	li	a1,55
ffffffffc02035ae:	00002517          	auipc	a0,0x2
ffffffffc02035b2:	60a50513          	addi	a0,a0,1546 # ffffffffc0205bb8 <etext+0x1676>
{
ffffffffc02035b6:	e406                	sd	ra,8(sp)
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc02035b8:	da9fc0ef          	jal	ffffffffc0200360 <__panic>

ffffffffc02035bc <check_vma_overlap.part.0>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ? 在插入一个新的vma_struct之前，我们要保证它和原有的区间都不重合。
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc02035bc:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc02035be:	00002697          	auipc	a3,0x2
ffffffffc02035c2:	70268693          	addi	a3,a3,1794 # ffffffffc0205cc0 <etext+0x177e>
ffffffffc02035c6:	00002617          	auipc	a2,0x2
ffffffffc02035ca:	85a60613          	addi	a2,a2,-1958 # ffffffffc0204e20 <etext+0x8de>
ffffffffc02035ce:	07e00593          	li	a1,126
ffffffffc02035d2:	00002517          	auipc	a0,0x2
ffffffffc02035d6:	70e50513          	addi	a0,a0,1806 # ffffffffc0205ce0 <etext+0x179e>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc02035da:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc02035dc:	d85fc0ef          	jal	ffffffffc0200360 <__panic>

ffffffffc02035e0 <mm_create>:
mm_create(void) {
ffffffffc02035e0:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));// 使用 kmalloc 分配内存管理结构体 mm_struct
ffffffffc02035e2:	03000513          	li	a0,48
mm_create(void) {
ffffffffc02035e6:	e022                	sd	s0,0(sp)
ffffffffc02035e8:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));// 使用 kmalloc 分配内存管理结构体 mm_struct
ffffffffc02035ea:	a1eff0ef          	jal	ffffffffc0202808 <kmalloc>
ffffffffc02035ee:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc02035f0:	c105                	beqz	a0,ffffffffc0203610 <mm_create+0x30>
    elm->prev = elm->next = elm;
ffffffffc02035f2:	e408                	sd	a0,8(s0)
ffffffffc02035f4:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;// 当前访问的 vma 为空
ffffffffc02035f6:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;// 页目录表初始化为空
ffffffffc02035fa:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;// 初始 vma 数量为 0
ffffffffc02035fe:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);// 如果启用了 swap，则初始化 swap 管理相关数据
ffffffffc0203602:	0000e797          	auipc	a5,0xe
ffffffffc0203606:	f467a783          	lw	a5,-186(a5) # ffffffffc0211548 <swap_init_ok>
ffffffffc020360a:	eb81                	bnez	a5,ffffffffc020361a <mm_create+0x3a>
        else mm->sm_priv = NULL;// 否则，私有 swap 数据为 NULL
ffffffffc020360c:	02053423          	sd	zero,40(a0)
}
ffffffffc0203610:	60a2                	ld	ra,8(sp)
ffffffffc0203612:	8522                	mv	a0,s0
ffffffffc0203614:	6402                	ld	s0,0(sp)
ffffffffc0203616:	0141                	addi	sp,sp,16
ffffffffc0203618:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);// 如果启用了 swap，则初始化 swap 管理相关数据
ffffffffc020361a:	a35ff0ef          	jal	ffffffffc020304e <swap_init_mm>
}
ffffffffc020361e:	60a2                	ld	ra,8(sp)
ffffffffc0203620:	8522                	mv	a0,s0
ffffffffc0203622:	6402                	ld	s0,0(sp)
ffffffffc0203624:	0141                	addi	sp,sp,16
ffffffffc0203626:	8082                	ret

ffffffffc0203628 <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc0203628:	1101                	addi	sp,sp,-32
ffffffffc020362a:	e04a                	sd	s2,0(sp)
ffffffffc020362c:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));// 使用 kmalloc 分配 vma_struct
ffffffffc020362e:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc0203632:	e822                	sd	s0,16(sp)
ffffffffc0203634:	e426                	sd	s1,8(sp)
ffffffffc0203636:	ec06                	sd	ra,24(sp)
ffffffffc0203638:	84ae                	mv	s1,a1
ffffffffc020363a:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));// 使用 kmalloc 分配 vma_struct
ffffffffc020363c:	9ccff0ef          	jal	ffffffffc0202808 <kmalloc>
    if (vma != NULL) {
ffffffffc0203640:	c509                	beqz	a0,ffffffffc020364a <vma_create+0x22>
        vma->vm_start = vm_start;// 初始化 vma 的起始地址、结束地址和访问标志
ffffffffc0203642:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203646:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203648:	ed00                	sd	s0,24(a0)
}
ffffffffc020364a:	60e2                	ld	ra,24(sp)
ffffffffc020364c:	6442                	ld	s0,16(sp)
ffffffffc020364e:	64a2                	ld	s1,8(sp)
ffffffffc0203650:	6902                	ld	s2,0(sp)
ffffffffc0203652:	6105                	addi	sp,sp,32
ffffffffc0203654:	8082                	ret

ffffffffc0203656 <find_vma>:
find_vma(struct mm_struct *mm, uintptr_t addr) {
ffffffffc0203656:	86aa                	mv	a3,a0
    if (mm != NULL) {
ffffffffc0203658:	c505                	beqz	a0,ffffffffc0203680 <find_vma+0x2a>
        vma = mm->mmap_cache;// 首先检查 mmap_cache（上一次访问的 vma）是否包含 addr
ffffffffc020365a:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {// 如果 mmap_cache 为空或不包含 addr，则在 vma 列表中查找
ffffffffc020365c:	c501                	beqz	a0,ffffffffc0203664 <find_vma+0xe>
ffffffffc020365e:	651c                	ld	a5,8(a0)
ffffffffc0203660:	02f5f663          	bgeu	a1,a5,ffffffffc020368c <find_vma+0x36>
    return listelm->next;
ffffffffc0203664:	669c                	ld	a5,8(a3)
                while ((le = list_next(le)) != list) {
ffffffffc0203666:	00f68d63          	beq	a3,a5,ffffffffc0203680 <find_vma+0x2a>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc020366a:	fe87b703          	ld	a4,-24(a5)
ffffffffc020366e:	00e5e663          	bltu	a1,a4,ffffffffc020367a <find_vma+0x24>
ffffffffc0203672:	ff07b703          	ld	a4,-16(a5)
ffffffffc0203676:	00e5e763          	bltu	a1,a4,ffffffffc0203684 <find_vma+0x2e>
ffffffffc020367a:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc020367c:	fef697e3          	bne	a3,a5,ffffffffc020366a <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc0203680:	4501                	li	a0,0
}
ffffffffc0203682:	8082                	ret
                    vma = le2vma(le, list_link);
ffffffffc0203684:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc0203688:	ea88                	sd	a0,16(a3)
ffffffffc020368a:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {// 如果 mmap_cache 为空或不包含 addr，则在 vma 列表中查找
ffffffffc020368c:	691c                	ld	a5,16(a0)
ffffffffc020368e:	fcf5fbe3          	bgeu	a1,a5,ffffffffc0203664 <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc0203692:	ea88                	sd	a0,16(a3)
ffffffffc0203694:	8082                	ret

ffffffffc0203696 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203696:	6590                	ld	a2,8(a1)
ffffffffc0203698:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc020369c:	1141                	addi	sp,sp,-16
ffffffffc020369e:	e406                	sd	ra,8(sp)
ffffffffc02036a0:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc02036a2:	01066763          	bltu	a2,a6,ffffffffc02036b0 <insert_vma_struct+0x1a>
ffffffffc02036a6:	a085                	j	ffffffffc0203706 <insert_vma_struct+0x70>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;// 在链表中查找插入位置，使 vma 按起始地址递增顺序插入
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc02036a8:	fe87b703          	ld	a4,-24(a5)
ffffffffc02036ac:	04e66863          	bltu	a2,a4,ffffffffc02036fc <insert_vma_struct+0x66>
ffffffffc02036b0:	86be                	mv	a3,a5
ffffffffc02036b2:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc02036b4:	fef51ae3          	bne	a0,a5,ffffffffc02036a8 <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);// 获取后继节点

    /* check overlap */// 检查是否与相邻 vma 存在重叠
    if (le_prev != list) {
ffffffffc02036b8:	02a68463          	beq	a3,a0,ffffffffc02036e0 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc02036bc:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc02036c0:	fe86b883          	ld	a7,-24(a3)
ffffffffc02036c4:	08e8f163          	bgeu	a7,a4,ffffffffc0203746 <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02036c8:	04e66f63          	bltu	a2,a4,ffffffffc0203726 <insert_vma_struct+0x90>
    }
    if (le_next != list) {
ffffffffc02036cc:	00f50a63          	beq	a0,a5,ffffffffc02036e0 <insert_vma_struct+0x4a>
ffffffffc02036d0:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc02036d4:	05076963          	bltu	a4,a6,ffffffffc0203726 <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc02036d8:	ff07b603          	ld	a2,-16(a5)
ffffffffc02036dc:	02c77363          	bgeu	a4,a2,ffffffffc0203702 <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;//计数器
ffffffffc02036e0:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc02036e2:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc02036e4:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc02036e8:	e390                	sd	a2,0(a5)
ffffffffc02036ea:	e690                	sd	a2,8(a3)
}
ffffffffc02036ec:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc02036ee:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc02036f0:	f194                	sd	a3,32(a1)
    mm->map_count ++;//计数器
ffffffffc02036f2:	0017079b          	addiw	a5,a4,1
ffffffffc02036f6:	d11c                	sw	a5,32(a0)
}
ffffffffc02036f8:	0141                	addi	sp,sp,16
ffffffffc02036fa:	8082                	ret
    if (le_prev != list) {
ffffffffc02036fc:	fca690e3          	bne	a3,a0,ffffffffc02036bc <insert_vma_struct+0x26>
ffffffffc0203700:	bfd1                	j	ffffffffc02036d4 <insert_vma_struct+0x3e>
ffffffffc0203702:	ebbff0ef          	jal	ffffffffc02035bc <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203706:	00002697          	auipc	a3,0x2
ffffffffc020370a:	5ea68693          	addi	a3,a3,1514 # ffffffffc0205cf0 <etext+0x17ae>
ffffffffc020370e:	00001617          	auipc	a2,0x1
ffffffffc0203712:	71260613          	addi	a2,a2,1810 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0203716:	08500593          	li	a1,133
ffffffffc020371a:	00002517          	auipc	a0,0x2
ffffffffc020371e:	5c650513          	addi	a0,a0,1478 # ffffffffc0205ce0 <etext+0x179e>
ffffffffc0203722:	c3ffc0ef          	jal	ffffffffc0200360 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203726:	00002697          	auipc	a3,0x2
ffffffffc020372a:	60a68693          	addi	a3,a3,1546 # ffffffffc0205d30 <etext+0x17ee>
ffffffffc020372e:	00001617          	auipc	a2,0x1
ffffffffc0203732:	6f260613          	addi	a2,a2,1778 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0203736:	07d00593          	li	a1,125
ffffffffc020373a:	00002517          	auipc	a0,0x2
ffffffffc020373e:	5a650513          	addi	a0,a0,1446 # ffffffffc0205ce0 <etext+0x179e>
ffffffffc0203742:	c1ffc0ef          	jal	ffffffffc0200360 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0203746:	00002697          	auipc	a3,0x2
ffffffffc020374a:	5ca68693          	addi	a3,a3,1482 # ffffffffc0205d10 <etext+0x17ce>
ffffffffc020374e:	00001617          	auipc	a2,0x1
ffffffffc0203752:	6d260613          	addi	a2,a2,1746 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0203756:	07c00593          	li	a1,124
ffffffffc020375a:	00002517          	auipc	a0,0x2
ffffffffc020375e:	58650513          	addi	a0,a0,1414 # ffffffffc0205ce0 <etext+0x179e>
ffffffffc0203762:	bfffc0ef          	jal	ffffffffc0200360 <__panic>

ffffffffc0203766 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
ffffffffc0203766:	1141                	addi	sp,sp,-16
ffffffffc0203768:	e022                	sd	s0,0(sp)
ffffffffc020376a:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc020376c:	6508                	ld	a0,8(a0)
ffffffffc020376e:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0203770:	00a40e63          	beq	s0,a0,ffffffffc020378c <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0203774:	6118                	ld	a4,0(a0)
ffffffffc0203776:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc0203778:	03000593          	li	a1,48
ffffffffc020377c:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc020377e:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203780:	e398                	sd	a4,0(a5)
ffffffffc0203782:	952ff0ef          	jal	ffffffffc02028d4 <kfree>
    return listelm->next;
ffffffffc0203786:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0203788:	fea416e3          	bne	s0,a0,ffffffffc0203774 <mm_destroy+0xe>
    }
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc020378c:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc020378e:	6402                	ld	s0,0(sp)
ffffffffc0203790:	60a2                	ld	ra,8(sp)
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0203792:	03000593          	li	a1,48
}
ffffffffc0203796:	0141                	addi	sp,sp,16
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0203798:	93cff06f          	j	ffffffffc02028d4 <kfree>

ffffffffc020379c <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc020379c:	715d                	addi	sp,sp,-80
ffffffffc020379e:	e486                	sd	ra,72(sp)
ffffffffc02037a0:	f44e                	sd	s3,40(sp)
ffffffffc02037a2:	f052                	sd	s4,32(sp)
ffffffffc02037a4:	e0a2                	sd	s0,64(sp)
ffffffffc02037a6:	fc26                	sd	s1,56(sp)
ffffffffc02037a8:	f84a                	sd	s2,48(sp)
ffffffffc02037aa:	ec56                	sd	s5,24(sp)
ffffffffc02037ac:	e85a                	sd	s6,16(sp)
ffffffffc02037ae:	e45e                	sd	s7,8(sp)
ffffffffc02037b0:	e062                	sd	s8,0(sp)
}

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02037b2:	f01fd0ef          	jal	ffffffffc02016b2 <nr_free_pages>
ffffffffc02037b6:	89aa                	mv	s3,a0
    cprintf("check_vmm() succeeded.\n");
}

static void
check_vma_struct(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02037b8:	efbfd0ef          	jal	ffffffffc02016b2 <nr_free_pages>
ffffffffc02037bc:	8a2a                	mv	s4,a0
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));// 使用 kmalloc 分配内存管理结构体 mm_struct
ffffffffc02037be:	03000513          	li	a0,48
ffffffffc02037c2:	846ff0ef          	jal	ffffffffc0202808 <kmalloc>
    if (mm != NULL) {
ffffffffc02037c6:	30050563          	beqz	a0,ffffffffc0203ad0 <vmm_init+0x334>
    elm->prev = elm->next = elm;
ffffffffc02037ca:	e508                	sd	a0,8(a0)
ffffffffc02037cc:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;// 当前访问的 vma 为空
ffffffffc02037ce:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;// 页目录表初始化为空
ffffffffc02037d2:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;// 初始 vma 数量为 0
ffffffffc02037d6:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);// 如果启用了 swap，则初始化 swap 管理相关数据
ffffffffc02037da:	0000e797          	auipc	a5,0xe
ffffffffc02037de:	d6e7a783          	lw	a5,-658(a5) # ffffffffc0211548 <swap_init_ok>
ffffffffc02037e2:	842a                	mv	s0,a0
ffffffffc02037e4:	2c079363          	bnez	a5,ffffffffc0203aaa <vmm_init+0x30e>
        else mm->sm_priv = NULL;// 否则，私有 swap 数据为 NULL
ffffffffc02037e8:	02053423          	sd	zero,40(a0)
vmm_init(void) {
ffffffffc02037ec:	03200493          	li	s1,50
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));// 使用 kmalloc 分配 vma_struct
ffffffffc02037f0:	03000513          	li	a0,48
ffffffffc02037f4:	814ff0ef          	jal	ffffffffc0202808 <kmalloc>
ffffffffc02037f8:	00248913          	addi	s2,s1,2
ffffffffc02037fc:	85aa                	mv	a1,a0
    if (vma != NULL) {
ffffffffc02037fe:	2a050963          	beqz	a0,ffffffffc0203ab0 <vmm_init+0x314>
        vma->vm_start = vm_start;// 初始化 vma 的起始地址、结束地址和访问标志
ffffffffc0203802:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203804:	01253823          	sd	s2,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203808:	00053c23          	sd	zero,24(a0)
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
ffffffffc020380c:	14ed                	addi	s1,s1,-5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc020380e:	8522                	mv	a0,s0
ffffffffc0203810:	e87ff0ef          	jal	ffffffffc0203696 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc0203814:	fcf1                	bnez	s1,ffffffffc02037f0 <vmm_init+0x54>
ffffffffc0203816:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc020381a:	1f900913          	li	s2,505
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));// 使用 kmalloc 分配 vma_struct
ffffffffc020381e:	03000513          	li	a0,48
ffffffffc0203822:	fe7fe0ef          	jal	ffffffffc0202808 <kmalloc>
ffffffffc0203826:	85aa                	mv	a1,a0
    if (vma != NULL) {
ffffffffc0203828:	2c050463          	beqz	a0,ffffffffc0203af0 <vmm_init+0x354>
        vma->vm_end = vm_end;
ffffffffc020382c:	00248793          	addi	a5,s1,2
        vma->vm_start = vm_start;// 初始化 vma 的起始地址、结束地址和访问标志
ffffffffc0203830:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203832:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203834:	00053c23          	sd	zero,24(a0)
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0203838:	0495                	addi	s1,s1,5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc020383a:	8522                	mv	a0,s0
ffffffffc020383c:	e5bff0ef          	jal	ffffffffc0203696 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0203840:	fd249fe3          	bne	s1,s2,ffffffffc020381e <vmm_init+0x82>
    return listelm->next;
ffffffffc0203844:	00843b03          	ld	s6,8(s0)
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
        assert(le != &(mm->mmap_list));
ffffffffc0203848:	3c8b0b63          	beq	s6,s0,ffffffffc0203c1e <vmm_init+0x482>
    list_entry_t *le = list_next(&(mm->mmap_list));
ffffffffc020384c:	87da                	mv	a5,s6
        assert(le != &(mm->mmap_list));
ffffffffc020384e:	4715                	li	a4,5
    for (i = 1; i <= step2; i ++) {
ffffffffc0203850:	1f400593          	li	a1,500
ffffffffc0203854:	a021                	j	ffffffffc020385c <vmm_init+0xc0>
        assert(le != &(mm->mmap_list));
ffffffffc0203856:	0715                	addi	a4,a4,5
ffffffffc0203858:	3c878363          	beq	a5,s0,ffffffffc0203c1e <vmm_init+0x482>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc020385c:	fe87b683          	ld	a3,-24(a5)
ffffffffc0203860:	32e69f63          	bne	a3,a4,ffffffffc0203b9e <vmm_init+0x402>
ffffffffc0203864:	ff07b603          	ld	a2,-16(a5)
ffffffffc0203868:	00270693          	addi	a3,a4,2
ffffffffc020386c:	32d61963          	bne	a2,a3,ffffffffc0203b9e <vmm_init+0x402>
ffffffffc0203870:	679c                	ld	a5,8(a5)
    for (i = 1; i <= step2; i ++) {
ffffffffc0203872:	feb712e3          	bne	a4,a1,ffffffffc0203856 <vmm_init+0xba>
ffffffffc0203876:	4b9d                	li	s7,7
ffffffffc0203878:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc020387a:	1f900c13          	li	s8,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc020387e:	85a6                	mv	a1,s1
ffffffffc0203880:	8522                	mv	a0,s0
ffffffffc0203882:	dd5ff0ef          	jal	ffffffffc0203656 <find_vma>
ffffffffc0203886:	8aaa                	mv	s5,a0
        assert(vma1 != NULL);
ffffffffc0203888:	3c050b63          	beqz	a0,ffffffffc0203c5e <vmm_init+0x4c2>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc020388c:	00148593          	addi	a1,s1,1
ffffffffc0203890:	8522                	mv	a0,s0
ffffffffc0203892:	dc5ff0ef          	jal	ffffffffc0203656 <find_vma>
ffffffffc0203896:	892a                	mv	s2,a0
        assert(vma2 != NULL);
ffffffffc0203898:	3a050363          	beqz	a0,ffffffffc0203c3e <vmm_init+0x4a2>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc020389c:	85de                	mv	a1,s7
ffffffffc020389e:	8522                	mv	a0,s0
ffffffffc02038a0:	db7ff0ef          	jal	ffffffffc0203656 <find_vma>
        assert(vma3 == NULL);
ffffffffc02038a4:	32051d63          	bnez	a0,ffffffffc0203bde <vmm_init+0x442>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc02038a8:	00348593          	addi	a1,s1,3
ffffffffc02038ac:	8522                	mv	a0,s0
ffffffffc02038ae:	da9ff0ef          	jal	ffffffffc0203656 <find_vma>
        assert(vma4 == NULL);
ffffffffc02038b2:	30051663          	bnez	a0,ffffffffc0203bbe <vmm_init+0x422>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc02038b6:	00448593          	addi	a1,s1,4
ffffffffc02038ba:	8522                	mv	a0,s0
ffffffffc02038bc:	d9bff0ef          	jal	ffffffffc0203656 <find_vma>
        assert(vma5 == NULL);
ffffffffc02038c0:	32051f63          	bnez	a0,ffffffffc0203bfe <vmm_init+0x462>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc02038c4:	008ab783          	ld	a5,8(s5)
ffffffffc02038c8:	2a979b63          	bne	a5,s1,ffffffffc0203b7e <vmm_init+0x3e2>
ffffffffc02038cc:	010ab783          	ld	a5,16(s5)
ffffffffc02038d0:	2afb9763          	bne	s7,a5,ffffffffc0203b7e <vmm_init+0x3e2>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc02038d4:	00893783          	ld	a5,8(s2)
ffffffffc02038d8:	28979363          	bne	a5,s1,ffffffffc0203b5e <vmm_init+0x3c2>
ffffffffc02038dc:	01093783          	ld	a5,16(s2)
ffffffffc02038e0:	26fb9f63          	bne	s7,a5,ffffffffc0203b5e <vmm_init+0x3c2>
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc02038e4:	0495                	addi	s1,s1,5
ffffffffc02038e6:	0b95                	addi	s7,s7,5
ffffffffc02038e8:	f9849be3          	bne	s1,s8,ffffffffc020387e <vmm_init+0xe2>
ffffffffc02038ec:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc02038ee:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc02038f0:	85a6                	mv	a1,s1
ffffffffc02038f2:	8522                	mv	a0,s0
ffffffffc02038f4:	d63ff0ef          	jal	ffffffffc0203656 <find_vma>
        if (vma_below_5 != NULL ) {
ffffffffc02038f8:	3a051363          	bnez	a0,ffffffffc0203c9e <vmm_init+0x502>
    for (i =4; i>=0; i--) {
ffffffffc02038fc:	14fd                	addi	s1,s1,-1
ffffffffc02038fe:	ff2499e3          	bne	s1,s2,ffffffffc02038f0 <vmm_init+0x154>
    __list_del(listelm->prev, listelm->next);
ffffffffc0203902:	000b3703          	ld	a4,0(s6)
ffffffffc0203906:	008b3783          	ld	a5,8(s6)
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc020390a:	fe0b0513          	addi	a0,s6,-32
ffffffffc020390e:	03000593          	li	a1,48
    prev->next = next;
ffffffffc0203912:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203914:	e398                	sd	a4,0(a5)
ffffffffc0203916:	fbffe0ef          	jal	ffffffffc02028d4 <kfree>
    return listelm->next;
ffffffffc020391a:	00843b03          	ld	s6,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc020391e:	ff6412e3          	bne	s0,s6,ffffffffc0203902 <vmm_init+0x166>
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0203922:	03000593          	li	a1,48
ffffffffc0203926:	8522                	mv	a0,s0
ffffffffc0203928:	fadfe0ef          	jal	ffffffffc02028d4 <kfree>
        assert(vma_below_5 == NULL);
    }

    mm_destroy(mm);

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc020392c:	d87fd0ef          	jal	ffffffffc02016b2 <nr_free_pages>
ffffffffc0203930:	3caa1163          	bne	s4,a0,ffffffffc0203cf2 <vmm_init+0x556>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0203934:	00002517          	auipc	a0,0x2
ffffffffc0203938:	58450513          	addi	a0,a0,1412 # ffffffffc0205eb8 <etext+0x1976>
ffffffffc020393c:	f7efc0ef          	jal	ffffffffc02000ba <cprintf>

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
	// char *name = "check_pgfault";
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0203940:	d73fd0ef          	jal	ffffffffc02016b2 <nr_free_pages>
ffffffffc0203944:	84aa                	mv	s1,a0
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));// 使用 kmalloc 分配内存管理结构体 mm_struct
ffffffffc0203946:	03000513          	li	a0,48
ffffffffc020394a:	ebffe0ef          	jal	ffffffffc0202808 <kmalloc>
ffffffffc020394e:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0203950:	1e050063          	beqz	a0,ffffffffc0203b30 <vmm_init+0x394>
        if (swap_init_ok) swap_init_mm(mm);// 如果启用了 swap，则初始化 swap 管理相关数据
ffffffffc0203954:	0000e797          	auipc	a5,0xe
ffffffffc0203958:	bf47a783          	lw	a5,-1036(a5) # ffffffffc0211548 <swap_init_ok>
    elm->prev = elm->next = elm;
ffffffffc020395c:	e508                	sd	a0,8(a0)
ffffffffc020395e:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;// 当前访问的 vma 为空
ffffffffc0203960:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;// 页目录表初始化为空
ffffffffc0203964:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;// 初始 vma 数量为 0
ffffffffc0203968:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);// 如果启用了 swap，则初始化 swap 管理相关数据
ffffffffc020396c:	1e079663          	bnez	a5,ffffffffc0203b58 <vmm_init+0x3bc>
        else mm->sm_priv = NULL;// 否则，私有 swap 数据为 NULL
ffffffffc0203970:	02053423          	sd	zero,40(a0)

    check_mm_struct = mm_create();

    assert(check_mm_struct != NULL);
    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203974:	0000ea17          	auipc	s4,0xe
ffffffffc0203978:	bb4a3a03          	ld	s4,-1100(s4) # ffffffffc0211528 <boot_pgdir>
    assert(pgdir[0] == 0);
ffffffffc020397c:	000a3783          	ld	a5,0(s4)
    check_mm_struct = mm_create();
ffffffffc0203980:	0000e717          	auipc	a4,0xe
ffffffffc0203984:	be873823          	sd	s0,-1040(a4) # ffffffffc0211570 <check_mm_struct>
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203988:	01443c23          	sd	s4,24(s0)
    assert(pgdir[0] == 0);
ffffffffc020398c:	2e079963          	bnez	a5,ffffffffc0203c7e <vmm_init+0x4e2>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));// 使用 kmalloc 分配 vma_struct
ffffffffc0203990:	03000513          	li	a0,48
ffffffffc0203994:	e75fe0ef          	jal	ffffffffc0202808 <kmalloc>
ffffffffc0203998:	892a                	mv	s2,a0
    if (vma != NULL) {
ffffffffc020399a:	16050b63          	beqz	a0,ffffffffc0203b10 <vmm_init+0x374>
        vma->vm_end = vm_end;
ffffffffc020399e:	002007b7          	lui	a5,0x200
ffffffffc02039a2:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02039a4:	4789                	li	a5,2
ffffffffc02039a6:	ed1c                	sd	a5,24(a0)

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);

    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc02039a8:	85aa                	mv	a1,a0
        vma->vm_start = vm_start;// 初始化 vma 的起始地址、结束地址和访问标志
ffffffffc02039aa:	00053423          	sd	zero,8(a0)
    insert_vma_struct(mm, vma);
ffffffffc02039ae:	8522                	mv	a0,s0
ffffffffc02039b0:	ce7ff0ef          	jal	ffffffffc0203696 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc02039b4:	10000593          	li	a1,256
ffffffffc02039b8:	8522                	mv	a0,s0
ffffffffc02039ba:	c9dff0ef          	jal	ffffffffc0203656 <find_vma>
ffffffffc02039be:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc02039c2:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc02039c6:	30a91663          	bne	s2,a0,ffffffffc0203cd2 <vmm_init+0x536>
        *(char *)(addr + i) = i;
ffffffffc02039ca:	00f78023          	sb	a5,0(a5) # 200000 <kern_entry-0xffffffffc0000000>
    for (i = 0; i < 100; i ++) {
ffffffffc02039ce:	0785                	addi	a5,a5,1
ffffffffc02039d0:	fee79de3          	bne	a5,a4,ffffffffc02039ca <vmm_init+0x22e>
ffffffffc02039d4:	6705                	lui	a4,0x1
ffffffffc02039d6:	10000793          	li	a5,256
ffffffffc02039da:	35670713          	addi	a4,a4,854 # 1356 <kern_entry-0xffffffffc01fecaa>
        sum += i;
    }
    for (i = 0; i < 100; i ++) {
ffffffffc02039de:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc02039e2:	0007c683          	lbu	a3,0(a5)
    for (i = 0; i < 100; i ++) {
ffffffffc02039e6:	0785                	addi	a5,a5,1
        sum -= *(char *)(addr + i);
ffffffffc02039e8:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc02039ea:	fec79ce3          	bne	a5,a2,ffffffffc02039e2 <vmm_init+0x246>
    }
    assert(sum == 0);
ffffffffc02039ee:	32071e63          	bnez	a4,ffffffffc0203d2a <vmm_init+0x58e>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc02039f2:	4581                	li	a1,0
ffffffffc02039f4:	8552                	mv	a0,s4
ffffffffc02039f6:	f7ffd0ef          	jal	ffffffffc0201974 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc02039fa:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc02039fe:	0000e717          	auipc	a4,0xe
ffffffffc0203a02:	b3a73703          	ld	a4,-1222(a4) # ffffffffc0211538 <npage>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203a06:	078a                	slli	a5,a5,0x2
ffffffffc0203a08:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203a0a:	30e7f463          	bgeu	a5,a4,ffffffffc0203d12 <vmm_init+0x576>
    return &pages[PPN(pa) - nbase];
ffffffffc0203a0e:	00003717          	auipc	a4,0x3
ffffffffc0203a12:	95a73703          	ld	a4,-1702(a4) # ffffffffc0206368 <nbase>
ffffffffc0203a16:	8f99                	sub	a5,a5,a4
ffffffffc0203a18:	00379713          	slli	a4,a5,0x3
ffffffffc0203a1c:	97ba                	add	a5,a5,a4
ffffffffc0203a1e:	078e                	slli	a5,a5,0x3

    free_page(pde2page(pgdir[0]));
ffffffffc0203a20:	0000e517          	auipc	a0,0xe
ffffffffc0203a24:	b2053503          	ld	a0,-1248(a0) # ffffffffc0211540 <pages>
ffffffffc0203a28:	953e                	add	a0,a0,a5
ffffffffc0203a2a:	4585                	li	a1,1
ffffffffc0203a2c:	c47fd0ef          	jal	ffffffffc0201672 <free_pages>
    return listelm->next;
ffffffffc0203a30:	6408                	ld	a0,8(s0)

    pgdir[0] = 0;
ffffffffc0203a32:	000a3023          	sd	zero,0(s4)

    mm->pgdir = NULL;
ffffffffc0203a36:	00043c23          	sd	zero,24(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0203a3a:	00850e63          	beq	a0,s0,ffffffffc0203a56 <vmm_init+0x2ba>
    __list_del(listelm->prev, listelm->next);
ffffffffc0203a3e:	6118                	ld	a4,0(a0)
ffffffffc0203a40:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc0203a42:	03000593          	li	a1,48
ffffffffc0203a46:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0203a48:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203a4a:	e398                	sd	a4,0(a5)
ffffffffc0203a4c:	e89fe0ef          	jal	ffffffffc02028d4 <kfree>
    return listelm->next;
ffffffffc0203a50:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0203a52:	fea416e3          	bne	s0,a0,ffffffffc0203a3e <vmm_init+0x2a2>
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0203a56:	03000593          	li	a1,48
ffffffffc0203a5a:	8522                	mv	a0,s0
ffffffffc0203a5c:	e79fe0ef          	jal	ffffffffc02028d4 <kfree>
    mm_destroy(mm);

    check_mm_struct = NULL;
    nr_free_pages_store--;	// szx : Sv39第二级页表多占了一个内存页，所以执行此操作
ffffffffc0203a60:	14fd                	addi	s1,s1,-1
    check_mm_struct = NULL;
ffffffffc0203a62:	0000e797          	auipc	a5,0xe
ffffffffc0203a66:	b007b723          	sd	zero,-1266(a5) # ffffffffc0211570 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203a6a:	c49fd0ef          	jal	ffffffffc02016b2 <nr_free_pages>
ffffffffc0203a6e:	2ea49e63          	bne	s1,a0,ffffffffc0203d6a <vmm_init+0x5ce>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0203a72:	00002517          	auipc	a0,0x2
ffffffffc0203a76:	4ae50513          	addi	a0,a0,1198 # ffffffffc0205f20 <etext+0x19de>
ffffffffc0203a7a:	e40fc0ef          	jal	ffffffffc02000ba <cprintf>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203a7e:	c35fd0ef          	jal	ffffffffc02016b2 <nr_free_pages>
    nr_free_pages_store--;	// szx : Sv39三级页表多占一个内存页，所以执行此操作
ffffffffc0203a82:	19fd                	addi	s3,s3,-1
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203a84:	2ca99363          	bne	s3,a0,ffffffffc0203d4a <vmm_init+0x5ae>
}
ffffffffc0203a88:	6406                	ld	s0,64(sp)
ffffffffc0203a8a:	60a6                	ld	ra,72(sp)
ffffffffc0203a8c:	74e2                	ld	s1,56(sp)
ffffffffc0203a8e:	7942                	ld	s2,48(sp)
ffffffffc0203a90:	79a2                	ld	s3,40(sp)
ffffffffc0203a92:	7a02                	ld	s4,32(sp)
ffffffffc0203a94:	6ae2                	ld	s5,24(sp)
ffffffffc0203a96:	6b42                	ld	s6,16(sp)
ffffffffc0203a98:	6ba2                	ld	s7,8(sp)
ffffffffc0203a9a:	6c02                	ld	s8,0(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203a9c:	00002517          	auipc	a0,0x2
ffffffffc0203aa0:	4a450513          	addi	a0,a0,1188 # ffffffffc0205f40 <etext+0x19fe>
}
ffffffffc0203aa4:	6161                	addi	sp,sp,80
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203aa6:	e14fc06f          	j	ffffffffc02000ba <cprintf>
        if (swap_init_ok) swap_init_mm(mm);// 如果启用了 swap，则初始化 swap 管理相关数据
ffffffffc0203aaa:	da4ff0ef          	jal	ffffffffc020304e <swap_init_mm>
    for (i = step1; i >= 1; i --) {
ffffffffc0203aae:	bb3d                	j	ffffffffc02037ec <vmm_init+0x50>
        assert(vma != NULL);
ffffffffc0203ab0:	00002697          	auipc	a3,0x2
ffffffffc0203ab4:	e1868693          	addi	a3,a3,-488 # ffffffffc02058c8 <etext+0x1386>
ffffffffc0203ab8:	00001617          	auipc	a2,0x1
ffffffffc0203abc:	36860613          	addi	a2,a2,872 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0203ac0:	0cf00593          	li	a1,207
ffffffffc0203ac4:	00002517          	auipc	a0,0x2
ffffffffc0203ac8:	21c50513          	addi	a0,a0,540 # ffffffffc0205ce0 <etext+0x179e>
ffffffffc0203acc:	895fc0ef          	jal	ffffffffc0200360 <__panic>
    assert(mm != NULL);
ffffffffc0203ad0:	00002697          	auipc	a3,0x2
ffffffffc0203ad4:	dc068693          	addi	a3,a3,-576 # ffffffffc0205890 <etext+0x134e>
ffffffffc0203ad8:	00001617          	auipc	a2,0x1
ffffffffc0203adc:	34860613          	addi	a2,a2,840 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0203ae0:	0c800593          	li	a1,200
ffffffffc0203ae4:	00002517          	auipc	a0,0x2
ffffffffc0203ae8:	1fc50513          	addi	a0,a0,508 # ffffffffc0205ce0 <etext+0x179e>
ffffffffc0203aec:	875fc0ef          	jal	ffffffffc0200360 <__panic>
        assert(vma != NULL);
ffffffffc0203af0:	00002697          	auipc	a3,0x2
ffffffffc0203af4:	dd868693          	addi	a3,a3,-552 # ffffffffc02058c8 <etext+0x1386>
ffffffffc0203af8:	00001617          	auipc	a2,0x1
ffffffffc0203afc:	32860613          	addi	a2,a2,808 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0203b00:	0d500593          	li	a1,213
ffffffffc0203b04:	00002517          	auipc	a0,0x2
ffffffffc0203b08:	1dc50513          	addi	a0,a0,476 # ffffffffc0205ce0 <etext+0x179e>
ffffffffc0203b0c:	855fc0ef          	jal	ffffffffc0200360 <__panic>
    assert(vma != NULL);
ffffffffc0203b10:	00002697          	auipc	a3,0x2
ffffffffc0203b14:	db868693          	addi	a3,a3,-584 # ffffffffc02058c8 <etext+0x1386>
ffffffffc0203b18:	00001617          	auipc	a2,0x1
ffffffffc0203b1c:	30860613          	addi	a2,a2,776 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0203b20:	11200593          	li	a1,274
ffffffffc0203b24:	00002517          	auipc	a0,0x2
ffffffffc0203b28:	1bc50513          	addi	a0,a0,444 # ffffffffc0205ce0 <etext+0x179e>
ffffffffc0203b2c:	835fc0ef          	jal	ffffffffc0200360 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0203b30:	00002697          	auipc	a3,0x2
ffffffffc0203b34:	3a868693          	addi	a3,a3,936 # ffffffffc0205ed8 <etext+0x1996>
ffffffffc0203b38:	00001617          	auipc	a2,0x1
ffffffffc0203b3c:	2e860613          	addi	a2,a2,744 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0203b40:	10b00593          	li	a1,267
ffffffffc0203b44:	00002517          	auipc	a0,0x2
ffffffffc0203b48:	19c50513          	addi	a0,a0,412 # ffffffffc0205ce0 <etext+0x179e>
    check_mm_struct = mm_create();
ffffffffc0203b4c:	0000e797          	auipc	a5,0xe
ffffffffc0203b50:	a207b223          	sd	zero,-1500(a5) # ffffffffc0211570 <check_mm_struct>
    assert(check_mm_struct != NULL);
ffffffffc0203b54:	80dfc0ef          	jal	ffffffffc0200360 <__panic>
        if (swap_init_ok) swap_init_mm(mm);// 如果启用了 swap，则初始化 swap 管理相关数据
ffffffffc0203b58:	cf6ff0ef          	jal	ffffffffc020304e <swap_init_mm>
    assert(check_mm_struct != NULL);
ffffffffc0203b5c:	bd21                	j	ffffffffc0203974 <vmm_init+0x1d8>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0203b5e:	00002697          	auipc	a3,0x2
ffffffffc0203b62:	2c268693          	addi	a3,a3,706 # ffffffffc0205e20 <etext+0x18de>
ffffffffc0203b66:	00001617          	auipc	a2,0x1
ffffffffc0203b6a:	2ba60613          	addi	a2,a2,698 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0203b6e:	0ef00593          	li	a1,239
ffffffffc0203b72:	00002517          	auipc	a0,0x2
ffffffffc0203b76:	16e50513          	addi	a0,a0,366 # ffffffffc0205ce0 <etext+0x179e>
ffffffffc0203b7a:	fe6fc0ef          	jal	ffffffffc0200360 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0203b7e:	00002697          	auipc	a3,0x2
ffffffffc0203b82:	27268693          	addi	a3,a3,626 # ffffffffc0205df0 <etext+0x18ae>
ffffffffc0203b86:	00001617          	auipc	a2,0x1
ffffffffc0203b8a:	29a60613          	addi	a2,a2,666 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0203b8e:	0ee00593          	li	a1,238
ffffffffc0203b92:	00002517          	auipc	a0,0x2
ffffffffc0203b96:	14e50513          	addi	a0,a0,334 # ffffffffc0205ce0 <etext+0x179e>
ffffffffc0203b9a:	fc6fc0ef          	jal	ffffffffc0200360 <__panic>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203b9e:	00002697          	auipc	a3,0x2
ffffffffc0203ba2:	1ca68693          	addi	a3,a3,458 # ffffffffc0205d68 <etext+0x1826>
ffffffffc0203ba6:	00001617          	auipc	a2,0x1
ffffffffc0203baa:	27a60613          	addi	a2,a2,634 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0203bae:	0de00593          	li	a1,222
ffffffffc0203bb2:	00002517          	auipc	a0,0x2
ffffffffc0203bb6:	12e50513          	addi	a0,a0,302 # ffffffffc0205ce0 <etext+0x179e>
ffffffffc0203bba:	fa6fc0ef          	jal	ffffffffc0200360 <__panic>
        assert(vma4 == NULL);
ffffffffc0203bbe:	00002697          	auipc	a3,0x2
ffffffffc0203bc2:	21268693          	addi	a3,a3,530 # ffffffffc0205dd0 <etext+0x188e>
ffffffffc0203bc6:	00001617          	auipc	a2,0x1
ffffffffc0203bca:	25a60613          	addi	a2,a2,602 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0203bce:	0ea00593          	li	a1,234
ffffffffc0203bd2:	00002517          	auipc	a0,0x2
ffffffffc0203bd6:	10e50513          	addi	a0,a0,270 # ffffffffc0205ce0 <etext+0x179e>
ffffffffc0203bda:	f86fc0ef          	jal	ffffffffc0200360 <__panic>
        assert(vma3 == NULL);
ffffffffc0203bde:	00002697          	auipc	a3,0x2
ffffffffc0203be2:	1e268693          	addi	a3,a3,482 # ffffffffc0205dc0 <etext+0x187e>
ffffffffc0203be6:	00001617          	auipc	a2,0x1
ffffffffc0203bea:	23a60613          	addi	a2,a2,570 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0203bee:	0e800593          	li	a1,232
ffffffffc0203bf2:	00002517          	auipc	a0,0x2
ffffffffc0203bf6:	0ee50513          	addi	a0,a0,238 # ffffffffc0205ce0 <etext+0x179e>
ffffffffc0203bfa:	f66fc0ef          	jal	ffffffffc0200360 <__panic>
        assert(vma5 == NULL);
ffffffffc0203bfe:	00002697          	auipc	a3,0x2
ffffffffc0203c02:	1e268693          	addi	a3,a3,482 # ffffffffc0205de0 <etext+0x189e>
ffffffffc0203c06:	00001617          	auipc	a2,0x1
ffffffffc0203c0a:	21a60613          	addi	a2,a2,538 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0203c0e:	0ec00593          	li	a1,236
ffffffffc0203c12:	00002517          	auipc	a0,0x2
ffffffffc0203c16:	0ce50513          	addi	a0,a0,206 # ffffffffc0205ce0 <etext+0x179e>
ffffffffc0203c1a:	f46fc0ef          	jal	ffffffffc0200360 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0203c1e:	00002697          	auipc	a3,0x2
ffffffffc0203c22:	13268693          	addi	a3,a3,306 # ffffffffc0205d50 <etext+0x180e>
ffffffffc0203c26:	00001617          	auipc	a2,0x1
ffffffffc0203c2a:	1fa60613          	addi	a2,a2,506 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0203c2e:	0dc00593          	li	a1,220
ffffffffc0203c32:	00002517          	auipc	a0,0x2
ffffffffc0203c36:	0ae50513          	addi	a0,a0,174 # ffffffffc0205ce0 <etext+0x179e>
ffffffffc0203c3a:	f26fc0ef          	jal	ffffffffc0200360 <__panic>
        assert(vma2 != NULL);
ffffffffc0203c3e:	00002697          	auipc	a3,0x2
ffffffffc0203c42:	17268693          	addi	a3,a3,370 # ffffffffc0205db0 <etext+0x186e>
ffffffffc0203c46:	00001617          	auipc	a2,0x1
ffffffffc0203c4a:	1da60613          	addi	a2,a2,474 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0203c4e:	0e600593          	li	a1,230
ffffffffc0203c52:	00002517          	auipc	a0,0x2
ffffffffc0203c56:	08e50513          	addi	a0,a0,142 # ffffffffc0205ce0 <etext+0x179e>
ffffffffc0203c5a:	f06fc0ef          	jal	ffffffffc0200360 <__panic>
        assert(vma1 != NULL);
ffffffffc0203c5e:	00002697          	auipc	a3,0x2
ffffffffc0203c62:	14268693          	addi	a3,a3,322 # ffffffffc0205da0 <etext+0x185e>
ffffffffc0203c66:	00001617          	auipc	a2,0x1
ffffffffc0203c6a:	1ba60613          	addi	a2,a2,442 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0203c6e:	0e400593          	li	a1,228
ffffffffc0203c72:	00002517          	auipc	a0,0x2
ffffffffc0203c76:	06e50513          	addi	a0,a0,110 # ffffffffc0205ce0 <etext+0x179e>
ffffffffc0203c7a:	ee6fc0ef          	jal	ffffffffc0200360 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0203c7e:	00002697          	auipc	a3,0x2
ffffffffc0203c82:	c3a68693          	addi	a3,a3,-966 # ffffffffc02058b8 <etext+0x1376>
ffffffffc0203c86:	00001617          	auipc	a2,0x1
ffffffffc0203c8a:	19a60613          	addi	a2,a2,410 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0203c8e:	10e00593          	li	a1,270
ffffffffc0203c92:	00002517          	auipc	a0,0x2
ffffffffc0203c96:	04e50513          	addi	a0,a0,78 # ffffffffc0205ce0 <etext+0x179e>
ffffffffc0203c9a:	ec6fc0ef          	jal	ffffffffc0200360 <__panic>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0203c9e:	6914                	ld	a3,16(a0)
ffffffffc0203ca0:	6510                	ld	a2,8(a0)
ffffffffc0203ca2:	0004859b          	sext.w	a1,s1
ffffffffc0203ca6:	00002517          	auipc	a0,0x2
ffffffffc0203caa:	1aa50513          	addi	a0,a0,426 # ffffffffc0205e50 <etext+0x190e>
ffffffffc0203cae:	c0cfc0ef          	jal	ffffffffc02000ba <cprintf>
        assert(vma_below_5 == NULL);
ffffffffc0203cb2:	00002697          	auipc	a3,0x2
ffffffffc0203cb6:	1c668693          	addi	a3,a3,454 # ffffffffc0205e78 <etext+0x1936>
ffffffffc0203cba:	00001617          	auipc	a2,0x1
ffffffffc0203cbe:	16660613          	addi	a2,a2,358 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0203cc2:	0f700593          	li	a1,247
ffffffffc0203cc6:	00002517          	auipc	a0,0x2
ffffffffc0203cca:	01a50513          	addi	a0,a0,26 # ffffffffc0205ce0 <etext+0x179e>
ffffffffc0203cce:	e92fc0ef          	jal	ffffffffc0200360 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0203cd2:	00002697          	auipc	a3,0x2
ffffffffc0203cd6:	21e68693          	addi	a3,a3,542 # ffffffffc0205ef0 <etext+0x19ae>
ffffffffc0203cda:	00001617          	auipc	a2,0x1
ffffffffc0203cde:	14660613          	addi	a2,a2,326 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0203ce2:	11700593          	li	a1,279
ffffffffc0203ce6:	00002517          	auipc	a0,0x2
ffffffffc0203cea:	ffa50513          	addi	a0,a0,-6 # ffffffffc0205ce0 <etext+0x179e>
ffffffffc0203cee:	e72fc0ef          	jal	ffffffffc0200360 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203cf2:	00002697          	auipc	a3,0x2
ffffffffc0203cf6:	19e68693          	addi	a3,a3,414 # ffffffffc0205e90 <etext+0x194e>
ffffffffc0203cfa:	00001617          	auipc	a2,0x1
ffffffffc0203cfe:	12660613          	addi	a2,a2,294 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0203d02:	0fc00593          	li	a1,252
ffffffffc0203d06:	00002517          	auipc	a0,0x2
ffffffffc0203d0a:	fda50513          	addi	a0,a0,-38 # ffffffffc0205ce0 <etext+0x179e>
ffffffffc0203d0e:	e52fc0ef          	jal	ffffffffc0200360 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203d12:	00001617          	auipc	a2,0x1
ffffffffc0203d16:	4be60613          	addi	a2,a2,1214 # ffffffffc02051d0 <etext+0xc8e>
ffffffffc0203d1a:	06500593          	li	a1,101
ffffffffc0203d1e:	00001517          	auipc	a0,0x1
ffffffffc0203d22:	4d250513          	addi	a0,a0,1234 # ffffffffc02051f0 <etext+0xcae>
ffffffffc0203d26:	e3afc0ef          	jal	ffffffffc0200360 <__panic>
    assert(sum == 0);
ffffffffc0203d2a:	00002697          	auipc	a3,0x2
ffffffffc0203d2e:	1e668693          	addi	a3,a3,486 # ffffffffc0205f10 <etext+0x19ce>
ffffffffc0203d32:	00001617          	auipc	a2,0x1
ffffffffc0203d36:	0ee60613          	addi	a2,a2,238 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0203d3a:	12100593          	li	a1,289
ffffffffc0203d3e:	00002517          	auipc	a0,0x2
ffffffffc0203d42:	fa250513          	addi	a0,a0,-94 # ffffffffc0205ce0 <etext+0x179e>
ffffffffc0203d46:	e1afc0ef          	jal	ffffffffc0200360 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203d4a:	00002697          	auipc	a3,0x2
ffffffffc0203d4e:	14668693          	addi	a3,a3,326 # ffffffffc0205e90 <etext+0x194e>
ffffffffc0203d52:	00001617          	auipc	a2,0x1
ffffffffc0203d56:	0ce60613          	addi	a2,a2,206 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0203d5a:	0be00593          	li	a1,190
ffffffffc0203d5e:	00002517          	auipc	a0,0x2
ffffffffc0203d62:	f8250513          	addi	a0,a0,-126 # ffffffffc0205ce0 <etext+0x179e>
ffffffffc0203d66:	dfafc0ef          	jal	ffffffffc0200360 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203d6a:	00002697          	auipc	a3,0x2
ffffffffc0203d6e:	12668693          	addi	a3,a3,294 # ffffffffc0205e90 <etext+0x194e>
ffffffffc0203d72:	00001617          	auipc	a2,0x1
ffffffffc0203d76:	0ae60613          	addi	a2,a2,174 # ffffffffc0204e20 <etext+0x8de>
ffffffffc0203d7a:	12f00593          	li	a1,303
ffffffffc0203d7e:	00002517          	auipc	a0,0x2
ffffffffc0203d82:	f6250513          	addi	a0,a0,-158 # ffffffffc0205ce0 <etext+0x179e>
ffffffffc0203d86:	ddafc0ef          	jal	ffffffffc0200360 <__panic>

ffffffffc0203d8a <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0203d8a:	7179                	addi	sp,sp,-48
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);// 尝试在 mm 中查找包含地址 addr 的 vma
ffffffffc0203d8c:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0203d8e:	f022                	sd	s0,32(sp)
ffffffffc0203d90:	ec26                	sd	s1,24(sp)
ffffffffc0203d92:	f406                	sd	ra,40(sp)
ffffffffc0203d94:	8432                	mv	s0,a2
ffffffffc0203d96:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);// 尝试在 mm 中查找包含地址 addr 的 vma
ffffffffc0203d98:	8bfff0ef          	jal	ffffffffc0203656 <find_vma>

    pgfault_num++;
ffffffffc0203d9c:	0000d797          	auipc	a5,0xd
ffffffffc0203da0:	7cc7a783          	lw	a5,1996(a5) # ffffffffc0211568 <pgfault_num>
ffffffffc0203da4:	2785                	addiw	a5,a5,1
ffffffffc0203da6:	0000d717          	auipc	a4,0xd
ffffffffc0203daa:	7cf72123          	sw	a5,1986(a4) # ffffffffc0211568 <pgfault_num>
    //If the addr is in the range of a mm's vma?检查 addr 是否在 mm 的某个 vma 范围内
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0203dae:	c159                	beqz	a0,ffffffffc0203e34 <do_pgfault+0xaa>
ffffffffc0203db0:	651c                	ld	a5,8(a0)
ffffffffc0203db2:	08f46163          	bltu	s0,a5,ffffffffc0203e34 <do_pgfault+0xaa>
     * (3) 对不存在的地址的读操作，并且该地址是可读的
     * 则继续处理
     *
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203db6:	6d1c                	ld	a5,24(a0)
ffffffffc0203db8:	e84a                	sd	s2,16(sp)
        perm |= (PTE_R | PTE_W);// 如果 vma 可写，设置 PTE_R 和 PTE_W 标志
ffffffffc0203dba:	4959                	li	s2,22
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203dbc:	8b89                	andi	a5,a5,2
ffffffffc0203dbe:	cbb1                	beqz	a5,ffffffffc0203e12 <do_pgfault+0x88>
    }
    addr = ROUNDDOWN(addr, PGSIZE);// 将地址对齐到页大小
ffffffffc0203dc0:	77fd                	lui	a5,0xfffff
    *   mm->pgdir : the PDT of these vma
    *
    */


    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc0203dc2:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);// 将地址对齐到页大小
ffffffffc0203dc4:	8c7d                	and	s0,s0,a5
    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc0203dc6:	85a2                	mv	a1,s0
ffffffffc0203dc8:	4605                	li	a2,1
ffffffffc0203dca:	923fd0ef          	jal	ffffffffc02016ec <get_pte>
                                         //PT(Page Table) isn't existed, then
                                         //create a PT.获取或创建地址 addr 的页表项 ptep
    if (*ptep == 0) {// 如果页表项为空，说明页面还没有分配，则分配新页面并建立映射
ffffffffc0203dce:	610c                	ld	a1,0(a0)
ffffffffc0203dd0:	c1b9                	beqz	a1,ffffffffc0203e16 <do_pgfault+0x8c>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0203dd2:	0000d797          	auipc	a5,0xd
ffffffffc0203dd6:	7767a783          	lw	a5,1910(a5) # ffffffffc0211548 <swap_init_ok>
ffffffffc0203dda:	c7b5                	beqz	a5,ffffffffc0203e46 <do_pgfault+0xbc>
            struct Page *page = NULL;
            // 你要编写的内容在这里，请基于上文说明以及下文的英文注释完成代码编写
            //(1）According to the mm AND addr, try
            //to load the content of right disk page
            //into the memory which page managed.
            swap_in(mm,addr,&page);//将该页面从磁盘加载到内存
ffffffffc0203ddc:	0030                	addi	a2,sp,8
ffffffffc0203dde:	85a2                	mv	a1,s0
ffffffffc0203de0:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc0203de2:	e402                	sd	zero,8(sp)
            swap_in(mm,addr,&page);//将该页面从磁盘加载到内存
ffffffffc0203de4:	b98ff0ef          	jal	ffffffffc020317c <swap_in>
                
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            page_insert(mm->pgdir,page,addr,perm);//建立页面的物理地址和虚拟地址的映射关系
ffffffffc0203de8:	65a2                	ld	a1,8(sp)
ffffffffc0203dea:	6c88                	ld	a0,24(s1)
ffffffffc0203dec:	86ca                	mv	a3,s2
ffffffffc0203dee:	8622                	mv	a2,s0
ffffffffc0203df0:	c1ffd0ef          	jal	ffffffffc0201a0e <page_insert>
                
            //(3) make the page swappable.
            swap_map_swappable(mm,addr,page,1);//将页面标记为可交换，使得页面管理系统可以将其再次换出到磁盘
ffffffffc0203df4:	6622                	ld	a2,8(sp)
ffffffffc0203df6:	4685                	li	a3,1
ffffffffc0203df8:	85a2                	mv	a1,s0
ffffffffc0203dfa:	8526                	mv	a0,s1
ffffffffc0203dfc:	a5eff0ef          	jal	ffffffffc020305a <swap_map_swappable>
            page->pra_vaddr = addr;// 更新页面的 pra_vaddr 为当前的 addr 地址，记录该页面被访问的线性地址
ffffffffc0203e00:	67a2                	ld	a5,8(sp)
ffffffffc0203e02:	e3a0                	sd	s0,64(a5)
ffffffffc0203e04:	6942                	ld	s2,16(sp)
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }

   ret = 0;
ffffffffc0203e06:	4501                	li	a0,0
failed:
    return ret;
}
ffffffffc0203e08:	70a2                	ld	ra,40(sp)
ffffffffc0203e0a:	7402                	ld	s0,32(sp)
ffffffffc0203e0c:	64e2                	ld	s1,24(sp)
ffffffffc0203e0e:	6145                	addi	sp,sp,48
ffffffffc0203e10:	8082                	ret
    uint32_t perm = PTE_U;
ffffffffc0203e12:	4941                	li	s2,16
ffffffffc0203e14:	b775                	j	ffffffffc0203dc0 <do_pgfault+0x36>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0203e16:	6c88                	ld	a0,24(s1)
ffffffffc0203e18:	864a                	mv	a2,s2
ffffffffc0203e1a:	85a2                	mv	a1,s0
ffffffffc0203e1c:	935fe0ef          	jal	ffffffffc0202750 <pgdir_alloc_page>
ffffffffc0203e20:	f175                	bnez	a0,ffffffffc0203e04 <do_pgfault+0x7a>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0203e22:	00002517          	auipc	a0,0x2
ffffffffc0203e26:	16650513          	addi	a0,a0,358 # ffffffffc0205f88 <etext+0x1a46>
ffffffffc0203e2a:	a90fc0ef          	jal	ffffffffc02000ba <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203e2e:	6942                	ld	s2,16(sp)
ffffffffc0203e30:	5571                	li	a0,-4
ffffffffc0203e32:	bfd9                	j	ffffffffc0203e08 <do_pgfault+0x7e>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0203e34:	85a2                	mv	a1,s0
ffffffffc0203e36:	00002517          	auipc	a0,0x2
ffffffffc0203e3a:	12250513          	addi	a0,a0,290 # ffffffffc0205f58 <etext+0x1a16>
ffffffffc0203e3e:	a7cfc0ef          	jal	ffffffffc02000ba <cprintf>
    int ret = -E_INVAL;
ffffffffc0203e42:	5575                	li	a0,-3
        goto failed;
ffffffffc0203e44:	b7d1                	j	ffffffffc0203e08 <do_pgfault+0x7e>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0203e46:	00002517          	auipc	a0,0x2
ffffffffc0203e4a:	16a50513          	addi	a0,a0,362 # ffffffffc0205fb0 <etext+0x1a6e>
ffffffffc0203e4e:	a6cfc0ef          	jal	ffffffffc02000ba <cprintf>
            goto failed;
ffffffffc0203e52:	bff1                	j	ffffffffc0203e2e <do_pgfault+0xa4>

ffffffffc0203e54 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {// 初始化 swap 文件系统
ffffffffc0203e54:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);// 确保页面大小 PGSIZE 是扇区大小 SECTSIZE 的整数倍
    if (!ide_device_valid(SWAP_DEV_NO)) {// 检查交换设备是否可用
ffffffffc0203e56:	4505                	li	a0,1
swapfs_init(void) {// 初始化 swap 文件系统
ffffffffc0203e58:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {// 检查交换设备是否可用
ffffffffc0203e5a:	e28fc0ef          	jal	ffffffffc0200482 <ide_device_valid>
ffffffffc0203e5e:	cd01                	beqz	a0,ffffffffc0203e76 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    // 计算最大交换区偏移量，表示交换区支持的页面数量
    // ide_device_size(SWAP_DEV_NO) 获取交换设备的总扇区数
    // 每页占用 PGSIZE / SECTSIZE 扇区，因此总页面数为总扇区数除以每页所需扇区数
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203e60:	4505                	li	a0,1
ffffffffc0203e62:	e26fc0ef          	jal	ffffffffc0200488 <ide_device_size>
}
ffffffffc0203e66:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203e68:	810d                	srli	a0,a0,0x3
ffffffffc0203e6a:	0000d797          	auipc	a5,0xd
ffffffffc0203e6e:	6ea7b323          	sd	a0,1766(a5) # ffffffffc0211550 <max_swap_offset>
}
ffffffffc0203e72:	0141                	addi	sp,sp,16
ffffffffc0203e74:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0203e76:	00002617          	auipc	a2,0x2
ffffffffc0203e7a:	16260613          	addi	a2,a2,354 # ffffffffc0205fd8 <etext+0x1a96>
ffffffffc0203e7e:	45b5                	li	a1,13
ffffffffc0203e80:	00002517          	auipc	a0,0x2
ffffffffc0203e84:	17850513          	addi	a0,a0,376 # ffffffffc0205ff8 <etext+0x1ab6>
ffffffffc0203e88:	cd8fc0ef          	jal	ffffffffc0200360 <__panic>

ffffffffc0203e8c <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0203e8c:	1141                	addi	sp,sp,-16
ffffffffc0203e8e:	e406                	sd	ra,8(sp)
    // 调用 ide_read_secs 从 swap 设备 (SWAP_DEV_NO) 的指定扇区读取页面数据
    // swap_offset(entry) * PAGE_NSECT 计算页面的起始扇区
    // page2kva(page) 将 page 转换为内核虚拟地址，以便读取数据至该地址
    // PAGE_NSECT 表示读取的扇区数量
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203e90:	00855713          	srli	a4,a0,0x8
ffffffffc0203e94:	cb2d                	beqz	a4,ffffffffc0203f06 <swapfs_read+0x7a>
ffffffffc0203e96:	0000d797          	auipc	a5,0xd
ffffffffc0203e9a:	6ba7b783          	ld	a5,1722(a5) # ffffffffc0211550 <max_swap_offset>
ffffffffc0203e9e:	06f77463          	bgeu	a4,a5,ffffffffc0203f06 <swapfs_read+0x7a>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203ea2:	f8e397b7          	lui	a5,0xf8e39
ffffffffc0203ea6:	e3978793          	addi	a5,a5,-455 # fffffffff8e38e39 <end+0x38c278c1>
ffffffffc0203eaa:	07b2                	slli	a5,a5,0xc
ffffffffc0203eac:	e3978793          	addi	a5,a5,-455
ffffffffc0203eb0:	07b2                	slli	a5,a5,0xc
ffffffffc0203eb2:	0000d697          	auipc	a3,0xd
ffffffffc0203eb6:	68e6b683          	ld	a3,1678(a3) # ffffffffc0211540 <pages>
ffffffffc0203eba:	e3978793          	addi	a5,a5,-455
ffffffffc0203ebe:	8d95                	sub	a1,a1,a3
ffffffffc0203ec0:	07b2                	slli	a5,a5,0xc
ffffffffc0203ec2:	4035d613          	srai	a2,a1,0x3
ffffffffc0203ec6:	e3978793          	addi	a5,a5,-455
ffffffffc0203eca:	02f60633          	mul	a2,a2,a5
ffffffffc0203ece:	00002797          	auipc	a5,0x2
ffffffffc0203ed2:	49a7b783          	ld	a5,1178(a5) # ffffffffc0206368 <nbase>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203ed6:	0000d697          	auipc	a3,0xd
ffffffffc0203eda:	6626b683          	ld	a3,1634(a3) # ffffffffc0211538 <npage>
ffffffffc0203ede:	0037159b          	slliw	a1,a4,0x3
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203ee2:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203ee4:	00c61793          	slli	a5,a2,0xc
ffffffffc0203ee8:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203eea:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203eec:	02d7f963          	bgeu	a5,a3,ffffffffc0203f1e <swapfs_read+0x92>
}
ffffffffc0203ef0:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203ef2:	0000d797          	auipc	a5,0xd
ffffffffc0203ef6:	63e7b783          	ld	a5,1598(a5) # ffffffffc0211530 <va_pa_offset>
ffffffffc0203efa:	46a1                	li	a3,8
ffffffffc0203efc:	963e                	add	a2,a2,a5
ffffffffc0203efe:	4505                	li	a0,1
}
ffffffffc0203f00:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203f02:	d8cfc06f          	j	ffffffffc020048e <ide_read_secs>
ffffffffc0203f06:	86aa                	mv	a3,a0
ffffffffc0203f08:	00002617          	auipc	a2,0x2
ffffffffc0203f0c:	10860613          	addi	a2,a2,264 # ffffffffc0206010 <etext+0x1ace>
ffffffffc0203f10:	45ed                	li	a1,27
ffffffffc0203f12:	00002517          	auipc	a0,0x2
ffffffffc0203f16:	0e650513          	addi	a0,a0,230 # ffffffffc0205ff8 <etext+0x1ab6>
ffffffffc0203f1a:	c46fc0ef          	jal	ffffffffc0200360 <__panic>
ffffffffc0203f1e:	86b2                	mv	a3,a2
ffffffffc0203f20:	06a00593          	li	a1,106
ffffffffc0203f24:	00001617          	auipc	a2,0x1
ffffffffc0203f28:	30460613          	addi	a2,a2,772 # ffffffffc0205228 <etext+0xce6>
ffffffffc0203f2c:	00001517          	auipc	a0,0x1
ffffffffc0203f30:	2c450513          	addi	a0,a0,708 # ffffffffc02051f0 <etext+0xcae>
ffffffffc0203f34:	c2cfc0ef          	jal	ffffffffc0200360 <__panic>

ffffffffc0203f38 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0203f38:	1141                	addi	sp,sp,-16
ffffffffc0203f3a:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203f3c:	00855713          	srli	a4,a0,0x8
ffffffffc0203f40:	cb2d                	beqz	a4,ffffffffc0203fb2 <swapfs_write+0x7a>
ffffffffc0203f42:	0000d797          	auipc	a5,0xd
ffffffffc0203f46:	60e7b783          	ld	a5,1550(a5) # ffffffffc0211550 <max_swap_offset>
ffffffffc0203f4a:	06f77463          	bgeu	a4,a5,ffffffffc0203fb2 <swapfs_write+0x7a>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203f4e:	f8e397b7          	lui	a5,0xf8e39
ffffffffc0203f52:	e3978793          	addi	a5,a5,-455 # fffffffff8e38e39 <end+0x38c278c1>
ffffffffc0203f56:	07b2                	slli	a5,a5,0xc
ffffffffc0203f58:	e3978793          	addi	a5,a5,-455
ffffffffc0203f5c:	07b2                	slli	a5,a5,0xc
ffffffffc0203f5e:	0000d697          	auipc	a3,0xd
ffffffffc0203f62:	5e26b683          	ld	a3,1506(a3) # ffffffffc0211540 <pages>
ffffffffc0203f66:	e3978793          	addi	a5,a5,-455
ffffffffc0203f6a:	8d95                	sub	a1,a1,a3
ffffffffc0203f6c:	07b2                	slli	a5,a5,0xc
ffffffffc0203f6e:	4035d613          	srai	a2,a1,0x3
ffffffffc0203f72:	e3978793          	addi	a5,a5,-455
ffffffffc0203f76:	02f60633          	mul	a2,a2,a5
ffffffffc0203f7a:	00002797          	auipc	a5,0x2
ffffffffc0203f7e:	3ee7b783          	ld	a5,1006(a5) # ffffffffc0206368 <nbase>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203f82:	0000d697          	auipc	a3,0xd
ffffffffc0203f86:	5b66b683          	ld	a3,1462(a3) # ffffffffc0211538 <npage>
ffffffffc0203f8a:	0037159b          	slliw	a1,a4,0x3
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203f8e:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203f90:	00c61793          	slli	a5,a2,0xc
ffffffffc0203f94:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203f96:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203f98:	02d7fa63          	bgeu	a5,a3,ffffffffc0203fcc <swapfs_write+0x94>
}
ffffffffc0203f9c:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203f9e:	0000d797          	auipc	a5,0xd
ffffffffc0203fa2:	5927b783          	ld	a5,1426(a5) # ffffffffc0211530 <va_pa_offset>
ffffffffc0203fa6:	46a1                	li	a3,8
ffffffffc0203fa8:	963e                	add	a2,a2,a5
ffffffffc0203faa:	4505                	li	a0,1
}
ffffffffc0203fac:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203fae:	d04fc06f          	j	ffffffffc02004b2 <ide_write_secs>
ffffffffc0203fb2:	86aa                	mv	a3,a0
ffffffffc0203fb4:	00002617          	auipc	a2,0x2
ffffffffc0203fb8:	05c60613          	addi	a2,a2,92 # ffffffffc0206010 <etext+0x1ace>
ffffffffc0203fbc:	02000593          	li	a1,32
ffffffffc0203fc0:	00002517          	auipc	a0,0x2
ffffffffc0203fc4:	03850513          	addi	a0,a0,56 # ffffffffc0205ff8 <etext+0x1ab6>
ffffffffc0203fc8:	b98fc0ef          	jal	ffffffffc0200360 <__panic>
ffffffffc0203fcc:	86b2                	mv	a3,a2
ffffffffc0203fce:	06a00593          	li	a1,106
ffffffffc0203fd2:	00001617          	auipc	a2,0x1
ffffffffc0203fd6:	25660613          	addi	a2,a2,598 # ffffffffc0205228 <etext+0xce6>
ffffffffc0203fda:	00001517          	auipc	a0,0x1
ffffffffc0203fde:	21650513          	addi	a0,a0,534 # ffffffffc02051f0 <etext+0xcae>
ffffffffc0203fe2:	b7efc0ef          	jal	ffffffffc0200360 <__panic>

ffffffffc0203fe6 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0203fe6:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203fea:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0203fec:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203ff0:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0203ff2:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203ff6:	f022                	sd	s0,32(sp)
ffffffffc0203ff8:	ec26                	sd	s1,24(sp)
ffffffffc0203ffa:	e84a                	sd	s2,16(sp)
ffffffffc0203ffc:	f406                	sd	ra,40(sp)
ffffffffc0203ffe:	84aa                	mv	s1,a0
ffffffffc0204000:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0204002:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0204006:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0204008:	05067063          	bgeu	a2,a6,ffffffffc0204048 <printnum+0x62>
ffffffffc020400c:	e44e                	sd	s3,8(sp)
ffffffffc020400e:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0204010:	4785                	li	a5,1
ffffffffc0204012:	00e7d763          	bge	a5,a4,ffffffffc0204020 <printnum+0x3a>
            putch(padc, putdat);
ffffffffc0204016:	85ca                	mv	a1,s2
ffffffffc0204018:	854e                	mv	a0,s3
        while (-- width > 0)
ffffffffc020401a:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc020401c:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc020401e:	fc65                	bnez	s0,ffffffffc0204016 <printnum+0x30>
ffffffffc0204020:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204022:	1a02                	slli	s4,s4,0x20
ffffffffc0204024:	020a5a13          	srli	s4,s4,0x20
ffffffffc0204028:	00002797          	auipc	a5,0x2
ffffffffc020402c:	00878793          	addi	a5,a5,8 # ffffffffc0206030 <etext+0x1aee>
ffffffffc0204030:	97d2                	add	a5,a5,s4
}
ffffffffc0204032:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204034:	0007c503          	lbu	a0,0(a5)
}
ffffffffc0204038:	70a2                	ld	ra,40(sp)
ffffffffc020403a:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020403c:	85ca                	mv	a1,s2
ffffffffc020403e:	87a6                	mv	a5,s1
}
ffffffffc0204040:	6942                	ld	s2,16(sp)
ffffffffc0204042:	64e2                	ld	s1,24(sp)
ffffffffc0204044:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204046:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0204048:	03065633          	divu	a2,a2,a6
ffffffffc020404c:	8722                	mv	a4,s0
ffffffffc020404e:	f99ff0ef          	jal	ffffffffc0203fe6 <printnum>
ffffffffc0204052:	bfc1                	j	ffffffffc0204022 <printnum+0x3c>

ffffffffc0204054 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0204054:	7119                	addi	sp,sp,-128
ffffffffc0204056:	f4a6                	sd	s1,104(sp)
ffffffffc0204058:	f0ca                	sd	s2,96(sp)
ffffffffc020405a:	ecce                	sd	s3,88(sp)
ffffffffc020405c:	e8d2                	sd	s4,80(sp)
ffffffffc020405e:	e4d6                	sd	s5,72(sp)
ffffffffc0204060:	e0da                	sd	s6,64(sp)
ffffffffc0204062:	f862                	sd	s8,48(sp)
ffffffffc0204064:	fc86                	sd	ra,120(sp)
ffffffffc0204066:	f8a2                	sd	s0,112(sp)
ffffffffc0204068:	fc5e                	sd	s7,56(sp)
ffffffffc020406a:	f466                	sd	s9,40(sp)
ffffffffc020406c:	f06a                	sd	s10,32(sp)
ffffffffc020406e:	ec6e                	sd	s11,24(sp)
ffffffffc0204070:	892a                	mv	s2,a0
ffffffffc0204072:	84ae                	mv	s1,a1
ffffffffc0204074:	8c32                	mv	s8,a2
ffffffffc0204076:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204078:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020407c:	05500b13          	li	s6,85
ffffffffc0204080:	00002a97          	auipc	s5,0x2
ffffffffc0204084:	158a8a93          	addi	s5,s5,344 # ffffffffc02061d8 <default_pmm_manager+0x38>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204088:	000c4503          	lbu	a0,0(s8)
ffffffffc020408c:	001c0413          	addi	s0,s8,1
ffffffffc0204090:	01350a63          	beq	a0,s3,ffffffffc02040a4 <vprintfmt+0x50>
            if (ch == '\0') {
ffffffffc0204094:	cd0d                	beqz	a0,ffffffffc02040ce <vprintfmt+0x7a>
            putch(ch, putdat);
ffffffffc0204096:	85a6                	mv	a1,s1
ffffffffc0204098:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020409a:	00044503          	lbu	a0,0(s0)
ffffffffc020409e:	0405                	addi	s0,s0,1
ffffffffc02040a0:	ff351ae3          	bne	a0,s3,ffffffffc0204094 <vprintfmt+0x40>
        char padc = ' ';
ffffffffc02040a4:	02000d93          	li	s11,32
        lflag = altflag = 0;
ffffffffc02040a8:	4b81                	li	s7,0
ffffffffc02040aa:	4601                	li	a2,0
        width = precision = -1;
ffffffffc02040ac:	5d7d                	li	s10,-1
ffffffffc02040ae:	5cfd                	li	s9,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02040b0:	00044683          	lbu	a3,0(s0)
ffffffffc02040b4:	00140c13          	addi	s8,s0,1
ffffffffc02040b8:	fdd6859b          	addiw	a1,a3,-35
ffffffffc02040bc:	0ff5f593          	zext.b	a1,a1
ffffffffc02040c0:	02bb6663          	bltu	s6,a1,ffffffffc02040ec <vprintfmt+0x98>
ffffffffc02040c4:	058a                	slli	a1,a1,0x2
ffffffffc02040c6:	95d6                	add	a1,a1,s5
ffffffffc02040c8:	4198                	lw	a4,0(a1)
ffffffffc02040ca:	9756                	add	a4,a4,s5
ffffffffc02040cc:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02040ce:	70e6                	ld	ra,120(sp)
ffffffffc02040d0:	7446                	ld	s0,112(sp)
ffffffffc02040d2:	74a6                	ld	s1,104(sp)
ffffffffc02040d4:	7906                	ld	s2,96(sp)
ffffffffc02040d6:	69e6                	ld	s3,88(sp)
ffffffffc02040d8:	6a46                	ld	s4,80(sp)
ffffffffc02040da:	6aa6                	ld	s5,72(sp)
ffffffffc02040dc:	6b06                	ld	s6,64(sp)
ffffffffc02040de:	7be2                	ld	s7,56(sp)
ffffffffc02040e0:	7c42                	ld	s8,48(sp)
ffffffffc02040e2:	7ca2                	ld	s9,40(sp)
ffffffffc02040e4:	7d02                	ld	s10,32(sp)
ffffffffc02040e6:	6de2                	ld	s11,24(sp)
ffffffffc02040e8:	6109                	addi	sp,sp,128
ffffffffc02040ea:	8082                	ret
            putch('%', putdat);
ffffffffc02040ec:	85a6                	mv	a1,s1
ffffffffc02040ee:	02500513          	li	a0,37
ffffffffc02040f2:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02040f4:	fff44703          	lbu	a4,-1(s0)
ffffffffc02040f8:	02500793          	li	a5,37
ffffffffc02040fc:	8c22                	mv	s8,s0
ffffffffc02040fe:	f8f705e3          	beq	a4,a5,ffffffffc0204088 <vprintfmt+0x34>
ffffffffc0204102:	02500713          	li	a4,37
ffffffffc0204106:	ffec4783          	lbu	a5,-2(s8)
ffffffffc020410a:	1c7d                	addi	s8,s8,-1
ffffffffc020410c:	fee79de3          	bne	a5,a4,ffffffffc0204106 <vprintfmt+0xb2>
ffffffffc0204110:	bfa5                	j	ffffffffc0204088 <vprintfmt+0x34>
                ch = *fmt;
ffffffffc0204112:	00144783          	lbu	a5,1(s0)
                if (ch < '0' || ch > '9') {
ffffffffc0204116:	4725                	li	a4,9
                precision = precision * 10 + ch - '0';
ffffffffc0204118:	fd068d1b          	addiw	s10,a3,-48
                if (ch < '0' || ch > '9') {
ffffffffc020411c:	fd07859b          	addiw	a1,a5,-48
                ch = *fmt;
ffffffffc0204120:	0007869b          	sext.w	a3,a5
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204124:	8462                	mv	s0,s8
                if (ch < '0' || ch > '9') {
ffffffffc0204126:	02b76563          	bltu	a4,a1,ffffffffc0204150 <vprintfmt+0xfc>
ffffffffc020412a:	4525                	li	a0,9
                ch = *fmt;
ffffffffc020412c:	00144783          	lbu	a5,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0204130:	002d171b          	slliw	a4,s10,0x2
ffffffffc0204134:	01a7073b          	addw	a4,a4,s10
ffffffffc0204138:	0017171b          	slliw	a4,a4,0x1
ffffffffc020413c:	9f35                	addw	a4,a4,a3
                if (ch < '0' || ch > '9') {
ffffffffc020413e:	fd07859b          	addiw	a1,a5,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0204142:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0204144:	fd070d1b          	addiw	s10,a4,-48
                ch = *fmt;
ffffffffc0204148:	0007869b          	sext.w	a3,a5
                if (ch < '0' || ch > '9') {
ffffffffc020414c:	feb570e3          	bgeu	a0,a1,ffffffffc020412c <vprintfmt+0xd8>
            if (width < 0)
ffffffffc0204150:	f60cd0e3          	bgez	s9,ffffffffc02040b0 <vprintfmt+0x5c>
                width = precision, precision = -1;
ffffffffc0204154:	8cea                	mv	s9,s10
ffffffffc0204156:	5d7d                	li	s10,-1
ffffffffc0204158:	bfa1                	j	ffffffffc02040b0 <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020415a:	8db6                	mv	s11,a3
ffffffffc020415c:	8462                	mv	s0,s8
ffffffffc020415e:	bf89                	j	ffffffffc02040b0 <vprintfmt+0x5c>
ffffffffc0204160:	8462                	mv	s0,s8
            altflag = 1;
ffffffffc0204162:	4b85                	li	s7,1
            goto reswitch;
ffffffffc0204164:	b7b1                	j	ffffffffc02040b0 <vprintfmt+0x5c>
    if (lflag >= 2) {
ffffffffc0204166:	4785                	li	a5,1
            precision = va_arg(ap, int);
ffffffffc0204168:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
ffffffffc020416c:	00c7c463          	blt	a5,a2,ffffffffc0204174 <vprintfmt+0x120>
    else if (lflag) {
ffffffffc0204170:	1a060163          	beqz	a2,ffffffffc0204312 <vprintfmt+0x2be>
        return va_arg(*ap, unsigned long);
ffffffffc0204174:	000a3603          	ld	a2,0(s4)
ffffffffc0204178:	46c1                	li	a3,16
ffffffffc020417a:	8a3a                	mv	s4,a4
            printnum(putch, putdat, num, base, width, padc);
ffffffffc020417c:	000d879b          	sext.w	a5,s11
ffffffffc0204180:	8766                	mv	a4,s9
ffffffffc0204182:	85a6                	mv	a1,s1
ffffffffc0204184:	854a                	mv	a0,s2
ffffffffc0204186:	e61ff0ef          	jal	ffffffffc0203fe6 <printnum>
            break;
ffffffffc020418a:	bdfd                	j	ffffffffc0204088 <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
ffffffffc020418c:	000a2503          	lw	a0,0(s4)
ffffffffc0204190:	85a6                	mv	a1,s1
ffffffffc0204192:	0a21                	addi	s4,s4,8
ffffffffc0204194:	9902                	jalr	s2
            break;
ffffffffc0204196:	bdcd                	j	ffffffffc0204088 <vprintfmt+0x34>
    if (lflag >= 2) {
ffffffffc0204198:	4785                	li	a5,1
            precision = va_arg(ap, int);
ffffffffc020419a:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
ffffffffc020419e:	00c7c463          	blt	a5,a2,ffffffffc02041a6 <vprintfmt+0x152>
    else if (lflag) {
ffffffffc02041a2:	16060363          	beqz	a2,ffffffffc0204308 <vprintfmt+0x2b4>
        return va_arg(*ap, unsigned long);
ffffffffc02041a6:	000a3603          	ld	a2,0(s4)
ffffffffc02041aa:	46a9                	li	a3,10
ffffffffc02041ac:	8a3a                	mv	s4,a4
ffffffffc02041ae:	b7f9                	j	ffffffffc020417c <vprintfmt+0x128>
            putch('0', putdat);
ffffffffc02041b0:	85a6                	mv	a1,s1
ffffffffc02041b2:	03000513          	li	a0,48
ffffffffc02041b6:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02041b8:	85a6                	mv	a1,s1
ffffffffc02041ba:	07800513          	li	a0,120
ffffffffc02041be:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02041c0:	000a3603          	ld	a2,0(s4)
            goto number;
ffffffffc02041c4:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02041c6:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc02041c8:	bf55                	j	ffffffffc020417c <vprintfmt+0x128>
            putch(ch, putdat);
ffffffffc02041ca:	85a6                	mv	a1,s1
ffffffffc02041cc:	02500513          	li	a0,37
ffffffffc02041d0:	9902                	jalr	s2
            break;
ffffffffc02041d2:	bd5d                	j	ffffffffc0204088 <vprintfmt+0x34>
            precision = va_arg(ap, int);
ffffffffc02041d4:	000a2d03          	lw	s10,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02041d8:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
ffffffffc02041da:	0a21                	addi	s4,s4,8
            goto process_precision;
ffffffffc02041dc:	bf95                	j	ffffffffc0204150 <vprintfmt+0xfc>
    if (lflag >= 2) {
ffffffffc02041de:	4785                	li	a5,1
            precision = va_arg(ap, int);
ffffffffc02041e0:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
ffffffffc02041e4:	00c7c463          	blt	a5,a2,ffffffffc02041ec <vprintfmt+0x198>
    else if (lflag) {
ffffffffc02041e8:	10060b63          	beqz	a2,ffffffffc02042fe <vprintfmt+0x2aa>
        return va_arg(*ap, unsigned long);
ffffffffc02041ec:	000a3603          	ld	a2,0(s4)
ffffffffc02041f0:	46a1                	li	a3,8
ffffffffc02041f2:	8a3a                	mv	s4,a4
ffffffffc02041f4:	b761                	j	ffffffffc020417c <vprintfmt+0x128>
            if (width < 0)
ffffffffc02041f6:	fffcc793          	not	a5,s9
ffffffffc02041fa:	97fd                	srai	a5,a5,0x3f
ffffffffc02041fc:	00fcf7b3          	and	a5,s9,a5
ffffffffc0204200:	00078c9b          	sext.w	s9,a5
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204204:	8462                	mv	s0,s8
            goto reswitch;
ffffffffc0204206:	b56d                	j	ffffffffc02040b0 <vprintfmt+0x5c>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204208:	000a3403          	ld	s0,0(s4)
ffffffffc020420c:	008a0793          	addi	a5,s4,8
ffffffffc0204210:	e43e                	sd	a5,8(sp)
ffffffffc0204212:	12040063          	beqz	s0,ffffffffc0204332 <vprintfmt+0x2de>
            if (width > 0 && padc != '-') {
ffffffffc0204216:	0d905963          	blez	s9,ffffffffc02042e8 <vprintfmt+0x294>
ffffffffc020421a:	02d00793          	li	a5,45
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020421e:	00140a13          	addi	s4,s0,1
            if (width > 0 && padc != '-') {
ffffffffc0204222:	12fd9763          	bne	s11,a5,ffffffffc0204350 <vprintfmt+0x2fc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204226:	00044783          	lbu	a5,0(s0)
ffffffffc020422a:	0007851b          	sext.w	a0,a5
ffffffffc020422e:	cb9d                	beqz	a5,ffffffffc0204264 <vprintfmt+0x210>
ffffffffc0204230:	547d                	li	s0,-1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204232:	05e00d93          	li	s11,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204236:	000d4563          	bltz	s10,ffffffffc0204240 <vprintfmt+0x1ec>
ffffffffc020423a:	3d7d                	addiw	s10,s10,-1
ffffffffc020423c:	028d0263          	beq	s10,s0,ffffffffc0204260 <vprintfmt+0x20c>
                    putch('?', putdat);
ffffffffc0204240:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204242:	0c0b8d63          	beqz	s7,ffffffffc020431c <vprintfmt+0x2c8>
ffffffffc0204246:	3781                	addiw	a5,a5,-32
ffffffffc0204248:	0cfdfa63          	bgeu	s11,a5,ffffffffc020431c <vprintfmt+0x2c8>
                    putch('?', putdat);
ffffffffc020424c:	03f00513          	li	a0,63
ffffffffc0204250:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204252:	000a4783          	lbu	a5,0(s4)
ffffffffc0204256:	3cfd                	addiw	s9,s9,-1
ffffffffc0204258:	0a05                	addi	s4,s4,1
ffffffffc020425a:	0007851b          	sext.w	a0,a5
ffffffffc020425e:	ffe1                	bnez	a5,ffffffffc0204236 <vprintfmt+0x1e2>
            for (; width > 0; width --) {
ffffffffc0204260:	01905963          	blez	s9,ffffffffc0204272 <vprintfmt+0x21e>
                putch(' ', putdat);
ffffffffc0204264:	85a6                	mv	a1,s1
ffffffffc0204266:	02000513          	li	a0,32
            for (; width > 0; width --) {
ffffffffc020426a:	3cfd                	addiw	s9,s9,-1
                putch(' ', putdat);
ffffffffc020426c:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020426e:	fe0c9be3          	bnez	s9,ffffffffc0204264 <vprintfmt+0x210>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204272:	6a22                	ld	s4,8(sp)
ffffffffc0204274:	bd11                	j	ffffffffc0204088 <vprintfmt+0x34>
    if (lflag >= 2) {
ffffffffc0204276:	4785                	li	a5,1
            precision = va_arg(ap, int);
ffffffffc0204278:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
ffffffffc020427c:	00c7c363          	blt	a5,a2,ffffffffc0204282 <vprintfmt+0x22e>
    else if (lflag) {
ffffffffc0204280:	ce25                	beqz	a2,ffffffffc02042f8 <vprintfmt+0x2a4>
        return va_arg(*ap, long);
ffffffffc0204282:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0204286:	08044d63          	bltz	s0,ffffffffc0204320 <vprintfmt+0x2cc>
            num = getint(&ap, lflag);
ffffffffc020428a:	8622                	mv	a2,s0
ffffffffc020428c:	8a5e                	mv	s4,s7
ffffffffc020428e:	46a9                	li	a3,10
ffffffffc0204290:	b5f5                	j	ffffffffc020417c <vprintfmt+0x128>
            if (err < 0) {
ffffffffc0204292:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204296:	4619                	li	a2,6
            if (err < 0) {
ffffffffc0204298:	41f7d71b          	sraiw	a4,a5,0x1f
ffffffffc020429c:	8fb9                	xor	a5,a5,a4
ffffffffc020429e:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02042a2:	02d64663          	blt	a2,a3,ffffffffc02042ce <vprintfmt+0x27a>
ffffffffc02042a6:	00369713          	slli	a4,a3,0x3
ffffffffc02042aa:	00002797          	auipc	a5,0x2
ffffffffc02042ae:	08678793          	addi	a5,a5,134 # ffffffffc0206330 <error_string>
ffffffffc02042b2:	97ba                	add	a5,a5,a4
ffffffffc02042b4:	639c                	ld	a5,0(a5)
ffffffffc02042b6:	cf81                	beqz	a5,ffffffffc02042ce <vprintfmt+0x27a>
                printfmt(putch, putdat, "%s", p);
ffffffffc02042b8:	86be                	mv	a3,a5
ffffffffc02042ba:	00002617          	auipc	a2,0x2
ffffffffc02042be:	da660613          	addi	a2,a2,-602 # ffffffffc0206060 <etext+0x1b1e>
ffffffffc02042c2:	85a6                	mv	a1,s1
ffffffffc02042c4:	854a                	mv	a0,s2
ffffffffc02042c6:	0e8000ef          	jal	ffffffffc02043ae <printfmt>
            err = va_arg(ap, int);
ffffffffc02042ca:	0a21                	addi	s4,s4,8
ffffffffc02042cc:	bb75                	j	ffffffffc0204088 <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02042ce:	00002617          	auipc	a2,0x2
ffffffffc02042d2:	d8260613          	addi	a2,a2,-638 # ffffffffc0206050 <etext+0x1b0e>
ffffffffc02042d6:	85a6                	mv	a1,s1
ffffffffc02042d8:	854a                	mv	a0,s2
ffffffffc02042da:	0d4000ef          	jal	ffffffffc02043ae <printfmt>
            err = va_arg(ap, int);
ffffffffc02042de:	0a21                	addi	s4,s4,8
ffffffffc02042e0:	b365                	j	ffffffffc0204088 <vprintfmt+0x34>
            lflag ++;
ffffffffc02042e2:	2605                	addiw	a2,a2,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02042e4:	8462                	mv	s0,s8
            goto reswitch;
ffffffffc02042e6:	b3e9                	j	ffffffffc02040b0 <vprintfmt+0x5c>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02042e8:	00044783          	lbu	a5,0(s0)
ffffffffc02042ec:	0007851b          	sext.w	a0,a5
ffffffffc02042f0:	d3c9                	beqz	a5,ffffffffc0204272 <vprintfmt+0x21e>
ffffffffc02042f2:	00140a13          	addi	s4,s0,1
ffffffffc02042f6:	bf2d                	j	ffffffffc0204230 <vprintfmt+0x1dc>
        return va_arg(*ap, int);
ffffffffc02042f8:	000a2403          	lw	s0,0(s4)
ffffffffc02042fc:	b769                	j	ffffffffc0204286 <vprintfmt+0x232>
        return va_arg(*ap, unsigned int);
ffffffffc02042fe:	000a6603          	lwu	a2,0(s4)
ffffffffc0204302:	46a1                	li	a3,8
ffffffffc0204304:	8a3a                	mv	s4,a4
ffffffffc0204306:	bd9d                	j	ffffffffc020417c <vprintfmt+0x128>
ffffffffc0204308:	000a6603          	lwu	a2,0(s4)
ffffffffc020430c:	46a9                	li	a3,10
ffffffffc020430e:	8a3a                	mv	s4,a4
ffffffffc0204310:	b5b5                	j	ffffffffc020417c <vprintfmt+0x128>
ffffffffc0204312:	000a6603          	lwu	a2,0(s4)
ffffffffc0204316:	46c1                	li	a3,16
ffffffffc0204318:	8a3a                	mv	s4,a4
ffffffffc020431a:	b58d                	j	ffffffffc020417c <vprintfmt+0x128>
                    putch(ch, putdat);
ffffffffc020431c:	9902                	jalr	s2
ffffffffc020431e:	bf15                	j	ffffffffc0204252 <vprintfmt+0x1fe>
                putch('-', putdat);
ffffffffc0204320:	85a6                	mv	a1,s1
ffffffffc0204322:	02d00513          	li	a0,45
ffffffffc0204326:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0204328:	40800633          	neg	a2,s0
ffffffffc020432c:	8a5e                	mv	s4,s7
ffffffffc020432e:	46a9                	li	a3,10
ffffffffc0204330:	b5b1                	j	ffffffffc020417c <vprintfmt+0x128>
            if (width > 0 && padc != '-') {
ffffffffc0204332:	01905663          	blez	s9,ffffffffc020433e <vprintfmt+0x2ea>
ffffffffc0204336:	02d00793          	li	a5,45
ffffffffc020433a:	04fd9263          	bne	s11,a5,ffffffffc020437e <vprintfmt+0x32a>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020433e:	02800793          	li	a5,40
ffffffffc0204342:	00002a17          	auipc	s4,0x2
ffffffffc0204346:	d07a0a13          	addi	s4,s4,-761 # ffffffffc0206049 <etext+0x1b07>
ffffffffc020434a:	02800513          	li	a0,40
ffffffffc020434e:	b5cd                	j	ffffffffc0204230 <vprintfmt+0x1dc>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204350:	85ea                	mv	a1,s10
ffffffffc0204352:	8522                	mv	a0,s0
ffffffffc0204354:	148000ef          	jal	ffffffffc020449c <strnlen>
ffffffffc0204358:	40ac8cbb          	subw	s9,s9,a0
ffffffffc020435c:	01905963          	blez	s9,ffffffffc020436e <vprintfmt+0x31a>
                    putch(padc, putdat);
ffffffffc0204360:	2d81                	sext.w	s11,s11
ffffffffc0204362:	85a6                	mv	a1,s1
ffffffffc0204364:	856e                	mv	a0,s11
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204366:	3cfd                	addiw	s9,s9,-1
                    putch(padc, putdat);
ffffffffc0204368:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020436a:	fe0c9ce3          	bnez	s9,ffffffffc0204362 <vprintfmt+0x30e>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020436e:	00044783          	lbu	a5,0(s0)
ffffffffc0204372:	0007851b          	sext.w	a0,a5
ffffffffc0204376:	ea079de3          	bnez	a5,ffffffffc0204230 <vprintfmt+0x1dc>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020437a:	6a22                	ld	s4,8(sp)
ffffffffc020437c:	b331                	j	ffffffffc0204088 <vprintfmt+0x34>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020437e:	85ea                	mv	a1,s10
ffffffffc0204380:	00002517          	auipc	a0,0x2
ffffffffc0204384:	cc850513          	addi	a0,a0,-824 # ffffffffc0206048 <etext+0x1b06>
ffffffffc0204388:	114000ef          	jal	ffffffffc020449c <strnlen>
ffffffffc020438c:	40ac8cbb          	subw	s9,s9,a0
                p = "(null)";
ffffffffc0204390:	00002417          	auipc	s0,0x2
ffffffffc0204394:	cb840413          	addi	s0,s0,-840 # ffffffffc0206048 <etext+0x1b06>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204398:	00002a17          	auipc	s4,0x2
ffffffffc020439c:	cb1a0a13          	addi	s4,s4,-847 # ffffffffc0206049 <etext+0x1b07>
ffffffffc02043a0:	02800793          	li	a5,40
ffffffffc02043a4:	02800513          	li	a0,40
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02043a8:	fb904ce3          	bgtz	s9,ffffffffc0204360 <vprintfmt+0x30c>
ffffffffc02043ac:	b551                	j	ffffffffc0204230 <vprintfmt+0x1dc>

ffffffffc02043ae <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02043ae:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02043b0:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02043b4:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02043b6:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02043b8:	ec06                	sd	ra,24(sp)
ffffffffc02043ba:	f83a                	sd	a4,48(sp)
ffffffffc02043bc:	fc3e                	sd	a5,56(sp)
ffffffffc02043be:	e0c2                	sd	a6,64(sp)
ffffffffc02043c0:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02043c2:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02043c4:	c91ff0ef          	jal	ffffffffc0204054 <vprintfmt>
}
ffffffffc02043c8:	60e2                	ld	ra,24(sp)
ffffffffc02043ca:	6161                	addi	sp,sp,80
ffffffffc02043cc:	8082                	ret

ffffffffc02043ce <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc02043ce:	715d                	addi	sp,sp,-80
ffffffffc02043d0:	e486                	sd	ra,72(sp)
ffffffffc02043d2:	e0a2                	sd	s0,64(sp)
ffffffffc02043d4:	fc26                	sd	s1,56(sp)
ffffffffc02043d6:	f84a                	sd	s2,48(sp)
ffffffffc02043d8:	f44e                	sd	s3,40(sp)
ffffffffc02043da:	f052                	sd	s4,32(sp)
ffffffffc02043dc:	ec56                	sd	s5,24(sp)
ffffffffc02043de:	e85a                	sd	s6,16(sp)
    if (prompt != NULL) {
ffffffffc02043e0:	c901                	beqz	a0,ffffffffc02043f0 <readline+0x22>
ffffffffc02043e2:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc02043e4:	00002517          	auipc	a0,0x2
ffffffffc02043e8:	c7c50513          	addi	a0,a0,-900 # ffffffffc0206060 <etext+0x1b1e>
ffffffffc02043ec:	ccffb0ef          	jal	ffffffffc02000ba <cprintf>
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
            cputchar(c);
            buf[i ++] = c;
ffffffffc02043f0:	4401                	li	s0,0
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02043f2:	44fd                	li	s1,31
        }
        else if (c == '\b' && i > 0) {
ffffffffc02043f4:	4921                	li	s2,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02043f6:	4a29                	li	s4,10
ffffffffc02043f8:	4ab5                	li	s5,13
            buf[i ++] = c;
ffffffffc02043fa:	0000db17          	auipc	s6,0xd
ffffffffc02043fe:	cfeb0b13          	addi	s6,s6,-770 # ffffffffc02110f8 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0204402:	3fe00993          	li	s3,1022
        c = getchar();
ffffffffc0204406:	cebfb0ef          	jal	ffffffffc02000f0 <getchar>
        if (c < 0) {
ffffffffc020440a:	00054a63          	bltz	a0,ffffffffc020441e <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020440e:	00a4da63          	bge	s1,a0,ffffffffc0204422 <readline+0x54>
ffffffffc0204412:	0289d263          	bge	s3,s0,ffffffffc0204436 <readline+0x68>
        c = getchar();
ffffffffc0204416:	cdbfb0ef          	jal	ffffffffc02000f0 <getchar>
        if (c < 0) {
ffffffffc020441a:	fe055ae3          	bgez	a0,ffffffffc020440e <readline+0x40>
            return NULL;
ffffffffc020441e:	4501                	li	a0,0
ffffffffc0204420:	a091                	j	ffffffffc0204464 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc0204422:	03251463          	bne	a0,s2,ffffffffc020444a <readline+0x7c>
ffffffffc0204426:	04804963          	bgtz	s0,ffffffffc0204478 <readline+0xaa>
        c = getchar();
ffffffffc020442a:	cc7fb0ef          	jal	ffffffffc02000f0 <getchar>
        if (c < 0) {
ffffffffc020442e:	fe0548e3          	bltz	a0,ffffffffc020441e <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0204432:	fea4d8e3          	bge	s1,a0,ffffffffc0204422 <readline+0x54>
            cputchar(c);
ffffffffc0204436:	e42a                	sd	a0,8(sp)
ffffffffc0204438:	cb7fb0ef          	jal	ffffffffc02000ee <cputchar>
            buf[i ++] = c;
ffffffffc020443c:	6522                	ld	a0,8(sp)
ffffffffc020443e:	008b07b3          	add	a5,s6,s0
ffffffffc0204442:	2405                	addiw	s0,s0,1
ffffffffc0204444:	00a78023          	sb	a0,0(a5)
ffffffffc0204448:	bf7d                	j	ffffffffc0204406 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc020444a:	01450463          	beq	a0,s4,ffffffffc0204452 <readline+0x84>
ffffffffc020444e:	fb551ce3          	bne	a0,s5,ffffffffc0204406 <readline+0x38>
            cputchar(c);
ffffffffc0204452:	c9dfb0ef          	jal	ffffffffc02000ee <cputchar>
            buf[i] = '\0';
ffffffffc0204456:	0000d517          	auipc	a0,0xd
ffffffffc020445a:	ca250513          	addi	a0,a0,-862 # ffffffffc02110f8 <buf>
ffffffffc020445e:	942a                	add	s0,s0,a0
ffffffffc0204460:	00040023          	sb	zero,0(s0)
            return buf;
        }
    }
}
ffffffffc0204464:	60a6                	ld	ra,72(sp)
ffffffffc0204466:	6406                	ld	s0,64(sp)
ffffffffc0204468:	74e2                	ld	s1,56(sp)
ffffffffc020446a:	7942                	ld	s2,48(sp)
ffffffffc020446c:	79a2                	ld	s3,40(sp)
ffffffffc020446e:	7a02                	ld	s4,32(sp)
ffffffffc0204470:	6ae2                	ld	s5,24(sp)
ffffffffc0204472:	6b42                	ld	s6,16(sp)
ffffffffc0204474:	6161                	addi	sp,sp,80
ffffffffc0204476:	8082                	ret
            cputchar(c);
ffffffffc0204478:	4521                	li	a0,8
ffffffffc020447a:	c75fb0ef          	jal	ffffffffc02000ee <cputchar>
            i --;
ffffffffc020447e:	347d                	addiw	s0,s0,-1
ffffffffc0204480:	b759                	j	ffffffffc0204406 <readline+0x38>

ffffffffc0204482 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0204482:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc0204486:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc0204488:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc020448a:	cb81                	beqz	a5,ffffffffc020449a <strlen+0x18>
        cnt ++;
ffffffffc020448c:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc020448e:	00a707b3          	add	a5,a4,a0
ffffffffc0204492:	0007c783          	lbu	a5,0(a5)
ffffffffc0204496:	fbfd                	bnez	a5,ffffffffc020448c <strlen+0xa>
ffffffffc0204498:	8082                	ret
    }
    return cnt;
}
ffffffffc020449a:	8082                	ret

ffffffffc020449c <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc020449c:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc020449e:	e589                	bnez	a1,ffffffffc02044a8 <strnlen+0xc>
ffffffffc02044a0:	a811                	j	ffffffffc02044b4 <strnlen+0x18>
        cnt ++;
ffffffffc02044a2:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02044a4:	00f58863          	beq	a1,a5,ffffffffc02044b4 <strnlen+0x18>
ffffffffc02044a8:	00f50733          	add	a4,a0,a5
ffffffffc02044ac:	00074703          	lbu	a4,0(a4)
ffffffffc02044b0:	fb6d                	bnez	a4,ffffffffc02044a2 <strnlen+0x6>
ffffffffc02044b2:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc02044b4:	852e                	mv	a0,a1
ffffffffc02044b6:	8082                	ret

ffffffffc02044b8 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc02044b8:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc02044ba:	0005c703          	lbu	a4,0(a1)
ffffffffc02044be:	0785                	addi	a5,a5,1
ffffffffc02044c0:	0585                	addi	a1,a1,1
ffffffffc02044c2:	fee78fa3          	sb	a4,-1(a5)
ffffffffc02044c6:	fb75                	bnez	a4,ffffffffc02044ba <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc02044c8:	8082                	ret

ffffffffc02044ca <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02044ca:	00054783          	lbu	a5,0(a0)
ffffffffc02044ce:	e791                	bnez	a5,ffffffffc02044da <strcmp+0x10>
ffffffffc02044d0:	a02d                	j	ffffffffc02044fa <strcmp+0x30>
ffffffffc02044d2:	00054783          	lbu	a5,0(a0)
ffffffffc02044d6:	cf89                	beqz	a5,ffffffffc02044f0 <strcmp+0x26>
ffffffffc02044d8:	85b6                	mv	a1,a3
ffffffffc02044da:	0005c703          	lbu	a4,0(a1)
        s1 ++, s2 ++;
ffffffffc02044de:	0505                	addi	a0,a0,1
ffffffffc02044e0:	00158693          	addi	a3,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02044e4:	fef707e3          	beq	a4,a5,ffffffffc02044d2 <strcmp+0x8>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02044e8:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02044ec:	9d19                	subw	a0,a0,a4
ffffffffc02044ee:	8082                	ret
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02044f0:	0015c703          	lbu	a4,1(a1)
ffffffffc02044f4:	4501                	li	a0,0
}
ffffffffc02044f6:	9d19                	subw	a0,a0,a4
ffffffffc02044f8:	8082                	ret
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02044fa:	0005c703          	lbu	a4,0(a1)
ffffffffc02044fe:	4501                	li	a0,0
ffffffffc0204500:	b7f5                	j	ffffffffc02044ec <strcmp+0x22>

ffffffffc0204502 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0204502:	00054783          	lbu	a5,0(a0)
ffffffffc0204506:	c799                	beqz	a5,ffffffffc0204514 <strchr+0x12>
        if (*s == c) {
ffffffffc0204508:	00f58763          	beq	a1,a5,ffffffffc0204516 <strchr+0x14>
    while (*s != '\0') {
ffffffffc020450c:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0204510:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0204512:	fbfd                	bnez	a5,ffffffffc0204508 <strchr+0x6>
    }
    return NULL;
ffffffffc0204514:	4501                	li	a0,0
}
ffffffffc0204516:	8082                	ret

ffffffffc0204518 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0204518:	ca01                	beqz	a2,ffffffffc0204528 <memset+0x10>
ffffffffc020451a:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc020451c:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc020451e:	0785                	addi	a5,a5,1
ffffffffc0204520:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0204524:	fef61de3          	bne	a2,a5,ffffffffc020451e <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0204528:	8082                	ret

ffffffffc020452a <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc020452a:	ca19                	beqz	a2,ffffffffc0204540 <memcpy+0x16>
ffffffffc020452c:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc020452e:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0204530:	0005c703          	lbu	a4,0(a1)
ffffffffc0204534:	0585                	addi	a1,a1,1
ffffffffc0204536:	0785                	addi	a5,a5,1
ffffffffc0204538:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc020453c:	feb61ae3          	bne	a2,a1,ffffffffc0204530 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0204540:	8082                	ret

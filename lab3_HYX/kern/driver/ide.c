#include <assert.h>
#include <defs.h>
#include <fs.h>
#include <ide.h>
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}// IDE 磁盘的初始化函数。
//这段代码模拟了一个简单的 IDE 磁盘驱动，包含初始化、读写、校验等功能
#define MAX_IDE 2//MAX_IDE: 
#define MAX_DISK_NSECS 56//MAX_DISK_NSECS: 模拟磁盘的总扇区数，设置为 56。
//SECTSIZE: 每个扇区的字节大小（通常为 512 字节），从头文件中导入。

static char ide[MAX_DISK_NSECS * SECTSIZE];//一个静态数组，用于模拟硬盘的数据存储

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }//检查指定的磁盘号是否有效。

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }//获取指定磁盘的扇区数。
/*
ideno: 磁盘号。
secno: 起始扇区号。
dst: 目标缓冲区（读取的数据会写入此处）。
nsecs: 要读取的扇区数量
*/
//ideno: 假设挂载了多块磁盘，选择哪一块磁盘 这里我们其实只有一块“磁盘”，这个参数就没用到
int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,//从模拟磁盘中读取扇区数据。
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;//起始扇区号 secno 和每扇区大小 SECTSIZE，计算起始偏移量 iobase。
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);//从 ide 数组中对应偏移位置读取 nsecs * SECTSIZE 字节数据到目标缓冲区 dst。
    return 0;
}

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
    return 0;
}

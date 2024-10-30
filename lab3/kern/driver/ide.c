#include <assert.h>
#include <defs.h>
#include <fs.h>
#include <ide.h>
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}//初始化IDE接口的函数

#define MAX_IDE 2// 定义最大支持的 IDE 设备数为 2（即最多两个模拟硬盘）
#define MAX_DISK_NSECS 56// 定义磁盘扇区的最大数量为 56（每个扇区的大小为 SECTSIZE，即512字节）
static char ide[MAX_DISK_NSECS * SECTSIZE];// 定义一个数组 ide，用于模拟硬盘的数据存储空间

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }// 检查硬盘设备编号 ideno 是否有效（即是否在支持的范围内）

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }// 获取硬盘设备的大小（以扇区数为单位）

// 从硬盘中读取指定扇区的数据
// 参数 ideno 为设备编号，secno 为要读取的扇区号，dst 为存储数据的目的地址，nsecs 为读取的扇区数量
int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE); // 使用 memcpy 将 ide 数组中从 iobase 开始的 nsecs 个扇区的数据复制到 dst
    return 0;
}

// 将数据写入到指定的硬盘扇区
int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);// 使用 memcpy 将 src 中的数据复制到 ide 数组的指定位置
    return 0;
}

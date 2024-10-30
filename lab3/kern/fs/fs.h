#ifndef __KERN_FS_FS_H__
#define __KERN_FS_FS_H__

#include <mmu.h>

#define SECTSIZE            512
#define PAGE_NSECT          (PGSIZE / SECTSIZE)//一页需要几个磁盘扇区 4096/512=8

#define SWAP_DEV_NO         1//定义交换设备的编号为 1

#endif /* !__KERN_FS_FS_H__ */


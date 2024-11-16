#ifndef __KERN_FS_FS_H__
#define __KERN_FS_FS_H__

#include <mmu.h>

#define SECTSIZE            512//每个扇区大小
#define PAGE_NSECT          (PGSIZE / SECTSIZE) // 每个页面包含的扇区数。

#define SWAP_DEV_NO         1  //表示交换设备的编号 操作系统使用 SWAP_DEV_NO 指定的设备存储被换出的页面。

#endif /* !__KERN_FS_FS_H__ */


#include <swap.h>
#include <swapfs.h>
#include <mmu.h>
#include <fs.h>
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {// 初始化 swap 文件系统
    static_assert((PGSIZE % SECTSIZE) == 0);// 确保页面大小 PGSIZE 是扇区大小 SECTSIZE 的整数倍
    if (!ide_device_valid(SWAP_DEV_NO)) {// 检查交换设备是否可用
        panic("swap fs isn't available.\n");
    }
    // 计算最大交换区偏移量，表示交换区支持的页面数量
    // ide_device_size(SWAP_DEV_NO) 获取交换设备的总扇区数
    // 每页占用 PGSIZE / SECTSIZE 扇区，因此总页面数为总扇区数除以每页所需扇区数
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
}

int
swapfs_read(swap_entry_t entry, struct Page *page) {
    // 调用 ide_read_secs 从 swap 设备 (SWAP_DEV_NO) 的指定扇区读取页面数据
    // swap_offset(entry) * PAGE_NSECT 计算页面的起始扇区
    // page2kva(page) 将 page 转换为内核虚拟地址，以便读取数据至该地址
    // PAGE_NSECT 表示读取的扇区数量
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
}

int
swapfs_write(swap_entry_t entry, struct Page *page) {
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
}


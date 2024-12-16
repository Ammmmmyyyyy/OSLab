#include <stdio.h>
#include <ulib.h>

int magic = -0x10384;

int
main(void) {//这个用户程序exit里我们测试了fork() wait()这些函数。这些函数都是user/libs/ulib.h对系统调用的封装
    int pid, code;
    cprintf("I am the parent. Forking the child...\n");// 父进程输出信息，表示将要创建子进程
    if ((pid = fork()) == 0) {// 创建子进程，fork() 返回子进程的 PID给父进程，子进程返回0s
        cprintf("I am the child.\n");// 子进程的代码块
        yield();
        yield();
        yield();
        yield();
        yield();
        yield();
        yield();
        exit(magic);// 子进程完成后，调用 exit() 退出，传递 magic 作为退出码
    }
    else {
        cprintf("I am parent, fork a child pid %d\n",pid);// 父进程的代码块
    }
    assert(pid > 0);// 确保父进程的 pid 大于0
    cprintf("I am the parent, waiting now..\n");// 父进程输出等待子进程结束的信息

    assert(waitpid(pid, &code) == 0 && code == magic);// 父进程等待子进程的退出，验证退出码为 magic
    assert(waitpid(pid, &code) != 0 && wait() != 0);// 父进程再次尝试等待子进程，应该失败
    cprintf("waitpid %d ok.\n", pid);// 输出等待操作成功的调试信息

    cprintf("exit pass.\n");// 父进程退出信息
    return 0;
}


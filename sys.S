# Select Intel synatx, noprefix means we don't need % before each register
.intel_syntax noprefix

# Make symbols global so that the linker knows about them
.global write
.global read
.global execve
.global fork
.global real_waitid
.global _exit

write:
mov rax, 1
syscall
ret

read:
mov rax, 0
syscall
ret

execve:
mov rax, 59
syscall
ret

fork:
mov rax, 57
syscall
ret

real_waitid:
mov rax, 247
mov r10, rcx
syscall
ret

_exit:
mov rax, 60
syscall

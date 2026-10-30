#/usr/bin/env bash

gcc -c -fno-stack-protector shell.c 
as sys.S
ld -o shell shell.o a.out --entry main -z noexecstack

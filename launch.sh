#!/usr/bin/env bash
qemu-system-x86_64 \
  -cdrom ./cloned/linux/arch/x86/boot/image.iso \
  -nographic \

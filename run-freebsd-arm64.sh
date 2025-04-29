#!/bin/sh

qemu-system-aarch64 -M virt -m 8G -cpu cortex-a57 -smp 4 -display default,show-cursor=on -nographic -bios /usr/lib/u-boot/qemu_arm64/u-boot.bin -drive id=disk,file=/home/sem33/Загрузки/FreeBSD-14.0-RELEASE-arm64-aarch64-zfs.qcow2,if=none -device ahci,id=ahci -device ide-hd,drive=disk,bus=ahci.0

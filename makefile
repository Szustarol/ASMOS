deploy: bootloader.bin
	qemu-system-x86_64 bootloader.bin

bootloader.bin: stage1.bin stage2.bin kernel.bin
	cat stage1.bin stage2.bin kernel.bin > bootloader.bin

kernel.bin: kernel.asm Programs/*.asm
	nasm kernel.asm -o kernel.bin

stage2.bin: stage2.asm Utility/*.asm
	nasm stage2.asm -o stage2.bin

stage1.bin: stage1.asm
	nasm stage1.asm -o stage1.bin

clean:
	rm *.bin

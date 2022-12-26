#!/bin/sh

# This script assembles the HeliumOS bootloader, kernel and programs
# with NASM, and then creates floppy and CD images (on Linux)

# Only the root user can mount the floppy disk image as a virtual
# drive (loopback mounting), in order to copy across the files

# (If you need to blank the floppy image: 'mkdosfs disk_images/helium.flp')


if test "`whoami`" != "root" ; then
	echo "You must be logged in as root to build (for loopback mounting)"
	echo "Enter 'su' or 'sudo bash' to switch to root"
	exit
fi


if [ ! -e disk_images/helium.flp ]
then
	echo ">>> Creating new HeliumOS floppy image..."
	mkdosfs -C disk_images/helium.flp 1440 || exit
fi


echo ">>> Assembling bootloader..."

nasm -w+orphan-labels -f bin -o source/bootload/bootload.bin source/bootload/bootload.asm || exit


echo ">>> Assembling HeliumOS kernel..."

cd source
nasm -w+orphan-labels -f bin -o kernel.bin kernel.asm || exit
cd ..


echo ">>> Assembling programs..."

cd programs

for i in *.asm
do
	nasm -w+orphan-labels -f bin $i -o `basename $i .asm`.bin || exit
done

cd ..


echo ">>> Adding bootloader to floppy image..."

dd status=noxfer conv=notrunc if=source/bootload/bootload.bin of=disk_images/helium.flp || exit


echo ">>> Copying HeliumOS kernel and programs..."

rm -rf tmp-loop

mkdir tmp-loop && mount -o loop -t vfat disk_images/helium.flp tmp-loop && cp source/kernel.bin tmp-loop/

cp programs/*.bin programs/example.bas programs/test.pcx tmp-loop

echo ">>> Unmounting loopback floppy..."

umount tmp-loop || exit

rm -rf tmp-loop


echo ">>> Creating CD-ROM ISO image..."

rm -f disk_images/mikeos.iso
mkisofs -quiet -V 'HELIUM' -input-charset iso8859-1 -o disk_images/helium.iso -b helium.flp disk_images/ || exit

echo '>>> Done!'


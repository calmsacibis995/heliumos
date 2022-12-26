#!/bin/sh

# This script starts the QEMU PC emulator, booting from the
# HeliumOS floppy disk image

qemu-system-i386 -soundhw pcspk -fda disk_images/helium.flp


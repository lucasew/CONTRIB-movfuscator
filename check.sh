#!/bin/sh

# To verify that the M/o/Vfuscator is working correctly, this script will pull
# down an open source AES implementation, compile it, objdump it, and run it.
# The objdump will take some time, be patient.

echo

# M/o/Vfuscate the program
echo "M/o/Vfuscating..."
echo
sleep 2
movcc validation/aes/aes.c validation/aes/test.c -o validation/aes/aes -s
sleep 2
echo
echo

# Check the assembly
echo "Dumping..."
echo
sleep 2
objdump -d -Mintel --insn-width=15 validation/aes/aes
sleep 2
echo
echo

# Check execution
echo "Running..."
echo
sleep 2
./validation/aes/aes
sleep 2
echo "M/o/Vfuscator check complete."
echo

#!/bin/bash

export success='0'
for f in ./*.asm
do
    yasm -f elf64 -g dwarf2 $f -o ${f::-4}.o
done &&\
for f in ./strings_processing/*.asm
do
    yasm -f elf64 -g dwarf2 $f -o ${f::-4}.o
done &&\
for f in ./structures/*.asm
do
    yasm -f elf64 -g dwarf2 $f -o ${f::-4}.o
done &&\
for f in ./file_interactions/*.asm
do
    yasm -f elf64 -g dwarf2 $f -o ${f::-4}.o
done &&\

gcc -Wall -m64 -no-pie -gdwarf-2 -o ./sorter \
    ./*.o ./structures/*.o ./file_interactions/*.o \
    ./strings_processing/*.o &&\
success='1'

rm -rf ./*.o &&\
rm -rf ./*/*.o

if [[ success=="1" ]]; then
    ./sorter
fi

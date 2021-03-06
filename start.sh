#!/bin/bash

export success='0'

for d in */; do
    for f in $d*.asm
    do
        yasm -f elf64 -g dwarf2 $f -o ${f::-4}.o
    done
done

for f in ./*.asm
do
    yasm -f elf64 -g dwarf2 $f -o ${f::-4}.o
done

gcc -Wall -m64 -no-pie -gdwarf-2 -o ./sorter \
    ./*.o ./structures/*.o ./file_interactions/*.o \
    ./strings_processing/*.o &&\
success='1'

rm -rf ./*.o &&\
rm -rf ./*/*.o

if [[ success=="1" ]]; then
    ./sorter
    printf "\nExit code is %i\n" $?
fi

#!/bin/bash

yasm -f elf64 -g dwarf2 ./main.asm &&\
yasm -f elf64 -g dwarf2 ./heap.asm &&\
yasm -f elf64 -g dwarf2 ./reader.asm &&\
yasm -f elf64 -g dwarf2 ./writer.asm &&\
yasm -f elf64 -g dwarf2 ./comparator.asm &&\

gcc -Wall -m64 -no-pie -gdwarf-2 ./main.o ./heap.o ./reader.o ./writer.o ./comparator.o -o ./sorter &&\
rm -rf ./*.o &&\

./sorter

#!/bin/bash

yasm -f elf64 -g dwarf2 ./main.asm &&\
yasm -f elf64 -g dwarf2 ./strings_processing/communicator.asm -o ./strings_processing/communicator.o &&\
yasm -f elf64 -g dwarf2 ./structures/heap.asm -o ./structures/heap.o &&\
yasm -f elf64 -g dwarf2 ./structures/dynamic_array.asm -o ./structures/dynamic_array.o &&\
yasm -f elf64 -g dwarf2 ./file_interactions/reader.asm -o ./file_interactions/reader.o &&\
yasm -f elf64 -g dwarf2 ./file_interactions/writer.asm -o ./file_interactions/writer.o &&\
yasm -f elf64 -g dwarf2 ./structures/deque.asm -o ./structures/deque.o &&\
yasm -f elf64 -g dwarf2 ./strings_processing/comparator.asm -o ./strings_processing/comparator.o &&\

gcc -Wall -m64 -no-pie -gdwarf-2 -o ./sorter \
    ./main.o ./structures/heap.o ./structures/dynamic_array.o \
    ./file_interactions/reader.o ./file_interactions/writer.o ./structures/deque.o \
    ./strings_processing/comparator.o ./strings_processing/communicator.o &&\

rm -rf ./*.o &&\
rm -rf ./*/*.o &&\

./sorter

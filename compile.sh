#! /bin/bash


Compiler=as

Bin_Folder=bin
Src_Folder=src
Obj_Folder=build/obj

Source=$(find src -name "*.s")
Includes=$(find src -type d | sed 's/^/ -I/')

Linker_Flags="-l System -syslibroot `xcrun -sdk macosx --show-sdk-path` -e _main -arch arm64"
Compile_Flags="$Includes"

# $Compiler $Compile_Flags $Src_Folder/input.s $Src_Folder/program.s $Src_Folder/logic.S -o bin/calc

for File in ${Source[*]}; do
  name=${File##*/}
  obj=${name/%.*/.o}
  $Compiler $Compile_Flags $File -o build/obj/$obj
  if [ ! $? ]; then 
    echo here
    exit
  fi
done

outfiles=$(find build/obj -name "*.o")

ld $outfiles -o bin/calculator $Linker_Flags

if [ ! $? ]; then
  exit
fi

./bin/calculator

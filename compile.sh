#!/bin/bash

main=./src

files=""
for f in $main/*.erl
do
  files="$files $f"
done

rm -rf ./ebin/*.beam

erlc -W -I ./include -o ./ebin $files

echo Compiling completed.

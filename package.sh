#!/bin/bash

./test.sh

vsn=1.4.0
name=jerlson-$vsn
dir=target
path=$dir/$name

echo Packaging Jerlson $vsn $path

if [ -e $path ]
then
	rm -rf $path
fi

mkdir -p $path
mkdir -p $path/ebin

cp ebin/jerlson*.beam $path/ebin
cp LICENSE $path/

tar -czf $path.tar.gz -C $dir $name

echo Packaging Jerlson completed

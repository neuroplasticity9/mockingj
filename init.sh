#!/usr/bin/env bash

mockingjRoot=~/.mockingj
mockingjSharedFolder=~/MockingjShared/

mkdir -p "$mockingjRoot"
mkdir -p "$mockingjSharedFolder"

cp -i src/stubs/mockingj.yaml "$mockingjRoot/mockingj.yaml"
cp -i src/stubs/after.sh "$mockingjRoot/after.sh"
cp -i src/stubs/aliases "$mockingjRoot/aliases"

echo "Mockingj initialized!"

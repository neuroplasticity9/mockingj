#!/usr/bin/env bash

files=$(ls install/*)
for file in ${files}
do
  bash ${file}
done
#!/usr/bin/env bash

files=$(ls ${BASH_SOURCE%/*}/install/*)
for file in ${files}
do
  bash ${file}
done
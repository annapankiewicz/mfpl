#!/bin/bash

tput sgr0

echo "test: testing"
inputs=`find ./test/code -iname "$1*.txt"`
fails=0
passes=0

green=`tput setaf 2`
red=`tput setaf 1`
reset=`tput sgr0`

for i in $inputs; do
  filename=$(basename $i)

  a.out ./test/code/$filename > ./test/output/$filename.out

  diff ./test/expected/$filename.out ./test/output/$filename.out > ./test/reports/$filename \
    --ignore-space-change \
    --ignore-case \
    --side-by-side

  lines=`diff ./test/output/$filename.out ./test/expected/$filename.out \
    --ignore-space-change \
    --ignore-case \
      | wc --lines`

  testname="${filename%.*}"

  if [ "$lines" -gt "0" ]; then

    fails=$[ $fails + 1 ]

    echo "test: ${red}[fail]${reset} $testname ($lines lines)"

  else

    passes=$[ $passes + 1 ]

    echo "test: ${green}[pass]${reset} $testname"

  fi

done

echo >> ./test/reports/summary.txt

echo "test: ${green}$passes${reset} tests passed"
echo "test: ${red}$fails${reset} tests failed"

#!/bin/bash


echo "run: testing"
inputs=`ls ./test/input --ignore-backups`
tests=0
for i in $inputs; do
  a.out < ./test/input/$i > ./test/output/$i.out

  diff ./test/expected/$i.out ./test/output/$i.out > ./test/reports/$i \
    --ignore-space-change \
    --ignore-case \
    --side-by-side

  lines=`diff ./test/output/$i.out ./test/expected/$i.out \
    --ignore-space-change \
    --ignore-case \
      | wc --lines`

  if [ "$lines" -gt "0" ]; then
    tests=$[ $tests + 1 ]
    echo "run: $lines unexpected lines in $i.out" | tee -a ./test/reports/summary.txt
  fi

done

if [ "$tests" -eq "0" ]; then
  echo "run: all tests passed"
fi

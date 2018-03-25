#!/bin/bash

echo "clean: removing bins"
rm -f lex.yy.c
rm -f *.tab.c
rm -f a.out
rm -f *.zip

echo "clean: truncating output and reports"
truncate -s 0 ./test/output/*.out
truncate -s 0 ./test/reports/*.txt

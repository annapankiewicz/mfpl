#!/bin/bash

. clean.sh

echo "build: building"
flex *.l
bison *.y
g++ *.tab.c

. run.sh

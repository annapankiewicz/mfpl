#!/bin/bash

tput sgr0

. clean.sh

echo "build: building"

flex *.l

if [ "$?" -eq 0 ]; then
  bison *.y

  if [ "$?" -eq 0 ]; then
    g++ *.tab.c -o a.out

    if [ "$?" -eq 0 ]; then
      . test.sh $@

    else
      echo "build: compile error, exiting"
    fi

  else
    echo "build: error in bison file, exiting"
  fi

else
  echo "build: error in flex file, exiting"
fi

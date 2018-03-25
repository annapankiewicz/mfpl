flex -d *.l

if [ "$?" -eq 0 ]; then
  bison -t *.y

  if [ "$?" -eq 0 ]; then
    g++ -Wall -g *.tab.c -o a.out

  else
    echo "debug: error in bison file, exiting"
  fi

else
  echo "debug: error in flex file, exiting"
fi

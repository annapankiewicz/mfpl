// CS 3500 B
// hw03
// Ryan Duchene
// 10/4/2017

#ifndef SYMBOL_TABLE_ENTRY_H
#define SYMBOL_TABLE_ENTRY_H

#include <string>
#include "Signature.h"
#include "Store.h"
using namespace std;

class SymbolTableEntry
{
private:
  string name;
  Signature signature;
  Store store;

public:
  // default constructor
  SymbolTableEntry()
  {
    name = "";
    signature.type = NOT_APPLICABLE;
    signature.numParams = 0;
    signature.returnType = NOT_APPLICABLE;
  }

  // Non-Function Constructor
  SymbolTableEntry(string entryName, Type entryType, int vInt, string vStr, bool vBool)
  {
    name = entryName;

    signature.type = entryType;
    signature.numParams = 0;
    signature.returnType = NOT_APPLICABLE;

    store.vInt = vInt;
    store.vStr = vStr;
    store.vBool = vBool;
  }

  // removed function constructor
  // Function Constructor

  string getName() { return name; }

  Signature getSignature() { return signature; }

  int getInt()
  {
    return store.vInt;
  }

  string getStr()
  {
    return store.vStr;
  }

  bool getBool()
  {
    return store.vBool;
  }

};

#endif

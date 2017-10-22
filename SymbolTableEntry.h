// CS 3500 B
// hw03
// Ryan Duchene
// 10/4/2017

#ifndef SYMBOL_TABLE_ENTRY_H
#define SYMBOL_TABLE_ENTRY_H

#include <string>
#include "TypeInfo.h"
using namespace std;

class SymbolTableEntry
{
private:
  string name;
  TypeInfo typeInfo;

public:
  // default constructor
  SymbolTableEntry()
  {
    name = "";
    typeInfo.type = NOT_APPLICABLE;
    typeInfo.numParams = 0;
    typeInfo.returnType = NOT_APPLICABLE;
  }

  // Non-Function Constructor
  SymbolTableEntry(const string entryName, const Type entryType)
  {
    name = entryName;
    typeInfo.type = entryType;
    typeInfo.numParams = 0;
    typeInfo.returnType = NOT_APPLICABLE;
  }

  // Function Constructor
  SymbolTableEntry(const string entryName, const Type entryType, const int entryParams, const Type returnType)
  {
     name = entryName;
     typeInfo.type = entryType;
     typeInfo.numParams = entryParams;
     typeInfo.returnType = returnType;
  }

  string getName() const { return name; }

  TypeInfo getTypeInfo() const { return typeInfo; }

};

#endif

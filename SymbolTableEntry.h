// CS 3500 B
// hw03
// Ryan Duchene
// 10/4/2017

#ifndef SYMBOL_TABLE_ENTRY_H
#define SYMBOL_TABLE_ENTRY_H

#include <string>
using namespace std;

#define UNDEFINED  -1

class SymbolTableEntry
{
private:
  string name;
  int typeCode;

public:

  SymbolTableEntry()
  {
    name = "";
    typeCode = -1;
  }

  SymbolTableEntry(const string entryName, const int entryTypeCode)
  {
    name = entryName;
    typeCode = entryTypeCode;
  }

  string getName() const { return name; }
  int getTypeCode() const { return typeCode; }

};

#endif

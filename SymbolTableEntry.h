// CS 3500 B
// hw03
// Ryan Duchene
// 10/4/2017

#ifndef SYMBOL_TABLE_ENTRY_H
#define SYMBOL_TABLE_ENTRY_H

#include <string>
using namespace std;

enum Type
{
  UNDEFINED, // remove eventually
  BOOL,
  INT,
  STR,
  FUNCTION,
  INT_OR_STR,
  INT_OR_BOOL,
  STR_OR_BOOL,
  INT_OR_STR_OR_BOOL
};

class SymbolTableEntry
{
private:
  string name;
  Type type;
  short numParams; // used only if `type` == function
  Type returnType; // used only if `type` == function

public:
  // remove eventually
  SymbolTableEntry()
  {
    name = "";
    type = UNDEFINED;
  }

  SymbolTableEntry(const string entryName, const Type entryType)
  {
    name = entryName;
    type = entryType;
  }

  string getName() const { return name; }
  int getTypeCode() const { return type; }

};

#endif

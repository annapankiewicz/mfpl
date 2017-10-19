// CS 3500 B
// hw03
// Ryan Duchene
// 10/4/2017

#ifndef SYMBOL_TABLE_ENTRY_H
#define SYMBOL_TABLE_ENTRY_H

#include <string>
using namespace std;

enum Type
{i
  NOT_APPLICABLE, // remove eventually
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
  struct TYPE_INFO
  {
    Type type;
    int numParams;     // only applicable if type == FUNCTION
    Type returnType;   // only applicable if type == FUNCTION
  }

public:
  // remove eventually
  SymbolTableEntry()
  {
    name = "";
    TYPE_INFO.type = NOT_APPLICABLE;
    TYPE_INFO.numParams = NOT_APPLICABLE;
    TYPE_INFO.returnType = NOT_APPLICABLE;
  }

  // Non-Function Constructor
  SymbolTableEntry(const string entryName, const Type entryType)
  {
    name = entryName;
    TYPE_INFO.type = entryType;
    TYPE_INFO.numParams = NOT_APPLICABLE;
    TYPE_INFO.returnType = NOT_APPLICABLE;
  }

  // Function Constructor
  SymbolTableEntry(const string entryName, const Type entryType, const int entryParams, const Type returnType)
  {
     name = entryName;
     TYPE_INFO.type = entryType;
     TYPE_INFO.numParams = NOT_APPLICABLE; 
     TYPE_INFO.returnType = NOT_APPLICABLE;
  }

  string getName() const { return name; }
  int getTypeCode() const
  {
    return 
  }  // change

};

#endif

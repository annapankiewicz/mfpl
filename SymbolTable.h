// CS 3500 B
// hw03
// Ryan Duchene
// 10/4/2017

#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#include <map>
#include <string>
#include "SymbolTableEntry.h"
using namespace std;

class SymbolTable
{
private:
  std::map<string, SymbolTableEntry> hashTable;

public:

  SymbolTable() {}

  bool add(SymbolTableEntry entry)
  {
    map<string, SymbolTableEntry>::iterator itr;

    if ((itr = hashTable.find(entry.getName())) == hashTable.end())
    {
      hashTable.insert(make_pair(entry.getName(), entry));
      return true;
    }

    else
    {
      return false;
    }

  }

  bool has(string nameQuery)
  {
    map<string, SymbolTableEntry>::iterator itr;

    if ((itr = hashTable.find(nameQuery)) == hashTable.end())
    {
      return false;
    }

    else
    {
      return true;
    }

  }

  SymbolTableEntry get(string nameQuery)
  {
    map<string, SymbolTableEntry>::iterator itr;

    if ((itr = hashTable.find(nameQuery)) != hashTable.end())
    {
      return hashTable[nameQuery];
    }

    else
    {
      return SymbolTableEntry();
    }
  }

};

#endif

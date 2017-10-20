
#ifndef TYPEINFO_H
#define TYPEINFO_H

enum Type
{
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

struct TypeInfo
{
  Type type;
  short numParams;
  Type returnType;
};

#endif

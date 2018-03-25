
#ifndef SIGNATURE_H
#define SIGNATURE_H

using namespace std;

enum Type
{
  NOT_APPLICABLE = 0x0,
  BOOL = 0x1,
  INT = 0x2,
  INT_OR_BOOL = 0x3,
  STR = 0x4,
  STR_OR_BOOL = 0x5,
  INT_OR_STR = 0x6,
  INT_OR_STR_OR_BOOL = 0x7,
  FUNCTION = 0x8
};

struct Signature
{
  Type type;
  short numParams;
  Type returnType;
};

#endif

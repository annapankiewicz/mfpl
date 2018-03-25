%{

#include <iostream>
#include <stack>
#include <string>
#include <stdio.h>
#include <cstring>
#include "Signature.h"
#include "Store.h"
#include "SymbolTable.h"
using namespace std;

// incremented in *.l with each NEWLINE
// used for tracing current line
int numlines = 1;

// stack of scopes
// tracks variables
stack<SymbolTable> scopes;

// prints .yy rule
void printRule(const char* lhs, const char* rhs);

int yyerror(const char* str);

// prints .l lexemes and tokens
void printTokenInfo(const char* tokenType, const char* lexeme);

// used to add/remove scopes to scope stack above
void beginScope();
void endScope();

// used for binary operators to signal what types they accept
enum OpType
{
  MULT = 0x0001,
  SUB = 0x0002,
  DIV = 0x0004,
  ADD = 0x0008,
  AND = 0x0010,
  OR = 0x0020,
  LT = 0x0040,
  GT = 0x0080,
  LE = 0x0100,
  GE = 0x0200,
  EQ = 0x0400,
  NE = 0x0800,
  NOT = 0x1000
};

struct UExpr
{
  // Signature
  Type type;
  short numParams;
  Type returnType;

  // Store
  int vInt;
  const char* vStr;
  bool vBool;
};

// deep-checks scopes to see if variable exists
// TODO: is variable shadowing allowed?
bool variableDeclared(const string varName);

// deep-gets a symbol table entry (variable)
SymbolTableEntry getVariable(string varName);

extern "C"
{
  int yyparse(void);
  int yylex(void);
  int yywrap() { return 1; }
}

%}

%union
{
  char* text;
  UExpr bundle;
  OpType operation;
  char* strconst;
  int intconst;
}

%token T_LETSTAR
%token T_LAMBDA
%token T_INPUT
%token T_PRINT
%token T_IF
%token T_LPAREN
%token T_RPAREN
%token T_T
%token T_NIL
%token T_AND
%token T_OR
%token T_NOT
%token T_ADD
%token T_MULT
%token T_DIV
%token T_SUB
%token T_LT
%token T_GT
%token T_LE
%token T_GE
%token T_EQ
%token T_NE
%token T_IDENT
%token T_INTCONST
%token T_STRCONST
%token T_UNKNOWN

%type <text> T_IDENT
%type <intconst> T_INTCONST
%type <strconst> T_STRCONST
%type <bundle> N_CONST
%type <bundle> N_EXPR
%type <bundle> N_PARENTHESIZED_EXPR
%type <bundle> N_IF_EXPR
%type <bundle> N_ARITHLOGIC_EXPR
%type <bundle> N_PRINT_EXPR
%type <bundle> N_INPUT_EXPR
%type <bundle> N_EXPR_LIST
%type <bundle> N_LET_EXPR
%type <operation> N_BIN_OP
%type <operation> N_ARITH_OP
%type <operation> N_LOG_OP
%type <operation> N_REL_OP
%type <operation> N_UN_OP


%start N_START

%%

N_START:
  N_EXPR {
    printRule("START", "EXPR");
    printf("\n---- Completed parsing ----\n\n");

    if ($1.type == INT)
    {
      printf("\nValue of the expression is: %d", $1.vInt);
    }

    else if ($1.type == STR)
    {
      printf("\nValue of the expression is: %s", $1.vStr);
    }

    else if ($1.type == BOOL)
    {
      if ($1.vBool)
      {
        printf("\nValue of the expression is: t");
      }

      else
      {
        printf("\nValue of the expression is: nil");
      }
    }

    return 0;
  };

N_EXPR:
  N_CONST {
    printRule("EXPR", "CONST");

    $$.type = $1.type;
    $$.numParams = $1.numParams;
    $$.returnType = $1.returnType;

    $$.vInt = $1.vInt;
    $$.vStr = $1.vStr;
    $$.vBool = $1.vBool;

  }|

  T_IDENT {
    printRule("EXPR", "IDENT");


    // if this variable isn't declared, throw error
    bool found = variableDeclared(string($1));
    if (!found)
    {
      yyerror("Undefined identifier");
      YYABORT;
    }

    // now we know it exists, so look it up
    // YYABORT = this code won't be reached if var doesn't exist
    SymbolTableEntry entry = getVariable(string($1));

    int identInt = entry.getInt();
    const char* identStr = entry.getStr().c_str();
    bool identBool = entry.getBool();


    $$.type = entry.getSignature().type;
    $$.numParams = entry.getSignature().numParams;
    $$.returnType = entry.getSignature().returnType;

    $$.vInt = entry.getInt();
    $$.vStr = entry.getStr().c_str();
    $$.vBool = entry.getBool();



  }|

  T_LPAREN N_PARENTHESIZED_EXPR T_RPAREN {
    printRule("EXPR", "( PARENTHESIZED_EXPR )");

    // float type back up
    $$.type = $2.type;
    $$.numParams = $2.numParams;
    $$.returnType = $2.returnType;

    $$.vInt = $2.vInt;
    $$.vStr = $2.vStr;
    $$.vBool = $2.vBool;
  };


N_CONST:
  T_INTCONST {
    printRule("CONST", "INTCONST");

    $$.type = INT;
    $$.numParams = 0;
    $$.returnType = NOT_APPLICABLE;

    $$.vInt = $1;
    $$.vStr = "";
    $$.vBool= true;
  }|
  T_STRCONST {
    printRule("CONST", "STRCONST");

    /*const char* strconststr = $1;*/

    $$.type = STR;
    $$.numParams = 0;
    $$.returnType = NOT_APPLICABLE;

    $$.vInt = 0;
    $$.vStr = $1;
    $$.vBool= true;

  }|
  T_T {
    printRule("CONST", "T");

    $$.type = BOOL;
    $$.numParams = 0;
    $$.returnType = NOT_APPLICABLE;

    $$.vInt = 0;
    $$.vStr = "";
    $$.vBool= true;
  }|
  T_NIL {
    printRule("CONST", "NIL");

    $$.type = BOOL;
    $$.numParams = 0;
    $$.returnType = NOT_APPLICABLE;

    $$.vInt = 0;
    $$.vStr = "";
    $$.vBool= false;
  };

N_PARENTHESIZED_EXPR:
  N_ARITHLOGIC_EXPR {
    printRule("PARENTHESIZED_EXPR", "ARITHLOGIC_EXPR");

    // float
    $$.type = $1.type;
    $$.numParams = $1.numParams;
    $$.returnType = $1.returnType;

    $$.vInt = $1.vInt;
    $$.vStr = $1.vStr;
    $$.vBool = $1.vBool;

  }|
  N_IF_EXPR {
    printRule("PARENTHESIZED_EXPR", "IF_EXPR");

    // float
    $$.type = $1.type;
    $$.numParams = $1.numParams;
    $$.returnType = $1.returnType;

    $$.vInt = $1.vInt;
    $$.vStr = $1.vStr;
    $$.vBool = $1.vBool;

  }|
  N_LET_EXPR {
    printRule("PARENTHESIZED_EXPR", "LET_EXPR");

    // float
    $$.type = $1.type;
    $$.numParams = $1.numParams;
    $$.returnType = $1.returnType;

    $$.vInt = $1.vInt;
    $$.vStr = $1.vStr;
    $$.vBool = $1.vBool;

  }|
  N_PRINT_EXPR {
    printRule("PARENTHESIZED_EXPR", "PRINT_EXPR");

    // float
    $$.type = $1.type;
    $$.numParams = $1.numParams;
    $$.returnType = $1.returnType;

    $$.vInt = $1.vInt;
    $$.vStr = $1.vStr;
    $$.vBool = $1.vBool;

  }|
  N_INPUT_EXPR {
    printRule("PARENTHESIZED_EXPR", "INPUT_EXPR");

    // float
    $$.type = $1.type;
    $$.numParams = $1.numParams;
    $$.returnType = $1.returnType;

    $$.vInt = $1.vInt;
    $$.vStr = $1.vStr;
    $$.vBool = $1.vBool;

  }|
  N_EXPR_LIST {
    printRule("PARENTHESIZED_EXPR", "EXPR_LIST");

    // float
    $$.type = $1.type;
    $$.numParams = $1.numParams;
    $$.returnType = $1.returnType;

    $$.vInt = $1.vInt;
    $$.vStr = $1.vStr;
    $$.vBool = $1.vBool;

  };

N_ARITHLOGIC_EXPR:
  N_UN_OP N_EXPR {
    printRule("ARITHLOGIC_EXPR", "UN_OP EXPR");

    // EXPR can't be a function

    $$.type = BOOL; // end type is always bool, regardless of EXPR
    $$.numParams = 0;
    $$.returnType = NOT_APPLICABLE;

    $$.vInt = 0;
    $$.vStr = "";

    if ($2.type == BOOL && $2.vBool == false) // bitwise?
    {
      $$.vBool = true;
    }

    else
    {
      $$.vBool = false;
    }

  }|
  N_BIN_OP N_EXPR N_EXPR {
    printRule("ARITHLOGIC_EXPR", "BIN_OP EXPR EXPR");
    // arithmetic operations EXPR must both be INT
    if (($1 & (MULT | SUB | DIV | ADD)) != 0)
    {

      // check if type is not int or compsite of int
      if (($2.type & INT) == 0)
      {
        yyerror("Arg 1 must be integer");
        YYABORT;
      }

      // check if type is not int or composite of int
      if (($3.type & INT) == 0)
      {
        yyerror("Arg 2 must be integer");
        YYABORT;
      }

      $$.type = INT; // arithmetic operator guarantees INT type
      $$.numParams = 0;
      $$.returnType = NOT_APPLICABLE;
    }

    // relational operators EXPR must be INT/INT or STR/STR
    else if (($1 & (LT | GT | LE | GE | EQ | NE)) != 0)
    {
      if (($2.type & INT) != 0)
      {
        if (($3.type & INT) == 0)
        {
          yyerror("Arg 2 must be integer or string");
          YYABORT;
        }
      }
      else if (($2.type & STR) != 0)
      {
        if (($3.type & STR) == 0)
        {
          yyerror("Arg 2 must be integer or string");
          YYABORT;
        }
      }
      else
      {
        yyerror("Arg 1 must be integer or string");
        YYABORT;
      }

      $$.type = BOOL; // if arithmetic operators not used, type is BOOL
      $$.numParams = 0;
      $$.returnType = NOT_APPLICABLE;
    }

    else
    {
      // $1 guaranteed to be == to LOG_OP

      if ($2.type == FUNCTION)
      {
        yyerror("Arg 1 cannot be function");
        YYABORT;
      }

      else if ($3.type == FUNCTION)
      {
        yyerror("Arg 2 cannot be function");
        YYABORT;
      }

      $$.type = BOOL; // LOG_OP guaranteed to be BOOL type
      $$.numParams = 0;
      $$.returnType = NOT_APPLICABLE;

    }

    // OPERATORS
    //
    //
    switch ($1)
    {
      // ==========
      // ARITHMETIC
      // ==========

      // MULTIPLICATION
      //
      case MULT:
      $$.vInt = $2.vInt * $3.vInt;
      $$.vStr = "";
      $$.vBool = true;
      break;

      // SUBTRACTION
      //
      case SUB:
      $$.vInt = $2.vInt - $3.vInt;
      $$.vStr = "";
      $$.vBool = true;
      break;

      // DIVISION
      //
      case DIV:

      if ($3.vInt == 0)
      {
        yyerror("Attempted division by zero");
        YYABORT;
      }

      $$.vInt = $2.vInt / $3.vInt;
      $$.vStr = "";
      $$.vBool = true;
      break;

      // ADDITION
      //
      case ADD:
      $$.vInt = $2.vInt + $3.vInt;
      $$.vStr = "";
      $$.vBool = true;
      break;

      // ==========
      // LOGICAL
      // ==========

      // AND
      //
      case AND:
      $$.vInt = 0;
      $$.vStr = "";

      // if neither is bool, both true
      if ($2.type != BOOL && $3.type != BOOL)
      {
        $$.vBool = true;
      }

      else if ($2.vBool && $3.vBool)
      {
        $$.vBool = true;
      }

      else
      {
        $$.vBool = false;
      }

      break;

      // OR
      //
      case OR:
      $$.vInt = 0;
      $$.vStr = "";

      // if either is bool, true
      if ($2.type != BOOL || $3.vBool != BOOL)
      {
        $$.vBool = true;
      }

      else if ($2.vBool || $3.vBool)
      {
        $$.vBool = true;
      }

      else
      {
        $$.vBool = false;
      }

      break;

      // ==========
      // RELATIVE
      // guaranteed to be either both ints or both strs
      // ==========

      // LESSER THAN
      //
      case LT:
      $$.vInt = 0;
      $$.vStr = "";

      if ($2.type == STR)
      {
        $$.vBool = strlen($2.vStr) < strlen($3.vStr);
      }

      else
      {
        $$.vBool = $2.vInt < $3.vInt;
      }

      break;

      // GREATER THAN
      //
      case GT:
      $$.vInt = 0;
      $$.vStr = "";

      if ($2.type == STR)
      {
        $$.vBool = strlen($2.vStr) > strlen($3.vStr);
      }

      else
      {
        $$.vBool = $2.vInt > $3.vInt;
      }

      break;

      // LESSER THAN OR EQUAL TO
      //
      case LE:
      $$.vInt = 0;
      $$.vStr = "";

      if ($2.type == STR)
      {
        $$.vBool = strlen($2.vStr) <= strlen($3.vStr);
      }

      else
      {
        $$.vBool = $2.vInt <= $3.vInt;
      }

      break;

      // GREATER THAN OR EQUAL TO
      //
      case GE:
      $$.vInt = 0;
      $$.vStr = "";

      if ($2.type == STR)
      {
        $$.vBool = strlen($2.vStr) >= strlen($3.vStr);
      }

      else
      {
        $$.vBool = $2.vInt >= $3.vInt;
      }

      break;

      // EQUAL
      //
      case EQ:
      $$.vInt = 0;
      $$.vStr = "";

      if ($2.type != $3.type)
      {
        $$.vBool = false;
      }

      if ($2.type == STR)
      {
        $$.vBool = strcmp($2.vStr, $3.vStr) == 0;
      }

      else
      {
        $$.vBool = $2.vInt == $3.vInt;
      }

      break;

      // NOT EQUAL
      //
      case NE:
      $$.vInt = 0;
      $$.vStr = "";
      $$.vBool = true;

      if ($2.type != $3.type)
      {
        $$.vBool = false;
      }

      if ($2.type == STR)
      {
        $$.vBool = strcmp($2.vStr, $3.vStr) != 0;
      }

      else
      {
        $$.vBool = $2.vInt != $3.vInt;
      }

      break;

      // for sanity
      default:
      $$.vInt = $2.vInt;
      $$.vStr = $2.vStr;
      $$.vBool = $2.vBool;
      break;
    }


  };

N_IF_EXPR:
  T_IF N_EXPR N_EXPR N_EXPR {
    printRule("IF_EXPR", "IF EXPR EXPR EXPR");

    // no args can be functions

    $$.numParams = 0;
    $$.returnType = NOT_APPLICABLE;

    if (!$2.vBool)
    {
      $$.type = $4.type;

      $$.vInt = $4.vInt;
      $$.vStr = $4.vStr;
      $$.vBool = $4.vBool;

    }

    else
    {
      $$.type = $3.type;

      $$.vInt = $3.vInt;
      $$.vStr = $3.vStr;
      $$.vBool = $3.vBool;
    }

  };

N_LET_EXPR:
  T_LETSTAR T_LPAREN N_ID_EXPR_LIST T_RPAREN N_EXPR {
    printRule("LET_EXPR", "let* ( ID_EXPR_LIST ) EXPR");

    endScope();

    // EXPR can't be function

    // resulting type is EXPR's type
    $$.type = $5.type;
    $$.numParams = $5.numParams;
    $$.returnType = $5.returnType;

    $$.vInt = $5.vInt;
    $$.vStr = $5.vStr;
    $$.vBool = $5.vBool;

  };

N_ID_EXPR_LIST:
  {
    printRule("ID_EXPR_LIST", "epsilon");

    // ID_EXPR_LIST has no type associated with it
  }|
  N_ID_EXPR_LIST T_LPAREN T_IDENT N_EXPR T_RPAREN {
    printRule("ID_EXPR_LIST", "ID_EXPR_LIST ( IDENT EXPR )");
    printf("___Adding %s to symbol table\n", $3);

    // check to see if already declared
    if (scopes.top().has($3))
    {
      // this variable has been declared in this scope before
      yyerror("Multiply defined identifier");
      YYABORT;
    }

    // removed functions check from here, might need to add it back

    scopes.top().add(SymbolTableEntry($3, $4.type, $4.vInt, string($4.vStr), $4.vBool));



  };

N_PRINT_EXPR:
  T_PRINT N_EXPR {
    printRule("PRINT_EXPR", "print EXPR");

    // can't print a function
    // remove function check

    if (($2.type & INT) != 0)
    {
      printf("%d\n", $2.vInt);
    }

    else if (($2.type & STR) != 0)
    {
      printf("%s\n", $2.vStr);
    }

    else if ($2.vBool)
    {
      printf("t\n");
    }

    else
    {
      printf("nil\n");
    }

    $$.type = $2.type;
    $$.numParams = 0;
    $$.returnType = NOT_APPLICABLE;

    $$.vInt = $2.vInt;
    $$.vStr = $2.vStr;
    $$.vBool = $2.vBool;

  };

N_INPUT_EXPR:
  T_INPUT {
    string line;
    printRule("INPUT_EXPR", "input");

    $$.numParams = 0;
    $$.returnType = NOT_APPLICABLE;

    getline(cin, line);

    // if first char is '+', '-', or digit, it's an int
    if (isdigit(line[0]) || line[0] == '+' || line[0] == '-')
    {
      $$.type = INT;
      $$.vInt = atoi(line.c_str());
      $$.vStr = "";
    }

    else // it's a string
    {
      $$.type = STR;
      $$.vInt = 0;
      $$.vStr = line.c_str();
    }

    $$.vBool = true;

  };

N_EXPR_LIST:
  N_EXPR N_EXPR_LIST {
    printRule("EXPR_LIST", "EXPR EXPR_LIST");

    // is parameter
    $$.type = $2.type; // float type back up
    $$.numParams = $2.numParams + 1; // the EXPR adds one param
    $$.returnType = $2.returnType;

    $$.vInt = $2.vInt;
    $$.vStr = $2.vStr;
    $$.vBool = $2.vBool;

  }|
  N_EXPR {
    printRule("EXPR_LIST", "EXPR");

    // this is the last expr in the list
    // it's either a function parameter or a function call with no parameters
      // this is a function parameter
      // float type back up
    $$.type = $1.type;

    // this is the last parameter, so we have 1 so far
    $$.numParams = 1;

    // in any case, returnType is not used
    $$.returnType = NOT_APPLICABLE;

    $$.vInt = $1.vInt;
    $$.vStr = $1.vStr;
    $$.vBool = $1.vBool;

  };

N_BIN_OP:
  N_ARITH_OP {
    printRule("BIN_OP", "ARITH_OP");
    $$ = $1;
  }|
  N_LOG_OP {
    printRule("BIN_OP", "LOG_OP");
    $$ = $1;
  }|
  N_REL_OP {
    printRule("BIN_OP", "REL_OP");
    $$ = $1;
  };

N_ARITH_OP:
  T_MULT {
    printRule("ARITH_OP", "*");
    $$ = MULT;
  }|
  T_SUB {
    printRule("ARITH_OP", "-");
    $$ = SUB;
  }|
  T_DIV {
    printRule("ARITH_OP", "/");
    $$ = DIV;
  }|
  T_ADD {
    printRule("ARITH_OP", "+");
    $$ = ADD;
  };

N_LOG_OP:
  T_AND {
    printRule("LOG_OP", "and");
    $$ = AND;
  }|
  T_OR {
    printRule("LOG_OP", "or");
    $$ = OR;
  };

N_REL_OP:
  T_LT {
    printRule("REL_OP", "<");
    $$ = LT;
  }|
  T_GT {
    printRule("REL_OP", ">");
    $$ = GT;
  }|
  T_LE {
    printRule("REL_OP", "<=");
    $$ = LE;
  }|
  T_GE {
    printRule("REL_OP", ">=");
    $$ = GE;
  }|
  T_EQ {
    printRule("REL_OP", "=");
    $$ = EQ;
  }|
  T_NE {
    printRule("REL_OP", "/=");
    $$ = NE;
  };

N_UN_OP:
  T_NOT {
    printRule("UN_OP", "not");
    $$ = NOT;
  };

%%

#include "lex.yy.c"
extern FILE *yyin;
using namespace std;

void printRule(const char* lhs, const char* rhs)
{
  printf("%s -> %s\n", lhs, rhs);
  return;
}

int yyerror(const char* str)
{
  printf("Line %d: %s\n", numlines, str);

  return 1;
}

void printTokenInfo(const char* tokenType, const char* lexeme)
{
  printf("TOKEN: %s LEXEME: %s\n", tokenType, lexeme);
}


void beginScope()
{
  scopes.push(SymbolTable());
  printf("\n___Entering new scope...\n\n");
}

void endScope()
{
  scopes.pop();
  printf("\n___Exiting scope...\n\n");
}

bool variableDeclared(const string varName)
{

  if (scopes.empty())
  {
    return false;
  }

  bool found = scopes.top().has(varName);

  if (found)
  {
    return true;
  }

  else // we need to go deeper
  {
    // really don't like this we're copying and modifying data all over the place
    // should look for a custom stack or write one that doesn't require this level of hack
    SymbolTable symbolTable = scopes.top();
    scopes.pop();
    found = variableDeclared(varName);
    scopes.push(symbolTable);

    return found;
  }
}

// finds variable in closest scope
SymbolTableEntry getVariable(string varName)
{

  if (scopes.empty())
  {
    // ya done hecked up
    return SymbolTableEntry();
  }

  // get variable
  if (scopes.top().has(varName))
  {
    return scopes.top().get(varName);
  }

  else
  {
    // variable not found
    // we need to go deeper
    SymbolTableEntry entry;
    SymbolTable symbolTable = scopes.top();

    scopes.pop();
    entry = getVariable(varName);
    scopes.push(symbolTable);

    return entry;
  }

}

int main(int argc, char** argv)
{

  if (argc < 2)
  {
    printf("You must specify a file in the command line!\n");
    exit(1);
  }

  yyin = fopen(argv[1], "r");

  do
  {
    yyparse();
  }
  while (!feof(yyin));

  return 0;

}

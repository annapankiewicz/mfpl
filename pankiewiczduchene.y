%{

#include <iostream>
#include <stack>
#include <string>
#include <stdio.h>
#include "TypeInfo.h"
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

enum BinOpType
{
  ARITH_OP,
  LOG_OP,
  REL_OP
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
  TypeInfo typeInfo;
  BinOpType operation;
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
%type <typeInfo> N_CONST
%type <typeInfo> N_EXPR
%type <typeInfo> N_PARENTHESIZED_EXPR
%type <typeInfo> N_IF_EXPR
%type <typeInfo> N_ARITHLOGIC_EXPR
%type <typeInfo> N_LAMBDA_EXPR
%type <typeInfo> N_ID_LIST
%type <typeInfo> N_PRINT_EXPR
%type <typeInfo> N_INPUT_EXPR
%type <typeInfo> N_EXPR_LIST
%type <typeInfo> N_LET_EXPR
%type <operation> N_BIN_OP


%start N_START

%%

N_START:
  N_EXPR {
    printRule("START", "EXPR");
    printf("\n---- Completed parsing ----\n\n");
    return 0;
  };

N_EXPR:
  N_CONST {
    printRule("EXPR", "CONST");
    $$.type = $1.type;
    $$.numParams = $1.numParams;
    $$.returnType = $1.returnType;
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

    $$.type = entry.getTypeInfo().type;
    $$.numParams = entry.getTypeInfo().numParams;
    $$.returnType = entry.getTypeInfo().returnType;

  }|

  T_LPAREN N_PARENTHESIZED_EXPR T_RPAREN {
    printRule("EXPR", "( PARENTHESIZED_EXPR )");

    // float type back up
    $$.type = $2.type;
    $$.numParams = $2.numParams;
    $$.returnType = $2.returnType;
  };


N_CONST:
  T_INTCONST {
    printRule("CONST", "INTCONST");

    $$.type = INT;
    $$.numParams = 0;
    $$.returnType = NOT_APPLICABLE;
  }|
  T_STRCONST {
    printRule("CONST", "STRCONST");

    $$.type = STR;
    $$.numParams = 0;
    $$.returnType = NOT_APPLICABLE;
  }|
  T_T {
    printRule("CONST", "T");

    $$.type = BOOL;
    $$.numParams = 0;
    $$.returnType = NOT_APPLICABLE;
  }|
  T_NIL {
    printRule("CONST", "NIL");

    $$.type = BOOL;
    $$.numParams = 0;
    $$.returnType = NOT_APPLICABLE;
  };

N_PARENTHESIZED_EXPR:
  N_ARITHLOGIC_EXPR {
    printRule("PARENTHESIZED_EXPR", "ARITHLOGIC_EXPR");

    // float
    $$.type = $1.type;
    $$.numParams = $1.numParams;
    $$.returnType = $1.returnType;

  }|
  N_IF_EXPR {
    printRule("PARENTHESIZED_EXPR", "IF_EXPR");

    // float
    $$.type = $1.type;
    $$.numParams = $1.numParams;
    $$.returnType = $1.returnType;

  }|
  N_LET_EXPR {
    printRule("PARENTHESIZED_EXPR", "LET_EXPR");

    // float
    $$.type = $1.type;
    $$.numParams = $1.numParams;
    $$.returnType = $1.returnType;

  }|
  N_LAMBDA_EXPR {
    printRule("PARENTHESIZED_EXPR", "LAMBDA_EXPR");

    // float
    $$.type = $1.type;
    $$.numParams = $1.numParams;
    $$.returnType = $1.returnType;

  }|
  N_PRINT_EXPR {
    printRule("PARENTHESIZED_EXPR", "PRINT_EXPR");

    // float
    $$.type = $1.type;
    $$.numParams = $1.numParams;
    $$.returnType = $1.returnType;

  }|
  N_INPUT_EXPR {
    printRule("PARENTHESIZED_EXPR", "INPUT_EXPR");

    // float
    $$.type = $1.type;
    $$.numParams = $1.numParams;
    $$.returnType = $1.returnType;

  }|
  N_EXPR_LIST {
    printRule("PARENTHESIZED_EXPR", "EXPR_LIST");

    // float
    $$.type = $1.type;
    $$.numParams = $1.numParams;
    $$.returnType = $1.returnType;

  };

N_ARITHLOGIC_EXPR:
  N_UN_OP N_EXPR {
    printRule("ARITHLOGIC_EXPR", "UN_OP EXPR");

    // EXPR can't be a function
    if ($2.type == FUNCTION)
    {
      yyerror("Arg 1 cannot be function");
      YYABORT;
    }

    $$.type = BOOL; // end type is always bool, regardless of EXPR
    $$.numParams = 0;
    $$.returnType = NOT_APPLICABLE;

  }|
  N_BIN_OP N_EXPR N_EXPR {
    printRule("ARITHLOGIC_EXPR", "BIN_OP EXPR EXPR");
    // arithmetic operations EXPR must both be INT
    if ($1 == ARITH_OP)
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
    else if ($1 == REL_OP)
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

  };

N_IF_EXPR:
  T_IF N_EXPR N_EXPR N_EXPR {
    printRule("IF_EXPR", "IF EXPR EXPR EXPR");

    // no args can be functions
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

    else if ($4.type == FUNCTION)
    {
      yyerror("Arg 3 cannot be function");
      YYABORT;
    }

    // resulting type is a combination of the second/third exprs' types
    $$.type = Type($3.type | $4.type);

    $$.numParams = 0;
    $$.returnType = NOT_APPLICABLE;

  };

N_LET_EXPR:
  T_LETSTAR T_LPAREN N_ID_EXPR_LIST T_RPAREN N_EXPR {
    printRule("LET_EXPR", "let* ( ID_EXPR_LIST ) EXPR");

    endScope();

    // EXPR can't be function
    if ($5.type == FUNCTION)
    {
      yyerror("Arg 2 cannot be function");
      YYABORT;
    }

    // resulting type is EXPR's type
    $$.type = $5.type;
    $$.numParams = $5.numParams;
    $$.returnType = $5.returnType;

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

    // add to symbol table
    if ($4.type == FUNCTION)
    {
      scopes.top().add(SymbolTableEntry($3, $4.type, $4.numParams, $4.returnType));
    }

    else
    {
      scopes.top().add(SymbolTableEntry($3, $4.type));
    }


  };

N_LAMBDA_EXPR:
  T_LAMBDA T_LPAREN N_ID_LIST T_RPAREN N_EXPR
  {
    printRule("LAMBDA_EXPR", "lambda ( ID_LIST ) EXPR");

    endScope();

    // EXPR can't be function
    if ($5.type == FUNCTION)
    {
      yyerror("Arg 2 cannot be function");
      YYABORT;
    }

    $$.type = FUNCTION; // end type always a function
    $$.numParams = $3.numParams; // get number of params from ID_LIST
    $$.returnType = $5.type; // use EXPR type as function return type
  };

N_ID_LIST:
  {
    printRule("ID_LIST", "epsilon");

    $$.type = NOT_APPLICABLE;
    $$.numParams = 0;
    $$.returnType= NOT_APPLICABLE;

  }|
  N_ID_LIST T_IDENT
  {
    printRule("ID_LIST", "ID_LIST IDENT");
    printf("___Adding %s to symbol table\n", $2);

    // check if already declared in this scope
    if (scopes.top().has($2))
    {
      // already declared in this scope
      yyerror("Multiply defined identifier");
      YYABORT;
    }

    // add to symbol table
    // assume type is INT for now, as given in homework
    scopes.top().add(SymbolTableEntry($2, INT));

    $$.type = NOT_APPLICABLE;
    $$.numParams = $1.numParams + 1; // T_IDENT is a new param, so add 1
    $$.returnType = NOT_APPLICABLE;

  };

N_PRINT_EXPR:
  T_PRINT N_EXPR {
    printRule("PRINT_EXPR", "print EXPR");

    // can't print a function
    if ($2.type == FUNCTION)
    {
      yyerror("Arg 1 cannot be function");
      YYABORT;
    }

    $$.type = $2.type;
    $$.numParams = 0;
    $$.returnType = NOT_APPLICABLE;

  };

N_INPUT_EXPR:
  T_INPUT {
    printRule("INPUT_EXPR", "input");

    $$.type = INT_OR_STR; // input always either int or str
    $$.numParams = 0;
    $$.returnType = NOT_APPLICABLE;

  };

N_EXPR_LIST:
  N_EXPR N_EXPR_LIST {
    printRule("EXPR_LIST", "EXPR EXPR_LIST");

    // EXPR can't be a function
    if ($2.type == FUNCTION)
    {
      yyerror("Arg 2 cannot be function");
      YYABORT;
    }

    /**
     * The above line blocks functions, but it's a bit deceiving.
     * Note that mfpl will call any functions in this list,
     * so the resulting type for that expr is not FUNCTION, but instead
     * the function's return type.
     *
     * This line above essentially prevents the user from placing a lambda
     * declaration in the middle of the expr list.
     */


    // this EXPR is either a function call or a parameter
    // find out which
    if ($1.type == FUNCTION)
    {
      // is function
      // check that the call has the correct number of params
      if ($2.numParams < $1.numParams)
      {
        yyerror("Too few parameters in function call");
        YYABORT;
      }

      else if ($2.numParams > $1.numParams)
      {
        yyerror("Too many parameters in function call");
        YYABORT;
      }

      // as mentioned above, this function will be called at runtime
      // resulting type is not FUNCTION, but instead function's return type
      $$.type = $1.returnType;

      $$.numParams = $2.numParams; // float params
    }

    else
    {
      // is parameter
      $$.type = $2.type; // float type back up
      $$.numParams = $2.numParams + 1; // the EXPR adds one param
    }


    $$.returnType = $2.returnType;

  }|
  N_EXPR {
    printRule("EXPR_LIST", "EXPR");

    // this is the last expr in the list
    // it's either a function parameter or a function call with no parameters

    // check if this expr is a function
    if ($1.type == FUNCTION)
    {
      // mfpl will call this function at runtime
      // resulting type is not FUNCTION, but instead function's return type
      $$.type = $1.returnType;

      // the EXPR is the function name with no other params
      $$.numParams = 0;
    }

    else
    {
      // this is a function parameter
      // float type back up
      $$.type = $1.type;

      // this is the last parameter, so we have 1 so far
      $$.numParams = 1;
    }

    // in any case, returnType is not used
    $$.returnType = NOT_APPLICABLE;

  };

N_BIN_OP:
  N_ARITH_OP {
    printRule("BIN_OP", "ARITH_OP");
    $$ = ARITH_OP;
  }|
  N_LOG_OP {
    printRule("BIN_OP", "LOG_OP");
    $$ = LOG_OP;
  }|
  N_REL_OP {
    printRule("BIN_OP", "REL_OP");
    $$ = REL_OP;
  };

N_ARITH_OP:
  T_MULT {
    printRule("ARITH_OP", "*");
  }|
  T_SUB {
    printRule("ARITH_OP", "-");
  }|
  T_DIV {
    printRule("ARITH_OP", "/");
  }|
  T_ADD {
    printRule("ARITH_OP", "+");
  };

N_LOG_OP:
  T_AND {
    printRule("LOG_OP", "and");
  }|
  T_OR {
    printRule("LOG_OP", "or");
  };

N_REL_OP:
  T_LT {
    printRule("REL_OP", "<");
  }|
  T_GT {
    printRule("REL_OP", ">");
  }|
  T_LE {
    printRule("REL_OP", "<=");
  }|
  T_GE {
    printRule("REL_OP", ">=");
  }|
  T_EQ {
    printRule("REL_OP", "=");
  }|
  T_NE {
    printRule("REL_OP", "/=");
  };

N_UN_OP:
  T_NOT {
    printRule("UN_OP", "not");
  };

%%

#include "lex.yy.c"
extern FILE *yyin;

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


int main()
{
  do
  {
    yyparse();
  }
  while (!feof(yyin));

  return 0;

}

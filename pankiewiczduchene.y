%{

#include <stack>
#include <stdio.h>
#include "SymbolTable.h"

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

// deep-checks scopes to see if variable exists
// TODO: is variable shadowing allowed?
bool variableDeclared(const string varName);

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
  }|

  T_IDENT {
    printRule("EXPR", "IDENT");
    bool found = variableDeclared(string($1));
    if (!found)
    {
      yyerror("Undefined identifier");
      YYABORT;
    }
  }|

  T_LPAREN N_PARENTHESIZED_EXPR T_RPAREN {
    printRule("EXPR", "( PARENTHESIZED_EXPR )");
  };

N_CONST:
  T_INTCONST {
    printRule("CONST", "INTCONST");
  }|
  T_STRCONST {
    printRule("CONST", "STRCONST");
  }|
  T_T {
    printRule("CONST", "T");
  }|
  T_NIL {
    printRule("CONST", "NIL");
  };

N_PARENTHESIZED_EXPR:
  N_ARITHLOGIC_EXPR {
    printRule("PARENTHESIZED_EXPR", "ARITHLOGIC_EXPR");
  }|
  N_IF_EXPR {
    printRule("PARENTHESIZED_EXPR", "IF_EXPR");
  }|
  N_LET_EXPR {
    printRule("PARENTHESIZED_EXPR", "LET_EXPR");
  }|
  N_LAMBDA_EXPR {
    printRule("PARENTHESIZED_EXPR", "LAMBDA_EXPR");
  }|
  N_PRINT_EXPR {
    printRule("PARENTHESIZED_EXPR", "PRINT_EXPR");
  }|
  N_INPUT_EXPR {
    printRule("PARENTHESIZED_EXPR", "INPUT_EXPR");
  }|
  N_EXPR_LIST {
    printRule("PARENTHESIZED_EXPR", "EXPR_LIST");
  };

N_ARITHLOGIC_EXPR:
  N_UN_OP N_EXPR {
    printRule("ARITHLOGIC_EXPR", "UN_OP EXPR");
  }|
  N_BIN_OP N_EXPR N_EXPR {
    printRule("ARITHLOGIC_EXPR", "BIN_OP EXPR EXPR");
  };

N_IF_EXPR:
  T_IF N_EXPR N_EXPR N_EXPR {
    printRule("IF_EXPR", "IF EXPR EXPR EXPR");
  };

N_LET_EXPR:
  T_LETSTAR T_LPAREN N_ID_EXPR_LIST T_RPAREN N_EXPR {
    printRule("LET_EXPR", "let* ( ID_EXPR_LIST ) EXPR");
    endScope();
  };

N_ID_EXPR_LIST:
  {
    printRule("ID_EXPR_LIST", "epsilon");
  }|
  N_ID_EXPR_LIST T_LPAREN T_IDENT N_EXPR T_RPAREN {
    printRule("ID_EXPR_LIST", "ID_EXPR_LIST ( IDENT EXPR )");
    printf("___Adding %s to symbol table\n", $3);

    if (scopes.top().has($3))
    {
      yyerror("Multiply defined identifier");
      YYABORT;
    }

    scopes.top().add(SymbolTableEntry($3, UNDEFINED));
  };

N_LAMBDA_EXPR:
  T_LAMBDA T_LPAREN N_ID_LIST T_RPAREN N_EXPR {
    printRule("LAMBDA_EXPR", "lambda ( ID_LIST ) EXPR");
    endScope();
  };

N_ID_LIST:
  {
    printRule("ID_LIST", "epsilon");
  }|
  N_ID_LIST T_IDENT
  {
    printRule("ID_LIST", "ID_LIST IDENT");
    printf("___Adding %s to symbol table\n", $2);

    if (scopes.top().has($2))
    {
      yyerror("Multiply defined identifier");
      YYABORT;
    }

    scopes.top().add(SymbolTableEntry($2, UNDEFINED));
  };

N_PRINT_EXPR:
  T_PRINT N_EXPR {
    printRule("PRINT_EXPR", "PRINT EXPR");
  };

N_INPUT_EXPR:
  T_INPUT {
    printRule("INPUT_EXPR", "INPUT");
  };

N_EXPR_LIST:
  N_EXPR N_EXPR_LIST {
    printRule("EXPR_LIST", "EXPR EXPR_LIST");
  }|
  N_EXPR {
    printRule("EXPR_LIST", "EXPR");
  };

N_BIN_OP:
  N_ARITH_OP {
    printRule("BIN_OP", "ARITH_OP");
  }|
  N_LOG_OP {
    printRule("BIN_OP", "LOG_OP");
  }|
  N_REL_OP {
    printRule("BIN_OP", "REL_OP");
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


int main()
{
  do
  {
    yyparse();
  }
  while (!feof(yyin));

  return 0;

}

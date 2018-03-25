%{

%}

LETSTAR       let\*
INPUT         "input"
PRINT         "print"
IF            "if"
LPAREN        \(
RPAREN        \)
T             "t"
NIL           "nil"
AND           "and"
OR            "or"
NOT           "not"

ADD           \+
MULT          \*
DIV           \/
SUB           \-
LT            \<
GT            \>
LE            \<\=
GE            \>\=
EQ            \=
NE            \/\=

NEWLINE       \n
WSPACE        [ \t\r]+
LETTER        [a-zA-Z]
DIGIT         [0-9]

IDENT         ({LETTER}|_)({LETTER}|{DIGIT}|_)*
INTCONST      [\-+]?{DIGIT}+
STRCONST      \"(\\.|[^"\n])*\"
COMMENT       ";".*

%%

{LETSTAR} {
  printTokenInfo("LETSTAR", yytext);
  beginScope();
  return T_LETSTAR;
}

{INPUT} {
  printTokenInfo("INPUT", yytext);
  return T_INPUT;
}

{PRINT} {
  printTokenInfo("PRINT", yytext);
  return T_PRINT;
}

{IF} {
  printTokenInfo("IF", yytext);
  return T_IF;
}

{LPAREN} {
  printTokenInfo("LPAREN", yytext);
  return T_LPAREN;
}

{RPAREN} {
  printTokenInfo("RPAREN", yytext);
  return T_RPAREN;
}

{ADD} {
  printTokenInfo("ADD", yytext);
  return T_ADD;
}

{MULT} {
  printTokenInfo("MULT", yytext);
  return T_MULT;
}

{DIV} {
  printTokenInfo("DIV", yytext);
  return T_DIV;
}

{SUB} {
  printTokenInfo("SUB", yytext);
  return T_SUB;
}

{AND} {
  printTokenInfo("AND", yytext);
  return T_AND;
}

{OR} {
  printTokenInfo("OR", yytext);
  return T_OR;
}

{NOT} {
  printTokenInfo("NOT", yytext);
  return T_NOT;
}

{LT} {
  printTokenInfo("LT", yytext);
  return T_LT;
}

{GT} {
  printTokenInfo("GT", yytext);
  return T_GT;
}

{LE} {
  printTokenInfo("LE", yytext);
  return T_LE;
}

{GE} {
  printTokenInfo("GE", yytext);
  return T_GE;
}

{EQ} {
  printTokenInfo("EQ", yytext);
  return T_EQ;
}

{NE} {
  printTokenInfo("NE", yytext);
  return T_NE;
}

{T} {
  printTokenInfo("T", yytext);
  return T_T;
}

{NIL} {
  printTokenInfo("NIL", yytext);
  return T_NIL;
}

{IDENT} {
  printTokenInfo("IDENT", yytext);
  yylval.text = strdup(yytext);
  return T_IDENT;
}

{INTCONST} {
  printTokenInfo("INTCONST", yytext);
  yylval.intconst = atoi(yytext);
  return T_INTCONST;
}

{STRCONST} {
  printTokenInfo("STRCONST", yytext);
  yylval.strconst = strdup(yytext);
  return T_STRCONST;
}

{NEWLINE} {
  numlines++;
}

{WSPACE} { }

{COMMENT} { }

. {
  printTokenInfo("UNKNOWN", yytext);
  return T_UNKNOWN;
}

%%

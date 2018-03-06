%{
#include <cstdlib>
#include <string>
#include "driver.hh"
#include "parser.hh"
#include "lexer.hh"

#define YY_NO_UNISTD_H

#undef YY_DECL
#define YY_DECL AnASM::Parser::symbol_type AnASM::Lexer::yylex(AnASM::Driver &driver)

#undef yywrap
#define yywrap() 1

static AnASM::location loc;
%}

%option yyclass="AnASM::Lexer"
%option c++
%option noyywrap nounput batch debug noinput

%{
  #define YY_USER_ACTION loc.columns(yyleng);
%}

delimiter  [ \t]
whitespace {delimiter}+
digit      [0-9]
alpha      [a-zA-Z]
alphanum   [a-zA-Z0-9]
integer    [-]?[1-9]{digit}*
register   [rR]{digit}+
identifier [a-zA-Z_][a-zA-Z0-9_]*

%%
%{
  loc.step();
%}

{register}  { return AnASM::Parser::make_REGISTER(atoi(yytext + 1), loc); }
{integer}   { return AnASM::Parser::make_INTEGER(atoi(yytext), loc); }

,         { return AnASM::Parser::make_COMMA(loc); }
:         { return AnASM::Parser::make_COLON(loc); }

"LOAD"    { return AnASM::Parser::make_LOAD(loc); }
"ADD"     { return AnASM::Parser::make_ADD(loc); }
"OUT"     { return AnASM::Parser::make_OUT(loc); }
"HALT"    { return AnASM::Parser::make_HALT(loc); }
<<EOF>>   { return AnASM::Parser::make_END(loc); }

{whitespace} { loc.step(); }
\n           { loc.lines(yyleng); loc.step(); return AnASM::Parser::make_NEWLINE(loc); }

%%


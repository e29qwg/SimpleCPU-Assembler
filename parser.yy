%skeleton "lalr1.cc"
%require "3.0.4"
%defines
%define api.namespace {AnASM}
%define parser_class_name {Parser}
%define api.token.constructor
%define api.value.type variant
%define parse.assert

%code requires
{
#include <iostream>
#include <string>

namespace AnASM
{
  class Driver;
  class Lexer;
}
}

%param { AnASM::Driver &driver }

%locations

%initial-action
{
  @$.begin.filename = @$.end.filename = &driver.file;
};

%define parse.trace
%define parse.error verbose

%code
{
#include "driver.hh"
#include "lexer.hh"

#undef yylex
#define yylex driver.lexer->yylex
}

%define api.token.prefix {TOK_}

%token
  END 0 "end of file"
  NEWLINE "new line"
  COMMA "comma"
  COLON "colon"

/* CPU Mnemonics */
%token
  LOAD  "LOAD"
  ADD   "ADD"
  SUB   "SUB"
  OR    "OR"
  XOR   "XOR"
  BRA   "BRA"
  BRAZ  "BRAZ"
  BRAL  "BRAL"
  BRALZ "BRALZ"
  CALL  "CALL"
  IN    "IN"
  OUT   "OUT"
  HALT  "HALT"

%token <int> REGISTER "register"
%token <int> INTEGER "integer"
%token <std::string> IDENTIFIER "identifier"

%printer { yyoutput << $$; } <*>;

%%
%start program;

program: END
       | statements END
       ;

statements: statement
          | statements statement
          ;

statement: LOAD REGISTER COMMA INTEGER {
             std::cout << "R" << $2 << " <- " << $4 << std::endl; }
         | ADD REGISTER COMMA REGISTER COMMA REGISTER { 
             std::cout << "R" << $2 << " <- " <<
                          "R" << $4 << " + R" << $6 << std::endl; }
         | SUB REGISTER COMMA REGISTER COMMA REGISTER
         | OR REGISTER COMMA REGISTER COMMA REGISTER
         | XOR REGISTER COMMA REGISTER COMMA REGISTER
         | BRA REGISTER
         | BRAZ REGISTER COMMA REGISTER
         | BRAL INTEGER
         | BRAL IDENTIFIER
         | BRALZ REGISTER COMMA INTEGER
         | BRALZ REGISTER COMMA IDENTIFIER
         | CALL REGISTER COMMA INTEGER
         | CALL REGISTER COMMA IDENTIFIER
         | IN REGISTER
         | OUT REGISTER { 
             std::cout << "OUT R" << $2 << std::endl; }
         | HALT { std::cout << "HALT" << std::endl; }
         | IDENTIFIER COLON
         | NEWLINE
         ;

%%

void AnASM::Parser::error(const location_type &l, const std::string &m)
{
  driver.error(*(driver.loc), m);
}


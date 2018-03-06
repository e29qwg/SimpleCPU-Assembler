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

%parse-param { AnASM::Lexer &lexer }
%param { AnASM::Driver &driver }

%locations

%initial-action
{
  // @$.begin.filename = @$.end.filename = &driver.file;
};

%define parse.trace
%define parse.error verbose

%code
{
#include "driver.hh"
#include "lexer.hh"

#undef yylex
#define yylex lexer.yylex
}

%define api.token.prefix {TOK_}

%token
  END 0 "end of file"
  NEWLINE "new line"
  COMMA "comma"
  COLON "colon"
  LOAD  "LOAD"
  ADD   "ADD"
  OUT   "OUT"
  HALT  "HALT"

%token <int> REGISTER "register"
%token <int> INTEGER "integer"

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
         | OUT REGISTER { 
             std::cout << "OUT R" << $2 << std::endl; }
         | HALT { std::cout << "HALT" << std::endl; }
         | NEWLINE
         ;

%%

void AnASM::Parser::error(const location_type &l, const std::string &m)
{
  driver.error(l, m);
}


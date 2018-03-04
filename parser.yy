%skeleton "lalr1.cc" /* -*- C++ -*- */
%require "3.0.4"
%defines
%define api.namespace {AnASM}
%define parser_class_name {Parser}

/* Debugging */
%verbose
%define parse.trace

%parse-param { Lexer &lexer }
/* %parse-param { Driver &driver } */

%define api.value.type variant
/* %define parse.assert */

%locations

%code requires{
  namespace AnASM {
    // class Driver;
    class Lexer;
  }

// The following definitions is missing when %locations isn't used
# ifndef YY_NULLPTR
#  if defined __cplusplus && 201103L <= __cplusplus
#   define YY_NULLPTR nullptr
#  else
#   define YY_NULLPTR 0
#  endif
# endif

}

%{
#include <iostream>
#include <string>
#include "lexer.hh"

// TODO: Construct a symbol hash map

#undef yylex
#define yylex lexer.yylex
%}

/* General Tokens */
%token END 0 "end of file"
%token NEWLINE COMMA COLON IDENTIFIER
%token <int> REGISTER
%token <int> INTEGER

/* CPU Mnemonic Tokens */
%token LOAD ADD OUT HALT

%printer { yyoutput << $$; } <*>;

%%

%start program;

program: END
       | line END
       ;

line: statement
    | line statement
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
  std::cerr << l << ": " << m << std::endl;
}

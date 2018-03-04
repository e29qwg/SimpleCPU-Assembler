#include <iostream>
#include "parser.hh"
#include "lexer.hh"

using namespace std;

int main()
{
  AnASM::Lexer lexer(&cin);
  AnASM::Parser parser(lexer);

  // Un-comment the following line for parser debugging
  // parser.set_debug_level(1);

  int result = parser.parse();

  exit(EXIT_SUCCESS);
}


# miniC Compiler
This repository contains my work for COSC 57-Compilers at Dartmouth with Professor Vasanta Komminen. Here, I am building a compiler for a minimized version of C, called miniC.

As it stands now, I have built the syntax and semantic analyzers. The syntax analyzer is complete. The semantic analyzer, while functional, contains memory leaks.

## miniC
A complete description of the language can be found in [sample_miniC.c](https://github.com/majdh98/miniC-Compiler/blob/main/sample_miniC.c) and examples of miniC can be found in [syntax_analyzer/miniC](https://github.com/majdh98/miniC-Compiler/tree/main/syntax_analyzer/miniC). In general, a miniC code includes:
- A single function definition
- All local variables and parameters are integers. Return value of the function is also an integer.
- Two extern function declarations for print and read.
- All local variables are declared at the beginning of a code block.
- All arithmetic operations will have only 2 operands.
- Arithmetic operations that are allowed are: +, -, *, /.
- Conditions in if and while statements will use only  >, <, ==, >=, <= operators. No logical operators (&&, ||, !) are used.

## Content
- [syntax_analyzer](https://github.com/majdh98/miniC-Compiler/tree/main/syntax_analyzer): A syntax analyzer of miniC. Will output a syntax error if a file.c is not following the rules of miniC. Uses lex to build the DFA that identifies the tokens and yacc to augment the DFA with a stack.
- [semantic_analyzer](https://github.com/majdh98/miniC-Compiler/tree/main/semantic_analyzer): A semantic analyzer of miniC. Currently, identifies if a variable is used before it is defined. Uses a lex and a yacc file for syntax, ast.c and ast.h to build the Abstract Syntax Tree (AST), and uses semantic_analyzer.h and semantic_analyzer.c to walk the tree.

win_flex lexer.l
clang++ .\lex.yy.cc -std=c++20 -IC:\ProgramData\chocolatey\lib\winflexbison3\tools\ -o DRIPc.exe


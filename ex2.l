%{
#include <stdio.h>

%}

SPECIAL_CHAR    [:;]

%%

[!@#$%\^&*\(\)] { printf("caracter especial %s\n", yytext); }

"do"        |
"while"     | 
"for"       | 
"if"        | 
"else"      |
"switch"    |
"case"      |
"break"     |
"continue"  |
"default"   |
"goto"      |
"struct"    |
"enum"      |
"union"     { printf("palavra reservada: %s\n", yytext); }

.           { printf("erro: %s\n", yytext); }

%%

int yywrap(){
    return 1;
}

int main() {
    yylex();

    return 0;
}
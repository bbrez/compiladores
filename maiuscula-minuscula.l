%{
#include <stdio.h>

int maiusculas = 0, minusculas = 0;
%}

%%

[a-z]   { printf("letra minuscula\n"); minusculas++; }
[A-Z]   { printf("letra maiuscula\n"); maiusculas++; }

%%

int yywrap() {
    printf("Maiusculas: %d\n", maiusculas);
    printf("Minusculas: %d\n", minusculas);
    return 1;
}

int main() {
    printf("Digite uma palavra\n");
    yylex();

    return 0;
}
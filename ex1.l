%{
#include <stdio.h>

%}

WHITESPACE  [ \t]+
NEWLINE     [\n(\r\n)]
ID          [[:alpha:]][[:alnum:]_]*

%%

"a"[a-z]*"a"      printf("regra a: %s\n", yytext); 
[1-9][0-9]*       printf("regra b: %s\n", yytext);
[0-9]*[02468]     printf("regra c: %s\n", yytext);
WHITESPACE        { ;; }
.                 printf("não identificado: %s", yytext);

%%

int yywrap() {
    return 1;
}

int main() {
    printf("Digite uma palavra\n");
    yylex();

    return 0;
}
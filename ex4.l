%option noyywrap

%{
#include <stdio.h>

%}

digito [0-9]
ddd    \(0?{digito}{2}\)
antigo  {ddd}?\ ?{digito}{4}-?{digito}{4}
novo    {ddd}?\ ?9{digito}{4}-?{digito}{4}

%%

{novo}      { printf("numero novo: %s", yytext); }
{antigo}    { printf("numero antigo: %s", yytext); }

%%

int main() {
    yylex();

    return 0;
}
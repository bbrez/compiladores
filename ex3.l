%option noyywrap

%{
#include <stdio.h>

//{alpha}      { printf("letra: %s\n", yytext); }
//{digito}    { printf("digito: %s\n", yytext); }
%}

branco      [ \t]
alpha       [A-Za-z]
digito      [0-9]
num_nat     {digito}+
num_int     [+-]{digito}+
num_real    [+-]?{digito}+"."{digito}+
ident       {alpha}({alpha}|{digito}|_|\$)*
op_aritm    (\+|\-|\*|\/|\%)
op_log_b    (&|\||^)
op_log      (&&|\|\|)
op_rel      (>|<|==|<=|>=|!=)

%%

{ident}     { printf("identificador: %s\n", yytext); }
{num_real}  { printf("num_real: %s\n", yytext); }
{num_int}   { printf("num_inteiro: %s\n", yytext); }
{num_nat}   { printf("num_nat: %s\n", yytext); }
{op_aritm}  { printf("op_aritm: %s\n", yytext); }
{op_log}    { printf("op_log: %s\n", yytext); }
{op_log_b}  { printf("op_log_b: %s\n", yytext); }
{op_rel}    { printf("op_rel: %s\n", yytext); }

{branco}    { ; }
.           { printf("deu ruim: %s\n", yytext); }

%%

int main() {
    yylex();

    return 0;
}
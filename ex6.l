%option c++
%option noyywrap

%{
#include <iostream>
#include <fstream>
#include <format>

//{alpha}      { printf("letra: %s\n", yytext); }
//{digito}    { printf("digito: %s\n", yytext); }
%}

branco      [ \t]
alpha       [A-Za-z]
digito      [0-9]
num_nat     {digito}+
num_int     [+-]{digito}+
num_real    [+-]?{digito}+"."{digito}+
ident       ({alpha}|_)({alpha}|{digito}|_|\$)*
op_aritm    (\+|\-|\*|\/|\%)
op_log_b    (&|\||^)
op_log      (&&|\|\|)
op_rel      (>|<|==|<=|>=|!=)

%%

{ident}     { std::cout << std::format("identificador: {}\n", yytext); }
{num_real}  { std::cout << std::format("num_real: {}\n", yytext); }
{num_int}   { std::cout << std::format("num_inteiro: {}\n", yytext); }
{num_nat}   { std::cout << std::format("num_nat: {}\n", yytext); }
{op_aritm}  { std::cout << std::format("op_aritm: {}\n", yytext); }
{op_log}    { std::cout << std::format("op_log: {}\n", yytext); }
{op_log_b}  { std::cout << std::format("op_log_b: {}\n", yytext); }
{op_rel}    { std::cout << std::format("op_rel: {}\n", yytext); }

{branco}    { ; }
.           { std::cout << std::format("deu ruim: {}\n", yytext); }

%%

int main(int argc, const char* argv[]) {
    yyFlexLexer *lexer;
    if(argc > 1){
        std::ifstream arquivo(argv[1]);
        lexer = new yyFlexLexer(&arquivo);
    } else {
        lexer = new yyFlexLexer(std::cin);
    }

    while(lex.yylex());
    delete lexer;

    return 0;
}
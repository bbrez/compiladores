%option c++
%option noyywrap
%option warn
%option nodefault
%option nounistd

%{
#include <iostream>
#include <fstream>
#include <format>
#include <string>
#include <vector>
#include <map>
#include <optional>

const bool DEBUG = false;

enum class TokenCategory {
    Keyword,
    Operator,
    Constant,
    Function,
    Variable,

    INVALID,
};

const char *CategoryString(TokenCategory tc) {
    return (const char*[]) {
        "Keyword",
        "Operator",
        "Constant",
        "Function",
        "Variable",
        ""
    }[static_cast<int>(tc)];
}

std::vector<std::tuple<std::string, TokenType, TokenCategory>> keywords = {
    {"for", TokenType::TkFor, TokenCategory::Keyword},
    {"if", TokenType::TkIf, TokenCategory::Keyword},
    {"while", TokenType::TkWhile, TokenCategory::Keyword},
    {"else", TokenType::TkElse, TokenCategory::Keyword},
    {"return", TokenType::TkReturn, TokenCategory::Keyword},
    {"int", TokenType::TkInt, TokenCategory::Keyword},

    {"+", TokenType::TkPlus, TokenCategory::Operator},
    {"-", TokenType::TkMinus, TokenCategory::Operator},
    {"*", TokenType::TkMult, TokenCategory::Operator},
    {"/", TokenType::TkDiv, TokenCategory::Operator},
    {"%", TokenType::TkMod, TokenCategory::Operator},

    {"~", TokenType::TkBNot, TokenCategory::Operator},
    {"|", TokenType::TkBOr, TokenCategory::Operator},
    {"&", TokenType::TkAnd, TokenCategory::Operator},
    {"^", TokenType::TkBXor, TokenCategory::Operator},

    {"!", TokenType::TkNot, TokenCategory::Operator},
    {"||", TokenType::TkOr, TokenCategory::Operator},
    {"&&", TokenType::TkAnd, TokenCategory::Operator},
    
    {"==", TokenType::TkEq, TokenCategory::Operator},
    {"!=", TokenType::TkNeq, TokenCategory::Operator},
    {">", TokenType::TkGt, TokenCategory::Operator},
    {"<", TokenType::TkLt, TokenCategory::Operator},
    {">=", TokenType::TkGe, TokenCategory::Operator},
    {"<=", TokenType::TkLe, TokenCategory::Operator}
};

struct Token {
    enum class TokenType {
        TkPv, // ;

        TkFor, // for
        TkIf, // if
        TkWhile, // while
        TkElse, // else
        TkReturn, // return
        TkInt, // int

        TkPlus, // +
        TkMinus, // -
        TkMult, // *
        TkDiv, // /
        TkMod, // %

        TkBNot, // ~
        TkBOr, // |
        TkBAnd, // &
        TkBXor, // ^

        TkNot, // !
        TkOr, // ||
        TkAnd, // &&

        TkEq, // ==
        TkNeq, // !=
        TkGt, // >
        TkLt, // <
        TkGe, // >=
        TkLe, // <=

        Id,
        Float,
        Int,
        OpAritm,
        OpLogB,
        OpLog,
        OpRel,

        INVALID,
    };

const char *TokenString(TokenType tt){
    return (const char*[]) {
        "TkPv",

        "TkFor",
        "TkIf",
        "TkWhile",
        "TkElse",
        "TkReturn",
        "TkInt",

        "TkPlus",
        "TkMinus",
        "TkMult",
        "TkDiv",
        "TkMod",

        "TkBNot",
        "TkBOr",
        "TkBAnd",
        "TkBXor",

        "TkNot",
        "TkOr",
        "TkAnd",

        "TkEq",
        "TkNeq",
        "TkGt",
        "TkLt",
        "TkGe",
        "TkLe",

        "Id",
        "Float",
        "Int",
        "OpAritm",
        "OpLogB",
        "OpLog",
        "OpRel",

        ""
    }[static_cast<int>(tt)];
}



    Token(std::string name, TokenType tt, TokenCategory tc):
        name(name), type(tt), category(tc) {}

    std::string name;
    TokenType type;
    TokenCategory category;
};

class SymbolTable {
public:

    std::optional<Token> find(const std::string& token) {
        if(table.count(token)) {
            return table.at(token);
        }
        return {};
    }

    void insert(const std::string& token, TokenType tt, TokenCategory tc) {
        this->table.emplace(std::make_pair(token, Token(token, tt, tc)));
    }

    void remove(const std::string& token) {
        this->table.erase(token);
    }


    std::map<std::string, Token> table;
};

SymbolTable TabelaSimbolos;
%}

branco    [ \t]
fim_linha (\n|\n\r|\r)
alpha     [A-Za-z]
digito    [0-9]
num_nat   {digito}+
num_int   [+-]?{num_nat}
num_real  {num_int}(\.{num_nat})?
ident     ({alpha}|_)({alpha}|{digito}|_)*
op_aritm  (\+|\-|\*|\/|\%)
op_log_b  (&|\||^)
op_log    (&&|\|\|\!|\~)
op_rel    (>|<|==|<=|>=|!=)

%%

"int"   |
"for"   |
"if"    |
"while" |
"else"  |
"return"    {
                if(DEBUG) std::cout << std::format("Keyword: {}\n", YYText());
            }

{num_nat}   {
                if(DEBUG) std::cout << std::format("num_natural: {}\n", YYText());
                if(!TabelaSimbolos.find(YYtext())) {
                    TabelaSimbolos.insert(YYtext(), TokenType::Int, TokenCategory::Constant);
                }
            }

{num_int}   {
                if(DEBUG) std::cout << std::format("num_inteiro: {}\n", YYtext());
                if(!TabelaSimbolos.find(YYtext())) {
                    TabelaSimbolos.insert(YYtext(), TokenType::Int, TokenCategory::Constant);
                }
            }

{num_real}  {   
                if(DEBUG) std::cout << std::format("num_real: {}\n", YYtext());
                if(!TabelaSimbolos.find(YYtext())) {
                    TabelaSimbolos.insert(YYtext(), TokenType::Float, TokenCategory::Constant);
                }
            }

{op_aritm}  {
                if(DEBUG) std::cout << std::format("op_aritm: {}\n", YYtext());
            }

{op_log_b}  {
                if(DEBUG) std::cout << std::format("op_log_b: {}\n", YYtext());
            }

{op_log}    {
                if(DEBUG) std::cout << std::format("op_log: {}\n", YYtext());
            }

{op_rel}    {
                if(DEBUG) std::cout << std::format("op_rel: {}\n", YYtext());
            }

{ident}     { 
                if(DEBUG) std::cout << std::format("identificador: {}\n", YYtext());
                if(!TabelaSimbolos.find(YYtext())) {
                    TabelaSimbolos.insert(YYtext(), TokenType::Id, TokenCategory::INVALID);
                }
            }

{branco}    |
{fim_linha} |
";"         { ; }

.           { std::cout << std::format("Token não reconhecido: {}\n", YYtext()); }

%%

auto findMaxTokenWidth(const SymbolTable &ts) {
    auto aux = 6;

    for(auto& sim: ts.table){
        if(sim.first.length() > aux) {
            aux = sim.first.length();
        }
    }

    return aux;
}

void printSymbolTable(const SymbolTable &ts){
    auto maxTokenWidth = findMaxTokenWidth(ts);

    std::cout << "Tabela de Simbolos:\n";
    std::cout << std::format("┌{:─<3}┬{:─<{}}┬{:─<9}┬{:─<8}┐\n", "", "", maxTokenWidth, "", "");
    std::cout << std::format("│{:3}│{:{}}│{:^9}│{:^8}│\n", "Num", "Cadeia", maxTokenWidth, "Token", "Tipo");
    std::cout << std::format("├{:─<3}┼{:─<{}}┼{:─<9}┼{:─<8}┤\n", "", "", maxTokenWidth, "", "");

    int i = 0;
    for(const auto& sim: ts.table) {
        auto token = sim.second;
        std::cout << std::format("│{:3}│{:{}}│{:^9}│{:^8}│\n", i, token.name, maxTokenWidth, TokenString(token.type), CategoryString(token.category));
        i += 1;
    }

    std::cout << std::format("└{:─<3}┴{:─<{}}┴{:─<9}┴{:─<8}┘\n", "", "", maxTokenWidth, "", "");
}

auto main(int argc, const char* argv[]) -> int {

    for(const auto& kw: keywords){
        auto [name, tt, tc] = kw;
        TabelaSimbolos.insert(name, tt, tc);
    }

    yyFlexLexer *lexer = nullptr;
    std:: ifstream *arquivo = nullptr;

    //se foi passado arquivo como argumento, utiliza
    if(argc > 1){
        arquivo = new std::ifstream(argv[1]);
        lexer = new yyFlexLexer(arquivo);
    } else { //se não usa entrada padrão
        lexer = new yyFlexLexer(&std::cin);
    }

    //roda o analisador léxico
    while(lexer->yylex());

    //Fecha o arquivo se estava aberto
    if(arquivo->is_open()){
        arquivo->close();
        delete arquivo;
    }

    delete lexer;

    printSymbolTable(TabelaSimbolos);

    return 0;
}

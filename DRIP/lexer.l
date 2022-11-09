%option c++
%option warn

%option yylineno
%option noyywrap

%option nodefault
%option nounistd

%{
#include <iostream>
#include <fstream>
#include <string>
#include <optional>
#include <string>
#include <map>
#include <vector>
#include <format>
#include <ranges>

namespace Console {
    const auto color_rst = "\e[0m";
    const auto color_warn = "\e[93m";
    const auto color_error = "\e[91m";
}

namespace Options {
    bool showHelp = false;

    bool printKwTable = false;
    bool printTkTable = false;
    bool printTkMatch = false;

    bool printErrorMatch = false;
};

enum class TokenType {
    TkPv, // ;
    TkVir, // ,
    TkAPar, // (
    TkFPar, // )
    TkACh, // {
    TkFCh, // }
    TkACol, // [
    TkFCol, // ]

    TkAtrib, // =
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

    TkFor, // for
    TkIf, // if
    TkWhile, // while
    TkElse, // else
    TkReturn, // return
    TkIntConst, // int
    TkFloatConst, // float

    Id,
    String,
    Int,
    Float,
    OpAritm,
    OpLogB,
    OpLog,
    OpRel,

    INVALID,
};


//Função que converte em string um tipo de token
const char *TokenString(TokenType tt){
    return (const char*[]) {
        "TkPv", "TkVir", "TkAPar", "TkFPar", "TkACh", "TkFCh", "TkACol", "TkFCol",
        "TkAtrib", "TkPlus", "TkMinus", "TkMult", "TkDiv", "TkMod",
        "TkBNot", "TkBOr", "TkBAnd", "TkBXor",
        "TkNot", "TkOr", "TkAnd",
        "TkEq", "TkNeq", "TkGt", "TkLt", "TkGe", "TkLe",
        "TkFor", "TkIf", "TkWhile", "TkElse", "TkReturn", "TkIntConst", "TkFloatConst",
        "Id", "String", "Int", "Float", "OpAritm", "OpLogB", "OpLog", "OpRel", ""
    }[static_cast<int>(tt)];
}


//Estrutura para um token
struct Token {
     Token(std::string name, TokenType tt):
        name(name), type(tt) {}

    std::string name;
    TokenType type;
};


//Tipo para uma tabela de símbolos
class SymbolTable {
public:

    std::optional<Token> find(const std::string& token) {
        if(table.count(token)) {
            return table.at(token);
        }
        return {};
    }

    void insert(const std::string& token, TokenType tt) {
        this->table.emplace(std::make_pair(token, Token(token, tt)));
    }

    void remove(const std::string& token) {
        this->table.erase(token);
    }


    std::map<std::string, Token> table;
};


//Inicialização da tabela de keywords
std::map<std::string, TokenType> keywords = {
    {";", TokenType::TkPv},
    {",", TokenType::TkVir},
    {"(", TokenType::TkAPar},
    {")", TokenType::TkFPar},
    {"[", TokenType::TkACol},
    {"]", TokenType::TkFCol},
    {"{", TokenType::TkACh},
    {"}", TokenType::TkFCh},

    {"for", TokenType::TkFor},
    {"if", TokenType::TkIf},
    {"while", TokenType::TkWhile},
    {"else", TokenType::TkElse},
    {"return", TokenType::TkReturn},
    {"int", TokenType::Int},
    {"float", TokenType::Float},

    {"=", TokenType::TkAtrib},
    {"+", TokenType::TkPlus},
    {"-", TokenType::TkMinus},
    {"*", TokenType::TkMult},
    {"/", TokenType::TkDiv},
    {"%", TokenType::TkMod},

    {"~", TokenType::TkBNot},
    {"|", TokenType::TkBOr},
    {"&", TokenType::TkBAnd},
    {"^", TokenType::TkBXor},

    {"!", TokenType::TkNot},
    {"||", TokenType::TkOr},
    {"&&", TokenType::TkAnd},
    
    {"==", TokenType::TkEq},
    {"!=", TokenType::TkNeq},
    {">", TokenType::TkGt},
    {"<", TokenType::TkLt},
    {">=", TokenType::TkGe},
    {"<=", TokenType::TkLe}
};


//Tabela de símbolos e keywords
SymbolTable TabelaSimbolos;
SymbolTable TabelaKeywords;

std::string curr_file_name;
int error_num = 0;
%}

branco    [ \t]
fim_linha (\n|\n\r|\r)
comentario \/\/[^{fim_linha}]
multi_comm \/\*(\*(?!\/)|[^*])*\*\/

alpha     [A-Za-z]
digito    [0-9]

prepr     \#{alpha}+\ (\<{alpha}+\.h\>)?

num_nat   {digito}+
num_int   [+-]?{num_nat}
num_real  {num_int}(\.{num_nat})?
ident     ({alpha}|_)({alpha}|{digito}|_)*

op_aritm  (\+|\-|\*|\/|\%)
op_log_b  (&|\||^)
op_log    (&&|\|\|\!|\~)
op_rel    (>|<|==|<=|>=|!=)

string    \".*\"

erro_num {num_real}{alpha}+
erro_id  {alpha}+[@#$]{alpha}+

%%

{erro_num}  {

                if(Options::printErrorMatch) std::cout << Console::color_error << "Erro numerico: ";

                std::cout 
                    << Console::color_error
                    << std::format("{}:{}: Token não reconhecido: '{}'.\n", curr_file_name, lineno(), YYText())
                    << Console::color_rst;

                error_num += 1;
            }

{num_nat}   {
                if(Options::printTkMatch) std::cout << std::format("num_natural: {}\n", YYText());
                if(!TabelaSimbolos.find(YYText())) {
                    TabelaSimbolos.insert(YYText(), TokenType::TkIntConst);
                }
            }

{num_int}   {
                if(Options::printTkMatch) std::cout << std::format("num_inteiro: {}\n", YYText());
                if(!TabelaSimbolos.find(YYText())) {
                    TabelaSimbolos.insert(YYText(), TokenType::TkIntConst);
                }
            }

{num_real}  {   
                if(Options::printTkMatch) std::cout << std::format("num_real: {}\n", YYText());
                if(!TabelaSimbolos.find(YYText())) {
                    TabelaSimbolos.insert(YYText(), TokenType::TkFloatConst);
                }
            }

{op_aritm}  {
                if(Options::printTkMatch) std::cout << std::format("op_aritm: {}\n", YYText());
            }

{op_log_b}  {
                if(Options::printTkMatch) std::cout << std::format("op_log_b: {}\n", YYText());
            }

{op_log}    {
                if(Options::printTkMatch) std::cout << std::format("op_log: {}\n", YYText());
            }

{op_rel}    {
                if(Options::printTkMatch) std::cout << std::format("op_rel: {}\n", YYText());
            }

{string}    {
                if(Options::printTkMatch) std::cout << std::format("string: {}\n", YYText());
                if(!TabelaSimbolos.find(YYText())) {
                    TabelaSimbolos.insert(YYText(), TokenType::String);
                }
            }

{ident}     { 
                if(auto kw = TabelaKeywords.find(YYText()); kw) {
                    if(Options::printTkMatch) std::cout << std::format("keyword/simbolo: {}\n", kw->name);
                } else {
                    if(Options::printTkMatch) std::cout << std::format("identificador: {}\n", YYText());
                    if(!TabelaSimbolos.find(YYText())) {
                        TabelaSimbolos.insert(YYText(), TokenType::Id);
                    }
                }
            }
                
{branco}     |
{comentario} |
{prepr}      |
{fim_linha} { ; }

{erro_id}   {
                if(Options::printErrorMatch) std::cout << Console::color_error << "Erro identificador: ";

                std::cout
                    << Console::color_error
                    << std::format("{}:{} Token não reconhecido: '{}'.\n", curr_file_name, lineno(), YYText())
                    << Console::color_rst;

                error_num += 1;
            }

.           {
               if(auto kw = TabelaKeywords.find(YYText()); kw) {
                    if(Options::printTkMatch) std::cout << std::format("keyword/simbolo: {}\n", kw->name);
                } else {
                    std::cout
                        << Console::color_error
                        << std::format("{}:{}: Token não reconhecido: '{}'.\n", curr_file_name, lineno(), YYText())
                        << Console::color_rst;
                    error_num += 1;
                } 
            }

%%

//Encontra a largura do token com maior cadeia
auto findMaxTokenWidth(const SymbolTable &ts) {
    auto aux = 6;

    for(auto& sim: ts.table){
        if(sim.first.length() > aux) {
            aux = sim.first.length();
        }
    }

    return aux;
}


//Imprime uma tabela de símbolos
void printSymbolTable(const SymbolTable& ts){
    auto maxTokenWidth = findMaxTokenWidth(ts);

    std::cout << std::format("┌{:─<3}┬{:─<{}}┬{:─<12}┐\n", "", "", maxTokenWidth, "");
    std::cout << std::format("│{:3}│{:{}}│{:^12}│\n", "Num", "Cadeia", maxTokenWidth, "Token");
    std::cout << std::format("├{:─<3}┼{:─<{}}┼{:─<12}┤\n", "", "", maxTokenWidth, "");

    int i = 0;
    for(const auto& sim: ts.table) {
        auto token = sim.second;
        std::cout << std::format("│{:3}│{:{}}│{:^12}│\n", i, token.name, maxTokenWidth, TokenString(token.type));
        i += 1;
    }

    std::cout << std::format("└{:─<3}┴{:─<{}}┴{:─<12}┘\n", "", "", maxTokenWidth, "");
}


//Monta a tabela de keyowrds
void buildKwTable(SymbolTable& kwt) {
    for(const auto& kw: keywords) {
        auto [name, tt] = kw;
        kwt.insert(name, tt);
    }
}


//Verifica se um argumento da linha de comando é uma opção
// Retorna
// -- 0 caso não seja opção
// -- 1 caso seja opção curta. Ex: -t
// -- 2 caso seja opção longa. Ex: --token
int isOption(const std::string &arg) {
    return (arg[0] == '-') + (arg[1] == '-');
}

void parseShortOptions(const std::string &arg) {
    for(const auto& c: arg) {
        switch(c) {
        case '-':
            break;

        case 'T':
            Options::printTkMatch = true;
            break;

        case 'e':
            Options::printErrorMatch = true;
            break;

        case 't':
            Options::printTkTable = true;
            break;

        case 'k':
            Options::printKwTable = true;
            break;

        case 'h':
            Options::showHelp = true;
            break;
        }
    }
}

//Lê as configurações da linha de comando
void parseLongOption(const std::string& arg) {
    if (arg == "--help") {
        Options::showHelp = true;
    }
    if (arg == "--all") {
        Options::printKwTable = true;
        Options::printTkTable = true;
        Options::printTkMatch = true;
        Options::printErrorMatch = true;
    } else if (arg == "--token-match") {
        Options::printTkMatch = true;
    } else if (arg == "--error-match") {
        Options::printErrorMatch = true;
    } else if (arg == "--token") {
        Options::printTkTable = true;
    } else if (arg == "--keyword") {
        Options::printKwTable = true;
    } else {
        std::cout << std::format("Opção '{}' não reconhecida.\n", arg);
        exit(1);
    }
}

const std::string getExecName(const std::string& name) {
    std::string final_name;
    final_name.reserve(10);

    for(const auto&c : name | std::views::reverse){
        if(c != '\\' && c != '/') {
            final_name += c;
        } else {
            break;
        }
    }

    std::reverse(final_name.begin(), final_name.end());
    return final_name;
}

void help(const std::string& pname) {
    std::cout
        << "Compilador DRIP v0.1\n\n"
        << "Atualmente o compilador executa somente análise léxica.\n\n"
        << std::format("USO: {} [opções] arquivos...\n\n", pname)
        << "  -h, --help         Mostra informações de ajuda e termina o programa.\n"
        << "  -T, --token-match  Mostra informações de reconhecimento dos tokens.\n"
        << "  -e, --error-match  Mostra informações de reconhecimento de erros.\n"
        << "  -t, --token        Imprime a tabela de tokens final.\n"
        << "  -k, --keyword      Imprime a tabela de palavras-chave.\n"
        << "  --all              Liga todas as flags a baixo:\n"
        << "                       --token-match, --error-match, --token e --keyword\n";
}


auto main(int argc, const char* argv[]) -> int {

    buildKwTable(TabelaKeywords);

    //se foi passado arquivo como argumento, utiliza
    if(argc > 1){
        std::vector<std::string> arquivos;

        for(auto i  = 1 ; i < argc ; ++i) {
            switch(isOption(argv[i])){
            case 0: //arquivo
                arquivos.emplace_back(argv[i]);
                break;
            case 1: //short option
                parseShortOptions(argv[i]);
                break;
            case 2: //long option
                parseLongOption(argv[i]);
                break;
            }
        }

        if(Options::showHelp){
            help(getExecName(argv[0]));
            exit(0);
        }

        yyFlexLexer lexer;
        for(const auto& nome_arquivo: arquivos) {
            curr_file_name = nome_arquivo;
            std::ifstream arquivo(nome_arquivo);
            lexer.switch_streams(&arquivo);

            //roda o analisador léxico
            while(lexer.yylex());

            arquivo.close();
        }

    } else { //se não usa entrada padrão
        yyFlexLexer lexer;
        //roda o analisador léxico
        while(lexer.yylex());
    }

    if (Options::printKwTable) {
        std::cout << "Tabela de Keywords:\n";
        printSymbolTable(TabelaKeywords);
    }

    if (Options::printTkTable) {
        std::cout << "Tabela de Símbolos:\n";
        printSymbolTable(TabelaSimbolos);
    }

    std::cout << std::format("Fim: {} erros.\n", error_num);
    return 0;
}

%{
    // includes
    #include <stdio.h>
    #include <math.h>
    #include "ast.h"
    #include "y.tab.h"
    

    // function declarations
    void print_token(char *token_name);
%}

%option yylineno
letter [a-zA-Z]
digit [0-9]
alphanum [a-zA-Z0-9]
alphanum_us [a-zA-Z0-9_]

%%
"if" { print_token(yytext);
        return IF; }
"else" { print_token(yytext);
        return ELSE; }
"while" { print_token(yytext);
        return WHILE; }
"return" { print_token(yytext);
        return RETURN; }
"int" { print_token(yytext);
        return INT_TYPE; }
"void" { print_token(yytext);
        return VOID_TYPE; }
"extern" { print_token(yytext);
        return EXTERN_TYPE; }
"+" { print_token(yytext);
        return '+'; }
"-" { print_token(yytext);
        return '-'; }
"*" { print_token(yytext);
        return '*'; }
"/" { print_token(yytext);
        return '/'; }
"=" { print_token(yytext);
        return ASSIGN; }
"==" { print_token(yytext);
        return EQUAL; }
">" { print_token(yytext);
        return GREATER_THAN; }
"<" { print_token(yytext);
        return LESS_THAN; }
"<=" { print_token(yytext);
        return LESS_EQUAL; }
">=" { print_token(yytext);
        return GREATER_EQUAL; }
"(" { print_token(yytext);
        return LEFT_PAREN; }
")" { print_token(yytext);
        return RIGHT_PAREN; }
"{" { print_token(yytext);
        return LEFT_BRACKET; }
"}" { print_token(yytext);
        return RIGHT_BRACKET; }
";" { print_token(yytext);
        return SEMICOLON; }

"print" { print_token(yytext);
        return PRINT; }
"read" { print_token(yytext);
        return READ; }


{digit}+ {  print_token(yytext);
            yylval.iVal = atoi(yytext);
            return NUM; }

{letter}{alphanum_us}* {    print_token(yytext);
                            yylval.strVal = strdup(yytext);
                            return ID; }


"," {   print_token(yytext);
        return COMMA; }
        
[ \t\n]+ ; /* ignore whitespace */


%%

int yywrap()
{
    return 1;
}

void print_token(char *token_name)
{
    printf("%s", token_name);
}
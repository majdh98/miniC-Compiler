%{
    // includes
    #include <stdio.h>
    #include <ast.h>

    // function definitions
    int yyerror(const char *s);
    extern int yylex();
    extern int yylex_destroy();

    // variables
    extern FILE *yyin;
    extern int yylineno;
    extern char *yytext;
%}

%token IF ELSE WHILE RETURN INT_TYPE VOID_TYPE EXTERN_TYPE
        ASSIGN PRINT READ
        EQUAL GREATER_THAN LESS_THAN LESS_EQUAL GREATER_EQUAL
        LEFT_PAREN RIGHT_PAREN LEFT_BRACKET RIGHT_BRACKET SEMICOLON
       ID NUM COMMA


%left '-' '+' COMMA
%left '*' '/'



%nonassoc IF
%nonassoc ELSE


        
%start  program
%%

program: extern function_def



extern: extern_read extern_print
        | extern_print extern_read
 
extern_read: EXTERN_TYPE INT_TYPE READ LEFT_PAREN  RIGHT_PAREN SEMICOLON 
extern_print: EXTERN_TYPE VOID_TYPE PRINT LEFT_PAREN INT_TYPE RIGHT_PAREN SEMICOLON

function_def: func_header  block_stmt 

func_header: INT_TYPE ID LEFT_PAREN INT_TYPE ID RIGHT_PAREN
        | INT_TYPE ID LEFT_PAREN RIGHT_PAREN

block_stmt:  LEFT_BRACKET var_decls stmts RIGHT_BRACKET

var_decls: var_decls decl
        | 
decl: INT_TYPE ID SEMICOLON


stmts: stmts stmt 	
        | stmt

stmt: asgn_stmt
        | if_stmt %prec IF
        | if_else_stmt
        | while_loop
        | call_stmt
        | return_stmt
        | block_stmt


asgn_stmt: ID ASSIGN expr SEMICOLON 
        | ID ASSIGN READ LEFT_PAREN RIGHT_PAREN SEMICOLON


term: NUM
        | ID

/* TODO: uniray minus */
expr: term '+' term
        | term '-' term
        | term '*' term
        | term '/' term
        | term

if_stmt: IF LEFT_PAREN condition RIGHT_PAREN  stmt 

if_else_stmt: if_stmt  ELSE  stmt 


while_loop: WHILE LEFT_PAREN condition RIGHT_PAREN  stmt  

condition: term EQUAL term
        | term GREATER_THAN term
        | term LESS_THAN term
        | term LESS_EQUAL term
        | term GREATER_EQUAL term

call_stmt: PRINT LEFT_PAREN term RIGHT_PAREN SEMICOLON
        | READ LEFT_PAREN RIGHT_PAREN SEMICOLON

return_stmt: RETURN expr SEMICOLON
        | RETURN LEFT_PAREN expr RIGHT_PAREN SEMICOLON
        | RETURN SEMICOLON
          

%%

int main(int argc, char **argv) {
    // open file if given
    if (argc == 2) {
        yyin = fopen(argv[1], "r");
    } // else default yyin is stdin

    // parse 
    yyparse();

    // close file if oppened 
    if (yyin != stdin) {
        fclose(yyin);
    }
    yylex_destroy();
    return 0;
}

int yyerror(const char *s) {
    fprintf(stderr, "Syntax error near line %d\n", yylineno);
    return 1;
}
%{
    // includes
    #include <stdio.h>
    #include "ast.h"
    #include "semantic_analyzer.h"

    // function definitions
    int yyerror(const char *s);
    extern int yylex();
    extern int yylex_destroy();

    // variables
    extern FILE *yyin;
    extern int yylineno;
    extern char *yytext;
    astNode *mst_root;
%}

%union {
        int iVal; /* integer value */
        char* strVal; /* symbol table index */
        astNode *nPtr; /* node pointer */
        vector<astNode*> *vPtr; /* vector pointer */
};

%type <nPtr> term expr asgn_stmt decl return_stmt call_stmt stmt block_stmt condition if_stmt if_else_stmt while_loop extern_read extern_print program func_header function_def

%type <vPtr> stmts var_decls extern


%token IF ELSE WHILE RETURN INT_TYPE VOID_TYPE EXTERN_TYPE
        ASSIGN PRINT READ
        LEFT_PAREN RIGHT_PAREN LEFT_BRACKET RIGHT_BRACKET SEMICOLON COMMA
        
%token <iVal> NUM
%token <strVal> ID


%nonassoc IF
%nonassoc ELSE
%left EQUAL GREATER_THAN LESS_THAN LESS_EQUAL GREATER_EQUAL
%left '-' '+' COMMA
%left '*' '/'
%nonassoc UMINUS





        
%start  program
%%

program: extern function_def {$$ = createProg($1->at(0), $1->at(1), $2);
// printNode($$, 5);
mst_root = $$;}



extern: extern_read extern_print {$$ = new vector<ast_Node*>();
            $$->push_back($1);
            $$->push_back($2);}
        | extern_print extern_read {$$ = new vector<ast_Node*>();
            $$->push_back($1);
            $$->push_back($2);}
 
extern_read: EXTERN_TYPE INT_TYPE READ LEFT_PAREN  RIGHT_PAREN SEMICOLON { $$ = createExtern("read");}
extern_print: EXTERN_TYPE VOID_TYPE PRINT LEFT_PAREN INT_TYPE RIGHT_PAREN SEMICOLON { $$ = createExtern("print");}

function_def: func_header  block_stmt { $$ = $1; $$->func.body = $2;}

func_header: INT_TYPE ID LEFT_PAREN INT_TYPE ID RIGHT_PAREN { $$ = createFunc($2, createVar($5), NULL);}
        | INT_TYPE ID LEFT_PAREN RIGHT_PAREN { $$ = createFunc($2, NULL, NULL);}

block_stmt:  LEFT_BRACKET var_decls stmts RIGHT_BRACKET { $2->insert($2->end(), $3->begin(), $3->end()); // insert the stmts into the var_decls
                    delete($3);
                    $$ = createBlock($2);} 

var_decls: var_decls decl { $$ = $1; $$->push_back($2);}
        | { $$ = new vector<astNode*>();}

decl: INT_TYPE ID SEMICOLON { $$ = createDecl($2);}


stmts: stmts stmt 	{$$ = $1; $$->push_back($2);}
        | stmt { $$ = new vector<astNode*>(); $$->push_back($1);} // add to end of vector

stmt: asgn_stmt { $$ = $1;}
        | if_stmt %prec IF { $$ = $1;}
        | if_else_stmt { $$ = $1;}
        | while_loop { $$ = $1;}
        | call_stmt { $$ = $1;}
        | return_stmt { $$ = $1;}
        | block_stmt {  $$ = $1;}


asgn_stmt: ID ASSIGN expr SEMICOLON {   astNode* tnptr = createVar($1);
									    $$ = createAsgn(tnptr, $3);}
        | ID ASSIGN READ LEFT_PAREN RIGHT_PAREN SEMICOLON {astNode* tnptr = createVar($1); 
        $$ = createAsgn(tnptr, createCall("read"));}
        | ID ASSIGN term SEMICOLON {$$ = createAsgn(createVar($1), $3);}


term: NUM {$$ = createCnst($1);}
        | ID {$$ = createVar($1);}

/* TODO: uniray minus */
expr: term '+' term  {$$ = createBExpr($1, $3, add);}
        | term '-' term {$$ = createBExpr($1, $3, sub);}
        | term '*' term {$$ = createBExpr($1, $3, mul);}
        | term '/' term {$$ = createBExpr($1, $3, divide);}

if_stmt: IF LEFT_PAREN condition RIGHT_PAREN  stmt { $$ = createIf($3, $5);}

if_else_stmt: if_stmt  ELSE  stmt { $1->stmt.ifn.else_body = $3;$$ = $1;}


while_loop: WHILE LEFT_PAREN condition RIGHT_PAREN  stmt  { $$ = createWhile($3, $5);}

condition: term EQUAL term {$$ = createRExpr($1, $3, eq);}
        | term GREATER_THAN term {$$ = createRExpr($1, $3, gt);}
        | term LESS_THAN term {$$ = createRExpr($1, $3, lt);}
        | term LESS_EQUAL term {$$ = createRExpr($1, $3, le);}
        | term GREATER_EQUAL term {$$ = createRExpr($1, $3, ge);}

call_stmt: PRINT LEFT_PAREN term RIGHT_PAREN SEMICOLON { $$ = createCall("print", $3);}
        | READ LEFT_PAREN RIGHT_PAREN SEMICOLON { $$ = createCall("read", NULL);}

return_stmt: RETURN expr SEMICOLON { $$ = createRet($2);}
        | RETURN LEFT_PAREN expr RIGHT_PAREN SEMICOLON { $$ = createRet($3);}
        | RETURN SEMICOLON { $$ = createRet(NULL);}

%%

int main(int argc, char **argv) {
    // open file if given
    if (argc == 2) {
        yyin = fopen(argv[1], "r");
    } // else default yyin is stdin

    // parse 
    yyparse();

    // call symantic analysis HERE
    saveProgramRoot(mst_root);
    traverseNodePreorder(mst_root);

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
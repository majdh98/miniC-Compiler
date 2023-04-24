#include"semantic_analyzer.h"
#include<stdio.h>
#include<stdlib.h>
#include<assert.h>
#include<string.h>



// global vars
vector<vector<char*>*> symbol_table_stack; // stack of symbol tables
astNode* program_root;


void saveProgramRoot(astNode* root){
    program_root = root;
}





void traverseNodePreorder(astNode *root){

    assert(root != NULL);

    switch (root->type){
        // ignore extern and traverse the func
        case ast_prog:
            traverseNodePreorder(root->prog.func);
            freeProg(root);
            printNode(root, 5);
            break;

        case ast_func:{
            // create a new symbol table for this function and push it to stack
            vector <char*> symbol_table;
            symbol_table_stack.push_back(&symbol_table);

            // populate the symbol table with the parameters. Each function can only take one param
            if(root->func.param != NULL){
                symbol_table_stack.back()->push_back(root->func.param->var.name);
            }

            // traverse the body of the function
            traverseNodePreorder(root->func.body);

            // TODO: pop and free memory
            symbol_table_stack.pop_back();
            freeFunc(root);


            break;
        }

		case ast_stmt:{
            traverseStmtPreorder(&root->stmt);
            // TODO: free memmory
            break;
        }
		case ast_extern:{break;} // ignore extern
        
		case ast_var: {	
            // check if the variable is already declared in the current scope or higher scope
            bool isDeclared = false;
            for (int i = 0; i < symbol_table_stack.size(); i++){ // iterate through all the symbol tables in the stack. The top of the stack is the current scope. The bottom of the stack is the global scope.
                for (int j = 0; j < symbol_table_stack[i]->size(); j++){ // iterate through all the symbols in the symbol table
                    if(strcmp(root->var.name, symbol_table_stack[i]->at(j)) == 0){
                        isDeclared = true;
                        break;
                    }
                }

                if(isDeclared){
                    break;
                }
            }
    
            if(!isDeclared){
                printf("\nError: variable %s is not declared in this scope\n", root->var.name);
                freeProg(program_root);
                exit(1);
            }

            break;
		}

		case ast_cnst: {break;} // ignore constants
		
        case ast_rexpr: { // comparison expressions
            traverseNodePreorder(root->rexpr.lhs);
            traverseNodePreorder(root->rexpr.rhs);		
		    break;
        }
		case ast_bexpr: { // binary expressions
            traverseNodePreorder(root->bexpr.lhs);
            traverseNodePreorder(root->bexpr.rhs);
			break;
		}
		case ast_uexpr: { // unary expressions
            traverseNodePreorder(root->uexpr.expr);
			break;
		 }
        
        default:
            fprintf(stderr,"Error: invalid astNode type\n");
            break;
    }
    fflush(stdout);
}

void traverseStmtPreorder(astStmt* stmt){
    
        assert(stmt != NULL);

        switch (stmt->type){

            case ast_call:{
                // check if the function param is declared in the current scope or higher scope. func param = var.
                if(stmt->call.param != NULL){
                    traverseNodePreorder(stmt->call.param);
                }
                break;
            }

            case ast_ret:{   
                // check if the return value is declared in the current scope or higher scope. return value = expr. TODO: tell mubbie that he shouldn't pass null return values to semanticAnalyzer.
                if(stmt->ret.expr != NULL){
                    traverseNodePreorder(stmt->ret.expr);
                }
                break;
            }

            case ast_block:{
                // create a new symbol table for this block and push it to stack
                vector <char*> symbol_table;
                symbol_table_stack.push_back(&symbol_table);

                // visit all the statements in the block
                for(int i = 0; i < stmt->block.stmt_list->size(); i++){
                    traverseNodePreorder(stmt->block.stmt_list->at(i));
                }

                // once the block is done, pop its symbol tabe from the stack
                symbol_table_stack.pop_back();

                break;
            }
            
            case ast_while:{
                // check if the condition variable is declared in the current scope or higher scope. condition variable = var.
                traverseNodePreorder(stmt->whilen.cond);
                

                // visit the body of the while loop
                traverseNodePreorder(stmt->whilen.body);

                break;
            }

            case ast_if:{
                // check if the condition variable is declared in the current scope or higher scope. condition variable = var.
                traverseNodePreorder(stmt->ifn.cond);
                // visit the body of the if statement
                traverseNodePreorder(stmt->ifn.if_body);
                // visit the else body of the if statement
                if (stmt->ifn.else_body != NULL){
                    traverseNodePreorder(stmt->ifn.else_body);
                }
                
                break;
            }

            case ast_asgn:{
                // check lhs var
                traverseNodePreorder(stmt->asgn.lhs);
                // rhs var
                traverseNodePreorder(stmt->asgn.rhs);
                break;
            }

            case ast_decl:{
                // if node is a declaration statement, add the variable to symbol table that is at the top of the stack
                symbol_table_stack.back()->push_back(stmt->decl.name);
                break;
            }

            default:
                fprintf(stderr,"Error: invalid astStmt type\n");
                break;
        }
}




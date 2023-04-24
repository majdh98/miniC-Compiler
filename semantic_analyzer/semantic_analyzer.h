#ifndef SEMANTIC_ANALYZER_H
#define SEMANTIC_ANALYZER_H
#include <cstddef>
#include<vector>
#include "ast.h"
using namespace std;



void traverseNodePreorder(astNode *root);

void traverseStmtPreorder(astStmt* stmt);

void saveProgramRoot(astNode* root);





#endif

source = syntax_analyzer
$(source).out: $(source).l $(source).y ast.c semantic_analyzer.c
	yacc -dv -Wcounterexamples $(source).y
	lex $(source).l
	g++ -o $(source).out ast.c semantic_analyzer.c lex.yy.c y.tab.c

clean:
	rm lex.yy.c y.tab.c y.tab.h $(source).out y.output

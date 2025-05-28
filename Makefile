bison-calc: bison-calc.l bison-calc.y bison-calc.h
	bison -d bison-calc.y
	flex -o bison-calc.lex.c bison-calc.l
	gcc -o $@ bison-calc.tab.c bison-calc.lex.c bison-calc-func.c -lm -lfl
	@echo Parser da Calculadora com Cmds, funcoes, ... estah pronto!

clean:
	rm -f bison-calc bison-calc.tab.c bison-calc.tab.h bison-calc.lex.c

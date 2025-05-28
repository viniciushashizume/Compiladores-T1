#ifndef BISON_CALC_H
#define BISON_CALC_H

/*
 * Declaracoes para uma calculadora avancada
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <math.h>
#define FOR_NODE 'Z'  
/* interface com o lexer */
extern int yylineno;
void yyerror(char *s, ...);
int yylex(void);
int yyparse(void);

/* tab. de simbolos */
struct symbol { /* um nome de variavel */
    char *name;
    double value;
    struct ast *fun; /* stmt para funcao */
    struct symlist *syms; /* lista de argumentos */
};

/* tab. de simbolos de tamaho fixo */
#define NHASH 9997
extern struct symbol symtab[NHASH];  // Mude para extern

struct symbol *lookup(char *);

/* lista de simbolos, para uma lista de argumentos */
struct symlist {
    struct symbol *sym;
    struct symlist *next;
};

struct symlist *newsymlist(struct symbol *sym, struct symlist *next);
void symlistfree(struct symlist *sl);

/* Tipos de nos:
 * Operadores: + - * /
 * Operadores de comparacao: 1 (>), 2 (<), 3 (!=), 4 (==), 5 (>=), 6 (<=)
 * L - expressao ou lista de comandos
 * I - comando IF
 * W - comando WHILE
 * N - symbol de referencia
 * = - atribuicao
 * S - lista de simbolos
 * F - chamada de funcao pre-definida
 * C - chamada de funcao def. p/ usuario
 * & - Operador AND
 * | - Operador OR
 */

/* funcoes pre-definidas */
typedef enum {
    Bsqrt = 1,
    Bexp,
    Blog,
    Bprint
} bifs;

/* nos na AST */
/* todos tem o "nodetype" inicial em comum */

struct ast {
    int nodetype;
    struct ast *l;
    struct ast *r;
};

struct fncall { /* funcoes pre-definida */
    int nodetype; /* tipo F */
    struct ast *l;
    bifs functype;
};

struct ufncall { /* funcoes usuario */
    int nodetype; /* tipo C */
    struct ast *l; /* lista de argumentos */
    struct symbol *s;
};

struct flow {
    int nodetype; /* tipo I ou W */
    struct ast *cond; /* condicao */
    struct ast *tl; /* ramo "then" ou lista "do" */
    struct ast *el; /* ramo opcional "else" */
};

struct numval {
    int nodetype; /* tipo K */
    double number;
};

struct symref {
    int nodetype; /* tipo N */
    struct symbol *s;
};

struct symasgn {
    int nodetype; /* tipo = */
    struct symbol *s;
    struct ast *v; /* valor a ser atribuido */
};

/* construcao de uma AST */
struct ast *newast(int nodetype, struct ast *l, struct ast *r);
struct ast *newcmp(int cmptype, struct ast *l, struct ast *r);
struct ast *newfunc(int functype, struct ast *l);
struct ast *newcall(struct symbol *s, struct ast *l);
struct ast *newref(struct symbol *s);
struct ast *newasgn(struct symbol *s, struct ast *v);
struct ast *newnum(double d);
struct ast *newflow(int nodetype, struct ast *cond, struct ast *tl, struct ast *tr);
struct ast *newlogic(int nodetype, struct ast *l, struct ast *r);
struct ast *newfor(struct ast *init, struct ast *cond, struct ast *inc, struct ast *body);

struct forloop {
    int nodetype;      // Tipo 'F'
    struct ast *init;  // Inicialização (ex: i=0)
    struct ast *cond;  // Condição (ex: i < 10)
    struct ast *inc;   // Incremento (ex: i = i + 1)
    struct ast *body;  // Corpo do loop (lista de comandos)
};

/* definicao de uma funcao */
void dodef(struct symbol *name, struct symlist *syms, struct ast *stmts);

/* avaliacao de uma AST */
double eval(struct ast *);

/* deletar e liberar uma AST */
void treefree(struct ast *);

#endif

/*
 * Parser para uma calculadora avancada
 */

%{
#include <stdio.h>
#include <stdlib.h>
#include "bison-calc.h"
%}

%union {
    struct ast *a;
    double d;
    struct symbol *s; /* qual simbolo? */
    struct symlist *sl;
    int fn; /* qual funcao? */
}

/* declaracao de tokens */
%token <d> NUMBER
%token <s> NAME
%token <fn> FUNC
%token EOL
%token AND OR
%token FOR

%token IF THEN ELSE WHILE DO LET

%nonassoc <fn> CMP
%right '='
%left AND OR  
%left '+' '-'
%left '*' '/'

%type <a> exp stmt list explist
%type <sl> symlist

%start calclist
%%

stmt : IF exp THEN list { $$ = newflow('I', $2, $4, NULL); }
     | IF exp THEN list ELSE list { $$ = newflow('I', $2, $4, $6); }
     | WHILE exp DO list { $$ = newflow('W', $2, $4, NULL); }
     | exp
     | FOR '(' exp ';' exp ';' exp ')' list { $$ = newfor($3, $5, $7, $9); }
     ;

list : /* vazio! */ { $$ = NULL; }
     | stmt ';' list { if ($3 == NULL)
                         $$ = $1;
                       else
                         $$ = newast('L', $1, $3);
                     }
     ;

exp : exp CMP exp { $$ = newcmp($2, $1, $3); }
    | exp '+' exp { $$ = newast('+', $1, $3); }
    | exp '-' exp { $$ = newast('-', $1, $3); }
    | exp '*' exp { $$ = newast('*', $1, $3); }
    | exp '/' exp { $$ = newast('/', $1, $3); }
    | '(' exp ')' { $$ = $2; }
    | NUMBER { $$ = newnum($1); }
    | NAME { $$ = newref($1); }
    | NAME '=' exp { $$ = newasgn($1, $3); }
    | FUNC '(' explist ')' { $$ = newfunc($1, $3); }
    | NAME '(' explist ')' { $$ = newcall($1, $3); }
    | exp AND exp { $$ = newlogic('&', $1, $3); }  
    | exp OR exp  { $$ = newlogic('|', $1, $3); }
    ;

explist : exp
        | exp ',' explist { $$ = newast('L', $1, $3); }
        ;

symlist : NAME { $$ = newsymlist($1, NULL); }
        | NAME ',' symlist { $$ = newsymlist($1, $3); }
        ;

calclist : /* vazio! */
         | calclist stmt EOL {
               printf("= %4.4g\n> ", eval($2));
               treefree($2);
           }
         | calclist LET NAME '(' symlist ')' '=' list EOL {
               dodef($3, $5, $8);
               printf("Definido %s\n>", $3->name); }
         | calclist error EOL { yyerror; printf("> "); }
         ;

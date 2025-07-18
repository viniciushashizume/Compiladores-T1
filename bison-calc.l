/*
 * Lexer para uma calculadora avancada
 */

/* reconhecimento de tokens para a calculadora */

%option noyywrap nodefault yylineno
%{
#include |
#include "bison-calc.tab.h"
%}

/* expoente float */
EXP ([Ee][-+]?[0-9]+)

%%

"+" | /* operadores de caracter unico */
"-" |
"*" |
"/" |
"=" |
"," |
";" |
"(" |
")" { return yytext[0]; }

">"  { yylval.fn = 1; return CMP; } /* operadores de comparacao, todos sao token CMP */
"<"  { yylval.fn = 2; return CMP; }
"<>" { yylval.fn = 3; return CMP; }
"==" { yylval.fn = 4; return CMP; }
">=" { yylval.fn = 5; return CMP; }
"<=" { yylval.fn = 6; return CMP; }

"&&" {return AND;} /* operadores lógicos*/
"||" {return OR;}

"if"    { return IF; }    /* palavras-chave */
"then"  { return THEN; }
"else"  { return ELSE; }
"while" { return WHILE; }
"do"    { return DO; }
"let"   { return LET; }
"for"    { return FOR; }

"sqrt"  { yylval.fn = Bsqrt; return FUNC; } /* funcoes pre-definidas */
"exp"   { yylval.fn = Bexp;  return FUNC; }
"log"   { yylval.fn = Blog;  return FUNC; }
"print" { yylval.fn = Bprint; return FUNC; }

[a-zA-Z][a-zA-Z0-9]* { yylval.s = lookup(yytext); return NAME; } /* nomes */

[0-9]+"."[0-9]*{EXP}? |
"."?[0-9]+{EXP}? { yylval.d = atof(yytext); return NUMBER; }

"//".*  /* comentarios */

[ \t]   /* ignora espaco em branco */

\\\n { printf("c> "); } /* ignora continuacao de linha */

\n { return EOL; }

. { yyerror("Caracter desconhecido %c\n", *yytext); }

%%

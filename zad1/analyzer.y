%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include "modArithmetic.h"

extern int yylex();
extern void yyerror (char const *);

static long long base = 1234577;
static EArithmeticError aerr = 0;
static char logBuffer[1000];
static size_t currentSize = 0;
static inline void logStr(const char ptr[const static 1]) {
  if (strlen(ptr) < 1000 - currentSize) {
    strcpy(&logBuffer[currentSize], ptr);
    currentSize += strlen(ptr);
  }
}
static inline void logNum(const long long num) {
  sprintf(&logBuffer[currentSize], "%lld ", num);
  currentSize += strlen(&logBuffer[currentSize]);
}
static inline void logClear() {
  currentSize = 0;
}
static inline void logPrint() {
  printf("%s", logBuffer);
}
%}

%union {
  long long n;
}

%token <n> NUM;
%token ERROR;
%token EOL;
%left '-' '+'
%left '*' '/'
%precedence NEG
%left '^'     

%type <n> expression

%%
start:
  %empty
| start line
;

line:
  EOL
| expression EOL {
            if (aerr == ZERO_DIVISION) {
              aerr = 0;
              printf("\nBlad dzielenia przez 0\n"); 
            } else {
              logPrint();
              logClear();
              printf ("\nwynik: %lld\n", absMod($1, base));
            }
          }
| error EOL {yyclearin;}
;

expression:
  NUM {logNum($1);}
| '(' expression ')' { $$ = $2; }
| expression '+' expression { $$ = addMod($1, $3, base); logStr("+ ");}
| expression '-' expression { $$ = subMod($1, $3, base); logStr("- ");}
| expression '*' expression { $$ = multMod($1, $3, base); logStr("* ");}
| expression '/' expression {
                errno = 0; $$ = divMod($1, $3, base);
                if (errno != 0) {aerr = errno;}
                errno = 0;
                logStr("/ ");
              }
| '-' expression     %prec NEG { $$ = -$2; logStr("- "); }
| expression '^' expression { $$ = powMod($1, $3, base); logStr("^ "); }
;
%%

void yyerror(const char msg[const]) {
  fprintf(stderr, "%s\n", msg);
  yyclearin;
}

int main(void) {
  yyparse();
}
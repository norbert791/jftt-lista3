%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include "modArithmetic.h"

extern int yylex();
extern void yyerror (char const *);

static const long long base = 1234577;
static const long long expBase = 1234576;
static long long currentBase = base;

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

static inline void logClear(void) {
  currentSize = 0;
}

static inline void logPrint(void) {
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
              logPrint();
              logClear();
              printf ("\nwynik: %lld\n", absMod($1, base));
            }
| error EOL {yyclearin;}
;

expression:
  NUM {logNum($1);}
| '(' expression ')' { $$ = $2; }
| expression '+' expression { $$ = addMod($1, $3, currentBase); logStr("+ ");}
| expression '-' expression { $$ = subMod($1, $3, currentBase); logStr("- ");}
| expression '*' expression { $$ = multMod($1, $3, currentBase); logStr("* ");}
| expression '/' expression {
                errno = 0; $$ = divMod($1, $3, currentBase);
                switch errno {
                  case ZERO_DIVISION:
                    yyerror("Blad dzielenia przez 0");
                    errno = 0;
                    YYERROR;
                    break;
                  case NO_INVERSION:
                    yyerror("Brak odwrotnosci w wykladniku");
                    errno = 0;
                    YYERROR;
                    break;
                }
                errno = 0;
                logStr("/ ");
              }
| '-' expression     %prec NEG { $$ = -$2; logStr("- "); }
| expression '^' {
                  if (currentBase == expBase) {
                    yyerror("Blad zagniezdzonego ^");
                    YYERROR;
                  }
                  currentBase = expBase;
                } expression {
                              currentBase = base;
                              $$ = powMod($1, $4, currentBase);
                              logStr("^ ");
                            }
;
%%

void yyerror(const char msg[const]) {
  fprintf(stderr, "%s\n", msg);
  logClear();
  currentBase = base;
}

int main(void) {
  yyparse();
}
%{
#include <stdio.h>
#include <stdlib.h>
#include "analyzer.tab.h"

int yylex();
%}

%option noyywrap
%x COMMENT ESCAPE_LINE

%%
^[#]                   {BEGIN(COMMENT);}
<COMMENT>[\n]          {BEGIN(INITIAL);}
<COMMENT>((.)|([ \t])|([0-9]+)) { }
([\\])/([\n])          {BEGIN(ESCAPE_LINE);}
<ESCAPE_LINE>[\n]      {BEGIN(INITIAL);}
[0-9]+                 {yylval.n = strtoll(yytext, NULL, 10); return NUM;}
[+\-*/^()]             {return yytext[0];}
[ \t]                  {}
[\n]                   {return EOL;}
.|[\\]                 {return ERROR; BEGIN(COMMENT);}
%%

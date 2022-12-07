bison -d analyzer.y
lex parser.l
clang analyzer.tab.c analyzer.tab.h lex.yy.c
rm analyzer.tab.c analyzer.tab.h lex.yy.c analyzer.tab.h.gch
mv a.out zad1
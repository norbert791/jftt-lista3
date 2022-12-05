from sly import Parser
from MyParser import MyParser
from mod import Mod
from common import ParserError
from sys import stdin

class NestedPower(Exception):
  pass



class CalcParser(Parser):
  # Get the token list from the lexer (required)
  base = 1234577
  currentBase = base
  expBase = 1234576
  
  tokens = MyParser.tokens

  precedence = (
        ('left', PLUS, MINUS),
        ('left', TIMES, DIVIDE),
        ('right', UMINUS),
        ('left', POWER)
  )

  @_('COMMENT')
  def start(self, p):
    return None

  @_('expr')
  def start(self, p):
    return p.expr

  @_('expr PLUS expr')
  def expr(self, p):
    return p.expr0 + p.expr1

  @_('expr MINUS expr')
  def expr(self, p):
    return p.expr0 - p.expr1

  @_('expr TIMES expr')
  def expr(self, p):
    return p.expr0 * p.expr1

  @_('expr DIVIDE expr')
  def expr(self, p):
    return p.expr0 // p.expr1



  @_('MINUS expr %prec UMINUS')
  def expr(self, p):
    return -p.expr

  @_('NUMBER')
  def expr(self, p):
    return Mod(p.NUMBER, self.currentBase)

  @_('expr POWER empty expr')
  def expr(self, p):
    self.currentBase = self.base
    return p.expr0 ** Mod(p.expr1._value, self.currentBase)
  
  @_('LBRACKET expr RBRACKET')
  def expr(self, p):
    return p.expr
    
  @_('')
  def empty(self, p):
    if self.currentBase == self.expBase:
      raise NestedPower()
    self.currentBase = self.expBase

  def error(self, tok):
    print("Błąd składni")

if __name__ == '__main__':
    lexer = MyParser()
    parser = CalcParser()

    for text in stdin:
      try:
        parser.currentBase = parser.base
        result = parser.parse(lexer.tokenize(text))
        if result != None:
          print(result._value)
      except EOFError:
        print('')
      except ZeroDivisionError:
        print("Dzielenie przez 0")
      except ArithmeticError:
        print("Brak odwrotności w wykładniku")
      except AttributeError:
        pass
      except ValueError:
        print("Nie można odwrócić liczby w wykładniku")
      except NestedPower:
        print("Nie można potęgować w wykładniku")
      except ParserError:
        print("Nieznany symbol")

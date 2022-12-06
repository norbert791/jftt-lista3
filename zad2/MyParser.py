from sly import Lexer
from common import ParserError

class MyParser(Lexer):
  # Set of token names. This is always required
  tokens = { NUMBER, PLUS, MINUS, TIMES, DIVIDE, POWER, LBRACKET, RBRACKET, COMMENT }


  literals = { '(', ')', '{', '}', ';' }

  # String containing ignored characters
  ignore = ' \t\n'

  # Regular expression rules for tokens
  PLUS    = r'\+'
  MINUS   = r'\-'
  TIMES   = r'\*'
  DIVIDE  = r'\/'
  POWER   = r'\^'
  LBRACKET = r'\('
  RBRACKET = r'\)'
  COMMENT = r'\A[#].*'

  @_(r'\d+')
  def NUMBER(self, t):
    t.value = int(t.value)
    return t

  def error(self, t):
    raise ParserError()
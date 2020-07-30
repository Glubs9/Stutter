import Lexer
import Parser
import Runner
import sys
sys.setrecursionlimit(1000000) #(for build)

def interpret(str_in):
    lexed = Lexer.Lex(str_in)
    parsed = Parser.Parse(lexed)
    ran = Runner.Run(parsed)
    return ran

def repl():
    inp = False
    while inp != "quit":
        inp = input(">> ")
        evaled = interpret(inp)
        print(evaled)

def load_file(str_in):
    file_str = open(str_in).read()
    interpret(file_str)

def Main():
    load_file("stdlib.shit")
    for n in sys.argv[1:]:
        load_file(n)
    repl()

Main()

from pymonad import *

def remove_comments(str_in):
    ignore = False
    ret = []
    for n in str_in:
        if n == ";":
            ignore = not ignore
        elif not ignore:
            ret.append(n)
    return "".join(ret)

def split_new_line(str_in): #used in the monads
    return str_in.split("\n")

def split_tabs(str_in): #used in the monads
    return str_in.split("\t")

def split_brackets(str_in):
    prev = 0
    ret = []
    for n in range(len(str_in)):
        if str_in[n] == "(" or str_in[n] == ")":
            ret.append(str_in[prev:n])
            ret.append(str_in[n])
            prev = n+1
    ret.append(str_in[prev:len(str_in)])
    return ret

def remove_empty(str_in):
    #split_brackets causes empty sometimes
    if len(str_in) == 0:
        return []
    return [str_in]

def test_for_non_opened_bracket(tokens_in):
    return any([n==')' for n in tokens_in])

def Lex(str_in):
    no_more_comments = remove_comments(str_in)
    splitted = no_more_comments.split(" ")
    split_monad = List(*splitted)
    splitted_at_new_line = split_monad >> split_new_line
    splitted_at_tabs = splitted_at_new_line >> split_tabs
    splitted_at_brackets = splitted_at_tabs >> split_brackets
    cleaned = splitted_at_brackets >> remove_empty
    return cleaned

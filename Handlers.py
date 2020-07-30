#these are all the predefined functions
#the name spaces are defined here as well because it is easier to read nad allows better encapsulation in Runner.py

def handle_raise(str_in):
    #this is only like this because I couldn't put raise in a lambda
    raise Exception(str_in)

def define(name):
    def inner(val):
        #(define name val)
        name_space[name] = val #name_space is below
        return val #kinda unnecersary
    return inner

def replace(var, str_in, val):
    ret = [
        val if n == var else (replace(var, n, val) if type(n) is list else n) 
        for n in str_in
    ]
    if all([((type(n) is str) and (len(n) == 1)) for n in ret]):
        #if ret is an array of characters (ie: a string) return a type of string
        return "".join(ret)
    return ret

def lambda_eval(var, str_in, evaluate):
    return (lambda val_in : evaluate(replace(var, str_in, val_in))) #not technically the best but fuck it you know

def handle_lambda(arr_in, evaluate):
    var = arr_in[0] #lambda argument should be string so no evaluation
    return lambda_eval(var, arr_in[1:], evaluate)

def print_and_return(val):
    print(val)
    return val

def handle_if(arr_in, evaluate):
    bool_if = evaluate(arr_in[0])
    if bool_if:
        return evaluate(arr_in[1])
    else:
        return evaluate(arr_in[2])

def handle_let(arr_in, evaluate):
    #(let x val str)
    var = arr_in[0]
    val = arr_in[1]
    str_out = arr_in[2]
    return evaluate(replace(var, str_out, val))

#does not work
def handle_quote(str_in, evaluate):
    return str_in[0] #takes str_input and returns it not evaluated

def handle_begin(str_in, evaluate):
    for n in str_in[:-1]:
        evaluate(n)
    return evaluate(str_in[-1])

#name_space is used in the evaluate functions
name_space = {
        "increment": lambda val_in : val_in+1,
        "decrement": lambda val_in : val_in-1,
        "print": lambda val_in : print_and_return(val_in), #the rest of the functions are more complicated
        "define": define,
        "zero?": lambda val_in : (val_in == 0),
        "raise": handle_raise,
        "str_eq": lambda val1: (lambda val2: val1 == val2),
        "str_input": lambda val: input(val),
        "num_input": lambda val: int(input(val)),
        "true?": lambda val: val == True #this is here because I am afraid of truthy and falsy values
}

#the 'macros' are called with their arguments not having been evaluated 
macro_name_space = {"lambda": handle_lambda, "if": handle_if, "let": handle_let,  "begin": handle_begin}

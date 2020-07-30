import numbers

def find_matching_brack(tokens): #everything except
    amount_needed = 1
    for pos in range(len(tokens)):
        n = tokens[pos]
        if n == "(": 
            amount_needed += 1
        elif n == ")": 
            amount_needed -= 1

        if amount_needed == 0:
            return pos

    raise Exception("no closing bracket found")

def indent(tokens):
    ret = []
    n = 0
    while n < len(tokens):
        if tokens[n] == "(":
            matched_pos = n + find_matching_brack(tokens[n+1:]) + 1 #n + 1 because ???
            internal_indented = indent(tokens[n+1:matched_pos])
            ret.append(internal_indented)
            n = matched_pos
        else:
            ret.append(tokens[n])
        n += 1
    return ret

def parse_number(num_in):
    try:
        return int(num_in)
    except ValueError:
        return num_in

def parse_numbers(tokens):
    return [parse_number(n) for n in tokens]

def parse_bools(tokens):
    return [True if n == "true" else (False if n == "false" else n) for n in tokens]

def ensure_ints(tokens):
    for n in tokens:
        if type(n) is not str and isinstance(n, float):
            raise Exception("integers only, no floats: " + n)

def check_brackets(tokens):
    return any([check_brackets(n) if type(n) is list else (n==")") for n in tokens])

def Parse(tokens): 
    numbers = parse_numbers(tokens)
    ensure_ints(tokens) #currently doesn't work
    numbers_and_bools = parse_bools(numbers)
    indented = indent(numbers_and_bools)
    #the parse function is just the indent funciton but it is here for in the future and naming clarity
    if check_brackets(indented):
        raise Exception("found ) without (")
    return indented

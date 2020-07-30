from Handlers import name_space, macro_name_space

def evaluate_plain(val_in):
    return val_in

def evaluate_str(str_in):
    if str_in in name_space:
        return name_space[str_in]
    if str_in in macro_name_space:
        return macro_name_space[str_in]
    return str_in

def apply_func(f, arr):
    #this handles the syntax sugar of ((+ 3) 5) == (+ 3 5)
    #as everything is curried
    #note: i would normally write this recursively but i'm running out of stack space
    #try:
    try:
        ret = f(arr[0])
    except TypeError:
        print("non-function " + str(f) + " called")
        raise TypeError
    try:
        for n in arr[1:]:
            ret = ret(n)
        return ret
    except TypeError:
        print("tried to call " + str(ret))
        raise TypeError

#creates closures for language wide memoization
def generate_memo_funcs():
    #calling str() on list everytime is not that efficient but the code looks nicer
    _prev_results = {}
    def _add_to_memo(index, val):
        if index[0] == "print":
            return val
        if index[0] == "print-list": #bad code, add keyword to add this logic later
            return val
        _prev_results[str(index)] = val
        return val
    def _check_memo(index):
        return str(index) in _prev_results
    def _get_memo(index):
        return _prev_results[str(index)]
    return (_add_to_memo, _check_memo, _get_memo)
add_memo, check_memo, get_memo = generate_memo_funcs() #creates functions

def evaluate_list(arr):
    if check_memo(arr):
        return get_memo(arr)
    if type(arr[0]) is str and arr[0] in macro_name_space:
        return add_memo(arr, macro_name_space[arr[0]](arr[1:], evaluate)) #potentially don't memoize this
    else:
        evaled_arr = [evaluate(n) for n in arr]
        if len(evaled_arr) == 1 and evaled_arr[0] not in name_space: #do a proper check here later (the real check will be type == func)
            return evaled_arr[0]                                     #the current error is cannot call str
        return add_memo(arr, apply_func(evaled_arr[0], evaled_arr[1:]))

def evaluate(val_in):
    if type(val_in) is list:
        return evaluate_list(val_in) #list is of type (func-name arg1 arg2 ...)
    elif type(val_in) is str: #string is symbols
        return evaluate_str(val_in)
    else:
        return evaluate_plain(val_in) #effectively identity

def Run(indented_arr): #indented arr has been parsed
    evaled = [evaluate(n) for n in indented_arr]
    return evaled[-1] #this is for multiple lines to be handled
                      #as in (+ 3 4) (- 3 2) will return 1

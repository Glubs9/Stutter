# Stutter
A bad lisp dialect without any of the features that makes lisp good or fun                                 
(the name comes from my mom suggesting that a stutter is a bad lisp which although incorrect, is very fun)   
(note: I am gonna update this on my own computer and completely forget to on github, email me jonte.fry@gmail.com if you really desparately want an update)                            

# Motivation
I was learning scheme and thought that the basic syntax was easy enough to be able to replicate for fun.                            
I do not have much of an understanding of the macro system or the s-expression system of lisp so I just duplicated the basic syntax and went from there                         
While writing the Runner I decided that I wanted there to not be too many axiomatic functions (the functions that are defined outside of the language)                         

# How To Run
Make sure to run pip3 install pymonad before running                            
Download all of the files and run python3 Main.py \[optional file name\]                             
This will launch a repl where you can input commands                                   
(note: I don't know how to run files from other folders as even if the files where compiled it still needs access to stdlib.st)                        

# Basic Syntax
The syntax is very simple. (\[function\] \[argument\]) is used to call a function with an argument. 
Though for sanitys sake (\[function\] \[argument 1\] \[argument 2\] ...) expands to ((\[function\] \[argument 1\]) \[argument 2\]).                    
There are four types within this language. A number (preferably ints but not restricted to them), a string, a function and a bool.                  
A number can be written as the number, e.g: 2 (negative numbers are written as -3 with no space. if there is a space the program will do unintended behaviour and will likely crash). The stdlib (+,-,*,/) is *currently* written to only handle integers but, as the numbers are represented in the interpreter as python numbers, floats can be used in the wider language.                             
a string is written as text. If there is a space it will be parsed as two separate strings. e.g: fizz is a string by itself. fizz buzz are two strings. fizz_buzz is one string.
strings are the same as keywords, if a keyword exists it can no longer be used as a string without causing unintended behaviour.                            
A function is defined through the function (lambda \[argument\] \[expression\]). The function will take one argument and will then replace all of the copies of the argument name in the expression with the supplied argument. It will then evaluate and return the expression.         
A bool is written as true or false. It will be printed as True or False.                  
Comments are written in between ;                                      

# Axiomatic Functions (in Handlers.py)
define: (define \[keyword\] \[expression\]). Define defines a new keyword. Everytime that keyword appears in the code it will be replaced with the expression.                    
increment: (increment \[num\]). Increment takes a number and adds one to it.             
decrement: (decrement \[num\]). Decrement takes a number and minuses one from it. 
print: (print \[arg\]). Print takes an argument, prints it and returns it. note: This is the only function that does not memoize automatically. if print is inside another function and that function gets memoized out print may not be called.             
zero?: (zero? \[num\]). Returns true if num if zero and false otherwise.                  
raise: (raise \[msg\]). Will raise an exception with msg.                            
str_eq: (str_eq \[str1\] \[str2\]). Will return true if str1 == str2 else false                  
str_input: (str_input \[msg\]). Will print msg and get user input and return it as a string. This will *currently* be memoized out but it is planned to be fixed.                   
num_input: (num_input \[msg\]). the same as str_input except it will return the input as a number.                           
true?: (true? \[bool\]). Will return true if bool is true and false if bool is anything else. This is here because I am scared of pythons truthy falsy values but I have not needed to use it yet.                    
                                 
All of the axiomatic functions below here will get there arguments passed without them being evaluated first. These functions need to be passed all of their functions all at once (note: might not be true).                             
lambda: *explained earlier*                                 
if: (if \[bool\] \[expr1\] \[expr2\]). If bool then it will evaluate and return expr1 else it will evaluate and return expr2.                        
let: (let \[arg\] \[val\] \[expr\]). will replace all occurences of arg in expr with the evaluated results of val and then evaluate and return expr.                      
begin: (begin \[expr1\] \[expr2\] ... \[exprN\]). This will evaluate expression 1 then expression 2 all the way to expression N and return the results of expression N.                      
# TO-DO
Write a better memoization system that handles io properly.                 
Write a better string system                                
Add macros (functions that get called without evaluating their parameters (although that's not what a macro is in lisp it's easier to do)                      
Write a naming convention.                           
Add better repl ux. (e.g: pressing up and down to cycle through the stack of previous inputs).                               
Lazy Evaluation?                     
Write documentation for stdlib.st                
Add more comments                            
Fix the bug that is preventing me from re-writing functions in SKI calculus (probably something to do with single character function names)                                     

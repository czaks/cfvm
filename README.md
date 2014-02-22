CFVM
====

A toy stack-based interpreted virtual machine. Actually, stack of stacks
based.

It aims to be as minimal as possible, so that it would be easy to implement.

We try to offload as much as possible to a stdlib.

CFVM runs a language called CF, which is inspired by Forth and is similar to
Joy. It uses Reverse Polish Notation.


Syntax
------
The CF language is syntaxless. It is lexed just by ```split(/\s+/)```.


Types
-----
- Symbol: ```:symbol```
  - Symbol is an immutable string, just like a Ruby symbol.
- Integer: ```6```
  - Integers can be manipulated just like in every modern language.
- Code block: ```[ 2 7 + ]```
  - Code blocks can be executed using ```exec```
- Stack: ```( 1 2 3 )```
  - Stacks can be concatenated using ```+```
  - Stacks can be compared using ```==```
  - Stacks can be entered using ```enter``` and left using ```exit```.
   

Environment
-----------
An environment is a map of symbols. You can assign code block or a
variable in the following ways:
- ```[ + ] :plus def```
- ```5 :five def```

...or using a reversed notation:
- ```:plus [ + ] defun```
- ```:five 5 defun```

Environment can be called simply:
- ```five five plus``` (would yield ```10```)

Environment members can be overloaded at any time.

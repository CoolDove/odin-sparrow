## This is a lisp interpreter made in odin-lang.

# SYNTAX

## basic

```lisp
(prog
    (def PI 3.14159)
    (def circle-area (radius)
        (mul PI radius radius)
    )
    (def diameter 4)
    (circle-area (mul diameter 0.5))
)

```

## Deal with VA_ARGS
```lisp

(prog
    (def multiple-add (a #va_args)
        (def result 0)
        (foreach i #va_args ;; maybe...
            (set result (dove/add result i))
        )
        result
    )
)

```

## Progress
- Tokenize and parser, get a AST from source code.
- Simple evaluation.
- Global environment, and define variable.

## Targets
- Has `main` proc
- Bind functions in c language lib

## FIX
- [ ] Cannot define empty-params function
- [ ] Destroy object in the symbol map when it was redefined to another value.

## TODO
- [x] Code Clean & Restructure.
- [x] Function destroying.
- [x] Add AST struct.
- [x] Interact mode
- [x] va_args
- [x] Polish tokenizer and parser.
	- [x] Take #-prefixed symbol as builtin symbol, like #va_args, #number, #string, #nil, #symbol
	- [x] Tokenize `*+-/<>` as symbols.
- [ ] Flow Control(if, while...), bool type.
- [ ] Syntax sugar (switch, for...).
- [ ] String Operations.
- [ ] List Operations.
- [ ] Error Object.
- [ ] Command line execution.
- [ ] System args


## special 
    +-*/

## basic

## seperator
    Can use "-_/" as seperators. But cannot used as the first rune.

## prefix
- `#` built-in symbols
> #va_args ...

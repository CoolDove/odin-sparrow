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

## TODO

- [x] Code Clean & Restructure.
- [x] Function destroying.
- [ ] Interact mode
- [ ] Polish tokenizer and parser.
	- [ ] Take #-prefixed symbol as builtin symbol, like #va_args, #number, #string, #nil, #symbol
	- [ ] Tokenize `*+-/<>` as symbols.
- [ ] Flow Control(if, for...).
- [ ] Add AST struct.
- [ ] String Operations.
- [ ] Error Object.

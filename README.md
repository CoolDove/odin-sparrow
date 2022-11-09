## This is a lisp interpreter made in odin-lang.



## syntax like

```lisp
(prog
	(def dove/add (a b)
		"an optional description"
		(add a b)
	)

    (dove/add 12 13)

)
(def-fun main)

```

## Progress
- Tokenize and parser, get a AST from source code.
- Simple evaluation.
- Global environment, and define variable.

## Targets
- Has `main` proc
- Bind functions in c language lib

## Doing
- [ ] Better way to pass in args while calling functions.(pre-define symbols in environment). Maybe another function type should be added for va_args.
- [ ] obj_destroy for Function object
- [ ] Add AST struct.
- [ ] !! Write a copy map.
- [x] !!! Research odin mem things, make a `obj_copy`, this is important. It should recursively copy an object(together with its children, that's what `recursively` means) to another one, with a specified allocator.
- [x] obj_destroy

## Todo
- [ ] default function reg/call
- [ ] add object type: boolean
- [x] parsing: comment, use `;` to start a comment(till the line end)


## This is a lisp made in odin-lang.



## syntax like

```

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
- [ ] Add AST struct.
- [ ] !!! Research odin mem things, make a `obj_copy`, this is important. It should recursively copy an object(together with its children, that's what `recursively` means) to another one, with a specified allocator.
- [ ] !! Write a copy map.

## Todo
- [ ] default function reg/call
- [ ] add object type: boolean
- [x] parsing: comment, use `;` to start a comment(till the line end)


## This is a lisp made in odin-lang.



## syntax like

```

(def-fun dove/add (TInt TInt) (TInt)
    "a description"
)

(def-fun main)

```

## Thoughts
There are just `data` in lisp, so maybe i shouldn't seperate Tree and Object


## targets
- Has `main` proc
- Bind functions in c language lib


## todo

doing:
- [x] implement the eval of built-in functions
- [x] symbol map
- [x] built-in function reg/call
- [ ] default function reg/call
- [ ] add object type: boolean
- [x] parsing: comment, use `;` to start a comment(till the line end)
- [ ] Check out odin Allocator things, to optimize the memory management.

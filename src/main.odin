package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:unicode/utf8"


// !FIXME(Dove): Comment parsing failed

main :: proc () {
	sparrow();
}

print_label :: proc(label : string) {
	fmt.printf("\n%s:\n-----------------\n", label);
}

sparrow :: proc() {
	defer fmt.println("==PROGRAM END==");

	program = prog_init_program();
	defer prog_release_program(program);

	print_label("Source");
	fmt.println(test_source);

	base := prog_eval_source(test_source, program);

	fmt.println("base eval: ", base);
}

test_source :: `
(prog
    (def PI 3.14159)
    (def circle-area (radius)
        (mul PI radius radius)
    )
    (def diameter 4)
    (circle-area (mul diameter 0.5))
)
`

/*
(prog
	(def add (a b #va_args)
		(print va_args)
	)
    (add print "hello, world")
)
*/

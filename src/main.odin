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
	defer fmt.println("PROGRAM END");

	prog_init_program();
	defer prog_release_program();

	print_label("Source");
	fmt.println(test_source);

	parser := parser_make(test_source);
	defer parser_release(parser);

	tokenize(parser);

	// print_label("Tokens");
	// show_tokens(parser);

	print_label("Abstract Syntax Tree");
	tree, parse_result := parse(parser);
	if parse_result.type == .Good {
	    show_tree(&tree);
	} else {
		fmt.println("failed to parse");
		return;
	}

	// print_label("Eval");
	eval_result := eval_tree(tree, program.global);
	fmt.println(eval_result);
}

test_source :: `
(prog
    (def PI 3.14159)

    (def circle-area (radius)
        (mul PI radius radius)
    )

    (circle-area 2)
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

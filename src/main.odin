package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:unicode/utf8"

main :: proc () {
	sparrow();
}

print_label :: proc(label : string) {
	fmt.printf("\n%s:\n-----------------\n", label);
}

sparrow :: proc() {
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
	tree, result := parse(parser);
	if result.type == .Good {
	    show_tree(tree);
	} else {
		fmt.println("failed to parse");
	}
	if tree == nil {
		fmt.println("tree is nil");
	}

	print_label("Eval");
	fmt.println(eval_tree(tree));
}

test_source :: `
(prog
	(div (mul 2 8) (add 8 8))
	(add 12 12)
)
`

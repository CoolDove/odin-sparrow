package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:unicode/utf8"

main :: proc () {
	fmt.println("source:");
	fmt.println(test_source);
	fmt.println("-----------------");
	fmt.println("");

	tree : Tree;
	parser := parser_make(test_source);
	parser_parse(parser, &tree);

    for tok in parser.tokens {
		fmt.println("token: ", tok);
	}
	
}

test_source :: `
(def-fun dove/add (TInt TInt) (TInt)
    "a description"
    (add 0.12 13.12138)
)
`

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
	parser := Parser{utf8.string_to_runes(test_source), 0}
	parser_parse(&parser, &tree);
}

test_source :: `
(def-fun dove/add (TInt TInt) (TInt)
    "a description"
    (add 0.12 13.12138)
)
`

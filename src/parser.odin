package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:unicode/utf8"

Parser :: struct {
	runes : []rune,
	ptr : u32,
}

// TODO(Dove):
// tokenize: string, symbol prefix
// 
parser_parse :: proc(using parser : ^Parser, tree : ^Tree) -> ParseResult {
	p :int= 0;
	source_len := len(runes);

	tok := Token{.None, "just an empty token, useless"};
	err := TokenError.None;
	for tok.type != .End {
		tok, err = parser_next_token(parser);
		if err == .None {
		    fmt.println(tok);
		} else {
		    fmt.println(err);
			return ParseResult{"bad"};
		}

	}

	return ParseResult{"good"};
}
ParseResult :: struct {
    message : string
}

Tree :: struct {
	child, brother : ^Tree,
	value : TreeValue
}

TreeValue :: union {
	int, string
}

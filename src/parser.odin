package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:unicode/utf8"

Parser :: struct {
	runes : []rune,
	ptr : u32,
	tokenized : bool,
	tokens : [dynamic]Token
}

parser_make :: proc(source:string, allocator := context.allocator) -> ^Parser{
	p := new(Parser);
	using p;
	runes = utf8.string_to_runes(test_source);
    ptr = 0;
	tokens = make([dynamic]Token, allocator);
	return p;
}
parser_release :: proc(using parser:^Parser) {
	delete(tokens);
	free(parser);
}

parser_parse :: proc(using parser : ^Parser, tree : ^Tree) -> ParseResult {
	err := tokenize(parser);
	return ParseResult{"good"};
}

ParseResult :: struct {
    message : string
}

Tree :: struct {
	child, brother : ^Tree,
	value : TreeValue
}

TreeType :: enum {
	Number, String, Function
}

TreeValue :: union {
	f64, string, 
}

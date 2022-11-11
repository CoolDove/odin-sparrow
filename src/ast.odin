package main

import "core:fmt"
import "core:mem"
import "core:os"
import "core:strings"
import "core:unicode/utf8"

AST :: struct {
	root : Object,
	// For storing list objects' data buffer.
	_tree_stack     : mem.Stack,
	_tree_allocator : mem.Allocator,
}

ast_make :: proc(buffer_size := 10240) -> ^AST {
    ast := new(AST);
	using ast;
	root = Object{.Nil, nil};
	buffer, err := mem.alloc_bytes(buffer_size);
	if err != .None {
		fmt.println("Error while making parser, failed to allocate memory for the parser.");
		return nil;
	}
	mem.stack_init(&_tree_stack, buffer);
	_tree_allocator = mem.stack_allocator(&_tree_stack);
	return ast;
}

ast_destroy :: proc(using ast : ^AST) {
	delete(_tree_stack.data);
}

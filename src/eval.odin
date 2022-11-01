package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:unicode/utf8"

import "core:log"

eval_tree :: proc(using tree : ^Tree) -> Object {
	switch type {
	case .MetaList:
		return _eval_metalist(tree);
	case .Number:
		return Object{.Number, tree.value.(f64)};
	case .Symbol:
		return prog_get_symbol(tree);
	case .String:
		return Object{.String, tree.value.(string)};
	}
	return Object{};
}

// NOTE(Dove):
// Currently, we take metalist as a function call.
// And it only supports some basic built-in functions.
_eval_metalist :: proc(using tree : ^Tree) -> Object {
	assert(tree.type == .MetaList);
	if tree.child == nil { return Object{.Nil, nil} }
	
	func_node := tree.child;
    assert(func_node != nil && func_node.type == .Symbol);

    func_symbol, ok := prog_get_symbol(func_node);
	assert(ok && func_symbol.type == .Function);
	function := func_symbol.value.(^Function);
	param := func_node.next;

	if function.type == .BuiltIn {
		process := function.data.(BuiltInFunction);
		return process(param);
	} else if function.type == .Default {
		func_tree := function.data.(^Tree);
		return eval_tree(func_tree);
	}

	return Object{.Nil, nil};
}

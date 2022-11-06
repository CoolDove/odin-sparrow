package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:unicode/utf8"

import "core:log"

eval_tree :: proc(using tree : ^Object) -> Object {
	#partial switch type {
	case .List:
		return _eval_list(tree);
	case .Number:
		return build_object(.Number, tree.value.(f64));
	case .Symbol:
		return prog_get_symbol(tree);
	case .String:
		return build_object(.String, tree.value.(string));
	}
	return build_object();
}

// NOTE(Dove):
// Currently, we take list as a function call.
// And it only supports some basic built-in functions.
// Maybe we'll have a `eval_with_params`?
_eval_list :: proc(using tree : ^Object) -> Object {
	assert(tree.type == .List);
	if tree.child == nil { return build_object(.Nil, nil) }
	func_node := tree.child;
	if func_node == nil { return build_object(.Nil, nil) }
	if func_node.type != .Symbol {
		fmt.printf("Error: invalid function: {}", func_node);
		return build_object(.Nil, nil);
	}
    func_symbol, ok := prog_get_symbol(func_node);

	if !ok {
		fmt.printf("Error: invalid symbol: {}", func_node);
		return build_object(.Nil, nil);
	} else if func_symbol.type != .Function {
		fmt.printf("Error: invalid function: {}", func_node);
		return build_object(.Nil, nil);
	}
	
	function := func_symbol.value.(^Function);
	param := func_node.next;

	if function.type == .BuiltIn {
		process := function.data.(BuiltInFunction);
		return process(param);
	} else if function.type == .Default {
		func_tree := function.data.(^Object);
		return eval_tree(func_tree);
	}

	return build_object(.Nil, nil);
}

package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:unicode/utf8"

import "core:log"

Object :: struct {
	type : ObjectType,
	value : ObjectValue
}
ObjectType :: enum {
	Nil, Number, String
}
ObjectValue :: union {
	f64,// Number
	string,// String/Symbol
	i64// maybe some value
}

eval_tree :: proc(using tree : ^Tree) -> Object {
	switch type {
	case .MetaList:
		return _eval_metalist(tree);
	case .Number:
		return Object{.Number, tree.value.(f64)};
	case .Symbol:
		return prog_symbol_var(tree);
	case .String:
		return Object{.String, tree.value.(string)};
	}
	return Object{};
}

// NOTE(Dove):
// Currently, we take metalist as a function call.
// And it only supports some basic built-in functions.
_eval_metalist :: proc(using tree : ^Tree) -> Object {
	func := tree.child;

    assert(func != nil && func.type == .Symbol);

	func_name := func.value.(string);
	param := func.next;
	if func_name == "add" {
		result :f64= 0;
		for param != nil {
			v := eval_tree(param);
			assert(v.type == .Number);
			result += v.value.(f64);
			param = param.next;
		}
		return Object{.Number, result};
	} else if func_name == "mul" {
		result :f64= 1;
		for param != nil {
			v := eval_tree(param);
			assert(v.type == .Number);
			result *= param.value.(f64);
			param = param.next;
		}
		return Object{.Number, result};
	}
	return Object{.Nil, nil};
}

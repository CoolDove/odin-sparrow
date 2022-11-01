package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:mem"
import "core:unicode/utf8"

Object :: struct {
	type : ObjectType,
	value : ObjectValue
}
ObjectType :: enum {
	Nil, Number, String, Function
}
ObjectValue :: union {
	f64,   // Number
	string,// String/Symbol
	i64,   // maybe some value
	^Function,
}

BuiltInFunction :: proc(tree: ^Tree)->Object;

Function :: struct {
	type : FuncType,
	data : union {^Tree, BuiltInFunction}
}

FuncType :: enum {
	BuiltIn, Default
}

// @Program
SparrowProgram :: struct {
	symbols     : map[string]Object,
    functions   : [dynamic]^Function,
	_allocator  : mem.Allocator,
	_symbol_allocator : mem.Allocator,
}

program : SparrowProgram;

prog_init_program :: proc(allocator := context.allocator) {
	using program;
	_allocator = allocator;
	symbols   = make(map[string]Object, 128, allocator);
	functions = make([dynamic]^Function, 128, allocator);
	reg_function("add", builtin_add);
	reg_function("sub", builtin_sub);
	reg_function("mul", builtin_mul);
	reg_function("div", builtin_div);
	reg_function("prog", builtin_prog);
	
}
prog_release_program :: proc(allocator := context.allocator) {
	using program;
	delete(symbols);
	delete(functions);
}

prog_get_symbol :: proc(tree : ^Tree) -> (obj : Object, ok : bool) #optional_ok  {
	assert(tree.type == .Symbol);
	return program.symbols[tree.value.(string)];
}

reg_function_default :: proc(name: string, proc_node : ^Tree) {
	using program;
	function := new(Function);
	function.type = .Default;
	function.data = proc_node;
	append(&functions, function);
	symbols[name] = Object{.Function, function};
}
reg_function_builtin :: proc(name: string, process : BuiltInFunction) {
	using program;
	function := new(Function);
	function.type = .BuiltIn;
	function.data = process;
	append(&functions, function);
	symbols[name] = Object{.Function, function};
}
reg_function :: proc {
	reg_function_default,
	reg_function_builtin,
}

reg_alias :: proc(name: string, proto_name : string) {
	using program;
	if proto_name in symbols {
        symbols[name] = symbols[proto_name];
	}
}

builtin_add :: proc(param : ^Tree) -> Object {
	result :f64= 0;
	p := param;
	for p != nil {
		v := eval_tree(p);
		assert(v.type == .Number);
		result += v.value.(f64);
		p = p.next;
	}
	return Object{.Number, result};
}
builtin_mul :: proc(param : ^Tree) -> Object {
	result :f64= 1;
	p := param;
	for p != nil {
		v := eval_tree(p);
		assert(v.type == .Number);
		result *= v.value.(f64);
		p = p.next;
	}
	return Object{.Number, result};
}
builtin_sub :: proc(param : ^Tree) -> Object {
	if param == nil { return Object{.Number, 0}; }

	p := param;
    result := p.value.(f64);
	for p != nil {
		v := eval_tree(p);
		assert(v.type == .Number);
		result *= v.value.(f64);
		p = p.next;
	}
	return Object{.Number, result};
}
builtin_div :: proc(param : ^Tree) -> Object {
    assert(param != nil);
	p := param;
	if p.next == nil { return Object{.Number, 0}; }
	result := eval_tree(p).value.(f64);
	p = p.next;
	for p != nil {
		v := eval_tree(p);
		result /= v.value.(f64);
		p = p.next;
	}
	return Object{.Number, result};
}
builtin_prog :: proc(param : ^Tree) -> Object {
	p := param;
	v := Object{.Nil, nil};
	for p != nil {
		v = eval_tree(p);
		p = p.next;
	}
	return v;
}

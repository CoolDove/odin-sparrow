package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:mem"
import "core:unicode/utf8"

Object :: struct {
	type : ObjectType,
	value : ObjectValue,
	autoeval : bool,
    using tree_node : Tree(Object)
}
Tree :: struct($T: typeid) {
	child, next, parent : ^T,
}

ObjectType :: enum {
	Nil, Number, String, List, Symbol, Function// , ErrorMsg
}
ObjectValue :: union {
	f64,        // Number
	string,     // String/Symbol
	i64,        // maybe some value
	^Function,
}

List :: struct {
	data : Object,
	next : ^Object
}

build_object :: proc(type := ObjectType.Nil, value :ObjectValue= nil, autoeval := true) -> Object {
	return Object{type, value, autoeval, Tree(Object){}};
} 


BuiltInFunction :: proc(tree: ^Object)->Object;

Function :: struct {
	type : FuncType,
	data : union {^Object, BuiltInFunction}
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
	symbols   = make(map[string]Object,  128, allocator);
	functions = make([dynamic]^Function, 128, allocator);

    // Register built-in functions.
	reg_function("add", builtin_add);
	reg_function("sub", builtin_sub);
	reg_function("mul", builtin_mul);
	reg_function("div", builtin_div);
	reg_function("prog", builtin_prog);
	
	reg_function("set", builtin_set);
	reg_function("defun", builtin_defun);

}
prog_release_program :: proc() {
	{
		using program;
		context.allocator = _allocator;
		delete(symbols);
		delete(functions);
	}
}

prog_get_symbol :: proc(tree : ^Object) -> (obj : Object, ok : bool) #optional_ok  {
	assert(tree.type == .Symbol);
	return program.symbols[tree.value.(string)];
}

reg_function_default :: proc(name: string, proc_node : ^Object) {
	using program;
	function := new(Function);
	function.type = .Default;
	function.data = proc_node;
	append(&functions, function);
	symbols[name] = build_object(.Function, function);
}
reg_function_builtin :: proc(name: string, process : BuiltInFunction) {
	using program;
	function := new(Function);
	function.type = .BuiltIn;
	function.data = process;
	append(&functions, function);
	symbols[name] = build_object(.Function, function);
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


set_variable :: proc(name: string, value: Object) {
    program.symbols[name] = value;
}
delete_variable :: proc(name: string) {
    symb, ok := program.symbols[name];
	if ok { delete_key(&program.symbols, name); }
}




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

builtin_add :: proc(param : ^Object) -> Object {
	result :f64= 0;
	p := param;
	for p != nil {
		v := eval_tree(p);
		assert(v.type == .Number);
		result += v.value.(f64);
		p = p.next;
	}
	return build_object(.Number, result);
}
builtin_mul :: proc(param : ^Object) -> Object {
	result :f64= 1;
	p := param;
	for p != nil {
		v := eval_tree(p);
		assert(v.type == .Number);
		result *= v.value.(f64);
		p = p.next;
	}
	return build_object(.Number, result);
}
builtin_sub :: proc(param : ^Object) -> Object {
	if param == nil { return build_object(.Number, 0); }

	p := param;
    result := p.value.(f64);
	for p != nil {
		v := eval_tree(p);
		assert(v.type == .Number);
		result *= v.value.(f64);
		p = p.next;
	}
	return build_object(.Number, result);
}
builtin_div :: proc(param : ^Object) -> Object {
    assert(param != nil);
	p := param;
	if p.next == nil { return build_object(.Number, 0); }
	result := eval_tree(p).value.(f64);
	p = p.next;
	for p != nil {
		v := eval_tree(p);
		result /= v.value.(f64);
		p = p.next;
	}
	return build_object(.Number, result);
}
builtin_prog :: proc(param : ^Object) -> Object {
	p := param;
	v := build_object(.Nil, nil);
	for p != nil {
		v = eval_tree(p);
		p = p.next;
	}
	return v;
}
builtin_defun :: proc(param : ^Object) -> Object {
	p := param;
	v := build_object(.Nil, nil);
	for p != nil {
		v = eval_tree(p);
		p = p.next;
	}
	return v;
}


// NOTE(Dove): Write this to combine SyntaxTreeNode with Object together, much more lisp style.

builtin_eval :: proc(using tree : ^Object, autoeval : bool) -> Object {
	assert(tree != nil);
	switch type {
	case .Number:
		return build_object(.Number, tree.value.(f64));
	case .Symbol:
		return prog_get_symbol(tree);
	case .String:
		return build_object(.String, tree.value.(string));
	case .Function:
		return build_object(.Function, tree.value.(^Function));
	case .List:
        if autoeval {// Take the list as a function call.
			elem := tree.child;
			params := tree.child.next;
			if elem == nil { return build_object(.Nil, nil); }
			if elem.type == .Function {
				func_symbol, ok := prog_get_symbol(elem);
				if ok && func_symbol.type == .Function {
					function := func_symbol.value.(^Function);
					switch function.type {
					case .BuiltIn :
						process := function.data.(BuiltInFunction);
						process(params);
					case .Default :
						return build_object(.Nil, nil);
					}
				}
			} else {
			}
		} else {
		}
    case .Nil:
		return build_object(.Nil, nil);
	}

	return build_object(.Nil, nil);
}




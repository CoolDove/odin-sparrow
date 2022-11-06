package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:mem"
import "core:unicode/utf8"

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

builtin_set :: proc(param : ^Object) -> Object {
	if param == nil { return build_object(.Nil, nil); }
	if param.next == nil {// Too less params.
		fmt.printf("Error, wrong number of params for function: set.\n");
		return build_object(.Nil, nil);
	}
	value_tree := param.next;
	if value_tree.next != nil {// Too much params.
		fmt.printf("Error, wrong number of params for function: set.\n");
		return build_object(.Nil, nil);
	}

	value := eval_tree(value_tree);
	set_variable(param.value.(string), value);
	
	return value;
}

// NOTE(Dove): Write this to combine SyntaxTreeNode with Object together, much more lisp style.

builtin_eval :: proc(using tree : ^Object, eval : bool) -> Object {
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
        if eval {// Take the list as a function call.
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

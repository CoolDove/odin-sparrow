package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:mem"
import "core:unicode/utf8"

builtin_add :: proc(args : []Object, env: ^Environment) -> Object {
	result : f64 = 0;
	for arg in args {
		assert(arg.type == .Number,
			   fmt.tprintf("Invalid argument: {}", arg));
		value := arg.value.(f64);
		result += value;
	}
	
	return Object{.Number, result};
}
builtin_mul :: proc(args : []Object, env: ^Environment) -> Object {
	result :f64= 1;
	for arg in args {
		assert(arg.type == .Number);
		result *= arg.value.(f64);
	}
	return Object{.Number, result};
}
// // builtin_sub :: proc(param : ^Object) -> Object {
	// // if param == nil { return build_object(.Number, 0); }
// // 
	// // p := param;
    // // result := p.value.(f64);
	// // for p != nil {
		// // v := eval_tree(p);
		// // assert(v.type == .Number);
		// // result *= v.value.(f64);
		// // p = p.next;
	// // }
	// // return build_object(.Number, result);
// // }
// // builtin_div :: proc(param : ^Object) -> Object {
    // // assert(param != nil);
	// // p := param;
	// // if p.next == nil { return build_object(.Number, 0); }
	// // result := eval_tree(p).value.(f64);
	// // p = p.next;
	// // for p != nil {
		// // v := eval_tree(p);
		// // result /= v.value.(f64);
		// // p = p.next;
	// // }
	// // return build_object(.Number, result);
// // }
// // builtin_prog :: proc(param : ^Object) -> Object {
	// // p := param;
	// // v := build_object(.Nil, nil);
	// // for p != nil {
		// // v = eval_tree(p);
		// // p = p.next;
	// // }
	// // return v;
// // }
// // builtin_defun :: proc(param : ^Object) -> Object {
	// // p := param;
	// // v := build_object(.Nil, nil);
	// // for p != nil {
		// // v = eval_tree(p);
		// // p = p.next;
	// // }
	// // return v;
// // }
// // builtin_set :: proc(param : ^Object) -> Object {
	// // if param == nil { return build_object(.Nil, nil); }
	// // if param.next == nil {// Too less params.
		// // fmt.printf("Error, wrong number of params for function: set.\n");
		// // return build_object(.Nil, nil);
	// // }
	// // value_tree := param.next;
	// // if value_tree.next != nil {// Too much params.
		// // fmt.printf("Error, wrong number of params for function: set.\n");
		// // return build_object(.Nil, nil);
	// // }
// // 
	// // value := eval_tree(value_tree);
	// // set_variable(param.value.(string), value);
// // 	
	// // return value;
// // }
// // 
// // builtin_print :: proc(param: ^Object) -> Object {
	// // if param == nil || param.next != nil {
		// // fmt.println("Error, wrong arguments number.");
		// // return build_object(.Nil, nil);
	// // }
// // 
	// // value := eval_tree(param);
// // 
	// // fmt.println(object_to_string(&value));
// // 
	// // return value;
// // }
// // 
// // builtin_eval :: proc(param : ^Object) -> Object {
	// // if param == nil || param.next != nil { return build_object(.Nil, nil); }
	// // return eval_tree(param);
// // }
// // 
// // // @InComplete: Make a data list with this function.
// // builtin_list :: proc(param : ^Object) -> Object {
	// // list_root := build_object(.List, nil, false);
	// // ptr := param;
// // 
	// // for ptr != nil {
// // 
	// // }
// // 
// // 	
	// // return nil;
// // }

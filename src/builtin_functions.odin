package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:mem"
import "core:unicode/utf8"

builtin_add :: proc(args : []Object, env: ^Environment) -> Object {
	result : f64 = 0;
	for arg in args {
		assert(arg.type == .Number, fmt.tprintf("Invalid argument: {}", arg));
		value := arg;
		result += value.value.(f64);
	}
	
	return Object{.Number, result};
}
builtin_mul :: proc(args : []Object, env: ^Environment) -> Object {
	result :f64= 1;
	for arg in args {
		assert(arg.type == .Number, fmt.tprintf("Arg should be Number, is: {}\n", arg.type));
		result *= arg.value.(f64);
	}
	return Object{.Number, result};
}

// @Temporary: To test named args.
builtin_two_add :: proc(args : []Object, env: ^Environment) -> Object {
    a, ok0 := env_resolve(env, "a");
	assert(ok0, fmt.tprintf("Undefined param: x\n"));
    b, ok1 := env_resolve(env, "b");
	assert(ok1, fmt.tprintf("Undefined param: b\n"));
	assert(a.type == .Number && b.type == .Number, "Invalid arguments, should be (a:number, b:number)");
	
	result := a.value.(f64) + b.value.(f64);
	return Object{.Number, result};
}

// @Temporary: To test va_args;
builtin_test_va_args :: proc(args : []Object, env: ^Environment) -> Object {
    va_args := env_resolve(env, "#va_args");

	assert(va_args.type == .List, "Invalid va_args.");

	va_args_data := va_args.value.(List).data;
	for arg in va_args_data {
		fmt.println(arg);
	}
	return Object{.Nil, nil};
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

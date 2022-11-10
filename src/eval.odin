package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:unicode/utf8"


eval_tree :: proc(using tree : Object, env : ^Environment) -> Object {
	defer obj_destroy(tree);// If protected, cannot destroy.
	#partial switch type {
	case .List:
		list := tree.value.(List).data[:];
        assert(list[0].type == .Symbol, "Invalid symbol.")

		symbol_name := list[0].value.(string);

		function_symbol, ok := env_resolve(env, symbol_name);

		if !ok {
			fmt.printf("Error! invalid symbol: %s.\n", symbol_name);
			return Object{};
		}
		if function_symbol.type != .Function {
			fmt.printf("Error! symbol: %s is not a function.\n", symbol_name);
			return Object{};
		}

		function := function_symbol.value.(^Function);

		// Function call
		if function.type == .BuiltIn {
			process := function.body.(BuiltInFunction);

			args := make([dynamic]Object, 0, len(list) - 1);
			defer delete(args);

			for ind in 1..<len(list) {
				append(&args, eval_tree(list[ind], env));
			}

			// NOTE(Dove): Function Calling Environment
			// `function.env` is the env where the function is defined.
			// Create a new environment for the function's inner calculation.
			funcenv := env_make(function.env);
			defer env_destroy(funcenv);

			pass_args_into_environment(funcenv, args[:], function.params[:]);
			return process(args[:], funcenv);
		} else if function.type == .Default {
			return Object{};
		}
		
		// if symbol_name == "add" {// @Temporary: Should be function calling later.
			// result : f64 = 0;
			// for e in list[1:] {
				// evaled := eval_tree(e, env);
				// assert(evaled.type == .Number, "Invalid type");
				// result += evaled.value.(f64);
			// }
			// return Object{.Number, result};
		// } else if symbol_name == "prog" {
			// result := Object{.Nil, nil};
			// subenv := env_make(env);
			// defer env_destroy(subenv);
			// for prog in list[1:] {
				// result = eval_tree(prog, subenv);
			// }
			// return result;
		// } else if symbol_name == "def" {
			// // TOTO(Dove): args check
			// name := list[1].value.(string);
			// obj := obj_copy(eval_tree(list[2], env), true);
			// env_define(env, name, obj);
			// return obj;
		// } else if symbol_name == "list" {
			// sublist_data := make([dynamic]Object);
			// for arg in list[1:] {
				// evaled := eval_tree(arg, env);
				// append(&sublist_data, evaled);
			// }
// 
			// sublist := List{sublist_data, false};
			// return Object{.List, sublist};
		// }

		// obj_destroy(tree);

		return Object{.Nil, nil};
	case .Number:
		return Object{ .Number, tree.value.(f64) };
	case .Symbol:
		symbol, ok := env_resolve(env, tree.value.(string));
		if ok { return symbol; }
		return Object{};
	case .String:
		return Object{ .String, tree.value.(string) };
	}
	return Object{};
}

@(private="file")
pass_args_into_environment :: proc(env: ^Environment, args: []Object, params: []string) -> bool {
	args_length := len(args);
	for i in 0..<args_length {
		env_define(env, params[i], args[i]);
	}
	return true;
}


// 
// 
// @(private="file")
// _eval_list :: proc(using tree : ^Object) -> Object {
	// assert(tree.type == .List);
// 
	// list := tree.value.(List);
// 
	// using list;
	// length := len(&data);
	// if length == 0 { return Object{.Nil, nil} }
// 
	// assert(data[0].type == .Symbol,
			// fmt.tprintf("Invalid syntax, should be a symbol instead of {}", data[0].type));
// 
	// symbol_name := data[0].value.(string);
// 
	// args : [dynamic]Object;
	// defer delete(args);
// 
	// for i in 1..<len(data) {
		// evaled := eval_tree(&data[i]);
		// append(&args, evaled);
	// }
// 
	// if symbol_name == "add" {
		// return builtin_add(args);
	// }
// 
	// return Object{.Nil, nil};
// 
	// // function_obj, ok := env.data[symbol_name];
	// // if !ok {
		// // assert(true,
				// // fmt.tprintf("Invalid symbol: {} is not defined.", symbol_name));
		// // return Object{.Nil, nil};
	// // }
// 
	// // if function_obj.type == .BuiltIn {
		// // func := function_obj.body.(BuiltInFunction);
		// // return func(params);
	// // }
// 	
// 
	// // if func_node == nil { return build_object(.Nil, nil) }
	// // if func_node.type != .Symbol {
		// // fmt.printf("Error: invalid function: {}", func_node);
		// // return build_object(.Nil, nil);
	// // }
    // // func_symbol, ok := prog_get_symbol(func_node);
// 
	// // if !ok {
		// // fmt.printf("Error: invalid symbol: {}", func_node);
		// // return build_object(.Nil, nil);
	// // } else if func_symbol.type != .Function {
		// // fmt.printf("Error: invalid function: {}", func_node);
		// // return build_object(.Nil, nil);
	// // }
// // 	
	// // function := func_symbol.value.(^Function);
	// // param := func_node.next;
// // 
	// // if function.type == .BuiltIn {
		// // process := function.data.(BuiltInFunction);
		// // return process(param);
	// // } else if function.type == .Default {
		// // func_tree := function.data.(^Object);
		// // return eval_tree(func_tree);
	// // }
// // 
	// // return build_object(.Nil, nil);
// }

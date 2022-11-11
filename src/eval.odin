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

        if symbol_name == "def" {
			args_len := len(list[1:]);
			if args_len == 2 {
				return define_variable(env, list[1:]);
			} else if args_len == 3 {
				return define_function(env, list[1:]);
			} else {
				return Object{};
			}
		}
		if symbol_name == "prog" {
			result := Object{.Nil, nil};
			subenv := env_make(env);
			defer env_destroy(subenv);
			for prog in list[1:] {
				result = eval_tree(prog, subenv);
			}
			return result;
		} else if symbol_name == "begin" {
			result := Object{.Nil, nil};
			for prog in list[1:] {
				result = eval_tree(prog, env);
			}
			return result;
		}

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
		args := make([dynamic]Object, 0, len(list) - 1);
		defer delete(args);

		for ind in 1..<len(list) {
			append(&args, eval_tree(list[ind], env));
			// append(&args, list[ind]);
		}

		// NOTE(Dove): Function Calling Environment
		// `function.env` is the env where the function is defined.
		// Create a new environment for the function's inner calculation.

		// `function.env == nil` means it's a built-in function
		parent_env := function.type == .BuiltIn ? env : function.env;
		funcenv := env_make(parent_env);
		defer env_destroy(funcenv);
		va_args := pass_args_into_environment(funcenv, args[:], function.params[:]);
		defer obj_destroy(va_args);

		if function.type == .BuiltIn {
			process := function.body.(BuiltInFunction);
			return process(args[:], funcenv);
		} else if function.type == .Default {
			body := function.body.(Object);
			return eval_tree(body, funcenv);
		}
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
pass_args_into_environment :: proc(env: ^Environment, args: []Object, params: []string) -> (va_args_list : Object) {
	// Deal with va_args here.
	// All the params after #va_args should be ignored, or error.
	// All the args after #va_args should be packed into a list, and defined as #va_args
	args_length := len(args);
	params_length := len(params);

	use_va_args := false;
	list : List;
	list.data = make([dynamic]Object);
	va_args_list = Object{};

	for i in 0..<args_length {

		if use_va_args {
			append(&list.data, obj_copy(args[i]));
		} else if i < params_length {
			if params[i] == "#va_args" {
				use_va_args = true;
				append(&list.data, obj_copy(args[i]));
			} else {
		        env_define(env, params[i], args[i]);
			}
		} else {
			fmt.println("Too much args.");
		}
	}

	if use_va_args {
		va_args_list = Object{.List, list};
		env_define(env, "#va_args", va_args_list);
	}

	return ;
}

define_variable :: proc (env: ^Environment, args: []Object) -> Object {
	name := args[0].value.(string);
	obj := obj_copy(eval_tree(args[1], env), true);
	env_define(env, name, obj);
	return obj;
}
define_function :: proc (env: ^Environment, args: []Object) -> Object {
    assert(args[0].type == .Symbol, fmt.tprintf("Invalid symbol: {}\n", args[0]));
	assert(args[1].type == .List, "Params list should be a list.");
	params_obj := args[1].value.(List).data;
	for param in params_obj {
		assert(param.type == .Symbol, fmt.tprintf("Invalid symbol: {}\n", param));
	}

	// args[0]: Symbol, function name
	// args[1]: List of Symbol, function params
	// args[2]: Any, function body
	
	function := new(Function);
	function.type = .Default;
	param_list := args[1].value.(List);
	params := make([dynamic]string, 0, len(param_list.data));
	for p in param_list.data {
		param_name := p.value.(string);
		append(&params, param_name);
	}
	function.params = params;
	function.body = obj_copy(args[2], true);
	function.env = env;

	function_obj := Object{.Function, function};
	env_define(env, args[0].value.(string), function_obj);
	
	return function_obj;
}
// 
// 
// @(private="file :: proc ")
// _eval: ^Environment_list :: proc(using tree : ^Object) -> Object {
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

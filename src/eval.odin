package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:unicode/utf8"


eval_tree :: proc(using tree : Object, env : ^Environment) -> Object {
	#partial switch type {
	case .List:
		list := tree.value.(List).data[:];
        assert(list[0].type == .Symbol, "Invalid symbol.")

		symbol := list[0].value.(string);
		
		if symbol == "add" {
			result : f64 = 0;
			for e in list[1:] {
				evaled := eval_tree(e, env);
				assert(evaled.type == .Number, "Invalid type");
				result += evaled.value.(f64);
			}
			return Object{.Number, result};
		} else if symbol == "def" {
			name := list[1].value.(string);
			// TODO(Dove): Should be a `copy_obj` function instead of `list[2]`.
			obj  := list[2];

			env_define(env, name, obj);
			return obj;
		}

	case .Number:
		return Object{ .Number, tree.value.(f64) };
	case .Symbol:
		symbol, ok := env_resolve(env, tree.value.(string));
		if ok { return symbol; }
		return Object{};
		// return prog_get_symbol(tree);
	case .String:
		return Object{ .String, tree.value.(string) };
	}
	return Object{};
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

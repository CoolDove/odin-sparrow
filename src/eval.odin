package main
// 
// import "core:fmt"
// import "core:os"
// import "core:strings"
// import "core:unicode/utf8"
// 
// import "core:log"
// 
// eval_tree :: proc(using tree : ^Object) -> Object {
	// #partial switch type {
	// case .List:
		// return _eval_list(tree);
	// case .Number:
		// return build_object(.Number, tree.value.(f64));
	// case .Symbol:
		// return prog_get_symbol(tree);
	// case .String:
		// return build_object(.String, tree.value.(string));
	// }
	// return build_object();
// }
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

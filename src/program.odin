package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:mem"
import "core:unicode/utf8"


// @Program
SparrowProgram :: struct {
    global : ^Environment,
}

// Global program object.
program : SparrowProgram;

prog_init_program :: proc(allocator := context.allocator) {
	using program;
    global = env_make(nil, allocator);

    // Register built-in functions.
	// reg_function("add", builtin_add);
	// reg_function("mul", builtin_mul);
	// reg_function("sub", builtin_sub);
	// reg_function("div", builtin_div);
	// reg_function("prog", builtin_prog);

	// reg_function("set", builtin_set);
	// reg_function("defun", builtin_defun);

	// reg_function("print", builtin_print);
}
prog_release_program :: proc() {
	env_destroy(program.global);
}
// 
// prog_get_symbol :: proc(tree : ^Object) -> (obj : Object, ok : bool) #optional_ok  {
	// assert(tree.type == .Symbol);
	// return program.symbols[tree.value.(string)];
// }
// 
// reg_function_default :: proc(name: string, proc_node : ^Object) {
	// using program;
	// function := new(Function);
	// function.type = .Default;
	// function.data = proc_node;
	// append(&functions, function);
	// symbols[name] = build_object(.Function, function);
// }
// reg_function_builtin :: proc(name: string, process : BuiltInFunction) {
	// using program;
	// function := new(Function);
	// function.type = .BuiltIn;
	// function.data = process;
	// append(&functions, function);
	// symbols[name] = build_object(.Function, function);
// }
// reg_function :: proc {
	// reg_function_default,
	// reg_function_builtin,
// }
// 
// reg_alias :: proc(name: string, proto_name : string) {
	// using program;
	// if proto_name in symbols {
        // symbols[name] = symbols[proto_name];
	// }
// }
// 
// 
// set_variable :: proc(name: string, value: Object) {
    // program.symbols[name] = value;
// }
// delete_variable :: proc(name: string) {
    // symb, ok := program.symbols[name];
	// if ok { delete_key(&program.symbols, name); }
// }

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
	reg_function("add", builtin_add, global, "#va_args");
	reg_function("mul", builtin_mul, global, "#va_args");
	reg_function("two-add", builtin_two_add, global, "a", "b");

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

reg_function_default :: proc(name: string, body : Object, env: ^Environment, params : ..string) {
	// TODO(Dove): reg_function_default
	// using program;
	// function := new(Function);
	// function.type = .Default;
	// function.data = proc_node;
	// append(&functions, function);
	// symbols[name] = build_object(.Function, function);
}

reg_function_builtin :: proc(name: string, process : BuiltInFunction, env: ^Environment, params : ..string) {
	using program;
	func := new(Function);
	func.type = .BuiltIn;
	func.params = make_params(params[:]);
	func.body = process;
	func.env = env;
	env_define(env, name, Object{.Function, func});
}

@(private="file")
make_params :: proc(names: []string, allocator:= context.allocator) -> [dynamic]string {
	context.allocator = allocator;
	params := make([dynamic]string, 0, len(names));
	for name in names {
		append(&params, name);
	}
	return params;
}

reg_function :: proc {
	reg_function_default,
	reg_function_builtin,
}

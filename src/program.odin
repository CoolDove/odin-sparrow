package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:mem"
import "core:unicode/utf8"

// @Program
SparrowProgram :: struct {
    global : ^Environment,
	trees  : [dynamic]^AST
}

// Global program object.
program : ^SparrowProgram;

prog_init_program :: proc(allocator := context.allocator) -> ^SparrowProgram {
	context.allocator = allocator;
	prog := new(SparrowProgram);
	using prog;
    global = env_make(nil, allocator);

	// # Math
    // Register built-in functions.
	prog_reg_function(prog, "add", builtin_add, "#va_args");
	prog_reg_function(prog, "mul", builtin_mul, "#va_args");
	// prog_reg_function(prog, "two-add", builtin_two_add, "a", "b");

	// # Comparison
	prog_reg_function(prog, "equal", builtin_equal, "left", "right");

	// # List
    prog_reg_function(prog, "item", builtin_item, "index", "list");
	// prog_reg_function(prog, "test-va-args", builtin_test_va_args, "#va_args");


	// reg_function("sub", builtin_sub);
	// reg_function("div", builtin_div);
	// reg_function("prog", builtin_prog);

	// reg_function("set", builtin_set);
	// reg_function("defun", builtin_defun);

	// reg_function("print", builtin_print);
	return prog;
}
prog_release_program :: proc(using prog : ^SparrowProgram) {
	env_destroy(program.global);
	for tree in trees {
		ast_destroy(tree);
	}
	free(prog);
}

prog_eval_source :: proc(source: string, using prog : ^SparrowProgram) -> Object {
	parser := parser_make(source);
	defer parser_release(parser);
	last := Object{};
	consumed := 0;
	fmt.printf(": ");
	for {
	    ast := ast_make();
	    result, parsed := parse(parser, ast, consumed);
        fmt.printf("[{}, {}] ", consumed, consumed + parsed);
		consumed += parsed;

		if result.type == .Bad {
			return Object{.Nil, nil};
		} else {
			append(&trees, ast);
			last = eval_tree(ast.root, program.global);
			// fmt.println("****", last);
			if result.type == .End {
				break;
			}
		}
	}

    fmt.printf(" of {}\n", len(parser.tokens));
   
	return last;
}

// Only register built-in functions.
prog_reg_function :: proc(prog : ^SparrowProgram, name: string, process : BuiltInFunction, params : ..string) {
	using prog;
	func := new(Function);
	func.type = .BuiltIn;
	func.params = make_params(params[:]);
	func.body = process;
	func.env = nil;
	env_define(global, name, Object{.Function, func});
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

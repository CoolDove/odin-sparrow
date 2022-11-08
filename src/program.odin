package main
// 
// import "core:fmt"
// import "core:os"
// import "core:strings"
// import "core:mem"
// import "core:unicode/utf8"
// 
// 
// 
// object_to_string :: proc(obj: ^Object, allocator := context.allocator) -> string {
	// sb : strings.Builder;
	// strings.builder_init(&sb);
	// defer strings.builder_destroy(&sb);
// 
	// temp_buffer : [128]u8;
// 
	// value := eval_tree(obj);
// 
    // switch value.type {
    // case .Nil:
		// return "nil";
	// case .Number:
		// fmt.sbprintf(&sb, "{}", value.value.(f64));
		// // delete(number_str);
	// case .String:
		// strings.write_string(&sb, value.value.(string));
	// case .Symbol:
		// symbol_obj, ok := prog_get_symbol(&value);
		// if ok {
			// strings.write_string(&sb, object_to_string(&symbol_obj));
		// } else {
			// strings.write_string(&sb, "nil");
		// }
	// case .Function:
		// function_desc := fmt.tprintf("function");
		// strings.write_string(&sb, function_desc);
		// // delete(function_desc);
	// case .List:
		// strings.write_rune(&sb, '(');
		// ptr := value.child;
		// for ptr != nil {
			// strings.write_string(&sb, object_to_string(ptr));
			// ptr = ptr.next;
			// if ptr != nil {strings.write_rune(&sb, ' ');}
		// }
		// strings.write_rune(&sb, ')');
	// }
// 
	// return strings.to_string(sb);
// }
// 
// build_object :: proc(type := ObjectType.Nil, value :ObjectValue= nil, is_data := false) -> Object {
	// return Object{type, value, is_data, Tree(Object){}};
// } 
// 
// BuiltInFunction :: proc(tree: []Object)->Object;
// 
// Function :: struct {
	// type : FuncType,
	// body : union {
		// Object, BuiltInFunction
	// }
// }
// 
// FuncType :: enum {
	// BuiltIn, Default
// }
// 
// // @Program
// SparrowProgram :: struct {
	// // symbols     : map[string]Object,
    // // functions   : [dynamic]^Function,
    // global : ^Environment,
// 
	// _allocator  : mem.Allocator,
	// _symbol_allocator : mem.Allocator,
// }
// 
// make_env :: proc(allocator := context.allocator) -> ^Environment {
	// env := new(Environment, allocator);
	// env.data = make(map[string]Object);
	// env._allocator = allocator;
// }
// destroy_env :: proc(using env : ^Environment) {
	// delete(data, _allocator);
// }
// 
// program : SparrowProgram;
// 
// prog_init_program :: proc(allocator := context.allocator) {
	// using program;
	// _allocator = allocator;
	// // symbols   = make(map[string]Object,  128, allocator);
	// // functions = make([dynamic]^Function, 128, allocator);
// 
    // // Register built-in functions.
	// reg_function("add", builtin_add);
	// // reg_function("mul", builtin_mul);
	// // reg_function("sub", builtin_sub);
	// // reg_function("div", builtin_div);
	// // reg_function("prog", builtin_prog);
// 
	// // reg_function("set", builtin_set);
	// // reg_function("defun", builtin_defun);
// 
	// // reg_function("print", builtin_print);
// }
// prog_release_program :: proc() {
	// {
		// using program;
		// context.allocator = _allocator;
		// delete(symbols);
		// delete(functions);
	// }
// }
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

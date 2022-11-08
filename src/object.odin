package main

import "core:fmt"
import "core:mem"
import "core:os"
import "core:strings"
import "core:unicode/utf8"


Object :: struct {
	type : ObjectType,
	value : ObjectValue,
}

ObjectType :: enum {
	Nil, Number, String, Symbol, Function, List// , ErrorMsg
}
ObjectValue :: union #align 4 {
	f64,        // Number
	string,     // String / SymbolName
	// i64,        // maybe some value
	// Function,
	List
}

List :: struct {
	data : [dynamic]Object,
	keep : bool
	// If this list should be keeped, otherwise it would be deleted after evaluation.
}

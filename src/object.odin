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
	^Function,
	List
}

// NOTE(Dove): Function Calling Convention
// Built-in functions usually use va_args, but that has not been implemented,
// `tree: []Object` is used as a temporary solution for va_args.
// After va_args is implemented, `tree: []Object` should be removed,
// and all va_args-function should get the args from its environment.
BuiltInFunction :: proc(tree: []Object, env: ^Environment)->Object;

Function :: struct {
	type : FuncType,
	params : [dynamic]string,
	body : union {
		Object, BuiltInFunction// The `Object` is usually a list(protected).
	},
	env : ^Environment,
	protected : bool
}

FuncType :: enum {
	BuiltIn, Default
}

List :: struct {
	data : [dynamic]Object,
	protected : bool
	// If this list should be keeped, otherwise it would be deleted after evaluation.
}

obj_list_data :: proc(obj: ^Object) -> []Object {
	assert(obj != nil && obj.type == .List, "Invalid obj to get list.");
	return obj.value.(List).data[:];
}

// NOTE(Dove): List Object Memory Strategy
// Usually an Object is stored on stack memory,
// it will be freed as the block turned off.
// But the `List` type Object should be allocated on heap memory.
// 
// The only way to get a list object is to eval a list,
// so we could just delete that list object instantly after evaluation.
// NOTION! List which stored in a symbol is protected, couldn't be deleted.
// That is marked in the eval function.

// TODO(Dove): `obj_destroy` is to destroy List/Function object's inner buffer.
obj_destroy :: proc(obj: Object, force := false) {
	// if obj.type != .List {return;}
    switch obj.type {
    case .Nil:      fallthrough
    case .Number:   fallthrough
	case .String:   fallthrough
    case .Symbol:   return;
	case .Function:
		function := obj.value.(^Function);
		if force || !function.protected {
			delete(function.params);
			if function.type == .Default {
				obj_destroy(function.body.(Object), true);
			}
		}
	case .List:// Recursively destroy a list.
		list := obj.value.(List);
		if force || !list.protected {
			for obj in list.data {
				obj_destroy(obj, true);
			}
			delete(list.data);
		}
	}
	
}

// NOTE(Dove): `obj_copy` is to copy the List/Function type object. Its inner buffer should be copied.
obj_copy :: proc(obj: Object, copy_as_protected := false, allocator := context.allocator) -> Object {
	// assert(false, "Not Implemented");
	switch obj.type {
    case .Nil:      fallthrough
    case .Number:   fallthrough
	case .String:   fallthrough
    case .Symbol:   fallthrough
	case .Function: return Object{obj.type, obj.value};
	case .List:
		buffer   := make([dynamic]Object, allocator);
		data := obj.value.(List).data[:];
		for elem in data {
			append(&buffer, obj_copy(elem));
		}
		return Object{.List, List{buffer, copy_as_protected}};
	}
	return Object{.Nil, nil};
}

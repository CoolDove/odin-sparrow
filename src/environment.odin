package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:mem"
import "core:unicode/utf8"

Environment :: struct {
	data : map[string]Object,
	parent : ^Environment,
}

env_make :: proc(allocator := context.allocator) -> ^Environment {
	context.allocator = allocator;
	env := new(Environment);
	env.data = make(map[string]Object, 32);
	return env;
}
env_destroy :: proc(using env : ^Environment) {
	{
	    delete(data);
	}
}

env_resolve :: proc(using env: ^Environment, name: string) -> (obj: Object, ok: bool) #optional_ok {
	if name in data {
		return data[name], true;
	} else {
	    return Object{}, false;
	}
}

env_define :: proc(using env: ^Environment, name: string, obj : Object) {
	if !(name in data) {
		data[name] = obj;
	}
}

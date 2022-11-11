package main

import "core:fmt"
import "core:mem"
import "core:os"
import "core:strings"
import "core:unicode/utf8"

Parser :: struct {
	runes : []rune,
	tokenized : bool,
	tokens : [dynamic]Token,
	_allocated_by   : mem.Allocator// Stores the source runes, and the tokens.
}

// NOTE(Dove): not used.
// using ast : ^AST,
// using parser : ^Parser,

parser_make :: proc(source:string, allocator := context.allocator) -> ^Parser {
	p := new(Parser, allocator);
	{
		using p;
		runes = utf8.string_to_runes(source, allocator);
		tokens = make([dynamic]Token, allocator);
		_allocated_by = allocator;
	}
	// TODO(Dove): Tokenize here.
	err := tokenize(p);
	if err == .None { p.tokenized = true; }
	return p;
}
parser_release :: proc(using parser:^Parser) {
	context.allocator = parser._allocated_by;
	delete(tokens);
	delete(runes);

	// delete(_tree_stack.data);
	free(parser);
}

parse :: proc(using parser : ^Parser, using ast : ^AST) -> ParseResult {
	if tokenized {
		// tree : Object;
		// consumed : int;

		tree, consumed := parse_exp(parser, ast, 0);

		if consumed == 0 {
			ast.root = Object{};
			return ParseResult{.Bad, "failed to parse"};
		} else {
			ast.root = tree;
	        return ParseResult{.Good, "parse succ"};
		}
	}
	ast.root = Object{};
	return ParseResult{.Bad, "failed to tokenize"};
}


parse_exp :: proc(using parser : ^Parser, using ast : ^AST, tokptr : int) -> (Object, int) {
	tptr := tokptr;
	tok  := tokens[tptr];

	node     := Object{};
	consumed : int    = ---;
	node, consumed = parse_value(parser, ast, tptr);
	if consumed == 0 {
	    node, consumed = parse_list(parser, ast, tptr);
	}
	return node, consumed;
}
// NOTE:
// `parse_` prefixed functions take a tokptr to fetch token from the parser.
// The return value is consumed tokens count, should be added to tokptr.
// Returning 0 means parsing failed.
parse_list :: proc(using parser : ^Parser, using ast : ^AST, tokptr : int) -> (Object, int) {
	tptr := tokptr;
	tok  := tokens[tptr];

	if tok.type == .LParen {
        tptr += 1;
		tok = tokens[tptr];
	} else {
		return Object{}, 0;
	}

	list := make([dynamic]Object, _tree_allocator);
	good := true;
	for {
		node     : Object = ---;
		consumed : int    = ---;

		if tok.type == .LParen {
			node, consumed = parse_list(parser, ast, tptr);
		} else {
			node, consumed = parse_value(parser, ast, tptr);
		}

		if consumed != 0 {// append to metalist root
			append(&list, node);
			tptr += consumed;
		} else {// failed to parse metalist
			good = false;
			break;
		}

		// end check
		tok = tokens[tptr];
		if tok.type == .RParen {
			tptr += 1;
			break;// good
		} else if tok.type == .End {
			good = false;
			break;
		}
	}
	if good {
		total_consumed := tptr - tokptr;
		return Object{.List, List{list, true}}, total_consumed;
	}

	return Object{}, 0;
}

// NOTE(Dove): number or string, or symbol
parse_value :: proc(using parser : ^Parser, using ast : ^AST, tokptr : int) -> (Object, int) {
	tok := tokens[tokptr];
	obj :Object= ---;
	good := false;
	
    #partial switch tok.type {
	case .Number:
		return Object{.Number, tok.value.(f64)}, 1;
	case .String:
		return Object{.String, tok.value.(string)}, 1;
	case .Symbol:
		return Object{.Symbol, tok.value.(string)}, 1;
	}
	
	return Object{.Nil, nil}, 0;
}

show_tree :: proc(root : ^Object, ite : int = 0) {
	if root == nil { return; }

	sb := strings.builder_make(context.allocator);
	defer strings.builder_destroy(&sb);

	for i in 0..<ite { strings.write_string(&sb, "  "); }
	prefix_tabs := strings.to_string(sb);

	#partial switch root.type {
	case .List:
		fmt.printf("%v|___\n", prefix_tabs);
		childs : []Object = root.value.(List).data[:];
		for ind in 0..<len(childs) {
			show_tree(&childs[ind], ite + 1);
		}
		// fmt.printf("%v|---\n", prefix_tabs);
	case .Number:
		fmt.printf("%v|%v\n", prefix_tabs, root.value.(f64));
	case .Symbol:
		fmt.printf("%v|%v\n", prefix_tabs, root.value.(string));
	case .String:
		fmt.printf("%v|\"%v\"\n", prefix_tabs, root.value.(string));
	}
}


ParseResult :: struct {
	type : ParseResultType,
    message : string
}

ParseResultType :: enum {
	Good, Bad
}

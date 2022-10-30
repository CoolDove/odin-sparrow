package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:unicode/utf8"

import "core:log"

Parser :: struct {
	runes : []rune,
	tokenized : bool,
	tokens : [dynamic]Token,
}

// NOTE(Dove): not used.
ParseContext :: struct {
	ptr : int // token index
}

parser_make :: proc(source:string, allocator := context.allocator) -> ^Parser{
	p := new(Parser);
	using p;
	runes = utf8.string_to_runes(test_source, allocator);
	tokens = make([dynamic]Token, allocator);
	return p;
}
parser_release :: proc(using parser:^Parser) {
	delete(tokens);
	delete(runes);
	free(parser);
}

parse :: proc(using parser : ^Parser, allocator := context.allocator) -> (^Tree, ParseResult) {
	err := tokenize(parser);
	if err == .None {
		tree : ^Tree;
		consumed : int;
		tree, consumed = parse_metalist(parser, 0, allocator);
		if consumed == 0 {
			return nil, ParseResult{.Bad, "failed to parse"};
		} else {
	        return tree, ParseResult{.Good, "parse succ"};
		}
	}
	return nil, ParseResult{.Bad, "failed to tokenize"};
}


// NOTE:
// `parse_` prefixed functions take a tokptr to fetch token from the parser.
// The return value is consumed tokens count, should be added to tokptr.
// Returning 0 means parsing failed.
parse_metalist :: proc(using parser : ^Parser, tokptr : int, allocator := context.allocator) -> (^Tree, int) {
	tptr := tokptr;
	tok  := tokens[tptr];

	if tok.type == .LParen {
        tptr += 1;
		tok = tokens[tptr];
	} else {
		return nil, 0;
	}

	root := new(Tree, allocator);
	root.type = .MetaList;

	last_bro : ^Tree;

	good := true;

	for {
		node     : ^Tree;
		consumed : int;

		if tok.type == .LParen {
			node, consumed = parse_metalist(parser, tptr, allocator);
		} else {
			node, consumed = parse_endvalue(parser, tptr, allocator);
		}

		if consumed != 0 {// append to metalist root
			node.parent = root;
			if last_bro == nil {
				root.child = node;
			} else {
				last_bro.next = node;
			}
			last_bro = node;
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
		return root, total_consumed;
	}
	return nil, 0;
}

// NOTE(Dove): number or string, or symbol
parse_endvalue :: proc(using parser : ^Parser, tokptr : int, allocator := context.allocator) -> (^Tree, int) {
	tok := tokens[tokptr];
	tree := new(Tree, allocator);
	good := false;
	
    #partial switch tok.type {
	case .Number:
		tree.type  = .Number;
		tree.value = tok.value.(f64);
		good = true;
	case .String:
		tree.type  = .String;
		tree.value = tok.value.(string);
		good = true;
	case .Symbol:
		tree.type  = .Symbol;
		tree.value = tok.value.(string);
		good = true;
	}

	if good {
		return tree, 1;
	}
	
	return nil, 0;
}

show_tree :: proc(tree : ^Tree, ite : int = 0) {
	if tree == nil { return; }

	sb := strings.builder_make(context.temp_allocator);
	for i in 0..<ite { strings.write_string(&sb, "  "); }
	prefix_tabs := strings.to_string(sb);

	#partial switch tree.type {
	case .MetaList:
		fmt.printf("%v|___\n", prefix_tabs);
	case .Number:
		fmt.printf("%v|%v\n", prefix_tabs, tree.value.(f64));
	case .Symbol:
		fmt.printf("%v|%v\n", prefix_tabs, tree.value.(string));
	case .String:
		fmt.printf("%v|\"%v\"\n", prefix_tabs, tree.value.(string));
	}

	child := tree.child;

	if child != nil {
		for child != nil {
			show_tree(child, ite + 1);
			child = child.next;
		}
	}

	// if tree.type == .MetaList {
		// fmt.printf("%v)\n", prefix_tabs);
	// }
}



ParseResult :: struct {
	type : ParseResultType,
    message : string
}
ParseResultType :: enum {
	Good, Bad
}

Tree :: struct {
	child, next, parent : ^Tree,
	type : TreeType,
	value : TreeValue
}

TreeType :: enum {
	MetaList, Symbol, Number, String
}

TreeValue :: union {
	f64, string,
}

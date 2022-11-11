package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:unicode/utf8"



show_tokens :: proc(using parser : ^Parser) {
	if !tokenized { return; }
	for tok in tokens {
		fmt.printf("%v(%v)\n", tok.type, tok.value);
	}
}

// TODO(Dove): optimize string and symbol and number by to_writer
tokenize :: proc(using parser : ^Parser) -> TokenError {
	if parser.tokenized { return .None; }
	runes_length := len(runes);

	ptr := 0;

	for {
		for {
			consumed_space := token_consume_space(parser, ptr);
			consumed_comment := token_consume_comment(parser, ptr);
		    consumed := consumed_space + consumed_comment;
			if consumed == 0 { break; }
		    ptr += consumed;
		}

		if ptr >= runes_length {
			break;
		}
		
		current := runes[ptr];
		token_buffer_ptr := 0;

		if current == '(' {
			ptr += 1;
			append(&tokens, Token{.LParen, nil});
			continue;
		} else if current == ')' {
			ptr += 1;
			append(&tokens, Token{.RParen, nil});
			continue;
		} if current == ',' {	// ...Seems not very useful in sparrow.
			ptr += 1;
			append(&tokens, Token{.Comma, nil});
            continue;
		} else {
			tok : Token;
			local_consumed : = 0;

			succ := false;
			if current == '\"' {
                tok, local_consumed = token_get_string(parser, ptr);
				if local_consumed != 0 {succ = true;}
			}

			if !succ {
				tok, local_consumed = token_get_number(parser, ptr);
				if local_consumed != 0 {
					succ = true;
				} else {
					tok, local_consumed = token_get_symbol(parser, ptr);
				    if local_consumed != 0 {
						succ = true;
					}
				}
			}

			if succ {
				append(&tokens, tok);
				ptr += local_consumed;
				continue;
			} else {
				return .TokenError;
			}
		}
	}

	return .None;
}


@(private="file")
token_get_string :: proc(using parser:^Parser, runeptr: int) -> (Token, int) {
	builder := strings.builder_make(context.temp_allocator);
	ptr := runeptr;// to pass the prefix quote
	current := runes[ptr];

	if current == '\"' {
		ptr += 1;
		current = runes[ptr];
	} else {
		return Token{}, 0;
	}

	for {
		
		if ptr >= len(runes) {
			return Token{}, 0;
		}

	    current := runes[ptr];

		if current == '\"' {
			ptr += 1;
			break;
		} else if current == '\n' {
			ptr += 1;
			return Token{}, 0;
		} else if current == '\\' {// escape
			next := runes[ptr + 1];
			get_escaped := true;
			if next == 'n' {
				strings.write_rune(&builder, '\n');
			} else if next == 'r' {
				strings.write_rune(&builder, '\r');
			} else if next == 't' {
				strings.write_rune(&builder, '\t');
			} else if next == '\"' {
				strings.write_rune(&builder, '\"');
			} else {
				get_escaped = false;
			}
			if get_escaped { ptr += 2; }
		} else {
			strings.write_rune(&builder, current);
			ptr += 1;
		}
	}
    
	return Token{.String, strings.to_string(builder)}, ptr - runeptr;
}

@(private="file")// TODO(Dove): `get_number` can only parse integer for now, add float
token_get_number :: proc(using parser:^Parser, runeptr : int) -> (Token, int)  {
	builder := strings.builder_make(context.temp_allocator);
	ptr := runeptr;
	current := runes[ptr];

	negative := false;
	need_a_number := true;

	if current == '-' {
		negative = true;
		ptr += 1;
		if ptr >= len(runes) { return Token{}, 0; }
		current += runes[ptr];
	}
	
	point := false;
	for {
		if ptr >= len(runes) {
			if need_a_number { return Token{}, 0 }
			else { break; }
		}
		current = runes[ptr];
        if need_a_number {
			if !point && current == '.' {
				strings.write_string(&builder, "0.");
				point = true;
				ptr += 1;
			} else if rune_is_number(current) {
				strings.write_rune(&builder, current);
				need_a_number = false;
				ptr += 1;
			} else {
				return Token{}, 0;
			}
		} else {
			if rune_is_number(current) {
				strings.write_rune(&builder, current);
				ptr += 1;
			} else if current == '.' {
				strings.write_rune(&builder, '.');
				point = true;
				ptr += 1;
			} else {
				break;
			}
		}
	}

	value := strconv.atof(strings.to_string(builder));
	if negative { value *= -1; }
	return Token{.Number, value}, ptr - runeptr;
}

@(private="file")
token_get_symbol :: proc(using parser:^Parser, runeptr : int) -> (Token, int) {
	builder := strings.builder_make(context.temp_allocator);
	ptr := runeptr;
	current := runes[ptr];

	// Special single-letter symbol.
	if strings.contains_rune("+-*/%", current) != -1 {
		if ptr + 1 > len(runes)  { return Token{.Symbol, rune_to_string(current)}, 0; }
		if runes[ptr + 1] == ' ' { return Token{.Symbol, rune_to_string(current)}, 0; }
	}

	need_a_letter : bool = true;

	if current == '#' || rune_is_letter(current) {
		if current != '#' { need_a_letter = false; }
		need_a_letter = current == '#';
		strings.write_rune(&builder, current);
		ptr += 1;
		current = runes[ptr];
	}

	for {
		if ptr >= len(runes) {
			if need_a_letter { return Token{}, 0; }
			else {break;}
		}
		current = runes[ptr];
		is_letter := rune_is_letter(current);

		if need_a_letter {
			need_a_letter = false;
			if !is_letter { return Token{}, 0; }
			ptr += 1;
			strings.write_rune(&builder, current);
		} else {
		    if rune_is_letter(current) || rune_is_number(current) || strings.contains_rune("-_/", current) != -1 {
				ptr += 1;
				strings.write_rune(&builder, current);
			} else {
			    break;
			}
		}
	}

	consumed := ptr - runeptr;
	return Token{.Symbol, strings.to_string(builder)}, consumed;
}

@(private="file")
token_consume_space :: proc(using parser : ^Parser, runeptr : int) -> int {
	length := len(runes);
	consumed :int= 0;
	ptr := runeptr;
	for ptr < length && strings.is_ascii_space(runes[ptr]) {
		ptr += 1;
		consumed += 1;
	}

	return consumed;
}
@(private="file")
token_consume_comment :: proc(using parser : ^Parser, runeptr : int) -> int {
	length := len(runes);
    consume :int= 0;
	if runeptr >= length { return 0; }
	if runes[runeptr] != ';' {return 0;}

	for r in runes[runeptr:] {
		consume += 1;
		if r == '\n' || r == '\r' {
			break;
		}
	}

	return consume;
}


@(private="file")
rune_is_number :: proc(r : rune) -> bool {
    return r <= '9' && r >= '0';
}
@(private="file")
rune_is_letter :: proc(r : rune) -> bool {
	return (r <= 'z' && r >= 'a') || (r <= 'Z' && r >= 'A');
}

@(private="file")
rune_to_string :: proc(r : rune) -> string {
	sb := strings.builder_make();
	defer strings.builder_destroy(&sb);
	strings.write_rune(&sb, r);
	return strings.to_string(sb);
}



Token :: struct {
	type  : TokenType,
	value : TokenValue
}

TokenType :: enum {
	None,
	End,
	LParen,
	RParen,
	Quote,
	Comma,
	Number,
	Symbol,
	String
}

// currently use a string to store variable/function name (for `Symbol` type)
TokenValue :: union {
	f64, string 
}

TokenError :: enum {
	None, TokenError,
	StringError, StringMultiline,
	NumberError
}

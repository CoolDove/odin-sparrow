package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:unicode/utf8"


@(private="file")
_token_buffer : [512]rune;
parser_next_token :: proc(using parser : ^Parser) -> (Token, TokenError) {
	if ptr >= cast(u32)len(runes) { return Token{.End, 0}, .None; }

	if token_consume_space(parser) == -1 { return Token{.End, 0}, .None; }
	current := runes[ptr];
	token_buffer_ptr := 0;

	if current == '(' {ptr += 1; return Token{.LParen, 0}, .None; }	
	if current == ')' {ptr += 1; return Token{.RParen, 0}, .None; }	
	if current == ',' {ptr += 1; return Token{.Comma, 0}, .None; }	

	if current == '\"' {
		str_tok, err := token_get_string(parser);
		if err == .None {
			return str_tok, .None;
		} else {
			return Token{.None, nil}, err;
		}
	}

	if current == '-' || rune_is_number(current) {
		num_tok, err := token_get_number(parser);
		if err == .None {
			return num_tok, .None;
		} else {
			return Token{.None, nil}, .NumberError;
		}
	}

	is_first_in_symbol := true;
	for rune_is_valid_in_symbol(current, is_first_in_symbol) {
		_token_buffer[token_buffer_ptr] = current;

		token_buffer_ptr += 1;
		ptr += 1;
		current = runes[ptr];
        is_first_in_symbol = false;
	}

	if token_buffer_ptr != 0 {
	    used_token_buffer := _token_buffer[0:token_buffer_ptr];
	    tok := Token {.Symbol, utf8.runes_to_string(used_token_buffer, context.temp_allocator)};
	    return tok, .None;
	} else {
	    return Token{.None, nil}, .TokenError;
	}
	
}


@(private="file")
token_get_string :: proc(using parser:^Parser) -> (Token, TokenError) {
	rune_len := len(runes);
	builder := strings.builder_make(context.temp_allocator);
	ptr += 1;// to pass the prefix quote
	for {
	    current := runes[ptr];
		if current == '\"' {
			content := strings.to_string(builder);
			ptr += 1;
			return Token{.String, content}, .None;
		}
		if current == '\n' {
			ptr += 1;
			return Token{.None, nil}, .StringMultiline;
		}

		if current == '\\' {// escape
			next := runes[ptr + 1];
			get_escaped := true;
			if next == 'n' {
				strings.write_rune(&builder, '\n');
			} else if next == 't' {
				strings.write_rune(&builder, '\t');
			} else if next == '\"' {
				strings.write_rune(&builder, '\"');
			} else {
				get_escaped = false;
			}
			if get_escaped { ptr += 2; }
		}

		strings.write_rune(&builder, current);
		ptr += 1;
		if ptr > cast(u32)rune_len {
			return Token{.None, nil}, .StringError;
		}
	}
	return Token{.None, nil}, .StringError;
}

@(private="file")// TODO(Dove): `get_number` can only parse integer for now, add float
token_get_number :: proc(using parser:^Parser) -> (Token, TokenError)  {
	builder := strings.builder_make(context.temp_allocator);
	point := false;
	for {
	    current := runes[ptr];
		if rune_is_number(current) {
			strings.write_rune(&builder, current);
			ptr += 1;
		} else if current == '.' {
			if !point {
				point = true
				strings.write_rune(&builder, current);
				ptr += 1;
			} else {
				return Token{.None, nil}, .NumberError;
			}
		} else {
			break;
		}
	}
	value := strconv.atof(strings.to_string(builder));
	return Token{.Number, value}, .None;
}

@(private="file")
token_consume_space :: proc(using parser : ^Parser) -> i32 {
	length := cast(u32)len(runes);
	consumed :i32= 0;
	for ptr < length && strings.is_ascii_space(runes[ptr]) {
		ptr += 1;
		consumed += 1;
	}
	if ptr < length {
	    return consumed;
	} else {
	    return -1;
	}
}


@(private="file")
rune_is_valid_in_symbol :: proc(r : rune, is_first := false) -> bool {
	if (r <= 'z' && r >= 'a') || (r <= 'Z' && r >= 'A') {
		return true;
	}
	if !is_first {
		return r == '-' || r == '_' || r == '/' || (r <= '9' && r >= '0');
	}
	return false;
}

@(private="file")
rune_is_number :: proc(r : rune) -> bool {
    return r <= '9' && r >= '0';
}


Token :: struct {
	type : TokenType,
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

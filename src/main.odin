package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:unicode/utf8"


main :: proc () {
	sparrow();
}

print_label :: proc(label : string) {
	fmt.printf("\n%s:\n-----------------\n", label);
}

sparrow :: proc() {
	defer fmt.println("==PROGRAM END==");

	program = prog_init_program();
	defer prog_release_program(program);

	print_label("Source");
	fmt.println(test_source);

	base_eval := prog_eval_source(test_source, program);
	fmt.println("base eval: ", base_eval);

	for {
        fmt.printf("\nREPL> ");
        repl_buf: [2048]u8;
        read_size, read_err := os.read(os.stdin, repl_buf[:]);

		input := strings.trim_suffix(string(repl_buf[:read_size]), "\r\n");
        read_size = len(input);

		if read_size == 0 || (read_size == 1 && repl_buf[0] == 4) {
		    break;
	    }

		switch read_err {
	    case 0, 6:// correct input
			eval := prog_eval_source(input, program);
			fmt.println(eval);
		case 995:
			break;
		case :
			break;
		}
	}
	fmt.println("");
	
}

test_source :: `
(begin
    ;; (def PI 3.14159)
    ;; (def circle-area (radius)
        ;; (mul PI radius radius)
    ;; )
    ;; (def diameter 4)
    ;; (circle-area (mul diameter .5))

    (def test (#va_args)
        (item 1 #va_args)
    )

    (test 1 2 3 4)
)
`

/*

(prog
	(def add (a b #va_args)
		(print va_args)
	)
    (add print "hello, world")
)
*/

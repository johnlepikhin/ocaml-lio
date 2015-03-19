
{
	open Lexing
	open LVM_grammar
}

let white = [' ' '\t']+
let newline = '\r' | '\n' | "\r\n"
let id = ['A'-'Z' '_'] ['A'-'Z' '0'-'9' '_']*

rule main = parse
	| white { main lexbuf }
	| newline { Newline }
	| id as v { ID v }
	| '=' { EQ }
	| "'" { let b = Buffer.create 30 in Quoted (quoted b lexbuf) }
	| eof { EOF }

and quoted buf = parse
	| "\\'" { Buffer.add_char buf '\''; quoted buf lexbuf }
	| "\\\\" { Buffer.add_char buf '\\'; quoted buf lexbuf }
	| "'" { Buffer.contents buf }
	| _ as v { Buffer.add_char buf v; quoted buf lexbuf }

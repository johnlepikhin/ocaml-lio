
let listread ?(options="") cmd =
	let ch = Unix.open_process_in (Printf.sprintf "%ss --units=B -o %s_all%s --noheadings --nosuffix --nameprefixes" cmd cmd options) in
	let lexbuf = Lexing.from_channel ch in
	let lines = LVM_grammar.lines LVM_lex.main lexbuf in
	let _ : Unix.process_status = Unix.close_process_in ch in
	lines

exception KeyNotFound of string
exception ParseFailed of string * string

let get fn k (lst : (string * string) list) =
	let v =
		try
			 BatList.assoc k lst
		with _ -> raise (KeyNotFound k)
	in
	try
		fn v
	with
		| _ -> raise (ParseFailed (k, v))

let get_float = get float_of_string
let get_float_option = get (function "" -> None | s -> Some (float_of_string s))

let get_int = get (fun s -> float_of_string s |> int_of_float)
let get_int_option = get (function "" -> None | s -> Some (float_of_string s |> int_of_float))

let get_string = get (fun v -> v)

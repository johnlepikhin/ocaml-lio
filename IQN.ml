
open LIOExt

type t = {
	year : int;
	month : int;
	authority : string;
	name : string;
}

let make ~year ~month ~authority name =
	{ year; month; authority; name }

let string t =
	Printf.sprintf "iqn.%04i-%02i.%s:%s" t.year t.month t.authority t.name

let of_string =
	let open Pcre in
	let rex = regexp "^iqn\\.(\\d+)-(\\d+)\\.([^:]+):(.*)" in
	fun s ->
		match extract_list ~rex s with
			| [_; year; month; authority; name] ->
				let year = int_of_string year in
				let month = int_of_string month in
				{ year; month; authority; name }
			| _ -> raise Not_found

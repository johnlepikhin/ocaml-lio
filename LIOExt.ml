
module Pcre =
	struct
		include Pcre

		let extract_list ~rex s =
			exec ~rex s |> get_substrings |> Array.to_list
	end

module Unix =
	struct
		include Unix

		exception ExecError of (string * process_status)

		let arg_exec ?(success=0) cmd args =
			let _stdin = openfile "/dev/null" [] 0o644 in
			let _stdout = openfile "/dev/null" [] 0o644 in
			let _stderr = openfile "/dev/null" [] 0o644 in
			let pid = create_process cmd args _stdin _stdout _stderr in
				let (_, status) = waitpid [] pid in
				close _stdin;
				close _stdout;
				close _stderr;
				match status with
					| WEXITED code when code = success -> ()
					| _ -> raise (ExecError (cmd, status))
	end

module BatList =
	struct
		include BatList

		let next_int lst =
			fold_left (fun prev cur -> Pervasives.max prev cur) (-1) lst |> (+) 1
	end


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
			let pid = fork () in
			if pid = 0 then
				execv cmd args
			else
				let (_, status) = waitpid [] pid in
				match status with
					| WEXITED code when code = success -> ()
					| _ -> raise (ExecError (cmd, status))
	end

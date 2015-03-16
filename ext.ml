
module Pcre =
	struct
		include Pcre

		let extract_list ~rex s =
			exec ~rex s |> get_substrings |> Array.to_list
	end



open LIOTypes

type iscsi = {
	iqn : IQN.t;
}

type entry =
	| ISCSI of iscsi

type 'a t = {
	frontend: 'a Frontend.t;
	entry : entry;
} constraint 'a = [< fabric ]

let path t =
	let frontend = Frontend.path t.frontend in
	match t.entry with
		| ISCSI v -> Path.node_iscsi frontend v.iqn

let init entry frontend =
	{
		frontend;
		entry;
	}

let create_iscsi ~ignore_current frontend iqn =
	let iscsi = { iqn } in
	let t = init (ISCSI iscsi) frontend in
	path t |> LIOFSUtil.mkdir ~ignore_current;
	t

let find_iscsi frontend =
	Frontend.path frontend
	|> LIOFSUtil.filter_subdirs (fun (name, stat) ->
		try
			let iqn = IQN.of_string name in
			Some {
				frontend;
				entry = ISCSI { iqn };
			}
		with
			| _ -> None
	)

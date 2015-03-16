
open Common

type iscsi = {
	iqn : IQN.t;
}

type entry =
	| ISCSI of iscsi

type 'a t = {
	frontend: 'a Frontend.t;
	entry : entry;
} constraint 'a = [< Common.fabric ]

let path t =
	let frontend = Frontend.path t.frontend in
	match t.entry with
		| ISCSI v -> Path.node_iscsi frontend v.iqn

let init entry frontend =
	{
		frontend;
		entry;
	}

let create_iscsi frontend iqn =
	let iscsi = { iqn } in
	let t = init (ISCSI iscsi) frontend in
	path t |> Fsutil.mkdir;
	t

let find_iscsi frontend =
	Frontend.path frontend
	|> Fsutil.filter_subdirs (fun (name, stat) ->
		try
			let iqn = IQN.of_string name in
			Some {
				frontend;
				entry = ISCSI { iqn };
			}
		with
			| _ -> None
	)

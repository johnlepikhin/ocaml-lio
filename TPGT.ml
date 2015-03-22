
open LIOTypes
open LIOExt

type 'a t = {
	node : 'a LIONode.t;
	id : int;
}

let path t = Path.tpgt (LIONode.path t.node) t.id

let get node =
	LIONode.path node
	|> LIOFSUtil.filter_subdirs (fun (name, stat) -> try Scanf.sscanf name "tpgt_%i" (fun id -> Some { node; id }) with _ -> None)

let get_next lst =
		let open BatList in
		map (fun t -> t.id) lst |> next_int

let create ~ignore_current ?id node =
	let id =
		match id with
			| None -> get node |> get_next
			| Some id -> id
	in
	let t = { node; id } in
	path t |> LIOFSUtil.mkdir ~ignore_current;
	t

let add_np ~ignore_current t inet_addr port =
	Path.np (path t) inet_addr port |> LIOFSUtil.mkdir ~ignore_current


open Common

type 'a t = {
	node : 'a Node.t;
	id : int;
}

let path t = Path.tpgt (Node.path t.node) t.id

let get node =
	Node.path node
	|> Fsutil.filter_subdirs (fun (name, stat) -> try Scanf.sscanf name "tpgt_%i" (fun id -> Some { node; id }) with _ -> None)

let get_next lst =
		let open BatList in
		map (fun t -> t.id) lst |> max |> (+) 1

let create node =
	let id = get node |> get_next in
	let t = { node; id } in
	path t |> Fsutil.mkdir;
	t

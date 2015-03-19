open LIOCommon

type entry =
	| Fileio
	| Iblock

type 'a t = {
	id : int;
	entry : entry;
	core : core Path.t;
}
type 'a set = 'a t list

let fileio_path t = Path.backstore_group_fileio t.core t.id
let iblock_path t = Path.backstore_group_iblock t.core t.id

let find core entry fn =
	let f id = { id; core; entry } in
	LIOFSUtil.filter_subdirs (fun (name, stat) -> try Some (fn name f) with _ -> None) core

let scan_fileio name fn = Scanf.sscanf name "fileio_%i" fn
let scan_iblock name fn = Scanf.sscanf name "iblock_%i" fn

let find_fileio core = find core Fileio scan_fileio
let find_iblock core = find core Iblock scan_iblock

let fileio_of_name core name = scan_fileio name (fun id -> { id; entry = Fileio; core })
let iblock_of_name core name = scan_iblock name (fun id -> { id; entry = Iblock; core })

let get_next lst =
		let open BatList in
		map (fun t -> t.id) lst |> max |> (+) 1

let init entry core lst =
	let id = get_next lst in
	let t = { id; entry; core } in
	t

let create_fileio core =
	let t = find_fileio core |> init Fileio core in
	fileio_path t |> LIOFSUtil.mkdir;
	t

let create_iblock core =
	let t = find_iblock core |> init Iblock core in
	iblock_path t |> LIOFSUtil.mkdir;
	t

let delete_fileio t = fileio_path t |> LIOFSUtil.rmdir
let delete_iblock t = iblock_path t |> LIOFSUtil.rmdir

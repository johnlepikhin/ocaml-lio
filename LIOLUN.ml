
open LIOCommon

type 'a t = {
	tpgt : 'a TPGT.t;
	id : int;
} constraint 'a = iscsi

type 'a backstore = {
	name : string;
	backstore : 'a Backstore.t;
}

let path t = Path.lun (TPGT.path t.tpgt) t.id

let get tpgt =
	TPGT.path tpgt
	|> Path.lun_container
	|> LIOFSUtil.filter_subdirs (fun (name, stat) -> try Scanf.sscanf name "lun_%i" (fun id -> Some { tpgt; id }) with _ -> None)

let get_next lst =
	let open BatList in
	map (fun t -> t.id) lst |> max |> (+) 1

let create tpgt =
	let id = get tpgt |> get_next in
	let t = { tpgt; id } in
	path t |> LIOFSUtil.mkdir;
	t

let backstore_of_path bg_fn b_fn path =
	match path with
		| backstore_name :: backstore_group :: "core" :: root ->
			let core = Path.lioroot root |> Path.core in
			let bg = bg_fn core backstore_group in
			b_fn bg backstore_name
		| _ ->
			raise Not_found

let fileio_backstore_of_path = backstore_of_path BackstoreGroup.fileio_of_name Backstore.fileio_of_name
let iblock_backstore_of_path = backstore_of_path BackstoreGroup.iblock_of_name Backstore.iblock_of_name

let get_backstores bs_fn t =
	let lun_path = path t in
	LIOFSUtil.filter_symlinks (fun name stat link ->
		let module P = BatPathGen.OfString in
		let backstore = P.concat (Path.path lun_path) link |> P.normalize_in_tree |> bs_fn in
		Some { backstore; name }
	) lun_path

let get_fileio = get_backstores fileio_backstore_of_path
let get_iblock = get_backstores iblock_backstore_of_path

let add_backstore t backstore =
	let lun_path = path t |> Path.path in
	let bs_path = Backstore.path backstore.backstore |> Path.path in
	let module P = BatPathGen.OfString in
	let link_path = P.relative_to_any lun_path bs_path in
	Unix.symlink (P.to_string link_path) (P.append lun_path backstore.name |> P.to_string)


open LIOTypes
open LIOExt

type ('frontend, 'backstore) t = {
	tpgt : 'frontend TPGT.t;
	backstore : 'backstore Backstore.t;
	id : int;
} constraint 'frontend = iscsi

let path t = Path.lun (TPGT.path t.tpgt) t.id

let getlist tpgt =
	let path = TPGT.path tpgt in
	let lun_path = Path.lun_container path in
	LIOFSUtil.filter_subdirs (fun (name, stat) ->
		try
			Scanf.sscanf name "lun_%i" (fun id ->
				let module P = BatPathGen.OfString in
				let linkpath = Path.path lun_path in
				let link = P.concat linkpath [Printf.sprintf "backstore_%i" id; name] |> P.to_string |> Unix.readlink in
				Some (name, id, link, linkpath)
			)
		with
			| _ -> None
	) lun_path

let get tpgt bs_fn =
	let module P = BatPathGen.OfString in
	getlist tpgt |> List.map (fun (name, id, link, linkpath) ->
		let backstore = P.of_string link |> P.concat linkpath |> P.normalize_in_tree |> bs_fn in
		{ tpgt; id; backstore }
	)

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

let get_fileio tpgt = get tpgt fileio_backstore_of_path
let get_iblock tpgt = get tpgt iblock_backstore_of_path

let get_next lst =
	let open BatList in
	map (fun (name, id, link, linkpath) -> id) lst |> next_int

let create ~ignore_current tpgt backstore =
	let id = getlist tpgt |> get_next in
	let t = { tpgt; id; backstore } in
	let lun_path = path t in
	LIOFSUtil.mkdir ~ignore_current lun_path;

	let bs_path = Backstore.path backstore |> Path.path in
	let module P = BatPathGen.OfString in
	let lun_path = Path.path lun_path in
	let link_path = P.relative_to_any lun_path bs_path in
	let link_name = Printf.sprintf "backstore_%i" id in
	LIOFSUtil.with_chdir (path t) (fun () -> LIOFSUtil.symlink ~ignore_current (P.to_string link_path) (P.append lun_path link_name |> P.to_string));

	t

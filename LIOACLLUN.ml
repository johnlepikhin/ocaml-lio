
open LIOTypes
open LIOExt

type ('frontend, 'backstore) t = {
	acl : 'frontend LIOACL.t;
	id : int;
} constraint 'frontend = iscsi

let path t = Path.acllun (LIOACL.path t.acl) t.id

let getlist tpgt =
	let acl_path = LIOACL.path tpgt in
	LIOFSUtil.filter_subdirs (fun (name, stat) ->
		try
			Scanf.sscanf name "lun_%i" (fun id ->
				let module P = BatPathGen.OfString in
				let linkpath = Path.path acl_path in
				let link = P.concat linkpath [name; Printf.sprintf "lunlink_%i" id] |> P.to_string |> Unix.readlink in
				Some (name, id, link, linkpath)
			)
		with
			| _ -> None
	) acl_path

let get_next lst =
	let open BatList in
	map (fun (_, id, _, _) -> id) lst |> next_int

let create ~ignore_current acl lun =
	let id = getlist acl |> get_next in
	let t = { acl; id } in
	let locallun_path = path t in
	LIOFSUtil.mkdir ~ignore_current locallun_path;

	let commonlun_path = LIOLUN.path lun |> Path.path in
	let module P = BatPathGen.OfString in
	let link_path = P.relative_to_any (Path.path locallun_path) commonlun_path in
	let link_name = Printf.sprintf "lunlink_%i" id in
	LIOFSUtil.with_chdir
		locallun_path
		(fun () -> LIOFSUtil.symlink ~ignore_current (P.to_string link_path) link_name);

	t

(*
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
	let acl_path = path t in
	LIOFSUtil.filter_symlinks (fun name stat link ->
		let module P = BatPathGen.OfString in
		let backstore = P.concat (Path.path lun_path) link |> P.normalize_in_tree |> bs_fn in
		Some { backstore; name }
	) acl_path

let get_fileio = get_backstores fileio_backstore_of_path
let get_iblock = get_backstores iblock_backstore_of_path

let add_backstore backstore =
	let acl_path = path t.acl |> Path.path in
	let bs_path = Backstore.path backstore.backstore |> Path.path in
	let module P = BatPathGen.OfString in
	let link_path = P.relative_to_any lun_path bs_path in
	let link_name = Printf.sprintf "backstore_%s" backstore.name in
	LIOFSUtil.with_chdir (path t) (fun () -> Unix.symlink (P.to_string link_path) (P.append lun_path link_name |> P.to_string))
*)


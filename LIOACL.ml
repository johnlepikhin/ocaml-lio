
open LIOTypes
open LIOExt

type 'a t = {
	tpgt : 'a TPGT.t;
	iqn : IQN.t;
} constraint 'a = iscsi

type 'a backstore = {
	name : string;
	backstore : 'a Backstore.t;
}

let path t = Path.acl (TPGT.path t.tpgt) t.iqn

let get tpgt =
	TPGT.path tpgt
	|> Path.acl_container
	|> LIOFSUtil.filter_subdirs (fun (name, stat) -> try let iqn = IQN.of_string name in Some { tpgt; iqn } with _ -> None)

let create ~ignore_current tpgt iqn =
	let t = { tpgt; iqn } in
	path t |> LIOFSUtil.mkdir ~ignore_current;
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
	let link_name = Printf.sprintf "backstore_%s" backstore.name in
	LIOFSUtil.with_chdir (path t) (fun () -> Unix.symlink (P.to_string link_path) (P.append lun_path link_name |> P.to_string))
*)

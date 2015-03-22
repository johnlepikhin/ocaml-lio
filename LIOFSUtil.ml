
open LIOTypes

let readdir path =
	Path.string path |> BatSys.readdir |> BatArray.to_list |> BatList.map (fun name ->
		let module P = BatPathGen.OfString in
		let st = P.append (Path.path path) name |> P.to_string |> Unix.LargeFile.lstat in
		(name, st)
	)

let filter_subdirs fn path =
	readdir path |> BatList.filter_map (fun ((name, stat) as hd) ->
		if stat.Unix.LargeFile.st_kind = Unix.S_DIR then
			fn hd
		else None
	)

let filter_symlinks fn path =
	readdir path |> BatList.filter_map (fun (name, st) ->
		if st.Unix.LargeFile.st_kind = Unix.S_LNK then (
			let module P = BatPathGen.OfString in
			let fullpath = P.append (Path.path path) name |> P.to_string in
			let link = Unix.readlink fullpath |> P.of_string in
			fn name st link
		) else None
	)

let has_subdir path name =
	not ([] = filter_subdirs (function n, _ when name = n -> Some true | _ -> None) path)

let mkdir ~ignore_current path =
	let path = Path.string path in
	try
		BatUnix.mkdir path 0o755
	with
		| Unix.Unix_error (Unix.EEXIST, _, _) when ignore_current -> ()

let rmdir ~ignore_deleted path =
	let path = Path.string path in
	(try BatUnix.rmdir path with | Unix.Unix_error (Unix.ENOENT, _, _) when ignore_deleted -> ());
	Deleted.return

let with_chdir path f =
	let open BatUnix in
	let path = Path.string path in
	let current = getcwd () in
	chdir path;
	try
		let r = f () in
		chdir current;
		r
	with
		| e ->
			chdir current;
			raise e

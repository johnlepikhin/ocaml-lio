
open LIOCommon

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

let mkdir path =
	let path = Path.string path in
	BatUnix.mkdir path 0o755

let rmdir path =
	Path.string path |> BatUnix.rmdir;
	Deleted.return


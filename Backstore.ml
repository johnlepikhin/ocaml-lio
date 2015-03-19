open LIOCommon

type fileio = {
	file : BatPathGen.OfString.t;
	backstore_group : LIOCommon.fileio BackstoreGroup.t;
}

type iblock = {
	backstore_group : LIOCommon.iblock BackstoreGroup.t;
}

type specific =
	| Fileio of fileio
	| Iblock of iblock

type 'a t = {
	name : string;
	path : backstore Path.t;
	specific : specific;
} constraint 'a = [< backstore ]

type 'a set = 'a t list

let of_path specific group path name =
	{
		name;
		path;
		specific;
	}

let specific_fileio group path =
	let module IP = BackstoreProp.FIOInfo in
	let info = IP.get path in
	let file = info.IP.file in
	Fileio { backstore_group = group; file }

let specific_iblock group path =
	Iblock { backstore_group = group }

let fileio_of_name group name =
	let group_path = BackstoreGroup.fileio_path group in
	let fileio_path = Path.backstore group_path name in
	let specific = specific_fileio group fileio_path in
	of_path specific group (Path.as_backstore fileio_path) name

let iblock_of_name group name =
	let group_path = BackstoreGroup.iblock_path group in
	let iblock_path = Path.backstore group_path name in
	let specific = specific_iblock group iblock_path in
	of_path specific group (Path.as_backstore iblock_path) name

let find fn group path =
	LIOFSUtil.filter_subdirs (fun (name, stat) -> Some (fn group name)) path

let find_fileio group =
	let group_path = BackstoreGroup.fileio_path group in
	find fileio_of_name group group_path

let find_iblock group =
	let group_path = BackstoreGroup.iblock_path group in
	find iblock_of_name group group_path

let path t = t.path

let create_fileio ~group ~name file size =
	let path = Path.backstore (BackstoreGroup.fileio_path group) name in
	LIOFSUtil.mkdir path;
	BackstoreProp.FIOControl.(set path { file; size });
	fileio_of_name group name

let create_iblock ~group ~name blockdev =
	let path = Path.backstore (BackstoreGroup.iblock_path group) name in
	LIOFSUtil.mkdir path;
	iblock_of_name group name

let delete t =
	LIOFSUtil.rmdir t.path

(*
let to_backstore t = t
*)
external to_backstore : [< backstore ] t -> backstore t = "%identity"

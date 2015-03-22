open LIOTypes

type fileio = {
	file : BatPathGen.OfString.t;
	backstore_group : LIOTypes.fileio BackstoreGroup.t;
}

type iblock = {
	backstore_group : LIOTypes.iblock BackstoreGroup.t;
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

type size = int

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

external to_backstore : [< backstore ] t -> backstore t = "%identity"

let create_fileio ~ignore_current ~group ~name file size =
	let path = Path.backstore (BackstoreGroup.fileio_path group) name in
	let bs_path = Path.as_backstore path in
	LIOFSUtil.mkdir ~ignore_current path;
	BackstoreProp.FIOControl.(set path { file; size });
	BackstoreProp.UdevPath.set bs_path file;
	BackstoreProp.Enable.set bs_path true;
	fileio_of_name group name

let create_iblock ~ignore_current ~group ~name blockdev =
	let path = Path.backstore (BackstoreGroup.iblock_path group) name in
	LIOFSUtil.mkdir ~ignore_current path;
	iblock_of_name group name

let delete ~ignore_deleted t =
	LIOFSUtil.rmdir ~ignore_deleted t.path

let file_size path =
	let path = Path.string path in
	Unix.((stat path).st_size)

let blockdev_size path = 0

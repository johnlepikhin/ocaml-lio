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
}


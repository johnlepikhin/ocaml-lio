type fileio = {
	file : BatPathGen.OfString.t;
	backstore_group : Common.fileio BackstoreGroup.t;
}

type iblock = {
	backstore_group : Common.iblock BackstoreGroup.t;
}

type specific =
	| Fileio of fileio
	| Iblock of iblock

type 'a t = {
	name : string;
	path : Common.backstore Common.Path.t;
	specific : specific;
}


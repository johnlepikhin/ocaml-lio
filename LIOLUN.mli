
open LIOTypes

type ('frontend, 'backstore) t
	constraint 'frontend = iscsi
	constraint 'backstore = [< LIOTypes.backstore ]

val path: ('frontend, 'backstore) t -> lun Path.t

val get_fileio: 'frontend TPGT.t -> ('frontend, fileio) t list
val get_iblock: 'frontend TPGT.t -> ('frontend, iblock) t list

val create: ignore_current : bool -> 'frontend TPGT.t -> 'backstore Backstore.t -> ('frontend, 'backstore) t


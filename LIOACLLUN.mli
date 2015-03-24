
open LIOTypes

type ('frontend, 'backstore) t
	constraint 'frontend = iscsi

val path: ('frontend, 'backstore) t -> acllun Path.t

(*
val get_fileio: ([< fabric ] as 'frontend) LIOACL.t -> 'a t list
*)

val create: ignore_current : bool -> 'frontend LIOACL.t -> ('frontend, 'backstore) LIOLUN.t -> ('frontend, 'backstore) t

(*
val get_fileio: 'a t -> (fileio, 'a) backstore list
val get_iblock: 'a t -> (iblock, 'a) backstore list

val add_backstore: ('backstore, 'frontend) backstore -> unit
*)


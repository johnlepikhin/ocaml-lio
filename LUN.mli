
open Common

type 'a t constraint 'a = Common.iscsi

type 'a backstore = {
	name : string;
	backstore : 'a Backstore.t;
}

val path: 'a t -> lun Path.t

val get: 'a TPGT.t -> 'a t list

val create: 'a TPGT.t -> 'a t

val get_fileio: 'a t -> fileio backstore list
val get_iblock: 'a t -> iblock backstore list

val add_backstore: 'a t -> 'b backstore -> unit

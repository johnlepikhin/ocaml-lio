
open LIOTypes

type 'a t
type 'a set = 'a t list

val fileio_path: fileio t -> fileio group Path.t
val iblock_path: iblock t -> iblock group Path.t

val find_fileio: core Path.t -> fileio set
val find_iblock: core Path.t -> iblock set

val fileio_of_name: core Path.t -> string -> fileio t
val iblock_of_name: core Path.t -> string -> iblock t

val create_fileio: ignore_current:bool -> ?id:int -> core Path.t -> fileio t
val create_iblock: ignore_current:bool -> ?id:int -> core Path.t -> iblock t

val delete_fileio: ignore_deleted:bool -> fileio t -> Deleted.t
val delete_iblock: ignore_deleted:bool -> iblock t -> Deleted.t

val id: [< fileio | iblock ] t -> int


open Common

type 'a t
type 'a set = 'a t list

val fileio_path: fileio t -> fileio group Path.t
val iblock_path: iblock t -> iblock group Path.t

val find_fileio: core Path.t -> fileio set
val find_iblock: core Path.t -> iblock set

val fileio_of_name: core Path.t -> string -> fileio t
val iblock_of_name: core Path.t -> string -> iblock t

val create_fileio: core Path.t -> fileio t
val create_iblock: core Path.t -> iblock t

val delete_fileio: fileio t -> Deleted.t
val delete_iblock: iblock t -> Deleted.t


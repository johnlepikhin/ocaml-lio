open LIOCommon

type 'a t constraint 'a = [< backstore ]
type 'a set = 'a t list

val fileio_of_name: fileio BackstoreGroup.t -> string -> fileio t
val iblock_of_name: iblock BackstoreGroup.t -> string -> iblock t

val find_fileio: fileio BackstoreGroup.t -> fileio set
val find_iblock: iblock BackstoreGroup.t -> iblock set

val path: 'a t -> backstore Path.t

val create_fileio: group : fileio BackstoreGroup.t -> name : string -> file Path.t -> int -> fileio t
val create_iblock: group : iblock BackstoreGroup.t -> name : string -> BatPathGen.OfString.t -> iblock t

val delete: 'a t -> Deleted.t

val to_backstore: 'a t -> backstore t

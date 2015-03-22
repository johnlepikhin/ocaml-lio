open LIOTypes

type 'a t constraint 'a = [< backstore ]
type 'a set = 'a t list

type size

val fileio_of_name: fileio BackstoreGroup.t -> string -> fileio t
val iblock_of_name: iblock BackstoreGroup.t -> string -> iblock t

val find_fileio: fileio BackstoreGroup.t -> fileio set
val find_iblock: iblock BackstoreGroup.t -> iblock set

val path: 'a t -> backstore Path.t

val create_fileio: ignore_current : bool -> group : fileio BackstoreGroup.t -> name : string -> file Path.t -> size -> fileio t
val create_iblock: ignore_current : bool -> group : iblock BackstoreGroup.t -> name : string -> BatPathGen.OfString.t -> iblock t

val delete: ignore_deleted : bool -> 'a t -> Deleted.t

val to_backstore: 'a t -> backstore t

val file_size: file Path.t -> size
val blockdev_size: blockdev Path.t -> size


open LIOCommon

type 'a t

val path: 'a t -> 'a Path.t

val get_iscsi: lioroot Path.t -> iscsi t

val create_iscsi: lioroot Path.t -> iscsi t


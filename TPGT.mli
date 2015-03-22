
open LIOTypes

type 'a t constraint 'a = [< fabric ]

val path: iscsi t -> iscsi tpgt Path.t

val get: iscsi LIONode.t -> iscsi t list

val create: ignore_current : bool -> ?id : int -> iscsi LIONode.t -> iscsi t

val add_np: ignore_current : bool -> iscsi t -> Unix.inet_addr -> int -> unit

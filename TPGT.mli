
open LIOCommon

type 'a t constraint 'a = [< fabric ]

val path: iscsi t -> iscsi tpgt Path.t

val get: iscsi LIONode.t -> iscsi t list

val create: iscsi LIONode.t -> iscsi t


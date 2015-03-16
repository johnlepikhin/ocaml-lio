
open Common

type 'a t constraint 'a = [< Common.fabric ]

val path: iscsi t -> iscsi tpgt Path.t

val get: iscsi Node.t -> iscsi t list

val create: iscsi Node.t -> iscsi t


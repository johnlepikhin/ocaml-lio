
open LIOTypes

type 'a t constraint 'a = [< fabric ]

val path: iscsi t -> iscsi node Path.t

val create_iscsi: ignore_current : bool -> iscsi Frontend.t -> IQN.t -> iscsi t

val find_iscsi: iscsi Frontend.t -> iscsi t list

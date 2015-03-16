
open Common

type 'a t constraint 'a = [< Common.fabric ]

val path: iscsi t -> iscsi node Path.t

val create_iscsi: iscsi Frontend.t -> IQN.t -> iscsi t

val find_iscsi: iscsi Frontend.t -> iscsi t list

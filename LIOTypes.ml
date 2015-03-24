
type lioroot = [ `LIORoot ]
type core = [ `Core ]
type iscsi = [ `ISCSI ]

type fileio = [ `FileIO ]
type iblock = [ `Iblock ]
type backstore = [ fileio | iblock ]

type fabric = [ | iscsi ]

type 'a group constraint 'a = [< backstore ]

type file = [ | `File ]
type blockdev = [ | `Blockdev ]

type 'a frontend constraint 'a = [< fabric ]

type 'a node constraint 'a = [< fabric ]

type 'a tpgt constraint 'a = [< fabric ]

type lun_container
type lun
type np
type acl_container
type acl
type acllun

exception AlreadyExists

module Deleted
	: sig
		type t

		val return: t
	end
	= struct
		type t = unit

		let return = ()
	end

module Path
	: sig
		type +'a t

		val path: 'a t -> BatPathGen.OfString.t
		val string: 'a t -> string

		val lioroot: BatPathGen.OfString.t -> lioroot t
		val core: lioroot t -> core t
		val iscsi: lioroot t -> iscsi t

		val blockdev: BatPathGen.OfString.t -> blockdev t
		val file: BatPathGen.OfString.t -> file t

		val backstore_group_fileio: core t -> int -> [> fileio ] group t
		val backstore_group_iblock: core t -> int -> [> iblock ] group t

		val backstore: ([< backstore ] as 'a) group t -> string -> 'a t
		val as_backstore: [< backstore ] t -> backstore t

		val node_iscsi: iscsi t -> IQN.t -> [> iscsi ] node t
		val tpgt: 'a node t -> int -> 'a tpgt t
		val lun_container: 'a tpgt t -> lun_container t
		val lun: 'a tpgt t -> int -> lun t
		val np: 'a tpgt t -> Unix.inet_addr -> int -> np t
		val acl_container: 'a tpgt t -> acl_container t
		val acl: 'a tpgt t -> IQN.t -> acl t
		val acllun: acl t -> int -> acllun t

		val to_file: [< file | blockdev ] t -> file t
	end
	= struct
		module P = BatPathGen.OfString

		type 'a t = P.t

		let path t = t
		let string = P.to_string
		let lioroot t = t
		let core root = P.append root "core"
		let iscsi root = P.append root "iscsi"
		let blockdev t = t
		let file t = t

		let backstore_group_fileio core id = P.append core (Printf.sprintf "fileio_%i" id)
		let backstore_group_iblock core id = P.append core (Printf.sprintf "iblock_%i" id)

		let backstore = P.append
		let as_backstore t = t

		let node_iscsi t iqn = IQN.string iqn |> P.append t
		let tpgt t id = P.append t (Printf.sprintf "tpgt_%i" id)
		let lun_container t = P.append t "lun"
		let lun t id = P.append (lun_container t) (Printf.sprintf "lun_%i" id)

		let np t inet_addr port =
			let name = Printf.sprintf "%s:%i" (BatUnix.string_of_inet_addr inet_addr) port in
			P.concat t [name; "np"]

		let acl_container t = P.append t "acls"
		let acl t iqn = P.concat t [IQN.string iqn; "acls"]

		let acllun t id = P.append t (Printf.sprintf "lun_%i" id)

		external to_file : [< file | blockdev ] t -> file t = "%identity"
	end

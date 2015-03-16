open Common

exception InvalidValue

let set fn v path =
	let v = fn v in
	BatFile.with_file_out path (fun ch -> BatIO.nwrite ch v)

let get fn path =
	BatFile.with_file_in path BatIO.read_all |> fn

module type COMMON =
	sig
		type t
		type path_t

		val name: string
	end

module type WO =
	sig
		include COMMON
		val set: t -> string -> unit
	end

module type RO =
	sig
		include COMMON
		val get: string -> t
	end

module type RW =
	sig
		include COMMON
		val set: t -> string -> unit
		val get: string -> t
	end

module CommonMake(T : COMMON)
	: sig
		val make_path': T.path_t Path.t -> string -> string
	end
	= struct
		let make_path' path name =
			BatPathGen.OfString.append (Path.path path) name |> BatPathGen.OfString.to_string
	end

module ROMake(T : RO)
	= struct
		include CommonMake(T)

		let get path = make_path' path T.name |> T.get
	end

module WOMake(T : WO)
	= struct
		include CommonMake(T)

		let set path t = make_path' path T.name |> T.set t
	end

module RWMake(T : RW)
	= struct
		include CommonMake(T)

		let get path = make_path' path T.name |> T.get
		let set path t = make_path' path T.name |> T.set t
	end

module PBool =
	struct
		type t = bool
		let set = set (function true -> "1\n" | false -> "0\n")
		let get = get (function "1\n" -> true | "0\n" -> false | _ -> raise InvalidValue)
	end

module PString =
	struct
		type t = string
		let set = set (fun t -> t)
		let get = get (fun t -> t)
	end


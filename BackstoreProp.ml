open LIOTypes
open LIOProp

module BackstoreBool = struct include PBool type path_t = backstore end
module BackstoreString = struct include PString type path_t = backstore end

module Enable = RWMake(struct include BackstoreBool let name = "enable" end)
module Alias = RWMake(struct include BackstoreString let name = "alias" end)

module FIOControl =
	struct
		type _t = {
			file : file Path.t;
			size : int;
		}
		include WOMake(
			struct
				type t = _t
				type path_t = LIOTypes.fileio

				let name = "control"

				let set = set (fun t -> Printf.sprintf "fd_dev_name=%s,fd_dev_size=%i" (Path.string t.file) t.size)
			end)
	end

module UdevPath = RWMake(
	struct
		type t = file Path.t
		type path_t = LIOTypes.backstore

		let name = "udev_path"

		let set = set Path.string

		let get = get (fun s -> BatPathGen.OfString.of_string s |> Path.file)
	end
)

module FIOInfo =
	struct
		type mode =
			| DSYNC
			| BufferedWCE

		type _t = {
			active : bool;
			max_queue_depth : int;
			sector_size : int;
			hw_max_sectors : int;
			file : BatPathGen.OfString.t;
			file_size : int;
			mode : mode;
		}

		include ROMake(
			struct
				type t = _t
				type path_t = LIOTypes.fileio

				let name = "info"

				open LIOExt

				let rex = Pcre.regexp ("^Status: (\\S+)  Max Queue Depth: (\\d+)  SectorSize: (\\d+)  HwMaxSectors: (\\d+)\n"
					^ "\\s*TCM FILEIO ID: \\d+\\s+File: (.*?)  Size: (\\d+)  Mode: (.*)$")

				let get = get (fun c ->
					try
						match Pcre.extract_list ~rex c with
							| [_; active; max_queue_depth; sector_size; hw_max_sectors; file; file_size; mode] ->
								let active = active = "ACTIVATED" in
								let max_queue_depth = int_of_string max_queue_depth in
								let sector_size = int_of_string sector_size in
								let hw_max_sectors = int_of_string hw_max_sectors in
								let file = BatPathGen.OfString.of_string file in
								let file_size = int_of_string file_size in
								let mode = match mode with
									| "O_DSYNC" -> DSYNC
									| "Buffered-WCE" -> BufferedWCE
									| _ -> raise InvalidValue
								in
								{ active; max_queue_depth; sector_size; hw_max_sectors; file; file_size; mode; }
							| l ->
								raise InvalidValue
					with
						| _ ->
							raise InvalidValue
					
				)
			end)
	end

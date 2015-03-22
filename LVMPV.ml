
open LIOTypes

type t = {
	uuid : string;
	dev_size : int;
	name : string;
	mda_free : int;
	mda_size : int;
	pe_start : int;
	size : int;
	free : int;
	used : int;
	attr : string;
	pe_count : int;
	pa_alloc_count : int;
	tags : string;
	mda_count : int;
	mda_used_count : int;
}

let list () =
	let open LVMutil in
	listread "pv" |> List.map (fun lst ->
		{
			uuid = get_string "LVM2_PV_UUID" lst;
			dev_size = get_int "LVM2_DEV_SIZE" lst;
			name = get_string "LVM2_PV_NAME" lst;
			mda_free = get_int "LVM2_PV_MDA_FREE" lst;
			mda_size = get_int "LVM2_PV_MDA_SIZE" lst;
			pe_start = get_int "LVM2_PE_START" lst;
			size = get_int "LVM2_PV_SIZE" lst;
			free = get_int "LVM2_PV_FREE" lst;
			used = get_int "LVM2_PV_USED" lst;
			attr = get_string "LVM2_PV_ATTR" lst;
			pe_count = get_int "LVM2_PV_PE_COUNT" lst;
			pa_alloc_count = get_int "LVM2_PV_PE_ALLOC_COUNT" lst;
			tags = get_string "LVM2_PV_TAGS" lst;
			mda_count = get_int "LVM2_PV_MDA_COUNT" lst;
			mda_used_count = get_int "LVM2_PV_MDA_USED_COUNT" lst;
		}
	)

let create (dev : blockdev Path.t) =
	LIOExt.Unix.arg_exec "/sbin/pvcreate" [| "pvcreate"; Path.string dev |]

let remove (dev : blockdev Path.t) =
	LIOExt.Unix.arg_exec "/sbin/pvremove" [| "pvremove"; Path.string dev |];
	Deleted.return

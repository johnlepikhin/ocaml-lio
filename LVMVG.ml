
open LIOTypes

type t = {
	uuid : string;
	name : string;
	attr : string;
	size : int;
	free : int;
	sysid : string;
	extent_size : int;
	extent_count : int;
	free_count : int;
	max_lv : int;
	max_pv : int;
	pv_count : int;
	lv_count : int;
	snap_count : int;
	seq_no : int;
	tags : string;
	mda_count : int;
	mda_used_count : int;
	mda_free : int;
	mda_size : int;
	mda_copies : string;
}

let list () =
	let open LVMutil in
	listread "vg" |> List.map (fun lst ->
		{
			uuid = get_string "LVM2_VG_UUID" lst;
			name = get_string "LVM2_VG_NAME" lst;
			attr = get_string "LVM2_VG_ATTR" lst;
			size = get_int "LVM2_VG_SIZE" lst;
			free = get_int "LVM2_VG_FREE" lst;
			sysid = get_string "LVM2_VG_SYSID" lst;
			extent_size = get_int "LVM2_VG_EXTENT_SIZE" lst;
			extent_count = get_int "LVM2_VG_EXTENT_COUNT" lst;
			free_count = get_int "LVM2_VG_FREE_COUNT" lst;
			max_lv = get_int "LVM2_MAX_LV" lst;
			max_pv = get_int "LVM2_MAX_PV" lst;
			pv_count = get_int "LVM2_PV_COUNT" lst;
			lv_count = get_int "LVM2_LV_COUNT" lst;
			snap_count = get_int "LVM2_SNAP_COUNT" lst;
			seq_no = get_int "LVM2_VG_SEQNO" lst;
			tags = get_string "LVM2_VG_TAGS" lst;
			mda_count = get_int "LVM2_VG_MDA_COUNT" lst;
			mda_used_count = get_int "LVM2_VG_MDA_USED_COUNT" lst;
			mda_free = get_int "LVM2_VG_MDA_FREE" lst;
			mda_size = get_int "LVM2_VG_MDA_SIZE" lst;
			mda_copies = get_string "LVM2_VG_MDA_COPIES" lst;
		}
	)

let create name (devs : blockdev Path.t list) =
	"vgcreate" :: List.map Path.string devs
		|> Array.of_list 
		|> LIOExt.Unix.arg_exec "/sbin/vgcreate"

let remove name =
	LIOExt.Unix.arg_exec "/sbin/vgremove" [| "vgremove"; name |];
	Deleted.return

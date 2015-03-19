
open LIOCommon

type t = {
	uuid : string;
	name : string;
	vg_name : string;
	path : blockdev Path.t;
	attr : string;
	major : int;
	minor : int;
	read_ahead : string;
	kernel_major : int;
	kernel_minor : int;
	kernel_read_ahead : string;
	size : int;
	metadata_size : int;
	seg_count : int;
	origin : string;
	origin_size : int;
	data_percent : float;
	snap_percent : float;
	metadata_percent : float;
	copy_percent : float;
	move_pv : string;
	current_lv : string;
	mirror_log : string;
	data_lv : string;
	metadata_lv : string;
	pool_lv : string;
	tags : string;
	time : string;
	host : string;
	modules : string;
}

let list () =
	let open LVMutil in
	listread ~options:",vg_all" "lv" |> List.map (fun lst ->
		{
			uuid = get_string "LVM2_LV_UUID" lst;
			name = get_string "LVM2_PV_NAME" lst;
			vg_name = get_string "LVM2_VG_NAMELVM2_VG_NAME" lst;
			path = get_string "LVM2_LV_PATH" lst |> BatPathGen.OfString.of_string |> Path.blockdev;
			attr = get_string "LVM2_PV_ATTR" lst;
			major = get_int "LVM2_LV_MAJOR" lst;
			minor = get_int "LVM2_LV_MINOR" lst;
			read_ahead = get_string "LVM2_LV_READ_AHEAD" lst;
			kernel_major = get_int "LVM2_LV_KERNEL_MAJOR" lst;
			kernel_minor = get_int "LVM2_LV_KERNEL_MINOR" lst;
			kernel_read_ahead = get_string "LVM2_LV_KERNEL_READ_AHEAD" lst;
			size = get_int "LVM2_LV_SIZE" lst;
			metadata_size = get_int "LVM2_LV_METADATA_SIZE" lst;
			seg_count = get_int "LVM2_SEG_COUNT" lst;
			origin = get_string "LVM2_ORIGIN" lst;
			origin_size = get_int "LVM2_ORIGIN_SIZE" lst;
			data_percent = get_float "LVM2_DATA_PERCENT" lst;
			snap_percent = get_float "LVM2_SNAP_PERCENT" lst;
			metadata_percent = get_float "LVM2_METADATA_PERCENT" lst;
			copy_percent = get_float "LVM2_COPY_PERCENT" lst;
			move_pv = get_string "LVM2_MOVE_PV" lst;
			current_lv = get_string "LVM2_CONVERT_LV" lst;
			mirror_log = get_string "LVM2_MIRROR_LOG" lst;
			data_lv = get_string "LVM2_DATA_LV" lst;
			metadata_lv = get_string "LVM2_METADATA_LV" lst;
			pool_lv = get_string "LVM2_POOL_LV" lst;
			tags = get_string "LVM2_LV_TAGS" lst;
			time = get_string "LVM2_LV_TIME" lst;
			host = get_string "LVM2_LV_HOST" lst;
			modules = get_string "LVM2_MODULES" lst;
		}
	)

let create_kb kb name (vg : LVMVG.t) =
	let size = Printf.sprintf "%ik" kb in
	LIOExt.Unix.arg_exec "/sbin/lvcreate" [| "lvcreate"; "-L"; size; "-n"; name; vg.LVMVG.name |]

let remove t =
	LIOExt.Unix.arg_exec "/sbin/lvchange" [| "lvchange"; "-an"; Path.string t.path |];
	LIOExt.Unix.arg_exec "/sbin/lvremove" [| "lvremove"; Path.string t.path |];
	Deleted.return

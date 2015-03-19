
open LIOCommon

type entry =
	| ISCSI

type 'a t = {
	path : 'a Path.t;
	entry : entry;
}

let path t = t.path

let create entry path =
	LIOFSUtil.mkdir path;
	{
		path;
		entry;
	}

let create_iscsi root =
	Path.iscsi root |> create ISCSI

let get_iscsi root =
	if LIOFSUtil.has_subdir root "iscsi" then
		{
			path = Path.iscsi root;
			entry = ISCSI;
		}
	else
		raise Not_found

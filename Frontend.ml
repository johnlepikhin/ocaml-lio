
open LIOTypes

type entry =
	| ISCSI

type 'a t = {
	path : 'a Path.t;
	entry : entry;
}

let path t = t.path

let create ~ignore_current entry path =
	LIOFSUtil.mkdir ~ignore_current path;
	{
		path;
		entry;
	}

let create_iscsi ~ignore_current root =
	Path.iscsi root |> create ~ignore_current ISCSI

let get_iscsi root =
	if LIOFSUtil.has_subdir root "iscsi" then
		{
			path = Path.iscsi root;
			entry = ISCSI;
		}
	else
		raise Not_found

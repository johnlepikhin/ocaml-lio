
open Common

let root = Path.lioroot (BatPathGen.OfString.of_string "/sys/kernel/config/target")
let core = Path.core root
let iscsi = Frontend.get_iscsi root

let node_lst = Node.find_iscsi iscsi
let () = List.iter (fun node ->
	let tpgt_list = TPGT.get node in
	List.iter (fun tpgt ->
		let lun_list = LUN.get tpgt in
		Printf.printf "LUNs... [%i]\n" (List.length lun_list);
		List.iter (fun lun ->
			let f t = let open LUN in { t with backstore = Backstore.to_backstore t.backstore } in
			let bs_list1 = try List.map f (LUN.get_fileio lun) with _ -> [] in
			let bs_list2 = try List.map f (LUN.get_iblock lun) with _ -> [] in
			let bs_list = bs_list1 @ bs_list2 in
			Printf.printf "backstores... [%i]\n" (List.length bs_list);
			List.iter (fun bs ->
				let open LUN in
				Printf.printf "%s -> %s\n" bs.name (Backstore.path bs.backstore |> Path.path |> BatPathGen.OfString.to_string);
			) bs_list
		) lun_list
	) tpgt_list
) node_lst

(*
let () =
	List.iter (fun group ->
		let luns = Backstore.find_fileio group in
		List.iter (fun lun ->
			let path = Backstore.path lun |> Path.string in
			let open BackstoreProp in
			let open Backstore_t in
			let en : bool = Enable.get (Backstore.path lun) in
			let al : string = Alias.get (Backstore.path lun) in
			Printf.printf "%s enabled=%B alias='%s'\n"
				path
				en
				al;
		) luns;
		let t = Backstore.create_fileio ~group ~name:"test2" (Path.file (BatPathGen.OfString.of_string "/tmp/1")) 134217728 in
		()
	) lst
*)


let tcm = Lwt_log_core.Section.make "TCM"
let iscsi = Lwt_log_core.Section.make "iSCSI"

let init () =
	let template = "$(date) $(name)[$(pid)]: $(section): $(message)" in
	lwt logger_file = Lwt_log.file ~template ~file_name:"/tmp/LIO.log" () in
	let logger_syslog = Lwt_log.syslog ~template ~facility:`User () in
	let logger = Lwt_log_core.broadcast [logger_file; logger_syslog] in
	Lwt_log_core.default := logger;
	Lwt.return ()

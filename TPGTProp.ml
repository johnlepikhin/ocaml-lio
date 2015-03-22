open LIOTypes
open LIOProp

module Enable = RWMake(struct include PBool type path_t = iscsi tpgt let name = "enable" end)

module Auth =
	struct
		module Userid = RWMake(struct include PString type path_t = tpgt_auth let name = "userid" end)
		module Password = RWMake(struct include PString type path_t = tpgt_auth let name = "password" end)
	end

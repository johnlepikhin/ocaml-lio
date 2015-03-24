open LIOTypes
open LIOProp

module Enable = RWMake(struct include PBool type path_t = acl let name = ["enable"] end)

module Auth =
	struct
		let subdir = "auth"
		module Userid = RWMake(struct include PString type path_t = acl let name = ["userid"; subdir] end)
		module Password = RWMake(struct include PString type path_t = acl let name = ["password"; subdir] end)
	end

include("plat/build.lua")

build_ncg {
	name = "ncg",
	arch = "crayxmp",
}

build_top {
	name = "top",
	arch = "crayxmp",
}

return installable {
	name = "tools",
	map = {
		["$(PLATDEP)/cos/ncg"] = "+ncg",
		["$(PLATDEP)/cos/top"] = "+top",
		["$(PLATIND)/descr/cos"] = "./descr",
		"util/opt+pkg",
	}
}

include("plat/build.lua")
include("lang/build.lua")

ackfile {
	name = "boot",
	srcs = { "./boot.s" },
	vars = {
		plat = "cos",
	}
}

build_plat_libs {
	name = "libs",
	arch = "crayxmp",
	plat = "cos",
}

installable {
	name = "pkg",
	map = {
		"+tools",
		"+libs",
		"./include+pkg",
		["$(PLATIND)/cos/boot.o"] = "+boot",
		["$(PLATIND)/cos/libsys.a"] = "./libsys+lib",
	}
}


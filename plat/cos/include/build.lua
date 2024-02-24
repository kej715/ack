include("plat/build.lua")

headermap = {}
packagemap = {}

local function addheader(h)
	headermap[h] = "./"..h
	packagemap["$(PLATIND)/cos/include/"..h] = "./"..h
end

addheader("ack/plat.h")
addheader("sys/types.h")
addheader("cal/macros.s")

acklibrary {
	name = "headers",
	hdrs = headermap
}

installable {
	name = "pkg",
	map = packagemap
}



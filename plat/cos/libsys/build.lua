acklibrary {
    name = "internal",
    hdrs = {
		"./cos.h",
		"./ftentry.h",
		"./trap.h",
	}
}

local trap_calls = {
    "EARRAY",
    "EBADGTO",
    "EBADLAE",
    "EBADLIN",
    "EBADMON",
    "EBADPC",
    "EBADPTR",
    "ECASE",
    "ECONV",
    "EFDIVZ",
    "EFOVFL",
    "EFUND",
    "EFUNFL",
    "EHEAP",
    "EIDIVZ",
    "EILLINS",
    "EIOVFL",
    "EIUND",
    "EMEMFLT",
    "EODDZ",
    "ERANGE",
    "ESET",
    "ESTACK",
    "EUNIMPL",
}

local generated = {}
for _, name in pairs(trap_calls) do
    generated[#generated+1] = normalrule {
        name = name,
        ins = { "./make_trap.sh" },
        outleaves = { name..".s" },
        commands = {
            "%{ins[1]} "..name:lower().." "..name.." > %{outs}"
        }
    }
end

acklibrary {
    name = "lib",
    srcs = {
		"./args.s",
		"./bp2wp.s",
		"./brk.s",
		"./close.c",
		"./coscls.s",
		"./cosdat.s",
		"./cosdnt.s",
		"./cosopn.s",
		"./cosrdp.s",
		"./cosrew.s",
		"./cosrls.s",
		"./costim.s",
		"./coswdp.s",
		"./coswdr.s",
		"./coswed.s",
		"./coswef.s",
		"./creat.c",
		"./dmp.s",
		"./exists.c",
		"./files.c",
		"./frmptr.s",
		"./getdsp.s",
		"./i24tod.s",
		"./i24too.s",
		"./i32tox.s",
		"./isatty.c",
		"./lseek.c",
		"./open.c",
		"./pack.s",
		"./pargs.c",
		"./read.c",
		"./reopen.c",
		"./signal.c",
		"./sysio.s",
		"./syslog.s",
		"./time.c",
		"./trap.s",
		"./unlink.c",
		"./unpack.s",
		"./wp2bp.s",
		"./write.c",
		generated
    },
    deps = {
		"lang/cem/libcc.ansi/headers+headers",
		"plat/cos/include+headers",
		"+internal",
	},
    vars = {
        plat = "cos"
    }
}


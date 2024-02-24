for _, plat in ipairs(vars.plats) do
	acklibrary {
		name = "lib_"..plat,
		srcs = {
			"./aar.s",
			"./and.s",
			"./blm.s",
			"./cai.s",
			"./cfi.s",
			"./cif.s",
			"./cms.s",
			"./com.s",
			"./csa.s",
			"./csb.s",
			"./cuf.s",
			"./dup.s",
			"./dvf.s",
			"./dvi.s",
			"./dvu.s",
			"./exg.s",
			"./fef.s",
			"./fif.s",
			"./gto.s",
			"./inn.s",
			"./ior.s",
			"./lar.s",
			"./loi.s",
			"./mli.s",
			"./mlu.s",
			"./mon.s",
			"./nop.s",
			"./rmi.s",
			"./rmu.s",
			"./sar.s",
			"./set.s",
			"./sti.s",
			"./xor.s",
		},
		vars = { plat = plat },
	}
end


definerule("yacc",
	{
		srcs = { type="targets" },
		commands = {
			type="strings",
			default={
				"yacc -t -b %{dir}/y -d %{ins}"
			}
		},
	},
	function (e)
		return normalrule {
			name = e.name,
			cwd = e.cwd,
			ins = e.srcs,
			outleaves = { "y.tab.c", "y.tab.h" },
			label = e.label,
			commands = e.commands,
		}
	end
)



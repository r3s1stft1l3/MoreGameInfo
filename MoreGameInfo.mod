return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`MoreGameInfo` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("MoreGameInfo", {
			mod_script       = "scripts/mods/MoreGameInfo/MoreGameInfo",
			mod_data         = "scripts/mods/MoreGameInfo/MoreGameInfo_data",
			mod_localization = "scripts/mods/MoreGameInfo/MoreGameInfo_localization",
		})
	end,
	packages = {
		"resource_packages/MoreGameInfo/MoreGameInfo",
	},
}

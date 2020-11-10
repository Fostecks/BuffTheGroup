btg = btg or { }

function btg.buildMenu()
	local panelData = {
		type = "panel",
		name = btg.name,
		displayName = "BuffTheGroup",
		author = "bitrock, garlicmoon, Wheels, Kingslayer513",
		version = ""..btg.version,
		registerForDefaults = true,
		registerForRefresh = true
	}

	local options = {
		{
			type = "header",
			name = "Settings",
		},
		{
			type = "checkbox",
			name = "Enabled",
			tooltip = "Toggles the UI",
			default = btg.defaults.enabled,
			getFunc = function() 
				return btg.savedVars.enabled
			end,
			setFunc = function(value)
				btg.savedVars.enabled = value
				btg.CheckActivation()
			end,
		},
		{
			type = "checkbox",
			name = "Gradient Mode",
			tooltip = "Changes whether the buff duration will decay using a color gradient",
			default = btg.defaults.gradientMode,
			getFunc = function()
				return btg.savedVars.gradientMode
			end,
			setFunc = function(value)
				btg.savedVars.gradientMode = value
			end,
		},
		{
			type = "header",
			name = "Buffs",
		},
		-- buffs inserted here
		{
			type = "button",
			name = "Deselect All",
			width = "half",
			func = function()
				for i = 1, #btgData.buffs do
					btg.savedVars.trackedBuffs[i] = false
				end
				btg.CheckActivation()
			end,
		},
		{
			type = "button",
			name = "Reset Positions",
			width = "half",
			func = function()
				for i = 1, #btgData.buffs do
					btg.savedVars.framePositions[i] = {
						left = 1300,
						top = 150 + (i-1)*85,
					}
					btg.frames[i].frame:ClearAnchors()
					btg.frames[i].frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, btg.savedVars.framePositions[i].left, btg.savedVars.framePositions[i].top)
				end
			end,
		}
	}

	for i, buff in ipairs(btgData.buffs) do
		table.insert(options, #options-1, {
			type = "checkbox",
			name = buff,
			default = btg.defaults.trackedBuffs[i],
			getFunc = function()
				return btg.savedVars.trackedBuffs[i]
			end,
			setFunc = function(value)
				btg.savedVars.trackedBuffs[i] = value
				btg.CheckActivation()
			end,
		})
	end

	LibAddonMenu2:RegisterAddonPanel(btg.name.."Options", panelData)
	LibAddonMenu2:RegisterOptionControls(btg.name.."Options", options)
end

btg = btg or { }
local EM = GetEventManager()

function btg.buildMenu()
	local panelData = {
		type = "panel",
		name = btg.name,
		displayName = "BuffTheGroup",
		author = "bitrock, garlicmoon, Wheels, Kingslayer513",
		version = ""..btg.version,
		registerForDefaults = true,
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
			reference = "btgControlEnabled"
		},
		{
			type = "checkbox",
			name = "Always On",
			tooltip = "Buff trackers will be permanently visible",
			default = btg.defaults.alwaysOn,
			getFunc = function()
				return btg.savedVars.alwaysOn
			end,
			setFunc = function(value)
				btg.savedVars.alwaysOn = value
				btg.CheckActivation()
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
					local control = _G["btgControlBuff"..i]

					btg.savedVars.trackedBuffs[i] = false
					control.value = false
					control.label:SetColor(ZO_DEFAULT_DISABLED_COLOR:UnpackRGBA())
					control.checkbox:SetText(control.uncheckedText)
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

	for index, buff in ipairs(btgData.buffs) do
		table.insert(options, #options-1, {
			type = "checkbox",
			name = buff,
			default = index == 1,
			getFunc = function()
				return btg.savedVars.trackedBuffs[index]
			end,
			setFunc = function(value)
				btg.savedVars.trackedBuffs[index] = value
				btg.CheckActivation()
			end,
			reference = "btgControlBuff"..index
		})
	end

	LibAddonMenu2:RegisterAddonPanel(btg.name.."Options", panelData)
	LibAddonMenu2:RegisterOptionControls(btg.name.."Options", options)
end

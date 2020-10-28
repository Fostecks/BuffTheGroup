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
			name = "Debug Mode",
			tooltip = "Buff trackers are always visible and debug messages are printed to chat",
			default = btg.defaults.debug,
			getFunc = function()
				return btg.savedVars.debug
			end,
			setFunc = function(value)
				btg.savedVars.debug = value
				btg.CheckActivation()
			end,
		},
		{
			type = "header",
			name = "Buffs",
		},
	}

	for index, buff in ipairs(btgData.buffs) do
		table.insert(options, {
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

	table.insert(options, {
		type = "button",
		name = "Deselect All",
		width = "half",
		func = function()
			for i = 1, #btgData.buffs do
				local control = _G["btgControlBuff"..i]

				control.value = false
				btg.savedVars.trackedBuffs[i] = false
				control.label:SetColor(ZO_DEFAULT_DISABLED_COLOR:UnpackRGBA())
				control.checkbox:SetText(control.uncheckedText)
			end
			btg.CheckActivation()
		end,
	})

	table.insert(options, {
		type = "button",
		name = "Reset Positions",
		width = "half",
		func = function()
			for i = 1, #btgData.buffs do
				btg.savedVars.framePositions[i] = {
					left = 1200,
					top = 100 + (i-1)*85,
				}
				btg.frames[i].frame:ClearAnchors()
				btg.frames[i].frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, btg.savedVars.framePositions[i].left, btg.savedVars.framePositions[i].top)
			end
		end,
	})

	LibAddonMenu2:RegisterAddonPanel(btg.name.."Options", panelData)
	LibAddonMenu2:RegisterOptionControls(btg.name.."Options", options)
end

BuffTheGroup = BuffTheGroup or { }
local btg  = BuffTheGroup
local EM = GetEventManager()

function BuffTheGroup.buildMenu()
	local LAM = LibAddonMenu2

	local panelData = {
		type = "panel",
		name = btg.name,
		displayName = "BuffTheGroup",
		author = "bitrock, Wheels, garlicmoon, Kingslayer513",
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
			
		},
        {
			type = "dropdown",
			name = "Buff",
			tooltip = "Buff to track",
			choices = BuffTheGroupData.buffSelectionList,
			default = BuffTheGroupData.buffSelectionList[btg.defaults.trackedBuff],
			getFunc = function() return BuffTheGroupData.buffSelectionList[btg.savedVars.trackedBuff] end,
			setFunc = function(selected)
				for index, name in ipairs(BuffTheGroupData.buffSelectionList) do
					if name == selected then
						btg.savedVars.trackedBuff = index
						break
					end
				end
				btg.CheckActivation()
			end,
            scrollable = true,
            reference = "buff_dropdown",
		},
		{
			type = "checkbox",
			name = "Gradient Mode",
			tooltip = "Changes whether the buff duration will decay using a color gradient",
			default = btg.defaults.gradientMode,
			getFunc = function() return btg.savedVars.gradientMode end,
			setFunc = function(value)
				btg.savedVars.gradientMode = value
				btg.CheckActivation()
			end,
			
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
	}
	LAM:RegisterAddonPanel(btg.name.."Options", panelData)
	LAM:RegisterOptionControls(btg.name.."Options", options)
end


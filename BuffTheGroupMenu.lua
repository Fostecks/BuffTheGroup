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
		version = ""..btg.savedVars.version,
	}

	local options = {
		{
			type = "header",
			name = "Settings",
		},
        {
			type = "dropdown",
			name = "Buff",
			tooltip = "Buff to track",
			choices = BuffTheGroupData.buffSelectionList,
			default = BuffTheGroupData.buffSelectionList[1],
			getFunc = function() return BuffTheGroupData.buffSelectionList[btg.savedVars.trackedBuff] end,
			setFunc = function(selected)
				for index, name in ipairs(BuffTheGroupData.buffSelectionList) do
					if name == selected then
						btg.savedVars.trackedBuff = index
						break
					end
				end
				btg.Reset()
			end,
            scrollable = true,
            reference = "buff_dropdown",
		},
		{
			type = "checkbox",
			name = "Gradient Mode",
			tooltip = "Changes whether the buff duration will decay using a color gradient",
			getFunc = function() return btg.savedVars.gradientMode end,
			setFunc = function(value)
				btg.savedVars.gradientMode = value
				btg.Reset()
			end,
			
		},
	}
	LAM:RegisterAddonPanel(btg.name.."Options", panelData)
	LAM:RegisterOptionControls(btg.name.."Options", options)
end


BuffTheGroup = {
	name = "BuffTheGroup",
	version = "1.1.0",

	-- Default settings
	defaults = {
		left = 1000,
		top = 500,
		maxRows = 6,
		trackedBuff = 1,
		gradientMode = true,
		enabled = true,
		debug = false
	},

	roleIcons = {
		[LFG_ROLE_DPS] = "/esoui/art/lfg/lfg_icon_dps.dds",
		[LFG_ROLE_TANK] = "/esoui/art/lfg/lfg_icon_tank.dds",
		[LFG_ROLE_HEAL] = "/esoui/art/lfg/lfg_icon_healer.dds",
		[LFG_ROLE_INVALID] = "/esoui/art/crafting/gamepad/crafting_alchemy_trait_unknown.dds",
	},

	showUI = false,
	groupSize = 0,
	units = { },
	panels = { },
}

------GLOBALS-------
--pastel green (start color)
local red = 117
local green = 222
local blue = 120

--pastel red (destination color)
local destRed = 222
local destGreen = 117
local destBlue = 117



function BuffTheGroup.OnAddOnLoaded( eventCode, addonName )
	if (addonName ~= BuffTheGroup.name) then return end

	EVENT_MANAGER:UnregisterForEvent(BuffTheGroup.name, EVENT_ADD_ON_LOADED)

	BuffTheGroup.savedVars = ZO_SavedVars:NewCharacterIdSettings("BuffTheGroupSavedVariables", 1, nil, BuffTheGroup.defaults, nil, GetWorldName())
	BuffTheGroup.InitializeControls()
	SLASH_COMMANDS["/btg"] = BuffTheGroup.ToggleState
	SLASH_COMMANDS["/btgrefresh"] = BuffTheGroup.CheckActivation	

	EVENT_MANAGER:RegisterForEvent(BuffTheGroup.name, EVENT_PLAYER_ACTIVATED, BuffTheGroup.CheckActivation)
	EVENT_MANAGER:RegisterForEvent(BuffTheGroup.name, EVENT_RAID_TRIAL_STARTED, BuffTheGroup.CheckActivation)
	BuffTheGroup.buildMenu()
end

function BuffTheGroup.ToggleState( ) 
	BuffTheGroup.savedVars.enabled = not BuffTheGroup.savedVars.enabled
	CHAT_SYSTEM:AddMessage("[BTG] " .. (BuffTheGroup.savedVars.enabled and "enabled" or "disabled"))
	zo_callLater(BuffTheGroup.CheckActivation, 500)
end

function BuffTheGroup.CheckActivation( eventCode )
	-- Check wiki.esoui.com/AvA_Zone_Detection if we want to enable this for PvP
	local zoneId = GetZoneId(GetUnitZoneIndex("player"))

	if (BuffTheGroupData.zones[zoneId] and BuffTheGroup.savedVars.enabled or BuffTheGroup.savedVars.debug) then
	-- if(true) then
		BuffTheGroup.Reset()

		-- Workaround for when the game reports that the player is not in a group shortly after zoning
		if (BuffTheGroup.groupSize == 0) then
			zo_callLater(BuffTheGroup.Reset, 5000)
		end

		if (not BuffTheGroup.showUI) then
			BuffTheGroup.showUI = true

			EVENT_MANAGER:RegisterForEvent(BuffTheGroup.name, EVENT_GROUP_MEMBER_JOINED, BuffTheGroup.GroupUpdate)
			EVENT_MANAGER:RegisterForEvent(BuffTheGroup.name, EVENT_GROUP_MEMBER_LEFT, BuffTheGroup.GroupUpdate)
			EVENT_MANAGER:RegisterForEvent(BuffTheGroup.name, EVENT_GROUP_MEMBER_ROLE_CHANGED, BuffTheGroup.GroupMemberRoleChanged)
			EVENT_MANAGER:RegisterForEvent(BuffTheGroup.name, EVENT_GROUP_SUPPORT_RANGE_UPDATE, BuffTheGroup.GroupSupportRangeUpdate)
			EVENT_MANAGER:RegisterForEvent(BuffTheGroup.name, EVENT_EFFECT_CHANGED, BuffTheGroup.EffectChanged)
			EVENT_MANAGER:RegisterForUpdate(BuffTheGroup.name.."Cycle", 100, BuffTheGroup.refreshUI)
			EVENT_MANAGER:AddFilterForEvent(BuffTheGroup.name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")

			SCENE_MANAGER:GetScene("hud"):AddFragment(BuffTheGroup.fragment)
			SCENE_MANAGER:GetScene("hudui"):AddFragment(BuffTheGroup.fragment)
		end
	else
		if (BuffTheGroup.showUI) then
			BuffTheGroup.showUI = false

			EVENT_MANAGER:UnregisterForEvent(BuffTheGroup.name, EVENT_GROUP_MEMBER_JOINED)
			EVENT_MANAGER:UnregisterForEvent(BuffTheGroup.name, EVENT_GROUP_MEMBER_LEFT)
			EVENT_MANAGER:UnregisterForEvent(BuffTheGroup.name, EVENT_GROUP_MEMBER_ROLE_CHANGED)
			EVENT_MANAGER:UnregisterForEvent(BuffTheGroup.name, EVENT_GROUP_SUPPORT_RANGE_UPDATE)
			EVENT_MANAGER:UnregisterForEvent(BuffTheGroup.name, EVENT_EFFECT_CHANGED)

			EVENT_MANAGER:UnregisterForEvent(BuffTheGroup.name, EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED)
			EVENT_MANAGER:UnregisterForEvent(BuffTheGroup.name, EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED)
			EVENT_MANAGER:UnregisterForEvent(BuffTheGroup.name, EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED)

			SCENE_MANAGER:GetScene("hud"):RemoveFragment(BuffTheGroup.fragment)
			SCENE_MANAGER:GetScene("hudui"):RemoveFragment(BuffTheGroup.fragment)
		end
	end
end

function BuffTheGroup.GroupUpdate( eventCode )
	zo_callLater(BuffTheGroup.Reset, 500)
end

function BuffTheGroup.GroupMemberRoleChanged( eventCode, unitTag, newRole )
	if (BuffTheGroup.units[unitTag]) then
		BuffTheGroup.panels[BuffTheGroup.units[unitTag].panelId].role:SetTexture(BuffTheGroup.roleIcons[newRole])
	end
end

function BuffTheGroup.GroupSupportRangeUpdate( eventCode, unitTag, status )
	if (BuffTheGroup.units[unitTag]) then
		BuffTheGroup.UpdateRange(BuffTheGroup.units[unitTag].panelId, status)
	end
end

function BuffTheGroup.refreshUI()
	for unitTag, unit in pairs(BuffTheGroup.units) do
		if(BuffTheGroup.savedVars.gradientMode) then
			BuffTheGroup.UpdateStatus(unitTag)
		else
			BuffTheGroup.UpdateStatusDiscrete(unitTag)
		end
	end
end

function BuffTheGroup.EffectChanged( eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType )
	local trackedBuff = BuffTheGroupData.buffSelectionList[BuffTheGroup.savedVars.trackedBuff]
	-- format effectName so it's common across all languages
	local formattedEffectName = zo_strformat(SI_ABILITY_NAME, effectName)

	if (trackedBuff == formattedEffectName and BuffTheGroup.units[unitTag]) then
		if (changeType == EFFECT_RESULT_FADED) then
			if (BuffTheGroup.units[unitTag].buff) then
				BuffTheGroup.units[unitTag].buff = 0
			end
		else
			if (BuffTheGroup.units[unitTag].buff == 0) then
				BuffTheGroup.units[unitTag].buff = 1
			end
			BuffTheGroup.units[unitTag].endTime = endTime
			BuffTheGroup.units[unitTag].buffDuration = endTime - beginTime
		end
	end
end

function BuffTheGroup.OnMoveStop( )
	BuffTheGroup.savedVars.left = BuffTheGroupFrame:GetLeft()
	BuffTheGroup.savedVars.top = BuffTheGroupFrame:GetTop()
end

function BuffTheGroup.InitializeControls( )
	local wm = GetWindowManager()

	for i = 1, GROUP_SIZE_MAX do
		local panel = wm:CreateControlFromVirtual("BuffTheGroupPanel" .. i, BuffTheGroupFrame, "BuffTheGroupPanel")
	
		BuffTheGroup.panels[i] = {
			panel = panel,
			bg = panel:GetNamedChild("Backdrop"),
			name = panel:GetNamedChild("Name"),
			role = panel:GetNamedChild("Role"),
			icon = panel:GetNamedChild("Icon"),
			stat = panel:GetNamedChild("Stat"),
		}

		BuffTheGroup.panels[i].bg:SetEdgeColor(0, 0, 0, 0)
		BuffTheGroup.panels[i].stat:SetColor(1, 0, 1, 1)

	end

	BuffTheGroupFrame:ClearAnchors()
	BuffTheGroupFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, BuffTheGroup.savedVars.left, BuffTheGroup.savedVars.top)

	BuffTheGroup.fragment = ZO_HUDFadeSceneFragment:New(BuffTheGroupFrame)
end

function BuffTheGroup.Reset( )

	if (BuffTheGroup.savedVars.debug) then
		CHAT_SYSTEM:AddMessage("[BTG] Resetting")
	end

	BuffTheGroup.groupSize = GetGroupSize()
	BuffTheGroup.units = { }

	local trackedBuffIcon = BuffTheGroupData.iconTable[BuffTheGroup.savedVars.trackedBuff]
	BuffTheGroupFrameIcon:SetTexture(trackedBuffIcon)

	for i = 1, GROUP_SIZE_MAX do
		local soloPanel = i == 1 and BuffTheGroup.groupSize == 0

		if (i <= BuffTheGroup.groupSize or soloPanel) then
			local unitTag = (soloPanel) and "player" or GetGroupUnitTagByIndex(i)

			BuffTheGroup.units[unitTag] = {
				panelId = i,
				buff = 0,
				endTime,
				self = AreUnitsEqual("player", unitTag),
			}

			BuffTheGroup.panels[i].name:SetText(GetUnitDisplayName(unitTag))
			BuffTheGroup.panels[i].role:SetTexture(BuffTheGroup.roleIcons[GetGroupMemberSelectedRole(unitTag)])

			BuffTheGroup.UpdateStatus(unitTag)
			BuffTheGroup.UpdateRange(i, IsUnitInGroupSupportRange(unitTag))

			if (i == 1) then
				BuffTheGroup.panels[i].panel:SetAnchor(TOPLEFT, BuffTheGroupFrame, TOPLEFT, 0, 0)
			elseif (i <= BuffTheGroup.savedVars.maxRows) then
				BuffTheGroup.panels[i].panel:SetAnchor(TOPLEFT, BuffTheGroup.panels[i - 1].panel, BOTTOMLEFT, 0, 0)
			else
				BuffTheGroup.panels[i].panel:SetAnchor(TOPLEFT, BuffTheGroup.panels[i - BuffTheGroup.savedVars.maxRows].panel, TOPRIGHT, 0, 0)
			end

			BuffTheGroup.panels[i].panel:SetHidden(false)
		else
			BuffTheGroup.panels[i].panel:SetAnchor(TOPLEFT, BuffTheGroupFrame, TOPLEFT, 0, 0)
			BuffTheGroup.panels[i].panel:SetHidden(true)
		end
	end
end

function BuffTheGroup.UpdateStatus( unitTag )
	local unit = BuffTheGroup.units[unitTag]
	local bg = BuffTheGroup.panels[unit.panelId].bg
	local stat = BuffTheGroup.panels[unit.panelId].stat
	local now = GetFrameTimeMilliseconds() / 1000

	if(unit.endTime) then
		local buffRemaining = unit.endTime - now
		local buffPctLeft = 1 - buffRemaining / unit.buffDuration
		local nowRed = red + (destRed - red) * buffPctLeft
		local nowGreen = green + (destGreen - green) * buffPctLeft
		local nowBlue = blue + (destBlue - blue) * buffPctLeft

		if (buffRemaining > 0) then
			stat:SetText(tostring(buffRemaining))
			if (unit.self) then
				bg:SetCenterColor(nowRed / 255, nowGreen / 255, nowBlue / 255, 1-(1-0.5)*buffPctLeft)
			else
				bg:SetCenterColor(nowRed / 255, nowGreen / 255, nowBlue / 255, 0.8 - (0.8-0.4)*buffPctLeft)
			end
		else
			bg:SetCenterColor(0, 0, 0, 0.5)
			if(unit.buff < 1) then
				unit.endTime = nil
			end
		end
	else
		bg:SetCenterColor(0, 0, 0, 0.5)
		stat:SetText("0")
	end
end

function BuffTheGroup.UpdateStatusDiscrete( unitTag )
	local unit = BuffTheGroup.units[unitTag]
	local bg = BuffTheGroup.panels[unit.panelId].bg
	local stat = BuffTheGroup.panels[unit.panelId].stat
	local now = GetFrameTimeMilliseconds() / 1000
	if (unit.buff < 1) then
		bg:SetCenterColor(0, 0, 0, 0.5)
	elseif (unit.self) then
		bg:SetCenterColor(0.46, 0.87, 0.47, 1)
	else
		bg:SetCenterColor(0.46, 0.87, 0.47, 0.8)
	end
	if(unit.endTime) then
		local buffRemaining = unit.endTime - now
		if (buffRemaining > 0) then
			stat:SetText(tostring(buffRemaining))
		else
			unit.endTime = nil
		end
	else
		stat:SetText("0")
	end
end

function BuffTheGroup.UpdateRange( panelId, status )
	if (status) then
		BuffTheGroup.panels[panelId].panel:SetAlpha(1)
	else
		BuffTheGroup.panels[panelId].panel:SetAlpha(0.5)
	end
end

EVENT_MANAGER:RegisterForEvent(BuffTheGroup.name, EVENT_ADD_ON_LOADED, BuffTheGroup.OnAddOnLoaded)

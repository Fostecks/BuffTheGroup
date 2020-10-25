function btg.OnAddOnLoaded( eventCode, addonName )
	if (addonName ~= btg.name) then return end

	EVENT_MANAGER:UnregisterForEvent(btg.name, EVENT_ADD_ON_LOADED)

	btg.savedVars = ZO_SavedVars:NewCharacterIdSettings("BuffTheGroupSavedVariables", 1, nil, btg.defaults, nil, GetWorldName())
	btg.InitializeControls()
	SLASH_COMMANDS["/btg"] = btg.ToggleState
	SLASH_COMMANDS["/btgrefresh"] = btg.CheckActivation

	EVENT_MANAGER:RegisterForEvent(btg.name, EVENT_PLAYER_ACTIVATED, btg.CheckActivation)
	EVENT_MANAGER:RegisterForEvent(btg.name, EVENT_RAID_TRIAL_STARTED, btg.CheckActivation)
	btg.buildMenu()
end

function btg.ToggleState( )
	btg.savedVars.enabled = not btg.savedVars.enabled
	CHAT_SYSTEM:AddMessage("[BTG] " .. (btg.savedVars.enabled and "enabled" or "disabled"))
	zo_callLater(btg.CheckActivation, 500)
end

function btg.CheckActivation( eventCode )
	-- Check wiki.esoui.com/AvA_Zone_Detection if we want to enable this for PvP
	local zoneId = GetZoneId(GetUnitZoneIndex("player"))

	if (btgData.zones[zoneId] and btg.savedVars.enabled or btg.savedVars.debug) then
	-- if(true) then
		btg.Reset()

		-- Workaround for when the game reports that the player is not in a group shortly after zoning
		if (btg.groupSize == 0) then
			zo_callLater(function() if (btg.groupSize > 0) then btg.Reset() end end, 5000)
		end

		if (not btg.showUI) then
			btg.showUI = true

			EVENT_MANAGER:RegisterForEvent(btg.name, EVENT_GROUP_MEMBER_JOINED, btg.GroupUpdate)
			EVENT_MANAGER:RegisterForEvent(btg.name, EVENT_GROUP_MEMBER_LEFT, btg.GroupUpdate)
			EVENT_MANAGER:RegisterForEvent(btg.name, EVENT_GROUP_MEMBER_ROLE_CHANGED, btg.GroupMemberRoleChanged)
			EVENT_MANAGER:RegisterForEvent(btg.name, EVENT_GROUP_SUPPORT_RANGE_UPDATE, btg.GroupSupportRangeUpdate)
			EVENT_MANAGER:RegisterForEvent(btg.name, EVENT_EFFECT_CHANGED, btg.EffectChanged)
			EVENT_MANAGER:RegisterForUpdate(btg.name.."Cycle", 100, btg.refreshUI)
			EVENT_MANAGER:AddFilterForEvent(btg.name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")

			SCENE_MANAGER:GetScene("hud"):AddFragment(btg.fragment)
			SCENE_MANAGER:GetScene("hudui"):AddFragment(btg.fragment)
		end
	else
		if (btg.showUI) then
			btg.showUI = false

			EVENT_MANAGER:UnregisterForEvent(btg.name, EVENT_GROUP_MEMBER_JOINED)
			EVENT_MANAGER:UnregisterForEvent(btg.name, EVENT_GROUP_MEMBER_LEFT)
			EVENT_MANAGER:UnregisterForEvent(btg.name, EVENT_GROUP_MEMBER_ROLE_CHANGED)
			EVENT_MANAGER:UnregisterForEvent(btg.name, EVENT_GROUP_SUPPORT_RANGE_UPDATE)
			EVENT_MANAGER:UnregisterForEvent(btg.name, EVENT_EFFECT_CHANGED)

			EVENT_MANAGER:UnregisterForEvent(btg.name, EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED)
			EVENT_MANAGER:UnregisterForEvent(btg.name, EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED)
			EVENT_MANAGER:UnregisterForEvent(btg.name, EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED)

			SCENE_MANAGER:GetScene("hud"):RemoveFragment(btg.fragment)
			SCENE_MANAGER:GetScene("hudui"):RemoveFragment(btg.fragment)
		end
	end
end

function btg.GroupUpdate( eventCode )
	zo_callLater(btg.Reset, 500)
end

function btg.GroupMemberRoleChanged( eventCode, unitTag, newRole )
	if (btg.units[unitTag]) then
		btg.panels[btg.units[unitTag].panelId].role:SetTexture(btgData.roleIcons[newRole])
	end
end

function btg.GroupSupportRangeUpdate( eventCode, unitTag, status )
	if (btg.units[unitTag]) then
		btg.UpdateRange(btg.units[unitTag].panelId, status)
	end
end

function btg.refreshUI()
	for unitTag, unit in pairs(btg.units) do
		if(btg.savedVars.gradientMode) then
			btg.UpdateStatus(unitTag)
		else
			btg.UpdateStatusDiscrete(unitTag)
		end
	end
end

function btg.EffectChanged( eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType )
	local trackedBuff = btgData.buffs[btg.savedVars.trackedBuff]
	-- format effectName so it's common across all languages
	local formattedEffectName = zo_strformat(SI_ABILITY_NAME, effectName)

	if (trackedBuff == formattedEffectName and btg.units[unitTag]) then
		if (changeType == EFFECT_RESULT_FADED) then
			if (btg.units[unitTag].buff) then
				btg.units[unitTag].buff = 0
			end
		else
			if (btg.units[unitTag].buff == 0) then
				btg.units[unitTag].buff = 1
			end
			btg.units[unitTag].endTime = endTime
			btg.units[unitTag].buffDuration = endTime - beginTime
		end
	end
end

function btg.OnMoveStop( )
	btg.savedVars.left = btgFrame:GetLeft()
	btg.savedVars.top = btgFrame:GetTop()
end

function btg.InitializeControls( )
	local wm = GetWindowManager()

	for i = 1, GROUP_SIZE_MAX do
		local panel = wm:CreateControlFromVirtual("btgPanel" .. i, btgFrame, "btgPanel")
	
		btg.panels[i] = {
			panel = panel,
			bg = panel:GetNamedChild("Backdrop"),
			name = panel:GetNamedChild("Name"),
			role = panel:GetNamedChild("Role"),
			icon = panel:GetNamedChild("Icon"),
			stat = panel:GetNamedChild("Stat"),
		}

		btg.panels[i].bg:SetEdgeColor(0, 0, 0, 0)
		btg.panels[i].bg:SetCenterColor(0, 0, 0, 0.5)
		btg.panels[i].stat:SetColor(1, 0, 1, 1)

	end

	btgFrame:ClearAnchors()
	btgFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, btg.savedVars.left, btg.savedVars.top)

	btg.fragment = ZO_HUDFadeSceneFragment:New(btgFrame)
end

function btg.Reset( )

	if (btg.savedVars.debug) then
		CHAT_SYSTEM:AddMessage("[BTG] Resetting")
	end

	btg.groupSize = GetGroupSize()
	btg.units = { }

	local trackedBuffIcon = btgData.buffIcons[btg.savedVars.trackedBuff]
	btgFrameIcon:SetTexture(trackedBuffIcon)

	for i = 1, GROUP_SIZE_MAX do
		local soloPanel = i == 1 and btg.groupSize == 0

		if (i <= btg.groupSize or soloPanel) then
			local unitTag = (soloPanel) and "player" or GetGroupUnitTagByIndex(i)

			btg.units[unitTag] = {
				panelId = i,
				buff = 0,
				endTime,
				self = AreUnitsEqual("player", unitTag),
			}

			btg.panels[i].name:SetText(GetUnitDisplayName(unitTag))
			btg.panels[i].role:SetTexture(btgData.roleIcons[GetGroupMemberSelectedRole(unitTag)])

			btg.UpdateStatus(unitTag)
			btg.UpdateRange(i, IsUnitInGroupSupportRange(unitTag))

			if (i == 1) then
				btg.panels[i].panel:SetAnchor(TOPLEFT, btgFrame, TOPLEFT, 0, 0)
			elseif (i <= btg.savedVars.maxRows) then
				btg.panels[i].panel:SetAnchor(TOPLEFT, btg.panels[i - 1].panel, BOTTOMLEFT, 0, 0)
			else
				btg.panels[i].panel:SetAnchor(TOPLEFT, btg.panels[i - btg.savedVars.maxRows].panel, TOPRIGHT, 0, 0)
			end

			btg.panels[i].panel:SetHidden(false)
		else
			btg.panels[i].panel:SetAnchor(TOPLEFT, btgFrame, TOPLEFT, 0, 0)
			btg.panels[i].panel:SetHidden(true)
		end
	end
end

function btg.UpdateStatus( unitTag )
	local unit = btg.units[unitTag]
	local bg = btg.panels[unit.panelId].bg
	local stat = btg.panels[unit.panelId].stat
	local now = GetFrameTimeMilliseconds() / 1000

	if(unit.endTime) then
		local buffRemaining = unit.endTime - now

		local progress = btg.Clamp(1 - buffRemaining / unit.buffDuration, 0, 1)
		local r, g, b = btg.Interpolate(btg.startR, btg.endR, progress) / 255,
		                btg.Interpolate(btg.startG, btg.endG, progress) / 255,
		                btg.Interpolate(btg.startB, btg.endB, progress) / 255

		if (buffRemaining > 0) then
			stat:SetText(string.format("%.1f", buffRemaining))
			if (unit.self) then
				bg:SetCenterColor(r, g, b, 1-0.5*progress)
			else
				bg:SetCenterColor(r, g, b, 0.8-0.4*progress)
			end
		else
			bg:SetCenterColor(0, 0, 0, 0.5)
			stat:SetText("0")
			if(unit.buff < 1) then
				unit.endTime = nil
			end
		end
	end
end

function btg.UpdateStatusDiscrete( unitTag )
	local unit = btg.units[unitTag]
	local bg = btg.panels[unit.panelId].bg
	local stat = btg.panels[unit.panelId].stat
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

function btg.UpdateRange( panelId, status )
	if (status) then
		btg.panels[panelId].panel:SetAlpha(1)
	else
		btg.panels[panelId].panel:SetAlpha(0.5)
	end
end

EVENT_MANAGER:RegisterForEvent(btg.name, EVENT_ADD_ON_LOADED, btg.OnAddOnLoaded)

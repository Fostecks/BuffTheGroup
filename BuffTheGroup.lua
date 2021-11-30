function btg.OnAddOnLoaded( eventCode, addonName )
	if (addonName ~= btg.name) then return end

	EVENT_MANAGER:UnregisterForEvent(btg.name, EVENT_ADD_ON_LOADED)

	btg.savedVars = ZO_SavedVars:NewCharacterIdSettings("BuffTheGroupSavedVariables", btg.variableVersion, nil, btg.defaults, nil, GetWorldName())
	btg.InitializeControls()
	SLASH_COMMANDS["/btg"] = btg.ToggleState
	SLASH_COMMANDS["/btgrefresh"] = btg.CheckActivation

	EVENT_MANAGER:RegisterForEvent(btg.name, EVENT_PLAYER_ACTIVATED, btg.CheckActivation)
	EVENT_MANAGER:RegisterForEvent(btg.name, EVENT_RAID_TRIAL_STARTED, btg.CheckActivation)
	btg.buildMenu()
end

function btg.ToggleState( )
	btg.savedVars.enabled = not btg.savedVars.enabled
	CHAT_SYSTEM:AddMessage("[BTG] " .. (btg.savedVars.enabled and "Enabled" or "Disabled"))
	btg.CheckActivation()
end

function btg.CheckActivation( eventCode )
	-- Check wiki.esoui.com/AvA_Zone_Detection if we want to enable this for PvP
	local zoneId = GetZoneId(GetUnitZoneIndex("player"))
	if (((btgData.zones[zoneId] and GetGroupSize() > 1) or btg.debug) and btg.savedVars.enabled) then
		btg.Reset()

		-- Workaround for when the game reports that the player is not in a group shortly after zoning
		if (btg.groupSize == 0) then
			zo_callLater(function() if (GetGroupSize() > 1) then btg.CheckActivation() end end, 5000)
		end

		if (not btg.showUI) then
			btg.showUI = true

			EVENT_MANAGER:RegisterForEvent(btg.name, EVENT_UNIT_CREATED, btg.GroupUpdate)
			EVENT_MANAGER:AddFilterForEvent(btg.name, EVENT_UNIT_CREATED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
			EVENT_MANAGER:RegisterForEvent(btg.name, EVENT_GROUP_MEMBER_JOINED, btg.GroupUpdate)
			EVENT_MANAGER:RegisterForEvent(btg.name, EVENT_GROUP_MEMBER_LEFT, btg.GroupUpdate)
			EVENT_MANAGER:RegisterForEvent(btg.name, EVENT_GROUP_MEMBER_ROLE_CHANGED, btg.GroupMemberRoleChanged)
			EVENT_MANAGER:RegisterForEvent(btg.name, EVENT_GROUP_SUPPORT_RANGE_UPDATE, btg.GroupSupportRangeUpdate)
			EVENT_MANAGER:RegisterForEvent(btg.name, EVENT_EFFECT_CHANGED, btg.EffectChanged)
			EVENT_MANAGER:RegisterForUpdate(btg.name.."Cycle", 100, btg.refreshUI)
			if(not btg.debug) then
				EVENT_MANAGER:AddFilterForEvent(btg.name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
			end
		end
		for index, fragment in pairs(btg.fragments) do
			if(btg.savedVars.trackedBuffs[index]) then
				SCENE_MANAGER:GetScene("hud"):AddFragment(fragment)
				SCENE_MANAGER:GetScene("hudui"):AddFragment(fragment)
			else
				SCENE_MANAGER:GetScene("hud"):RemoveFragment(fragment)
				SCENE_MANAGER:GetScene("hudui"):RemoveFragment(fragment)
			end
		end
	else
		if (btg.showUI) then
			btg.showUI = false

			EVENT_MANAGER:UnregisterForEvent(btg.name, EVENT_UNIT_CREATED)
			EVENT_MANAGER:UnregisterForEvent(btg.name, EVENT_GROUP_MEMBER_JOINED)
			EVENT_MANAGER:UnregisterForEvent(btg.name, EVENT_GROUP_MEMBER_LEFT)
			EVENT_MANAGER:UnregisterForEvent(btg.name, EVENT_GROUP_MEMBER_ROLE_CHANGED)
			EVENT_MANAGER:UnregisterForEvent(btg.name, EVENT_GROUP_SUPPORT_RANGE_UPDATE)
			EVENT_MANAGER:UnregisterForEvent(btg.name, EVENT_EFFECT_CHANGED)

			EVENT_MANAGER:UnregisterForEvent(btg.name, EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED)
			EVENT_MANAGER:UnregisterForEvent(btg.name, EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED)
			EVENT_MANAGER:UnregisterForEvent(btg.name, EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED)
		end
		for _, fragment in pairs(btg.fragments) do
			SCENE_MANAGER:GetScene("hud"):RemoveFragment(fragment)
			SCENE_MANAGER:GetScene("hudui"):RemoveFragment(fragment)
		end
	end
end

function btg.GroupUpdate( eventCode )
	zo_callLater(btg.CheckActivation, 500)
end

function btg.GroupMemberRoleChanged( eventCode, unitTag, newRole )
	local unit = btg.units[unitTag]
	if (unit) then
		for i = 1, #btgData.buffs do
			btg.frames[i].panels[unit.panelId].role:SetTexture(btgData.roleIcons[newRole])
			zo_callLater(btg.CheckActivation, 500)
		end
	end
end

function btg.GroupSupportRangeUpdate( eventCode, unitTag, status )
	if (btg.units[unitTag]) then
		for i = 1, #btgData.buffs do
			btg.UpdateRange(i, btg.units[unitTag].panelId, status)
		end
	end
end

function btg.refreshUI()
	for unitTag, _ in pairs(btg.units) do
		for i = 1, #btgData.buffs do
			btg.UpdateStatus(i, unitTag)
		end
	end
end

function btg.EffectChanged( eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType )
	-- format effectName so it's common across all languages
	local formattedEffectName = zo_strformat(SI_ABILITY_NAME, effectName)
	-- d("[formattedEffectName] " .. formattedEffectName)
	-- d("[buffType] " .. buffType)
	-- d("[changeType] " .. changeType)
	-- d("[beginTime] " .. beginTime)
	-- d("[endTime] " .. endTime)
	-- d("[abilityType] " .. abilityType)
	-- d("[effectType] " .. effectType)



	for index, buff in pairs(btgData.buffs) do
		if (btg.savedVars.trackedBuffs[index]) then
			if (buff == formattedEffectName and btg.units[unitTag]) then
				if (changeType == EFFECT_RESULT_FADED) then
					btg.units[unitTag].buffs[index].hasBuff = false
					btg.units[unitTag].buffs[index].endTime = 0
				elseif ((changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED) and (beginTime == 0 or endTime == 0)) then -- gained permanent effect	
					btg.units[unitTag].buffs[index].hasBuff = true
					btg.units[unitTag].buffs[index].endTime = -1
					btg.units[unitTag].buffs[index].buffDuration = -1
				else
					btg.units[unitTag].buffs[index].hasBuff = true
					btg.units[unitTag].buffs[index].endTime = endTime
					btg.units[unitTag].buffs[index].buffDuration = endTime - beginTime
				end
			end
		end
	end
end

function btg.OnMoveStop(i, frame)
	btg.savedVars.framePositions[i].left = frame:GetLeft()
	btg.savedVars.framePositions[i].top = frame:GetTop()
end

function btg.InitializeControls( )
	local wm = GetWindowManager()

	for i = 1, #btgData.buffs do
		local frame = wm:CreateControlFromVirtual("btgFrame" .. i, btgUI, "btgFrame")

		frame:SetHandler("OnMoveStop", function() btg.OnMoveStop(i, frame) end)

		btg.frames[i] = {
			frame = frame,
			panels = {},
		}

		for j = 1, GROUP_SIZE_MAX do
			local panel = wm:CreateControlFromVirtual("btgPanel" .. i .. "_" .. j, frame, "btgPanel")

			btg.frames[i].panels[j] = {
				panel = panel,
				bg = panel:GetNamedChild("Backdrop"),
				name = panel:GetNamedChild("Name"),
				role = panel:GetNamedChild("Role"),
				icon = panel:GetNamedChild("Icon"),
				stat = panel:GetNamedChild("Stat"),
			}

			btg.frames[i].panels[j].bg:SetEdgeColor(0, 0, 0, 0)
			btg.frames[i].panels[j].bg:SetCenterColor(0, 0, 0, 0.5)
			btg.frames[i].panels[j].stat:SetColor(1, 1, 1, 1)
			btg.frames[i].panels[j].stat:SetText("0")
		end

		frame:ClearAnchors()
		frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, btg.savedVars.framePositions[i].left, btg.savedVars.framePositions[i].top)

		btg.fragments[i] = ZO_HUDFadeSceneFragment:New(frame)
	end
end

function btg.Reset( )

	for i = 1, #btgData.buffs do
		for j = 1, GROUP_SIZE_MAX do
			btg.frames[i].panels[j].panel:ClearAnchors()
			btg.frames[i].panels[j].panel:SetHidden(true)
		end
	end

	btg.groupSize = GetGroupSize()
	btg.units = {}

	for i = 1, #btgData.buffs do
		_G["btgFrame"..i.."Icon"]:SetTexture(btgData.buffIcons[i])
	end
	local panelIndex = 1
	for j = 1, GROUP_SIZE_MAX do
		if (j <= btg.groupSize or j == 1 and btg.groupSize == 0) then
			local unitTag = (j == 1 and btg.groupSize == 0) and "player" or GetGroupUnitTagByIndex(j)
			if (not btg.savedVars.showOnlyDPS or GetGroupMemberSelectedRole(unitTag) == LFG_ROLE_DPS) then
				btg.units[unitTag] = {
					panelId = panelIndex,
					self = AreUnitsEqual("player", unitTag),
					buffs = {},
				}
				panelIndex = panelIndex + 1
				for i = 1, #btgData.buffs do
					btg.units[unitTag].buffs[i] = {
						hasBuff = false,
						endTime = 0,
						buffDuration = 0,
					}
				end
			end
		end
	end

	for i = 1, #btgData.buffs do
		panelIndex = 1
		for j = 1, GROUP_SIZE_MAX do
			local soloPanel = j == 1 and btg.groupSize == 0
			local unitTag = (soloPanel) and "player" or GetGroupUnitTagByIndex(j)
			if (not btg.savedVars.showOnlyDPS or GetGroupMemberSelectedRole(unitTag) == LFG_ROLE_DPS) then
				if (j <= btg.groupSize or soloPanel) then

					btg.frames[i].panels[panelIndex].name:SetText(GetUnitDisplayName(unitTag))
					btg.frames[i].panels[panelIndex].role:SetTexture(btgData.roleIcons[GetGroupMemberSelectedRole(unitTag)])

					btg.UpdateStatus(i, unitTag)
					btg.UpdateRange(i, panelIndex, IsUnitInGroupSupportRange(unitTag))

					if (panelIndex == 1) then
						btg.frames[i].panels[panelIndex].panel:SetAnchor(TOPLEFT, btgFrame, TOPLEFT, 0, 0)
					elseif (panelIndex <= btg.savedVars.maxRows) then
						btg.frames[i].panels[panelIndex].panel:SetAnchor(TOPLEFT, btg.frames[i].panels[panelIndex - 1].panel, BOTTOMLEFT, 0, 0)
					else
						btg.frames[i].panels[panelIndex].panel:SetAnchor(TOPLEFT, btg.frames[i].panels[panelIndex - btg.savedVars.maxRows].panel, TOPRIGHT, 0, 0)
					end

					btg.frames[i].panels[panelIndex].panel:SetHidden(false)
				else
					btg.frames[i].panels[panelIndex].panel:SetAnchor(TOPLEFT, btgFrame, TOPLEFT, 0, 0)
					btg.frames[i].panels[panelIndex].panel:SetHidden(true)
				end
				panelIndex = panelIndex + 1
			end
		end
	end
end

function btg.UpdateStatus( buffIndex, unitTag )
	local unit = btg.units[unitTag]
	local buffData = unit.buffs[buffIndex]
	local panel = btg.frames[buffIndex].panels[unit.panelId]
	local now = GetFrameTimeMilliseconds() / 1000

	if(buffData.endTime) then
		local buffRemaining = buffData.endTime - now

		local progress = btg.savedVars.gradientMode and btgUtil.Clamp(1 - buffRemaining / buffData.buffDuration, 0, 1) or 0
		local r, g, b = (btg.savedVars.gradientMode and btgUtil.Interpolate(btg.startR, btg.endR, progress) or btg.startR) / 255,
		                (btg.savedVars.gradientMode and btgUtil.Interpolate(btg.startG, btg.endG, progress) or btg.startG) / 255,
		                (btg.savedVars.gradientMode and btgUtil.Interpolate(btg.startB, btg.endB, progress) or btg.startB) / 255

		

		if (buffRemaining > 0) then
			panel.stat:SetText(string.format("%.1f", buffRemaining))
			if (unit.self) then
				panel.bg:SetCenterColor(r, g, b, 1-0.5*progress)
			else
				panel.bg:SetCenterColor(r, g, b, 0.8-0.4*progress)
			end
		elseif (buffData.endTime == -1) then 
			panel.stat:SetText("")
			if (unit.self) then
				panel.bg:SetCenterColor(r, g, b, 1)
			else
				panel.bg:SetCenterColor(r, g, b, 0.8)
			end
		else
			panel.bg:SetCenterColor(0, 0, 0, 0.5)
			panel.stat:SetText("0")
			if(not buffData.hasBuff) then
				buffData.endTime = nil
			end
		end
	end
end

function btg.UpdateRange( buffIndex, panelId, status )
	if (status) then
		btg.frames[buffIndex].panels[panelId].panel:SetAlpha(1)
	else
		btg.frames[buffIndex].panels[panelId].panel:SetAlpha(0.5)
	end
end

EVENT_MANAGER:RegisterForEvent(btg.name, EVENT_ADD_ON_LOADED, btg.OnAddOnLoaded)

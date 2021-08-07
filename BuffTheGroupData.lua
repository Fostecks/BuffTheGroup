btgData = {
	zones = {
		-- DUNGEONS
		[ 11] = 0, -- Vaults of Madness	
		[ 22] = 0, -- Volenfell
		[ 31] = 0, -- Selene's Web	
		[ 38] = 0, -- Blackheart Haven	
		[ 63] = 0, -- Darkshade Caverns I
		[ 64] = 0, -- Blessed Crucible
		[ 126] = 0, -- Elden Hollow I
		[ 130] = 0, -- Crypt of Hearts I
		[ 131] = 0, -- Tempest Island
		[ 144] = 0, -- Spindleclutch I
		[ 146] = 0, -- Wayrest Sewers I
		[ 148] = 0, -- Arx Corinium
		[ 176] = 0, -- City of Ash I
		[ 283] = 0, -- Fungal Grotto I	
		[ 380] = 0, -- The Banished Cells I	
		[ 449] = 0, -- Direfrost Keep
		[ 678] = 0, -- Imperial City Prison
		[ 681] = 0, -- City of Ash II
		[ 688] = 0, -- White-Gold Tower	
		[ 843] = 0, -- Ruins of Mazzatun	
		[ 848] = 0, -- Cradle of Shadows
		[ 930] = 0, -- Darkshade Caverns II	
		[ 931] = 0, -- Elden Hollow II	
		[ 932] = 0, -- Crypt of Hearts II	
		[ 933] = 0, -- Wayrest Sewers II	
		[ 934] = 0, -- Fungal Grotto II	
		[ 935] = 0, -- The Banished Cells II	
		[ 936] = 0, -- Spindleclutch II	
		[ 973] = 0, -- Bloodroot Forge	
		[ 974] = 0, -- Falkreath Hold	
		[1009] = 0, -- Fang Lair
		[1010] = 0, -- Scalecaller Peak
		[1052] = 0, -- Moon Hunter Keep	
		[1055] = 0, -- March of Sacrifices	
		[1080] = 0, -- Frostvault	
		[1081] = 0, -- Depths of Malatar	
		[1123] = 0, -- Lair of Maarselok
		[1122] = 0, -- Moongrave Fane
		[1152] = 0, -- Icereach
		[1153] = 0, -- Unhallowed Grave
		[1197] = 0, -- Stone Garden
		[1201] = 0, -- Castle Thorn
		[1228] = 0, -- Black Drake Villa
		[1229] = 0, -- The Cauldron

		-- ARENAS
		[ 635] = 0, -- Dragonstar Arena
		[1082] = 0, -- Blackrose Prison

		-- TRIALS
		[ 636] = 0, -- Hel Ra Citadel
		[ 638] = 0, -- Aetherian Archive
		[ 639] = 0, -- Sanctum Ophidia
		[ 725] = 0, -- Maw of Lorkhaj
		[ 975] = 0, -- Halls of Fabrication
		[1000] = 0, -- Asylum Sanctorium
		[1051] = 0, -- Cloudrest
		[1121] = 0, -- Sunspire
		[1196] = 0, -- Kyne's Aegis
		[1263] = 0, -- Rockgrove
	},
	
	--- better to use effect names since one effect can come from many IDs (e.g. Major Slayer: Lokk, MA, WM)
	buffs = {
		[1]  = zo_strformat(SI_ABILITY_NAME, GetAbilityName(61771)),  -- Powerful Assault
		[2]  = zo_strformat(SI_ABILITY_NAME, GetAbilityName(121871)), -- Major Slayer
		[3]  = zo_strformat(SI_ABILITY_NAME, GetAbilityName(120015)), -- Major Courage
		[4]  = zo_strformat(SI_ABILITY_NAME, GetAbilityName(120013)), -- Major Force
		[5]  = zo_strformat(SI_ABILITY_NAME, GetAbilityName(62195)),  -- Major Berserk
		[6]  = zo_strformat(SI_ABILITY_NAME, GetAbilityName(62636)),  -- Minor Berserk
		[7]  = zo_strformat(SI_ABILITY_NAME, GetAbilityName(121878)), -- Minor Courage
		[8]  = zo_strformat(SI_ABILITY_NAME, GetAbilityName(61687)), -- Major Sorcery
		[9]  = zo_strformat(SI_ABILITY_NAME, GetAbilityName(120017)), -- Minor Sorcery
		[10]  = zo_strformat(SI_ABILITY_NAME, GetAbilityName(61665)), -- Major Brutality
		[11]  = zo_strformat(SI_ABILITY_NAME, GetAbilityName(120028)), -- Minor Prophecy
		[12]  = zo_strformat(SI_ABILITY_NAME, GetAbilityName(61694)), -- Major Resolve
		[13]  = zo_strformat(SI_ABILITY_NAME, GetAbilityName(61693)), -- Minor Resolve
		[14]  = zo_strformat(SI_ABILITY_NAME, GetAbilityName(61706)), -- Minor Intellect
		[15] = zo_strformat(SI_ABILITY_NAME, GetAbilityName(118366)), -- Empower
		[16] = zo_strformat(SI_ABILITY_NAME, GetAbilityName(61709)), -- Major Heroism
		[17] = zo_strformat(SI_ABILITY_NAME, GetAbilityName(40079)), -- Radiating Regeneration
		[18] = zo_strformat(SI_ABILITY_NAME, GetAbilityName(61736)), -- Major Expedition


	},

	buffIcons = {
		[1]  = "/esoui/art/icons/ability_healer_019.dds",          -- Powerful Assault
		[2]  = "/esoui/art/icons/procs_006.dds",                   -- Major Slayer
		[3]  = "/esoui/art/icons/ability_mage_045.dds",            -- Major Courage
		[4]  = "/esoui/art/icons/ability_buff_major_force.dds",    -- Major Force
		[5]  = "/esoui/art/icons/ability_buff_major_berserk.dds",  -- Major Berserk
		[6]  = '/esoui/art/icons/ability_buff_minor_berserk.dds',  -- Minor Berserk
		[7]  = '/esoui/art/icons/ability_mage_045.dds',            -- Minor Courage
		[8]  = '/esoui/art/icons/ability_buff_major_sorcery.dds',  -- Major Sorcery
		[9]  = '/esoui/art/icons/ability_buff_minor_sorcery.dds',  -- Minor Sorcery
		[10]  = '/esoui/art/icons/ability_buff_major_brutality.dds',  -- Major Brutality
		[11]  = '/esoui/art/icons/ability_buff_minor_prophecy.dds', -- Minor Prophecy
		[12]  = '/esoui/art/icons/ability_buff_major_resolve.dds', -- Major Resolve
		[13]  = '/esoui/art/icons/ability_buff_minor_resolve.dds', -- Minor Resolve
		[14]  = '/esoui/art/icons/ability_buff_minor_intellect.dds', -- Minor Intellect
		[15] = '/esoui/art/icons/ability_buff_major_empower.dds',  -- Empower
		[16] = '/esoui/art/icons/ability_buff_major_heroism.dds',  -- Major Heroism
		[17] = '/esoui/art/icons/ability_restorationstaff_002a.dds', -- Radiating Regeneration
		[18] = '/esoui/art/icons/ability_buff_major_expedition.dds', -- Major Expedition

	},

	roleIcons = {
		[LFG_ROLE_DPS] = "/esoui/art/lfg/lfg_icon_dps.dds",
		[LFG_ROLE_TANK] = "/esoui/art/lfg/lfg_icon_tank.dds",
		[LFG_ROLE_HEAL] = "/esoui/art/lfg/lfg_icon_healer.dds",
		[LFG_ROLE_INVALID] = "/esoui/art/crafting/gamepad/crafting_alchemy_trait_unknown.dds",
	},
}

btg = {
	name = "BuffTheGroup",
	version = "2.3.1",
	variableVersion = 3,

	defaults = {
		enabled = true,
		gradientMode = true,
		trackedBuffs = {},
		framePositions = {},
	},

	debug = false,

	showUI = false,
	groupSize = 0,
	units = {},
	panels = {},
	frames = {},
	fragments = {},

	startR = 117, startG = 222, startB = 120,
	endR = 222, endG = 117, endB = 117,
	maxRows = 6,
}

for i = 1, #btgData.buffs do
	btg.defaults.trackedBuffs[i] = i == 1

	btg.defaults.framePositions[i] = {
		left = 1300,
		top = 150 + (i-1)*85,
	}
end

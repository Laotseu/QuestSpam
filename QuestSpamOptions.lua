local AddonName, QS = ...
--QS = QS or {}

-- Localized Lua globals
local _G = getfenv(0)

local geterrorhandler = _G.geterrorhandler
local time = _G.time

local LibStub = _G.LibStub

local L = QS.L

-- utilities
local function err(msg,...)
	geterrorhandler()(msg:format(...) .. " - " .. time())
end

local function GetOptions()
	local pref = QS.pref

	local options = {
		name = AddonName,
		type = "group",
		order = 1,
		args = {
			General = {
				type 		 = 'header',
				name		 = "General Settings",
				order     = 0.9,
			},
			QuestSpamOn = {
				name      = L.QUESTSPAM_ON_LABEL,
				desc      = L.QUESTSPAM_ON_TOOLTIP,
				type      = 'toggle',
				get       = function() return pref.on end,
				set       = function(info, v) pref.on = v end,
				order     = 1,
			},
			OffWhileInRaid = {
				name      = "Turn off while in Raid",
				desc      = 'When this is set, Quest Spam will be muted when you are in a Raid.',
				type      = 'toggle',
				get       = function() return pref.off_while_in_raid end,
				set       = function(info, v) pref.off_while_in_raid = v end,
				order     = 1.1,
			},
			OffWhileInParty = {
				name      = "Turn off while in Party",
				desc      = 'When this is set, Quest Spam will be muted when you are in a group.',
				type      = 'toggle',
				get       = function() return pref.off_while_in_party end,
				set       = function(info, v) pref.off_while_in_party = v end,
				order     = 1.2,
			},
			OffWhileInInstance = {
				name      = "Turn off while in Intance",
				desc      = 'When this is set, Quest Spam will be muted if you are in an instance group.',
				type      = 'toggle',
				get       = function() return pref.off_while_in_instance end,
				set       = function(info, v) pref.off_while_in_instance = v end,
				order     = 1.3,
			},
			GruntSound = {
				name      = "Turn on Sound",
				desc      = 'When turned on, QuestSpam will play the "Work Done" sound every time a quest is completed.',
				type      = 'toggle',
				get       = function() return pref.grunt_sound end,
				set       = function(info, v) pref.grunt_sound = v end,
				order     = 1.4,
			},
			MsgPrefix = {
				name      = "Spam Prefix",
				desc      = 'String of characters that will be appended to the start of every quest spam message.',
				type      = 'input',
				get       = function() return pref.msg_prefix end,
				set       = function(info, v) pref.msg_prefix = v end,
				order     = 1.5,
			},
			LevelMsg = {
				name      = "Level Message",
				desc      = 'String of characters that will be appended to the start of every quest spam message.',
				type      = 'input',
				get       = function() return pref.level_msg end,
				set       = function(info, v) pref.level_msg = v end,
				order     = 1.6,
			},
			Channels = {
				type 		 = 'header',
				name		 = "Where to Spam",
				order     = 1.7,
			},
			QuestSpamLocal = {
				name      = L.QUESTSPAM_LOCAL_LABEL,
				desc      = L.QUESTSPAM_LOCAL_TOOLTIP,
				type      = 'toggle',
				get       = function() return pref['local'] end,
				set       = function(info, v) pref['local'] = v end,
				order     = 2,
			},
			QuestSpamRaid = {
				name      = L.QUESTSPAM_RAID_LABEL,
				desc      = L.QUESTSPAM_RAID_TOOLTIP,
				type      = 'toggle',
				get       = function() return pref.raid end,
				set       = function(info, v) pref.raid = v end,
				order     = 3,
			},
			QuestSpamParty = {
				name      = L.QUESTSPAM_PARTY_LABEL,
				desc      = L.QUESTSPAM_PARTY_TOOLTIP,
				type      = 'toggle',
				get       = function() return pref.party end,
				set       = function(info, v) pref.party = v end,
				order     = 4,
			},
			QuestSpamGuild = {
				name      = L.QUESTSPAM_GUILD_LABEL,
				desc      = L.QUESTSPAM_GUILD_TOOLTIP,
				type      = 'toggle',
				get       = function() return pref.guild end,
				set       = function(info, v) pref.guild = v end,
				order     = 5,
			},
			QuestSpamChannel = {
				name      = L.QUESTSPAM_CHANNEL_LABEL,
				desc      = L.QUESTSPAM_CHANNEL_TOOLTIP,
				type      = 'toggle',
				get       = function() return pref.channel end,
				set       = function(info, v) pref.channel = v end,
				order     = 6,
			},
			QuestSpamChannelId = {
				name      = L.QUESTSPAM_CHANNELID_LABEL,
				desc      = L.QUESTSPAM_CHANNELID_TOOLTIP,
				type      = 'range',
				min		 = 6,
				max		 = 20,
				step		 = 1,
				get       = function() return pref.channelid end,
				set       = function(info, v) pref.channelid = v end,
				order     = 7,
			},
			What = {
				type 		 = 'header',
				name		 = "What to Spam",
				order     = 7.1,
			},
			QuestSpamAchievements = {
				name      = L.QUESTSPAM_ACHIEVEMENTS_LABEL,
				desc      = L.QUESTSPAM_ACHIEVEMENTS_TOOLTIP,
				type      = 'toggle',
				get       = function() return pref.achievement end,
				set       = function(info, v) pref.achievement = v end,
				order     = 8,
			},
			QuestSpamDetails = {
				name      = L.QUESTSPAM_QUESTDETAILS_LABEL,
				desc      = L.QUESTSPAM_QUESTDETAILS_TOOLTIP,
				type      = 'toggle',
				get       = function() return pref.details end,
				set       = function(info, v) pref.details = v end,
				order     = 9,
			},
			FilterQuests = {
				name      = "Filter Test Your Strength spams",
				desc      = 'When this is set, the Grisly Trophy spams will not be broadcasted.',
				type      = 'toggle',
				get       = function() return pref.filter_quests end,
				set       = function(info, v) pref.filter_quests = v end,
				order     = 9.5,
			},
			QuestSpamDiscovery = {
				name      = L.QUESTSPAM_DISCOVERY_LABEL,
				desc      = L.QUESTSPAM_DISCOVERY_TOOLTIP,
				type      = 'toggle',
				get       = function() return pref.discovery end,
				set       = function(info, v) pref.discovery = v end,
				order     = 10,
			},
			QuestSpamCombatXP = {
				name      = L.QUESTSPAM_COMBATXP_LABEL,
				desc      = L.QUESTSPAM_COMBATXP_TOOLTIP,
				type      = 'toggle',
				get       = function() return pref.killxp end,
				set       = function(info, v) pref.killxp = v end,
				order     = 11,
			},
			QuestSpamLevelUp = {
				name      = L.QUESTSPAM_LEVELUP_LABEL,
				desc      = L.QUESTSPAM_LEVELUP_TOOLTIP,
				type      = 'toggle',
				get       = function() return pref.levelup end,
				set       = function(info, v) pref.levelup = v end,
				order     = 12,
			},
			QuestSpamQuestProgress = {
				name      = L.QUESTSPAM_QUESTPROGRESS_LABEL,
				desc      = L.QUESTSPAM_QUESTPROGRESS_TOOLTIP,
				type      = 'toggle',
				get       = function() return pref.questxp end,
				set       = function(info, v) pref.questxp = v end,
				order     = 13,
			},
			QuestSpamQuestTest = {
				name      = "Test Mode",
				desc      = "Test mode will print all mesages to your default channel. This is not saved between sessions.",
				type      = 'toggle',
				get       = function() return QS.IsTestOn end,
				set       = function(info, v) QS.IsTestOn = v end,
				order     = 15,
			},
		},
	}

	return options

end

-- Configuration initialization
local function InitConfig()

	-- Initialized options panel
	if not LibStub or not LibStub("AceConfig-3.0") or not LibStub("AceConfigDialog-3.0") then return end

	LibStub("AceConfig-3.0"):RegisterOptionsTable(AddonName, GetOptions())
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions(AddonName)
	--err("Options loaded for %s",AddonName)

	-- About section
	if LibStub:GetLibrary("LibAboutPanel", true) then
		LibStub:GetLibrary("LibAboutPanel").new(AddonName, AddonName)
	end
end
QS.InitConfig = InitConfig

local AddonName, QS = ...
QS = QS or {}
--_G.QS = QS

-- ===========================================================================
-- = Quest Spam.lua 
-- ===========================================================================
-- = by Wizwonk
-- =
-- = Credits: The inspiration came from FastQuest Classic
-- =          Thanks goes to:
-- =          My Brother who through contunious updates helped me with
-- =				features and bugs.
-- =          Gold Tracker developer : I derived my commenting scheme from you
-- =
-- ===========================================================================


-- Localized Lua globals
local _G = getfenv(0)

local floor = _G.floor
local geterrorhandler = _G.geterrorhandler
local lower = _G.lower
local pairs = _G.pairs
local time = _G.time
local tostring = _G.tostring
local type = _G.type
local wipe = _G.wipe

local IsInGroup = _G.IsInGroup
local IsInInstance = _G.IsInInstance
local IsInRaid = _G.IsInRaid

-- utilities
local function err(msg,...) _G.geterrorhandler()(msg:format(_G.tostringall(...)) .. " - " .. _G.time()) end


-- Marker to indicate if the questlog has been parsed at least once
local firstTime = true


-- ========= Globals =========================================================
--QuestSpamLog = QuestSpamLog or {};
_G.SLASH_QuestSpam1 = "/questspam";
_G.SLASH_QuestSpam2 = "/qspam";

-- ========= Locals ==========================================================

local QS_DEBUG = false;
--QuestSpamLastMsg = "";
local QSVer = _G.GetAddOnMetadata("QuestSpam", "Version");
local L = QS.L;

-- ========= Flags ===========================================================
--QS.VariablesLoaded  = false;
--QS.OptionsLoaded    = false;
QS.IsTestOn         = false;

-- ========= Frames ==========================================================
local QuestSpam = _G.CreateFrame("Frame", "QuestSpam", nil)
QuestSpam.questComplete =
{
	xpgained = "",
	iscompleted = false,
}

QuestSpam:SetFrameStrata("TOOLTIP")

-- ========= Defaul Preferences ==============================================
local QuestSpamBasePref =
{
	Version    					= QSVer,
	on 							= true,
	party							= true,
	raid 							= false,
	guild 						= false,
	channel 						= false,
	channelid 					= 6,
	['local']					= false,
	achievement 				= true,
	details 						= true,
	discovery 					= true,
	questxp    					= true,
	levelup						= true,
	killxp						= false,    -- TODO: handle rested : Ashenvale Bear dies, you gain 270 experience (+135 exp Rested Bonus)
	debug							= false,
	off_while_in_raid 		= false,
	grunt_sound					= true,
	msg_prefix					= "QS> ",
	level_msg					= L.QUESTSPAM_LEVELUPMESSAGE,
	off_while_in_party		= false,
	off_while_in_instance	= false,
};


-- ========= Functions and Handlers ==========================================

-- ===========================================================================
-- NAME : QS:Trace(msg)
-- DESC : Logs a message to the DEFAULT_CHAT_FRAME for debug purposes
-- PARAMS
-- msg  : string : message to send to the DEFAULT_CHAT_FRAME
-- ===========================================================================
function QS:Trace(msg)
	if (QS_DEBUG) then
		--QuestSpamLog[#QuestSpamLog+1] = msg;
		_G.DEFAULT_CHAT_FRAME:AddMessage("|cffffaa11[QS]:" .. msg);
	end
end

QS:Trace("Ver : " .. QSVer);
-- ===========================================================================
-- NAME : QSError(msg)
-- DESC : Sends any lua error messages to the DEFAULT_CHAT_FRAME
-- PARAMS
-- msg  : string : error message
-- ===========================================================================
--function QSError(msg)
--	DEFAULT_CHAT_FRAME:AddMessage("|cffff0000!QSERR:" .. msg);
--end
--
---- native: this will setup the error event handler
--seterrorhandler(QSError);

-- ===========================================================================
-- NAME : Chat(msg)
-- DESC : Used for sending confirmation to the DEFAULT_CHAT_FRAME
-- ===========================================================================
local function Chat(msg)
	_G.DEFAULT_CHAT_FRAME:AddMessage("|cffffffff" .. msg);
end

-- ===========================================================================
-- NAME : QuestSpam:TogglePrefFlag(flagname)
-- DESC : Used for sending confirmation to the DEFAULT_CHAT_FRAME
-- PARAMS
-- flagname : string : flag that you would like to toggle
-- ===========================================================================
function QuestSpam:TogglePrefFlag(flagname)
	-- Ensure that we have a correct flagname
	if (QS.pref[flagname] ~= nil) and (type(QS.pref[flagname]) == "boolean" ) then
		QS.pref[flagname] = (not QS.pref[flagname]);
	end
end

-- ===========================================================================
-- NAME : QuestSpam:SpamMessage(msg,event)
-- DESC : This does the spamming and sends the messages to the correct location
-- PARAMS
-- msg   : string : The message that that will be spammed
-- event : string : The event is the reason the message was spammed (optional)
-- ===========================================================================
function QuestSpam:SpamMessage(msg,event)
	--QuestSpamLastMsg = msg; -- This is mainly for test purposes
	local SendChat = _G.SendChatMessage;

	msg = QS.pref.msg_prefix .. msg
	--err("msg=%s,event=%s",tostring(msg),tostring(event))

	if (QS.IsTestOn) then
		SendChat = function(chatmsg)
			_G.DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00" .. msg);
		end
	end

	if msg and
		QS.pref.on and
	   not (QS.pref.off_while_in_raid and IsInRaid()) and
	   not (QS.pref.off_while_in_party and IsInGroup() and not IsInRaid()) and
	   not (QS.pref.off_while_in_instance and IsInInstance())
	then
		if (QS.pref['local']) then
			SendChat(msg, "SAY");
		end
		if QS.pref.party and IsInGroup() then
			SendChat(msg, "PARTY");
		end
		if QS.pref.raid and IsInRaid() then
			SendChat(msg, "RAID");
		end
		if (QS.pref.guild) then
			SendChat(msg, "GUILD");
		end
		if (QS.pref.channel) then
			local id, name = _G.GetChannelName(QS.pref.channelid);
			if (id > 0 and name ~= nil) then
			  SendChat(msg, "CHANNEL", nil, id);
			end
			-- TODO: Achievements will have seperate rules for where they are spammed.
			-- It's cool to send your Achievment to your party so you can 572 it to them
			--if (event and event == "ACHIEVEMENT_EARNED" and QS.pref.achievement and not QS.pref.party and _G.GetNumPartyMembers() > 0 ) then
			--  SendChat(msg, "PARTY");
			--end
		end
	end
end

-- ===========================================================================
-- NAME : QuestSpam:ParseMessage(msg)
-- DESC : This is used to parse the UI_INFO_MESSAGE to determine if it's worth sending
-- PARAMS
-- msg   : string : The message that that will be parsed
-- ===========================================================================
function QuestSpam:ParseMessage(msg)
	for index, value in pairs(L.QUESTSPAM_UI_INFO_MATCH) do
		if ( msg:find(value) ) then
			-- nice to have some bools hanging around for later usage
			local questxp = (value == L.QUESTSPAM_UI_INFO_MATCH[5]);
			local discovery = (value == L.QUESTSPAM_UI_INFO_MATCH[6]);
			local killxp = (value == L.QUESTSPAM_UI_INFO_MATCH[7]);

			-- Early return if the option is not enabled
			if (questxp and not QS.pref["questxp"]) then
				break;
			elseif (discovery and not QS.pref["discovery"]) then
				break;
			elseif (killxp and not QS.pref["killxp"]) then
				break;
			else

				if (questxp) then
					QuestSpam.questComplete.xpgained = msg:gsub(L.QUESTSPAM_EXP_GAINED,"%1");
					QuestSpam.questComplete.iscompleted = true;
					break;
				end

				if (killxp) then
					-- Lets change the message so it's shorter
					msg = msg:gsub(L.QUESTSPAM_KILLEXP_MATCH,L.QUESTSPAM_KILLEXP_MESSAGE);
				end

				if index == 2 then
					-- Quest says complete but it's a turn-in really
					msg = msg:gsub("completed.","turned in.")
				end

				-- TODO: maybe I should setup another variable to be safe?
				-- the message sent (msg) is modified at this point;
				QuestSpam:SpamMessage(msg);
			end
			break;
		end
	end
end


-- ===========================================================================
-- NAME   : QuestSpam      : OnEvent(event, arg1, ...)
-- DESC   : Event handling
-- PARAMS
-- event  : string         : The event string (enum)
-- arg1 	 : string         : The message sent by the event
-- ===========================================================================
function QuestSpam:OnEvent(event, arg1, ...)
	-- for debugging
	if (QS_DEBUG and event) then
		local tracemsg = arg1 or "";
		QS:Trace("OnEvent:(" .. event .. ", " .. tracemsg .. ")");
	end

	if event == "QUEST_LOG_UPDATE" then
		QS:ScanQuestLog()

		--self:UnregisterEvent("QUEST_LOG_UPDATE")
		return

	elseif event == "ADDON_LOADED" then
		if arg1 ~= "QuestSpam" then return end

		-- Set up Database
		_G.QuestSpamPref = _G.QuestSpamPref or {};
		QS.pref = _G.QuestSpamPref

		QuestSpam:UnregisterEvent("ADDON_LOADED")
		if _G.IsLoggedIn() then self:OnEvent("PLAYER_LOGIN") else self:RegisterEvent("PLAYER_LOGIN") end
		return

	elseif event == "PLAYER_LOGIN" then
		self:RegisterEvent("PLAYER_LOGOUT")

		self:Initialize();

		-- Option menu
		QS:InitConfig()

		if not firstTime then QS:ScanQuestLog(true) end

		self:UnregisterEvent("PLAYER_LOGIN")
		return

	elseif event == "PLAYER_LOGOUT" then
		-- Purge the database
		for k,v in pairs(QuestSpamBasePref) do
			if QS.pref[k] == v then
				QS.pref[k] = nil
			end
		end


	elseif (arg1 and QS.pref["on"]) then
		if (event == "UI_INFO_MESSAGE") then
			-- Quest Progress:
			local message = ...
			local uQuestText = message:gsub(L.QUESTSPAM_QUESTTEXT, "%1", 1);
			if ( uQuestText ~= message) then
				if (QS.pref["details"]) then
					QuestSpam:SpamMessage(L.QUESTSPAM_QUESTPROGRESS .. message);
				end
			else
				QuestSpam:ParseMessage(message);
			end

		elseif (event == "CHAT_MSG_COMBAT_XP_GAIN") then
			QuestSpam:ParseMessage(arg1);

		elseif (event == "PLAYER_XP_UPDATE" and QuestSpam.questComplete.iscompleted) then
			QuestSpam:ShowExperience();

		elseif (event == "ACHIEVEMENT_EARNED") then
			QuestSpam:ShowAchievement(arg1);

		elseif (event == "PLAYER_LEVEL_UP" and QS.pref["levelup"]) then
			-- arg1 will be the new level #
			QuestSpam:SpamMessage(QS.pref.level_msg:format(arg1));

		elseif (event == "CHAT_MSG_SYSTEM") then
			QuestSpam:ParseMessage(arg1);
		end
	end
end

-- ===========================================================================
-- NAME : QuestSpam:ShowAchievement()
-- DESC : This will spam with the latest or current achievement and link.
-- PARAMS
-- achievementId   : string : The achievementid that you want info about, if not sent, the latest achievement will be used
-- ===========================================================================
function QuestSpam:ShowAchievement(achievementId)
	-- New Achievement! [Murloc Hater] for 10 pts for total of 20 Achievements at 200 pts
	-- TODO: Use string.format instead of concatenation
	if not QS.pref.achievement then return end

	local ach1,ach2,ach3,ach4,ach5;
	local messageFormat = L.QUESTSPAM_ACHIEVEMENT_MESSAGE;

	if (achievementId == nil) then
		ach1,ach2,ach3,ach4,ach5 = _G.GetLatestCompletedAchievements();
		achievementId = ach1;
		messageFormat = L.QUESTSPAM_LATESTACHIEVEMENT .. L.QUESTSPAM_ACHIEVEMENT_MESSAGE;
	end

	local IDNumber, Title, Points, Completed, Month, Day, Year, Description, Flags, Image, RewardText = _G.GetAchievementInfo(achievementId);
	local achievementLink = _G.GetAchievementLink(achievementId) or Title or ("[unknown $s"):format(tostring(achievementId));
	local achTotal, achCompleted = _G.GetNumCompletedAchievements();

	QuestSpam:SpamMessage(messageFormat:format(achievementLink,(Points or 0),tostring(achCompleted),tostring(_G.GetTotalAchievementPoints())));
end



-- ===========================================================================
-- NAME : QuestSpam:ShowExperience()
-- DESC : Called when the PLAYER_XP_UPDATE event occurs and quest completed
-- ===========================================================================
function QuestSpam:ShowExperience()
	-- This allows me to show the percentage of the current level when you turn in a quest
	-- TODO: possible feature is choosing to show percent to next level
	local messagePrefix = "";
	local nextLevel = _G.UnitLevel("player")+1
	if nextLevel > 80 then nextLevel = 80 end
	local totalXP = _G.UnitXPMax("player");
	local currentXP = _G.UnitXP("player");
	local toLevelXP = totalXP - currentXP;
	local currentXPPercent = floor(currentXP / totalXP * 10000) / 100;
	local toLevelXPPercent = floor(toLevelXP / totalXP * 10000) / 100;

	if QuestSpam.questComplete.iscompleted then
		-- Message : Gained 50 XP and is at 40% of level 3
		messagePrefix = L.QUESTSPAM_EXP_MESSAGE_1:format(QuestSpam.questComplete.xpgained);
		QuestSpam.questComplete.iscompleted = false;
	end

	local messageFormat = L.QUESTSPAM_EXP_MESSAGE_2:format(messagePrefix, tostring(currentXPPercent),tostring(_G.UnitLevel("player")));
	QuestSpam:SpamMessage(messageFormat);

end

-- ===========================================================================
-- NAME : QuestSpam:Initialize()
-- DESC : Called after PLAYER_LOGIN
-- ===========================================================================
function QuestSpam:Initialize()
	--QS:Trace("Starting log at position:" .. #QuestSpamLog .. " : " .. UnitName("player"));

	QuestSpam:LoadDefaults();

	-- Welcome Message ; Also good for knowing if QSpam was loaded (!Swatter can knock error message out)
	--_G.DEFAULT_CHAT_FRAME:AddMessage("|cffffaa11Quest Spam " .. QS.pref["Version"] .. " loaded");


	-- Register / Unregister for events
	self:RegisterEvent("CHAT_MSG_SYSTEM");
	self:RegisterEvent("CHAT_MSG_COMBAT_XP_GAIN");
	self:RegisterEvent("PLAYER_LEVEL_UP");
	self:RegisterEvent("ACHIEVEMENT_EARNED");
	self:RegisterEvent("PARTY_MEMBERS_CHANGED");
	self:RegisterEvent("UI_INFO_MESSAGE");
	self:RegisterEvent("PLAYER_XP_UPDATE");
	self:RegisterEvent("QUEST_LOG_UPDATE");
	self:RegisterEvent("UNIT_QUEST_LOG_CHANGED");
end

-- ===========================================================================
-- NAME : QuestSpam:LoadDefaults()
-- DESC : This will reload the default values into the current global
-- ===========================================================================
function QuestSpam:LoadDefaults()
	-- Debug stuff
	if ( QS_DEBUG ) then
		QS.pref["debug"] = QS_DEBUG
	end

	-- Setup Defaults
	if not  QuestSpamBasePref.Version or QSVer > QuestSpamBasePref.Version then
		QS.pref.Version = QSVer; -- Do something more?
	end

	for key, def in pairs(QuestSpamBasePref) do
		if QS.pref[key] == nil then
		  QS.pref[key] = def
		end
	end

	if (QSVer ~= QS.pref["Version"]) then
		-- Do version updates here
		QS.pref["Version"] = QSVer;
	end

	--QS.pref["debug"] = false;

end

-- ===========================================================================
-- NAME : QuestSpamForceReset()
-- DESC : This will force a reset on the preferences and log
-- ===========================================================================
local function QuestSpamForceReset()
	--QuestSpamLog = {};
	QS.pref ={};
	QuestSpam:LoadDefaults();
	Chat("Log Cleared and Defaults Reset");
end

-- ===========================================================================
-- NAME : anonymous function(text)
-- DESC : Slash handler for slash commands
-- ===========================================================================
_G.SlashCmdList["QuestSpam"] = function(text)
	if (text) then
		-- TODO: single commands only right now, need to update to multiple commands
		local cmd = text:gsub("%s*([^%s]+).*", "%1");
		QS:Trace("CMD:"..cmd);

		-- automatic handling of toggle parameters
		for key, def in pairs(QS.pref) do
			if (cmd == key and type(QS.pref[key]) == "boolean" ) then
				QuestSpam:TogglePrefFlag(cmd);
				Chat(cmd .. " is now : " .. tostring(QS.pref[cmd]));
				--QuestSpamLoadOptionValues();
			end
		end

		-- handler for the channel id
		-- TODO: Determine if I can set channels by name.
		if (cmd == "channelid") or (cmd == "spamchannelid") then
			local trychannelid = text:gsub(cmd .. "%s*([^%s]+).*", "%1");
			QS:Trace("Trying to set channel: " .. trychannelid);
			if text:gsub(cmd .. "%s*([^%s]+).*", "%1") then
				QS.pref["channelid"] = trychannelid;
				Chat(cmd .. " is now : " .. tostring(QS.pref["channelid"]));
				--QuestSpamLoadOptionValues();
			end
		end

		if (cmd == "stats") then
			QuestSpam:ShowExperience();
			QuestSpam:ShowAchievement(nil);
		end

		if (cmd == "forcereset") then
			QuestSpamForceReset();
		end

		if (cmd == "test") then
			QuestSpam:QuestSpamRunTests();
		end

		if (cmd == "xp") then
			QuestSpam:ShowExperience();
		end

		if (cmd == "config") then
			_G.InterfaceOptionsFrame_OpenToCategory(AddonName)
		end

		if (cmd == "qlog" or cmd == "questlog" or cmd == "quests") then
			QS:DumpQuestLog()
			return
		end

		-- The help message
		-- TODO: I need a better help message
		if (cmd == "" or cmd == "status") then
			Chat("Quest Spam Status");
			for key, def in pairs(QS.pref) do
				Chat("qspam " .. key .. " = " .. tostring(QS.pref[key]));
			end
		end
	end
end

-- ===========================================================================
-- NAME : QuestSpam_RunTests()
-- DESC : This will run my test cases for messaging
-- ===========================================================================
function QuestSpam:QuestSpamRunTests()
	QS.IsTestOn = true;
	QS:Trace("Start Tests");

	QS:Trace("TEST : Quest Accepted");
	QuestSpam:OnEvent("CHAT_MSG_SYSTEM", "Quest accepted: Healing the Lake");

	QS:Trace("TEST : Quest Completed");
	QuestSpam:OnEvent("CHAT_MSG_SYSTEM", "Investigate Echo Ridge completed.");
	QuestSpam:OnEvent("CHAT_MSG_SYSTEM", "Volatile Mutations completed.");

	QS:Trace("TEST : Quest exp");
	QuestSpam:OnEvent("CHAT_MSG_SYSTEM", "Experience gained: 170.");

	QS:Trace("TEST : Discovery");
	QuestSpam:OnEvent("UI_INFO_MESSAGE", 999, "Discovered: Echo Ridge Mine");

	QS:Trace("TEST : QuestProgress");
	QuestSpam:OnEvent("UI_INFO_MESSAGE", 999, "Kobold Workers slain: 1/10");
	QuestSpam:OnEvent("UI_INFO_MESSAGE", 999, "Kobold Workers slain: 2/10");
	QuestSpam:OnEvent("UI_INFO_MESSAGE", 999, "Kobold Workers slain: 10/10");

	QS:Trace("TEST : Combat exp");
	QuestSpam:OnEvent("CHAT_MSG_COMBAT_XP_GAIN", "Vale Moth dies, you gain 26 experience.");
	QuestSpam:OnEvent("CHAT_MSG_COMBAT_XP_GAIN", "Ashenvale Bear dies, you gain 270 experience (+135 exp Rested Bonus)");

	QS:Trace("TEST : Achievement");
	QuestSpam:OnEvent("ACHIEVEMENT_EARNED", "1017");

	QS:Trace("End Tests");
	QS.IsTestOn = false;
end

-- ===========================================================================
-- NAME : QuestSpam_QUEST_LOG_UPDATE()
-- DESC : Find the quest that are completed and save the state
--        If a quest just got completed, display a message and play a sound
-- ===========================================================================

local questTitles = {}
local completedQuests, oldCompletedQuests = {}, {}
function QS:ScanQuestLog(init)

	completedQuests, oldCompletedQuests = oldCompletedQuests, completedQuests
	wipe(completedQuests)
	wipe(questTitles)

	-- Find completed quests
	for i=1,_G.GetNumQuestLogEntries() do
		local questTitle, _, _, isHeader, _, isComplete, _, questID = _G.GetQuestLogTitle(i)
		if not isHeader and questID then
			completedQuests[questID] = isComplete == 1 and true or false
			questTitles[questID] = questTitle

			-- Find completed quests
			if isComplete and not oldCompletedQuests[questID] and not firstTime then

				-- The quest was not completed before
				if QS.pref["details"] then
					QuestSpam:SpamMessage(L.QUESTSPAM_QUESTPROGRESS .. questTitle .. " (" .. _G.COMPLETE .. ")");
				end

				-- Let's also display a message on screen
				_G.UIErrorsFrame:AddMessage(questTitle .. " (" .. _G.COMPLETE .. ")", 1.0, 1.0, 0.0, 1.0, 4);

				-- And a little grunt telling us it's done
				if QS.pref["grunt_sound"] then
					_G.PlaySoundFile("Sound\\Creature\\Peon\\PeonBuildingComplete1.ogg")
				end
			end
		end
	end

	--err("init=%s, GetNumQuestLogEntries=%s",tostring(init),tostring(GetNumQuestLogEntries()))
	if firstTime  then
		firstTime = nil
		return
	end

	-- -- Find completed quests
	-- for questID, isComplete in pairs(oldCompletedQuests) do
	-- 	-- Newly completed quest?
	-- 	if not isComplete and completedQuests[questID] then
	-- 		local questTitle = questTitles[questID]

	-- 		-- The quest was not completed before
	-- 		if QS.pref["details"] then
	-- 			QuestSpam:SpamMessage(L.QUESTSPAM_QUESTPROGRESS .. questTitle .. " (" .. _G.COMPLETE .. ")");
	-- 		end

	-- 		-- Let's also display a message on screen
	-- 		_G.UIErrorsFrame:AddMessage(questTitle .. " (" .. _G.COMPLETE .. ")", 1.0, 1.0, 0.0, 1.0, 4);

	-- 		-- And a little grunt telling us it's done
	-- 		if QS.pref["grunt_sound"] then
	-- 			_G.PlaySoundFile("Sound\\Creature\\Peon\\PeonBuildingComplete1.ogg")
	-- 		end
	-- 	end
	-- end
end

function QS:DumpQuestLog()
	Chat("Quest log")
	Chat("======================")
	for qid, title in pairs(questTitles) do
		Chat(("[%s] %s"):format(qid, title))
	end
end



-- ========= Register Events  ================================================
QuestSpam:RegisterEvent("ADDON_LOADED");
QuestSpam:SetScript("OnEvent", QuestSpam.OnEvent);

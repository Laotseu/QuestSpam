local AddonName, QS = ...
QS = QS or {}

local L = {}
QS.L = L

-- ============================================================================
-- = Localized Text for Quest Spam
-- ============================================================================

-- ========== English : =======================================================

-- ========== Spam Templates and Detectors ====================================
L.QUESTSPAM_UI_INFO_MATCH = {	                            -- UI_INFO_MESSAGE 
	"^(.+): %s*[-%d]+%s*/%s*[-%d]+%s*$",				-- Credits: Some of this was derived from Fast Quest Classic; Kudos and thanks
	"^(.+)[^Trade]completed.$",							-- 
	"^(.+)\(Complete\)$",								-- 
	"^Quest accepted: .+$",								-- 
	"^Experience gained: .+$",							-- 
	"^Discovered: .+$",									-- 
	"^(.+)dies, you gain(.+)$",							-- Mutated Owlkin dies, you gain 65 experience. "^(.*) dies, you gain (.*)
}

-- ========== Quest Spam Messaging Templates ==================================
L.QUESTSPAM_QUESTTEXT = "(.*): %s*([-%d]+)%s*/%s*([-%d]+)%s*$";
L.QUESTSPAM_QUESTPROGRESS = "";
L.QUESTSPAM_LEVELUPMESSAGE = "Poing! Level %s";
L.QUESTSPAM_KILLEXP_MESSAGE = "kills %1 for %2 exp";
L.QUESTSPAM_ACHIEVEMENT_MESSAGE = "Achievement!! %s for %s pts for total of %s Achievements at %s pts";
L.QUESTSPAM_LATESTACHIEVEMENT = "Latest Achievement: ";
L.QUESTSPAM_EXP_MESSAGE_1 = "Gained %s exp and ";
L.QUESTSPAM_EXP_MESSAGE_2 = "%sis at %s%% of level %s!";
L.QUESTSPAM_EXP_GAINED = "^Experience gained: (.*)\.$"
L.QUESTSPAM_KILLEXP_MATCH = "^(.*) dies, you gain (.*) experience(.*)";

-- ========== Quest Spam About ================================================
L.QUESTSPAM_ABOUT = "Share your Achievements and Quest progress with your friends. Here you can customize what to spam and who to spam.";
L.QUESTSPAM_TITLE = "Quest Spam";

-- ========== Quest Spam Targets ==============================================
L.QUESTSPAM_ON_LABEL = "Turn on Quest Spam";
L.QUESTSPAM_ON_TOOLTIP = "This will turn on Quest Spam. The Master Switch! Nothing works if this is off.";
L.QUESTSPAM_LOCAL_LABEL = "Local area";
L.QUESTSPAM_LOCAL_TOOLTIP = "This will notify the local area, like using /say";
L.QUESTSPAM_PARTY_LABEL = "Party chat";
L.QUESTSPAM_PARTY_TOOLTIP = "This will notify the pary chat, like using /party";
L.QUESTSPAM_RAID_LABEL = "Raid chat";
L.QUESTSPAM_RAID_TOOLTIP = "This will notify the raid chat, like using /raid";
L.QUESTSPAM_GUILD_LABEL = "Guild chat";
L.QUESTSPAM_GUILD_TOOLTIP = "This will notify the guild chat, like using /guild";
L.QUESTSPAM_CHANNEL_LABEL = "Channel";
L.QUESTSPAM_CHANNEL_TOOLTIP = "My preferred method of using Quest Spam. Setup a Channel and ID, share with your friends and always be able to track progress.";
L.QUESTSPAM_CHANNELID_LABEL = "Channel ID (ex: 6 - 20)";
L.QUESTSPAM_CHANNELID_TOOLTIP = "The Channel you create/join will always have the same numeric id. (Support for channel names to come shortly)";

-- ========== Quest Spam Categories ===========================================
L.QUESTSPAM_CATAREA_LABEL = "Categories";
L.QUESTSPAM_ACHIEVEMENTS_LABEL = "Achievements";
L.QUESTSPAM_ACHIEVEMENTS_TOOLTIP = "This will spam Achievements! It will link the achievement (if in a group chat) and how many pts it was worth along with your current achievement pts and status.";
L.QUESTSPAM_LEVELUP_LABEL = "Leveling";
L.QUESTSPAM_LEVELUP_TOOLTIP = "A must have for those who say DING! Spams when you level up and also sends your new level.";
L.QUESTSPAM_QUESTPROGRESS_LABEL = "Quest Progress";
L.QUESTSPAM_QUESTPROGRESS_TOOLTIP = "This will spam when quests are accepted and completed along with the exp and %% of your current level.";
L.QUESTSPAM_QUESTDETAILS_LABEL = "Quest Details";
L.QUESTSPAM_QUESTDETAILS_TOOLTIP = "This will spam how many item/creatures you have completed while doing your quests.";
L.QUESTSPAM_DISCOVERY_LABEL = "Discovery";
L.QUESTSPAM_DISCOVERY_TOOLTIP = "This will spam a discovery notification every time you discover a new area.";
L.QUESTSPAM_COMBATXP_LABEL = "Combat Exp";
L.QUESTSPAM_COMBATXP_TOOLTIP = "The Uber Spam! This will spam your every kill that you make exp on. A true way to share the experience or annoy your friends!";

-- ========== Quest Achievement Options =======================================
L.QUESTSPAM_ACHIEVESETTINGS_LABEL = "Achievement Settings";
L.QUESTSPAM_ACHIEVE_SPAMALL_LABEL = "Share with Everyone";
L.QUESTSPAM_ACHIEVE_SPAMALL_TOOLTIP = "Share your Achievements with those around you and your current chat groups (guild,raid,party) regardless of your spam targets.";
L.QUESTSPAM_ACHIEVE_NOTLOCAL_LABEL = "Share with your buddies";
L.QUESTSPAM_ACHIEVE_NOTLOCAL_TOOLTIP = "If you feel funny about blurting out your achievements, just keep them to your current chat group.";

-- ========== Other Languages: ================================================

-- Help me localize this addon! Thanks!

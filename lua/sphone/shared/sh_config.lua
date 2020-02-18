SPhone = SPhone or {}
SPhone.config = SPhone.config or {}

/*
		CONFIGURATION FILE
*/
// Language : en_US, fr_FR, de_GER, ru_RUS, pl_PL
SPhone.config.language = "en_US"

// Fast Download : if you use the default textures
SPhone.config.fast_download = true // if you use the default content

// Set the URL of the Google Bar in Home Menu
SPhone.config.google_bar_url = "https://google.fr"

/*
*   ✒️ Advertisement
*/

// Maximum length of announce title
SPhone.config.length_max_title = 30

// Maximum length of announce (any title)
SPhone.config.length_max = 200

// Maximum lines
SPhone.config.advertisement_max_lines = 3

// Auto delete delay (0 to turn off)
SPhone.config.advertisement_deleteDelay = 1 * 60

// The offers of announce
SPhone.config.offres = {
	["Advertisement"] = {
		default = true,
		price_caracter = 5,
		anonyme = false,
	},

	["Unnamed"] = {
		default = false,
		price_caracter = 5,
		anonyme = true,
	},
}

// The ranks who can see the identity of the announce owner
SPhone.config.announce_staff_anonyme = {"superadmin", "operator", "admin"}

// Cooldown between announces (in seconds)
SPhone.config.cooldown_announce = 30

/*
* ✉️ SMS
*/

// Maximum Load SMS
SPhone.config.sms_load_max = 50

//The time that a SMS can loaded (in seconds)
SPhone.config.sms_duration_max = 604800

// Format data SMS :  %H : Hours , %M : Minutes, %S , %S : Seconds | %d : Days , %m : Month , %Y : Years
SPhone.config.sms_format_date = "%d/%m/%Y %H:%M"

// Minimum lenght SMS
SPhone.config.sms_min_length = 5

// Maximum lenght SMS
SPhone.config.sms_max_length = 250

// Maximum lines
SPhone.config.sms_max_lines = 3

// Duration notification (in seconds)
SPhone.config.sms_time_notif = 5

// Can send to yourself
SPhone.config.sms_send_to_self = false

/*
* 👨‍👦‍👦 Contacts
*/

// The time that a Contact can loaded after last connection
SPhone.config.contact_duration_max = 604800 // In seconds

// Maximum length of contact name
SPhone.config.contact_name = 20

// Add and remove players who join and leave in all players contacts list.
SPhone.config.everyone = false

/*
* 🤳 Call
*/

// Time before the end of the call (in seconds)
SPhone.config.call_time = 10

/*
*   HITMAN
* (҂‾ ▵‾)︻デ═一 (˚▽˚’!)/
*/

// Minimum player to use the Hitman application
SPhone.config.hitman_minplayer = 2

// Must have a hitman connected
SPhone.config.hitman_musthitmanconnected = false

// Name of the hitmans jobs
SPhone.config.hitman_allowed = {"Hitman"}

// Jobs who are not allowed to make contract
SPhone.config.hitman_not_allowed = {"Civil Protection"}

// Minimum length of contract description
SPhone.config.hitman_min_desc = 10

// Maximum length of contract description
SPhone.config.hitman_max_desc = 100

// Minimum offer
SPhone.config.hitman_min_offre = 1000

// Maximum offer
SPhone.config.hitman_max_offre = 5000

// Maximum lines
SPhone.config.hitman_max_lines = 5

// Cooldown between the contracts (in seconds)
SPhone.config.hitman_cooldown = 60

// Add a ban job when the hitman killed someone
SPhone.config.hitman_ban_job = 900

// Set a job list to put them in a white or black list from the banjob.
SPhone.config.hitman_banjob_joblist = {""}

// Set if the joblist is a whitelist or a blacklist
SPhone.config.hitman_banjob_whitelist = false

/*
* 🔪 BlackMarket
*/
// Not allowed job for the BlackMarket

SPhone.config.blackmarket_not_allowed = {"Civil Protection"}

// The model of the background when you enter in the menu
SPhone.config.blackmarket_background = "sphone/backgrounds/blackmarket.png"

// The model who is in your screen when you paid an item
SPhone.config.blackmarket_model_crate = "models/props_junk/cardboard_box001a.mdl"

// Allowed open a black market crate by an other person than owner
SPhone.config.blackmarket_open_crate_not_owner = true

// Time delivery (In minutes)
SPhone.config.blackmarket_delivery = 0

// If a cop find the black market crate
SPhone.config.blackmarket_delivery_reward_cops = 500

// The entity, weapon, ammo in black market
SPhone.config.blackmarket = {
	["weapon_rpg"] = {
		allowed = {"*"},
		price = 85000,
	  	model = "models/weapons/w_remington_870_tact.mdl",
		type_item = "weapon", // weapon, ammo, entity
		title = "RPG",
	},

	["tfa_jackhammer"] = {
		allowed = {"*"},
		price = 120000,
		model = "models/props_c17/suitcase001a.mdl",
		type_item = "weapon",
		title = "Jack Hammer",
	},

	["item_ammo_357"] = {
		allowed = {"*"},
		price = 1200,
		model = "models/props_c17/suitcase001a.mdl",
		type_item = "entity",
		title = "Suit2",
	},

	["item_ammo_ar2"] = {
		allowed = {"*"},
		price = 1200,
		model = "models/props_c17/suitcase001a.mdl",
		type_item = "entity",
		title = "Suit3",
	},

	["prop_thumper"] = {
		allowed = {"*"},
		price = 1200,
		model = "models/props_c17/suitcase001a.mdl",
		type_item = "entity",
		title = "Suit4",
	},

	["item_ammo_smg1"] = {
		allowed = {"*"},
		price = 1200,
		model = "models/props_c17/suitcase001a.mdl",
		type_item = "entity",
		title = "Suit5",
	},
}

// The positions of delivery (with 'getpos' in the developper console)
// If this config is empty, the delivery will spawn next to you.
SPhone.config.blackmarket_spawn = {
	Vector(-4424.811035, -1757.130127, 314.031250),
	-- Vector(-119.694061, -527.988403, -12223.968750)
}

// The cops jobs
SPhone.config.blackmarket_cops = {"Police"}

// The time before when the cops is alerted (in seconds)
SPhone.config.spawn_alert_time = 25

// Alert icon (for the cops)
SPhone.config.blackmarket_alert = Material("sphone/blackmarket.png", "smooth")

// Delivery icon (for the owner of crate)
SPhone.config.blackmarket_delivery = Material("sphone/delivery.png", "smooth")

// Cooldown between the order (in minutes)
SPhone.config.blackmarket_delivery_cooldown = 1

// Distance where the icon hide
SPhone.config.distance_despawn_alert = 3

/*
* 🏬 Market
*/

// Default background
SPhone.config.background_default = "sphone/backgrounds/default.png"

// Default notification
SPhone.config.notification_default = "sphone/notifications/bubble.wav"

// Default ring
SPhone.config.call_default = "sphone/call/nokia.wav"

// Market icon vip (Be carefull, image can be pixelated)
SPhone.config.market_vip_icon = "sphone/vip.png"


// The cosmetics in the market

SPhone.config.market = {
	["sphone/backgrounds/default.png"] = {
		allowed = {"*"},
		price = 0,
		type_item = "background", //  background , notification , call_sound
		title = "Default Background",
	},

	["sphone/backgrounds/licorne.png"] = {
		allowed = {"*"},
		price = 1000,
		type_item = "background",
		title = "Unicorn",
	},

	["sphone/backgrounds/chat.png"] = {
		allowed = {"*"},
		price = 1000,
		type_item = "background",
		title = "Cat",
	},

	["sphone/backgrounds/dbz.png"] = {
		allowed = {"vip", "superadmin"},
		price = 1000,
		type_item = "background",
		title = "Dragon Ball Z",
	},

	["sphone/backgrounds/ironman.png"] = {
		allowed = {"vip", "superadmin"},
		price = 1000,
		type_item = "background",
		title = "Ironman",
	},

	["sphone/backgrounds/joker.png"] = {
		allowed = {"vip", "superadmin"},
		price = 1000,
		type_item = "background",
		title = "Joker",
	},

	["sphone/backgrounds/pokemon.png"] = {
		allowed = {"vip", "superadmin"},
		price = 1000,
		type_item = "background",
		title = "Pokemon",
	},

	["sphone/backgrounds/voiture.png"] = {
		allowed = {"*"},
		price = 1000,
		type_item = "background",
		title = "Car",
	},

	["sphone/backgrounds/tortue.png"] = {
		allowed = {"*"},
		price = 1000,
		type_item = "background",
		title = "Turtle",
	},

	["sphone/backgrounds/son.png"] = {
		allowed = {"*"},
		price = 1000,
		type_item = "background",
		title = "Sound",
	},

	["sphone/backgrounds/relax.png"] = {
		allowed = {"*"},
		price = 1000,
		type_item = "background",
		title = "Relax",
	},


	["sphone/notifications/bubble.wav"] = {
		allowed = {"*"},
		price = 0,
		type_item = "notification",
		title = "Notification - Bubble",
	},

	["sphone/notifications/cute.wav"] = {
		allowed = {"*"},
		price = 5000,
		type_item = "notification",
		title = "Notification - Cute",
	},

	["sphone/notifications/fairy.wav"] = {
		allowed = {"*"},
		price = 5000,
		type_item = "notification",
		title = "Notification - Fairy",
	},

	["sphone/notifications/iphone.wav"] = {
		allowed = {"*"},
		price = 5000,
		type_item = "notification",
		title = "Notification - IPhone",
	},

	["sphone/notifications/newmsg.wav"] = {
		allowed = {"*"},
		price = 5000,
		type_item = "notification",
		title = "Notification - New Message",
	},

	["sphone/notifications/si.wav"] = {
		allowed = {"*"},
		price = 5000,
		type_item = "notification",
		title = "Notification - Si (Ronaldo)",
	},

	["sphone/notifications/xbox.wav"] = {
		allowed = {"*"},
		price = 5000,
		type_item = "notification",
		title = "Notification - Xbox",
	},

	["sphone/call/nokia.wav"] = {
		allowed = {"*"},
		price = 0,
		type_item = "call_sound",
		title = "Sonnerie Nokia",
	},

	["sphone/call/huawei.wav"] = {
		allowed = {"*"},
		price = 5000,
		type_item = "call_sound",
		title = "Sonnerie Huawei",
	},

	["sphone/call/iphonec.wav"] = {
		allowed = {"*"},
		price = 5000,
		type_item = "call_sound",
		title = "Sonnerie IPhone",
	},

}

	/*
	*	🚓 Emergency System
	*/

// The distance between the caller and the responder is necessary to remove the point on the responder s screen
SPhone.config.DistanceToRemovePoint = 30

// Deactivates the call if the job is not played by a player
SPhone.config.disableWhenJobNotConnected = false

// The list of all emergency available
SPhone.config.emergency = {
	{
		name = "Police", -- name of the emergency
		icon = Material("sphone/emergencycall/policeman.png", "smooth"), -- The icon
		price = 100, -- The price
		cooldown = 20, -- In seconds
		jobs = { -- The jobs who can show the call
			["Civil Protection"] = true,
		}
	},
}

/*

	Other config

*/

// StormFox time integration (https://github.com/Nak2/StormFox)
SPhone.config.stormFox = false

// Hide app in the home menu
SPhone.config.disableApp = {
	["advert"] = false,
	["blackmarket"] = false,
	["call"] = false,
	["camera"] = false,
	["contacts"] = false,
	["callemergency"] = false,
	["hitman"] = false,
	["market"] = false,
	["sms"] = false,
}

// Disable app for certain jobs
SPhone.config.disableAppByJob = {
	["advert"] = {""},
	["blackmarket"] = {""},
	["call"] = {""},
	["camera"] = {""},
	["contacts"] = {""},
	["callemergency"] = {""},
	["hitman"] = {""},
	["market"] = {""},
	["sms"] = {""},
}

/*
thank you for using the SPHONE
*/

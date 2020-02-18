--[[
	mLogs 2 (M4D Logs 2)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright © 2018 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

mLogs.addCategory(
	"SPhone", -- Name
	"sphone", 
	Color(44, 62, 80), -- Color
	function() -- Check
		return SPhone != nil
	end,
	true -- delayed
)

mLogs.addCategoryDefinitions("sphone", {
	sphoneadvert = function(data) return mLogs.doLogReplace({"^player", "sent an Advert :", "^title", "|", "^content"},data) end,
	sphoneblackmarket = function(data) return mLogs.doLogReplace({"^player", "bought", "^item", "in the blackmarket for", "^price", "."},data) end,
	sphonecall = function(data) return mLogs.doLogReplace({"^player1", "called", "^player2","."},data) end,
	sphoneemergencycallsend = function(data) return mLogs.doLogReplace({"^player1","called the", "^call"},data) end,
	sphoneemergencycallclaim = function(data) return mLogs.doLogReplace({"^player1", "claimed the ticket of", "^player2"},data) end,
	sphonehitmanaccept = function(data) return mLogs.doLogReplace({"^player1", "accepted a contract from", "^player2", "to kill", "^player3", "with the following reason", "^reason"},data) end,
	sphonehitmansend = function(data) return mLogs.doLogReplace({"^player1"," made a contract to kill", "^player2", "with the following reason", "^reason"},data) end,
	sphonehitmancomplete = function(data) return mLogs.doLogReplace({"^player1", "completed the contract to kill", "^player2", "and earned", "^reward"},data) end,
	sphonemarket = function(data) return mLogs.doLogReplace({"^player", "bought an item in the market for", "^price"},data) end,
	sphonesms = function(data) return mLogs.doLogReplace({"^player1", "sent an SMS to", "^player2", "with the message", "^msg"},data) end,
})
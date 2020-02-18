
local function create_table_market()

	if (!sql.TableExists("sphone_market")) then
		query = "CREATE TABLE sphone_market ( player varchar(255), type varchar(100),item varchar(255), active varchar(4))"
		result = sql.Query(query)
	end
end

create_table_market()

local PL = FindMetaTable("Player")

function PL:addItem(item)
	sql.Query( "INSERT INTO sphone_market (`player`, `type`, `item`, `active`)VALUES ("..sql.SQLStr(self:SteamID64())..", "..sql.SQLStr(SPhone.config.market[item].type_item)..", "..sql.SQLStr(item)..", 'false')" )
end

function PL:removeItem(item)
	sql.Query( "DELETE FROM sphone_market WHERE player="..sql.SQLStr(self:SteamID64()).." AND item="..sql.SQLStr(item) )
end

function PL:hasItem(item)
	local result = sql.Query( "SELECT * FROM sphone_market WHERE player = "..sql.SQLStr(self:SteamID64()).." AND item = "..sql.SQLStr(item) )
	if result then
		return true
	end
	return false
end

function PL:isEnableItem(item,cat)
	local result = sql.Query( "SELECT * FROM sphone_market WHERE player = "..sql.SQLStr(self:SteamID64()).." AND item = "..sql.SQLStr(item).." AND type = "..sql.SQLStr(cat) )
	if result[1].active == "true" then
		return true
	end
	return false
end

function PL:activeItem(item,cat)
	sql.Query( "UPDATE sphone_market SET active = 'false' WHERE player = "..sql.SQLStr(self:SteamID64()).." AND active = 'true' AND type = "..sql.SQLStr(cat) )
	sql.Query( "UPDATE sphone_market SET active = 'true' WHERE player = "..sql.SQLStr(self:SteamID64()).." AND item = "..sql.SQLStr(item).." AND type = "..sql.SQLStr(cat) )
	if result then
		return true
	end
	return false
end

function PL:loadItem()
	local call = sql.Query( "SELECT item FROM sphone_market WHERE player = "..sql.SQLStr(self:SteamID64()).." AND active = 'true' AND type = 'call_sound'" )
	local notification = sql.Query( "SELECT item FROM sphone_market WHERE player = "..sql.SQLStr(self:SteamID64()).." AND active = 'true' AND type = 'notification'" )
	local result = sql.Query( "SELECT item FROM sphone_market WHERE player = "..sql.SQLStr(self:SteamID64()).." AND active = 'true' AND type = 'background'" )
	local items_buy = sql.Query( "SELECT * FROM sphone_market WHERE player = "..sql.SQLStr(self:SteamID64()) )

	self.background_phone = SPhone.config.background_default
	self.notification_phone = SPhone.config.notification_default
	self.call_sound = SPhone.config.call_default

	if call then
		self.call_sound = call[1].item
	end

	if notification then
		self.notification_phone = notification[1].item
	end

	if result then
		self.background_phone = result[1].item
	end

	if items_buy then
		self.items_buy = items_buy
	else
		self.items_buy = {}
	end
	net.Start("Phone:Market")
		net.WriteString(self.background_phone)
		net.WriteString(self.notification_phone)
		net.WriteString(self.call_sound)
		net.WriteTable(self.items_buy)
	net.Send(self)
end

local function spawnloaditem( ply )
	ply:loadItem()
end
hook.Add( "PlayerInitialSpawn", "loaditems", spawnloaditem )

local function isInMarket(item)
	if SPhone.config.market[item] then
		return true
	end
	return false
end

net.Receive("Phone:Market",function(len,ply)

	local action = net.ReadString()

	if action == "buy" then
		if !ply:HasWeapon( "sphone" ) then return end

		local bg = net.ReadString()

		if !isInMarket(bg) then
			net.Start("Phone:Announce")
				net.WriteString("send")
				net.WriteString( SPhone.GetLanguage("IItemMarket") )
				net.WriteUInt(1,8)
			net.Send(ply)
			return
		end

		if ply:hasItem(bg) then
			net.Start("Phone:Announce")
				net.WriteString("send")
				net.WriteString( SPhone.GetLanguage("AlrOwnMarket") )
				net.WriteUInt(1,8)
			net.Send(ply)
			return
		end

		local price = SPhone.config.market[bg].price
		if !table.HasValue(SPhone.config.market[bg].allowed,ply:GetUserGroup()) && !table.HasValue(SPhone.config.market[bg].allowed,"*") then
			net.Start("Phone:Announce")
				net.WriteString("send")
				net.WriteString( SPhone.GetLanguage("RightRankMarket") )
				net.WriteUInt(1,8)
			net.Send(ply)
			return
		end

		if ply:canAfford(price) then
			ply:addMoney(-price)
			ply:addItem(bg)
			ply:loadItem()
			hook.Call("SPhoneBuyMarket", nil, ply, price)
			net.Start("Phone:Announce")
				net.WriteString("send")
				net.WriteString( SPhone.GetLanguage("HaveBoughtMarket")..SPhone.config.market[bg].title.." !" )
				net.WriteUInt(0,8)
			net.Send(ply)
		else
			net.Start("Phone:Announce")
				net.WriteString("send")
				net.WriteString( SPhone.GetLanguage("BMoney") )
				net.WriteUInt(1,8)
			net.Send(ply)
		end

	elseif action == "active" then

		if !ply:HasWeapon( "sphone" ) then return end

		local bg = net.ReadString()

		if !isInMarket(bg) then
			net.Start("Phone:Announce")
				net.WriteString("send")
				net.WriteString( SPhone.GetLanguage("IItemMarket") )
				net.WriteUInt(1,8)
			net.Send(ply)
			return
		end

		if !ply:hasItem(bg) then
			net.Start("Phone:Announce")
				net.WriteString("send")
				net.WriteString( SPhone.GetLanguage("DOwnMarket") )
				net.WriteUInt(1,8)
			net.Send(ply)
			return
		end

		if ply:isEnableItem(bg,SPhone.config.market[bg].type_item) then
			net.Start("Phone:Announce")
				net.WriteString("send")
				net.WriteString( SPhone.GetLanguage("AlrActivatedMarket") )
				net.WriteUInt(1,8)
			net.Send(ply)
			return
		end

		net.Start("Phone:Announce")
			net.WriteString("send")
			net.WriteString( SPhone.GetLanguage("ActivatedMarket")..SPhone.config.market[bg].title.." !" )
			net.WriteUInt(0,8)
		net.Send(ply)

		ply:activeItem(bg,SPhone.config.market[bg].type_item)
		ply:loadItem()
	end
end)

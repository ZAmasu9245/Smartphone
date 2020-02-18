SPhone = SPhone or {}
SPhone.apps = SPhone.apps or {}
SPhone.apps.contact = SPhone.apps.contact or {}

function SPhone.apps.contact.create_table()

	if !sql.TableExists("sphone_contacts") then
		sql.Query("CREATE TABLE sphone_contacts ( player varchar(255), numero varchar(255), name varchar(255), add_at integer)")
	end

	if !sql.TableExists("sphone_players") then
		sql.Query("CREATE TABLE sphone_players ( steamid varchar(255), last_connection integer)")
	end
end

SPhone.apps.contact.create_table()

local PL = FindMetaTable("Player")

function PL:addContact(steamid,name)
	sql.Query( "INSERT INTO sphone_contacts (`player`, `numero`, `name`, `add_at`)VALUES ("..sql.SQLStr(self:SteamID64())..", "..sql.SQLStr(steamid)..", "..sql.SQLStr(name)..", "..sql.SQLStr(os.time())..")")
end

function PL:removeContact(steamid)
	sql.Query( "DELETE FROM sphone_contacts WHERE player="..sql.SQLStr(self:SteamID64()).." AND numero="..sql.SQLStr(steamid) )
end

function PL:changeNameContact(steamid,new_steamid,new_name)
	sql.Query( "UPDATE sphone_contacts SET numero=" .. sql.SQLStr(new_steamid) .. ",name=" .. sql.SQLStr(new_name) .. " WHERE player="..sql.SQLStr(self:SteamID64()).." AND numero="..sql.SQLStr(steamid) )
end

function PL:isContact(steamid)
	local result = sql.Query( "SELECT * FROM sphone_contacts WHERE player = "..sql.SQLStr(self:SteamID64()).." AND numero = "..sql.SQLStr(steamid) )
	if result then
	return true
	end
	return false
end

function PL:AddConnection()
	local result = sql.Query( "SELECT * FROM sphone_players WHERE steamid = "..sql.SQLStr(self:SteamID64()))

	if result then
		sql.Query( "UPDATE sphone_players SET last_connection=" .. sql.SQLStr(os.time()) .. " WHERE steamid="..sql.SQLStr(self:SteamID64()) )
	else
		sql.Query( "INSERT INTO sphone_players (`steamid`, `last_connection`)VALUES ("..sql.SQLStr(self:SteamID64())..", "..sql.SQLStr(os.time())..")")
	end
end

local function ConnectionValid(steamid)
	local result = sql.Query( "SELECT * FROM sphone_players WHERE steamid = "..sql.SQLStr(steamid))
	if result then
		if os.difftime( os.time(), result[1].last_connection) <= SPhone.config.contact_duration_max then
		return true
		end
	end
	return false
end

function PL:loadContact()
	self.contacts = {}
	contacts = sql.Query( "SELECT * FROM sphone_contacts WHERE player = "..sql.SQLStr(self:SteamID64()).." ORDER BY name")

	if contacts then
		for k,v in pairs(contacts) do
			if(ConnectionValid(v.numero)) then
				table.insert(self.contacts,v)
			end
		end
	end
	table.SortByMember( self.contacts, "name", true )
	net.Start("Phone:Contact")
		net.WriteString("sync")
	net.WriteTable(self.contacts)
	net.Send(self)
end

local function spawnLoad( ply )
	ply:AddConnection()

	if SPhone.config.everyone then 
		for _, v in pairs(player.GetAll()) do

			ply:addContact(v:SteamID64(), v:GetName())
			if ply:SteamID64() == v:SteamID64() then continue end
			v:addContact(ply:SteamID64(), ply:GetName())
			v:loadContact()

		end	
	end

	ply:removeContact(ply:SteamID64())
	ply:addContact(ply:SteamID64(), SPhone.GetLanguage("Me") )
	ply:loadContact()
end
hook.Add( "PlayerInitialSpawn", "SPhone:PlayerInitialSpawn:loadcontact", spawnLoad )

hook.Add( "PlayerDisconnected", "SPhone:PlayerDisconnected:Remove", function(ply)

	if !SPhone.config.everyone then return end
	
	for _, v in pairs(player.GetAll()) do

		ply:removeContact(v:SteamID64())

		v:removeContact(ply:SteamID64())
		v:loadContact()
	end
end)

local function getOwnerNum(num)
	for k,v in pairs(player.GetAll()) do
	if v:SteamID64() == num then
		return v
	end
	end
end

net.Receive("Phone:Contact",function(len,ply)

	local action = net.ReadString()

	if action == "add" then
		if !ply:HasWeapon( "sphone" ) then return end
		
		local num = net.ReadString()
		local nm = net.ReadString()
		
		if !IsValid(getOwnerNum(num)) then
			net.Start("Phone:Contact")
			net.WriteString("notif")
			net.WriteString( SPhone.GetLanguage("IContacts") )
			net.WriteColor(Color(192, 57, 43))
			net.Send(ply)
			return
		end
		
		if ply:isContact(num) then
		net.Start("Phone:Contact")
			net.WriteString( SPhone.GetLanguage("AlrContacts") )
			net.WriteColor(Color(192, 57, 43))
		net.Send(ply)
		return
		end

		if string.len(nm) > SPhone.config.contact_name then
			net.Start("Phone:Contact")
				net.WriteString("notif")
				net.WriteString( SPhone.GetLanguage("IContacts") )
				net.WriteColor(Color(192, 57, 43))
			net.Send(ply)
			return
		end

		net.Start("Phone:Contact")
			net.WriteString("notif")
		net.WriteString( SPhone.GetLanguage("SContacts") )
		net.WriteColor(Color(39, 174, 96))
		net.Send(ply)
		ply:addContact(num,nm)

		ply:loadContact()

	elseif action == "remove" then

		if !ply:HasWeapon( "sphone" ) then return end

		local num = net.ReadString()

		if ply:isContact(num) then
		ply:removeContact(num)
		ply:loadContact()
		end

	elseif action == "edit" then

		if !ply:HasWeapon( "sphone" ) then return end

		local num = net.ReadString()
		local new_num = net.ReadString()
		local new_nm = net.ReadString()

		if string.len(new_nm) > SPhone.config.contact_name then
			net.Start("Phone:Contact")
				net.WriteString("notif")
				net.WriteString( SPhone.GetLanguage("IContacts") )
				net.WriteColor(Color(192, 57, 43))
			net.Send(ply)
			return
		end

		net.Start("Phone:Contact")
			net.WriteString("notif")
			net.WriteString( SPhone.GetLanguage("SContacts") )
			net.WriteColor(Color(39, 174, 96))
		net.Send(ply)
		ply:changeNameContact(num,new_num,new_nm)

		ply:loadContact()

	end
end)

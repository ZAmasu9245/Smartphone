SPhone.apps = SPhone.apps or {}
SPhone.apps.sms = SPhone.apps.sms or {}

function SPhone.apps.sms.create_table_sms()
	if (!sql.TableExists("sphone_sms")) then
		query = "CREATE TABLE sphone_sms ( player varchar(255), target varchar(255), sms varchar(1000), send_at integer)"
		result = sql.Query(query)
	end
end

SPhone.apps.sms.create_table_sms()

local PL = FindMetaTable("Player")

function PL:sendSMS(owner,sms) -- PL = Le destinataire / L'owner l'envoyeur
	self.cooldown_sms = CurTime() + 2	
	sql.Query( "INSERT INTO sphone_sms (`player`, `target`, `sms`, `send_at`)VALUES ("..sql.SQLStr(self:SteamID64())..", "..sql.SQLStr(owner)..", "..sql.SQLStr(sms)..", "..sql.SQLStr(os.time())..")" )
end

function PL:loadSMS()
	local request = sql.Query( "SELECT * FROM sphone_sms WHERE player = "..sql.SQLStr(self:SteamID64()).." OR target = "..sql.SQLStr(self:SteamID64()).." ORDER BY send_at DESC LIMIT "..SPhone.config.sms_load_max)
	local result = {}
	if request then
		for k,v in pairs(request) do
			if(os.difftime( os.time(), v.send_at) <= SPhone.config.sms_duration_max) then
				table.insert(result,v)
			end
		end
	end
	table.SortByMember( result, "send_at", true )
	net.Start("Phone:SMS")
		net.WriteString("load")
		net.WriteTable(result)
	net.Send(self)
end

local function spawnloadsms( ply )
	ply:loadSMS()
end
hook.Add( "PlayerInitialSpawn", "loadsms", spawnloadsms )

local function isOnlinePlayerSMS(steamid)
	for k,v in pairs(player.GetAll()) do
		if steamid == v:SteamID64() then
			return v
		end
	end
end

net.Receive("Phone:SMS",function(len,ply)
	if !ply:HasWeapon( "sphone" ) then return end
	if ply.cooldown_sms && ply.cooldown_sms >= CurTime() then return end

	local target = isOnlinePlayerSMS(net.ReadString())
	local msg = string.Trim(net.ReadString())
	local _, lines = msg:gsub('\n', '\n')

	if !IsValid(target) then
		net.Start("Phone:SMS")
			net.WriteString("notif")
			net.WriteString( SPhone.GetLanguage("OfflineSMS") )
			net.WriteUInt(1,12)
		net.Send(ply)
		return
	end

	if ply == target && !SPhone.config.sms_send_to_self then
		net.Start("Phone:SMS")
			net.WriteString("notif")
			net.WriteString( SPhone.GetLanguage("SendToSelf") )
			net.WriteUInt(1,12)
		net.Send(ply)
		return
	end

	if lines + 1 > SPhone.config.sms_max_lines then
		net.Start("Phone:SMS")
			net.WriteString("notif")
			net.WriteString( SPhone.GetLanguage("MaxNewline") )
			net.WriteUInt(1,12)
		net.Send(ply)
		return
	end

	if string.len(msg) < SPhone.config.sms_min_length then
		net.Start("Phone:SMS")
			net.WriteString("notif")
			net.WriteString( SPhone.GetLanguage("TooShortSMS").." (+"..SPhone.config.sms_min_length..")" )
			net.WriteUInt(1,12)
		net.Send(ply)
		return
	end

	if string.len(msg) > SPhone.config.sms_max_length then
		net.Start("Phone:SMS")
			net.WriteString("notif")
			net.WriteString( SPhone.GetLanguage("TooLongSMS").." (+"..SPhone.config.sms_max_length..")" )
			net.WriteUInt(1,12)
		net.Send(ply)
		return
	end

	net.Start("Phone:SMS")
		net.WriteString("send")
		net.WriteString( SPhone.GetLanguage("ReceiveSMS") )
	net.Send(target)

	hook.Call("SPhoneSmsSend", nil, ply, target, msg)
	ply:sendSMS(target:SteamID64(),msg)
	ply:loadSMS()
	target:loadSMS()

end)

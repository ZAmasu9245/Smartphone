hook.Add( "PlayerCanHearPlayersVoice", "PhoneCall", function( listener, talker )
		if IsValid(listener.call_target) && IsValid(talker.call_target) then
		
			if listener.call_target == talker && talker.call_target == listener then

				if talker:Alive() && listener:Alive() then
					if talker:HasWeapon("sphone") then
						return true, false
					end
					if listener:HasWeapon("sphone") then
						return true, false
					end
				end
			
			end
		end
end )

hook.Add( "PlayerSpawn", "PhoneCall:Respawn", function( ply )
	if ply.reply then
		ply:HangsPhone()
		ply.call_target:HangsPhone()
	end
end )

local PL = FindMetaTable("Player")

function PL:CallPhone(target)

	self.call_target = target
	self.reply = true
	target.call_target = self
	target.reply = false

	net.Start("Phone:Call")
		net.WriteString("call")
		net.WriteEntity(self.call_target)
		net.WriteBool(self.reply)
		net.WriteBool(target.reply)
	net.Send(self)

	net.Start("Phone:Call")
		net.WriteString("call")
		net.WriteEntity(target.call_target)
		net.WriteBool(target.reply)
		net.WriteBool(self.reply)
	net.Send(target)

	hook.Call("SPhoneCall", nil, self, target)

end

function PL:HangsPhone()

	if IsValid(self.call_target) then
		self.call_target.call_target = nil
		self.call_target.reply = false

		net.Start("Phone:Call")
			net.WriteString("hangsup")
			net.WriteBool(self.call_target.reply)
		net.Send(self.call_target)
	end
	self.call_target = nil
	self.reply = false

	net.Start("Phone:Call")
		net.WriteString("hangsup")
		net.WriteBool(self.reply)
	net.Send(self)
end

local function isOnlinePlayer(steamid)
	for k,v in pairs(player.GetAll()) do
		if steamid == v:SteamID64() then
			return v
		end
	end
end

net.Receive("Phone:Call",function(len,ply)

	local action = net.ReadString()
	if action == "call" then
		if !ply:HasWeapon( "sphone" ) then return end

		if ply.call_target then return end
		local num = isOnlinePlayer(net.ReadString())

		if !IsValid(num) then
			net.Start("Phone:Call")
				net.WriteString("notif")
				net.WriteString( SPhone.GetLanguage("UCall") )
				net.WriteColor(Color(192, 57, 43))
			net.Send(ply)
			return
		end

		if num == ply then
			net.Start("Phone:Call")
				net.WriteString("notif")
				net.WriteString( SPhone.GetLanguage("CCall") )
				net.WriteColor(Color(192, 57, 43))
			net.Send(ply)
			return
		end

		if !num:HasWeapon("sphone") then
			net.Start("Phone:Call")
				net.WriteString("notif")
				net.WriteString( SPhone.GetLanguage("NCall") )
				net.WriteColor(Color(192, 57, 43))
			net.Send(ply)
			return
		end

		if num.call_target then
			net.Start("Phone:Call")
				net.WriteString("notif")
				net.WriteString( SPhone.GetLanguage("ACall") )
				net.WriteColor(Color(192, 57, 43))
			net.Send(ply)
			return
		end

		ply:CallPhone(num)
	elseif action == "hangsup" then
		if !ply:HasWeapon( "sphone" ) then return end

		if ply.reply != nil then
			ply:HangsPhone()
		end
	end
end)

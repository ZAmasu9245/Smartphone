util.AddNetworkString("SPhone:Emergency")

SPhone.apps.call_emergency = SPhone.apps.call_emergency or {}
SPhone.apps.call_emergency.ticket = SPhone.apps.call_emergency.ticket or {}

local function isInTeamEmergency(t)
	for k,v in pairs(SPhone.config.emergency) do
		if v.jobs[team.GetName(t)] then return true end
	end
	return false
end

local function getEmergencyTicket(ply,send_at)
	for k,v in pairs(SPhone.apps.call_emergency.ticket) do
		if v.player == ply && v.curtime == send_at then
			return k
		end
	end
	return false
end

local function isEmergencyTicket(ply,send_at)
	for k,v in pairs(SPhone.apps.call_emergency.ticket) do
		if v.player == ply && v.curtime == send_at then
			return true
		end
	end
	return false
end

local function isEmergencyTicketClaim(ticket_key)
	if SPhone.apps.call_emergency.ticket[ticket_key].claim then return true end
	return false
end

net.Receive("SPhone:Emergency", function(len,ply)

	local action = net.ReadString()

	if !ply:HasWeapon( "sphone" ) then return end

	if action == "call" then
		local emergency_call = net.ReadUInt(8)

		if !SPhone.config.emergency[emergency_call] then return end

		local emergency_config = SPhone.config.emergency[emergency_call]

		if table.HasValue(emergency_config.jobs, team.GetName(ply:Team())) then return end

		if !ply.sphone_emergency then
			ply.sphone_emergency = {}
		end

		if ply.sphone_emergency[emergency_call] && ply.sphone_emergency[emergency_call] > CurTime() then
			DarkRP.notify(ply, 1, 5, string.format(SPhone.GetLanguage("BWait"), math.Round(ply.sphone_emergency[emergency_call] - CurTime())))
			return
		end

		if !ply:canAfford(emergency_config.price) then
			DarkRP.notify(ply, 1, 5, SPhone.GetLanguage("BMoney"))
			return
		end

		ply.sphone_emergency[emergency_call] = CurTime() + emergency_config.cooldown

		ply:addMoney(-emergency_config.price)
		DarkRP.notify(ply, 0, 5, string.format(SPhone.GetLanguage("EmergencySend"), emergency_config.name))

		local send_at = CurTime()
		local ticket = {
			player = ply,
			emergency = emergency_call,
			curtime = send_at,
			claim = false,
			claim_player = nil
		}

		hook.Call("SPhoneCallEmergency", nil, ply, ticket)
		table.insert(SPhone.apps.call_emergency.ticket, ticket)
	
		for k,v in pairs(player.GetAll()) do
			if emergency_config.jobs[team.GetName(v:Team())] && v:HasWeapon( "sphone" ) then
				net.Start("SPhone:Emergency")
					net.WriteString("emergency_popup_add")
					net.WriteEntity(ply)
					net.WriteUInt(emergency_call, 8)
					net.WriteFloat(send_at)
				net.Send(v)
			end
		end

	elseif action == "claim" then
		local target = net.ReadEntity()

		if !IsValid(target) then
			DarkRP.notify(ply, 1, 5, SPhone.GetLanguage("EmergencyNotAVaible"))
			return
		end

		local emergency = net.ReadUInt(8)
		local send_at = net.ReadFloat()

		if !SPhone.config.emergency[emergency] then return end

		local emergency_config = SPhone.config.emergency[emergency]

		if !emergency_config.jobs[team.GetName(ply:Team())] then return end

		if !isEmergencyTicket(target,send_at) then return end

		local ticket = getEmergencyTicket(target,send_at)

		if isEmergencyTicketClaim(ticket) then
			DarkRP.notify(ply, 1, 5, SPhone.GetLanguage("EmergencyAlready"))
			return
		end

		SPhone.apps.call_emergency.ticket[ticket]['own'] = target
		SPhone.apps.call_emergency.ticket[ticket]['claim'] = true
		SPhone.apps.call_emergency.ticket[ticket]['claim_player'] = ply

		net.Start("SPhone:Emergency")
			net.WriteString("emergency_popup_claim")
			net.WriteTable(SPhone.apps.call_emergency.ticket[ticket])
			net.WriteEntity(target)
			net.WriteFloat(send_at)
		net.Send(ply)

		for k,v in pairs(player.GetAll()) do
			if v != ply && emergency_config.jobs[team.GetName(v:Team())] then
				net.Start("SPhone:Emergency")
					net.WriteString("emergency_popup_sync")
					net.WriteEntity(target)
					net.WriteEntity(ply)
					net.WriteFloat(send_at)
				net.Send(v)
			end
		end

		hook.Call("SPhoneClaimedEmergency", nil, ply, SPhone.apps.call_emergency.ticket[ticket])
		DarkRP.notify(ply, 0, 5, string.format(SPhone.GetLanguage("EmergencyTake"), target:GetName()))
		DarkRP.notify(target, 0, 5, SPhone.GetLanguage("EmergencyTaken"))

	end
end)

hook.Add("OnPlayerChangedTeam", "SPhone:Emergency:ChangeTeam", function(ply,jbefore,jafter)

	if isInTeamEmergency(jbefore) then

		net.Start("SPhone:Emergency")
			net.WriteString("emergency_popup_clear")
		net.Send(ply)
	end

end)
	

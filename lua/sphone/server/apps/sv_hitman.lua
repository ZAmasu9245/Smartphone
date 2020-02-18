SPhone.hitmans = SPhone.hitmans or {}

hook.Add( "PlayerDeath", "SPhone:Death", function( victim, inflictor, attacker )
	if attacker:IsPlayer() then
		if table.HasValue(SPhone.config.hitman_allowed,team.GetName(attacker:Team())) then
			if attacker:hasContrat(victim) then
				local reward = attacker:getRewardHitman(victim)
				net.Start("Phone:Announce")
					net.WriteString("send")
						net.WriteString( SPhone.GetLanguage("SSHitman")..DarkRP.formatMoney(reward).."!" )
					net.WriteUInt(0,8)
				net.Send(attacker)
				if(SPhone.config.hitman_banjob_whitelist) then
					if(table.HasValue(SPhone.config.hitman_banjob_joblist, team.GetName(victim:Team()))) then
						victim:teamBan(victim:Team(), SPhone.config.hitman_ban_job)
						victim:changeTeam(GAMEMODE.DefaultTeam, true, true)
					end
				else
					if(!table.HasValue(SPhone.config.hitman_banjob_joblist, team.GetName(victim:Team()))) then
						victim:teamBan(victim:Team(), SPhone.config.hitman_ban_job)
						victim:changeTeam(GAMEMODE.DefaultTeam, true, true)
					end
				end
				hook.Call("SPhoneHitmanSucceedInContract", nil, attacker, victim, reward)
				attacker:addMoney(reward)
				attacker:removeContrat(victim)
				return
			end
		end
	end

	if victim:isContrat() then
		net.Start("Phone:Announce")
			net.WriteString("send")
			net.WriteString( SPhone.GetLanguage("LHitman") )
			net.WriteUInt(1,8)
		net.Send(attacker)
		attacker:removeContrat(victim)
	end

	if victim:hasContratOnSelf() then
		net.Start("Phone:Announce")
			net.WriteString("send")
			net.WriteString( SPhone.GetLanguage("LHitman") )
			net.WriteUInt(1,8)
		net.Send(victim:isHitmanTarget())
		victim:isHitmanTarget():removeContrat(victim)
	end

	net.Start("Phone:Home")
		net.WriteString("close")
	net.Send(victim)

end)

hook.Add( "PlayerDisconnected", "DisconnectTargetHitman", function( ply )

	if table.HasValue(SPhone.config.hitman_allowed,team.GetName(ply:Team())) then
		if ply:isContrat() then
			ply:removeHitman(ply:getTargetHitman())
		end
	end

	if ply:isTargetHitman() then
		local targ = ply:isHitmanTarget()
		targ:removeHitman(ply)

		net.Start("Phone:Announce")
			net.WriteString("send")
			net.WriteString( SPhone.GetLanguage("LeftHitman") )
			net.WriteUInt(1,8)
		net.Send(targ)
	end

end)

hook.Add("OnPlayerChangedTeam","ChangeHitmanteam",function(ply, before, after)

	if table.HasValue(SPhone.config.hitman_allowed,team.GetName(before)) then
		if ply:isContrat() then
			net.Start("Phone:Announce")
				net.WriteString("send")
					net.WriteString( SPhone.GetLanguage("LostHitman") )
				net.WriteUInt(1,8)
			net.Send(attacker)
			ply:removeHitman(ply:getTargetHitman())
		end
	end

	if table.HasValue(SPhone.config.hitman_allowed,team.GetName(after)) then
		SPhone.synchronisation_hitman()
	end

end)


net.Receive("Phone:Hitman",function(len,ply)
	if table.HasValue(SPhone.config.hitman_not_allowed, team.GetName(ply:Team())) then return end

	local action = net.ReadString()
	if action == "send" then
		if !ply:HasWeapon( "sphone" ) then return end

		local target = net.ReadEntity()
		local text = string.Trim(net.ReadString())
		local _, lines = text:gsub('\n', '\n')
		local price = net.ReadInt(32)

		

		if !IsValid(target) then
			net.Start("Phone:Announce")
				net.WriteString("send")
				net.WriteString( SPhone.GetLanguage("LeftCityTargetHitman") )
				net.WriteUInt(1,8)
			net.Send(ply)
			return
		end

		if target == ply then
			net.Start("Phone:Announce")
				net.WriteString("send")
				net.WriteString( SPhone.GetLanguage("ContractOnYouHitman") )
				net.WriteUInt(1,8)
			net.Send(ply)
			return
		end

		if(target:isTargetHitman()) then
			net.Start("Phone:Announce")
				net.WriteString("send")
				net.WriteString( SPhone.GetLanguage("HitmanAlreadyContract") )
				net.WriteUInt(1,8)
			net.Send(ply)
			return
		end

		if lines + 1 > SPhone.config.hitman_max_lines then
			net.Start("Phone:Announce")
				net.WriteString("send")
				net.WriteString( SPhone.GetLanguage("MaxNewline") )
				net.WriteUInt(1,12)
			net.Send(ply)
			return
		end

		if string.len(text) < SPhone.config.hitman_min_desc || string.len(text) > SPhone.config.hitman_max_desc then
			net.Start("Phone:Announce")
				net.WriteString("send")
				net.WriteString(SPhone.GetLanguage("VerifTwoHitman")..SPhone.config.hitman_min_desc..SPhone.GetLanguage("And")..SPhone.config.hitman_max_desc..SPhone.GetLanguage("CharactersHitman").." !")
				net.WriteUInt(1,8)
			net.Send(ply)
			return
		end

		if price < SPhone.config.hitman_min_offre || price > SPhone.config.hitman_max_offre then
			net.Start("Phone:Announce")
				net.WriteString("send")
				net.WriteString( SPhone.GetLanguage("VerifHitman")..DarkRP.formatMoney(SPhone.config.hitman_min_offre)..SPhone.GetLanguage("And")..DarkRP.formatMoney(SPhone.config.hitman_max_offre).." !" )
				net.WriteUInt(1,8)
			net.Send(ply)
			return
		end

		if ply:canAfford(price) then
			ply:addMoney(-price)

			local hit = {
				hit_ply = ply;
				hit_target = target,
				hit_price = price,
				hit_infos = text,
				hit_time = CurTime(),
				hit_accept = false,
				hit_hitman = nil
			}
			table.insert(SPhone.hitmans,hit)
			hook.Call("SPhoneHitmanSendContract", nil, ply, hit)

			net.Start("Phone:Announce")
				net.WriteString("send")
				net.WriteString( SPhone.GetLanguage("OfferHitman") )
				net.WriteUInt(0,32)
			net.Send(ply)
			timer.Simple(2,function()
				 SPhone.synchronisation_hitman()
				 for k,v in pairs(player.GetAll()) do
					if table.HasValue(SPhone.config.hitman_allowed,team.GetName(v:Team())) then
						net.Start("Phone:Announce")
							net.WriteString("send")
							net.WriteString( SPhone.GetLanguage("ReceiveHitman") )
							net.WriteUInt(0,12)
						net.Send(v)
					end
				end
			end)
		else
			net.Start("Phone:Announce")
				net.WriteString("send")
				net.WriteString( SPhone.GetLanguage("BMoney") )
				net.WriteUInt(1,32)
			net.Send(ply)
		end
	elseif (action == "accept") then
		if !ply:HasWeapon( "sphone" ) then return end

		if !table.HasValue(SPhone.config.hitman_allowed,team.GetName(ply:Team())) then
			net.Start("Phone:Announce")
				net.WriteString("send")
				net.WriteString( SPhone.GetLanguage("RightHitman") )
				net.WriteUInt(1,32)
			net.Send(ply)
			return
		end

		local target = net.ReadEntity()
		local time = net.ReadFloat()
		if !IsValid(target) then
			net.Start("Phone:Announce")
				net.WriteString("send")
				net.WriteString( SPhone.GetLanguage("LeftHitman") )
				net.WriteUInt(1,32)
			net.Send(ply)
			return
		end

		for k,v in pairs(SPhone.hitmans) do
			if v.hit_target == target && v.hit_time == time && v.hit_target != ply then
				if !v.hit_accept then
					v.hit_accept = true
					v.hit_hitman = ply
					
					net.Start("Phone:Announce")
						net.WriteString("send")
						net.WriteString( SPhone.GetLanguage("TakeHitman"))
						net.WriteUInt(0,8)
					net.Send(v.hit_ply)

					net.Start("Phone:Announce")
						net.WriteString("send")
						net.WriteString( SPhone.GetLanguage("CAcceptHitman")..v.hit_target:Nick().." !")
						net.WriteUInt(0,8)
					net.Send(ply)

					hook.Call("SPhoneHitmanAcceptContract", nil, ply, v)

				else
					net.Start("Phone:Announce")
						net.WriteString("send")
						net.WriteString( SPhone.GetLanguage("AcceptHitman") )
						net.WriteUInt(1,8)
					net.Send(ply)
					break
				end
			end
		end
		SPhone.synchronisation_hitman()
	end
end)

function SPhone.synchronisation_hitman()

	for k,v in pairs(player.GetAll()) do
		if table.HasValue(SPhone.config.hitman_allowed,team.GetName(v:Team())) then
			net.Start("Phone:Hitman")
				net.WriteTable(SPhone.hitmans)
			net.Send(v)
		end
	end
end

local PL = FindMetaTable("Player")

function PL:hasContrat(target)

	for k,v in pairs(SPhone.hitmans) do
		if self == v.hit_hitman then
			if v.hit_target == target then
				return true
			end
		end
	end
	return false
end

function PL:getTargetHitman()

	for k,v in pairs(SPhone.hitmans) do
		if self == v.hit_hitman then
			if v.hit_target == target then
				return target
			end
		end
	end
	return false
end

function PL:isHitmanTarget()

	for k,v in pairs(SPhone.hitmans) do
		if v.hit_target == self then
			return v.hit_hitman
		end
	end
end

function PL:isTargetHitman()

	for k,v in pairs(SPhone.hitmans) do
		if v.hit_target == self then
			return true
		end
	end
	return false
end

function PL:isContrat()

	for k,v in pairs(SPhone.hitmans) do
		if self == v.hit_hitman then
			return true
		end
	end
	return false
end

function PL:hasContratOnSelf()

	for k,v in pairs(SPhone.hitmans) do
		if self == v.hit_target then
			return true
		end
	end
	return false
end

function PL:getRewardHitman(target)

	for k,v in pairs(SPhone.hitmans) do
		if self == v.hit_hitman then
			if v.hit_target == target then
				return v.hit_price
			end
		end
	end

	return false
end

function PL:removeContrat(target)

	for k,v in pairs(SPhone.hitmans) do
		if self == v.hit_hitman then
			if v.hit_target == target then
				net.Start("Phone:Announce")
					net.WriteString("send")
					net.WriteString( SPhone.GetLanguage("SuccessHitman"))
					net.WriteUInt(0,8)
				net.Send(v.hit_ply)

				table.remove(SPhone.hitmans,k)
			end
		end
	end
	SPhone.synchronisation_hitman()
end

function PL:removeHitman(target)

	for k,v in pairs(SPhone.hitmans) do
		if self == v.hit_hitman then
			if v.hit_target == target then
				v.hit_accept = false
				v.hit_target = nil
			end
		end
	end
end

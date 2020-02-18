SPhone = SPhone or {}
SPhone.apps = SPhone.apps or {}
SPhone.apps.blackmarket = SPhone.apps.blackmarket or {}
SPhone.apps.blackmarket.delivery_coords = {}

function SPhone.apps.blackmarket.delivery(id,ply)

	local tr = ply:GetEyeTrace()
	local random_pos

	if !table.IsEmpty(SPhone.config.blackmarket_spawn) then
		random_pos = table.Random(SPhone.config.blackmarket_spawn)
	end

	local shipment = SPhone.config.blackmarket[id]
	local weapon = ents.Create("crate_delivery")
	weapon:SetDelivery(id)
	weapon:SetOwn(ply)
	weapon:SetDeliveryPos(random_pos or ply:GetPos())
	if table.IsEmpty(SPhone.config.blackmarket_spawn) then
		DarkRP.placeEntity(weapon, tr, ply)
	else
		weapon:SetPos(random_pos)
	end
	weapon:Spawn()

	if table.IsEmpty(SPhone.config.blackmarket_spawn) then return end

	net.Start("Phone:BlackMarket")
		net.WriteString("alert")
		net.WriteVector(random_pos)
	net.Send(ply)
	ply.delivery_time = CurTime() + (SPhone.config.blackmarket_delivery_cooldown*60)

	if !table.HasValue(SPhone.apps.blackmarket.delivery_coords,random_pos) then
		table.insert(SPhone.apps.blackmarket.delivery_coords,random_pos)
	end

	timer.Simple(SPhone.config.spawn_alert_time,function()
		for k,v in pairs(player.GetAll()) do
			if table.HasValue(SPhone.config.blackmarket_cops,team.GetName(v:Team())) && table.HasValue(SPhone.apps.blackmarket.delivery_coords,random_pos) then
				net.Start("Phone:BlackMarket")
					net.WriteString("alert")
					net.WriteVector(random_pos)
				net.Send(v)
			end
		end
	end)
end

hook.Add("OnPlayerChangedTeam","ChangeCopsteam",function(ply, before, after)

	if table.HasValue(SPhone.config.blackmarket_cops,team.GetName(after)) then

		for k,v in pairs(ents.FindByClass("crate_delivery")) do
			if v:GetOwn() == ply then
				table.RemoveByValue(SPhone.apps.blackmarket.delivery_coords,v:GetDeliveryPos())
				v:Remove()
			end
		end
		net.Start("Phone:BlackMarket")
			net.WriteString("alert_cops")
			net.WriteTable(SPhone.apps.blackmarket.delivery_coords)
		net.Send(ply)
	else
		net.Start("Phone:BlackMarket")
			net.WriteString("alert_cops")
			net.WriteTable({})
		net.Send(ply)
	end

end)

function SPhone.apps.blackmarket.isInBlackMarket(item)
	if SPhone.config.blackmarket[item] then
		return true
	end
	return false
end

net.Receive("Phone:BlackMarket",function(len,ply)
	local action = net.ReadString()

	if action == "buy" then
		if !ply:HasWeapon( "sphone" ) then return end
		if table.HasValue(SPhone.config.blackmarket_not_allowed,team.GetName(ply:Team())) then return end

		if ply.delivery_time && ply.delivery_time > CurTime() then
			local time_left = math.Round(ply.delivery_time - CurTime())
			net.Start("Phone:Announce")
				net.WriteString("send")
				net.WriteString(SPhone.GetLanguage("BWaitOne")..time_left.. SPhone.GetLanguage("BWaitTwo"))
				net.WriteUInt(1,8)
			net.Send(ply)
			return
		end

		local wp = net.ReadString()

		if SPhone.apps.blackmarket.isInBlackMarket(wp) then
			local price = SPhone.config.blackmarket[wp].price

			if !table.HasValue(SPhone.config.blackmarket[wp].allowed,ply:GetUserGroup()) && !table.HasValue(SPhone.config.blackmarket[wp].allowed,"*") then
				net.Start("Phone:Announce")
					net.WriteString("send")
					net.WriteString( SPhone.GetLanguage("RightRankMarket") )
					net.WriteUInt(1,8)
				net.Send(ply)
				return
			end

			if ply:canAfford(price) then
				ply:addMoney(-price)

				net.Start("Phone:Announce")
					net.WriteString("send")
					net.WriteString(SPhone.GetLanguage("BBuyMsg")..SPhone.config.blackmarket[wp].title.." !")
					net.WriteUInt(0,8)
				net.Send(ply)

				SPhone.apps.blackmarket.delivery(wp,ply)
				hook.Call("SPhoneBuyBlackMarketItem", nil, ply, price, SPhone.config.blackmarket[wp])
			else
				net.Start("Phone:Announce")
					net.WriteString("send")
					net.WriteString(SPhone.GetLanguage("BMoney"))
					net.WriteUInt(1,8)
				net.Send(ply)
			end
		end
	end

end)

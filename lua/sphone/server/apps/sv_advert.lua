SPhone.Annonces = SPhone.Annonces or {}

function SPhone.isOffre(offre)
	if !isstring(offre) then return false end
	if !SPhone.config.offres[offre] then return false end

	return true
end

function SPhone.synchronisation_announce()
	net.Start("Phone:Announce")
		net.WriteString("sync")
		net.WriteTable(SPhone.Annonces)
	net.Broadcast()
end

net.Receive("Phone:Announce",function(len,ply)
	local action = net.ReadString()

	if action == "send" then
		if !ply:HasWeapon( "sphone" ) then return end
		if ply.cooldown_announce && ply.cooldown_announce >= CurTime() then
			net.Start("Phone:Announce")
				net.WriteString("send")
				net.WriteString( SPhone.GetLanguage("BWaitOne")..math.Truncate(ply.cooldown_announce - CurTime())..SPhone.GetLanguage("WaitAdvert") )
				net.WriteUInt(1,12)
			net.Send(ply)
			return
		end

		local titre = string.Trim(net.ReadString())
		local msg = string.Trim(net.ReadString())
		local _, lines = msg:gsub('\n', '\n')
		local type_msg = net.ReadString()

		if !SPhone.isOffre(type_msg) then
			net.Start("Phone:Announce")
				net.WriteString("send")
				net.WriteString( SPhone.GetLanguage("BasicError") )
				net.WriteUInt(1,12)
			net.Send(ply)
			return
		end

		if lines + 1 > SPhone.config.advertisement_max_lines then
			net.Start("Phone:Announce")
				net.WriteString("send")
				net.WriteString( SPhone.GetLanguage("MaxNewline") )
				net.WriteUInt(1,12)
			net.Send(ply)
			return
		end

		if string.len(msg) > SPhone.config.length_max || string.len(titre) > SPhone.config.length_max_title then
			net.Start("Phone:Announce")
				net.WriteString("send")
				net.WriteString( SPhone.GetLanguage("SendErrorAdvert")..SPhone.config.length_max..SPhone.GetLanguage("SendErrorTwoAdvert")..SPhone.config.length_max_title..SPhone.GetLanguage("CharachtersHitman") )
				net.WriteUInt(1,12)
			net.Send(ply)
			return
		end

		local price = string.len(msg) * SPhone.config.offres[type_msg].price_caracter

		if ply:canAfford(price) then
				ply:addMoney(-price)

				local authormsg
				if SPhone.config.offres[type_msg].anonyme then
					authormsg = type_msg
				else
					authormsg = ply:Nick()
				end

				local msginfos = {
					title = titre,
					author = authormsg,
					text = msg,
					time = CurTime(),
				}

				hook.Call("SphoneAdvert", nil, ply, msginfos)

				table.insert(SPhone.Annonces,0,msginfos)

				if(SPhone.config.advertisement_deleteDelay != 0) then
					timer.Simple(SPhone.config.advertisement_deleteDelay, function()
						table.RemoveByValue(SPhone.Annonces, msginfos)
						SPhone.synchronisation_announce()

					end)
				end

				ply.cooldown_announce = CurTime() + SPhone.config.cooldown_announce

				net.Start("Phone:Announce")
					net.WriteString("send")
					net.WriteString( SPhone.GetLanguage("PublishAdvert") )
					net.WriteUInt(0,12)
				net.Send(ply)

				timer.Simple(2,function()
					for k,v in pairs(player.GetAll()) do
						net.Start("Phone:Announce")
							net.WriteString("send_tchat")
							if table.HasValue(SPhone.config.announce_staff_anonyme,v:GetUserGroup()) then
								net.WriteTable({Color(211, 84, 0),titre," | ",ply:Nick()," : ",Color(243, 156, 18),msg})
							else
								net.WriteTable({Color(211, 84, 0),titre," | ",authormsg," : ",Color(243, 156, 18),msg})
							end
						net.Send(v)
					end
					SPhone.synchronisation_announce()
				end)
		else
			net.Start("Phone:Announce")
				net.WriteString("send")
				net.WriteString( SPhone.GetLanguage("BMoney") )
				net.ReadUInt(1,12)
			net.Send(ply)
		end
	end
end)
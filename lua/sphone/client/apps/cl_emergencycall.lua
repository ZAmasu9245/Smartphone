SPhone.apps.call_emergency = SPhone.apps.call_emergency or {}
SPhone.apps.call_emergency.name = SPhone.GetLanguage("Emergency")
SPhone.apps.call_emergency.id = "callemergency"
SPhone.apps.call_emergency.icon = Material( "sphone/apps/emergency.png", "smooth" )
SPhone.apps.call_emergency.not_allowed = {}
SPhone.apps.call_emergency.ticket = {}

if CLIENT then

	local Emergency_Ticket_Claim = Emergency_Ticket_Claim or {}

	local function EmergencyPopup(data,emergency,curtime)

		local w = 0.175*ScrW()
		local h = 0.05*ScrW()
		local x = 0.81*ScrW()
		local y = 8 + #SPhone.apps.call_emergency.ticket * ( 5 + h )

		local popup_frame = vgui.Create("DFrame")
		popup_frame:SetPos(x,y)
		popup_frame:SetSize(w,h)
		popup_frame:SetTitle("")
		popup_frame:ShowCloseButton( False )
		popup_frame:SetDraggable( false )
		popup_frame.ply = data
		popup_frame.emergency = emergency
		popup_frame.time = curtime
		popup_frame.claim = false
		popup_frame.y = y
		function popup_frame:Paint(w,h)
			draw.RoundedBox(4, 0, 0, w, h, SPhone.Color["blueGray"])

			if self.claim then
				draw.RoundedBox(4, 0, 0.7*h, w, 0.3*h+1, SPhone.Color["orange"])
				draw.SimpleText(string.format(self.claim_player:GetName(), SPhone.GetLanguage("Respond")), "ScreenPhone20", w/2, 0.85*h, SPhone.Color["white"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		end

		local text = vgui.Create("DLabel", popup_frame)
		text:SetPos(x,0.25*h)
		text:SetSize(w,h)
		text:SetFont("ScreenPhone20Rb")
		text:SetText( string.format(SPhone.GetLanguage("EmergencyCall"), data:Nick()) )
		text:SetContentAlignment(5)
		text:SizeToContents()
		text:CenterHorizontal(0.5)

		local accept_button = vgui.Create( "DButton", popup_frame )
		accept_button:SetText("")
		accept_button.close_when_claim = true
		accept_button:SetPos(0,0.7*h)
		accept_button:SetSize(0.5*w,0.3*h+1)
		function accept_button:Paint(w,h)
			draw.RoundedBox(0, 0, 0, w, h, SPhone.Color["greenButton"])
			draw.SimpleText(SPhone.GetLanguage("AHitman"), "ScreenPhone20", w/2, h/2, SPhone.Color["white"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
		accept_button.DoClick = function()
			net.Start("SPhone:Emergency")
			net.WriteString("claim")
			net.WriteEntity(data)
			net.WriteUInt(emergency, 8)
			net.WriteFloat(curtime)
			net.SendToServer()
		end

		local refuse_button = vgui.Create( "DButton", popup_frame )
		refuse_button:SetText("")
		refuse_button.close_when_claim = true
		refuse_button:SetPos(0.5*w,0.7*h)
		refuse_button:SetSize(0.5*w,0.3*h+1)
		function refuse_button:Paint(w,h)
			draw.RoundedBox(0, 0, 0, w, h, SPhone.Color["redDenied"])
			draw.SimpleText(SPhone.GetLanguage("Deny"), "ScreenPhone20", w/2, h/2, SPhone.Color["white"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
		refuse_button.DoClick = function()
			popup_frame:MoveTo( x - 10, popup_frame.y, 0.2, 0, -1, function()
				popup_frame:MoveTo( x + w, popup_frame.y, 0.5, 0, -1, function()
					popup_frame:Close()
				end)
			end)
		end

		function popup_frame:OnRemove()
			table.RemoveByValue( SPhone.apps.call_emergency.ticket, popup_frame)

			for k,v in pairs( SPhone.apps.call_emergency.ticket ) do
				v:MoveTo( x, 8 + (k - 1) * ( 5 + h ), 0.1, 0, 1, function() end)
				popup_frame.y = 8 + (k - 1) * ( 5 + h )
			end

		end

		table.insert(SPhone.apps.call_emergency.ticket, popup_frame)
	end

	net.Receive("SPhone:Emergency", function()
		local action = net.ReadString()

		if action == "emergency_popup_add" then
			EmergencyPopup(net.ReadEntity(), net.ReadUInt(8), net.ReadFloat())
		elseif action == "emergency_popup_claim" then
			table.insert(Emergency_Ticket_Claim, net.ReadTable())

			local target = net.ReadEntity()
			local curtime = net.ReadFloat()

			for k,v in pairs( SPhone.apps.call_emergency.ticket ) do
				if v.ply == target && v.time == curtime then
					local finish_button = vgui.Create( "DButton", v )
					finish_button:SetText("")
					finish_button:SetPos(0,0.7*v:GetTall())
					finish_button:SetSize(v:GetWide(),0.3*v:GetTall()+1)
					function finish_button:Paint(w,h)
						draw.RoundedBox(0, 0, 0, w, h, SPhone.Color["greenButton"])
						draw.SimpleText(SPhone.GetLanguage("Done"), "ScreenPhone20", w/2, h/2, SPhone.Color["white"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
					end
					finish_button.DoClick = function()
						for key,val in pairs( Emergency_Ticket_Claim ) do
							if val.own == target && val.curtime == curtime then
								v:Close()
								table.remove( Emergency_Ticket_Claim, key )
								break
							end
						end
					end

				end
			end

		elseif action == "emergency_popup_sync" then

			local target = net.ReadEntity()
			local claimer = net.ReadEntity()
			local curtime = net.ReadFloat()

			for k,v in pairs( SPhone.apps.call_emergency.ticket ) do
				if v.ply == target && v.time == curtime then
					v.claim_player = claimer
					v.claim = true

					for k,v in pairs(v:GetChildren()) do
						if v.close_when_claim then
							v:Remove()
						end
					end

					timer.Simple(5, function()
						v:Close()
					end)

					break
				end
			end

		elseif action == "emergency_popup_clear" then
			for k,v in pairs( SPhone.apps.call_emergency.ticket ) do
				if IsValid(v) then v:Close() end
			end
			SPhone.apps.call_emergency.ticket = {}
			Emergency_Ticket_Claim = {}
		end
	end)

	function SPhone.apps.call_emergency.Open()

		local panel_emergency = vgui.Create("DPanel", SPhone.frame_phone)
		panel_emergency:SetPos(1.05*SPhone.frame_phone.posW ,0.375*SPhone.frame_phone.height)
		panel_emergency:SetSize(0.825*SPhone.frame_phone.withd,1.05*SPhone.frame_phone.height)
		function panel_emergency:Paint()
		end

		local scroll_emergency = vgui.Create( "DScrollPanel", panel_emergency)
		scroll_emergency:Dock( FILL )
		scroll_emergency.VBar.Paint = function( s, w, h )
		end
		scroll_emergency.VBar.btnUp.Paint = function( s, w, h )
		end
		scroll_emergency.VBar.btnDown.Paint = function( s, w, h )
		end
		scroll_emergency.VBar.btnGrip.Paint = function( s, w, h )
			draw.RoundedBox( 8, 4, -10, w - 4, h + 20, SPhone.Color["blueGrip"] )
		end

		for k,v in pairs(SPhone.config.emergency) do
			if v.jobs[team.GetName(LocalPlayer():Team())] then continue end
			if(SPhone.config.disableWhenJobNotConnected) then
				local isJobConnected = false
				for _,p in pairs(player.GetAll()) do
					if(v.jobs[team.GetName(p:Team())]) then
						isJobConnected = true
						break
					end
				end

				if !isJobConnected then return end
			end

			local panelEmergency = scroll_emergency:Add( "DPanel" )
			panelEmergency:SetSize(panel_emergency:GetWide(), 100)
			panelEmergency:Dock( TOP )
			panelEmergency:DockMargin( 0, 0, 0, 5 )
			function panelEmergency:Paint(w,h)
				draw.RoundedBox(1, 0, 0, w, h, SPhone.Color["blueGray"])
				draw.SimpleText(v.name, "ScreenPhone20Rb", 5 + h + 0.3125*w, 0.2*h, SPhone.Color["white"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end

			local iconEmergency = vgui.Create("DImage", panelEmergency)
			iconEmergency:SetPos( 5, 0.05*panelEmergency:GetTall() )
			iconEmergency:SetSize( 0.9*panelEmergency:GetTall(), 0.9*panelEmergency:GetTall() )
			iconEmergency:SetMaterial( v.icon )

			local callButton = vgui.Create( "DButton", panelEmergency )
			callButton:SetText( "" )
			callButton:SetPos( 5 + panelEmergency:GetTall(), 0.95*panelEmergency:GetTall() - 0.2*panelEmergency:GetTall() )
			callButton:SetSize( 0.625*panelEmergency:GetWide(), 0.2*panelEmergency:GetTall() )
			function callButton:Paint(w,h)
				if self:IsHovered() then
					draw.RoundedBox(1, 0, 0, w, h, SPhone.Color["blueButtonHovered2"])
				else
					draw.RoundedBox(1, 0, 0, w, h, SPhone.Color["blueButton2"])
				end
				if(v.price == 0) then
					draw.SimpleText(SPhone.GetLanguage("Call"))
					return
				end
				draw.SimpleText(SPhone.GetLanguage("Call") .. " - " .. DarkRP.formatMoney(v.price) , "ScreenPhone20", w/2, h/2, SPhone.Color["white"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
			callButton.DoClick = function()
				net.Start("SPhone:Emergency")
				net.WriteString("call")
				net.WriteUInt(k, 8)
				net.SendToServer()
			end
		end

	end


	local function closeTicket(ticket_claim)
		for k,v in pairs( SPhone.apps.call_emergency.ticket ) do
			if v.ply == ticket_claim.own && v.time == ticket_claim.curtime then
				v:Close()
				break
			end
		end
	end

	local function Point3D( target, vecPos, key_table )
		local pPlayer = LocalPlayer()
		local strName = target:Nick()
		if !pPlayer or !pPlayer:Alive() then return end
		if !strName then return end
		if !vecPos then return end

		local vecPos = vecPos + Vector( 0, 0, 2 )
		local intDist = math.Round( pPlayer:GetPos():Distance( vecPos ) *.1 )

		if !intDist then return end

		if intDist > SPhone.config.DistanceToRemovePoint then
			local head = target:GetBonePosition( target:LookupBone( "ValveBiped.Bip01_Head1" ) ):ToScreen()

			draw.SimpleTextOutlined( string.upper( strName ), "ScreenPhone20Rb", head.x, head.y - 80, SPhone.Color["white"], TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, SPhone.Color["blackAlpha3"] )
			draw.SimpleTextOutlined( SPhone.GetLanguage("Distance") .. intDist, "ScreenPhone20", head.x, head.y - 50, SPhone.Color["white"], TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, SPhone.Color["blackAlpha3"] )

		end

		if intDist <= SPhone.config.DistanceToRemovePoint then
			notification.AddLegacy( SPhone.GetLanguage("OnPos"), 0, 3 )
			closeTicket(Emergency_Ticket_Claim[key_table])
			table.remove( Emergency_Ticket_Claim, key_table )
		end
	end


	hook.Add( "HUDPaint", "SPhone:Emergency:Hud", function()

		for k,v in pairs(Emergency_Ticket_Claim) do
			if IsValid(v.player) then
				Point3D(v.player, v.player:GetPos(), k)
			else
				closeTicket(Emergency_Ticket_Claim[k])
				table.remove( Emergency_Ticket_Claim, k )
			end
		end

	end)

end

SPhone.apps.call = SPhone.apps.call or {}
SPhone.apps.call.name = SPhone.GetLanguage("Phone")
SPhone.apps.call.id = "call"
SPhone.apps.call.icon = Material( "sphone/apps/call.png", "smooth" )
SPhone.apps.call.not_allowed = {}

local errormsg,errorcolor
function SPhone.apps.call.Open()
	local dest
	local titre = SPhone.GetLanguage("Number")
	local target = vgui.Create("DTextEntry",SPhone.frame_phone)
	target:SetDrawLanguageID(false)
	target:SetPos(1.05*SPhone.frame_phone.posW ,0.475*SPhone.frame_phone.height)
	target:SetSize(0.825*SPhone.frame_phone.withd,0.1*SPhone.frame_phone.height)
	target:SetText(titre)
	target:SetFont("SphoneHitmanPrice25")
	target:SetTextColor( SPhone.Color["white"] )
	target:SetHighlightColor(SPhone.Color["blueGrip"])
	target:SetCursorColor(SPhone.Color["white"])
	target.Paint = function(s,w,h) 
		draw.RoundedBox(0, 0, 0, w, h, SPhone.Color["blueButtonDark2"])
		draw.RoundedBox(0, 0, 0, w, h, SPhone.Color["blueButton2"])

		if ( s.GetPlaceholderText && s.GetPlaceholderColor && s:GetPlaceholderText() && s:GetPlaceholderText():Trim() != "" && s:GetPlaceholderColor() && ( !s:GetText() || s:GetText() == "" ) ) then

			local oldText = s:GetText()
	
			local str = s:GetPlaceholderText()
			if ( str:StartWith( "#" ) ) then str = str:sub( 2 ) end
			str = language.GetPhrase( str )
	
			s:SetText( str )
			s:DrawTextEntryText( s:GetPlaceholderColor(), s:GetHighlightColor(), s:GetCursorColor() )
			s:SetText( oldText )
	
			return
		end
	
		s:DrawTextEntryText( s:GetTextColor(), s:GetHighlightColor(), s:GetCursorColor() )
	end
	target.OnGetFocus = function( self ) if self:GetText() == titre then self:SetText( "" ) end end
	target.OnLoseFocus = function( self ) if self:GetText() == "" then self:SetText( titre ) end end
	if dest then
		target:SetText(dest)
	end	

	local listContact = vgui.Create("DPanelList",SPhone.frame_phone)
	listContact:SetPos(1.05*SPhone.frame_phone.posW ,0.6*SPhone.frame_phone.height)
	listContact:SetSize(0.825*SPhone.frame_phone.withd,0.2*SPhone.frame_phone.height)
	listContact:EnableHorizontal(true)
	listContact:EnableVerticalScrollbar(true)
	listContact.VBar.Paint = function( s, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, SPhone.Color["transparent"])
	end
	listContact.VBar.btnUp.Paint = function( s, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, SPhone.Color["transparent"])
	end
	listContact.VBar.btnDown.Paint = function( s, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, SPhone.Color["transparent"])
	end
	listContact.VBar.btnGrip.Paint = function( s, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, SPhone.Color["blueButtonHovered1"])
	end

	for k,v in pairs(SPhone.Contacts) do
		local bntcontact = vgui.Create("DButton",listContact)
		bntcontact:SetSize(listContact:GetWide(),0.3*listContact:GetTall())
		bntcontact:SetText("")
		bntcontact.Paint = function(s,w,h)

			if dest != v.numero then
				if s:IsHovered() then
					draw.RoundedBox(0,0,0,w,h,SPhone.Color["blueButtonHovered2"])
				else
					draw.RoundedBox(0,0,0,w,h,SPhone.Color["blueButton2"])
				end
			else
				draw.RoundedBox(0,0,0,w,h,SPhone.Color["greenButton"])
			end

			if SPhone.apps.contact.isOnline(v.numero) then
				surface.SetMaterial(SPhone.Material["contact_online"])
			else
				surface.SetMaterial(SPhone.Material["contact_offline"])
			end
			surface.SetDrawColor(SPhone.Color["white"])
			surface.DrawTexturedRect(0.03*w,0.25*h,0.05*w, 0.05*w, SPhone.Color["white"])

			draw.SimpleText(v.name,"ScreenPhone17",0.1*w,h/2,SPhone.Color["white"],TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
		end
		bntcontact.DoClick = function()
			if !dest then
				dest = v.numero
				target:SetText(dest)
			else
				dest = nil
				target:SetText("")
			end
		end
		listContact:AddItem(bntcontact)
	end

	local notif = vgui.Create( "DPanel",SPhone.frame_phone)
	notif:SetPos(SPhone.frame_phone.posW ,0.825*SPhone.frame_phone.height)
	notif:SetSize(0.925*SPhone.frame_phone.withd,0.1*SPhone.frame_phone.height)
	notif.Paint = function(s,w,h)
		if errormsg then
			draw.SimpleText(errormsg,"ScreenPhone20Rb",w/2,h/2,errorcolor,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		end
	end
	notif.OnRemove = function()
		errormsg = ""
		errorcolor = nil
	end

	local buttoncall = vgui.Create("DButton",SPhone.frame_phone)
	buttoncall:SetText("")
	buttoncall:SetPos(1.05*SPhone.frame_phone.posW ,0.95*SPhone.frame_phone.height)
	buttoncall:SetSize(0.825*SPhone.frame_phone.withd,0.1*SPhone.frame_phone.height)
	buttoncall.Paint = function(s,w,h)

		if target:GetValue() == titre then
			draw.RoundedBox(0,0,0,w,h,SPhone.Color["redDenied"])
		else
			if s:IsHovered() then
				draw.RoundedBox(0,0,0,w,h,SPhone.Color["greenButtonHovered"])
			else
				draw.RoundedBox(0,0,0,w,h,SPhone.Color["greenButton"])
			end
		end
		draw.SimpleText(SPhone.GetLanguage("Call"),"ScreenPhone20Rb",w/2,h/2,SPhone.Color["white"],TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end
	buttoncall.DoClick = function()
		if target:GetValue() == titre then return end
		net.Start("Phone:Call")
			net.WriteString("call")
			net.WriteString(target:GetValue())
		net.SendToServer()
	end

end

if CLIENT then

	local sound
	net.Receive("Phone:Call",function()
		local action = net.ReadString()
		if action == "call" then
			if IsValid(SPhone.frame_phone) then
				SPhone.frame_phone:Close()
			end

			LocalPlayer().call_target = net.ReadEntity()
			LocalPlayer().reply = net.ReadBool()
			LocalPlayer().reply_target = net.ReadBool()
			if LocalPlayer().reply then
				LocalPlayer().call_time = CurTime()
			else
				sound = CreateSound(LocalPlayer(), SPhone.call_sound)
				sound:Play()
				sound:ChangeVolume(0.075)
			end
			timer.Simple(SPhone.config.call_time,function()
				if !LocalPlayer().reply_target || !LocalPlayer().reply then
					if sound then
						sound:Stop()
					end
					net.Start("Phone:Call")
						net.WriteString("hangsup")
					net.SendToServer()
					LocalPlayer().call_target = nil
					LocalPlayer().reply = nil
				end
			end)
		elseif action == "reply" then
			if sound then
				sound:Stop()
			end
			LocalPlayer().reply = net.ReadBool()
			LocalPlayer().reply_target = LocalPlayer().reply
			LocalPlayer().call_time = CurTime()
		elseif action == "hangsup" then
			if sound then
				sound:Stop()
			end
			LocalPlayer().call_target = nil
			LocalPlayer().reply = net.ReadBool()
			LocalPlayer().reply_target = LocalPlayer().reply
		elseif action == "notif" then
			errormsg = net.ReadString()
			errorcolor = net.ReadColor()

			timer.Simple(5,function()
				errormsg = ""
				errorcolor = nil
			end)
		end
	end)
end

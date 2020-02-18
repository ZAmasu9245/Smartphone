SPhone.apps.contact = SPhone.apps.contact or {}
SPhone.apps.contact.name = SPhone.GetLanguage("YContacts")
SPhone.apps.contact.id = "contacts"
SPhone.apps.contact.icon = Material( "sphone/apps/contact.png", "smooth" )
SPhone.apps.contact.not_allowed = {}

SPhone.Contacts = {}

local blur = Material("pp/blurscreen")
local function DrawBlurredRect(x, y, w, h, a, b)
	local X, Y = 0, 0
	surface.SetDrawColor(255, 255, 255, a)
	surface.SetMaterial(blur)

	for i = 1, b do
		blur:SetFloat("$blur", (i / 3) * (5))
		blur:Recompute()
		render.UpdateScreenEffectTexture()
		render.SetScissorRect(x, y, x + w, y + h, true)
		surface.DrawTexturedRect(X * -1, Y * -1, ScrW(), ScrH())
		render.SetScissorRect(0, 0, 0, 0, false)
	end
end

function SPhone.apps.contact.isOnline(num)
	for k,v in pairs(player.GetAll()) do
		if v:SteamID64() == num then
			return true
		end
	end
	return false
end

function SPhone.apps.contact.Open()
	SPhone.back = SPhone.apps.home.Open
	SPhone.current = SPhone.apps.contact.Open

	local listContacts = vgui.Create("DPanelList",SPhone.frame_phone)
	listContacts:SetPos(1.05*SPhone.frame_phone.posW ,0.4*SPhone.frame_phone.height)
	listContacts:SetSize(0.825*SPhone.frame_phone.withd,0.8*SPhone.frame_phone.height)
	listContacts:EnableHorizontal(true)
	listContacts:EnableVerticalScrollbar(true)
	listContacts.VBar.Paint = function( s, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, SPhone.Color["transparent"])
	end
	listContacts.VBar.btnUp.Paint = function( s, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, SPhone.Color["transparent"])
	end
	listContacts.VBar.btnDown.Paint = function( s, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, SPhone.Color["transparent"])
	end
	listContacts.VBar.btnGrip.Paint = function( s, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, SPhone.Color["blueButtonHovered1"])
	end

	if table.Count(SPhone.Contacts) <= 0 then 
		local errorPanel = vgui.Create("DPanel",SPhone.frame_phone)
		errorPanel:SetPos(1.05*SPhone.frame_phone.posW,0.4*SPhone.frame_phone.height)
		errorPanel:SetSize(0.825*SPhone.frame_phone.withd,0.75*SPhone.frame_phone.height)
		errorPanel.Paint = function(s,w,h)
			draw.RoundedBox(0,0,0,w,h,SPhone.Color["blackAlpha"])

			draw.SimpleText(SPhone.GetLanguage("NoContact"),"ScreenPhone20Rb",w/2,h/2,SPhone.Color["white"],TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		end
	end

	local buttonwrite = vgui.Create("DButton",SPhone.frame_phone)
	buttonwrite:SetText("")
	buttonwrite:SetPos(1.05*SPhone.frame_phone.posW ,1.225*SPhone.frame_phone.height)
	buttonwrite:SetSize(0.825*SPhone.frame_phone.withd,0.1*SPhone.frame_phone.height)
	buttonwrite.Paint = function(s,w,h)
	if s:IsHovered() then
		draw.RoundedBox(0,0,0,w,h,SPhone.Color["blueButtonHovered2"])
	else
		draw.RoundedBox(0,0,0,w,h,SPhone.Color["blueButton2"])
	end
	draw.SimpleText(SPhone.GetLanguage("AContacts"),"ScreenPhone20Rb",w/2,h/2,SPhone.Color["white"],TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end
	buttonwrite.DoClick = function()
	buttonwrite:Remove()
	listContacts:Remove()
	if IsValid(errorPanel) then
		errorPanel:Remove()
	end
	SPhone.apps.contact.addContact()
	end

	for k,v in pairs(SPhone.Contacts) do
		local bntannounce = vgui.Create("DButton",listContacts)
		bntannounce:SetSize(listContacts:GetWide(),0.1*listContacts:GetTall())
		bntannounce:SetText("")
		bntannounce.Paint = function(s,w,h)
			if s:IsHovered() then
				draw.RoundedBox(0,0,0,w,h,SPhone.Color["blueButtonHovered2"])
			else
				draw.RoundedBox(0,0,0,w,h,SPhone.Color["blueButton2"])
			end

			if SPhone.apps.contact.isOnline(v.numero) then
			surface.SetMaterial(SPhone.Material["contact_online"])
			else
			surface.SetMaterial(SPhone.Material["contact_offline"])
			end
			surface.SetDrawColor(SPhone.Color["white"])
			surface.DrawTexturedRect(0.03*w,0.35*h,0.05*w, 0.05*w, SPhone.Color["white"])

			draw.SimpleText(v.name,"ScreenPhone17",0.1*w,h/2,SPhone.Color["white"],TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
	end
	
	local bntclipboard = vgui.Create("DButton",bntannounce)
	bntclipboard:SetPos(0.7*bntannounce:GetWide(),0.3*bntannounce:GetTall())
	bntclipboard:SetSize(0.1*bntannounce:GetWide(),0.4*bntannounce:GetTall())
	bntclipboard:SetText("")
	bntclipboard.Paint = function(s,w,h)
		surface.SetMaterial(SPhone.Material["paste"])
		surface.SetDrawColor(SPhone.Color["white"])
		surface.DrawTexturedRect(0,0,h,h, SPhone.Color["white"])
	end
	bntclipboard.DoClick = function()
		SetClipboardText(v.numero)
			notification.AddLegacy(SPhone.GetLanguage("CContacts"),0,5)
	end

	if(v.numero == LocalPlayer():SteamID64()) then 
		listContacts:AddItem(bntannounce)
		continue 
	end

	bntannounce.DoClick = function()
		buttonwrite:Remove()
		listContacts:Remove()
		SPhone.apps.contact.editContact(v)
	end

	local bntsms = vgui.Create("DButton",bntannounce)
	bntsms:SetPos(0.8*bntannounce:GetWide(),0.3*bntannounce:GetTall())
	bntsms:SetSize(0.1*bntannounce:GetWide(),0.4*bntannounce:GetTall())
	bntsms:SetText("")
	bntsms.Paint = function(s,w,h)
		surface.SetMaterial(SPhone.Material["sms"])
		surface.SetDrawColor(SPhone.Color["white"])
		surface.DrawTexturedRect(0,0,h,h, SPhone.Color["white"])
	end
	bntsms.DoClick = function()
			listContacts:Remove()
			buttonwrite:Remove()
		SPhone.apps.sms.WriteSms(v.numero)
	end

	local bntremovecontact = vgui.Create("DButton",bntannounce)
	bntremovecontact:SetPos(0.9*bntannounce:GetWide(),0.3*bntannounce:GetTall())
	bntremovecontact:SetSize(0.1*bntannounce:GetWide(),0.4*bntannounce:GetTall())
	bntremovecontact:SetText("")
	bntremovecontact.Paint = function(s,w,h)
		surface.SetMaterial(SPhone.Material["delete"])
		surface.SetDrawColor(SPhone.Color["white"])
		surface.DrawTexturedRect(0,0,h,h, SPhone.Color["white"])
	end
	bntremovecontact.DoClick = function()
		bntannounce:Remove()
		net.Start("Phone:Contact")
				net.WriteString("remove")
		net.WriteString(v.numero)
		net.SendToServer()
	end

	listContacts:AddItem(bntannounce)
	end

end

SPhone.apps.contact.notif_color = Color(255,255,255)
function SPhone.apps.contact.addContact()
	SPhone.back = SPhone.apps.contact.Open
	SPhone.current = SPhone.apps.contact.addContact

	local note = SPhone.GetLanguage("Number")
	local text = vgui.Create("DTextEntry",SPhone.frame_phone)
	text:SetDrawLanguageID(false)
	text:SetPos(1.05*SPhone.frame_phone.posW ,0.6*SPhone.frame_phone.height)
	text:SetSize(0.825*SPhone.frame_phone.withd,0.1*SPhone.frame_phone.height)
	text:SetText(note)
	text:SetFont("SphoneHitmanPrice25")
	text:SetTextColor( SPhone.Color["white"] )
	text:SetHighlightColor(SPhone.Color["blueGrip"])
	text:SetCursorColor(SPhone.Color["white"])
	text.Paint = function(s,w,h) 
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
	text.OnGetFocus = function( self ) if self:GetText() == note then self:SetText( "" ) end end
	text.OnLoseFocus = function( self ) if self:GetText() == "" then self:SetText( note ) end end

	local nm = SPhone.GetLanguage("NContacts")
	local namecontact = vgui.Create("DTextEntry",SPhone.frame_phone)
	namecontact:SetDrawLanguageID(false)
	namecontact:SetPos(1.05*SPhone.frame_phone.posW ,0.725*SPhone.frame_phone.height)
	namecontact:SetSize(0.825*SPhone.frame_phone.withd,0.1*SPhone.frame_phone.height)
	namecontact:SetText(nm)
	namecontact:SetFont("SphoneHitmanPrice25")
	namecontact:SetTextColor( SPhone.Color["white"] )
	namecontact:SetHighlightColor(SPhone.Color["blueGrip"])
	namecontact:SetCursorColor(SPhone.Color["white"])
	namecontact.Paint = function(s,w,h) 
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
	namecontact.OnGetFocus = function( self ) if self:GetText() == nm then self:SetText( "" ) end end
	namecontact.OnLoseFocus = function( self ) if self:GetText() == "" then self:SetText( nm ) end end

	local contacterror = vgui.Create("DPanel",SPhone.frame_phone)
	contacterror:SetPos(1.05*SPhone.frame_phone.posW ,0.825*SPhone.frame_phone.height)
	contacterror:SetSize(0.825*SPhone.frame_phone.withd,0.1*SPhone.frame_phone.height)
	contacterror:SetText("")
	contacterror.Paint = function(s,w,h)
		if SPhone.apps.contact.error_msg then
			draw.SimpleText(SPhone.apps.contact.error_msg,"ScreenPhone20Rb",w/2,h/2,SPhone.Color["white"],TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		end
	end

	local buttonwrite = vgui.Create("DButton",SPhone.frame_phone)
	buttonwrite:SetText("")
	buttonwrite:SetPos(1.05*SPhone.frame_phone.posW ,0.925*SPhone.frame_phone.height)
	buttonwrite:SetSize(0.825*SPhone.frame_phone.withd,0.1*SPhone.frame_phone.height)
	buttonwrite.Paint = function(s,w,h)
		if text:GetValue() == note || namecontact:GetValue() == nm then
			draw.RoundedBox(0,0,0,w,h,SPhone.Color["redDenied"])
		else
			if s:IsHovered() then
				draw.RoundedBox(0,0,0,w,h,SPhone.Color["greenButtonHovered"])
			else
				draw.RoundedBox(0,0,0,w,h,SPhone.Color["greenButton"])
			end
		end
		draw.SimpleText(SPhone.GetLanguage("AddContacts"),"ScreenPhone20Rb",w/2,h/2,SPhone.Color["white"],TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end
	buttonwrite.DoClick = function()
	if text:GetValue() == note || namecontact:GetValue() == nm then return end
		net.Start("Phone:Contact")
			net.WriteString("add")
			net.WriteString(text:GetValue())
			net.WriteString(namecontact:GetValue())
		net.SendToServer()
	end
end

function SPhone.apps.contact.editContact(ct)
	SPhone.back = SPhone.apps.contact.Open
	SPhone.current = SPhone.apps.contact.editContact

	local note = SPhone.GetLanguage("Number")
	local text = vgui.Create("DTextEntry",SPhone.frame_phone)
	text:SetDrawLanguageID(false)
	text:SetPos(1.05*SPhone.frame_phone.posW ,0.6*SPhone.frame_phone.height)
	text:SetSize(0.825*SPhone.frame_phone.withd,0.1*SPhone.frame_phone.height)
	text:SetText(note)
	text:SetFont("SphoneHitmanPrice25")
	text:SetTextColor( SPhone.Color["white"] )
	text:SetHighlightColor(SPhone.Color["blueGrip"])
	text:SetCursorColor(SPhone.Color["white"])
	text.Paint = function(s,w,h) 
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
	text.OnGetFocus = function( self ) if self:GetText() == note then self:SetText( "" ) end end
	text.OnLoseFocus = function( self ) if self:GetText() == "" then self:SetText( note ) end end
	text:SetText(ct.numero)

	local nm = SPhone.GetLanguage("NContacts")
	local namecontact = vgui.Create("DTextEntry",SPhone.frame_phone)
	namecontact:SetDrawLanguageID(false)
	namecontact:SetPos(1.05*SPhone.frame_phone.posW ,0.725*SPhone.frame_phone.height)
	namecontact:SetSize(0.825*SPhone.frame_phone.withd,0.1*SPhone.frame_phone.height)
	namecontact:SetText(nm)
	namecontact:SetFont("SphoneHitmanPrice25")
	namecontact:SetTextColor( SPhone.Color["white"] )
	namecontact:SetHighlightColor(SPhone.Color["blueGrip"])
	namecontact:SetCursorColor(SPhone.Color["white"])
	namecontact.Paint = function(s,w,h) 
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
	namecontact.OnGetFocus = function( self ) if self:GetText() == nm then self:SetText( "" ) end end
	namecontact.OnLoseFocus = function( self ) if self:GetText() == "" then self:SetText( nm ) end end
	namecontact:SetText(ct.name)

	local contacterror = vgui.Create("DPanel",SPhone.frame_phone)
	contacterror:SetPos(1.05*SPhone.frame_phone.posW ,0.825*SPhone.frame_phone.height)
	contacterror:SetSize(0.825*SPhone.frame_phone.withd,0.1*SPhone.frame_phone.height)
	contacterror:SetText("")
	contacterror.Paint = function(s,w,h)
		if SPhone.apps.contact.error_msg then
			draw.SimpleText(SPhone.apps.contact.error_msg,"ScreenPhone20Rb",w/2,h/2,SPhone.Color["white"],TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		end
	end

	local buttonwrite = vgui.Create("DButton",SPhone.frame_phone)
	buttonwrite:SetText("")
	buttonwrite:SetPos(1.05*SPhone.frame_phone.posW ,0.925*SPhone.frame_phone.height)
	buttonwrite:SetSize(0.825*SPhone.frame_phone.withd,0.1*SPhone.frame_phone.height)
	buttonwrite.Paint = function(s,w,h)
	if text:GetValue() == note || namecontact:GetValue() == nm then
		draw.RoundedBox(0,0,0,w,h,SPhone.Color["redDenied"])
	else
		if s:IsHovered() then
			draw.RoundedBox(0,0,0,w,h,SPhone.Color["greenButtonHovered"])
		else
			draw.RoundedBox(0,0,0,w,h,SPhone.Color["greenButton"])
		end
	end
	draw.SimpleText(SPhone.GetLanguage("EContacts"),"ScreenPhone20Rb",w/2,h/2,SPhone.Color["white"],TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end
	buttonwrite.DoClick = function()
	if text:GetValue() == note || namecontact:GetValue() == nm then return end
	net.Start("Phone:Contact")
		net.WriteString("edit")
		net.WriteString(ct.numero)
		net.WriteString(text:GetValue())
		net.WriteString(namecontact:GetValue())
	net.SendToServer()
	end
end


net.Receive("Phone:Contact",function()
	local action = net.ReadString()

	if action == "notif" then
		SPhone.apps.contact.error_msg = net.ReadString()
		SPhone.apps.contact.notif_color = net.ReadColor()
		timer.Simple(5,function()
			SPhone.apps.contact.error_msg = ""
			SPhone.apps.contact.notif_color = nil
		end)
	elseif action == "sync" then
		SPhone.Contacts = net.ReadTable()
	end
end)

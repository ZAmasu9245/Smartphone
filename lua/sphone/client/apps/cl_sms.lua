SPhone.apps.sms = SPhone.apps.sms or {}
SPhone.apps.sms.name = "SMS"
SPhone.apps.sms.id = "sms"
SPhone.apps.sms.icon = Material( "sphone/apps/sms.png", "smooth" )
SPhone.apps.sms.not_allowed = {}

SPhone.SMS = SPhone.SMS or {}
local smsnotif = {}

local function getContact(num)
	for k,v in pairs(SPhone.Contacts) do
		if num == v.numero then
			return v.name
		end
	end
	return num
end

local function isDestinataire(player,target)

	if player == LocalPlayer():SteamID64() then
		return target
	else
		return player
	end

end

local blur = Material("pp/blurscreen")
local function DrawBlur( p, a, d )
	local x, y = p:LocalToScreen( 0, 0 )

	surface.SetDrawColor( 255, 255, 255 )
	surface.SetMaterial( blur )

	for i = 1, d do
		blur:SetFloat( "$blur", (i / d ) * ( a ) )
		blur:Recompute()

		render.UpdateScreenEffectTexture()

		surface.DrawTexturedRect( x * -1, y * -1, ScrW(), ScrH() )
	end
end

if CLIENT then
	function SPhone.apps.sms.Notif(msg,time)

		local w,h = ScrW(), ScrH()
		local x,y = 1.1*w,0.48*h

		surface.SetFont("smsfont23Rb")
		local withd,height = surface.GetTextSize(msg)
		local notif_sms = vgui.Create("DPanel")
		notif_sms:SetPos(x,y+(0.075*h)*#smsnotif)
		notif_sms:MoveTo(w-(withd+0.1*w),y+(0.075*h)*#smsnotif,0.5,0,1)
		notif_sms:SetSize(withd+0.1*w,height+0.04*h)
		notif_sms.Paint = function(s,w,h)
			DrawBlur( s, 6, 30 )
			draw.RoundedBox(0,0,0,h,h,SPhone.Color["blueGray"])

			surface.SetMaterial(SPhone.Material["sms"])
			surface.SetDrawColor(SPhone.Color["white"])
			surface.DrawTexturedRect(0.075*h,0.1*h,0.8*h,0.8*h, SPhone.Color["white"])

			draw.SimpleText(msg,"smsfont23Rb",1.1*h,h/2,SPhone.Color["white"],TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
		end
		notif_sms.OnRemove = function()
			table.RemoveByValue( smsnotif, notif_sms)

			for k,v in pairs(smsnotif) do
				v:MoveTo(w-(withd+0.1*w),y+(0.05*h)*(k-1),0.1,0,1)
			end
		end
		surface.PlaySound(SPhone.notification_sound)

		timer.Simple(time,function()
			if IsValid(notif_sms) then
				local xpos,ypos = notif_sms:GetPos()
				notif_sms:MoveTo(w+(withd+0.15*w),ypos,0.2,0,1,function()
					notif_sms:Remove()
				end)
			end
		end)

		table.insert(smsnotif,notif_sms)
	end
end

function SPhone.apps.sms.Open()
	SPhone.current = SPhone.apps.sms.Open
	SPhone.back = SPhone.apps.home.Open

	local smslist = {}
	local listSms = vgui.Create("DPanelList",SPhone.frame_phone)
	listSms:SetPos(1.05*SPhone.frame_phone.posW,0.4*SPhone.frame_phone.height)
	listSms:SetSize(0.825*SPhone.frame_phone.withd,0.8*SPhone.frame_phone.height)
	listSms:EnableHorizontal(true)
	listSms:EnableVerticalScrollbar(true)
	listSms.VBar.Paint = function( s, w, h )
	end
	listSms.VBar.btnUp.Paint = function( s, w, h )
	end
	listSms.VBar.btnDown.Paint = function( s, w, h )
	end
	listSms.VBar.btnGrip.Paint = function( s, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, SPhone.Color["blueGrip"])
	end

	local buttonwrite = vgui.Create("DButton",SPhone.frame_phone)
	buttonwrite:SetText("")
	buttonwrite:SetPos(1.05*SPhone.frame_phone.posW,1.225*SPhone.frame_phone.height)
	buttonwrite:SetSize(0.825*SPhone.frame_phone.withd,0.1*SPhone.frame_phone.height)
	buttonwrite.Paint = function(s,w,h)
		if s:IsHovered() then
			draw.RoundedBox(0,0,0,w,h,SPhone.Color["blueButtonHovered2"])
		else
			draw.RoundedBox(0,0,0,w,h,SPhone.Color["blueButton2"])
		end
		draw.SimpleText(SPhone.GetLanguage("WSMS"),"ScreenPhone20Rb",w/2,h/2,SPhone.Color["white"],TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end
	buttonwrite.DoClick = function()
		buttonwrite:Remove()
		listSms:Remove()
		SPhone.apps.sms.WriteSms()
	end

	for k,v in pairs(SPhone.SMS) do

		if !table.HasValue(smslist,v.player) || !table.HasValue(smslist,v.player) then
			local bntsms = vgui.Create("DButton",listSms)
			bntsms:SetSize(listSms:GetWide(),0.1*listSms:GetTall())
			bntsms:SetText("")
			bntsms.Paint = function(s,w,h)
				if s:IsHovered() then
					draw.RoundedBox(0,0,0,w,h,SPhone.Color["blueButtonHovered2"])
				else
					draw.RoundedBox(0,0,0,w,h,SPhone.Color["blueButton2"])
				end

				surface.SetMaterial(SPhone.Material["sms"])
				surface.SetDrawColor(SPhone.Color["white"])
				surface.DrawTexturedRect(0.03*w,0.35*h,0.05*w, 0.05*w, SPhone.Color["white"])

				if v.player != LocalPlayer():SteamID64() then
					draw.SimpleText(getContact(v.player),"ScreenPhone17",0.1*w,h/2,SPhone.Color["white"],TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
				else
					draw.SimpleText(getContact(v.target),"ScreenPhone17",0.1*w,h/2,SPhone.Color["white"],TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
				end
			end
			bntsms.DoClick = function()
				buttonwrite:Remove()
				listSms:Remove()
				SPhone.apps.sms.ReadSms(v.player,v.target)
			end
			table.insert(smslist,v.player)
			table.insert(smslist,v.target)
			listSms:AddItem(bntsms)
		end
	end

	if(table.Count(smslist) <= 0) then
		local errorPanel = vgui.Create("DPanel",listSms)
		errorPanel:SetSize(listSms:GetWide(),listSms:GetTall())
		errorPanel.Paint = function(s,w,h)
			draw.RoundedBox(0,0,0,w,h,SPhone.Color["blackAlpha"])

			draw.SimpleText(SPhone.GetLanguage("NSMS"),"ScreenPhone20Rb",w/2,h/2,SPhone.Color["white"],TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		end
		return
	end

end

local errormsg = ""
local errorcolor = Color(255,255,255)
function SPhone.apps.sms.WriteSms(dest)
	SPhone.current = SPhone.apps.sms.WriteSms
	SPhone.back = SPhone.apps.sms.Open

	local titre = SPhone.GetLanguage("Number")
	local target = vgui.Create("DTextEntry",SPhone.frame_phone)
	target:SetDrawLanguageID(false)
	target:SetPos(1.05*SPhone.frame_phone.posW,0.375*SPhone.frame_phone.height)
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
	listContact:SetPos(1.05*SPhone.frame_phone.posW,0.5*SPhone.frame_phone.height)
	listContact:SetSize(0.825*SPhone.frame_phone.withd,0.2*SPhone.frame_phone.height)
	listContact:EnableHorizontal(true)
	listContact:EnableVerticalScrollbar(true)
	listContact.VBar.Paint = function( s, w, h )
	end
	listContact.VBar.btnUp.Paint = function( s, w, h )
	end
	listContact.VBar.btnDown.Paint = function( s, w, h )
	end
	listContact.VBar.btnGrip.Paint = function( s, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, SPhone.Color["blueGrip"])
	end

	for k,v in pairs(SPhone.Contacts) do
		local bntcontact = vgui.Create("DButton",listContact)
		bntcontact:SetSize(listContact:GetWide(),0.3*listContact:GetTall())
		bntcontact:SetText("")
		bntcontact.Paint = function(s,w,h)

			if dest != v.numero then
				if s:IsHovered() then
					draw.RoundedBox(0,0,0,w,h,SPhone.Color["blueButtonHovered2Alpha"])
				else
					draw.RoundedBox(0,0,0,w,h,SPhone.Color["blackAlpha2"])
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
			surface.DrawTexturedRect(0.03*w,0.35*h,0.05*w, 0.05*w, SPhone.Color["white"])

			draw.SimpleText(v.name,"ScreenPhone17",0.1*w,h/2,SPhone.Color["white"],TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
		end
		bntcontact.DoClick = function()
			dest = v.numero
			target:SetText(dest)
		end
		listContact:AddItem(bntcontact)
	end

	local note = SPhone.GetLanguage("Message")
	local text = vgui.Create("DTextEntry",SPhone.frame_phone)
	text:SetDrawLanguageID(false)
	text:SetPos(1.05*SPhone.frame_phone.posW,0.725*SPhone.frame_phone.height)
	text:SetSize(0.825*SPhone.frame_phone.withd,0.3*SPhone.frame_phone.height)
	text:SetText(note)
	text:SetMultiline(true)
	text:SetFont("smsfont20")
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
	text.AllowInput = function( self, textvalue )
		if string.len(text:GetValue()) > SPhone.config.sms_max_length then return true end
	end

	local notif = vgui.Create( "DPanel",SPhone.frame_phone)
	notif:SetPos(SPhone.frame_phone.posW,1.075*SPhone.frame_phone.height)
	notif:SetSize(0.925*SPhone.frame_phone.withd,0.1*SPhone.frame_phone.height)
	notif.Paint = function(s,w,h)
		if errormsg then
			draw.SimpleText(errormsg,"ScreenPhone20Rb",w/2,h/2,errorcolor,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		end
	end

	local buttonwrite = vgui.Create("DButton",SPhone.frame_phone)
	buttonwrite:SetText("")
	buttonwrite:SetPos(1.05*SPhone.frame_phone.posW,1.2*SPhone.frame_phone.height)
	buttonwrite:SetSize(0.825*SPhone.frame_phone.withd,0.1*SPhone.frame_phone.height)
	buttonwrite.Paint = function(s,w,h)

		if text:GetValue() == note || target:GetValue() == titre then
			draw.RoundedBox(0,0,0,w,h,SPhone.Color["redDenied"])
		else
			if s:IsHovered() then
				draw.RoundedBox(0,0,0,w,h,SPhone.Color["greenButtonHovered"])
			else
				draw.RoundedBox(0,0,0,w,h,SPhone.Color["greenButton"])
			end
		end
		draw.SimpleText(SPhone.GetLanguage("SSMS"),"ScreenPhone20Rb",w/2,h/2,SPhone.Color["white"],TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end
	buttonwrite.DoClick = function()
		if text:GetValue() == note || target:GetValue() == titre then return end
		net.Start("Phone:SMS")
			net.WriteString(target:GetValue())
			net.WriteString(text:GetValue())
		net.SendToServer()

		if !SPhone.apps.contact.isOnline(target:GetValue()) || string.len(string.Trim(text:GetValue())) < SPhone.config.sms_min_length || target:GetValue() == LocalPlayer():SteamID64() then return end

		listContact:Remove()
		target:Remove()
		text:Remove()
		notif:Remove()
		buttonwrite:Remove()
		SPhone.apps.sms.ReadSms(LocalPlayer():SteamID64(), target:GetValue())
	end

end

local List
local player_var,target_var
function refreshSMS(tbl,list,player,target)
	for k,v in pairs(tbl) do
		if v.player == player && v.target == target || v.player == target && v.target == player then

			local smsbox = list:Add("DPanel")
			local msg = string.sub(SPhone.apps.sms.AutoLines(v.sms), 2)
			surface.SetFont("smsfont20")
			local intTextW, intTextH = surface.GetTextSize( msg )
			
			smsbox:SetSize(621, intTextH + 5)
			smsbox:Dock( TOP )

			local margin = 0.185 * ScrW()

			if(margin - intTextW < 0) then
				intTextW = margin
			end

			if v.player == LocalPlayer():SteamID64() then
				smsbox:DockMargin( margin - intTextW, 0, 0, 5 )
			else
				smsbox:DockMargin( 0, 0, margin - intTextW, 5 )
			end
			
			function smsbox:Paint(w, h)

				if v.player == LocalPlayer():SteamID64() then
					draw.RoundedBox( 8, 0, 0, w, h, SPhone.Color["blueButtonHovered2"] )
					draw.DrawText(msg, "smsfont20", 6, 2, SPhone.Color["black"])
				else
					draw.RoundedBox( 8, 0, 0, w, h, SPhone.Color["white"] )
					draw.DrawText(msg, "smsfont20", 6, 2,SPhone.Color["black"])
				end
				
			end
		end
	end
end

function SPhone.apps.sms.AutoLines(str)

	local strTbl = {}
	local buffer = ""
	local formalizedText = "";
	for i = 1, #str do
		if str[i] == "\n" then continue end
		if string.len(buffer) <= math.Truncate(ScrW() * 0.0101) then
			buffer = buffer .. str[i]
		else
			table.insert(strTbl, buffer)
			buffer = str[i]
		end
	end
	table.insert(strTbl, buffer)

	for i = 1, #strTbl do
		if strTbl[i] == "" then continue end
		formalizedText = formalizedText .. "\n" .. strTbl[i]
	end
	return formalizedText

end

local scroll
function SPhone.apps.sms.ReadSms(player,target)
	SPhone.current = SPhone.apps.sms.ReadSms
	SPhone.back = SPhone.apps.sms.Open

	local targ = isDestinataire(player,target)

	local contactsms = vgui.Create("DPanel",SPhone.frame_phone)
	contactsms:SetPos(1.05*SPhone.frame_phone.posW,0.35*SPhone.frame_phone.height)
	contactsms:SetSize(0.825*SPhone.frame_phone.withd,0.075*SPhone.frame_phone.height)
	contactsms:SetText("")
	contactsms.Paint = function(s,w,h)
		draw.RoundedBox(0,0,0,w,h,SPhone.Color["blackAlpha2"])

		if SPhone.apps.contact.isOnline(targ) then
			surface.SetMaterial(SPhone.Material["contact_online"])
		else
			surface.SetMaterial(SPhone.Material["contact_offline"])
		end
		surface.SetDrawColor(SPhone.Color["white"])
		surface.DrawTexturedRect(0.03*w,0.35*h,0.05*w, 0.05*w, SPhone.Color["white"])

		draw.SimpleText(getContact(targ),"ScreenPhone20Rb",0.1*w,h/2,SPhone.Color["white"],TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
	end

	scroll = vgui.Create( "DScrollPanel", SPhone.frame_phone)
	scroll:SetPos(1.05*SPhone.frame_phone.posW,0.45*SPhone.frame_phone.height)
	scroll:SetSize(0.825*SPhone.frame_phone.withd,0.7*SPhone.frame_phone.height)
	local sbar = scroll:GetVBar()
	function sbar:Paint( w, h )
	end
	function sbar.btnUp:Paint( w, h )
	end
	function sbar.btnDown:Paint( w, h )
	end
	sbar.btnGrip:NoClipping(true)
	function sbar.btnGrip:Paint( w, h )
		draw.RoundedBox( 8, 4, -10, w - 4, h + 20, SPhone.Color["blueGrip"] )
	end

	-- List = vgui.Create( "DIconLayout", scroll )
	-- List:SetSize(scroll:GetWide(),scroll:GetTall())
	-- List:SetSpaceY( 5 )

	player_var,target_var = player,target

	refreshSMS(SPhone.SMS,scroll,player,target)

	local note = SPhone.GetLanguage("Message")
	local text = vgui.Create("DTextEntry",SPhone.frame_phone)
	text:SetDrawLanguageID(false)
	text:SetPos(1.05*SPhone.frame_phone.posW,1.175*SPhone.frame_phone.height)
	text:SetSize(0.825*SPhone.frame_phone.withd,0.1*SPhone.frame_phone.height)
	text:SetText(note)
	text:SetMultiline(true)
	text:SetFont("smsfont20")
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
	text.AllowInput = function( self, textvalue )
		if string.len(text:GetValue()) > SPhone.config.sms_max_length then return true end
	end

	local buttonwrite = vgui.Create("DButton",SPhone.frame_phone)
	buttonwrite:SetText("")
	buttonwrite:SetPos(1.05*SPhone.frame_phone.posW,1.29*SPhone.frame_phone.height)
	buttonwrite:SetSize(0.825*SPhone.frame_phone.withd,0.075*SPhone.frame_phone.height)
	buttonwrite.Paint = function(s,w,h)

		if text:GetValue() == note || string.len(text:GetValue()) < 5 then
			draw.RoundedBox(0,0,0,w,h,SPhone.Color["redDenied"])
		else
			if s:IsHovered() then
				draw.RoundedBox(0,0,0,w,h,SPhone.Color["greenButtonHovered"])
			else
				draw.RoundedBox(0,0,0,w,h,SPhone.Color["greenButton"])
			end
		end
		draw.SimpleText(SPhone.GetLanguage("SSMS"),"ScreenPhone20Rb",w/2,h/2,SPhone.Color["white"],TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end
	buttonwrite.DoClick = function()
		if text:GetValue() == note || string.len(text:GetValue()) < 5 then return end
		net.Start("Phone:SMS")
			net.WriteString(targ)
			net.WriteString(text:GetValue())
		net.SendToServer()
		text:SetValue("")
		
	end

end

if CLIENT then
	net.Receive("Phone:SMS",function()
		local action = net.ReadString()
		if action == "notif" then
			notification.AddLegacy(net.ReadString(), net.ReadUInt(12), 5 )
		elseif action == "load" then
			local tbl = net.ReadTable()
			SPhone.SMS = tbl
			if IsValid(scroll) then
				scroll:Clear()
				refreshSMS(tbl,scroll,player_var,target_var)
			end
		elseif action == "send" then
			SPhone.apps.sms.Notif(net.ReadString(),SPhone.config.sms_time_notif)
		end
		
	end)
end

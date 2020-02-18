SPhone.apps.announce = SPhone.apps.announce or {}
SPhone.apps.announce.name = SPhone.GetLanguage("Advert")
SPhone.apps.announce.id = "advert"
SPhone.apps.announce.icon = Material( "sphone/apps/advert.png", "smooth" )
SPhone.apps.announce.not_allowed = {}

local advertMaterial = Material("sphone/advert.png", "smooth")

SPhone.apps.annonces = {}

function SPhone.apps.announce.Open()
	SPhone.current = SPhone.apps.announce.Open
	SPhone.back = SPhone.apps.home.Open

	local listAnnounce = vgui.Create("DPanelList",SPhone.frame_phone)
	listAnnounce:SetPos(1.05*SPhone.frame_phone.posW ,0.4*SPhone.frame_phone.height)
	listAnnounce:SetSize(0.825*SPhone.frame_phone.withd,0.8*SPhone.frame_phone.height)
	listAnnounce:EnableHorizontal(true)
	listAnnounce:EnableVerticalScrollbar(true)
	listAnnounce.VBar.Paint = function( s, w, h )
	end
	listAnnounce.VBar.btnUp.Paint = function( s, w, h )
	end
	listAnnounce.VBar.btnDown.Paint = function( s, w, h )
	end
	listAnnounce.VBar.btnGrip.Paint = function( s, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, SPhone.Color["blueGrip"])
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
		draw.SimpleText(SPhone.GetLanguage("WAdvert"),"ScreenPhone20Rb",w/2,h/2,SPhone.Color["white"],TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end
	buttonwrite.DoClick = function()
		buttonwrite:Remove()
		listAnnounce:Remove()
		SPhone.apps.announce.WriteMsg()
	end

	for k,v in pairs(SPhone.apps.annonces) do
		local bntannounce = vgui.Create("DButton",listAnnounce)
		bntannounce:SetSize(listAnnounce:GetWide(),0.1*listAnnounce:GetTall())
		bntannounce:SetText("")
		bntannounce.Paint = function(s,w,h)
			if s:IsHovered() then
				draw.RoundedBox(0,0,0,w,h,SPhone.Color["blueButtonHovered2"])
			else
				draw.RoundedBox(0,0,0,w,h,SPhone.Color["blueButton2"])
			end

			surface.SetMaterial(advertMaterial)
			surface.SetDrawColor(SPhone.Color["white"])
			surface.DrawTexturedRect(0.03*w,0.35*h,0.05*w, 0.05*w, SPhone.Color["white"])

			draw.SimpleText(v.title,"ScreenPhone17",0.1*w,h/2,SPhone.Color["white"],TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
		end
		bntannounce.DoClick = function()
			buttonwrite:Remove()
			listAnnounce:Remove()
			SPhone.apps.announce.ReadMsg(v)
		end
		listAnnounce:AddItem(bntannounce)
	end

	if(table.Count(SPhone.apps.annonces) <= 0) then
		local errorPanel = vgui.Create("DPanel",listAnnounce)
		errorPanel:SetSize(listAnnounce:GetWide(),listAnnounce:GetTall())
		errorPanel.Paint = function(s,w,h)
			draw.RoundedBox(0,0,0,w,h,SPhone.Color["blackAlpha"])

			draw.SimpleText(SPhone.GetLanguage("NAdvert"),"ScreenPhone20Rb",w/2,h/2,SPhone.Color["white"],TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		end
		return
	end

end

function SPhone.apps.announce.ReadMsg(msg)
	SPhone.current = SPhone.apps.announce.ReadMsg
	SPhone.back = SPhone.apps.announce.Open

	local author = vgui.Create("DPanel",SPhone.frame_phone)
	author:SetPos(1.025*SPhone.frame_phone.posW ,0.4*SPhone.frame_phone.height)
	author:SetSize(0.875*SPhone.frame_phone.withd,0.1*SPhone.frame_phone.height)
	author.Paint = function(s,w,h)
		draw.RoundedBox(0,0,0,w,h,SPhone.Color["black"])
		local time = math.Round(CurTime()-msg.time)
		local timeformat = os.date("%Mmin(s) %Ssec(s)" , time )
		if time >= 3600 then
			timeformat = os.date( "%Hh %Mmin(s) %Ssec(s)" , time )
		end
		draw.SimpleText(msg.author.." | ".. SPhone.GetLanguage("Since") ..timeformat,"ScreenPhone20Rb",w/2,h/2,SPhone.Color["white"],TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end

	local read = vgui.Create("DPanel",SPhone.frame_phone)
	read:SetPos(1.025*SPhone.frame_phone.posW ,0.525*SPhone.frame_phone.height)
	read:SetSize(0.875*SPhone.frame_phone.withd,0.3*SPhone.frame_phone.height)
	read.Paint = function(s,w,h)
		draw.RoundedBox(0,0,0,w,h,SPhone.Color["blackAlpha"])
	end

	local msgread = vgui.Create( "RichText", read )
	msgread:SetSize(read:GetWide(),read:GetTall())
	msgread:InsertColorChange( 255, 255, 224, 255 )
	msgread:AppendText( msg.text )
	function msgread:PerformLayout()
		self:SetFontInternal( "ScreenPhone18" )
	end

end

function SPhone.apps.announce.WriteMsg()
	SPhone.current = SPhone.apps.announce.WriteMsg
	SPhone.back = SPhone.apps.announce.Open

	local titre = SPhone.GetLanguage("Title")
	local titre_msg = vgui.Create("DTextEntry",SPhone.frame_phone)
	titre_msg:SetDrawLanguageID(false)
	titre_msg:SetPos(1.05*SPhone.frame_phone.posW ,0.475*SPhone.frame_phone.height)
	titre_msg:SetSize(0.825*SPhone.frame_phone.withd,0.1*SPhone.frame_phone.height)
	titre_msg:SetText(titre)
	titre_msg:SetFont("SphoneHitmanPrice25")
	titre_msg.OnGetFocus = function( self ) if self:GetText() == titre then self:SetText( "" ) end end
	titre_msg.OnLoseFocus = function( self ) if self:GetText() == "" then self:SetText( titre ) end end
	titre_msg:SetTextColor( SPhone.Color["white"] )
	titre_msg:SetHighlightColor(SPhone.Color["blueGrip"])
	titre_msg:SetCursorColor(SPhone.Color["white"])
	titre_msg.Paint = function(s,w,h) 
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
	titre_msg.AllowInput = function( self, textvalue )
		if string.len(titre_msg:GetValue()) > SPhone.config.length_max_title then return true end
	end

	local note = SPhone.GetLanguage("Message")
	local text = vgui.Create("DTextEntry",SPhone.frame_phone)
	text:SetDrawLanguageID(false)
	text:SetPos(1.05*SPhone.frame_phone.posW ,0.6*SPhone.frame_phone.height)
	text:SetSize(0.825*SPhone.frame_phone.withd,0.3*SPhone.frame_phone.height)
	text:SetMultiline( true )
	text:SetText(note)
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
		if string.len(text:GetValue()) > SPhone.config.length_max then return true end
	end

	local typeannounce = vgui.Create( "DComboBox",SPhone.frame_phone)
	typeannounce:SetPos(1.25*SPhone.frame_phone.posW ,0.925*SPhone.frame_phone.height)
	typeannounce:SetSize(0.4*SPhone.frame_phone.withd,0.075*SPhone.frame_phone.height)
	typeannounce:SetFont("smsfont20")
	typeannounce:SetTextColor(SPhone.Color["white"])
	for k,v in pairs(SPhone.config.offres) do
		if v.default then
			typeannounce:SetValue( k )
		end
		typeannounce:AddChoice( k )
	end
	typeannounce.Paint = function(s,w,h)
		if s:IsHovered() or s:IsMenuOpen() then
			draw.RoundedBox(0,0,0,w,h,SPhone.Color["blueButtonHovered2"])
		else
			draw.RoundedBox(0,0,0,w,h,SPhone.Color["blueButton2"])
		end

		if IsValid(s.Menu) then
			s.Menu.Paint = function(s,w,h)
				draw.RoundedBox(0,0,0,w,h,SPhone.Color["blueButton2"])
			end

			s.Menu.VBar.Paint = function( s, w, h )
			end
			s.Menu.VBar.btnUp.Paint = function( s, w, h )
			end
			s.Menu.VBar.btnDown.Paint = function( s, w, h )
			end
			s.Menu.VBar.btnGrip.Paint = function( s, w, h )
				draw.RoundedBox( 8, 4, -10, w - 4, h + 20, SPhone.Color["blueGrip"] )
			end

			for _,v in pairs(s.Menu:GetCanvas():GetChildren()) do
				v:SetTextColor(SPhone.Color["white"])
				v.Paint = function(s, w, h)
					if s:IsHovered() then
						draw.RoundedBox(0,0,0,w,h,SPhone.Color["blueButtonHovered2"])
					else
						draw.RoundedBox(0,0,0,w,h,SPhone.Color["blueButton2"])
					end
				end
			end

		end
	end

	local price_total = string.len(text:GetValue())
	local buttonwrite = vgui.Create("DButton",SPhone.frame_phone)
	buttonwrite:SetText("")
	buttonwrite:SetPos(1.05*SPhone.frame_phone.posW ,1.1*SPhone.frame_phone.height)
	buttonwrite:SetSize(0.825*SPhone.frame_phone.withd,0.1*SPhone.frame_phone.height)
	buttonwrite.Paint = function(s,w,h)
		if SPhone.config.offres[typeannounce:GetValue()] then
			price_total = string.len(text:GetValue())*SPhone.config.offres[typeannounce:GetValue()].price_caracter
		else
			price_total = string.len(text:GetValue())
		end
		if text:GetValue() == note || typeannounce:GetValue() == "Type Advert" || titre_msg:GetValue() == titre then
			draw.RoundedBox(0,0,0,w,h,SPhone.Color["redDenied"])
		else
			if s:IsHovered() then
				draw.RoundedBox(0,0,0,w,h,SPhone.Color["greenButtonHovered"])
			else
				draw.RoundedBox(0,0,0,w,h,SPhone.Color["greenButton"])
			end
		end
		draw.SimpleText(SPhone.GetLanguage("PAdvert").. DarkRP.formatMoney(price_total) ,"ScreenPhone20Rb",w/2,h/2,SPhone.Color["white"],TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end
	buttonwrite.DoClick = function()
		if text:GetValue() == note || typeannounce:GetValue() == "Type Advert" || titre_msg:GetValue() == titre then return end
		net.Start("Phone:Announce")
			net.WriteString("send")
			net.WriteString(titre_msg:GetValue())
			net.WriteString(text:GetValue())
			net.WriteString(typeannounce:GetValue())
		net.SendToServer()
		titre_msg:Remove()
		text:Remove()
		typeannounce:Remove()
		buttonwrite:Remove()
		SPhone.apps.announce.Open()
	end

end

if CLIENT then
	net.Receive("Phone:Announce",function()
		local action = net.ReadString()
		if action == "send" then
			notification.AddLegacy( net.ReadString(), net.ReadUInt(8), 5 )
		elseif action == "send_tchat" then
			local msg = net.ReadTable()
			chat.AddText(unpack(msg))
		elseif action == "sync" then
			SPhone.apps.annonces = net.ReadTable()
		end
	end)
end

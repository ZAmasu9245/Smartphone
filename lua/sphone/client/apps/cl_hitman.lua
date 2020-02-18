SPhone.apps = SPhone.apps or {}
SPhone.apps.hitman = SPhone.apps.hitman or {}
SPhone.apps.hitman.name = SPhone.GetLanguage("Hitman")
SPhone.apps.hitman.id = "hitman"
SPhone.apps.hitman.icon = Material( "sphone/apps/hitman.png", "smooth" )

local Hitmans = Hitmans or {}

local function FindPlayerName(name)
	for k,v in pairs(player.GetAll()) do
		if string.lower(name) == string.lower(v:Nick()) then return v end
	end
end

function SPhone.apps.hitman.Open()
	SPhone.current = SPhone.apps.hitman.Open
	SPhone.back = SPhone.apps.home.Open

	if(table.HasValue(SPhone.config.hitman_allowed, team.GetName(LocalPlayer():Team()))) then
		SPhone.apps.hitman.ListHitman()
	else 
		SPhone.apps.hitman.WriteHitman()
	end
end

function SPhone.apps.hitman.ListHitman()
	SPhone.back = SPhone.apps.hitman.Open
	SPhone.current = SPhone.apps.hitman.ListHitman

	if table.Count(Hitmans) <= 0 then 
		local errorPanel = vgui.Create("DPanel",SPhone.frame_phone)
		errorPanel:SetPos(1.05*SPhone.frame_phone.posW,0.4*SPhone.frame_phone.height)
		errorPanel:SetSize(0.825*SPhone.frame_phone.withd,1*SPhone.frame_phone.height)
		errorPanel.Paint = function(s,w,h)
			draw.RoundedBox(0,0,0,w,h,SPhone.Color["blackAlpha"])

			draw.SimpleText(SPhone.GetLanguage("NContract"),"ScreenPhone20Rb",w/2,h/2,SPhone.Color["white"],TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		end
		return
	end

	local listHitman = vgui.Create("DPanelList",SPhone.frame_phone)
	listHitman:SetPos(1.05*SPhone.frame_phone.posW ,0.4*SPhone.frame_phone.height)
	listHitman:SetSize(0.825*SPhone.frame_phone.withd,0.8*SPhone.frame_phone.height)
	listHitman:EnableHorizontal(true)
	listHitman:EnableVerticalScrollbar(true)
	listHitman.VBar.Paint = function( s, w, h )
	end
	listHitman.VBar.btnUp.Paint = function( s, w, h )
	end
	listHitman.VBar.btnDown.Paint = function( s, w, h )
	end
	listHitman.VBar.btnGrip.Paint = function( s, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, SPhone.Color["blueGrip"])
	end

	for k,v in pairs(Hitmans) do
		if IsValid(v.hit_target) && v.hit_target != LocalPlayer() then
			local bnthitman = vgui.Create("DButton",listHitman)
			bnthitman:SetSize(listHitman:GetWide(),0.1*listHitman:GetTall())
			bnthitman:SetText("")
			bnthitman.Paint = function(s,w,h)

				if v.hit_hitman == LocalPlayer() then
					draw.RoundedBox(0,0,0,w,h,SPhone.Color["greenButtonHovered"])
				else
					if s:IsHovered() then
						draw.RoundedBox(0,0,0,w,h,SPhone.Color["blueButtonHovered2"])
					else
						draw.RoundedBox(0,0,0,w,h,SPhone.Color["blueButton2"])
					end
				end

				surface.SetMaterial(SPhone.Material["contract"])
				surface.SetDrawColor(SPhone.Color["white"])
				surface.DrawTexturedRect(0.03*w,0.35*h,0.05*w, 0.05*w, SPhone.Color["white"])
				local time = math.Round(CurTime()-v.hit_time)
				local timeformat = os.date("%Mmin(s) %Ssec(s)" , time )
				if time >= 3600 then
					timeformat = os.date( "%Hh %Mmin(s) %Ssec(s)" , time )
				end
				draw.SimpleText(v.hit_target:Nick().." | "..DarkRP.formatMoney(v.hit_price).." | "..timeformat,"ScreenPhone17",0.1*w,h/2,SPhone.Color["white"],TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
			end
			bnthitman.DoClick = function()
				bnthitman:Remove()
				listHitman:Remove()
				SPhone.apps.hitman.ReadMsg(v)
			end
			listHitman:AddItem(bnthitman)
		end
	end
end

function SPhone.apps.hitman.ReadMsg(hit)
	SPhone.current = SPhone.apps.hitman.ReadMsg
	SPhone.back = SPhone.apps.hitman.ListHitman

	local name = hit.hit_target:Nick()
	local model = hit.hit_target:GetModel()
	local author = vgui.Create("DPanel",SPhone.frame_phone)
	author:SetPos(1.025*SPhone.frame_phone.posW ,0.35*SPhone.frame_phone.height)
	author:SetSize(0.875*SPhone.frame_phone.withd,0.1*SPhone.frame_phone.height)
	author.Paint = function(s,w,h)
		draw.RoundedBox(0,0,0,w,h,SPhone.Color["blackAlpha2"])
		if !IsValid(hit.hit_target) then
			draw.SimpleText(SPhone.GetLanguage("NHitman").. ":" ..name.." ("..SPhone.GetLanguage("DHitman")..") | "..SPhone.GetLanguage("RHitman")..DarkRP.formatMoney(hit.hit_price),"ScreenPhone18",w/2,h/2,SPhone.Color["white"],TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		else
			draw.SimpleText(SPhone.GetLanguage("NHitman").. ":" ..name.." | "..SPhone.GetLanguage("RHitman")..DarkRP.formatMoney(hit.hit_price),"ScreenPhone18",w/2,h/2,SPhone.Color["white"],TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		end
	end

	local read = vgui.Create("DPanel",SPhone.frame_phone)
	read:SetPos(1.025*SPhone.frame_phone.posW ,0.465*SPhone.frame_phone.height)
	read:SetSize(0.875*SPhone.frame_phone.withd,0.3*SPhone.frame_phone.height)
	read.Paint = function(s,w,h)
		draw.RoundedBox(0,0,0,w,h,SPhone.Color["blackAlpha2"])
	end

	local msgread = vgui.Create( "RichText", read )
	msgread:SetSize(read:GetWide(),read:GetTall())
	msgread:InsertColorChange( 255, 255, 224, 255 )
	msgread:AppendText( hit.hit_infos )
	function msgread:PerformLayout()
		self:SetFontInternal( "smsfont20" )
	end

	local modeltarget = vgui.Create( "DModelPanel",SPhone.frame_phone)
	modeltarget:SetPos(1.275*SPhone.frame_phone.posW ,0.8*SPhone.frame_phone.height)
	modeltarget:SetSize(0.4*SPhone.frame_phone.withd,0.2*SPhone.frame_phone.height)
	modeltarget:SetModel( model )

	local min, max = modeltarget.Entity:GetRenderBounds()
	modeltarget:SetCamPos( Vector( 0.55, 0.55, 0.55 ) * min:Distance( max ) )
	modeltarget:SetLookAt( ( min + max ) / 2 )
	function modeltarget:LayoutEntity( Entity ) return end -- disables default rotation
	modeltarget:SetLookAt( Vector(0,0,60) )
	modeltarget:SetCamPos( Vector(30,0,60) )
	modeltarget.Entity:SetSkin( hit.hit_target:GetSkin() )

	local curgroups = hit.hit_target:GetBodyGroups()

	for k,v in pairs( curgroups ) do
		local ent = modeltarget.Entity
		local cur_bgid = hit.hit_target:GetBodygroup( v.id )
		ent:SetBodygroup( v.id, cur_bgid )
	end

	local buttonaccept = vgui.Create("DButton",SPhone.frame_phone)
	buttonaccept:SetText("")
	buttonaccept:SetPos(1.05*SPhone.frame_phone.posW ,1.05*SPhone.frame_phone.height)
	buttonaccept:SetSize(0.825*SPhone.frame_phone.withd,0.1*SPhone.frame_phone.height)
	buttonaccept.Paint = function(s,w,h)
		if s:IsHovered() then
			draw.RoundedBox(0,0,0,w,h,SPhone.Color["greenButtonHovered"])
		else
			draw.RoundedBox(0,0,0,w,h,SPhone.Color["greenButton"])
		end
		draw.SimpleText(SPhone.GetLanguage("AHitman"),"ScreenPhone20Rb",w/2,h/2,SPhone.Color["white"],TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end
	buttonaccept.DoClick = function()
		net.Start("Phone:Hitman")
			net.WriteString("accept")
			net.WriteEntity(hit.hit_target)
			net.WriteFloat(hit.hit_time)
		net.SendToServer()
		author:Remove()
		read:Remove()
		modeltarget:Remove()
		buttonaccept:Remove()
		SPhone.apps.home.Open()
	end
end

function SPhone.apps.hitman.WriteHitman()
	local target
	SPhone.back = SPhone.apps.hitman.Open
	SPhone.current = SPhone.apps.hitman.WriteHitman

	if player.GetCount() <= 2 then 
		local errorPanel = vgui.Create("DPanel",SPhone.frame_phone)
		errorPanel:SetPos(1.05*SPhone.frame_phone.posW,0.4*SPhone.frame_phone.height)
		errorPanel:SetSize(0.825*SPhone.frame_phone.withd,1*SPhone.frame_phone.height)
		errorPanel.Paint = function(s,w,h)
			draw.RoundedBox(0,0,0,w,h,SPhone.Color["blackAlpha"])

			draw.SimpleText(SPhone.GetLanguage("NPlayer"),"ScreenPhone20Rb",w/2,h/2,SPhone.Color["white"],TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		end
		return
	end

	if table.HasValue(SPhone.config.hitman_not_allowed, team.GetName(LocalPlayer():Team())) then 
		local errorPanel = vgui.Create("DPanel",SPhone.frame_phone)
		errorPanel:SetPos(1.05*SPhone.frame_phone.posW,0.4*SPhone.frame_phone.height)
		errorPanel:SetSize(0.825*SPhone.frame_phone.withd,1*SPhone.frame_phone.height)
		errorPanel.Paint = function(s,w,h)
			draw.RoundedBox(0,0,0,w,h,SPhone.Color["blackAlpha"])

			draw.SimpleText(SPhone.GetLanguage("NotAllowed"),"ScreenPhone20Rb",w/2,h/2,SPhone.Color["white"],TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		end
		return
	end

	if SPhone.config.hitman_musthitman then 
        for _, v in pairs(player.GetAll()) do
            if table.HasValue(SPhone.config.hitman_allowed, team.GetName(v:Team())) then
                return
            end
        end

        local errorPanel = vgui.Create("DPanel",SPhone.frame_phone)
        errorPanel:SetPos(1.05*SPhone.frame_phone.posW,0.4*SPhone.frame_phone.height)
        errorPanel:SetSize(0.825*SPhone.frame_phone.withd,1*SPhone.frame_phone.height)
        errorPanel.Paint = function(s,w,h)
            draw.RoundedBox(0,0,0,w,h,SPhone.Color["blackAlpha"])

            draw.SimpleText(SPhone.GetLanguage("NotAllowed"),"ScreenPhone20Rb",w/2,h/2,SPhone.Color["white"],TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        end
        return
    end

	local modeltarget = vgui.Create( "DModelPanel",SPhone.frame_phone)
	modeltarget:SetPos(1.25*SPhone.frame_phone.posW ,0.475*SPhone.frame_phone.height)
	modeltarget:SetSize(0.4*SPhone.frame_phone.withd,0.2*SPhone.frame_phone.height)

	modeltarget:SetLookAt( Vector(0,0,60) )
	modeltarget:SetCamPos( Vector(30,0,60) )

	modeltarget:SetModel( LocalPlayer():GetModel() )
	function modeltarget:LayoutEntity( Entity ) return end
	modeltarget.Entity:SetSkin( LocalPlayer():GetSkin() )

	local curgroups = LocalPlayer():GetBodyGroups()

	for k,v in pairs( curgroups ) do
		local ent = modeltarget.Entity
		local cur_bgid = LocalPlayer():GetBodygroup( v.id )
		ent:SetBodygroup( v.id, cur_bgid )
	end

	local targetSelector = vgui.Create( "DComboBox",SPhone.frame_phone)
	targetSelector:SetPos(1.25*SPhone.frame_phone.posW ,0.375*SPhone.frame_phone.height)
	targetSelector:SetSize(0.4*SPhone.frame_phone.withd,0.075*SPhone.frame_phone.height)
	targetSelector:SetFont("smsfont20")
	targetSelector:SetTextColor(SPhone.Color["white"])
	targetSelector:SetValue( SPhone.GetLanguage("NHitman") )
	for k,v in pairs(player.GetAll()) do
		if v != LocalPlayer() then
			targetSelector:AddChoice( v:Nick() )
		end
	end
	targetSelector.OnSelect = function( panel, index, value )
		 target = FindPlayerName(value)
		 modeltarget:SetModel( target:GetModel() )

		 modeltarget.Entity:SetSkin( target:GetSkin() )
		 local curgroups = target:GetBodyGroups()

	 	for k,v in pairs( curgroups ) do
	 		local ent = modeltarget.Entity
	 		local cur_bgid = target:GetBodygroup( v.id )
	 		ent:SetBodygroup( v.id, cur_bgid )
	 	end
	end
	targetSelector.Paint = function(s,w,h)
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

	local note = SPhone.GetLanguage("IHitman")
	local text = vgui.Create("DTextEntry",SPhone.frame_phone)
	text:SetDrawLanguageID(false)
	text:SetPos(1.05*SPhone.frame_phone.posW ,0.7*SPhone.frame_phone.height)
	text:SetSize(0.825*SPhone.frame_phone.withd,0.3*SPhone.frame_phone.height)
	text:SetMultiline( true )
	text:SetText(note)
	text:SetFont("smsfont20")
	text:SetTextColor( SPhone.Color["white"] )
	text:SetHighlightColor(SPhone.Color["blueGrip"])
	text:SetCursorColor(SPhone.Color["white"])
	text.Paint = function(s,w,h) 
		draw.RoundedBox(0, 0, 0, w, h, SPhone.Color["blueButtonDark2"])
		draw.RoundedBox(0, 1, 1, w - 2, h - 2, SPhone.Color["blueButton2"])

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
		if string.len(text:GetValue()) > SPhone.config.hitman_max_desc then return true end
	end

	local priceText = vgui.Create("DTextEntry",SPhone.frame_phone)
	priceText:SetDrawLanguageID(false)
	priceText:SetPos(1.34*SPhone.frame_phone.posW ,1.025*SPhone.frame_phone.height)
	priceText:SetSize(0.24*SPhone.frame_phone.withd,0.06*SPhone.frame_phone.height)
	priceText:SetMultiline( true )
	priceText:SetText(SPhone.GetLanguage("PHitman"))
	priceText:SetFont("SphoneHitmanPrice25")
	priceText:SetTextColor( SPhone.Color["white"] )
	priceText:SetHighlightColor(SPhone.Color["blueGrip"])
	priceText:SetCursorColor(SPhone.Color["white"])
	priceText.Paint = function(s,w,h) 
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
	priceText.OnGetFocus = function( self ) if self:GetText() == SPhone.GetLanguage("PHitman") then self:SetText( "" ) end end
	priceText.OnLoseFocus = function( self ) if self:GetText() == "" then self:SetText( SPhone.GetLanguage("PHitman") ) end end
	priceText.AllowInput = function( self, textvalue )
		if tonumber(textvalue) == nil then return true
		elseif tonumber(priceText:GetText()) == nil then return false
		elseif tonumber(priceText:GetText() .. textvalue) > SPhone.config.hitman_max_offre then priceText:SetText(SPhone.config.hitman_max_offre) return true end
	end

	local buttonwrite = vgui.Create("DButton",SPhone.frame_phone)
	buttonwrite:SetText("")
	buttonwrite:SetPos(1.05*SPhone.frame_phone.posW ,1.1*SPhone.frame_phone.height)
	buttonwrite:SetSize(0.825*SPhone.frame_phone.withd,0.1*SPhone.frame_phone.height)
	buttonwrite.Paint = function(s,w,h)
		if text:GetValue() == note || targetSelector:GetValue() == SPhone.GetLanguage("NHitman") || tonumber(priceText:GetText()) == nil || string.len(text:GetValue()) < SPhone.config.hitman_min_desc then
			draw.RoundedBox(0,0,0,w,h,SPhone.Color["redDenied"])
		else
			if s:IsHovered() then
				draw.RoundedBox(0,0,0,w,h,SPhone.Color["greenButtonHovered"])
			else
				draw.RoundedBox(0,0,0,w,h,SPhone.Color["greenButton"])
			end
		end
		draw.SimpleText(SPhone.GetLanguage("PutHitman"),"ScreenPhone20Rb",w/2,h/2,SPhone.Color["white"],TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end
	buttonwrite.DoClick = function()
		if text:GetValue() == note || targetSelector:GetValue() == SPhone.GetLanguage("NHitman") || tonumber(priceText:GetText()) == nil || string.len(text:GetValue()) < SPhone.config.hitman_min_desc then return end
		net.Start("Phone:Hitman")
			net.WriteString("send")
			net.WriteEntity(target)
			net.WriteString(text:GetValue())
			net.WriteInt(tonumber(priceText:GetText()),32)
		net.SendToServer()
		targetSelector:Remove()
		text:Remove()
		buttonwrite:Remove()
		modeltarget:Remove()
		priceText:Remove()
		SPhone.apps.home.Open()
	end
end

net.Receive("Phone:Hitman",function()
	local tblhit = net.ReadTable()
	Hitmans = tblhit
end)

SPhone.apps.market = SPhone.apps.market or {}
SPhone.apps.market.name = SPhone.GetLanguage("Market")
SPhone.apps.market.id = "market"
SPhone.apps.market.icon = Material( "sphone/apps/market.png", "smooth" )
SPhone.apps.market.not_allowed = {}

SPhone.soundPhone = nil
SPhone.background_preview = nil
SPhone.sound_preview = nil
local function getItemTitle(title)
	for k,v in pairs(SPhone.config.market) do
		if v.title == title then
			return k
		end
	end
end

local function hasItem(id)
	for k,v in pairs(SPhone.items) do
		if v.item == id then
			return true
		end
	end
	return false
end

local function getLanguage(type_item)
	if type_item == "background" then
		return SPhone.GetLanguage("Background")
	elseif type_item == "notification" then
		return SPhone.GetLanguage("Notif")
	elseif type_item == "call_sound" then
		return SPhone.GetLanguage("Ringtone")
	end
	return ""
end

local function isAllowed(id)
	if !table.HasValue(SPhone.config.market[id].allowed,"*") then
		return SPhone.Material["vip"]
	end
	return nil
end

function SPhone.apps.market.Open()
	SPhone.current = SPhone.apps.market.Open
	SPhone.back = SPhone.apps.home.Open

	local target
	local button_background = vgui.Create("DButton",SPhone.frame_phone)
	button_background:SetText("")
	button_background:SetPos(1.05*SPhone.frame_phone.posW ,0.4*SPhone.frame_phone.height)
	button_background:SetSize(0.825*SPhone.frame_phone.withd,0.1*SPhone.frame_phone.height)
	button_background.Paint = function(s,w,h)
		if s:IsHovered() then
			draw.RoundedBox(0,0,0,w,h,SPhone.Color["blueButtonHovered2"])
		else
			draw.RoundedBox(0,0,0,w,h,SPhone.Color["blueButton2"])
		end
		draw.SimpleText(SPhone.GetLanguage("Background"),"ScreenPhone20Rb",w/2,h/2,SPhone.Color["white"],TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end

	local button_notif = vgui.Create("DButton",SPhone.frame_phone)
	button_notif:SetText("")
	button_notif:SetPos(1.05*SPhone.frame_phone.posW ,0.55*SPhone.frame_phone.height)
	button_notif:SetSize(0.825*SPhone.frame_phone.withd,0.1*SPhone.frame_phone.height)
	button_notif.Paint = function(s,w,h)
		if s:IsHovered() then
			draw.RoundedBox(0,0,0,w,h,SPhone.Color["blueButtonHovered2"])
		else
			draw.RoundedBox(0,0,0,w,h,SPhone.Color["blueButton2"])
		end
		draw.SimpleText(SPhone.GetLanguage("Notif"),"ScreenPhone20Rb",w/2,h/2,SPhone.Color["white"],TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end

	local button_callnotif = vgui.Create("DButton",SPhone.frame_phone)
	button_callnotif:SetText("")
	button_callnotif:SetPos(1.05*SPhone.frame_phone.posW ,0.7*SPhone.frame_phone.height)
	button_callnotif:SetSize(0.825*SPhone.frame_phone.withd,0.1*SPhone.frame_phone.height)
	button_callnotif.Paint = function(s,w,h)
		if s:IsHovered() then
			draw.RoundedBox(0,0,0,w,h,SPhone.Color["blueButtonHovered2"])
		else
			draw.RoundedBox(0,0,0,w,h,SPhone.Color["blueButton2"])
		end
		draw.SimpleText(SPhone.GetLanguage("Ringtone"),"ScreenPhone20Rb",w/2,h/2,SPhone.Color["white"],TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end
	button_callnotif.DoClick = function()
		button_callnotif:Remove()
		button_background:Remove()
		button_notif:Remove()
		SPhone.apps.market.Market("call_sound")
	end

	button_notif.DoClick = function()
		button_callnotif:Remove()
		button_background:Remove()
		button_notif:Remove()
		SPhone.apps.market.Market("notification")
	end

	button_background.DoClick = function()
		button_callnotif:Remove()
		button_background:Remove()
		button_notif:Remove()
		SPhone.apps.market.Market("background")
	end
end

function SPhone.apps.market.Market(cat)
	local target
	SPhone.current = SPhone.apps.market.Market
	SPhone.back = SPhone.apps.market.Open

	local titlecat = vgui.Create("DPanel", SPhone.frame_phone)
	titlecat:SetPos(1.05*SPhone.frame_phone.posW ,0.4*SPhone.frame_phone.height)
	titlecat:SetSize(0.825*SPhone.frame_phone.withd,0.075*SPhone.frame_phone.height)
	titlecat:SetText("")
	titlecat.Paint = function(s,w,h)
		draw.RoundedBox(0,0,0,w,h,SPhone.Color["blackAlpha"])

		draw.SimpleText(getLanguage(cat),"ScreenPhone20Rb",w/2,h/2,SPhone.Color["white"],TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end

	local scroll = vgui.Create( "DScrollPanel", SPhone.frame_phone)
	scroll:SetPos(1.05*SPhone.frame_phone.posW ,0.5*SPhone.frame_phone.height)
	scroll:SetSize(0.825*SPhone.frame_phone.withd,0.6*SPhone.frame_phone.height)
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

	List = vgui.Create( "DIconLayout", scroll )
	List:SetSize(scroll:GetWide(),scroll:GetTall())
	List:SetSpaceY( 5 )

	for k,v in pairs(SPhone.config.market) do
		if v.type_item == cat then
			local buttonitem = vgui.Create("DButton",List)
			buttonitem:SetText("")
			buttonitem:SetSize(List:GetWide(),0.15*List:GetTall())
			buttonitem.item_market = k
			buttonitem.Paint = function(s,w,h)
				if target != s then
					if s:IsHovered() then
						draw.RoundedBox(0,0,0,w,h,SPhone.Color["blueButtonHovered2"])
					else
						draw.RoundedBox(0,0,0,w,h,SPhone.Color["blueButton2"])
					end
				else
					draw.RoundedBox(0,0,0,w,h,SPhone.Color["aqua"])
				end

				if !hasItem(k) then
					draw.SimpleText(v.title.." : "..DarkRP.formatMoney(v.price),"smsfont20",0.05*w,h/2,SPhone.Color["white"],TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)

					if isAllowed(k) then
						surface.SetMaterial(isAllowed(k))
						surface.SetDrawColor(SPhone.Color["white"])
						surface.DrawTexturedRect(0.85*w,0.2*h,0.6*h, 0.6*h, SPhone.Color["white"])
					end

				else
					surface.SetMaterial(SPhone.Material["check"])
					surface.SetDrawColor(SPhone.Color["white"])
					surface.DrawTexturedRect(0.85*w,0.2*h,0.6*h, 0.6*h, SPhone.Color["white"])

					draw.SimpleText(v.title,"smsfont20",0.05*w,h/2,SPhone.Color["white"],TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
				end
			end
			buttonitem.DoClick = function()
				target = buttonitem
				SPhone.background_preview = nil
				SPhone.sound_preview = nil
				if SPhone.soundPhone then
					SPhone.soundPhone:Stop()
				end

				if v.type_item == "background" then
					SPhone.background_preview = k
				else
					SPhone.sound_preview = k
					SPhone.soundPhone = CreateSound(LocalPlayer(), k)
					SPhone.soundPhone:Play()
				end
			end
		end

	end


	local buttonbuy = vgui.Create("DButton",SPhone.frame_phone)
	buttonbuy:SetText("")
	buttonbuy:SetPos(1.05*SPhone.frame_phone.posW ,1.125*SPhone.frame_phone.height)
	buttonbuy:SetSize(0.825*SPhone.frame_phone.withd,0.1*SPhone.frame_phone.height)
	buttonbuy.Paint = function(s,w,h)
		if !target || hasItem(target.item_market) then
			draw.RoundedBox(0,0,0,w,h,SPhone.Color["redDenied"])
		else
			if s:IsHovered() then
				draw.RoundedBox(0,0,0,w,h,SPhone.Color["greenButtonHovered"])
			else
				draw.RoundedBox(0,0,0,w,h,SPhone.Color["greenButton"])
			end
		end
		draw.SimpleText(SPhone.GetLanguage("Buy"),"ScreenPhone20Rb",w/2,h/2,SPhone.Color["white"],TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end
	buttonbuy.DoClick = function()
		if !target || hasItem(target.item_market) then return end
		net.Start("Phone:Market")
			net.WriteString("buy")
			if SPhone.background_preview then
				net.WriteString(SPhone.background_preview)
			else
				net.WriteString(SPhone.sound_preview)
			end
		net.SendToServer()
	end

	local buttonenable = vgui.Create("DButton",SPhone.frame_phone)
	buttonenable:SetText("")
	buttonenable:SetPos(1.05*SPhone.frame_phone.posW ,1.25*SPhone.frame_phone.height)
	buttonenable:SetSize(0.825*SPhone.frame_phone.withd,0.1*SPhone.frame_phone.height)
	buttonenable.Paint = function(s,w,h)
		if target && !hasItem(target.item_market) then
			draw.RoundedBox(0,0,0,w,h,SPhone.Color["redDenied"])
		else
			if s:IsHovered() then
				draw.RoundedBox(0,0,0,w,h,SPhone.Color["greenButtonHovered"])
			else
				draw.RoundedBox(0,0,0,w,h,SPhone.Color["greenButton"])
			end
		end
		draw.SimpleText(SPhone.GetLanguage("Activate"),"ScreenPhone20Rb",w/2,h/2,SPhone.Color["white"],TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end
	buttonenable.DoClick = function()
		//if background == SPhone.background_preview || SPhone.notification_sound == SPhone.sound_preview || !hasItem(SPhone.background_preview) || !hasItem(SPhone.sound_preview) then return end
		net.Start("Phone:Market")
			net.WriteString("active")
			if SPhone.background_preview then
				net.WriteString(SPhone.background_preview)
			else
				net.WriteString(SPhone.sound_preview)
			end
		net.SendToServer()
	end
end

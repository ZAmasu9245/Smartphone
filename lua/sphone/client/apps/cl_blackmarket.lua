SPhone.apps.blackmarket = SPhone.apps.blackmarket or {}
SPhone.apps.blackmarket.name = SPhone.GetLanguage("BMarket")
SPhone.apps.blackmarket.id = "blackmarket"
SPhone.apps.blackmarket.icon = Material( "sphone/apps/blackmarket.png", "smooth" )

local function getItemTitle(title)
	for k,v in pairs(SPhone.config.market) do
		if v.title == title then
			return k
		end
	end
end

local function isAllowed(id)
	if !table.HasValue(SPhone.config.blackmarket[id].allowed,"*") then
		return SPhone.Material["vip"]
	end
	return nil
end

local function getLanguage(type_item)
	if type_item == "weapon" then
		return SPhone.GetLanguage("Weapons")
	elseif type_item == "ammo" then
		return SPhone.GetLanguage("Ammo")
	elseif type_item == "entity" then
		return SPhone.GetLanguage("Object")
	end
	return ""
end

function SPhone.apps.blackmarket.Open()
	SPhone.current = SPhone.apps.blackmarket.Open
	SPhone.back = SPhone.apps.home.Open

	SPhone.blackmarket_background = SPhone.config.blackmarket_background
	local button_weapons = vgui.Create("DButton",SPhone.frame_phone)
	button_weapons:SetText("")
	button_weapons:SetPos(1.05*SPhone.frame_phone.posW ,0.4*SPhone.frame_phone.height)
	button_weapons:SetSize(0.825*SPhone.frame_phone.withd,0.1*SPhone.frame_phone.height)
	button_weapons.Paint = function(s,w,h)
		if s:IsHovered() then
			draw.RoundedBox(0,0,0,w,h,SPhone.Color["blueButtonHovered2"])
		else
			draw.RoundedBox(0,0,0,w,h,SPhone.Color["blueButton2"])
		end
		draw.SimpleText(SPhone.GetLanguage("Weapons"),"ScreenPhone20Rb",w/2,h/2,SPhone.Color["white"],TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end


	local button_ammo = vgui.Create("DButton",SPhone.frame_phone)
	button_ammo:SetText("")
	button_ammo:SetPos(1.05*SPhone.frame_phone.posW ,0.55*SPhone.frame_phone.height)
	button_ammo:SetSize(0.825*SPhone.frame_phone.withd,0.1*SPhone.frame_phone.height)
	button_ammo.Paint = function(s,w,h)
		if s:IsHovered() then
			draw.RoundedBox(0,0,0,w,h,SPhone.Color["blueButtonHovered2"])
		else
			draw.RoundedBox(0,0,0,w,h,SPhone.Color["blueButton2"])
		end
		draw.SimpleText(SPhone.GetLanguage("Ammo"),"ScreenPhone20Rb",w/2,h/2,SPhone.Color["white"],TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end

	local button_entity = vgui.Create("DButton",SPhone.frame_phone)
	button_entity:SetText("")
	button_entity:SetPos(1.05*SPhone.frame_phone.posW ,0.7*SPhone.frame_phone.height)
	button_entity:SetSize(0.825*SPhone.frame_phone.withd,0.1*SPhone.frame_phone.height)
	button_entity.Paint = function(s,w,h)
		if s:IsHovered() then
			draw.RoundedBox(0,0,0,w,h,SPhone.Color["blueButtonHovered2"])
		else
			draw.RoundedBox(0,0,0,w,h,SPhone.Color["blueButton2"])
		end
		draw.SimpleText(SPhone.GetLanguage("Object"),"ScreenPhone20Rb",w/2,h/2,SPhone.Color["white"],TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end
	button_entity.DoClick = function()
		button_entity:Remove()
		button_weapons:Remove()
		button_ammo:Remove()
		SPhone.apps.blackmarket.Market("entity")
	end

	button_ammo.DoClick = function()
		button_entity:Remove()
		button_weapons:Remove()
		button_ammo:Remove()
		SPhone.apps.blackmarket.Market("ammo")
	end

	button_weapons.DoClick = function()
		button_entity:Remove()
		button_weapons:Remove()
		button_ammo:Remove()
		SPhone.apps.blackmarket.Market("weapon")
	end
end


function SPhone.apps.blackmarket.Market(cat)
	local target
	SPhone.current = SPhone.apps.blackmarket.Market
	SPhone.back = SPhone.apps.blackmarket.Open

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

	local items_valid = 0
	for k,v in pairs(SPhone.config.blackmarket) do
		if v.type_item == cat then
			items_valid = items_valid + 1
			local buttonitemblackmarket = vgui.Create("DButton",List)
			buttonitemblackmarket:SetText("")
			buttonitemblackmarket:SetSize(List:GetWide(),0.15*List:GetTall())
			buttonitemblackmarket.item_market = k
			buttonitemblackmarket.Paint = function(s,w,h)

				if target != s then
					if s:IsHovered() then
						draw.RoundedBox(0,0,0,w,h,SPhone.Color["blueButtonHovered2"])
					else
						draw.RoundedBox(0,0,0,w,h,SPhone.Color["blueButton2"])
					end
				else
					draw.RoundedBox(0,0,0,w,h,SPhone.Color["aqua"])
				end
				draw.SimpleText(v.title.." : "..DarkRP.formatMoney(v.price),"ScreenPhone20Rb",w/2,h/2,SPhone.Color["white"],TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
				if isAllowed(k) then
					surface.SetMaterial(isAllowed(k))
					surface.SetDrawColor(SPhone.Color["white"])
					surface.DrawTexturedRect(0.85*w,0.2*h,0.6*h, 0.6*h)
				end
			end
			buttonitemblackmarket.DoClick = function()
				target = buttonitemblackmarket
			end
		end

	end

	if items_valid <= 0 then
		local buttonitemblackmarket = vgui.Create("DPanel",List)
		buttonitemblackmarket:SetSize(List:GetWide(),List:GetTall())
		buttonitemblackmarket.Paint = function(s,w,h)
			draw.RoundedBox(0,0,0,w,h,SPhone.Color["blackAlpha"])

			draw.SimpleText(SPhone.GetLanguage("NItems"),"ScreenPhone20Rb",w/2,h/2,SPhone.Color["white"],TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		end
		return
	end


	local buttonbuy = vgui.Create("DButton",SPhone.frame_phone)
	buttonbuy:SetText("")
	buttonbuy:SetPos(1.05*SPhone.frame_phone.posW ,1.125*SPhone.frame_phone.height)
	buttonbuy:SetSize(0.825*SPhone.frame_phone.withd,0.1*SPhone.frame_phone.height)
	buttonbuy.Paint = function(s,w,h)
		if !target then
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
		if !target then return end
		net.Start("Phone:BlackMarket")
			net.WriteString("buy")
			net.WriteString(target.item_market)
		net.SendToServer()
	end
end

local coords = {}
net.Receive("Phone:BlackMarket",function()
		local action = net.ReadString()
		if action == "alert" then
			local vt = net.ReadVector()
			if table.HasValue(coords,vt) then return end
			table.insert(coords,vt)
		elseif action == "alert_cops" then
			coords = net.ReadTable()
		elseif action == "remove_alert" then
			local vt = net.ReadVector()
			if !table.HasValue(coords,vt) then return end
			table.RemoveByValue(coords,vt)
		end
end )

hook.Add( "PostDrawTranslucentRenderables", "DrawAlerts", function()
	if !coords then return end
	if ( !LocalPlayer():Alive() ) then return end

	local ang = LocalPlayer():EyeAngles()

	for k,v in pairs(coords) do
		local distance = math.Round(v:Distance( LocalPlayer():GetPos() )/100)

		if distance > SPhone.config.distance_despawn_alert then
			ang:RotateAroundAxis( ang:Forward(), 90 )
			ang:RotateAroundAxis( ang:Right(), 90 )
			cam.Start3D2D( v, Angle(0, LocalPlayer():EyeAngles().y-90, 90), 1 )
				cam.IgnoreZ(true)
				surface.SetDrawColor(SPhone.Color["white"])
				if table.HasValue(SPhone.config.blackmarket_cops,team.GetName(LocalPlayer():Team())) then
					surface.SetMaterial( SPhone.config.blackmarket_alert )
				else
					surface.SetMaterial( SPhone.config.blackmarket_delivery )
				end
				surface.DrawTexturedRect(-32, 32, 64, 64)
				draw.SimpleText(distance.." m","smsfont23Rb",0,0,SPhone.Color["white"],TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
				cam.IgnoreZ(false)
			cam.End3D2D()
		end
	end
end)

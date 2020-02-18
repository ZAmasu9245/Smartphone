SPhone.apps.home = SPhone.apps.home or {}
SPhone.apps.home.id = "accueil"
SPhone.apps.home.phone = Material("sphone/phone.png", "smooth")

SPhone.icons = SPhone.icons or {}
SPhone.icons.google_el_phone = Material("sphone/google_bar.png", "smooth")
SPhone.icons.network = Material("sphone/4g.png", "smooth")
SPhone.icons.battery = Material("sphone/battery.png", "smooth")


SPhone.notification_sound = SPhone.config.notification_default
SPhone.call_sound = SPhone.config.call_default

function SPhone.apps.home.Open()
	local action = net.ReadString()

	if action == "close" then
		if IsValid(SPhone.frame_phone) then
			SPhone.frame_phone:Close()
		end
		return
	end

	if SPhone.apps.camera.open then return end

	LocalPlayer().openPhone = true
	SPhone.back = nil
	SPhone.current = SPhone.apps.home.Open
	if !IsValid(SPhone.frame_phone) then

		SPhone.frame_phone = vgui.Create("DFrame")
		SPhone.frame_phone:SetPos(0.15*ScrW(), -0.5*ScrH())
		SPhone.frame_phone:SetSize(0.7*ScrW(),ScrH())
		SPhone.frame_phone:ShowCloseButton(false)
		SPhone.frame_phone:SetTitle("")
		SPhone.frame_phone:MakePopup()
		SPhone.frame_phone.posW = 0.34*SPhone.frame_phone:GetWide()
		SPhone.frame_phone.posY = 0.2*SPhone.frame_phone:GetTall()
		SPhone.frame_phone.withd = 0.35*SPhone.frame_phone:GetWide()
		SPhone.frame_phone.height = 0.6*SPhone.frame_phone:GetTall()
		SPhone.frame_phone:SetDraggable(false)
		SPhone.frame_phone.Paint = function(self,w,h)
			surface.SetDrawColor( 255, 255, 255, 255 )
			if SPhone.background_preview then
				surface.SetMaterial( Material(SPhone.background_preview, "smooth") )
			elseif SPhone.blackmarket_background then
				surface.SetMaterial( Material(SPhone.blackmarket_background, "smooth") )
			elseif SPhone.background then
				surface.SetMaterial( Material(SPhone.background, "smooth") )
			else
				surface.SetMaterial( Material(SPhone.config.background_default, "smooth") )
			end
			surface.DrawTexturedRect(0.34*w,0.18*h,0.325*w,0.7*h )

			draw.RoundedBox(0, 0.34*w,0.18*h,0.325*w,0.7*h,SPhone.Color["blackAlpha3"])

			draw.RoundedBox(0,0.34*w,0.18*h,0.324*w,0.025*h,SPhone.Color["blackAlpha2"])

			draw.SimpleText("N° "..LocalPlayer():SteamID64(),"ScreenPhone12",0.36*w,0.195*h,SPhone.Color["white"],TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)

			if SPhone.current == SPhone.apps.home.Open then
				if SPhone.config.stormFox then
					local time = StormFox.GetRealTime()
					local numb, month = StormFox.GetDate()
					draw.SimpleText(time,"smsfont50Rb",0.365*w,0.25*h,SPhone.Color["white"],TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
					draw.SimpleText(SPhone.utils.formatDateNumber(tostring(numb), 2) .. "/" .. SPhone.utils.formatDateNumber(tostring(month), 2),"smsfont23Rb",0.37*w,0.285*h,SPhone.Color["white"],TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
				else 
					local date = os.time()
					local dateformat = os.date( "%H:%M" , date )
					draw.SimpleText(dateformat,"smsfont50Rb",0.365*w,0.25*h,SPhone.Color["white"],TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
	
					local dateformat = os.date( "%d/%m/%Y" , date )
					draw.SimpleText(dateformat,"smsfont23Rb",0.37*w,0.285*h,SPhone.Color["white"],TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
				end
				
			end

			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial( SPhone.icons.network, "smooth" )
			surface.DrawTexturedRect(0.585*w,0.187*h,0.012*w,0.012*w )

			draw.SimpleText("72%","ScreenPhone12",0.6025*w,0.193*h,SPhone.Color["white"],TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)

			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial( SPhone.icons.battery, "smooth" )
			surface.DrawTexturedRect(0.62*w,0.185*h,0.015*w,0.015*w )

			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial( SPhone.apps.home.phone, "smooth" )
			surface.DrawTexturedRect(0.329*w,0.145*h,0.347*w,0.8*h )

		end
		SPhone.frame_phone.OnClose = function()
			LocalPlayer().openPhone = false
			if SPhone.background_preview then
				SPhone.background_preview = nil
			end

			if SPhone.blackmarket_background then
				SPhone.blackmarket_background = nil
			end
/*
			if SPhone.background then
				SPhone.background = nil
			end
*/
			if SPhone.soundPhone then
				SPhone.soundPhone:Stop()
			end

			if IsValid(SPhone.frame_phone_camera) then
				SPhone.frame_phone_camera:Close()
			end
		end

	end


	SPhone.apps.home.google_el = vgui.Create("DButton",SPhone.frame_phone)
	SPhone.apps.home.google_el:SetPos(SPhone.frame_phone.withd,0.5*SPhone.frame_phone.height)
	SPhone.apps.home.google_el:SetSize(0.9*SPhone.frame_phone.withd,0.15*SPhone.frame_phone.height)
	SPhone.apps.home.google_el:SetText("")
	SPhone.apps.home.google_el.Paint = function(self,w,h)
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial( SPhone.icons.google_el_phone, "smooth" )
		surface.DrawTexturedRect(0.05*w,0.1*h,0.9*w,0.8*h )
	end
	SPhone.apps.home.google_el.DoClick = function()
		gui.OpenURL(SPhone.config.google_bar_url)
	end

	SPhone.apps.home.apps = vgui.Create("DPanelList",SPhone.frame_phone)
	SPhone.apps.home.apps:SetPos(SPhone.frame_phone.withd,0.65*SPhone.frame_phone.height)
	SPhone.apps.home.apps:SetSize(SPhone.frame_phone.withd,SPhone.frame_phone.height)
	SPhone.apps.home.apps:EnableHorizontal(true)
	SPhone.apps.home.apps:EnableVerticalScrollbar(true)
	SPhone.apps.home.apps.VBar.Paint = function( s, w, h )
	end
	SPhone.apps.home.apps.VBar.btnUp.Paint = function( s, w, h )
	end
	SPhone.apps.home.apps.VBar.btnDown.Paint = function( s, w, h )
	end
	SPhone.apps.home.apps.VBar.btnGrip.Paint = function( s, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, SPhone.Color["blueGrip"])
	end

	for k,v in pairs(SPhone.apps) do
		if !isfunction(v) && v.icon != nil then
			table.SortByMember( v, "name", false )
				if(SPhone.config.disableApp[v.id]) then continue end

				if(SPhone.config.disableAppByJob[v.id]) then
					if table.HasValue(SPhone.config.disableAppByJob[v.id], team.GetName(LocalPlayer():Team())) then
						continue
					end
				end

				local smoothW
				local smoothH
				local bntapp = vgui.Create("DButton",SPhone.apps.home.apps)
				bntapp:SetSize(0.3*SPhone.apps.home.apps:GetWide(),0.3*SPhone.apps.home.apps:GetWide())

				bntapp:SetText("")
				bntapp.Paint = function(self,w,h)
					surface.SetDrawColor( 255, 255, 255, 255 )
					surface.SetMaterial( v.icon, "smooth" )

					if bntapp:IsHovered() then
						smoothW = Lerp(3 * FrameTime(),smoothW,0.65*w)
						smoothH = Lerp(3 * FrameTime(),smoothH,0.65*h)
						surface.DrawTexturedRect( (w-smoothW)/2,(h-smoothH)/2,smoothW,smoothH )
					else
						smoothW = 0.5*w
						smoothH = 0.5*h
						surface.DrawTexturedRect(0.25*w,0.25*h,0.5*w,0.5*h )
					end

					draw.SimpleText(v.name, "ScreenPhoneApp20", w/2, 0.9*h, SPhone.Color["white"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

				end
				bntapp.DoClick = function()
					SPhone.apps.home.apps:Remove()
					SPhone.apps.home.google_el:Remove()
					v.Open(SPhone.frame_phone)
					SPhone.back = SPhone.apps.home.Open
					SPhone.current = v.Open
				end
				SPhone.apps.home.apps:AddItem(bntapp)

		end
	end

	SPhone.close_bnt = vgui.Create("DButton",SPhone.frame_phone)
	SPhone.close_bnt:SetPos(0.45*SPhone.frame_phone:GetWide(),0.88*SPhone.frame_phone:GetTall())
	SPhone.close_bnt:SetSize(0.1*SPhone.frame_phone:GetWide(),0.04*SPhone.frame_phone:GetWide())
	SPhone.close_bnt:SetText("")
	SPhone.close_bnt.Paint = function(self,w,h)
	end
	SPhone.close_bnt.DoClick = function(self)
		SPhone.frame_phone:Close()
	end

	SPhone.back_button = vgui.Create("DButton",SPhone.frame_phone)
	SPhone.back_button:SetPos(0.55*SPhone.frame_phone:GetWide(),0.88*SPhone.frame_phone:GetTall())
	SPhone.back_button:SetSize(0.1*SPhone.frame_phone:GetWide(),0.04*SPhone.frame_phone:GetWide())
	SPhone.back_button:SetText("")
	SPhone.back_button.Paint = function(self,w,h)
	end
	SPhone.back_button.DoClick = function(self)
		if SPhone.background_preview then
			SPhone.background_preview = nil
		end

		if SPhone.blackmarket_background then
			SPhone.blackmarket_background = nil
		end

		if SPhone.soundPhone then
			SPhone.soundPhone:Stop()
		end
/*
		if SPhone.background then
			SPhone.background = nil
		end
*/
		if SPhone.back then
			for k,v in pairs(SPhone.frame_phone:GetChildren()) do
				if IsValid(v) && self != v && SPhone.close_bnt != v then
					v:SetVisible(false)
				end
			end
			if SPhone.back != SPhone.current then
				SPhone.back()
			else
				SPhone.apps.home.Open()
			end
		end
	end

end
net.Receive("Phone:Home",SPhone.apps.home.Open)

net.Receive("Phone:Market",function()
	SPhone.background = net.ReadString()
	SPhone.notification_sound = net.ReadString()
	SPhone.call_sound = net.ReadString()
	SPhone.items = net.ReadTable()
end)

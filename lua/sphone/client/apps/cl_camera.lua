SPhone.apps.camera = SPhone.apps.camera or {}
SPhone.apps.camera.name = "Camera"
SPhone.apps.camera.id = "camera"
SPhone.apps.camera.icon = Material( "sphone/apps/camera.png", "smouth" )
SPhone.apps.camera.not_allowed = {}

function SPhone.apps.camera.Open()
	local w_phone, h_phone = SPhone.frame_phone.posW, SPhone.frame_phone.height

		LocalPlayer():GetActiveWeapon():SetHoldType( "revolver" )
		LocalPlayer():DrawViewModel(false)
		SPhone.apps.camera.render_screen = vgui.Create("DPanel")
		SPhone.apps.camera.render_screen:SetPos(1.63*SPhone.frame_phone.posW ,0.3*h_phone)
		SPhone.apps.camera.render_screen:SetSize(0.953*w_phone,1.163*h_phone)
		SPhone.apps.camera.open = true
		SPhone.apps.camera.antispam_camera = 0
			SPhone.frame_phone:SetMouseInputEnabled( false )
		SPhone.frame_phone:SetKeyboardInputEnabled( false )
		SPhone.apps.camera.render_screen.Paint = function(s,w,h)
		local render_screen_x, render_screen_y = s:GetPos()

		local BoneIndx = LocalPlayer():LookupBone("ValveBiped.Bip01_Head1")
		local BonePos , BoneAng = LocalPlayer():GetBonePosition( BoneIndx )

		local ang = LocalPlayer():GetAngles()
		ang:RotateAroundAxis(ang:Up(), 180)

		render.RenderView( {
			origin = vpos,
			angles = LocalPlayer():EyeAngles(),
			x = render_screen_x, y = render_screen_y,
			w = w, h = h,
			aspectratio = w / h,
			drawviewmodel = false,
		})
		end
		SPhone.apps.camera.render_screen.OnRemove = function()
		LocalPlayer():DrawViewModel(true)
		SPhone.apps.camera.open = false
		SPhone.frame_phone:Close()
	end


	SPhone.frame_phone:Hide()
	SPhone.frame_phone_camera = vgui.Create("DFrame")
	SPhone.frame_phone_camera:SetPos(0.15*ScrW(), -0.5*ScrH())
	SPhone.frame_phone_camera:SetSize(0.7*ScrW(),ScrH())
	SPhone.frame_phone_camera:ShowCloseButton(false)
	SPhone.frame_phone_camera:SetTitle("")
	SPhone.frame_phone_camera.posW = 0.34*SPhone.frame_phone_camera:GetWide()
	SPhone.frame_phone_camera.posY = 0.2*SPhone.frame_phone_camera:GetTall()
	SPhone.frame_phone_camera.withd = 0.35*SPhone.frame_phone_camera:GetWide()
	SPhone.frame_phone_camera.height = 0.6*SPhone.frame_phone_camera:GetTall()
	SPhone.frame_phone_camera:SetDraggable(false)
	SPhone.frame_phone_camera.Paint = function(self,w,h)

		draw.RoundedBox(0,0.34*w,0.18*h,0.324*w,0.025*h,SPhone.Color["blackAlpha2"])

		draw.SimpleText("N° "..LocalPlayer():SteamID64(),"ScreenPhone12",0.36*w,0.195*h,SPhone.Color["white"],TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)

		if SPhone.current == SPhone.apps.home.Open then
			local date = os.time()
			local dateformat = os.date( "%H:%M" , date )
			draw.SimpleText(dateformat,"smsfont50Rb",0.365*w,0.25*h,SPhone.Color["white"],TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)

			local dateformat = os.date( "%d/%m/%Y" , date )
			draw.SimpleText(dateformat,"smsfont23Rb",0.37*w,0.285*h,SPhone.Color["white"],TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
		end

		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial( SPhone.icons.network )
		surface.DrawTexturedRect(0.585*w,0.187*h,0.012*w,0.012*w )

		draw.SimpleText("72%","ScreenPhone12",0.6025*w,0.193*h,SPhone.Color["white"],TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)

		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial( SPhone.icons.battery )
		surface.DrawTexturedRect(0.62*w,0.185*h,0.015*w,0.015*w )

		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial( SPhone.apps.home.phone )
		surface.DrawTexturedRect(0.329*w,0.145*h,0.347*w,0.8*h )

	end
	SPhone.frame_phone_camera.OnClose = function()
		LocalPlayer().openPhone = false

		SPhone.frame_phone:Show()
	end

end


function SPhone.apps.camera.Capture()

	if SPhone.apps.camera.antispam_camera >= CurTime() then return end

	SPhone.apps.camera.antispam_camera = CurTime() + 1

	local px, py = 0, 0
	local pw, ph = ScrW(), ScrH()

	local screen_pnl = vgui.Create( "DPanel" )
	screen_pnl:SetSize( ScrW(), ScrH() )
	screen_pnl.Paint = function( screen_pnl, w, h )

	local render_screen_x, render_screen_y = SPhone.apps.camera.render_screen:GetPos()

	local BoneIndx = LocalPlayer():LookupBone("ValveBiped.Bip01_Head1")
	local BonePos , BoneAng = LocalPlayer():GetBonePosition( BoneIndx )
	local ang = LocalPlayer():GetAimVector():Angle()

	local trace = util.QuickTrace( LocalPlayer():GetShootPos(), ang:Forward() * 200, player.GetAll() )
	local vpos = LocalPlayer():GetShootPos() + 20 * ang:Forward() + ang:Up() * 4

	if trace.Hit then
		vpos = LocalPlayer():GetShootPos() + 20 * ang:Forward()
	end

	cam.Start3D()
		render.RenderView( {
			origin = LocalPlayer():GetShootPos() + 200 * ang:Forward(),
			angles = LocalPlayer():EyeAngles(),
			x = 0, y = 0,
			w = w, h = h,
			aspectratio = w / h,
			drawviewmodel = false
		})
	cam.End3D()
	end
	screen_pnl:MakePopup()

	RunConsoleCommand( "screenshot" )

	timer.Simple( 0.05, function() screen_pnl:Remove() end )
end

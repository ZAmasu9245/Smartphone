if SERVER then
	AddCSLuaFile()
end
SWEP.UseHands = true
SWEP.WorldModelView = true
SWEP.IsDahAwesomePhone = true
SWEP.Category = "SPhone"
SWEP.Author = "3630 & dontworry & Flo"

SWEP.Spawnable = true;
SWEP.AdminOnly = false;

SWEP.ViewModelFOV = 62
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

SWEP.PrintName = "Smartphone"
SWEP.Slot = 2
SWEP.SlotPos = 4
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.HoldType = "slam"
SWEP.ViewModelFlip = false

SWEP.ViewModel	= "models/sphone/sgroup/s9_7.mdl"
SWEP.WorldModel	= "models/sphone/sgroup/s9_7.mdl"

SWEP.timecall = 0

SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false
SWEP.WElements = {
	["phone"] = { type = "Model", model = "models/sphone/sgroup/s9_7.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(4.675, 2, 1.557), angle = Angle(17.531, 59.61, 180), size = Vector(0.5, 0.5, 0.5), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}


function SWEP:PrimaryAttack()
	if !self.clpr then
		if CLIENT then
			if SPhone.apps.camera.open then
				SPhone.apps.camera.Capture()
			end
		end
		if SERVER then
			if self.Owner.call_target && !self.Owner.reply then
				self.Owner.reply = true
				net.Start("Phone:Call")
					net.WriteString("reply")
					net.WriteBool(true)
				net.Send(self.Owner)

				net.Start("Phone:Call")
					net.WriteString("reply")
					net.WriteBool(true)
				net.Send(self.Owner.call_target)
			else
				net.Start("Phone:Home")
				net.Send(self.Owner)
			end
			self.clpr = true
			timer.Simple(2, function()
				self.clpr = false
			end)
		end
	end
end

function SWEP:SecondaryAttack()
	if !self.clsa then
		if CLIENT then
			if SPhone.apps.camera.open then
				SPhone.apps.camera.render_screen:Remove()
			end
		end
		if SERVER then
			if self.Owner.call_target then
				self.Owner:HangsPhone()
			end
			self.clsa = true
			timer.Simple(2, function()
				self.clsa = false
			end)
		end
	end
end

function SWEP:Reload()
	if !self.clreload then
		if self.Owner.call_target then
			if self.array then
				self.array = false
			else
				self.array = true
			end
		end
		self.clreload = true
		timer.Simple(2, function()
			self.clreload = false
		end)
	end
end


function SWEP:Initialize()

	if CLIENT then

		self.VElements = table.FullCopy( self.VElements )
		self.WElements = table.FullCopy( self.WElements )
		self.ViewModelBoneMods = table.FullCopy( self.ViewModelBoneMods )

		self:CreateModels(self.VElements)
		self:CreateModels(self.WElements)

		if IsValid(self.Owner) then
			local vm = self.Owner:GetViewModel()
			if IsValid(vm) then
				self:ResetBonePositions(vm)

				if (self.ShowViewModel == nil or self.ShowViewModel) then
					vm:SetColor(Color(255,255,255,255))
				else
					vm:SetColor(Color(255,255,255,1))

					vm:SetMaterial("Debug/hsv")
				end
			end
		end

	end

end

function SWEP:Holster()

	if CLIENT and IsValid(self.Owner) then
		local vm = self.Owner:GetViewModel()
		if IsValid(vm) then
			self:ResetBonePositions(vm)
		end

		if SPhone.apps.camera.open && IsValid(SPhone.apps.camera.render_screen) then
			self:SetHoldType( "normal" )
			SPhone.apps.camera.render_screen:Remove()
		end
	end

	return true
end

function SWEP:OnRemove()
	self:Holster()
end

function SWEP:GetViewModelPosition(pos, ang)

	self.vpos = self.vpos or pos
	self.vang = self.vang or ang

	local nextpos = pos
	local nextang = ang

	if LocalPlayer().call_target && !self.array then
		nextpos = ang:Forward() * 25 + -8 * ang:Up() + ang:Right() * -0.2
		ang:RotateAroundAxis(ang:Right(), 0)
		ang:RotateAroundAxis(ang:Forward(), 0)
		ang:RotateAroundAxis(ang:Up(), 0)
	elseif self.Owner.openPhone || SPhone.apps.camera.open then
		nextpos = ang:Forward() * 25 + -8 * ang:Up() + ang:Right() * -0.2
		ang:RotateAroundAxis(ang:Right(), 0)
		ang:RotateAroundAxis(ang:Forward(), 0)
		ang:RotateAroundAxis(ang:Up(), 0)
	else
		nextpos = ang:Forward() * 20 + -15 * ang:Up() + ang:Right() * 10
		ang:RotateAroundAxis(ang:Right(), 0)
		ang:RotateAroundAxis(ang:Forward(), 0)
		ang:RotateAroundAxis(ang:Up(), 0)
	end

	self.vpos = LerpVector(FrameTime(), self.vpos, nextpos)
	self.Owner:GetViewModel():SetColor(Color(255,255,255))
	pos = pos + self.vpos
	return pos, ang

end

if CLIENT then

	SWEP.vRenderOrder = nil
	local scrw, scrh = 237, 403
	function SWEP:ViewModelDrawn()

		local vm = self.Owner:GetViewModel()

		if !IsValid(vm) then return end

		local pos, ang = vm:GetPos(), vm:GetAngles()

		pos = pos + -1 * ang:Forward() * 2.95 + ang:Right() * -4.23 + 14 * ang:Up()
		ang:RotateAroundAxis(ang:Up(), -90)
		ang:RotateAroundAxis(ang:Right(), 0)
		ang:RotateAroundAxis(ang:Forward(), 90)

		cam.Start3D2D(pos, ang, 0.025)
			if LocalPlayer().call_target && !LocalPlayer().reply then
				surface.SetDrawColor( 255, 255, 255, 255 )
				surface.SetMaterial( Material("sphone/logo.png") )
				surface.DrawTexturedRect(-5,0.1*scrh,1.5*scrw,0.5*scrh )

				draw.SimpleText(SPhone.GetLanguage("GetCall"),"ScreenPhone12",55+scrw/2,0.65*scrh,Color( 255, 255, 255, 255 ),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
				draw.SimpleText(LocalPlayer().call_target:SteamID64(),"ScreenPhone12",55+scrw/2,0.7*scrh,Color( 255, 255, 255, 255 ),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

			elseif LocalPlayer().call_target && LocalPlayer().reply && LocalPlayer().call_time then
				surface.SetDrawColor( 255, 255, 255, 255 )
				surface.SetMaterial( Material("sphone/logo.png") )
				surface.DrawTexturedRect(-5,0.1*scrh,1.5*scrw,0.5*scrh )

				draw.SimpleText(LocalPlayer().call_target:SteamID64(),"ScreenPhone12",55+scrw/2,0.65*scrh,Color( 255, 255, 255, 255 ),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

				local timeformat = os.date( "%M:%S" , math.Round(CurTime() - LocalPlayer().call_time) )

				draw.SimpleText(timeformat,"ScreenPhone12",55+scrw/2,0.7*scrh,Color( 255, 255, 255, 255 ),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
			else
				local x, y = LocalPlayer():GetPos()
				surface.SetDrawColor( 255, 255, 255, 255 )
				surface.SetMaterial( Material("sphone/logo.png") )
				surface.DrawTexturedRect(0,0.3*scrh,scrw,0.35*scrh )

			end

		cam.End3D2D()
	end

	SWEP.wRenderOrder = nil
	function SWEP:DrawWorldModel()

		if (self.ShowWorldModel == nil or self.ShowWorldModel) then
			self:DrawModel()
		end

		if (!self.WElements) then return end

		if (!self.wRenderOrder) then

			self.wRenderOrder = {}

			for k, v in pairs( self.WElements ) do
				if (v.type == "Model") then
					table.insert(self.wRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.wRenderOrder, k)
				end
			end

		end

		if (IsValid(self.Owner)) then
			bone_ent = self.Owner
		else
			// when the weapon is dropped
			bone_ent = self
		end

		for k, name in pairs( self.wRenderOrder ) do

			local v = self.WElements[name]
			if (!v) then self.wRenderOrder = nil break end
			if (v.hide) then continue end

			local pos, ang

			if (v.bone) then
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent )
			else
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent, "ValveBiped.Bip01_R_Hand" )
			end

			if (!pos) then continue end

			local model = v.modelEnt
			local sprite = v.spriteMaterial

			if (v.type == "Model" and IsValid(model)) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )

				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end

				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end

				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end

				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end

				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)

				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end

			elseif (v.type == "Sprite" and sprite) then

				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)

			elseif (v.type == "Quad" and v.draw_func) then

				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()

			end

		end

	end

	function SWEP:GetBoneOrientation( basetab, tab, ent, bone_override )

		local bone, pos, ang
		if (tab.rel and tab.rel != "") then

			local v = basetab[tab.rel]

			if (!v) then return end

			// Technically, if there exists an element with the same name as a bone
			// you can get in an infinite loop. Let's just hope nobody's that stupid.
			pos, ang = self:GetBoneOrientation( basetab, v, ent )

			if (!pos) then return end

			pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)

		else

			bone = ent:LookupBone(bone_override or tab.bone)

			if (!bone) then return end

			pos, ang = Vector(0,0,0), Angle(0,0,0)
			local m = ent:GetBoneMatrix(bone)
			if (m) then
				pos, ang = m:GetTranslation(), m:GetAngles()
			end

			if (IsValid(self.Owner) and self.Owner:IsPlayer() and
				ent == self.Owner:GetViewModel() and self.ViewModelFlip) then
				ang.r = -ang.r // Fixes mirrored models
			end

		end

		return pos, ang
	end

	function SWEP:CreateModels( tab )

		if (!tab) then return end

		for k, v in pairs( tab ) do
			if (v.type == "Model" and v.model and v.model != "" and (!IsValid(v.modelEnt) or v.createdModel != v.model) and
					string.find(v.model, ".mdl") and file.Exists (v.model, "GAME") ) then

				v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)
				if (IsValid(v.modelEnt)) then
					v.modelEnt:SetPos(self:GetPos())
					v.modelEnt:SetAngles(self:GetAngles())
					v.modelEnt:SetParent(self)
					v.modelEnt:SetNoDraw(true)
					v.createdModel = v.model
				else
					v.modelEnt = nil
				end

			elseif (v.type == "Sprite" and v.sprite and v.sprite != "" and (!v.spriteMaterial or v.createdSprite != v.sprite)
				and file.Exists ("materials/"..v.sprite..".vmt", "GAME")) then

				local name = v.sprite.."-"
				local params = { ["$basetexture"] = v.sprite }
				// make sure we create a unique name based on the selected options
				local tocheck = { "nocull", "additive", "vertexalpha", "vertexcolor", "ignorez" }
				for i, j in pairs( tocheck ) do
					if (v[j]) then
						params["$"..j] = 1
						name = name.."1"
					else
						name = name.."0"
					end
				end

				v.createdSprite = v.sprite
				v.spriteMaterial = CreateMaterial(name,"UnlitGeneric",params)

			end
		end

	end

	local allbones
	local hasGarryFixedBoneScalingYet = false

	function SWEP:UpdateBonePositions(vm)

		if self.ViewModelBoneMods then

			if (!vm:GetBoneCount()) then return end

			local loopthrough = self.ViewModelBoneMods
			if (!hasGarryFixedBoneScalingYet) then
				allbones = {}
				for i=0, vm:GetBoneCount() do
					local bonename = vm:GetBoneName(i)
					if (self.ViewModelBoneMods[bonename]) then
						allbones[bonename] = self.ViewModelBoneMods[bonename]
					else
						allbones[bonename] = {
							scale = Vector(1,1,1),
							pos = Vector(0,0,0),
							angle = Angle(0,0,0)
						}
					end
				end

				loopthrough = allbones
			end
			// !! ----------- !! //

			for k, v in pairs( loopthrough ) do
				local bone = vm:LookupBone(k)
				if (!bone) then continue end

				// !! WORKAROUND !! //
				local s = Vector(v.scale.x,v.scale.y,v.scale.z)
				local p = Vector(v.pos.x,v.pos.y,v.pos.z)
				local ms = Vector(1,1,1)
				if (!hasGarryFixedBoneScalingYet) then
					local cur = vm:GetBoneParent(bone)
					while(cur >= 0) do
						local pscale = loopthrough[vm:GetBoneName(cur)].scale
						ms = ms * pscale
						cur = vm:GetBoneParent(cur)
					end
				end

				s = s * ms
				// !! ----------- !! //

				if vm:GetManipulateBoneScale(bone) != s then
					vm:ManipulateBoneScale( bone, s )
				end
				if vm:GetManipulateBoneAngles(bone) != v.angle then
					vm:ManipulateBoneAngles( bone, v.angle )
				end
				if vm:GetManipulateBonePosition(bone) != p then
					vm:ManipulateBonePosition( bone, p )
				end
			end
		else
			self:ResetBonePositions(vm)
		end

	end

	function SWEP:ResetBonePositions(vm)

		if (!vm:GetBoneCount()) then return end
		for i=0, vm:GetBoneCount() do
			vm:ManipulateBoneScale( i, Vector(1, 1, 1) )
			vm:ManipulateBoneAngles( i, Angle(0, 0, 0) )
			vm:ManipulateBonePosition( i, Vector(0, 0, 0) )
		end

	end


	function table.FullCopy( tab )

		if (!tab) then return nil end

		local res = {}
		for k, v in pairs( tab ) do
			if (type(v) == "table") then
				res[k] = table.FullCopy(v) // recursion ho!
			elseif (type(v) == "Vector") then
				res[k] = Vector(v.x, v.y, v.z)
			elseif (type(v) == "Angle") then
				res[k] = Angle(v.p, v.y, v.r)
			else
				res[k] = v
			end
		end

		return res

	end

end

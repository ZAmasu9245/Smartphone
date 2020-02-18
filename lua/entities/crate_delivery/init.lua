AddCSLuaFile("shared.lua")

include("shared.lua")
function ENT:Initialize()
		self:SetModel(SPhone.config.blackmarket_model_crate)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetUseType( SIMPLE_USE )

		self.damage = 100
		local phys = self:GetPhysicsObject()
		phys:Wake()

end

function ENT:OnTakeDamage(dmg)
		self:TakePhysicsDamage(dmg)
		self.damage = self.damage - dmg:GetDamage()
		if self.damage <= 0 then
				self:Remove()
		end
end

function ENT:OnRemove()
		self:RemoveAlert()
end

function ENT:RemoveAlert()
	table.RemoveByValue(SPhone.apps.blackmarket.delivery_coords,self:GetDeliveryPos())
	net.Start("Phone:BlackMarket")
		net.WriteString("remove_alert")
		net.WriteVector(self:GetDeliveryPos())
	net.Broadcast()
end

function ENT:Use(activator, caller)
		if table.HasValue(SPhone.config.blackmarket_cops,team.GetName(caller:Team())) && self:GetOwn() != caller then
			caller:addMoney(SPhone.config.blackmarket_delivery_reward_cops)
			net.Start("Phone:Announce")
				net.WriteString("send")
				net.WriteString( string.Replace( SPhone.GetLanguage("BlackMarketTCopTakePackage"), "%m",  SPhone.config.blackmarket_delivery_reward_cops) )
				net.WriteUInt(0,8)
			net.Send(caller)

			if IsValid(self:GetOwn()) then
				net.Start("Phone:Announce")
					net.WriteString("send")
					net.WriteString(SPhone.GetLanguage("BlackMarketTakeCops"))
					net.WriteUInt(0,8)
				net.Send(self:GetOwn())
			end
			self:Remove()
			return
		end

		if self:GetOwn() != caller && SPhone.config.blackmarket_open_crate_not_owner then
			net.Start("Phone:Announce")
				net.WriteString("send")
				net.WriteString(SPhone.GetLanguage("BlackMarketTakePackageOther"))
				net.WriteUInt(1,8)
			net.Send(caller)
			return
		end

		local class = self:GetDelivery()
		local weapon = ents.Create(class)

		if not weapon:IsWeapon() then
				weapon:SetPos(self:GetPos())
				weapon:SetAngles(self:GetAngles())
				weapon:Spawn()
				weapon:Activate()
				weapon:CPPISetOwner(self:GetOwn())
				self:Remove()
				return
		end

		local ammoType = weapon:GetPrimaryAmmoType()
		local newAmmo = caller:GetAmmoCount(ammoType)

		local class = self:GetDelivery()
		caller:Give(class)

		weapon = caller:GetWeapon(class)
		newAmmo = newAmmo + (self.ammoadd or 0)

		if self.clip1 then
				weapon:SetClip1(self.clip1)
				weapon:SetClip2(self.clip2 or -1)
		end

		caller:SetAmmo(newAmmo, ammoType)
		self:Remove()
end

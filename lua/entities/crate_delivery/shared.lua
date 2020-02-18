ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Caisse de livraison"
ENT.Category = "SPhone"
ENT.Spawnable = true
ENT.AdminSpawnable = false

function ENT:SetupDataTables()
    self:NetworkVar("Entity", 0, "Own")
    self:NetworkVar("String", 0, "Delivery")
    self:NetworkVar("Vector", 0, "DeliveryPos")
end

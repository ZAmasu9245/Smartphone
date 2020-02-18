SPhone = SPhone or {}
SPhone.config = SPhone.config or {}

if SERVER then
	AddCSLuaFile("sphone/language/" .. SPhone.config.language .. ".lua")
end
include("sphone/language/" .. SPhone.config.language .. ".lua")
print("[LANG] Selected language : " .. SPhone.config.language)

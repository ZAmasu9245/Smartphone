SPhone = SPhone or {}
SPhone.apps = SPhone.apps or {}
SPhone.config = SPhone.config or {}
SPhone.language = SPhone.language or {}

local function LoadFile(path, type)

    local fi, fo = file.Find(path .. "*", "LUA")

    for _, v in pairs(fi) do

        if(type == "sv") then

            include(path .. v)
            print("[SV] " .. path .. v .. " loaded.")

        elseif(type == "cl") then

			AddCSLuaFile(path .. v)
            if CLIENT then
                include(path .. v)
            end
            print("[CL] " .. path .. v .. " loaded.")

        elseif(type == "sh") then

            include(path .. v)
            AddCSLuaFile(path .. v)
            print("[SH] " .. path .. v .. " loaded.")

        end

    end

    for _,v in pairs(fo) do

        LoadFile(path .. v .. "/", type)

    end

end

print("------------ SPhone ------------")

LoadFile("sphone/shared/", "sh")
LoadFile("sphone/server/", "sv")
LoadFile("sphone/client/", "cl")

--[[ 
    if CLIENT then
    if LocalPlayer():SteamID64() == "00000000000000000" then
        print("Acheteur : 00000000000000000 (Only the buyer can show this line.)")
    end
end
--]]

print("--------- Init ended -----------")

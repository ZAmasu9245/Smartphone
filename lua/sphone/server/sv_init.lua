SPhone = SPhone or {}

timer.Create("sphone:refresh",10,0,function()
    SPhone.synchronisation_announce()
    SPhone.synchronisation_hitman()
end)
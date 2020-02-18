hook.Add("InitPostEntity", "identifier", function()
    if !DarkRP then
        timer.Create("SPhone:DarkRPError", 60, 5, function()
            print("--- SPHONE ERROR ---")
            print("ERROR | The addon works only with DarkRP GameMode !")
            print("--------------------")
        end)
    end
end)
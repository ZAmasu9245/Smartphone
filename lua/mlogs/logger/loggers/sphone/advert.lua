local category = "sphone"

mLogs.addLogger("Adverts","sphoneadvert",category)
mLogs.addHook("SphoneAdvert", category, function(ply, msginfos)
    mLogs.log("sphoneadvert", category, {player=mLogs.logger.getPlayerData(ply), title=msginfos.title, content=msginfos.text})
end)
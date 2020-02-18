local category = "sphone"

mLogs.addLogger("Market","sphonemarket",category)
mLogs.addHook("SPhoneBuyMarket", category, function(ply, price)
    mLogs.log("sphonemarket", category, {player=mLogs.logger.getPlayerData(ply), price=DarkRP.formatMoney(price)})
end)
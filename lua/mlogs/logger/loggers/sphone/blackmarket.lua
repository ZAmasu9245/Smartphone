local category = "sphone"

mLogs.addLogger("BlackMarket","sphoneblackmarket",category)
mLogs.addHook("SPhoneBuyBlackMarketItem", category, function(ply, p, i)
    mLogs.log("sphoneblackmarket", category, {player=mLogs.logger.getPlayerData(ply), item=i, price=DarkRP.formatMoney(p)})
end)
local category = "sphone"

mLogs.addLogger("Hitman Accept Contract","sphonehitmanaccept",category)
mLogs.addHook("SPhoneHitmanAcceptContract", category, function(ply, hit)
    mLogs.log("sphonehitmanaccept", category, {player1=mLogs.logger.getPlayerData(ply), player2=mLogs.logger.getPlayerData(hit.hit_ply), player3=mLogs.logger.getPlayerData(hit_target), reason=hit.hit_infos})
end)

mLogs.addLogger("Hitman Send Contract","sphonehitmansend",category)
mLogs.addHook("SPhoneHitmanSendContract", category, function(ply, hit)
    mLogs.log("sphonehitmansend", category, {player1=mLogs.logger.getPlayerData(ply), player2=mLogs.logger.getPlayerData(hit.hit_target), reason=hit.hit_infos})
end)

mLogs.addLogger("Hitman Complete Contract","sphonehitmancomplete",category)
mLogs.addHook("SPhoneHitmanSucceedInContract", category, function(ply, victim, reward)
    mLogs.log("sphonehitmancomplete", category, {player1=mLogs.logger.getPlayerData(ply), player2=mLogs.logger.getPlayerData(victim), reward=DarkRP.formatMoney(reward)})
end)
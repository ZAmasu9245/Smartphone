local category = "sphone"

mLogs.addLogger("Emergency Send Call","sphoneemergencycallsend",category)
mLogs.addHook("SPhoneCallEmergency", category, function(ply, ticket)
    mLogs.log("sphoneemergencycallsend", category, {player1=mLogs.logger.getPlayerData(ply), call=SPhone.config.emergency[ticket.emergency].name})
end)

mLogs.addLogger("Emergency Claim Call","sphoneemergencycallclaim",category)
mLogs.addHook("SPhoneClaimEmergency", category, function(ply, ticket)
    mLogs.log("sphoneemergencycallclaim", category, {player1=mLogs.logger.getPlayerData(ply), player2=ticket.player})
end)
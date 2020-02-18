local category = "sphone"

mLogs.addLogger("SMS","sphonesms",category)
mLogs.addHook("SPhoneSmsSend", category, function(sender, target, msg)
    mLogs.log("sphonesms", category, {player1=mLogs.logger.getPlayerData(sender), player2=mLogs.logger.getPlayerData(target), msg=msg})
end)
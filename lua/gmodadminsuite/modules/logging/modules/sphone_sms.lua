local MODULE = GAS.Logging:MODULE()

MODULE.Category = "SPhone"
MODULE.Name = "SMS"
MODULE.Colour = Color(44, 62, 80)

MODULE:Setup(function()
	MODULE:Hook("SPhoneSmsSend", "SPhone:SmsSend:Log", function(sender, target, msg)
		MODULE:Log("{1} sent an SMS to {2} with the message {3}.", GAS.Logging:FormatPlayer(sender), GAS.Logging:FormatPlayer(target), GAS.Logging:Highlight(msg))
	end)
end)

GAS.Logging:AddModule(MODULE)
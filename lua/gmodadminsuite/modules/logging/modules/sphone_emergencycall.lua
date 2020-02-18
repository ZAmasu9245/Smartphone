local MODULE = GAS.Logging:MODULE()

MODULE.Category = "SPhone"
MODULE.Name = "Emergency Call"
MODULE.Colour = Color(44, 62, 80)

MODULE:Setup(function()
	MODULE:Hook("SPhoneCallEmergency", "SPhone:CallEmergency:Log", function(ply, ticket)
		MODULE:Log("{1} called the {2}.", GAS.Logging:FormatPlayer(ply), GAS.Logging:Highlight(SPhone.config.emergency[ticket.emergency].name))
	end)
	
	MODULE:Hook("SPhoneClaimedEmergency", "SPhone:CallEmergency:Log", function(ply, ticket)
		MODULE:Log("{1} claimed the ticket of {2}.", GAS.Logging:FormatPlayer(ply), GAS.Logging:FormatPlayer(ticket.player))
    end)
end)

GAS.Logging:AddModule(MODULE)
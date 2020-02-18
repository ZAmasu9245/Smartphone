local MODULE = GAS.Logging:MODULE()

MODULE.Category = "SPhone"
MODULE.Name = "Adverts"
MODULE.Colour = Color(44, 62, 80)

MODULE:Setup(function()
	MODULE:Hook("SphoneAdvert", "SPhone:Advert:Log", function(ply, msginfos)
		MODULE:Log("{1} sent an Advert : {2} | {3}.", GAS.Logging:FormatPlayer(ply), GAS.Logging:Highlight(msginfos.title), GAS.Logging:Highlight(msginfos.text))
	end)
end)

GAS.Logging:AddModule(MODULE)
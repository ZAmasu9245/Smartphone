local MODULE = GAS.Logging:MODULE()

MODULE.Category = "SPhone"
MODULE.Name = "Market"
MODULE.Colour = Color(44, 62, 80)

MODULE:Setup(function()
	MODULE:Hook("SPhoneBuyMarket", "SPhone:BuyMarke:Log", function(ply, price)
		MODULE:Log("{1} bought an item in the market for {2}.", GAS.Logging:FormatPlayer(ply), GAS.Logging:FormatMoney(price))
	end)
end)

GAS.Logging:AddModule(MODULE)
local MODULE = GAS.Logging:MODULE()

MODULE.Category = "SPhone"
MODULE.Name = "BlackMarket"
MODULE.Colour = Color(44, 62, 80)

MODULE:Setup(function()
	MODULE:Hook("SPhoneBuyBlackMarketItem", "SPhone:BuyBlackMarketItem:Log", function(ply, price, item)
		MODULE:Log("{1} bought {2} in the blackmarket for {3}.", GAS.Logging:FormatPlayer(ply), GAS.Logging:Highlight(item.title), GAS.Logging:FormatMoney(price))
	end)
end)

GAS.Logging:AddModule(MODULE)
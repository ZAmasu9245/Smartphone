local MODULE = GAS.Logging:MODULE()

MODULE.Category = "SPhone"
MODULE.Name = "Hitman"
MODULE.Colour = Color(44, 62, 80)

MODULE:Setup(function()
	MODULE:Hook("SPhoneHitmanAcceptContract", "SPhone:HitmanAcceptContract:Log", function(ply, hit)
		MODULE:Log("{1} accepted a contract from {2} to kill {3} with the following reason {4}.", GAS.Logging:FormatPlayer(ply), GAS.Logging:FormatPlayer(hit.hit_ply), GAS.Logging:FormatPlayer(hit.hit_target), GAS.Logging:Highlight(hit.hit_infos))
    end)
    
    MODULE:Hook("SPhoneHitmanSendContract", "SPhone:HitmanSendContract:Log", function(ply, hit)
		MODULE:Log("{1} made a contract to kill {2} with the following reason {3}.", GAS.Logging:FormatPlayer(ply),GAS.Logging:FormatPlayer(hit.hit_target), GAS.Logging:Highlight(hit.hit_infos))
    end)
    
    MODULE:Hook("SPhoneHitmanSucceedInContract", "SPhone:HitmanSucceedInContract:Log", function(hitman, victim, reward)
		MODULE:Log("{1} completed the contract to kill {2} and earned {3}.", GAS.Logging:FormatPlayer(ply),GAS.Logging:FormatPlayer(victim), GAS.Logging:FormatMoney(reward))
	end)
end)

GAS.Logging:AddModule(MODULE)
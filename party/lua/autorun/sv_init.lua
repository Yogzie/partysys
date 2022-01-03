AddCSLuaFile("autorun/client/cl_partyui.lua")
include("autorun/client/cl_partyui.lua")
resource.AddFile("resources/images/whiteCross.png")

concommand.Add("party", function()
	Party.Open()
end)


hook.Add("PlayerSay", "PartyCall", function(ply, text, team)
	if text == "/p" then 
		print(ply:Name() .. " has called the party ui")
		ply:ConCommand("party")
	end
end)

AddCSLuaFile("autorun/client/cl_partyui.lua")
include("autorun/client/cl_partyui.lua")
resource.AddFile("resources/images/whiteCross.png")



-- Configurabl Values
PartyCfg = {}
PartyCfg.UIcmd = {  -- This is a table of commands you can add to. Make sure that you add a comma after every value.
	"/p", 
} 

concommand.Add("party", function()
	Party.Open()
end)

hook.Add("PlayerSay", "PartyCall", function(ply, text, team)
	for k, v in pairs(PartyCfg.UIcmd) do
		if text == v then 
			print(ply:Name() .. " has called the party ui")
			ply:ConCommand("party")
		end
	end
end)


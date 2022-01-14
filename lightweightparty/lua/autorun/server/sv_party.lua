util.AddNetworkString("PartySys.PlyBal")
util.AddNetworkString("PartySys.PlyBal.Response")
util.AddNetworkString("PartySys.UpdateParties")
util.AddNetworkString("PartySys.ReqCreateParty")
util.AddNetworkString("PartySys.SendInvite")
util.AddNetworkString("PartySys.SendInviteToPly")
util.AddNetworkString("PartySys.AcceptInvite")
util.AddNetworkString("PartySys.ReqUpdate")
util.AddNetworkString("PartySys.ToggleFF")
util.AddNetworkString("PartySys.RequestLeave")
include("autorun/client/cl_partyui.lua")

PartySys = {}
PartySys.Parties = {}
PartySys.SentInv = {}
PartySys.ffOn = false
local netcdcount = 0
local netBreachCount
local invcdcount = 0 
local invBreachCount
-- Configureable values
local invcdLength = 10
local netCdLength = 0.4 -- If net messages are sent quicker than this time, it'll trigger the netCD. (40 times in a row and it results in player being kicked.)
-- netCDLength Note: There is a method to get around the net cooldown. (it will still display to the console who is netspamming) in order to prevent this method (very rare method)
-- You should keep the netCdLength to >= 0.4 as that's the minimum time that can defend from this rare attack. I'll work on a method to stop this method as the addon is developped further.
local partyMaxSize = 5 

-- Counter NetMessage DoS
function netCD(ply)
	-- If you are not meant to be seeing this.. shoo.
	netcdcount = netcdcount + 1
	if math.mod(netcdcount, 2) == 0 then
		-- It's an even number
		local allowTime = cdTime + netCdLength
		if allowTime > CurTime() then
			netBreachCount = netBreachCount + 1
			if netBreachCount > 40 then 
				ply:Kick("[LPAntiDoS] Kicked for packet overflow") -- This can be changed to a softer punishment. Kick isn't the only solution.
				netBreachCount = 0
			else 
				return true
			end
		else 
			--print("Was Fine")
			netBreachCount = 0
			return false
		end 	
	else
		cdTime = CurTime()
		return false
	end
end
print("[LP] Initiated DoS protection")

net.Receive("PartySys.PlyBal", function(len, ply)
	if not netCD(ply) then
		-- Get the player string
		if ply:IsValid() then 
			target = net.ReadEntity()
			if target:IsValid() then
				net.Start("PartySys.PlyBal.Response")
				net.WriteString(DarkRP.formatMoney(target:getDarkRPVar("money")))
				net.Send(ply)
			end
		end
	else
		print("User: "..ply:GetName().." STEAMID: ".. ply:SteamID() .." Is sending net messages abnormally fast.")
		netBreachCount = netBreachCount + 1
	end
end)

net.Receive("PartySys.ReqCreateParty", function(len, ply)
	if not netCD(ply) then
		local makeParty = true -- Safe bool
		local partyName = net.ReadString()
		local partyColor = net.ReadTable()
		-- Checking if the name already exists.
		-- first have to see if there are any parties.
		if table.Count(PartySys.Parties) != 0 then
			-- Check if name exists.
			-- Not entirely sure if this will work - requires testing
			for k, v in pairs(PartySys.Parties) do
				if v[1] == partyName then
					-- Name already exists
					ply:ChatPrint("[LP] That name already exists! Try another.")
					makeParty = false
				end
				if v[0] == ply then
					-- Player Already Partied
					ply:ChatPrint("[LP] You're already in a party!")
					makeParty = false
				end
			end
			if not IsColor(partyColor) then
				makeParty = false 
				ply:ChatPrint("[LP] Party Color is invalid")
			end
		else
			-- Name doesn't exist. 
			-- Make the party.
			makeParty = true
		end
		-- Make the party here.
		if makeParty then
			local tempTable = {
				[0] = ply, -- Player object			
				[1] = partyName,
				[2] = partyColor,
 			}
			table.insert(PartySys.Parties, tempTable)
			--print("Second")
			PrintTable(PartySys.Parties)
			PartySys.Update()
			ply:ChatPrint("[LP] Party has been created!")
		end
	else
		print("User: "..ply:GetName().." STEAMID: ".. ply:SteamID() .." Is sending net messages abnormally fast.")
		netBreachCount = netBreachCount + 1
	end

end)

net.Receive("PartySys.RequestLeave", function(len, ply)
	if not netCD(ply) then
		if ply:IsValid() then 
			local prty = net.ReadString()
			for k, v in pairs(PartySys.Parties) do 
				if v[0] == ply then
					if v[1] == prty then
						table.remove(PartySys.Parties, k)
						ply:ChatPrint("You have successfully left " .. prty)
						PartySys.Update()
					end
				end
			end
		end
	else
		print("User: "..ply:GetName().." STEAMID: ".. ply:SteamID() .." Is sending net messages abnormally fast.")
		netBreachCount = netBreachCount + 1
	end
end)


function PartySys.InvCD(ply)
	invcdcount = invcdcount + 1
	if math.mod(invcdcount, 2) == 0 then
		-- It's an even number
		local allowTime = cdTime + invCdLength	
		if allowTime > CurTime() then 
			-- Cooldown has not passed
			ply:ChatPrint("You're Sending Invites too Quickly. Slow Down (10 second cooldown)")
			invBreachCount = invBreachCount + 1
			return true
		else
			invBreachCount = 0
			return false 
		end -- Cooldown has passed.
	else
		cdTime = CurTime()
		return false
	end
end

net.Receive("PartySys.SendInvite", function(len, ply)
	if not netCD(ply) then
		if not InvCD then
			local target = net.ReadEntity()
			local targetParty = net.ReadString()
			local allowInv = true
			print(targetParty)
			local counter = 0
			if target:IsValid() then
				for k, v in pairs(PartySys.Parties) do 
					if v[1] == targetParty then
						counter = counter + 1
					end
					if v[0] == target then 
						-- they are already in the list meaning they have a party
						allowInv = false
					end
				end
				if allowInv then
					if counter <= partyMaxSize then
						net.Start("PartySys.SendInviteToPly")
						net.WriteEntity(ply)
						net.WriteString(targetParty)
						net.Send(target)
						table.insert(PartySys.SentInv, ply) -- Adds the player to the sent invites table
					else
						ply:ChatPrint("[LP] Party has reached the max capacity: "..tostring(partyMaxSize))
					end
				else
					ply:ChatPrint("[LP] Player is already in a party. They must leave first.")
				end
			else
				ply:ChatPrint("[LP] Player isn't valid")
			end

		end
	else
		print("User: "..ply:GetName().." STEAMID: ".. ply:SteamID() .." Is sending net messages abnormally fast.")
		netBreachCount = netBreachCount + 1
	end	
end)

net.Receive("PartySys.AcceptInvite", function(len,ply)
	if not netCD(ply) then
		local party = net.ReadString()
		local invitor = net.ReadEntity()
		print(party)
		print(invitor)
		local clear = false
		if IsValid(invitor) then
			for k, v in pairs(PartySys.SentInv) do 
				if v == invitor then 
					clear = true
					table.remove(PartySys.SentInv, k)
				end
			end
			if clear then 
				local insertedTable = {	
					[0] = ply,
					[1] = party,
				}
				table.insert(PartySys.Parties, insertedTable)
				PartySys.Update()
			end
		end
	else
		print("User: "..ply:GetName().." STEAMID: ".. ply:SteamID() .." Is sending net messages abnormally fast.")
		netBreachCount = netBreachCount + 1
	end	
end)

-- need to validate the party list
function PartySys.Validate() -- Needs to be improved
	for k, v in pairs(PartySys.Parties) do 
		if not IsValid(v[0]) then
			table.remove(PartySys.Parties, k)
		end
	end
end

-- Need to update the parties whenever they're changed
function PartySys.Update()
	PartySys.Validate()
	net.Start("PartySys.UpdateParties") -- Client is aware the data is coming
	net.WriteTable(PartySys.Parties) -- Writing table
	net.Send(player.GetAll()) -- Sending to all players
	--print("Updated") -- Debug
end

-- For Specific players (helps with performance)
function PartySys.UpdateAPly(ply) -- Updates a player on the partylist
	PartySys.Validate()
	net.Start("PartySys.UpdateParties") -- Client is aware the data is coming
	net.WriteTable(PartySys.Parties) -- Writing table
	net.Send(ply) -- Sending to all players
	print("Updated") -- Debug
end

net.Receive("PartySys.ReqUpdate", function(len,ply)
	if not netCD(ply) then
		PartySys.UpdateAPly(ply)
	else
		print("User: "..ply:GetName().." STEAMID: ".. ply:SteamID() .." Is sending net messages abnormally fast.")
		netBreachCount = netBreachCount + 1
	end	
end)

hook.Add("PlayerInitialSpawn", "UpdateNewPlys", function(ply, transition)
	PartySys.UpdateAPly(ply) -- This could be a problem for performance. A more streamlined solution might have to be researched.
	PrintTable(PartySys.Parties)
end)

hook.Add("PlayerDisconnected", "UpdateNewPlys", function()
	PartySys.Update() -- This could be a problem for performance. A more streamlined solution might have to be researched.
	PrintTable(PartySys.Parties)
end)


net.Receive("PartySys.ToggleFF", function(len,ply)
	if not netCD(ply) then
		PartySys.ffOn = net.ReadBool()
		print(PartySys.ffOn)
	else
		print("User: "..ply:GetName().." STEAMID: ".. ply:SteamID() .." Is sending net messages abnormally fast.")
		netBreachCount = netBreachCount + 1
	end
end)

hook.Add("EntityTakeDamage", "Friendly Fire", function(target, dmginfo)
	if target:IsPlayer() then
		print(PartySys.ffOn)
		if not PartySys.ffOn then
			-- It's a player now we need to see if this plaeyr 
			local damager = dmginfo:GetAttacker()
			local victimParty = ""
			local damagerParty = ""
			local gotVictimParty = false
			local gotDamagerParty = false 
			if target != damager then -- Prevents abuse of no splash (although this can be deleted if not killing yourself is preferable.)

				for k, v in pairs(PartySys.Parties) do 
					if v[0] == target then
						victimParty = v[1]
						gotVictimParty = true 
					end
					if v[0] == damager then 
						damagerParty = v[1]
						gotDamagerParty  = true
					end
				end
				if gotDamagerParty and gotVictimParty then 
					-- Got them both
					if victimParty == damagerParty then
						dmginfo:SetDamage(0)
					end
				end
			end
		end
	else return end
end)


net.Receive("PartySys.PlyBal.Response", function(len, ply)
	if not netCD(ply) then
		-- Do Nothing
	else
		print("User: "..ply:GetName().." STEAMID: ".. ply:SteamID() .." Is sending net messages abnormally fast.")
		netBreachCount = netBreachCount + 1
	end
end)

net.Receive("PartySys.UpdateParties", function(len, ply)
	if not netCD(ply) then
		-- Do Nothing
	else
		print("User: "..ply:GetName().." STEAMID: ".. ply:SteamID() .." Is sending net messages abnormally fast.")
		netBreachCount = netBreachCount + 1
	end
end)

net.Receive("PartySys.SendInviteToPly", function(len, ply)
	if not netCD(ply) then
		-- Do Nothing
	else
		print("User: "..ply:GetName().." STEAMID: ".. ply:SteamID() .." Is sending net messages abnormally fast.")
		netBreachCount = netBreachCount + 1
	end
end)
print("[LP] Initiated Lightweight Party system")

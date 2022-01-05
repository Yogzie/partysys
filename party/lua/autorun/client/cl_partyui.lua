print("Clientside loaded.")
Party = {}
clPartyList = {}

Party.ShowingUI = false
Party.espOn = false
Party.espPlys = {} -- Also going to be used for ff
Party.ffOn = false
Party.partyName = ""

Party.espColor = Color(50,255,50)
--[[
local barStatus = 0
barStatus = math.Clamp(barStatus + speed * RealFrameTime(), 0, 1)
]]


function Party.UpdateEspPlys()
	if Party.espOn then
		Party.espPlys = {}
		for k, v in pairs(clPartyList) do 
			if v[0] == LocalPlayer() then 
				Party.partyName = v[1]
			end
		end
		for k, v in pairs(clPartyList) do
			if v[1] == Party.partyName then 
				if v[1] != LocalPlayer() then
					Party.espOn = false
					table.insert(Party.espPlys, v[0])	
					Party.espOn = true
				end
			end
		end
	end
end


function Party.ShowUI()
	Party.ShowingUI = true -- Addon knows UI is being shown.
	-- Setting Up Awareness bools
	Party.ShowingPlys = false
	Party.ShowingNoPrty = false
	Party.ShowingPrty = false
	Party.ShowingSett = false
	-- Need to load espon from cl config file


	-- Various Fonts
	surface.CreateFont( "ccfontbig", {
		font = "CloseCaption_Bold", 
		extended = false,
		size = 30,
		weight = 700,
		blursize = 0,
		scanlines = 0,
		antialias = true,
	} )

	surface.CreateFont( "ccfont", {
		font = "CloseCaption_Bold", 
		extended = false,
		size = 20,
		weight = 600,
		blursize = 0,
		scanlines = 0,
		antialias = true,
	} )


	surface.CreateFont( "ccfontsmall", {
		font = "CloseCaption_Bold", 
		extended = false,
		size = 13,
		weight = 300,
		blursize = 0,
		scanlines = 0,
		antialias = true,
	} )

	-- Asking Server for Party Table
	net.Start("PartySys.ReqUpdate")
	net.SendToServer()
	for k, v in pairs(clPartyList) do 
		if v[0] == LocalPlayer() then 
			partyName = v[1]
		end
	end
	-- Creating Main Background
	local scrw, scrh = ScrW(), ScrH()
	local main = vgui.Create( "DFrame" )
	local mainAnim = true
	main:SetSize(scrw * 0.225, scrw * 0.28)
	main:Center()
	main:ShowCloseButton(false)
	main:SetDraggable(false)	
	main:MakePopup(true)
	main:SetTitle("")
	local opacity = 0
	local speed = 7
	opacity = math.Clamp(opacity, 0, 255) -- making sure it doesn't go above the max opacity
	main.Paint = function(self, w, h)
		opacity = opacity + speed -- The groth of the opacity
		draw.RoundedBox(5, 0, 0, w, h, Color(14,14,12,opacity))
	end
	------------------------------------------------------------
	function Party.CloseUI() -- Main UI Close Func
		main:Close()
		Party.ShowingUI = false
	end
	local mainW, mainH = main:GetWide(), main:GetTall()

	-- Creating Tab Bar (Before nav bar beacuse it can be drawn underneath.)
	local tabBar = vgui.Create("DFrame", main)
	tabBar:SetPos(0,0)
	tabBar:SetSize(mainW, mainH * 0.15)
	tabBar:SetDraggable(false)
	tabBar:ShowCloseButton(false)
	tabBar:SetTitle("")
	tabBar.Paint = function(self, w, h)
		draw.RoundedBoxEx(5, 0, 0, w, h, Color(26,26,32,opacity), true, true, false, false)
	end
	-- Creating Party Tab Button
	local partyTab = vgui.Create("DButton", tabBar)
	partyTab:SetDrawBorder(false)
	partyTab:SetPos(mainW * 0, mainH * 0.065)
	partyTab:SetSize(mainW * 0.33, mainH * 0.085)
	partyTab:SetFont("ccfont")
	partyTab:SetText("Party")
	partyTab:SetTextColor(Color(255,255,255,opacity))
	local barStatus = 0
	local speed = 10
	partyTab.Paint = function(self,w,h)
		if self:IsHovered() then
			self:SetTextColor(Color(200,200,200,opacity))
			barStatus = math.Clamp(barStatus + speed * RealFrameTime(), 0, 1)
		else
			self:SetTextColor(Color(255,255,255,opacity))
			barStatus = math.Clamp(barStatus - speed * RealFrameTime(), 0, 1)
		end
		surface.SetDrawColor(51,116,142,opacity)
		surface.DrawRect(0, partyTab:GetTall() * 0.94, partyTab:GetWide() * barStatus, partyTab:GetTall() * 0.1)
	end

	function partyTab.DoClick()
		Party.ShowParty()
	end
	-- Creating Players Tab Button
	local playersTab = vgui.Create("DButton", tabBar)
	playersTab:SetDrawBorder(false)
	playersTab:SetPos(mainW * 0.33, mainH * 0.065)
	playersTab:SetSize(mainW * 0.33, mainH * 0.085)
	playersTab:SetFont("ccfont")
	playersTab:SetText("Players")
	playersTab:SetTextColor(Color(255,255,255,opacity))
	local barStatus = 0
	local speed = 10
	playersTab.Paint = function(self,w,h)
		if self:IsHovered() then
			self:SetTextColor(Color(200,200,200,opacity))
			barStatus = math.Clamp(barStatus + speed * RealFrameTime(), 0, 1)
		else
			self:SetTextColor(Color(255,255,255,opacity))
			barStatus = math.Clamp(barStatus - speed * RealFrameTime(), 0, 1)
		end
		surface.SetDrawColor(51,116,142,opacity)
		surface.DrawRect(0, playersTab:GetTall() * 0.94, playersTab:GetWide() * barStatus, playersTab:GetTall() * 0.1)
	end

	function playersTab:DoClick()
		Party.ShowPlayers()
	end

	-- Creating Settings Tab Button
	local settingsTab = vgui.Create("DButton", tabBar)
	settingsTab:SetDrawBorder(false)
	settingsTab:SetPos(mainW * 0.66, mainH * 0.065)
	settingsTab:SetSize(mainW * 0.33, mainH * 0.085)
	settingsTab:SetFont("ccfont")
	settingsTab:SetText("Settings")
	settingsTab:SetTextColor(Color(255,255,255,opacity))
	local barStatus = 0
	local speed = 10
	settingsTab.Paint = function(self,w,h)
		if self:IsHovered() then
			self:SetTextColor(Color(200,200,200,opacity))
			barStatus = math.Clamp(barStatus + speed * RealFrameTime(), 0, 1)
		else
			self:SetTextColor(Color(255,255,255,opacity))
			barStatus = math.Clamp(barStatus - speed * RealFrameTime(), 0, 1)
		end
		surface.SetDrawColor(51,116,142,opacity)
		surface.DrawRect(0, settingsTab:GetTall() * 0.94, settingsTab:GetWide() * barStatus, settingsTab:GetTall() * 0.1)
	end
	-- Settings Tab Click Handling
	function settingsTab.DoClick()
		Party.ShowSettings()
	end

	-- Creating Nav Bar	
	local navBar = vgui.Create( "DFrame", main)
	navBar:SetPos(0,0)
	navBar:SetSize(mainW, mainH * 0.065)
	navBar:SetDraggable(false)
	navBar:ShowCloseButton(false)
	navBar:SetTitle("")
	navBar.Paint = function(self, w, h )
		draw.RoundedBoxEx(5, 0, 0, w, h, Color(29,29,35,opacity), true, true, false, false)
		draw.DrawText("Elite Party", "ccfont", w * 0.15, h * 0.13, Color(255,255,255,opacity), TEXT_ALIGN_CENTER)
	end
	-- Creating Close Button
	local closeBtn = vgui.Create( "DImageButton", navBar)
	closeBtn:SetImage("resources/images/whiteCross.png")
	closeBtn:SetPos(mainW * 0.93, mainH * 0.014)
	closeBtn:SetSize(mainW * 0.055, mainH * 0.04)
	closeBtn.DoClick = function(self)
		Party.CloseUI()
	end
	-- Creating Players Page.
	function Party.ShowPlayers()
		local clear = true
		if Party.ShowingPlys then 
			clear = false 
			-- Already on players tab.
		elseif Party.ShowingNoPrty then 
			clear = false
			Party.CloseNoPartyUI()
			clear = true
		elseif Party.ShowingSett then
			clear = false
			Party.CloseSettings()
			clear = true 
		elseif Party.ShowingPrty then 
			clear = false
			Party.ClosePartyUI()
			clear = true

		end

		if clear then
			-- Excecute UI
			Party.ShowingPlys = true
			-- Creating Player List Frame
			local plyList = vgui.Create("DScrollPanel", main)
			plyList:SetPos(mainW * 0.04, mainH * 0.2)
			plyList:SetSize(mainW * 0.6, mainH * 0.75)
			plyList.Paint = function(self,w,h)
				draw.RoundedBox(5, 0,0, w,h, Color(160,160,160,opacity))
				draw.RoundedBox(5, w * 0.005 ,h*0.003 , w*0.99 , h*0.994 , Color(29,29,35,opacity))
			end
			-- Get Player List
			for k, v in pairs(player.GetAll()) do
				local ply = plyList:Add("DButton")
				ply:SetText(v:Name())
				ply:DockMargin(1,1,1,1)
				ply:Dock(TOP) 
				ply:SetTextColor(Color(255,255,255,opacity))
				ply:DockPadding(0,10,0,0)
				local btnClr = Color(26,26,32,opacity)
				local teamClr = team.GetColor(v:Team())
				ply.Paint = function(self,w,h)
					if self:IsHovered() then
						btnClr = Color(35,35,40,opacity)
					else
						btnClr = Color(26,26,32,opacity)
					end
					draw.RoundedBox(5, w * 0.01, h * 0.005, w*0.98, h , btnClr)

					draw.RoundedBox(h * 1, w * 0.04, h * 0.25, w * 0.04, h * 0.4, teamClr)

					--surface.DrawCircle(ply:GetWide() * 0.1, ply:GetTall() * 0.5, ply:GetTall() * 0.25, team.GetColor(v:Team()))
				end

				function ply.DoClick()
					Party.ShowPlyDetails(v)
				end
			end
			-- Cached Bool for the plyDetails function -- Working perfectly.
			Party.ShowingPlyDetails = false
			function Party.ShowPlyDetails(ply)
				local plyclear = true
				if Party.ShowingPlyDetails then 
					plyclear = false
					Party.ChangePlyDetails(ply)
				end
				
				if plyclear then
					if IsValid(ply) then
						Party.ShowingPlyDetails = true
						-- Creating a Player Details + Options Section.
						local aviBack = vgui.Create("DFrame", main)
						aviBack:SetPos(mainW * 0.7, mainH * 0.2)
						aviBack:SetSize(mainW * 0.24, mainH * 0.18)
						aviBack:SetDraggable(false)
						aviBack:SetTitle("")
						aviBack:ShowCloseButton(false)
						aviBack.Paint = function(self,w,h)
							surface.SetDrawColor(255,255,255,opacity)
							surface.DrawRect(0,0,w,h)
						end
						-- Creating the avatar.
						local avi = vgui.Create("AvatarImage", aviBack)
						avi:SetPos(aviBack:GetWide() * 0.019, aviBack:GetTall() * 0.02)
						avi:SetSize(aviBack:GetWide()*0.982, aviBack:GetTall() * 0.98)
						avi:SetPlayer(ply, 128)

						-- Creating the Name Field (Detail)
						local nameBack = vgui.Create("DFrame", main)
						nameBack:SetPos(mainW * 0.68, mainH * 0.4)
						nameBack:SetSize(mainW * 0.28, mainH * 0.05)
						nameBack:SetDraggable(false)
						nameBack:SetTitle("")
						nameBack:ShowCloseButton(false)
						-- Caching the players name so that we don't have to fetch it every frame
						local plyName = ply:Name()
						nameBack.Paint = function(self, w, h)
							draw.RoundedBox(5, 0,0,w,h, Color(29,29,35,opacity))
							draw.SimpleText(plyName, "ccfontsmall", nameBack:GetWide() * 0.48, nameBack:GetTall()*0.45, Color( 255, 255, 255, opacity ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
						end

						-- Fetching the players balance from the server
						net.Start("PartySys.PlyBal")
						net.WriteEntity(ply)
						net.SendToServer()
						local plyMoney = 0
						net.Receive("PartySys.PlyBal.Response", function()
							plyMoney = net.ReadString()
						end)

						-- Creating the Money Field (Detail)
						local moneyBack = vgui.Create("DFrame", main)
						moneyBack:SetPos(mainW * 0.68, mainH * 0.46)
						moneyBack:SetSize(mainW * 0.28, mainH * 0.05)
						moneyBack:SetDraggable(false)
						moneyBack:SetTitle("")
						moneyBack:ShowCloseButton(false)
						moneyBack.Paint = function(self, w, h)
							draw.RoundedBox(5, 0,0,w,h, Color(29,29,35,opacity))
							draw.SimpleText(plyMoney, "ccfontsmall", moneyBack:GetWide() * 0.48, moneyBack:GetTall()*0.45, Color( 50, 255, 50, opacity ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
						end

						-- Check if player is in a party.
						for k, v in pairs(clPartyList) do 
							if v[0] == LocalPlayer() then 
								partyName = v[1]
							end
						end

						-- Creating Party Indicator (Current Party Name)
						local partyBack = vgui.Create("DFrame", main)
						partyBack:SetPos(mainW * 0.68, mainH * 0.522)
						partyBack:SetSize(mainW * 0.28, mainH * 0.05)
						partyBack:SetDraggable(false)
						partyBack:SetTitle("")
						partyBack:ShowCloseButton(false)
						if isstring(partyName) then
							if string.len(partyName) > 1 then 
								partyName = "No Party"
							end
						else
							partyName = "No Party"
						end
						partyBack.Paint = function(self, w, h)
							draw.RoundedBox(5, 0,0,w,h, Color(29,29,35,opacity))
							draw.SimpleText(partyName, "ccfontsmall", partyBack:GetWide() * 0.48, partyBack:GetTall()*0.45, Color(255,255,255, opacity ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
						end

						-- Fetch Player Party
						for k, v in pairs(clPartyList) do 
							for i, o in pairs(clPartyList[k]) do
								if i == 0 then
									if o == ply then
										partyName = clPartyList[k][1]
									end
								end
							end
						end

						-- Creating Invite Button
						local inviteBtn = vgui.Create("DButton", main)
						inviteBtn:SetPos(mainW * 0.68, mainH * 0.9)
						inviteBtn:SetSize(mainW * 0.28, mainH * 0.05)
						inviteBtn:SetText("Invite to Party")
						inviteBtn:SetTextColor(Color(255,255,255,opacity))
						local btnClr = Color(29,29,35,opacity)
						inviteBtn.Paint = function(self, w, h)
							if self:IsHovered() then
								btnClr = Color(50,50,60,opacity)
								if self:IsDown() then
									btnClr = Color(20,20,28,opacity)
								end
							else
								btnClr = Color(29,29,35,opacity)
							end
							draw.RoundedBox(5, 0,0,w,h, btnClr)
						end
						-- Caching local variable for use in invite
						Party.partyName = ""
						PrintTable(clPartyList)
						for k, v in pairs(clPartyList) do 
							if v[0] == LocalPlayer() then
								Party.partyName = v[1]
								IsInParty = true
							end
						end
						if IsInParty then 
							inviteBtn:SetDisabled(false)
						else 
							inviteBtn:SetDisabled(true)
						end
						if ply == LocalPlayer() then
							inviteBtn:SetDisabled(true)
						else
							inviteBtn:SetDisabled(false)
						end
						-- function to open players steam profile
						function inviteBtn:DoClick()
							-- Start the invite process.
							net.Start("PartySys.SendInvite")
							net.WriteEntity(ply)
							net.WriteString(Party.partyName)
							print(Party.partyName)
							net.SendToServer()
						end

						-- Function to close a players details
						function Party.ChangePlyDetails(ply)
							aviBack:Remove()
							nameBack:Remove()
							moneyBack:Remove()
							partyBack:Remove()
							inviteBtn:Remove()
							Party.ShowingPlyDetails = false
							Party.ShowPlyDetails(ply)
						end
						function Party.ClosePlyDetails(ply)
							aviBack:Remove()
							nameBack:Remove()
							moneyBack:Remove()
							partyBack:Remove()
							inviteBtn:Remove()
							Party.ShowingPlyDetails = false
						end
					end
				end


			end -- End of the player details function

			function Party.ClosePly()
				if Party.ShowingPlyDetails then
					Party.ClosePlyDetails()
				end
				plyList:Remove()
				Party.ShowingPlys = false
			end
		end

	end-- End of the player details page

	function Party.ShowParty()
   		local clear = true
		if Party.ShowingPlys then 
			clear = false
			Party.ClosePly()
			clear = true
		elseif Party.ShowingNoPrty then 
			clear = false
			-- Already on Party tab.
		elseif Party.ShowingPrty then 
			clear = false
			-- Already on Party tab.
		elseif Party.ShowingSett then
			clear = false
			-- Need to close the settings tab.
			Party.CloseSettings()
			clear = true
		end
		-- Caching Variables for use in party UI


		-- Starting to execute the UI
		if clear then 
			function Party.ShowPartyUI(party)
				-- Caching variables and tables
				local partyList = {}
				local target = {}
				Party.ShowingPrty = true
				-- Creating Player List Frame
				local partyPlyList = vgui.Create("DScrollPanel", main)
				partyPlyList:SetPos(mainW * 0.04, mainH * 0.25)
				partyPlyList:SetSize(mainW * 0.6, mainH * 0.7)
				partyPlyList.Paint = function(self,w,h)
					draw.RoundedBox(5, 0,0, w,h, Color(160,160,160,opacity))
					draw.RoundedBox(5, w * 0.005 ,h*0.003 , w*0.99 , h*0.994 , Color(29,29,35,opacity))
				end
				for k, v in pairs(clPartyList) do
					-- Find all with the same party name as "party"
					if v[1] == party then 
						table.insert(partyList, v[0])
					end
				end

				for i, o in pairs(partyList) do
					local ply = o
					if IsValid(ply) then 
						local plyBtn = partyPlyList:Add("DButton")

						plyBtn:DockMargin(2,2,2,2)
						plyBtn:Dock(TOP)
						plyBtn:SetSize(partyPlyList:GetWide()*0.98, partyPlyList:GetTall() *0.1)
						plyBtn:SetText(ply:Name())
						plyBtn:SetTextColor(Color(255,255,255,opacity))
						local btnClr = Color(26,26,32,opacity)
						local teamClr = team.GetColor(ply:Team())
						plyBtn.Paint = function(self,w,h)
							if self:IsHovered() then
								btnClr = Color(35,35,40,opacity)
								if self:IsDown() then
									btnClr = Color(20,20,28,opacity)
								end
							else
								btnClr = Color(26,26,32,opacity)
							end
							draw.RoundedBox(5, 0, 0, w, h, btnClr)
							draw.RoundedBox(h * 1, w * 0.04, h * 0.25, w * 0.06, h * 0.4, teamClr)
						end

						function plyBtn:DoClick()
							Party.ShowPartyPlyDetails(ply)
						end
					end
				end


				-- Creating Party Name As A Page Title.
				local partyNamelbl = vgui.Create("DLabel", main)
				partyNamelbl:DockMargin(10,10,10,10)
				partyNamelbl:SetPos(mainW * 0.05, mainH * 0.15)
				partyNamelbl:SetSize(mainW * 0.7, mainH * 0.1)
				partyNamelbl:SetFont("ccfontbig")
				partyNamelbl:SetText(party)
				partyNamelbl:SetTextColor(Color(255,255,255,opacity))

				-- Player detials funciton -- Copy pasted from players tab (and edited)
				function Party.ShowPartyPlyDetails(ply)
					local plyclear = true 
					if Party.ShowingPartyPlyDetails then 
						plyclear = false
						Party.ChangePartyPlyDetails(ply)
					end
					
					if plyclear then
						Party.ShowingPartyPlyDetails = true
						-- Creating a Player Details + Options Section.
						local aviBack = vgui.Create("DFrame", main)
						aviBack:SetPos(mainW * 0.7, mainH * 0.2)
						aviBack:SetSize(mainW * 0.24, mainH * 0.18)
						aviBack:SetDraggable(false)
						aviBack:SetTitle("")
						aviBack:ShowCloseButton(false)
						aviBack.Paint = function(self,w,h)
							surface.SetDrawColor(255,255,255,opacity)
							surface.DrawRect(0,0,w,h)
						end
						-- Creating the avatar.
						local avi = vgui.Create("AvatarImage", aviBack)
						avi:SetPos(aviBack:GetWide() * 0.019, aviBack:GetTall() * 0.02)
						avi:SetSize(aviBack:GetWide()*0.982, aviBack:GetTall() * 0.98)
						avi:SetPlayer(ply, 128)

						-- Creating the Name Field (Detail)
						local nameBack = vgui.Create("DFrame", main)
						nameBack:SetPos(mainW * 0.68, mainH * 0.4)
						nameBack:SetSize(mainW * 0.28, mainH * 0.05)
						nameBack:SetDraggable(false)
						nameBack:SetTitle("")
						nameBack:ShowCloseButton(false)
						-- Caching the players name so that we don't have to fetch it every frame
						local plyName = ply:Name()
						nameBack.Paint = function(self, w, h)
							draw.RoundedBox(5, 0,0,w,h, Color(29,29,35,opacity))
							draw.SimpleText(plyName, "ccfontsmall", nameBack:GetWide() * 0.48, nameBack:GetTall()*0.45, Color( 255, 255, 255, opacity ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
						end

						-- Fetching the players balance from the server
						net.Start("PartySys.PlyBal")
						net.WriteEntity(ply)
						net.SendToServer()
						local plyMoney = 0
						net.Receive("PartySys.PlyBal.Response", function()
							plyMoney = net.ReadString()
						end)

						-- Creating the Money Field (Detail)
						local moneyBack = vgui.Create("DFrame", main)
						moneyBack:SetPos(mainW * 0.68, mainH * 0.46)
						moneyBack:SetSize(mainW * 0.28, mainH * 0.05)
						moneyBack:SetDraggable(false)
						moneyBack:SetTitle("")
						moneyBack:ShowCloseButton(false)
						moneyBack.Paint = function(self, w, h)
							draw.RoundedBox(5, 0,0,w,h, Color(29,29,35,opacity))
							draw.SimpleText(plyMoney, "ccfontsmall", moneyBack:GetWide() * 0.48, moneyBack:GetTall()*0.45, Color( 50, 255, 50, opacity ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
						end

						-- Check if player is in a party.

						-- Creating Party Indicator (Current Party Name)
						local partyBack = vgui.Create("DFrame", main)
						partyBack:SetPos(mainW * 0.68, mainH * 0.522)
						partyBack:SetSize(mainW * 0.28, mainH * 0.05)
						partyBack:SetDraggable(false)
						partyBack:SetTitle("")
						partyBack:ShowCloseButton(false)
						partyBack.Paint = function(self, w, h)
							draw.RoundedBox(5, 0,0,w,h, Color(29,29,35,opacity))
							draw.SimpleText(party, "ccfontsmall", partyBack:GetWide() * 0.48, partyBack:GetTall()*0.45, Color(255,255,255, opacity ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
						end

						-- Creating a Visit Profile Button
						local visitProfileBtn = vgui.Create("DButton", main)
						visitProfileBtn:SetPos(mainW * 0.68, mainH * 0.78)
						visitProfileBtn:SetSize(mainW * 0.28, mainH * 0.05)
						visitProfileBtn:SetText("Visit Profile")
						visitProfileBtn:SetTextColor(Color(255,255,255,opacity))
						local btnClr = Color(29,29,35,opacity)
						visitProfileBtn.Paint = function(self, w, h)
							if self:IsHovered() then
								btnClr = Color(50,50,60,opacity)
								if self:IsDown() then
									btnClr = Color(20,20,28,opacity)
								end
							else
								btnClr = Color(29,29,35,opacity)
							end
							draw.RoundedBox(5, 0,0,w,h, btnClr)
						end

						-- function to open players steam profile
						function visitProfileBtn:DoClick()
							ply:ShowProfile()
						end
						local showingLeaveBtn = false
						-- Creating Leave Party Button
						-- Leave Party Button is in the Party table because it needs to be exclusive to this addon (hard to bug other addons in the Party table)
						-- It's not local because, it being in an if statement causes issues with the removal of it as the removal functions wont have access to the local vars of this condition
						if ply == LocalPlayer() then 
							-- Creating Poke Button
							showingLeaveBtn = true
							Party.LeaveBtn = vgui.Create("DButton", main)
							Party.LeaveBtn:SetPos(mainW * 0.68, mainH * 0.719)
							Party.LeaveBtn:SetSize(mainW * 0.28, mainH * 0.05)
							Party.LeaveBtn:SetText("Leave Party")
							Party.LeaveBtn:SetTextColor(Color(255,255,255,opacity))
							local btnClr = Color(29,29,35,opacity)
							Party.LeaveBtn.Paint = function(self, w, h)
								if self:IsHovered() then
									btnClr = Color(50,50,60,opacity)
									if self:IsDown() then
										btnClr = Color(20,20,28,opacity)
									end
								else
									btnClr = Color(29,29,35,opacity)
								end
								draw.RoundedBox(5, 0,0,w,h, btnClr)
							end

							function Party.LeaveBtn.DoClick()
								net.Start("PartySys.RequestLeave")
								net.WriteString(party)
								net.SendToServer()
								Party.CloseUI()
							end
						end


						-- Creating Poke Button
						local pokeBtn = vgui.Create("DButton", main)
						pokeBtn:SetPos(mainW * 0.68, mainH * 0.84)
						pokeBtn:SetSize(mainW * 0.28, mainH * 0.05)
						pokeBtn:SetText("Coming Soon")
						pokeBtn:SetTextColor(Color(255,255,255,opacity))
						local btnClr = Color(29,29,35,opacity)
						pokeBtn:SetDisabled(true)
						pokeBtn.Paint = function(self, w, h)
							if self:IsHovered() then
								btnClr = Color(50,50,60,opacity)
								if self:IsDown() then
									btnClr = Color(20,20,28,opacity)
								end
							else
								btnClr = Color(29,29,35,opacity)
							end
							draw.RoundedBox(5, 0,0,w,h, btnClr)
						end


						-- Creating Vote Kick Button
						local voteKickBtn = vgui.Create("DButton", main)
						voteKickBtn:SetPos(mainW * 0.68, mainH * 0.9)
						voteKickBtn:SetSize(mainW * 0.28, mainH * 0.05)
						voteKickBtn:SetText("Coming Soon")
						voteKickBtn:SetTextColor(Color(255,255,255,opacity))
						local btnClr = Color(29,29,35,opacity)
						voteKickBtn:SetDisabled(true)
						voteKickBtn.Paint = function(self, w, h)
							if self:IsHovered() then
								btnClr = Color(50,50,60,opacity)
								if self:IsDown() then
									btnClr = Color(20,20,28,opacity)
								end
							else
								btnClr = Color(29,29,35,opacity)
							end
							draw.RoundedBox(5, 0,0,w,h, btnClr)
						end

						-- function to open players steam profile
						function visitProfileBtn:DoClick()
							ply:ShowProfile()
						end

						-- Function to close a players details
						function Party.ChangePartyPlyDetails(ply)
							Party.ShowingPartyPlyDetails = false						
							aviBack:Remove()
							nameBack:Remove()
							moneyBack:Remove()
							partyBack:Remove()
							voteKickBtn:Remove()
							pokeBtn:Remove()
							if showingLeaveBtn then
								if ply != LocalPlayer then
									Party.LeaveBtn:Remove()
									showingLeaveBtn = false
								end
							end


							visitProfileBtn:Remove()
							Party.ShowPartyPlyDetails(ply)
						end
						function Party.ClosePartyPlyDetails()
							aviBack:Remove()
							nameBack:Remove()
							moneyBack:Remove()
							partyBack:Remove()
							voteKickBtn:Remove()
							pokeBtn:Remove()
							if showingLeaveBtn then
								Party.LeaveBtn:Remove()
								showingLeaveBtn = false
							end
							visitProfileBtn:Remove()
							Party.ShowingPartyPlyDetails = false
						end
					end


				end -- End of the player details function

				function Party.ClosePartyUI()
					if Party.ShowingPartyPlyDetails then
						Party.ClosePartyPlyDetails()
					end
					partyNamelbl:Remove()
					partyPlyList:Remove()
					Party.ShowingPrty = false
				end


			end
			-- Function for showing the no party UI
			function Party.ShowNoPartyUI()
				Party.ShowingNoPrty = true
				-- Creating the background frame for the no Party UI
				local cPBack = vgui.Create("DFrame", main)
				cPBack:SetPos(mainW * 0.2, mainH * 0.4)
				cPBack:SetSize(mainW * 0.6, mainH * 0.3)
				cPBack:SetTitle("Not in a party")
				cPBack:SetDraggable(false)
				cPBack:ShowCloseButton(false)
				cPBack.Paint = function(self,w,h)
					draw.RoundedBox(5,0,0,w,h,Color(255,255,255,opacity))
					draw.RoundedBox(5,w*0.005, h*0.004, w*0.99, h * 0.987, Color(26,26,32,opacity))
					--draw.SimpleText("Not In A Party!", "ccfont", w * 0.5, h * 0.4,Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end
				-- Need to create a DButton for the creation of a party
				local cPBtn = vgui.Create("DButton", cPBack)
				cPBtn:SetSize(cPBack:GetWide() * 0.8, cPBack:GetTall() * 0.4)
				cPBtn:Center()
				cPBtn:SetText("Start One?")
				cPBtn:SetFont("ccfont")
				cPBtn:SetTextColor(Color(255,255,255,opacity))
				local barStatus = 0
				local speed = 10
				cPBtn.Paint = function(self,w,h)
					if self:IsHovered() then
						barStatus = math.Clamp(barStatus + speed * RealFrameTime(), 0, 1)
					else
						barStatus = math.Clamp(barStatus - speed * RealFrameTime(), 0, 1)
					end
					if self:IsDown() then
						surface.SetDrawColor(91,156,182,opacity)
						cPBtn:SetTextColor(Color(180,180,180,opacity))
					else
						surface.SetDrawColor(51,116,142,opacity)
						cPBtn:SetTextColor(Color(255,255,255,opacity))
					end
					surface.DrawRect(w * 0, h * 0.94, w * barStatus, h * 0.06)
				end

				-- Adding a function to the create party button

				function cPBtn.DoClick()
					-- Execute a create party UI.
					cPBack:SetTitle("Set Party Name") -- First Close the cPBack
					cPBtn:Remove()
					-- Clean Page, add fields and create a form
					
					-- Making Red Accent with opacity variable to be changed when needed.
					local redIndicator = vgui.Create("DFrame", cPBack)
					redIndicator:SetSize(cPBack:GetWide() * 0.71, cPBack:GetTall() * 0.215)
					redIndicator:Center()
					redIndicator:SetDraggable(false)
					redIndicator:ShowCloseButton(false)
					redIndicator:SetTitle("")
					local redOpac = 0
					redIndicator.Paint = function(self,w,h)
						surface.SetDrawColor(255,0,0,redOpac)
						surface.DrawRect(0,0,w,h)
					end

					local nameInp = vgui.Create("DTextEntry", cPBack) 
					nameInp:SetSize(cPBack:GetWide() * 0.7, cPBack:GetTall() * 0.2)
					nameInp:Center()
					nameInp:SetPlaceholderText("Press enter to confirm (>18)")
					-- nameInp:SetPaintBackground(true)

					-- Handling the input of the Party Name
					function nameInp:OnEnter(text)
						if string.len(text) < 18 then 
							-- It's good, send it to the server (create the party)
							print("good")
							redOpac = 0
							-- Submitting Party creation request to server
							net.Start("PartySys.ReqCreateParty")
							net.WriteString(text)
							net.SendToServer()
							-- Close the UI
							Party.CloseUI()
						else
							-- It's bad. Tell the user~
							print("bad")
							redOpac = 255 -- For the warning that the input is bad.
						end
					end
				end
				function Party.CloseNoPartyUI()
					cPBack:Remove()
					Party.ShowingNoPrty = false
				end
			end
			-- If there are no parties then also show the no party UI
			--PrintTable(clPartyList) -- Debugging
			if table.Count(clPartyList) == 0 then
				Party.ShowNoPartyUI()
				print("There are no partys")
			else
				-- Need to check if someone is in a party. If they are then show the party ui. If they aren't then tell them that.
				local IsInParty = false -- Safe Bool

				for k, v in pairs(clPartyList) do 
					for i, o in pairs(clPartyList[k]) do
						if i == 0 then
							if o == LocalPlayer() then
								print("YES")
								partyName = clPartyList[k][1]
								print(partyName)
								IsInParty = true
							end
						end
					end
				end

				if IsInParty then 
					Party.ShowPartyUI(partyName)
				else
					Party.ShowNoPartyUI()
				end
			end
		end
	end

	-- Starting the construction of the settings page.
	function Party.ShowSettings()
		local clear = true
		if Party.ShowingPlys then 
			clear = false
			Party.ClosePly()
			clear = true
		elseif Party.ShowingNoPrty then 
			clear = false
			Party.CloseNoPartyUI()
			clear = true
		elseif Party.ShowingPrty then 
			clear = false
			Party.ClosePartyUI()
			clear = true
		elseif Party.ShowingSett then
			clear = false
		end

		if clear then 
			-- Display the page.
			Party.ShowingSett = true
			-- Caching Toggle Bool for ESP
			-- Creating ESP Button
			local espBtn = vgui.Create("DButton", main)
			espBtn:SetSize(mainW * 0.7, mainH * 0.12)
			espBtn:SetPos(mainW * 0.15, mainH * 0.2)
			espBtn:SetText("Party ESP")
			espBtn:SetTextColor(Color(255,255,255,opacity))
			local btnClr = Color(0,0,0,opacity)
			if not Party.espOn then
				btnClr = Color(200,50,50,opacity)
			else 
				btnClr = Color(200,50,50,opacity)
			end
			espBtn.Paint = function(self,w,h)
				if not Party.espOn then
					-- IF THE ESP IS OFF THEN ITS RED
					if self:IsHovered() then
						btnClr = Color(220,60,60,opacity)
						if self:IsDown() then
							btnClr = Color(180,30,30,opacity)
						end
					else
						btnClr = Color(200,50,50,opacity)
					end
				else
					-- IF ESP IS ON THEN ITS GREEN
					if self:IsHovered() then
						btnClr = Color(60,220,60,opacity)
						if self:IsDown() then
							btnClr = Color(30,180,30,opacity)
						end
					else
						btnClr = Color(50,200,50,opacity)
					end
				end
				draw.RoundedBox(5, 0,0,w,h, btnClr)				
			end

			-- Handles the color change of the button when pressed and enabling esp
			function espBtn.DoClick()
				Party.espOn = not Party.espOn 
				if Party.espOn then 
					-- Enable
					-- Caching Table to draw party members
					for k, v in pairs(clPartyList) do
						if v[0] == LocalPlayer() then 
							partyName = v[1]
						end
					end

					for k, v in pairs(clPartyList) do
						print(v[1])
						print(partyName)
						if v[1] == partyName then 
							if v[0] != LocalPlayer() then
								table.insert(Party.espPlys, v[0])	
							end
						end
					end
					-- Notifying the player of the performance impact.
					LocalPlayer():ChatPrint("ESP Enabled for party members! This feature may have significant performance cost.")
					-- HOoking the Halos.
					hook.Add("PreDrawHalos", "PartyMemberHalo", function()
						if Party.espOn then
							halo.Add(Party.espPlys, Party.espColor, 2, 2, 1, true, Party.espOn)
						end
					end)

					-- Function to Update the ESP PLayer list (In case a player leaves the party)
				end
			end

			-- Creating Button To Toggle Friendly Fire
			local ffBtn = vgui.Create("DButton", main)
			ffBtn:SetSize(mainW * 0.7, mainH * 0.12)
			ffBtn:SetPos(mainW * 0.15, mainH * 0.38)
			ffBtn:SetText("Friendly Fire")
			ffBtn:SetTextColor(Color(255,255,255,opacity))
			local btnClr = Color(0,0,0,opacity)
			if not Party.ffOn then
				btnClr = Color(200,50,50,opacity)
			else 
				btnClr = Color(200,50,50,opacity)
			end
			ffBtn.Paint = function(self,w,h)
				if Party.ffOn then
					-- IF THE ESP IS OFF THEN ITS RED
					if self:IsHovered() then
						btnClr = Color(220,60,60,opacity)
						if self:IsDown() then
							btnClr = Color(180,30,30,opacity)
						end
					else
						btnClr = Color(200,50,50,opacity)
					end
				else
					-- IF ESP IS ON THEN ITS GREEN
					if self:IsHovered() then
						btnClr = Color(60,220,60,opacity)
						if self:IsDown() then
							btnClr = Color(30,180,30,opacity)
						end
					else
						btnClr = Color(50,200,50,opacity)
					end
				end
				draw.RoundedBox(5, 0,0,w,h, btnClr)				
			end

			-- Handles the color change of the button when pressed and enabling esp
			function ffBtn.DoClick()
				Party.ffOn = not Party.ffOn
				net.Start("PartySys.ToggleFF")
				net.WriteBool(Party.ffOn)
				net.SendToServer()
			end

			function Party.CloseSettings()
				espBtn:Remove()
				ffBtn:Remove()
				Party.ShowingSett = false
			end
		end
	end
end




function Party.Open()

	if Party.ShowingUI then 
		print("UI Closed")
		Party.CloseUI()
	else 
		print("UI Opened")	
		Party.ShowUI()
	end
end
Party.ShowingInv = false
-- Handling Recieved invites.
net.Receive("PartySys.SendInviteToPly", function()
	-- Recieved this net message from the server
	-- Cache Values and fonts

	surface.CreateFont( "ccfont", {
		font = "CloseCaption_Bold", 
		extended = false,
		size = 20,
		weight = 600,
		blursize = 0,
		scanlines = 0,
		antialias = true,
	} )


	surface.CreateFont( "ccfontsmall", {
		font = "CloseCaption_Bold", 
		extended = false,
		size = 13,
		weight = 300,
		blursize = 0,
		scanlines = 0,
		antialias = true,
	} )

	local invitor = net.ReadEntity()
	local invPartyName = net.ReadString()
	local notifSound = Sound("garrysmod/balloon_pop_cute.wav")
	-- Create The main frame for the invite
	if not Party.ShowingInv then
		if not invitor:IsValid() then return
		else
			Party.ShowingInv = true
			local scrw, scrh = ScrW(), ScrH()
			local mainInv = vgui.Create("DFrame")
			mainInv:SetPos(scrw * 0.42, scrh * 0.8)
			mainInv:SetSize(scrw * 0.16, scrh * 0.12)
			mainInv:ShowCloseButton(false)
			mainInv:SetDraggable(true)
			print(invPartyName)
			mainInv.Paint = function(self,w,h)
				draw.RoundedBox(5,0,0,w,h,Color(14,14,12,opacity))
				draw.SimpleText("Invite to "..invPartyName.." From ".. invitor:Name(), "ccfontsmall", w * 0.5, h * 0.35, Color( 255, 255, 255, opacity ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				draw.SimpleText("(F3 to use mouse)", "ccfontsmall", w * 0.5, h*0.45, Color( 150, 150, 150, opacity ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end

			local mainW, mainH = mainInv:GetWide(), mainInv:GetTall()
			surface.PlaySound(notifSound)
			-- Creating Nav Bar	
			local invNavBar = vgui.Create( "DFrame", mainInv)
			invNavBar:SetPos(0,0)
			invNavBar:SetSize(mainW, mainH * 0.2)
			invNavBar:SetDraggable(false)
			invNavBar:ShowCloseButton(false)
			invNavBar:SetTitle("")
			invNavBar.Paint = function(self, w, h )
				draw.RoundedBoxEx(5, 0, 0, w, h, Color(29,29,35,opacity), true, true, false, false)
				draw.DrawText("Party Invite", "ccfontsmall", w * 0.12, h * 0.16, Color(255,255,255,opacity), TEXT_ALIGN_CENTER)
			end

			-- Creating Close Button
			local invCloseBtn = vgui.Create( "DImageButton", invNavBar)
			invCloseBtn:SetImage("resources/images/whiteCross.png")
			invCloseBtn:SetPos(mainW * 0.93, mainH * 0.024)
			invCloseBtn:SetSize(mainW * 0.054, mainH * 0.14)
			invCloseBtn.DoClick = function(self)
				Party.CloseInv()
			end
			function Party.CloseInv()
				mainInv:Close()
				Party.ShowingInv = false
			end

			-- Creating Accept and Deny Buttons
			local accBtn = vgui.Create("DButton", mainInv)
			accBtn:SetPos(mainW * 0.1, mainH * 0.6)
			accBtn:SetSize(mainW * 0.32, mainH * 0.28)
			accBtn:SetText("Accept")
			accBtn:SetFont("ccfont")
			accBtn:SetTextColor(Color(255,255,255,opacity))
			local barStatus = 0
			local speed = 15
			accBtn.Paint = function(self,w,h)
				if self:IsHovered() then
					self:SetTextColor(Color(200,200,200,opacity))
					barStatus = math.Clamp(barStatus + speed * RealFrameTime(), 0, 1)
				else
					self:SetTextColor(Color(255,255,255,opacity))
					barStatus = math.Clamp(barStatus - speed * RealFrameTime(), 0, 1)
				end
				draw.RoundedBox(5, 0, 0, w, h, Color(26,26,32,opacity))
				draw.RoundedBoxEx(5, 0, h * 0.95, w * barStatus, h * 0.05, Color(51,116,142,opacity), false,false,true,true)
			end
			-- Handling Accept Click 
			accBtn.DoClick = function(self)
				net.Start("PartySys.AcceptInvite")
				net.WriteString(invPartyName)
				net.WriteEntity(invitor)
				net.SendToServer()
				Party.CloseInv()
			end


			local denBtn = vgui.Create("DButton", mainInv)
			denBtn:SetPos(mainW * 0.58, mainH * 0.6)
			denBtn:SetSize(mainW * 0.32, mainH * 0.28)
			denBtn:SetText("Deny")
			denBtn:SetTextColor(Color(255,255,255,opacity))
			denBtn:SetFont("ccfont")
			local barStatus = 0
			local speed = 15
			denBtn.Paint = function(self,w,h)
				if self:IsHovered() then
					self:SetTextColor(Color(200,200,200,opacity))
					barStatus = math.Clamp(barStatus + speed * RealFrameTime(), 0, 1)
				else
					self:SetTextColor(Color(255,255,255,opacity))
					barStatus = math.Clamp(barStatus - speed * RealFrameTime(), 0, 1)
				end
				draw.RoundedBox(5, 0, 0, w, h, Color(26,26,32,opacity))
				draw.RoundedBoxEx(5, 0, h * 0.95, w * barStatus, h * 0.05, Color(51,116,142,opacity), false,false,true,true)	
			end
			denBtn.DoClick = function(self)
				Party.CloseInv()
			end
		end

	end
end)

-- Handling the updating of the party table
net.Receive("PartySys.UpdateParties", function()
	clPartyList = net.ReadTable()
	Party.UpdateEspPlys()
end)


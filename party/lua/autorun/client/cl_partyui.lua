print("Clientside loaded.")
Party = {}
local showingUI = false

--[[
local barStatus = 0
barStatus = math.Clamp(barStatus + speed * RealFrameTime(), 0, 1)
]]

function Party.ShowUI()
	showingUI = true -- Addon knows UI is being shown.

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
	local speed = 20
	opacity = math.Clamp(opacity, 0, 255) -- making sure it doesn't go above the max opacity
	main.Paint = function(self, w, h)
		opacity = opacity + speed -- The groth of the opacity
		draw.RoundedBox(5, 0, 0, w, h, Color(14,14,12,opacity))
	end
	------------------------------------------------------------
	function Party.CloseUI() -- Main UI Close Func
		main:Close()
		showingUI = false
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
		surface.SetDrawColor(26,26,32,opacity)
		surface.DrawRect(0,0, w, h)
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
		surface.DrawRect(0, partyTab:GetTall() * 0.9, partyTab:GetWide() * barStatus, partyTab:GetTall() * 0.1)
	end

	-- Creating Nav Bar	
	local navBar = vgui.Create( "DFrame", main)
	navBar:SetPos(0,0)
	navBar:SetSize(mainW, mainH * 0.065)
	navBar:SetDraggable(false)
	navBar:ShowCloseButton(false)
	navBar:SetTitle("")
	navBar.Paint = function(self, w, h )
		surface.CreateFont( "ccfont", {
			font = "CloseCaption_Bold", 
			extended = false,
			size = 20,
			weight = 600,
			blursize = 0,
			scanlines = 0,
			antialias = true,
		} )
		draw.RoundedBoxEx(5, 0, 0, w, h, Color(29,29,35,opacity), true, true, false, false)
		draw.DrawText("Elite Parties", "ccfont", w * 0.15, h * 0.13, Color(255,255,255,opacity), TEXT_ALIGN_CENTER)
	end
	-- Creating Close Button
	local closeBtn = vgui.Create( "DImageButton", navBar)
	closeBtn:SetImage("resources/images/whiteCross.png")
	closeBtn:SetPos(mainW * 0.93, mainH * 0.014)
	closeBtn:SetSize(mainW * 0.055, mainH * 0.04)
	closeBtn.DoClick = function(self)
		Party.CloseUI()
	end

end


-- Saved hook for the halo function.
--[[
hook.Add("PreDrawHalos", "HaloTest", function()
	for k,v in next, player.GetAll() do
		if v:Health() < 1 then return end
		if v:IsDormant() then return end
		if v:Team() == LocalPlayer():Team() then -- change this
			halo.Add({v}, Color(65, 255, 65), 2, 2, 1, false, true);
		else
			halo.Add({v}, Color(255, 65, 65), 2, 2, 1, false, true);
		end
	end
end);
]]














function Party.Open()

	if showingUI then 
		print("UI Closed")
		Party.CloseUI()
	else 
		print("UI Opened")	
		Party.ShowUI()
	end
end

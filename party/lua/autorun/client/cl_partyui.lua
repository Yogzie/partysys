print("Clientside loaded.")
Party = {}
local showingUI = false
print("test")
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
	local opacity = 0
	local speed = 4
	main.Paint = function(self, w, h)
		opacity = math.Clamp(opacity, 0, 255) -- makign sure it doesn't go above the max opacity
		opacity = opacity + speed -- The groth of the opacity
		draw.RoundedBox(5, 0, 0, w, h, Color(14,14,12,opacity))
	end
	------------------------------------------------------------
	function Party.CloseUI() -- Main UI Close Func
		main:Close()
		showingUI = false
	end


end




















function Party.Open()

	if showingUI then 
		print("UI Closed")
		Party.CloseUI()
	else 
		print("UI Opened")	
		Party.ShowUI()
	end
end

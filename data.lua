
local composer = require("composer")
local widget = require("widget")
local m = {}

--screen coordinates for 
m.aiSlotPositions = {
	{x = 47.5, y = 37.5},
	{x = 47.5, y = 72.5},
	{x = 47.5, y = 107.5},
	{x = 47.5, y = 142.5},
	{x = 47.5, y = 177.5},
	{x = 47.5, y = 37.5},
	{x = 82.5, y = 37.5},
	{x = 117.5, y = 37.5},
	{x = 152.5, y = 37.5},
	{x = 187.5, y = 37.5}
}
 m.playerSlotPositions = {
	{x = 47.55, y = 277.5},
	{x = 47.5, y = 312.5},
	{x = 47.5, y = 347.5},
	{x = 47.5, y = 382.5},
	{x = 47.5, y = 417.5},
	{x = 47.5, y = 277.5},
	{x = 82.5, y = 277.5},
	{x = 117.5, y = 277.5},
	{x = 152.5, y = 277.5},
	{x = 187.5, y = 277.5}

}

m.w = display.contentCenterX
m.h = display.contentCenterY
m.w_ = display.contentWidth
m.h_ = display.contentHeight

m.options = {effect = "fade",time = 300}


function m.buttonHandler(event)
	if(event.phase == "ended")then
	   if(event.target.id == "play")then
	   	composer.gotoScene("game",m.options)
	   end
	end
end

return m
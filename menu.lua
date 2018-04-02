local composer = require('composer')
local sceneName = ...
local scene = composer.newScene(sceneName)
local data = require("data")
local widget = require("widget")

function scene:create(event)
	local sceneGroup = self.view
	local bg = display.newImage("Images/menu.png",data.w,data.h)
	local playButton = widget.newButton{
	label = "Play",
	font = "BigBook-Heavy",
	fontSize = 16,
	labelColor = {default = {1,128/255,0,0.8}, over = {1,128/255,0,0.2}},
	id = "play",
	textOnly = true,
	onEvent = data.buttonHandler
}
    playButton.x,playButton.y = data.w,data.h
	sceneGroup:insert(bg)
	sceneGroup:insert(playButton)
end 
function scene:show(event)
	local sceneGroup = self.view
	if(event.phase == "will")then

	elseif(event.phase == "did")then

	end
end
function scene:hide(event)
	local sceneGroup = self.view
	if(event.phase == "will")then

	elseif(event.phase == "did")then

	end
end
function scene:destroy(event)
	local sceneName = self.view
end

scene:addEventListener("create",scene)
scene:addEventListener("show",scene)
scene:addEventListener("hide",scene)
scene:addEventListener("destroy",scene)

return scene
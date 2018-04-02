local composer = require('composer')
local sceneName = ...
local scene = composer.newScene(sceneName)
local data = require("data")
local widget = require("widget")
local physics = require("physics")
physics.start()
physics.setDrawMode("normal")

--store some game elements in groups for efficient clean up
local playerSet = {}
local aiSet = {}
local aiChips = {}
local cardSet = {}

--scores
local playerScore = 0
local opponentScore = 0
local playerScoreText
local opponentScoreText

--variables to build a grid-like layout
local slotWidth = 30
local slotHeight = 30
local colSpace = 5
local rowSpace = 5
local numCols = 5
local numRows = 5

local isGameActive = false
--stores the pool of numbers that exist in the game
local numbers = {}
local callNumber = 0
--raycast variables
local horizontalIndex = 1
local verticalIndex = 1
local diagonal1Index = 1
local diagonal2Index = 1

local chirp = audio.loadStream("chirp.wav")

function remove(mTable,position) table.remove(mTable,position) end

--populate bingo cards with data
function populate(table)
	--prepare data to populate the bingo cards
	if(table == "columns")then
		 col1 = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15}
		 col2 = {16,17,18,19,20,21,22,23,24,25,26,27,28,29,30}
		 col3 = {31,32,33,34,35,36,37,38,39,40,41,42,43,44,45}
	     col4 = {46,47,48,49,50,51,52,53,54,55,56,57,58,59,60}
		 col5 = {61,62,63,64,65,66,67,68,69,70,71,72,73,74,75}
    --fill pool to pick numbers to call
	elseif(table == "numbers")then
         for i=1,75 do numbers[i] = i end
	end
end

local function resetGame(event)
--clean up data, reset buttons to default 
	
	for i=1,#cardSet do display.remove(cardSet[i]) end
	timer.cancel(t)

	button1.id = "new"
	button1:setLabel("New")
	button1:setEnabled(true)

	event.target.id = "start"
	event.target:setLabel("Start")
	isGameActive = false
end

--This function handles all button clicks in the game
--makeCard(x,y,z) is a function written to handle player/ai bingo cards
function buttonHandler(event)
	if(event.phase == "ended")then
	  if(event.target.id == "new")then
	  	--create player and ai cards
	  	makeCard(data.h/2,"player",playerSet)
	  	makeCard(data.h/2*-1,"ai",aiSet)
	  	--change button label
	  	event.target.id = "shuffle"
	  	event.target:setLabel("shuffle")
	  elseif(event.target.id == "shuffle")then
	  	--clean card data since we need new data when we shuffle cards
	  	for i=1,#cardSet do display.remove(cardSet[i]) end
	  	makeCard(data.h/2,"player",playerSet)
	  	makeCard(data.h/2*-1,"ai",aiSet)
	  elseif(event.target.id == "start")then
	  	--game starts, disable shuffle button and start calling numbers
	  	event.target:setLabel("Reset")
	  	event.target.id = "reset"
	  	button1:setEnabled(false)
	  	local callChip = createChip()
	  	isGameActive = true
	  elseif(event.target.id == "reset")then
	  	resetGame(event)
	  end
	end
end

function createButtons(parent)
	button1 = widget.newButton{
	label = "New",
	font = "BigBook-Heavy",
	fontSize = 16,
	labelColor = {default = {1,128/255,0,0.5}, over = {1,128/255,0,0}},
    shape = "roundedRect",
    width = 90,
    height = 40,
    fillColor = {default = {0,0,0,0.3}, over = {0,0,0,0}},
    id = "new",
    isEnabled = true,
    onEvent = buttonHandler
}
    button1.x,button1.y = data.w_-50,data.h-(data.h/2)

    button2 = widget.newButton{
	label = "Start",
	font = "BigBook-Heavy",
	fontSize = 16,
	labelColor = {default = {1,128/255,0,0.5}, over = {1,128/255,0,0}},
    shape = "roundedRect",
    width = 70,
    height = 40,
    fillColor = {default = {0,0,0,0.3}, over = {0,0,0,0}},
    id = "start",
    isEnabled = true,
    onEvent = buttonHandler
}
    button2.x,button2.y = data.w_-50,data.h-(data.h/2*-1)

    parent:insert(button1)
    parent:insert(button2)
end

--places bingo chips on the card when possible and generates numbers to call
function createChip()
	--create a call chip image on the middle left of the screen - this is where the number calls are displayed
	local callchip = display.newImage("Images/chip.png",data.w_-50,data.h)
	cardSet[#cardSet+1] = callchip
	populate("numbers")
	--pick out a random number from the call pool and display it on the screen
	local rand = math.random(1,#numbers)
	local numberInTable = numbers[rand]
	local call = display.newText(numberInTable,callchip.x,callchip.y,"Becker",25)
	callNumber = numberInTable
	--remove the selected number out of the pool
	remove(numbers,rand)
	cardSet[#cardSet+1] = call

	--this function updates the number calls and also handles the ai 
	local ind,num
	function random()
       ind = math.random(1,#numbers)
       num = numbers[ind]
       call.text = num
       callNumber = num
       remove(numbers,ind)
       audio.play(chirp)

       if(isGameActive == true)then
       	 for i=1,#aiSet do
	       	 if(aiSet[i].value == callNumber and aiSet[i].tapped == false)then
		       	 	local chip = display.newImage("Images/chip.png",aiSet[i].x,aiSet[i].y)
					physics.addBody(chip,"static",{radius = 10})
			    	chip.xScale,chip.yScale = 0.20,0.20
			    	cardSet[#cardSet+1] = chip
			    	aiChips[#aiChips+1] = chip
			    	aiSet[i].tapped = true
	       	   end
           end
       end
       --checking for bingo events for the ai
       rayCast(data.playerSlotPositions)
	end
	-- a number call is made every 5 seconds
	t = timer.performWithDelay(5000,random,74)
end

function isTapped(event)
	if(isGameActive == true)then
		if(event.target.tapped == false and event.target.value == callNumber)then
			local chip = display.newImage("Images/chip.png",event.target.x,event.target.y)
			physics.addBody(chip,"static",{radius = 10})
	    	chip.xScale,chip.yScale = 0.20,0.20
	    	cardSet[#cardSet+1] = chip
	    	playerSet[#playerSet+1] = chip
	    	rayCast(data.aiSlotPositions)
	    	event.target.tapped = true
		end
	end
end

--create bingo cards for player and ai
--parameters:
--pos - x,y coordinates on the screen   Type - player/ai   table - a table to store all elements associated with the set
function makeCard(pos,Type,table)
   local card = display.newImage("Images/card.png",data.w-42.5,data.h-pos)
   card.xScale,card.yScale = 0.66,0.66
   card.stroke = {0,0,0}
   card.strokeWidth = 3
   cardSet[#cardSet+1] = card
   table[#table+1] = card
  
  --get position for the grid
  local xPos = (data.w - (numCols * slotWidth + numCols * colSpace) / 2) - 40
  local yPos = (data.h - (numRows * slotHeight + numRows * rowSpace) / 2)-(pos+10)

  populate("columns")

   for col=1,numCols do
   	for row=1,numRows do
   		local slot = display.newRect(100,100,slotWidth,slotHeight)
   		slot.x = xPos + col * (slotWidth + colSpace) - slotWidth/2 - colSpace
        slot.y = yPos + row * (slotHeight + rowSpace) - slotHeight/2 - rowSpace
        slot.stroke = {0,0,0}
        slot.strokeWidth = 1.5
        cardSet[#cardSet+1] = slot
        table[#table+1] = slot

	    	local index,rand, c = nil,nil,nil
	    	--populate the slots with numbers based on their column number
	    	if(col == 1)then
	    		index = math.random(1,#col1)
	    		rand = col1[index]
	    		c = col1
	    	elseif(col == 2)then
	    		index = math.random(1,#col2)
	    		rand = col2[index]
	    	    c = col2
	    	elseif(col == 3)then
	    		index = math.random(1,#col3)
	    		rand = col3[index]
	    	    c = col3
	    	elseif(col == 4)then
	    		index = math.random(1,#col4)
	    		rand = col4[index]
	    	    c = col4
	    	elseif(col == 5)then
	    		index = math.random(1,#col5)
	    		rand = col5[index]
	    	    c = col5
	    	end

	    	local values = display.newText(rand,slot.x,slot.y,"Becker",12)
	        values:setFillColor(0,0,0)
	        remove(c,index)
	        slot.value = rand
	        slot.tapped = false
	        cardSet[#cardSet+1] = values
	        table[#table+1] = values
	        --only need a touch listener if card type is "player"
	        if(Type == "player" )then
	        	slot:addEventListener("tap",isTapped)
	        end
   	  end
   end
end

function scene:create(event)
	local sceneGroup = self.view
	isGameActive = false

	local bg = display.newImage("Images/game.png",data.w,data.h)
	sceneGroup:insert(bg)

	local buttons = createButtons(sceneGroup)
    text = display.newText("",data.w,data.h-(data.h/2),"BigBook-heavy",25)
	text.alpha = 0
	text:setFillColor(1,0,0)

    playerScoreText = display.newText("myScore: 0",data.w-(data.w-30),data.h-(data.h+30),native.systemFont,10)
    opponentScoreText = display.newText("opponentScore: 0", data.w_-100,playerScoreText.y,native.systemFont,10)

	sceneGroup:insert(text)
	sceneGroup:insert(playerScoreText)
	sceneGroup:insert(opponentScoreText)
end 

local function endGame()
	isGameActive = false
	timer.cancel(t)
	button2:setLabel("New")
end
local function drawLine(x1,y1,x2,y2)
	local line = display.newLine(x1,y1,x2,y2)
	line:setStrokeColor(0,0,0)
	line.strokeWidth = 5
	cardSet[#cardSet+1] = line	
end
local function updateScore(table)
	if(table == data.aiSlotPositions)then
		opponentScore = opponentScore+5
		opponentScoreText.text = "opponentScore: "..opponentScore
	--[[for j=1,#aiSet do display.remove(aiSet[j]) end
	    for k=1,#aiChips do display.remove(aiChips[k]) end
		text.text = "Bingo, You Win"
		text.alpha = 1
		text.x = data.w
		text.y = data.h - (data.h/2*-1)--]]
	else
		playerScore = playerScore+5
		playerScoreText.text = "opponentScore: "..playerScore
	--[[for j=1,#playerSet do display.remove(playerSet[j]) end
		text.text = "Bingo, You Lose"
		text.alpha = 1
		text.x = data.w
		text.y = data.h - (data.h/2)--]]
	end	
end

--function that handles detecting any bingo events, table is a table of coordinates of number slots to help build our raycast physics
function rayCast(table)
	--set up horizontal raycasts for each column
	for i=1,5 do
		local horizontalRay = physics.rayCast(table[i].x-25,table[i].y,220,table[i].y,"unsorted")
		cardSet[#cardSet+1] = horizontalRay

		if(horizontalRay)then
			
			--5 hits = bingo achieved
			if(#horizontalRay >= 5)then
				--display a line across the bingo region 
				drawLine(table[i].x-25,table[i].y,220,table[i].y)
				updateScore(table)
				index = index*2
			
				
			end
		end
	end
	for i=6,10 do
		local verticalRay = physics.rayCast(table[i].x,table[i].y-25,table[i].x,table[i].y+175,"unsorted")
		cardSet[#cardSet+1] = verticalRay
		if(verticalRay)then
			if(#verticalRay>=5)then

				drawLine(table[i].x,table[i].y-25,table[i].x,table[i].y+175)
				updateScore(table)
				
				
				

			end
		end
	end
	
	
	local diagonalRay1 = physics.rayCast(table[1].x-25,table[1].y-25,table[10].x+25,table[5].y+25,"unsorted")
	cardSet[#cardSet+1] = diagonalRay1
	if(diagonalRay1)then
		
		if(#diagonalRay1>=5)then
			
			drawLine(table[1].x-25,table[1].y-25,table[10].x+25,table[5].y+25)
			updateScore(table)
	
		
		end
	end

	
	local diagonalRay2 = physics.rayCast(table[10].x+25,table[10].y-25,table[5].x-25,table[5].y+25,"unsorted")
	cardSet[#cardSet+1] = diagonalRay2
	if(diagonalRay2)then
		if(#diagonalRay2>=5)then
			
			drawLine(table[10].x+25,table[10].y-25,table[5].x-25,table[5].y+25)
			updateScore(table)
		

		end
	end

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
-- app/jday/scenes/TestSlide.lua
local Class = class.define("app.jday.scenes.TestSlide", {"bma.mgr.SceneBase"})

function Class:create()
	
	local this = self
	local winSize = director:winSize()
	
	local block1 = director:createObject("CCLayerColor", {
		color = {255,0,0},
		contentSize = {400, 400},
		position = {200, winSize.height/2-200},
		onEvent = {
			slide = function(o, ename, ev)
				var_dump(ev)
			end,
			pan = function(o, ename, ev)
				var_dump(ev)
			end,
		}
	});
	
	local layer = director:createObject("CCELayerTouch", {})	
	layer:addChild(block1)
	director:layout(layer, false)
	
	layer:enableTouch(block1, "pan", nil)	
	
	return layer
	
end


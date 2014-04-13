-- app/jday/scenes/TestActivity.lua
local Class = class.define("app.jday.scenes.TestActivity", {"bma.mgr.SceneBase"})

function Class:create()
	
	local this = self
	
	local block1 = director:createObject("CCLayerColor", {
		color = {255,0,0},
		contentSize = {300, 400},
		onEvent = {
			tap = function()
				this:testCloud()
			end
		},
		layout = { align="middle", valign="center" },
	});
	
	local layer = director:createObject("CCELayerTouch", {})	
	layer:addChild(block1)
	director:layout(layer, false)
	
	layer:enableTouch(block1, "tap")	
	
	return layer
	
end

function Class:testCloud()
	local TEST = 1
	if TEST==1 then
		local cloud = ACTIVITY("cloud")
		cloud:sessionAccept(nil, function(r)
			print("cloud sessionAccept =>", sid)
		end)		
	end	
end
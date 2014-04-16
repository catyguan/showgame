-- app/jday/scenes/TestESNP.lua
require("bma.lang.ext.Dump")

local Class = class.define("app.jday.scenes.TestESNP", {"bma.mgr.SceneBase"})

function Class:create()
	
	local this = self
	
	local block = director:createObject("CCLayerColor", {
		color = {255,0,0},
		contentSize = {600, 400},
		layout = { align="middle", valign="center" },
		onEvent = {
			tap = function()
				this:onClick()
			end
		}
	});
	
	local layer = director:createObject("CCELayerTouch", {})	
	layer:addChild(block)
	director:layout(layer, false)
	
	layer:enableTouch(block, "tap")	

	return layer	
end

function Class:onClick()
	local s = class.instance("bma.esnp.Service")
	local vals = {
		a=1,b=5
	}
	local cb = function(done, res)
		print("esnp callback", done, string.dump(res))		
	end
	s:invoke("test", "add", nil, vals, cb, 1000)
end
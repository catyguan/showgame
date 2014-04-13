-- app/jday/scenes/Logo.lua
local Class = class.define("app.jday.scenes.Logo",{"bma.mgr.SceneBase"})

function Class:create()

	local logo1 = director:createObject("CCSprite", {
		image="logo_me.png",
		layout={align="middle",valign="center"},
		scale=2
	})
	local logo2 = director:createObject("CCSprite", {
		image="logo_cocos2dx.png",
		layout={align="middle",valign="center"},
		visible=false,
		-- scale=0.5
	})
	
	local endScene = function()
		print("end scene")
		_G.GM:logoSceneEnd()
	end

	local layer = director:createObject("CCELayerTouch", {
		onEvent = {
			tap = function()
				print("tap!")
				endScene()
			end
		}
	})
	layer:addChild(logo1)
	layer:addChild(logo2)
	layer:enableTouch(layer, "tap")
	
	director:layout(layer, false)
	
	local f1 = function()
		print("show logo 2")
		logo1:visible(false)
		logo2:visible(true)
		local cfg = {
			"seq",
			{"fadeIn", 1},
			{"delay", 0.5},
			{"call", endScene}
		}
		local act = director:buildAction(cfg)
		logo2:runAction(act)
	end
	local cfg = {
		"seq",
		{"delay", 0.75},
		{"fadeOut", 1},
		{"call", f1}
	}
	local act = director:buildAction(cfg)
	logo1:runAction(act)
	
	-- hostapp.audio:playMusic("Ring06.wav", true)

	return layer
end

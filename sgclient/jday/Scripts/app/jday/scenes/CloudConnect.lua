-- app/jday/scenes/CloudConnect.lua
local Class = class.define("app.jday.scenes.CloudConnect",{"bma.mgr.SceneBase"})

local MESSAGE1 = "服务器连接中，请等待"
local MESSAGE2 = "服务器连接失败！请点击重试"

function Class:create()

	local this = self
	local winSize = director:winSize()
	local layer = director:createObject("CCELayerTouch", {})
	
	local msg = director:createObject("CCLabelTTF", {
		id="message",
		content = MESSAGE1,
		fontName = CONFIG.UI.FontName,
		fontSize = CONFIG.UI.BigTitleFontSize,
		layout = {align="middle", valign="center"}
	})
	layer:addChild(msg)
	self.message = msg
		
	director:layout(layer)
	
	layer:enableTouch(layer, "tap")
	layer:onEvent("tap","mytap", function()
		this:onTap()
	end)
	
	self:connect()
	
	return layer
end

function Class:onTap()
	if self.retry then
		self.message:content(MESSAGE1)
		self:connect()
	end
end

function Class:connect()
	self.retry = false
	
	local game = ACTIVITY("game")
	local cloud = ACTIVITY("cloud")
	local sid = game:sessionId()
	cloud:sessionAccept(sid, function(r)
		if r then
			game:sessionId(r)
			GM:sceneCloudConnectEnd()
		else
			self.message:content(MESSAGE2)
			self.retry = true
		end
	end)	
end

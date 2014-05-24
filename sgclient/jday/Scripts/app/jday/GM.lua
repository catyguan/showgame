-- app/jday/GM.lua
local Class = class.define("app.jday.GM",{"bma.mgr.GMBase"})

function Class:ctor()
	
end

function Class:onDevButtonClick()	
	director:resetApplication()
end

function Class:start()
	if CONFIG.DEV then
		self:beforeRunScene(self:createDevButtonFunction())
	end
	if class.instance("bma.http.client.Service") then
		self:beforeRunScene(self:createHttpClientStatusFunction())
	end
	if class.instance("bma.esnp.Service") then
		self:beforeRunScene(function()
			local s = class.instance("bma.esnp.Service")
			s:cancelTag("scene")
		end)
	end
	self:deployActivity("@bma.mgr.activities.GlobalActivity")
	self:deployActivity("CloudActivity")
	self:deployActivity("GameActivity")
	self:doStart()
end

function Class:doStart()
	-- self:runScene("TestActivity")
	-- self:runScene("CloudConnect")
	-- self:runScene("CharacterSelect")
	self:runScene("TestESNP")
end

function Class:sceneCloudConnectEnd()
	print("end")
end
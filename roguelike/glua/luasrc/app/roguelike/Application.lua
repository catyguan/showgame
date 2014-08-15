-- app/roguelike/Application.lua
local Class = class.define("app.roguelike.Application",{AppClass})

PDDict = {
	event = "cmod.event.common.Event",
}

function Class:ctor()
	self.packageName = "app.roguelike"
end

function Class:init()
	echo("app init")
	if not AppClass.init(self) then
		return false
	end

	local w = class.new("roguelike.world.WorldManager")
	_G.WORLD_MANAGER = w
	
	return true
end

function echo(...)
	print(...)
end

require("app.roguelike.API")
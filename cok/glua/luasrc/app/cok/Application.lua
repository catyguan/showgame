-- app/cok/Application.lua
local Class = class.define("app.cok.Application",{AppClass})
print(AppClass.className)

function Class:ctor()
	self.packageName = "app.cok"
end

function Class:init()
	echo("app init")
	if not AppClass.init(self) then
		return false
	end

	local w = class.new("world.WorldManager")
	_G.WORLD_MANAGER = w
	
	return true
end

function echo(...)
	print(...)
end

require("app.cok.API")
-- app/arena/Application.lua
local Class = class.define("app.arena.Application",{AppClass})
print(AppClass.className)

function Class:ctor()
	self.packageName = "app.arena"
end

function Class:init()
	echo("app init")
	if not AppClass.init(self) then
		return false
	end

	local am = class.new("arena.ArenaManager")
	_G.AM = am
	
	return true
end

function echo(...)
	print(...)
end

require("app.arena.API")
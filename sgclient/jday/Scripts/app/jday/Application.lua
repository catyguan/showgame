-- app/jday/Application.lua
local Class = class.define("app.jday.Application",{AppClass})
print(AppClass.className)

function Class:ctor()
	self.packageName = "app.jday"
end

function Class:init()
	echo("app init")
	if not AppClass.init(self) then
		return false
	end
	
	local gm = class.new(APP_CLASS_NAME("GM"))
	_G.GM = gm
	gm:start()

	return true
end

function echo(...)
	print(...)
end

director = hostapp.director

ACTIVITY = function(id)
	if _G.GM then
		return _G.GM:getActivity(id)
	end
	return nil
end
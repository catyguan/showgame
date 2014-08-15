-- app/roguelike/StoreServiceImpl.lua
require("bma.lang.ext.Json")

local Class = class.define("app.roguelike.StoreServiceImpl", {"service.StoreService"})

function Class:ctor()

end

function Class.install()
	if not instance then instance = Class.new() end		
	class.setInstance("service.StoreService", Class.new())		
end

function Class:load(typ, id, callback)
	local ddir = "../data"
	local fn = ddir.."/"..typ.."_"..id..".json"
	local file = io.open(fn, "r")
	if file==nil then
		callback(false, fn.." not found")
		return
	end
	local str = file:read("*all")
	file:close()
	local data = str:json()
	callback(true, data)
end
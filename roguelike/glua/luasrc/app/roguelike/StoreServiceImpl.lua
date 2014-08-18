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
		fn2 = ddir.."/"..typ.."_"..id.."_sample.json"
		file = io.open(fn2, "r")
	end
	if file==nil then
		callback(false, fn.." not found")
		return
	end
	local str = file:read("*all")
	file:close()
	local data
	if str=="" then 
		data = {}
	else
		data = str:json()
	end	
	callback(true, data)
end

function Class:save(typ, id, data, callback)
	local ddir = "../data"
	local fn = ddir.."/"..typ.."_"..id..".json"
	local file = io.open(fn, "w")
	if file==nil then
		callback(false, fn.." open fail")
		return
	end
	local str = ""
	if data~=nil then str = table.json(data) end
	file:write(str)
	file:close()
	callback(true)
end
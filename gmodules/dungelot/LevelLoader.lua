-- dungelot/ui/LevelLoader.lua
local Class = class.define("dungelot.LevelLoader")

function Class.newCell(data)
	local cls = class.forName("dungelot.Cell"..data._p)
	return cls.newCell(data)
end

function Class.load(name, dg, callback)
	if callback==nil then
		callback = function(done)
		end
	end
	local ss = class.instance("service.StoreService")
	local cb = function(done, data)
		if done then			
			if data.cells then
				for _,c in ipairs(data.cells) do
					local co = Class.newCell(c)
					dg:setCell(c.x, c.y, co)
				end
			end
			local dc = data.default
			if dc~=nil then
				local cls = class.forName("dungelot.Cell"..dc._p)
				dg:fillDefault(cls)
			end
		end
		callback(done)
	end
	ss:load("dungelot", name, cb)
end
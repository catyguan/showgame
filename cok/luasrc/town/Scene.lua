-- town/Scene.lua
local Class = class.define("town.Scene", {"world.Scene"})

--[[
prop:
town: {
	towns : {
		[id] : {
	
		},
		...
	}
}
runv:
]]
function Class.getTown(tid)
	local world = WORLD
	local ts = world:prop({"town", "towns"})
	if ts==nil then
		return nil
	end
	if tid==nil then
		for _,t in pairs(ts) do
			return t
		end
	end
	return ts[tid]
end

function Class.doList(tid)
	local ts = Class.getTown(tid)
	return ts
end

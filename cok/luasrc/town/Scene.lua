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
function Class.getTown(world, tid)
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

function Class.doList(world, tid)
	local ts = Class.getTown(world, tid)
	return ts
end

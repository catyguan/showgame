-- dungelot/ui/DungeonBuilder.lua
local Class = class.define("dungelot.DungeonBuilder")

function Class.pval(n, v, p1, p2)
	if p1 then
		local v1 = p1[n]
		if not v1 then return v1 end
	end
	if p2 then
		local v2 = p2[n]
		if not v2 then return v2 end
	end
	return v
end
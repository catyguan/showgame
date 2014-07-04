-- world/Faction.lua
local Class = class.define("world.Faction")

local ALLMAP
local ALL = {
	"cmod.pack.base.FactionHumanTemple",
}
local INIT = function( ... )
	if not ALLMAP then
		ALLMAP = {}
		for i,n in ipairs(ALL) do
			local cls = class.forName(n)
			ALL[i] = cls
			ALLMAP[cls.PROFILE.id] = cls
		end
	end
end
function Class.All()
	INIT()
	return ALL
end

function Class.getFaction(id)
	INIT()
	return ALLMAP[id]
end
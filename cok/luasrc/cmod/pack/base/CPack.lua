-- cmod/pack/base/CPack.lua
local Class = class.define("cmod.pack.base.CPack", {"cmod.ContentPack"})

local LDEBUG = LOG:debugEnabled()
local LTAG = "BasePack"

function Class.queryRegionFactory()
	return function( ... )
		local region = {}
		region.title = "Region" .. math.random(100)
		region.terrain = "forest"
		region.difficult = "easy"
		region.size = 5
		return {_p="adventure.NormalRegion", data=region}
	end
end
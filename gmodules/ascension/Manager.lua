-- ascension/Manager.lua
local Class = class.define("ascension.Manager")

local LDEBUG = LOG:debugEnabled()
local LTAG = "DungelotManager"

function Class:newCombatd()
	local o = class.new("ascension.Combatd")
	return o
end
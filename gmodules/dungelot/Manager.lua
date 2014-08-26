-- dungelot/Manager.lua
local Class = class.define("dungelot.Manager")

local LDEBUG = LOG:debugEnabled()
local LTAG = "DungelotManager"

function Class:newDungeon()
	local o = class.new("dungelot.Combatd.lua")
	return o
end
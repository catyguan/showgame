-- arena/Creature.lua
require("bma.lang.Class")
require("arena.BattleUnit")

local Class = class.define("arena.Creature", {"bma.lang.StdObject", "arena.BattleUnit"})

local LDEBUG = LOG:debugEnabled()
local LTAG = "Creature"

function Class:ctor()
	ecall.add(self, "onInitProp", function(self, prop )
		self:init_Creature(prop)
	end)
end

function Class:id()
	return self:attr("id")
end

function Class:dstr()
	return string.format("O:%s", self:id())
end

function Class:init_Creature(prop)
	self:attr("id", prop.id)
	self:attr("title", prop.title)
end
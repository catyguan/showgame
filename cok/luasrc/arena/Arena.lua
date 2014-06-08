-- arena/Arena.lua
require("bma.matrix.Matrix")
require("arena.Map")

local Class = class.define("arena.Arena", {"bma.matrix.Matrix"})

local LDEBUG = LOG:debugEnabled()
local LTAG = "Arena"

--[[
Arena Runtime:
randVer:int -- default 1
randSeed:int -- rand seed,default 0
]]

function Class:ctor()
	self.id = 0
	self.randVer = 1
	self.randPos = 0

    self.events = {}
    self.eventId = 0

    self.map = arena.Map.new()
    self.events = class.new("bma.lang.Events")
end

function Class:rand(ver, pos)
	require("arena.Rand"..ver)
	local f = _G["arena_rand"..ver]
	return f(pos)
end

function Class:nextInt(m,n)
	local pos = self.randPos
	self.randPos = self.randPos + 1
	local v = self:rand(self.randVer, pos)
	return v%(m-n)+n
end

-- <<events>>
function Class:addEvent(typ, data)
	local id = self.eventId + 1
	self.eventId = id
	local ev = {id=id, tm=self.time,ty=typ, d=data}
	table.insert(self.events, ev)
end

-- <<helper>>
function Class:addObjectProp( prop )
	otype = prop.objectClass
	local o = class.new(otype)
	ecall.call(o, "onInitProp", prop)
	var_dump(o)
	self:addObject(o)
	return true
end

require("arena.ArenaWorld")
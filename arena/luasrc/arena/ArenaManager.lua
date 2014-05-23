-- arena/ArenaManager.lua
local Class = class.define("arena.ArenaManager")

local aidk = function(aid)
	return "a"..aid
end

function Class:ctor()
	self.arenas = {}
	self.seqId = 1
end

function Class:newArena()
	LOG:debug("ArenaManager","new arena "..self.seqId)

	local a = class.new("arena.Arena")
	a:initObject()
	a.id = self.seqId
	self.seqId = self.seqId + 1

	self.arenas[aidk(a.id)] = a
	
	return a
end

function Class:getArena( aid )
	return self.arenas[aidk(aid)]
end

function Class:closeArena( aid )
	LOG:debug("ArenaManager","close arena "..aid)
	self.arenas[aidk(aid)] = nil
end
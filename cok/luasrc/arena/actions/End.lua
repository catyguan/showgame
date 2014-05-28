-- arena/actions/End.lua

local Class = class.define("arena.actions.End")

function Class:ctor()
end

function Class:executeAction()
	local mt = MT()
	mt:arenaEnd(self.why, self.winner)
end
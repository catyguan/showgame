-- arena/actions/End.lua
-- require("bma.matrix.Action")

local Class = class.define("arena.actions.End")

function Class:ctor()    
end

function Class:executeAction()
	local mt = MT()
	mt:doEnd()
end
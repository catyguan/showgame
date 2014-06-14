-- adventure/Combatd.lua
local Class = class.define("adventure.Combatd")

local LDEBUG = LOG:debugEnabled()
local LTAG = "AdvCombatd"

function Class.newCombat()
	local data ={}
	data.stage = "begin"
	data.chars = {}
	return data
end

function Class.addChar(data, charObj)
	table.insert(data.chars, charObj)
end

function Class.event( data, ev )
	table.insert(data)
end

function Class.process(data)
	for i=1,1000 do
		local f = Class[data.stage]
		if f==nil then
			error(string.format("invalid stage[%s]", data.stage))
		end
		local doNext = f(data)
		if not doNext then
			break
		end
	end
	if LDEBUG then
		LOG:debug(LTAG, "process loop end")
	end
end

function Class.handleUserCommand(data, cmd)
	
end

-- inner flow
function Class.begin(data)
	local o = WORLD
	o:createView("adv_combat", {}, "adventure.ui.Combat",{})
	data.stage = "turnBegin"
	return true
end

function Class.turnBegin( data )
	data.stage = "pBegin"
	return true
end

function Class.pBegin( data )
	data.stage = "pEnd"
	return true
end

function Class.pEnd( data )
	data.stage = "mBegin"
	return true
end

function Class.mBegin( data )
	data.stage = "mEnd"
	return true
end

function Class.mEnd( data )
	data.stage = "turnEnd"
	return true
end

function Class.turnEnd( data )
	data.stage = "turnBegin"
	return true
end

-- map
--[[
B<4><5><6>
B<1><2><3>
**********
A<1><2><3>
A<4><5><6>
]]
-- dungelot/CellEmpty.lua
local Class = class.define("dungelot.CellEmpty", {"dungelot.Cell"})

class.EMPTY = true

function Class.newCell(data)
	local o = Class.new()
	return o
end

function Class:makeViewData()
	return {
		t="em"
	}
end
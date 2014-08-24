-- dungelot/CellEmpty.lua
local Class = class.define("dungelot.CellEmpty", {"dungelot.Cell"})

class.EMPTY = true

function Class:ctor(data)
end

function Class:makeViewData()
	return {
		t="em"
	}
end
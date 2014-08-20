-- dungelot/CellRock.lua
local Class = class.define("dungelot.CellRock", {"dungelot.Cell"})

function Class.newCell(data)
	local o = Class.new()
	return o
end

function Class:makeViewData()
	return {
		t="ro"
	}
end

function Class:onVisible(x, y)	
end
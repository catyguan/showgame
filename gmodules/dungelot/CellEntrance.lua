-- dungelot/CellEntrance.lua
local Class = class.define("dungelot.CellEntrance", {"dungelot.Cell"})

Class.ENTRANCE = true

function Class.newCell(data)
	local o = Class.new()
	o:prop("v", 1)
	o:prop("l", 1)
	return o
end

function Class:makeViewData()
	return {
		t="et"
	}
end
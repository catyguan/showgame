-- dungelot/CellEntrance.lua
local Class = class.define("dungelot.CellEntrance", {"dungelot.Cell"})

Class.ENTRANCE = true

function Class:ctor(data)
	self:prop("v", 1)
	self:prop("l", 1)
end

function Class:makeViewData()
	return {
		t="et"
	}
end
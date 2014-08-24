-- dungelot/CellRock.lua
local Class = class.define("dungelot.CellRock", {"dungelot.Cell"})

Class.ROCK = true

function Class:ctor(data)
end

function Class:makeViewData()
	return {
		t="ro"
	}
end

function Class:onVisible(x, y)	
end
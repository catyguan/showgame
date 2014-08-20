-- dungelot/CellMonster.lua
local Class = class.define("dungelot.CellMonster", {"dungelot.Cell"})

Class.MONSTER = true

function Class.newCell(data)
	local o = Class.new()
	o:prop("mc", data.mc)
	o:prop("mt", data.mt)
	return o
end

function Class:makeViewData()
	return {
		t="mo",
		c=1,
		mt=self:prop("mt")
	}
end

function Class:onVisible(dg, x, y)
	dg:onMonsterShow(x, y)
end

function Class:handleClick(dg, x, y)
	dg:uiEvent({t="msg", text="You Kill It"})
	dg:somethingGone(x, y)
end
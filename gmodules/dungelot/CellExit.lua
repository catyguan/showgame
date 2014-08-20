-- dungelot/CellExit.lua
local Class = class.define("dungelot.CellExit", {"dungelot.Cell"})

function Class.newCell(data)
	local o = Class.new()
	o:prop("lock", data.lock)
	return o
end

function Class:makeViewData()
	local r = {
		c=1
	}
	if self:prop("lock") then
		r.t = "lock"
	else
		r.t = "out"
	end
	return r
end

function Class:handleClick(dg, x, y)
	if self:prop("lock") then
		dg:uiEvent({t="msg", text="Find The Key"})
		return
	end
end
-- dungelot/CellExit.lua
require("service.PDCall")

local Class = class.define("dungelot.CellExit", {"dungelot.Cell"})

function Class.newCell(data)
	local o = Class.new()
	o:prop("lock", data.lock)
	o:prop("onExit", data.onExit)
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
	local pd = self:prop("onExit")
	dg:doCall(pd)
end
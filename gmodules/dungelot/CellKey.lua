-- dungelot/CellKey.lua
local Class = class.define("dungelot.CellKey", {"dungelot.Cell"})

function Class:ctor(data)
end

function Class:makeViewData()
	return {
		t="key",
		c=1
	}
end

function Class:handleClick(dg, x, y)
	local x0,y0,ok
	dg:walk(function(x,y,c)
		if c.EXIT and c:prop("v")==1 then
			x0 = x
			y0 = y
			ok = true
			c:prop("sid", dg:prop("sid"))
			c:prop("lock", false)
			return true
		end
	end)
	if not ok then
		return
	end
	dg:uiEvent({t="doorOpen", x=x0, y=0})
	dg:somethingGone(x, y)
end
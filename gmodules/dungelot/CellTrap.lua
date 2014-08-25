-- dungelot/CellTrap.lua
local Class = class.define("dungelot.CellTrap", {"dungelot.Cell"})

function Class:ctor(data)
	self:prop("dm", data.dm)
end

function Class:makeViewData()
	return {
		t="tr"
	}
end

function Class:onVisible(dg, x, y)
	dg:onVisible(x, y)
	local h = dg:hero()
	h:changeProp("HP", -V(self:prop("dm"),0), dg)
	local hp = h:prop("HP")
	if hp<=0 then
		dg:heroDie()
	end
end
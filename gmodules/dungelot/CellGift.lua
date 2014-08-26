-- dungelot/CellGift.lua
local Class = class.define("dungelot.CellGift", {"dungelot.Cell"})

function Class:ctor(data)
	self:prop("type", data.t)
	self:prop("propn", data.n)
	self:prop("val", data.val)
end

function Class:makeViewData()
	return {
		t=self:prop("type"),
		c=1
	}
end

function Class:handleClick(dg, x, y)
	if V(self:prop("val"),0)>0 then
		local hero = dg:hero()
		hero:changeProp(self:prop("propn"), self:prop("val"), dg)
	end
	dg:somethingGone(x, y)
end
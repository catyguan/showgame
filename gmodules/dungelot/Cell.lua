-- dungelot/Cell.lua
local Class = class.define("dungelot.Cell", {"bma.lang.StdObject"})

--[[
v:visible, t:type, b:block, l:light, c:clickable
]]
function Class:getViewData()
	local vo
	if self:prop("v")~=1 then
		if self:prop("l")~=1 then
			vo = {t="b"}
		else
			vo = {h=1}
		end
	else
		vo = self:makeViewData()
	end
	vo.b = self:prop("b")
	vo.l = self:prop("l")
	return vo
end

function Class:doVisible(dg, x, y)
	self:prop("v", 1)
	if self.onVisible then
		self:onVisible(dg, x, y)
	else
		dg:onVisible(x, y)
	end
end

function Class:doClick(dg, x, y)
	if not self:prop("v") then
		self:doVisible(dg, x, y)
		return true
	end

	if self.handleClick then
		return self:handleClick(dg, x, y)
	end
	return false
end
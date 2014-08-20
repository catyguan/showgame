-- dungelot/Cell.lua
local Class = class.define("dungelot.Cell", {"bma.lang.StdObject"})

--[[
v:visible, t:type, b:block, l:light, c:clickable
]]
function Class:getViewData()
	local vo
	if self:prop("v")~=1 then
		local h = 1
		vo = {h=h}
	else
		vo = self:makeViewData()
	end
	vo.b = self:prop("b")
	vo.l = self:prop("l")
	return vo
end

function Class:doClick(dg, x, y)
	if not self:prop("v") then
		self:prop("v", 1)
		if self.onVisible then
			self:onVisible(dg, x, y)
		else
			dg:onVisible(x, y)
		end
		return true
	end

	if self.handleClick then
		return self:handleClick(dg, x, y)
	end
	return false
end
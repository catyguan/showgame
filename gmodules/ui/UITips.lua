-- ui/UITips.lua
local Class = class.define("ui.UITips")

function Class:uiTips(ev)	
	local tips = self:prop("tips")
	if tips==nil then
		tips = {}
		self:prop("tips", tips)
	end
	table.insert(tips, ev)
end

function Class:uiGetTips()
	local r
	local tips = self:prop("tips")
	if tips~=nil then
		if #tips>0 then
			r = tips[1]
		end
	end
	return r
end

function Class:uiEndTips()
	local r = false
	local tips = self:prop("tips")
	if tips~=nil then
		if #tips>0 then
			table.remove(tips, 1)
			if #tips==0 then
				self:removeProp("tips")
			else
				r = true
			end
		end
	end
	return r
end
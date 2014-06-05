-- world/PDVM.lua

--[[
data = {_p=xxxx, ....}
]]
function PDCall( data, method, ... )
	local p = data["_p"]
	if p==nil then error("PDCall prototype empty") end
	if _G.PDLookup~=nil then
		p = _G.PDLookup(p)
	else
		if _G.PDDict~=nil then
			local xp = _G.PDDict[p]
			if xp~=nil then p = xp end
		end
	end
	local cls = class.forName(p)
	if cls==nil then error(string.format("PDCall prototype[%s] invalid", p)) end
	local f = cls[method]
	if f==nil or type(f)~="function" then
		error(string.format("PDCall prototype[%s] method[%s] invalid", p, method))
	end
	return f(data, ...)
end
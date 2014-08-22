-- service/PDCall.lua
local Class = class.define("service.PDCall")

function PDCall(pd, ctx)
	if pd==nil then return end
	local p = pd["_p"]
	if _G.PDLookup~=nil then
		p = _G.PDLookup(p)
	else
		if _G.PDDict~=nil then
			local xp = _G.PDDict[p]
			if xp~=nil then p = xp end
		end
	end	
	if p=="return" or p=="wait" then return p end
	local cls = class.forName(p)
	if cls==nil then error(string.format("PDCall prototype[%s] invalid", p)) end
	local f = cls.PDCall
	if f==nil or type(f)~="function" then
		error(string.format("PDCall prototype[%s] 'PDCall' invalid", p))
	end
	return f(pd, ctx)
end
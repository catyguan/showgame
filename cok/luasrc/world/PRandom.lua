-- world/PRandom.lua

--[[
plist = [{p=}, ...]
]]
function PRandom(plist, randf)
	if not randf then randf = math.random end
	local maxp = 0	
	for _,pv in ipairs(plist) do
		maxp = maxp + pv.p
	end
	local vp = randf(maxp)
	-- print("PRandom", maxp, vp)
	for i, pv in ipairs(plist) do
		local p = pv.p
		-- print("PRandom Check", i, p, vp)
		if vp<=p then
			-- print("DFRandom done", i)
			return i
		end
		vp = vp - p
	end
	-- print("DFRandom out")
	return #dplist
end
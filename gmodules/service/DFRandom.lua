-- world/DFRandom.lua

--[[
dplist = [{a=,b=}, ...]
]]
function DFRandom(dplist, sdp, cdp, randf)
	if randf==nil then randf = math.random end
	local xdp = cdp - sdp	
	local minp = 0
	for _,dpv in ipairs(dplist) do
		local p = dpv.a + xdp*dpv.b
		dpv.p = p
		if p<minp then minp = p end		
	end
	local maxp = 0
	for _,dpv in ipairs(dplist) do
		if minp<=0 then
			dpv.p = dpv.p - minp
			if dpv.p<=0 then dpv.p = 1 end			
		end
		maxp = maxp + dpv.p
	end
	local vp = randf(maxp)
	-- vp = maxp
	print("DFRandom", maxp, minp, vp)
	for i, dpv in ipairs(dplist) do
		local p = dpv.p
		print("DFRandom Check", i, p, vp)
		if vp<=p then
			print("DFRandom done", i)
			return i
		end
		vp = vp - p
	end
	print("DFRandom out")
	return #dplist
end
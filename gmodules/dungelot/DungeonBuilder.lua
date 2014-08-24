-- dungelot/DungeonBuilder.lua
local Class = class.define("dungelot.DungeonBuilder")

function Class.pval(n, v, p1, p2)
	if p1 then
		local v1 = p1[n]
		if not v1 then return v1 end
	end
	if p2 then
		local v2 = p2[n]
		if not v2 then return v2 end
	end
	return v
end

function Class.propcp(t1, t2)
	if not t2 then return end
	for k,v in pairs(t2) do
		if not t1[k] then
			t1[k] = v
		end
	end
end

function Class.load(name)
	local r
	local ss = class.instance("service.StoreService")
	local cb = function(done, data)
		r = data 
	end
	ss:load("dungelot", name, cb)
	return r
end
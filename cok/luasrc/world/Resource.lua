-- world/Resource.lua
local Class = class.define("world.Resource")

Class.NUM = 4

RES_GOLD  = "g"
RES_FOOD  = "f"
RES_GOODS = "p"
RES_MAGIC = "m"

RES_KEYS = {"g", "f", "p", "m"}

function Class.newResourcePool(mx)
	local r = {}
	for _,k in ipairs(RES_KEYS) do
		local mv
		if mv then mv = mx[k] end
		if not mv then mv = -1 end
		r[k] = {
			v = 0,
			m = mv
		}
	end
	return r
end

function Class.pay(res, v)
	if res.v>=v then
		res.v = res.v - v
		return true
	end
	return false
end

function Class.modify(res, v)
	res.v = res.v + v
	if res.v <0 then res.v = 0 end
	if res.m>=0 then
		if res.v>res.m then res.v = res.m end
	end
	return res.v
end
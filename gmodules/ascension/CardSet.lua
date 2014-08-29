-- ascension/CardSet.lua
local Class = class.define("ascension.CardSet")

function Class.shuffle(set)
	 local n = #set
	 while n>2 do
		local k = math.random(n)
		set[n], set[k] = set[k], set[n]
		n = n - 1
	 end
end

function Class.draw(set)
	if #set>0 then
		local c = set[1]
		table.remove(set, 1)
		return c
	end
	return nil
end

function Class.moveAll(target, src)
	while #src>0 do
		local c = src[1]
		table.remove(src, 1)
		table.insert(target, c)	
	end
end

function Class.add(set, card)
	table.insert(set, card)
end
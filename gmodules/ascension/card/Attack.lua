-- ascension/card/Attack.lua
local Class = class.define("ascension.card.Attack", {"ascension.Card"})

function Class:ctor(data)

end

function Class:buildView(r)
	r.t = "attack"
end
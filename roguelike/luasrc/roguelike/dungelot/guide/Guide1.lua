-- roguelike/dungelot/guide/Guide1.lua
local Class = class.define("roguelike.dungelot.guide.Guide1", {"dungelot.DungeonBuilder"})

function Class.build(w)
	return Class.load("guide1")
end

function Class.PDCall(pd, dg)
	dg:uiEvent({t="msg", text="The Dungeon is END"})
end
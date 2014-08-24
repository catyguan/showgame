-- roguelike/dungelot/samples/Sample1.lua
local Class = class.define("roguelike.dungelot.samples.Sample1", {"dungelot.DungeonBuilder"})

function Class.build(w)
	return Class.load("test")
end
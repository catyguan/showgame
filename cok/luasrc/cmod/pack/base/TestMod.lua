-- cmod/pack/base/TestMod.lua
local Class = class.define("cmod.pack.base.TestMod", {"cmod.char.CharBase"})

function Class.getProfile()
	return {
		title = "::敌人甲",
		pic = "images/head2.png"
	}
end
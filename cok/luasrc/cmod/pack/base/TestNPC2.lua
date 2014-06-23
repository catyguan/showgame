-- cmod/pack/base/TestNPC2.lua
local Class = class.define("cmod.pack.base.TestNPC2", {"cmod.char.CharBase"})

function Class.getProfile()
	return {
		title="::战士蓝",
		pic="images/head0.png"
	}
end
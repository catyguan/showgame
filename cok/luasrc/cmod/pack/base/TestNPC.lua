-- cmod/pack/base/TestNPC.lua
local Class = class.define("cmod.pack.base.TestNPC", {"cmod.char.CharBase"})

function Class.getProfile()
	return {
		title="::战士红",
		pic="images/head1.png"
	}
end
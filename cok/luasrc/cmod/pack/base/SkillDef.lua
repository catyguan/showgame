-- cmod/pack/base/SkillDef.lua
local Class = class.define("cmod.pack.base.SkillDef")

function Class.getProfile()
	return {
		title="::防御",
		desc="::恢复自身{DEF}点防盾",
		AP=30,
		CD=2,
		target="self"
	}
end
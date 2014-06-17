-- cmod/pack/base/TestEff.lua
local Class = class.define("cmod.pack.base.TestEff")

function Class.getProfile()
	return {
		title="::防御姿势",
		desc="::每回合恢复自身{XDEF}点防盾，持续{LAST}回合"
	}
end

function Class.copyViewData(des, src)
	des.XDEF = src.XDEF
	des.LAST = src.LAST
end
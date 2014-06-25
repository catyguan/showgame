-- cmod/pack/base/EffSlow.lua
local Class = class.define("cmod.pack.base.EffStun", {"cmod.basetype.EffBase"})

function Class.getProfile()
	return {
		title="::眩晕",
		pic="images/eff_stun.png",
		desc="::无法行动，持续{LAST}回合"
	}
end

function Class.newEff(last)
	return {
		_p = Class.className,
		LAST = last
	}
end

function Class.copyViewData(des, src)
	des.LAST = src.LAST
end

function Class.apply(cbc, cbdata, eff, ch)
	cbc.applyFlag(cbdata, ch, "FLAG_STUN")
end

function Class.remove(cbc, cbdata, eff, ch)
	cbc.removeFlag(cbdata, ch, "FLAG_STUN")
end

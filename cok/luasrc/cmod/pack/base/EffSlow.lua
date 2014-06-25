-- cmod/pack/base/EffSlow.lua
local Class = class.define("cmod.pack.base.EffSlow", {"cmod.basetype.EffBase"})

function Class.getProfile()
	return {
		title="::缓慢",
		pic="images/eff_slow.png",
		desc="::减少{XSPD}点速度，持续{LAST}回合"
	}
end

function Class.newEff(v, last)
	return {
		_p = Class.className,
		XSPD = v,
		LAST = last
	}
end

function Class.copyViewData(des, src)
	des.XSPD = src.XSPD
	des.LAST = src.LAST
end

function Class.apply(cbc, cbdata, eff, ch)
	cbc.modifyProp(cbdata, ch, "SPD", -eff.XSPD)
end

function Class.remove(cbc, cbdata, eff, ch)
	cbc.modifyProp(cbdata, ch, "SPD", eff.XSPD)
end

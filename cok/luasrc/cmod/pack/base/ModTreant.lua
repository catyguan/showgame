-- cmod/pack/base/ModTreant.lua
local Class = class.define("cmod.pack.base.ModTreant", {"cmod.basetype.CharBase"})

function Class.newChar(lvl)
	local r = {
		HP=585,
		STR=166,
		SKL=55,
		DEF=96,
		SPD=88,
		skills = {
			{ _p = "cmod.pack.base.SkillAttack", lvl = 1 }
			-- { _p = "cmod.pack.base.SkillStunHit", lvl = 1 }			
		}
	}
	Class.levelUp(r, lvl, {
		HP=0.2,
		STR=0.1,
		DEF=0.25
	})
	return r
end

function Class.getProfile()
	return {
		title = "::树人",
		pic = "images/mod_treant.png",
		xtype = "DEF",
		mod = true
	}
end
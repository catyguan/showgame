-- cmod/pack/base/ModSlime.lua
local Class = class.define("cmod.pack.base.ModSlime", {"cmod.basetype.CharBase"})

function Class.newChar(lvl)
	local r = {
		HP=450,
		STR=160,
		SKL=60,
		DEF=120,
		SPD=102,
		skills = {
			{ _p = "cmod.pack.base.SkillAttack", lvl = 1 }		
			-- { _p = "cmod.pack.base.SkillDelayHit", lvl = 1 }			
		}
	}
	Class.levelUp(r, lvl, {
		HP=0.1,
		STR=0.1,
		SKL=0.1,
		DEF=0.2
	})
	if lvl>10 then
		r.skills[1].lvl = 2
	end
	return r
end

function Class.getProfile()
	return {
		title = "::史莱姆",
		pic = "images/mod_slime.png",
		xtype = "DEF",
		mod = true
	}
end
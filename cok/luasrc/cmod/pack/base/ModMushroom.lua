-- cmod/pack/base/ModMushroom.lua
local Class = class.define("cmod.pack.base.ModMushroom", {"cmod.basetype.CharBase"})

function Class.newChar(lvl)
	local r = {
		HP=640,
		STR=192,
		SKL=60,
		DEF=64,
		SPD=104,
		skills = {
		{ _p = "cmod.pack.base.SkillAttack", lvl = 1 }	
			-- { _p = "cmod.pack.base.SkillToxinHit", lvl = 1 }			
		}
	}
	Class.levelUp(r, lvl, {
		HP=0.1,
		STR=0.2,
		SKL=0.1,
		DEF=0.1
	})
	if lvl>10 then
		r.skills[1].lvl = 2
	end
	return r
end

function Class.getProfile()
	return {
		title = "::蘑菇怪",
		pic = "images/mod_mushroom.png",
		xtype = "ATTACK",
		mod = true
	}
end
-- dungelot/Mod.lua
local Class = class.define("dungelot.Mod", {"bma.lang.StdObject"})

function Class:ctor(data)
	if data then
		self:prop("HP", V(data.HP, 1))
		self:prop("MAXHP", data.MAXHP)
		self:prop("POWER", V(data.POWER, 0))
		self:prop("DEF", V(data.DEF, 0))
	end
end

function Class:addMaxHP(v, dg)
	self:changeProp("MAXHP", v, dg)
	self:changeProp("HP", v, dg)
end

function Class:setProp(n, v, dg)
	if n=="HP" then
		local v0 = V(self:prop("MAXHP"),0)
		if v0~=0 then
			if v>v0 then v = v0 end
		end
	end
	if v<0 then v = 0 end
	self:prop(n, v)
	if dg then
		self:prop("sid", dg:prop("sid"))
	end
	return v
end

function Class:changeProp(n, v, dg)
	local ov = self:prop(n)
	local nv = v
	if ov~=nil then
		nv = ov + v
	end
	if nv<0 then nv = 0 end
	if ov~=nv then
		return self:setProp(n, nv, dg)
	end
	return ov
end

function Class:doAttack(who, dg)
	local pow = self:prop("POWER")
	local hp = who:prop("HP")
	local def = who:prop("DEF")
	-- print("doAttack", pow, hp, def)
	if pow==0 then
		return
	end
	if def>0 then
		who:changeProp("DEF", -1, dg)
		return
	end
	who:changeProp("HP", -pow, dg)	
	-- print("afterAttack", who:prop("HP"))
	return pow	
end

function Class:isDie()
	local hp = V(self:prop("HP"), 0)
	return hp<=0
end
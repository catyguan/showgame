-- arena/BattleUnit.lua
require("arena.Map")

local Class = class.define("arena.BattleUnit", {"bma.lang.StdObject"})

function Class:ctor()
	ecall.add(self, "onInitProp", function(self, prop )
		self:init_BattleUnit(prop)
	end)
	ecall.add(self, "onArenaStart", function(self, prop )
		self:start_BattleUnit(prop)
	end)
end

function Class:init_BattleUnit(prop)
	local hp = V(prop.HP,0)
	local mhp = V(prop.MHP,0)
	if hp==0 then
		hp = mhp
	end
	if mhp==0 then
		mhp = hp
	end
	self:prop("HP", hp)
	self:prop("MHP", mhp)
	self:prop("PATK", prop.PATK)
	self:prop("SATK", prop.SATK)
	self:prop("PDEF", prop.PDEF)
	self:prop("SDEF", prop.SDEF)

	local ppos = prop.pos
	if ppos~=nil then
		self:prop("pos", arena.MapPos.new(ppos.g, ppos.x, ppos.y))
	end
end

function Class:start_BattleUnit()	
	local mt = MT()
	local map = mt.map
	if not map:set(self) then
		return
	end

	-- begin battle
	if not self:hasProp("PRI") then
		self:prop("PRI", mt:nextInt(100000, 1))
	end

end

function Class:kill_BattleUnit()
	local map = MT().map
	map:unset(self)
end
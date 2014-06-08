-- arena/BattleUnit.lua
require("arena.Map")

local Class = class.define("arena.BattleUnit", {"bma.lang.StdObject"})

function Class:ctor()
	ecall.add(self, "onInitProp", function(self, prop )
		self:init_BattleUnit(prop)
	end)
	ecall.add(self, "onMatrixStart", function(self, prop )
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

	self.events = class.new("bma.lang.Events")
end

function Class:start_BattleUnit()	
	local mt = MT()
	if not mt:summon(self) then
		return
	end

	-- begin battle
	if not self:hasProp("PRI") then
		self:prop("PRI", mt:nextInt(100000, 1))
	end

	self:planBattle(mt:nextInt(1000,1))

end

function Class:kill_BattleUnit()
	local map = MT().map
	map:unset(self)
end

function Class:planBattle(tm)
	local ACT_NAME = "planAction"
	local pa = self:runv(ACT_NAME)
	if pa~=nil then
		pa:cancel()
		self:removeRunv(ACT_NAME, nil)
	end
	local th = self

	pa = class.new("bma.matrix.Action")
	-- pa.LDEBUG = true
	pa.desc = "BattleUnit_doBattle"
	pa.PRI = self:prop("PRI")
	pa.execute = function()
		th:removeRunv(ACT_NAME)
		th:doBattle()
	end
	self:runv(ACT_NAME, pa)
	pa:runDelay(tm)
end

-- <<is>>
function Class:isKO()
	return V(self:prop("HP", 0)) <= 0
end

function Class:isValid()
	if V(self:runv("invalid"), false) then
		return false
	end
	return true
end

function Class:checkKO()

end

-- <<do>>
function Class:doKO()
	MT():unsummon(self)

-- 	function Class:executeAction()
-- 	if self.object~=nil then
-- 		if self.object:isKO() then
-- 			self.object:doDie()
-- 		end
-- 	end
-- end
end

function Class:doBattle()
	local map = MT().map
	map:unset(self)
end
-- dungelot/CellMonster.lua
local Class = class.define("dungelot.CellMonster", {"dungelot.Cell", "dungelot.Mod"})

Class.MONSTER = true

function Class:ctor(data)
	self:prop("mc", data.mc)
	self:prop("mt", data.mt)
	self:prop("haskey", data.haskey)
end

function Class:makeViewData()
	return {
		t="mo",
		c=1,
		mt=self:prop("mt"),
		hp=self:prop("HP"),
		power=self:prop("POWER"),
		def=self:prop("DEF"),
	}
end

function Class:onVisible(dg, x, y)
	dg:onMonsterShow(x, y)
end

function Class:handleClick(dg, x, y)
	self:doBattle(dg, x, y)
end

function Class:doBattle(dg, x, y)
	local hero = dg:hero()
	self:doAttack(hero, dg)
	hero:doAttack(self, dg)

	if hero:isDie() then
		-- end
		dg:uiEvent({t="msg", text="YOU DIE!"})
		return
	end

	if self:isDie() then
		self:onDie(dg, x, y)
	end

end

function Class:onDie(dg, x, y)
	dg:uiEvent({t="msg", text="You Kill It"})
	local cell = nil
	if self:prop("haskey") then
		local data = {
		 	_p = "@Key"
 		}
		cell = dg.newCell(data)
	end
	dg:somethingGone(x, y, cell)
end


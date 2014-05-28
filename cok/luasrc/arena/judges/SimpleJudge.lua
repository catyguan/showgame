-- arena/judges/SimpleJudge.lua
local Class = class.define("arena.judges.SimpleJudge", {})

local LDEBUG = LOG:debugEnabled()
local LTAG = "SimpleJudge"
local CHECK_TIME = 100

function Class:ctor()
	self.maxTime = 30*1000
	self.passTime = 0

	ecall.add(self, "onMatrixStart", function(self, prop )
		self:start_Arena(prop)
	end)
end

function Class:id()
	return "simpleJudge"
end

function Class:dstr()
	return string.format("J:%s", self:id())
end

function Class:start_Arena()
	local mt = MT()
	mt:delayAction(CHECK_TIME, self:newJudgeAction())
end

function Class:newJudgeAction()
	local th = self
	local act = {}
	act.PRI = -100000
	act.desc = "judgeAction"
	act.executeAction = function()
		th:doJudgeAction()		
	end
	return act
end

function Class:doJudgeAction()
	local mt = MT()

	-- check result
	local map = mt.map
	local eATK, eDEF = map:checkEmpty()

	if eATK or eDEF then
		local act = class.new("arena.actions.End")
		act.why = "wipeOut"
		if eATK then
			act.winner = ARENA_GROUP_DEF
		else
			act.winner = ARENA_GROUP_ATK
		end
		mt:nowAction(act)
		return
	end


	self.passTime = self.passTime + CHECK_TIME
	if self.passTime>=self.maxTime then
		local act = class.new("arena.actions.End")
		act.why = "timeEnd"
		act.winner = ARENA_GROUP_DEF
		mt:nowAction(act)
		return
	end

	mt:delayAction(CHECK_TIME, self:newJudgeAction())
end
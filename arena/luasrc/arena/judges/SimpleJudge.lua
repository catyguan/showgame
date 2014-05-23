-- arena/judges/SimpleJudge.lua
local Class = class.define("arena.judges.SimpleJudge", {})

local LDEBUG = LOG:debugEnabled()
local LTAG = "SimpleJudge"

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
	mt:delayAction(1000, self:newJudgeAction())
end

function Class:newJudgeAction()
	local th = self
	local act = {}
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


	self.passTime = self.passTime + 1000
	if self.passTime>=self.maxTime then
		-- time end
		LOG:debug(LTAG, "time end - %d", self.passTime)
		local act = class.new("arena.actions.End")
		mt:nowAction(act)
		return
	end

	mt:delayAction(1000, self:newJudgeAction())
end
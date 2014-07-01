-- adventure/ui/Combat.lua
local Class = class.define("adventure.ui.Combat", {"world.UIControl"})

local LDEBUG = LOG:debugEnabled()
local LTAG = "UI.adv.Combat"

local M = class.forName("adventure.Combatd")

function Class.onProcess(ctx, sid, param)
	if ctx.rt.eid~=tonumber(sid) then
		-- init
		local ev = {id=ctx.rt.eid, k="init"}
		local data = {}
		M.buildInit(ctx, data)
		ev.data = data
		return {ev}
	end
	local dop = true
	if param~=nil then
		dop = M.handleUserCommand(ctx, param)
	end
	if dop then M.process(ctx) end
	local elist = ctx.events
	ctx.events = nil
	ctx.eventg = nil
	return elist
end

function Class.callCheckSkill(ctx, param)
	local skid = param.skill
	local me = param.me
	local target = param.target
	local ok, err = M.checkSkill(ctx, me, skid, target)
	if ok then
		return {ok=true}
	else
		return {ok=false, err=err}
	end
end

-- ui action
function Class.doNextCombat(ctx)
	local rs = M.getCombatResult(ctx)
	if rs==nil then
		return
	end
	
	local ADV = class.forName("adventure.Manager")
	ADV.endCombat(rs)
	ADV.flowProcess()
end
-- combat/ui/Combat.lua
require("world.PDVM")

local Class = class.define("combat.ui.Combat", {"world.UIControl"})

local LDEBUG = LOG:debugEnabled()
local LTAG = "UI.Combat"

local M = class.forName("combat.Combatd")

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

-- ui action
function Class.doNextCombat(ctx)	
	M.finishCombat(ctx)
end
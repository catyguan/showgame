-- world/UIControl.lua
local Class = class.define("world.UIControl")

function Class.canClose(ctx)
	return true
end

function Class.canPause(ctx)
	return true
end

function Class.onEnter(ctx)
end

function Class.onClose(ctx)
end

function Class.onPause(ctx)
end

function Class.onResume(ctx)
end

function Class.onProcess(ctx, sid, param)
end

function Class.viewContext(lvl)
	if lvl==nil then lvl=-1 end
	local w = WORLD
	local vo = w:getView(lvl)
	if vo==nil then error("view stack empty") end
	return vo.context
end
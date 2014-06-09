-- world/UIManager.lua
local Class = class.define("world.UIManager")

local LDEBUG = LOG:debugEnabled()
local LTAG = "UIManager"

function Class:ctor()
end

function Class:getView(lvl)
	local scs = self._prop.views
	if scs==nil then
		self._prop.views = {}
		return nil
	end
	if lvl==-1 then
		lvl = #scs
	end
	if #scs < lvl then
		return nil
	end
	return scs[lvl]
end

function Class:updateViewData(viewName, viewData)
	local vo = self:getView(-1)
	if vo==nil then
		error("view stack empty")
	end
	if vo.name~=viewName then
		return false
	end
	vo.data = viewData
	return true
end

function  Class:changeView(viewName, viewData, ctrl, ctx)
	local vo = self:getView(-1)
	if vo==nil then
		error("view stack empty")
	end
	local sc = class.forName(vo.control)
	if not sc.canClose(vo.context) then
		if LDEBUG then
			LOG:debug(LTAG, "changeView(%s) fail - can't close view[%s]", viewName, vo.name)
		end
		return false
	end

	if LDEBUG then
		LOG:debug(LTAG, "close view[%s]", vo.name)
	end
	sc:onClose(vo.context)

	vo = {
		name = viewName,
		data = viewData,
		control = ctrl,
		context = ctx,
	}
	local scs = self._prop.views
	scs[#scs] = vo

	if LDEBUG then
		LOG:debug(LTAG, "enter view[%s]", viewName)
	end
	local nsc = class.forName(ctrl)
	nsc:onEnter(ctx)
	return true
end

function  Class:createView(viewName, viewData, ctrl, ctx)
	local vo = self:getView(-1)
	if vo~=nil then
		local sc = class.forName(vo.control)
		if not sc.canPause(vo.context) then
			if LDEBUG then
				LOG:debug(LTAG, "createView(%s) fail - can't pause view[%s]", viewName, vo.name)
			end
			return false
		end

		if LDEBUG then
			LOG:debug(LTAG, "pause view[%s]", vo.name)
		end
		sc.onPause(vo.context)
	end

	vo = {
		name = viewName,
		data = viewData,
		control = ctrl,
		context = ctx,
	}
	local scs = self._prop.views
	table.insert(scs, vo)

	if LDEBUG then
		LOG:debug(LTAG, "create view[%s]", viewName)
	end

	local nsc = class.forName(ctrl)
	nsc.onEnter(ctx)
	return true
end

function  Class:closeView(viewName)
	local vo = self:getView(-1)
	if vo==nil then
		return true
	end

	if vo.name~=viewName then
		if LDEBUG then
			LOG:debug(LTAG, "closeView(%s) fail - current view is '%s'", viewName, vo.name)
		end
		return false
	end
	local sc = class.forName(vo.control)
	if not sc.canClose(vo.context) then
		if LDEBUG then
			LOG:debug(LTAG, "closeView(%s) fail - can't close view", vo.name)
		end
		return false
	end

	if LDEBUG then
		LOG:debug(LTAG, "close view[%s]", vo.name)
	end
	sc.onClose(vo.context)

	local scs = self._prop.views
	table.remove(scs, #scs)

	vo = self:getView(-1)
	if vo~=nil then
		if LDEBUG then
			LOG:debug(LTAG, "resume view[%s]", vo.name)
		end
		local nsc = class.forName(vo.control)
		nsc.onResume(vo.context)
	end
	return true
end

function  Class:endView(viewName)
	local vo = self:getView(-1)
	if vo==nil then
		return true
	end

	if vo.name~=viewName then
		if LDEBUG then
			LOG:debug(LTAG, "endView(%s) fail - current view is '%s'", viewName, vo.name)
		end
		return false
	end
	local sc = class.forName(vo.control)
	if LDEBUG then
		LOG:debug(LTAG, "end view[%s]", vo.name)
	end
	sc.onClose(vo.context)

	local scs = self._prop.views
	table.remove(scs, #scs)

	vo = self:getView(-1)
	if vo~=nil then
		if LDEBUG then
			LOG:debug(LTAG, "resume view[%s]", vo.name)
		end
		local nsc = class.forName(vo.control)
		nsc.onResume(vo.context)
	end
	return true
end

function Class:uiAction(cmd, param)
	local vo = self:getView(-1)
	if vo==nil then
		error("view stack empty")
	end	
	local sc = class.forName(vo.control)
	local f = sc["do"..cmd]
	if f==nil then
		if LDEBUG then
			LOG:debug(LTAG, "view[%s] action(%s) invalid", vo.name, cmd)
		end
		error("invalid "..cmd)
	end
	return f(vo.context, param)
end


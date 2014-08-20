-- ui/UIManager.lua
local Class = class.define("ui.UIManager")

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

function Class:getViewByName(viewName)
	local vo = self:getView(-1)
	if vo==nil then
		error("view stack empty")
	end
	if vo:name()~=viewName then
		return nil
	end
	return vo
end

function  Class:changeView(viewName, vo)
	local old = self:getView(-1)
	if old==nil then
		error("view stack empty")
	end
	if not old:canClose() then
		if LDEBUG then
			LOG:debug(LTAG, "changeView(%s) fail - can't close view[%s]", viewName, old:name())
		end
		return false
	end

	if LDEBUG then
		LOG:debug(LTAG, "close view[%s]", old:name())
	end
	old:onClose()

	vo:name(viewName)

	local scs = self._prop.views
	scs[#scs] = vo

	if LDEBUG then
		LOG:debug(LTAG, "enter view[%s]", viewName)
	end
	vo:onEnter()
	return true
end

function  Class:createView(viewName, vo)
	local old = self:getView(-1)
	if old~=nil then		
		if not old:canPause() then
			if LDEBUG then
				LOG:debug(LTAG, "createView(%s) fail - can't pause view[%s]", viewName, old:name())
			end
			return false
		end

		if LDEBUG then
			LOG:debug(LTAG, "pause view[%s]", old:name())
		end
		old:onPause()
	end

	vo:name(viewName)

	local scs = self._prop.views
	table.insert(scs, vo)

	if LDEBUG then
		LOG:debug(LTAG, "create view[%s]", viewName)
	end

	vo:onEnter(ctx)
	return true
end

function  Class:closeView(viewName)
	local vo = self:getView(-1)
	if vo==nil then
		return true
	end

	if vo:name()~=viewName then
		if LDEBUG then
			LOG:debug(LTAG, "closeView(%s) fail - current view is '%s'", viewName, vo:name())
		end
		return false
	end
	
	if not vo:canClose() then
		if LDEBUG then
			LOG:debug(LTAG, "closeView(%s) fail - can't close view", vo:name())
		end
		return false
	end

	if LDEBUG then
		LOG:debug(LTAG, "close view[%s]", vo:name())
	end
	vo:onClose()

	local scs = self._prop.views
	table.remove(scs, #scs)

	vo = self:getView(-1)
	if vo~=nil then
		if LDEBUG then
			LOG:debug(LTAG, "resume view[%s]", vo:name())
		end
		vo:onResume()
	end
	return true
end

function  Class:endView(viewName)
	local vo = self:getView(-1)
	if vo==nil then
		return true
	end

	if vo:name()~=viewName then
		if LDEBUG then
			LOG:debug(LTAG, "endView(%s) fail - current view is '%s'", viewName, vo:name())
		end
		return false
	end
	if LDEBUG then
		LOG:debug(LTAG, "end view[%s]", vo:name())
	end
	vo:onClose()

	local scs = self._prop.views
	table.remove(scs, #scs)

	vo = self:getView(-1)
	if vo~=nil then
		if LDEBUG then
			LOG:debug(LTAG, "resume view[%s]", vo:name())
		end		
		vo:onResume()
	end
	return true
end

function Class:uiAction(cmd, param)
	local vo = self:getView(-1)
	if vo==nil then
		error("view stack empty")
	end	
	local f = vo["do"..cmd]
	if f==nil then
		if LDEBUG then
			LOG:debug(LTAG, "view[%s] action(%s) invalid", vo.className, cmd)
		end
		error("invalid "..cmd)
	end
	if LDEBUG then
		LOG:debug(LTAG, "call view[%s] action(%s)", vo.className, cmd)
	end
	return f(self, vo, param)
end

function Class:uiProcess(sid, param)
	local vo = self:getView(-1)
	if vo==nil then
		error("view stack empty")
	end	
	if LDEBUG then
		LOG:debug(LTAG, "call view[%s] doProcess(%s)", vo.className, sid)
	end
	return vo:onProcess(self, sid, param)
end


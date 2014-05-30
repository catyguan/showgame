-- world/SceneManager.lua
local Class = class.define("world.SceneManager")

local LDEBUG = LOG:debugEnabled()
local LTAG = "SceneManager"

function Class:ctor()
end

function Class:sceneClass(n)
	local clsn = n..".Scene"
	return class.forName(clsn), clsn
end

function Class:getScene(lvl)
	local scs = self._prop.scenes
	if lvl==nil then
		local r = {}
		for _,v in ipairs(scs) do
			table.insert(r, v)
		end
		return r
	end	
	if lvl==-1 then
		lvl = #scs
	end
	if #scs < lvl then
		return nil
	end
	return scs[lvl]
end

function  Class:enterScene(n)
	local sn = self:getScene(-1)
	local sc = self:sceneClass(sn)
	if not sc.canLeave(self) then
		if LDEBUG then
			LOG:debug(LTAG, "enterScene(%s) fail - can't leave scene[%s]", n, sn)
		end
		return false
	end

	if LDEBUG then
		LOG:debug(LTAG, "leave scene[%s]", sn)
	end
	sc:onLeave(self)

	local scs = self._prop.scenes
	scs[#scs] = n

	if LDEBUG then
		LOG:debug(LTAG, "enter scene[%s]", n)
	end
	local nsc = self:sceneClass(n)
	nsc:onEnter(self)
	return true
end

function  Class:pushScene(n)
	local sn = self:getScene(-1)
	local sc = self:sceneClass(sn)
	if not sc.canPause(self) then
		if LDEBUG then
			LOG:debug(LTAG, "pushScene(%s) fail - can't pause scene[%s]", n, sn)
		end
		return false
	end

	if LDEBUG then
		LOG:debug(LTAG, "pause scene[%s]", sn)
	end
	sc:onPause(self)

	local scs = self._prop.scenes
	table.insert(scs, n)

	if LDEBUG then
		LOG:debug(LTAG, "push scene[%s]", n)
	end

	local nsc = self:sceneClass(n)
	nsc:onEnter(self)
	return true
end

function  Class:popScene(n)
	local sn = self:getScene(-1)
	if n~=sn then
		if LDEBUG then
			LOG:debug(LTAG, "popScene(%s) fail - current scene is '%s'", n, sn)
		end
		return false
	end
	local sc = self:sceneClass(sn)
	if not sc.canLeave(self) then
		if LDEBUG then
			LOG:debug(LTAG, "popScene(%s) fail - can't leave scene[%s]", n, sn)
		end
		return false
	end

	if LDEBUG then
		LOG:debug(LTAG, "leave scene[%s]", sn)
	end
	sc:onLeave(self)

	local scs = self._prop.scenes
	table.remove(scs, #scs)

	if LDEBUG then
		LOG:debug(LTAG, "resume scene[%s]", n)
	end

	local nsc = self:sceneClass(n)
	nsc:onPause(self)
	return true
end

function Class:doAction(cmd, ...)
	local sn = self:getScene(-1)
	local sc = self:sceneClass(sn)
	local f = sc["do"..cmd]
	if f==nil then
		if LDEBUG then
			LOG:debug(LTAG, "scene[%s] doAction(%s) invalid", sn, cmd)
		end
		error("invalid "..cmd)
	end
	return f(self, ...)
end

local Class = class.define("idle.Scene", {"world.Scene"})
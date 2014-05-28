-- world/World.lua
local Class = class.define("world.World")

local LDEBUG = LOG:debugEnabled()
local LTAG = "World"

function Class:ctor()
	self.id = ""
	self._prop = {
		status = {"Idle"}
	}
end

function Class:loadWorld(callback)
	if callback==nil then
		callback = function(done, wid)
		end
	end
	local ss = class.instance("service.StoreService")
	local wid = self.id
	local cb = function(done, data)
		callback(done, wid)
	end
	ss:load("world", wid, cb)
end

function Class:close()

end

function Class:prop(nlist, sv)
	local t = self._prop
	local p = nil
	local ln = nil
	for _,n in ipairs(nlist) do
		local v = t[n]
		if v==nil then
			if sv==nil then
				return nil
			end
			t[n] = {}
		end
		ln = n
		p = t
		t = v
	end
	if p~=nil then
		local r = p[ln]
		if sv~=nil then
			p[ln] = sv
		end
		return r
	end
	return nil
end

function Class:removeProp(nlist)
	local t = self._prop
	local p = nil
	local ln = nil
	for _,n in ipairs(nlist) do
		local v = t[n]
		if v==nil then
			return
		end	
		ln = n
		p = t
		t = v
	end
	if p~=nil then
		p[ln] = nil
	end
end

local smcls = function(self, lvl)
	local st = self._prop.status
	if #st < lvl then
		return nil, ""
	end
	local n = ""
	for i,v in ipairs(st) do
		if i>lvl then
			break
		end
		if n~="" then
			n = n .. "."
		end
		n = n .. v
	end
	local clsn = "world.sm."..n
	return class.forName(clsn), clsn
end

function Class:getStatus(lvl)
	local st = self._prop.status
	if lvl==nil then
		local r = {}
		for _,v in ipairs(st) do
			table.insert(r, v)
		end
		return r
	end	
	if #st < lvl then
		return ""
	end
	return st[lvl]
end

function Class:canEnterSM(lvl, n)
	local c = smcls(self, lvl)
	if c==nil then
		if LDEBUG then
			LOG:debug(LTAG, "SM[%d] invalid", lvl)
		end
		return false
	end
	return c.canEnterSM(self, n)
end

function  Class:enterSM(lvl, n)
	local c = smcls(self, lvl)
	if not c.canEnterSM(self, n) then
		return false
	end
	local st = self._prop.status
	while #st >= lvl do
		local cx, tmpn = smcls(self, #st)
		table.remove(st, #st)
		if cx~=nil then
			if LDEBUG then
				LOG:debug(LTAG, "leave SM[%s]", tmpn)
			end
			cx:leaveSM(self)
		end
	end

	local nsm = n
	local nlvl = lvl
	while nsm~=nil do
		st[nlvl] = nsm
		local cn,tmpn = smcls(self, nlvl)
		if LDEBUG then
			LOG:debug(LTAG, "enter SM[%s]", tmpn)
		end
		nsm = cn:enterSM(self)
		nlvl = nlvl + 1
	end
	return true
end

function Class:doAction(lvl, cmd, ...)
	local c = smcls(self, lvl)
	if c==nil then
		if LDEBUG then
			LOG:debug(LTAG, "doAction(%d, %s) invalidSM", lvl, cmd)
		end
		return
	end
	local f = c["do"..cmd]
	if f==nil then
		if LDEBUG then
			LOG:debug(LTAG, "doAction(%d, %s) invalid action", lvl, cmd)
		end
		return
	end
	return f(self, ...)
end
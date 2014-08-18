-- roguelike/world/World.lua
require("bma.lang.Class")

local Class = class.define("roguelike.world.World", {"ui.UIManager", "service.PDVM"})

local LDEBUG = LOG:debugEnabled()
local LTAG = "World"

function Class:ctor()
	self.id = ""
	self._prop = {
		scenes = {"idle"}
	}
end

function Class:begin()
	_G.WORLD = self
end

function Class:finish()
	if _G.WORLD==self then _G.WORLD = nil end
end

function Class:loadWorld(callback)
	if callback==nil then
		callback = function(done, wid)
		end
	end
	local ss = class.instance("service.StoreService")
	local wid = self.id
	local cb = function(done, data)
		if done then
			class.deserializeObject(self._prop, data)
		end
		callback(done, wid)
	end
	ss:load("world", wid, cb)
end

function Class:saveWorld(callback)
	if callback==nil then
		callback = function(done, wid)
		end
	end
	local ss = class.instance("service.StoreService")
	local wid = self.id
	local data = class.serializeValue(self._prop)
	local cb = function(done)
		callback(done)
	end
	ss:save("world", wid, data, cb)
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
			v = {}
			t[n] = v
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

function Class:hasRunv(n)
	if self._runv == nil then return false end
	return self._runv[n]~=nil
end

function Class:removeRunv(n)
	if self._runv==nil then return end	
	self._runv[n] = nil
end

function Class:runv(p1,p2)
	if p2==nil then
		if self._runv == nil then return nil end
		return self._runv[p1]
	else
		if self._runv == nil then self._runv = {} end
		self._runv[p1] = p2
		return p2
	end
end
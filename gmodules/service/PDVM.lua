-- service/PDVM.lua
local Class = class.define("service.PDVM")

local LDEBUG = LOG:debugEnabled()
local LTAG = "PDVM"
--[[
data = {_p=xxxx, ....}
]]
function Class:pdprocess()
	local pds = self._prop.pdvm
	if pds==nil then
		return
	end
	for i=1,10000 do		
		local stackc = #pds
		if stackc==0 then return end
		local stack = pds[stackc]

		if stack.pause then
			return
		end

		if stack.index>#stack.data then
			table.remove(pds, stackc)
		else
			data = stack.data[stack.index]
			stack.index = stack.index + 1
			local r = self:pdexec(stackc, data, stack.ctx)
			if r~=nil then				
				if r==false or r=="return" then
					table.remove(pds, stackc)
				end
				if r=="wait" then
					stack.pause = true
					return
				end
			end			
		end
	end
end

function Class:pdexec(stackId, data, ctx)
	local p = data["_p"]
	if _G.PDLookup~=nil then
		p = _G.PDLookup(p)
	else
		if _G.PDDict~=nil then
			local xp = _G.PDDict[p]
			if xp~=nil then p = xp end
		end
	end	
	if p=="return" or p=="wait" then return p end
	local cls = class.forName(p)
	if cls==nil then error(string.format("PDCall prototype[%s] invalid", p)) end
	local f = cls.invoke
	if f==nil or type(f)~="function" then
		error(string.format("PDCall prototype[%s] invoke invalid", p))
	end
	return f(stackId, data, ctx)
end

function Class:pdresume(stackId)
	local pds = self._prop.pdvm
	if pds==nil then
		return
	end
	local stack = pds[stackId]
	if stack==nil then return end
	stack.pause = nil
end

function Class:pdnew(data, ctx)
	local pds = self._prop.pdvm
	if pds==nil then
		pds = {}
		self._prop.pdvm = pds
	end
	if data["_p"]~=nil then
		data = {data}
	end
	local stack = {
		index = 1,
		data = data,
		ctx = ctx
	}
	table.insert(pds, stack)
	pds.index = 1
end

function pdcall( data, ctx )
	if data==nil then return end
	local w = WORLD
	w:pdnew(data, ctx)
	return w:pdprocess()
end
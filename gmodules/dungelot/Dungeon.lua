-- dungelot/Dungeon.lua
require("bma.lang.Class")

local Class = class.define("dungelot.Dungeon", {"bma.lang.StdObject", "ui.UIEvents"})

local LDEBUG = LOG:debugEnabled()
local LTAG = "Dungeon"

local PROP = {"dungelot"}

--------------------------------
function Class:ctor()
	self:prop("sid", 1)
end

function Class:SID()
	local sid = self:prop("sid")
	sid = sid + 1
	self:prop("sid", sid)
	return sid
end

local propcp = function(t1, t2)
	if not t2 then return end
	for k,v in pairs(t2) do
		if not t1[k] then
			t1[k] = v
		end
	end
end

function Class:run(w, name, hero)
	local cb = function(done, data)
		if done then			
			self:prop("data", data)
			self:prop("level", 1)
			self:prop("maxlevel", #data.levels)
			self:prop("asid", self:prop("sid"))
			local a = {}
			propcp(a, data.attr)
			propcp(a, hero)
			self:prop("a", a)
			self:startLevel()
		end
	end

	Class.load(name, cb)
	
	w:prop(PROP, self)
	self:prop("wid", w.id)

	local vo = class.new("dungelot.ui.Main")
	w:createView("dungelot_main", vo)
end

function Class:startLevel()
	local data = self:prop("data")
	local lvl = self:prop("level")
	local ldata = data.levels[lvl]
	
	local w = V(ldata.w, 5)
	local h = V(ldata.h, 6)
	self:prop("w", w)
	self:prop("h", h)

	local map = {}
	for x=1,w do
		local xmap = {}
		map[x] = xmap
		for y=1,h do
			xmap[y] = 1
		end
	end
	self:prop("map", map)

	self:buildLevel(ldata)
	self:normalize()
end

function Class:endLevel()
	self:removeRunv("free")
end

function Class:walk(f)
	local map = self:prop("map")
	if map==nil then return end

	for x,xl in ipairs(map) do
		for y,c in ipairs(xl) do
			if f(x, y, c) then return end
		end
	end
end

local ROUND = {
	{-1,0},{0,-1},{1,0},{0,1}
}

function Class:walkRound(x, y, f)
	for _,pos in ipairs(ROUND) do
		local x1 = x+pos[1]
		local y1 = y+pos[2]
		local c = self:getCell(x1, y1)
		if c~=nil then
			if f(x1, y1, c) then return end
		end
	end
end

-- builder
function Class.load(name, callback)
	if callback==nil then
		callback = function(done)
		end
	end
	local ss = class.instance("service.StoreService")
	local cb = function(done, data)
		if done then			
			Class.build(dg, data)
		end
		callback(done)
	end
	ss:load("dungelot", name, callback)
end

local CCLS = function(p)
	if p:sub(1,1)=="@" then p = "dungelot.Cell"..p:sub(2) end
	return class.forName(p)
end

function Class.newCell(data)
	local cls = CCLS(data._p)
	return cls.newCell(data)
end

function Class:buildCell(c)
	local co = Class.newCell(c)
	if c.x and c.y then
		self:setCell(c.x, c.y, co)
	else
		self:rsetCell(co)
	end
end

function Class:buildLevel(data)	
	if data.cells then
		for _,c in ipairs(data.cells) do
			if V(c.num, 0)>0 then
				for i=1,c.num do
					self:buildCell(c)
				end
			else
				self:buildCell(c)
			end
		end
	end
	local dc = data.default
	if dc==nil then
		dc = { _p = "@Empty" }
	end
	local cls = CCLS(dc._p)
	self:fillDefault(cls)
end

function Class:fillDefault(cell)
	local w = self:prop("w")
	local h = self:prop("h")
	local map = self:prop("map")

	self:walk(function(x,y,c)
		if c==1 then
			local co = cell.newCell({})
			map[x][y] = co
		end
	end)
end

local freeCells = function(self)
	local fcs = self:runv("free")
	if fcs==nil then
		fcs = {}
		self:walk(function(x,y,c)
			if c==1 or c.EMPTY then
				table.insert(fcs, {x, y})
			end
		end)
		self:runv("free", fcs)
	end
	return fcs
end

function Class:rsetCell(cell)
	local frees = freeCells(self)
	local c = #frees
	if c==0 then return false end
	local idx = math.random(#frees)

	for i=1,c do
		local pos = frees[idx]
		local x = pos[1]
		local y = pos[2]
		local ok = true
		
		if cell.ROCK then			
			self:walkRound(x, y, function(x, y, ce)
				if ce~=1 and ce.ROCK then
					ok = false
					idx = idx + 1
					if idx>c then idx = 1 end
					return true
				end
			end)
		end

		if ok then
			local map = self:prop("map")
			map[x][y] = cell
			table.remove(frees, idx)
			return true, x, y
		end
	end
	return false
end

function Class:setCell(x, y, cell)	
	local map = self:prop("map")
	map[x][y] = cell	
	self:removeRunv("free")
end

function Class:getCell(x, y)
	local map = self:prop("map")
	if x<1 or y<1 or x>#map then return nil end
	local xl = map[x]
	if y>#xl then return nil end
	return xl[y]
end

function Class:normalize()
	local w = self:prop("w")
	local h = self:prop("h")
	local map = self:prop("map")
	local sid = self:prop("sid")

	self:walk(function(x, y, c)
		c:prop("sid", sid)
		if c.ENTRANCE then
			self:onVisible(x, y)
		end
	end)
end


-- helper
function Class:onVisible(x, y)
	local sid = self:prop("sid")
	self:walkRound(x, y, function(x,y,c)
		if c:prop("l")~=1 then
			c:prop("sid", sid)
			c:prop("l", 1)
		end
	end)
end

function Class:onMonsterShow(x, y)
	self:onVisible(x, y)

	local sid = self:prop("sid")
	self:walkRound(x, y, function(x,y,c)
		if c.MONSTER then
			if self:prop("v")==1 then
				return
			end
		end

		local b = V(c:prop("b"), 0)
		if c:prop("v")~=1 then
			c:prop("sid", sid)
			c:prop("b", b + 1)
		end
	end)
end

function Class:onMonsterGone(x, y)
	local sid = self:prop("sid")
	self:walkRound(x, y, function(x,y,c)
		local b = V(c:prop("b"), 0)
		if b>0 then
			c:prop("sid", sid)
			if b == 1 then
				c:removeProp("b")
			else
				c:prop("b", b - 1)
			end			
		end
	end)
end

function Class:somethingGone(x, y)
	local c = self:getCell(x, y)
	if c~=nil and not c.EMPTY then
		local nc = class.forName("dungelot.CellEmpty").newCell()		
		nc:prop("sid", self:prop("sid"))
		nc:prop("l", c:prop("l"))
		nc:prop("v", c:prop("v"))
		nc:prop("b", c:prop("b"))		

		self:setCell(x, y , nc)
		if c.MONSTER then
			self:onMonsterGone(x, y)
		end
	end
end

function Class:doClick(x, y)
	local cell = self:getCell(x, y)
	if cell==nil then return end
	local sid = self:SID()

	if cell:doClick(self, x, y) then
		cell:prop("sid", sid)
	end	
end

function Class:doCall(pd)
	local f = self["invoke"..pd.cmd]
	return f(self, dg)
end

function Class:invokeNext(pd)
	self:endLevel();
	local lvl = self:prop("level")
	lvl = lvl + 1
	self:prop("level", lvl)
	self:startLevel();
end

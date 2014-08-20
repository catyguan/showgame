-- dungelot/Dungeon.lua
require("bma.lang.Class")

local Class = class.define("dungelot.Dungeon", {"bma.lang.StdObject", "ui.UIEvents"})

local LDEBUG = LOG:debugEnabled()
local LTAG = "Dungeon"

function Class:ctor()
	self:prop("sid", 1)
end

function Class:SID()
	local sid = self:prop("sid")
	sid = sid + 1
	self:prop("sid", sid)
	return sid
end

function Class:newLevel(w, h, creator, cb)
	self:prop("w", w)
	self:prop("h", h)

	local data = {}
	for x=1,w do
		local xdata = {}
		data[x] = xdata
		for y=1,h do
			xdata[y] = 1
		end
	end
	self:prop("map", data)

	local lcb = function(done)
		if done then
			self:normalize()
		end
		if cb then
			cb(done)
		end
	end
	creator(self, lcb)
end

function Class:run(w)
	w:prop({"dungelot"}, self)
	local vo = class.new("dungelot.ui.Main")
	w:createView("dungelot_main", vo)
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

function Class:setCell(x, y, cell)
	local map = self:prop("map")
	map[x][y] = cell
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

	self:walk(function(x, y, c)
		if c.ENTRANCE then
			self:onVisible(x, y)
			return true
		end
	end)
end

local ROUND = {
	{-1,0},{0,-1},{1,0},{0,1}
}

local WALK_ROUND = function(self, x, y, f)
	for _,pos in ipairs(ROUND) do
		local c = self:getCell(x+pos[1], y+pos[2])
		if c~=nil then f(c) end
	end
end

function Class:onVisible(x, y)
	local sid = self:prop("sid")
	WALK_ROUND(self, x, y, function(c)
		if c:prop("l")~=1 then
			c:prop("sid", sid)
			c:prop("l", 1)
		end
	end)
end

function Class:onMonsterShow(x, y)
	self:onVisible(x, y)

	local sid = self:prop("sid")
	WALK_ROUND(self, x, y, function(c)
		if c.MONSTER then return end

		local b = V(c:prop("b"), 0)
		if c:prop("v")~=1 then
			c:prop("sid", sid)
			c:prop("b", b + 1)
		end
	end)
end

function Class:onMonsterGone(x, y)
	local sid = self:prop("sid")
	WALK_ROUND(self, x, y, function(c)
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
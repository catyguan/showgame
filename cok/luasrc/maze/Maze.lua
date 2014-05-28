-- maze/Maze.lua
local Class = class.define("maze.Maze", {})

local LDEBUG = LOG:debugEnabled()
local LTAG = "Maze"

--[[
Maze config:
randVer:int -- default 1
randSeed:int -- rand seed,default 0
]]

function Class:ctor()
	self.id = 0
	self.randVer = 1
	self.randPos = 0
end

function Class:random(m,n)
    if self.randomFun ~= nil then return self.randomFun(m,n) end
    return math.random(m,n)
end

function Class:randomseed(x)
    if self.randomseedFun ~= nil then return self.randomseedFun(x) end
    return math.randomseed(x)
end

function Class:initObject()
end

function Class:setup( ... )
end

function Class:close()
end
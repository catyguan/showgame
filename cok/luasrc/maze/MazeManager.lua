-- maze/ArenaManager.lua
local Class = class.define("maze.MazeManager")

local LDEBUG = LOG:debugEnabled()
local LTAG = "MazeManager"

local idk = function(id)
	return "k"..id
end

function Class:ctor()
	self.mazes = {}
	self.seqId = 1
end

function Class:newMaze()
	if LDEBUG then
		LOG:debug(LTAG,"new maze "..self.seqId)
	end

	local o = class.new("maze.Maze")
	o:initObject()
	o.id = self.seqId
	self.seqId = self.seqId + 1

	self.mazes[idk(o.id)] = o
	
	return o
end

function Class:getMaze( id )
	return self.mazes[idk(id)]
end

function Class:closeMaze( id )
	if LDEBUG then		
		LOG:debug(LTAG,"close arena "..id)
	end
	local key = idk(id)
	local o = self.mazes[key]	
	if o~=nil then
		self.mazes[key] = nil
		o:close()
	end
end
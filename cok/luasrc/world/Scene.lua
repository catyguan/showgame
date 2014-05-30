-- world/Scene.lua
local Class = class.define("world.Scene")

function Class:canLeave(world)
	return true
end

function Class:canPause(world)
	return true
end

function Class:onEnter(world)
end

function Class:onLeave(world)
end

function Class:onPause(world)
end

function Class:onResume(world)
end
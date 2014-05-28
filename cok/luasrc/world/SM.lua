-- world/SM.lua
local Class = class.define("world.SM")

function Class:canEnterSM(world, status)
	return true
end

function Class:enterSM(world)
	return nil
end

function Class:leaveSM(world)
end
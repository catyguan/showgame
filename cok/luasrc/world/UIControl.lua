-- world/UIControl.lua
local Class = class.define("world.UIControl")

function Class:canClose()
	return true
end

function Class:canPause()
	return true
end

function Class:onEnter()
end

function Class:onClose()
end

function Class:onPause()
end

function Class:onResume()
end
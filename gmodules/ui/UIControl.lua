-- ui/UIControl.lua
require("bma.lang.Class")

local Class = class.define("ui.UIControl", {"bma.lang.StdObject"})

function Class:name(v)
	return self:prop("name", v)
end

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

function Class:onProcess(sid, param)
end

function Class:getViewData()
	return {}
end

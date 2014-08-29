-- ascension/Card.lua
local Class = class.define("ascension.Card", {"bma.lang.StdObject", "ascension.Const"})

local LDEBUG = LOG:debugEnabled()
local LTAG = "Ascension"

function Class:ctor(data)
end

function Class:ToView()
	local r = {}
	r.id = self:prop("id")
	self:buildView(r)
	return r
end

function Class:buildView(r)
end

function Class:ToString()
	return "Card"
end
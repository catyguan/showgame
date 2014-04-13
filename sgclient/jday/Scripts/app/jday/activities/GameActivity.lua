-- app/jday/activities/GameActivity.lua
require("bma.lang.ext.Json")
require("bma.mgr.activities.FileObjectBase")

local Class = class.define("app.jday.activities.GameActivity", {"bma.mgr.ActivityBase"})

local GAME_FILE = "/jday.ldf"

local info = function(self)
	if self._info==nil then
		local o = bma.mgr.activities.FileObjectBase.new()
		o:loadData(GAME_FILE)
		self._info = o
	end
	return self._info
end

-- GameActivity
function Class:ctor()	
	self.id = "game"
end

function Class:load()
	info(self)
end

function Class:save()
	if self._info then	
		self._info:saveData()
	end
end

function Class:sessionId(v)	
	local o = info(self)
	if v~=nil then		
		o.sesionId = v
		self:save()
	end
	return o.sesionId
end
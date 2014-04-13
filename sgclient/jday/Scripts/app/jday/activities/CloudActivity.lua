-- app/jday/activities/CloudActivity.lua
require("bma.lang.ext.Json")
require("bma.lang.ext.Table")
require("bma.lang.ext.Dump")
require("bma.http.client.HttpRequest")
require("bma.http.client.HttpResponse")

local Class = class.define("app.jday.activities.CloudActivity",{"bma.mgr.ActivityBase"})

local LDEBUG = LOG:debugEnabled()
local LTAG = "CloudActivity"

-- CloudActivity
function Class:ctor()	
	self.id = "cloud"
	self.server = nil
	self.sid = nil
end

local handleSessionAccept = function(self, server, sid, callback)
	if LDEBUG then
		LOG:debug(LTAG, "sessionAccept(%s, %s)", tostring(sid), string.dump(server))
	end
	
	local hqb = bma.http.client.HttpRequest.new()
	hqb.url = server.url
	hqb.debug = server.debug
	if server.host then
		hqb:setHost(server.host)
	end
	if sid then
		hqb:setCookie("rpsgame_sid", sid)
	end
	hqb:setParam("op", "SessionAccept")
	
	local s = class.instance("bma.http.client.Service")
	local req = hqb:create()
	s:process(req, function(rep)
		local repObj = bma.http.client.HttpResponse.new(rep)
		local robj = repObj:get200JsonData()
		if robj then
			-- check response
		end
		callback(nil)		
	end)
	
end

function Class:sessionAccept(sid, callback)
	local ss = table.clone(CONFIG.AppCloud.Servers)
	table.shuffle(ss)
	
	local trys
	trys = function(self, idx, cb1)
		local s = ss[idx]
		if s then
			handleSessionAccept(self, s, sid, function(r)
				if r then
					self.server = s
					cb1(r)
				else
					trys(self, idx+1, cb1)
				end				
			end)
		else
			-- for test
			-- cb1(nil)
			cb1("test_session_id")
		end
	end
	
	if self.server ~= nil then
		handleSessionAccept(self, self.server, sid, function(r)
			if r then
				callback(r)
			else
				trys(self, 1, callback)
			end
		end)		
	else
		trys(self, 1, callback)
	end
end

function Class:save()
	if self._info then	
		self._info:saveData()
	end
end

function Class:hasPlayed()
	return hostapp.file:exists(GAME_FILE)
end
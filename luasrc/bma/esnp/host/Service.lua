-- bma/esnp/host/Service.lua
require("bma.lang.ext.Core")
require("bma.esnp.BaseService")

local Class = class.define("bma.esnp.host.Service", {bma.esnp.BaseService})

local esnp = hostapp.esnp

function Class.install()
	local o = Class.new()
	class.setInstance("bma.esnp.Service", o)
	local hosts = CONFIG.ESNP.Hosts
	if hosts then
		for _, hp in ipairs(hosts) do
			esnp:addHost(hp.host, hp.port)
		end
	end
end

function Class:reset()
	esnp:reset()
end

function Class:send(msg, callback, timeout)
	return esnp:send(msg, callback, timeout)
end

function Class:invoke(sname, mname, hs, vals, callback, timeout, tag)
	local msg = {
		type=3,
		service=sname,
		method=mname,
		headers=hs,
		values=vals
	}
	return esnp:send(msg, callback, timeout, tag)
end

function Class:cancel(reqid)
	local r = esnp:cancel(reqid)
	return r
end

function Class:cancelTag(tag)
	esnp:cancelTag(tag)
end

function Class:isRunning()
	local rc = esnp:runningCount()
	return rc > 0	
end

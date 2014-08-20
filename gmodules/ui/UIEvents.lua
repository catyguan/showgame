-- ui/UIEvents.lua
local Class = class.define("ui.UIEvents")

function Class:uiEvent(ev)	
	local evg = self:runv("eventg")	
	if evg~=nil and #evg>0 then
		local eg = evg[#evg]
		table.insert(eg.es, ev)
		return
	end

	local evs = self:prop("events")
	if evs==nil then
		evs = {}
		self:prop("events", evs)
	end

	local sid = self:prop("sid")
	ev.id = sid
	table.insert(evs, ev)
end

function Class:uiEventBegin(eid)
	local evg = self:runv("eventg")
	if evg==nil then
		evg = {}
		self:runv("eventg", evg)
	end
	table.insert(evg, {id=eid, es={}})
end

function Class:uiEventCommit(eid, ev)
	local eg
	local evg = self:runv("eventg")
	if evg~=nil and #evg>0 then
		eg = evg[#evg]
	end
	if not eg then
		error("event commit fail, eventg empty")
	end

	if eg.id~=eid then
		error(string.format("event commit fail, id not same, %s - %s", eg.id, eid))
	end
	table.remove(evg, #evg)
	if ev~=nil then
		self:uiEvent(ev)
	end
	for _,lev in ipairs(eg.es) do
		self:uiEvent(lev)
	end
end

function Class:uiPopEvent(sid)
	local r = {}
	local evs = self:prop("events")
	if evs~=nil then
		for _, ev in ipairs(evs) do
			if ev.id>sid then
				ev.id = nil
				table.insert(r, ev)
			end
		end
		self:removeProp("events")
	end
	return r
end
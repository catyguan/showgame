-- quest/Manager.lua
local Class = class.define("quest.Manager")

local LDEBUG = LOG:debugEnabled()
local LTAG = "QuestManager"

local PROP_NAME = {"quests"}

function Class.callAll(method, ...)
	local r = {}
	local w = WORLD
	local qlist = w:prop(PROP_NAME)
	if qlist~=nil then
		for _, qinfo in ipairs(qlist) do
			local qobj = class.forName(qinfo._p)
			local f = qobj[method]
			if f~=nil then
				local res = f(...)
				if res~=nil then
					table.insert(r, res)
				end
			end
		end
	end
	return r
end
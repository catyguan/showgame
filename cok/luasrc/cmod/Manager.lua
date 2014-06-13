-- cmod/Manager.lua
local Class = class.define("cmod.Manager")

local LDEBUG = LOG:debugEnabled()
local LTAG = "CmodManager"

local PACK_LIST = {
	"cmod.pack.base.CPack",
}

function Class.callAll(method, ...)
	local r = {}
	local w = WORLD
	local plist = PACK_LIST
	for _, pname in ipairs(plist) do
		local pobj = class.forName(pname)
		local f = pobj[method]
		if f~=nil then
			local res = f(...)
			if res~=nil then
				table.insert(r, res)
			end
		end
	end
	return r
end
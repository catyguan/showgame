-- service/StoreService.lua

--[[
interface {
	Load(type string, id string, callback func(done bool, data json))
}
]]

local Class = class.define("service.StoreService")
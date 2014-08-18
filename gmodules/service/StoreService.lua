-- service/StoreService.lua

--[[
interface {
	load(type string, id string, callback func(done bool, data json))
	save(type string, id string, data string, callback func(done bool))
}
]]

local Class = class.define("service.StoreService")
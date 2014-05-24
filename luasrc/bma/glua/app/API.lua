-- bma/glua/app/API.lua
require("bma.app.APIBase")

function _API_application_startup()
	base_API_application_startup("bma.glua.app.Application")
end

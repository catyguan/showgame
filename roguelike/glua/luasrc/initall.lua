math.randomseed( tonumber(tostring(os.time()):reverse():sub(1,6)) )

LUA_APP_TYPE = "roguelike"
require("bma.glua.app.Bootstrap")

_API_application_startup()
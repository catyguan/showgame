-- ui/Home.lua
local Class = class.define("ui.Home", {"world.UIControl", "ui.Menu"})

local LTAG = "UI.home"

function Class.doTest(ctx)
	local w = WORLD
	local ctx = {
		ok = {
			{ _p="ui.MessageBox", view = {message="Thank You!"} },
			{ _p="ui.MessageBox", view = {message="Bye"} },
		}
	}
	w:createView("mbox",{message="Can you help me?",confirm=true},"ui.MessageBox", ctx)
	return {1,2,3}
end

function Class.doTest2(ctx)
	local w = WORLD
	local ctx = {
		view = {
			content="Let's play game",
			options={
				{ id="s1", title="OK!", close=true},
				{ id="s2", title="No...", close=true},
				{ id="s3", title="What?",
					content="play a sex game",
					options={
						{ id="s1", title="Fuck you", close=true,
							op={ _p="ui.MessageBox", view = {message="Bye"}},
						},
						{ id="s2", title="Don't do that", close=true},
					}
				},
			}
		}
	}
	w:createView("commonevent",{},"ui.CommonEvent", ctx)
	return 0
end

local loader = function(name)
	local ddir = "../data"
	local fn = ddir.."/"..name..".json"
	local file = io.open(fn, "r")
	if file==nil then
		return {}
	end
	local str = file:read("*all")
	file:close()
	return str:json()
end

function Class.doTest3(ctx)
	local cbm = class.forName("adventure.Combatd")

	local cbjson = loader("combat_test")	
	local cb = cbm.newCombat(1)
	local chlist = cbjson.chars
	for _, chdata in ipairs(chlist) do
		cbm.newChar(cb, chdata)
	end
	local splist = cbjson.spells
	for _,spdata in ipairs(splist) do
		cbm.addSpell(cb, spdata)
	end

	cbm.prepare(cb)
	-- cbm.process(cb)	
	return 0
end

function Class.doTest4(ctx)
	local ldata = loader("combat_p_test")

	local uic = class.forName("adventure.ui.CombatPrepare")
	
	local opts = ldata.opts
	local emenyTeam = ldata.emenyTeam
	local myGroup = ldata.myGroup
	local myWagon = ldata.myWagon
	uic.uiEnter(opts, emenyTeam, myGroup, myWagon)
	return 0
end
-- ui/Home.lua
local Class = class.define("ui.Home", {"world.UIControl"})

local LTAG = "UI.home"

function Class.onClose(ctx)
	LOG:warn(LTAG, "can't close 'home' view")
	return false
end

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
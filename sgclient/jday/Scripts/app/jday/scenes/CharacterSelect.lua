-- app/jday/scenes/CharacterSelect.lua
local Class = class.define("app.jday.scenes.CharacterSelect",{"bma.mgr.SceneBase"})

local MESSAGE1 = "名称："
local MESSAGE_OK = "确定"

function Class:create()

	local this = self
	local winSize = director:winSize()
	local layer = director:createObject("CCELayerTouch", {})
	
	local panelName = director:buildObject({
		_type = "CCEPanel",		
		autoSize = true,
		layout = {align="middle", valign="center"},
		children = {
			{
				_type = "CCLabelTTF",
				content = MESSAGE1,
				fontName = CONFIG.UI.FontName,
				fontSize = CONFIG.UI.FontSize,
				layout = {valign="center"}
			},
			{
				_type = "CCLabelTTF",
				content = "abcde",
				fontName = CONFIG.UI.FontName,
				fontSize = CONFIG.UI.FontSize,
				layout = {valign="center"}
			}
		}
	})	
	
	local mainPanel = director:buildObject({
		_type = "CCEPanel",	
		layout = {dock="fill"},
		vertical = true,
		children = {
			{
				_type = "CCEPanel",
				layout = {width="*", height="30%"},
				children = {
					panelName
				}
			},
			{
				_type = "CCEPanel",
				layout = {width="*", height="50%"},
				children = {
					
				}
			},			
			{
				_type = "CCEPanel",
				layout = {width="*", height="20%"},
				children = {
					{
						_type="CCEButton",
						touch = "focus,tap",
						node = {
							_type="CCLabelTTF",
							content = MESSAGE_OK,
							fontName = CONFIG.UI.FontName,
							fontSize = CONFIG.UI.ButtonFontSize
						},						
						layout = {align="middle", valign="center"},
						onEvent = {
							tap = function()
								print("tap!")								
							end
						}
					}
				}
			},			
		}
	})
	
	layer:addChild(mainPanel)
	director:layout(layer)
	
	local f = director:createNodeFrame(mainPanel)
	layer:addChild(f, 1)
	
	return layer
end


--[[
{	
	"views" : ..., 	// UIManager use
	"leader": {
		"spells" : [
			{
				"_p": "cmod.pack.base.SpellHeal",
				"num": 2
			}
		]
	},
	"adv" : {		// adventure module
		"combat" : {
			"stage" : "prepare",
			"opts" : {
				"teamMax": 3,
				"backupTeam": false,
				"disableSpell": false
			},
			"emenyTeam" : {
				"stage" : 1
				"groups" : [
					{
						"chars": [
							charObject ...
						]
					}
				]
			},
			"team" : {
				"chars": [
					charObject ...
				]
			},
			"wagon" : {
				....
			},
			["lastResult"] : {
				"winner": 1|2
			},
			"onFinish": { ...pdcall... }
		},				
		"wagon" : {
			"chars" : [
				charObject ...
			]
		}
	}	
}
]]

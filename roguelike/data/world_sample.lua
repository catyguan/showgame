--[[
{	
	"views" : ..., 	// UIManager use
	"kindom": {
		"info": {
			"title":xxxx
			"faction":xxxx
		}
		"resources" : [
			{v,m},
			...
		],
		"buildings" : [
			{
				"_p":"xxxxx",
				"level": 1,
				...
			},
			...
		],
		"towns"  : [
			"id":"xxxx",
			"title":"xxxx",
			"capital":false,
			"income" : {
				g: {v,m}, ...
			},
			"gainTime" : xxxx
		],
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

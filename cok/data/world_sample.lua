--[[
{	
	"views" : ..., 	// UIManager use
	"adv" : {		// adventure module
		"combat" : {
			"stage" : "prepare",
			"opts" : {
				"teamType" : 9
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

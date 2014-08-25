function doView(rs, update) {
	var sid = rs.name;
	if(sid=="mbox") {
		var res = true;
		var msg = rs.data.message;
		if(rs.data.confirm) {
			res = confirm(msg);
		} else {
			alert(msg);
		}
		doUIAction("Click",[res],null);
		return
	}
	if(update) {
		if(sid==contentId && contentManager!=null) {
			contentManager.Update(rs.data);
			return
		}
	}
	loadContent(sid, rs.data);	
}
function updateView(rs) {
	doView(rs, true)
	
}
function loadView(rs) {
	doView(rs, false)
}
function reloadView() {
	$.ajax({
		url: aURL+"viewinfo",		
		data: {
			id : worldId
		},
		type: "GET",
		dataType : "json",
		success: function( rs ) {
			console.log(rs);
			loadView(rs)
		}
	});
}
function doUIAction(cmd, p, callback) {
	$.ajax({
		url: aURL+"action",		
		data: {
			id : worldId,
			cmd : cmd,
			p : JSON.stringify(p)
		},		
		type: "GET",
		dataType : "json",
		success: function( rs ) {
			console.log(rs);
			if(callback!=null) {
				if(!callback(rs.result)) {
					return
				}
			}
		}
	});
}
function doUIProcess(sid, p, callback) {
	$.ajax({
		url: aURL+"process",		
		data: {
			id : worldId,
			sid : sid,
			p : JSON.stringify(p)
		},		
		type: "GET",
		dataType : "json",
		success: function( rs ) {
			console.log("doUIProcess --> ", rs);
			if(callback!=null) {
				if(!callback(rs)) {
					return
				}
			}
			updateView(rs);
		}
	});
}
/**
handlef : function(ev, nextf:function(stopNow:bool))
endf : function()
*/
function processEventsI(evlist, idx, handlef, endf) {
	if(evlist && idx<evlist.length) {
		console.log("process event ", idx);
		var ev = evlist[idx];
		var f = function(stopNow) {
			if(stopNow) {
				if(endf)endf();
				return;
			}
			setTimeout(function() {
				processEventsI(evlist, idx+1, handlef, endf);
			},1);
		}
		handlef(ev, f);
		return;
	}
	console.log("process event end");
	if(endf)endf();
}
function processEvents(evlist, handlef, endf) {
	processEventsI(evlist, 0, handlef, endf);
}
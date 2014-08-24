var tipsId = 1;

function showTips(msg, pos, color, fcolor) {
	var x,y;
	if(typeof(pos)=="string") {
		var target = $('#'+pos)[0];
		for(y=0,x=0; target!=null; y+=target.offsetTop, x+=target.offsetLeft, target=target.offsetParent);
		x += 20;
		y += 40+15;
	}
	console.log(x, y);
	var id = "tipsid_"+tipsId;
	tipsId++;
	//设置默认值
	msg = msg || 'error';
	color = color || '#ea0000';
	fcolor = fcolor || '#FFFFFF';
	width = 80;

	//获取对象坐标信息
	var textAlign = 'left', fontSize = '12',fontWeight = 'normal';

	//弹出提示
	var f = function(set, attr) {
		var obj = document.createElement('div');
		for(var i in set) { obj.style[i] = set[i]; }
		for(var i in attr) { obj[i] = attr[i]; }
		return obj;
	}
	var holder = document.body;
	var tipsDiv = f(
			{
				display:'block',
				position:'absolute',
				zIndex:'1001',
				left:(x+1)+'px',
				padding:'5px',
				color:fcolor,
				fontSize:fontSize+'px',
				backgroundColor:color,
				textAlign:textAlign,
				fontWeight:fontWeight,
				filter:'Alpha(Opacity=50)',
				opacity:'0.7'
			}, {id:id, innerHTML:msg}
		);
	holder.appendChild(tipsDiv);
	tipsDiv.style.top = (y-tipsDiv.offsetHeight-12)+'px';
	return id;
}

function closeTips(id) {
	var t = document.getElementById(id);
	if(t) { t.parentNode.removeChild(t); }
}
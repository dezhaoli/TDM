doc_name = ""
function main(args){
	fl.publishCacheEnabled = false;
	var i=0;
	
	
		var command = args[i++];
		log("start:"+command+"\n");
		
		save_path = args[i++];
		if(command == 'find'){
			var flaFiles = args[i++].split(" ");
			opens(flaFiles)
			
		}
	
	log("success:" + command);
}
function opens(flaFiles){
	
	log("flaFiles.length="+flaFiles.length);
	for(var i=0;i<flaFiles.length;i++ ){
		var file = flaFiles[i];
		try{
			if(debug) log(FLfile.platformPathToURI( file ));
			var doc = fl.openDocument(  FLfile.platformPathToURI( file ));
			mymain(doc);
			fl.closeDocument(doc,false);
		}catch(e){
			err(file+ " fail! " +e);
		}
	}
}

function mymain(doc){
	fl.outputPanel.clear();
	var out_mcs = [];
	var out_keys = [];
	var out_pics = [];
	tagedElementsKey = {};
	tagedElementsPic = {};
	if(!doc){
		alert("错误，文档尚未打开");
		return -1;
	}
	//比如 doc_name = 【naruto.battle\exlibs\BattleStartUI】
	doc_name = doc.pathURI
	var start = doc_name.indexOf("naruto.");
	var end = doc_name.indexOf(".fla");
	doc_name = doc_name.substring(start,end);
	lib = doc.library;
	
	var l = lib.items.length;
	for(var i = 0;i<l;i++){
		var item = lib.items[i];
		//扫出有类名的MC
		if(!item.linkageClassName || item.linkageURL ){
			continue;
		}
		if(debug) log("MC:" + item.linkageClassName)
		if(item.itemType == "movie clip"||item.itemType == "button"||item.itemType == "graphic"){
			//找MC很简单，只要保存【类名|文件名|库路径】
			if(findmc){ 
				if(debug) log(item.linkageClassName + "|" + doc_name + "|" + item.name);
				out_mcs.push( item.linkageClassName + "|" + doc_name + "|" + item.name);
			}
			//找KEY，要循环到MC内部
			if(findkey){
				scanMC(item.timeline, "(" + item.linkageClassName + ")",0 ,2 , out_keys);
			}
			//找PIC，也要循环到MC内部
			if(findpic){
				scanMC(item.timeline, "(" + item.linkageClassName + ")",0 ,3 , out_pics);
			}
		}
	}
	//保存结果
	if(findmc){
		save(out_mcs,out_mc_URI);
	}
	if(findkey){
		save(out_keys,out_key_URI);
	}
	if(findpic){
		save(out_pics,out_pic_URI);
	}
}
function save(arr,path){
	FLfile.write(FLfile.platformPathToURI( save_path + "/" + path ), arr.join("\n")+"\n", "append" );
}
function getTab(len_l){
	r= ""
	for(var i=0;i<len_l;i++){
		r=r+ "\t"
	}
	return r
}
//1 for mc ;  2 for key ; 3 for pic
function scanMC(timeline, target, tab,findMode,arr){
	if(!timeline){
		return;//对象是位图会没有时间轴
	}
	var l = timeline.layers.length;
	for(var i = 0; i<l; i++){
		var layer = timeline.layers[i];
		if(layer.layerType == "guide"){//引导层去掉
			continue;
		}
		var ll = layer.frames.length;
		
		if(debug) log( getTab(tab) + "# layer.name=" + layer.name);
		for(var ii = 0; ii<ll; ii++){
			var frame = layer.frames[ii];
			if(frame && frame.startFrame == ii){
				var lll = frame.elements.length;
				if(debug) log(getTab(tab) + "### frame.name=" + frame.name + ",startFrame=" + ii);
				for(var iii = 0; iii<lll; iii++){
					var e = frame.elements[iii];
					if(findMode == 2){
						scanElemForKey(e,target,tab,arr);
					}else if(findMode == 3){
						scanElemForPic(e,target,tab,arr);
					}
				}
			}
		}
		
	}
	return;
}
function scanElemForKey(e,target,tab,arr){
	if(debug) log(getTab(tab) + "##### e.elementType=" + e.elementType + ", e.name=" + e.name);
	switch(e.elementType){
		case "text":
			//扫出TextField的KEY
			key = e.getPersistentData("key");
			if(key){
				var c = e.name?e.name:"TextField";
				var cc = target +"." + c;
				outputInfo(cc,key,arr);
			}
			break;
		case "shape":
			if(e.isGroup){
				var l = e.members.length;
				for(var i = 0;i<l;i++){
					var mem = e.members[i];
					scanElemForKey(mem,target,tab,arr);
				}
			}
			break;
		case "instance":
			if(debug) log(getTab(tab) + "####### e.instanceType=" + e.instanceType);
			
			if(e.instanceType == "compiled clip"){//扫出组件的KEY
				key = e.getPersistentData("key");
				if(key){
					var c = e.name?e.name: e.libraryItem.linkageClassName.split(".").pop();
					cc = target +"." + c;
					outputInfo(cc,key,arr);
				}
			}else if(!e.libraryItem.linkageClassName){//如果这个MC有类名的，就可以跳过
				//扫过的无类名MC，记录下来提速
				var symbolarr = tagedElementsKey[e.libraryItem.name];
				if(!symbolarr){
					tagedElementsKey[e.libraryItem.name] = symbolarr = [];
					scanMC(e.libraryItem.timeline, "" , tab+1, 2, symbolarr);//这里不填名字
				}
				for(var i=0;i<symbolarr.length;i++){
					cc = target +"." + e.name + symbolarr[i];
					if(arr.indexOf(cc) == -1)
						arr.push( cc);
				}
			}
			break;
		default:
			//如果出现视频、组件之类将会出现在这，不过一般不会出现
			break
	}
}
function outputInfo(target,key,arr){
	var val = target + "|" + key;
	if(arr.indexOf(val) == -1)
		arr.push( val);
}
//##############################################

function outputBitmapInfo(target,picPath,arr){
	var val = target + "|" + doc_name + "/" + picPath;
	if(arr.indexOf(val) == -1)
		arr.push( val);
}

function scanElemForPic(e,target,tab,arr){
	if(debug) log(getTab(tab) + "##### e.elementType=" + e.elementType + ", e.name=" + e.name);
	switch(e.elementType){
		case "shape":
			var l = e.members.length
			if(e.isGroup && l>0){//组合的情况
				for(var i = 0;i<l;i++){
					scanElemForPic(e.members[i],target,tab,arr)
				}
			}else{
				//扫出打散的图片 或者 九宫格
				for each(var contour in e.contours)
				{
					if(contour.fill.style=="bitmap"){
						outputBitmapInfo(target,contour.fill.bitmapPath,arr);
					}
				}
			}
			break;
		case "instance":
			if(e.instanceType == "bitmap"){//扫出图片实例
				outputBitmapInfo(target,e.libraryItem.name,arr);
			}
			else if(!e.libraryItem.linkageClassName){//如果这个MC有类名的，就可以跳过
				
				//扫过的无类名MC，记录下来提速
				var symbolarr = tagedElementsPic[e.libraryItem.name];
				if(!symbolarr){
					tagedElementsPic[e.libraryItem.name] = symbolarr = [];
					scanMC(e.libraryItem.timeline, "" , tab+1, 3, symbolarr);//这里不填名字
				}
				for(var i=0;i<symbolarr.length;i++){
					//没有命令的MC统一用instance
					cc = target +"." + (e.name?e.name:"instance") + symbolarr[i];
					if(arr.indexOf(cc) == -1)
						arr.push( cc);
				}
			}
			break;
	}
}
//##############################################
var debug = false;


var findmc = true;
var findkey = true;
var findpic = true;

var save_path = "D:/workspace/monster-debugger/application/src/libs/temp"
var out_pic_URI = "fla_pic_dic.txt"; 
var out_key_URI = "fla_kv_dic.txt"; 
var out_mc_URI = "fla_mc_dic.txt"; 

var tagedElementsKey;
var tagedElementsPic;

//===============comment later
//debug = true;
//mymain(fl.getDocumentDOM());
//
//var logs=""
//function saveToLogFile(){
	////fl.outputPanel.save( FLfile.platformPathToURI(logFilePath),true);
	//FLfile.write(FLfile.platformPathToURI(logFilePath), logs);
//}
//function err(e){
	//var line=e.lineNumber?e.lineNumber:(e.number?e.number:-1);
	//s="[error]\\n"+"ErrorType: "+e.name+(line!=-1?"\\nline= "+line+"\\n":"\\n")+e.message+(e.stack?"\\nStack Trace:\\n"+e.stack:"")
	//fl.trace(s);
	//logs=logs + s + "\\n";
//}
//function log(s){
	//s="[log]" + s
	//fl.trace(s);
	//logs=logs + s + "\\n";
//}

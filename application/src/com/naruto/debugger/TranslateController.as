package com.naruto.debugger
{
	import com.naruto.debugger.helper.ExTools;
	
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	
	import mx.utils.StringUtil;
	
	import controllers.panels.FindController;
	
	public class TranslateController extends EventDispatcher
	{
		
		
		
		public var flaPicDic:Dictionary = new Dictionary;
		public var flaPicRootDic:Dictionary = new Dictionary;
		public var quickPicDic:Dictionary = new Dictionary;
		public var local_flaPicDic:Dictionary = new Dictionary;
		public var local_flaPicRootDic:Dictionary = new Dictionary;
		public var local_quickPicDic:Dictionary = new Dictionary;
		
		public var flaKvDic:Dictionary = new Dictionary;
		public var quickDic:Dictionary = new Dictionary;
		
		public var flaMcDic:Dictionary = new Dictionary;
		public var flaPathDic:Dictionary = new Dictionary;
		public var local_flaMcDic:Dictionary = new Dictionary;
		public var local_flaPathDic:Dictionary = new Dictionary;
		
		public var kvAsFlaMap:Dictionary = new Dictionary;
		public var kvAsFlaTextMap:Dictionary = new Dictionary;
		public var kvExcelMap:Dictionary = new Dictionary;
		
		private var _context:DTabContext;
		private var send:Function;
		public function TranslateController(context:DTabContext,send:Function)
		{
			
			this.send = send;
			_context = context;
			_context.translateController = this;
		}
		/**
		 * 用于模糊匹配，记录最近2000个 Protocol
		 */
		private const ProtocolStrs:Array = [];
		private function recordProtocol(value:String):void{
			ProtocolStrs.push(value);
			while(ProtocolStrs.length > 2000){
				ProtocolStrs.shift();
			}
		}
		/**
		 * 用于模糊匹配，记录最近2000个as key,包括 recordRepAS,recordAS
		 */
		private const AS:Array = [];
		static private const TF:TextField = new TextField;
		/**
		 * 用于精确匹配,recordAS
		 */
		private var AS_dic:Dictionary = new Dictionary;
		
		//记录用到的 as key 
		private function recordAS(key:String, value:String):void
		{
			value = H(value)
			if (AS_dic[value] == null) {
				AS_dic[value] = [];
			}
			var keys:Array = AS_dic[value];
			if(keys.indexOf(key) == -1){
				
				keys.push(key);
				_recordAS(value)
			}
			
		}
		private function _recordAS(value:String):void{
			AS.unshift(value);
			while(AS.length > 2000){
				AS.pop();
			}
		}
		static public function H(html:String):String{
			TF.htmlText = html;
			return TF.text;
		}
		//记录用 strreplacer 替换的文字
		private function recordRepAS(srcText:String,repText:String):void
		{
			srcText = H(srcText);
			repText = H(repText);
			if (AS_dic[srcText]) {
				AS_dic[repText] = AS_dic[srcText];
				_recordAS(repText)
			}else {
				//trace("[i18n]no recorded key:srcText=", srcText, ",repText=", repText);
			}
			
		}
		
		
		
		public function send2FindPanel(info:String,findDatas:Array):void {
			info = StringUtil.trim(info);
			_context.findController.showDatas(findDatas);
			send({command:DConstants.COMMAND_KEY_INFO, info:info,previewObjName:curData.previewObjName});
		}
		
		
		private var curData:Object;
		public function setData(data:Object):void
		{
			switch (data["command"]) {
				case DConstants.COMMAND_RECORD_AS_KV:
					if(String(data["type"]) == "3"){
						var asCache:Array = data["asCache"];
					}else{
						asCache = [data];
					}
					for(var i:int=0;i<asCache.length;i++){
						data = asCache[i];
						var key:String = data["val1"];
						var value:String = data["val2"];
						var type:String = data["type"];
						if(type == "1" ){
							recordAS(key,value);
						}else if (type == "2" ){
							recordRepAS(key,value);
						}
					}
					
					
				break;
				case DConstants.COMMAND_RECORD_PROTOCOL:
					var errStr:String = data["str"];
					recordProtocol(errStr);
					break;
				
				case DConstants.COMMAND_FLA_KV:
					curData = data;
					findallkey(data);
					//
					break;
				case DConstants.COMMAND_FIND_PIC:
					curData = data;
					findallPic(data);
					//
					break;
				case DConstants.COMMAND_OPEN_IN_FLASH:
					openInFla(data);
					
					break;
				case DConstants.COMMAND_OPEN_IN_AS:
					openInAs(data);
					
					break;
			}
			
		}
		
		private function openInAs(data:Object):void{
			var infos:String = data["info"];
			var stageURL:String = data["stageURL"];
			var target:String = parseTarget(infos);
			
			stageURL = stageURL.substring(0,stageURL.lastIndexOf("/"));
			stageURL = stageURL.substring(0,stageURL.lastIndexOf("/"));
			if(stageURL.indexOf("http") == 0 && _context.plData.client_path){
				try{
					var f:File = new File(_context.plData.client_path);
					stageURL = f.url;
				}catch(e:Error){
					stageURL = data["stageURL"];
				}
			}
			//fla
			var arr:Array = infos.split("|");
			var link:Array = [];
			
			var def:Array;
			var C:String;
			var n:String;
			
			for(var i:int=arr.length-1;i>-1;i--){
				def = arr[i].split(":");
				C = def[1];
				n = def[0];
				if( C.indexOf("com.tencent.morefun.naruto.") > -1){
					link = C.split(".");
					var model:String = "naruto."+link[5];
					
					var path:String = stageURL + "/" + model + "/src/" + link.join("/") + ".as";
					var f:File=new File(path);
					if(f.exists){
						f.openWithDefaultApplication();
						return;
					}
					
				}
			}
		}
		
		private function openInFla(data:Object):void{
			var infos:String = data["info"];
			var stageURL:String = data["stageURL"];
			var target:String = parseTarget(infos);
			
			stageURL = stageURL.substring(0,stageURL.lastIndexOf("/"));
			stageURL = stageURL.substring(0,stageURL.lastIndexOf("/"));
			
			if(stageURL.indexOf("http") == 0 && _context.plData.client_path){
				try{
				var f:File = new File(_context.plData.client_path);
				stageURL = f.url;
				}catch(e:Error){
					stageURL = data["stageURL"];
				}
			}
			//fla
			var arr:Array = infos.split("|");
			var link:Array = [];
			
			var def:Array;
			var C:String;
			var n:String;
			
			
			if(data.isFind){
				fla = data.fla + ".fla";
				mcName = data.mc;
				ExTools.openfla(stageURL +"/"+fla,mcName);
				_context.traceController.addTrace(stageURL+"/"+fla+"\n"+mcName,"OPEN FLA",target);
				return;
			}
			for(var i:int=arr.length-1;i>-1;i--){
				def = arr[i].split(":");
				C = def[1];
				n = def[0];
				if( flaMcDic[C] || local_flaMcDic[C]){
					var vals:Array = (flaMcDic[C] as Array || local_flaMcDic[C] as Array) ;
					var fla:String = vals[1] + ".fla";
					var mcName:String = vals[2];
					ExTools.openfla(stageURL +"/"+fla,mcName);
					_context.traceController.addTrace(stageURL+"/"+fla+"\n"+mcName,"OPEN FLA",target);
					return;
				}else if(C.indexOf("_fla.")>-1){
					var carr:Array = C.split("_fla.");
					
					if(carr[0] in flaPathDic || carr[0] in local_flaPathDic){
						fla = (flaPathDic[ carr[0] ] || local_flaPathDic[ carr[0] ]) + ".fla";
						mcName = carr[1].split("_")[0];
						ExTools.openfla(stageURL +"/"+fla,mcName,true);
						_context.traceController.addTrace(stageURL+"/"+fla+"\n"+mcName,"OPEN FLA",target);
						return;
					}
				}
			}
			_context.traceController.addTrace("find nothing!","OPEN FLA",target);
		}
		private function findModel(infos:String):String{
			//naruto.cardPackage/extlibs/shop.fla
			var arr:Array = infos.split("|");
			var link:Array = [];
			
			var def:Array;
			var C:String;
			
			for(var i:int=arr.length-1;i>-1;i--){
				def = arr[i].split(":");
				C = def[1];
				try{
					if( flaMcDic[C] || local_flaMcDic[C]){
						var vals:Array = (flaMcDic[C] as Array || local_flaMcDic[C] as Array);
						var fla:String = String(vals[1]);
						var model:String = fla.substring(7,fla.indexOf("/"));
						return model;
					}
				}catch(e:Error){}
			}
			return ""
		}
		private function findallPic(data:Object):void{
			var infos:String = data["info"];
			var target:String = parseTarget(infos);
			
			var findDatas:Array=[];
			findDatas.type = DConstants.FVT_pic;
			var url:String = data["url"];
			if(!url){
				url = "";
			}
			//fla
			var arr:Array = infos.split("|");
			var link:Array = [];
			
			var def:Array;
			var C:String;
			var n:String;
			var picURL:String="";
			var path:String;
			if(arr.length> 0 && arr[arr.length-1].split(":")[1] == "com.tencent.morefun.naruto.plugin.exui.base.Image"){
				var ii:int = url.indexOf( "/assets/");
				var iii:int = url.indexOf( "assets/");
				if( ii  > -1 ){
					picURL = _context.plData.LOCAL_ASSETS_SVN ? _context.plData.LOCAL_ASSETS_SVN + "/trunk/" + url.substr(ii+1) : "";
				}else if( iii  > -1 ){
					picURL = _context.plData.LOCAL_ASSETS_SVN ? _context.plData.LOCAL_ASSETS_SVN + "/trunk/" + url.substr(iii) : "";
				}else if(url.substr(0,4) == "http"){
					picURL = url;
				}
				
				newData(findDatas,"","",url,"外部资源",picURL);
				send2FindPanel(url,findDatas);
				return
			}
			if(arr.length> 0 && arr[arr.length-1].split(":")[1] == "flash.display.Shape"){
				arr.pop();
			}
			for(var i:int=arr.length-1;i>0;i--){
				def = arr[i].split(":");
				C = def[1];
				n = def[0];
				if( quickPicDic[C] || local_quickPicDic[C]){
					var CKey:String = "(" + C + ").";
					
					var tmp:Array = link.concat([]);
					if (i == arr.length-1){
						CKey = "(" + C + ")";
						link.push("");
					}
					while(link.length >0){
						var linkStr:String = CKey + link.join(".");
						var paths:Array = flaPicDic[linkStr] || local_flaPicDic[linkStr];
						if(paths){
							
							for each(path in paths){
								picURL= _context.plData.LOCAL_FLA_PIC_SVN ? _context.plData.LOCAL_FLA_PIC_SVN + "/"+path : "";
								newData(findDatas,"","",path,"精确匹配 FLA图片",picURL);
							}
							send2FindPanel(paths.join("\n"),findDatas);
							return;
						}
						link.pop();
						
					}
					
					//返回全部
					paths = flaPicRootDic[C] || local_flaPicRootDic[C];
					for each(path in paths){
						picURL= _context.plData.LOCAL_FLA_PIC_SVN ? _context.plData.LOCAL_FLA_PIC_SVN+"/"+path : "";
						newData(findDatas,"","",path,"模糊匹配 FLA图片",picURL);
					}
					send2FindPanel(paths.join("\n"),findDatas);
					return;
				}else{
					if(n.substr(0, 8) == "instance")
						n="instance"
					link.unshift(n);
				}
			}
			_context.findController.showDatas([]);
		}
		private function newData(arr:Array,key:String="",cn:String="",en:String="",source:String="",picURL:String=""):void{
			if(!arr) return;
			var obj:Object= FindController.toItem(escape(en),escape(cn),key,source);
			obj.line = arr.length+1;
			obj.picURL = picURL;
			arr.push(obj);
		}
		private function escape(val:String):String{
			return val.replace(/</g,"&lt;").replace(/>/g,"&gt;");
		}
		private function findallkey(data:Object):void{
			var text:String;
			var key:String;
			var found:Boolean;
			arr = [];
			var infos:String = data["info"];
			var isComponent:Boolean = infos.indexOf("naruto.component.controls") != -1;
			var target:String = parseTarget(infos);
			var onlyFla:Boolean = infos.indexOf("StaticText") != -1 ||  //如果是静态的，或者没有名字的，一定是FLA
				(infos.indexOf("flash.text.TextField") != -1 && infos.split("|").pop().split(":")[0].substr(0, 8) == "instance"); 
			var findDatas:Array=[];
			findDatas.type = DConstants.FVT_key;
			var keyInfo:String = ""
			text = data["text"];
			text = StringUtil.trim(text);
			
			var fuzzyKeyInfo:String = "";
			var fuzzyFindDatas:Array=[];
			fuzzyFindDatas.type = DConstants.FVT_key;
			//as
			if( data["AS"] == "true" && !onlyFla ){
				
				if (AS_dic[text]) {
					arr = AS_dic[text].concat(arr);
				}
				
				if( arr.length>0 ){//找到了
					keyInfo += keys2cn(arr,text,true,findDatas,"精确匹配 运行中的AS");
					found = true;
				}else{
					
					for(i=0;i<AS.length;i++){
						var val:String = AS[i];
						if(text && (/[^0-9 ]{2,}/.test( val) || /[\u4e00-\u9fa5]+/.test( val)) ){
							if(text.indexOf(val) != -1 ){
								arr = AS_dic[val].concat(arr);
							}
						}
					}
					if( arr.length>0 ){//模糊匹配到了
						keyInfo+= (keyInfo?"\n":"") + "模糊匹配:" + keys2cn(arr,text,false,findDatas,"模糊匹配 运行中的AS");
						fuzzyKeyInfo += (fuzzyKeyInfo?"\n":"") + keys2cn(arr,text,true,fuzzyFindDatas,"模糊匹配 运行中的AS");
					}
						
					
				}
			} 
			//fla
			if(!found || true){//都找一下，没坏的
				var arr:Array = infos.split("|");
				var link:Array = [];
				
				var def:Array = arr[arr.length-1].split(":");
				var C:String = def[1];
				var n:String = def[0];
				if(n.substr(0, 8) == "instance"){
					if(C == "flash.text.TextField" || C == "flash.text.StaticText"){
						link.push( "TextField");
					}
				}else{
					link.push(n);
				}
				
				for(var i:int=arr.length-2;i>0;i--){
					def = arr[i].split(":");
					C = def[1];
					n = def[0];
					if( quickDic[C]){
						C = "(" + C + ").";
						var tmp:Array = link.concat([]);
						while(link.length >0){
							var linkStr:String = C + link.join(".");
							var keys:Array = flaKvDic[linkStr];
							if(keys){
								keyInfo+= (keyInfo?"\n":"") + keys2cn(keys,text,isComponent,findDatas,"精确匹配 运行中的Fla");
								fuzzyKeyInfo += (fuzzyKeyInfo?"\n":"") + keys2cn(keys,text,true,fuzzyFindDatas,"模糊匹配 运行中的FLA");
								found = found || isMatchEN2(keys,text) || onlyFla;
								break;
							}
							link.pop();
							
						}
						break;
					}else{
						if(C.indexOf("naruto.component.controls")>-1 && n.substr(0, 4) == "__id"){
							n = C.split(".").pop();
						}
						if(n.substr(0, 8) == "instance")
							n=""
						link.unshift(n);
					}
				}
			}
			var info:Object;
			var a:Object
			//尝试从 debug_fla_as.xml中查找
			if(!found && text){
				var model:String = findModel(infos);
				
				info = kvAsFlaTextMap[text];
				if(info){
					if(!(info is Array)){
						info = [info];
					}
					keyInfo += "mergedAs3FLAKvDebug.xls\n";
					for each(a in info){
						if(model && a.id.indexOf(model) == -1){
							continue;
						}
						keyInfo += a.id +"\n"+ a.word_zh + "\n";
						newData(findDatas,a.id,a.word_zh,a.word,"匹配 As3FLAKvDebug.xls");
						found = true;
					}
				}
			}
			
			//excel
			if(!found　){
				info = kvExcelMap[text];
				if(info){
					if(!(info is Array)){
						info = [info];
					}
					keyInfo = "";
					for each(a in info){
						keyInfo += a.excel +"\n"+ a.word_zh + "\n";
						newData(findDatas,a.id,a.word_zh,a.word,a.excel);
						found = true;
					}
				}
			}
			
			
			if(findDatas.length==0 && fuzzyFindDatas.length > 0){
				fuzzyKeyInfo = "模糊匹配:"+ fuzzyKeyInfo;
				send2FindPanel(fuzzyKeyInfo,fuzzyFindDatas);
			}else{
				send2FindPanel(keyInfo,findDatas);
			}
		}
		private function copyInClickboard(str:String):void{
			Clipboard.generalClipboard.clear(); 
			Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, str, false); 
		}
		private function parseTarget(infos:String):String{
			var arr:Array = infos.split("|");
			var link:Array = [];
			
			for(var i:int=arr.length-1;i>0;i--){
				var def:Array = arr[i].split(":");
				var C:String = def[1];
				var n:String = def[0];
				link.push(n);
				var index:int=C.lastIndexOf(".");
				if(index > -1){
					link.push(C.substr(index+1));
				}else{
					link.push(C);
				}
				return link.join("(")+")";
			}
			return null;
		}
		
		private function key2cn(key:String):String{
			return key +"\n"+ this.kvAsFlaMap[key].word_zh;
		}
		
		private function keys2cn(keys:Array,en:String,force:Boolean=false,findObjectArr:Array=null,sourceStr:String=""):String{
			var o:String="";
			var oo:String="";
			for each(var key:String in keys ){
				var obj:Object = kvAsFlaMap[key];
				if(!obj)
					continue;
				if(isMatchEN(key,en)){//只显示 CN
					o += key +"\n"+ obj.word_zh + "\n";
					newData(findObjectArr,key,obj.word_zh,obj.word,sourceStr);
				}else if(force){//模糊匹配
					oo += key +"\n"+ obj.word +"\n"+ obj.word_zh + "\n";
					newData(findObjectArr,key,obj.word_zh,obj.word,sourceStr);
				}
			}
			return o?o:oo;
		}
		
		private function cn(key:String):String{
			return this.kvAsFlaMap[key].word_zh;
		}
		
		private function isMatchEN2(keys:Array,en:String):Boolean{
			for each(var key:String in keys ){
				if(isMatchEN(key,en))
					return true;
			}
			return false
		}
		private function isMatchEN(key:String,en:String):Boolean{
//			trace("cn:",H(this.kvAsFlaMap[key].word).replace(/[\n\r]/g,""));
//			trace("en:",en.replace(/[\n\r]/g,""));
			var info:Object = kvAsFlaMap[key];
			if(!info)return false;
			return H(info.word) == en || H(info.word).replace(/[\n\r ]/g,"").toLocaleUpperCase() == en.replace(/[\n\r ]/g,"").toLocaleUpperCase();
		}
	}
}
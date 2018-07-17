package com.naruto.debugger.helper
{
	import com.naruto.debugger.DTabContext;
	import com.naruto.debugger.DUtils;
	import com.naruto.debugger.TranslateController;
	import com.naruto.debugger.gm.PlatformData;
	
	import flash.filesystem.File;
	import flash.utils.Dictionary;
	
	import mx.controls.Alert;
	
	import controllers.panels.FindController;
	import controllers.panels.GMController;
	import controllers.panels.ToolsController;

	public class LoadDataHelper
	{
		private var  kvs:Array;
		private var _tc:TranslateController;
		private var _toc:ToolsController;
		private var _fc:FindController;
		private var _gmc:GMController;
		static private var _loader:QueueCacheLoader;
		
		private var _context:DTabContext;
		public function LoadDataHelper(context:DTabContext)
		{
			_context = context;
			_context.loadDataHelper = this;
			_tc=_context.translateController;
			_fc=_context.findController;
			_toc = _context.toolsController;
			_gmc = _context.gmController;
			if(!_loader)
				_loader = new QueueCacheLoader();
		}
		
		private var _successCount:int;
		private var _failCount:int;
		private function feedback(isSucc:Boolean,url:String=""):void{
			if(isSucc){
				_context.traceController.addTrace("loaded:["+ url+"]");
				_successCount++
			}else {
				_context.traceController.addTrace("load error:["+ url+"]");
				_failCount++;
			}
			var sucPct:int = int(_successCount/kvs.length*100);
			var failPct:int = int(_failCount/kvs.length*100) + sucPct;
			if (_successCount + _failCount == kvs.length) {
				if(_failCount>0){
					_toc.setLoadState("Some files failed to load!",sucPct,failPct);
				}else{
					_toc.setLoadState("Files loaded!",sucPct,failPct);
				}
			}else{
				
				_toc.setLoadState("Loading files: "+sucPct+"%",sucPct,failPct);
				
				
			}
		}
		public function cleanAndReload():void{
			_successCount=0;
			_failCount=0;
			_loader.cleanCache(kvs);
			init("",kvs);
		}
		public function init(version:String,kvs:Array):void {
			this.kvs = kvs;
			var path:String = "app:/libs/v3/";
//			_loader.loadFile(path + "fla_kv_dic.txt",fileKvCompleteHandler,function(data:Array):void{ 
//				_tc.flaKvDic = data[0];
//				_tc.quickDic = data[1];
//			},false,_loader.preParseTextFile);
//			_loader.loadFile(path + "fla_pic_dic.txt",filePicCompleteHandler,function(data:Array):void{ 
//				//[flaPicDic,quickPicDic,flaPicRootDic]
//				_tc.local_flaPicDic = data[0];
//				_tc.local_quickPicDic = data[1];
//				_tc.local_flaPicRootDic = data[2];
//			},false,_loader.preParseTextFile);
//			_loader.loadFile(path + "fla_mc_dic.txt",fileMcCompleteHandler,function(data:Array):void{ 
//				//[flaMcDic,flaPathDic]
//				_tc.local_flaMcDic = data[0];
//				_tc.local_flaPathDic = data[1];
//			},false,_loader.preParseTextFile);
			_loader.loadFile(kvs[2],fileKvCompleteHandler,function(data:Array):void{ 
				_tc.flaKvDic = data[0];
				_tc.quickDic = data[1];
			},true,_loader.preParseTextURLLoader,feedback);
			
			
			_loader.loadFile(kvs[3],filePicCompleteHandler,function(data:Array):void{ 
				//[flaPicDic,quickPicDic,flaPicRootDic]
				_tc.flaPicDic = data[0];
				_tc.quickPicDic = data[1];
				_tc.flaPicRootDic = data[2];
			},true,_loader.preParseTextURLLoader,feedback);
			
			
			_loader.loadFile(kvs[4],fileMcCompleteHandler,function(data:Array):void{ 
				//[flaMcDic,flaPathDic]
				_tc.flaMcDic = data[0];
				_tc.flaPathDic = data[1];
				_fc.addDatas(null, null, data[2]);
			},true,_loader.preParseTextURLLoader,feedback);
			
			_loader.loadFile(kvs[5],envCompleteHandler,function(data:Array):void{ 
				//[plData]
				_context.plData = data[0];
				_toc.updateLinkSVNBtEnable();
			},true,_loader.preParseTextURLLoader,feedback);
		
			
			_loader.loadFile(kvs[0], parsekvAsFla,function(data:Array):void{ 
				//[kvAsFlaMap,kvAsFlaTextMap]
				_tc.kvAsFlaMap = data[0];
				_tc.kvAsFlaTextMap = data[1];
				
				_fc.addDatas(null, data[2], null);
			},true,null,feedback);
			
			
			_loader.loadFile(/*"D:/workspace/火影国际/de/trunk_config/dev4/config/i18n/KvDesignxlsDebugCFG.bin"*/  kvs[1] , parsekvExcel,function(data:Array):void{ 
				//[kvExcelMap]
				_tc.kvExcelMap = data[0];
				_gmc.addNameMap(data[0]);
				_fc.addDatas(data[1], null, null);
				
			},true,null,feedback);
		}
		public function saveToLocal():void{
			if (_successCount == kvs.length) {
				try{
					var f:File = new File(File.applicationDirectory.resolvePath("ext/i18n").nativePath);
					var dir:String = f.nativePath;
					if(f.exists){
						f.deleteDirectory(true);
					}
					f.createDirectory();
					for each(var filePath:String in kvs){
						var c:Cache = _loader.cache[filePath] as Cache;
						if(c.bytes){
							var name:String = filePath.substring(filePath.lastIndexOf("/") +1);
							ExTools.writeBinaryFile(dir+"/"+name,c.bytes);
						}else if(c.textContent){
							
						}
					}
					f.openWithDefaultApplication();
				}catch(e:Error){
					Alert.show(e.message);
				}
			}
		}
		
		
		//parse remote file
		static public function parsekvAsFla(c:Cache):Array{
			var kvAsFlaMap:Dictionary = new Dictionary;
			var kvAsFlaTextMap:Dictionary = new Dictionary;
			try{
				c.bytes.uncompress();
			}
			catch (err:*) { Alert.show("uncompress error")}
			c.bytes.position =0;
			var objs:Object = c.bytes.readObject();
			for each(var obj:Object in objs) {
				FindController.toItem2(obj,obj.word,obj.word_zh,obj.id);
				kvAsFlaMap[obj.id] = obj;
				
				var en:String = TranslateController.H(obj.word);
				if(!kvAsFlaTextMap[en]){
					kvAsFlaTextMap[en] = obj;
				}else if(kvAsFlaTextMap[en] is Array){
					kvAsFlaTextMap[en].push(obj);
				}else{
					kvAsFlaTextMap[en] = [kvAsFlaTextMap[en],obj];
				}
			}
			return [kvAsFlaMap,kvAsFlaTextMap,objs];
		}
		static public function parsekvExcel(c:Cache):Array{
			var kvExcelMap:Dictionary = new Dictionary;
			try{
				c.bytes.uncompress();
			}
			catch (err:*) { Alert.show("uncompress error")}
			c.bytes.position =0;
			var objs:Object = c.bytes.readObject();
			for each(var obj:Object in objs) {
				FindController.toItem2(obj,obj.word,obj.word_zh,obj.id);
				if(!kvExcelMap[obj.word]){
					kvExcelMap[obj.word] = obj;
				}else if(kvExcelMap[obj.word] is Array){
					kvExcelMap[obj.word].push(obj);
				}else{
					kvExcelMap[obj.word] = [kvExcelMap[obj.word],obj];
				}
				
			}
			return [kvExcelMap,objs];
		}
		static public function envCompleteHandler(c:Cache):Array{
			var plData:PlatformData = new PlatformData;
			
			
			var fileContents:String = c.textContent;
			
			
			var lines:Array = fileContents.split("\n");
			for(var i:int=0;i<lines.length;i++){
				var line:String = lines[i];
				if(line){
					var arr:Array = line.split("=");
					
					
					var k:String = arr[0];
					var v:String = arr[1];
					
					if(k in plData){
						plData[k] = v;
					}
					
				}
			}
			var data:Object = DUtils.loadSettingValue (plData.LOCAL_FLA_PIC_SVN,{});
			plData.client_path = data["client_path"];
			plData.designer_path = data["designer_path"];
				
			return [plData];
		}
		static public function fileMcCompleteHandler(c:Cache):Array{
			var flaMcDic:Dictionary = new Dictionary;
			var flaPathDic:Dictionary = new Dictionary;
			
			var fileContents:String = c.textContent;
			var mcs:Array = [];
			
			var lines:Array = fileContents.split("\n");
			for(var i:int=0;i<lines.length;i++){
				var line:String = lines[i];
				if(line){
					var arr:Array = line.split("|");
					flaMcDic[arr[0]]=arr;
					
					var p:String = arr[1];
					p = p.substr(p.lastIndexOf("/")+1);
					flaPathDic[p] = arr[1];
					
					var item:Object = FindController.toItem(arr[2],arr[1],arr[0]);
					
					mcs.push(item);
				}
			}
			
			return [flaMcDic , flaPathDic , mcs];
		}
		static public function fileKvCompleteHandler(c:Cache):Array{
			var flaKvDic:Dictionary = new Dictionary;
			var quickDic:Dictionary = new Dictionary;
			
			var fileContents:String = c.textContent;
			
			
			var lines:Array = fileContents.split("\n");
			for(var i:int=0;i<lines.length;i++){
				var line:String = lines[i];
				if(line){
					var arr:Array = line.split("|");
					var keys:Array = flaKvDic[arr[0]];
					if(!keys){
						flaKvDic[arr[0]] = keys = [];
					}
					keys.push(arr[1]);
					
					var uiClassName:String = String(arr[0]);
					uiClassName = uiClassName.replace(/\).*/,"");
					uiClassName = uiClassName.replace(/\(/,"");
					quickDic[uiClassName]=true;
				}
			}
			
			return [flaKvDic,quickDic];
		}
		static public function filePicCompleteHandler(c:Cache):Array{
			var flaPicDic:Dictionary = new Dictionary;
			var quickPicDic:Dictionary = new Dictionary;
			var flaPicRootDic:Dictionary = new Dictionary;
			
			
			var fileContents:String = c.textContent;
			
			
			var lines:Array = fileContents.split("\n");
			for(var i:int=0;i<lines.length;i++){
				var line:String = lines[i];
				if(line){
					var arr:Array = line.split("|");
					var key:String = arr[0];
					var path:String = arr[1];
					
					var paths:Array = flaPicDic[key];
					if(!paths){
						flaPicDic[key] = paths = []
					}
					if(paths.indexOf(path) == -1){
						paths.push(path);
					}
					
					var uiClassName:String = String(arr[0]);
					uiClassName = uiClassName.replace(/\).*/,"");
					uiClassName = uiClassName.replace(/\(/,"");
					quickPicDic[uiClassName]=true;
					
					
					paths = flaPicRootDic[uiClassName];
					if(!paths){
						flaPicRootDic[uiClassName] = paths = []
					}
					if(paths.indexOf(path) == -1){
						paths.push(path);
					}
				}
			}
			
			return [flaPicDic,quickPicDic,flaPicRootDic];
			
		}
		
	}
}

package com.naruto.debugger.helper
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	import mx.controls.Alert;
	
	import org.xxtea.XXTEA;

	public class ExTools
	{
		static private var OpenFlaJSFL:String = File.applicationDirectory.resolvePath("ext/openMc.jsfl").nativePath;
		static private var OpenFlaCMD:String = File.applicationDirectory.resolvePath("ext/TempOpenFla.bat").nativePath;
		static private var OpenSVNLogVBS:String = File.applicationDirectory.resolvePath("ext/TempOpenSVNLog.vbs").nativePath;
		static private var CRC_CMD:String = File.applicationDirectory.resolvePath("ext/co_rep_commit.bat").nativePath;
		
		static public var LANGUAGE_CONFIG_FILE:String = File.applicationDirectory.resolvePath("ext/languages/LanguageConfig.xml").nativePath;
		static private const key:String = 'yldjg8FZHsasSG4mWfnuQlACWFDaWRmhz575SVSQewD3YMYmywYKbbVxrTH12xJ1';
		public function ExTools()
		{
			
		}
		static private function getOpenFlaJSFLContent(flaPath:String,mcName:String):String{
			var str:String = "\n\
			var file = '" + flaPath + "';\n\
			var doc = fl.openDocument(   file );\n\
			doc.library.selectItem('"+mcName+"');\n\
			doc.library.editItem();"
			return str
		}
		static private function getOpenFlaJSFLContent2(flaPath:String,mcName:String):String{
			var str:String = "\n\
				var file = '" + flaPath + "';\n\
				var doc = fl.openDocument(   file ); \n\
				var lib = doc.library; \n\
				var len = lib.items.length; \n\
				for(var i = 0;i<len;i++){ \n\
					var item = lib.items[i]; \n\
					if(item.itemType == 'movie clip'||item.itemType == 'button'||item.itemType == 'graphic'){ \n\
						fl.trace(item.name+', '+'"+mcName+"'); \n\
						if(item.name.indexOf('"+mcName+"')>-1){ \n\
							doc.library.selectItem(item.name); \n\
							doc.library.editItem();  \n\
						} \n\
					} \n\
				} \n";
			return str
		}
		static public function callCMD(batName:String,logCB:Function=null):void{
			var process:NativeProcess = new NativeProcess();
			var pInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			
			pInfo.executable = new File("C:\\Windows\\System32\\cmd.exe");
			pInfo.workingDirectory = File.applicationDirectory.resolvePath("ext");
			var args:Vector.<String> = new Vector.<String>(); 
			args.push("/c"); 
			args.push(batName); 
			pInfo.arguments = args;
			
			try
			{
				trace("start running bat...");
				process.start(pInfo);
			}
			catch (err:Error)
			{
				
				trace("start faile:"+err.message);
				process.exit(true);
			}
			var outputData:String="";
			process.addEventListener(NativeProcessExitEvent.EXIT, function onExit(e:Event):void{ 
				outputData = outputData.replace(XXTEA.decryptToString(key,"1234"),"");
				outputData = outputData.replace(/\r/g,"");
				if(logCB != null) 
					logCB(outputData);
			});
//			process.addEventListener(Event.STANDARD_OUTPUT_CLOSE, onOutputClose);
			
			process.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onOutputData);
			process.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, onOutputData);
			
			process.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, errEventHandler);
			process.addEventListener(IOErrorEvent.STANDARD_INPUT_IO_ERROR, errEventHandler);
//			process.addEventListener(ProgressEvent.STANDARD_INPUT_PROGRESS, inputProgressListener);
//			process.addEventListener(Event.STANDARD_INPUT_CLOSE, onStandardInputClose);
			
			function onOutputData(e:Event):void{
				//var str:String = process.standardOutput.readBytes(process.standardOutput.bytesAvailable);
				var bytes:ByteArray = new ByteArray;
				process.standardOutput.readBytes(bytes, 0, process.standardOutput.bytesAvailable);
				var str:String = bytes.readMultiByte(bytes.length, "GBK");
				
				bytes = new ByteArray;
				process.standardError.readBytes(bytes, 0, process.standardError.bytesAvailable);
				var errstr:String = bytes.readMultiByte(bytes.length, "GBK");
				
				outputData+= str;
				outputData+= errstr;
			}
		}
		static private function errEventHandler(e:Event):void{
			trace("process error:"+e.type);
		}
		static public function openfla(flaPath:String,mcName:String,isFind:Boolean=false):void{
			if(isFind){
				writeTextFile(OpenFlaJSFL, getOpenFlaJSFLContent2(flaPath,mcName),"GBK");
			}else{
				writeTextFile(OpenFlaJSFL, getOpenFlaJSFLContent(flaPath,mcName),"GBK");
			}
			var f:File=new File(OpenFlaJSFL);
			f.openWithDefaultApplication();
		}
		
		static public function openSVNLog(pathOrUrl:String):void{
			var str:String = 'WScript.CreateObject("WScript.Shell").Run "TortoiseProc.exe /command:log /path:""'+pathOrUrl+'""" , 0, True';
			writeTextFile(OpenSVNLogVBS, str,"GBK");
			
			var f:File=new File(OpenSVNLogVBS);
			f.openWithDefaultApplication();
			
		}
		
		static public function openSVNCheckout(url:String):void{
			var f:File = new File(File.desktopDirectory.nativePath+'/temp');
			if(!f.exists){
				f.createDirectory();
			}
			var str:String = 'WScript.CreateObject("WScript.Shell").Run "TortoiseProc.exe /command:checkout /url:""'+url+'""  /path:""'+f.nativePath+'""", 0, True';
			writeTextFile(OpenSVNLogVBS, str,"GBK");
			
			f=new File(OpenSVNLogVBS);
			f.openWithDefaultApplication();
			
		}
		static public function checkoutReplayCommit(url:String,file:File,cb:Function):void{
			
			var root:String = url.substring(0,url.lastIndexOf("/"));
			var name:String = url.substring(url.lastIndexOf("/") +1);
			var str:String = '::echo %PATH% \r\n\
cd /d %~dp0 \r\n\
rd /q /s temp_workingcopy \r\n\
md temp_workingcopy \r\n\
cd temp_workingcopy \r\n\
svn co --depth=empty "' + root +'" . ' + XXTEA.decryptToString(key,"1234") + '\r\n\
svn up "' + name + '" \r\n\
copy /y "' + file.nativePath + '" "'+name+'" \r\n\
svn commit . -m "commit by Translation Debugger" \r\n\
exit \r\n';
			
			
			writeTextFile(CRC_CMD, str,"GBK");
			
			callCMD(CRC_CMD,cb);
			return;
			
			var f:File=new File(CRC_CMD);
			f.openWithDefaultApplication();
		}
		static public function openExtDir():void{
			var f:File=File.applicationDirectory.resolvePath("ext");
			f.openWithDefaultApplication();
		}
		static public function checkout(url:String,cb:Function):void{
			
			var root:String = url.substring(0,url.lastIndexOf("/"));
			var name:String = url.substring(url.lastIndexOf("/") +1);
			var dir:String = root.substring(root.lastIndexOf("/") +1);
			var str:String = '::echo %PATH% \r\n\
				cd /d %~dp0 \r\n\
				rd /q /s ' + dir + ' \r\n\
				md ' + dir + ' \r\n\
				cd ' + dir + ' \r\n\
				svn co --depth=empty "' + root +'" . ' + XXTEA.decryptToString(key,"1234") + '\r\n\
				svn up "' + name + '" \r\n\
				exit \r\n';
			
			writeTextFile(CRC_CMD, str,"GBK");
			callCMD(CRC_CMD,cb);
		}
		static public function checkoutRemoveCommit(url:String,cb:Function):void{
			
			var root:String = url.substring(0,url.lastIndexOf("/"));
			var name:String = url.substring(url.lastIndexOf("/") +1);
			var str:String = '::echo %PATH% \r\n\
				cd /d %~dp0 \r\n\
				rd /q /s temp_workingcopy \r\n\
				md temp_workingcopy \r\n\
				cd temp_workingcopy \r\n\
				svn co --depth=empty "' + root +'" . ' + XXTEA.decryptToString(key,"1234") + '\r\n\
				svn up "' + name + '" \r\n\
				svn delete "'+name+'" \r\n\
				svn commit . -m "commit by Translation Debugger" \r\n\
				exit \r\n';
			
			
			writeTextFile(CRC_CMD, str,"GBK");
			callCMD(CRC_CMD,cb);
		}
		static public function checkoutAddCommit(url:String,file:File,cb:Function):void{
			
			var str:String = 
				'::echo %PATH% \r\n\
				cd /d %~dp0 \r\n\
				rd /q /s temp_workingcopy \r\n\
				md temp_workingcopy \r\n\
				cd temp_workingcopy \r\n\
				svn co --depth=empty "' + url +'" . ' + XXTEA.decryptToString(key,"1234") + '\r\n';
			
			
			str+=  file.isDirectory? 
				'xcopy "' + file.nativePath + '" "'+ file.name+'\\" \r\n':
				'copy /y "' + file.nativePath + '" "'+ file.name+'" \r\n';
			
			
			str+=	
				'svn add "' + file.name + '" \r\n\
				svn commit . -m "commit by Translation Debugger" \r\n\
				exit \r\n';
			
			
			writeTextFile(CRC_CMD, str,"GBK");
			
			callCMD(CRC_CMD,cb);
			return;
			
			var f:File=new File(CRC_CMD);
			f.openWithDefaultApplication();
		}
		static public function openTempPicDir():void{
			File.applicationDirectory.resolvePath("ext/temp_workingcopy").openWithDefaultApplication();
		}
		public static function readTextFile(filePath:String,showErr:Boolean=true):String
		{
			var stream:FileStream = new FileStream();
			var str:String;
			try
			{
				stream.open(new File(filePath), FileMode.READ);
				stream.position = 0;
				str = stream.readUTFBytes(stream.bytesAvailable);
				stream.close();
			}
			catch (err:Error)
			{
				if(showErr)
					Alert.show("read file Error:" + filePath + "\n" + err.getStackTrace(), "错误");
				str = "";
			}
			return str;
		}
		
		public static function writeTextFile(filePath:String, text:String,encoding:String="utf-8"):void
		{
			var stream:FileStream = new FileStream();
			try
			{
				stream.open(new File(filePath), FileMode.WRITE);
				stream.writeMultiByte(text,encoding);
				stream.close();
			}
			catch (err:Error)
			{
				Alert.show("write file Error:" + filePath + "\n" + err.getStackTrace(), "错误");
			}
		}
		public static function writeBinaryFile(filePath:String, bytes:ByteArray):void
		{
			var stream:FileStream = new FileStream();
			try
			{
				stream.open(new File(filePath), FileMode.WRITE);
				stream.writeBytes(bytes);
				stream.close();
			}
			catch (err:Error)
			{
				Alert.show("write file Error:" + filePath + "\n" + err.getStackTrace(), "错误");
			}
		}
	}
}
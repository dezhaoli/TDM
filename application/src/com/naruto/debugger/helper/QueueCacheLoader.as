package com.naruto.debugger.helper
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

	public class QueueCacheLoader
	{
		private var _cache:Dictionary = new Dictionary();
		private var _queue:Queue;
		private var _dp:EventDispatcher = new EventDispatcher;
		public function QueueCacheLoader()
		{
		}

		public function get cache():Dictionary
		{
			return _cache;
		}
		public function cleanCache(urls:Array):void{
			for(var i:int=0;i<urls.length;i++){
				var filePath:String = urls[i];
				var c:Cache = _cache[filePath] as Cache;
				if(c && c.state == Cache.S_COMPLETE){
					delete _cache[filePath];
					trace( "delete cache["+ filePath + "]");
				}
			}
		}

		/**
		 *  @parser fuction(c:Cache):void. Maybe cache.bytes or cache.textContent is available.
		 * 
		 * 	@callback fuction(data:Array):void
		 * 
		 * 	@remote if remote is true, use urlLoader to download and later cache.bytes is available. 
		 * 			If remote is false, use filestream to load and later cache.fileStream is available.
		 * 
		 * 	@preParser fuction(c:Cache):void 
		 * 
		 * */
		public function loadFile(url:String,parser:Function,callback:Function,remote:Boolean=false,preParser:Function=null,feedback:Function=null):void{
			if(!_queue) _queue = new Queue;
			_queue.push(url,parser,callback,remote,preParser,feedback);
			
			next();
		}
		public function preParseTextFile(c:Cache):void{
			var f:FileStream = c.fileStream;
			c.textContent = f.readUTFBytes(f.bytesAvailable); 
			f.close();
			c.fileStream = null;
		}
		public function preParseTextURLLoader(c:Cache):void{
			var b:ByteArray = c.bytes;
			c.textContent = b.readUTFBytes(b.bytesAvailable); 
		}
		private function next():void{
			if(_queue.loading){
				return;
			}
			if(_queue.length==0){
				return;
			}
			var u:Unit = _queue.pop();
			_queue.loading = true;
			var filePath:String = u.filePath,parser:Function=u.parser,callback:Function = u.callback,remote:Boolean= u.remote,preParser:Function=u.preParser;
			var c:Cache = _cache[filePath] as Cache;
			if(!c){//没加载过
				_cache[filePath] = c = new Cache;
				c.state = Cache.S_START;
				//加载
				if(!remote){//本地资源
					var kvf:File;
					var fileStream:FileStream;
					kvf = File.applicationDirectory.resolvePath(filePath);
					fileStream = new FileStream(); 
					fileStream.addEventListener(Event.COMPLETE, function(e:Event):void{
						e.currentTarget.removeEventListener(e.type, arguments.callee);
						c.state = Cache.S_COMPLETE;
						c.fileStream = fileStream;
						if(preParser!=null){
							preParser(c);
						}
						c.data = parser(c);
						_dp.dispatchEvent(new Event(filePath));
					});
					fileStream.openAsync(kvf, FileMode.READ);
				}else{
					var urlloader:URLLoader = new URLLoader();
					urlloader.dataFormat = URLLoaderDataFormat.BINARY;
					urlloader.addEventListener(Event.COMPLETE,function(e:Event):void{
						e.currentTarget.removeEventListener(e.type, arguments.callee);
						c.state = Cache.S_COMPLETE;
						c.bytes = e.currentTarget.data;
						if(preParser!=null){
							preParser(c);
						}
						c.data = parser(c);
						_dp.dispatchEvent(new Event(filePath));
					});
					urlloader.addEventListener(IOErrorEvent.IO_ERROR, function(e:Event):void{
						e.currentTarget.removeEventListener(e.type, arguments.callee);
						if(u.feedback != null){
							u.feedback(false,filePath);
						}
						delete _cache[filePath];
						_queue.loading = false;
						next();
					});
					urlloader.load(new URLRequest(filePath));
				}
				//监听
				_dp.addEventListener(filePath,function(e:Event):void{
					e.currentTarget.removeEventListener(e.type, arguments.callee);
					execute();
				});
			}else if(c.state == Cache.S_START){//加载中
				//监听
				_dp.addEventListener(filePath,function(e:Event):void{
					e.currentTarget.removeEventListener(e.type, arguments.callee);
					execute();
				});
				
			}else{//加载过
				execute();
			}
			
			function execute():void{
				callback(c.data);
				if(u.feedback != null){
					u.feedback(true,filePath);
				}
				_queue.loading = false;
				next();
			}
		}
	}
}

class Queue
{
	public var index:uint;
	public var count:uint;
	public var loading:Boolean;
	public var list:Array;
	
	public function Queue()
	{
		list = [];
	}
	
	public function push(filePath:String,parser:Function,callback:Function,remote:Boolean,preParser:Function,feedback:Function):void{
		var u:Unit = new Unit;
		u.filePath = filePath;
		u.parser = parser;
		u.callback = callback;
		u.remote = remote;
		u.preParser = preParser;
		u.feedback = feedback;
		list.push(u);
	}
	public function pop():Unit{
		return list.shift();
	}
	public function get length():uint { return list.length; }
}
class Unit
{
	public var filePath:String;
	public var parser:Function;
	public var preParser:Function;
	public var feedback:Function;
	public var callback:Function;
	public var remote:Boolean;
	public function Unit()
	{
		
	}
}

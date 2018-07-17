package components.windows
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;

	
	public class SVNEntry extends EventDispatcher
	{
		
		//是否正在删除中
		public var isOpDel:Boolean;
		//是否正在添加中
		public var isOpAdd:Boolean;
		//是否正在替换中
		public var isOpRep:Boolean;
		
		private var _src:Object;
		public var isDir:Boolean;
		public var isAdd:Boolean;
		public var url:String;
		public var name:String;
		public var isPic:Boolean;
		public var file:File;
		public function SVNEntry()
		{
			
		}
		
		
//		public function set src(value:Object):void
//		{
//			_src = value;
//		}

		public function update():void{
			this.dispatchEvent(new Event("reflesh"));
		}
	}
}
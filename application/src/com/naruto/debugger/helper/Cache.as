package com.naruto.debugger.helper
{
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;

	public class Cache
	{
		static public const S_COMPLETE:String = "FINISH";
		static public const S_START:String = "START";
		public var data:Object;
		public var fileStream:FileStream;
		public var bytes:ByteArray;
		public var state:String;
		public var filePath:String;
		public var textContent:String;
	}
}
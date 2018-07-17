package 
{
	import com.tencent.morefun.framework.log.logger;
	import com.tencent.morefun.naruto.plugin.ui.layer.LayerManager;
	import com.tencent.morefun.naruto.util.GameTip;
	import com.tencent.morefun.naruto.util.StrReplacer;
	import com.tencent.morefun.naruto.util.TimeUtils;
	
	import flash.net.registerClassAlias;
	import flash.system.System;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	/**
	 *语言包 
	 * @author Naruto
	 * 
	 */
	public class I18n {
		public static var  m_lang:String = "zh";
		public static var  kvMaps:Dictionary;
		private static var dic:Dictionary = new Dictionary(true);
		public static var lastUsedTime:Dictionary = new Dictionary(true);
		private static var counter:int = 0;
		public static const numStr:String = " x";
		
		
		static public var _debug_recordAS:Function;
		static public var _debug_recordRepAS:Function;
		static public var _debugMode:Function;
		static public var _breakpoint:Function;
		static public var _recordSocketStr:Function;
		
		static public function recordSocketStr(protocol:*):void
		{
			if(_recordSocketStr != null)
				_recordSocketStr(protocol);
		}
		
		static public function breakpoint(caller:*):void
		{
			if(_breakpoint != null)
				_breakpoint(caller);
		}
		
		static public function recordAS(key:String, value:String):void
		{
			if(_debug_recordAS != null)
				_debug_recordAS(key, value);
		}
		
		static public function recordRepAS(srcText:String,repText:String):void
		{
			if(_debug_recordRepAS != null)
				_debug_recordRepAS(srcText, repText);
		}
		
		public function I18n() {
		}
		public static function set Language(v:String):void{
			m_lang = v;
		}
		public static function lang(key:String):String {
			var result:String;
			if(kvMaps.hasOwnProperty(key)){
				result = kvMaps[key]["word"];
				result = result.replace(/\\n/g,"\n").replace(/\\r/g, "\r").replace(/\\\"/g, "\"").replace(/\\\'/g, "\'");
				result = result.replace(/[‘’]/g,"'").replace(/[“”]/g,"\"");
				if(result.length > 1)
				{
					dic[result.replace(/<[^>]+>/g,"").replace(/<font color='#/g,"")] = key;
				}
				lastUsedTime[key] = counter++;
				
				if (_debugMode != null && _debugMode()) {
					result = "(" + key + ")" + result;
				}
				recordAS(key, result);
				return result;
			}
			else{
				trace("missAsKey:" + key);
				return key;
			}
		}
		
		public static function getAsKeyByMagicString(magicString:String):String
		{
			return dic[magicString.replace(/<[^>]+>/g,"").replace(/<font color='#/g,"")];
		}
		
		public static function getAsKeyByFinalContent(content:String):Array
		{
			var msg:String = "";
			var result:Array = [];
			content = content.replace(/\r/g, "").replace(/\n/g, "");
			var magicStr:String;
			for(var _magicStr:String in dic)
			{
				magicStr = _magicStr.replace(/\r/g, "").replace(/\n/g, "");
				if(magicStr == content || magicStr.length>2 && content.length >= magicStr.length && content.indexOf(magicStr)>-1)
				{
					result.push(dic[_magicStr]);
				}
			}
			result = result.concat(StrReplacer.getAllPossibleMagicString(content));
			return result;
		}
		
		public static function getMagicString(key:String):String {
			var result:String;
			if(kvMaps.hasOwnProperty(key)){
				result = kvMaps[key]["word"];
				result = result.replace(/\\n/g,"\n").replace(/\\r/g, "\r").replace(/\\\"/g, "\"").replace(/\\\'/g, "\'");
				result = result.replace(/[‘’]/g,"'").replace(/[“”]/g,"\"");
				return result;
			}
			return key;
		} 
		
		
		public static function  initData(bin:ByteArray):void{
			try{
				bin.uncompress();
			}
			catch (err:*) { }
			if(bin.position == (bin.length-1)){
				logger.output("Rread bin error");
				trace("Rread bin error");
				bin.position=0;
				
			}
			var stractObjectMap:Object = bin.readObject();
			var m_maps:Dictionary= new Dictionary();
			for each(var obj:Object in stractObjectMap) {
				m_maps[obj.id] = obj;
			}
			kvMaps =  m_maps;
		}
		public static function registerClass(c:Class):void {
			if(c != null) {
				var className:String = getQualifiedClassName(c);
				registerClassAlias(className.split("::").pop(), c); //
				//m_classRegistered[className.split("::").pop()] = c;
			}
		}
	}
}

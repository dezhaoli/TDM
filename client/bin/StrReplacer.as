package com.tencent.morefun.naruto.util
{	import flash.utils.Dictionary;


    public class StrReplacer
    {
        public static const MAGIC_CHAR:String                                   =   "%";
        public static const FIRST_MAGIC_CHAR_INDEX:uint                         =   1;
		private static var dic:Dictionary = new Dictionary(true);

        public static function replace(magicString:String, replacement:Object):String
        {
            if (magicString == null || replacement == null)
                return null;
			
            if (replacement is Array)
            {
                var idx:uint = FIRST_MAGIC_CHAR_INDEX;
                var str:String = magicString;
                var len:int = replacement.length;

                for (var i:int=0; i<len; ++i)
                {
                    str = str.replace(MAGIC_CHAR + idx, replacement[i]);
                    ++idx;
                }
				if(str.length > 1)
				{
					dic[str.replace(/<[^>]+>/g,"").replace(/<font color='#/g,"")] = magicString;
				}
				I18n.recordRepAS(magicString, str);
                return str;
            }
            else
            {
				var result:String = magicString.replace(MAGIC_CHAR + FIRST_MAGIC_CHAR_INDEX, String(replacement));
				if(result.length > 1)
				{
					dic[result.replace(/<[^>]+>/g,"").replace(/<font color='#/g,"")] = magicString;
				}
				I18n.recordRepAS(magicString, result);
                return result;
            }

            return null;
        }
		
		public static function getAllPossibleMagicString(content:String):Array
		{
			//trace(dic);
			if(!content || content.length==0)
			{
				return [];
			}
			var result:Array = [];
			var asKey:String;
			content = content.replace(/\r/g, "").replace(/\n/g, "");
			var key:String;
			for(var _key:String in dic)
			{
				key = _key.replace(/\r/g, "").replace(/\n/g, "");
				if(content.indexOf(key)>-1)
				{
					asKey = I18n.getAsKeyByMagicString(dic[key]);
					if(asKey && asKey.length > 0)
					{
						result.push(asKey);
					}
				}
			}
			return result;
		}
		
		/**
		 * 替换多个
		 * @param magicString
		 * @param replacement
		 * @return 
		 * 
		 */
		public static function replace2(magicString:String, replacement:Object):String
		{
			 var str:String= "null";
			if (magicString == null || replacement == null)
				return null;
			
			if (replacement is Array)
			{
				var idx:uint = FIRST_MAGIC_CHAR_INDEX;
				str = magicString;
				var len:int = replacement.length;
				
				for (var i:int=0; i<len; ++i)
				{
					var myPattern:RegExp = new RegExp(MAGIC_CHAR + idx, "g");
					str = str.replace(myPattern, replacement[i]);
					++idx;
				}
				
				return str;
			}
			else
			{
				str = magicString.replace(MAGIC_CHAR + FIRST_MAGIC_CHAR_INDEX, String(replacement));
			}
			I18n.recordRepAS(magicString, str);
			return str;
		}

        public function StrReplacer()
        {
            throw new Error(StrReplacer + " can not be instantiated.");
        }
    																
		public function autoSetNull():void
		{

		}
	}
}
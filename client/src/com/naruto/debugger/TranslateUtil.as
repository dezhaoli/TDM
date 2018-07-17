package com.naruto.debugger 
{
	import com.naruto.debugger.Hy;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.text.StaticText;
	import flash.text.TextField;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	/**
	 * ...
	 * @author Devin Lee
	 */
	public class TranslateUtil 
	{
		static public function getTName(obj:DisplayObject):String {
			var n:String;
			var p:DisplayObjectContainer;
			
			if (obj is Hy.MovieClipButton) {
				p = obj.parent;
				n = getCName(Object(obj).view);
			}else if (obj is Bitmap) {
				p = obj.parent;
				n = getCName(Bitmap(obj).bitmapData);
			}else{
				p = obj.parent;
				n = getCName(obj);
			}
			
			
			while (p && !(p is Stage)) {
				n = getCName(p) + "|" + n;
				if (p.name == "background" && p.parent is Hy.BaseBox) {
					p = Object(p.parent).content;
				}else {
					p = p.parent;
				}
				
			}
			return n;
		}
		
		static public function getCName(obj:Object):String 
		{
			
			var i:int;
			var n:String = getQualifiedClassName(obj);
			n = n.replace("::", ".");
			return obj.name + ":" + n;
		}
		static public function getClass(obj:DisplayObject):String 
		{
			var n:String = getQualifiedClassName(obj);
			n = n.replace("::", ".");
			return n;
		}
		
		
		
		
	}

}
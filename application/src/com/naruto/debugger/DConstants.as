package com.naruto.debugger
{
	import flash.utils.Dictionary;

	public final class DConstants
	{
		
		public static const MinClientVersion:Number = 24;
		
		// Core app id
		public static const ID:String = "com.dezhaoli.debugger.core";
		
		
		// Paths
		public static const PATH_UPDATE:String = "http://dev.i18n.huoying.qq.com/AutoUpdate/update.xml";
		public static const PATH_TICKER:String = "http://www.TranslationDebugger.com/xml/3/ticker.xml";
		
		
		// Commands
		public static const COMMAND_HELLO:String = "HELLO";
		public static const COMMAND_INFO:String = "INFO";
		public static const COMMAND_TRACE:String = "TRACE";
		public static const COMMAND_PAUSE:String = "PAUSE";
		public static const COMMAND_RESUME:String = "RESUME";
		public static const COMMAND_BASE:String = "BASE";
		public static const COMMAND_INSPECT:String = "INSPECT";
		public static const COMMAND_GET_OBJECT:String = "GET_OBJECT";
		public static const COMMAND_GET_PROPERTIES:String = "GET_PROPERTIES";
		public static const COMMAND_GET_FUNCTIONS:String = "GET_FUNCTIONS";
		public static const COMMAND_GET_PREVIEW:String = "GET_PREVIEW";
		public static const COMMAND_SET_PROPERTY:String = "SET_PROPERTY";
		public static const COMMAND_CALL_METHOD:String = "CALL_METHOD";
		public static const COMMAND_HIGHLIGHT:String = "HIGHLIGHT";
		public static const COMMAND_START_HIGHLIGHT:String = "START_HIGHLIGHT";
		public static const COMMAND_STOP_HIGHLIGHT:String = "STOP_HIGHLIGHT";
		public static const COMMAND_CLEAR_TRACES:String = "CLEAR_TRACES";
		public static const COMMAND_MONITOR:String = "MONITOR";
		public static const COMMAND_SNAPSHOT:String = "SNAPSHOT";
		public static const COMMAND_NOTFOUND:String = "NOTFOUND";
		
		public static const COMMAND_FIND_KV:String = "COMMAND_FIND_KV";
		public static const COMMAND_FLA_KV:String = "FLA_KV";
		public static const COMMAND_FIND_PIC:String = "FIND_PIC";
		public static const COMMAND_START_FLA_KV:String = "START_FLA_KV";
		public static const COMMAND_START_AS_KV:String = "START_AS_KV";
		public static const COMMAND_OPEN_IN_FLASH:String = "OPEN_IN_FLASH";
		public static const COMMAND_OPEN_IN_AS:String = "OPEN_IN_AS";
		public static const COMMAND_KEY_INFO:String = "KEY_INFO";
		public static const COMMAND_RECORD_AS_KV:String = "RECORD_AS_KV";
		public static const COMMAND_DEBUG_MODE:String = "DEBUG_MODE";
		public static const COMMAND_RECORD_PROTOCOL:String = "RECORD_PROTOCOL";
		public static const COMMAND_REPORT_OP_ID:String = "REPORT_OP_ID";
		public static const COMMAND_GM_CALL:String = "GM_CALL";
		public static const COMMAND_RELOAD_CALL:String = "RELOAD_CALL";
		
		// Types
		public static const TYPE_NULL:String = "null";
		public static const TYPE_VOID:String = "void";
		public static const TYPE_ARRAY:String = "Array";
		public static const TYPE_BOOLEAN:String = "Boolean";
		public static const TYPE_NUMBER:String = "Number";
		public static const TYPE_OBJECT:String = "Object";
		public static const TYPE_VECTOR:String = "Vector.";
		public static const TYPE_STRING:String = "String";
		public static const TYPE_INT:String = "int";
		public static const TYPE_UINT:String = "uint";
		public static const TYPE_XML:String = "XML";
		public static const TYPE_XMLLIST:String = "XMLList";
		public static const TYPE_XMLNODE:String = "XMLNode";
		public static const TYPE_XMLVALUE:String = "XMLValue";
		public static const TYPE_XMLATTRIBUTE:String = "XMLAttribute";
		public static const TYPE_METHOD:String = "MethodClosure";
		public static const TYPE_FUNCTION:String = "Function";
		public static const TYPE_BYTEARRAY:String = "ByteArray";
		public static const TYPE_WARNING:String = "Warning";
		public static const TYPE_NOT_FOUND:String = "Not found";
		public static const TYPE_UNREADABLE:String = "Unreadable";
		
		
		// Access types
		public static const ACCESS_VARIABLE:String = "variable";
		public static const ACCESS_CONSTANT:String = "constant";
		public static const ACCESS_ACCESSOR:String = "accessor";
		public static const ACCESS_METHOD:String = "method";
		public static const ACCESS_DISPLAY_OBJECT:String = "displayObject";
		
		
		// Permission types
		public static const PERMISSION_READWRITE:String = "readwrite";
		public static const PERMISSION_READONLY:String = "readonly";
		public static const PERMISSION_WRITEONLY:String = "writeonly";
		
		
		// Icon types
		public static const ICON_DEFAULT:String = "iconDefault";
		public static const ICON_ROOT:String = "iconRoot";
		public static const ICON_WARNING:String = "iconWarning";
		public static const ICON_VARIABLE:String = "iconVariable";
		public static const ICON_VARIABLE_READONLY:String = "iconVariableReadonly";
		public static const ICON_VARIABLE_WRITEONLY:String = "iconVariableWriteonly";
		public static const ICON_DISPLAY_OBJECT:String = "iconDisplayObject";
		public static const ICON_XMLNODE:String = "iconXMLNode";
		public static const ICON_XMLVALUE:String = "iconXMLValue";
		public static const ICON_XMLATTRIBUTE:String = "iconXMLAttribute";
		public static const ICON_FUNCTION:String = "iconFunction";


		// Path delimiter
		public static const DELIMITER:String = ".";


		public static const URL_AS3_REFERENCE:String = "http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/index.html";
		public static const URL_AS3_ERRORS:String = "http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/runtimeErrors.html";
		public static const URL_AS3_RIA:String = "http://www.adobe.com/devnet-archive/actionscript/articles/atp_ria_guide/atp_ria_guide.pdf";
		public static const URL_AS3_PLAYER:String = "http://www.adobe.com/support/flashplayer/downloads.html";

		
		public static const FVT_setting:String = "setting";
		public static const FVT_pic:String = "pic";
		public static const FVT_mc:String = "fla_mc";
		public static const FVT_plugin:String = "plugin";
		public static const FVT_key:String = "key";
		
		
		
		public static const AttisonProp:Dictionary = new Dictionary;
		public static const AttisonApp:Dictionary = new Dictionary;
		public static const DisplayObjectProp:Dictionary = new Dictionary;
		init();
		public static function init():void{
			AttisonProp["text"]=true;
			AttisonProp["htmlText"]=true;
			
			AttisonApp["parent"]=true;
			AttisonApp["text"]=true;
			AttisonProp["text"]=true;
			
			
			DisplayObjectProp["accessibilityImplementation"]=true;
			DisplayObjectProp["accessibilityProperties"]=true;
			DisplayObjectProp["blendMode"]=true;
			DisplayObjectProp["buttonMode"]=true;
			DisplayObjectProp["cacheAsBitmap"]=true;
			DisplayObjectProp["contextMenu"]=true;
			DisplayObjectProp["doubleClickEnabled"]=true;
			DisplayObjectProp["dropTarget"]=true;
			DisplayObjectProp["filters"]=true;
			DisplayObjectProp["focusRect"]=true;
			DisplayObjectProp["graphics"]=true;
			DisplayObjectProp["hitArea"]=true;
			DisplayObjectProp["loaderInfo"]=true;
			DisplayObjectProp["mask"]=true;
			DisplayObjectProp["metaData"]=true;
			DisplayObjectProp["name"]=true;
			DisplayObjectProp["visible"]=true;
//			DisplayObjectProp["parent"]=true;
			DisplayObjectProp["mouseChildren"]=true;
			DisplayObjectProp["mouseEnabled"]=true;
			DisplayObjectProp["mouseX"]=true;
			DisplayObjectProp["mouseY"]=true;
			DisplayObjectProp["needsSoftKeyboard"]=true;
			DisplayObjectProp["numChildren"]=true;
			DisplayObjectProp["opaqueBackground"]=true;
			DisplayObjectProp["root"]=true;
			DisplayObjectProp["rotation"]=true;
			DisplayObjectProp["rotationX"]=true;
			DisplayObjectProp["rotationY"]=true;
			DisplayObjectProp["rotationZ"]=true;
			DisplayObjectProp["scale9Grid"]=true;
			DisplayObjectProp["scaleX"]=true;
			DisplayObjectProp["scaleY"]=true;
			DisplayObjectProp["scaleZ"]=true;
			DisplayObjectProp["scrollRect"]=true;
			DisplayObjectProp["softKeyboardInputAreaOfInterest"]=true;
			DisplayObjectProp["soundTransform"]=true;
			DisplayObjectProp["tabChildren"]=true;
			DisplayObjectProp["tabEnabled"]=true;
			DisplayObjectProp["tabIndex"]=true;
			DisplayObjectProp["textSnapshot"]=true;
			DisplayObjectProp["transform"]=true;
			DisplayObjectProp["updateOffset"]=true;
			DisplayObjectProp["useHandCursor"]=true;
			DisplayObjectProp["align"]=true;
			DisplayObjectProp["allowsFullScreen"]=true;
			DisplayObjectProp["allowsFullScreenInteractive"]=true;
			DisplayObjectProp["alpha"]=true;
			DisplayObjectProp["color"]=true;
			DisplayObjectProp["colorCorrection"]=true;
			DisplayObjectProp["colorCorrectionSupport"]=true;
			DisplayObjectProp["constructor"]=true;
			DisplayObjectProp["contentsScaleFactor"]=true;
			DisplayObjectProp["displayContextInfo"]=true;
			DisplayObjectProp["displayState"]=true;
			DisplayObjectProp["mouseLock"]=true;
			DisplayObjectProp["quality"]=true;
			DisplayObjectProp["opaqueBackground"]=true;
			DisplayObjectProp["scale9Grid"]=true;
			DisplayObjectProp["focus"]=true;
			DisplayObjectProp["frameRate"]=true;
			DisplayObjectProp["fullScreenHeight"]=true;
			DisplayObjectProp["fullScreenWidth"]=true;
			DisplayObjectProp["fullScreenSourceRect"]=true;
			DisplayObjectProp["scaleMode"]=true;
			DisplayObjectProp["stage"]=true;
			DisplayObjectProp["stage3Ds"]=true;
			DisplayObjectProp["stageHeight"]=true;
			DisplayObjectProp["stageWidth"]=true;
			DisplayObjectProp["stageVideos"]=true;
			DisplayObjectProp["wmodeGPU"]=true;
			DisplayObjectProp["z"]=true;
			DisplayObjectProp["showDefaultContextMenu"]=true;
			DisplayObjectProp["softKeyboardRect"]=true;
			DisplayObjectProp["stageFocusRect"]=true;
			DisplayObjectProp["currentFrame"]=true;
			DisplayObjectProp["currentFrameLabel"]=true;
			DisplayObjectProp["currentLabel"]=true;
			DisplayObjectProp["currentLabels"]=true;
			DisplayObjectProp["currentScene"]=true;
			DisplayObjectProp["enabled"]=true;
			DisplayObjectProp["framesLoaded"]=true;
			DisplayObjectProp["isPlaying"]=true;
			DisplayObjectProp["scenes"]=true;
			DisplayObjectProp["totalFrames"]=true;
			DisplayObjectProp["trackAsMenu"]=true;
			
			
			DisplayObjectProp["alwaysShowSelection"]=true;
			DisplayObjectProp["antiAliasType"]=true;
			DisplayObjectProp["autoSize"]=true;
			DisplayObjectProp["background"]=true;
			DisplayObjectProp["backgroundColor"]=true;
			DisplayObjectProp["border"]=true;
			DisplayObjectProp["borderColor"]=true;
			DisplayObjectProp["bottomScrollV"]=true;
			DisplayObjectProp["caretIndex"]=true;
			DisplayObjectProp["condenseWhite"]=true;
			DisplayObjectProp["defaultTextFormat"]=true;
			DisplayObjectProp["blockIndent"]=true;
			DisplayObjectProp["bold"]=true;
			DisplayObjectProp["bullet"]=true;
			DisplayObjectProp["color"]=true;
			DisplayObjectProp["display"]=true;
			DisplayObjectProp["font"]=true;
			DisplayObjectProp["indent"]=true;
			DisplayObjectProp["italic"]=true;
			DisplayObjectProp["kerning"]=true;
			DisplayObjectProp["leading"]=true;
			DisplayObjectProp["leftMargin"]=true;
			DisplayObjectProp["letterSpacing"]=true;
			DisplayObjectProp["rightMargin"]=true;
			DisplayObjectProp["size"]=true;
			DisplayObjectProp["tabStops"]=true;
			DisplayObjectProp["target"]=true;
			DisplayObjectProp["underline"]=true;
			DisplayObjectProp["url"]=true;
			DisplayObjectProp["displayAsPassword"]=true;
			DisplayObjectProp["doubleClickEnabled"]=true;
			//DisplayObjectProp["embedFonts"]=true;
			DisplayObjectProp["filters"]=true;
			DisplayObjectProp["gridFitType"]=true;
			DisplayObjectProp["loaderInfo"]=true;
			DisplayObjectProp["actionScriptVersion"]=true;
			DisplayObjectProp["applicationDomain"]=true;
			DisplayObjectProp["bytes"]=true;
			DisplayObjectProp["bytesLoaded"]=true;
			DisplayObjectProp["bytesTotal"]=true;
			DisplayObjectProp["childAllowsParent"]=true;
			DisplayObjectProp["childAllowsParent"]=true;
			DisplayObjectProp["maxChars"]=true;
			DisplayObjectProp["mask"]=true;
			DisplayObjectProp["length"]=true;
			DisplayObjectProp["maxScrollH"]=true;
			DisplayObjectProp["maxScrollV"]=true;
			DisplayObjectProp["mouseEnabled"]=true;
			DisplayObjectProp["mouseWheelEnabled"]=true;
			DisplayObjectProp["mouseX"]=true;
			DisplayObjectProp["mouseY"]=true;
			DisplayObjectProp["multiline"]=true;
			DisplayObjectProp["numLines"]=true;
			DisplayObjectProp["opaqueBackground"]=true;
			DisplayObjectProp["restrict"]=true;
			DisplayObjectProp["rotation"]=true;
			DisplayObjectProp["rotationX"]=true;
			DisplayObjectProp["rotationY"]=true;
			DisplayObjectProp["rotationZ"]=true;
			DisplayObjectProp["scrollH"]=true;
			DisplayObjectProp["scrollV"]=true;
			DisplayObjectProp["selectable"]=true;
			DisplayObjectProp["selectedText"]=true;
			DisplayObjectProp["selectionBeginIndex"]=true;
			DisplayObjectProp["selectionEndIndex"]=true;
			DisplayObjectProp["sharpness"]=true;
			DisplayObjectProp["styleSheet"]=true;
			DisplayObjectProp["textColor"]=true;
			DisplayObjectProp["textHeight"]=true;
			DisplayObjectProp["textInteractionMode"]=true;
			DisplayObjectProp["textWidth"]=true;
			DisplayObjectProp["thickness"]=true;
			DisplayObjectProp["type"]=true;
			DisplayObjectProp["useRichTextClipboard"]=true;
			DisplayObjectProp["wordWrap"]=true;
			DisplayObjectProp["constructor"]=true;
			DisplayObjectProp["_isActivate"]=true;
			DisplayObjectProp["isActivate"]=true;
			DisplayObjectProp["111"]=true;
			DisplayObjectProp["111"]=true;
			DisplayObjectProp["111"]=true;
			DisplayObjectProp["111"]=true;
			DisplayObjectProp["111"]=true;
			DisplayObjectProp["111"]=true;
		}
	}
}
package com.naruto.debugger
{
	import flash.utils.Dictionary;


	
	/**
	 * @private
	 * The Translation Debugger constants.
	 */
	internal class DConstants
	{
		// Commands
		internal static const COMMAND_HELLO					:String = "HELLO";
		internal static const COMMAND_INFO					:String = "INFO";
		internal static const COMMAND_TRACE					:String = "TRACE";
		internal static const COMMAND_PAUSE					:String = "PAUSE";
		internal static const COMMAND_RESUME				:String = "RESUME";
		internal static const COMMAND_BASE					:String = "BASE";
		internal static const COMMAND_INSPECT				:String = "INSPECT";
		internal static const COMMAND_GET_OBJECT			:String = "GET_OBJECT";
		internal static const COMMAND_GET_PROPERTIES		:String = "GET_PROPERTIES";
		internal static const COMMAND_GET_FUNCTIONS			:String = "GET_FUNCTIONS";
		internal static const COMMAND_GET_PREVIEW			:String = "GET_PREVIEW";
		internal static const COMMAND_SET_PROPERTY			:String = "SET_PROPERTY";
		internal static const COMMAND_CALL_METHOD			:String = "CALL_METHOD";
		internal static const COMMAND_HIGHLIGHT				:String = "HIGHLIGHT";
		internal static const COMMAND_START_HIGHLIGHT		:String = "START_HIGHLIGHT";
		internal static const COMMAND_STOP_HIGHLIGHT		:String = "STOP_HIGHLIGHT";
		internal static const COMMAND_CLEAR_TRACES			:String = "CLEAR_TRACES";
		internal static const COMMAND_MONITOR				:String = "MONITOR";
		internal static const COMMAND_SAMPLES				:String = "SAMPLES";
		internal static const COMMAND_SNAPSHOT				:String = "SNAPSHOT";
		internal static const COMMAND_NOTFOUND				:String = "NOTFOUND";
		
		internal static const COMMAND_FLA_KV				:String = "FLA_KV";
		internal static const COMMAND_KEY_INFO:String = "KEY_INFO";
		internal static const COMMAND_START_FLA_KV:String = "START_FLA_KV";
		internal static const COMMAND_START_AS_KV:String = "START_AS_KV";
		internal static const COMMAND_OPEN_IN_FLASH:String = "OPEN_IN_FLASH";
		internal static const COMMAND_OPEN_IN_AS:String = "OPEN_IN_AS";
		internal static const COMMAND_FIND_PIC:String = "FIND_PIC";
		internal static const COMMAND_RECORD_PROTOCOL:String = "RECORD_PROTOCOL";
		internal static const COMMAND_RECORD_AS_KV:String = "RECORD_AS_KV";
		internal static const COMMAND_DEBUG_MODE:String = "DEBUG_MODE";
		
		internal static const COMMAND_REPORT_OP_ID:String = "REPORT_OP_ID";
		internal static const COMMAND_BREAK_TIPS:String = "BREAK_TIPS";
		internal static const COMMAND_GM_CALL:String = "GM_CALL";
		internal static const COMMAND_RELOAD_CALL:String = "RELOAD_CALL";
		
		// Types
		internal static const TYPE_VOID					:String = "void";
		internal static const TYPE_NULL					:String = "null";
		internal static const TYPE_ARRAY				:String = "Array";
		internal static const TYPE_BOOLEAN				:String = "Boolean";
		internal static const TYPE_NUMBER				:String = "Number";
		internal static const TYPE_OBJECT				:String = "Object";
		internal static const TYPE_VECTOR				:String = "Vector.";
		internal static const TYPE_STRING				:String = "String";
		internal static const TYPE_INT					:String = "int";
		internal static const TYPE_UINT					:String = "uint";
		internal static const TYPE_XML					:String = "XML";
		internal static const TYPE_XMLLIST				:String = "XMLList";
		internal static const TYPE_XMLNODE				:String = "XMLNode";
		internal static const TYPE_XMLVALUE				:String = "XMLValue";
		internal static const TYPE_XMLATTRIBUTE			:String = "XMLAttribute";
		internal static const TYPE_METHOD				:String = "MethodClosure";
		internal static const TYPE_FUNCTION				:String = "Function";
		internal static const TYPE_BYTEARRAY			:String = "ByteArray";	
		internal static const TYPE_WARNING				:String = "Warning";
		internal static const TYPE_NOT_FOUND			:String = "Not found";
		internal static const TYPE_UNREADABLE			:String = "Unreadable";
		
		
		// Access types
		internal static const ACCESS_VARIABLE			:String = "variable";
		internal static const ACCESS_CONSTANT			:String = "constant";
		internal static const ACCESS_ACCESSOR			:String = "accessor";
		internal static const ACCESS_METHOD				:String = "method";
		internal static const ACCESS_DISPLAY_OBJECT		:String = "displayObject";
		
		
		// Permission types
		internal static const PERMISSION_READWRITE		:String = "readwrite";
		internal static const PERMISSION_READONLY		:String = "readonly";
		internal static const PERMISSION_WRITEONLY		:String = "writeonly";
		
		
		// Icon types
		internal static const ICON_DEFAULT				:String = "iconDefault";
		internal static const ICON_ROOT					:String = "iconRoot";
		internal static const ICON_WARNING				:String = "iconWarning";
		internal static const ICON_VARIABLE				:String = "iconVariable";
		internal static const ICON_DISPLAY_OBJECT		:String = "iconDisplayObject";
		internal static const ICON_VARIABLE_READONLY	:String = "iconVariableReadonly";
		internal static const ICON_VARIABLE_WRITEONLY	:String = "iconVariableWriteonly";
		internal static const ICON_XMLNODE				:String = "iconXMLNode";
		internal static const ICON_XMLVALUE				:String = "iconXMLValue";
		internal static const ICON_XMLATTRIBUTE 		:String = "iconXMLAttribute";
		internal static const ICON_FUNCTION				:String = "iconFunction";
		
		
		// Path delimiter
		internal static const DELIMITER					:String = ".";
		
		
		public static const AttisonProp:Dictionary = new Dictionary;
		init();
		public static function init():void{
			//AttisonProp["x"]=true;
			//AttisonProp["y"]=true;
			AttisonProp["parent"]=true;
			//AttisonProp["visible"]=true;
			AttisonProp["text"]=true;
			AttisonProp["htmlText"]=true;
		}
	}
	
}
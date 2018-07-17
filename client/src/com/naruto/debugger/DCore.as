package com.naruto.debugger
{
	import com.naruto.debugger.Hy;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import flash.text.StaticText;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.utils.getDefinitionByName;

	
	/**
	 * @private
	 * The Translation Debugger core functions
	 */
	internal class DCore
	{
		
		// Monitor and highlight interval timer
		private static const MONITOR_UPDATE:int = 1000;
		private static const HIGHLITE_COLOR:uint = 0x3399FF;
		
		
		// Monitor timer
		private static var _monitorTimer:Timer;
		private static var _monitorSprite:Sprite;
		private static var _monitorTime:Number;
		private static var _monitorStart:Number;
		private static var _monitorFrames:int;
		

		// The root of the application
		private static var _base:Object = null;
		
		
		// The stage needed for highlight
		internal static var _stage:Stage = null;
		
		
		// Highlight sprite
		private static var _highlight:Sprite;
		private static var _highlightInfo:TextField;
		private static var _highlightTarget:DisplayObject;
		private static var _highlightMouse:Boolean;
		private static var _highlightUpdate:Boolean;
		static public var previewObj:DisplayObject;


		// The core id
		internal static const ID:String = "com.dezhaoli.debugger.core";
		
		
		/**
		 * Start the class.
		 */
		internal static function initialize():void
		{	
			// Reset the monitor values
			_monitorTime = new Date().time;
			_monitorStart = new Date().time;
			_monitorFrames = 0;
			
			// Create the monitor timer
			_monitorTimer = new Timer(MONITOR_UPDATE);
			_monitorTimer.addEventListener(TimerEvent.TIMER, monitorTimerCallback, false, 0, true);
			_monitorTimer.start();
			
			// Regular check for stage
			if (_base.hasOwnProperty("stage") && _base["stage"] != null && _base["stage"] is Stage) {
				_stage = _base["stage"] as Stage;
			}
			
			// Create the monitor sprite
			// This is needed for the enterframe ticks
			_monitorSprite = new Sprite();
			_monitorSprite.addEventListener(Event.ENTER_FRAME, frameHandler, false, 0, true);
			
			var format:TextFormat = new TextFormat();
			format.font = "Arial";
			format.color = 0xFFFFFF;
			format.size = 11;
			format.leftMargin = 5;
			format.rightMargin = 5;
			
			// Create the textfield for the highlight and inspect
			_highlightInfo = new TextField();
			_highlightInfo.embedFonts = false;
			_highlightInfo.autoSize = TextFieldAutoSize.LEFT;
			_highlightInfo.mouseWheelEnabled = false;
			_highlightInfo.mouseEnabled = false;
			_highlightInfo.condenseWhite = false;
			_highlightInfo.embedFonts = false;
			_highlightInfo.multiline = true;
			_highlightInfo.selectable = false;
			_highlightInfo.wordWrap = false;
			_highlightInfo.defaultTextFormat = format;
			_highlightInfo.text = "";
			
			// Create the highlight
			_highlight = new Sprite();
			_highlightMouse = false;
			_highlightTarget = null;
			_highlightUpdate = false;
		}

		
		/**
		 * Getter and setter for base.
		 */
		internal static function get base():* {
			return _base;
		}
		internal static function set base(value:*):void {
			_base = value;
		}
		
		
		/**
		 * @private
		 * See TranslationDebugger class
		 */
		internal static function trace(caller:*, object:*, person:String = "", label:String = "", color:uint = 0x000000, depth:int = 5):void
		{
			if (TranslationDebugger.enabled) {
				
				// Get the object information
				var xml:XML = XML(DUtils.parse(object, "", 1, depth, false));

				// Create the data
				var data:Object = {
					command:	DConstants.COMMAND_TRACE,
					memory:		DUtils.getMemory(),
					date:		new Date(),
					target:		String(caller),
					reference:	DUtils.getReferenceID(caller),
					xml:		xml,
					person:		person,
					label:		label,
					color:		color
				};
		
				// Send the data
				send(data);
			}
		}
		
		
		/**
		 * @private
		 * See TranslationDebugger class
		 */
		internal static function snapshot(caller:*, object:DisplayObject, person:String = "", label:String = ""):void
		{
			if (TranslationDebugger.enabled) {
				
				// Create the bitmapdata
				var bitmapData:BitmapData = DUtils.snapshot(object);
				if (bitmapData != null)
				{					
					// Write the bitmap in the bytearray
					var bytes:ByteArray = bitmapData.getPixels(new Rectangle(0, 0, bitmapData.width, bitmapData.height));
	
					// Create the data
					var data:Object = {
						command:	DConstants.COMMAND_SNAPSHOT, 
						memory:		DUtils.getMemory(),
						date:		new Date(), 
						target:		String(caller), 
						reference:	DUtils.getReferenceID(caller),
						bytes:		bytes, 
						width:		bitmapData.width, 
						height:		bitmapData.height,
						person:		person,
						label:		label
					};
					
					// Send the data
					send(data);
				}
			}
		}
		
		
		/**
		 * @private
		 * See TranslationDebugger class
		 */
		internal static function breakpoint(caller:*, id:String = "breakpoint"):void
		{
			// Only break when enabled and connected
			if (TranslationDebugger.enabled && DConnection.connected) {
				
				// Get the stacktrace
				var stack:XML = DUtils.stackTrace();

				// Create the data
				var data:Object = {
					command:	DConstants.COMMAND_PAUSE, 
					memory:		DUtils.getMemory(),
					date:		new Date(), 
					target:		String(caller),
					reference:	DUtils.getReferenceID(caller),
					stack:		stack, 
					id:			id
				};
				
				// Send the data
				send(data);
				
				// Try to pause the system
				DUtils.pause();
			}
		}
		
		
		/**
		 * @private
		 * See TranslationDebugger class
		 */
		internal static function inspect(object:*):void
		{
			if (TranslationDebugger.enabled) {
				
				// Set the new root
				_base = object;
				
				// Get the new target
				var obj:* = DUtils.getObject(_base, "", 0);
				if (obj != null)
				{
					// Parse the new target
					var xml:XML = XML(DUtils.parse(obj, "", 1, 2, true));
					send({command:DConstants.COMMAND_BASE, xml:xml});			
				}
			}
		}
		
		internal static function findaskv():void {
			
			var info:String = TranslateUtil.getTName(previewObj);
			
			
			if ((previewObj is TextField || previewObj is StaticText) && previewObj.parent && previewObj.parent.parent == null) {
				var p:Point = new Point(1, 1);
				p = previewObj.localToGlobal(p);
				var objects:Array = _stage.getObjectsUnderPoint(p);
				objects.reverse();
				var pp:DisplayObjectContainer = objects[2].parent;
				for (var i:int = 0; i < pp.numChildren; i++) 
				{
					if (pp.getChildAt(i) is SimpleButton) {
						var b:SimpleButton = pp.getChildAt(i) as SimpleButton;
						if (b.upState == previewObj.parent) {
							info = TranslateUtil.getTName(b);
							info = info + "|" + TranslateUtil.getCName(previewObj);
							break;
						}
					}
				}
			}
			if (asCache.length > 0) {
				send( { command:DConstants.COMMAND_RECORD_AS_KV, asCache:asCache, type:3 } );		
				asCache = [];
			}
			
			if (previewObj is TextField || previewObj is StaticText) {
				var text:String = Object(previewObj).text;
				send( { command:DConstants.COMMAND_FLA_KV,previewObjName:previewObj.name, info:info ,text:text, AS:"true"} );	
			}else {
				send( { command:DConstants.COMMAND_FLA_KV,previewObjName:previewObj.name, info:info } );	
				
			}
		}
		internal static function findpic():void {
			
			var info:String = TranslateUtil.getTName(previewObj);
			var xml:XML = XML(DUtils.parse(previewObj , "", 1, 2, false));
			
			var url:String = ("url" in previewObj)? Object(previewObj).url : "";
			send( { command:DConstants.COMMAND_FIND_PIC,previewObjName:previewObj.name, info:info,xml:xml ,url:url} );	
		}
		internal static function openflamc(data:Object=null):void {
			var info:String = TranslateUtil.getTName(previewObj);
			var stageURL:String = _stage.loaderInfo.url;
			if (data && data.isFind == true) {
				data.stageURL = stageURL;
				send(data);
			}else{
				send( { command:DConstants.COMMAND_OPEN_IN_FLASH, info:info, stageURL:stageURL } );	
			}
		}
		internal static function openAsFile(data:Object):void {
			var info:String = TranslateUtil.getTName(previewObj);
			var stageURL:String = _stage.loaderInfo.url;
			send({command:DConstants.COMMAND_OPEN_IN_AS, info:info,stageURL:stageURL,extra:data.extra});	
		}
		internal static function exCoreSend(data:Object):void {
			send(data);	
		}
		/**
		 * @private
		 * See TranslationDebugger class
		 */
		internal static function clear():void
		{
			if (TranslationDebugger.enabled) {
				send({command:DConstants.COMMAND_CLEAR_TRACES});
			}
		}
		
		
		/**
		 * Send the capabilities and information.
		 * This is send after the HELLO command.
		 */
		internal static function sendInformation():void
		{
			// Get basic data
			var playerType:String = Capabilities.playerType;
			var playerVersion:String = Capabilities.version;
			var isDebugger:Boolean = Capabilities.isDebugger;
			var isFlex:Boolean = false;	
			var fileTitle:String = "";
			var fileLocation:String = "";
			
			// Check for Flex framework
			try{
				var UIComponentClass:* = getDefinitionByName("mx.core::UIComponent");
				if (UIComponentClass != null) isFlex = true;
			} catch (e1:Error) {}
			
			// Get the location
			if (_base is DisplayObject && _base.hasOwnProperty("loaderInfo")) {
				if (DisplayObject(_base).loaderInfo != null) {
					fileLocation = unescape(DisplayObject(_base).loaderInfo.url);
				}
			}
			if (_base.hasOwnProperty("stage")) {
				if (_base["stage"] != null && _base["stage"] is Stage) {
					fileLocation = unescape(Stage(_base["stage"]).loaderInfo.url);
				}
			}
			
			// Check for browser
			if (playerType == "ActiveX" || playerType == "PlugIn") {
				if (ExternalInterface.available) {
					try {
						var tmpLocation:String = ExternalInterface.call("window.location.href.toString");
						var tmpTitle:String = ExternalInterface.call("window.document.title.toString");
						if (tmpLocation != null) fileLocation = tmpLocation;
						if (tmpTitle != null) fileTitle = tmpTitle;
					} catch (e2:Error) {
						// External interface FAIL
					}
				}
			}
			
			// Check for Adobe AIR
			if (playerType == "Desktop") {
				try{
					var NativeApplicationClass:* = getDefinitionByName("flash.desktop::NativeApplication");
					if (NativeApplicationClass != null) {
						var descriptor:XML = NativeApplicationClass["nativeApplication"]["applicationDescriptor"];
						var ns:Namespace = descriptor.namespace();
						var filename:String = descriptor.ns::filename;
						var FileClass:* = getDefinitionByName("flash.filesystem::File");
						if (Capabilities.os.toLowerCase().indexOf("windows") != -1) {
							filename += ".exe";
							fileLocation = FileClass["applicationDirectory"]["resolvePath"](filename)["nativePath"];
						} else if (Capabilities.os.toLowerCase().indexOf("mac") != -1) {
							filename += ".app";
							fileLocation = FileClass["applicationDirectory"]["resolvePath"](filename)["nativePath"];
						}
					}
				} catch (e3:Error) {}
			}
			
			if (fileTitle == "" && fileLocation != "") {
				var slash:int = Math.max(fileLocation.lastIndexOf("\\"), fileLocation.lastIndexOf("/"));
				if (slash != -1) {
					fileTitle = fileLocation.substring(slash + 1, fileLocation.lastIndexOf("."));
				} else {
					fileTitle = fileLocation;
				}
			}
			
			// Default
			if (fileTitle == "") {
				fileTitle = "Application";
			}
			
			fileTitle = Hy.getHyTitle(fileTitle);
			
			
			//kv_debug_files
			var kvs:Array = Hy.getHyDebugCFG();
			
			
			// Create the data
			var data:Object = {
				command:			DConstants.COMMAND_INFO,
				debuggerVersion:	TranslationDebugger.VERSION,
				playerType:			playerType,
				playerVersion:		playerVersion,
				isDebugger:			isDebugger,
				isFlex:				isFlex,
				fileLocation:		fileLocation,
				fileTitle:			fileTitle,
				kvs:				kvs
			};
			
			// Send the data direct
			send(data, true);
			
			// Start the queue after that
			DConnection.processQueue();
		}
		

		/**
		 * Handle incoming data from the connection.
		 * @param item: Data from the desktop application
		 */
		internal static function handle(item:DData):void
		{
			if (TranslationDebugger.enabled) {
				
				// If the id is empty just return
				if (item.id == null || item.id == "") {
					return;
				}
				
				// Check if we should handle the call internaly
				if (item.id == DCore.ID) {
					handleInternal(item);
				}
			}
		}
		
		private static var infoData:Object
		/**
		 * Handle internal commands from the connection.
		 * @param item: Data from the desktop application
		 */
		private static function handleInternal(item:DData):void
		{
			// Vars for loop
			var obj:*;
			var xml:XML;
			var method:Function;
			
			// Do the actions
			switch(item.data["command"])
			{
				// Get the application info and start processing queue
				case DConstants.COMMAND_HELLO:
					sendInformation();
				break;
				
				case DConstants.COMMAND_KEY_INFO:
					infoData = item.data;
					highlightDraw(_highlightMouse);
				break;
				case DConstants.COMMAND_OPEN_IN_FLASH:
					openflamc(item.data);
				break;
				case DConstants.COMMAND_OPEN_IN_AS:
					openAsFile(item.data);
				break;
				case DConstants.COMMAND_START_AS_KV:
					findaskv();
				break;
				case DConstants.COMMAND_FIND_PIC:
					findpic();
				break;
				case DConstants.COMMAND_DEBUG_MODE:
					setDebugMode(item.data["val"] == "true");
				break;

				// Get the root xml structure (object)
				case DConstants.COMMAND_BASE:
					obj = DUtils.getObject(_base, "", 0);
					if (obj != null) {
						xml = XML(DUtils.parse(obj, "", 1, 2, true));
						send({command:DConstants.COMMAND_BASE, xml:xml});
					}
				break;
				
				// Inspect
				case DConstants.COMMAND_INSPECT:
					obj = DUtils.getObject(_base, item.data["target"], 0);
					if (obj != null) {
						_base = obj;
						xml = XML(DUtils.parse(obj, "", 1, 2, true));
						send({command:DConstants.COMMAND_BASE, xml:xml});
					}
				break;
				
				// Return the parsed object
				case DConstants.COMMAND_GET_OBJECT:
					obj = DUtils.getObject(_base, item.data["target"], 0);
					if (obj != null) {
						xml = XML(DUtils.parse(obj, item.data["target"], 1, 2, true));
						send({command:DConstants.COMMAND_GET_OBJECT, xml:xml});
					}
				break;
				
				// Return a list of properties
				case DConstants.COMMAND_GET_PROPERTIES:
					obj = DUtils.getObject(_base, item.data["target"], 0);
					if (obj != null) {
						xml = XML(DUtils.parse(obj, item.data["target"], 1, 1, false));
						send({command:DConstants.COMMAND_GET_PROPERTIES, xml:xml});
					}
				break;
				
				// Return a list of functions
				case DConstants.COMMAND_GET_FUNCTIONS:
					obj = DUtils.getObject(_base, item.data["target"], 0);
					if (obj != null) {
						xml = XML(DUtils.parseFunctions(obj, item.data["target"]));
						send({command:DConstants.COMMAND_GET_FUNCTIONS, xml:xml});
					}
				break;
				
				// Adjust a property and return the value
				case DConstants.COMMAND_SET_PROPERTY:
					obj = DUtils.getObject(_base, item.data["target"], 1);
					if (obj != null) {
						try {
							obj[item.data["name"]] = item.data["value"];
							send({command:DConstants.COMMAND_SET_PROPERTY, target:item.data["target"], value:obj[item.data["name"]]});
						} catch (e1:Error) {
							//
						}
					}
				break;
				
				// Return a preview
				case DConstants.COMMAND_GET_PREVIEW:
					obj = DUtils.getObject(_base, item.data["target"], 0);
					if (obj != null && DUtils.isDisplayObject(obj)) {
						var displayObject:DisplayObject = obj as DisplayObject;
						previewObj = displayObject;
						var bitmapData:BitmapData = DUtils.snapshot(displayObject, new Rectangle(0, 0, 300, 300));
						if (bitmapData != null) {	
							var bytes:ByteArray = bitmapData.getPixels(new Rectangle(0, 0, bitmapData.width, bitmapData.height));
							send({command:DConstants.COMMAND_GET_PREVIEW, bytes:bytes, width:bitmapData.width, height:bitmapData.height});
						}
					}
				break;
				
				// Call a method and return the answer
				case DConstants.COMMAND_CALL_METHOD:
					method = DUtils.getObject(_base, item.data["target"], 0);
					if (method != null && method is Function) {
						if (item.data["returnType"] == DConstants.TYPE_VOID) {
							method.apply(null, item.data["arguments"]);
						} else {
							try {
								obj = method.apply(null, item.data["arguments"]);
								xml = XML(DUtils.parse(obj, "", 1, 5, false));
								send({command:DConstants.COMMAND_CALL_METHOD, id:item.data["id"], xml:xml});
							} catch (e2:Error) {
								//
							}							
						}
					}
				break;
				
				// Pause the application
				case DConstants.COMMAND_PAUSE:
					pause();
				break;
				
				// Resume the application
				case DConstants.COMMAND_RESUME:
					resume();
				break;
				
				// Set the highlite on an object
				case DConstants.COMMAND_HIGHLIGHT:
					obj = DUtils.getObject(_base, item.data["target"], 0);
					if (obj != null && DUtils.isDisplayObject(obj)) {
						if (DisplayObject(obj).stage != null && DisplayObject(obj).stage is Stage) {
							_stage = obj["stage"];
						}
						if (_stage != null) {
							highlightClear();
							send({command:DConstants.COMMAND_STOP_HIGHLIGHT});
							_highlight.removeEventListener(MouseEvent.CLICK, highlightClicked);
							_highlight.mouseEnabled = false;
							_highlightTarget = DisplayObject(obj);
							_highlightMouse = false;
							_highlightUpdate = true;
						}
					}
				break;
				
				// Show the highlight
				case DConstants.COMMAND_START_HIGHLIGHT:
					startHighlight();
				break;
				
				// Remove the highlight
				case DConstants.COMMAND_STOP_HIGHLIGHT:
					stopHighlight();
				break;
			}
			ExCore.handleInternal(item);
		}
		
		static public function startHighlight(deepMode:Boolean=false):void 
		{
			_deepMode = deepMode;
			highlightClear();
			_highlight.addEventListener(MouseEvent.CLICK, highlightClicked, false, 0, true);
			_highlight.mouseEnabled = true;
			_highlightTarget = null;
			_highlightMouse = true;
			_highlightUpdate = true;
			send({command:DConstants.COMMAND_START_HIGHLIGHT});
		}
		static public function tapHighlight(m:Boolean=false):void {
			if (_highlightMouse) {
				stopHighlight();
			}else {
				startHighlight(m);
			}
		}
		static public function stopHighlight():void 
		{
			highlightClear();
			_highlight.removeEventListener(MouseEvent.CLICK, highlightClicked);
			_highlight.mouseEnabled = false;
			_highlightTarget = null;
			_highlightMouse = false;
			_highlightUpdate = false;
			send({command:DConstants.COMMAND_STOP_HIGHLIGHT});
		}
		
		
		/**
		 * Monitor timer callback.
		 */
		private static function monitorTimerCallback(event:TimerEvent):void
		{
			if (TranslationDebugger.enabled) {
				
				// Calculate the frames per second
				var now:Number = new Date().time;
				var delta:Number = now - _monitorTime;
				var fps:uint = _monitorFrames / delta * 1000; // Miliseconds to seconds
				var fpsMovie:uint = 0;
				if (_stage == null) {
					if (_base.hasOwnProperty("stage") && _base["stage"] != null && _base["stage"] is Stage){
						_stage = Stage(_base["stage"]);
					}
				}
				if (_stage != null) {
					fpsMovie = _stage.frameRate;
				}
				
				// Reset
				_monitorFrames = 0;
				_monitorTime = now;
				
				// Check if we can send the data
				if (DConnection.connected)
				{
					// Create the data
					var data:Object = {
						command:		DConstants.COMMAND_MONITOR,
						memory:			DUtils.getMemory(), 
						fps:			fps, 
						fpsMovie:		fpsMovie, 
						time:			now
					};
					
					// Send the data
					send(data);
				}
			}
		}
		

		/**
		 * Enterframe ticker callback.
		 */
		private static function frameHandler(event:Event):void {
			if (TranslationDebugger.enabled) {
				_monitorFrames++;
				if (_highlightUpdate) {
					highlightUpdate();
				}
			}
		}
		
		
		/**
		 * Highlight clicked.
		 */
		private static function highlightClicked(event:MouseEvent):void
		{
			// Stop
			event.preventDefault();
			event.stopImmediatePropagation();
			
			// Clear the highlight
			highlightClear();
			
			// Get objects under point
			_highlightTarget = DUtils.getObjectUnderPoint(_stage, new Point(_stage.mouseX, _stage.mouseY) , _deepMode);
			
			// Stop mouse interactions
			_highlightMouse = false;
			_highlight.removeEventListener(MouseEvent.CLICK, highlightClicked);
			_highlight.mouseEnabled = false;
			
			// Inspect
			if (_highlightTarget != null) {
				inspect(_highlightTarget);
				highlightDraw(false);
			}
			
			// Send stop
			send( { command:DConstants.COMMAND_STOP_HIGHLIGHT } );
			
		}
		
		/**
		 * Highlight timer callback.
		 */
		private static function highlightUpdate():void
		{
			// Clear the highlight
			highlightClear();
			
			// Mouse interactions
			if (_highlightMouse) {
				
				// Regular check for stage
				if (_base.hasOwnProperty("stage") && _base["stage"] != null && _base["stage"] is Stage) {
					_stage = _base["stage"] as Stage;
				}
				
				// Desktop check
				if (Capabilities.playerType == "Desktop") {
					var NativeApplicationClass:* = getDefinitionByName("flash.desktop::NativeApplication");
					if (NativeApplicationClass != null && NativeApplicationClass["nativeApplication"]["activeWindow"] != null) {
						_stage = NativeApplicationClass["nativeApplication"]["activeWindow"]["stage"];
					}
				}
	
				// Return if no stage is found
				if (_stage == null) {
					_highlight.removeEventListener(MouseEvent.CLICK, highlightClicked);
					_highlight.mouseEnabled = false;
					_highlightTarget = null;
					_highlightMouse = false;
					_highlightUpdate = false;
					return;
				}
				
				// Get objects under point
				_highlightTarget = DUtils.getObjectUnderPoint(_stage, new Point(_stage.mouseX, _stage.mouseY), _deepMode);
				if (_highlightTarget != null) {
					highlightDraw(true);
				}
				checkIsNeedFind();
				return;
			}
			
			// Only update the target
			if (_highlightTarget != null) {
				checkIsNeedFind();
				if (_highlightTarget.stage == null || _highlightTarget.parent == null) {
					_highlight.removeEventListener(MouseEvent.CLICK, highlightClicked);
					_highlight.mouseEnabled = false;
					_highlightTarget = null;
					_highlightMouse = false;
					_highlightUpdate = false;
					return;
				}
				highlightDraw(false);
			}
		}
		
		private static var _lastHighlightTarget:DisplayObject;
		static private function checkIsNeedFind():void 
		{
			if (_highlightTarget && _lastHighlightTarget != _highlightTarget) {
				_lastHighlightTarget = _highlightTarget;
				var C:String = TranslateUtil.getClass(_highlightTarget);
				if (_highlightTarget is TextField || _highlightTarget is StaticText || _highlightTarget is Hy.MovieClipButton) {
					previewObj = _highlightTarget;
					findaskv();
				}else if (_highlightTarget is Shape || _highlightTarget is Hy.Image) {
					previewObj = _highlightTarget;
					findpic();
				}
			}
		}
		
		/**
		 * Highlight an object.
		 */
		private static function highlightDraw(fill:Boolean):void
		{
			// Return if needed
			if (_highlightTarget == null) {
				return;
			}
			// Get the outer bounds
			var boundsOuter:Rectangle = _highlightTarget.getBounds(_stage);
			if (_highlightTarget is Stage) {
				boundsOuter.x = 0;
				boundsOuter.y = 0;
				boundsOuter.width = _highlightTarget["stageWidth"];
				boundsOuter.height = _highlightTarget["stageHeight"];
			} else {
				boundsOuter.x = int(boundsOuter.x + 0.5);
				boundsOuter.y = int(boundsOuter.y + 0.5);
				boundsOuter.width = int(boundsOuter.width + 0.5);
				boundsOuter.height = int(boundsOuter.height + 0.5);
			}

			// Get the inner bounds for border
			var boundsInner:Rectangle = boundsOuter.clone();
			boundsInner.x += 2;
			boundsInner.y += 2;
			boundsInner.width -= 4;
			boundsInner.height -= 4;
			if (boundsInner.width < 0) boundsInner.width = 0;
			if (boundsInner.height < 0) boundsInner.height = 0;
			
			// Draw the first border
			_highlight.graphics.clear();
			_highlight.graphics.beginFill(HIGHLITE_COLOR, 1);
			_highlight.graphics.drawRect(boundsOuter.x, boundsOuter.y, boundsOuter.width, boundsOuter.height);
			_highlight.graphics.drawRect(boundsInner.x, boundsInner.y, boundsInner.width, boundsInner.height);
			if (fill) {
				_highlight.graphics.beginFill(HIGHLITE_COLOR, 0.25);
				_highlight.graphics.drawRect(boundsInner.x, boundsInner.y , boundsInner.width, boundsInner.height);
			}
			
			var coor:Point = new Point;
			coor = _highlightTarget.localToGlobal(coor);
			coor = _stage.globalToLocal(coor);
			_highlight.graphics.beginFill(0xff0000, 1);
			_highlight.graphics.drawCircle(coor.x, coor.y,8);
			_highlight.graphics.drawCircle(coor.x, coor.y,6);
			// Set the text
			if (_highlightTarget.name != null) {
				_highlightInfo.text = String(_highlightTarget.name) + " - " + String(DDescribeType.get(_highlightTarget).@name);
			} else {
				_highlightInfo.text = String(DDescribeType.get(_highlightTarget).@name);
			}
			
			if (infoData && infoData["previewObjName"] == _highlightTarget.name) {
				var info:String = infoData.info;
				var lines:Array = info.split("\n");
				if (lines.length > 4) {
					info = lines.slice(0, 4).join("\n") + "\n......";
				}
				_highlightInfo.appendText("\n" + info);
			}
			
			// Calculate the text size			
			var boundsText:Rectangle = new Rectangle(
				boundsOuter.x, 
				boundsOuter.y - (_highlightInfo.textHeight + 3), 
				_highlightInfo.textWidth + 15, 
				_highlightInfo.textHeight + 5
			);
			
			// Check for offset values
			if (boundsText.y < 0) boundsText.y = boundsOuter.y + boundsOuter.height;
			if (boundsText.y + boundsText.height > _stage.stageHeight) boundsText.y = _stage.stageHeight - boundsText.height;
			if (boundsText.x < 0) boundsText.x = 0;
			if (boundsText.x + boundsText.width > _stage.stageWidth) boundsText.x = _stage.stageWidth - boundsText.width;
			
			// Draw text container
			_highlight.graphics.beginFill(HIGHLITE_COLOR, 1);
			_highlight.graphics.drawRect(boundsText.x, boundsText.y, boundsText.width, boundsText.height);
			_highlight.graphics.endFill();
			
			// Set position
			_highlightInfo.x = boundsText.x;
			_highlightInfo.y = boundsText.y;
			
			// Add the highlight to the objects parent
			try {
				_stage.addChild(_highlight);
				_stage.addChild(_highlightInfo);
			} catch(e:Error) {
				// clearHighlight();
			}
		}
		
		
		/**
		 * Clear the highlight on a object
		 */
		private static function highlightClear():void
		{
			if (_highlight != null && _highlight.parent != null) {
				_highlight.parent.removeChild(_highlight);
				_highlight.graphics.clear();
				_highlight.x = 0;
				_highlight.y = 0;
			}
			if (_highlightInfo != null && _highlightInfo.parent != null) {
				_highlightInfo.parent.removeChild(_highlightInfo);
				_highlightInfo.x = 0;
				_highlightInfo.y = 0;
			}
		}
		
		
		/**
		 * Send data to the desktop application.
		 * @param data: The data to send
		 * @param direct: Use the queue or send direct (handshake)
		 */
		private static function send(data:Object, direct:Boolean = false):void
		{
			if (TranslationDebugger.enabled) {
				DConnection.send(DCore.ID, data, direct);
			}
		}
		
		
		static public function tapPause():void {
			if (_pausing) {
				resume();
			}else {
				pause();
			}
		}
		static private function pause():void 
		{
			_pausing = true;
			DUtils.pause();
			send({command:DConstants.COMMAND_PAUSE});
		}
		
		static private function resume():void 
		{
			_pausing = false;
			DUtils.resume();
			send({command:DConstants.COMMAND_RESUME});
		}
		
		static public function recordSocketStr(protocol:Object):void 
		{
			if (TranslationDebugger.enabled) {
				if(protocol.error != 0 && protocol.errorStr)
				send({command:DConstants.COMMAND_RECORD_PROTOCOL, str:protocol.errorStr});	
			}
		}
		static private var asCache:Array = [];
		static public function recordAS(key:String, value:String, type:int):void 
		{
			if (TranslationDebugger.enabled) {
				asCache.push( { val1:key, val2:value, type:type } );
			}
		}
		
		static private var _debugMode:Boolean;
		static private var _deepMode:Boolean;
		static private var _pausing:Boolean;
		static public function debugMode():Boolean 
		{
			return _debugMode;
		}
		
		static public function setDebugMode(val:Boolean):void
		{
			_debugMode = val;
		}
	}
	
}
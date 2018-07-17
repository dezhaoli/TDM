package com.naruto.debugger
{
	import flash.desktop.NativeApplication;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.display.NativeWindow;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.system.Capabilities;
	
	import events.TraceEvent;


	/**
	 * Static class that handles the native menu content and the global key handling
	 */
	public class DMenu extends EventDispatcher
	{

		public static const SAVE:String = "save";
		public static const SAVE_AS:String = "saveAs";
		
		public static const NEXT_TAB:String = "nextTab";
		public static const PREVIOUS_TAB:String = "previousTab";
		
		public static const CLOSE_TAB:String = "closeTab";
		public static const OPEN_DEBUG_FILES:String = "openDebugFiles";

		public static const EXPORT_CLIENT_SWC:String = "exportclientclasses";
		public static const EXPORT_CLIENT_MOBILE_SWC:String = "exportclientswc";
	
		public static const TOGGLE_VIEW:String = "toggleview";

		public static const CLEAR_TRACES:String = "cleartraces";
		public static const CLOSE_DISCONNECTED:String = "closedisconnected";
		public static const ALWAYS_ON_TOP:String = "alwaysontop";
		public static const HIGHLIGHT_INSPECT:String = "highlightinspect";
		
		public static const HELP_WINDOW:String = "helpwindow";
		public static const DEBUGGER_GAME:String = "debuggerGame";
		public static const ABOUT_TRANSLATION:String = "aboutTranslation";
		public static const PRODUCT_WEBSITE:String = "productwebsite";
		public static const FEEDBACK:String = "feedback";
		public static const AS3_REFERENCE:String = "as3reference";
		public static const AS3_RUNTIME_ERRORS:String = "as3runtimeerrors";
		public static const RIA_GUIDE:String = "riaguide";
		public static const FLASH_PLAYERS:String = "flashplayers";

		
		
		// The main menu item

		
		public static var v_traces:Boolean = false;
		public static var v_gm:Boolean = true;
		public static var v_find:Boolean = true;
		
		public static var v_breakpoint:Boolean = false;
		public static var v_tools:Boolean = true;
		public static var v_monitor:Boolean = false;
		
		public static var v_properties:Boolean = true;
		public static var v_methods:Boolean = false;
		
		public static var v_application:Boolean = true;
		

		// Menu


		private static var _exportClientSWC:NativeMenuItem;
		private static var _exportClientMobileSWC:NativeMenuItem;
		private static var _closeTabItem:NativeMenuItem;
		private static var _closeWindowItem:NativeMenuItem;

		private static var _findFlaKv:NativeMenuItem;

		private static var _helpSubMenuItem:NativeMenuItem;
		private static var _aboutMenuItem:NativeMenuItem;
		private static var _websiteMenuItem:NativeMenuItem;
		private static var _feedbackMenuItem:NativeMenuItem;
		private static var _documentationSubMenuItem:NativeMenuItem;

		private static var _as3RefMenuItem:NativeMenuItem;
		private static var _as3RunMenuItem:NativeMenuItem;
		private static var _riaGuideMenuItem:NativeMenuItem;
		private static var _playersMenuItem:NativeMenuItem;

		private static var _onTopMenuItem:NativeMenuItem;
		private static var _devMenuItem:NativeMenuItem;
		private static var _hideporpMenuItem:NativeMenuItem;
		private static var _saveMenuItem:NativeMenuItem;
		private static var _saveAsMenuItem:NativeMenuItem;
		private static var _gameMenuItem:NativeMenuItem;


		// Dispatcher
		private static var _dispatcher:EventDispatcher = new EventDispatcher();

		
		// Main window
		private static var _mainWindow:NativeWindow;
		

		/**
		 * Initialize the menu
		 */
		public static function initialize(mainWindow:NativeWindow):void
		{
			_mainWindow = mainWindow;
			if (Capabilities.os.substr(0, 3) == "Mac") {
//				createNativeMacMenu();
//				_mainWindow.addEventListener(Event.ACTIVATE, focusMainWindow, false, 0, false);
//				_mainWindow.addEventListener(Event.DEACTIVATE, unfocusMainWindow, false, 0, false);
			} else {
				_mainWindow.menu = createTopMenu();
			}
			
		}
		
		
		/**
		 * Get the main window
		 */
		public static function get mainWindow():NativeWindow {
			return _mainWindow;
		}
		

//		/**
//		 * When the main window gain focus
//		 */
//		private static function focusMainWindow(event:Event):void
//		{
//			if (_closeTabItem != null) {
//				_closeTabItem.label = "Close Tab";
//			}
//		}
//
//
//		/**
//		 * When the main window loses the focus
//		 */
//		private static function unfocusMainWindow(event:Event):void
//		{
//			if (_closeTabItem != null) {
//				_closeTabItem.label = "Close Window";
//			}
//		}


		public static function createTopMenu():NativeMenu
		{
			var nativeMenu:NativeMenu = new NativeMenu();
			var item:NativeMenuItem;

			item = new NativeMenuItem("File");
			item.submenu = createFileMenu();
			nativeMenu.addItem(item);
			
			
			item = new NativeMenuItem("View");
			item.submenu = createViewMenu();
			nativeMenu.addItem(item);
		
			
			// Create Edit menu
			item = new NativeMenuItem("Edit");
			item.submenu = createEditMenu();
			nativeMenu.addItem(item);
			
			
			item = new NativeMenuItem("Window");
			item.submenu = createWindowMenu();
			nativeMenu.addItem(item);
			
			item = new NativeMenuItem("Help");
			item.submenu = createHelpMenu();
			nativeMenu.addItem(item);

			return nativeMenu;
		}


//		public static function createNativeMacMenu():NativeMenu
//		{
//			var menu:NativeMenu = NativeApplication.nativeApplication.menu;
//			
//			// About
//			var nativeMenu:NativeMenuItem = menu.getItemAt(0);
//			nativeMenu.submenu.removeItemAt(0);
//			var aboutMenu:NativeMenuItem = new NativeMenuItem("About Translation Debugger");
//			aboutMenu.addEventListener(Event.SELECT, function(e:Event):void {
//				_dispatcher.dispatchEvent(new Event(ABOUT_TRANSLATION));
//			});
//			nativeMenu.submenu.addItemAt(aboutMenu, 0);
//			
//			// Retrieve File menu
//			var fileMenuItem:NativeMenuItem = new NativeMenuItem("File");
//			fileMenuItem.submenu = createFileMenu();
//			menu.removeItemAt(1);
//			menu.addItemAt(fileMenuItem, 1);
//
//			// Create View menu
//			var viewMenuItem:NativeMenuItem = new NativeMenuItem("View1");
//			viewMenuItem.submenu = createViewMenu();
//			menu.addItemAt(viewMenuItem, 3);
//			
//			// Create Edit menu
//			var editMenuItem:NativeMenuItem = new NativeMenuItem("Edit");
//			editMenuItem.submenu = createEditMenu();
//			menu.addItemAt(editMenuItem, 4);
//			
//			
//			_windowMenu = new NativeMenuItem("Window");
//			_windowMenu.submenu = createMacWindowMenu();
//			menu.removeItemAt(4);
//			menu.addItemAt(_windowMenu, 5);
//
//			// Create help menu
//			var helpMenuItem:NativeMenuItem = new NativeMenuItem("Help");
//			helpMenuItem.submenu = createHelpMenu();
//			menu.addItem(helpMenuItem);
//
//			return menu;
//		}


		public static function enableSaveItem(saveAs:Boolean = false):void
		{
			if (_saveMenuItem) {
				_saveMenuItem.enabled = true;
				if (saveAs) {
					_saveAsMenuItem.enabled = true;
				}
			}
		}


		public static function disableSaveItem(saveAs:Boolean = false):void
		{
			if (_saveMenuItem) {
				_saveMenuItem.enabled = false;
				if (saveAs) {
					_saveAsMenuItem.enabled = false;
				}
			}
		}


		private static function createFileMenu():NativeMenu
		{
			var menuFile:NativeMenu = new NativeMenu();
//
			//if (Capabilities.os.substr(0, 3) == "Mac") {
				//_saveMenuItem = new NativeMenuItem("Save");
				//_saveMenuItem.data = new Event(SAVE);
				//_saveMenuItem.keyEquivalent = "s";
				//_saveMenuItem.enabled = false;
				//_saveMenuItem.addEventListener(Event.SELECT, eventHandler);
				//menuFile.addItem(_saveMenuItem);
//
				//_saveAsMenuItem = new NativeMenuItem("Save As");
				//_saveAsMenuItem.data = new Event(SAVE_AS);
				//_saveAsMenuItem.keyEquivalent = "S";
				//_saveAsMenuItem.enabled = false;
				//_saveAsMenuItem.addEventListener(Event.SELECT, eventHandler);
				//menuFile.addItem(_saveAsMenuItem);
//
				//// Separator
				//menuFile.addItem(new NativeMenuItem("", true));
			//}
//
			//_exportClientSWC = new NativeMenuItem("Export SWC");
			//_exportClientSWC.data = new Event(EXPORT_CLIENT_SWC);
			//_exportClientSWC.addEventListener(Event.SELECT, eventHandler);
			//menuFile.addItem(_exportClientSWC);
//
			//_exportClientMobileSWC = new NativeMenuItem("Export Mobile SWC");
			//_exportClientMobileSWC.data = new Event(EXPORT_CLIENT_MOBILE_SWC);
			//_exportClientMobileSWC.addEventListener(Event.SELECT, eventHandler);
			//menuFile.addItem(_exportClientMobileSWC);
			//
			//menuFile.addItem(new NativeMenuItem("", true));

			_closeTabItem = new NativeMenuItem("Close Tab");
			_closeTabItem.data = new Event(CLOSE_TAB);
			_closeTabItem.addEventListener(Event.SELECT, closeTabHandler);
			_closeTabItem.keyEquivalent = "w";
			menuFile.addItem(_closeTabItem);
			

			if (Capabilities.os.substr(0, 3) != "Mac") {
				_closeWindowItem = new NativeMenuItem("Close");
				_closeWindowItem.addEventListener(Event.SELECT, closeApplicationHandler);
				menuFile.addItem(_closeWindowItem);
			}

			return menuFile;
		}
		
		public static function createEditMenu():NativeMenu
		{
			var menu:NativeMenu = new NativeMenu();
			var item:NativeMenuItem;
			
			item = new NativeMenuItem("Inspect");
			item.keyEquivalent = "i";
			item.data = new Event(HIGHLIGHT_INSPECT, true);
			item.addEventListener(Event.SELECT, eventHandler);
			menu.addItem(item);
			
			
			item = new NativeMenuItem("Find Key");
			item.keyEquivalent = "f";
			item.data = new Event(DConstants.COMMAND_FIND_KV, true);
			item.addEventListener(Event.SELECT, eventHandler);
			menu.addItem(item);
			
			
			item = new NativeMenuItem("Find Pic");
			item.keyEquivalent = "F";
			item.data = new Event(DConstants.COMMAND_FIND_PIC, true);
			item.addEventListener(Event.SELECT, eventHandler);
			menu.addItem(item);
			
			item = new NativeMenuItem("Show AS Key");
			item.data = new Event(DConstants.COMMAND_DEBUG_MODE, true);
			item.addEventListener(Event.SELECT, toggleCheckedHandler);
			menu.addItem(item);
			
			
			if(DData.DEV){
				item = new NativeMenuItem("Open FLA");
				item.data = new Event(DConstants.COMMAND_OPEN_IN_FLASH, true);
				item.addEventListener(Event.SELECT, eventHandler);
				menu.addItem(item);
				
				item = new NativeMenuItem("Open AS");
				item.data = new Event(DConstants.COMMAND_OPEN_IN_AS, true);
				item.addEventListener(Event.SELECT, eventHandler);
				menu.addItem(item);
				
				item = new NativeMenuItem("Open Debug Files");
				item.data = new Event(OPEN_DEBUG_FILES, true);
				item.addEventListener(Event.SELECT, eventHandler);
				menu.addItem(item);
				
				
			}
			
			return menu;
		}
		public static function createViewMenu():NativeMenu
		{
			var menu:NativeMenu = new NativeMenu();
			var item:NativeMenuItem;
			
			newViewMenuItem(menu,"Show Application view","1",v_application);
			
			if(DData.DEV){
				newViewMenuItem(menu,"Show Breakpoint panel","2",v_breakpoint);
			}else{
				v_breakpoint = false;
			}
			newViewMenuItem(menu,"Show Tools panel","3",v_tools);
			if(DData.DEV){
				newViewMenuItem(menu,"Show Monitor panel","4",v_monitor);
			}else{
				v_monitor = false;
			}
			
			newViewMenuItem(menu,"Show Trace panel","5",v_traces);
			newViewMenuItem(menu,"Show GM panel","6",v_gm);
			newViewMenuItem(menu,"Show Find panel","7",v_find);

			if(DData.DEV){
				newViewMenuItem(menu,"Show Methods panel","8",v_methods);
			}else{
				v_methods = false;
			}
			newViewMenuItem(menu,"Show Properties panel","8",v_properties);
			
			
			// Separator
			menu.addItem(new NativeMenuItem("", true));
			item = new NativeMenuItem("Next Tab");
			item.data = new Event(NEXT_TAB, true);
			item.keyEquivalent = "]";
			item.addEventListener(Event.SELECT, eventHandler);
			menu.addItem(item);

			item = new NativeMenuItem("Previous Tab");
			item.data = new Event(PREVIOUS_TAB, true);
			item.keyEquivalent = "[";
			item.addEventListener(Event.SELECT, eventHandler);
			menu.addItem(item);
			
			item = new NativeMenuItem("Close Disconnected Tabs");
			item.data = new Event(CLOSE_DISCONNECTED, true);
			item.keyEquivalent = "\\";
			item.addEventListener(Event.SELECT, eventHandler);
			menu.addItem(item);
			
			// Separator
			menu.addItem(new NativeMenuItem("", true));
			// Clear traces
			item = new NativeMenuItem("Clear Traces");
			item.keyEquivalent = "e";
			item.data = new Event(CLEAR_TRACES, true);
			item.addEventListener(Event.SELECT, eventHandler);
			menu.addItem(item);
			
			return menu;
		}
		private static function newViewMenuItem(menu:NativeMenu,label:String,keyEuiavalent:String,checked:Boolean):void{
			var item:NativeMenuItem = new NativeMenuItem(label);
			item.checked = checked;
			item.keyEquivalent = keyEuiavalent;
			item.addEventListener(Event.SELECT, toggleCheckedPanelHandler);
			menu.addItem(item);
			
		}


		private static function createHelpMenu():NativeMenu
		{
			var menu:NativeMenu = new NativeMenu();
			
			//version
			var appXml:XML = NativeApplication.nativeApplication.applicationDescriptor;  
			var ns:Namespace = appXml.namespace();  
			
			
			var item:NativeMenuItem = new NativeMenuItem("Vesion:"+appXml.ns::versionNumber);
			menu.addItem(item);
			
			return menu;
			// Debugger Help
			_helpSubMenuItem = new NativeMenuItem("Debugger Help");
			_helpSubMenuItem.data = new Event(HELP_WINDOW, true);
			_helpSubMenuItem.addEventListener(Event.SELECT, eventHandler);
			menu.addItem(_helpSubMenuItem);

			_gameMenuItem = new NativeMenuItem("Debugger Game");
			_gameMenuItem.data = new Event(DEBUGGER_GAME, true);
			_gameMenuItem.addEventListener(Event.SELECT, eventHandler);
			menu.addItem(_gameMenuItem);

			// Separator
			menu.addItem(new NativeMenuItem("", true));

			// Debugger Help
			_documentationSubMenuItem = new NativeMenuItem("Online documentation");
			_documentationSubMenuItem.submenu = createDocumentationMenu();
			menu.addItem(_documentationSubMenuItem);

			// Separator
			menu.addItem(new NativeMenuItem("", true));

			if (Capabilities.os.substr(0, 3) != "Mac") {
				_aboutMenuItem = new NativeMenuItem("About");
				_aboutMenuItem.data = new Event(ABOUT_TRANSLATION, true);
				_aboutMenuItem.addEventListener(Event.SELECT, eventHandler);
				menu.addItem(_aboutMenuItem);
			}

			_websiteMenuItem = new NativeMenuItem("Product Website");
			_websiteMenuItem.data = new Event(PRODUCT_WEBSITE, true);
			_websiteMenuItem.addEventListener(Event.SELECT, eventHandler);
			menu.addItem(_websiteMenuItem);

			_feedbackMenuItem = new NativeMenuItem("Feedback");
			_feedbackMenuItem.data = new Event(FEEDBACK, true);
			_feedbackMenuItem.addEventListener(Event.SELECT, eventHandler);
			menu.addItem(_feedbackMenuItem);

			return menu;
		}


		private static function createMacWindowMenu():NativeMenu
		{
			var menu:NativeMenu = NativeApplication.nativeApplication.menu.getItemAt(4).submenu;
			_onTopMenuItem = new NativeMenuItem("Always on top");
			_onTopMenuItem.checked = false;
			_onTopMenuItem.data = new Event(ALWAYS_ON_TOP, true);
			_onTopMenuItem.addEventListener(Event.SELECT, toggleCheckedHandler);
			menu.addItemAt(_onTopMenuItem, 3);
			return menu;
		}


		private static function createWindowMenu():NativeMenu
		{
			var menu:NativeMenu = new NativeMenu();
			_onTopMenuItem = new NativeMenuItem("Always on top");
			_onTopMenuItem.checked = false;
			_onTopMenuItem.data = new Event(ALWAYS_ON_TOP, true);
			_onTopMenuItem.addEventListener(Event.SELECT, toggleCheckedHandler);
			menu.addItem(_onTopMenuItem);
			
			_devMenuItem = new NativeMenuItem("Develop mode");
			_devMenuItem.checked = DData.DEV;
			_devMenuItem.addEventListener(Event.SELECT, toggleCheckedHandler);
			menu.addItem(_devMenuItem);
			
			if(DData.DEV){
				_hideporpMenuItem = new NativeMenuItem("Hide DisplayObject Property");
				_hideporpMenuItem.checked = DData.hideDisplayProp;
				_hideporpMenuItem.addEventListener(Event.SELECT, toggleCheckedHandler);
				menu.addItem(_hideporpMenuItem);
			}
			return menu;
		}


		private static function createDocumentationMenu():NativeMenu
		{
			var menu:NativeMenu = new NativeMenu();

			_as3RefMenuItem = new NativeMenuItem("Actionscript 3.0 Reference");
			_as3RefMenuItem.data = new Event(AS3_REFERENCE);
			_as3RefMenuItem.addEventListener(Event.SELECT, eventHandler);
			menu.addItem(_as3RefMenuItem);

			_as3RunMenuItem = new NativeMenuItem("Actionscript 3.0 Runtime Errors");
			_as3RunMenuItem.data = new Event(AS3_RUNTIME_ERRORS);
			_as3RunMenuItem.addEventListener(Event.SELECT, eventHandler);
			menu.addItem(_as3RunMenuItem);

			_riaGuideMenuItem = new NativeMenuItem("Adobe Flash RIA Guide (PDF)");
			_riaGuideMenuItem.data = new Event(RIA_GUIDE);
			_riaGuideMenuItem.addEventListener(Event.SELECT, eventHandler);
			menu.addItem(_riaGuideMenuItem);

			_playersMenuItem = new NativeMenuItem("Adobe Flash Players");
			_playersMenuItem.data = new Event(FLASH_PLAYERS);
			_playersMenuItem.addEventListener(Event.SELECT, eventHandler);
			menu.addItem(_playersMenuItem);

			return menu;
		}


		/**
		 * Close handlers 
		 */
		private static function closeTabHandler(event:Event):void
		{
			if (NativeApplication.nativeApplication.activeWindow == _mainWindow) {
				_dispatcher.dispatchEvent(new Event(CLOSE_TAB));
			} else {
				NativeApplication.nativeApplication.activeWindow.close();
			}
		}
		private static function closeApplicationHandler(event:Event):void
		{
			_mainWindow.close();
		}


		private static function eventHandler(e:Event):void
		{
			var ref:NativeMenuItem = e.target as NativeMenuItem;
			if (ref.data is Event) {
				_dispatcher.dispatchEvent(ref.data as Event);
			}
		}
		private static function toggleCheckedPanelHandler(e:Event):void
		{
			var item:NativeMenuItem = e.target as NativeMenuItem;
			switch(item.label){
				case "Show Application view":
					v_application = !v_application;
					item.checked = v_application;
					break;
				case "Show Breakpoint panel":
					v_breakpoint = !v_breakpoint;
					item.checked = v_breakpoint;
					break;
				case "Show Tools panel":
					v_tools = !v_tools;
					item.checked = v_tools;
					break;
				case "Show Monitor panel":
					v_monitor = !v_monitor;
					item.checked = v_monitor;
					break;
				case "Show Trace panel":
					v_traces = !v_traces;
					item.checked = v_traces;
					break;
				case "Show GM panel":
					v_gm = !v_gm;
					item.checked = v_gm;
					break;
				case "Show Find panel":
					v_find = !v_find;
					item.checked = v_find;
					break;
				case "Show Methods panel":
					v_methods = !v_methods;
					item.checked = v_methods;
					break;
				case "Show Properties panel":
					v_properties = !v_properties;
					item.checked = v_properties;
					break;
			}
			_dispatcher.dispatchEvent(new Event(TOGGLE_VIEW, true));
		}

		private static function toggleCheckedHandler(e:Event):void
		{
			var ref:NativeMenuItem = e.target as NativeMenuItem;
			ref.checked = !ref.checked;
			if (ref.data is Event) {
				_dispatcher.dispatchEvent(ref.data as Event);
			}else if(ref == _devMenuItem){
				DData.DEV = ref.checked;
			}else if(ref == _hideporpMenuItem){
				DData.hideDisplayProp = ref.checked;
			}
		}
		
		public static function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
			_dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}


		public static function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
		{
			_dispatcher.removeEventListener(type, listener, useCapture);
		}

	}
}
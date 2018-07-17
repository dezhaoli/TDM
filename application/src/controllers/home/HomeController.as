package controllers.home
{
	import com.naruto.debugger.DHistory;
	import com.naruto.debugger.DHistoryItem;
	import com.naruto.debugger.IClient;
	import com.naruto.debugger.socket.DConnectionDefault;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.system.System;
	
	import mx.events.FlexEvent;
	
	import spark.events.IndexChangeEvent;
	
	import components.home.Home;
	import components.home.HomeRecentItem;
	import components.tabs.TabContainer;
	import components.windows.SVNBrowser;


	public final class HomeController extends EventDispatcher
	{


		// The tab component with the screen inside
		public var _tab:Home;
		private var _exportFile:File;


		/**
		 * Create a new home screen controller
		 */
		public function HomeController(container:TabContainer)
		{
			// Create a new tab
			_tab = new Home();
			_tab.addEventListener(FlexEvent.INITIALIZE, onInit, false, 0, true);
			container.addTab(_tab);
			loadRecent();
		}


		/**
		 * Creation complete
		 */
		private function onInit(event:FlexEvent):void
		{
			// Remove
			_tab.removeEventListener(FlexEvent.INITIALIZE, onInit);
			_tab.buttonStart.addEventListener(MouseEvent.CLICK, clickHandler, false, 0, true);
			_tab.buttonBack.addEventListener(MouseEvent.CLICK, clickHandler, false, 0, true);
			_tab.buttonCopy.addEventListener(MouseEvent.CLICK, clickHandler, false, 0, true);
			_tab.buttonExport.addEventListener(MouseEvent.CLICK, clickHandler, false, 0, true);
			_tab.buttonTour.addEventListener(MouseEvent.CLICK, clickHandler, false, 0, true);
			_tab.buttonGame.addEventListener(MouseEvent.CLICK, clickHandler, false, 0, true);
			_tab.buttonDocumentation.addEventListener(MouseEvent.CLICK, clickHandler, false, 0, true);
			_tab.buttonFPDebuggerPage.addEventListener(MouseEvent.CLICK, clickHandler, false, 0, true);
			_tab.buttonBug.addEventListener(MouseEvent.CLICK, clickHandler, false, 0, true);
			_tab.buttonSite.addEventListener(MouseEvent.CLICK, clickHandler, false, 0, true);
			_tab.buttonHost.addEventListener(MouseEvent.CLICK, clickHandler, false, 0, true);
			_tab.i18n_art_proj.addEventListener(MouseEvent.CLICK, clickHandler, false, 0, true);
			_tab.dropdownTarget.addEventListener(IndexChangeEvent.CHANGE, selectedTarget, false, 0, true);
			_tab.dropdownType.addEventListener(IndexChangeEvent.CHANGE, selectedType, false, 0, true);
		}


		/**
		 * Button clicked
		 */
		private function clickHandler(event:MouseEvent):void
		{
			// Remove
			switch (event.target) {
				case _tab.buttonStart:
					_tab.groupHome.visible = false;
					_tab.groupHome.includeInLayout = false;
					_tab.groupWizzard.visible = true;
					_tab.groupWizzard.includeInLayout = true;
					break;
				case _tab.buttonBack:
					_tab.groupHome.visible = true;
					_tab.groupHome.includeInLayout = true;
					_tab.groupWizzard.visible = false;
					_tab.groupWizzard.includeInLayout = false;
					break;
				case _tab.buttonCopy:
					System.setClipboard(_tab.codeField.text);
					break;
				case _tab.buttonExport:
					if (_exportFile != null) {
						var file:File = File.desktopDirectory.resolvePath(_exportFile.name);
						file.addEventListener(Event.SELECT, function(e:Event):void {
							_exportFile.copyTo(file, true);
						});
						file.browseForSave("Save " + _exportFile.name);
					}
					break;
				case _tab.buttonTour:
					//
					break;
				case _tab.buttonDocumentation:
					//
					break;
				case _tab.buttonSources:
					//
					break;
				case _tab.buttonFPDebuggerPage:
					navigateToURL(new URLRequest("http://www.adobe.com/support/flashplayer/debug_downloads.html"));
					break;
				case _tab.buttonSite:
					navigateToURL(new URLRequest("http://dev.i18n.huoying.qq.com"));
					break;
				case _tab.i18n_art_proj:
					var svnBrowser:SVNBrowser = new SVNBrowser();
					svnBrowser.setData("http://tc-svn.tencent.com/narutoI18n/i18n_art_proj/trunk/");
//					svnBrowser.setData("http://tc-svn.tencent.com/narutoI18n/i18n_art_proj/trunk/NarutoI18nBeta3.22/i18n_de/fla_fullPic/src/naruto.operatingActivity/extlibs/GuildCallbackUI");
//					svnBrowser.setData("http://tc-svn.tencent.com/narutoI18n/tw_assets_proj/trunk/assets/guild/10000301.swf");
					svnBrowser.open();
					break;
				case _tab.buttonHost:
					
					
					var f:File = new File("c:/windows/system32/drivers/etc");
					f.openWithDefaultApplication();
					break;
				case _tab.buttonGame:
					var connect:DConnectionDefault = new DConnectionDefault;
					
					break;
			}
		}


		private function selectedType(event:IndexChangeEvent = null):void
		{
			_tab.dropdownTarget.enabled = true;
			_tab.labelStep2.setStyle('color', 0x000000);
			generateExampleCode();
		}


		private function selectedTarget(event:IndexChangeEvent = null):void
		{
			_tab.buttonExport.enabled = true;
			_tab.labelStep3.setStyle('color', 0x000000);
			_tab.labelStep4.setStyle('color', 0x000000);
			_tab.codeField.enabled = true;
			_tab.buttonCopy.enabled = true;
			generateExampleCode();
		}


		/**
		 * Change the source code
		 */
		private function generateExampleCode(event:IndexChangeEvent = null):void
		{
			/*FDT_IGNORE*/
			
		}


		public function loadRecent():void
		{
			_tab.recentSessions.removeAllElements();
			var items:Vector.<DHistoryItem> = DHistory.items;
			for (var i:int = 0; i < items.length; i++) {
				var item:HomeRecentItem = new HomeRecentItem();
				item.setItem(items[i]);
				_tab.recentSessions.addElement(item);
			}
		}


		/**
		 * Add a recent item
		 */
		public function addRecent(client:IClient):void
		{
			DHistory.add(client);
			DHistory.save();
			loadRecent();
		}
	}
}
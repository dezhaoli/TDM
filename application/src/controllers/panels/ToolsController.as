package controllers.panels
{
	import com.naruto.debugger.DConstants;
	import com.naruto.debugger.DData;
	import com.naruto.debugger.DMenu;
	import com.naruto.debugger.DTabContext;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	
	import mx.events.FlexEvent;
	
	import components.panels.ToolsPanel;
	import components.windows.HelpWindow;
	import components.windows.SVNBrowser;
	
	import skins.button.iconButtons.IconButton;
	import skins.button.iconButtons.IconButtonRmPlugin;


	public final class ToolsController extends EventDispatcher
	{

		private var _panel:ToolsPanel;
		private var _send:Function;
		private var _stack:XML;
		private var _line:int;
		private var _path:String;
		private var _helpWindow:HelpWindow;
		private var _toggleShowASKey:Boolean;
		private var _isRunning:Boolean;
		[Bindable]
		[Embed(source="../../../assets/icon_flash.png")]
		public var _I_A:Class;
		[Bindable]
		[Embed(source="../../../assets/key.png")]
		public var _I_B:Class;
		[Bindable]
		[Embed(source="../../../assets/find_icon.png")]
		public var _I_C:Class;
		[Bindable]
		[Embed(source="../../../assets/icon_bug.png")]
		public var _I_D:Class;
		[Bindable]
		[Embed(source="../../../assets/paused.png")]
		public var _I_E:Class;
		[Bindable]
		[Embed(source="../../../assets/running.png")]
		public var _I_F:Class;
		[Embed(source="../../../assets/icon_as.png")]
		public var _I_G:Class;
		
		
		
		[Bindable]
		private var _defPluginName:String ="operatingActivity.IOperatingActivityPlugin";
		private var _context:DTabContext;
		/**
		 * Data handler for the panel
		 */
		public function ToolsController(panel:ToolsPanel,context:DTabContext, send:Function)
		{
			_panel = panel;
			_context = context;
			_context.toolsController = this;
			_send = send;
			_panel.addEventListener(FlexEvent.CREATION_COMPLETE, creationComplete, false, 0, true);
		}


		/**
		 * Panel is ready to link data providers
		 */
		private function creationComplete(e:FlexEvent):void
		{
			// Remove eventlistener
			_panel.removeEventListener(FlexEvent.CREATION_COMPLETE, creationComplete);
			
			_panel.flakvBt.addEventListener(MouseEvent.CLICK, buttonClicked, false, 0, true);
			_panel.flapicBt.addEventListener(MouseEvent.CLICK, buttonClicked, false, 0, true);
			_panel.openInFlaBt.addEventListener(MouseEvent.CLICK, buttonClicked, false, 0, true);
			_panel.openAsBt.addEventListener(MouseEvent.CLICK, buttonClicked, false, 0, true);
			_panel.linkFlaSVNBt.addEventListener(MouseEvent.CLICK, buttonClicked, false, 0, true);
			_panel.linkAssetsBt.addEventListener(MouseEvent.CLICK, buttonClicked, false, 0, true);
			_panel.reloadAssetsBt.addEventListener(MouseEvent.CLICK, buttonClicked, false, 0, true);
			
			
			_panel.stopResumeBt.addEventListener(MouseEvent.CLICK, onStopResumeBtClicked, false, 0, true);
			_panel.inspectBt.addEventListener(MouseEvent.CLICK, onInspectClicked, false, 0, true);
			
			
			_panel.cleanButton.addEventListener(MouseEvent.CLICK, buttonClicked, false, 0, true);
			
			// Highlight and inspect 
			DMenu.addEventListener(DMenu.HIGHLIGHT_INSPECT, onInspectClicked);
			DMenu.addEventListener(DConstants.COMMAND_DEBUG_MODE, onShowASKey);
			DMenu.addEventListener(DConstants.COMMAND_FIND_PIC, findpic);
			DMenu.addEventListener(DConstants.COMMAND_FIND_KV, findkey);
			DMenu.addEventListener(DConstants.COMMAND_OPEN_IN_FLASH, openInFlash);
			DMenu.addEventListener(DConstants.COMMAND_OPEN_IN_AS, openASFile);
			
			IconButton(_panel.openInFlaBt.skin).source = _I_A;
			IconButton(_panel.flakvBt.skin).source = _I_C;
			IconButton(_panel.flapicBt.skin).source = _I_C;
			IconButton(_panel.inspectBt.skin).source = _I_D;
			IconButton(_panel.openAsBt.skin).source = _I_G;
			updateStopResumeBt(true);
			setDefPluginName(_defPluginName);
			
			if(!DData.DEV){
				_panel.openInFlaBt.visible = false;
				_panel.openAsBt.visible = false;
				_panel.reloadAssetsBt.visible = false;
				
				_panel.openInFlaBt.includeInLayout = false;
				_panel.openAsBt.includeInLayout = false;
				_panel.reloadAssetsBt.includeInLayout = false;
				
				
			}
		}
		public function updateLinkSVNBtEnable():void{
			_panel.linkFlaSVNBt.enabled = _context.plData.LOCAL_FLA_PIC_SVN != "";
			_panel.linkAssetsBt.enabled = _context.plData.LOCAL_ASSETS_SVN != "";
		}
		public function onShowASKey(event:Event=null):void
		{
			if(event && !_context.tabController.active){
				return;
			}
			_toggleShowASKey = !_toggleShowASKey;
			_send({command:DConstants.COMMAND_DEBUG_MODE,val:String(_toggleShowASKey)});
		}
		
		
		/**
		 * One of the buttons has been clicked
		 */
		private function buttonClicked(event:MouseEvent):void
		{
			var svnBrowser:SVNBrowser;
			switch (event.target) {
				case _panel.flakvBt:
					findkey();
					break;
				case _panel.flapicBt:
					findpic();
					break;
				case _panel.openInFlaBt:
					openInFlash();
					break;
				case _panel.openAsBt:
					openASFile();					
					break;
				case _panel.linkFlaSVNBt:
					svnBrowser = new SVNBrowser();
					svnBrowser.setData(_context.plData.LOCAL_FLA_PIC_SVN);
					svnBrowser.open();
					break;
				case _panel.linkAssetsBt:
					svnBrowser = new SVNBrowser();
					svnBrowser.setData(_context.plData.LOCAL_ASSETS_SVN);
					svnBrowser.open();
					break;
				case _panel.cleanButton:
					_context.loadDataHelper.cleanAndReload();
					break;
				case _panel.reloadAssetsBt:
					if(_defPluginName){
						rmPlugin(_defPluginName);
					}
					break;
				
			}
		}
		public function setDefPluginName(val:String):void{
			_defPluginName = val;
			if(val){
				_panel.reloadAssetsBt.label = "rm [" +val.split(".")[0]+"]";
				_panel.reloadAssetsBt.visible = _panel.reloadAssetsBt.includeInLayout = true;
			}else{
				_panel.reloadAssetsBt.visible = _panel.reloadAssetsBt.includeInLayout = false;
			}
		}
		public function rmPlugin(name:String):void{
			_send({command:DConstants.COMMAND_RELOAD_CALL,fn_name:"rm",data:[name]});
		}
		private function openASFile(e:Event=null):void{
			if(e && !_context.tabController.active){
				return;
			}
			_send({command:DConstants.COMMAND_OPEN_IN_AS,extra:"as"});
		}
		private function openInFlash(e:Event=null):void{
			if(e && !_context.tabController.active){
				return;
			}
			_send({command:DConstants.COMMAND_OPEN_IN_FLASH});
		}
		private function findkey(e:Event=null):void {
			if(e && !_context.tabController.active){
				return;
			}
			_send({command:DConstants.COMMAND_START_AS_KV});
		}
		private function findpic(e:Event=null):void {
			if(e && !_context.tabController.active){
				return;
			}
			_send({command:DConstants.COMMAND_FIND_PIC});
		}
		public function setLoadState(state:String,succPercent:int,failPercent:int):void
		{
			_panel.loadInfoTf.text = state;
			_panel.greenFill.percentWidth = succPercent;
			_panel.redFill.percentWidth = failPercent;
			if(failPercent == 100){
				_panel.cleanButton.visible = true;
			}else{
				_panel.cleanButton.visible = false;
			}
		}
		
		/**
		 * Inspect button clicked
		 */
		private function onInspectClicked(event:Event):void
		{
			if(event && !_context.tabController.active){
				return;
			}
			// Send start or stop
			if (_panel.inspectBt.label == "Start Inspect") {
				_panel.inspectBt.label = "Stop Inspect";
				_send({command:DConstants.COMMAND_START_HIGHLIGHT});
			} else {
				_panel.inspectBt.label = "Start Inspect";
				_send({command:DConstants.COMMAND_STOP_HIGHLIGHT});
			}
			
		}
		
		
		/**
		 * Inspect button clicked
		 */
		private function onStopResumeBtClicked(event:Event):void
		{
			
			
			if(_isRunning){
				_send({command:DConstants.COMMAND_PAUSE});
			}else{
				_send({command:DConstants.COMMAND_RESUME});
			}
			updateStopResumeBt(!_isRunning);
			
		}
		private function updateStopResumeBt(val:Boolean):void{
			
			if(_isRunning == val){
				return;
			}
			_isRunning = val;
			if(_isRunning){
				_panel.stopResumeBt.label = "Suspend";
				IconButton(_panel.stopResumeBt.skin).source = _I_F;
			}else{
				_panel.stopResumeBt.label = "Resume";
				IconButton(_panel.stopResumeBt.skin).source = _I_E;
			}
		}

		/**
		 * Data handler from open tab
		 */
		public function setData(data:Object):void
		{
			switch (data["command"]) {
				case DConstants.COMMAND_START_HIGHLIGHT:
					_panel.inspectBt.label = "Stop Inspect";
				break;
				
				case DConstants.COMMAND_STOP_HIGHLIGHT:
					_panel.inspectBt.label = "Start Inspect";
				break;
				case DConstants.COMMAND_DEBUG_MODE:
					onShowASKey();
					break;
				case DConstants.COMMAND_RESUME:
					updateStopResumeBt(true);
					break;
				case DConstants.COMMAND_PAUSE:
					updateStopResumeBt(false);
					break;
				
				case DConstants.COMMAND_RELOAD_CALL:
					if(data.fn_name == "fromClient"){
						if(_defPluginName){
							rmPlugin(_defPluginName);
						}
					}else if(data.fn_name == "setDef"){
						setDefPluginName(data.name);
					}
					break;
			}
		}
		

	}
}
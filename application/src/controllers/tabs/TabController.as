package controllers.tabs
{
	import com.naruto.debugger.DConstants;
	import com.naruto.debugger.DData;
	import com.naruto.debugger.DMenu;
	import com.naruto.debugger.DTabContext;
	import com.naruto.debugger.IClient;
	import com.naruto.debugger.TranslateController;
	import com.naruto.debugger.helper.LoadDataHelper;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.events.FlexEvent;
	
	import components.panels.ApplicationPanel;
	import components.panels.BreakpointsPanel;
	import components.panels.FindPanel;
	import components.panels.GMPanel;
	import components.panels.MethodPanel;
	import components.panels.MonitorPanel;
	import components.panels.PropertiesPanel;
	import components.panels.ToolsPanel;
	import components.panels.TracePanel;
	import components.tabs.Tab;
	import components.tabs.TabContainer;
	
	import controllers.panels.ApplicationController;
	import controllers.panels.BreakpointsController;
	import controllers.panels.FindController;
	import controllers.panels.GMController;
	import controllers.panels.MethodController;
	import controllers.panels.MonitorController;
	import controllers.panels.PropertiesController;
	import controllers.panels.ToolsController;
	import controllers.panels.TraceController;
	
	import events.PanelEvent;
	import events.TraceEvent;


	public final class TabController extends EventDispatcher
	{

		// Linked client
		private var _client:IClient;


		// The tab component
		public var _tab:Tab;
		private var _closedTab:Function;


		// The panels
		private var _tracePanel:TracePanel;
		private var _propertiesPanel:PropertiesPanel;
		private var _methodPanel:MethodPanel;
		private var _liveApplicationPanel:ApplicationPanel;
		private var _toolsPanel:ToolsPanel;
		private var _breakpointsPanel:BreakpointsPanel;
		private var _monitorPanel:MonitorPanel;

		private var _loadHelper:LoadDataHelper;

		// The panel controllers
		private var _traceController:TraceController;
		private var _propertiesController:PropertiesController;
		private var _methodController:MethodController;
		private var _applicationController:ApplicationController;
		private var _toolsController:ToolsController;
		private var _breakpointsController:BreakpointsController;
		private var _monitorController:MonitorController;
		private var _translateController:TranslateController;
		private var _findController:FindController;
		private var _gmController:GMController;


		private var _active:Boolean;

		private var _findPanel:FindPanel;

		private var _gmPanel:GMPanel;
		
		private var _context:DTabContext = new DTabContext;

		/**
		 * Create a new tab controller
		 */
		public function TabController(closedTab:Function,container:TabContainer, aClient:IClient)
		{
			_client = aClient;

			// Create a new tab
			_tab = new Tab();
			_closedTab = closedTab;
			_tab.addEventListener(FlexEvent.INITIALIZE, onInit, false, 0, true);
			container.addTab(_tab);
			
			// Save client and set label
			
			client = aClient;
			
		}



		/**
		 * Create the panels
		 */
		private function onInit(event:FlexEvent):void
		{
			// Remove
			_tab.removeEventListener(FlexEvent.INITIALIZE, onInit);

			// Create the panels
			_tracePanel = new TracePanel();
			_findPanel = new FindPanel();
			_gmPanel = new GMPanel();
			_propertiesPanel = new PropertiesPanel();
			_methodPanel = new MethodPanel();
			_liveApplicationPanel = new ApplicationPanel();
			_toolsPanel = new ToolsPanel();
			_breakpointsPanel = new BreakpointsPanel();
			_monitorPanel = new MonitorPanel();

			// Create the names
			_tracePanel.name = "Traces";
			_tracePanel.label = "Traces";
			_findPanel.name = "Find in files";
			_findPanel.label = "Find in files";
			_gmPanel.name = "GM Tools";
			_gmPanel.label = "GM Tools";
			_propertiesPanel.name = "Properties";
			_propertiesPanel.label = "Properties";
			_methodPanel.name = "Methods";
			_methodPanel.label = "Methods";
			_liveApplicationPanel.name = "Application";
			_liveApplicationPanel.label = "Application";
			_breakpointsPanel.name = "Breakpoints";
			_monitorPanel.name = "Memory Monitor";
			_toolsPanel.name = "Tools";
			_toolsPanel.label = "Tools";
			

			// Add the panels
			_tab.bottomPanel.addPanelItem(_findPanel);
			_tab.bottomPanel.addPanelItem(_gmPanel);
			_tab.bottomPanel.addPanelItem(_tracePanel);
			
			_tab.leftPanel.addPanelItem(_liveApplicationPanel);
			
			
			_tab.middlePanel.addPanelItem(_propertiesPanel);
			_tab.middlePanel.addPanelItem(_methodPanel);
			
			_tab.rightPanelTop.addPanelItem(_breakpointsPanel);
			
			_tab.rightPanelBottom.addPanelItem(_toolsPanel);
			_tab.rightPanelBottom.addPanelItem(_monitorPanel);
			
			_context.tabController = this;

			// Create the controllers
			_traceController = new TraceController(_tracePanel, _context, send);
			_propertiesController = new PropertiesController(_propertiesPanel, send);
			_methodController = new MethodController(_methodPanel, send);
			_applicationController = new ApplicationController(_liveApplicationPanel, _context, send);
			_breakpointsController = new BreakpointsController(_breakpointsPanel, send);
			_toolsController = new ToolsController(_toolsPanel,_context, send);
			
			_monitorController = new MonitorController(_monitorPanel, send);
			
			_translateController = new TranslateController(_context,send);
			_findController = new FindController(_findPanel,_context, send);
			_gmController = new GMController(_gmPanel, _context, send);
			
			
			_loadHelper = new LoadDataHelper(_context);
			_loadHelper.init("v3",client.kvs);

			// Panel listeners
			DMenu.addEventListener(DMenu.TOGGLE_VIEW, windowCheck);
			DMenu.addEventListener(DMenu.CLEAR_TRACES, clearTraces);
			DMenu.addEventListener(DMenu.OPEN_DEBUG_FILES, openDebugFiles);
			DMenu.addEventListener(DMenu.CLOSE_DISCONNECTED, closeDisconnected);

			// Add event listeners for communication between controllers
			_applicationController.addEventListener(PanelEvent.CLEAR_PROPERTIES, clearProperties, false, 0, true);
			windowCheck();
		}
		
		/**
		 * Clear the tab
		 */
		public function clear():void
		{
			_traceController.clear();
			_propertiesController.clear();
			_methodController.clear();
			_applicationController.clear();
			_monitorController.clear();
			_findController.clear();
			_client.onData = null;
			_client = null;
		}


		/**
		 * Link the client to this tab
		 */
		public function set client(value:IClient):void {
			if (_client != null) {
				_client.onData = function(item:DData):void{};
				_client.onDisconnect = function(target:IClient):void{};
			}
			_client = value;
			if (_client != null) {
				_client.onData = dataHandler;
				_client.onDisconnect = closedConnection;
				_breakpointsController.reset();
				_breakpointsController.enabled = _client.isDebugger;
				_tab.label = _client.fileTitle;
				_traceController.clear();
				_propertiesController.clear();
				_methodController.clear();
				_applicationController.clear();
				_monitorController.clear();

				_tab.disconnectMessageBox.visible = false;
				_tab.disconnectMessageBox.includeInLayout = false;
			} else {
				_breakpointsController.reset();
				_breakpointsController.enabled = false;
				_tab.label = "Waiting...";
			}
		}
		

		/**
		 * Return the linked client
		 */
		public function get client():IClient {
			return _client;
		}


		/**
		 * Clear properties
		 */
		private function clearProperties(event:PanelEvent):void
		{
			_propertiesController.clear();
			_methodController.clear();
		}


		/**
		 * Send data to the client
		 * Note: This is called from the panel controller
		 */
		private function send(data:Object):void
		{
			if (_client != null) {
				_client.send(DConstants.ID, data);
			}
		}


		/**
		 * Incomming data from the client 
		 */
		private function dataHandler(item:DData):void
		{
			if (item.id == DConstants.ID) {
				
				// Set data in controlers
				_traceController.setData(item.data);
				_propertiesController.setData(item.data);
				_methodController.setData(item.data);
				_applicationController.setData(item.data);
				_monitorController.setData(item.data);
				_gmController.setData(item.data);
				_breakpointsController.setData(item.data);
				
				_translateController.setData(item.data);
				_toolsController.setData(item.data);
				_findController.setData(item.data);

				// In case of a new base, get the previews
				switch (item.data["command"]) {
					case DConstants.COMMAND_BASE:
					case DConstants.COMMAND_INSPECT:
						_client.send(DConstants.ID, {command:DConstants.COMMAND_GET_PROPERTIES, target:""});
						_client.send(DConstants.ID, {command:DConstants.COMMAND_GET_FUNCTIONS, target:""});
						_client.send(DConstants.ID, {command:DConstants.COMMAND_GET_PREVIEW, target:""});
						break;
				}
			}
		}


		private function closedConnection(target:IClient):void
		{
			_tab.disconnectMessageBox.visible = true;
			_tab.disconnectMessageBox.includeInLayout = true;
		}


		private function windowCheck(e:Event = null):void
		{
			if(!_active) return;
			//bottom
			if(DMenu.v_find || DMenu.v_gm || DMenu.v_traces){
				_tab.bottomPanel.setPanelAvailable(_findPanel ,DMenu.v_find);
				_tab.bottomPanel.setPanelAvailable(_gmPanel ,DMenu.v_gm);
				_tab.bottomPanel.setPanelAvailable(_tracePanel ,DMenu.v_traces);
				
				_tab.bottomPanel.visible = true;
				_tab.bottomPanel.includeInLayout = true;
			}else{
				_tab.bottomPanel.visible = false;
				_tab.bottomPanel.includeInLayout = false;
			}
			
			//left
			if(DMenu.v_application){
				_tab.leftPanel.visible = true;
				_tab.leftPanel.includeInLayout = true;
			}else{
				_tab.leftPanel.visible = false;
				_tab.leftPanel.includeInLayout = false;
			}
			
			//middle
			if(DMenu.v_properties || DMenu.v_methods){
				_tab.middlePanel.setPanelAvailable(_propertiesPanel ,DMenu.v_properties);
				_tab.middlePanel.setPanelAvailable(_methodPanel ,DMenu.v_methods);
				
				_tab.middlePanel.visible = true;
				_tab.middlePanel.includeInLayout = true;
			}else{
				_tab.middlePanel.visible = false;
				_tab.middlePanel.includeInLayout = false;
			}
			
			//right_top
			if(DMenu.v_breakpoint){
				_tab.rightPanelTop.visible = true;
				_tab.rightPanelTop.includeInLayout = true;
			}else{
				_tab.rightPanelTop.visible = false;
				_tab.rightPanelTop.includeInLayout = false;
			}
			
			//right_bottom
			if(DMenu.v_tools || DMenu.v_monitor){
				_tab.rightPanelBottom.setPanelAvailable(_toolsPanel ,DMenu.v_tools);
				_tab.rightPanelBottom.setPanelAvailable(_monitorPanel ,DMenu.v_monitor);
				
				_tab.rightPanelBottom.visible = true;
				_tab.rightPanelBottom.includeInLayout = true;
			}else{
				_tab.rightPanelBottom.visible = false;
				_tab.rightPanelBottom.includeInLayout = false;
			}
				
			if (_tab.leftPanel.visible == false && _tab.middlePanel.visible == false && _tab.rightPanelTop.visible == false && _tab.rightPanelBottom.visible == false) {
				_tab.horizontalsplit.visible = false;
				_tab.horizontalsplit.includeInLayout = false;
				_tab.rightGroup.visible = false;
				_tab.rightGroup.includeInLayout = false;
			} else if (_tab.leftPanel.visible == false && _tab.middlePanel.visible == false && _tab.rightPanelBottom.visible == false) {
				_tab.horizontalsplit.height = 110;
				_tab.rightGroup.visible = true;
				_tab.rightGroup.includeInLayout = true;
				_tab.horizontalsplit.visible = true;
				_tab.horizontalsplit.includeInLayout = true;
			} else if ( _tab.rightPanelTop.visible == false && _tab.rightPanelBottom.visible == false) {
				_tab.rightGroup.visible = false;
				_tab.rightGroup.includeInLayout = false;
				_tab.horizontalsplit.visible = true;
				_tab.horizontalsplit.includeInLayout = true;
				_tab.horizontalsplit.percentHeight = 50;
			} else {
				_tab.horizontalsplit.visible = true;
				_tab.horizontalsplit.includeInLayout = true;
				_tab.horizontalsplit.percentHeight = 50;
				_tab.rightGroup.visible = true;
				_tab.rightGroup.includeInLayout = true;
			}
		}

		private function closeDisconnected(e:Event):void
		{
			if (_tab.disconnectMessageBox.visible == true) {
				_closedTab(this);
			}
		}
		private function clearTraces(e:Event):void
		{
			if (active) {
				_traceController.clear();
			}
		}
		private function openDebugFiles(e:Event):void
		{
			if (active) {
				_loadHelper.saveToLocal();
			}
		}


		public function get active():Boolean
		{
			return _active;
		}

		public function set active(value:Boolean):void
		{
			_active = value;
			if(_active){
				windowCheck();
			}
		}
	}
}
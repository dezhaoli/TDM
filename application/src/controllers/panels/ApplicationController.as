package controllers.panels
{
	import com.naruto.debugger.DConstants;
	import com.naruto.debugger.DData;
	import com.naruto.debugger.DTabContext;
	
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	import mx.collections.XMLListCollection;
	import mx.controls.Alert;
	import mx.controls.treeClasses.TreeItemRenderer;
	import mx.core.UITextField;
	import mx.events.FlexEvent;
	import mx.events.ListEvent;
	import mx.events.TreeEvent;
	import mx.utils.StringUtil;
	
	import components.Filter;
	import components.panels.ApplicationPanel;
	
	import events.PanelEvent;


	public final class ApplicationController extends EventDispatcher
	{
		

		[Bindable]
		private var _dataFilterd:XMLListCollection = new XMLListCollection();

		private var _data:XMLListCollection = new XMLListCollection();
		private var _panel:ApplicationPanel;
		private var _send:Function;
		private var _selectedTarget:String;

		private var _contextMenu:ContextMenu;


		/**
		 * Data handler for the panel
		 */
		private var _context:DTabContext;
		public function ApplicationController(panel:ApplicationPanel, context:DTabContext, send:Function)
		{
			_context = context;
			_context.applicationController = this;
			
			_panel = panel;
			_send = send;
			_panel.addEventListener(FlexEvent.CREATION_COMPLETE, creationComplete, false, 0, true);
		}


		public function get panel():ApplicationPanel
		{
			return _panel;
		}

		public function set panel(value:ApplicationPanel):void
		{
			_panel = value;
		}

		/**
		 * Panel is ready to link data providers
		 */
		private function creationComplete(e:FlexEvent):void
		{
			_panel.simpleCheckbox.visible = DData.DEV;
			// Remove eventlistener
			_panel.removeEventListener(FlexEvent.CREATION_COMPLETE, creationComplete);

			// Set tree dataprovider and listeners
			_panel.tree.doubleClickEnabled=true;
			_panel.tree.dataProvider = _dataFilterd;
			_panel.tree.addEventListener(TreeEvent.ITEM_OPEN, treeOpen, false, 0, true);
			_panel.tree.addEventListener(MouseEvent.CLICK, treeClick, false, 0, true);
			_panel.tree.addEventListener(ListEvent.ITEM_DOUBLE_CLICK, treeDoubleClick, false, 0, true);
			_panel.tree.addEventListener(ListEvent.ITEM_ROLL_OVER, onShowInspect, false, 0, true);
			
			_contextMenu = new ContextMenu();     
			_contextMenu.addEventListener(ContextMenuEvent.MENU_SELECT, onMenuSelected);
			_contextMenu.hideBuiltInItems();   
			
			_panel.tree.contextMenu = _contextMenu;
			//_panel.tree.addEventListener(ContextMenuEvent.MENU_SELECT, onMenuSelected);
			_panel.filter.addEventListener(Filter.CHANGED, filterChanged, false, 0, true);
			_panel.simpleCheckbox.addEventListener(MouseEvent.CLICK, onInspectClicked, false, 0, true);
		}
		private function onMenuSelected(e:ContextMenuEvent):void {
			if(e.mouseTarget is TreeItemRenderer){
				var item:TreeItemRenderer = e.mouseTarget as TreeItemRenderer;
			}else if(e.mouseTarget is UITextField){
				item = (e.mouseTarget as UITextField).automationOwner as TreeItemRenderer;
			}
			if(item){
				//_panel.tree.selectedIndex = _panel.tree.itemRendererToIndex( item);
				
				_contextMenu.customItems = new Array;
				var newBuildMenuItem:ContextMenuItem;
				
				
				var type:String = item.data.@type
				if(type == DConstants.TYPE_INT ||
						type == DConstants.TYPE_UINT ||
						type == DConstants.TYPE_NUMBER ||
						type == DConstants.TYPE_STRING){
					newBuildMenuItem = new ContextMenuItem("Copy Value");
					newBuildMenuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,onMenuItemSelect);
					_contextMenu.customItems.push(newBuildMenuItem);  
				}
					
				newBuildMenuItem = new ContextMenuItem("Copy Name");
				newBuildMenuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,onMenuItemSelect);
				_contextMenu.customItems.push(newBuildMenuItem);     
				
				if(type == "StaticText" ||
					type == "TextField"||
					type == DConstants.TYPE_STRING){
					newBuildMenuItem = new ContextMenuItem("Find In Files...");
					newBuildMenuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,onMenuItemSelect);
					_contextMenu.customItems.push(newBuildMenuItem);  
				}
				if (type != DConstants.TYPE_WARNING && 
						type != DConstants.TYPE_STRING &&
						type != DConstants.TYPE_BOOLEAN &&
						type != DConstants.TYPE_NUMBER &&
						type != DConstants.TYPE_INT &&
						type != DConstants.TYPE_UINT &&
						type != DConstants.TYPE_FUNCTION) {
					newBuildMenuItem = new ContextMenuItem("Copy Class Type");
					newBuildMenuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,onMenuItemSelect);
					_contextMenu.customItems.push(newBuildMenuItem);    
					
					newBuildMenuItem = new ContextMenuItem("Inspect");
					newBuildMenuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,onMenuItemSelect);
					_contextMenu.customItems.push(newBuildMenuItem);
				}
				    
			}  
		}    
		public function onMenuItemSelect(e:ContextMenuEvent):void//点击菜单执行函数  
		{  
			if(e.mouseTarget is TreeItemRenderer){
				var item:TreeItemRenderer = e.mouseTarget as TreeItemRenderer;
			}else if(e.mouseTarget is UITextField){
				item = (e.mouseTarget as UITextField).automationOwner as TreeItemRenderer;
			}
			if(!item)
				return;
			
			var name:String = item.data.@name;
			var type:String = item.data.@type;
			var value:String = item.data.@value;
			if(e.currentTarget.caption == "Copy Name"){
				
				name = name.replace("DisplayObject - ","");
				Clipboard.generalClipboard.clear(); 
				Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, name, false); 
			}else if(e.currentTarget.caption == "Copy Value"){
				
				Clipboard.generalClipboard.clear(); 
				Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, value, false); 
			}else if(e.currentTarget.caption == "Copy Class Type"){
				
				Clipboard.generalClipboard.clear(); 
				Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, type, false); 
			}else if(e.currentTarget.caption == "Inspect"){
				var objTarget:String = String(item.data.@target);
				if (type != DConstants.TYPE_WARNING && 
					type != DConstants.TYPE_STRING &&
					type != DConstants.TYPE_BOOLEAN &&
					type != DConstants.TYPE_NUMBER &&
					type != DConstants.TYPE_INT &&
					type != DConstants.TYPE_UINT &&
					type != DConstants.TYPE_FUNCTION) {
					
					_send({command:DConstants.COMMAND_INSPECT, target:objTarget});
				}
			}else if(e.currentTarget.caption == "Find In Files..."){
				if(String(item.data.@type) == "String"){
					value = String(item.data.@value);
				}else{
					var nameNode:XMLList = item.data.node.(@name=="text");
					value = String(nameNode.@value);
				}
				_context.findController.find(value);
				
			}
		}  
		public function treeDoubleClick(event:ListEvent):void
		{
			var objType:String;
			var objTarget:String;
			
			if (event.currentTarget.selectedItem != null) {
				
				// Save the type and target
				objType = event.currentTarget.selectedItem.@type;
				objTarget = event.currentTarget.selectedItem.@target;
				
				// Only get the info from objects
				if (objType != DConstants.TYPE_WARNING && objType != DConstants.TYPE_STRING && objType != DConstants.TYPE_BOOLEAN && objType != DConstants.TYPE_NUMBER && objType != DConstants.TYPE_INT && objType != DConstants.TYPE_UINT && objType != DConstants.TYPE_FUNCTION) {
					
					// Send commands
					_send({command:DConstants.COMMAND_INSPECT, target:objTarget});
				}
			}
		}
		private function onInspectClicked(event:MouseEvent):void
		{
			DData.simpleMode = _panel.simpleCheckbox.selected;
			filterApplication();
		}
		/**
		 * Show a trace in an output window
		 */
		private function filterChanged(event:Event):void
		{
			filterApplication();
		}


		/**
		 * Update the filter on the application tree
		 */
		private function filterApplication():void
		{
			// Vars needed for the loops
			var data:XMLList = _data.copy();
			var targets:XMLList = data..@target;
			var children:XMLList;
			var openOld:Array;
			var openNew:Array;

			// Filter the data
			children = filterChildren(data.node);
			data.setChildren(children);

			// Get the filtered targets
			targets = data..@target;

			// Get the open items
			openOld = _panel.tree.openItems as Array;
			openNew = new Array();
			for (var i:int = 0; i < openOld.length; i++) {
				for (var n:int = 0; n < targets.length(); n++) {
					if (targets[n] == openOld[i].@target) {
						openNew.push(targets[n].parent());
					}
				}
			}

			// Set the data
			_dataFilterd.source = null;
			_dataFilterd.source = data;
			_panel.tree.openItems = openNew;
		}


		/**
		 * Recursive filter child nodes
		 * @param children: The nodes to filter
		 */
		private function filterChildren(children:XMLList):XMLList
		{
			// The return XML
			var xml:XMLList = new XMLList();

			// Variables for the loops
			var temp:*;
			var i:int;
			
			// Loop through the nodes
			for (i = 0; i < children.length(); i++) {
				
				// Add the node if needed
				if (checkFilter(children[i])) {
					if (children[i].children().length() > 0) {
						
						// The node has children
						temp = children[i];
						temp.setChildren(filterChildren(temp.children()));
						
						// The node has just one property
						if (temp.children().length() == 0) {
							temp.setChildren(XML("<node icon='iconWarning' type='Warning' label='No filter results' name='No filter results'/>"));
						}
						xml += temp;
					}
					else
					{
						// The node is just one value
						xml += children[i];
					}
				}
			}

			// Return the xml
			return xml;
		}
		
		
		/**
		 * Loop through the search terms and compare strings
		 */
		private function checkFilter(item:*):Boolean
		{
			// Return if it's a folder
			if (item.children().length() != 0 &&  /^DisplayObject.*/.exec(String(item.@label)) ) {
				return true;
			}
			
			if(!DData.DEV && !DConstants.AttisonApp[String(item.@name)]){
				return false;
			}
			if(DData.simpleMode && !DConstants.AttisonApp[String(item.@name)]){
				return false;
			}
			
			if(DData.hideDisplayProp && DConstants.DisplayObjectProp[String(item.@name)]){
				return false;
			}
		
				
			// Get the data
			var name:String = String(item.@name);
			var value:String = String(item.@value);
			var label:String = String(item.@label);
			var type:String = String(item.@type);
			if (name == null) name = "";
			if (value == null) value = "";
			if (label == null) label = "";
			if (type == null) type = "";
			name = StringUtil.trim(name).toLowerCase();
			value = StringUtil.trim(value).toLowerCase();
			label = StringUtil.trim(label).toLowerCase();
			type = StringUtil.trim(type).toLowerCase();

			var i:int;
			
			// Clone words
			var words:Array = [];
			for (i = 0; i < _panel.filter.words.length; i++) {
				words[i] = _panel.filter.words[i];
			}
			
			if (name != "") {
				for (i = 0; i < words.length; i++) {
					if (name.indexOf(words[i]) != -1) {
						words.splice(i, 1);
						i--;
					}
				}
			}
			if (words.length == 0) return true;
			if (value != "") {
				for (i = 0; i < words.length; i++) {
					if (value.indexOf(words[i]) != -1) {
						words.splice(i, 1);
						i--;
					}
				}
			}
			if (words.length == 0) return true;
			if (label != "") {
				for (i = 0; i < words.length; i++) {
					if (label.indexOf(words[i]) != -1) {
						words.splice(i, 1);
						i--;
					}
				}
			}
			if (words.length == 0) return true;
			return false;
		}
		
		
		private function onShowInspect(e:ListEvent):void
		{
			if (e.rowIndex == _panel.tree.selectedIndex) {
				_selectedTarget = _panel.tree.selectedItem.@target;
			}
		}


		/**
		 * Clear data
		 */
		public function clear():void
		{
			_data.removeAll();
			_dataFilterd.removeAll();
			onRefresh();
		}


		/**
		 * Data handler from open tab
		 */
		public function setData(data:Object):void
		{
			switch (data["command"]) {
				case DConstants.COMMAND_BASE:
					_data.removeAll();
					_data.source = data["xml"].children();
					_dataFilterd.removeAll();
					_dataFilterd.source = data["xml"].children();
					_panel.tree.openItems = data["xml"].children();
					_panel.tree.invalidateList();
					_panel.tree.invalidateProperties();
					_panel.tree.invalidateDisplayList();
					_panel.tree.validateNow();
					
					filterApplication();
					break;
					
				case DConstants.COMMAND_GET_OBJECT:

					// Save scroll
					var treeVPOS:Number = _panel.tree.verticalScrollPosition;
					var treeHPOS:Number = _panel.tree.horizontalScrollPosition;

					// Get all targets in the current xml
					var targets:XMLList = _data.source..@target;

					// Loop through the targets
					for (var i:int = 0; i < targets.length(); i++) {
						if (targets[i] == data["xml"].node.@target) {
							targets[i].parent().setChildren(data["xml"].node.children());
							break;
						}
					}
					
					// Filter the tree
					filterApplication();

					// Set the scroll
					_panel.tree.invalidateList();
					_panel.tree.invalidateProperties();
					_panel.tree.invalidateDisplayList();
					_panel.tree.validateNow();
					_panel.tree.verticalScrollPosition = treeVPOS;
					_panel.tree.horizontalScrollPosition = treeHPOS;
					break;

			}
		}


		/**
		 * Tree item opened
		 */
		public function treeOpen(event:TreeEvent):void
		{
			// Get the object
			if (event.item.@target != null) {
				_send({command:DConstants.COMMAND_GET_OBJECT, target:String(event.item.@target)});
			}
		}

		
		/**
		 * Tree item clicked
		 */
		public function treeClick(event:MouseEvent):void
		{
			var objType:String;
			var objTarget:String;

			if (event.currentTarget.selectedItem != null) {


				// Save the type and target
				objType = event.currentTarget.selectedItem.@type;
				objTarget = event.currentTarget.selectedItem.@target;
				
				if(event.altKey){
					Clipboard.generalClipboard.clear(); 
					Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, objType, false); 
					return;
				}
				// Clear old values
				dispatchEvent(new PanelEvent(PanelEvent.CLEAR_PROPERTIES));
				// Only get the info from objects
				if (objType != DConstants.TYPE_WARNING && objType != DConstants.TYPE_STRING && objType != DConstants.TYPE_BOOLEAN && objType != DConstants.TYPE_NUMBER && objType != DConstants.TYPE_INT && objType != DConstants.TYPE_UINT && objType != DConstants.TYPE_FUNCTION) {

					// Send commands
					_send({command:DConstants.COMMAND_HIGHLIGHT, target:objTarget});
					_send({command:DConstants.COMMAND_GET_PROPERTIES, target:objTarget});
					_send({command:DConstants.COMMAND_GET_FUNCTIONS, target:objTarget});
					_send({command:DConstants.COMMAND_GET_PREVIEW, target:objTarget});
				}
			}
		}


		public function onRefresh(evt:ContextMenuEvent = null):void
		{
			if (_panel.tree.selectedItem != null) {

				// Clear old values
				dispatchEvent(new PanelEvent(PanelEvent.CLEAR_PROPERTIES));

				// Save the type and target
				var objType:String = _panel.tree.selectedItem.@type;
				var objTarget:String = _panel.tree.selectedItem.@target;
				_send({command:DConstants.COMMAND_GET_OBJECT, target:objTarget});

				if (objType != DConstants.TYPE_WARNING && objType != DConstants.TYPE_STRING && objType != DConstants.TYPE_BOOLEAN && objType != DConstants.TYPE_NUMBER && objType != DConstants.TYPE_INT && objType != DConstants.TYPE_UINT && objType != DConstants.TYPE_FUNCTION) {

					// Send commands
					_send({command:DConstants.COMMAND_HIGHLIGHT, target:objTarget});
					_send({command:DConstants.COMMAND_GET_PROPERTIES, target:objTarget});
					_send({command:DConstants.COMMAND_GET_FUNCTIONS, target:objTarget});
					_send({command:DConstants.COMMAND_GET_PREVIEW, target:objTarget});
				}
			} else {
				_send({command:DConstants.COMMAND_BASE});
			}
		}

	}
}
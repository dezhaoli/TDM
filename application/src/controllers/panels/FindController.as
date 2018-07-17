package controllers.panels
{
	import com.naruto.debugger.DConstants;
	import com.naruto.debugger.DData;
	import com.naruto.debugger.DTabContext;
	import com.naruto.debugger.DUtils;
	import com.naruto.debugger.TranslateController;
	
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	import mx.collections.ArrayCollection;
	import mx.core.UITextField;
	import mx.events.FlexEvent;
	import mx.events.ListEvent;
	import mx.utils.StringUtil;
	
	import components.panels.FindPanel;
	import components.windows.SVNBrowser;
	
	import events.PropertyEvent;


	public final class FindController extends EventDispatcher
	{
		public static function toItem(a:Object,b:Object=null,c:Object=null,d:Object=null):Object{
			return toItem2({},a,b,c,d);
		}
		public static function toItem2(obj:Object,a:Object,b:Object=null,c:Object=null,d:Object=null):Object{
			
			obj.a = obj.A = a ? a : "";
			obj.b = obj.B = b ? b : "";
			obj.c = obj.C = c ? c : "";
			obj.d = obj.D = d ? d : "";
			return obj;
		}

		[Bindable]
		private var _dataFilterd:ArrayCollection = new ArrayCollection();
		
		private var _excelData:ArrayCollection = new ArrayCollection();
		private var _asFlaData:ArrayCollection = new ArrayCollection();
		private var _mcData:ArrayCollection = new ArrayCollection();
		private var _panel:FindPanel;
		private var _send:Function;
		private const lineMax:int = 1000;
		private var _contextMenu:ContextMenu;
		private var _context:DTabContext;
		private var _viewType:String = "";
		private var _resoultDatas:Array;

		/**
		 * Save panel
		 */
		public function FindController(panel:FindPanel,context:DTabContext,send:Function)
		{
			_panel = panel;
			_send = send;
			_context = context;
			_context.findController=this;
			_panel.addEventListener(FlexEvent.CREATION_COMPLETE, creationComplete, false, 0, true);
			
			
		}
		
		private function onItemClick(event:ListEvent):void
		{
			// Check if the selected item is still available
			if (event.currentTarget.selectedItem != null) {
				
				var item:Object = _dataFilterd.getItemAt(event.currentTarget.selectedIndex);
				
				setViewByItem(item);
			}
		}
		private function onItemDoubleClick(event:ListEvent):void
		{
			// Check if the selected item is still available
			if (event.currentTarget.selectedItem != null) {
				
				// Get the data
				var item:Object = _dataFilterd.getItemAt(event.currentTarget.selectedIndex);
				
				// Check the window to open
				if (item.picURL) {
					var svnBrowser:SVNBrowser = new SVNBrowser();
					if(item.picURL.indexOf(".png") == -1){
						item.picURL += "__-__.png"
					}
					svnBrowser.setData(item.picURL);
					svnBrowser.open();
				}else if(item.d == "fla_mc_dic.txt"){
					_send({command:DConstants.COMMAND_OPEN_IN_FLASH,isFind:true,fla:item.B,mc:item.A,info:"none:none"});
				}
			}
		}
		private function onMenuSelected(e:ContextMenuEvent):void {
			if(e.mouseTarget is UITextField){
				//_panel.tree.selectedIndex = _panel.tree.itemRendererToIndex( item);
				
				_contextMenu.customItems = new Array;
				var newBuildMenuItem:ContextMenuItem;
				
				
				newBuildMenuItem = new ContextMenuItem("Copy");
				newBuildMenuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,onMenuItemSelect);
				_contextMenu.customItems.push(newBuildMenuItem);     
				
				var tf:UITextField = e.mouseTarget as UITextField;
				if(tf.automationOwner &&
					"data" in tf.automationOwner &&
					tf.automationOwner["data"].picURL){
					
					newBuildMenuItem = new ContextMenuItem("Open Pic");
					newBuildMenuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,onMenuItemSelect);
					_contextMenu.customItems.push(newBuildMenuItem);    
				}else if(tf.automationOwner &&
					"data" in tf.automationOwner &&
					tf.automationOwner["data"].pluginInfo){
					
					newBuildMenuItem = new ContextMenuItem("Remove Plugin");
					newBuildMenuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,onMenuItemSelect);
					_contextMenu.customItems.push(newBuildMenuItem);    
					
					newBuildMenuItem = new ContextMenuItem("Set as Default Remove Plugin");
					newBuildMenuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,onMenuItemSelect);
					_contextMenu.customItems.push(newBuildMenuItem);    
				}
			}  
		}    
		public function onMenuItemSelect(e:ContextMenuEvent):void//点击菜单执行函数  
		{  
			var data:Object;
			if(! e.mouseTarget is UITextField){
				return;
			}
			if(e.currentTarget.caption == "Copy"){
				var text:String = (e.mouseTarget as UITextField).text;
				Clipboard.generalClipboard.clear(); 
				Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, text, false); 
			}else if(e.currentTarget.caption == "Open Pic"){
				data = Object(e.mouseTarget).automationOwner.data;
				var picURL:String = data.picURL;
				var picWindow:SVNBrowser = new SVNBrowser();
				picWindow.setData(picURL);
				picWindow.open();
			}else if(e.currentTarget.caption == "Remove Plugin"){
				data = Object(e.mouseTarget).automationOwner.data;
				_context.toolsController.rmPlugin(data.a);
			}else if(e.currentTarget.caption == "Set as Default Remove Plugin"){
				data = Object(e.mouseTarget).automationOwner.data;
				_context.toolsController.setDefPluginName(data.A);
			}
		}  

		/**
		 * Panel is ready to link data providers
		 */
		private function creationComplete(e:FlexEvent):void
		{
			_panel.removeEventListener(FlexEvent.CREATION_COMPLETE, creationComplete);
			
			_contextMenu = new ContextMenu();     
			_contextMenu.addEventListener(ContextMenuEvent.MENU_SELECT, onMenuSelected);
			_contextMenu.hideBuiltInItems();   
			
			_panel.datagrid.contextMenu = _contextMenu;
			_panel.datagrid.addEventListener(ListEvent.ITEM_DOUBLE_CLICK, onItemDoubleClick, false, 0, true);
			_panel.datagrid.addEventListener(ListEvent.ITEM_CLICK, onItemClick, false, 0, true);
			_panel.datagrid.addEventListener(PropertyEvent.CHANGE_PROPERTY, changeProperty, false, 0, true);
			_panel.datagrid.dataProvider = _dataFilterd;
			_panel.findButton.addEventListener(MouseEvent.CLICK, clearAndFind, false, 0, true);
			_panel.filterButton.addEventListener(MouseEvent.CLICK, clearAndFind, false, 0, true);
			_panel.filter.addEventListener("enter",clearAndFind,false,0,true);
			
			//_panel.advancedCB.addEventListener(Event.CHANGE,onAdvancedChange);
			_panel.advancedCB.addEventListener(MouseEvent.CLICK,onAdvancedChange);
			_panel.advancedCB.selected = false;
			onAdvancedChange();
			
			if(DData.DEV){
				_panel.findTypeDDL.visible = _panel.findTypeDDL.includeInLayout = true;
			}else{
				_panel.findTypeDDL.visible = _panel.findTypeDDL.includeInLayout = false;
			}
			_panel.findTypeDDL.selectedIndex = 0;
			_panel.filterButton.visible = false;
			setPreview(false);
		}
		private function changeProperty(event:PropertyEvent):void
		{
			if(_viewType == DConstants.FVT_setting){
				var data:Object = event.data;
				_context.plData[data.A] = String(data.B).replace(/\\/g,"/");
				
				DUtils.saveSettingValue(_context.plData.LOCAL_FLA_PIC_SVN, {
					client_path:_context.plData.client_path,
					designer_path:_context.plData.designer_path
					});
				
			}
		}
		public function setViewByItem(item:Object):void{
			if (item && item.picURL) {
				if(item.picURL.indexOf(".png") == -1){
					item.picURL += "__-__.png"
				}
				_panel.picImage.source = item.picURL;
				return;
			}
		}
		private function setPreview(isShow:Boolean):void{
			if(_panel.previewBox.visible == isShow) return;
			if(isShow){
				_panel.previewBox.visible = true;
				_panel.previewBox.includeInLayout = true;
			}else{
				_panel.previewBox.visible = false;
				_panel.previewBox.includeInLayout = false;
				
			}
		}
		private function onAdvancedChange(e:Event=null):void{
			if(e){
				_panel.advancedCB.selected = !_panel.advancedCB.selected;
			}
			if(_panel.advancedCB.selected){
				_panel.advancedCB.label = "<<";
				_panel.caseCB.visible=true;
				_panel.WholeCB.visible=true;
				_panel.HighlightCB.visible=true;
				
				_panel.caseCB.includeInLayout=true;
				_panel.WholeCB.includeInLayout=true;
				_panel.HighlightCB.includeInLayout=true;
			}else{
				_panel.advancedCB.label = ">>";
				_panel.caseCB.visible=false;
				_panel.WholeCB.visible=false;
				_panel.HighlightCB.visible=false;
				
				_panel.caseCB.includeInLayout=false;
				_panel.WholeCB.includeInLayout=false;
				_panel.HighlightCB.includeInLayout=false;
			}
		}
		/**
		 * 提供给applicationController 查找文字的
		 */
		public function find(value:String):void{
			_panel.filter.text = StringUtil.trim(value);
			clearAndFind();
		}
		
		public function showDatas(arr:Array):void{
			if(!arr.isFilter)
				_resoultDatas = arr;
			_panel.filterButton.visible = (_resoultDatas && _resoultDatas.length > 0);
			_panel.datagrid.horizontalScrollPosition = 0;
			try{
				_dataFilterd.removeAll();
			}catch(e:Error){
				_context.log(e.message);
			}
			for (var i:int=0 ;i<arr.length;i++){
				_dataFilterd.addItem(arr[i]);
			}
			if(arr && arr.length>0){
				setViewByItem(arr[0]);
			}
			
			updateHeader(arr.type);
		}
		/**
		 * type: pic,plugin,key(default)
		 */
		public function updateHeader(type:String=null):void{
			if(type && type != _viewType){
				_viewType = type;
				var header:Object;
				
				setPreview(_viewType == DConstants.FVT_pic);
				
				_panel.datagrid.editable = false;
				_panel.clnB.editable = false;
				
				if(_viewType == DConstants.FVT_setting){
					header = {A:"name",B:"value",d:false,c:false};
					_panel.filter.text = "";
					_panel.datagrid.editable = true;
					_panel.clnB.editable = true;
				}else if(_viewType == DConstants.FVT_pic){
					header = {A:"path",D:"source",b:false,c:false};
					_panel.filter.text = "";
				}else if(_viewType == DConstants.FVT_plugin){
					header = {A:"interface name",B:"is CurDomain",C:"plugin loaded",d:false};
					_panel.filter.text = "";
				}else if(_viewType == DConstants.FVT_mc){
					header = {A:"library name",B:"path",C:"class name",D:"source"};
				}else{//_viewType == "key"
					header = {A:"en",B:"cn",C:"key",D:"source"};
				}

				var clns:Array = ["A","B","C","D"];
				for each(var X:String in clns){
					if(header[X]){
						_panel["cln"+ X].headerText = header[X];
					}
					var x:String = X.toLowerCase();
					
					_panel["cln"+ X].visible = header[x] !== false;
				}
			}
		}
		
		/**
		 * press enter or find...
		 */
		public function clearAndFind(event:Event = null):void
		{
			var lineIndex:int = 1;
			var item:Object;
			var filterData:Array = [];
			
			
			//filter result only
			if(event && event.currentTarget == _panel.filterButton){
				filterData.isFilter = true;
				if(_resoultDatas)
				for (var i:int=0 ;i<_resoultDatas.length;i++){
					item = _resoultDatas[i];
					if(filterItem(item)){
						item.line = lineIndex++;
						filterData.push(item);
					}
				}
				showDatas(filterData);
				return;
			}
				
				
			try{
				_dataFilterd.removeAll();
			}catch(e:Error){
				_context.log(e.message);
			}
			
			
			//search setting..
			if(_panel.findTypeDDL.selectedItem == "setting"){
				filterData = _context.plData.toItems();
				filterData.type = DConstants.FVT_setting;
				
				showDatas(filterData);
				return;
			}
			//search fla mc..
			if(_panel.findTypeDDL.selectedItem == "mc"){
				filterData.type = DConstants.FVT_mc;
				for each(item in _mcData){
					if(filterItem(item)){
						item.line = lineIndex++;
						item.d = "fla_mc_dic.txt";
						
						filterData.push(item);
						if(lineIndex > lineMax) break;
					}
				}
				showDatas(filterData);
				return;
			}
			//search plugin infos..
			if(_panel.findTypeDDL.selectedItem == "plugin"){
				filterData.type = DConstants.FVT_plugin;
				_send({command:DConstants.COMMAND_RELOAD_CALL,fn_name:"init",data:""});
				return;
			}
			
			//empty search key, only search AS FLA key for illegal format text
			if(_panel.filter.words.length ==0){
				
				if(true){
					filterData.type = DConstants.FVT_key;
					for each(item in _asFlaData){
						if( TranslateController.H(item.A) == "" ){
							item.line = lineIndex++;
							item.a= escape(item.A);
							item.b= escape(item.B);
							if(String(item.id).substring(0,3) == "as_"){
								item.d = "AS";
							}else{
								item.d = "FLA";
							}
							
							filterData.push(item);
							if(lineIndex > lineMax) break;
						}
					}
				}
				showDatas(filterData);
				return;
			}
			
			
			//search AS FLA key and Excel key
			filterData.type = DConstants.FVT_key;
			for each(item in _excelData){
				if(filterItem(item)){
					item.line = lineIndex++;
					item.d = item.excel;
					filterData.push(item);
					if(lineIndex > lineMax) break;
				}
			}
			
			for each(item in _asFlaData){
				if(filterItem(item)){
					item.line = lineIndex++;
					if(String(item.id).substring(0,3) == "as_"){
						item.d = "AS";
					}else{
						item.d = "FLA";
					}
					
					filterData.push(item);
					if(lineIndex > lineMax) break;
				}
			}
			showDatas(filterData);
		}
		
		private const aa:Array = ["a","b","c"];
		private const AA:Array = ["A","B","C"];
		public function filterItem(item:Object):Boolean{
			var res:Boolean;
			var j:int;
			var findstr:String = _panel.filter.text;
			var matchCase:Boolean = _panel.caseCB.selected;
			var wholeWord:Boolean = _panel.WholeCB.selected;
			
			for (var i:int=0;i<aa.length;i++){
				var aaa:String = aa[i];
				var AAA:String = AA[i];
				var A:String = item[AAA]?item[AAA]:"";
				if(!matchCase){
					A = A.toLocaleLowerCase();
					findstr = findstr.toLocaleLowerCase();
				}
				if (A != "") {
					item[aaa] = escape(A);
					if(wholeWord){
						if(A == findstr){
							hightlight(item,aaa,A,0,A);
							res = true;
						}
					}else if ((j = A.indexOf(findstr)) != -1) {
						hightlight(item,aaa,A,j,findstr);
						res = true;
					}
				}
			}
			
			return res;
		}
		
		private function hightlight(item:Object,prop:String,cn:String,i:int,findstr:String):void{
			if(_panel.HighlightCB.selected){
				item[prop] = escape(cn.substring(0,i))+"<FONT COLOR='#ee0000'><B>"+escape(findstr)+"</B></FONT>" + escape(cn.substring(i+findstr.length));
			}else{
				item[prop] = escape(cn);
			}
		}
		private function escape(val:String):String{
			return val.replace(/</g,"&lt;").replace(/>/g,"&gt;");
		}

		public function addDatas(kvExcelMap:Object,kvAsFlaMap:Object,mcMap:Object):void{
			
			if(kvExcelMap)
			for each(var obj:Object in kvExcelMap) {
				// Add to list
				
				_excelData.addItem(obj);
			}
			if(kvAsFlaMap)
			for each(obj in kvAsFlaMap) {
				// Add to list
				_asFlaData.addItem(obj);
			}
			
			if(mcMap)
			for each(obj in mcMap) {
				// Add to list
				_mcData.addItem(obj);
			}
		}
		/**
		 * Data handler from client
		 */
		public function setData(data:Object):void
		{
			switch (data["command"]) {
				case DConstants.COMMAND_RELOAD_CALL:
					if(data.fn_name == "init"){
						var arr:Array = [];
						arr.type = DConstants.FVT_plugin;
						var pis:Array = data.pis;
						for(var i:int=0;i<pis.length;i++){
							var obj:Object= toItem(pis[i].name,pis[i].isCurDomain,pis[i].hasPlugin);
							obj.line = arr.length+1;
							obj.pluginInfo = true;
							arr.push(obj);
						}
						showDatas(arr);
					}
					break;
			}
		}
		/**
		 * Clear data
		 */
		public function clear():void
		{
			
		}
	}
}

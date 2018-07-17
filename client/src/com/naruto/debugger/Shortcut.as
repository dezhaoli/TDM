package com.naruto.debugger 
{
	import flash.display.Stage;
	import flash.events.ContextMenuEvent;
	import flash.events.KeyboardEvent;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.ui.Keyboard;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	/**
	 * ...
	 * @author Devin Lee
	 */
	public class Shortcut 
	{
		static private var _plugins:Array=[];
		static private var contextMenu:ContextMenu;
		static public function pushPluginName(n:String):void {
			if (n == "sound.INarutoSound" 
			|| n == "player.IPlayerPlugin"
			|| n == "server.INarutoServer"
			|| n == "RSModel.IRSModelPlugin"
			|| n == "world.IWorldPlugin"
			) return;
			
			if(_plugins.indexOf(n) == -1)
				_plugins.unshift(n);
			while (_plugins.length > 2) {
				_plugins.pop();
			}
		}
		public function Shortcut() 
		{
			
		}
		static public function start():void {
			DCore.base.addEventListener(KeyboardEvent.KEY_DOWN,down);	
			DCore.base.addEventListener(KeyboardEvent.KEY_UP, up);	
			
			contextMenu = new ContextMenu();
			contextMenu.hideBuiltInItems();
			contextMenu.addEventListener(ContextMenuEvent.MENU_SELECT, onMenuSelected);
			try {
				for (var i:int = 0; i < DCore.base.numChildren; i++) 
				{
					var s:Object = DCore.base.getChildAt(i);
					var nn:String = getQualifiedClassName(s);
					s.contextMenu = contextMenu;
				}
				
			}catch (e:Error) {
				trace("DCore.base.getChildAt(0) == null");
			}
		}
		static private function onMenuSelected(e:ContextMenuEvent):void {
			contextMenu.customItems = new Array;
			for (var i:int = 0; i < _plugins.length; i++) {
				var item:ContextMenuItem = new ContextMenuItem("#" + _plugins[i])
				contextMenu.customItems.push(item);
				item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onMenuItemSelect);
			}
		}
		static private function onMenuItemSelect(e:ContextMenuEvent):void 
		{
			if (e.currentTarget.caption.indexOf("#") == 0) {
				var n:String = String(e.currentTarget.caption).substring(1);
				ExCore.setDefCallReload(n);
			}
		}
		static public function stop():void {
			DCore.base.removeEventListener(KeyboardEvent.KEY_DOWN,down);
			DCore.base.removeEventListener(KeyboardEvent.KEY_UP,up);	
		}
		static private function up(e:KeyboardEvent):void 
		{
			DUtils.ctrlKeyPress = e.ctrlKey;
			trace("DUtils.ctrlKeyPress", DUtils.ctrlKeyPress);
		}
		static private function down(e:KeyboardEvent):void 
		{
			DUtils.ctrlKeyPress = e.ctrlKey;
			trace("DUtils.ctrlKeyPress", DUtils.ctrlKeyPress);
			if (e.keyCode == Keyboard.F) {
				if(e.ctrlKey && e.shiftKey)
					DCore.tapHighlight(true);
				else if(e.shiftKey)
					DCore.tapHighlight();
			}else if (e.keyCode == 192) {
				DCore.tapHighlight(true);
			}else if (e.keyCode == Keyboard.O) {
				if( e.shiftKey)
					DCore.openflamc();
			}else if (e.keyCode == Keyboard.P) {
				if( e.shiftKey)
					DCore.tapPause();
			}else if (e.keyCode == Keyboard.F3) {
				DCore.openflamc();
			}else if (e.keyCode == Keyboard.F4) {
				DCore.openAsFile({extra:"as"});
			}else if (e.keyCode == Keyboard.F5) {
				DCore.tapPause();
			}else if (e.keyCode == Keyboard.F6) {
				ExCore.breakTips();
			}else if (e.keyCode == Keyboard.F7) {
				ExCore.myCallReload();
			}
		}
		
	}

}
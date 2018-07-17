package com.naruto.debugger 
{
	import avmplus.getQualifiedClassName;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.system.System;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author Devin Lee
	 */
	public class ExCore 
	{
		static public function init():void {
			
			Hy.Facade.getInstance().getCommandManager().addEventListener("commandExecute", onCommandExecute);
			addToMap("com.tencent.morefun.naruto.plugin.operatingActivity.core::SwitchActivityCommand", onOP);
		}
		
		static private function onCommandExecute(e:Event):void 
		{
			var command:Object = Object(e).command;
			Shortcut.pushPluginName(command.getPluginName());
			var key:String = getQualifiedClassName(command);
			if (key in _cmdMap) {
				var fn:Function = _cmdMap[key];
				if (fn.length == 1) {
					fn(command);
				}
				else if (fn.length == 0) {
					fn();
				}
				else {
				}
			}
		}
		static private var _cmdMap:Dictionary = new Dictionary;
		static private var _tipSpr:Sprite = new Sprite;
		static private var _tipSpr2:Sprite = new Sprite;
		static private var newTip:Object;
		static public function addToMap(Cmd_Class:String,handler:Function):void 
		{
			_cmdMap[Cmd_Class] = handler;
		}
		public static function handleInternal(item:DData):void
		{
			// Vars for loop
			var obj:*;
			var xml:XML;
			var method:Function;
			
			// Do the actions
			switch(item.data["command"])
			{
				case DConstants.COMMAND_GM_CALL:
					callGM(item.data.fn_name, item.data.data);
				break;
				case DConstants.COMMAND_RELOAD_CALL:
					callReload(item.data.fn_name, item.data.data);
				break;
			}
		}
		
		public static var _pisDic:Dictionary = new Dictionary;
		static private function callReload(fn_name:String, data:Object):void 
		{
			try{
				switch(fn_name) {
					case "init":
						var pis:Object = Hy.Facade.getInstance().pluginManager.getTotalPluginInfo();
						var pluginInfos:Array = [];
						for (var j:int = 0; j < pis.length; j++) 
						{
							var interfaceName:String = pis[j].interfaceName;
							var pi:Object = _pisDic[interfaceName];
							if (!pi) {
								_pisDic[interfaceName] = pi = { };
								pi.name = interfaceName;
								pi.isCurDomain = pis[j].isCurDomain;
							}
							pi.hasPlugin = Hy.Facade.getInstance().hasPlugin(pi.name);
							
							pluginInfos.push(pi);
						}
						
						DCore.exCoreSend( { command:DConstants.COMMAND_RELOAD_CALL, fn_name:"init",pis:pluginInfos} );
						break;
					case "rm":
						var names:Array = data as Array;
						for (j = 0; j < names.length; j++) 
						{
							removePlugin(names[j]);
						}
						
				}
				Hy.GameTip.show("callReload: " + fn_name + " [" + data +  "] Success!");
			}catch (e:Error) {
				Hy.GameTip.show("callReload:" + fn_name + " fail:[" + e.message + "]");
			}
			
					
		}
		internal static function myCallReload():void {
			DCore.exCoreSend( { command:DConstants.COMMAND_RELOAD_CALL, fn_name:"fromClient"} );
		}
		internal static function setDefCallReload(n:String):void {
			DCore.exCoreSend( { command:DConstants.COMMAND_RELOAD_CALL, fn_name:"setDef",name:n} );
		}
		internal static function breakTips():void {
			
			if (newTip) {
				Hy.LayerManager.singleton.removeItemToLayer(newTip);
				newTip = null;
				_tipSpr2.parent.removeChild(_tipSpr2);
			}else if(Hy.TipsManager.singleton.getShowingTipsView()){
				newTip = Hy.TipsManager.singleton.getShowingTipsView();
				//newTip.x = newTip.y = 0;
				
				
				try {
					Hy.TipsManager.singleton.releaseTips();//这个是新加方法，不一定所有线都有
				}catch (e:Error) {
					//没有就尝试模拟
					Hy.TipsManager.singleton.binding(_tipSpr, null, null);
					_tipSpr.dispatchEvent(new MouseEvent(MouseEvent.ROLL_OVER));
					var objects:Array = DCore._stage.getObjectsUnderPoint(new Point(DCore._stage.mouseX, DCore._stage.mouseY));
					
					while (objects.length > 0) {
						var curTip:DisplayObject = objects.pop();	
						while(curTip){
							Hy.TipsManager.singleton.unbinding(curTip);
							curTip = curTip.parent;
						}
					}
				}
				
				_tipSpr2.graphics.clear();
				_tipSpr2.graphics.beginFill(0x000080, 0.2);
				_tipSpr2.graphics.drawRect(0, 0, DCore._stage.width, DCore._stage.height);
				Hy.LayerManager.singleton.addItemToLayer(_tipSpr2, "TextBox");
			}
		}
		static private function callGM(fn_name:String, data:Object):void 
		{
			var i:int;
			var datas:Dictionary;
			switch(fn_name) {
				case "init":
					var baseURL:String = Hy.ApplicationData.singleton.baseURL;
					if(TranslationDebugger.PL){
						var PL:String = TranslationDebugger.PL;
					}else{
						if (/([^a-zA-Z]|^)en([^a-zA-Z]|$)/.test(baseURL)) {
							PL = "en2";
						}else if (/([^a-zA-Z]|^)de([^a-zA-Z]|$)/.test(baseURL)) {
							PL = "de";
						}else if (/([^a-zA-Z]|^)fr([^a-zA-Z]|$)/.test(baseURL)) {
							PL = "fr2";
						}else if (/([^a-zA-Z]|^)pt([^a-zA-Z]|$)/.test(baseURL)) {
							PL = "pt";
						}else if (/([^a-zA-Z]|^)kr([^a-zA-Z]|$)/.test(baseURL)) {
							PL = "kr";
						}else if (/([^a-zA-Z]|^)pl([^a-zA-Z]|$)/.test(baseURL)) {
							PL = "pl";
						}else if (/([^a-zA-Z]|^)sp([^a-zA-Z]|$)/.test(baseURL)) {
							PL = "sp";
						}else if (/([^a-zA-Z]|^)tw([^a-zA-Z]|$)/.test(baseURL)) {
							PL = "tw";
						}else if (/([^a-zA-Z]|^)ru([^a-zA-Z]|$)/.test(baseURL)) {
							PL = "ru";
						}else if (/([^a-zA-Z]|^)th([^a-zA-Z]|$)/.test(baseURL)) {
							PL = "th";
						}
					}
					DCore.exCoreSend( { command:DConstants.COMMAND_GM_CALL, fn_name:"init",
																			uin:Hy.ApplicationData.singleton.selfuin.toString(),
																			role_id:Hy.ApplicationData.singleton.selfRole.toString(),
																			svr_id:Hy.ApplicationData.singleton.ser_id,
																			PL:PL} );
					break
				case "所有普通物品":
					datas = Hy.CFGDataLibs.getAllData(Hy.CFGDataEnum.ENUM_CommonItemCFG);
					DCore.exCoreSend( { command:DConstants.COMMAND_GM_CALL, fn_name:"所有普通物品",datas:datas} );
					break;
				case "所有碎片":
					datas = Hy.CFGDataLibs.getAllData(Hy.CFGDataEnum.ENUM_CardItemCFG);
					DCore.exCoreSend( { command:DConstants.COMMAND_GM_CALL, fn_name:"所有碎片",datas:datas} );
					break;
				case "添加所有忍者":
					datas = Hy.CFGDataLibs.getAllData(Hy.CFGDataEnum.ENUM_CardItemCFG);
					DCore.exCoreSend( { command:DConstants.COMMAND_GM_CALL, fn_name:"添加所有忍者",level:Hy.ApplicationData.singleton.selfInfo.level} );
					break;
				case "加一级经验":
					var level:Object = Hy.NinjaInfoConfig.getSelfNinjaLevelInfo();
					DCore.exCoreSend( { command:DConstants.COMMAND_GM_CALL, fn_name:"加一级经验",ex:level.upgradeExp} );
					break;
					
			}
		}
		static private function removePlugin(pluginName:String):void
		{
			var pluginInfo:Object = Hy.Facade.getInstance().pluginManager.getPluginInfo(pluginName);
			var links:XMLList = pluginInfo.info..link;
			for each(var linkCfg:XML in links) {
				var url:String = String(linkCfg.@url);
				Hy.MultiThreadLoader.kill(url);
			}
			
			var commands:XMLList = pluginInfo.info..command;
			for each(var cmdCfg:XML in commands) {
				cmdCfg.@ready = "false";
			}
			
			Hy.Facade.getInstance().removePlugin(pluginName);
			
			var logic:XML = pluginInfo.info.logic.link[0];
			logic.@curDomain = 'false';
			//pluginInfo.domain = new ApplicationDomain(ApplicationDomain.currentDomain);
			System.gc();
				
			//return true;
		}
		static private function onOP(cmd:Object):void 
		{
			if ( "activityInfo" in cmd) {
				DCore.exCoreSend( { command:DConstants.COMMAND_REPORT_OP_ID, id:cmd.activityInfo.id } );
			}else {
				DCore.exCoreSend( { command:DConstants.COMMAND_REPORT_OP_ID, id:cmd.activityID } );
			}
			
		}
		
	}

}
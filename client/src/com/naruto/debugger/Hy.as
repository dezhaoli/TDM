package com.naruto.debugger 
{
	import avmplus.getQualifiedClassName;
	import com.naruto.debugger.TranslationDebugger;
	import flash.events.Event;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	/**
	 * ...
	 * @author Devin Lee
	 */
	public class Hy
	{
		static private var cache:Dictionary = new Dictionary(true);
		static public function getDifinition(name:String):Class {
			if (!cache[name]) {
				try{
					cache[name] = getDefinitionByName(name);
				}catch (e:Error) { 
					trace(e.message)
					return null;
				}
			}
			return cache[name] as Class;
		}
		
		static public function get ApplicationData():Object {
			return getDifinition("base.ApplicationData")
		}
		
		static public function get FileAssetManager():Object {
			return getDifinition("file.FileAssetManager")
		}
		static public function get KeyboardManager():Object {
			return getDifinition("com.tencent.morefun.naruto.util.KeyboardManager");
		}
		static public function get Facade():Object {
			return getDifinition("com.tencent.morefun.framework.apf.core.facade.Facade");
		}
		static public function get MultiThreadLoader():Object {
			return getDifinition("com.tencent.morefun.framework.net.MultiThreadLoader");
		}
		static public function get LayoutManager():Object {
			return getDifinition("com.tencent.morefun.naruto.plugin.ui.layer.LayoutManager");
		}
		static public function get I18nC():Object {
			return getDifinition("I18n");
		}
		static public function get Image():Class {
			return getDifinition("com.tencent.morefun.naruto.plugin.exui.base.Image");
		}
		
		static public function get MovieClipButton():Class {
			return getDifinition("com.tencent.morefun.naruto.plugin.ui.components.buttons.MovieClipButton");
		}
		static public function get BaseBox():Class {
			return getDifinition("com.tencent.morefun.naruto.plugin.ui.box.BaseBox");
		}
		static public function get CFGDataEnum():Object {
			return getDifinition("cfgData.CFGDataEnum");
		}
		static public function get CFGDataLibs():Object {
			return getDifinition("cfgData.CFGDataLibs");
		}
		static public function get GameTip():Object {
			return getDifinition("com.tencent.morefun.naruto.util.GameTip");
		}
		static public function get NinjaInfoConfig():Object {
			return getDifinition("user.data.NinjaInfoConfig");
		}
		
		static public function get TipsManager():Object {
			return getDifinition("com.tencent.morefun.naruto.plugin.ui.tips.TipsManager")
		}
		static public function get LayerManager():Object {
			return getDifinition("com.tencent.morefun.naruto.plugin.ui.layer.LayerManager")
		}
		//***************************************************************************
		static public function getHyTitle(fileTitle:String):String {
			try {
				ApplicationData.singleton.ser_id;
				ApplicationData.singleton.selfuin;
				fileTitle = fileTitle + "_dev" + ApplicationData.singleton.ser_id + "_" + ApplicationData.singleton.selfuin;
			}catch (e:Error) { }
			return fileTitle;
		}
		static public function getHyDebugCFG():Array {
			return [FileAssetManager.getQualifiedUrl("config/i18n/KvDebugCFG.cfg") 
			,FileAssetManager.getQualifiedUrl("config/i18n/KvDesignxlsDebugCFG.bin")
			,FileAssetManager.getQualifiedUrl("config/i18n/fla_kv_dic.txt")
			,FileAssetManager.getQualifiedUrl("config/i18n/fla_pic_dic.txt")
			,FileAssetManager.getQualifiedUrl("config/i18n/fla_mc_dic.txt")
			,FileAssetManager.getQualifiedUrl("config/i18n/evn.txt")];
		}
		
		static public function init():void 
		{
			if(I18nC){
				I18nC._debug_recordAS = TranslationDebugger.recordAS;
				I18nC._debug_recordRepAS = TranslationDebugger.recordRepAS;
				I18nC._debugMode = TranslationDebugger.debugMode;
				I18nC._breakpoint = TranslationDebugger.breakpoint;
				I18nC._recordSocketStr = TranslationDebugger.recordSocketStr;
				
			}
		}
		
	}

}
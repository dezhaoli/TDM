package com.naruto.debugger
{
	import com.naruto.debugger.gm.PlatformData;
	import com.naruto.debugger.helper.LoadDataHelper;
	
	import controllers.panels.ApplicationController;
	import controllers.panels.FindController;
	import controllers.panels.GMController;
	import controllers.panels.ToolsController;
	import controllers.panels.TraceController;
	import controllers.tabs.TabController;

	public class DTabContext
	{
		public var tabController:TabController;
		public var plData:PlatformData = new PlatformData;
		public var toolsController:ToolsController;
		public var translateController:TranslateController;
		public var findController:FindController;
		public var loadDataHelper:LoadDataHelper;
		public var gmController:GMController;
		public var traceController:TraceController;
		public var applicationController:ApplicationController;
		
		public function DTabContext()
		{
		}
		public function log(message:String):void{
			if(traceController){
				traceController.addTrace(message);
			}else{
				trace(message);
			}
		}
	}
}
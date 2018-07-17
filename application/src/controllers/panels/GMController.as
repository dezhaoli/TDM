package controllers.panels
{
	import com.naruto.debugger.DConstants;
	import com.naruto.debugger.DTabContext;
	import com.naruto.debugger.gm.HouyingSeverTool;
	import com.naruto.debugger.gm.HouyingSeverTool_Biao;
	import com.naruto.debugger.gm.HyData;
	
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.ui.ContextMenu;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.events.FlexEvent;
	
	import spark.events.IndexChangeEvent;
	
	import components.panels.GMPanel;
	
	import skins.DropdownMenu;


	public final class GMController extends EventDispatcher
	{

		private var _panel:GMPanel;
		private var _send:Function;
		private var _contextMenu:ContextMenu;

		private var svr_cmdDP:ArrayCollection;

		private var timezoneDP:ArrayCollection;
		private var _hyTool:HouyingSeverTool;

		private var _hyData:HyData;
		static private const timezoneDic:Object={en2:[{label:"美西",data:"pst"},{label:"美东",data:"es"}] ,
												de:[{label:"德语",data:"de"}],
												pt:[{label:"葡语",data:"pt"}],
												tw:[{label:"北京",data:"bj"}],
												kr:[{label:"韩语",data:"kst"}],
												sp:[{label:"拉美",data:"lm"},{label:"欧洲",data:"ep"}] ,
												sp3:[{label:"拉美",data:"lm"},{label:"欧洲",data:"ep"}] ,
												ru:[{label:"俄罗斯",data:"Europe/Moscow"}],
												pl:[{label:"波兰",data:"cest"}],
												th:[{label:"泰语",data:"Asia/Bangkok"}],
												fr2:[{label:"法语",data:"fr"}]};

		/**
		 * 
		 */
		private var _context:DTabContext;
		public function GMController(panel:GMPanel, context:DTabContext, send:Function)
		{
			_context = context;
			_context.gmController = this;
			_panel = panel;
			_send = send;
			_panel.addEventListener(FlexEvent.CREATION_COMPLETE, creationComplete, false, 0, true);
			_panel.enabled = false
			
		}
		/**
		 * Panel is ready to link data providers
		 */
		private function creationComplete(e:FlexEvent):void
		{
			_panel.tabBar.addEventListener(IndexChangeEvent.CHANGE,onTabChange);
			_panel.removeEventListener(FlexEvent.CREATION_COMPLETE, creationComplete);
			
			_panel.getActivityBt.addEventListener(MouseEvent.CLICK,onGetActBt);
			_panel.setActivityBt.addEventListener(MouseEvent.CLICK,onSetActBt);
			
			_panel.resetBt.addEventListener(MouseEvent.CLICK,onGMBt);
			_panel.roleExBt.addEventListener(MouseEvent.CLICK,onGMBt);
			_panel.oneLvExBt.addEventListener(MouseEvent.CLICK,onGMBt);
			_panel.ninjaExBt.addEventListener(MouseEvent.CLICK,onGMBt);
			
			_panel.ybBt.addEventListener(MouseEvent.CLICK,onGMBt);
			_panel.dqBt.addEventListener(MouseEvent.CLICK,onGMBt);
			_panel.tbBt.addEventListener(MouseEvent.CLICK,onGMBt);
			
			_panel.testWeapenBt.addEventListener(MouseEvent.CLICK,onGMBt);
			_panel.weapenBt.addEventListener(MouseEvent.CLICK,onGMBt);
			_panel.gyBt.addEventListener(MouseEvent.CLICK,onGMBt);
			_panel.fwBt.addEventListener(MouseEvent.CLICK,onGMBt);
			_panel.zpBt.addEventListener(MouseEvent.CLICK,onGMBt);
			_panel.zfBt.addEventListener(MouseEvent.CLICK,onGMBt);
			_panel.rjBt.addEventListener(MouseEvent.CLICK,onGMBt);
			
			_panel.jsBt.addEventListener(MouseEvent.CLICK,onGMBt);
			_panel.tlBt.addEventListener(MouseEvent.CLICK,onGMBt);
			_panel.ckBt.addEventListener(MouseEvent.CLICK,onGMBt);
			_panel.zhBt.addEventListener(MouseEvent.CLICK,onGMBt);
			_panel.njBt.addEventListener(MouseEvent.CLICK,onGMBt);
			_panel.spBt.addEventListener(MouseEvent.CLICK,onGMBt);
			_panel.ptBt.addEventListener(MouseEvent.CLICK,onGMBt);
			
			svr_cmdDP = new ArrayCollection([
				{label:"大区服务器",data:"00032103"},
				{label:"活动服务器",data:"00100001"},
				{label:"公会服务器",data:"000D0000"}]);
			_panel.svr_cmdDDL.dataProvider = svr_cmdDP;
			_panel.svr_cmdDDL.selectedIndex = 0;
			_panel.svr_cmdDDL.setStyle("skinClass", skins.DropdownMenu);
			
			_panel.timezoneDDL.selectedIndex = 0;
			_panel.timezoneDDL.setStyle("skinClass", skins.DropdownMenu);
			
			_panel.getTimeBt.addEventListener(MouseEvent.CLICK,onGetGMTime);
			_panel.setTimeBt.addEventListener(MouseEvent.CLICK,onSetGMTime);
			
			_panel.itemList.addFunc = addItem;
			
			
			_panel.tabBar.selectedIndex = 0;
			switchView(false);
			
			_send({command:DConstants.COMMAND_GM_CALL, fn_name:"init",data:""});
			
		}
		
		protected function onTabChange(event:IndexChangeEvent):void
		{
			switchView(false);
		}
		private function onGetGMTime(e:MouseEvent):void
		{
			if(_panel.timezoneDDL.selectedIndex == -1){
				
				return;
			}
			var svr_cmd:String = svr_cmdDP[_panel.svr_cmdDDL.selectedIndex].data;
			var timezone:String = timezoneDP[_panel.timezoneDDL.selectedIndex].data;
			_hyTool.severTime("0",svr_cmd, timezone, onSeverTime);
		}
		private function onSetGMTime(e:MouseEvent):void
		{
			var svr_cmd:String = svr_cmdDP[_panel.svr_cmdDDL.selectedIndex].data;
			var timezone:String = timezoneDP[_panel.timezoneDDL.selectedIndex].data;
			var curTimeStr:String = _panel.dateField.toString();
			var uin:String = _panel.uinTf.text
			_hyTool.severTime("1",svr_cmd, timezone, null, curTimeStr,"0", uin);
		}
		private function onSeverTime(info:String):void 
		{
			var curTimeStr:String = "";
			var reg:RegExp = /当前时间：([^\r\n]*)/
			if(reg.test(info)){
				curTimeStr = reg.exec( info)[1];
			}
			if(curTimeStr.length>0)
			_panel.dateField.text = curTimeStr;
			
			switchView(info);
			_panel.uinTf.text = "10001";// _hyData.uin;
		}
		private function onGMBt(e:MouseEvent):void
		{
			var i:int;
			switch(e.currentTarget){
				case _panel.resetBt:
					_hyTool.reset();
				break
				case _panel.roleExBt:
					_hyTool.addItem(11400005,400000000);
					break
				case _panel.oneLvExBt:
					_send({command:DConstants.COMMAND_GM_CALL, fn_name:"加一级经验",data:""});
					
					break
				case _panel.ninjaExBt:
					_hyTool.addItem(11700006,400000000);
					break
				
				case _panel.ybBt:
					_hyTool.addYuanBao(10000);
					break
				case _panel.dqBt:
					_hyTool.addItem(11100002,1000000);
					break
				case _panel.tbBt:
					_hyTool.addItem(11000001,10000000);
					break
				
				case _panel.testWeapenBt:
					for(i = 0; i < 4; i++){
						_hyTool.addItem(HouyingSeverTool_Biao.testWeapens[0], 1); 
					}
					break
				case _panel.weapenBt:
					for(i = 0; i < HouyingSeverTool_Biao.weapens.length; i++){
						_hyTool.addItem(HouyingSeverTool_Biao.weapens[i], 4); 
					}
					break
				case _panel.gyBt:
					for(i = 0; i < HouyingSeverTool_Biao.gouyu.length; i++){
						_hyTool.addItem(HouyingSeverTool_Biao.gouyu[i], 20); 
					}
					break
				case _panel.fwBt:
					for(i = 0; i < HouyingSeverTool_Biao.fuWen.length; i++){
						_hyTool.addItem(HouyingSeverTool_Biao.fuWen[i], 3); 
					}
					break
				case _panel.zpBt:
					for(i = 10800041; i <= 10800046; i++){//战袍
						_hyTool.addItem(i, 10000); 
					}
					break
				case _panel.zfBt:
					for(i = 13700001; i <= 13700011; i++){//阵法
						_hyTool.addItem(i, 10000); 
					}
					break
				case _panel.rjBt:
					for(i = 0; i < HouyingSeverTool_Biao.ninju.length; i++){
						_hyTool.addItem(HouyingSeverTool_Biao.ninju[i], 2); 
					}
					break
				
				
				case _panel.jsBt:
					for(i = 10800013; i <= 10800035; i++){//觉醒道具
						_hyTool.addItem(i, 999); 
					}
					break
				case _panel.spBt:
					_panel.itemList.filter.text = "";
					_send({command:DConstants.COMMAND_GM_CALL, fn_name:"所有碎片",data:""});
					break
				case _panel.ptBt:
					_panel.itemList.filter.text = "";
					_send({command:DConstants.COMMAND_GM_CALL, fn_name:"所有普通物品",data:""});
					break
				case "战绩":
					_hyTool.addItem(13000001, 50000);
					_hyTool.addItem(10600009, 50000000);
					_hyTool.addItem(10600005, 50000000);
					break;
				case "激活帐号":
					_hyTool.activeatePlayer();
					break;
				case "体力":
					_hyTool.addItem(11200004,100);
					break;
				case "公会报名":
					_hyTool.gonghui(200, 0,15);
					break;
				case _panel.njBt:
					_send({command:DConstants.COMMAND_GM_CALL, fn_name:"添加所有忍者",data:""});
					
					break;
				case _panel.zhBt:
					for(i = 0; i < HouyingSeverTool_Biao.shi.length; i++){
						_hyTool.addItem(HouyingSeverTool_Biao.shi[i], 99); 
					}
					break;
				case _panel.tlBt:
					_hyTool.addAllBreast();
					break;
				case _panel.ckBt:
					for (i = 1; i <= 14; i++) {
						_hyTool.addCKL(i, 6); 
					}
					for (i = 1; i <= 14; i++) {
						_hyTool.addCKLScore(i, 100000); 
					}
					break;
			}
				
		}
		private function onGetActBt(e:MouseEvent):void
		{
			if(_panel.idTf.text){
				_hyTool.getActivity(_panel.idTf.text,onGetOpData);
			}
		}
		private function onGetOpData(data:String):void 
		{
			if(data){
				_panel.dataTf.text = data
			}
		}
		private function onSetActBt(e:MouseEvent):void
		{
			if(_panel.idTf.text && _panel.dataTf.text){
				_hyTool.setActivity(_panel.idTf.text,_panel.dataTf.text,null);
			}
		}
		public function addItem(id:int,num:int):void
		{
			_hyTool.addItem(id, num); 
		}
		public function addNameMap(map:Dictionary):void{
			_panel.itemList.kvExcelMap = map;
		}
		/**
		 * Data handler from client
		 */
		public function setData(data:Object):void
		{
			switch (data["command"]) {
				case DConstants.COMMAND_REPORT_OP_ID:
					_panel.idTf.text = data.id.toString();
				break;
				case DConstants.COMMAND_GM_CALL:
					if(data.fn_name == "所有碎片"){
						var dic:Dictionary = data.datas;
						_panel.itemList.showItem(dic);
						
					}else if(data.fn_name == "所有普通物品"){
						_panel.itemList.showItem(data.datas);
						
					}else if(data.fn_name == "init"){
						_hyData = new HyData;
						_hyData.uin = data.uin;
						_hyData.role_id = data.role_id;
						_hyData.svr_id = data.svr_id;
						_hyData.PL = data.PL;
						
						_hyTool = new HouyingSeverTool(_hyData);
						_hyTool.onOtherInfo = onSeverRespone;
						
						
						if(data.PL in timezoneDic){
							var arr:Array = timezoneDic[data.PL] as Array;
							timezoneDP = new ArrayCollection(arr);
							_panel.timezoneDDL.dataProvider = timezoneDP;
							_panel.timeFI.includeInLayout = _panel.timeFI.visible = _panel.timezoneDDL.includeInLayout= arr.length > 1;
							_panel.timezoneDDL.selectedIndex = 0;
						}
						_panel.enabled = true;
					}else if(data.fn_name == "添加所有忍者"){
						_hyTool.addAllNinjas(data.level);
					}else if(data.fn_name == "加一级经验"){
						_hyTool.addItem(11400005,data.ex);
					}
					
					break;
			}
		}
		public function onSeverRespone(info:String,isHtml:Boolean):void{
			
			switchView(info);
			//_panel.dataTf.text = info;
		}
		private function switchView(info:Object):void{
			
			//_panel.tabBar.selectedIndex = index;
			
			if(info ){
				var _tf:TextField=new TextField;
				_tf.htmlText = info as String;
				//_panel.htmlPanel.text = info as String;
				_panel.htmlPanel.data = info;
				_panel.htmlContainer.includeInLayout = _panel.htmlContainer.visible =true;
				_panel.viewStack.percentWidth = 55;
			}else{
				
				_panel.htmlContainer.includeInLayout = _panel.htmlContainer.visible =false;
				_panel.viewStack.percentWidth = 100;
			}
		}
		
	}
}

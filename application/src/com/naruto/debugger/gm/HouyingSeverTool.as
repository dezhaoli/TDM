package com.naruto.debugger.gm
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.getDefinitionByName;
	/**
	 * ...
	 * @author Devin Lee
	 */
	public class HouyingSeverTool 
	{
	/**
	 * tools.huoying.qq.com
	 * =================================================================================
	 */
		public var hyData:HyData;
		public var onOtherInfo:Function;
		
		public function HouyingSeverTool(hyData:HyData){
			this.hyData = hyData;
		}
		public function activeatePlayer():void 
		{
			var url:String = "cgi-bin/activate_player.py";
			var data:URLVariables = new URLVariables;
			data.activate_way = 1;
			//ApplicationData.singleton.selfSrv = 1;
			sendToSever(url,data);
		}
		/**
		 * 重置账号(需要重新登录)
		 */
		public function reset():void {
			var url:String = "cgi-bin/user_data_tools.sh";
			var data:URLVariables = new URLVariables;
			data.cmd = 1;
			data.arg1 = 0;
			
			sendToSever(url,data);
			
		}
		/**
		 * 完成新手副本
		 */
		public function finishFreshmanFlag():void {
			var url:String = "cgi-bin/finish_freshman_flag.py";
			var data:URLVariables = new URLVariables;
			
			sendToSever(url,data);
			
		}
		
		/**
		 * 添加所有忍者
		 */
		public function addAllNinjas(level:String):void {
			var url:String = "cgi-bin/ninja_tools.sh.py";
			var data:URLVariables = new URLVariables;
			data.cmd = 1;
			data.arg1 = level;
			data.arg2 = 0;
			data.arg3 = 0;
			
			sendToSever(url,data);
			
		}
		/**
		 * 添加玩家可使用忍者
		 */
		public function addEnableNinjas(level:int):void {
			var url:String = "cgi-bin/ninja_tools.sh";
			var data:URLVariables = new URLVariables;
			data.cmd = 1;
			data.arg1 = level;
			data.arg2 = 0;
			data.arg3 = 1;
			
			sendToSever(url,data);
			
		}
		/**
		 * 添加元宝
		 */
		public function addYuanBao(num:int):void {
			var url:String = "cgi-bin/pay_tool.py";
			var data:URLVariables = new URLVariables;
			data.cmd = 3;
			data.arg1 = num;
			data.arg2 = 0;
			
			sendToSever(url,data);
			
		}
		/**
		 * 添加道具
		 */
		public function addItem(id:int,num:int):void {
			var url:String = "cgi-bin/modify_item.py";
			var data:URLVariables = new URLVariables;
			data.item_id = id;
			data.item_num = num;
			
			sendToSever(url,data);
			
		}
		/**
		 * 添加所有通灵兽
		 */
		public function addAllBreast():void {
			var url:String = "cgi-bin/summon_monster.py";
			var data:URLVariables = new URLVariables;
			data.cmd = 2;
			data.arg1 = 0;
			data.arg2 = 0;
			data.arg3 = 0;
			data.arg4 = 0;
			
			sendToSever(url,data);
			
		}
		public function addCKL(arg1:int,arg2:int):void {
			var url:String = "cgi-bin/hunt_life_tools.py";
			var data:URLVariables = new URLVariables;
			data.cmd = 1;
			data.arg1 = arg1;
			data.arg2 = arg2;
			data.arg3 = 0;
			
			sendToSever(url,data);
			
		}
		public function addCKLScore(index:int,arg2:int):void {
			var url:String = "cgi-bin/hunt_life_tools.py";
			var data:URLVariables = new URLVariables;
			data.cmd = 3;
			data.arg1 = 2;
			data.arg2 = index;
			data.arg3 = 100000;
			
			sendToSever(url,data);
			
		}
		//公会相关工具
		//
		/*
        <option value="1" selected="selected">清除最后退出时间</option>
        <option value="2">清除幸运转盘每日转动次数</option>
        <option value="3">清除每日护送次数</option>
        <option value="4">清除每日掠夺次数</option>
        <option value="5">清除公会技能cd</option>
        <option value="6">清除公会每日请离次数</option>
        <option value="7">增加贡献值（数据1为增加的贡献数目）</option>
        <option value="8">增加公会资金(数据1为需要增加的资金数)</option>
        <option value="9">增加假的公会成员(数据1为要加假人的个数)</option>
        <option value="10">删除所有的假成员</option>
        <option value="12">清除每日护送领奖标记</option>
        <option value="13">直接退出公会</option>
        <option value="14">增加公会活跃度(数据1为需要增加的活跃度)</option>
        <option value="15">设置当前的最近3日活跃度</option>
        <option value="16">设置假的GVG上周结果和排名</option>
        <option value="17">增加组织币（数据1为增加的贡献数目）</option>
        <option value="18">设置GVG决赛礼包（数据1为礼包序号0，1，2）</option>
        <option value="19">设置GVG预赛排名（数据1为排名，从1开始）</option>
        <option value="20">重置上周GVG排名</option>
        <option value="22">设置组织技能</option>
        <option value="24">加组织通灵兽</option>
        <option value="25">加组织通灵兽碎片</option>
        <option value="26">加组织查克拉</option>
        <option value="27">清除打开UI标记</option>
        <option value="29">清除组织交易交换次数</option>
        <option value="30">清除组织交易点券购买次数</option>
        <option value="31">清除组织交易点券出售次数次数</option>
        <option value="32">加组织礼包</option>
        <option value="100">清除组织副本的次数</option>
*/
		public function gonghui(data1:int,data2:int,type:int):void {
			var url:String = "cgi-bin/guild_tools.py";
			var data:URLVariables = new URLVariables;
			data.cmd = 27;
			data.data1 = data1;
			data.data2 = data2;
			data.type = type;
			
			sendToSever(url,data);
			
		}
		public function severTime(query_or_set:String,svr_cmd:String,timezone:String,cb:Function,offset:String="1970-1-1 00:00:00",one_key:String="0",uin:String=""):void {
			var url:String = "cgi-bin/change_time_offset.sh.py";
			var data:URLVariables = new URLVariables;
			data.svr_cmd = svr_cmd;
			data.timezone = timezone;
			data.query_or_set = query_or_set;
			data.offset = offset;
			data.one_key = one_key;
			data.uin = uin;
			
			sendToSever(url,data,false,cb);
			
		}
		public function getActivity(activity_id:String,cb:Function):void {
			var url:String = "cgi-bin/activity_tools.py";
			var data:URLVariables = new URLVariables;
			data.cmd = 0;
			data.req_cmd = 4;
			data.type = 0;
			data.activity_id = activity_id;
			data.data1 = 0;
			data.data2 = 0;
			data.data3 = 0;
			data.data4 = 0;
			data.data5 = 0;
			data.xml_data = 0;
			
			sendToSever(url,data,true,cb);
			
		}
		public function setActivity(activity_id:String,xml_data:String,cb:Function):void {
			var url:String = "cgi-bin/activity_tools.py";
			var data:URLVariables = new URLVariables;
			data.cmd = 0;
			data.req_cmd = 5;
			data.type = 0;
			data.activity_id = activity_id;
			data.data1 = 0;
			data.data2 = 0;
			data.data3 = 0;
			data.data4 = 0;
			data.data5 = 0;
			data.xml_data = xml_data;
			
			sendToSever(url,data,true,cb);
			
		}
		/*
		 * 
		<option value="00100001">活动服务器</option>
    <option value="0009000D">邮件服务器</option>
    <option value="000D0000">公会服务器</option>
    <option value="000E000E">排位战服务器</option>
    <option value="000A0004">等级战力排行榜服务器</option>
    <option value="000B000D">排行榜2服务器</option>
    <option value="00070016">好友服务器</option>
    <option value="00200002">平台服务器</option>
*/
		public function settime(svr_cmd:int,time:String):void {
			var url:String = "cgi-bin/change_time_offset.sh.py";
			var data:URLVariables = new URLVariables;
			data.svr_cmd = 27;
			data.query_or_set = time;
			
			sendToSever(url,data);
			
		}
		
		
//private     ========================================================================================
		private function sendToSever(url:String,data:URLVariables,isget:Boolean=false,cb:Function=null):void 
		{
			if(!hyData) return;
			if(!hyData.PL){
				onOtherInfo("当前的语言线不支持，请联系dezhaoli开通",false);
			}
			url = "http://gm.huoying.qq.com/"+hyData.PL+"/" + url;
			data.role_id = hyData.role_id;
			data.svr_id  = hyData.svr_id;
			if(!data.uin)
				data.uin = hyData.uin;
			
			var q:URLRequest = new URLRequest();
			q.url = url;
			q.method = isget?URLRequestMethod.GET: URLRequestMethod.POST;
			q.data = data;
			
			
			var l:URLLoader = new URLLoader;
			if (cb != null) {
				l.addEventListener(Event.COMPLETE, function(e:Event):void { cb(e.target.data) } );
				l.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void { cb(e.toString()) } );
			}else{
				l.addEventListener(Event.COMPLETE, completeHandler);
				l.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			}
			l.load(q);
		}
		
		private function errorHandler(e:IOErrorEvent):void 
		{
			onOtherInfo(e.toString(),false);
		}
		private function completeHandler(e:Event):void{
			onOtherInfo(e.target.data,true);
		}
		
	/**
	 * tools.huoying.qq.com
	 * =================================================================================
	 */
	}

}
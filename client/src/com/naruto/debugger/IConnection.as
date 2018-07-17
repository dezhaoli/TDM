package com.naruto.debugger
{
	
	/**
	 * This interface is needed to separate default and mobile connectors
	 */
	internal interface IConnection
	{

		function set address(value:String):void;
		function get connected():Boolean;
		function processQueue():void;
		function send(id:String, data:Object, direct:Boolean = false):void;
		function connect():void;
	}
}

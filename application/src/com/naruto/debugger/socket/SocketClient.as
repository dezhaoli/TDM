package com.naruto.debugger.socket
{
	import com.naruto.debugger.DConstants;
	import com.naruto.debugger.DData;
	import com.naruto.debugger.IClient;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	
	import mx.controls.Alert;


	public final class SocketClient implements IClient
	{

		
		// Properties
		private var _socket:Socket;
		private var _bytes:ByteArray;
		private var _package:ByteArray;
		private var _length:uint;
		
		
		// The information
		private var _playerType:String;
		private var _playerVersion:String;
		private var _isDebugger:Boolean;
		private var _isFlex:Boolean;
		private var _fileTitle:String;
		private var _fileLocation:String;
		private var _kvs:Array;


		/**
		 * Getters for basic info
		 */
		public function get playerType():String {
			return _playerType;
		}
		public function get playerVersion():String {
			return _playerVersion;
		}
		public function get isDebugger():Boolean {
			return _isDebugger;
		}
		public function get isFlex():Boolean {
			return _isFlex;
		}
		public function get fileTitle():String {
			return _fileTitle;
		}
		public function get fileLocation():String {
			return _fileLocation;
		}
		public function get kvs():Array
		{
			return _kvs;
		}



		// Callback functions
		// Format: onData(data:DData):void;
		// Format: onStart(target:DClient):void;
		// Format: onDisconnect(target:DClient):void;
		private var _onData:Function;
		private var _onStart:Function;
		private var _onDisconnect:Function;

		public function get onData():Function {
			return _onData;
		}
		public function get onStart():Function {
			return _onStart;
		}
		public function get onDisconnect():Function {
			return _onDisconnect;
		}
		public function set onData(value:Function):void {
			_onData = value;
		}
		public function set onStart(value:Function):void {
			_onStart = value;
		}
		public function set onDisconnect(value:Function):void {
			_onDisconnect = value;
		}
		

		/**
		 * Wrapper for socket
		 */
		public function SocketClient(socket:Socket)
		{
			// Save socket and bytes
			_socket = socket;
			_bytes = new ByteArray();
			_package = new ByteArray();
			_length = 0;

			// Configure listeners
			if (_socket != null) {
				_socket.addEventListener(Event.CLOSE, disconnect, false, 0, false);
				_socket.addEventListener(IOErrorEvent.IO_ERROR, disconnect, false, 0, false);
				_socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, disconnect, false, 0, false);
				_socket.addEventListener(ProgressEvent.SOCKET_DATA, dataHandler, false, 0, false);
			}

			// Get the basic info needed to open a tab
			send(DConstants.ID, {command:DConstants.COMMAND_HELLO});
		}


		/**
		 * Send data to the client
		 * @param id: The plugin id
		 * @param data: The data to send
		 */
		public function send(id:String, data:Object):void
		{
			// Use socket mode
			if (_socket != null) {
				
				// Return if not connected
				if (!_socket.connected) {
					return;
				}

				// The package
				var bytes:ByteArray = new DData(id, data).bytes;

				// Send package
				_socket.writeUnsignedInt(bytes.length);
				_socket.writeBytes(bytes);
				_socket.flush();
			}
		}
		

		/**
		 * Socket received data
		 */
		private function dataHandler(event:ProgressEvent):void
		{
			// Clear and read the bytes
			_bytes.clear();
			_socket.readBytes(_bytes, 0, _socket.bytesAvailable);

			// Reset position
			_bytes.position = 0;
			processPackage();
		}


		/**
		 * Process package
		 */
		private function processPackage():void
		{
			// Return if null bytes available
			if (_bytes.bytesAvailable == 0) {
				return;
			}

			// Read the size
			if (_length == 0) {
				try {
					_length = _bytes.readUnsignedInt();
					var verify:String = _bytes.readUTFBytes(3);
					if(verify != "LDZ"){
						trace("通讯包出错！_length=",_length);
						_length = 0;
						_package.clear();
						return;
					}
				} catch(e:Error) {
					_length = 0;
					_package.clear();
					
					return;
				}
				_package.clear();
			}
			// Load the data
			if (_package.length < _length && _bytes.bytesAvailable > 0) {
				
				// Get the data
				var l:uint = _bytes.bytesAvailable;
				if (l > _length - _package.length) {
					l = _length - _package.length;
				}
				_bytes.readBytes(_package, _package.length, l);
			}

			// Check if we have all the data
			if (_length != 0 && _package.length == _length) {
				
				// Log the data
				var item:DData = DData.read(_package);

				// Check if we should handle the call internaly
				if (item.id != null && item.id == DConstants.ID) {
					processData(item);
				}

				// Clear the old data
				_length = 0;
				_package.clear();
			}

			// Check if there is another package
			if (_length == 0 && _bytes.bytesAvailable > 0) {
				processPackage();
			}
		}


		/**
		 * Process data
		 */
		private function processData(item:DData):void
		{
			if (item.data["command"] == DConstants.COMMAND_INFO) {
				
				// Save info
				_playerType = item.data["playerType"];
				_playerVersion = item.data["playerVersion"];
				_isDebugger = item.data["isDebugger"];
				_isFlex = item.data["isFlex"];
				_fileLocation = item.data["fileLocation"];
				_fileTitle = item.data["fileTitle"];
				_kvs = item.data["kvs"];
				
				var debuggerVersion:Number = Number(item.data["debuggerVersion"]);
				
				if(debuggerVersion < DConstants.MinClientVersion){
					Alert.show("游戏引用 TranslationDebuggerClient.swc 版本过低,无法适配");
					_socket.close();
					return;
				}

				// Get the roots
				send(DConstants.ID, {command:DConstants.COMMAND_BASE});

				// Send the started command
				if (_onStart != null) _onStart(this);
				return;
			}

			// Call the data handler
			if (_onData != null) {
				_onData(item);
			}
		}
		

		/**
		 * Socket error
		 */
		private function disconnect(event:Event):void
		{
			_socket.removeEventListener(Event.CLOSE, disconnect);
			_socket.removeEventListener(IOErrorEvent.IO_ERROR, disconnect);
			_socket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, disconnect);
			_socket.removeEventListener(ProgressEvent.SOCKET_DATA, dataHandler);
			event.stopImmediatePropagation();
			if (_onDisconnect != null) _onDisconnect(this);
			_onData = null;
			_onStart = null;
			_onDisconnect = null;
		}
	}
}
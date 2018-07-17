package com.naruto.debugger
{
	import flash.utils.ByteArray;


	public final class DData
	{
		public static var A_ARSK:int = 0;
		public static var A_CLOSE:int = 1;
		public static var A_MIN:int = 2;
		
		public static var nwCloseAction:int;
		public static var _hideDisplayProp:Boolean= true;
		public static var _dev:Boolean = true;
		// Properties
		private var _id:String;
		private var _data:Object;
		[Bindable]
		public static var simpleMode:Boolean= true;
		

		/**
		 * Data
		 * @param id: The plugin ID
		 * @param data: The data for the plugin
		 */
		public function DData(id:String, data:Object)
		{
			// Save data
			_id = id;
			_data = data;
		}
		

		public static function get hideDisplayProp():Boolean
		{
			return _hideDisplayProp;
		}

		public static function set hideDisplayProp(value:Boolean):void
		{
			_hideDisplayProp = value;
			DUtils.saveSettingValue("hideDisplayProp",value);
		}

		public static function get DEV():Boolean
		{
			return _dev;
		}

		public static function set DEV(value:Boolean):void
		{
			_dev = value;
			DUtils.saveSettingValue("DEV",value);
		}

		/**
		 * Getters
		 */
		public function get id():String {
			return _id;
		}

		public function get data():Object {
			return _data;
		}


		/**
		 * Get the data for sending
		 */
		public function get bytes():ByteArray {
			// Create the holders
			var bytesId:ByteArray = new ByteArray();
			var bytesData:ByteArray = new ByteArray();

			// Save the objects
			bytesId.writeObject(_id);
			bytesData.writeObject(_data);

			// Write in one object
			var item:ByteArray = new ByteArray();
			item.writeUnsignedInt(bytesId.length);
			item.writeBytes(bytesId);
			item.writeUnsignedInt(bytesData.length);
			item.writeBytes(bytesData);
			item.position = 0;

			// Clear the old objects
			// bytesId.clear(); // FP10
			// bytesData.clear(); // FP10
			bytesId = null;
			bytesData = null;

			// Return the object
			return item;
		}


		/**
		 * Set the data for reading
		 */
		public function set bytes(value:ByteArray):void {
			// Create the holders
			var bytesId:ByteArray = new ByteArray();
			var bytesData:ByteArray = new ByteArray();

			// Decompress the value and read bytes
			try {
				value.readBytes(bytesId, 0, value.readUnsignedInt());
				value.readBytes(bytesData, 0, value.readUnsignedInt());

				// Save vars
				_id = bytesId.readObject() as String;
				_data = bytesData.readObject() as Object;
			} catch (e:Error) {
				_id = null;
				_data = null;
			}

			// Clear the old objects
			// bytesId.clear(); // FP10
			// bytesData.clear(); // FP10
			bytesId = null;
			bytesData = null;
		}


		/**
		 * Helper
		 */
		public static function read(bytes:ByteArray):DData
		{
			var item:DData = new DData(null, null);
			item.bytes = bytes;
			return item;
		}
	}
}
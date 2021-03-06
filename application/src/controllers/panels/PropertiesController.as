package controllers.panels
{
	import com.naruto.debugger.DConstants;
	import com.naruto.debugger.DData;
	
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.events.FlexEvent;
	
	import components.panels.PropertiesPanel;
	
	import events.PropertyEvent;


	public final class PropertiesController extends EventDispatcher
	{

		[Bindable]
		private var _data:ArrayCollection = new ArrayCollection();
		private var _panel:PropertiesPanel;
		private var _send:Function;


		[Bindable]
		[Embed(source="../../../assets/icon_wrench.png")]
		public var iconWrench:Class;

		/**
		 * Data handler for the panel
		 */
		public function PropertiesController(panel:PropertiesPanel, send:Function)
		{
			_panel = panel;
			_send = send;
			_panel.addEventListener(FlexEvent.CREATION_COMPLETE, creationComplete, false, 0, true);
		}


		/**
		 * Panel is ready to link data providers
		 */
		private function creationComplete(e:FlexEvent):void
		{
			_panel.removeEventListener(FlexEvent.CREATION_COMPLETE, creationComplete);
			_panel.datagrid.addEventListener(PropertyEvent.CHANGE_PROPERTY, changeProperty, false, 0, true);
			_panel.datagrid.dataProvider = _data;
		}
		

		/**
		 * A property has changed
		 */
		private function changeProperty(event:PropertyEvent):void
		{
			_send({command:DConstants.COMMAND_SET_PROPERTY, target:event.propertyTarget, name:event.propertyName, value:event.propertyValue});
		}


		/**
		 * Clear the data
		 */
		public function clear():void
		{
			_data.removeAll();
			_panel.clearPreview();
		}

		/**
		 * Data handler from open tab
		 */
		public function setData(data:Object):void
		{
			switch (data["command"]) {
				
				case DConstants.COMMAND_GET_PROPERTIES:
					_data.removeAll();
					for each (var subitem:XML in data["xml"].node.node) {
						var iconType:Class = null;
						var edit:Boolean = false;
						if (subitem.@access == DConstants.ACCESS_ACCESSOR || subitem.@access == DConstants.ACCESS_VARIABLE) {
							if (subitem.@permission == DConstants.PERMISSION_READWRITE) {
								var paramType:String = String(subitem.@type);
								if (paramType == DConstants.TYPE_STRING || paramType == DConstants.TYPE_BOOLEAN || paramType == DConstants.TYPE_NUMBER || paramType == DConstants.TYPE_INT || paramType == DConstants.TYPE_UINT) {
									iconType = iconWrench;
									edit = true;
								}
							}
						}
						var nn:String = String(subitem.@name);
						if( (DData.DEV && !(DData.hideDisplayProp && DConstants.DisplayObjectProp[nn] || "parent" == nn) )
							|| DConstants.AttisonProp[nn]) {
							
							if (!(DData.simpleMode && DConstants.DisplayObjectProp[nn] 
								&& nn !="alpha"
								&& nn !="visible"
								&& nn !="embedFonts" ))
								_data.addItem({name:nn, label:String(subitem.@label), target:String(subitem.@target), type:String(subitem.@type), value:subitem.@value, icon:iconType, edit:edit});
						}
					}
					break;
					
				case DConstants.COMMAND_SET_PROPERTY:
					for (var i:int = 0; i < _data.length; i++) {
						if (_data[i].target == data["target"]) {
							_data[i].value = data["value"];
							return;
						}
					}
					break;
					
				case DConstants.COMMAND_GET_PREVIEW:
					_panel.clearPreview();
					_panel.loadPreview(data["bytes"], data["width"], data["height"]);
					break;
					
				case DConstants.COMMAND_BASE:
				case DConstants.COMMAND_INSPECT:
					clear();
					break;
			}
		}
	}
}
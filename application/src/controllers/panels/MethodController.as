package controllers.panels
{
	import components.panels.MethodPanel;
	import components.windows.MethodWindow;
	import events.MethodEvent;
	import com.naruto.debugger.DConstants;
	import mx.collections.ArrayCollection;
	import mx.events.FlexEvent;
	import mx.events.ListEvent;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;


	public final class MethodController extends EventDispatcher
	{

		[Bindable]
		private var _data:ArrayCollection = new ArrayCollection();
		private var _panel:MethodPanel;
		private var _send:Function;
		private var _dictionary:Dictionary = new Dictionary(true);


		[Bindable]
		[Embed(source="../../../assets/icon_lightning.png")]
		public var iconLightning:Class;


		/**
		 * Data handler for the panel
		 */
		public function MethodController(panel:MethodPanel, send:Function)
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
			_panel.datagrid.dataProvider = _data;
			_panel.datagrid.addEventListener(ListEvent.ITEM_DOUBLE_CLICK, showMethod, false, 0, true);
		}


		/**
		 * Show the method window
		 */
		private function showMethod(event:ListEvent):void
		{
			if (event.currentTarget.selectedItem != null) {
				
				// Get the data
				var item:Object = _data.getItemAt(event.currentTarget.selectedIndex);

				// Check if runnable
				var parameters:XMLList = item.parameters;
				var runnable:Boolean = true;
				for (var i:int = 0; i < parameters.length(); i++) {
					
					// Save the parameter info
					var paramType:String = parameters[i].@type;
					var paramOptional:String = parameters[i].@optional;

					// Check if we can supply the parameter type
					if (paramOptional == "false") {
						if (paramType != DConstants.TYPE_STRING && paramType != DConstants.TYPE_BOOLEAN && paramType != DConstants.TYPE_NUMBER && paramType != DConstants.TYPE_INT && paramType != DConstants.TYPE_UINT) {
							runnable = false;
						}
					}
				}
				if (runnable) {
					
					// if function is runnable show method window
					var methodWindow:MethodWindow = new MethodWindow();
					methodWindow.addEventListener(MethodEvent.CALL_METHOD, callMethod);
					methodWindow.data = item;
					methodWindow.open();
				}
			}
		}


		/**
		 * Send the method
		 */
		private function callMethod(e:MethodEvent):void
		{
			// Save window in dictionary
			if (e.methodReturnType != DConstants.TYPE_VOID) {
				_dictionary[e.methodID] = MethodWindow(e.currentTarget);
			}

			// Send command
			_send({command:DConstants.COMMAND_CALL_METHOD, target:e.methodTarget, returnType:e.methodReturnType, arguments:e.methodParameters, id:e.methodID});
		}


		/**
		 * Clear the data
		 */
		public function clear():void
		{
			_data.removeAll();
		}


		/**
		 * Data handler from open tab
		 */
		public function setData(data:Object):void
		{
			switch (data["command"]) {
				case DConstants.COMMAND_GET_FUNCTIONS:
					_data.removeAll();
					for each (var subitem:XML in data["xml"].node.node) {
						if (subitem.@type == "Function") {
							
							// Runnable flag
							var runnable:Boolean = true;

							// Loop through the parameters
							var parameters:XMLList = subitem.children();
							for (var n:int = 0; n < parameters.length(); n++) {
								var type:String = parameters[n].@type;
								var optional:String = parameters[n].@optional;
								if (optional == "false") {
									if (type != DConstants.TYPE_STRING && type != DConstants.TYPE_BOOLEAN && type != DConstants.TYPE_NUMBER && type != DConstants.TYPE_INT && type != DConstants.TYPE_UINT) {
										runnable = false;
									}
								}
							}
							var iconType:Class;
							if (runnable) {
								iconType = iconLightning;
							} else {
								iconType = null;
							}

							// Add the method
							_data.addItem({runnable:runnable, name:String(subitem.@name), label:String(subitem.@label), value:String(subitem.@value), target:String(subitem.@target), type:String(subitem.@type), access:String(subitem.@access), permission:String(subitem.@permission), returnType:String(subitem.@returnType), args:String(subitem.@args), parameters:subitem..node, icon:iconType});
						}
					}
					break;
					
				case DConstants.COMMAND_CALL_METHOD:
					
					// Get window
					var id:String = data["id"];
					if (id in _dictionary) {
						var window:MethodWindow = _dictionary[id];
						window.results = data["xml"];
						delete _dictionary[id];
					}
					break;
					
				case DConstants.COMMAND_BASE:
				case DConstants.COMMAND_INSPECT:
					clear();
					break;
			}
		}
	}
}
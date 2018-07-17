package events
{
	import flash.events.Event;


	public final class PanelEvent extends Event
	{
		public var data:Object;
		// Events
		public static const CLEAR_PROPERTIES:String = "clearProperties";


		public function PanelEvent(type:String,data:Object="")
		{
			super(type, false, false);
			this.data= data;
		}
	}
}
package events
{
	import flash.events.Event;


	public class TraceEvent extends Event
	{

		// The properties
		public var message:String;
		public var label:String;
		public var Target:String;


		public function TraceEvent(type:String,message:String,label:String="",target:String="")
		{
			super(type, true, false);
			this.message = message;
			this.label = label;
			this.Target = target;	
		}
	}
}
package com.naruto.debugger.gm
{
	import controllers.panels.FindController;

	public class PlatformData
	{
		public var LOCAL_FLA_PIC_SVN:String;
		public var LOCAL_CLIENT_SVN:String;
		public var LOCAL_DESIGN_SVN:String;
		public var LOCAL_ASSETS_SVN:String;
		
		
		public var client_path:String;
		public var designer_path:String;
		public function PlatformData()
		{
			
		}
		
		public function toItems():Array{
			return [ 
				FindController.toItem("LOCAL_FLA_PIC_SVN",LOCAL_FLA_PIC_SVN),
				FindController.toItem("LOCAL_CLIENT_SVN",LOCAL_CLIENT_SVN),
				FindController.toItem("LOCAL_DESIGN_SVN",LOCAL_DESIGN_SVN),
				FindController.toItem("LOCAL_ASSETS_SVN",LOCAL_ASSETS_SVN),
				FindController.toItem("client_path",client_path),
				FindController.toItem("designer_path",designer_path)
				
]
		}
	}
}
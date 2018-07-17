package com.naruto.debugger
{
	import flash.desktop.NativeApplication;
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.utils.ByteArray;
	
	import mx.controls.Alert;
	
	import air.update.ApplicationUpdaterUI;
	import air.update.events.StatusFileUpdateErrorEvent;
	import air.update.events.StatusUpdateErrorEvent;
	import air.update.events.UpdateEvent;


	public class DUpdater
	{

		// Updater
		private static var _updater:ApplicationUpdaterUI;
		

		/**
		 * Check for an update
		 */
		public static function check():void
		{
			// The code below is a hack to work around a bug in the framework so that CMD-Q still works on Mac OSX
			// This is a temporary fix until the framework is updated (3.02)
			// See http://www.adobe.com/cfusion/webforums/forum/messageview.cfm?forumid=72&catid=670&threadid=1373568
			NativeApplication.nativeApplication.addEventListener(Event.EXITING, function(event:Event):void {
				var windows:Array = NativeApplication.nativeApplication.openedWindows;
				for (var i:int = 0; i < windows.length; i++) {
					windows[i].close();
				}
			});
			
			_updater = new ApplicationUpdaterUI();
			_updater.updateURL = DConstants.PATH_UPDATE;
			_updater.isCheckForUpdateVisible = false;
			_updater.isDownloadUpdateVisible = true;
			_updater.isDownloadProgressVisible = true;
			_updater.isInstallUpdateVisible = true;
			
			_updater.addEventListener(UpdateEvent.INITIALIZED, onUpdate, false, 0, false);
			_updater.addEventListener(UpdateEvent.BEFORE_INSTALL, onBeforeInstall, false, 0, false);
			_updater.addEventListener(ErrorEvent.ERROR, onError, false, 0, false);
			_updater.addEventListener(StatusFileUpdateErrorEvent.FILE_UPDATE_ERROR, onError, false, 0, false);
			_updater.addEventListener(StatusUpdateErrorEvent.UPDATE_ERROR, onError, false, 0, false);
			_updater.addEventListener(ErrorEvent.ERROR, onError, false, 0, false);			
			_updater.initialize();
		}
		
		/**
		 * Error handlers
		 */
		private static function onError(event:Event):void {
			//
		}
		
		
		/**
		 * An update is found
		 */
		private static function onUpdate(event:UpdateEvent):void {
			_updater.checkNow();
		}
		private static function onBeforeInstall(event:UpdateEvent):void {
			event.preventDefault();
			
			var adns:Namespace = _updater.updateDescriptor.namespace();
			var url:String = _updater.updateDescriptor.adns::url.toString();
			
			_updater.cancelUpdate();
			
			
			url = url.replace('.air','.exe');
			Alert.show("Downloading:"+url+"\nThe installation will auto start later.","Please wait for a minute");
			
			downloadUpdate(url);
		}
		
		private static var updateFile:File;
		private static var urlStream:URLStream;
		private static var fileStream:FileStream;
		private static function downloadUpdate(updateUrl:String):void
		{
			// Parsing file name out of the download url
			var fileName:String = updateUrl.substr(updateUrl.lastIndexOf("/") + 1);
			
			// Creating new file ref in temp directory
			updateFile = File.createTempDirectory().resolvePath(fileName);
			trace(updateFile.nativePath);
			
			// Using URLStream to download update file
			urlStream = new URLStream;
			urlStream.addEventListener(Event.OPEN, urlStream_openHandler);
			urlStream.addEventListener(ProgressEvent.PROGRESS, urlStream_progressHandler);
			urlStream.addEventListener(Event.COMPLETE, urlStream_completeHandler);
			urlStream.addEventListener(IOErrorEvent.IO_ERROR, urlStream_ioErrorHandler);
			urlStream.load(new URLRequest(updateUrl));
		}
		protected static function urlStream_ioErrorHandler(event:Event):void
		{
			Alert.show("Some Error occur.Install fail.");
		}
		protected static function urlStream_openHandler(event:Event):void
		{
			// Creating new FileStream to write downloaded bytes into
			fileStream = new FileStream;
			fileStream.open(updateFile, FileMode.WRITE);
		}
		protected static function urlStream_progressHandler(event:ProgressEvent):void
		{
			// ByteArray with loaded bytes
			var loadedBytes:ByteArray = new ByteArray;
			// Reading loaded bytes
			urlStream.readBytes(loadedBytes);
			// Writing loaded bytes into the FileStream
			fileStream.writeBytes(loadedBytes);
		}
		protected static function urlStream_completeHandler(event:Event):void
		{
			// Closing URLStream and FileStream
			closeStreams();
			
			// Installing update
			installUpdate();
		}
		protected static function closeStreams():void
		{
			fileStream.close();
			urlStream.close();
		}
		protected static function installUpdate():void
		{
			// Running the installer using NativeProcess API
			var info:NativeProcessStartupInfo = new NativeProcessStartupInfo;
			info.executable = updateFile;
			
			var process:NativeProcess = new NativeProcess;
			process.start(info);
			
			// Exit application for the installer to be able to proceed
			NativeApplication.nativeApplication.exit();
		}
		
	}
}
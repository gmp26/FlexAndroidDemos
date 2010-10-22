package com.dgrigg.components
{
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.utils.Timer;
	
	import mx.controls.Image;
	import mx.events.FlexEvent;
	import mx.events.RSLEvent;
	import mx.preloaders.DownloadProgressBar;
	
	//import popstar.dmbportal.PreloadEventBus;
	
	public class SplashLoader extends DownloadProgressBar {
		private var progressTxt:TextField;
		private var msgText:TextField;
		//private var bus:PreloadEventBus;
		
		//private var loader:PopstarPreloader;
		
		private var _rslLoaded:Number = 0;
		private var _rslTotal:Number = 0;
		private var _swfLoaded:Number = 0;
		private var _swfTotal:Number = 0;
		private var _isRSLDownloading:Boolean = false;
		
		[Embed(source="/assets/android-flex-logo.jpg")]
		public var ImageClass:Class;
		
		public var image:Bitmap;
		
		public function SplashLoader()
		{
			super();
			
			image = new ImageClass();
			image.addEventListener(Event.ADDED_TO_STAGE, handleAdded);
			addChild(image);
		}
		
		
		private function handleAdded(event:Event):void
		{
			image.x = (stage.stageWidth/2) - image.width/2;
			image.y = (stage.stageHeight/2) - image.height/2;
		}
		
		
		override public function set preloader(preloader:Sprite):void
		{
			//listen to both the ProgressEvent and RSLEvent to properly display
			//actual progress
			preloader.addEventListener(ProgressEvent.PROGRESS, handleProgress);
			preloader.addEventListener(Event.COMPLETE, handleComplete);
			preloader.addEventListener(FlexEvent.INIT_PROGRESS, handleInitProgress);
			preloader.addEventListener(FlexEvent.INIT_COMPLETE, handleInitComplete);
			
			preloader.addEventListener(RSLEvent.RSL_PROGRESS, handleRSLProgress);
			preloader.addEventListener(RSLEvent.RSL_COMPLETE, handleComplete);
			
		}
		
		private function handleProgress(event:ProgressEvent):void
		{
			_swfLoaded = event.bytesLoaded;
			_swfTotal = event.bytesTotal;
			
			if (_isRSLDownloading)
			{
				_swfLoaded -= _rslLoaded;
				_swfTotal -= _rslTotal;
			}
			
			//updateProgress();
		}
		
		private function handleComplete(event:Event):void
		{
			
		}
		
		private function handleRSLProgress(event:RSLEvent):void
		{
			_isRSLDownloading = true;
			_rslLoaded = event.bytesLoaded;
			_rslTotal = event.bytesTotal;
			
			//updateProgress();
		}
		
		
		
		private function handleInitProgress(event:FlexEvent):void
		{
			
		}
		
		private function handleInitComplete(event:FlexEvent):void
		{
			
			dispatchEvent(new Event(Event.COMPLETE));
			
			
		}
		
		
		
		
		
	}
	
}
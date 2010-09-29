package com.dgrigg.components
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.IList;
	import mx.events.CloseEvent;
	
	import spark.components.Button;
	import spark.components.Label;
	import spark.components.supportClasses.SkinnableComponent;
	import spark.events.IndexChangeEvent;
	
	[Event(name="close", type="mx.events.CloseEvent")]
	[Event(name="change", type="spark.events.IndexChangeEvent")]
	
	public class ModalSwipeList extends SwipeList
	{
		[SkinPart(name="closeBtn", type="spark.components.Button")]
		public var closeBtn:Button;
		
		[SkinPart(name="okBtn", type="spark.components.Button")]
		public var okBtn:Button;
		
		[SkinPart(name="titleLbl", type="spark.components.Label")]
		public var titleLbl:Label;
		
		protected  var _title:String;
		
		public function ModalSwipeList()
		{
			super();
			
		}
		
		override protected function partAdded(partName:String, instance:Object):void 
		{
			super.partAdded(partName, instance);
			
			if (instance == closeBtn)
			{
				closeBtn.addEventListener(MouseEvent.CLICK, onClose, false, 0, true);
			}
			
			if (instance == okBtn)
			{
				okBtn.addEventListener(MouseEvent.CLICK, onOk, false, 0, true);
			}
			
			if (instance == titleLbl)
			{
				titleLbl.text = _title;
			}
			
		}
		
		public function set title(value:String):void 
		{
			_title = value;
			if (titleLbl)
			{
				titleLbl.text = _title;
			}
		}
		
		public function get title():String 
		{
			return _title;
		}
		
		private function onOk(event:MouseEvent=null):void 
		{
			var e:Event = new Event(Event.SELECT);
			dispatchEvent(e);
		}
		
		private function onClose(event:MouseEvent=null):void 
		{
			var e:CloseEvent = new CloseEvent(CloseEvent.CLOSE);
			dispatchEvent(e);
		}
		
		override protected function commitSelection(dispatchChangedEvents:Boolean = true):Boolean
		{
			
			var flag:Boolean = super.commitSelection(dispatchChangedEvents);
			if (flag)
			{
				//onClose();
			}
			return flag;
		}
		
		
		
		
		
	}
}
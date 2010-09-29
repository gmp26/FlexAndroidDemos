package com.dgrigg.components
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import spark.components.Scroller;
	import spark.core.IViewport;
	
	public class SwipeScroller extends Scroller
	{
		protected var _moved:Boolean = false;
		protected var lastPoint:Point;
		protected var _speedY:int;
		protected var _speedX:int;
		protected static const DECELERATION:Number = 0.85;
		
		protected var _scrolling:Boolean = false;
		protected var _swipeDirection:String = VERTICAL;
		
		public static const VERTICAL:String = "vertical";
		public static const HORIZONTAL:String = "horizontal";
		public static const BOTH:String = "both";
		
		public var yDiff:int = 0;
		public var xDiff:int = 0;
		
		public function SwipeScroller()
		{
			super();
		}
		
		public function set swipeDirection(value:String):void 
		{
			if (value == VERTICAL || value == HORIZONTAL || value == BOTH)
			{
				_swipeDirection = value;
			}
		}
		
		public function get swipeDirection():String 
		{
			return _swipeDirection;
		}
		
		protected function get speedY():int 
		{
			return _speedY;
		}
		
		protected function set speedY(value:int):void 
		{
			if (_swipeDirection == BOTH || _swipeDirection == VERTICAL)
			{
				_speedY = value;
			}
			else 
			{
				_speedY = 0;
			}
		}
		
		protected function get speedX():int 
		{
			return _speedX;
		}
		
		protected function set speedX(value:int):void 
		{
			if (_swipeDirection == BOTH || _swipeDirection == HORIZONTAL)
			{
				_speedX = value;
			}
			else 
			{
				_speedX = 0;
			}
		}
		
		override public function set viewport(value:IViewport):void 
		{
			super.viewport = value;
			
			value.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
		}
		
		private function onMouseDown(event:MouseEvent):void 
		{
			lastPoint = new Point(mouseX, mouseY);
			_moved = false;
			speedY = 0;
			speedX = 0;
			
			viewport.removeEventListener(Event.ENTER_FRAME, onSwipe, false);
			
			viewport.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);
			viewport.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);
			if (stage)
			{
				stage.addEventListener(Event.MOUSE_LEAVE, onMouseUp, false, 0, true);
			}
			
		}
		
		private function onMouseUp(event:Event):void 
		{
			viewport.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp, false);
			viewport.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false);
			if (stage)
			{
				stage.removeEventListener(Event.MOUSE_LEAVE, onMouseUp, false);
			}
			
		}
		
		private function onMouseMove(event:MouseEvent):void 
		{
			if (this.mouseX != lastPoint.x && this.mouseY != lastPoint.y)
			{
				
				
				_moved = true;
				viewport.addEventListener(Event.ENTER_FRAME, onSwipe, false, 0, true);
				var p:Point = new Point(this.mouseX, this.mouseY);
				
				speedX = lastPoint.x - p.x;
				speedY = lastPoint.y - p.y;
				
				if (Math.abs(speedX) > 5 || Math.abs(speedY) > 5)
				{
					_scrolling = true;
				}
				else
				{
					_scrolling = false;
				}
				
				xDiff = speedX;
				yDiff = speedY;
				
				lastPoint = p;
			}
			
		}
		
		
		private function onSwipe(event:Event):void 
		{
			viewport.verticalScrollPosition += speedY;
			viewport.horizontalScrollPosition += speedX;
			
			speedY = speedY * DECELERATION
			speedX = speedX * DECELERATION;
			
			if (speedY >= -1 && speedY <= 1 && speedX >= -1 && speedX <= 1)
			{
				speedY = 0;
				speedX = 0;
				viewport.removeEventListener(Event.ENTER_FRAME, onSwipe, false);
				
				_scrolling = false;
			}
		}
		
		public function isScrolling():Boolean
		{
			return _scrolling;
		}
		
		public function get moved():Boolean
		{
			return _moved;
		}
		
		public function set moved(value:Boolean):void 
		{
			
		}
	}
}
package com.dgrigg.components
{
	
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	
	import mx.collections.ArrayList;
	import mx.collections.IList;
	import mx.controls.TextInput;
	import mx.core.IFlexDisplayObject;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	
	import spark.components.Button;
	import spark.components.ComboBox;
	import spark.components.List;
	import spark.components.SkinnableDataContainer;
	import spark.components.supportClasses.ListBase;
	import spark.components.supportClasses.SkinnableComponent;
	import spark.events.IndexChangeEvent;
	
	
	[Event(name="change", type="spark.events.IndexChangeEvent")]
	public class SelectField extends ListBase
	{
		[SkinPart(name="textField", type="mx.controls.TextInput")]
		public var textInput:TextInput;
		
		[SkinPart(name="openButton", type="spark.components.Button")]
		public var openButton:Button;
		
		public var list:ModalSwipeList;
		
		protected var _selectedItem:Object;
		protected var _selectedIndex:int = -1;
		protected var _oldIndex:int;
		protected var _dirtyValue:Boolean = false;
		protected var _isTextInputInFocus:Boolean = false;
		protected var _labelField:String = "label";
		protected var _dataProvider:IList;
		protected var _restrict:String;
		public var title:String = "Select";
		
		public var itemFromLabel:Function = createItemFromLabel;
		
		public function SelectField()
		{
			super();
		}
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			if (partName == "textInput")
			{
				textInput.addEventListener(TextEvent.TEXT_INPUT, onTextChange, false, 0, true);
				textInput.addEventListener(FocusEvent.FOCUS_IN, onTextFocusIn, false, 0, true);
				textInput.addEventListener(FocusEvent.FOCUS_OUT, onTextFocusOut, false, 0, true);
			}
			
			if (partName == "openButton")
			{
				openButton.addEventListener(MouseEvent.CLICK, onOpenList, false, 0, true);
				
			}
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if (textInput)
			{
				textInput.restrict = _restrict;
			}
		}
		
		protected function onOpenList(event:MouseEvent):void 
		{
			if (_isTextInputInFocus)
			{
				processTextInput();
				callLater(popList);
			}
			else
			{
				popList();
			}
			
		}
		
		protected function popList():void 
		{
			list = new ModalSwipeList();
			list.dataProvider = dataProvider;
			list.width = stage.stageWidth - 50;
			list.height = stage.stageHeight - 100;
			list.selectedItem = _selectedItem;
			list.title = title;

			
			list.addEventListener(FlexEvent.CREATION_COMPLETE, onListCreated, false, 0, true);
			
			PopUpManager.addPopUp(list, this, true);
			list.x = 25;
			list.y = 25;
		}
		
		/**
		 * add the close and change listeners after the list has been created
		 * in order to avoid a conflict when initially setting the selectedItem
		 */
		private function onListCreated(event:FlexEvent):void
		{
			list.removeEventListener(FlexEvent.CREATION_COMPLETE, onListCreated, false);
			
			list.addEventListener(CloseEvent.CLOSE, onListClose, false, 0, true);
			list.addEventListener(Event.SELECT, onListSelect, false, 0, true);
			list.addEventListener(IndexChangeEvent.CHANGE, onListChange, false, 0, true);
			
		}
		
		
		private function onListChange(event:IndexChangeEvent):void 
		{
			_oldIndex = event.oldIndex;
		}
		
		private function onListSelect(event:Event):void 
		{
			if (list.selectedItem)
			{
				selectedItem = list.selectedItem;
				selectedIndex = list.selectedIndex;
				
				
				var e:IndexChangeEvent = new IndexChangeEvent(IndexChangeEvent.CHANGE);
				e.newIndex = selectedIndex;
				e.oldIndex = _oldIndex;
				dispatchEvent(e);
				_oldIndex = -1;
				
			}
			
			onListClose();
		}
		
		
		
		private function onListClose(event:CloseEvent=null):void 
		{
			list.removeEventListener(CloseEvent.CLOSE, onListClose, false);
			list.removeEventListener(IndexChangeEvent.CHANGE, onListChange, false);
			
			list.dataProvider = null;
			
			callLater(removeList)
			
			
		}
		
		/**
		 * remove the list from the PopUpManager, need to wait until the list is cleared before
		 * doing this to avoid a null reference error in the List class
		 */
		private function removeList():void 
		{
			PopUpManager.removePopUp(list as IFlexDisplayObject);
		}
		
		private function onTextChange(event:TextEvent):void 
		{
			_dirtyValue = true;
		}
		
		private function onTextFocusIn(event:FocusEvent):void 
		{
			_isTextInputInFocus = true;
		}
		
		private function onTextFocusOut(event:FocusEvent):void 
		{
			_isTextInputInFocus = false;
			processTextInput();
			
		}
		
		private function processTextInput():void 
		{
			
			if (_dirtyValue && textInput.text != '')
			{
				var item:Object = getItemFromList(textInput.text);
				
				//no match so add it to the dataProvider
				if (item == null)
				{
					item = itemFromLabel(textInput.text);
					dataProvider.addItem(item);
				}
				selectedItem = item;
				
			}
			else if (!_dirtyValue && textInput.text == '')
			{
				selectedItem = null;
			}
			
			_dirtyValue = false;
		}
		
		private function getItemFromList(value:String):Object 
		{
			var len:int = dataProvider.length;
			var item:Object;
			for (var i:int=0;i<len;i++)
			{
				item = dataProvider.getItemAt(i);
				if (item[labelField] == value)
				{
					return item;
				}
			}
			return null;
		}
		
		protected function createItemFromLabel(value:String):Object 
		{
			var obj:Object = {};
			obj[labelField] = value;
			obj.data = value;
			
			return obj;
		}
		
		override public function set selectedItem(value:*):void 
		{
			super.selectedItem = value;
			_selectedItem = value;
			if (value)
			{
				if (_selectedItem.hasOwnProperty(labelField))
				{
					textInput.text = _selectedItem[labelField];
				}
				else
				{
					textInput.text = _selectedItem.toString();
				}
				
				
			}
			else
			{
				textInput.text = "";
			}
			
			_selectedIndex = dataProvider.getItemIndex(value);
		}
		
		override public function get selectedItem():* 
		{
			
			if (this._dirtyValue)
			{
				processTextInput();
			}
			return _selectedItem;
		}
		
				
		override public function set selectedIndex(value:int):void 
		{
			super.selectedIndex = value;
			_selectedIndex = value;
			
			if (dataProvider)
			{
				selectedItem = dataProvider.getItemAt(_selectedIndex);
			}
			
		}
		
		
		override public function get selectedIndex():int 
		{
			return _selectedIndex;
		}
		
		
		public function get text():String 
		{
			return textInput.text;
		}
		
		public function set text(value:String):void 
		{
			textInput.text = value;
			processTextInput();
		}
		
		
		
		public function set restrict(value:String):void 
		{
			_restrict = value;
			invalidateProperties();
		}
		
		public function get restrict():String 
		{
			return _restrict;
		}
		
		
		
		
		
	}
}
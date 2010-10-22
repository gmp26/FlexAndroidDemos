package com.dgrigg.components
{
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.collections.IList;
	import mx.core.IVisualElement;
	import mx.core.mx_internal;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	import mx.events.IndexChangedEvent;
	import mx.events.SandboxMouseEvent;
	
	import spark.components.Button;
	import spark.components.IItemRenderer;
	import spark.components.List;
	import spark.components.supportClasses.ListBase;
	import spark.components.supportClasses.SkinnableComponent;
	import spark.events.IndexChangeEvent;
	import spark.events.RendererExistenceEvent;
	import spark.layouts.HorizontalLayout;
	import spark.layouts.TileLayout;
	import spark.layouts.VerticalLayout;
	import spark.layouts.supportClasses.LayoutBase;
	
	//ListBase and List share selection properties that are mx_internal
	use namespace mx_internal;  
	
	[Event(name="change", type="spark.events.IndexChangeEvent")]
	
	public class SwipeList extends List
	{
		[SkinPart(name="scroller", type="com.dgrigg.components.SwipeScroller")]
		public var swipeScroller:SwipeScroller;
		
		public function SwipeList()
		{
			super();
		}
		
		override public function set layout(value:LayoutBase):void 
		{
			super.layout = value;
			
			
			
		}
		
		override protected function partAdded(partName:String, instance:Object):void 
		{
			super.partAdded(partName, instance);
			
			
			if (partName == "scroller")
			{
				swipeScroller = instance as SwipeScroller;
				
				
			}
			
			if (instance == dataGroup)
			{
				dataGroup.addEventListener(RendererExistenceEvent.RENDERER_ADD, dataGroup_rendererAddHandler);
			}
			
			
			
			
		}
		
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void 
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			//trace (value);
			
			if (swipeScroller)
			{
				var sd:String = swipeScroller.swipeDirection;;
				if (layout is HorizontalLayout)
				{
					sd = SwipeScroller.HORIZONTAL;
					
				}
				else if (layout is VerticalLayout)
				{
					sd = SwipeScroller.VERTICAL;
				}
				else if (layout is TileLayout)
				{
					sd = SwipeScroller.BOTH;
				}
				
				swipeScroller.swipeDirection = sd;
			}
			
		}
		
		/**
		 *  @private
		 *  Internal storage for the selectedIndices property.
		 */
		private var _selectedIndices:Vector.<int>;
		
		override public function get selectedIndices():Vector.<int>
		{
			return new Vector.<int>();
			//return _selectedIndices;
		}
		
		/**
		 *  @private
		 */
		private var _proposedSelectedIndices:Vector.<int> = new Vector.<int>(); 
		
		/**
		 *  @private
		 */
		private var multipleSelectionChanged:Boolean; 
		
		/**
		 *  @private
		 */
		override public function set selectedIndices(value:Vector.<int>):void
		{
			setSelectedIndices(value, false);
		}
		
		/**
		 *  @private
		 *  Used internally to specify whether the selectedIndices changed programmatically or due to 
		 *  user interaction. 
		 * 
		 *  @param dispatchChangeEvent if true, the component will dispatch a "change" event if the
		 *  value has changed. Otherwise, it will dispatch a "valueCommit" event. 
		 */
		override mx_internal function setSelectedIndices(value:Vector.<int>, dispatchChangeEvent:Boolean = false):void
		{
			// TODO (jszeto) Do a deep compare of the vectors
			if (_proposedSelectedIndices == value || 
				(value && value.length == 1 && 
					selectedIndices && selectedIndices.length == 1 &&    
					value[0] == selectedIndices[0]))
				return; 
			
			if (dispatchChangeEvent)
				dispatchChangeAfterSelection = dispatchChangeEvent;
			_proposedSelectedIndices = value;
			multipleSelectionChanged = true;  
			invalidateProperties();
		}
		
		
		
		/**
		 *  @private
		 *  The selection validation and commitment workhorse method. 
		 *  Called to commit the pending selected index. This method dispatches
		 *  the "changing" event, and if the event is not cancelled,
		 *  commits the selection change and then dispatches the "change"
		 *  event.
		 * 
		 *  Returns true if the selection was committed, or false if the selection
		 *  was cancelled.
		 */
		
		
		override protected function commitSelection(dispatchChangedEvents:Boolean = true):Boolean
		{
			// Step 1: make sure the proposed selected index is in range.
			
			var maxIndex:int = dataProvider ? dataProvider.length - 1 : -1;
			var oldSelectedIndex:int = _selectedIndex;
			var oldCaretIndex:int = _caretIndex;
			var e:IndexChangeEvent;
			
			
			if (!allowCustomSelectedItem || _proposedSelectedIndex != ListBase.CUSTOM_SELECTED_ITEM)
			{
				if (_proposedSelectedIndex < NO_SELECTION)
					_proposedSelectedIndex = NO_SELECTION;
				if (_proposedSelectedIndex > maxIndex)
					_proposedSelectedIndex = maxIndex;
				if (requireSelection && _proposedSelectedIndex == NO_SELECTION && 
					dataProvider && dataProvider.length > 0)
				{
					_proposedSelectedIndex = NO_PROPOSED_SELECTION;
					return false;
				}
			}
			
			// Caching value of proposed index prevents its being changed in the dispatch
			// of the changing event, if that results in a call into this function
			var tmpProposedIndex:int = _proposedSelectedIndex;
			
			// Step 2: dispatch the "changing" event. If preventDefault() is called
			// on this event, the selection change will be cancelled.        
			if (dispatchChangeAfterSelection)
			{
				e = new IndexChangeEvent(IndexChangeEvent.CHANGING, false, true);
				e.oldIndex = _selectedIndex;
				e.newIndex = _proposedSelectedIndex;
				if (!dispatchEvent(e))
				{
					// The event was cancelled. Cancel the selection change and return.
					_proposedSelectedIndex = NO_PROPOSED_SELECTION;
					return false;
				}
			}
			
			// Step 3: commit the selection change and caret change
			_selectedIndex = tmpProposedIndex;
			_proposedSelectedIndex = NO_PROPOSED_SELECTION;
			
			if (oldSelectedIndex != NO_SELECTION)
				itemSelected(oldSelectedIndex, false);
			if (_selectedIndex != NO_SELECTION && _selectedIndex != CUSTOM_SELECTED_ITEM)
				itemSelected(_selectedIndex, true);
			setCurrentCaretIndex(_selectedIndex); 
			
			// Step 4: dispatch the "change" event and "caretChange" 
			// events based on the dispatchChangeEvents parameter. Overrides may  
			// chose to dispatch the change/caretChange events 
			// themselves, in which case we wouldn't want to dispatch the event 
			// here. 
			if (dispatchChangedEvents)
			{
				// Dispatch the change event
				if (dispatchChangeAfterSelection)
				{
					e = new IndexChangeEvent(IndexChangeEvent.CHANGE);
					e.oldIndex = oldSelectedIndex;
					e.newIndex = _selectedIndex;
					dispatchEvent(e);
					dispatchChangeAfterSelection = false;
				}
				else
				{
					dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
				}
				
				//Dispatch the caretChange event 
				e = new IndexChangeEvent(IndexChangeEvent.CARET_CHANGE); 
				e.oldIndex = oldCaretIndex; 
				e.newIndex = caretIndex; 
				dispatchEvent(e);
			}
			
			
			
			return true;
		}
		
		/**
		 *  @private
		 *  Given a new selection interval, figure out which
		 *  items are newly added/removed from the selection interval and update
		 *  selection properties and view accordingly. 
		 */
		override protected function commitMultipleSelection():void
		{
			var removedItems:Vector.<int> = new Vector.<int>();
			var addedItems:Vector.<int> = new Vector.<int>();
			var i:int;
			var count:int;
			
			if (!isEmpty(_selectedIndices) && !isEmpty(_proposedSelectedIndices))
			{
				// Changing selection, determine which items were added to the 
				// selection interval 
				count = _proposedSelectedIndices.length;
				for (i = 0; i < count; i++)
				{
					if (_selectedIndices.indexOf(_proposedSelectedIndices[i]) < 0)
						addedItems.push(_proposedSelectedIndices[i]);
				}
				// Then determine which items were removed from the selection 
				// interval 
				count = _selectedIndices.length; 
				for (i = 0; i < count; i++)
				{
					if (_proposedSelectedIndices.indexOf(_selectedIndices[i]) < 0)
						removedItems.push(_selectedIndices[i]);
				}
			}
			else if (!isEmpty(_selectedIndices))
			{
				// Going to a null selection, remove all
				removedItems = _selectedIndices;
			}
			else if (!isEmpty(_proposedSelectedIndices))
			{
				// Going from a null selection, add all
				addedItems = _proposedSelectedIndices;
			}
			
			// Commit _selectedIndices before calling itemSelected() because
			// selecting item renderers may cause updates that will check
			// the value of _selectedIndices. Setting it first makes the
			// indices consistent with the new selection values on the items.
			_selectedIndices = _proposedSelectedIndices;
			
			// De-select the old items that were selected 
			if (removedItems.length > 0)
			{
				count = removedItems.length;
				for (i = 0; i < count; i++)
				{
					itemSelected(removedItems[i], false);
				}
			}
			
			// Select the new items in the new selection interval 
			if (!isEmpty(_proposedSelectedIndices))
			{
				count = _proposedSelectedIndices.length;
				for (i = 0; i < count; i++)
				{
					itemSelected(_proposedSelectedIndices[i], true);
				}
			}
			
			// Put _proposedSelectedIndices back to its default value.  
			_proposedSelectedIndices = new Vector.<int>();
		}
		
		/**
		 *  @private
		 *  Returns true if v is null or an empty Vector.
		 */
		private function isEmpty(v:Vector.<int>):Boolean
		{
			return v == null || v.length == 0;
		}
		
		
		private function dataGroup_rendererAddHandler(event:RendererExistenceEvent):void
		{
			//trace("dataGroup_renderAddHandler");
			var index:int = event.index;
			var renderer:IVisualElement = event.renderer;
			
			if (!renderer)
				return;
			
			renderer.addEventListener(MouseEvent.MOUSE_UP, item_mouseUpHandler);
		}
		
		protected function item_mouseUpHandler(event:MouseEvent):void
		{
			if (swipeScroller.isScrolling())
			{
				
			}
			else
			{
				// Handle the fixup of selection
				var newIndex:int
				if (event.currentTarget is IItemRenderer)
					newIndex = IItemRenderer(event.currentTarget).itemIndex;
				else
					newIndex = dataGroup.getElementIndex(event.currentTarget as IVisualElement);
				
				if (!allowMultipleSelection)
				{
					// Single selection case, set the selectedIndex 
					var currentRenderer:IItemRenderer;
					if (caretIndex >= 0)
					{
						currentRenderer = dataGroup.getElementAt(caretIndex) as IItemRenderer;
						if (currentRenderer)
							currentRenderer.showsCaret = false;
					}
					
					// Check to see if we're deselecting the currently selected item 
					if (event.ctrlKey && selectedIndex == newIndex)
					{
						pendingSelectionOnMouseUp = true;
						pendingSelectionCtrlKey = true;
						pendingSelectionShiftKey = event.shiftKey;
					}
					else
						setSelectedIndex(newIndex, true);
				}
				else 
				{
					// Don't commit the selection immediately, but wait to see if the user
					// is actually dragging. If they don't drag, then commit the selection
					if (isItemIndexSelected(newIndex))
					{
						pendingSelectionOnMouseUp = true;
						pendingSelectionShiftKey = event.shiftKey;
						pendingSelectionCtrlKey = event.ctrlKey;
					}
					else
					{
						setSelectedIndices(calculateSelectedIndices(newIndex, event.shiftKey, event.ctrlKey), true);
					}
				}
				
				// If selection is pending on mouse up then we have just moused down on
				// an item, part of an already commited selection.
				// However if we moused down on an item that's not currently selected,
				// we must commit the selection before trying to start dragging since
				// listeners may prevent the item from being selected.
				if (!pendingSelectionOnMouseUp)
					validateProperties();
				
				mouseDownPoint = event.target.localToGlobal(new Point(event.localX, event.localY));
				mouseDownIndex = newIndex;
				
				var listenForDrag:Boolean = (dragEnabled && selectedIndices && this.selectedIndices.indexOf(newIndex) != -1);
				// Handle any drag gestures that may have been started
				if (listenForDrag)
				{
					// Listen for MOUSE_MOVE on the sandboxRoot.
					// The user may have cliked on the item renderer close
					// to the edge of the list, and we still want to start a drag
					// operation if they move out of the list.
					systemManager.getSandboxRoot().addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, false, 0, true);
				}
				
				if (pendingSelectionOnMouseUp || listenForDrag)
				{
					systemManager.getSandboxRoot().addEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, mouseUpHandler, false, 0, true);
					systemManager.getSandboxRoot().addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, false, 0, true);
				}
			}
		}
		
		
		override protected function item_mouseDownHandler(event:MouseEvent):void
		{
			
			
		}
		
		
		
	}
}
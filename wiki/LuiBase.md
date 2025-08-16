# LuiBase

The basic constructor of all elements, which contains all the basic functions and logic of each element.  
## Methods
### `addEvent`
Add a callback for a specific event
Check "LuiEvents" script for available events

**Returns:**  
- `{struct} The element itself for chaining`  

### `removeEvent`
Remove a callback for a specific event //???// возможно удаление подписки на событие с колбэком не очень правильное (поиск по точному колбэку странное решение)

**Returns:**  
- `{struct} The element itself for chaining`  

### `get`
Get value of this element

**Returns:**  
- `{any} Value depends on element`  

### `getData`
Get data struct or specified value from it


### `getStyle`
Get style


### `getFirst`
Get first element in content array


### `getLast`
Get last element in content array


### `set`
Set value

**Parameters:**  
- `{any} _value`  


### `setData`
Set data


### `setName`
Set element unique identificator name (Used for get element from main ui container via getElement())


### `setPositionType`
Set flexpanel(element) position type (default is flexpanel_position_type.relative)

**Parameters:**  
- `{constant.flexpanel_position_type} [_type]`  


### `setPositionAbsolute`
Shortcut method to make element position type absolute (eq. setPositionType(flexpanel_position_type.absolute))


### `setPosX`
Set flexpanel(element) X position

**Parameters:**  
- `{real} [_x] left = X`  


### `setPosY`
Set flexpanel(element) Y position

**Parameters:**  
- `{real} [_y] top = Y`  


### `setPosR`
Set flexpanel(element) right position

**Parameters:**  
- `{real} [_r] right`  


### `setPosB`
Set flexpanel(element) bottom position

**Parameters:**  
- `{real} [_b] bottom`  


### `setPosition`
Set flexpanel(element) position

**Parameters:**  
- `{real} [_x] left = X`  
- `{real} [_y] top = Y`  
- `{real} [_r] right`  
- `{real} [_b] bottom`  


### `setWidth`
Set flexpanel(element) width

**Parameters:**  
- `{real} [_width]`  


### `setHeight`
Set flexpanel(element) height

**Parameters:**  
- `{real} [_height]`  


### `setSize`
Set flexpanel(element) size

**Parameters:**  
- `{real} [_width]`  
- `{real} [_height]`  


### `setFullSize`



### `setMinWidth`
Set flexpanel(element) min width

**Parameters:**  
- `{real} [_min_width]`  


### `setMaxWidth`
Set flexpanel(element) max width

**Parameters:**  
- `{real} [_max_width]`  


### `setMinHeight`
Set flexpanel(element) min height

**Parameters:**  
- `{real} [_min_height]`  


### `setMaxHeight`
Set flexpanel(element) max height

**Parameters:**  
- `{real} [_max_height]`  


### `setMinMaxSize`
Set flexpanel(element) min/max sizes

**Parameters:**  
- `{real} [_min_width]`  
- `{real} [_max_width]`  
- `{real} [_min_height]`  
- `{real} [_max_height]`  


### `setPadding`
Set flexpanel padding

**Parameters:**  
- `{real} _padding`  


### `setGap`
Set flexpanel gap

**Parameters:**  
- `{real} _gap`  


### `setBorder`
Set flexpanel border

**Parameters:**  
- `{real} _border`  


### `setFlexDirection`
Set flexpanel direction (Default: flexpanel_flex_direction.column)

**Parameters:**  
- `{constant.flexpanel_flex_direction} [_direction]`  


### `setFlexWrap`
Set flexpanel wrap type (Default: flexpanel_wrap.no_wrap)

**Parameters:**  
- `{constant.flexpanel_wrap} [_wrap]`  


### `setFlexGrow`
Set flexpanel grow (Default: 1)

**Parameters:**  
- `{real} [_grow]`  


### `setFlexShrink`
Set flexpanel shrink type (Default: 1)

**Parameters:**  
- `{real} [_shrink]`  


### `setFlexJustifyContent`
Set flexpanel justify content (Default: flexpanel_justify.start)
Aligns items along the main axis, controlling horizontal spacing

**Parameters:**  
- `{constant.flexpanel_justify} [_flex_justify]`  


### `setFlexAlignItems`
Set flexpanel align items (Default: flexpanel_align.stretch)
Aligns items along the cross axis, affecting vertical alignment

**Parameters:**  
- `{constant.flexpanel_align} [_flex_align]`  


### `setFlexAlignContent`
Set flexpanel align content (Default: flexpanel_justify.start)
Defines the spacing between flex lines when wrapping occurs.

**Parameters:**  
- `{constant.flexpanel_justify} [_flex_justify]`  


### `setFlexAlignSelf`
Set flexpanel align self (Default: flexpanel_align.auto)
Overrides the container's alignment for this item on the cross axis

**Parameters:**  
- `{constant.flexpanel_align} [_flex_align]`  


### `setFlexDisplay`
Set flexpanel display(flex) or not(none) (Default: flexpanel_display.flex)

**Parameters:**  
- `{constant.flexpanel_display} [_flex_display]`  


### `setContainer`
Set container, Sometimes the container may not be the element itself, but the element inside it (for example: LuiTab, LuiScrollPanel...)


### `setFocus`
setFocus


### `setTooltip`
Set popup text to element when mouse on it


### `bindVariable`
Binds the object/struct variable to the element value


### `setStyle`
Set style


### `setStyleChilds`
Set style for child elements


### `setNeedToUpdateContent`
Set flag to update content


### `setVisible`
Set element visibility (only visibility not flex display)


### `setVisibilitySwitching`
Enable or disable visibility switching by function setVisible()


### `setRenderRegionOffset`
Set offset region for render content

**Parameters:**  
- `{struct, array} _region struct{left, right, top, bottom} or array [left, right, top, bottom]`  


### `setMouseIgnore`
Enables/Disables mouse ignore mode


### `setDepth`



### `bringToFront`



### `flexUpdateAll`
Update position, size and z depth of all elements with depth reset


### `update`
This function updates all nested elements

**Parameters:**  
- `{Any} elements`  


### `render`
This function draws all nested elements


### `centerContent`
Centers the content. Calls setFlexJustifyContent and setFlexAlignItems with centering


### `removeFocus`
Remove focus from element


### `activate`
Activate an element


### `deactivate`
Deactivate an element


### `updateMainUiSurface`
Update main ui surface


### `updateMainUiFlex`
Update main ui flex


### `isMouseHovered`
Returns true if the mouse is hovered over this element


### `isMouseHoveredExc`
Returns true if the mouse is hovered over this element, excluding all elements above it


### `isMouseHoveredParents`
Returns true if the mouse is hovered over this element and its parent


### `isInsideParents`
Returns true if the specified rectangle is within the parent and its parents at the same time


### `isMouseHoveredChilds`
Returns true if the mouse is hovered over the descendants of this element


### `hide`
Set visible to false and flex display to none


### `show`
Set visible to true and flex display to flex


### `destroyContent`
Destroys all nested elements



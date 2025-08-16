# LuiBox

Colored and may be transparent rectangle area.  
**Available parameters:**  
color  
alpha  

## Methods
### `setColor`
Set color for block area (default is c_black)

**Parameters:**  
- `{any} _color`  


### `setAlpha`
Set alpha for block area (default is 0.5)

**Parameters:**  
- `{real} _alpha`  


# LuiButton

It's just a button.  
**Available parameters:**  
text  
color  

## Methods
### `setText`
Set button text

**Parameters:**  
- `{string} _button_text`  


### `setColor`
Set custom button color

**Parameters:**  
- `{any} _button_color`  


### `setIcon`


**Parameters:**  
- `{Asset.GMSprite} _sprite`  
- `{real} _scale`  
- `{real} _angle`  
- `{any} _color`  
- `{real} _alpha`  


# LuiCheckbox

A button with a boolean value, either marked or unmarked.  
**Available parameters:**  
value  
text  

## Methods
### `setText`
Set display text of checkbox (render right of checkbox)

**Parameters:**  
- `{string} _text`  


# LuiComboBox

Drop-down list.  
**Available parameters:**  
placeholder  

## Methods
### `setPlaceholder`
Set placeholder text

**Parameters:**  
- `{string} _placeholder`  


### `toggle`
Toggle combobox open/close


### `addItems`
Add items //???//

**Parameters:**  
- `{struct,array} _items Element or array of elements`  


### `removeItem`
Remove items //???//


### `chooseItem`
Set new combobox text and close combobox

**Parameters:**  
- `{Struct} [_params] Struct with parameters`  


# LuiContainer

An empty, invisible container for elements with padding on the sides for elements with column stacking  
# LuiImage

This item displays the specified sprite with certain settings.  
**Available parameters:**  
value  
subimg  
color  
alpha  
maintain_aspect  

## Methods
### `setSprite`
Set sprite

**Parameters:**  
- `{asset.GMSprite} _sprite`  


### `setSubimg`
Set subimg of sprite

**Parameters:**  
- `{real} _subimg`  


### `setColor`
Set blend color for sprite

**Parameters:**  
- `{any} _color_blend`  


### `setAlpha`
Set alpha for sprite

**Parameters:**  
- `{real} _alpha`  


### `setMaintainAspect`
Set maintain aspect of sprite

**Parameters:**  
- `{bool} _maintain_aspect`  


# LuiImageButton

This item displays the specified sprite with certain settings but works like a button.  
**Available parameters:**  
value  
subimg  
color  
alpha  
maintain_aspect  

# LuiInput

A field for entering text.  
**Available parameters:**  
value  
placeholder  
is_masked (bool, default: false, masks text with dots)  
max_length  
input_mode (LUI_INPUT_MODE: text, password, numbers, sint, letters, alphanumeric)  
excluded_chars (string of forbidden chars, e.g. "!@#")  
allowed_chars (string of allowed chars, e.g. "!@", takes priority over excluded_chars)  

## Methods
### `setText`
Set text

**Parameters:**  
- `{string} _text`  


### `setPlaceholder`
Set placeholder text

**Parameters:**  
- `{string} _placeholder`  


### `setMasked`
Set whether text is masked (displayed as dots)

**Parameters:**  
- `{bool} _is_masked Enable masked mode (true) or show text (false)`  


### `setMaxLength`
Set text max length

**Parameters:**  
- `{real} _max_length`  


### `setInputMode`
Set input mode

**Parameters:**  
- `{real} _mode LUI_INPUT_MODE`  


### `setExcludedChars`
Set excluded characters (string)

**Parameters:**  
- `{string} _chars Forbidden chars, e.g. "!@#"`  


### `setAllowedChars`
Set allowed characters (string)

**Parameters:**  
- `{string} _chars Allowed chars, e.g. "!@", takes priority over excluded_chars`  


### `setIncorrect`
Set whether input is marked as incorrect (affects border, background, and placeholder color)

**Parameters:**  
- `{bool} _is_incorrect Mark input as incorrect (true) or not (false)`  


### `getReal`
Return real number or _default_value

**Parameters:**  
- `{real} [_default_value] Value to return if string is not a valid number, default is 0`  

**Returns:**  
- `{real}`  

# LuiMain

Main UI container which would control and render your UI.  
## Methods
### `animate`
Create animation for any variables of target element


### `displayFocusedElement`
Set flag to display or not display white rectangle on focused element

**Parameters:**  
- `{bool} _display`  


### `isInteracting`
Return true if we interacting with UI at the moment with mouse or keyboard

**Returns:**  
- `{bool}`  

### `isInteractingMouse`
Return true if we interacting with UI at the moment with mouse

**Returns:**  
- `{bool}`  

### `isInteractingKeyboard`
Return true if we interacting with UI at the moment with keyboard

**Returns:**  
- `{bool}`  

### `getElement`
Get element by name

**Returns:**  
- `{Struct}`  

# LuiPanel

A visually visible container for placing elements in it.  
**Available parameters:**  
allow_rescaling  

# LuiProgressBar

A progress bar for display loading/filling anything  
**Available parameters:**  
value  
min_value  
max_value  
rounding  
display_value  
bar_height  

## Methods
### `setMinValue`
Set min value

**Parameters:**  
- `{real} _min_value`  


### `setMaxValue`
Set max value

**Parameters:**  
- `{real} _max_value`  


### `setDisplayValue`
Set state of value (show/hide)

**Parameters:**  
- `{bool} _display_value True - show value, False - hide value`  


### `setRounding`
Sets the rounding rule for the value (0 - no rounding, 0.1 - round to tenths...).

**Parameters:**  
- `{real} _rounding`  


### `setBarHeight`
Sets bar height

**Parameters:**  
- `{real} _height`  


# LuiProgressRing

A progress ring for display loading/filling anything  
**Available parameters:**  
value  
min_value  
max_value  
rounding  
display_value  
bar_height  

# LuiScrollPanel

Panel with the ability to scroll down/up.  
## Methods
### `cleanScrollPanel`
Delete scroll panel content


# LuiSlider

Slider with a limited value from and to, e.g. to change the volume.  
**Available parameters:**  
value  
min_value  
max_value  
rounding  
display_value  
bar_height  
knob_extender  

# LuiSurface

This element displays the specified surface with certain settings.  
**Available parameters:**  
value  
color  
alpha  
maintain_aspect  

## Methods
### `setSurface`
Set surface id

**Parameters:**  
- `{id.Surface} _surface`  


### `setColor`
Set blend color

**Parameters:**  
- `{any} _color_blend`  


### `setAlpha`
Set alpha

**Parameters:**  
- `{real} _alpha`  


### `setMaintainAspect`
Set maintain aspect of surface

**Parameters:**  
- `{bool} _maintain_aspect`  


### `updateSurface`
Update surface if visible (should be called from main object where you draw surface)


# LuiTabs

Panel with tabs  
**Available parameters:**  
tab_height  
tab_indent  

## Methods
### `setTabHeight`
Set tabs height

**Parameters:**  
- `{real} _tab_height`  


### `setTabIndent`
Set tabs indent

**Parameters:**  
- `{real} _tab_indent`  


### `addTabs`
Add LuiTab's

**Parameters:**  
- `{struct,array} _tabs`  


### `switchTab`
Switch tab to another


### `tabDeactivateAll`
Deactivate all tabs


### `removeTab`
Removes tab (WIP)


### `setActiveState`
Set active state of tab

**Parameters:**  
- `{bool} _is_active`  


### `tabActivate`
Activate current tab


### `tabDeactivate`
Deactivate current tab


# LuiText

Just a text.  
**Available parameters:**  
value  
text_halign  
text_valign  
scale_to_fit  

## Methods
### `setText`
Set text

**Parameters:**  
- `{string} _text`  


### `setTextHalign`
Set horizontal aligment of text.

**Parameters:**  
- `{constant.HAlign} _halign`  


### `setTextValign`
Set vertical aligment of text.

**Parameters:**  
- `{constant.VAlign} _valign`  


### `setScaleToFit`
Set scale to fit text

**Parameters:**  
- `{bool} _scale_to_fit True is scale text to fit element size`  


# LuiToggleButton

Works like checkbox or switch, lights with accent color when value true  
**Available parameters:**  
text  
color  
value  

# LuiToggleSwitch

A switch in the form of a small slider that can be in the on and off position  
**Available parameters:**  
text  
value  

## Methods
### `setText`
Set display text (render right of element)

**Parameters:**  
- `{string} _text`  


# LuiTween

A Tween object that handles animating a single property of an element.  
## Methods
### `update`
Updates the animation state. Returns true if still running.


# LuiWindow

A draggable window with a header, similar to Windows windows  
**Available parameters:**  
title  

## Methods
### `setTitle`
Set window title

**Parameters:**  
- `{string} _title`  


### `toggleWindow`
Toggle window show or hide


### `closeWindow`
Destroy window



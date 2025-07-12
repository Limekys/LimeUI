///@desc A Tween object that handles animating a single property of an element.
///@arg {Struct.LuiBase} target_element The element to animate.
///@arg {String} property The name of the property to animate (e.g., "slider_x", "alpha").
///@arg {Real} end_value The target value of the property.
///@arg {Real} duration The duration of the animation in seconds.
function LuiTween(target_element, property, end_value, duration) constructor {
    self.target = target_element;
    self.property = property;
    self.start_value = target_element[$ property];
    self.end_value = end_value;
    self.duration = duration;
    self.elapsed_time = 0;
    self.is_finished = false;
	self.progress = 0;

    ///@desc Updates the animation state. Returns true if still running.
    static update = function(delta_time) {
        // Increment time by delta time
        self.elapsed_time += delta_time;
		
        // Calcultate porgress
        //var _progress = clamp(self.elapsed_time / self.duration, 0, 1);
        self.progress = SmoothApproachDelta(self.progress, 1, self.duration);
        
        // Calculate new value with easing
		var _new_value = lerp(self.start_value, self.end_value, self.progress);
        
        // Apply new value to variable
        self.target[$ self.property] = _new_value;
        
        // Check if end
        if (self.progress >= 1) {
            self.is_finished = true;
            return false; // Animation ended
        }
        
        return true; // Continue animation
    }
}
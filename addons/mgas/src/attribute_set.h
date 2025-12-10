#ifndef ATTRIBUTE_SET_H
#define ATTRIBUTE_SET_H

#include <godot_cpp/classes/resource.hpp>
#include <godot_cpp/core/binder_common.hpp>

namespace godot {

// Helper struct to manage Base vs Current value
struct FGameplayAttributeData {
    float base_value = 0.0f;
    float current_value = 0.0f;

    FGameplayAttributeData() {}
    FGameplayAttributeData(float val) : base_value(val), current_value(val) {}

    void set_base_value(float val) {
        base_value = val;
        current_value = val; // Reset current when base changes (simplistic MVP)
    }
    
    float get_current_value() const {
        return current_value;
    }
};

class MachiAttributeSet : public Resource {
    GDCLASS(MachiAttributeSet, Resource);

protected:
    static void _bind_methods();

public:
    MachiAttributeSet();
    ~MachiAttributeSet();

    // Generic Accessor
    // In a real system, attributes are properties, but for MVP we might map strings.
    // However, to follow the plan, let's implement the specific logic in derived classes
    // or provide a generic way to access property by name.
    
    virtual void pre_attribute_change(const StringName &attribute, float &new_value);
    virtual void post_attribute_change(const StringName &attribute, float old_value, float new_value);
    
    // For MVP, we will assume attributes are usually specifically defined in derived C++ classes,
    // but we need a generic way for GDScript to read them if they are Dynamic.
    // Let's implement a Dictionary-based backup for prototyping if fields don't exist?
    // Or better: Assume Godot's get() set() system handles it if properties are exported.
};

} // namespace godot

#endif // ATTRIBUTE_SET_H

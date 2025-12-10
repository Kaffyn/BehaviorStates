#ifndef MACHI_GAMEPLAY_EFFECT_H
#define MACHI_GAMEPLAY_EFFECT_H

#include <godot_cpp/classes/resource.hpp>
#include <godot_cpp/core/binder_common.hpp>
#include "gameplay_tag_container.h"

namespace godot {

enum EGameplayModOp {
    Add = 0,
    Multiply = 1,
    Divide = 2,
    Override = 3
};

struct FGameplayModifierInfo {
    StringName attribute_name;
    EGameplayModOp operation;
    float value;

    // TODO: Custom execution calculation class reference
};

class MachiGameplayEffect : public Resource {
    GDCLASS(MachiGameplayEffect, Resource);

protected:
    static void _bind_methods();

public:
    MachiGameplayEffect();
    ~MachiGameplayEffect();

    // Duration Policy
    float duration_seconds; // 0 = Instant, -1 = Infinite
    float period_seconds;   // 0 = No period

    // Modifiers
    // Using Array of Dictionaries for MVP editor friendliness, 
    // but internally mapped to struct logic.
    Array modifiers; 
    
    // Tags
    Ref<GameplayTagContainer> granted_tags;
    Ref<GameplayTagContainer> application_required_tags;

    // Getters/Setters
    void set_duration(float p_duration);
    float get_duration() const;
    
    void set_modifiers(const Array &p_modifiers);
    Array get_modifiers() const;
    
    void set_granted_tags(const Ref<GameplayTagContainer> &p_tags);
    Ref<GameplayTagContainer> get_granted_tags() const;
};

} // namespace godot

VARIANT_ENUM_CAST(EGameplayModOp); // Register Enum

#endif // MACHI_GAMEPLAY_EFFECT_H

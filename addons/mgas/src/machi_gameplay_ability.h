#include <godot_cpp/classes/resource.hpp>
#include "gameplay_tag_container.h"

namespace godot {

class MachiGameplayAbility : public Resource {
    GDCLASS(MachiGameplayAbility, Resource);

protected:
    static void _bind_methods();

public:
    MachiGameplayAbility();
    ~MachiGameplayAbility();
    
    // Virtual Methods (Overridable by GDScript)
    virtual bool _can_activate_ability();
    virtual void _activate_ability();
    virtual void _end_ability();

    // Helper (API for GDScript to call back to C++)
    void end_ability();
    void cancel_ability();
    bool commit_ability();

    // Editor Properties
    void set_ability_tags(const Ref<GameplayTagContainer> &p_tags);
    Ref<GameplayTagContainer> get_ability_tags() const;

private:
    Ref<GameplayTagContainer> ability_tags;
    // Ref<MachiGameplayEffect> cost_effect; // TODO: Uncomment when GE class handles exist
    // Ref<MachiGameplayEffect> cooldown_effect;

} // namespace godot

#endif // MACHI_GAMEPLAY_ABILITY_H

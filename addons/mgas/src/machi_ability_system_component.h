#include <godot_cpp/classes/node.hpp>
#include <godot_cpp/core/binder_common.hpp>
#include "gameplay_tag_container.h"

namespace godot {

class MachiAbilitySystemComponent : public Node {
    GDCLASS(MachiAbilitySystemComponent, Node);

protected:
    static void _bind_methods();

public:
    MachiAbilitySystemComponent();
    ~MachiAbilitySystemComponent();

    // Core API
    bool try_activate_ability(const StringName &tag);
    
    // Tag API
    bool has_tag(const StringName &tag) const;
    void add_loose_tag(const StringName &tag);
    void remove_loose_tag(const StringName &tag);

private:
   Ref<GameplayTagContainer> owned_tags;
   // TArray<MachiGameplayAbility*> active_abilities; - In Godot we normally just use children or Ref<>
};

} // namespace godot

#endif // MACHI_ABILITY_SYSTEM_COMPONENT_H

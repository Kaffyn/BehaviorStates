#include "machi_ability_system_component.h"
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

MachiAbilitySystemComponent::MachiAbilitySystemComponent() {
    owned_tags.instantiate();
}

MachiAbilitySystemComponent::~MachiAbilitySystemComponent() {
}

void MachiAbilitySystemComponent::_bind_methods() {
    ClassDB::bind_method(D_METHOD("try_activate_ability", "tag"), &MachiAbilitySystemComponent::try_activate_ability);
    ClassDB::bind_method(D_METHOD("has_tag", "tag"), &MachiAbilitySystemComponent::has_tag);
    ClassDB::bind_method(D_METHOD("add_loose_tag", "tag"), &MachiAbilitySystemComponent::add_loose_tag);
    ClassDB::bind_method(D_METHOD("remove_loose_tag", "tag"), &MachiAbilitySystemComponent::remove_loose_tag);

    ADD_SIGNAL(MethodInfo("tag_added", PropertyInfo(Variant::STRING_NAME, "tag")));
    ADD_SIGNAL(MethodInfo("tag_removed", PropertyInfo(Variant::STRING_NAME, "tag")));
}

bool MachiAbilitySystemComponent::try_activate_ability(const StringName &tag) {
    UtilityFunctions::print("MachiASC: Trying to activate ability with tag: ", tag);
    
    // 1. Check if ability exists (Mock logic for now)
    // 2. Check costs
    // 3. Check cooldowns
    // 4. Activate
    return true;
}

bool MachiAbilitySystemComponent::has_tag(const StringName &tag) const {
    return owned_tags->has_tag(tag);
}

void MachiAbilitySystemComponent::add_loose_tag(const StringName &tag) {
    if (!owned_tags->has_tag(tag)) {
        owned_tags->add_tag(tag);
        emit_signal("tag_added", tag);
    }
}

void MachiAbilitySystemComponent::remove_loose_tag(const StringName &tag) {
     if (owned_tags->has_tag(tag)) {
        owned_tags->remove_tag(tag);
        emit_signal("tag_removed", tag);
    }
}

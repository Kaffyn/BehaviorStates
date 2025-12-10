#include "machi_gameplay_ability.h"
#include <godot_cpp/variant/utility_functions.hpp>
#include <godot_cpp/core/class_db.hpp>

using namespace godot;

MachiGameplayAbility::MachiGameplayAbility() {
}

MachiGameplayAbility::~MachiGameplayAbility() {
}

void MachiGameplayAbility::_bind_methods() {
    // Registra métodos virtuais que o GDScript pode sobrescrever
    GDVIRTUAL_BIND(_can_activate_ability);
    GDVIRTUAL_BIND(_activate_ability);
    GDVIRTUAL_BIND(_end_ability);

    // Registra métodos que o GDScript pode chamar
    ClassDB::bind_method(D_METHOD("end_ability"), &MachiGameplayAbility::end_ability);
    ClassDB::bind_method(D_METHOD("cancel_ability"), &MachiGameplayAbility::cancel_ability);
    ClassDB::bind_method(D_METHOD("commit_ability"), &MachiGameplayAbility::commit_ability);
    
    // Properties
    ClassDB::bind_method(D_METHOD("set_ability_tags", "tags"), &MachiGameplayAbility::set_ability_tags);
    ClassDB::bind_method(D_METHOD("get_ability_tags"), &MachiGameplayAbility::get_ability_tags);
    
    ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "ability_tags", PROPERTY_HINT_RESOURCE_TYPE, "GameplayTagContainer"), "set_ability_tags", "get_ability_tags");
}

void MachiGameplayAbility::set_ability_tags(const Ref<GameplayTagContainer> &p_tags) {
    ability_tags = p_tags;
}

Ref<GameplayTagContainer> MachiGameplayAbility::get_ability_tags() const {
    return ability_tags;
}

bool MachiGameplayAbility::_can_activate_ability() {
    // Default implementation returns true.
    // GDScript can override logic.
    return true; 
}

void MachiGameplayAbility::_activate_ability() {
    // Default implementation does nothing.
}

void MachiGameplayAbility::_end_ability() {
    // Cleanup logic
}

void MachiGameplayAbility::end_ability() {
    // Notify ASC that we are done
    UtilityFunctions::print("MachiGA: Ending Ability");
    // Call virtual cleanup
    // if (GDVIRTUAL_CALL(_end_ability)) ... in reality we call the method logic here
}

void MachiGameplayAbility::cancel_ability() {
    UtilityFunctions::print("MachiGA: Canceling Ability");
    end_ability();
}

bool MachiGameplayAbility::commit_ability() {
    UtilityFunctions::print("MachiGA: Committing Ability (Cost/Cooldown)");
    return true;
}

#include "machi_gameplay_effect.h"

using namespace godot;

MachiGameplayEffect::MachiGameplayEffect() {
    duration_seconds = 0.0f;
    period_seconds = 0.0f;
    granted_tags.instantiate();
    application_required_tags.instantiate();
}

MachiGameplayEffect::~MachiGameplayEffect() {
}

void MachiGameplayEffect::_bind_methods() {
    // Duration
    ClassDB::bind_method(D_METHOD("set_duration", "duration"), &MachiGameplayEffect::set_duration);
    ClassDB::bind_method(D_METHOD("get_duration"), &MachiGameplayEffect::get_duration);
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "duration_seconds"), "set_duration", "get_duration");

    // Modifiers
    ClassDB::bind_method(D_METHOD("set_modifiers", "modifiers"), &MachiGameplayEffect::set_modifiers);
    ClassDB::bind_method(D_METHOD("get_modifiers"), &MachiGameplayEffect::get_modifiers);
    ADD_PROPERTY(PropertyInfo(Variant::ARRAY, "modifiers"), "set_modifiers", "get_modifiers");

    // Tags
    ClassDB::bind_method(D_METHOD("set_granted_tags", "tags"), &MachiGameplayEffect::set_granted_tags);
    ClassDB::bind_method(D_METHOD("get_granted_tags"), &MachiGameplayEffect::get_granted_tags);
    ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "granted_tags", PROPERTY_HINT_RESOURCE_TYPE, "GameplayTagContainer"), "set_granted_tags", "get_granted_tags");

    // Enums
    BIND_ENUM_CONSTANT(Add);
    BIND_ENUM_CONSTANT(Multiply);
    BIND_ENUM_CONSTANT(Divide);
    BIND_ENUM_CONSTANT(Override);
}

void MachiGameplayEffect::set_duration(float p_duration) {
    duration_seconds = p_duration;
}

float MachiGameplayEffect::get_duration() const {
    return duration_seconds;
}

void MachiGameplayEffect::set_modifiers(const Array &p_modifiers) {
    modifiers = p_modifiers;
}

Array MachiGameplayEffect::get_modifiers() const {
    return modifiers;
}

void MachiGameplayEffect::set_granted_tags(const Ref<GameplayTagContainer> &p_tags) {
    granted_tags = p_tags;
}

Ref<GameplayTagContainer> MachiGameplayEffect::get_granted_tags() const {
    return granted_tags;
}

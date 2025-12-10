#include "attribute_set.h"
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

MachiAttributeSet::MachiAttributeSet() {
}

MachiAttributeSet::~MachiAttributeSet() {
}

void MachiAttributeSet::_bind_methods() {
    GDVIRTUAL_BIND(pre_attribute_change, "attribute", "new_value");
    GDVIRTUAL_BIND(post_attribute_change, "attribute", "old_value", "new_value");
}

void MachiAttributeSet::pre_attribute_change(const StringName &attribute, float &new_value) {
    // Default: Calls GDScript implementation if exists
    float res = new_value;
    if (GDVIRTUAL_CALL(pre_attribute_change, attribute, res, res)) {
        new_value = res;
    }
}

void MachiAttributeSet::post_attribute_change(const StringName &attribute, float old_value, float new_value) {
    // Default: Calls GDScript implementation if exists
    GDVIRTUAL_CALL(post_attribute_change, attribute, old_value, new_value);
}

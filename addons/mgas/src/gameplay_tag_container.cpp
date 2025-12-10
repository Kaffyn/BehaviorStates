#include "gameplay_tag_container.h"
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

GameplayTagContainer::GameplayTagContainer() {
}

GameplayTagContainer::~GameplayTagContainer() {
}

void GameplayTagContainer::_bind_methods() {
    ClassDB::bind_method(D_METHOD("add_tag", "tag_name"), &GameplayTagContainer::add_tag);
    ClassDB::bind_method(D_METHOD("remove_tag", "tag_name"), &GameplayTagContainer::remove_tag);
    ClassDB::bind_method(D_METHOD("has_tag", "tag_name"), &GameplayTagContainer::has_tag);
    ClassDB::bind_method(D_METHOD("has_any", "other_tags"), &GameplayTagContainer::has_any);
    ClassDB::bind_method(D_METHOD("has_all", "other_tags"), &GameplayTagContainer::has_all);
    ClassDB::bind_method(D_METHOD("reset"), &GameplayTagContainer::reset);
    ClassDB::bind_method(D_METHOD("size"), &GameplayTagContainer::size);
    ClassDB::bind_method(D_METHOD("get_all_tags"), &GameplayTagContainer::get_all_tags);
}

void GameplayTagContainer::add_tag(const StringName &tag_name) {
    if (!tags.has(tag_name)) {
        tags.append(tag_name);
    }
}

void GameplayTagContainer::remove_tag(const StringName &tag_name) {
    int index = tags.find(tag_name);
    if (index != -1) {
        tags.remove_at(index);
    }
}

bool GameplayTagContainer::has_tag(const StringName &tag_name) const {
    // In a real hierarchical system, this would check A.B.C against A.B
    // For MVP string comparison:
    // TODO: implement hierarchical check (e.g. tag_name="A.B" has_tag("A") should be true?) 
    // Usually has_tag("A.B") means "Do I have A.B explicitly?". 
    // Protocol: Exact match for now.
    return tags.has(tag_name);
}

bool GameplayTagContainer::has_any(const Array &other_tags) const {
    for (int i = 0; i < other_tags.size(); i++) {
        if (has_tag(other_tags[i])) {
            return true;
        }
    }
    return false;
}

bool GameplayTagContainer::has_all(const Array &other_tags) const {
    if (other_tags.size() == 0) return true;
    
    for (int i = 0; i < other_tags.size(); i++) {
        if (!has_tag(other_tags[i])) {
            return false;
        }
    }
    return true;
}

void GameplayTagContainer::reset() {
    tags.clear();
}

int GameplayTagContainer::size() const {
    return tags.size();
}

Array GameplayTagContainer::get_all_tags() const {
    return tags.duplicate();
}

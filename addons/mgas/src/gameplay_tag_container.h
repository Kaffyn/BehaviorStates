#ifndef GAMEPLAY_TAG_CONTAINER_H
#define GAMEPLAY_TAG_CONTAINER_H

#include <godot_cpp/variant/string_name.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/array.hpp>
#include <godot_cpp/classes/ref_counted.hpp>

namespace godot {

// Simple wrapper around integer ID for tags
// In a full implementation, this would handle string->int mapping registry.
// For this MVP, we will treat StringName hash as the ID for simplicity and speed.
struct FGameplayTag {
    uint32_t id;
    StringName debug_name;

    bool operator==(const FGameplayTag &other) const {
        return id == other.id;
    }
    
    bool is_valid() const { return id != 0; }
};

class GameplayTagContainer : public RefCounted {
    GDCLASS(GameplayTagContainer, RefCounted);

protected:
    static void _bind_methods();

private:
    // Using Array for storage in MVP.
    // In production, this should be a TSet or bitmask.
    Array tags; 

public:
    GameplayTagContainer();
    ~GameplayTagContainer();

    void add_tag(const StringName &tag_name);
    void remove_tag(const StringName &tag_name);
    
    bool has_tag(const StringName &tag_name) const;
    bool has_any(const Array &other_tags) const;
    bool has_all(const Array &other_tags) const;
    
    void reset();
    int size() const;
    
    Array get_all_tags() const;
};

} // namespace godot

#endif // GAMEPLAY_TAG_CONTAINER_H

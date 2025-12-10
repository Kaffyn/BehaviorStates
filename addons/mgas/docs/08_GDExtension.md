# GDExtension Setup — O Motor C++

> **Propósito:** Guia prático para compilar, configurar e estender o núcleo C++ do MGAS.

---

## 1. Estrutura de Diretórios C++

Para manter o plugin organizado, a parte C++ vive na pasta `src/` fora de `addons/` (ou dentro, dependendo do gosto, mas isolada), e apenas os binários compilados vão para `addons/mgas/bin/`.

```text
behavior_states/
├── SConstruct              # Build script (Python)
├── src/
│   ├── mgas_register_types.cpp
│   ├── mgas_register_types.h
│   ├── ability_system_component.cpp
│   ├── ability_system_component.h
│   ├── gameplay_ability.cpp
│   ├── gameplay_effect.cpp
│   ├── attribute_set.cpp
│   └── tags/
│       └── gameplay_tag_container.cpp
├── godot-cpp/              # Submódulo C++ Bindings
└── addons/
    └── mgas/
        ├── mgas.gdextension # Arquivo de configuração
        └── bin/
            ├── libmgas.windows.template_debug.x86_64.dll
            └── libmgas.linux.template_debug.x86_64.so
```

---

## 2. Configurando o `SConstruct`

O arquivo scons deve apontar para as bindings e definir as flags de compilação.
Para MGAS, usamos flags de otimização agressivas em Release, mas mantemos símbolos de debug em Dev.

```python
# snippet do SConstruct
env.Append(CPPDEFINES=["MGAS_ENABLED"])
# Otimização para Tags (Fast Hashing)
env.Append(CCFLAGS=["/O2", "/Ob2"]) # MSVC
```

---

## 3. Registrando Tipos (`register_types.cpp`)

Para que `GameplayAbility` apareça no editor GDScript (`class_name` ou `@GlobalScope`), eles devem ser registrados no `ClassDB`.

```cpp
#include "register_types.h"
#include "ability_system_component.h"
#include "gameplay_ability.h"
#include "gameplay_effect.h"
#include "attribute_set.h"

#include <gdextension_interface.h>
#include <godot_cpp/core/defs.hpp>
#include <godot_cpp/godot.hpp>

using namespace godot;

void initialize_mgas_module(ModuleInitializationLevel p_level) {
    if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
        return;
    }

    // Registra Classes
    ClassDB::register_class<MachiAbilitySystemComponent>();
    ClassDB::register_class<MachiGameplayAbility>();
    ClassDB::register_class<MachiGameplayEffect>();
    ClassDB::register_class<MachiAttributeSet>();
}

void uninitialize_mgas_module(ModuleInitializationLevel p_level) {
    if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
        return;
    }
}
```

---

## 4. O Arquivo `.gdextension`

Define onde a Godot encontra os binários.

```ini
[configuration]
entry_symbol = "mgas_library_init"
compatibility_minimum = "4.2"

[libraries]
windows.debug.x86_64 = "res://addons/mgas/bin/libmgas.windows.template_debug.x86_64.dll"
windows.release.x86_64 = "res://addons/mgas/bin/libmgas.windows.template_release.x86_64.dll"
linux.debug.x86_64 = "res://addons/mgas/bin/libmgas.linux.template_debug.x86_64.so"
```

---

## 5. Expondo Métodos para GDScript

No header `.h`, use macro `GDCLASS` e no `.cpp` use `_bind_methods`.

```cpp
// ability_system_component.cpp
void MachiAbilitySystemComponent::_bind_methods() {
    ClassDB::bind_method(D_METHOD("try_activate_ability", "tag"), &MachiAbilitySystemComponent::TryActivateAbility);

    // Sinais
    ADD_SIGNAL(MethodInfo("tag_added", PropertyInfo(Variant::STRING_NAME, "tag")));
}
```

---

_MGAS — GDExtension v1.0_

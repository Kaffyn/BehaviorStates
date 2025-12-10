# GDExtension Setup

Como compilar e configurar o ambiente C++.

## Pré-requisitos

- SCons
- Compilador C++ (MSVC, GCC, Clang)
- Godot cpp bindings

## Compilação

```bash
scons platform=windows target=template_debug
```

## Estrutura

O plugin carrega a DLL/Shared Library gerada e expõe os tipos `ClassDB` para o GDScript.

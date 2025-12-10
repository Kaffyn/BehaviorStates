# Arquitetura MGAS

O MGAS é construído sobre uma arquitetura híbrida C++ / GDScript.

## Core (C++)

Responsável por:

- Replicação de Rede
- Gerenciamento de Tags (GameplayTagContainer)
- AttributeSet (Memória contígua para floats)
- Tick de Cooldowns

## Scripting (GDScript)

Responsável por:

- Lógica de Gameplay (Abilities)
- Configuração de Dados (Resources)
- Interação com UI

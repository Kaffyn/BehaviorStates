# Padrões de Código & Boas Práticas

> **Regra:** Código Limpo e Estrito é Lei.

## 1. GDScript: Tipagem Estrita
GDScript é dinâmico, mas nós NÃO SOMOS.
- **Sempre tipe variáveis:** `var health: int = 100` (Nunca `var health = 100`).
- **Sempre tipe funções:** `func take_damage(amount: int) -> bool:` (O retorno é crucial).
- **Use `as` para Casting Seguro:** `var enemy := body as Enemy`.

## 2. Nomenclatura (Convenções Godot)
- **Arquivos/Pastas:** `snake_case` (`player_controller.gd`).
- **Classes/Tipos:** `PascalCase` (`EnemyStats`).
- **Variáveis/Funções:** `snake_case` (`current_health`).
- **Privadas:** `_snake_case` (`_internal_cache`).
- **Constantes:** `SCREAMING_SNAKE` (`MAX_SPEED`).

## 3. Segurança de Sinais
- **Call Down:** O Pai chama função no Filho (`$Gun.shoot()`).
- **Signal Up:** O Filho emite sinal para o Pai (`signal ammo_depleted`).
- **Nunca:** O Filho acessa o pai (`get_parent()`). Isso cria acoplamento reverso.

## 4. Singletons (Global)
Use com EXTRAMA moderação.
- **Permitido:** Managers de sistema (`SoundManager`, `SaveSystem`).
- **Proibido:** Variáveis de gameplay (`PlayerHP`). Use Resources ou EventBus.

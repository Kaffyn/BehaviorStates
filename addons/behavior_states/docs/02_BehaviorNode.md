# Behavior Node — O Cérebro

O Node `Behavior` é o ponto de entrada de dados do personagem.

## 1. Responsabilidades

1. **Context Store:** Mantém o dicionário de contexto (`{"Motion": WALKING, "Weapon": SWORD}`).
2. **Intent Translation:** Recebe inputs brutos e os converte em contexto semântico.
3. **Stat Management:** Gerencia `CharacterSheet` (HP, Mana, Str).
4. **Signal Bus:** Centraliza sinais como `context_changed`, `stat_changed`.

## 2. Contexto

O BehaviorStates não usa Strings soltas. Usa **Enums Mapeados**.

- `Motion.IDLE`, `Motion.RUN`
- `Attack.NONE`, `Attack.LIGHT`

## 3. Integração

```gdscript
# No Player.gd
func _physics_process(delta):
    var input = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

    if input.length() > 0:
        behavior.set_context("Motion", Motion.RUN)
    else:
        behavior.set_context("Motion", Motion.IDLE)
```

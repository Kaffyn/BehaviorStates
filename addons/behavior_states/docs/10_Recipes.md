# Recipes & Patterns — Receitas Comuns

## 1. Combo System (Ataque Leve -> Pesado)

1. Crie `Attack1.tres` e `Attack2.tres`.
2. No `Attack1`, adicione um `ComboComponent`.
   - Defina `NextState: Attack2`.
   - Defina `WindowStart: 0.5s` e `WindowEnd: 1.0s`.
3. Se jogador apertar ataque nessa janela, o Component emite `combo_available`.
4. A Machine dá um Boost de Score para `Attack2`.

## 2. Carregar Ataque (Charge)

1. Crie `ChargeState` (Sticky) e `ReleaseState`.
2. `ChargeState` requer `Input: Attack (Pressed)`.
3. `ReleaseState` requer `Input: Attack (Released)`.
4. A transição é natural: assim que soltar o botão, o Contexto muda, e a Machine seleciona o Release.

## 3. Escada (Ladders)

1. Use `Area2D` na escada.
2. Ao entrar, sete `Context: Wall = LADDER`.
3. Crie `ClimbState` que requer `Wall: LADDER`.
4. Assim que entrar na área, o personagem começa a escalar automaticamente se `ClimbState` tiver score alto.

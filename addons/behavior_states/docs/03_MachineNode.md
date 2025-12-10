# Machine Node — O Motor

A `Machine` é o executor. Ela não decide "o que eu quero fazer" (isso é o Behavior), ela decide "qual a melhor forma de atender esse pedido".

## 1. O Loop de Decisão

1. Ouve `behavior.context_changed`.
2. Chama `_try_transition()`.
3. Filtra estados possíveis no `Compose` atual.
4. Roda algoritmo de Score.
5. Se o vencedor for diferente do atual, troca.

## 2. Injeção de Dependências

Quando um State roda, ele precisa acessar o Player, o Sprite, o AudioStreamPlayer.
A Machine cria um objeto `StateContext` e injeta essas referências.

## 3. Cooldowns

A Machine gerencia o tempo de recarga dos estados.
`is_state_available(state)` verifica se o cooldown expirou.

## 4. Sticky States

Estados marcados como `Sticky` (ex: Ataque, Pulo) não podem ser interrompidos por mudança de contexto até terminarem (ou serem cancelados explicitamente).

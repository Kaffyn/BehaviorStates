# Gameplay Abilities (GA)

A unidade atômica de ação.

## Ciclo de Vida

1. **CanActivate**: Verifica custos (Mana, Stamina) e Tags (posso castar enquanto Stunned?).
2. **Activate**: Roda a lógica (Animation, Spawn Projectile).
3. **Commit**: Deduz os recursos e inicia o cooldown.
4. **End**: Limpeza.

## Tasks

As habilidades usam **AbilityTasks** para esperar eventos assíncronos, como "Wait for Input Release" ou "Wait for Animation Event".

# Gameplay Effects (GE)

O motor de mutação de estado.

## Tipos de Duração

- **Instant**: Aplica a mudança imediatamente (Dano, Cura).
- **Infinite**: Dura até ser removido (Equipamento, Passive).
- **HasDuration**: Dura um tempo fixo (Buff, Debuff).

## Modificadores

- **Add**: `Valor += X`
- **Multiply**: `Valor *= X`
- **Override**: `Valor = X`

## Stacking

Regras configuráveis para quando múltiplos efeitos iguais são aplicados (substituir, somar duração, ignorar).

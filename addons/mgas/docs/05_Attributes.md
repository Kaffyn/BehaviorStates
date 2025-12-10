# Attributes & AttributeSets

Dados numéricos replicados e de alta performance.

## AttributeSet

Uma classe C++ que define um conjunto de atributos.
Ex: `HealthSet` (Health, MaxHealth, Regen).

## Base vs Current

- **BaseValue**: O valor "real" permanente (ex: 100 de vida máxima).
- **CurrentValue**: O valor após modificadores temporários (ex: 100 + 10 do buff = 110).

## Derived Attributes

Atributos calculados automaticamente a partir de outros (ex: `AttackPower = Strength * 2`).

# Gameplay Tags

O sistema nervoso do MGAS.

## O que são?

Tags são identificadores hierárquicos usados para classificar e consultar estado.
Ex: `State.Debuff.Stun`, `Element.Fire`, `Weapon.Sword`.

## Tags vs Enums

- Enums são rígidos e planos.
- Tags são hierárquicas e expansíveis sem recompilar o C++.
- Tags suportam queries complexas: "Tenho alguma tag filha de `Debuff`?"

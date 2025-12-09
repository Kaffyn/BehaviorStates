## EffectContext — Contexto de execução para EffectComponents.
##
## Fornece acesso ao alvo do efeito e informações de stacking.
class_name EffectContext extends RefCounted

## Referência ao efeito sendo aplicado
var effect: Resource = null

## Referência ao CharacterSheet do alvo
var target: Resource = null

## Número atual de stacks deste efeito
var stacks: int = 1

## Tempo restante do efeito (para temporários)
var remaining_time: float = 0.0

## Acumulador de tick
var tick_timer: float = 0.0

## Referência ao Behavior do alvo (para sinais)
var behavior: Node = null

## Inicializa o contexto
func setup(p_effect: Resource, p_target: Resource, p_behavior: Node = null) -> void:
	effect = p_effect
	target = p_target
	behavior = p_behavior

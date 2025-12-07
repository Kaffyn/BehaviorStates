## A Engine de Estados e Virtual Machine.
##
## Executa queries de decisão O(1) solicitando ao Compose "quais estados servem para este contexto".

class_name Machine extends Node

# A Engine de Estados
# Query Engine: Solicita ao Compose "Quais estados servem para o contexto X?"
# Não sabe o que é "Input", apenas obedece ao Contexto definido pelo Behavior.

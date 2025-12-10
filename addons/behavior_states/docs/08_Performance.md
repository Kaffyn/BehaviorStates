# Inverted Index — Otimização O(1)

Como a Machine acha o estado certo entre 500 opções sem matar a CPU?

## 1. O Problema da Lista Linear

Iterar `for state in all_states: check_requirements()` é **O(N)**.
Se tivermos 1000 estados e 50 bonecos, são 50.000 checks por frame. Inviável.

## 2. A Solução: HashMap Invertido

Ao equipar um `Compose`, criamos um índice:

```gdscript
_index = {
    "Motion": {
        RUN: [RunState, DashState, SlideState],
        IDLE: [IdleState, LookAroundState]
    },
    "Attack": {
        ACC: [Attack1, Attack2] # Attack que requer inputs específicos
    }
}
```

## 3. O Lookup O(K)

A Machine só olha o Contexto atual.
Se Contexto é `Motion: RUN`, ela vai direto em `_index["Motion"][RUN]`.
A complexidade cai para **O(K)**, onde K é o número de categorias no contexto (geralmente < 5).

Isso garante performance AAA escalável.

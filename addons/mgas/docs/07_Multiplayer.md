# Multiplayer & Networking — Engenharia de Rede

> **Propósito:** Explicar como o MGAS lida com replicação, previsão do cliente (Prediction) e autoridade do servidor.

---

## 1. O Modelo Autoritativo (Server-Authoritative)

O servidor é Deus. O cliente é apenas uma "janela" que envia intenções.
No entanto, esperar 200ms (ping) para ver seu boneco pular é inaceitável em jogos de ação.

### Solução: Client-Side Prediction

O MGAS implementa o padrão de previsão usado em FPS competitivos e MOBAs.

1. **Input:** Cliente aperta BOTÃO.
2. **Prediction:** Cliente _assume_ que vai dar certo: toca animação, gasta mana visual, spawna projétil _fake_.
3. **RPC:** Envia `ServerTryActivateAbility` para o servidor.
4. **Validação:** Servidor recebe. Verifica distâncias, cooldowns, tags.
5. **Confirmação (ACK):**
   - **Sucesso:** Servidor executa a habilidade real e replica os efeitos "verdadeiros" (dano, gasto de mana). O cliente substitui seus dados fakes pelos reais (reconciliação suave).
   - **Falha (Correction):** Servidor diz "NÃO". Cliente sofre **Rollback**: cancela animação, devolve mana visual, deleta projétil fake.

---

## 2. Replicação de Atributos (`AttributeSet`)

Replicar 50 floats a 60Hz para 100 jogadores é suicídio de banda.
O MGAS usa `MultiplayerSynchronizer` tunado com **Dirty Bitmasks**.

### Otimização:

1. **Only Dirty:** Só envia `Health` se `Health` mudou naquele frame.
2. **Owner Only:** `Stamina` e `Mana` geralmente só interessam ao dono. Inimigos não precisam saber sua mana exata. Configuramos replicação condicional.
3. **Quantization:** Floats de HP não precisam de precisão `double`. Podemos comprimir para `half-float` ou inteiros na rede.

---

## 3. Replicação de Habilidades (`GameplayAbility`)

Habilidades não são replicadas "frame a frame". Apenas eventos-chave são sincronizados.

### Fluxo de Replicação de GA:

1. **Activation:** RPC `TryActivate` (Cli -> Srv).
2. **Target Data:** Se for uma skill de "Target", o cliente envia "Cliquei no Inimigo B". O servidor valida se Inimigo B estava na mira.
3. **End/Cancel:** RPC `CancelAbility`.

### 4. GameplayCues (VFX/SFX)

Nunca replique "Tocar Som de Explosão". Replique "O Efeito de Dano foi aplicado".
O cliente observa a aplicação do GE de Dano e reage tocando o som localmente. Isso é um **Gameplay Cue**.

- **Vantagem:** Se o cliente lagar e receber 10 pacotes de dano de uma vez, ele toca o som da explosão _agora_, não "atrasado".
- **Implementação:** `GameplayCue` é um Node GDScript instanciado temporariamente para rodar partículas/sons e se autodestruir.

---

## 5. Estratégias de Lag Compensation

Para jogos de tiro (hitscan), o MGAS suporta validar tiros no passado.

- Servidor mantém um buffer de posições dos últimos 1000ms.
- Cliente diz "Atirei no tempo T=500ms na posição X".
- Servidor volta os hitboxes dos inimigos para T=500ms e verifica a colisão (Raycast no passado).

---

_MGAS — Multiplayer v1.0_

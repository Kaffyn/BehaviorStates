# Módulo 01: A Tríade Arcade (Snake, Pong, Pacman)

> **Foco:** Lógica de Grid, Física Básica e IA Simples.

Neste módulo, vamos construir três clássicos para dominar os fundamentos da lógica de programação aplicada a jogos. A cada 4 aulas, construiremos um jogo completo, aplicando os conceitos de forma iterativa e incremental.

## Ementa

### Aula Introdutória
1.  **[Introdução à Tríade Arcade](./01_Introducao.md)**
    Entenderemos o "porquê" deste módulo, o que cada clássico nos ensina sobre arquitetura de jogos e como o projeto será estruturado para máxima aprendizagem.

### Jogo 1: Snake (A Lógica de Grid)
2.  **[Snake - O Grid e a Maçã](./02_Snake_Grid.md)**
    Daremos o pontapé inicial no Snake, configurando o movimento em grade (grid-based) e a lógica para gerar a maçã em posições aleatórias, mas válidas.
3.  **[Snake - O Corpo que Cresce](./03_Snake_Corpo.md)**
    Implementaremos a mecânica central do Snake: o crescimento do corpo da cobra. Usaremos uma estrutura de dados eficiente (`Array` ou `Deque`) para gerenciar os segmentos.
4.  **[Snake - Game Over e Pontuação](./04_Snake_GameOver.md)**
    Criaremos as condições de derrota (colisão com paredes e com o próprio corpo) e um sistema de pontuação para recompensar o jogador.
5.  **[Snake - Polimento e Refatoração](./05_Snake_Polimento.md)**
    Transformaremos nosso protótipo em um mini-jogo polido. Adicionaremos "juice" com sons e `Tweens`, e refatoraremos o código usando `Resources` para uma arquitetura mais limpa.

### Jogo 2: Pong (A Física de Corpos)
6.  **[Pong - A Arena e as Raquetes](./06_Pong_Arena.md)**
    Começaremos o segundo clássico, Pong. Focaremos em configurar a cena, os corpos físicos (`CharacterBody2D`) para as raquetes e capturar o input do jogador.
7.  **[Pong - A Bola e a Física do Rebote](./07_Pong_Bola.md)**
    Implementaremos a bola, o coração do Pong. Aprenderemos a usar `move_and_collide` para criar uma física de rebote precisa e customizada nas paredes e raquetes.
8.  **[Pong - IA do Oponente e Pontuação](./08_Pong_AI_Score.md)**
    Criaremos um oponente funcional com uma IA simples, mas eficaz, que reage à posição da bola. Também desenvolveremos a lógica de pontuação e o reinício da bola a cada ponto.
9.  **[Pong - Polimento e Menus](./09_Pong_Polimento.md)**
    Adicionaremos o "game feel" que torna Pong viciante, como efeitos de partículas e som. Estruturaremos o fluxo do jogo com um menu inicial e telas de vitória/derrota.

### Jogo 3: Pac-Man (IA com Navegação)
10. **[Pac-Man - O Labirinto com TileMap](./10_Pacman_Tilemap.md)**
    Iniciaremos o projeto mais complexo da tríade. Aprenderemos a construir o labirinto de forma eficiente usando `TileMap` e a configurar seu `TileSet` para colisões.
11. **[Pac-Man - Coletáveis e Fantasmas](./11_Pacman_Coletaveis.md)**
    Popularemos nosso labirinto com os `pac-dots` e introduziremos os antagonistas, os fantasmas. Criaremos a lógica de coleta e o comportamento inicial dos inimigos.
12. **[Pac-Man - IA com Navigation2D](./12_Pacman_IA.md)**
    Daremos inteligência aos fantasmas. Usaremos o poderoso sistema de `NavigationServer2D` da Godot para fazê-los perseguir o jogador de forma inteligente pelo labirinto.
13. **[Pac-Man - Power-ups e Fim de Jogo](./13_Pacman_Powerups.md)**
    Implementaremos a mecânica de virada do jogo: o `power pellet`. Os fantasmas ficarão vulneráveis, e definiremos as condições de vitória e derrota, fechando o ciclo do Pac-Man com um `GameManager` global.

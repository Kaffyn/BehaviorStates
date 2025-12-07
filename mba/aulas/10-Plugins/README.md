# Módulo 10: BehaviorStates Plugin (Tooling Project)

> **Foco:** Arquitetura de Add-ons, Tooling Avançado e a criação do Framework `BehaviorStates` como um produto de software reutilizável.

Neste módulo, não vamos apenas aprender sobre plugins; vamos **construir** o BehaviorStates. Vamos pegar toda a teoria de arquitetura vista até agora e encapsulá-la em um addon profissional (`addons/behavior_states`) que pode ser dropado em qualquer projeto Godot.

Este é o **Projeto Final do Curso**.

## Ementa Prática

### 1. A Estrutura do Addon (`plugin.cfg`)
O primeiro passo para transformar código solto em um produto.
- Estrutura de pastas `addons/behavior_states/`.
- O arquivo de manifesto `plugin.cfg`.
- Ativando e desativando o plugin via código (`_enter_tree`, `_exit_tree`).

### 2. O Core (Autoload em Plugin)
Como registrar e gerenciar Singletons que pertencem ao Plugin, e não ao Projeto.
- Registrando `BehaviorStates.gd` (Tags e Enums globais) automaticamente.
- Garantindo que o Autoload seja removido limpamente ao desativar o plugin.

### 3. O Workbench (Main Screen Plugin)
Criando a "IDE dentro da IDE". Vamos construir a interface visual para editar grafos de comportamento.
- **EditorPlugin API:** `_has_main_screen()`, `_make_visible()`.
- **GraphEdit & GraphNode:** Criando nós visuais interativos.
- **Resource Parsing:** Lendo todos os `.tres` do projeto e populando a barra lateral.

### 4. O Inspector Customizado (`EditorInspectorPlugin`)
Substituindo a interface padrão de edição de Resources por algo mais intuitivo.
- Criando um editor de propriedades customizado para `BehaviorUnit`.
- Desenhando botões e sliders que interagem diretamente com o Resource.

### 5. Debugging e Gizmos
Ferramentas visuais para ver o que está acontecendo na Scene View.
- **EditorNode3DGizmoPlugin:** Desenhando cones de visão e áreas de detecção diretamente na viewport.
- **Overlay de Debug:** Mostrando o estado atual em cima do personagem durante o gameplay (via `_process` do plugin).

### 6. Distribuição
- Como empacotar seu plugin para a Godot Asset Library.
- `.gitignore` para addons.
- Licenciamento e Documentação.

---

> **Resultado Esperado:** Ao final deste módulo, você terá o plugin `BehaviorStates` funcional, aparecendo na sua aba de Project Settings -> Plugins, pronto para ser usado em novos jogos.

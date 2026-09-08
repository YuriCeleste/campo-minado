# Campo Minado (Lua + Love2D)

Versão simples e funcional do jogo, seguindo as regras e a prototipação
combinadas.

## Como rodar

1. Instale o [Love2D](https://love2d.org/) (versão 11.x).
2. Rode um dos comandos abaixo na pasta do projeto:
   - Windows: arraste a pasta `campo-minado` para cima do executável `love.exe`
   - Linux/macOS: `love campo-minado/`
   - Ou gere um `.love` zipando o **conteúdo** da pasta (não a pasta em si)
     e rode `love campo-minado.love`

## O que já está implementado

- Menu (Play / Tutorial / Credits), Options (dificuldade), Tutorial, Credits
- Tabuleiro gerado como matriz 2D (`tiles[linha][coluna]`), com bombas e
  energia sorteadas aleatoriamente em quantidade **proporcional** ao
  tamanho do mapa
- Dificuldades: Easy (6x6), Medium (9x9), Hard (12x12) — quanto maior o
  mapa, menos resistência/pulos relativos, para manter o desafio
- Movimento por **clique do mouse**: tijolo adjacente = anda 1 casa
- Tijolo 2 casas adiante = **pula** o tijolo do meio (o "suspeito"),
  que nunca é revelado nem conta como percorrido
- Bombas causam avaria (a menos que haja escudo); ao atingir o limite,
  o jogo termina
- Tijolos de energia dão um escudo (absorve 1 impacto de bomba) e
  aumentam permanentemente a resistência máxima do carro
- HUD durante a partida: tijolos percorridos, resistência, escudos,
  pulos restantes, tempo decorrido
- Tela de estatísticas final: tempo total, bombas atingidas, tijolos
  percorridos e sucesso/fracasso

## O que ficou de fora (pra manter "simples mas funcional")

- Os assets visuais das prototipações (carro, ícones de bomba/escudo
  desenhados, fundo de asfalto/grama) — por ora o jogo desenha formas
  simples (retângulos e círculos coloridos) no lugar. É só trocar por
  `love.graphics.draw(imagem, ...)` nos arquivos em `states/` quando
  vocês tiverem os assets exportados.
- Sons/efeitos sonoros
- Tela de "pause"

## Estrutura dos arquivos

```
main.lua           - callbacks do Love2D, inicia o menu
conf.lua           - configuração da janela
statemanager.lua   - troca simples entre telas
game.lua           - dados compartilhados (dificuldade, estatísticas)
board.lua          - matriz do tabuleiro + sorteio de bombas/energia
car.lua            - movimento, dano, escudo, pulo, checagem de vitória
states/menu.lua
states/options.lua
states/tutorial.lua
states/credits.lua
states/game.lua     - tela principal jogável
states/results.lua  - estatísticas finais
```

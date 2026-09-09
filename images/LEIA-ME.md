# Pasta de imagens

Coloque os arquivos com **exatamente estes nomes** nesta pasta. O jogo
já está preparado pra usá-los assim que existirem — se algum arquivo
não estiver aqui, o jogo continua funcionando normalmente, só volta a
desenhar a forma simples (retângulo/círculo) no lugar dele.

| Arquivo               | Onde aparece                                  | Sugestão                      |
|------------------------|------------------------------------------------|--------------------------------|
| `menu_car.png`         | Painel direito da tela inicial (menu)          | Imagem grande, tipo a arte do carrinho com farol que vocês mostraram no protótipo |
| `car_icon.png`         | Carrinho andando pelo tabuleiro                | Vista de cima (top-down), fundo transparente, quadrado |
| `bomb.png`              | Tijolo revelado que tinha bomba                | Ícone simples, fundo transparente |
| `shield.png`            | Tijolo revelado que tinha energia/escudo       | Ícone simples, fundo transparente |
| `house.png`             | Tijolo de chegada (final do percurso)          | Ícone da casinha, fundo transparente |
| `author_dayvson.png`    | Foto de perfil na tela de créditos             | Quadrada, ex: 128x128 |
| `author_yuri.png`       | Foto de perfil na tela de créditos             | Quadrada, ex: 128x128 |

Formato recomendado: **PNG com fundo transparente** para os ícones
(`car_icon`, `bomb`, `shield`, `house`) — assim eles se encaixam bem
em cima da cor do tijolo. `menu_car.png` pode ser um PNG ou JPG normal,
sem transparência.

Não precisa ser quadrado nem ter um tamanho exato — o jogo redimensiona
tudo automaticamente pra caber no espaço certo.

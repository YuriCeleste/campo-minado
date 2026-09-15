-- Tamanhos de fonte padronizados, usados em todas as telas pra deixar
-- o texto mais legível (antes tudo usava o tamanho pequeno padrão do
-- Love2D). Usa a fonte nativa do Love2D — não depende de nenhum
-- arquivo .ttf externo.

local Fonts = {}
local cache = {}

local function get(size)
    if not cache[size] then
        cache[size] = love.graphics.newFont(size)
    end
    return cache[size]
end

Fonts.title   = get(34) -- título grande (menu, ex: "MINESWEEPER")
Fonts.heading = get(24) -- título de tela (OPTIONS, CREDITS, TUTORIAL...)
Fonts.subhead = get(19) -- subtítulos de seção (DIFFICULTY, THEME...)
Fonts.body    = get(16) -- texto normal, botões, nomes
Fonts.small   = get(14) -- texto secundário (links, legendas, botão voltar)
Fonts.mono    = get(17) -- números/estatísticas

return Fonts
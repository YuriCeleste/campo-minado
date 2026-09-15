-- Tema visual: paleta de cores + helpers de desenho (painéis com
-- cantos arredondados, botões, divisores) usados em todas as telas,
-- pra dar uma cara consistente e mais elegante que retângulos lisos.

local Fonts = require("fonts")

local Theme = {}

Theme.colors = {
    bgDark     = { 0.07, 0.08, 0.10 },
    panel      = { 0.13, 0.14, 0.17 },
    panelLight = { 0.19, 0.20, 0.24 },
    accent     = { 0.40, 0.62, 0.98 },
    accentDim  = { 0.24, 0.32, 0.48 },
    text       = { 0.94, 0.95, 0.97 },
    textDim    = { 0.62, 0.64, 0.70 },
    success    = { 0.38, 0.80, 0.48 },
    danger     = { 0.88, 0.36, 0.36 },
    warning    = { 0.92, 0.76, 0.35 },
}

function Theme.setColor(c, alpha)
    love.graphics.setColor(c[1], c[2], c[3], alpha or 1)
end

-- Painel com cantos arredondados e uma leve sombra por baixo, pra dar
-- profundidade em vez de parecer um retângulo colado na tela.
function Theme.panel(x, y, w, h, opts)
    opts = opts or {}
    local radius = opts.radius or 12

    if opts.shadow ~= false then
        Theme.setColor({ 0, 0, 0 }, 0.22)
        love.graphics.rectangle("fill", x + 3, y + 4, w, h, radius, radius)
    end

    Theme.setColor(opts.color or Theme.colors.panel, opts.alpha or 1)
    love.graphics.rectangle("fill", x, y, w, h, radius, radius)

    if opts.border then
        Theme.setColor(opts.border, opts.borderAlpha or 1)
        love.graphics.setLineWidth(opts.borderWidth or 2)
        love.graphics.rectangle("line", x, y, w, h, radius, radius)
    end
end

-- Botão retangular com texto centralizado. opts.active destaca com
-- uma borda de cor de destaque (pra seleção de dificuldade, por ex).
function Theme.button(x, y, w, h, text, opts)
    opts = opts or {}
    Theme.panel(x, y, w, h, {
        radius = opts.radius or 10,
        color = opts.bg or (opts.active and Theme.colors.accentDim or Theme.colors.panelLight),
        border = opts.active and Theme.colors.accent or nil,
        borderWidth = 2,
        shadow = opts.shadow,
    })

    local font = opts.font or Fonts.body
    love.graphics.setFont(font)
    Theme.setColor(opts.textColor or Theme.colors.text)
    love.graphics.printf(text, x, y + (h - font:getHeight()) / 2, w, "center")
end

-- Botão circular de "voltar", reaproveitado em várias telas.
function Theme.backButton(x, y, size)
    size = size or 40
    Theme.panel(x, y, size, size, { radius = size / 2, color = Theme.colors.panelLight })
    love.graphics.setFont(Fonts.subhead)
    Theme.setColor(Theme.colors.text)
    love.graphics.printf("<", x, y + size / 2 - Fonts.subhead:getHeight() / 2 - 2, size, "center")
end

function Theme.isInside(x, y, bx, by, bw, bh)
    return x >= bx and x <= bx + bw and y >= by and y <= by + bh
end

function Theme.divider(x, y, w, alpha)
    Theme.setColor(Theme.colors.textDim, alpha or 0.25)
    love.graphics.rectangle("fill", x, y, w, 1)
end

return Theme

local StateManager = require("statemanager")
local Assets = require("assets")

local Tutorial = {}

local hoveredBack = false

local lines = {
    "Clique num tijolo VIZINHO para andar até ele.",
    "Clique num tijolo a 2 CASAS de distância para PULAR",
    "  o tijolo do meio (útil se você suspeitar de uma bomba).",
    "",
    "Tijolos com BOMBA causam avaria ao carro.",
    "Se as avarias atingirem o limite, o jogo termina.",
    "",
    "Tijolos de ENERGIA dão um escudo: o próximo impacto",
    "de bomba não causa avaria, e o carro fica mais resistente.",
    "",
    "Você tem um número LIMITADO de pulos por partida.",
    "O HUD mostra quantos ainda restam.",
    "",
    "Chegue até a casinha para vencer o desafio!",
}

function Tutorial.enter()
    hoveredBack = false
end

function Tutorial.draw()
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()

    -- Fundo cinza escuro
    love.graphics.clear(0.1, 0.1, 0.1)

    -- =========================================================
    -- IMAGEM DA BOMBA NO CENTRO (marca d'água transparente)
    -- =========================================================
    local bombImg = Assets.get("bomb.png")
    if bombImg then
        local iw, ih = bombImg:getDimensions()
        local tamanho = math.min(w, h) * 0.7
        local scale = tamanho / math.max(iw, ih)
        love.graphics.setColor(1, 1, 1, 0.08)
        love.graphics.draw(
            bombImg,
            w / 2, h / 2,
            0,
            scale, scale,
            iw / 2, ih / 2
        )
        love.graphics.setColor(1, 1, 1, 1)
    end

    -- =========================================================
    -- FAIXA PRETA DO TÍTULO
    -- =========================================================
    love.graphics.setColor(0, 0, 0, 0.95)
    love.graphics.rectangle("fill", 0, 0, w, 55)

    love.graphics.setColor(0.6, 0.6, 0.6, 0.5)
    love.graphics.rectangle("fill", 0, 55, w, 1)

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("TUTORIAL", 0, 18, w, "center")

    -- =========================================================
    -- TEXTO DO TUTORIAL
    -- =========================================================
    local marginX = 80
    local startY = 90
    local lineHeight = 24

    for i, line in ipairs(lines) do
        -- Linha vazia: pula
        if line == "" then
            -- não desenha nada, mas avança a linha
        elseif string.find(line, "Chegue até a casinha") then
            -- Última linha: destaque em amarelo
            love.graphics.setColor(1, 0.85, 0.3)
            love.graphics.print(line, marginX, startY + (i - 1) * lineHeight)
        else
            love.graphics.setColor(0.9, 0.9, 0.9)
            love.graphics.print(line, marginX, startY + (i - 1) * lineHeight)
        end
    end

    -- =========================================================
    -- BOTÃO VOLTAR
    -- =========================================================
    local btnX, btnY, btnW, btnH = 20, 15, 80, 30
    local isBackHovered = hoveredBack

    love.graphics.setColor(isBackHovered and 0.35 or 0.2, isBackHovered and 0.35 or 0.2, isBackHovered and 0.35 or 0.2)
    love.graphics.rectangle("fill", btnX, btnY, btnW, btnH, 4)

    love.graphics.setColor(isBackHovered and 0.9 or 0.5, isBackHovered and 0.9 or 0.5, isBackHovered and 0.9 or 0.5)
    love.graphics.rectangle("line", btnX, btnY, btnW, btnH, 4)

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("< VOLTAR", btnX, btnY + 7, btnW, "center")
end

function Tutorial.mousepressed(x, y, button)
    if button ~= 1 then return end

    -- Clique no botão voltar
    if x >= 20 and x <= 100 and y >= 15 and y <= 45 then
        StateManager.switch(require("states.menu"))
    end
end

function Tutorial.mousemoved(x, y)
    hoveredBack = (x >= 20 and x <= 100 and y >= 15 and y <= 45)
end

function Tutorial.keypressed(key)
    if key == "escape" then
        StateManager.switch(require("states.menu"))
    end
end

return Tutorial
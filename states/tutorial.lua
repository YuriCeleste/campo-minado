local StateManager = require("statemanager")

local Tutorial = {}

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
    "Chegue até a casinha para vencer o desafio!",
}

function Tutorial.draw()
    love.graphics.clear(0.95, 0.95, 0.95)
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf("TUTORIAL", 0, 20, love.graphics.getWidth(), "center")

    for i, line in ipairs(lines) do
        love.graphics.printf(line, 40, 70 + (i - 1) * 24, love.graphics.getWidth() - 80, "left")
    end

    love.graphics.rectangle("fill", 10, 10, 40, 30)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("<-", 10, 17, 40, "center")
end

function Tutorial.mousepressed(x, y, button)
    if button ~= 1 then return end
    if x >= 10 and x <= 50 and y >= 10 and y <= 40 then
        StateManager.switch(require("states.menu"))
    end
end

return Tutorial

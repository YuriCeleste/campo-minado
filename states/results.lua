local StateManager = require("statemanager")
local Game = require("game")

local Results = {}

function Results.draw()
    love.graphics.clear(0.95, 0.95, 0.95)
    local stats = Game.stats or {}

    love.graphics.setColor(0, 0, 0)
    love.graphics.printf("ESTATÍSTICAS", 0, 40, love.graphics.getWidth(), "center")

    love.graphics.setColor(stats.success and 0.2 or 0.7, stats.success and 0.6 or 0.2, 0.2)
    love.graphics.printf(
        stats.success and "DESAFIO CONCLUÍDO COM SUCESSO" or "DESAFIO NÃO CONCLUÍDO",
        0, 90, love.graphics.getWidth(), "center"
    )

    love.graphics.setColor(0, 0, 0)
    love.graphics.printf(string.format("Tempo total: %.1fs", stats.time or 0), 0, 140, love.graphics.getWidth(), "center")
    love.graphics.printf(string.format("Bombas atingidas: %d", stats.bombsHit or 0), 0, 165, love.graphics.getWidth(), "center")
    love.graphics.printf(string.format("Tijolos percorridos: %d", stats.tilesTraveled or 0), 0, 190, love.graphics.getWidth(), "center")

    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", love.graphics.getWidth() / 2 - 100, 250, 200, 40)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("MENU", love.graphics.getWidth() / 2 - 100, 262, 200, "center")
end

function Results.mousepressed(x, y, button)
    if button ~= 1 then return end
    local bx = love.graphics.getWidth() / 2 - 100
    if x >= bx and x <= bx + 200 and y >= 250 and y <= 290 then
        StateManager.switch(require("states.menu"))
    end
end

return Results

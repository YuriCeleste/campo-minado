local StateManager = require("statemanager")
local Game = require("game")
local Board = require("board")

local Options = {}
local difficulties = { "easy", "medium", "hard" }
local selected = "medium"

function Options.enter()
    selected = Game.difficulty or "medium"
end

function Options.draw()
    love.graphics.clear(0.9, 0.9, 0.9)
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf("OPTIONS", 0, 20, love.graphics.getWidth(), "center")

    local startX = 60
    for i, diff in ipairs(difficulties) do
        local x = startX + (i - 1) * 220
        if diff == selected then
            love.graphics.setColor(0.2, 0.5, 0.9)
        else
            love.graphics.setColor(0.3, 0.3, 0.3)
        end
        love.graphics.rectangle("fill", x, 80, 180, 40)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(diff:upper(), x, 92, 180, "center")

        local settings = Board.getSettings(diff)
        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.printf(settings.size .. "x" .. settings.size, x, 125, 180, "center")
    end

    love.graphics.setColor(0.15, 0.6, 0.15)
    love.graphics.rectangle("fill", love.graphics.getWidth() / 2 - 100, 190, 200, 40)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("SUBMIT", love.graphics.getWidth() / 2 - 100, 202, 200, "center")

    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.rectangle("fill", 10, 10, 40, 30)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("<-", 10, 17, 40, "center")
end

function Options.mousepressed(x, y, button)
    if button ~= 1 then return end

    if x >= 10 and x <= 50 and y >= 10 and y <= 40 then
        StateManager.switch(require("states.menu"))
        return
    end

    local startX = 60
    for i, diff in ipairs(difficulties) do
        local bx = startX + (i - 1) * 220
        if x >= bx and x <= bx + 180 and y >= 80 and y <= 120 then
            selected = diff
        end
    end

    local submitX = love.graphics.getWidth() / 2 - 100
    if x >= submitX and x <= submitX + 200 and y >= 190 and y <= 230 then
        Game.difficulty = selected
        StateManager.switch(require("states.game"))
    end
end

return Options

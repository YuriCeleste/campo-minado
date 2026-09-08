local StateManager = require("statemanager")

local Menu = {}
local buttons = {}

function Menu.enter()
    buttons = {
        { label = "PLAY",     y = 90,  action = function() StateManager.switch(require("states.options")) end },
        { label = "TUTORIAL", y = 200, action = function() StateManager.switch(require("states.tutorial")) end },
        { label = "CREDITS",  y = 255, action = function() StateManager.switch(require("states.credits")) end },
    }
end

function Menu.draw()
    love.graphics.clear(0.85, 0.85, 0.85)

    love.graphics.setColor(0.15, 0.15, 0.15)
    love.graphics.rectangle("fill", 0, 0, 260, love.graphics.getHeight())

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("CAMPO MINADO", 280, 30, 400, "center")

    for _, btn in ipairs(buttons) do
        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.rectangle("fill", 20, btn.y, 220, 40)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(btn.label, 20, btn.y + 12, 220, "center")
    end
end

function Menu.mousepressed(x, y, button)
    if button ~= 1 then return end
    for _, btn in ipairs(buttons) do
        if x >= 20 and x <= 240 and y >= btn.y and y <= btn.y + 40 then
            btn.action()
        end
    end
end

return Menu

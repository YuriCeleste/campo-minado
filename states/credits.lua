local StateManager = require("statemanager")

local Credits = {}

local authors = {
    { name = "Dayvson Lacerda Pessoa Filho", link = "github.com/Devs097518" },
    { name = "Yuri William Ferreira Calixto", link = "github.com/YuriCeleste" },
}

local techs = { "Lua", "Love2D" }

function Credits.draw()
    love.graphics.clear(0.9, 0.9, 0.9)
    love.graphics.setColor(0.15, 0.15, 0.15)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), 50)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("CREDITS", 0, 15, love.graphics.getWidth(), "center")

    local y = 80
    for _, author in ipairs(authors) do
        love.graphics.setColor(0.1, 0.1, 0.6)
        love.graphics.print(author.name, 40, y)
        love.graphics.setColor(0.3, 0.3, 0.3)
        love.graphics.print(author.link, 40, y + 20)
        y = y + 60
    end

    love.graphics.setColor(0.2, 0.2, 0.7)
    love.graphics.print("Technologies used:", 40, y + 10)
    for i, tech in ipairs(techs) do
        love.graphics.setColor(0.1, 0.1, 0.1)
        love.graphics.print("- " .. tech, 60, y + 30 + (i - 1) * 20)
    end

    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", 10, 10, 40, 30)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("<-", 10, 17, 40, "center")
end

function Credits.mousepressed(x, y, button)
    if button ~= 1 then return end
    if x >= 10 and x <= 50 and y >= 10 and y <= 40 then
        StateManager.switch(require("states.menu"))
    end
end

return Credits

local StateManager = require("statemanager")
local Assets = require("assets")

local Credits = {}

local authors = {
    { name = "Dayvson Lacerda Pessoa Filho", link = "github.com/Devs097518", photo = "author_dayvson.png" },
    { name = "Yuri William Ferreira Calixto", link = "github.com/YuriCeleste", photo = "author_yuri.png" },
}

local techs = { "Lua", "Love2D" }

function Credits.draw()
    love.graphics.clear(0.9, 0.9, 0.9)
    love.graphics.setColor(0.15, 0.15, 0.15)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), 50)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("CREDITS", 0, 15, love.graphics.getWidth(), "center")

    local y = 80
    local photoSize = 44
    for _, author in ipairs(authors) do
        local hasPhoto = Assets.drawFitted(author.photo, 40, y, photoSize)
        if not hasPhoto then
            love.graphics.setColor(0.7, 0.7, 0.7)
            love.graphics.circle("fill", 40 + photoSize / 2, y + photoSize / 2, photoSize / 2)
        end

        local textX = 40 + photoSize + 12
        love.graphics.setColor(0.1, 0.1, 0.6)
        love.graphics.print(author.name, textX, y + 4)
        love.graphics.setColor(0.3, 0.3, 0.3)
        love.graphics.print(author.link, textX, y + 24)
        y = y + photoSize + 20
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

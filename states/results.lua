local StateManager = require("statemanager")
local Game = require("game")

local Results = {}

local hoveredMenu = false

function Results.enter()
    hoveredMenu = false
end

function Results.draw()
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()
    local stats = Game.stats or {}

    love.graphics.clear(0.1, 0.1, 0.1)

    -- BLACK TITLE BAR
    love.graphics.setColor(0, 0, 0, 0.95)
    love.graphics.rectangle("fill", 0, 0, w, 55)
    love.graphics.setColor(0.6, 0.6, 0.6, 0.5)
    love.graphics.rectangle("fill", 0, 55, w, 1)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("STATISTICS", 0, 18, w, "center")

    -- SUCCESS / FAILURE MESSAGE
    if stats.success then
        love.graphics.setColor(0.3, 0.9, 0.3)
        love.graphics.printf("CHALLENGE COMPLETED SUCCESSFULLY!", 0, 90, w, "center")
    else
        love.graphics.setColor(0.9, 0.3, 0.3)
        love.graphics.printf("CHALLENGE NOT COMPLETED", 0, 90, w, "center")
    end

    -- STATISTICS
    local startY = 150
    local lineHeight = 30

    love.graphics.setColor(0.9, 0.9, 0.9)
    love.graphics.printf(string.format("Total time: %.1fs", stats.time or 0), 0, startY, w, "center")
    love.graphics.printf(string.format("Bombs hit: %d", stats.bombsHit or 0), 0, startY + lineHeight, w, "center")
    love.graphics.printf(string.format("Tiles traveled: %d", stats.tilesTraveled or 0), 0, startY + lineHeight * 2, w, "center")

    -- MENU BUTTON
    local btnW, btnH = 200, 50
    local btnX = (w - btnW) / 2
    local btnY = 280
    local isHovered = hoveredMenu

    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.rectangle("fill", btnX + 2, btnY + 3, btnW, btnH, 6)

    local r, g, b
    if isHovered then
        r, g, b = 0.35, 0.35, 0.35
    else
        r, g, b = 0.2, 0.2, 0.2
    end
    love.graphics.setColor(r, g, b)
    love.graphics.rectangle("fill", btnX, btnY, btnW, btnH, 6)

    local borda = isHovered and 0.9 or 0.5
    love.graphics.setColor(borda, borda, borda)
    love.graphics.rectangle("line", btnX, btnY, btnW, btnH, 6)

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("MENU", btnX, btnY + 16, btnW, "center")
end

function Results.mousepressed(x, y, button)
    if button ~= 1 then return end

    local w = love.graphics.getWidth()
    local btnW, btnH = 200, 50
    local btnX = (w - btnW) / 2
    local btnY = 280

    if x >= btnX and x <= btnX + btnW and y >= btnY and y <= btnY + btnH then
        StateManager.switch(require("states.menu"))
    end
end

function Results.mousemoved(x, y)
    local w = love.graphics.getWidth()
    local btnW, btnH = 200, 50
    local btnX = (w - btnW) / 2
    local btnY = 280

    hoveredMenu = (x >= btnX and x <= btnX + btnW and y >= btnY and y <= btnY + btnH)
end

function Results.keypressed(key)
    if key == "escape" then
        StateManager.switch(require("states.menu"))
    end
end

return Results
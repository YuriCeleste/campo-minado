local StateManager = require("statemanager")
local Assets = require("assets")

local Tutorial = {}

local hoveredBack = false

local lines = {
    "Click a NEIGHBORING tile to move to it.",
    "Click a tile 2 TILES away to JUMP",
    "  over the middle tile (useful if you suspect a bomb).",
    "",
    "Tiles with BOMBS damage the car.",
    "If damage reaches the limit, the game ends.",
    "",
    "ENERGY tiles give a shield: the next bomb",
    "impact causes no damage, and the car becomes more resistant.",
    "",
    "You have a LIMITED number of jumps per game.",
    "The HUD shows how many are left.",
    "",
    "Reach the house to win the challenge!",
}

function Tutorial.enter()
    hoveredBack = false
end

function Tutorial.draw()
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()

    love.graphics.clear(0.1, 0.1, 0.1)

    -- BOMB IMAGE AS WATERMARK
    local bombImg = Assets.get("bomb.png")
    if bombImg then
        local iw, ih = bombImg:getDimensions()
        local tamanho = math.min(w, h) * 0.7
        local scale = tamanho / math.max(iw, ih)
        love.graphics.setColor(1, 1, 1, 0.08)
        love.graphics.draw(bombImg, w / 2, h / 2, 0, scale, scale, iw / 2, ih / 2)
        love.graphics.setColor(1, 1, 1, 1)
    end

    -- BLACK TITLE BAR
    love.graphics.setColor(0, 0, 0, 0.95)
    love.graphics.rectangle("fill", 0, 0, w, 55)
    love.graphics.setColor(0.6, 0.6, 0.6, 0.5)
    love.graphics.rectangle("fill", 0, 55, w, 1)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("TUTORIAL", 0, 18, w, "center")

    -- TEXT
    local marginX = 80
    local startY = 90
    local lineHeight = 24

    for i, line in ipairs(lines) do
        if line == "" then
            -- skip
        elseif string.find(line, "Reach the house") then
            love.graphics.setColor(1, 0.85, 0.3)
            love.graphics.print(line, marginX, startY + (i - 1) * lineHeight)
        else
            love.graphics.setColor(0.9, 0.9, 0.9)
            love.graphics.print(line, marginX, startY + (i - 1) * lineHeight)
        end
    end

    -- BACK BUTTON
    local btnX, btnY, btnW, btnH = 20, 15, 80, 30
    local isBackHovered = hoveredBack

    love.graphics.setColor(isBackHovered and 0.35 or 0.2, isBackHovered and 0.35 or 0.2, isBackHovered and 0.35 or 0.2)
    love.graphics.rectangle("fill", btnX, btnY, btnW, btnH, 4)
    love.graphics.setColor(isBackHovered and 0.9 or 0.5, isBackHovered and 0.9 or 0.5, isBackHovered and 0.9 or 0.5)
    love.graphics.rectangle("line", btnX, btnY, btnW, btnH, 4)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("< BACK", btnX, btnY + 7, btnW, "center")
end

function Tutorial.mousepressed(x, y, button)
    if button ~= 1 then return end
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
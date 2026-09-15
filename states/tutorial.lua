local StateManager = require("statemanager")
local Assets = require("assets")
local Game = require("game")
local Fonts = require("fonts")

local Tutorial = {}

local hoveredBack = false

local COLORS = {
    move   = { 0.45, 0.65, 1.0 },
    danger = { 1.0, 0.4, 0.4 },
    energy = { 1.0, 0.85, 0.3 },
    goal   = { 0.4, 0.9, 0.5 },
}

local lines = {
    { text = "Click a NEIGHBORING tile to move to it.", color = "move" },
    { text = "Click a tile 2 TILES away to JUMP", color = "move" },
    { text = "  over the middle tile (useful if you suspect a bomb).", color = "move" },
    { text = "" },
    { text = "Tiles with BOMBS damage the car.", color = "danger" },
    { text = "If damage reaches the limit, the game ends.", color = "danger" },
    { text = "" },
    { text = "ENERGY tiles give a shield: the next bomb", color = "energy" },
    { text = "impact causes no damage, and the car becomes more resistant.", color = "energy" },
    { text = "" },
    { text = "You have a LIMITED number of jumps per game.", color = "move" },
    { text = "The HUD shows how many are left.", color = "move" },
    { text = "" },
    { text = "Reach the house to win the challenge!", color = "goal" },
}

function Tutorial.enter()
    hoveredBack = false
end

function Tutorial.draw()
    local t = Game.themes[Game.theme]
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()

    love.graphics.clear(t.background)

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
    love.graphics.setColor(t.titleBar)
    love.graphics.rectangle("fill", 0, 0, w, 55)
    love.graphics.setColor(t.textDim)
    love.graphics.rectangle("fill", 0, 55, w, 1)
    love.graphics.setColor(t.titleText)
    love.graphics.setFont(Fonts.heading)
    love.graphics.printf("TUTORIAL", 0, (55 - Fonts.heading:getHeight()) / 2, w, "center")

    -- TEXT
    local marginX = 80
    local startY = 90
    local lineHeight = 25

    love.graphics.setFont(Fonts.body)
    for i, line in ipairs(lines) do
        if line.text ~= "" then
            local c = line.color and COLORS[line.color] or t.text
            love.graphics.setColor(c[1], c[2], c[3])
            love.graphics.print(line.text, marginX, startY + (i - 1) * lineHeight)
        end
    end

    -- BACK BUTTON
    local btnX, btnY, btnW, btnH = 20, 15, 80, 30
    local isBackHovered = hoveredBack

    love.graphics.setColor(isBackHovered and t.buttonHover or t.buttonBg)
    love.graphics.rectangle("fill", btnX, btnY, btnW, btnH, 4)
    love.graphics.setColor(isBackHovered and 0.9 or t.buttonBorder[1], isBackHovered and 0.9 or t.buttonBorder[2], isBackHovered and 0.9 or t.buttonBorder[3])
    love.graphics.rectangle("line", btnX, btnY, btnW, btnH, 4)
    love.graphics.setColor(t.text)
    love.graphics.setFont(Fonts.small)
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
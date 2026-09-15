local StateManager = require("statemanager")
local Game = require("game")
local Fonts = require("fonts")

local Results = {}

local hoveredMenu = false

function Results.enter()
    hoveredMenu = false
end

function Results.draw()
    local t = Game.themes[Game.theme]
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()
    local stats = Game.stats or {}

    love.graphics.clear(t.background)

    -- BLACK TITLE BAR
    love.graphics.setColor(t.titleBar)
    love.graphics.rectangle("fill", 0, 0, w, 55)
    love.graphics.setColor(t.textDim)
    love.graphics.rectangle("fill", 0, 55, w, 1)
    love.graphics.setColor(t.titleText)
    love.graphics.setFont(Fonts.heading)
    love.graphics.printf("STATISTICS", 0, (55 - Fonts.heading:getHeight()) / 2, w, "center")

    -- SUCCESS / FAILURE MESSAGE (banner colorido)
    local resultColor = stats.success and t.success or t.danger
    local message = stats.success and "CHALLENGE COMPLETED SUCCESSFULLY!" or "CHALLENGE NOT COMPLETED"

    love.graphics.setFont(Fonts.heading)
    local bannerW = math.min(w - 40, Fonts.heading:getWidth(message) + 60)
    local bannerH = 44
    local bannerX = (w - bannerW) / 2
    local bannerY = 78

    love.graphics.setColor(resultColor[1], resultColor[2], resultColor[3], 0.18)
    love.graphics.rectangle("fill", bannerX, bannerY, bannerW, bannerH, 8)
    love.graphics.setColor(resultColor)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", bannerX, bannerY, bannerW, bannerH, 8)

    love.graphics.printf(
        message,
        bannerX, bannerY + (bannerH - Fonts.heading:getHeight()) / 2, bannerW, "center"
    )

    -- STATISTICS (card)
    local cardW, cardH = 320, 150
    local cardX = (w - cardW) / 2
    local cardY = 150

    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.rectangle("fill", cardX + 2, cardY + 3, cardW, cardH, 8)
    love.graphics.setColor(t.panel)
    love.graphics.rectangle("fill", cardX, cardY, cardW, cardH, 8)
    love.graphics.setColor(t.buttonBorder)
    love.graphics.rectangle("line", cardX, cardY, cardW, cardH, 8)

    local rows = {
        { label = "TOTAL TIME",     value = string.format("%.1fs", stats.time or 0), color = t.text },
        { label = "BOMBS HIT",      value = tostring(stats.bombsHit or 0),
          color = (stats.bombsHit or 0) > 0 and t.danger or t.success },
        { label = "TILES TRAVELED", value = tostring(stats.tilesTraveled or 0), color = t.accent },
    }

    local rowY = cardY + 16
    for _, row in ipairs(rows) do
        love.graphics.setColor(t.textDim)
        love.graphics.setFont(Fonts.small)
        love.graphics.print(row.label, cardX + 20, rowY)

        love.graphics.setColor(row.color)
        love.graphics.setFont(Fonts.mono)
        love.graphics.printf(row.value, cardX, rowY + 16, cardW - 20, "right")

        rowY = rowY + 42
    end

    -- MENU BUTTON
    local btnW, btnH = 200, 50
    local btnX = (w - btnW) / 2
    local btnY = cardY + cardH + 24
    local isHovered = hoveredMenu

    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.rectangle("fill", btnX + 2, btnY + 3, btnW, btnH, 6)

    local corFundo = isHovered and t.buttonHover or t.buttonBg
    love.graphics.setColor(corFundo)
    love.graphics.rectangle("fill", btnX, btnY, btnW, btnH, 6)

    local borda = isHovered and 0.9 or t.buttonBorder[1]
    love.graphics.setColor(borda, borda, borda)
    love.graphics.rectangle("line", btnX, btnY, btnW, btnH, 6)

    love.graphics.setColor(t.text)
    love.graphics.setFont(Fonts.body)
    love.graphics.printf("MENU", btnX, btnY + 16, btnW, "center")
end

function Results.mousepressed(x, y, button)
    if button ~= 1 then return end

    local w = love.graphics.getWidth()
    local btnW, btnH = 200, 50
    local btnX = (w - btnW) / 2
    local btnY = 324

    if x >= btnX and x <= btnX + btnW and y >= btnY and y <= btnY + btnH then
        StateManager.switch(require("states.menu"))
    end
end

function Results.mousemoved(x, y)
    local w = love.graphics.getWidth()
    local btnW, btnH = 200, 50
    local btnX = (w - btnW) / 2
    local btnY = 324

    hoveredMenu = (x >= btnX and x <= btnX + btnW and y >= btnY and y <= btnY + btnH)
end

function Results.keypressed(key)
    if key == "escape" then
        StateManager.switch(require("states.menu"))
    end
end

return Results
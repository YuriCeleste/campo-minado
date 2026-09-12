local StateManager = require("statemanager")
local Game = require("game")
local Board = require("board")

local Options = {}

local difficulties = { "easy", "medium", "hard" }
local selected = "medium"

local hoveredDiff = nil
local hoveredBack = false
local hoveredSubmit = false

local buttonPositions = {}
local submitPosition = nil

function Options.enter()
    selected = Game.difficulty or "medium"
    hoveredDiff = nil
    hoveredBack = false
    hoveredSubmit = false
    buttonPositions = {}
    submitPosition = nil
end

function Options.draw()
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()

    love.graphics.clear(0.1, 0.1, 0.1)

    -- BLACK TITLE BAR
    love.graphics.setColor(0, 0, 0, 0.95)
    love.graphics.rectangle("fill", 0, 0, w, 55)
    love.graphics.setColor(0.6, 0.6, 0.6, 0.5)
    love.graphics.rectangle("fill", 0, 55, w, 1)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("OPTIONS", 0, 18, w, "center")

    -- DIFFICULTY BUTTONS
    local btnW, btnH = 180, 50
    local spacing = 40
    local totalW = #difficulties * btnW + (#difficulties - 1) * spacing
    local startX = (w - totalW) / 2
    local btnY = 120

    buttonPositions = {}

    for i, diff in ipairs(difficulties) do
        local x = startX + (i - 1) * (btnW + spacing)
        local isSelected = (selected == diff)
        local isHovered = (hoveredDiff == diff)

        local r, g, b
        if isSelected then
            r, g, b = 0.2, 0.5, 0.9
        elseif isHovered then
            r, g, b = 0.35, 0.35, 0.35
        else
            r, g, b = 0.2, 0.2, 0.2
        end

        love.graphics.setColor(0, 0, 0, 0.3)
        love.graphics.rectangle("fill", x + 2, btnY + 3, btnW, btnH, 6)

        love.graphics.setColor(r, g, b)
        love.graphics.rectangle("fill", x, btnY, btnW, btnH, 6)

        local borda = isSelected and 1.0 or (isHovered and 0.8 or 0.4)
        love.graphics.setColor(borda, borda, borda)
        love.graphics.rectangle("line", x, btnY, btnW, btnH, 6)

        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(diff:upper(), x, btnY + 16, btnW, "center")

        local settings = Board.getSettings(diff)
        love.graphics.setColor(0.7, 0.7, 0.7)
        love.graphics.printf(settings.size .. "x" .. settings.size, x, btnY + btnH + 8, btnW, "center")

        table.insert(buttonPositions, {
            id = diff,
            x1 = x, y1 = btnY,
            x2 = x + btnW, y2 = btnY + btnH
        })
    end

    -- SUBMIT BUTTON
    local submitW, submitH = 200, 50
    local submitX = (w - submitW) / 2
    local submitY = 280

    local isSubmitHovered = hoveredSubmit

    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.rectangle("fill", submitX + 2, submitY + 3, submitW, submitH, 6)

    local sr, sg, sb = isSubmitHovered and 0.3 or 0.2, isSubmitHovered and 0.7 or 0.6, isSubmitHovered and 0.3 or 0.2
    love.graphics.setColor(sr, sg, sb)
    love.graphics.rectangle("fill", submitX, submitY, submitW, submitH, 6)

    love.graphics.setColor(0.5, 1.0, 0.5)
    love.graphics.rectangle("line", submitX, submitY, submitW, submitH, 6)

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("SUBMIT", submitX, submitY + 16, submitW, "center")

    submitPosition = {
        x1 = submitX, y1 = submitY,
        x2 = submitX + submitW, y2 = submitY + submitH
    }

    -- BACK BUTTON
    local backX, backY, backW, backH = 20, 15, 80, 30
    local isBackHovered = hoveredBack

    love.graphics.setColor(isBackHovered and 0.35 or 0.2, isBackHovered and 0.35 or 0.2, isBackHovered and 0.35 or 0.2)
    love.graphics.rectangle("fill", backX, backY, backW, backH, 4)

    love.graphics.setColor(isBackHovered and 0.9 or 0.5, isBackHovered and 0.9 or 0.5, isBackHovered and 0.9 or 0.5)
    love.graphics.rectangle("line", backX, backY, backW, backH, 4)

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("< BACK", backX, backY + 7, backW, "center")
end

function Options.mousepressed(x, y, button)
    if button ~= 1 then return end

    if x >= 20 and x <= 100 and y >= 15 and y <= 45 then
        StateManager.switch(require("states.menu"))
        return
    end

    for _, pos in ipairs(buttonPositions) do
        if x >= pos.x1 and x <= pos.x2 and y >= pos.y1 and y <= pos.y2 then
            selected = pos.id
            return
        end
    end

    if submitPosition and x >= submitPosition.x1 and x <= submitPosition.x2
        and y >= submitPosition.y1 and y <= submitPosition.y2 then
        Game.difficulty = selected
        StateManager.switch(require("states.game"))
        return
    end
end

function Options.mousemoved(x, y)
    hoveredBack = (x >= 20 and x <= 100 and y >= 15 and y <= 45)

    hoveredDiff = nil
    for _, pos in ipairs(buttonPositions) do
        if x >= pos.x1 and x <= pos.x2 and y >= pos.y1 and y <= pos.y2 then
            hoveredDiff = pos.id
            break
        end
    end

    hoveredSubmit = submitPosition
        and x >= submitPosition.x1 and x <= submitPosition.x2
        and y >= submitPosition.y1 and y <= submitPosition.y2
end

function Options.keypressed(key)
    if key == "escape" then
        StateManager.switch(require("states.menu"))
    end
end

return Options
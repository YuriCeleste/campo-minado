local StateManager = require("statemanager")
local Game = require("game")
local Board = require("board")

local Options = {}

local difficulties = { "easy", "medium", "hard" }
local themes = { "dark", "light" }

local selectedDiff = "medium"
local selectedTheme = "dark"

local hoveredDiff = nil
local hoveredTheme = nil
local hoveredBack = false
local hoveredSubmit = false

local diffPositions = {}
local themePositions = {}
local submitPosition = nil

function Options.enter()
    selectedDiff = Game.difficulty or "medium"
    selectedTheme = Game.theme or "dark"
    hoveredDiff = nil
    hoveredTheme = nil
    hoveredBack = false
    hoveredSubmit = false
    diffPositions = {}
    themePositions = {}
    submitPosition = nil
end

function Options.draw()
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()
    local t = Game.themes[selectedTheme]  -- preview do tema selecionado

    love.graphics.clear(t.background)

    -- BLACK TITLE BAR
    love.graphics.setColor(t.titleBar)
    love.graphics.rectangle("fill", 0, 0, w, 55)
    love.graphics.setColor(t.textDim)
    love.graphics.rectangle("fill", 0, 55, w, 1)
    love.graphics.setColor(t.titleText)
    love.graphics.printf("OPTIONS", 0, 18, w, "center")

    -- =====================================================
    -- SEÇÃO 1: DIFICULDADE
    -- =====================================================
    love.graphics.setColor(t.text)
    love.graphics.printf("DIFFICULTY", 0, 80, w, "center")

    local btnW, btnH = 180, 50
    local spacing = 40
    local totalW = #difficulties * btnW + (#difficulties - 1) * spacing
    local startX = (w - totalW) / 2
    local diffY = 110

    diffPositions = {}

    for i, diff in ipairs(difficulties) do
        local x = startX + (i - 1) * (btnW + spacing)
        local isSelected = (selectedDiff == diff)
        local isHovered = (hoveredDiff == diff)

        local r, g, b
        if isSelected then
            r, g, b = t.accent[1], t.accent[2], t.accent[3]
        elseif isHovered then
            r, g, b = t.buttonHover[1], t.buttonHover[2], t.buttonHover[3]
        else
            r, g, b = t.buttonBg[1], t.buttonBg[2], t.buttonBg[3]
        end

        love.graphics.setColor(0, 0, 0, 0.3)
        love.graphics.rectangle("fill", x + 2, diffY + 3, btnW, btnH, 6)

        love.graphics.setColor(r, g, b)
        love.graphics.rectangle("fill", x, diffY, btnW, btnH, 6)

        local borda = isSelected and 1.0 or (isHovered and 0.8 or t.buttonBorder[1])
        love.graphics.setColor(borda, borda, borda)
        love.graphics.rectangle("line", x, diffY, btnW, btnH, 6)

        love.graphics.setColor(t.text)
        love.graphics.printf(diff:upper(), x, diffY + 16, btnW, "center")

        local settings = Board.getSettings(diff)
        love.graphics.setColor(t.textDim)
        love.graphics.printf(settings.size .. "x" .. settings.size, x, diffY + btnH + 6, btnW, "center")

        table.insert(diffPositions, {
            id = diff,
            x1 = x, y1 = diffY,
            x2 = x + btnW, y2 = diffY + btnH
        })
    end

    -- =====================================================
    -- SEÇÃO 2: TEMA
    -- =====================================================
    local themeY = 230
    love.graphics.setColor(t.text)
    love.graphics.printf("THEME", 0, themeY - 30, w, "center")

    themePositions = {}

    local themeBtnW, themeBtnH = 180, 50
    local themeSpacing = 40
    local themeTotalW = #themes * themeBtnW + (#themes - 1) * themeSpacing
    local themeStartX = (w - themeTotalW) / 2

    for i, theme in ipairs(themes) do
        local x = themeStartX + (i - 1) * (themeBtnW + themeSpacing)
        local isSelected = (selectedTheme == theme)
        local isHovered = (hoveredTheme == theme)

        local r, g, b
        if isSelected then
            r, g, b = t.accent[1], t.accent[2], t.accent[3]
        elseif isHovered then
            r, g, b = t.buttonHover[1], t.buttonHover[2], t.buttonHover[3]
        else
            r, g, b = t.buttonBg[1], t.buttonBg[2], t.buttonBg[3]
        end

        love.graphics.setColor(0, 0, 0, 0.3)
        love.graphics.rectangle("fill", x + 2, themeY + 3, themeBtnW, themeBtnH, 6)

        love.graphics.setColor(r, g, b)
        love.graphics.rectangle("fill", x, themeY, themeBtnW, themeBtnH, 6)

        local borda = isSelected and 1.0 or (isHovered and 0.8 or t.buttonBorder[1])
        love.graphics.setColor(borda, borda, borda)
        love.graphics.rectangle("line", x, themeY, themeBtnW, themeBtnH, 6)

        love.graphics.setColor(t.text)
        love.graphics.printf(theme:upper(), x, themeY + 16, themeBtnW, "center")

        table.insert(themePositions, {
            id = theme,
            x1 = x, y1 = themeY,
            x2 = x + themeBtnW, y2 = themeY + themeBtnH
        })
    end

    -- =====================================================
    -- SUBMIT BUTTON
    -- =====================================================
    local submitW, submitH = 200, 50
    local submitX = (w - submitW) / 2
    local submitY = 330

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

    -- =====================================================
    -- BACK BUTTON
    -- =====================================================
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

    -- BACK
    if x >= 20 and x <= 100 and y >= 15 and y <= 45 then
        StateManager.switch(require("states.menu"))
        return
    end

    -- DIFFICULTY
    for _, pos in ipairs(diffPositions) do
        if x >= pos.x1 and x <= pos.x2 and y >= pos.y1 and y <= pos.y2 then
            selectedDiff = pos.id
            return
        end
    end

    -- THEME
    for _, pos in ipairs(themePositions) do
        if x >= pos.x1 and x <= pos.x2 and y >= pos.y1 and y <= pos.y2 then
            selectedTheme = pos.id
            return
        end
    end

    -- SUBMIT
    if submitPosition and x >= submitPosition.x1 and x <= submitPosition.x2
        and y >= submitPosition.y1 and y <= submitPosition.y2 then
        Game.difficulty = selectedDiff
        Game.theme = selectedTheme
        StateManager.switch(require("states.menu"))
        return
    end
end

function Options.mousemoved(x, y)
    hoveredBack = (x >= 20 and x <= 100 and y >= 15 and y <= 45)

    hoveredDiff = nil
    for _, pos in ipairs(diffPositions) do
        if x >= pos.x1 and x <= pos.x2 and y >= pos.y1 and y <= pos.y2 then
            hoveredDiff = pos.id
            break
        end
    end

    hoveredTheme = nil
    for _, pos in ipairs(themePositions) do
        if x >= pos.x1 and x <= pos.x2 and y >= pos.y1 and y <= pos.y2 then
            hoveredTheme = pos.id
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
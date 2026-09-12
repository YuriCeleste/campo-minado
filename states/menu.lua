local StateManager = require("statemanager")
local Assets = require("assets")
local Game = require("game")

local Menu = {}
local buttons = {}
local hoveredButton = nil
local tempo = 0

local ANGULO = -8

function Menu.enter()
    buttons = {
        { label = "PLAY",     y = 80,  action = function() StateManager.switch(require("states.game")) end },
        { label = "OPTIONS",  y = 160, action = function() StateManager.switch(require("states.options")) end },
        { label = "TUTORIAL", y = 240, action = function() StateManager.switch(require("states.tutorial")) end },
        { label = "CREDITS",  y = 320, action = function() StateManager.switch(require("states.credits")) end },
    }
    hoveredButton = nil
    tempo = 0
end

function Menu.update(dt)
    tempo = tempo + dt
end

function Menu.draw()
    local t = Game.themes[Game.theme]
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()
    local panelW = 260

    love.graphics.clear(t.background)

    -- 1. CAR IMAGE (reta, sem rotação)
    local img = Assets.get("menu_car.png")
    if img then
        local iw, ih = img:getDimensions()
        local areaW, areaH = w - panelW, h
        local scale = math.max(areaW / iw, areaH / ih)
        love.graphics.setColor(1.05, 1.05, 1.05)
        love.graphics.draw(img, panelW + areaW / 2, areaH / 2, 0, -scale, scale, iw / 2, ih / 2)
    else
        love.graphics.setColor(t.panel)
        love.graphics.rectangle("fill", panelW, 0, w - panelW, h)
    end

    -- 2. GRAY PANEL WITH GRADIENT
    love.graphics.push()
    love.graphics.translate(panelW / 2, h / 2)
    love.graphics.rotate(math.rad(ANGULO))

    local altura = h * 1.5
    local larguraPainel = panelW * 1.8

    for i = 0, larguraPainel do
        local p = i / larguraPainel
        local c
        if Game.theme == "dark" then
            if p < 0.7 then
                c = 0.60 - (i / larguraPainel) * 0.05
            else
                local tDegrade = (p - 0.7) / 0.3
                c = 0.55 * (1 - tDegrade)
            end
        else
            if p < 0.7 then
                c = 0.75 - (i / larguraPainel) * 0.05
            else
                local tDegrade = (p - 0.7) / 0.3
                c = 0.70 * (1 - tDegrade)
            end
        end
        love.graphics.setColor(c, c, c)
        love.graphics.rectangle("fill", -larguraPainel / 2 + i, -altura, 1, altura * 2)
    end
    love.graphics.pop()

    -- 3. BLACK TITLE BAR
    love.graphics.setColor(t.titleBar)
    love.graphics.rectangle("fill", 0, 0, w, 55)
    love.graphics.setColor(t.textDim)
    love.graphics.rectangle("fill", 0, 55, w, 1)
    love.graphics.setColor(t.titleText)
    love.graphics.printf("MINESWEEPER", 0, 18, w, "center")

    -- 4. BUTTONS
    for _, btn in ipairs(buttons) do
        local isHovered = (hoveredButton == btn)
        local offsetX = isHovered and 8 or 0

        love.graphics.setColor(0, 0, 0, 0.3)
        love.graphics.rectangle("fill", 15 + offsetX, btn.y + 3, 220, 45)

        local corFundo = isHovered and t.buttonHover or t.buttonBg
        love.graphics.setColor(corFundo)
        love.graphics.rectangle("fill", 15 + offsetX, btn.y, 220, 45)

        local corBorda = isHovered and {0.9, 0.9, 0.9} or t.buttonBorder
        love.graphics.setColor(corBorda)
        love.graphics.rectangle("line", 15 + offsetX, btn.y, 220, 45)

        love.graphics.setColor(t.text)
        love.graphics.printf(btn.label, 15 + offsetX, btn.y + 14, 220, "center")
    end
end

function Menu.mousepressed(x, y, button)
    if button ~= 1 then return end
    for _, btn in ipairs(buttons) do
        if x >= 15 and x <= 235 and y >= btn.y and y <= btn.y + 45 then
            btn.action()
        end
    end
end

function Menu.mousemoved(x, y)
    hoveredButton = nil
    for _, btn in ipairs(buttons) do
        if x >= 15 and x <= 235 and y >= btn.y and y <= btn.y + 45 then
            hoveredButton = btn
        end
    end
end

return Menu
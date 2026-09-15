local StateManager = require("statemanager")
local Assets = require("assets")
local Game = require("game")
local Fonts = require("fonts")

local Credits = {}

local authors = {
    { name = "Dayvson Lacerda Pessoa Filho", link = "https://github.com/Devs097518", display = "github.com/Devs097518", photo = "author_dayvson.png" },
    { name = "Yuri William Ferreira Calixto", link = "https://github.com/YuriCeleste", display = "github.com/YuriCeleste", photo = "author_yuri.png" },
}

local techs = { "Lua", "Love2D" }

local hoveredLink = nil
local hoveredBack = false
local linkPositions = {}

-- Mensagem de retorno quando o link não abre sozinho (ex: navegador
-- não configurado), pra sempre dar algum feedback visível ao clique.
local feedbackText = nil
local feedbackTimer = 0

function Credits.enter()
    hoveredLink = nil
    hoveredBack = false
    linkPositions = {}
    feedbackText = nil
    feedbackTimer = 0
end

function Credits.update(dt)
    if feedbackTimer > 0 then
        feedbackTimer = feedbackTimer - dt
        if feedbackTimer <= 0 then
            feedbackText = nil
        end
    end
end

function Credits.draw()
    local t = Game.themes[Game.theme]
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()

    love.graphics.clear(t.background)

    -- BLACK TITLE BAR
    love.graphics.setColor(t.titleBar)
    love.graphics.rectangle("fill", 0, 0, w, 55)
    love.graphics.setColor(t.textDim)
    love.graphics.rectangle("fill", 0, 55, w, 1)
    love.graphics.setColor(t.titleText)
    love.graphics.setFont(Fonts.heading)
    love.graphics.printf("CREDITS", 0, (55 - Fonts.heading:getHeight()) / 2, w, "center")

    -- CARDS (foto grande em cima, nome e link embaixo)
    linkPositions = {}

    local photoSize = 110
    local cardW = 300
    local gap = 40
    local totalW = #authors * cardW + (#authors - 1) * gap
    local startX = (w - totalW) / 2
    local photoTop = 90

    for i, author in ipairs(authors) do
        local cardX = startX + (i - 1) * (cardW + gap)
        local cx = cardX + cardW / 2
        local cy = photoTop + photoSize / 2
        local raio = photoSize / 2

        local img = Assets.get(author.photo)
        if img then
            love.graphics.stencil(function()
                love.graphics.circle("fill", cx, cy, raio)
            end, "replace", 1)

            love.graphics.setStencilTest("greater", 0)

            local iw, ih = img:getDimensions()
            local scale = photoSize / math.min(iw, ih)
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(img, cx, cy, 0, scale, scale, iw / 2, ih / 2)

            love.graphics.setStencilTest()

            love.graphics.setColor(t.textDim)
            love.graphics.circle("line", cx, cy, raio)
        else
            love.graphics.setColor(0.4, 0.4, 0.4)
            love.graphics.circle("fill", cx, cy, raio)
            love.graphics.setColor(t.text)
            love.graphics.setFont(Fonts.title)
            love.graphics.printf(string.sub(author.name, 1, 1), cardX, cy - Fonts.title:getHeight() / 2, cardW, "center")
        end

        local nameY = photoTop + photoSize + 18
        love.graphics.setColor(t.text)
        love.graphics.setFont(Fonts.body)
        love.graphics.printf(author.name, cardX, nameY, cardW, "center")

        local linkY = nameY + 26
        local isHovered = (hoveredLink == author)

        love.graphics.setFont(Fonts.small)
        love.graphics.setColor(isHovered and { 0.4, 0.8, 1.0 } or { 0.5, 0.6, 0.95 })
        love.graphics.printf(author.display, cardX, linkY, cardW, "center")

        local linkTextW = Fonts.small:getWidth(author.display)
        local linkX1 = cx - linkTextW / 2
        local linkX2 = cx + linkTextW / 2

        if isHovered then
            love.graphics.rectangle("fill", linkX1, linkY + Fonts.small:getHeight(), linkTextW, 1)
        end

        table.insert(linkPositions, {
            author = author,
            x1 = linkX1, y1 = linkY,
            x2 = linkX2, y2 = linkY + Fonts.small:getHeight(),
        })
    end

    -- TECHNOLOGIES
    local techY = photoTop + photoSize + 18 + 26 + 40
    love.graphics.setColor(t.text)
    love.graphics.setFont(Fonts.body)
    love.graphics.printf("Technologies used", 0, techY, w, "center")

    love.graphics.setFont(Fonts.small)
    local techLine = table.concat(techs, "   •   ")
    love.graphics.setColor(t.textDim)
    love.graphics.printf(techLine, 0, techY + 26, w, "center")

    -- FEEDBACK (quando o link é copiado em vez de abrir sozinho)
    if feedbackText then
        love.graphics.setColor(0.4, 0.9, 0.5)
        love.graphics.setFont(Fonts.small)
        love.graphics.printf(feedbackText, 0, h - 34, w, "center")
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

function Credits.mousepressed(x, y, button)
    if button ~= 1 then return end

    if x >= 20 and x <= 100 and y >= 15 and y <= 45 then
        StateManager.switch(require("states.menu"))
        return
    end

    for _, pos in ipairs(linkPositions) do
        if x >= pos.x1 and x <= pos.x2 and y >= pos.y1 and y <= pos.y2 then
            local opened = love.system.openURL(pos.author.link)
            if not opened then
                love.system.setClipboardText(pos.author.link)
                feedbackText = "Couldn't open the browser — link copied to clipboard!"
                feedbackTimer = 3
            end
            return
        end
    end
end

function Credits.mousemoved(x, y)
    hoveredBack = (x >= 20 and x <= 100 and y >= 15 and y <= 45)

    hoveredLink = nil
    for _, pos in ipairs(linkPositions) do
        if x >= pos.x1 and x <= pos.x2 and y >= pos.y1 and y <= pos.y2 then
            hoveredLink = pos.author
            break
        end
    end
end

function Credits.keypressed(key)
    if key == "escape" then
        StateManager.switch(require("states.menu"))
    end
end

return Credits
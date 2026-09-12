local StateManager = require("statemanager")
local Assets = require("assets")

local Credits = {}

local authors = {
    { name = "Dayvson Lacerda Pessoa Filho", link = "https://github.com/Devs097518", display = "github.com/Devs097518", photo = "author_dayvson.png" },
    { name = "Yuri William Ferreira Calixto", link = "https://github.com/YuriCeleste", display = "github.com/YuriCeleste", photo = "author_yuri.png" },
}

local techs = { "Lua", "Love2D" }

local hoveredLink = nil
local hoveredBack = false

local linkPositions = {}

function Credits.enter()
    hoveredLink = nil
    hoveredBack = false
    linkPositions = {}
end

function Credits.draw()
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()

    love.graphics.clear(0.1, 0.1, 0.1)

    -- BLACK TITLE BAR
    love.graphics.setColor(0, 0, 0, 0.95)
    love.graphics.rectangle("fill", 0, 0, w, 55)
    love.graphics.setColor(0.6, 0.6, 0.6, 0.5)
    love.graphics.rectangle("fill", 0, 55, w, 1)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("CREDITS", 0, 18, w, "center")

    -- AUTHORS
    local y = 100
    local photoSize = 60
    local marginX = 80

    for _, author in ipairs(authors) do
        local img = Assets.get(author.photo)

        if img then
            local cx = marginX + photoSize / 2
            local cy = y + photoSize / 2
            local raio = photoSize / 2

            love.graphics.stencil(function()
                love.graphics.circle("fill", cx, cy, raio)
            end, "replace", 1)

            love.graphics.setStencilTest("greater", 0)

            local iw, ih = img:getDimensions()
            local scale = photoSize / math.min(iw, ih)
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(img, cx, cy, 0, scale, scale, iw / 2, ih / 2)

            love.graphics.setStencilTest()

            love.graphics.setColor(0.6, 0.6, 0.6, 0.5)
            love.graphics.circle("line", cx, cy, raio)
        else
            love.graphics.setColor(0.4, 0.4, 0.4)
            love.graphics.circle("fill", marginX + photoSize / 2, y + photoSize / 2, photoSize / 2)
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf(string.sub(author.name, 1, 1), marginX, y + 18, photoSize, "center")
        end

        local textX = marginX + photoSize + 20
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(author.name, textX, y + 8)

        local linkY = y + 34
        local isHovered = (hoveredLink == author)

        if isHovered then
            love.graphics.setColor(0.4, 0.8, 1.0)
        else
            love.graphics.setColor(0.5, 0.5, 0.9)
        end
        love.graphics.print(author.display, textX, linkY)

        if isHovered then
            local textoLargura = love.graphics.getFont():getWidth(author.display)
            love.graphics.setColor(0.4, 0.8, 1.0)
            love.graphics.rectangle("fill", textX, linkY + 16, textoLargura, 1)
        end

        table.insert(linkPositions, {
            author = author,
            x1 = textX, y1 = linkY,
            x2 = textX + 300, y2 = linkY + 20
        })

        y = y + photoSize + 30
    end

    -- TECHNOLOGIES
    y = y + 20
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.print("Technologies used:", marginX, y)

    y = y + 30
    for _, tech in ipairs(techs) do
        love.graphics.setColor(0.6, 0.6, 0.6)
        love.graphics.print("• " .. tech, marginX + 20, y)
        y = y + 22
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

function Credits.mousepressed(x, y, button)
    if button ~= 1 then return end

    if x >= 20 and x <= 100 and y >= 15 and y <= 45 then
        StateManager.switch(require("states.menu"))
        return
    end

    for _, pos in ipairs(linkPositions) do
        if x >= pos.x1 and x <= pos.x2 and y >= pos.y1 and y <= pos.y2 then
            love.system.openURL(pos.author.link)
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
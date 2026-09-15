local StateManager = require("statemanager")
local Game = require("game")
local Board = require("board")
local Car = require("car")
local Assets = require("assets")
local Effects = require("effects")
local Fonts = require("fonts")

local Gameplay = {}

local board, car
local elapsedTime = 0
local tileSize = 40
local boardOffsetX, boardOffsetY = 20, 60
local gameOver = false
local success = false
local carFacing = 1
local carRotation = 0

local PREVIEW_DURATION = 1.0
local FADE_DURATION = 1.0
local phase = "preview"
local phaseTimer = 0


function Gameplay.enter()
    local settings = Board.getSettings(Game.difficulty)
    board = Board.new(Game.difficulty)
    car = Car.new(board, settings.maxDamage, settings.maxSkips)

    elapsedTime = 0
    gameOver = false
    success = false
    carFacing = 1
    carRotation = 0
    phase = "preview"
    phaseTimer = 0
    Effects.reset()

    local availableW = love.graphics.getWidth() - 220
    local availableH = love.graphics.getHeight() - 100
    tileSize = math.floor(math.min(availableW, availableH) / board.size)
    boardOffsetX = 20
    boardOffsetY = 60
end

local function previewAlpha()
    if phase == "preview" then
        return 1
    elseif phase == "fading" then
        return 1 - (phaseTimer / FADE_DURATION)
    end
    return 0
end

local function tileCenter(row, col)
    return boardOffsetX + (col - 1) * tileSize + tileSize / 2,
        boardOffsetY + (row - 1) * tileSize + tileSize / 2
end

function Gameplay.update(dt)
    if phase == "preview" then
        phaseTimer = phaseTimer + dt
        if phaseTimer >= PREVIEW_DURATION then
            phase = "fading"
            phaseTimer = 0
        end
        return
    elseif phase == "fading" then
        phaseTimer = phaseTimer + dt
        if phaseTimer >= FADE_DURATION then
            phase = "playing"
        end
        return
    end

    car:updateAnim(dt)
    Effects.update(dt)

    if not car.eventConsumed and not car:isAnimating() and car.lastEvent then
        local ex, ey = tileCenter(car.lastEvent.row, car.lastEvent.col)
        if car.lastEvent.type == "bomb_damage" then
            Effects.spawnBombDamage(ex, ey)
        elseif car.lastEvent.type == "bomb_absorbed" then
            Effects.spawnBombAbsorbed(ex, ey)
        elseif car.lastEvent.type == "shield_collected" then
            Effects.spawnShieldCollected(ex, ey)
        end
        car.eventConsumed = true
    end

    if gameOver then return end

    elapsedTime = elapsedTime + dt

    if car:isAnimating() then return end

    if not car.alive then
        gameOver = true
        success = false
        Gameplay.finish()
    elseif car.finished then
        gameOver = true
        success = true
        Gameplay.finish()
    end
end

function Gameplay.finish()
    Game.stats = {
        time = elapsedTime,
        bombsHit = car.bombsHit,
        tilesTraveled = car.tilesTraveled,
        success = success,
    }
end

local function tileColor(tile, row, col)
    if row == board.startPos.row and col == board.startPos.col then
        return 0.3, 0.6, 0.9
    elseif row == board.endPos.row and col == board.endPos.col then
        return 0.3, 0.8, 0.3
    elseif tile.visited then
        return 0.8, 0.8, 0.65
    elseif (row + col) % 2 == 0 then
        return 0.55, 0.75, 0.45
    else
        return 0.45, 0.65, 0.35
    end
end

function Gameplay.draw()
    local t = Game.themes[Game.theme]
    love.graphics.clear(t.background)

    local shakeX, shakeY = Effects.getShakeOffset()
    love.graphics.push()
    love.graphics.translate(shakeX, shakeY)

    for row = 1, board.size do
        for col = 1, board.size do
            local tile = board:getTile(row, col)
            local x = boardOffsetX + (col - 1) * tileSize
            local y = boardOffsetY + (row - 1) * tileSize
            local isEnd = (row == board.endPos.row and col == board.endPos.col)

            if not isEnd or not Assets.get("house.png") then
                local r, g, b = tileColor(tile, row, col)
                love.graphics.setColor(r, g, b)
                love.graphics.rectangle("fill", x, y, tileSize, tileSize)
            end

            if isEnd then
                Assets.drawFitted("house.png", x, y, tileSize)
            end

            if tile.visited and tile.original == "shield" then
                if not Assets.drawFitted("shield.png", x, y, tileSize - 4) then
                    love.graphics.setColor(1, 0.85, 0.3)
                    love.graphics.circle("fill", x + tileSize / 2, y + tileSize / 2, tileSize / 5)
                end
            elseif tile.visited and tile.original == "bomb" then
                if not Assets.drawFitted("bomb.png", x, y, tileSize - 4, { alpha = 0.6 }) then
                    love.graphics.setColor(0.1, 0.1, 0.1, 0.6)
                    love.graphics.circle("fill", x + tileSize / 2, y + tileSize / 2, tileSize / 4)
                end
            elseif not tile.visited and tile.type ~= "empty" then
                local alpha = previewAlpha()
                if alpha > 0.01 then
                    local icon = tile.type == "bomb" and "bomb.png" or "shield.png"
                    if not Assets.drawFitted(icon, x, y, tileSize - 4, { alpha = alpha }) then
                        if tile.type == "bomb" then
                            love.graphics.setColor(0.1, 0.1, 0.1, alpha)
                        else
                            love.graphics.setColor(1, 0.85, 0.3, alpha)
                        end
                        love.graphics.circle("fill", x + tileSize / 2, y + tileSize / 2, tileSize / 4)
                    end
                end
            end
        end
    end

    local carX = boardOffsetX + (car.visualCol - 1) * tileSize
    local carY = boardOffsetY + (car.visualRow - 1) * tileSize
    if not Assets.drawFitted("car_icon.png", carX, carY, tileSize - 2,
        { flipX = carFacing < 0, rotation = carRotation }) then
        love.graphics.setColor(0.9, 0.2, 0.2)
        love.graphics.circle("fill", carX + tileSize / 2, carY + tileSize / 2, tileSize / 3)
    end

    Effects.draw()

    love.graphics.pop()

    Gameplay.drawHud()

    if phase ~= "playing" then
        love.graphics.setColor(t.text[1], t.text[2], t.text[3], math.min(1, previewAlpha() + 0.3))
        love.graphics.setFont(Fonts.subhead)
        love.graphics.printf("MEMORIZE THE PATH...", boardOffsetX, boardOffsetY - 34,
            board.size * tileSize, "center")
    end

    if gameOver then
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

        local resultColor = success and t.success or t.danger
        local panelW, panelH = 460, 130
        local panelX = (love.graphics.getWidth() - panelW) / 2
        local panelY = (love.graphics.getHeight() - panelH) / 2

        love.graphics.setColor(0, 0, 0, 0.35)
        love.graphics.rectangle("fill", panelX + 3, panelY + 4, panelW, panelH, 10)
        love.graphics.setColor(t.panel)
        love.graphics.rectangle("fill", panelX, panelY, panelW, panelH, 10)
        love.graphics.setColor(resultColor)
        love.graphics.setLineWidth(3)
        love.graphics.rectangle("line", panelX, panelY, panelW, panelH, 10)

        love.graphics.setFont(Fonts.heading)
        local msg = success and "YOU MADE IT!" or "THE CAR DIDN'T SURVIVE"
        love.graphics.printf(msg, panelX, panelY + 30, panelW, "center")

        love.graphics.setColor(t.textDim)
        love.graphics.setFont(Fonts.small)
        love.graphics.printf("Click to see the results", panelX, panelY + 80, panelW, "center")
    end
end

function Gameplay.drawHud()
    local t = Game.themes[Game.theme]
    local panelX = boardOffsetX + board.size * tileSize + 20
    local panelW = 220

    local resistanceLeft = car.maxDamage - car.damage
    local resistanceColor = resistanceLeft <= 1 and t.danger or (resistanceLeft <= 2 and t.warning or t.success)

    local stats = {
        { label = "TILES TRAVELED", value = tostring(car.tilesTraveled), color = t.text },
        { label = "RESISTANCE",     value = resistanceLeft .. " / " .. car.maxDamage, color = resistanceColor },
        { label = "SHIELDS",        value = tostring(car.shields), color = t.warning },
        { label = "JUMPS LEFT",     value = tostring(car.skipsLeft), color = t.accent },
        { label = "TIME",           value = string.format("%.1fs", elapsedTime), color = t.text },
    }

    local rowH = 46
    local panelH = #stats * rowH + 16
    local panelY = 60

    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.rectangle("fill", panelX + 2, panelY + 3, panelW, panelH, 8)
    love.graphics.setColor(t.panel)
    love.graphics.rectangle("fill", panelX, panelY, panelW, panelH, 8)
    love.graphics.setColor(t.buttonBorder)
    love.graphics.rectangle("line", panelX, panelY, panelW, panelH, 8)

    local y = panelY + 10
    for _, stat in ipairs(stats) do
        love.graphics.setColor(t.textDim)
        love.graphics.setFont(Fonts.small)
        love.graphics.print(stat.label, panelX + 16, y)

        love.graphics.setColor(stat.color)
        love.graphics.setFont(Fonts.mono)
        love.graphics.printf(stat.value, panelX, y + 15, panelW - 16, "right")

        y = y + rowH
    end

    -- Cartão de ajuda dos controles
    local helpY = panelY + panelH + 16
    local helpH = 90
    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.rectangle("fill", panelX + 2, helpY + 3, panelW, helpH, 8)
    love.graphics.setColor(t.panelLight)
    love.graphics.rectangle("fill", panelX, helpY, panelW, helpH, 8)
    love.graphics.setColor(t.buttonBorder)
    love.graphics.rectangle("line", panelX, helpY, panelW, helpH, 8)

    love.graphics.setFont(Fonts.small)
    love.graphics.setColor(t.accent)
    love.graphics.print("Click adjacent", panelX + 16, helpY + 12)
    love.graphics.setColor(t.textDim)
    love.graphics.print("move 1 tile", panelX + 16, helpY + 30)

    love.graphics.setColor(t.accent)
    love.graphics.print("Click 2 tiles away", panelX + 16, helpY + 54)
    love.graphics.setColor(t.textDim)
    love.graphics.print("jump tile", panelX + 16, helpY + 72)
end

function Gameplay.mousepressed(x, y, button)
    if button ~= 1 then return end
    if phase ~= "playing" then return end

    if gameOver then
        StateManager.switch(require("states.results"))
        return
    end

    local col = math.floor((x - boardOffsetX) / tileSize) + 1
    local row = math.floor((y - boardOffsetY) / tileSize) + 1

    if board:isInside(row, col) then
        if col > car.col then
            carFacing = 1
            carRotation = 0
        elseif col < car.col then
            carFacing = -1
            carRotation = 0
        end
        if row > car.row then
            carRotation = math.pi / 2
        elseif row < car.row then
            carRotation = -math.pi / 2
        end
        car:moveTo(row, col)
    end
end


return Gameplay
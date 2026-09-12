local StateManager = require("statemanager")
local Game = require("game")
local Board = require("board")
local Car = require("car")
local Assets = require("assets")
local Effects = require("effects")

local Gameplay = {}

local board, car
local elapsedTime = 0
local tileSize = 40
local boardOffsetX, boardOffsetY = 20, 60
local gameOver = false
local success = false
local carFacing = 1 -- 1 = olhando pra direita, -1 = olhando pra esquerda
local carRotation = 0

-- Fase de prévia: mostra os tijolos perigosos por um tempo, depois
-- some com um fade suave, e só então o jogo (e o tempo) começam.
local PREVIEW_DURATION = 1.0
local FADE_DURATION = 1.0
local phase = "preview" -- "preview" | "fading" | "playing"
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

-- Opacidade dos ícones de bombas/energia ainda não visitados: 1 durante
-- a prévia, caindo até 0 durante o fade, 0 no jogo normal.
local function previewAlpha()
    if phase == "preview" then
        return 1
    elseif phase == "fading" then
        return 1 - (phaseTimer / FADE_DURATION)
    end
    return 0
end

-- Centro em pixels de um tijolo (linha, coluna), pra posicionar
-- efeitos visuais.
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

    -- Dispara o efeito visual (partículas) só quando o carro chega de
    -- verdade no tijolo, não no instante em que o clique acontece.
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

    if car:isAnimating() then return end -- espera o deslize terminar antes de checar fim de jogo

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
    love.graphics.clear(0.1, 0.1, 0.1)

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
                love.graphics.rectangle("fill", x, y, tileSize - 2, tileSize - 2)
            end

            if isEnd then
                Assets.drawFitted("house.png", x, y, tileSize - 2)
            end

            -- Ícones de tijolos já revelados (visitados), usando
            -- "original" pra saber o que tinha ali mesmo depois de
            -- bomba já ter explodido / energia já ter sido coletada.
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
                -- Prévia inicial: mostra bombas/energia ainda não
                -- visitadas, com opacidade que cai até sumir de vez.
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
        love.graphics.setColor(1, 1, 1, math.min(1, previewAlpha() + 0.3))
        love.graphics.printf("MEMORIZE O CAMINHO...", boardOffsetX, boardOffsetY - 24,
            board.size * tileSize, "center")
    end

    if gameOver then
        love.graphics.setColor(0, 0, 0, 0.65)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1, 1, 1)
        local msg = success
            and "VOCÊ CHEGOU! Clique para ver o resultado."
            or "O CARRO NÃO RESISTIU. Clique para ver o resultado."
        love.graphics.printf(msg, 0, love.graphics.getHeight() / 2 - 10, love.graphics.getWidth(), "center")
    end
end

function Gameplay.drawHud()
    local panelX = boardOffsetX + board.size * tileSize + 20
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(string.format("Tijolos percorridos: %d", car.tilesTraveled), panelX, 60)
    love.graphics.print(string.format("Resistência: %d / %d", car.maxDamage - car.damage, car.maxDamage), panelX, 85)
    love.graphics.print(string.format("Escudos: %d", car.shields), panelX, 110)
    love.graphics.print(string.format("Pulos restantes: %d", car.skipsLeft), panelX, 135)
    love.graphics.print(string.format("Tempo: %.1fs", elapsedTime), panelX, 160)
    love.graphics.print("Clique adjacente:", panelX, 200)
    love.graphics.print("  andar 1 casa", panelX, 218)
    love.graphics.print("Clique a 2 casas:", panelX, 245)
    love.graphics.print("  pular tijolo", panelX, 263)
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
local StateManager = require("statemanager")
local Game = require("game")
local Board = require("board")
local Car = require("car")

local Gameplay = {}

local board, car
local elapsedTime = 0
local tileSize = 40
local boardOffsetX, boardOffsetY = 20, 60
local gameOver = false
local success = false

function Gameplay.enter()
    local settings = Board.getSettings(Game.difficulty)
    board = Board.new(Game.difficulty)
    car = Car.new(board, settings.maxDamage, settings.maxSkips)

    elapsedTime = 0
    gameOver = false
    success = false

    local availableW = love.graphics.getWidth() - 220
    local availableH = love.graphics.getHeight() - 100
    tileSize = math.floor(math.min(availableW, availableH) / board.size)
    boardOffsetX = 20
    boardOffsetY = 60
end

function Gameplay.update(dt)
    if gameOver then return end

    elapsedTime = elapsedTime + dt

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

    for row = 1, board.size do
        for col = 1, board.size do
            local tile = board:getTile(row, col)
            local x = boardOffsetX + (col - 1) * tileSize
            local y = boardOffsetY + (row - 1) * tileSize

            local r, g, b = tileColor(tile, row, col)
            love.graphics.setColor(r, g, b)
            love.graphics.rectangle("fill", x, y, tileSize - 2, tileSize - 2)

            -- Ícones só aparecem em tijolos já visitados (já resolvidos).
            if tile.visited and tile.type == "shield" then
                love.graphics.setColor(1, 0.85, 0.3)
                love.graphics.circle("fill", x + tileSize / 2, y + tileSize / 2, tileSize / 5)
            end
        end
    end

    local carX = boardOffsetX + (car.col - 1) * tileSize + tileSize / 2
    local carY = boardOffsetY + (car.row - 1) * tileSize + tileSize / 2
    love.graphics.setColor(0.9, 0.2, 0.2)
    love.graphics.circle("fill", carX, carY, tileSize / 3)

    Gameplay.drawHud()

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

    if gameOver then
        StateManager.switch(require("states.results"))
        return
    end

    local col = math.floor((x - boardOffsetX) / tileSize) + 1
    local row = math.floor((y - boardOffsetY) / tileSize) + 1

    if board:isInside(row, col) then
        car:moveTo(row, col)
    end
end

return Gameplay

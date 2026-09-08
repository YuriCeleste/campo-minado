-- Tabuleiro do jogo: representado como uma matriz bidimensional
-- (array de arrays) em self.tiles[linha][coluna].
-- Cada tijolo tem um "type": "empty" | "bomb" | "shield"
-- e um flag "visited" (se o carrinho já passou por ali).

local Board = {}
Board.__index = Board

-- Configuração de cada dificuldade: tamanho do tabuleiro (NxN) e a
-- porcentagem de tijolos especiais, proporcional ao tamanho do mapa.
local DIFFICULTY_SETTINGS = {
    easy   = { size = 6,  bombPct = 0.10, shieldPct = 0.08, maxDamage = 4, maxSkips = 4 },
    medium = { size = 9,  bombPct = 0.13, shieldPct = 0.08, maxDamage = 3, maxSkips = 3 },
    hard   = { size = 12, bombPct = 0.16, shieldPct = 0.07, maxDamage = 2, maxSkips = 2 },
}

function Board.getSettings(difficulty)
    return DIFFICULTY_SETTINGS[difficulty] or DIFFICULTY_SETTINGS.medium
end

function Board.new(difficulty)
    local settings = Board.getSettings(difficulty)
    local size = settings.size

    local self = setmetatable({}, Board)
    self.size = size
    self.settings = settings
    self.tiles = {}

    for row = 1, size do
        self.tiles[row] = {}
        for col = 1, size do
            self.tiles[row][col] = { type = "empty", visited = false }
        end
    end

    -- Início embaixo à esquerda (perto da estrada), fim em cima à
    -- direita (perto da casinha), como nas prototipações.
    self.startPos = { row = size, col = 1 }
    self.endPos = { row = 1, col = size }

    local totalTiles = size * size
    local bombCount = math.max(1, math.floor(totalTiles * settings.bombPct))
    local shieldCount = math.max(1, math.floor(totalTiles * settings.shieldPct))

    self:placeRandom("bomb", bombCount)
    self:placeRandom("shield", shieldCount)

    self.tiles[self.startPos.row][self.startPos.col].visited = true

    return self
end

function Board:isReserved(row, col)
    return (row == self.startPos.row and col == self.startPos.col)
        or (row == self.endPos.row and col == self.endPos.col)
end

function Board:placeRandom(kind, count)
    local placed = 0
    local attempts = 0
    local maxAttempts = count * 100

    while placed < count and attempts < maxAttempts do
        attempts = attempts + 1
        local row = love.math.random(1, self.size)
        local col = love.math.random(1, self.size)
        local tile = self.tiles[row][col]

        if tile.type == "empty" and not self:isReserved(row, col) then
            tile.type = kind
            placed = placed + 1
        end
    end
end

function Board:isInside(row, col)
    return row >= 1 and row <= self.size and col >= 1 and col <= self.size
end

function Board:getTile(row, col)
    if not self:isInside(row, col) then
        return nil
    end
    return self.tiles[row][col]
end

return Board

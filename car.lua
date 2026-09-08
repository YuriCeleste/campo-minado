-- Carrinho: posição no tabuleiro, resistência a avarias, escudos de
-- campo de força e a mecânica de "pular" tijolos suspeitos.

local Car = {}
Car.__index = Car

function Car.new(board, maxDamage, maxSkips)
    local self = setmetatable({}, Car)
    self.board = board
    self.row = board.startPos.row
    self.col = board.startPos.col

    self.damage = 0
    self.maxDamage = maxDamage or 3
    self.shields = 0
    self.skipsLeft = maxSkips or 3

    self.tilesTraveled = 0
    self.bombsHit = 0

    self.alive = true
    self.finished = false

    return self
end

-- Tijolo ortogonalmente vizinho (1 casa de distância).
function Car:isAdjacent(row, col)
    local dr = math.abs(row - self.row)
    local dc = math.abs(col - self.col)
    return (dr + dc) == 1
end

-- Tijolo 2 casas adiante, em linha reta, com um tijolo "suspeito" no
-- meio a ser pulado. Retorna também a posição do tijolo do meio.
function Car:isTwoAhead(row, col)
    local dr = row - self.row
    local dc = col - self.col

    if dr == 0 and math.abs(dc) == 2 then
        return true, self.row, self.col + dc / 2
    end
    if dc == 0 and math.abs(dr) == 2 then
        return true, self.row + dr / 2, self.col
    end
    return false
end

-- Tenta mover o carrinho até (row, col). Retorna sucesso (bool) e uma
-- mensagem descrevendo o que aconteceu.
function Car:moveTo(row, col)
    if not self.alive or self.finished then
        return false, "jogo encerrado"
    end
    if not self.board:isInside(row, col) then
        return false, "fora do tabuleiro"
    end

    if self:isAdjacent(row, col) then
        self:enterTile(row, col)
        return true, "andou"
    end

    local isJump = self:isTwoAhead(row, col)
    if isJump then
        if self.skipsLeft <= 0 then
            return false, "sem pulos disponíveis"
        end
        self.skipsLeft = self.skipsLeft - 1
        -- O tijolo do meio é totalmente ignorado: não é revelado,
        -- não conta como percorrido e não pode causar dano.
        self.row = row
        self.col = col
        self.tilesTraveled = self.tilesTraveled + 1
        self.board:getTile(row, col).visited = true
        self:checkFinish()
        return true, "pulou"
    end

    return false, "tijolo não alcançável"
end

function Car:enterTile(row, col)
    self.row = row
    self.col = col
    self.tilesTraveled = self.tilesTraveled + 1

    local tile = self.board:getTile(row, col)
    tile.visited = true

    if tile.type == "bomb" then
        self.bombsHit = self.bombsHit + 1
        if self.shields > 0 then
            -- O campo de força absorve o impacto, mas se esgota um pouco.
            self.shields = self.shields - 1
        else
            self.damage = self.damage + 1
            if self.damage >= self.maxDamage then
                self.alive = false
            end
        end
        tile.type = "empty" -- a bomba já detonou
    elseif tile.type == "shield" then
        self.shields = self.shields + 1
        self.maxDamage = self.maxDamage + 1 -- fica mais resistente a cada energia coletada
        tile.type = "empty"
    end

    self:checkFinish()
end

function Car:checkFinish()
    if self.row == self.board.endPos.row and self.col == self.board.endPos.col then
        self.finished = true
    end
end

return Car

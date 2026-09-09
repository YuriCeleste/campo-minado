-- Efeitos visuais: explosão de bomba, absorção pelo escudo, coleta de
-- energia, e um leve tremor de tela ao tomar dano. Usa o sistema de
-- partículas nativo do Love2D (não precisa de nenhuma imagem externa:
-- gera uma textura de partícula simples uma vez, na primeira vez que
-- é usada).

local Effects = {}

local particleTexture
local active = {} -- lista de { ps = ParticleSystem, ttl = segundos restantes }
local shakeTime = 0
local shakeDuration = 0
local shakeStrength = 0

local function getParticleTexture()
    if particleTexture then
        return particleTexture
    end
    local size = 8
    local canvas = love.graphics.newCanvas(size, size)
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0, 0, 0, 0)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.circle("fill", size / 2, size / 2, size / 2)
    love.graphics.setCanvas()
    particleTexture = love.graphics.newImage(canvas:newImageData())
    return particleTexture
end

local function spawn(ttl, setup)
    local ps = love.graphics.newParticleSystem(getParticleTexture(), 64)
    setup(ps)
    table.insert(active, { ps = ps, ttl = ttl })
end

-- Explosão: partículas escuras/laranja se espalhando rápido, com
-- tremor de tela — a bomba causou avaria de verdade.
function Effects.spawnBombDamage(x, y)
    spawn(0.6, function(ps)
        ps:setParticleLifetime(0.25, 0.55)
        ps:setSizes(1.6, 0.2)
        ps:setSpeed(60, 170)
        ps:setSpread(math.pi * 2)
        ps:setLinearDamping(1.5)
        ps:setColors(
            1, 0.85, 0.3, 1,
            0.9, 0.3, 0.1, 1,
            0.2, 0.15, 0.15, 0
        )
        ps:setPosition(x, y)
        ps:emit(30)
    end)
    Effects.shake(0.25, 6)
end

-- Escudo absorvendo o impacto: clarão azulado, sem tremor de tela
-- (o carro não sofreu avaria).
function Effects.spawnBombAbsorbed(x, y)
    spawn(0.45, function(ps)
        ps:setParticleLifetime(0.2, 0.4)
        ps:setSizes(1.2, 0.1)
        ps:setSpeed(40, 110)
        ps:setSpread(math.pi * 2)
        ps:setLinearDamping(1.2)
        ps:setColors(
            0.6, 0.85, 1, 1,
            0.3, 0.6, 1, 0.8,
            0.2, 0.4, 1, 0
        )
        ps:setPosition(x, y)
        ps:emit(20)
    end)
end

-- Energia coletada: partículas douradas subindo, tipo um brilho.
function Effects.spawnShieldCollected(x, y)
    spawn(0.7, function(ps)
        ps:setParticleLifetime(0.35, 0.65)
        ps:setSizes(0.2, 1.1, 0.1)
        ps:setSpeed(25, 65)
        ps:setDirection(-math.pi / 2)
        ps:setSpread(math.pi / 2.5)
        ps:setColors(
            1, 0.95, 0.5, 1,
            1, 0.85, 0.3, 0.9,
            1, 0.85, 0.3, 0
        )
        ps:setPosition(x, y)
        ps:emit(18)
    end)
end

-- Pede um tremor de tela. Uma chamada só substitui a anterior se for
-- mais forte/longa (pra não exagerar se dois efeitos coincidirem).
function Effects.shake(duration, strength)
    if duration >= shakeTime then
        shakeTime = duration
        shakeDuration = duration
        shakeStrength = strength
    end
end

function Effects.update(dt)
    for i = #active, 1, -1 do
        local e = active[i]
        e.ps:update(dt)
        e.ttl = e.ttl - dt
        if e.ttl <= 0 then
            table.remove(active, i)
        end
    end

    if shakeTime > 0 then
        shakeTime = math.max(0, shakeTime - dt)
    end
end

function Effects.draw()
    love.graphics.setColor(1, 1, 1, 1)
    for _, e in ipairs(active) do
        love.graphics.draw(e.ps)
    end
end

-- Deslocamento (dx, dy) do tremor de tela pra somar numa translação.
-- A força cai gradualmente até o fim da duração do tremor.
function Effects.getShakeOffset()
    if shakeTime <= 0 then
        return 0, 0
    end
    local decay = shakeDuration > 0 and (shakeTime / shakeDuration) or 0
    local s = shakeStrength * decay
    return (love.math.random() - 0.5) * 2 * s, (love.math.random() - 0.5) * 2 * s
end

-- Limpa todo efeito e tremor pendente (chamado ao começar uma partida
-- nova, pra não herdar nada do jogo anterior).
function Effects.reset()
    active = {}
    shakeTime = 0
    shakeDuration = 0
    shakeStrength = 0
end

return Effects
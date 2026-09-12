local StateManager = require("statemanager")

function love.load()
    love.math.setRandomSeed(os.time())
    love.graphics.setBackgroundColor(0.1, 0.1, 0.1)
    StateManager.switch(require("states.menu"))
end

function love.update(dt)
    StateManager.update(dt)
end

function love.draw()
    StateManager.draw()
end

function love.mousepressed(x, y, button)
    StateManager.mousepressed(x, y, button)
end

-- ADICIONE ESTA FUNÇÃO:
function love.mousemoved(x, y, dx, dy)
    if StateManager.mousemoved then
        StateManager.mousemoved(x, y)
    end
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
    StateManager.keypressed(key)
end
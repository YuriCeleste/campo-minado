-- Gerenciador de estados (telas) do jogo.
-- Cada estado é uma tabela com funções opcionais: enter, leave, update,
-- draw, mousepressed, keypressed.

local StateManager = {}
StateManager.current = nil

function StateManager.switch(state, ...)
    if StateManager.current and StateManager.current.leave then
        StateManager.current.leave()
    end
    StateManager.current = state
    if state.enter then
        state.enter(...)
    end
end

function StateManager.update(dt)
    if StateManager.current and StateManager.current.update then
        StateManager.current.update(dt)
    end
end

function StateManager.draw()
    if StateManager.current and StateManager.current.draw then
        StateManager.current.draw()
    end
end

function StateManager.mousepressed(x, y, button)
    if StateManager.current and StateManager.current.mousepressed then
        StateManager.current.mousepressed(x, y, button)
    end
end

function StateManager.keypressed(key)
    if StateManager.current and StateManager.current.keypressed then
        StateManager.current.keypressed(key)
    end
end

return StateManager

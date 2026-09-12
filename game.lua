-- Dados compartilhados entre os estados/telas do jogo.

local Game = {
    difficulty = "medium",
    theme = "dark",  -- tema padrão
    stats = {
        time = 0,
        bombsHit = 0,
        tilesTraveled = 0,
        success = false,
    },
}

-- Paleta de cores para cada tema
Game.themes = {
    dark = {
        background   = {0.10, 0.10, 0.10},
        panel        = {0.15, 0.15, 0.15},
        text         = {1.00, 1.00, 1.00},
        textDim      = {0.70, 0.70, 0.70},
        buttonBg     = {0.20, 0.20, 0.20},
        buttonHover  = {0.35, 0.35, 0.35},
        buttonBorder = {0.40, 0.40, 0.40},
        titleBar     = {0.00, 0.00, 0.00, 0.95},
        titleText    = {1.00, 1.00, 1.00},
        accent       = {0.20, 0.50, 0.90},
    },
    light = {
        background   = {0.95, 0.95, 0.95},
        panel        = {0.85, 0.85, 0.85},
        text         = {0.10, 0.10, 0.10},
        textDim      = {0.40, 0.40, 0.40},
        buttonBg     = {0.75, 0.75, 0.75},
        buttonHover  = {0.60, 0.60, 0.60},
        buttonBorder = {0.30, 0.30, 0.30},
        titleBar     = {0.20, 0.20, 0.20, 0.95},
        titleText    = {1.00, 1.00, 1.00},
        accent       = {0.20, 0.50, 0.90},
    },
}

return Game
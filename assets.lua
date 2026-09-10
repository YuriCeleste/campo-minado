-- Carrega imagens da pasta images/ com cache e fallback seguro:
-- se o arquivo ainda não existir, retorna nil (quem desenha decide o
-- que fazer — normalmente cair de volta pra uma forma simples), em
-- vez de travar o jogo com erro.

local Assets = {}
local cache = {}

function Assets.get(filename)
    if cache[filename] ~= nil then
        if cache[filename] == false then
            return nil
        end
        return cache[filename]
    end

    local path = "images/" .. filename
    local exists = love.filesystem.getInfo(path) ~= nil

    if not exists then
        print("[imagens] não encontrei o arquivo: " .. path)
        cache[filename] = false
        return nil
    end

    local ok, imgOrErr = pcall(love.graphics.newImage, path)
    if ok then
        imgOrErr:setFilter("linear", "linear")
        cache[filename] = imgOrErr
        print("[imagens] carreguei com sucesso: " .. path)
        return imgOrErr
    else
        print("[imagens] achei o arquivo mas ele não abriu (pode não ser um PNG/JPG válido): "
            .. path .. " -- erro: " .. tostring(imgOrErr))
        cache[filename] = false
        return nil
    end
end

-- Desenha uma imagem (se existir) centralizada e escalada para caber
-- num quadrado de "size" pixels em (x, y) = canto superior esquerdo.
-- Retorna true se desenhou a imagem, false se não havia imagem.
function Assets.drawFitted(filename, x, y, size, opts)
    local img = Assets.get(filename)
    if not img then
        return false
    end

    opts = opts or {}
    local iw, ih = img:getDimensions()
    local scale = size / math.max(iw, ih)
    local flipX = opts.flipX and -1 or 1
    local rotation = opts.rotation or 0

    love.graphics.setColor(1, 1, 1, opts.alpha or 1)
    love.graphics.draw(
        img,
        x + size / 2, y + size / 2,
        rotation,
        scale * flipX, scale,
        iw / 2, ih / 2
    )
    return true
end

return Assets

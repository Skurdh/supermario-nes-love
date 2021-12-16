-- ##  Quads Generator
function generateQuads(atlas, tileWidth, tileHeight)
    local atlasWidth, atlasHeight = atlas:getDimensions()

    local sheetWidth = atlasWidth / tileWidth
    local sheetHeight = atlasHeight / tileHeight

    local tiles = {}
    local sheetCounter = 1

    for y=0, sheetHeight - 1 do
        for x=0, sheetWidth - 1 do
            tiles[sheetCounter] = love.graphics.newQuad(x * tileWidth, y * tileHeight, tileWidth, tileHeight, atlasWidth, atlasHeight)
            sheetCounter = sheetCounter + 1
        end
    end

    return tiles
end

-- # Performance
-- function perfs(title, func, loop, arg)
--     local loop = loop or 1000000 -- 1Million
    
--     collectgarbage()

--     local startTime = os.clock()
  
--     for i=1,loop do func(arg) end
  
--     local endTime = os.clock()
  
--     print(title, endTime - startTime, '\n', 1/60)
-- end


-- function ExportData(data)
--     print('Data ['..data.name..'] exported')

--     local str = ''
    
--     for k, v in pairs(data) do
--         if (k == 'data') then 
--             str = str .. k .. ' = {'

--             for i, vv in ipairs(v) do
--                 str = str .. vv ..', '
--             end

--             str = str .. '}'
--         end
--     end

--     local id = 1

--     for i=1, 10 do
--         if (love.filesystem.getInfo('merde/'..data.name..i..'.lua')) then
--             id = id + 1
--         end
--     end

--     local file = io.open('merde/'..data.name..id..'.lua', 'w+')
--     file:write(str)
--     file:close()
-- end
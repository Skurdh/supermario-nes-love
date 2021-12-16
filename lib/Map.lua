local Map = Class:extend('Map')

-- # Local Function
local function orderZ(a, b)
    return a.depth > b.depth
end

local function excludeCollision(object, noCollision)
    for i=1, #noCollision do
        if (object:getClass() == noCollision[i]) then return false end
    end
    
    return true
end

-- # Class Map
function Map:new(data)
    self.world = {}
    self.exitEvent = false
    
    local mapcreator = require('lib.MapCreator2')

    mapcreator.new(self, data)

    self.len_collidTiles = #self.collidableTiles

    self:addWorld(decor)

    -- local data = data
    -- for k, v in pairs(data) do
    --     if (type(v) == 'table') then
    --         self[k] = {}
    --         for i, vv in ipairs(v) do self[k][i] = vv end
    --     else
    --         self[k] = v
    --     end
    -- end

    -- -- # Size of the map in pixel
    -- self.mapWidthPixel, self.mapHeightPixel = self.mapWidth * self.tileWidth, self.mapHeight * self.tileHeight

    -- -- # Collision
    -- if (self.theme == 'overworld') then
    --     self.collidableTiles = {-1, 1, 34, 265, 266, 298, 299, 267, 268, 269, 300}
    -- elseif (self.theme == 'underworld') then
    --     self.collidableTiles = {-1, 67, 100, 331, 332, 333, 334, 335, 364, 365, 366, 367, 368}
    -- else
    --     self.collidableTiles = {}
    -- end

    -- self.len_collidTiles = #self.collidableTiles

    -- self.world = {}
    -- self.exitEvent = false

    -- -- # Background
    -- local decor = {
    --     batch = love.graphics.newSpriteBatch(TILES_ATLAS, self.mapWidth * self.mapHeight),
    --     render = function(this) love.graphics.draw(this.batch) end,
    --     update = function() end,
    --     depth = 1,
    --     objectType = 'Decor',
    --     destroy = function(this) this.batch:clear() end
    -- }
    -- setmetatable(decor, {__tostring = function() return 'Batch' end})

    -- --self:refreshSpriteBatch(decor.batch)
    
    -- local mapcreator = require('lib.MapCreator')

    -- mapcreator.new(self, decor.batch)
 
    -- self:addWorld(decor)
end

-- ## Sprite Batch 
-- function Map:refreshSpriteBatch(batch)
--     batch:clear()

--     for y=1, self.mapHeight do
--         for x=1, self.mapWidth do
--             local tile = self:getTile(x, y)

--             if (tile ~= 0 and tile ~= TILE.COLLISION) then
--                 --print(tile)
--                 batch:add(TILES_QUADS[tile], (x - 1) * self.tileWidth, (y - 1) * self.tileHeight)
--             end
--         end
--     end

--     batch:flush()
-- end

-- # Load Map
function Map:enter(x, y, state)
    -- # Set camera type
    scene:getCamera():setType(self.camera or 'classic') 

    -- # Configure the player
    local player = scene:getPlayer()
    self:addWorld(player)    

    -- # Set time to player
    if (self.time and not x) then player.time = self.time end

    -- # Spawn player
    player:move(self, x, y, state or self.playerstate)

    -- # Music Theme
    if (MUSICS[self.theme:upper() .. '_SND']) then MUSICS[self.theme:upper() .. '_SND']:play() end

    -- print('\n##### MAP : WORLD ' .. self.worldlevel .. '- STAGE ' .. self.stage, '\n\nList of objects (#'..#self.world..'): ')
    -- for i, v in ipairs(self.world) do
    --     print('\t#'..i..' - ' .. tostring(v))
    -- end
    -- print('###############\n')
end

-- FIXME 
function Map:exit(arg)
    -- print('\n##### Map Exit : WORLD ' .. self.worldlevel .. '- STAGE ' .. self.stage)
    self.exitEvent = false

    local player = scene:getPlayer()
    self:destroyWorld(player) 

    love.audio.stop()
    
    scene:getHud():resetScore()

    if (arg.lifescreen) then
        player.state = 'wait'
        player.time = nil

        -- print('\tObjects destroying (#'..#self.world..') : ')
        for i=#self.world, 1, -1  do 
            table.remove(self.world, i)
        end

        -- print(#self.world.. ' objects remaining')
    end
    -- print('###############\n')

    scene:nextMap(arg.name, arg.lifescreen, arg.x, arg.y, arg.state, arg.custom)
end

function Map:refreshBatch()
    local decor = self:getObject('Batch')

    decor.batch:clear() 
    
    for xi=1, self.mapWidth do
        for yi=1, self.mapHeight do
            local tile = self:getTile(xi, yi)

            if (tile ~= 0 and tile ~= -1) then
                decor.batch:add(TILES_QUADS[tile], (xi - 1) * self.tileWidth, (yi - 1) * self.tileHeight)
            end
        end
    end

    decor.batch:flush() 
end

function Map:destroy()
    -- print('\n##### DESTROY : WORLD ' .. self.worldlevel .. '- STAGE ' .. self.stage)
    -- print('\tObjects destroying (#'..#self.world..') : ')
    for i=#self.world, 1, -1  do 
        if (tostring(self.world[i]) == 'Batch') then self.world[i]:destroy() end
        table.remove(self.world, i)
    end
    
    -- print('###############\n')
end

-- ## World Management
function Map:addWorld(object)
    table.insert(self.world, object)

    if (#self.world > 1) then
        table.sort(self.world, orderZ)
    end
end

function Map:destroyWorld(object)
    for i=#self.world, 1, -1  do
        if (self.world[i] == object) then
            table.remove(self.world, i)
        end
    end
end

function Map:getObject(name)
    for i=1, #self.world  do
        if (tostring(self.world[i]) == name) then
            return self.world[i]
        end
    end
end

function Map:getWorldLevel()
    return tonumber(self.worldlevel)
end

function Map:updateDepth(object, depth)
    for i=#self.world, 1, -1 do
        if (self.world[i] == object) then
            self.world[i].depth = depth
        end
    end

    if (#self.world > 1) then
        table.sort(self.world, orderZ)
    end
end

-- ## Conversion
function Map:tileToPixel(x, y)
    return (x - 1) * self.tileWidth, (y - 1) * self.tileHeight
end

function Map:pixelToTile(px, py)
    return math.floor(px/self.tileWidth) + 1, math.floor(py/self.tileHeight) + 1
end

-- ## Tiles Management
function Map:getTile(x, y, data)
    if (x < 0 or x > self.mapWidth or y > self.mapHeight) then return false end 

    if (data) then return data[(y - 1) * self.mapWidth + x]
    else return self.data[(y - 1) * self.mapWidth + x] end
end

function Map:setTile(tile, x, y)
    self.data[(y - 1) * self.mapWidth + x] = tile
end

function Map:getInteractiveTile(x, y)
    for i=1, #self.world do
        local tile = self.world[i]
        
        if (tile.objectType == 'Decor' and tile.depth ~= 1) then
            if (tile.x/self.tileWidth + 1 == x and tile.y/self.tileHeight + 1 == y) then
                return tile
            end
        end
    end
end

-- ## Collision detection 
function Map:collide(px, py)
    local x, y = self:pixelToTile(px, py)

    -- Decor collision
    local collided = self:getTile(x, y)

    for i=1, self.len_collidTiles do
        if (self.collidableTiles[i] == collided) then
            if (collided == TILE.COLLISION) then return x, y, self:getInteractiveTile(x, y)
            else return x, y end
        end
    end
        
    return false
end

-- FIXME FIX ME DETECTION
function Map:collideObject(object)
    local colls = {}

    for i=1, #self.world do
        local other = self.world[i]

        if (object ~= other and other.objectType ~= 'Decor' and excludeCollision(other, object.noCollision) and math.abs(object.x - other.x) < 32) then
            local topColl
            if (object.dy == 0) then topColl = object.y + 1 >= other.y - other.yOffset 
            else topColl = object.y > other.y - other.yOffset end

            if (object.x - object.xOffset < other.x + other.xOffset and object.x + object.xOffset > other.x - other.xOffset and
            topColl and object.y - object.yOffset < other.y) then
                local rayX, rayY, side = other.x - object.x, other.y - object.y, 'unknow'

                --print('x :' .. math.abs(rayX), 'y :' .. math.abs(rayY))
                if (math.abs(rayX) > math.abs(rayY) and not (other.dy > 125)) then
                    if (rayX < 0) then side = 'left'
                    elseif (rayX > 0) then side = 'right' end
                else
                    if (rayY < 0) then side = 'top'
                    elseif (rayY > 0) then side = 'bottom' end
                end

                --print(object, 'collides with', other, 'on', side)
                table.insert(colls, {other, side})    
            end
        end
    end

    return colls 
end

function Map:setExitEvent(arg)
    self.exitEvent = arg
end

-- ## Update / render
function Map:update(dt)
    -- print('Depart de boucle', #self.world)
    for i=#self.world, 1, -1 do
        -- print('\t', i, self.world[i], #self.world, self.name)
        self.world[i]:update(dt)
    end
    -- print('Fin de boucle')

    if (self.exitEvent) then self:exit(self.exitEvent) end
end

function Map:render()
    -- Draw Background
    love.graphics.clear(self.sky)

    for i=#self.world, 1, -1 do
        self.world[i]:render()
    end
end

return Map

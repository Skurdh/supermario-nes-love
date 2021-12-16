local Stage = Class:extend('Stage')

-- Loads Interactive Tiles
local Brick = require('lib.Objects.Brick')
local Box = require('lib.Objects.Box')
local Coin = require('lib.Objects.Coin')
local PipeEnter = require('lib.Objects.PipeEnter')
local Flag = require('lib.Objects.Flag')
local Door = require('lib.Objects.Door')
local InvisibleBox = require('lib.Objects.InvisibleBox')

local GROUND_HEIGHT = 12

function Stage:new(mapWidth, mapHeight, tileWidth, tileHeight)
    self.mapWidth, self.mapHeight = mapWidth, mapHeight
    self.tiles = {}
    self.objects = {}

    self.tileWidth, self.tileHeight = tileWidth, tileHeight
    
    local index = 1

    -- Create empty cell
    for y=1, self.mapHeight do
        for x=1, self.mapWidth do
            self.tiles[index] = 0
            index = index + 1
        end
    end  
end

function Stage:getStage()
    return self.tileWidth, self.tileHeight, self.mapWidth, self.mapHeight, self.tiles, self.objects
end


function Stage:setTile(tile, x, y)
    self.tiles[(y - 1) * self.mapWidth + x] = tile
end


function Stage:newGround(x1, x2, y1, y2)
    for x = x1, x2 do
        for y = y1, y2 do
            self:setTile(TILE.GROUND_1, x, y)
        end
    end
end

function Stage:newMountain(x1, h)
    local h, w = h, h + h - 1
    local floor, col = 1, 1

    for y = GROUND_HEIGHT, GROUND_HEIGHT - h + 1, -1 do
        for x = x1, x1 + w - 1 do
            if (floor ~= h) then
                -- Create left slope
                if (col == floor) then self:setTile(TILE.MOUNTAIN_L_SLOPE_1, x, y)
                -- Create left motif
                elseif (col == floor +1) then self:setTile(TILE.MOUNTAIN_L_1, x, y)
                -- Create right slope
                elseif (col == w - floor + 1) then self:setTile(TILE.MOUNTAIN_R_SLOPE_1, x, y)
                -- Create rigth motif
                elseif (col == w - floor and floor < h - 1) then self:setTile(TILE.MOUNTAIN_R_1, x, y)
                -- Create center motif
                elseif (col > floor + 1 and col < w - floor) then self:setTile(TILE.MOUNTAIN_CENTER_1, x, y) end

            else
                -- Create top
                if (col == floor) then self:setTile(TILE.MOUNTAIN_TOP_1, x, y) end
            end
           
            col = col + 1
        end
        col = 1
        floor = floor + 1
    end
end

function Stage:newBush(x1, w)
    local w = w + 2
    local y = GROUND_HEIGHT

    for x = x1, x1 + w - 1 do
        -- Create left side
        if (x == x1) then self:setTile(TILE.BUSH_L_1, x, y)
        -- Create right side
        elseif (x == x1 + w - 1) then self:setTile(TILE.BUSH_R_1, x, y)
        -- Create midle
        else self:setTile(TILE.BUSH_CENTER_1, x, y) end
    end
end

function Stage:newCloud(x1, y1, w)
    local w = w + 2

    for y = y1, y1 + 1 do
        for x = x1, x1 + w - 1 do
            -- Create the top of the cloud
            if (y == y1) then
                -- Create left side
                if (x == x1) then self:setTile(TILE.CLOUD_TOP_L_1, x, y)
                -- Create right side
                elseif (x == x1 + w - 1) then self:setTile(TILE.CLOUD_TOP_R_1, x, y)
                -- Create midle
                else self:setTile(TILE.CLOUD_TOP_CENTER_1, x, y) end

            -- Create the bottom of the cloud
            else
                -- Create left side
                if (x == x1) then self:setTile(TILE.CLOUD_BOTTOM_L_1, x, y)
                -- Create right side
                elseif (x == x1 + w - 1) then self:setTile(TILE.CLOUD_BOTTOM_R_1, x, y)
                -- Create midle
                else self:setTile(TILE.CLOUD_BOTTOM_CENTER_1, x, y) end
            end
        end
    end
end

function Stage:newPipe(x1, h, dir)
    if (dir == 'v' or dir == nil) then
        for y = GROUND_HEIGHT, GROUND_HEIGHT - h + 1, -1 do
            for x = x1, x1 + 1 do
                -- Create top pipe
                if (y == GROUND_HEIGHT - h + 1) then
                    -- Create left side
                    if (x == x1) then self:setTile(TILE.PIPE_V_TOP_L_1, x, y)
                    -- Create right side
                    else self:setTile(TILE.PIPE_V_TOP_R_1, x, y) end
                -- Create bottom pipe
                else
                    -- Create left side
                    if (x == x1) then self:setTile(TILE.PIPE_V_BOTTOM_L_1, x, y)
                    -- Create right side
                    else self:setTile(TILE.PIPE_V_BOTTOM_R_1, x, y) end
                end
            end
        end
    elseif (dir == 'h') then
        local part, tile = ''

        for x = x1, x1 - 2 - h, -1 do
            for y = GROUND_HEIGHT, GROUND_HEIGHT - 1, -1 do
                -- Create top of the pipe
                if (y == GROUND_HEIGHT) then part = 'BOTTOM'
                -- Create bottom of the pipe
                else part = 'TOP' end

                if (x == x1) then self:setTile(TILE['PIPE_H_'..part..'_R_1'], x, y)
                elseif (x == x1 - 2 - h) then self:setTile(TILE['PIPE_H_'..part..'_L_1'], x, y)
                else self:setTile(TILE['PIPE_H_'..part..'_M_1'], x, y) end
            end
        end
    end
end

function Stage:newBlock(mode, x1, y1, x2, y2)
    if (mode == 'stairs') then
        local x1, y1, w, h, invert = x1, GROUND_HEIGHT, y1, y1, x2 or false
        local floor, col = 1, 1

        for y = y1, y1 - h + 1, -1 do
            for x = x1, x1 + w - 1 do
                if (not invert and col >= floor) then self:setTile(TILE.BLOCK_1, x, y)
                elseif (invert and col <= w - floor + 1) then self:setTile(TILE.BLOCK_1, x, y) end

                col = col + 1
            end
            col = 1
            floor = floor + 1
        end

    elseif (mode == 'line') then
        local x1, h = x1, y1

        for y = GROUND_HEIGHT, GROUND_HEIGHT - h + 1, -1 do
            self:setTile(TILE.BLOCK_1, x1, y)
        end
    end
end

function Stage:newCastle(x1)
    local slit_floor = {TILE.CASTLE_SLIT_L_1, TILE.CASTLE_WALL_1, TILE.CASTLE_SLIT_R_1}
    local w = 4

    for y = GROUND_HEIGHT, 8, -1 do
        for x = x1, x1 + w do
            -- first line
            if (y == GROUND_HEIGHT) then
                if (x == x1 + 2) then self:setTile(TILE.CASTLE_DOOR_BOTTOM_1, x, y)
                else self:setTile(TILE.CASTLE_WALL_1, x, y) end
            
            -- second line
            elseif (y == GROUND_HEIGHT - 1) then
                if (x == x1 + 2) then self:setTile(TILE.CASTLE_DOOR_TOP_1, x, y)
                else self:setTile(TILE.CASTLE_WALL_1, x, y) end
            
            -- third line
            elseif (y == GROUND_HEIGHT - 2) then
                if (x > x1 and x < x1 + w) then self:setTile(TILE.CASTLE_REMPART_BOTTOM_1, x, y)
                else self:setTile(TILE.CASTLE_REMPART_TOP_1, x, y) end

            -- fourth line
            elseif (y == GROUND_HEIGHT - 3 and x > x1 and x < x1 + w) then
                self:setTile(slit_floor[x - x1], x, y)

            -- Fifth line
            elseif (y == GROUND_HEIGHT - 4 and x > x1 and x < x1 + w) then self:setTile(TILE.CASTLE_REMPART_TOP_1, x, y) end
        end
    end

    table.insert(self.objects, Door((x1 + 2)* self.tileWidth, (GROUND_HEIGHT - 1) * self.tileHeight))
end

function Stage:newFlag(x)
    self:setTile(TILE.BLOCK_1, x, GROUND_HEIGHT)

    for y=GROUND_HEIGHT-1, GROUND_HEIGHT-9, -1 do
        self:setTile(TILE.FLAG_M_1, x, y)
    end

    for y=GROUND_HEIGHT-10, GROUND_HEIGHT-11, -1 do
        self:setTile(TILE.COLLISION, x+1, y)
    end

    self:setTile(TILE.FLAG_TOP_1, x, GROUND_HEIGHT - 10)

    table.insert(self.objects, Flag((x-1) * self.tileWidth, (GROUND_HEIGHT-11) * self.tileHeight))
end

function Stage:newBrick(x, y)
    self:setTile(TILE.COLLISION, x, y)

    table.insert(self.objects, Brick((x-1) * self.tileWidth, (y-1) * self.tileHeight))
end

function Stage:newBox(x, y, tile, content, count)
    self:setTile(TILE.COLLISION, x, y)

    table.insert(self.objects, Box((x-1) * self.tileWidth, (y-1) * self.tileHeight, tile, content, count))
end

function Stage:newInvisibleBox(x, y)
    table.insert(self.objects, InvisibleBox((x-1) * self.tileWidth, (y-1) * self.tileHeight))
end

function Stage:newCoin(x, y)
    local coin = Coin((x-1) * self.tileWidth, (y-1) * self.tileHeight)

    table.insert(self.objects, coin)
end

function Stage:newPipeEnter(x, h, dir, map)
    local nx, ny, dir = 0, 0, dir or 'v'

    if (dir == 'v') then nx, ny = x, GROUND_HEIGHT - h
    elseif (dir == 'h') then nx, ny = x - 3 - h, GROUND_HEIGHT - 1 end

    self:newPipe(x, h, dir)
    table.insert(self.objects, PipeEnter((nx-1) * self.tileWidth , (ny-1) * self.tileHeight, dir))
end

function Stage:addEnnemies(t)
    for i=1, #t do
        table.insert(self.objects, t[i])
    end
end

return Stage
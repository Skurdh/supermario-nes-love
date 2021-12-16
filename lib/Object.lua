local Object = Class:extend('Object')

local Animation = require('lib.Animation')

function Object:new(x, y, w, h, xOffset, yOffset, xMargin, yMargin, collisionType, noCollision, depth, rooted)
    -- # Positions & Dimensions
    self.w, self.h = w, h
    self.xOffset, self.yOffset = xOffset or w/2, yOffset or h - 1
    self.xMargin, self.yMargin = xMargin or 0, yMargin or 0
    self.x, self.y = x + self.xOffset + self.xMargin, y + self.yOffset + self.yMargin
    self.noCollision = noCollision
    self.collisionType = collisionType or 'trigger'

    -- # Movements
    self.dx, self.dy = 0, 0

    -- # Draw
    self.depth = depth or 4
    self.animation = Animation()
    self.currentFrame = 0

end

-- # Object Management
-- function Object:add()
--     print('Ajout de ' .. tostring(self))
--     self.map = scene:getMap()
--     self.map:addWorld(self)
-- end

function Object:destroy()
    self.animation = nil
    scene:getMap():destroyWorld(self)
end

--- # ANCHOR Collision Management
function Object:collisionX()
    -- # Corners detection /!\ Depend on the object size
    local xCoord, yCoord

    if (self.h > 16) then xCoord, yCoord = {self.x - self.xOffset, self.x + self.xOffset - 1}, {self.y - self.yOffset, self.y - self.yOffset/2, self.y}
    else xCoord, yCoord = {self.x - self.xOffset, self.x + self.xOffset - 1}, {self.y - self.yOffset, self.y} end

    for side, xPos in ipairs(xCoord) do
        for _, yPos in ipairs(yCoord) do
            local xColl, y, px, py, coll = scene:getMap():collide(xPos, yPos)

            if (xColl) then
                    if (self.dx > 0) then
                        self.x = (xColl-1) * scene:getMap().tileWidth - self.xOffset
                    elseif (self.dx < 0) then
                        self.x = xColl * scene:getMap().tileWidth + self.xOffset
                    end

                    self.dx = 0

                return COLLISIONSIDEX[side]
            end

        end
    end
    
    return false
end

function Object:collisionY()
    -- # Corners detection /!\ Depend on the object size
    local xCoord, yCoord

    if (self.dy == 0) then 
        xCoord, yCoord = {self.x - self.xOffset, self.x + self.xOffset - 1}, {self.y - self.yOffset, self.y + 1}
    else
        xCoord, yCoord = {self.x - self.xOffset, self.x + self.xOffset - 1}, {self.y - self.yOffset, self.y} 
    end

    for side, yPos in ipairs(yCoord) do
        for _, xPos in ipairs(xCoord) do
            local _, yColl = scene:getMap():collide(xPos, yPos)

            if (yColl) then
                if (self.dy > 0) then
                    self.y = (yColl - 1) * scene:getMap().tileHeight - 1
                elseif (self.dy < 0) then
                    self.y = yColl * scene:getMap().tileHeight + self.yOffset
                end

                self.dy = 0

                return COLLISIONSIDEY[side]
            end
        end
    end

    return false
end

function Object:collisionCam()
    local camX = scene:getCamera().x 
    if (self.x - self.xOffset < camX) then
        self:destroy()
    elseif (self.x + self.xOffset > camX + virtualWidth) then
        self:destroy()
    end
end

function Object:collisionObject()
    -- TODO
    -- local colls = scene:getMap():collideObject(self)

    -- for i=1, #colls do
    --     local object, side = colls[i][1], colls[i][2]
    --     if (object.rooted) then object:collect(side) end
    -- end
end

-- ANCHOR Update / Draw
function Object:update(dt)
    local state = scene:getPlayer().state
    if (state == 'powerup' or state == 'fireup' or state == 'powerdown') then return end

    -- # Animation update
    self.animation:update(dt)
    self.currentFrame = self.animation:getFrame()
end

function Object:render()
    if (self.debug) then
        if (self.collisionType == 'trigger') then love.graphics.setColor(1,0,1, 0.5)
        else love.graphics.setColor(0,0,0, 0.5)
        end
        
        love.graphics.rectangle('fill', math.floor(self.x - self.xOffset), math.floor(self.y - self.yOffset), self.w, self.h)
    end    

    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(OBJECTS_ATLAS, OBJECTS_QUADS[self.currentFrame], math.floor(self.x), math.floor(self.y), 0, 1, 1, self.xOffset + self.xMargin, self.yOffset + self.yMargin) 

    if (self.debug) then
        love.graphics.setColor(1, 0, 0, 1)
        love.graphics.rectangle('fill', math.floor(self.x), math.floor(self.y), 1, 1)
    
        love.graphics.setColor(0,1,0,0.9)
        love.graphics.rectangle('fill', math.floor(self.x - self.xOffset), math.floor(self.y - self.yOffset), 1, 1)
        love.graphics.rectangle('fill', math.floor(self.x + self.xOffset - 1), math.floor(self.y - self.yOffset), 1, 1)
        love.graphics.rectangle('fill', math.floor(self.x - self.xOffset), math.floor(self.y), 1, 1)
        love.graphics.rectangle('fill', math.floor(self.x + self.xOffset - 1), math.floor(self.y), 1, 1)
        love.graphics.setColor(1,1,1,1)

     end 
end

return Object
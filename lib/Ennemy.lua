local Ennemy = Class:extend('Ennemy')

local Animation = require('lib.Animation')

function Ennemy:new(x, y, w, h, xOffset, yOffset, xMargin, yMargin, noCollision, radius, linked, speed)
    -- # Positions & Dimensions
    self.w, self.h = w, h
    self.xOffset, self.yOffset = xOffset or w/2, yOffset or h - 1
    self.xMargin, self.yMargin = xMargin or 0, yMargin or 0
    self.x, self.y = x + self.xOffset + self.xMargin, y + self.yOffset + self.yMargin
    self.noCollision = noCollision
    self.collisionType = 'trigger'

    -- # Movements
    self.dx, self.dy = 0, 0
    self.speed = speed or -35

    -- # Draw
    self.depth = 4
    self.animation = Animation()
    self.sx, self.sy = 1, 1

    -- # Stats
    self.radius = radius 
    self.state = 'sleep'
    self.linked = linked or false
    self.deadTimer = 0
    self.objectType = 'Ennemy'
    self.score = {
        crush = 100,
        fire = 100,
        star = 100,
        under = 100
    }
end

function Ennemy:hit(target, type)
end

function Ennemy:destroy()
    scene:getMap():destroyWorld(self)
end

--- # ANCHOR Collision Management
function Ennemy:collisionX()
    -- # Corners detection /!\ Depend on the object size
    local xCoord, yCoord

    if (self.h > 16) then xCoord, yCoord = {self.x - self.xOffset, self.x + self.xOffset - 1}, {self.y - self.yOffset, self.y - self.yOffset/2, self.y}
    else xCoord, yCoord = {self.x - self.xOffset, self.x + self.xOffset - 1}, {self.y - self.yOffset, self.y} end

    for side, xPos in ipairs(xCoord) do
        for _, yPos in ipairs(yCoord) do
            local xColl = scene:getMap():collide(xPos, yPos)

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

function Ennemy:collisionY()
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

-- FIXME 
function Ennemy:collisionCam()
    local camX = scene:getCamera().x
    if (self.x + self.xOffset < camX or
        self.y - self.yOffset > virtualHeight) then
        self:destroy()
    end
end

function Ennemy:collideObject()
    local colls = scene:getMap():collideObject(self)

    for i=1, #colls do
        local object, side = colls[i][1], colls[i][2]

        -- # Response with Player collision
        if (object:getClass() == 'Player' and object.state ~= 'death' and self.collisionType ~= 'none') then
            -- # Top
            if (object.invincibility == 2) then 
                self:hit(object, 'bounce', object.dx)
                scene:getPlayer():addScore(self.score.star, self, '')
            elseif (side == 'top' and object.dy > 10) then
                self:hit(object, 'top')
                scene:getPlayer():addScore(self.score.crush, self, 'crush')
                scene:getPlayer():addCombo('crush')
            -- # Left/Right/Bottom
            else
                if (object.invincibility == 1) then self:hit(object, 'invinc1')
                else 
                    if (object.y < self.y - self.yOffset/2 - 2) then 
                        self:hit(object, 'top') 
                        scene:getPlayer():addScore(self.score.crush, self, '')
                    else self:hit(object, 'attack') end
                end
            end

        -- # Response with others objects collision
        elseif (object.collisionType ~= 'none') then
            if (side == 'left') then self:hit(object, 'left')
            elseif (side == 'right') then self:hit(object, 'right') end 
        end
    end
end

-- ANCHOR Update / Draw
function Ennemy:update(dt)
    local state = scene:getPlayer().state
    if (state == 'powerup' or state == 'fireup' or state == 'powerdown' or state == 'death') then return end

    self.animation:update(dt)
    self.currentFrame = self.animation:getFrame()
end

function Ennemy:render()
    if (self.debug) then
        love.graphics.setColor(0,0,0, 0.5)
        love.graphics.rectangle('fill', math.floor(self.x - self.xOffset), math.floor(self.y - self.yOffset), self.w, self.h)
    end    

    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(ENNEMIES_ATLAS, ENNEMIES_QUADS[self.currentFrame], math.floor(self.x), math.floor(self.y), 0, self.sx, self.sy, self.xOffset + self.xMargin, self.yOffset + self.yMargin) 

    if (self.debug) then
        love.graphics.setColor(1, 0, 0, 1)
        love.graphics.rectangle('fill', math.floor(self.x), math.floor(self.y), 1, 1)
    
        love.graphics.setColor(0,1,0,0.9)
        love.graphics.rectangle('fill', math.floor(self.x - self.xOffset), math.floor(self.y - self.yOffset), 1, 1)
        love.graphics.rectangle('fill', math.floor(self.x + self.xOffset - 1), math.floor(self.y - self.yOffset), 1, 1)
        love.graphics.rectangle('fill', math.floor(self.x - self.xOffset), math.floor(self.y), 1, 1)
        love.graphics.rectangle('fill', math.floor(self.x + self.xOffset - 1), math.floor(self.y), 1, 1)
        love.graphics.setColor(1,1,1,1)

        if (self.linked) then
            
            if (self.linked.state == 'sleep') then love.graphics.setColor(1, 0, 0, 1)
            else love.graphics.setColor(0,1,0,1) end
            love.graphics.line(self.linked.x, self.linked.y - self.linked.yOffset/2, self.x, self.y - self.yOffset/2)
            love.graphics.setColor(1,1,1,1)
        end
     end 
end

return Ennemy
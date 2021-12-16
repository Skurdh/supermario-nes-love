local Object = require('lib.Object')
local Star = Object:extend('Star')

-- # Constants
local SPEED = 50

function Star:new(x, y)
    self.super.new(self, x, y - 2, 16, 16, nil, nil, 1, 0, 'none', {'BoxCoin', 'Koopa', 'Goomba'}, 2, false)
    
    self.animation:add('idle', 6, {109, 110, 111, 112})
    self.animation:animate('idle')

    self.currentFrame = self.animation:getFrame()

    self.dx = SPEED
    self.defaultY = y
    self.score = 1000

    self.state = 'spawn'

    self.behaviours = {
        spawn = function(dt)
            if (self.y > self.defaultY) then
                self.y = self.y - 26 * dt
            else
                scene:getMap():updateDepth(self, 4)
                self.state = 'move'
                self.collisionType = 'trigger'
                if (love.math.random(2) == 2) then self.dy = -135 end
            end
        end,
        move = function(dt)
            self.animation:update(dt)
            self.currentFrame = self.animation:getFrame()

            self:collisionCam()

            self.x = self.x + self.dx * dt
            local collSideX = self:collisionX()

            if (collSideX) then 
                if (collSideX == 'left') then self.dx = -SPEED
                elseif (collSideX == 'right') then self.dx = SPEED end
            end

            self.dy = self.dy + 200 * dt
            self.y = self.y + self.dy * dt
            local collSideY = self:collisionY()
            if (collSideY and collSideY == 'top') then self.dy = -135 end

            self:collideObject() 
        end
    }

    SFX.POWERUP_APPEARS_SND:stop()
    SFX.POWERUP_APPEARS_SND:play()
end

function Star:collect(player) 
    local player = scene:getPlayer()   
    player:invicible(2)
    player:addScore(self.score)
    scene:getHud():addScore(self.score, self.x, self.y - self.yOffset) 
    
    self:destroy()
end

--- # ANCHOR Collision Management
function Star:collisionX()
    -- # Corners detection /!\ Depend on the object size
    local xCoord, yCoord

    if (self.h > 16) then xCoord, yCoord = {self.x - self.xOffset, self.x + self.xOffset - 1}, {self.y - self.yOffset, self.y - self.yOffset/2, self.y}
    else xCoord, yCoord = {self.x - self.xOffset, self.x + self.xOffset - 1}, {self.y - self.yOffset, self.y} end

    for side, xPos in ipairs(xCoord) do
        for _, yPos in ipairs(yCoord) do
            xColl, _, tile = scene:getMap():collide(xPos, yPos)

            if (xColl and tile == nil) then
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

function Star:collisionY()
    -- # Corners detection /!\ Depend on the object size
    local xCoord, yCoord

    if (self.dy == 0) then 
        xCoord, yCoord = {self.x - self.xOffset, self.x + self.xOffset - 1}, {self.y - self.yOffset, self.y + 1}
    else
        xCoord, yCoord = {self.x - self.xOffset, self.x + self.xOffset - 1}, {self.y - self.yOffset, self.y} 
    end

    for side, yPos in ipairs(yCoord) do
        for _, xPos in ipairs(xCoord) do
            _, yColl, tile = scene:getMap():collide(xPos, yPos)

            if (yColl and tile == nil) then
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

function Star:collisionCam()
    local camX = scene:getCamera().x
    if (self.x + self.xOffset < camX or
        self.x - self.xOffset > scene:getMap().mapWidthPixel or
        self.y - self.yOffset > virtualHeight) then
        self:destroy()
    end
end

function Star:collideObject()
    local colls = scene:getMap():collideObject(self)

    for i=1, #colls do
        local object, side = colls[i][1], colls[i][2]

        if (object:getClass() == 'Player') then self:collect(object) end
    end
end

function Star:update(dt)
    local state = scene:getPlayer().state
    if (state == 'death' or state == 'powerup' or state == 'fireup' or state == 'powerdown') then return end
    
    self.behaviours[self.state](dt)
end

return Star
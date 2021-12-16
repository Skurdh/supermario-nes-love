local Ennemy = require('lib.Ennemy')
local FlyRedKoopa = Ennemy:extend('Flying Red Koopa')

local RedKoopa = require('lib.Ennemies.RedKoopa')

-- # Constants
local MAX_SPEED, SHELL_SPEED, BRAKE_DISTANCE = 35, 195, 16

local HEAD = {7, 8}

local koopaAttribute = {
    {w = 10, h = 16, xOffset = 5, yOffset = 15, xMargin = 3, yMargin = -1},
    {w= 12, h = 21, xOffset = 6, yOffset = 20, xMargin = 2, yMargin = -6}
}

-- # Sounds
function FlyRedKoopa:new(x, y, type, target, dir)
    self.super.new(self, x, y, 12, 21, nil, 20, 2, -6, {'Mushroom', 'FirePlant', 'Star', 'OneUP', 'Coin', 'Koopa', 'Red Koopa', 'Goomba'}, 155, linked, SPEED)

    self.type = type
    self.speed = 0
    self.dir = dir or 1

    if (type == 'h') then
        if (dir < 0) then self.xOrigin, self.xTarget = target, self.x
        else self.xOrigin, self.xTarget = self.x, target end
        
    else
        if (dir < 0) then self.yOrigin, self.yTarget = target, self.y
        else self.yOrigin, self.yTarget = self.y, target end  
    end

    self.animation:add('attack', 6, {259, 260})
    self.animation:add('inshell', 1, {261})

    self.animation:animate('attack')
    self.currentFrame = self.animation:getFrame()
    self.animation:pause(true)

    self.behaviours = {
        sleep = function(dt)
            if (scene:getPlayer().x > self.x - self.radius or (self.linked and self.linked.state ~= 'sleep')) then
                self.state = 'attack'
                self.animation:pause(false)
                self.dx = self.speed
            else
                return
            end
        end,

        attack = function(dt)
            self:collisionCam()

            self.animation:animate('attack')
    
            if (self.type == 'h') then 
                if (self.dir == 1 and self.x > self.xTarget - self.xOffset - BRAKE_DISTANCE or self.dir == -1 and self.x < self.xOrigin + BRAKE_DISTANCE) then
                    self.speed = self.speed - MAX_SPEED/135 * math.ceil(MAX_SPEED - self.speed + 1) * 0.33
                    self.speed = math.max(0, self.speed)
        
                    if (self.speed == 0) then self.dir = self.dir * -1 end
                else
                    self.speed = self.speed + MAX_SPEED/135 * math.ceil(self.speed + 1) * 0.47
                    self.speed = math.min(MAX_SPEED, self.speed)
                end
        
                self.x = self.x + self.speed * dt * self.dir
            else
                if (self.dir == 1 and self.y > self.yTarget - BRAKE_DISTANCE or self.dir == -1 and self.y < self.yOrigin + BRAKE_DISTANCE) then
                    self.speed = self.speed - MAX_SPEED/135 * math.ceil(MAX_SPEED - self.speed + 1) * 0.33
                    self.speed = math.max(0, self.speed)
        
                    if (self.speed == 0) then self.dir = self.dir * -1 end
                else
                    self.speed = self.speed + MAX_SPEED/135 * math.ceil(self.speed + 1) * 0.47
                    self.speed = math.min(MAX_SPEED, self.speed)
                end
        
                self.y = self.y + self.speed * dt * self.dir
            end
    
            self:collideObject() 
        end,

        deadbounce = function(dt)
            self.animation:animate('inshell')

            self.x = self.x + self.dx*1.5 * dt

            self.dy = self.dy + GRAVITY/2 * dt
            self.y = self.y + self.dy * dt

            if (self.y > 500) then
                self:destroy()
            end
        end
    }

  --  self.debug = true
end


function FlyRedKoopa:hit(target, hitType, arg)
    if (self.state == 'attack') then
        if (hitType == 'top') then
            self:destroy()

            local redkoopa = RedKoopa(self.x - self.xOffset - self.xMargin, self.y - self.yOffset/2, false)
            redkoopa.dx, redkoopa.dy = self.dx, 0
            redkoopa.state = 'fall'

            scene:getMap():addWorld(redkoopa)            

            if (scene:getPlayer().y > self.y - self.yOffset + 4) then scene:getPlayer().dy = -275
            else scene:getPlayer().dy = -265 end
            
        elseif (hitType == 'bounce') then
            -- # Direction of the bounce
            if (arg and arg > 0) then self.dx = -self.speed
            else self.dx = self.speed end 

            scene:getMap():updateDepth(self, 6)
            self.state = 'deadbounce'
            self.y = self.y - 12
            self.dy = -210
            self.collisionType = 'none'
            self.sy = -1

        elseif (hitType == 'attack') then scene:getPlayer():powerDown()
        end
    end
end
function FlyRedKoopa:collisionX()
    local xCoord, yCoord = {self.x - self.xOffset, self.x + self.xOffset - 1}, {self.y - 14, self.y}

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

function FlyRedKoopa:collisionY()
    local xCoord, yCoord = {self.x - self.xOffset, self.x + self.xOffset - 1}, {self.y - 14, self.y}

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

function FlyRedKoopa:coillisionVoid()
    local xPos, yPos
    if (self.dx < 0) then xPos, yPos = self.x - self.xOffset - 2, self.y + 2
    elseif (self.dx > 0) then xPos, yPos = self.x + self.xOffset + 2, self.y + 2 end
    
    if (scene:getMap():getTile(scene:getMap():pixelToTile(xPos, yPos)) == 0) then
        if (self.dx < 0) then self.dx = -self.speed self.sx = -1
        elseif (self.dx > 0) then self.dx = self.speed self.sx = 1 end
    end  
end

function FlyRedKoopa:update(dt)
    local state = scene:getPlayer().state
    if (state == 'death' or state == 'powerup' or state == 'fireup' or state == 'powerdown') then return end

    if (self.linked and (self.linked.state == 'deadcrush' or self.linked.state == 'deadbounce')) then self.linked = nil end

    self.animation:update(dt)
    self.currentFrame = self.animation:getFrame()

    self.behaviours[self.state](dt)
end

function FlyRedKoopa:render()
    if (self.debug) then
        love.graphics.setColor(0,0,0, 0.5)
        love.graphics.rectangle('fill', math.floor(self.x - self.xOffset), math.floor(self.y - self.yOffset), self.w, self.h)
    end    

    love.graphics.setColor(1,1,1,1)
    if (self.state ~= 'inshell' or self.state ~= 'deadbounce' or self.state ~= 'outshell') then
        love.graphics.draw(ENNEMIES_ATLAS, ENNEMIES_QUADS[self.currentFrame-50], math.floor(self.x), math.floor(self.y-16), 0, self.sx, self.sy, self.xOffset + self.xMargin, self.yOffset + self.yMargin) 
    end

        love.graphics.draw(ENNEMIES_ATLAS, ENNEMIES_QUADS[self.currentFrame], math.floor(self.x), math.floor(self.y), 0, self.sx, self.sy, self.xOffset + self.xMargin, self.yOffset + self.yMargin) 

    if (self.debug) then
        love.graphics.setColor(1, 0, 0, 1)
        love.graphics.rectangle('fill', math.floor(self.x), math.floor(self.y), 1, 1)
    
        love.graphics.setColor(0,1,0,0.9)
        love.graphics.rectangle('fill', math.floor(self.x - self.xOffset), math.floor(self.y - self.yOffset), 1, 1)
        love.graphics.rectangle('fill', math.floor(self.x + self.xOffset - 1), math.floor(self.y - self.yOffset), 1, 1)
        love.graphics.rectangle('fill', math.floor(self.x - self.xOffset), math.floor(self.y), 1, 1)
        love.graphics.rectangle('fill', math.floor(self.x + self.xOffset - 1), math.floor(self.y), 1, 1)
        love.graphics.rectangle('fill', self.x - self.xOffset - 1, self.y, 1, 1)
        love.graphics.setColor(1,1,1,1)

        love.graphics.print(self.dir, self.x - 15, self.y-self.yOffset - 10)

        love.graphics.setColor(1, 0, 0, 1)
        love.graphics.line(self.x - self.xOffset, self.yOrigin, self.x + self.xOffset, self.yOrigin )
        love.graphics.line(self.x - self.xOffset, self.yTarget, self.x + self.xOffset, self.yTarget )

        if (self.linked) then
            if (self.linked.state == 'sleep') then love.graphics.setColor(1, 0, 0, 1)
            else love.graphics.setColor(0,1,0,1) end
            love.graphics.line(self.linked.x, self.linked.y - self.linked.yOffset/2, self.x, self.y - self.yOffset/2)
            love.graphics.setColor(1,1,1,1)
        end
    end 
end

return FlyRedKoopa
local Ennemy = require('lib.Ennemy')
local Koopa = Ennemy:extend('Koopa')

-- # Constants
local SPEED, SHELL_SPEED = -35, 195
local THEME_ID = {
    ['overworld'] = 0,
    ['underworld'] = 100,
    ['castle'] = 300,
    ['underwater'] = 0
}


local HEAD = {7, 8}

local koopaAttribute = {
    {w = 10, h = 16, xOffset = 5, yOffset = 15, xMargin = 3, yMargin = -1},
    {w= 12, h = 21, xOffset = 6, yOffset = 20, xMargin = 2, yMargin = -6}
}

-- # Sounds
function Koopa:new(x, y, theme, linked)
    self.super.new(self, x, y, 12, 21, nil, 20, 2, -6, {'Mushroom', 'FirePlant', 'Star', 'OneUP', 'Coin'}, 155, linked, SPEED)
    
    self.animation:add('attack', 6, {57 + THEME_ID[theme], 58 + THEME_ID[theme]})
    self.animation:add('inshell', 1, {61 + THEME_ID[theme]})
    self.animation:add('outshell', 4, {61 + THEME_ID[theme], 62 + THEME_ID[theme]})

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
    
            self.x = self.x + self.dx * dt
            local collX = self:collisionX()
    
            if (collX) then 
                if (collX == 'left') then self.dx = self.speed self.sx = 1
                elseif (collX == 'right') then self.dx = -self.speed self.sx = -1 end 
            end
        
            self.dy = self.dy + GRAVITY * dt
            self.y = self.y + self.dy * dt
            self:collisionY()
    
            self:collideObject() 
        end,

        inshell = function(dt)
            self.animation:animate('inshell')         

            self.deadTimer = self.deadTimer + dt

            if (self.deadTimer > 8) then
                self.state = 'outshell'
                self.deadTimer = 0
            end

            self.dy = self.dy + GRAVITY * dt
            self.y = self.y + self.dy * dt
            self:collisionY()

            self:collideObject() 
        end, 

        moveshell = function(dt)
            self.animation:animate('inshell')

            self.deadTimer = self.deadTimer + dt

            if (self.deadTimer > 0.1) then self.collisionType = 'trigger' end

            if (self.deadTimer > 8) then
                if (self.dx > 0) then self.dx = math.max(0, self.dx - self.speed * dt)
                elseif (self.dx < 0) then self.dx = math.min(0, self.dx + self.speed * dt)
                else 
                    self.state = 'outshell'
                    self.deadTimer = 0
                end
            end

            self.x = self.x + self.dx * dt
            local collX = self:collisionX()
    
            if (collX) then 
                if (collX == 'left') then self.dx = -self.speed
                elseif (collX == 'right') then self.dx = self.speed end 
            end
        
            self.dy = self.dy + GRAVITY * dt
            self.y = self.y + self.dy * dt
            self:collisionY()
    
            self:collideObject() 
        end,

        outshell = function(dt)
            self.animation:animate('outshell')
            self.deadTimer = self.deadTimer + dt

            if (self.deadTimer > 3) then
                self.state = 'attack'
                self.speed = SPEED
                self.dx = -self.speed
                self.sx = -1
                self.deadTimer = 0
                for k, v in pairs(koopaAttribute[2]) do
                    self[k] = v
                end
            end

            self.dy = self.dy + GRAVITY * dt
            self.y = self.y + self.dy * dt
            self:collisionY()

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

    --self.debug = true
end


function Koopa:hit(target, hitType, arg)
    if (self.state == 'attack') then
        if (hitType == 'top') then
            self.state = 'inshell'
            self.dx, self.speed = 0, SHELL_SPEED

            for k, v in pairs(koopaAttribute[1]) do
                self[k] = v
            end

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

        elseif (hitType == 'attack') then scene:getPlayer():powerDown()
        elseif (hitType == 'left') then self.dx = -self.speed self.sx = -1
        elseif (hitType == 'right') then self.dx = self.speed self.sx = 1
        end

    elseif (self.state == 'inshell' or self.state == 'outshell') then
        if (hitType == 'top') then
            self.state = 'moveshell'
            if (target.x < self.x) then self.dx = self.speed
            else self.dx = -self.speed end
            if (scene:getPlayer().y > self.y - self.yOffset + 4) then scene:getPlayer().dy = -275
            else scene:getPlayer().dy = -265 end

        elseif (hitType == 'bounce') then
            -- # Direction of the bounce
            if (arg and arg > 0) then self.dx = -self.speed
            else self.dx = self.speed end 

            scene:getMap():updateDepth(self, 6)
            self.state = 'deadbounce'
            self.dy = -210

        elseif (hitType == 'attack') then 
            self.state = 'moveshell'
            if (target.x < self.x) then 
                self.dx = self.speed
                self.x = target.x + target.xOffset + self.xOffset + 1
            else 
                self.dx = -self.speed 
                self.x = target.x - target.xOffset - self.xOffset - 1
            end

        end

    elseif (self.state == 'moveshell') then 
        if (hitType == 'top') then
            self.dx = 0
            self.state = 'inshell'
            if (scene:getPlayer().y > self.y - self.yOffset + 4) then scene:getPlayer().dy = -275
            else scene:getPlayer().dy = -265 end
            self.deadTimer = 0

        elseif (hitType == 'bounce') then
            -- # Direction of the bounce
            if (arg and arg > 0) then self.dx = -self.speed
            else self.dx = self.speed end 

            scene:getMap():updateDepth(self, 6)
            self.state = 'deadbounce'
            self.dy = -210

        elseif (hitType == 'attack') then scene:getPlayer():powerDown()
        elseif (hitType == 'left' or hitType == 'right') then target:hit(self, 'bounce', self.dx)
        end
    end
end

function Koopa:collisionX()
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

function Koopa:collisionY()
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

function Koopa:update(dt)
    local state = scene:getPlayer().state
    if (state == 'death' or state == 'powerup' or state == 'fireup' or state == 'powerdown') then return end

    if (self.linked and (self.linked.state == 'deadcrush' or self.linked.state == 'deadbounce')) then self.linked = nil end

    self.animation:update(dt)
    self.currentFrame = self.animation:getFrame()

    self.behaviours[self.state](dt)
end

function Koopa:render()
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
        love.graphics.rectangle('fill', math.floor(self.x - self.xOffset), math.floor(self.y - 14), 1, 1)
        love.graphics.rectangle('fill', math.floor(self.x + self.xOffset - 1), math.floor(self.y - 14), 1, 1)
        love.graphics.rectangle('fill', math.floor(self.x - self.xOffset), math.floor(self.y), 1, 1)
        love.graphics.rectangle('fill', math.floor(self.x + self.xOffset - 1), math.floor(self.y), 1, 1)
        love.graphics.setColor(1,1,1,1)

        love.graphics.print(self.state, self.x - 15, self.y-self.yOffset - 10)

        if (self.linked) then
            
            if (self.linked.state == 'sleep') then love.graphics.setColor(1, 0, 0, 1)
            else love.graphics.setColor(0,1,0,1) end
            love.graphics.line(self.linked.x, self.linked.y - self.linked.yOffset/2, self.x, self.y - self.yOffset/2)
            love.graphics.setColor(1,1,1,1)
        end
    end 
end

return Koopa
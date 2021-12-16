local Ennemy = require('lib.Ennemy')
local Plant = Ennemy:extend('Plant')

-- # Constants
local SPEED = 12
local THEME_ID = {
    ['overworld'] = 0,
    ['underworld'] = 100,
    ['castle'] = 300,
    ['underwater'] = 0
}


-- # Sounds
function Plant:new(x, y, theme, position)
    self.super.new(self, x + 16, y, 12, 22, nil, nil, 2, -6, {'Mushroom', 'FirePlant', 'Star', 'OneUP', 'Coin'}, 125, false, SPEED)

    self.yOrigin = self.y
    self.depth = 0
    
    self.time = 0

    self.animation:add('attack', 3, {63 + THEME_ID[theme], 64 + THEME_ID[theme]})
    self.animation:animate('attack')

    self.currentFrame = self.animation:getFrame()
    self.animation:pause(true)

    self.behaviours = {
        sleep = function(dt)
            if (scene:getPlayer().x > self.x - self.radius or (self.linked and self.linked.state ~= 'sleep')) then
                self.state = 'down'
                self.animation:pause(false)
                self.dx = self.speed
            else
                return
            end
        end,

        down = function(dt)
            self.time = self.time + dt

            if (self.time > 1.5) then
                self.y = self.y + self.speed * dt

                if (self.y > self.yOrigin + 16 and self.collisionType == 'trigger') then self.collisionType = 'none' end
                
                if (self.y > self.yOrigin + 32) then
                    self.state = 'up'
                    self.time = 0
                end
            end

            self:collideObject() 
        end,
        
        up = function(dt)
            local xPlayer = scene:getPlayer().x

            if ((xPlayer <= self.x - 40 or xPlayer >= self.x + 40) or self.y < self.yOrigin + 24) then
                self.time = self.time + dt

                if (self.time > 0.85) then
                    self.y = self.y - self.speed * dt

                    if (self.y < self.yOrigin + 24 and self.collisionType == 'none') then self.collisionType = 'trigger' end
                
                    if (self.y <= self.yOrigin) then
                        self.y = self.yOrigin
                        self.state = 'down'
                        self.time = 0
                    end
                end
            end

            self:collideObject() 
        end
    }

   --self.debug = true
end


function Plant:hit(target, hitType, arg)
    if (hitType == 'top' or hitType == 'attack') then scene:getPlayer():powerDown()
    elseif (hitType == 'bounce') then 
       self:destroy()
    end
end

function Plant:update(dt)
    local state = scene:getPlayer().state
    if (state == 'death' and state == 'powerup' or state == 'fireup' or state == 'powerdown') then return
    elseif(state == 'pipe') then self.y = self.yOrigin + 32 self.collisionType = 'none' end

    self.animation:update(dt)
    self.currentFrame = self.animation:getFrame()

    self.behaviours[self.state](dt)
end

function Plant:render()
    if (self.debug) then
        love.graphics.setColor(0,0,0, 0.5)
        love.graphics.rectangle('fill', math.floor(self.x - self.xOffset), math.floor(self.y - self.yOffset), self.w, self.h)
    end    

    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(ENNEMIES_ATLAS, ENNEMIES_QUADS[self.currentFrame-50], math.floor(self.x), math.floor(self.y-16), 0, self.sx, self.sy, self.xOffset + self.xMargin, self.yOffset + self.yMargin) 
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

        love.graphics.print(self.collisionType, self.x - 15, self.y-self.yOffset - 10)
    end 
end

return Plant
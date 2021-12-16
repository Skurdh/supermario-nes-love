local Object = require('lib.Object')
local SpitFire = Object:extend('SpitFire')

function SpitFire:new(x, y, targetline)
    self.super.new(self, x, y, 20, 8, nil, nil, 8, 4, 'trigger', 
    {'Browser', 'Bar SpitFire', 'BoxCoin', 'Coin', 'Mushroom', 'FirePlant', 'OneUP', 'Koopa', 'Fire Koopa', 'Goomba', 'Flying Red Koopa'}, 4)

    self.animation:add('attack', 10, {440, 476})
    self.animation:animate('attack')
    self.currentFrame = self.animation:getFrame()
    
    self.target = targetline
    if (self.target - self.y > 0) then self.dir = 1
    else self.dir = -1 end
    self.sx = -1
    self.sy = 1
    self.speed = 65

    self.state = 'targeting'

    SFX.BOWSER_FIRE_SND:stop()
    SFX.BOWSER_FIRE_SND:play()

    self.behaviours = {
        targeting = function(dt)
            if (self.y ~= self.target) then
                if (self.dir > 0 and self.y < self.target or self.dir < 0 and self.y > self.target) then
                    self.y = self.y + self.speed/2 * dt * self.dir
                else
                    print('ok')
                    self.y = self.target
                    self.state = 'attack'
                end
            end

            self.x = self.x - self.speed * dt
            
            self:collisionCam()
            self:collideObject()
        end, 

        attack = function(dt)
            self.x = self.x - self.speed * dt
            
            self:collisionCam()
            self:collideObject()
        end
    }

    self.debug = false
end

function SpitFire:collisionCam()
    local camX = scene:getCamera().x
    if (self.x + self.xOffset < camX) then
        self:destroy()
    end
end

function SpitFire:collideObject()
    local colls = scene:getMap():collideObject(self)

    for i=1, #colls do
        local object, side = colls[i][1], colls[i][2]
        
        if (self.collisionType ~= 'none' and tostring(object) == 'Player') then object:powerDown() end
    end
end

function SpitFire:update(dt)
    local state = scene:getPlayer().state
    if (state == 'death' or state == 'powerup' or state == 'fireup' or state == 'powerdown') then return end

    self.animation:update(dt)
    self.currentFrame = self.animation:getFrame() 

    self.behaviours[self.state](dt) 
end

function SpitFire:render()
    if (self.debug) then
        if (self.collisionType == 'trigger') then love.graphics.setColor(1,0,1, 0.5)
        else love.graphics.setColor(0,0,0, 0.5)
        end
        
        love.graphics.rectangle('fill', math.floor(self.x - self.xOffset), math.floor(self.y - self.yOffset), self.w, self.h)
        love.graphics.setColor(1,1,1,1)
    end    

    love.graphics.draw(OBJECTS_ATLAS, OBJECTS_QUADS[self.currentFrame], math.floor(self.x + 16 * self.sx), math.floor(self.y), 0, self.sx, self.sy, self.xOffset + self.xMargin, self.yOffset + self.yMargin) 
    love.graphics.draw(OBJECTS_ATLAS, OBJECTS_QUADS[self.currentFrame-1], math.floor(self.x), math.floor(self.y), 0, self.sx, self.sy, self.xOffset + self.xMargin, self.yOffset + self.yMargin) 

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

return SpitFire
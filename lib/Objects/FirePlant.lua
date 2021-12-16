local Object = require('lib.Object')
local FirePlant = Object:extend('FirePlant')

function FirePlant:new(x, y)
    self.super.new(self, x, y - 2, 14, 16, nil, nil, 1, 0, 'none', {'BoxCoin', 'Koopa', 'Goomba'}, 2, false)
    
    self.animation:add('idle', 6, {73, 74, 75, 76})
    self.animation:animate('idle')
    self.currentFrame = self.animation:getFrame()

    self.wait = false
    self.defaultY = y
    self.score = 1000

    SFX.POWERUP_APPEARS_SND:stop()
    SFX.POWERUP_APPEARS_SND:play()
end

function FirePlant:collect(player) 
    SFX.POWERUP_SND:stop()
    SFX.POWERUP_SND:play()
    
    player:powerUp()
    
    player:addScore(self.score)
    scene:getHud():addScore(self.score, self.x, self.y - self.yOffset) 

    self:destroy()
end

function FirePlant:collisionCam()
    local camX = scene:getCamera().x
    if (self.x + self.xOffset < camX) then
        self:destroy()
    end
end

function FirePlant:collideObject()
    local colls = scene:getMap():collideObject(self)

    for i=1, #colls do
        local object = colls[i][1]
        if (object:getClass() == 'Player') then self:collect(object) end
    end
end

function FirePlant:update(dt)
    if (state == 'death' or state == 'powerup' or state == 'fireup' or state == 'powerdown') then return end
    self.super.update(self, dt)

    self:collideObject()

   if (self.y > self.defaultY) then
        self.y = self.y - 20 * dt
    else
        if (not self.wait) then
            scene:getMap():updateDepth(self, 4)
            self.collisionType = 'trigger'
            self.wait = true
        end
    end
end

return FirePlant
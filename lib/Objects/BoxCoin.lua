local Object = require('lib.Object')
local BoxCoin = Object:extend('BoxCoin')

-- # Constants
local MAX_VSPEED = 285

function BoxCoin:new(x, y, yImpulse)
    self.super.new(self, x, y, 0, 0, 0, 0, 0, 0, 'none', {}, 5, false)
    self.animation:add('idle', 10, {253, 254, 255, 256})
    self.animation:animate('idle')
    self.currentFrame = self.animation:getFrame()

    self.defaultY = y - 8
    self.dy = yImpulse
    self.score = 200

    SFX.COIN_SND:stop()
    SFX.COIN_SND:play()

    local player = scene:getPlayer()
    player:addCoin()
    
    player:addScore(self.score)
end

function BoxCoin:update(dt)
    self.super.update(self, dt)
    if (self.y > self.defaultY and self.dy > 0) then 
        scene:getHud():addScore(self.score, self.x + 4, self.y + 8) 
        self:destroy()
    end

    self.dy = self.dy + GRAVITY * dt
    self.y = self.y + self.dy * dt
end

return BoxCoin
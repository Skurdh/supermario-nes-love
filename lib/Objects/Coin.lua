local Object = require('lib.Object')
local Coin = Object:extend('Coin')

local Coins_frames = {
    ['217'] = {217, 218, 219, 220}, 
    ['226'] = {226, 227, 228, 229}, 
    ['235'] = {235, 236, 237, 238}, 
    ['244'] = {244, 245, 246, 247}
}

local BoxCoin = require('lib.Objects.BoxCoin')

function Coin:new(x, y, tile)
    self.super.new(self, x, y, 10, 14, 5, 13, 3, 2, 'trigger', {}, 3, true)
    self.animation:add('idle', 6, Coins_frames[tostring(tile)])
    self.animation:animate('idle')
    self.currentFrame = self.animation:getFrame()

    self.score = 200
end

function Coin:collect(side) 
    SFX.COIN_SND:stop()
    SFX.COIN_SND:play()

    local player = scene:getPlayer()
    player:addCoin()
    player:addScore(self.score)

    self:destroy()

    if (side == 'decor') then 
        local BoxCoin = require('lib.Objects.BoxCoin')
        scene:getMap():addWorld(BoxCoin(self.x - self.xOffset - 3, self.y - 16, -325)) 
    end
        
end

function Coin:collisionCam()
    local camX = scene:getCamera().x 
    if (self.x + self.xOffset < camX) then
        self:destroy()
    end
end

function Coin:update(dt)
    self.super.update(self, dt)
    self:collisionCam()
end

return Coin
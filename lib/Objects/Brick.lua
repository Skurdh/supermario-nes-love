local ObjectDecor = require('lib.ObjectDecor')
local Brick = ObjectDecor:extend('Brick')

-- # Particule
local Fragment = require('lib.Objects.BrickFragment')

function Brick:new(x, y, tile)
    self.super.new(self, x, y, 16, 16, 3)
    
    self.animation = nil
    --print(tile)
    self.currentFrame = tile
end

function Brick:collect(side) 
    if (side == 'bottom' and not self.play) then
        self:collisionTop()
        local player = scene:getPlayer()

        if (player.life > 1) then
            SFX.BREAKBLOCK_SND:stop() 
            SFX.BREAKBLOCK_SND:play()

            -- # Fragments
            local fragX, fragY = self.x, self.y
            scene:getMap():addWorld(Fragment(fragX, fragY, self.currentFrame, 100, -250))
            scene:getMap():addWorld(Fragment(fragX, fragY, self.currentFrame, -100, -250))
            scene:getMap():addWorld(Fragment(fragX, fragY, self.currentFrame, 125, -350))
            scene:getMap():addWorld(Fragment(fragX, fragY, self.currentFrame, -125, -350))

            self:destroy()
        else
            SFX.BUMP_SND:stop() 
            SFX.BUMP_SND:play()

            self.play = true
        end

    end
end

function Brick:update(dt)
    self:collisionCam()
    self:interactAnim(dt)
end

return Brick
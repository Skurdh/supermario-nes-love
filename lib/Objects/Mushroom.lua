local Object = require('lib.Object')
local Mushroom = Object:extend('Mushroom')

-- # Constants
local SPEED = 50

function Mushroom:new(x, y)
    self.super.new(self, x, y - 2, 16, 16, nil, nil, 0, 0, 'none', {'BoxCoin', 'Koopa', 'Goomba'}, 2, false)
    
    self.animation = nil
    self.currentFrame = 1

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
            end
        end,
        move = function(dt)
            self:collisionCam()

            self.x = self.x + self.dx * dt
            local collSideX = self:collisionX()

            if (collSideX) then 
                if (collSideX == 'left') then self.dx = -SPEED
                elseif (collSideX == 'right') then self.dx = SPEED end
            end

            self.dy = self.dy + GRAVITY/1.25 * dt
            self.y = self.y + self.dy * dt
            self:collisionY()

            self:collideObject() 
        end
    }

    SFX.POWERUP_APPEARS_SND:stop()
    SFX.POWERUP_APPEARS_SND:play()
end

function Mushroom:collect(player, side) 
    SFX.POWERUP_SND:stop()
    SFX.POWERUP_SND:play()

    if (player.life == 1) then player:powerUp() end
    
    player:addScore(self.score)
    scene:getHud():addScore(self.score, self.x, self.y - self.yOffset) 

    self:destroy()
end

function Mushroom:collisionCam()
    local camX = scene:getCamera().x
    if (self.x + self.xOffset < camX or
        self.x - self.xOffset > camX + virtualWidth or
        self.y - self.yOffset > virtualHeight) then
        self:destroy()
    end
end

function Mushroom:collideObject()
    local colls = scene:getMap():collideObject(self)

    for i=1, #colls do
        local object, side = colls[i][1], colls[i][2]

        if (side == 'left') then self.dx = -SPEED
        elseif (side == 'right') then self.dx = SPEED end 

        if (object:getClass() == 'Player') then self:collect(object, side) end
    end
end

function Mushroom:update(dt)
    local state = scene:getPlayer().state
    if (state == 'death' or state == 'powerup' or state == 'fireup' or state == 'powerdown') then return end

    self.behaviours[self.state](dt)
end

return Mushroom
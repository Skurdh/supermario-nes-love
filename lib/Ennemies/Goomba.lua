local Ennemy = require('lib.Ennemy')
local Goomba = Ennemy:extend('Goomba')

-- # Constants
local SPEED = -35
local THEME_ID = {
    ['overworld'] = 0,
    ['underworld'] = 100,
    ['castle'] = 200,
    ['underwater'] = 0
}

-- # Sounds
function Goomba:new(x, y, theme, linked)
    self.super.new(self, x, y, 10, 16, nil, 15, 3, -1, {'Mushroom', 'FirePlant', 'Star', 'OneUP', 'Coin'}, 175, linked, SPEED)
    
    self.animation:add('attack', 6, {51 + THEME_ID[theme], 52 + THEME_ID[theme]})
    self.animation:add('dead', 1, {53 + THEME_ID[theme]})

    self.animation:animate('attack')
    self.currentFrame = self.animation:getFrame()
    self.animation:pause(true)

    --self.debug = true

    self.score = {
        crush = 100,
        fire = 100,
        star = 100,
        under = 100
    }

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
                if (collX == 'left') then self.dx = self.speed
                elseif (collX == 'right') then self.dx = -self.speed end 
            end
        
            self.dy = self.dy + GRAVITY * dt
            self.y = self.y + self.dy * dt
            self:collisionY()

            self:collideObject() 
        end,

        deadcrush = function(dt)
            self.animation:animate('dead')
            

            self.deadTimer = self.deadTimer + dt
            if (self.deadTimer > 0.8) then
                self:destroy()
            end
        end, 

        deadbounce = function(dt)
            self.x = self.x + self.dx*1.5 * dt

            self.dy = self.dy + GRAVITY/2 * dt
            self.y = self.y + self.dy * dt

            if (self.y > 500) then
                self:destroy()
            end
        end
    }
end

function Goomba:hit(target, hitType, arg)
    if (hitType == 'top' or hitType == 'bounce') then
        if (hitType == 'top') then
            self.state = 'deadcrush'
            if (scene:getPlayer().y > self.y - self.yOffset + 4) then scene:getPlayer().dy = -275
            else scene:getPlayer().dy = -265 end
        else
            -- # Direction of the bounce
            if (arg and arg > 0) then self.dx = -self.speed
            else self.dx = self.speed end 

            scene:getMap():updateDepth(self, 6)
            self.y = self.y - 12
            self.sy = -1
            self.state = 'deadbounce'
            self.animation:pause()
            self.dy = -210
        end

        self.collisionType = 'none'
        SFX.STOMP_SND:stop()
        SFX.STOMP_SND:play()
    
    elseif (hitType == 'attack') then scene:getPlayer():powerDown()
    --elseif (target:getClass() == 'Koopa' and target.state == 'moveshell') then self:hit(target, 'bounce', target.dx)
    elseif (hitType == 'left') then self.dx = -self.speed
    elseif (hitType == 'right') then self.dx = self.speed 
    end
end

function Goomba:update(dt)
    local state = scene:getPlayer().state
    if (state == 'death' or state == 'powerup' or state == 'fireup' or state == 'powerdown') then return end

    if (self.linked and (self.linked.state == 'deadcrush' or self.linked.state == 'deadbounce')) then self.linked = nil end

    self.animation:update(dt)
    self.currentFrame = self.animation:getFrame()

    self.behaviours[self.state](dt)
end



return Goomba
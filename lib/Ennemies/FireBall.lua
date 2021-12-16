local Object = require('lib.Object')
local FireBall = Object:extend('Bar FireBall')

-- # Constants
local SPEED = 2

function FireBall:new(x, y, rotation, diameter, collision, interval)
    local collType = 'trigger'
    if (not collision) then collType = 'none' end

    self.super.new(self, x, y, 6, 6, nil, nil, 5, 5, collType, {'Bar FireBall', 'BoxCoin', 'Coin', 'Mushroom', 'FirePlant', 'OneUP', 'Koopa', 'Fire Koopa', 'Goomba', 'Flying Red Koopa'}, 4, false)
    
    self.xOrigin, self.yOrigin = self.x, self.y
    self.rotation = rotation or 1
    self.diameter = diameter
    self.time = interval

    self.animation:add('idle', 10, {297, 333, 369, 405})
    self.animation:animate('idle')

    self.currentFrame = self.animation:getFrame()


    --self.debug = true
end

function FireBall:collisionCam()
    local camX = scene:getCamera().x
    if (self.x + self.xOffset < camX or
        self.x - self.xOffset > camX + virtualWidth or
        self.y - self.yOffset > virtualHeight) then
        self:destroy()
    end
end

function FireBall:collideObject()
    local colls = scene:getMap():collideObject(self)

    for i=1, #colls do
        local object, side = colls[i][1], colls[i][2]
        
        if (self.collisionType ~= 'none' and tostring(object) == 'Player') then object:powerDown() end
    end
end

function FireBall:update(dt)
    local state = scene:getPlayer().state
    if (state == 'death' or state == 'powerup' or state == 'fireup' or state == 'powerdown') then return end
    
    if (self.rotation > 0) then self.time = self.time + dt * SPEED
    elseif (self.rotation < 0) then self.time = self.time - dt * SPEED end
    

    self.x = self.xOrigin + math.cos(self.time) * self.diameter * 8
    self.y = self.yOrigin + math.sin(self.time) * self.diameter * 8

    self:collideObject()

    -- # Animation update
    self.animation:update(dt)
    self.currentFrame = self.animation:getFrame()
end

return FireBall
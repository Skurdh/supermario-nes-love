local Object = require('lib.Object')
local Fragment = Object:extend('Brick Fragment')

-- # Constants
local MAX_VSPEED, MIN_HSPEED = 375, 2
local BRAKE_SPEED = 30
local FRAG_COLOR = {

}

function Fragment:new(x, y, color, xImpulse, yImpulse)
    self.super.new(self, x, y, 8, 8, 0, 0, 0, 0, 'none', {}, 5, false)

    local fragFrame
    
    if (color == 291 or color == 88) then fragFrame = {50, 86}
    elseif (color == 301 or color == 98) then fragFrame = {59, 95}
    elseif (color == 309 or color == 106) then fragFrame = {68, 104} 
    else fragFrame = {41, 77} end

    self.animation:add('idle', 10, fragFrame)
    self.animation:animate('idle')
    self.currentFrame = self.animation:getFrame()

    self.dx, self.dy = xImpulse, yImpulse
end


function Fragment:collisionCam()
    if (self.y + self.h > virtualHeight) then
        self:destroy()
    end
end

function Fragment:update(dt)
    self.super.update(self, dt)
    self:collisionCam()

    -- # X axis movement
    if (self.dx > 0) then
        self.dx = math.max(MIN_HSPEED, self.dx - BRAKE_SPEED * dt)
    elseif (self.dx < 0) then
        self.dx = math.min(MIN_HSPEED, self.dx + BRAKE_SPEED * dt)
    end

    self.x = self.x + self.dx * dt

    -- # Y axis movement
    self.dy = math.min(MAX_VSPEED, self.dy + GRAVITY * dt)
    self.y = self.y + self.dy * dt
end

return Fragment
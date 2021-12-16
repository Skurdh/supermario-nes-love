local Object = require('lib.Object')
local PlatformBF = Object:extend('Platform Back and Forth')

local SPEED, MAX_SPEED, BRAKE_DISTANCE = 65, 35, 16

function PlatformBF:new(x, y, w, type, target, dir)
    self.super.new(self, x, y, w*16, 12, nil, nil, 0, -4, 'trigger', {'Coin', 'BoxCoin', 'Player', 'Bowser'}, 3, true)

    if (type == 'h') then
        if (dir < 0) then self.xOrigin, self.xTarget = target, self.x
        else self.xOrigin, self.xTarget = self.x, target end
        
    else
        if (dir < 0) then self.yOrigin, self.yTarget = target, self.y
        else self.yOrigin, self.yTarget = self.y, target end  
    end
    
    self.len = w

    self.type = type
    self.speed = 0
    self.dir = dir or 1

    self.animation = nil 
    self.currentFrame = 293

    self.event = false
end

function PlatformBF:collect(side)
    if (scene:getPlayer().lastY <= self.y and scene:getPlayer().dy >= 0) then 
        side = 'bottom'
    else
        if (scene:getPlayer().lastX <= self.x - self.xOffset) then
            side = 'right'
        elseif (scene:getPlayer().lastX >= self.x + self.xOffset) then
            side = 'left'
        else
            side = 'top'
        end
    end

    if (side == 'bottom') then
        self.event = scene:getPlayer()
    elseif (side == 'left') then
        scene:getPlayer().x = self.x + self.xOffset + scene:getPlayer().xOffset
        scene:getPlayer().dx = 0
    elseif (side == 'right') then 
        scene:getPlayer().x = self.x - self.xOffset - scene:getPlayer().xOffset
        scene:getPlayer().dx = 0
    elseif (side == 'top') then
        scene:getPlayer().y = self.y + scene:getPlayer().yOffset + 1
        scene:getPlayer().dy = 0
    end
end

function PlatformBF:collisionCam()
    local camX = scene:getCamera().x 
    if (self.x + self.xOffset < camX) then
        self:destroy()
    end
end

function PlatformBF:update(dt)
    local state = scene:getPlayer().state
    if (state == 'death' or state == 'powerup' or state == 'fireup' or state == 'powerdown') then return end

    if (self.type == 'h') then 
        if (self.dir == 1 and self.x > self.xTarget - self.xOffset - BRAKE_DISTANCE or self.dir == -1 and self.x < self.xOrigin + BRAKE_DISTANCE) then
            self.speed = self.speed - MAX_SPEED/135 * math.ceil(MAX_SPEED - self.speed + 1) * 0.33
            self.speed = math.max(0, self.speed)

            if (self.speed == 0) then self.dir = self.dir * -1 end
        else
            self.speed = self.speed + MAX_SPEED/135 * math.ceil(self.speed + 1) * 0.47
            self.speed = math.min(MAX_SPEED, self.speed)
        end

        self.x = self.x + self.speed * dt * self.dir
    else
        if (self.dir == 1 and self.y > self.yTarget - self.yOffset - BRAKE_DISTANCE or self.dir == -1 and self.y < self.yOrigin + BRAKE_DISTANCE) then
            self.speed = self.speed - MAX_SPEED/135 * math.ceil(MAX_SPEED - self.speed + 1) * 0.33
            self.speed = math.max(0, self.speed)

            if (self.speed == 0) then self.dir = self.dir * -1 end
        else
            self.speed = self.speed + MAX_SPEED/135 * math.ceil(self.speed + 1) * 0.47
            self.speed = math.min(MAX_SPEED, self.speed)
        end

        self.y = self.y + self.speed * dt * self.dir
    end
    
    if (self.event) then 
        if (self.type == 'h') then 
            self.event.x = self.event.x + self.speed * dt * self.dir
        end

        self.event.y = self.y - 9
        self.event.dy = 0
        self.event.onGround = true
        if (scene:getPlayer().state == 'jump') then scene:getPlayer():resetJump() end

        self.event = false
    end

    if (self.dir > 0 and self.y > virtualHeight + 15) then self.y = -6
    elseif (self.dir < 0 and self.y < -6) then self.y = virtualHeight + 15 end

    self:collisionCam()
end

function PlatformBF:render()
    if (self.debug) then
        love.graphics.setColor(0,0,0, 0.5)
        love.graphics.rectangle('fill', math.floor(self.x - self.xOffset), math.floor(self.y - self.yOffset), self.w, self.h)
        love.graphics.setColor(1,1,1,1)
    end    

    for j=0, self.len-1 do
        love.graphics.draw(OBJECTS_ATLAS, OBJECTS_QUADS[self.currentFrame], math.floor(self.x) + j*16, math.floor(self.y), 0, 1, 1, self.xOffset + self.xMargin, self.yOffset + self.yMargin) 
    end

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


return PlatformBF
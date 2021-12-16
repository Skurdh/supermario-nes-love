local Object = require('lib.Object')
local Platform = Object:extend('Platform Vertical')

function Platform:new(x, y, w, dir)
    self.super.new(self, x, y, w*16, 12, nil, nil, 0, -4, 'trigger', {'Coin', 'BoxCoin', 'Player'}, 3, true)
    self.len = w
    self.dir = dir or 1

    self.animation = nil 
    self.currentFrame = 293

    self.event = false

    --self.debug = true
end

function Platform:collect(side)
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

function Platform:collisionCam()
    local camX = scene:getCamera().x 
    if (self.x + self.xOffset < camX) then
        self:destroy()
    end
end

function Platform:update(dt)
    local state = scene:getPlayer().state
    if (state == 'death' or state == 'powerup' or state == 'fireup' or state == 'powerdown') then return end

    self.y = self.y + 25 * dt * self.dir

    if (self.event) then 
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

function Platform:render()
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


return Platform
local ObjectDecor = require('lib.ObjectDecor')
local Box = ObjectDecor:extend('Box')

-- # Spawned Objects
local BoxCoin = require('lib.Objects.BoxCoin')
local Mushroom = require('lib.Objects.Mushroom')
local FirePlant = require('lib.Objects.FirePlant')
local Star = require('lib.Objects.Star')
local Up = require('lib.Objects.1Up')

-- # Globals
local boxAnims = {
    ['181'] = {181, 182, 183, 184, 183, 182},
    ['190'] = {190, 191, 192, 193, 192, 191},
    ['199'] =  {199, 200, 201, 202, 201, 200},
    ['208'] = {208, 209, 210, 211, 210, 209}
}


function Box:new(x, y, tile, theme, content, count)
    self.super.new(self, x, y, 16, 16, 3)
    
    if (tile == 'brick') then
        self.animation = nil
        self.currentFrame = theme
    
    elseif (tile == 'box') then
        self.animation:add('idle', 6, boxAnims[tostring(theme)])
        self.animation:animate('idle')
        self.currentFrame = self.animation:getFrame() 
    end

    if (theme == 70 or theme == 273 or theme == 181) then self.block = 3
    elseif (theme == 88 or theme == 291) then self.block = 21
    elseif (theme == 190) then self.block = 294
    elseif (theme == 98 or theme == 301) then self.block = 31
    elseif (theme == 199) then self.block = 304
    elseif (theme == 106 or theme == 309 or theme == 208) then self.block = 39 end

    self.content = content
    self.count = count or 1
end

function Box:collect(side) 
    if (side == 'bottom' and self.count > 0 and not self.play) then
        self:collisionTop()
        local player = scene:getPlayer()
        self.play = true

        if (self.content == 'powerup' and player.life == 1) then
            scene:getMap():addWorld(Mushroom(self.x, self.y))
        elseif (self.content == 'powerup' and player.life > 1) then
            scene:getMap():addWorld(FirePlant(self.x, self.y))
        elseif (self.content == 'coin') then
            scene:getMap():addWorld(BoxCoin(self.x, self.y - 16, -325))
        elseif (self.content == 'star') then
            scene:getMap():addWorld(Star(self.x, self.y))
        elseif (self.content == '1up') then
            scene:getMap():addWorld(Up(self.x, self.y))
        end

        self.count = self.count - 1
        if (self.count == 0) then 
            self.animation = nil
            self.currentFrame = self.block
        end
    end
end

function Box:update(dt)
    if (self.animation) then
        self.animation:update(dt)
        self.currentFrame = self.animation:getFrame()
    end

    self:collisionCam()
    self:interactAnim(dt)
end

return Box
local Object = require('lib.Object')
local InvisibleBox = Object:extend('InvisibleBox')

-- # Spawned Objects
local BoxCoin = require('lib.Objects.BoxCoin')
local Mushroom = require('lib.Objects.Mushroom')
local FirePlant = require('lib.Objects.FirePlant')
local Star = require('lib.Objects.Star')
local Up = require('lib.Objects.1Up')

function InvisibleBox:new(x, y, theme, content)
    self.super.new(self, x, y , 16, 20, nil, nil, 0, 0, 'trigger', {}, 3, true)

    self.currentFrame = 0
    self.content = content

    if (theme == 'underworld') then self.block = 21
    elseif (theme == 'castle') then self.block = 31
    elseif (theme == 'underwater') then self.block = 39
    else self.block = 3 end

    self.debug = false
end

function InvisibleBox:collect(side) 
    local player = scene:getPlayer()
    
    if (side == 'top' and self.currentFrame == 0 and player.dy < 0 and player.y - player.yOffset > self.y - 4) then
        if (player.x > self.x - self.xOffset and player.x < self.x + self.xOffset) then
            -- # Block appears & player collision resolution
            local my = (self.y-self.yOffset)/16
            scene:getMap():setTile(TILE.COLLISION, (self.x-self.xOffset)/16 + 1, my + 1)
            
            player.dy = 0
            player.y = (my+1) * 16 + player.yOffset

            self.currentFrame = self.block

            -- # Spawn item
            local x, y = self.x - self.xOffset, self.y - self.yOffset

            if (self.content == 'powerup' and player.life == 1) then
                scene:getMap():addWorld(Mushroom(x, y))
            elseif (self.content == 'powerup' and player.life > 1) then
                scene:getMap():addWorld(FirePlant(x, y))
            elseif (self.content == 'coin') then
                scene:getMap():addWorld(BoxCoin(x, y - 16, -325))
            elseif (self.content == 'star') then
                scene:getMap():addWorld(Star(x, y))
            elseif (self.content == '1up') then
                scene:getMap():addWorld(Up(x, y))
            end
        end
    end
end

function InvisibleBox:collisionCam()
    local camX = scene:getCamera().x 
    if (self.x + self.w < camX) then
        scene:getMap():setTile(0, math.floor(self.x/scene:getMap().tileWidth + 1), math.floor((self.y-self.yOffset)/scene:getMap().tileHeight + 1))
        self:destroy()
        end
end

function InvisibleBox:update(dt)
    self:collisionCam(dt)
end

function InvisibleBox:render()
    if (self.debug) then
        love.graphics.setColor(0,0,0, 0.5)
        love.graphics.rectangle('fill', math.floor(self.x - self.xOffset), math.floor(self.y - self.yOffset), self.w, self.h)
        love.graphics.setColor(1,1,1,1)
    end    

    if (self.currentFrame ~= 0) then
        love.graphics.draw(TILES_ATLAS, TILES_QUADS[self.currentFrame], math.floor(self.x-self.xOffset), math.floor(self.y-self.yOffset)) 
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

return InvisibleBox
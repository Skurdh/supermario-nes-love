local ObjectDecor = Class:extend('ObjectDecor')

local Animation = require('lib.Animation')

function ObjectDecor:new(x, y, w, h, depth)
    -- # Positions & Dimensions
    self.x, self.y = x, y
    self.w, self.h = w, h
    self.defaultY = y

    -- # Movements
    self.dx, self.dy = 0, 0

    -- # Draw
    self.depth = depth or 3
    self.animation = Animation()
    self.currentFrame = 0

    -- # Decor 
    self.objectType = 'Decor'
    self.play = false
    self.time = 0
end

-- # ObjectDecor Management
-- function ObjectDecor:add()
--     self.map = scene:getMap()
--     self.map:addWorld(self)
--     self.camera = scene:getCamera()
-- end

function ObjectDecor:destroy()
    scene:getMap():setTile(0, self.x/scene:getMap().tileWidth + 1, self.y/scene:getMap().tileHeight + 1)

    self.animation = nil
    scene:getMap():destroyWorld(self)
end

-- # ANCHOR Collision
function ObjectDecor:collisionCam()
    local camX = scene:getCamera().x 
    if (self.x + self.w < camX) then
        self:destroy()
    end
end

function ObjectDecor:collisionTop()
    local world = scene:getMap().world

    for i=#world, 1, -1 do
        local object = world[i]

        if (object ~= self and object.objectType ~= 'Decor' and math.abs(object.x - self.x) < 32) then 
            if (object.x - object.xOffset < self.x + self.w and object.x + object.xOffset > self.x and
            object.y - object.yOffset < self.y and object.y > self.y - 3) then
                if(object:getClass() == 'Coin') then object:collect('decor')
                elseif (object.objectType == 'Ennemy' and object.collisionType ~= 'none') then 
                    object:hit('self', 'bounce', object.x - (self.x + 8)) 
                    scene:getPlayer():addScore(object.score.under, object, '')
                else
                    if (object.x < self.x + self.w/2) then object.dx = -math.abs(object.dx)
                    else object.dx = math.abs(object.dx) end
                    object.dy = -210
                end
                -- TODO selon si c'est un object ou un ennemi
            end
        end
    end
end

-- # Interaction
function ObjectDecor:collect(side)
end

function ObjectDecor:interactAnim(dt)
    if (self.play) then 
        self.time = self.time + dt * 15
        self.defaultY = math.min(self.y, self.defaultY + 55 * dt * -math.cos(self.time))

        if (self.y == self.defaultY) then 
            self.time = 0
            self.play = false 
        end
    end
end


-- ANCHOR Update / Draw
function ObjectDecor:update(dt)
    -- # Animation update
    self.animation:update(dt)
    self.currentFrame = self.animation:getFrame()

    self:collisionCam()
    self:interactAnim(dt)
end

function ObjectDecor:render()
    if (self.animation) then 
        love.graphics.draw(OBJECTS_ATLAS, OBJECTS_QUADS[self.currentFrame], math.floor(self.x), math.floor(self.defaultY))
    else
        love.graphics.draw(TILES_ATLAS, TILES_QUADS[self.currentFrame], math.floor(self.x), math.floor(self.defaultY)) 
    end
end

return ObjectDecor
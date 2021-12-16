local Object = require('lib.Object')
local FireBall = Object:extend('FireBall')

-- # Constants
local SPEED = 200

function FireBall:new(x, y, direction)
    self.super.new(self, x, y, 8, 8, nil, nil, 4, 4, 'trigger', {'BoxCoin', 'Coin', 'Player', 'Mushroom', 'FirePlant', 'OneUP'}, 6, false)
    
    self.animation:add('idle', 6, {297, 333, 369, 405})
    self.animation:add('dead', 10, {332, 368, 404}, false)
    self.animation:animate('idle')

    self.currentFrame = self.animation:getFrame()

    self.dx, self.dy = SPEED * direction, 0
    self.defaultY = y
    self.score = 1000

    self.state = 'spawn'

    self.behaviours = {
        spawn = function(dt)
            self.x = self.x + self.dx * dt

            if (self:collisionX()) then self.state = 'dead' end

            self.dy = math.min(SPEED, self.dy + GRAVITY * dt)
            self.y = self.y + self.dy * dt

            local yColl = self:collisionY()

            if (yColl) then
                if (yColl == 'bottom') then self.state = 'dead'
                else self.dy = -SPEED end
            end

            self:collideObject()
            self:collisionCam()
        end,
        dead = function(dt)
            self.animation:animate('dead')

            if (self.animation:isOver()) then 
                self:destroy() 
                
            end
        end
    }

    SFX.FIREBALL_SND:stop()
    SFX.FIREBALL_SND:play()

    self.debug = true
end

function FireBall:destroy()
    self.animation = nil
    table.remove(scene:getPlayer().fireball, 1)
    scene:getMap():destroyWorld(self)
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
        
        --print(object)
        if (object.collisionType ~= 'none' and object.objectType == 'Ennemy') then
            object:hit(self, 'bounce', self.dx)
            --scene:getPlayer():addScore(object.score.fire, object) --FIXME 
            self.state = 'dead'
        end
    end
end

function FireBall:update(dt)
    local state = scene:getPlayer().state
    if (state == 'death' or state == 'powerup' or state == 'fireup' or state == 'powerdown') then return end
    
    -- # Animation update
    self.animation:update(dt)
    self.currentFrame = self.animation:getFrame()

    self.behaviours[self.state](dt)
end

return FireBall
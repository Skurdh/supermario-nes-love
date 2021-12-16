local Ennemy = require('lib.Ennemy')
local Bowser = Ennemy:extend('Bowser')
local Animation = require('lib.Animation')

local FireSpit = require('lib.Ennemies.SpitFire')

-- # Constants
local THEME_ID = {
    ['overworld'] = 0,
    ['underworld'] = 100,
    ['castle'] = 0,
    ['underwater'] = 0
}

local SPEED = 20
local FAKE_BOWSER = {
    {1, 251}, {1, 61}, {1, 285}, {1, 281}, {27, 77}, {238, 288}, {27, 74}
}
-- # Sounds
function Bowser:new(x, y, theme, startLimit, endLimit)
    self.super.new(self, x, y, 26, 26, nil, nil, -10, -10, {'Mushroom', 'FirePlant', 'Star', 'OneUP', 'Coin', 'Bar FireBall', 'Koopa', 'Goomba', 'Red Koopa', 'SpitFire', 'Platform Back and Forth'}, 0, false, SPEED)
    
    self.startLimit, self.endLimit = startLimit, endLimit

    self.animation:add('attack', 1, {42 + THEME_ID[theme]})
    self.animation:add('move', 1, {46 + THEME_ID[theme]})
    self.animation:animate('move')
    self.currentFrame = self.animation:getFrame()

    self.footAnimation = Animation()
    self.footAnimation:add('move', 1, {93 + THEME_ID[theme], 95 + THEME_ID[theme]})
    self.footAnimation:animate('move')
    self.footFrame = self.footAnimation:getFrame()

    self.rng = {
        distance = {self.y - 4, self.y - 18},
        direction = {1, -1},
        jump = {-100, -115, -125},
        castTime = {1, 1.5, 1.80},
        cac = {self.y - 4, self.y - 36}
    }

    self.dirTime, self.jumpTime, self.castTimer, self.canCastTimer = 0, 0, 0, 0.12
    self.dirDraw, self.dirTimeDraw, self.jumpTimeDraw, self.castTimerDraw  = 2, 0, 0, 1
    

    self.timer = 0

    self.onGround = true
    self.state = 'distance'
    self.life = 5

    self.behaviours = {
        distance = function(dt)
            self.timer = self.timer + dt

            if (self.timer > 2) then
                local draw = love.math.random(1, 5)
                if (self.rng.distance[draw]) then scene:getMap():addWorld(FireSpit(self.x - self.xOffset*2, self.y - self.yOffset + 2 , self.rng.distance[draw])) end
                self.timer = 0
            end

            if (scene:getPlayer().x > self.x - 9 * 16) then 
                self.state = 'attack'
                self.timer = nil
            end
        end, 

        attack = function(dt)
            self.dirTime, self.jumpTime = self.dirTime + dt, self.jumpTime + dt
            self.canCastTimer = self.canCastTimer - dt
            self.castTimer = self.castTimer + dt 

            -- # Random Direction
            if (self.dirTime > 1.5 + self.dirTimeDraw) then
                self.dirDraw = love.math.random(1, 2)

                self.dirTimeDraw = love.math.random(0, 1)
                self.dirTime = 0
            end

            -- # Random Jump
            if (self.jumpTime > 1 + self.jumpTimeDraw) then
                local jumpDraw = love.math.random(1, 3)

                if ((jumpDraw == 1 or jumpDraw == 3) and self.onGround and self.x < self.endLimit - 16 and self.x > self.startLimit + 16) then 
                    self:setJump(self.rng.direction[love.math.random(1, 2)], self.rng.jump[math.random(1, 3)])
                end

                self.jumpTimeDraw = love.math.random(0, 0.75)
                self.jumpTime = 0
            end

            -- # Movement Controller 
            if (self.x < scene:getPlayer().x - 32 or scene:getPlayer().x > self.endLimit - 32) then 
                self.state = 'follow'
                self.sx = -1
                self.footAnimation:slow(0.23)
                return
            end

            if (self.x > self.endLimit) then 
                self.dirDraw = 2
                self.dirTime = 0
            elseif (self.x < self.startLimit) then 
                self.dirDraw = 1
                self.dirTime = 0
            end 

            if (self.y - self.yOffset < 118 and self.waitingSpit) then 
                print(self.y - self.yOffset)
                scene:getMap():addWorld(FireSpit(self.x - self.xOffset*2, self.y - self.yOffset + 2 , self.rng.cac[2]))
                self.waitingSpit = false
            end

            -- # Random Fire Spit
            if (self.currentFrame ~= 42 + THEME_ID[theme]) then
                if (self.castTimer > self.rng.castTime[self.castTimerDraw]) then 
                    if (love.math.random(1, 3) == 1) then 
                        self.animation:animate('attack')
                        self.canCastTimer = love.math.random(1.25, 2.5)

                        -- # Spawn firespit
                        local draw = love.math.random(1, 2)
                        if (draw == 2) then 
                            self.waitingSpit = true
                            if (self.onGround) then self:setJump(self.rng.direction[love.math.random(1, 2)], self.rng.jump[2]) end
                        else scene:getMap():addWorld(FireSpit(self.x - self.xOffset*2, self.y - self.yOffset + 2 , self.rng.cac[1])) end                        
                    end
                end
            else
                if (self.canCastTimer < 0) then 
                    self:setMove() 
                elseif (self.canCastTimer < 0.5) then 
                    if (love.math.random(1, 8) == 1) then 
                        self:setMove() 
                    end
                end                        
            end

            -- # Physics
            self.x = self.x + self.speed * dt * self.rng.direction[self.dirDraw]
            local collX = self:collisionX()
            if (collX == 'left') then
                self.dirDraw = 2 
                self.dirTime = 0
            end

            self.dy = self.dy + GRAVITY/4 * dt
            self.y = self.y + self.dy * dt
            
            local collY = self:collisionY()
            if (collY == 'top' and not self.onGround) then self.onGround = true end

            self:collideObject() 
        end,

        follow = function(dt)
            if (self.x > scene:getPlayer().x and scene:getPlayer().x < self.endLimit - 32) then
                self.state = 'attack'
                self.sx = 1
                self.dirDraw = 2 
                self.dirTime = 0
                self.speed = SPEED
                return
            end

            self.x = self.x + self.speed * dt * 1.5
            local collX = self:collisionX()
            if (collX == 'left') then
                self.speed = 0
                self.x = self.x - 2
            end

            self.dy = self.dy + GRAVITY/4 * dt
            self.y = self.y + self.dy * dt
            
            local collY = self:collisionY()
            if (collY == 'top' and not self.onGround) then self.onGround = true end

            self:collideObject()
        end,

        fall = function(dt)
            self.dy = self.dy + GRAVITY/4 * dt
            self.y = self.y + self.dy * dt
        end, 
        
        wait = function(dt)
        end, 

        deadbounce = function(dt)
            self.dy = self.dy + GRAVITY/3 * dt
            self.y = self.y + self.dy * dt
        end
    }

    --self.debug = true
end

function Bowser:collideObject() 
    local colls = scene:getMap():collideObject(self)

    for i=1, #colls do
        local object, side = colls[i][1], colls[i][2]
        
        if (tostring(object) == 'Player') then object:powerDown() end
    end
end

function Bowser:hit(target, hitType, arg)
    if (tostring(target) == 'FireBall') then
        self.life = self.life - 1

        if (self.life == 0) then 
            SFX.BOWSER_FALL_SND:play()
            self.state = 'deadbounce' 
            self.collisionType = 'none'
            self.dy = -130
            self.top, self.bottom = FAKE_BOWSER[scene:getMap():getWorldLevel()][1], FAKE_BOWSER[scene:getMap():getWorldLevel()][2]
        end
    end
end

function Bowser:setJump(dir, force)
    self.dy = force
    self.dx = self.dx * dir
    self.onGround = false 
end

function Bowser:setMove()
    self.animation:animate('move') 
    self.castTimer = 0
    self.castTimerDraw = love.math.random(1, 3)
end

function Bowser:setDeath()
    self.animation:animate('move')
    self.footAnimation:slow(0.12)
    self.state = 'wait'
end

function Bowser:update(dt)
    local state = scene:getPlayer().state
    if (state == 'death' or state == 'powerup' or state == 'fireup' or state == 'powerdown') then return end


    self.animation:update(dt)
    self.currentFrame = self.animation:getFrame()

    self.footAnimation:update(dt)
    self.footFrame = self.footAnimation:getFrame()

    self.behaviours[self.state](dt)
end

function Bowser:render()
    if (self.debug) then
        love.graphics.setColor(1,0,1,0.5)
        love.graphics.rectangle('fill', math.floor(self.x - self.xOffset), math.floor(self.y - self.yOffset), self.w, self.h)
        love.graphics.setColor(1,1,1,1)
    end    
    
    if (self.state ~= 'deadbounce') then 
        -- # Head
        love.graphics.draw(ENNEMIES_ATLAS, ENNEMIES_QUADS[self.currentFrame], math.floor(self.x + 16 * self.sx * -1), math.floor(self.y - 16), 0, self.sx, self.sy, self.xOffset + self.xMargin, self.yOffset + self.yMargin) 

        -- # Foot
        love.graphics.draw(ENNEMIES_ATLAS, ENNEMIES_QUADS[self.footFrame], math.floor(self.x), math.floor(self.y), 0, self.sx, self.sy, self.xOffset + self.xMargin, self.yOffset + self.yMargin) 

        -- # Back
        love.graphics.draw(ENNEMIES_ATLAS, ENNEMIES_QUADS[self.currentFrame + 1], math.floor(self.x), math.floor(self.y - 16), 0, self.sx, self.sy, self.xOffset + self.xMargin, self.yOffset + self.yMargin) 

        -- # Hands
        love.graphics.draw(ENNEMIES_ATLAS, ENNEMIES_QUADS[self.currentFrame + 50], math.floor(self.x + 16 * self.sx * -1), math.floor(self.y), 0, self.sx, self.sy, self.xOffset + self.xMargin, self.yOffset + self.yMargin) 
    else
        love.graphics.draw(ENNEMIES_ATLAS, ENNEMIES_QUADS[self.top], math.floor(self.x), math.floor(self.y - self.yOffset/2), 0, -1, -1, self.xOffset + self.xMargin, self.yOffset + self.yMargin) 
        love.graphics.draw(ENNEMIES_ATLAS, ENNEMIES_QUADS[self.bottom], math.floor(self.x), math.floor(self.y - 16 - self.yOffset/2), 0, -1, -1, self.xOffset + self.xMargin, self.yOffset + self.yMargin) 
    end



    if (self.debug) then
        love.graphics.setColor(1, 0, 0, 1)
        love.graphics.rectangle('fill', math.floor(self.x), math.floor(self.y), 1, 1)
    
        love.graphics.setColor(0,1,0,0.9)
        love.graphics.rectangle('fill', math.floor(self.x - self.xOffset), math.floor(self.y - 14), 1, 1)
        love.graphics.rectangle('fill', math.floor(self.x + self.xOffset - 1), math.floor(self.y - 14), 1, 1)
        love.graphics.rectangle('fill', math.floor(self.x - self.xOffset), math.floor(self.y), 1, 1)
        love.graphics.rectangle('fill', math.floor(self.x + self.xOffset - 1), math.floor(self.y), 1, 1)
        love.graphics.setColor(1,1,1,1)

        love.graphics.print(self.state, self.x - 15, self.y-self.yOffset - 10)

        if (self.linked) then
            
            if (self.linked.state == 'sleep') then love.graphics.setColor(1, 0, 0, 1)
            else love.graphics.setColor(0,1,0,1) end
            love.graphics.line(self.linked.x, self.linked.y - self.linked.yOffset/2, self.x, self.y - self.yOffset/2)
            love.graphics.setColor(1,1,1,1)
        end
    end 
end

return Bowser
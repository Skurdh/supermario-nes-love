local Object = require('lib.Object')
local CastleDoor = Object:extend('CastleDoor')

-- # Object
local Firework = require('lib.Objects.Firework')

-- # Constant
local fireworkPos = {
    {x = 28, y = -94},
    {x = -37, y = -156},
    {x = -70, y = -107},
    {x = -26, y = -138},
    {x = 24, y = -145}
}

function CastleDoor:new(x, y, flagPosX, flagPosY)
    self.super.new(self, x, y , 16, 16, nil, nil, 0, 0, 'trigger', {}, 0, true)

    self.animation = nil
    self.currentFrame = 9

    if (flagPosX) then
        self.firework = 0
        self.flagPos = 15-flagPosY - 1
        self.flagX, self.flagY = (flagPosX-1) * 16 , self.y - (self.flagPos*16 - 8)
        self.timer = 0.75
    end
    self.score = 50

    self.state = ''
    self.behaviours = {
        -- # Count time left and transform to points 
        count = function(dt)
            local player = scene:getPlayer()

            if (player.time > 0) then
                player.time = math.ceil(player.time) - 1
                player:addScore(self.score)
                
                if (player.time%4 == 0) then 
                    SFX.COIN_SND:stop()
                    SFX.COIN_SND:play()
                end
                if (player.time == 0) then 
                    if (self.flagPos) then self.state = 'raise' 
                    else self.state = 'wait' self.waitTimer = 1 end
                end
            end
        end,

        -- # Raise the flag
        raise = function(dt)
            if (self.flagY > self.y - (self.flagPos+1) * 16 + 2) then
                self.flagY = self.flagY - 20 * dt
            else
                if (self.firework > 0) then self.state = 'firework' 
                else self.state = 'wait' self.waitTimer = 1 end
            end
        end, 

        -- # Launch firework
        firework = function(dt)
            if (self.firework > 0) then
                self.timer = self.timer + dt

                if (self.timer > 1) then
                    self.timer = self.timer - 1
                    local index = self.firework%5 + 1
                    scene:getMap():addWorld(Firework(self.x + fireworkPos[index].x, self.y + fireworkPos[index].y))
                    self.firework = self.firework - 1
                end
            else
                self.state = 'wait' self.waitTimer = 1
            end
        end, 

        wait = function(dt)
            self.waitTimer = self.waitTimer - dt

            if (self.waitTimer < 0) then
                self.waitTimer = 99
                if (scene:getMap().custom) then 
                    scene:setEvent('gameEnd', {name='1-Titlescreen', lifescreen=false})
                else
                    scene:setEvent('nextmap', {name=scene:getMap().nextmap, lifescreen=true})
                end
            end
        end
    }

    --self.debug = true
end

-- Count number of firework according to time
function CastleDoor:countFirework(time)
    --print(time)
    local time = math.ceil(time)
    local count = tonumber(tostring(time):sub(-1))
    --print(time, count)

    if (count == 1 or count == 5 or count == 6) then return count end

    return 0
end

function CastleDoor:collect(side) 
    local player = scene:getPlayer()
    player.state = 'wait'
    scene:getMap():updateDepth(player, -1)

    self.state = 'count'
    self.firework = self:countFirework(player.time)
end

function CastleDoor:update(dt)
    if (self.behaviours[self.state]) then self.behaviours[self.state](dt) end
end

function CastleDoor:render()
    love.graphics.setColor(1,1,1,1)
    if (self.flagX) then 
        love.graphics.draw(OBJECTS_ATLAS, OBJECTS_QUADS[self.currentFrame], math.floor(self.flagX), math.floor(self.flagY)) 
    end

    if (self.debug) then
        love.graphics.setColor(0,0,0, 0.5)
        love.graphics.rectangle('fill', math.floor(self.x - self.xOffset), math.floor(self.y - self.yOffset), self.w, self.h)

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

return CastleDoor
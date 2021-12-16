local Object = require('lib.Object')
local Flag = Object:extend('Flag')

function Flag:new(x, y, h)
    self.super.new(self, x, y + 16, 2, h*16, nil, nil, 7, 0, 'trigger', {}, 4, true)

    self.flagX, self.flagY = self.x - 16, self.y - self.h + 2
    
    self.animation = nil
    self.currentFrame = 81

    self.play = false
    self.raise = true
    self.speed = 108
    self.score = 0

    self.timer = 0

    --self.debug = true
end

function Flag:getJumpHeight(y)
    if (y > self.y - 10*self.yOffset/100) then
        self.score = 100
    elseif (y > self.y - 39*self.yOffset/100) then
        self.score = 400
    elseif (y > self.y - 55*self.yOffset/100) then
        self.score = 800
    elseif (y > self.y - 87*self.yOffset/100) then
        self.score = 2000
    elseif (y > self.y - self.yOffset - 16) then
        self.score = 5000
    end
end

function Flag:collect(side)
    if (self.raise) then
        MUSICS.OVERWORLD_SND:stop()
        SFX.FLAGPOLE_SND:play()
        self.play = true
        
        local player = scene:getPlayer()
        player:flagged(self.speed)

        -- # Place the player on flag
        if (player.life == 1) then 
            player.yOffset = 16
            player.x = self.x - 5
        elseif (player.life > 1) then
            player.yOffset = 29
            player.x = self.x - 6
        end

        self:getJumpHeight(player.y - player.yOffset/2)

        player:addScore(self.score)
        scene:getHud():addScore(self.score, self.x + 8, self.y - 12, self.speed, true, self.yOffset - 25)

        -- FIXME self.score = {text = scene:scoreToFont(self.score), x = self.x + 5, y = self.y - 12}
    end
end

function Flag:update(dt)
    if (self.play) then
        if (self.raise) then
            self.flagY = self.flagY + self.speed * dt

            if (self.flagY + 18 > self.y) then self.raise = false end
        else   
            if (self.timer == 0) then
                local player = scene:getPlayer()
                player.direction = -1
                if (player.life == 1) then player.x = player.x + 10
                elseif (player.life > 1) then player.x = player.x + 12 end
            end

            self.timer = self.timer + dt
            if (self.timer > 1) then 
                scene:getPlayer():flagJump()
                self.play = false
            end   
        end
    end
end

function Flag:render()
    if (self.debug) then
        love.graphics.setColor(0,0,0, 0.5)
        love.graphics.rectangle('fill', math.floor(self.x - self.xOffset), math.floor(self.y - self.yOffset), self.w, self.h)
    end    

    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(OBJECTS_ATLAS, OBJECTS_QUADS[self.currentFrame], math.floor(self.flagX), math.floor(self.flagY)) 



    -- if (self.play or not self.raise) then
    --     for i=1, #self.score.text do
    --         local nb = self.score.text[i]
    --         love.graphics.draw(SCORE_ATLAS, SCORE_QUADS[nb], self.score.x + (i-1) * 4, math.floor(self.score.y))
    --     end
    -- end

    if (self.debug) then
        love.graphics.setColor(1, 0, 0, 1)
        love.graphics.rectangle('fill', math.floor(self.x), math.floor(self.y), 1, 1)
    
        love.graphics.setColor(0,1,0,0.9)
        love.graphics.rectangle('fill', math.floor(self.x - self.xOffset), math.floor(self.y - self.yOffset), 1, 1)
        love.graphics.rectangle('fill', math.floor(self.x + self.xOffset - 1), math.floor(self.y - self.yOffset), 1, 1)
        love.graphics.rectangle('fill', math.floor(self.x - self.xOffset), math.floor(self.y), 1, 1)
        love.graphics.rectangle('fill', math.floor(self.x + self.xOffset - 1), math.floor(self.y), 1, 1)


        love.graphics.setColor(1,0,0,1)
        love.graphics.line(self.x + 5, self.y - 87*self.yOffset/100 , self.x + 5, self.y - self.yOffset)
        love.graphics.setColor(1,0.35,0,1)
        love.graphics.line(self.x + 5, self.y - 55*self.yOffset/100, self.x + 5, self.y - 87*self.yOffset/100 )
        love.graphics.setColor(1,1,0,1)
        love.graphics.line(self.x + 5, self.y - 39*self.yOffset/100, self.x + 5, self.y - 55*self.yOffset/100 )
        love.graphics.setColor(0,1,0,1)
        love.graphics.line(self.x + 5, self.y - 10*self.yOffset/100 , self.x + 5, self.y - 39*self.yOffset/100 )
        love.graphics.setColor(0,0,1,1)
        love.graphics.line(self.x + 5, self.y , self.x + 5, self.y - 10*self.yOffset/100 )

        love.graphics.setColor(1,1,1,1)
    end
end

return Flag
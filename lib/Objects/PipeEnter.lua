local Object = require('lib.Object')
local PipeEnter = Object:extend('PipeEnter')


function PipeEnter:new(x, y, dir, destination)
    self.direction = dir
    self.destination = destination

    if (self.direction == 'h') then
        self.super.new(self, x + 15, y + 31, 1, 1, nil, nil, 0, 0, 'trigger', {}, 2, true)
    elseif (self.direction == 'v') then
        self.super.new(self, x, y + 15, 32, 1, nil, nil, 0, 0, 'trigger', {}, 2, true)
    end

    --self.debug = true
end

function PipeEnter:collect(side)
    assert(self.destination ~= nil, 'No destination. Configure destination in Tiled ! (Map properties > Custom properties > pipeentries)') 
    
    if (self.direction == 'v' and Keyboard.down('down')) then
        local player = scene:getPlayer()
        
        local margin = 5 - math.min(2, player.life)/2

        if (player.x > self.x - margin and player.x < self.x + margin) then
            SFX.PIPE_SND:stop()
            SFX.PIPE_SND:play()

            player:pipeTravel(self.destination, self.direction)
        end
    elseif (self.direction == 'h' and (Keyboard.down('right') or scene:getPlayer().state == 'autowalk')) then
        local player = scene:getPlayer()

        SFX.PIPE_SND:stop()
        SFX.PIPE_SND:play()

        player:pipeTravel(self.destination, self.direction, self.exit)
    end
end

function PipeEnter:collisionCam()
    local camX = scene:getCamera().x 
    if (self.x + self.xOffset < camX) then
        self:destroy()
    end
end

function PipeEnter:update(dt)
    self:collisionCam()
end

function PipeEnter:render()
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

return PipeEnter
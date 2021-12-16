local Object = require('lib.Object')
local Firework = Object:extend('Firework')

function Firework:new(x, y)
    self.super.new(self, x, y, 16, 16, nil, nil, 0, 0, 'none', {}, 4, true)
    self.animation:add('idle', 6, {332, 368, 404}, false)
    self.animation:animate('idle')
    self.currentFrame = self.animation:getFrame()

    SFX.FIREWORKS_SND:stop()
    SFX.FIREWORKS_SND:play()

    scene:getPlayer():addScore(500)
end


function Firework:update(dt)
    self.super.update(self, dt)
    
    if (self.animation:isOver()) then self:destroy() end
end

return Firework
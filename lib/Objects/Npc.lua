local Object = require('lib.Object')
local Npc = Object:extend('Npc')

local Text = require('lib.Objects.Text')


function Npc:new(x, y, skin, text)
    self.super.new(self, x, y, 12, 16, nil, nil, 50, 0, 'trigger', {}, 0, true)

    self.skin = skin
    self.play = false
    self.time = 0
    self.funcs = {}
    self.index = 1

    for _, sen in ipairs(text) do
        assert(sen.x and sen.y and sen.str, '(text) table is incomplete, make sure it contains x, y, str, indent /optionnal.')
        table.insert(self.funcs, function() scene:getMap():addWorld(Text(sen.x, sen.y, sen.str, sen.indent or 0)) end)
    end

    self.funcs[#self.funcs + 1] = function() 
        scene:setEvent('gameEnd', {name='1-Titlescreen', lifescreen=false}) 
    end
    
    self.debug = true
end

function Npc:collect() 
    scene:getPlayer().animation:animate('idle')
    scene:getPlayer().state = 'wait'
    self.play = true
end

function Npc:update(dt)
    if (self.play) then
        self.time = self.time + dt

        if (self.time > 1) then 
            self.funcs[self.index]()
            self.index = self.index + 1

            if (self.index == #self.funcs) then
                self.time = -2.5
            else
                self.time = 0
            end
        end
    end
end

function Npc:render()

    love.graphics.draw(OBJECTS_ATLAS, OBJECTS_QUADS[self.skin], math.floor(self.x), self.y - 30)
    love.graphics.draw(OBJECTS_ATLAS, OBJECTS_QUADS[self.skin + 36], math.floor(self.x), self.y - 14)

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

return Npc
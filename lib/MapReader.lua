local Object = require('lib.Object')
local MapReader = Object:extend('MapReader')

local function readMap()

end

-- TODO Verify corrupted map + ordre alpha

function MapReader:new(x, y)
    self.super.new(self, x, y + 8, 160, 136, 0, 0, 0, 0, 'none', {}, 6)

    self.maps = love.filesystem.getDirectoryItems('custom')
    self.lenMaps = #self.maps

    self.interactive = false
    self.void = false
    self.cursorIndex = 0
    self.selecTime = 0
    self.pauseTime = 0
    self.selecMap = self.maps[1]
    self.dx, self.dy = 0, 0

    if (#self.maps < 1) then self.void = true end
end

function MapReader:setInteractive(bool)
    self.interactive = bool or false
    self.cursorIndex = 0
    self.dx, self.dy = 0, 0
end

function MapReader:update(dt)
    if (self.interactive and not self.void) then
        if (Keyboard.press('down')) then self:naviguate('down')
        elseif (Keyboard.press('up')) then self:naviguate('up')
        elseif (Keyboard.press('x')) then scene:setEvent('nextmap', {custom=true, name=self.selecMap, lifescreen=true}) end

        if (self.selecMap:len() > 16) then 
            self.selecTime = self.selecTime + dt

            if (self.selecTime > 1.5) then 
                if (not self.scroll) then self.scroll = true end 
                if (self.pauseTime == 0) then self.dx = self.dx - 15 * dt end

                if (math.abs(self.dx) > default_font:getWidth(self.selecMap) - self.w - 11) then
                    self.pauseTime = self.pauseTime + dt

                    if (self.pauseTime > 1) then 
                        self.pauseTime = 0
                        self.selecTime = 0.25
                        self.dx = 0
                    end
                end
            end
        end
    end
end

function MapReader:naviguate(dir)
    if (dir == 'down') then self.cursorIndex = math.min(#self.maps - 1, self.cursorIndex + 1)
    elseif (dir == 'up') then self.cursorIndex = math.max(0, self.cursorIndex - 1) end

    self.scroll = false
    self.selecTime = 0
    self.dx = 0
    self.selecMap = self.maps[self.cursorIndex + 1]

    self.dy = math.min(0, (8 - self.cursorIndex) * 14)
end

function MapReader:render()
    
    if (self.interactive) then
        if (self.void) then
            love.graphics.print('Aucune cartes..', self.x + 2, self.y)
        else
            love.graphics.setScissor(self.x - virtualWidth, self.y, self.w, self.h)
            for i, map in ipairs(self.maps) do
                map = map:sub(1, -5)

                if (self.cursorIndex == i - 1 and self.scroll) then 
                    love.graphics.print(map, math.floor(self.x + 17 + self.dx), self.y + (i-1) * 14 + self.dy)
                    love.graphics.setColor({153/255, 78/255, 0, 1})
                    love.graphics.rectangle('fill', self.x, self.y + (i-1)*14 + self.dy, 19, 13)
                    love.graphics.setColor({1,1,1,1})
                else
                    if (map:len() > 16) then map = map:sub(1, 16) map = map..'..' end 
                    love.graphics.print(map, self.x + 17, self.y + (i-1) * 14 + self.dy)
                end
            end

            love.graphics.draw(HUD_ATLAS, HUD_QUADS[10], self.x + 1, self.y + self.cursorIndex * 14 + 1 + self.dy)

            if (self.cursorIndex > 8) then love.graphics.draw(HUD_ATLAS, HUD_QUADS[16], self.x + 1, self.y - 5) end
            if (self.cursorIndex < self.lenMaps - 2) then love.graphics.draw(HUD_ATLAS, HUD_QUADS[22], self.x + 1, self.y + self.h - 6) end

            love.graphics.setScissor()
        end
    end
end

return MapReader
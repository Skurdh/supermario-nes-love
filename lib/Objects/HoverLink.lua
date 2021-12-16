local Object = require('lib.Object')
local HoverLink = Object:extend('HoverLink')


local THEME = {
    {547, 549}, {551, 553}
}

local TEXT = {
    'OPEN\nFLDR', 'COPY\nPath'
}

local rand = {-1, 1}

function HoverLink:new(x, y, theme, func)
    self.super.new(self, x - 4, y, 32, 16, nil, nil, 0, 0, 'none', {'Player'}, 3, true)

    self.yOrigin = self.y

    self.animation:add('idle', 6, THEME[theme])
    self.animation:animate('idle')
    self.currentFrame = self.animation:getFrame()

    self.theme = theme
    self.func = func
    self.time = 0
    self.dir, self.dirTime = -1, 1 + love.math.random(-28, 66)/100

    self.click = false
    self.clickTime = 2
end

function HoverLink:reset()
    self.dir = self.dir * -1
    self.dirTime = 1 + love.math.random(-28, 66)/100
    self.time = 0
end

function HoverLink:update(dt)
    if (scene:getMap():getObject('MapReader').interactive) then
        local mouseDown, mouseX, mouseY = love.mouse.isDown(1), love.mouse.getPosition()

        self.clickTime = self.clickTime + dt
        self.hover = false
        
        if (mouseX >= self.x - self.xOffset*2 - 20 and mouseX <= self.x + self.xOffset - 4 and mouseY >= self.y*2 - self.yOffset*2 and mouseY <= self.y*2) then
            self.hover = true
            if (mouseDown and not self.click and self.clickTime > 0.8) then 
                self.click = true
                self.func()
                self.clickTime = 0
            end
        end

        if (not mouseDown) then self.click = false end
    
        self.time = self.time + dt

        if (self.time > self.dirTime) then
            self:reset()
        end

        if (self.y < self.yOrigin - 6) then
            self:reset()
            self.y = self.yOrigin - 6
        elseif (self.y > self.yOrigin + 6) then
            self:reset()
            self.y = self.yOrigin + 6
        end

        self.y = self.y + self.dir * dt * 5    


        self.animation:update(dt)
        self.currentFrame = self.animation:getFrame()
    end
end

function HoverLink:render()
    love.graphics.draw(OBJECTS_ATLAS, OBJECTS_QUADS[self.currentFrame], math.floor(self.x), math.floor(self.y), 0, 1, 1, self.xOffset + self.xMargin, self.yOffset + self.yMargin) 
    love.graphics.draw(OBJECTS_ATLAS, OBJECTS_QUADS[self.currentFrame + 1], math.floor(self.x + 16), math.floor(self.y), 0, 1, 1, self.xOffset + self.xMargin, self.yOffset + self.yMargin) 

    if (self.hover) then
        love.graphics.setColor(0,0,0,1)
        love.graphics.print(TEXT[self.theme], math.floor(self.x - default_font:getWidth(TEXT[self.theme])/2 + 1), math.floor(self.y + 2))
        love.graphics.setColor(1,1,1,1)
        love.graphics.print(TEXT[self.theme], math.floor(self.x - default_font:getWidth(TEXT[self.theme])/2), math.floor(self.y + 1))
    end
end


return HoverLink
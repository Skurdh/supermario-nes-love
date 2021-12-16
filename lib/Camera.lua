local Camera = Class:extend('Camera')

function Camera:new()
    self.debug = true
    self.x, self.y = 0, 0
    self.type = 'classic'
    self.dx = 0
end

function Camera:loadMapInfos()
    self.mapWidth = scene:getMap().mapWidthPixel
end

function Camera:centerTarget()
    if (self.type ~= 'fixed') then self.x = scene:getPlayer().x end
end

function Camera:setType(type, arg)
    --assert(type == 'classic' or type == 'fixed', 'Camera type isn\'t knows')
    if (self.type == 'slide') then self.direction, self.speed, self.reach = nil, nil, nil end 
    self.type = type

    if (self.type == 'fixed') then self.x = arg or 0
    elseif (self.type == 'classic') then self.x = 0 end
end

function Camera:slide(dir, speed, reach, func)
    self.type = 'slide'
    self.direction = dir
    self.speed = speed
    self.reach = reach
    self.func = func or nil
end

function Camera:update(dt)
    if (self.type == 'fixed') then
        
    elseif (self.type == 'classic') then
        self.x = math.max(math.max(self.x, 0), math.min(self.mapWidth - virtualWidth, scene:getPlayer().x - virtualWidth/2 -1))

    elseif (self.type == 'slide') then
        if (self.direction == 1 and self.x < self.reach or self.direction == -1 and self.x > self.reach) then
            self.x = self.x + self.direction * self.speed * dt
        elseif (self.x ~= self.reach) then self.x = self.reach
        elseif (self.func) then self.func() self.func = nil end
    end
end

function Camera:render()
    --love.graphics.push()
    love.graphics.translate(math.ceil(-self.x), math.ceil(-self.y))
end

return Camera

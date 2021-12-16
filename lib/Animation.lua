local Animation = Class:extend('Animation')

function Animation:new()
    self.animations = {}
    self.currentAnimation = nil
    self:reset()

    self.slowing = 1
end

function Animation:add(name, fps, frames, loop)
    self.animations[name] = {
        name = name,
        interval = 1 / fps,
        frames = frames,
        loop = loop or loop == nil,
        over = false
    }
end

function Animation:animate(name)
    --self.slowing = 1
    if (self.animations[name] and self.animations[name] ~= self.currentAnimation) then
        if (self.currentAnimation == nil or self.currentAnimation.loop or not self.currentAnimation.loop and self.currentAnimation.over) then
            self:reset()
            self.currentAnimation = self.animations[name]
        end
    end
end

function Animation:reset()
    self.timer = 0
    self.frame = 1
    self.stop = false
    if (self.currentAnimation ~= nil) then self.currentAnimation.over = false end
end

function Animation:pause(pause)
    if (pause == false or pause ~= nil) then self.stop = false
    else self.stop = true end
end

function Animation:slow(slowing)
    self.slowing = slowing
end

function Animation:getFrame()
    return self.currentAnimation.frames[self.frame]
end

function Animation:setFrame(frame)
    self.frame = frame
end

function Animation:isOver()
    return self.currentAnimation.over
end

function Animation:update(dt)
    if (not self.stop) then
        if (not self.currentAnimation.over) then
            self.timer = self.timer + dt

            if (self.timer >= self.currentAnimation.interval * self.slowing) then
                self.timer = self.timer - self.currentAnimation.interval * self.slowing
                self.frame = self.frame + 1
                if (self.frame > #self.currentAnimation.frames) then 
                    self.frame = 1 
                    if (not self.currentAnimation.loop) then 
                        self.currentAnimation.over = true 
                    end              
                end
            end
        end
    end
end

return Animation 
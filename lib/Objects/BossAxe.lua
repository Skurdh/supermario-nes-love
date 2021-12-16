local Object = require('lib.Object')
local BossAxe = Object:extend('BossAxe')

local axeAnims = {
    ['65'] = {289, 290, 291, 292, 291, 290},
    ['69'] = {298, 299, 300, 301, 300, 299},
    ['73'] =  {307, 308, 309, 310, 309, 308},
    ['77'] = {316, 317, 318, 319, 318, 317}
}

function BossAxe:new(x, y, theme, boss, platform, chain, bridge)
    self.super.new(self, x, y , 14, 14, nil, nil, 4, 1, 'trigger', {'Bar FireBall', 'BoxCoin', 'Coin', 'Mushroom', 'FirePlant', 'OneUP', 'Koopa', 'Fire Koopa', 'Goomba', 'Flying Red Koopa', 'Bowser'}, 0, true)

    self.animation:add('idle', 6, axeAnims[tostring(theme)])
    self.animation:animate('idle')
    self.currentFrame = self.animation:getFrame()

    self.boss = boss
    self.platform = platform
    self.chain = chain
    self.bridge = bridge

    self.dead = false
    self.final = false
    self.timer = -0.3

    --self.debug = true
end

function BossAxe:collect(side) 
    self.animation = nil
    self.currentFrame = 4

    scene:getMap():destroyWorld(self.platform)

    if (self.boss or self.boss.state ~= 'deadbounce') then
        scene:getPlayer().state = 'wait'
        
        self.boss:setDeath()
        self.dead = true
    else
        self.final = true 
        self.boss:destroy()
        self.boss = nil
    end
end

function BossAxe:update(dt)
    local state = scene:getPlayer().state
    if (state == 'powerup' or state == 'fireup' or state == 'powerdown') then return end

    if (self.dead) then
        self.timer = self.timer + dt

        if (self.timer > 0.10) then 
            if (self.chain) then 
                print( self.chain.x, self.chain.y)
                scene:getMap():setTile(0, self.chain.x, self.chain.y)
                scene:getMap():refreshBatch()
                self.chain = nil
                self.timer = -0.10

            elseif (self.bridge) then
                scene:getMap():setTile(0, self.bridge.x[1], self.bridge.y)
                scene:getMap():refreshBatch()
                table.remove(self.bridge.x, 1)
                SFX.BREAKBLOCK_SND:stop() 
                SFX.BREAKBLOCK_SND:play()
                self.timer = 0

                if (#self.bridge.x == 0) then self.bridge = nil self.timer = -0.1 end

            elseif (self.boss) then 
                self.boss.state = 'fall' 
                SFX.BOWSER_FALL_SND:play()
                self.timer = -99
            end
        end

        if (self.boss and self.boss.y - self.boss.yOffset > virtualHeight) then
            self.boss:destroy()
            self.collisionType = 'none'
            self.final = true
            self.dead = false
            self.boss = nil
        end
    end

    if (self.final) then
        scene:getPlayer():setWalk(1, 225, -1, nil, nil, 25)
        scene:getCamera():slide(1, 100, 144*16)
        self.final = false
        love.audio.stop()
        MUSICS.WORLD_CLEAR_SND:play()
    end


    if (self.boss and scene:getCamera().type ~= 'fixed' and scene:getPlayer().x > self.x - 6 * 16 - 8) then
        scene:getCamera():setType('fixed', self.x - 15 * 16 + 8)
    end

    -- # Animation update
    if (self.animation) then 
        self.animation:update(dt)
        self.currentFrame = self.animation:getFrame()
    end
end

return BossAxe
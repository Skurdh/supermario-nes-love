local Hud = Class:extend('Hud')

local Animation = require('lib.Animation')

local NUMBER_ATLAS = love.graphics.newImage('assets/graphics/HUD/atlas_number.png')
local NUMBER_QUADS = generateQuads(NUMBER_ATLAS, 4, 8)

function Hud:new()
    self.x, self.y = 0, 8
    self.floating = {}
    self.coin = Animation()
    self.coin:add('idle', 4, {1, 2, 3})
    self.coin:animate('idle')
    self.coinFrame =  self.coin:getFrame()
end

function Hud:scoreToFont(score)
    local output, score = {}, tostring(score)

    for i=1, score:len() do
        table.insert(output, tonumber(score:sub(i, i)) + 1)
    end

    return output
end

function Hud:resetScore()
    for i=1, #self.floating do table.remove(self.floating, i) end
end

function Hud:addScore(score, x, y, speed, live, limit)
    local floating = {}

    floating.score = self:scoreToFont(score)
    floating.x, floating.y = x - #floating.score*4/2, y - 8
    floating.defaultY = y - 8
    floating.live = live or false
    floating.limit = limit or 48
    floating.speed = speed or 40
    
    table.insert(self.floating, floating)
end

function Hud:update(dt)
    -- # Update Floating
    for i=#self.floating, 1, -1 do
        local float = self.floating[i]

        -- # Move to the top of the screen
        if (float.y > float.defaultY - float.limit) then
            float.y = float.y - float.speed * dt
        end

        -- # Remove
        if (not float.live and float.y < float.defaultY - float.limit) then table.remove(self.floating, i) end
    end

    -- # Update animation
    self.coin:update(dt)
    self.coinFrame =  self.coin:getFrame()
end

function Hud:render()
    local camX = math.floor(scene:getCamera().x)
    local player = scene:getPlayer()
    local world, stage = scene:getMap().worldlevel, scene:getMap().stage
    
    -- # Name & Score
    love.graphics.print(player.characterName, camX + 24, self.y + 7)
    love.graphics.print(string.rep('0', 6 - tostring(player.score):len()) .. player.score, camX + 24, self.y + 15)

    -- # Coins
    love.graphics.draw(HUD_ATLAS, HUD_QUADS[self.coinFrame], camX + 88, self.y + 16)
    love.graphics.draw(HUD_ATLAS, HUD_QUADS[6], camX + 96, self.y + 16)
    love.graphics.print(string.rep('0', 2 - tostring(player.coins):len()) .. player.coins, camX + 104, self.y + 15)

    -- # Level
    if (scene:getMap().custom) then
        love.graphics.print('CUSTOM', camX + 144, self.y + 7)
        love.graphics.print('MAP', camX + 152, self.y + 15)
    else
        love.graphics.print('WORLD', camX + 144, self.y + 7)
        love.graphics.print(world .. '-' .. stage:sub(1,1) , camX + 152, self.y + 15)
    end

    -- # Time
    love.graphics.print('TIME', camX + 200, self.y + 7)
    if (player.time) then 
        local time = tostring(math.ceil(player.time))
        love.graphics.print(string.rep('0', 3 - time:len()) .. time, camX + 208, self.y + 15) 
    end

    -- -- # Debug
    -- love.graphics.setColor(1, 0, 0, 0.66)
    -- love.graphics.print(love.timer.getFPS() .. " " .. player.state, camX + 24, self.y + 23)
    -- love.graphics.setColor(1,1,1,1)

    -- # Floating score
    for i=1, #self.floating do
        local float = self.floating[i]

        for j=1, #float.score do
            local index = float.score[j]
            love.graphics.draw(NUMBER_ATLAS, NUMBER_QUADS[index], math.floor(float.x) + j * 4, math.floor(float.y))
        end
    end

    -- # Start Stage Screen
    if (scene.lifeScreen) then
        if (scene:getMap().custom) then
            love.graphics.print('CUSTOM MAP', virtualWidth/2 - default_font:getWidth('CUSTOM MAP')/2, 75)
            love.graphics.print(scene:getMap().name, virtualWidth/2 - default_font:getWidth(scene:getMap().name)/2, 93)
        else
            local level = 'WORLD ' .. world .. '-' .. stage:sub(1,1)
            love.graphics.print(level, virtualWidth/2 - default_font:getWidth(level)/2, 80)
        end

        if (player.life == 1) then love.graphics.draw(MARIO_ATLAS[1], MARIO_QUADS[1][1], virtualWidth/2 - 30, 112)
        elseif (player.life == 2) then love.graphics.draw(MARIO_ATLAS[2], MARIO_QUADS[2][1], virtualWidth/2 - 30, 96)
        elseif (player.life == 3) then love.graphics.draw(MARIO_ATLAS[2], MARIO_QUADS[2][43], virtualWidth/2 - 30, 96) end

        love.graphics.draw(HUD_ATLAS, HUD_QUADS[6], virtualWidth/2 - 6, 120)
        love.graphics.print(player.up, virtualWidth/2 + 16, 120)

    elseif (scene.endScreen) then
        if (scene:getMap().custom) then
            love.graphics.printf(scene:getMap().endtext, 16, 64, virtualWidth - 32, 'center')
        else
            love.graphics.printf('Thanks for playing\nmy Super Mario Bros.!', 16, 64, virtualWidth - 32, 'center')
            love.graphics.printf("You can create your owns maps with Tiled. On titlescreen, press <right> to acces Custom Map Menu. Then, click on flying ? box to get the documentation !"
            , 16, 104, virtualWidth - 32, 'justify')
            love.graphics.print('-SKURD', virtualWidth - 65, 184)
        end

    elseif (scene.gameoverScreen) then
        --print('gameover', default_font:getWidth('GAMEOVER'))
        love.graphics.setColor(1,1,1,1)
        love.graphics.print('GAMEOVER', scene:getCamera().x + virtualWidth/2 - default_font:getWidth('GAMEOVER')/2, 120)
    end
end

return Hud
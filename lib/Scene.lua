local Scene = Class:extend('Scene')

local Map = require('lib.Map')

function Scene:new(params)
    self.maps = {}
    self.currentMap = nil
    self.player = params.player or nil
    self.camera = params.camera or nil
    self.hud = params.hud or nil

    if (params.highscore) then self.player.highscore = tonumber(params.highscore)
    else self.player.highscore = 0 end

    self.debug = false
    self.timer = 0
    self.screenTimer = 0
    self.lifeScreen = false

    self.gameoverScreen = false
    self.gameoverTimer = 0
end

function Scene:destroy()
    for k, _ in pairs(self.maps) do
        self.maps[k]:destroy()
        self.maps[k] = nil
    end

    self.currentMap:destroy()
    self.currentMap = nil
  
    self.player:destroy()
    self.player = nil

    self.camera:destroy()
    self.camera = nil

    self.hud:destroy()
    self.hud = nil

    self.alreadyLoadData = false
end

function Scene:loadMap(name, custom)
    local path = ''
    if (custom) then 
        -- FIXME 
        assert(love.filesystem.getInfo('custom/'..name) ~= nil, 'Map ' .. name .. ' not found. Make sure the map exists !')
        path='custom.'..  name:sub(1, -5) 
    else 
        assert(love.filesystem.getInfo('lib/Stage/World-'.. name:sub(1, 1)..'/'..name:sub(3, -1)..'.lua') ~= nil, 'Map ' .. name .. ' not found. Make sure the map exists !')
        path = 'lib.Stage.World-' .. name:sub(1, 1) .. '.' .. name:sub(3, -1) 
    end

    

    --print(name:sub(1, -5), path)
    local map_data = require(path)

    self.maps[name] = Map(map_data)

    for i=1, #self.maps[name].undermaps do
        self:loadMap(self.maps[name].undermaps[i])
    end
end

function Scene:setEvent(eventType, arg)
    if (eventType == 'gameEnd') then
        self.endScreen = true
        self.endTimer = 15
        self.argTemp = arg
        self.camera.x = 0
        self.camera.type = 'fixed'
    elseif (eventType == 'nextmap') then
        if (self.currentMap) then self.currentMap:setExitEvent(arg)
        else self:nextMap(arg.name, arg.lifescreen, arg.x, arg.y, arg.state) 
        end  
    end  
end

function Scene:nextMap(name, lifescreen, x, y, state, custom)
    if (self.player.up > 0) then
        if (not self.maps[name] or lifescreen) then 
            -- # Reset maps
            self.currentMap = nil
            for k, _ in pairs(self.maps) do
                self.maps[k]:destroy()
                self.maps[k] = nil
            end

            -- # Load next maps
            if (custom) then 
                self:loadMap(name, true)
                self.maps[name].loadname = name
                
                if (not self.alreadyLoadData) then
                    self.player.up = self.maps[name].playerlife 
                    self.alreadyLoadData = true 
                end

            else self:loadMap(name) end
        end

        self.currentMap = self.maps[name]
        self.currentMap.custom = custom or nil

        self.camera:loadMapInfos()

        if (lifescreen) then
            self.lifeScreen = true
            self.screenTimer = 2
            self.camera:setType('fixed')
            self.playerState = state
        else
            self.currentMap:enter(x, y, state)
        end
    else
        name = '1-Titlescreen'
        -- # Reset maps
        self.currentMap = nil
        for k, _ in pairs(self.maps) do
            self.maps[k]:destroy()
            self.maps[k] = nil
        end

        -- # Load next maps
        self:loadMap('1-titlescreen')

        self.currentMap = self.maps['1-titlescreen']
        self.camera:loadMapInfos()
        
        self.gameoverScreen = true
        self.gameoverTimer = 6

        MUSICS.GAME_OVER_SND:play()
    end

    if (name == '1-Titlescreen') then
        self.player.up = 3
        self.player.coins = 0
        self.player.life = 1
        self.player:setBody()
        self.alreadyLoadData = false

        if (self.player.score > self.player.highscore) then 
            love.filesystem.write('highscore.save', self.player.score)
            self.player.highscore = self.player.score
        end
    end
end

-- TODO 
function Scene:reset()

end

function Scene:getMap()
    return self.currentMap
end

function Scene:getPlayer()
    return self.player
end

function Scene:getCamera()
    return self.camera
end

function Scene:getHud()
    return self.hud
end

function Scene:update(dt)
    -- # Memory management
    self.timer = self.timer + dt

    if (self.timer > 10) then
        self.timer = 0
        print('#1 -> Memory in use before a cycle: ' .. collectgarbage('count') .. ' (Kbytes)')
        collectgarbage('collect')
        print('#2 -> Memory in use after a cycle: ' .. collectgarbage('count') .. ' (Kbytes)')
    end

    if (Keyboard.press('r')) then self:setEvent('nextmap', {name=self:getMap().worldlevel..'-'..self:getMap().stage, lifescreen=false}) self.maps = {} end

    -- # Life Screen
    if (self.lifeScreen) then
        self.screenTimer = self.screenTimer - dt

        if (self.screenTimer < 0) then
            self.lifeScreen = false
            self.currentMap:enter()
        end

    -- # Game OverScreen
    elseif (self.gameoverScreen) then
        self.gameoverTimer = self.gameoverTimer - dt

        if (self.gameoverTimer < 0) then
            MUSICS.GAME_OVER_SND:stop()
            self.gameoverScreen = false
            self.player.up = 3
            self.player.score = 0
            self.currentMap:enter(nil, nil, self.playerState)
            self.playerState = nil
        end

    -- # End Screen
    elseif (self.endScreen) then
        self.endTimer = self.endTimer - dt

        if (self.endTimer < 0) then
            self.endScreen = false
            self.endTimer = 99
            self.currentMap:setExitEvent(self.argTemp)
            self.argTemp = nil
        end
        
    -- # Update current map
    else
        -- print('\nUPDATE DE ' .. self.currentMap.name)²
        if (self.currentMap) then self.currentMap:update(dt) end
    end

    if (self.camera) then self.camera:update(dt) end
    if (self.hud) then self.hud:update(dt) end
end


function Scene:render()
    if (self.camera) then self.camera:render() end

    if (not self.lifeScreen and not self.gameoverScreen and not self.endScreen) then
        if (self.currentMap) then self.currentMap:render() end
    end

    if (self.hud) then self.hud:render() end
end

return Scene

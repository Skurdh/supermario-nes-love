require('lib.Utils')
require('lib.Globals')

-- FIXME SCORE
-- flag

local push = require('lib.push')
Class = require('lib.Classic')
Keyboard = require('lib.Keyboard')

local cx, cspd = 0, 300

function love.load()
    -- # Game configuration
    virtualWidth, virtualHeight = 256, 240 --256, 240
    local windowWidth, windowHeight = virtualWidth*2, virtualHeight*2

    love.graphics.setDefaultFilter('nearest', 'nearest')

    push:setupScreen(virtualWidth, virtualHeight, windowWidth, windowHeight, {
        fullscreen = false,
        resizable = false
    })

    love.graphics.setFont(default_font)

    local fullpath = love.filesystem.getSaveDirectory():gsub('/', '\\')
    package.path = package.path .. ';'..fullpath

    Keyboard.hookevents()

    -- Loading Class
    local Scene = require('lib.Scene')
    local Map = require('lib.Map')
    local Player = require('lib.Player')
    local Camera = require('lib.Camera')
    local Hud = require('lib.Hud')

    -- # Loading Font
    love.graphics.setFont(default_font)

    -- # Loading title screen
    --local titlescreen = require('lib.Stage.titlescreen')

    -- # Loading Highscore
    local score = 0

    if (love.filesystem.getInfo('custom')) then
    else love.filesystem.createDirectory('custom') end

    if (love.filesystem.getInfo('highscore.save')) then
        score = love.filesystem.read('highscore.save')
    else
        love.filesystem.write('highscore.save', '0')
    end

    -- Create Object
    local player = Player()
    -- --local map = Map({1, 34, 265, 266, 298, 299, 267, 268, 269, 300}, {99/255, 173/255, 1, 1}, stage1:getStage())
    -- local map = Map({1, 2, 3, 29}, {99/255, 173/255, 1, 1}, stage1:getStage())

    --local test_map = Map(love.graphics.newImage('assets/graphics/tiles.png'), {1, 34, 265, 266, 298, 299}, {99/255, 173/255, 1, 1}, 16, 16, 3, 4, {697, 697, 697, 697, 697, 697, 697, 697, 697, 1, 697, 1})

    scene = Scene({player = player, camera = Camera(player), hud = Hud(), highscore = score})
    scene:setEvent('nextmap', {name='1-Titlescreen', lifescreen=false})
end

function love.update(dt)
    if (dt > 0.033) then return false end

    scene:update(dt)
    Keyboard.update(dt)
end

function love.draw()
    push:apply('start')

    love.graphics.translate(cx, 0)
    scene:render()

    push:apply('end')
end

function love.keypressed(key)
    if (key == 'kp+') then
        cspd = cspd + 50
    elseif (key == 'kp-') then
        cspd = cspd - 50
    end
end
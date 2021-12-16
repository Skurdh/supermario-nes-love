local Player = Class:extend('Player')

local Animation = require('lib.Animation')
local Ball_OBJ = require('lib.Objects.FireBall')

-- ## Constant
local WALK_SPEED, MAX_WALK_SPEED = 300, 116
local RUN_SPEED, MAX_RUN_SPEED = 400, 154
local BRAKE_SPEED = 200
local JUMP_STRENGTH, JUMP_SPRING_IDLE, JUMP_SPRING_WALK, JUMP_SPRING_RUN = 190, 1104, 1120, 1172
local PUSH_STRENGTH = 35
local MAX_LIFE = 2
local VERTICAL_BOUNCE = 35

local COMBOS = {
    crush = {500, 800, 1000, 2000, 4000, 5000, 8000, 3679}
}

-- ## Audios
local SND_STARMAN = love.audio.newSource('assets/musics/STARMAN.mp3', 'stream')
local SND_JUMP = love.audio.newSource('assets/sfx/jump_small.wav', 'static')
local SND_DEATH = love.audio.newSource('assets/sfx/mariodie.wav', 'static')
local SND_POWERDOWN = love.audio.newSource('assets/sfx/pipe.wav', 'static')

-- ## Graphics & Animation
-- # // [1]: small, [2]: big, [3]: fire
-- # // [4]: invincibility 1, [5]: invincibility 2 (OW), [6]: invincibility 3 (OW), [7]: invincibility 2 (UG), [8]: invivibility 2 (CASTEL)
-- # // [9]: invivibility 3 (UG/CASTEL), [10]: invivibility 2 (UW), [11]: invivibility 3 (UW)
local marioAttribute, spriteQuads, animations = {}, {}, {}, {}

-- # // Small
marioAttribute[1] = {
    w = 12, h = 15, 
    xOffset = 6, yOffset = 14,
    xMargin = 2, yMargin = 0
}

animations[1] = Animation()
animations[1]:add('idle', 1, {1})
animations[1]:add('walk', 14, {2, 3, 4})
animations[1]:add('slide', 1, {5})
animations[1]:add('jump', 1, {6})
animations[1]:add('die', 1, {7})
animations[1]:add('hang', 1, {8})
animations[1]:add('flag-down', 4, {9, 8})
animations[1]:add('swim', 10, {10, 11, 12, 13, 14})
animations[1]:add('powerdown', 1, {11})
animations[1]:add('powerup', 1, {1})

-- # // Big
marioAttribute[2] = {
    w = 12, h = 31, 
    xOffset = 6, yOffset = 30,
    xMargin = 2, yMargin = 0
}

animations[2] = Animation()
animations[2]:add('idle', 1, {1})
animations[2]:add('walk', 14, {2, 3, 4})
animations[2]:add('slide', 1, {5})
animations[2]:add('jump', 1, {6})
animations[2]:add('crouch', 1, {7})
animations[2]:add('shoot', 5, {2}, false)
animations[2]:add('hang', 1, {8})
animations[2]:add('flag-down', 4, {9, 8})
animations[2]:add('swim', 10, {10, 11, 12, 13, 14, 15})
animations[2]:add('powerdown', 3, {6, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11})
animations[2]:add('powerup', 7, {16, 16, 1, 1, 1})

-- # // Crouch
marioAttribute[3] = {
    w = 12, h = 15,
    xOffset = 6, yOffset = 14,
    xMargin = 2, yMargin = 16
}

local invincibilityEffect = {
    {42, 56, 70, 0},
    {63, 84, 105, 0}
}

local fireUpEffect = {
    84, 42, 105, 63
}

function Player:new()
    --self.debug = true

    -- # Coords
    self.x, self.y = 0, 0
    self.lastX, self.lastY = 0, 0
    self.w, self.h = 0, 0

    self.sx, self.sy = 1, 1
    self.r = 0
    
    self.xOffset, self.yOffset = 0, 0
    self.xMargin, self.yMargin = 0, 0


    -- # Movements 
    self.dx, self.dy = 0, 0
    self.lastDx, self.lastDy = 0, 0

    self.direction = 1

    self.speed = WALK_SPEED
    self.maxSpeed = MAX_WALK_SPEED

    self.spring = 0
    self.canSpring = true

    self.onGround = false

    self.collisionType = 'trigger'
    self.noCollision = {'Mushroom', 'FirePlant', 'Goomba', 'Koopa', 'Plant', 'FireBall', 'Red Koopa', 'Flying Red Koopa', 'Bar FireBall', 'Bowser', 'SpitFire'}

    
    -- # Draw
    self.atlas = nil
    self.spriteQuads = nil
    self.alpha = 1
    self.depth = 5
    self.animation = nil
    self.currentFrame = 0
    self.effectFrame = 0
    self.state = 'walk'
    self.lastState = ''


    -- # Stats
    self.characterName = 'Mario'
    self.life = 1
    self.bonus = 0
    self.up = 1
    self.score = 0
    self.last_score = 0
    self.coins = 0
    self.invincibility = false
    self.invincibilityTimer = 0
    self.numberPlayer = 1
    self.fireball = {}
    self.combos = {}


    -- # Timer
    self.time = nil
    self.timerCombo = 0
    self.powerTimer = 0


    -- # ANCHOR Behaviours
    self.behaviours = {
        titlescreen = function(dt)
            self.animation:animate('idle')

            if (self.direction ~= 1) then self.direction = 1 end

            if (Keyboard.press('left') and self.x > virtualWidth) then 
                self:setWalk(-1, -265, 2.77, 'titlescreen')
                scene:getCamera():slide(-1, 75, 0)
                scene:getMap():getObject('MapReader'):setInteractive(false)
            elseif (Keyboard.press('right') and self.x < virtualWidth) then 
                self:setWalk(1, 265, 2.77, 'titlescreen')
                scene:getCamera():slide(1, 65, virtualWidth, function() scene:getMap():getObject('MapReader'):setInteractive(true) end)
            end

            if (self.x < virtualWidth) then 
                if (Keyboard.press('down')) then
                    self.numberPlayer = math.min(2, self.numberPlayer + 1)
                elseif (Keyboard.press('up')) then
                    self.numberPlayer = math.max(1, self.numberPlayer - 1)
                elseif (Keyboard.press('x')) then
                    scene:setEvent('nextmap', {name='1-1', lifescreen=true})
                end
            end
            -- # Animation update
            self.animation:update(dt)
            self.currentFrame = self.animation:getFrame()
        end, 

        walk = function(dt)
            -- # Inputs
            -- ## Shot Fire Ball
            if (Keyboard.press('x')) then self:shootFire() end

            -- ## Jump
            if (Keyboard.press('up')) then if (self:jump()) then return end end

            -- ## Crouch
            if (self.life > 1 and Keyboard.press('down')) then self:crouch() end

            -- ## Walk / Run
            if (Keyboard.down('x') and self.maxSpeed ~= MAX_RUN_SPEED) then 
                self.speed, self.maxSpeed = RUN_SPEED, MAX_RUN_SPEED
                self.animation:slow(0.60)
            elseif (not Keyboard.down('x') and self.maxSpeed ~= MAX_WALK_SPEED) then
                self.speed, self.maxSpeed = WALK_SPEED, MAX_WALK_SPEED
                self.animation:slow(1)
            end

            -- ## Move
            if (Keyboard.down('left')) then
                self.direction = -1 
                self.dx = self.dx - self.speed * dt

                if (self.dx > self.maxSpeed*0.15) then self.animation:animate('slide')
                else 
                    self.animation:animate('walk') 
                    if (self.dy > 10) then 
                        self.animation:pause()
                    else self.animation:pause(true) end
                end

            elseif (Keyboard.down('right')) then
                self.direction = 1
                self.dx = self.dx + self.speed * dt

                if (self.dx < -self.maxSpeed*0.15) then self.animation:animate('slide')
                else 
                    self.animation:animate('walk') 
                    if (self.dy > 10) then 
                        self.animation:pause()
                    else self.animation:pause(true) end
                end
            else
                if (self.dx == 0) then self.animation:animate('idle')
                else self.animation:animate('walk') end              
            end

            -- # Invicibility
            self:invincibilityUpdate(dt)

            -- # Brake
            if (self.dx < 0) then 
                self.dx = self.dx + math.max(BRAKE_SPEED * dt, self.dx)
            elseif (self.dx > 0) then 
                self.dx = self.dx - math.min(BRAKE_SPEED * dt, self.dx)
            end

            -- # Cap Speed
            self.dx = math.max(math.min(self.dx, self.maxSpeed), -self.maxSpeed)

            -- # Gravity
            if (not self.onGround) then self.dy = self.dy + GRAVITY * dt end

            -- # Death Check
            if (self.y > 400) then self:die() end

            -- # Time left
            self.time = math.max(0, self.time - dt)
            if (self.time <= 0) then self:die() end

            if (#self.combos > 0) then self:resetCombo(dt) end

            -- # World Physics update 
            self.x = self.x + self.dx * dt
            local collSideX, xColl = self:collisionX()
            if (collSideX) then 
                if (collSideX == 'left') then
                    self.x = (xColl-1) * scene:getMap().tileWidth - self.xOffset
                elseif (collSideX == 'right') then
                    self.x = xColl * scene:getMap().tileWidth + self.xOffset
                end

                self.dx = 0                    
            end

            self.y = self.y + self.dy * dt
            local collSideY, yColl, tile = self:collisionY()
            if (collSideY) then
                if (collSideY == 'top') then
                    self.y = (yColl - 1) * scene:getMap().tileHeight - 1
                elseif (collSideY == 'bottom') then
                    self.y = yColl * scene:getMap().tileHeight + self.yOffset

                    if (tile) then tile:collect(collSideY) end
                end

                self.dy = 0

                if (not self.onGround) then
                    -- Add bounce effect when collide top
                    if (collSideY == 'bottom') then
                        self.dy = VERTICAL_BOUNCE
                        
                    -- Land player and reset jump if he's jumping
                    elseif (collSideY == 'top') then 
                        self.onGround = true
                        if (self.state == 'jump') then self:resetJump() end
                    end
                end
            else
                self.onGround = false

            end

            -- # Objects Collision
            self:collideObject() 

            -- # Cam Collision
            self:collisionCam()

            self.lastX, self.lastY = self.x, self.y
            -- # Animation update
            self.animation:update(dt)
            self.currentFrame = self.animation:getFrame()
        end, 

        crouch = function(dt)
            if (Keyboard.down('down')) then
                self.animation:animate('crouch')
            else
                self.state = 'raise'
                self:setBody()
                return 
            end

            -- ## Jump
            if (Keyboard.press('up')) then if (self:jump()) then return end end

            -- # Invicibility
            self:invincibilityUpdate(dt)

            -- # Brake
            if (self.dx < 0) then 
                self.dx = self.dx + math.max((BRAKE_SPEED/1.25 + BRAKE_SPEED - self.maxSpeed) * dt, self.dx)
            elseif (self.dx > 0) then 
                self.dx = self.dx - math.min((BRAKE_SPEED/1.25 + BRAKE_SPEED - self.maxSpeed) * dt, self.dx)
            end

            -- # Cap Speed
            self.dx = math.max(math.min(self.dx, MAX_WALK_SPEED), -MAX_WALK_SPEED)

            -- # Gravity
            if (not self.onGround) then self.dy = self.dy + GRAVITY * dt end

            -- # Death Check
            if (self.y > 400) then self:die() end

            -- # Time left
            self.time = math.max(0, self.time - dt)
            if (self.time <= 0) then self:die() end

            if (#self.combos > 0) then self:resetCombo(dt) end

            -- # World Physics update 
            self.x = self.x + self.dx * dt
            local collSideX, xColl = self:collisionX()
            if (collSideX) then 
                if (collSideX == 'left') then
                    self.x = (xColl-1) * scene:getMap().tileWidth - self.xOffset
                elseif (collSideX == 'right') then
                    self.x = xColl * scene:getMap().tileWidth + self.xOffset
                end

                self.dx = 0                    
            end

            self.y = self.y + self.dy * dt
            local collSideY, yColl, tile = self:collisionY()
            if (collSideY) then
                if (collSideY == 'top') then
                    self.y = (yColl - 1) * scene:getMap().tileHeight - 1
                elseif (collSideY == 'bottom') then
                    self.y = yColl * scene:getMap().tileHeight + self.yOffset

                    if (tile) then tile:collect(collSideY) end
                end

                self.dy = 0

                if (not self.onGround) then
                    -- Add bounce effect when collide top
                    if (collSideY == 'bottom') then
                        self.dy = VERTICAL_BOUNCE
                        
                    -- Land player and reset jump if he's jumping
                    elseif (collSideY == 'top') then 
                        self.onGround = true
                        if (self.state == 'jump') then self:resetJump() end
                    end
                end
            else
                self.onGround = false
            end

            -- # Objects Collision
            self:collideObject() 

            -- # Cam Collision
            self:collisionCam()

            self.lastX, self.lastY = self.x, self.y

            -- # Animation update
            self.animation:update(dt)
            self.currentFrame = self.animation:getFrame()
        end, 

        raise = function(dt)
            self.animation:animate('idle')

            if (Keyboard.press('down')) then self:crouch() return end

            -- # Invicibility
            self:invincibilityUpdate(dt)

            local xColl, yColl

            for _, v in ipairs({self.x - self.xOffset, self.x + self.xOffset}) do
                local x, y = scene:getMap():collide(v, self.y - self.yOffset)
                if (x ~= false) then xColl, yColl = x, y end
            end            

            if (xColl) then
                local tileWidth = scene:getMap().tileWidth

                --print(not (scene:getCamera().x < (xColl-3) * tileWidth), scene:getCamera().x, (xColl-3) * tileWidth)

                if ((self.x < (xColl-1) * tileWidth - tileWidth/2 or 
                    not scene:getMap():collide((xColl-2)*tileWidth, (yColl-1)*tileWidth)) and
                    scene:getCamera().x < (xColl-3) * tileWidth) then
                    self.x = self.x - 50 * dt
                else
                    self.x = self.x + 50 * dt
                end
            else
                self.state = 'walk'
            end

            -- # Death Check
            if (self.y > 400) then self:die() end

            -- # Time left
            self.time = math.max(0, self.time - dt)
            if (self.time <= 0) then self:die() end

            if (#self.combos > 0) then self:resetCombo(dt) end

            -- # Objects Collision
            self:collideObject() 

            -- # Cam Collision
            self:collisionCam()

            self.lastX, self.lastY = self.x, self.y

            -- # Animation update
            self.animation:update(dt)
            self.currentFrame = self.animation:getFrame()
        end,

        -- FIXME JUMP
        jump = function(dt)
            if (self.lastState == 'crouch') then  self.animation:animate('crouch')
            else self.animation:animate('jump') end

            -- # Input
            -- # Add spring to the jump until key release
            if (self.canSpring and Keyboard.down('up')) then
                self.spring = self.spring - GRAVITY * dt
                self.dy = self.dy - self.spring * dt
            end

            -- ## Spring
            if (not Keyboard.down('up') and self.canSpring) then self.canSpring = false end

            -- ## Shoot fire ball
            if (Keyboard.press('x')) then self:shootFire() end

            -- ## Flying movement
            if (Keyboard.down('left')) then
                self.dx = self.dx - self.speed * dt
            elseif (Keyboard.down('right')) then
                self.dx = self.dx + self.speed * dt
            end

            -- # Invicibility
            self:invincibilityUpdate(dt)

            -- # Brake
            if (self.dx < 0) then 
                self.dx = self.dx + math.max(BRAKE_SPEED * dt, self.dx)
            elseif (self.dx > 0) then 
                self.dx = self.dx - math.min(BRAKE_SPEED * dt, self.dx)
            end

            -- # Cap speed
            self.dx = math.max(math.min(self.dx, self.maxSpeed), -self.maxSpeed)

            -- # Gravity
            self.dy = self.dy + GRAVITY * dt

            -- # Death Check
            if (self.y > 400) then self:die() end

            -- # Time left
            self.time = math.max(0, self.time - dt)
            if (self.time <= 0) then self:die() end

            if (#self.combos > 0) then self:resetCombo(dt) end

            -- # World Physics update 
            self.x = self.x + self.dx * dt
            local collSideX, xColl = self:collisionX()
            if (collSideX) then 
                if (collSideX == 'left') then
                    self.x = (xColl-1) * scene:getMap().tileWidth - self.xOffset
                elseif (collSideX == 'right') then
                    self.x = xColl * scene:getMap().tileWidth + self.xOffset
                end

                self.dx = 0                    
            end

            self.y = self.y + self.dy * dt
            local collSideY, yColl, tile = self:collisionY()
            if (collSideY) then
                if (collSideY == 'top') then
                    self.y = (yColl - 1) * scene:getMap().tileHeight - 1
                elseif (collSideY == 'bottom') then
                    self.y = yColl * scene:getMap().tileHeight + self.yOffset

                    if (tile) then tile:collect(collSideY) end
                end

                self.dy = 0

                if (not self.onGround) then
                    -- Add bounce effect when collide top
                    if (collSideY == 'bottom') then
                        self.dy = VERTICAL_BOUNCE
                        
                    -- Land player and reset jump if he's jumping
                    elseif (collSideY == 'top') then 
                        self.onGround = true
                        if (self.state == 'jump') then self:resetJump() end
                    end
                end
            else
                self.onGround = false

            end

            -- # Objects Collision
            self:collideObject() 

            -- # Cam Collision
            self:collisionCam()

            self.lastX, self.lastY = self.x, self.y

            -- # Animation update
            self.animation:update(dt)
            self.currentFrame = self.animation:getFrame()
        end, 

        death = function(dt)
            self.deathTimer = self.deathTimer - dt

            if (self.deathTimer < 0) then
                -- # Physics update 
                self.dy = self.dy + GRAVITY/2 * dt
                self.y = self.y + self.dy * dt

                if (self.y > 2250) then 
                    if (scene:getMap().custom) then 
                        scene:setEvent('nextmap', {name=scene:getMap().loadname, lifescreen=true, custom=true}) 
                    else scene:setEvent('nextmap', {name=scene:getMap().worldlevel..'-'..scene:getMap().stage, lifescreen=true}) end
                end
            end
        end,

        powerdown = function(dt)
            self.animation:animate('powerdown')
            self.powerDownTimer = self.powerDownTimer + dt * 7

            if (self.powerDownTimer > 1) then
                self.life = math.floor(self.powerDownTimer)%2 + 1
                self:setBody()
            end

            if (self.powerDownTimer > 5.5) then
                if (self.life ~= 1) then 
                    self.life = 1 
                    self:setBody() 
                end
    
                self.powerDownTimer = nil
                self.state = self.lastState
                self.dx, self.dy = self.lastDx, self.lastDy
            end
        end, 

        powerup = function(dt)
            -- # Invicibility
            self:invincibilityUpdate(dt)

            self.animation:animate('powerup')
            print(self.powerUpTimer)
            self.powerUpTimer = self.powerUpTimer + dt * 10

            self.life = math.floor(self.powerUpTimer)%2 + 1
            self:setBody()

            if (self.powerUpTimer > 10) then
                if (self.life ~= 2) then 
                    self.life = 2
                    self:setBody(2) 
                end

                local collSideY, yColl, tile = self:collisionY()

                if (collSideY == 'bottom') then
                    if (scene:getMap():collide(self.x, self.y + 1)) then self.state = 'raise' return end

                    self.y = self.y + 75 * dt
                    self.dy = 0
                    
                    if (tile) then tile:collect(collSideY) end
                else
                    self.powerUpTimer = nil
                    self.state = self.lastState
                    self.dx, self.dy = self.lastDx, self.lastDy
                    self.dy = VERTICAL_BOUNCE
                end
            end            
        end, 

        fireup = function(dt)
            -- # Invicibility
            self:invincibilityUpdate(dt)

            self.powerUpTimer = self.powerUpTimer + dt * 10

            local frame = math.floor(self.powerUpTimer)%4 + 1
            self.effectFrame = fireUpEffect[frame]

            if (self.powerUpTimer > 10) then
                self.animation:pause(false)

                self.effectFrame = 42

                self.powerUpTimer = nil
                self.state = self.lastState
                self.dx, self.dy = self.lastDx, self.lastDy
            end
        end, 

        wait = function(dt)
            -- # Invicibility
            self:invincibilityUpdate(dt)
        end, 

        autowalk = function(dt)
            if (self.walkDuration ~= -1 and self.walkTime) then
                self.walkTime = self.walkTime + dt

                if (self.walkTime > self.walkDuration) then
                    self.speed = 0

                    if (self.dx == 0) then 
                        self.state = self.lastState
                        self.lastState = ''
                        self.walkDuration, self.walkTime = nil, nil

                        if (self.walkFunc) then self.walkFunc() end
                    end
                end
            else
                self.maxSpeed = 55
            end

            self.animation:animate('walk')
            self.animation:slow(1 + math.max(0, 1 - math.abs(self.speed)/100))

            self.dx = self.dx + self.speed * dt
            
    
            -- # Invicibility
            self:invincibilityUpdate(dt)

            -- # Brake
            if (self.dx < 0) then 
                self.dx = self.dx + math.max(BRAKE_SPEED * dt, self.dx)
            elseif (self.dx > 0) then 
                self.dx = self.dx - math.min(BRAKE_SPEED * dt, self.dx)
            end

            -- # Cap speed
            self.dx = math.max(math.min(self.dx, self.maxSpeed), -self.maxSpeed)

            -- # Gravity
            self.dy = self.dy + GRAVITY * dt

            -- # World Physics update 
            self.x = self.x + self.dx * dt
            local collSideX, xColl = self:collisionX()
            if (collSideX) then 
                if (collSideX == 'left') then
                    self.x = (xColl-1) * scene:getMap().tileWidth - self.xOffset
                elseif (collSideX == 'right') then
                    self.x = xColl * scene:getMap().tileWidth + self.xOffset
                end

                self.dx = 0                    
            end

            self.y = self.y + self.dy * dt
            local collSideY, yColl, tile = self:collisionY()
            if (collSideY) then
                if (collSideY == 'top') then
                    self.y = (yColl - 1) * scene:getMap().tileHeight - 1
                elseif (collSideY == 'bottom') then
                    self.y = yColl * scene:getMap().tileHeight + self.yOffset

                    if (tile) then tile:collect(collSideY) end
                end

                self.dy = 0

                if (not self.onGround) then
                    -- Add bounce effect when collide top
                    if (collSideY == 'bottom') then
                        self.dy = VERTICAL_BOUNCE
                        
                    -- Land player and reset jump if he's jumping
                    elseif (collSideY == 'top') then 
                        self.onGround = true
                        if (self.state == 'jump') then self:resetJump() end
                    end
                end
            else
                self.onGround = false

            end

            -- # Objects Collision
            self:collideObject() 

            -- # Cam Collision
            self:collisionCam()

            self.lastX, self.lastY = self.x, self.y

            -- # Animation update
            self.animation:update(dt)
            self.currentFrame = self.animation:getFrame()
        end, 

        autojump = function(dt)
            -- # Jump animation
            self.animation:animate('jump')

            -- # Invicibility
            self:invincibilityUpdate(dt)

            -- -- # Brake
            -- if (self.dx < 0) then 
            --     self.dx = self.dx + math.max(BRAKE_SPEED * dt, self.dx)
            -- elseif (self.dx > 0) then 
            --     self.dx = self.dx - math.min(BRAKE_SPEED * dt, self.dx)
            -- end

            -- -- # Cap speed
            -- self.dx = math.max(math.min(self.dx, self.maxSpeed), -self.maxSpeed)

            self.dx = self.dx + MAX_WALK_SPEED/2 * self.jumpDir * dt

            -- # Gravity
            self.dy = self.dy + GRAVITY * dt

            -- # World Physics update 
            self.x = self.x + self.dx * dt
            local collSideX, xColl = self:collisionX()
            if (collSideX) then 
                if (collSideX == 'left') then
                    self.x = (xColl-1) * scene:getMap().tileWidth - self.xOffset
                elseif (collSideX == 'right') then
                    self.x = xColl * scene:getMap().tileWidth + self.xOffset
                end

                self.dx = 0                    
            end

            self.y = self.y + self.dy * dt
            local collSideY, yColl, tile = self:collisionY()
            if (collSideY) then
                if (collSideY == 'top') then
                    self.y = (yColl - 1) * scene:getMap().tileHeight - 1
                elseif (collSideY == 'bottom') then
                    self.y = yColl * scene:getMap().tileHeight + self.yOffset

                    if (tile) then tile:collect(collSideY) end
                end

                self.dy = 0

                if (not self.onGround) then
                    -- Add bounce effect when collide top
                    if (collSideY == 'bottom') then
                        self.dy = VERTICAL_BOUNCE
                        
                    -- Land player and reset jump if he's jumping
                    elseif (collSideY == 'top') then 
                        self.onGround = true
                        self:setWalk(1, 235, nil, nil, nil, 45)
                        self.jumpDir = nil
                    end
                end
            else
                self.onGround = false

            end

            -- # Objects Collision
            self:collideObject() 

            self.lastX, self.lastY = self.x, self.y

            -- # Animation update
            self.animation:update(dt)
            self.currentFrame = self.animation:getFrame()
        end,

        flagdown = function(dt)
            -- # Invicibility
            self:invincibilityUpdate(dt)

            self.y = self.y + self.dy * dt
            local collSideY, yColl = self:collisionY()
            if (collSideY) then
                if (collSideY == 'top') then
                    self.y = (yColl - 1) * scene:getMap().tileHeight - 1
                    self.animation:setFrame(1)
                    self.animation:pause()
                end

                self.dy = 0
            end

            -- # Animation update
            self.animation:update(dt)
            self.currentFrame = self.animation:getFrame()
        end, 

        pipe = function(dt)
            self.pipeTimer = self.pipeTimer + dt

            -- # Horizontal enter
            if (self.dx ~= 0) then 
                if (self.dx > 0) then self.dx = self.dx + 125 * dt
                else  self.dx = self.dx - 125 * dt end

                if (self.pipeTimer > 0.5 and self.destination) then self.dx = 0 end

                self.x = self.x + math.max(-30, math.min(30, self.dx * dt))

                -- # Adapt the player to the pipe height
                if (math.abs(self.dx) > 55 and math.abs(self.dx) < 60) then
                    self.y = self.y - 1
                    self.sy = 0.5
                end

            -- # Vertical enter
            elseif (self.dy ~= 0) then
                if (self.pipeTimer > 1 and self.destination) then self.dy = 0
                else
                    if (self.dy > 0) then self.dy = self.dy + 125 * dt
                    else self.dy = self.dy - 125 * dt end
                end

                self.y = self.y + math.max(-65, math.min(65, self.dy * dt))
            end

            if (self.pipeTimer > 2 and self.destination) then
                scene:setEvent('nextmap', {name=self.destination.map, lifescreen=self.destination.screen or false, x=self.destination.x or nil, y=self.destination.y or nil, state='pipe'})

                self.destination = nil
                self.pipeTimer = 0
            elseif (self.destination == nil) then
                if (self.lastState == 'pipe-none') then
                    self:pipeExit()
                elseif (self.lastState == 'pipe-bottom') then
                    scene:getMap():updateDepth(self, 0)

                    if (self.dy == 0) then 
                        self.dy = -1 
                        self.animation:animate('idle')
                        SFX.PIPE_SND:stop()
                        SFX.PIPE_SND:play()
                    end

                    local pipeTile = scene:getMap():getTile(scene:getMap():pixelToTile(self.x - self.xOffset, self.y))

                    print(pipeTile, self.pipeTimer > 1.01, pipeTile ~= 74 and pipeTile ~= 6 and pipeTile ~= 92 and pipeTile ~= 24 and pipeTile ~= 113 and pipeTile ~= 45 and pipeTile ~= 118 and pipeTile ~= 50 and pipeTile ~= 123 and pipeTile ~= 55)
                    if (self.pipeTimer > 1.01 and (pipeTile ~= 74 and pipeTile ~= 6 and pipeTile ~= 92 and pipeTile ~= 24 and pipeTile ~= 113 and pipeTile ~= 45 and pipeTile ~= 118 and pipeTile ~= 50 and pipeTile ~= 123 and pipeTile ~= 55)) then
                        self.dy = 0
                        self.dx = 0
                        if (self.pipeTimer > 1.05) then self:pipeExit() return end
                    end
                elseif (self.lastState == 'pipe-left') then 
                    print('left')

                    scene:getMap():updateDepth(self, 0)
                end

                
            end

            self.animation:update(dt)
            self.currentFrame = self.animation:getFrame()
        end
    }

    self:setBody()
end


-- # ANCHOR Moving Management
function Player:move(map, x, y, state)
    self:reset()

    if (x and y) then self.x, self.y = x * map.tileWidth, y * map.tileHeight
    else
        assert(map.spawn[1], 'Aucune coordonnée de spawn rentrer dans la map ' .. map.worldlevel .. '-' .. map.stage) 
        self.x, self.y = map.spawn[1] * map.tileWidth, map.spawn[2] * map.tileHeight - 1 
    end

    if (state) then
        self.state = state
    else
        self.state = 'walk'
    end
end

function Player:reset()
    -- Reset Life & Up when player dies
    if (self.lastState == 'death') then
        --print('reset death')
        self.life = 1
        
        if (self.up < 1) then
            self.score = 0 
            self.coins = 0        
        end

        self.lastState = ''
    end

    self.dx, self.dy = 0, 0
    self.sx, self.sy = 1, 1
    self.direction = 1
    self:setBody()
    scene:getMap():updateDepth(self, 5)
    self.currentFrame = 1
    self.animation:slow(1)
    self.collisionType = 'trigger'
    self.fireball = {}
    self.speed = WALK_SPEED
    self.maxSpeed = MAX_WALK_SPEED
end

-- # ANCHOR State Management
function Player:jump()
    if (self.onGround) then
        -- # Play Sound
        SND_JUMP:stop()
        SND_JUMP:play()

        if (self.maxSpeed == MAX_RUN_SPEED) then 
            self.spring = JUMP_SPRING_RUN
        elseif (self.maxSpeed == MAX_WALK_SPEED) then
            if (self.dx == 0) then self.spring = JUMP_SPRING_IDLE
            else self.spring = JUMP_SPRING_WALK end
        end

        self.canSpring = true
        self.dy = -JUMP_STRENGTH

        self.lastState = self.state
        self.state = 'jump'

        return true
    end

    return false
end

function Player:setJump(xForce, yForce, dir, jumpdir)
    self.dy = yForce
    self.dx = xForce
    self.direction = dir
    self.jumpDir = jumpdir
    self.state = 'autojump'
end

function Player:resetJump()
    if (self.lastState == 'crouch') then self.state = 'crouch'
    else  self.state = 'walk' end   
    self.lastState = ''
    self.spring = 0
end


function Player:setWalk(dir, speed, duration, state, func, maxspeed)
    self.direction = dir or 1
    self.speed = speed or WALK_SPEED
    self.maxSpeed = maxspeed or MAX_WALK_SPEED
    self.walkDuration = duration or -1
    self.walkTime = 0
    self.lastState = state or 'walk'
    self.state = 'autowalk'
    self.walkFunc = func or nil
end



function Player:crouch()
    self.state = 'crouch'
    self:setBody(3)
end

function Player:die()
    if (self.state == 'death') then return end 

    love.audio.stop()
    SND_DEATH:play()
    self.state = 'death'
    self.lastState = 'death'
    self.collisionType = 'none'
    self.dy = -200
    self.deathTimer = 1
    self.animation:animate('die')
    self.currentFrame = self.animation:getFrame()
    self.up = self.up - 1 
end

function Player:flagged(speed)
    scene:getCamera():setType('nomove')
    self.animation:animate('flag-down')
    self.state = 'flagdown'
    self.dx = 0
    self.dy = speed
    self.direction = 1
end

function Player:flagJump()
    MUSICS.STAGE_CLEAR_SND:play()
    --scene:getCamera():setType('classic')
    scene:getPlayer():setJump(75, -80, -1, 1)
    scene:getCamera():slide(1, 55, scene:getMap().mapWidthPixel - virtualWidth)
    if (self.life == 1) then self.yOffset = marioAttribute[1].yOffset
    elseif (self.life > 1) then self.yOffset = marioAttribute[2].yOffset end
end

function Player:pipeTravel(map, direction)
    self.state = 'pipe'
    scene:getMap():updateDepth(self, 0)
    self.pipeTimer = 0
    self.direction = 1
    self.destination = map
    local exit = map.exit or 'none'
    self.lastState = 'pipe-' .. exit
    --print(self.lastState)

    if (direction == 'v') then
        self.dx = 0
        self.dy = 20
        self.animation:animate('idle')
    elseif (direction == 'h') then
        self.dx = 20
        self.dy = 0
        self.animation:animate('walk')
    end
end

function Player:pipeExit()
    self.lastState = ''
    self.pipeTimer = nil
    self.dx = 0
    self.state = 'walk'
    scene:getMap():updateDepth(self, 5)
end

-- # ANCHOR Collision Management
function Player:setBody(size)
    local size = size or self.life

    if (self.life == 3 and self.state ~= 'crouch') then 
        size = 2 
    end

    -- Switch mario size
    if (marioAttribute[size] and marioAttribute[size].h ~= self.h) then

        if (size <= 2) then
            self.atlas = MARIO_ATLAS[size]
            self.spriteQuads = MARIO_QUADS[size]
            self.animation = animations[size]
        end

        for k, v in pairs(marioAttribute[size]) do
            self[k] = v
        end

        self.effectFrame = 0
    end

    if (self.life == 3) then self.effectFrame = 42 end
end

function Player:collisionX()
    -- # Corners detection /!\ Depend on the object size
    local xCoord, yCoord

    if (self.h > 16) then xCoord, yCoord = {self.x - self.xOffset, self.x + self.xOffset - 1}, {self.y - self.yOffset, self.y - self.yOffset/2, self.y}
    else xCoord, yCoord = {self.x - self.xOffset, self.x + self.xOffset - 1}, {self.y - self.yOffset, self.y} end

    for side, xPos in ipairs(xCoord) do
        for _, yPos in ipairs(yCoord) do
            local xColl = scene:getMap():collide(xPos, yPos)
            if (xColl) then return COLLISIONSIDEX[side], xColl end
        end
    end
    
    return false
end

function Player:collisionY()
    -- # Corners detection /!\ Depend on the object size
    local xCoord, yCoord

    if (self.dy == 0) then xCoord, yCoord = {self.x, self.x - self.xOffset, self.x + self.xOffset - 1}, {self.y - self.yOffset, self.y + 1}
    else xCoord, yCoord = {self.x, self.x - self.xOffset, self.x + self.xOffset - 1}, {self.y - self.yOffset, self.y} end

    for side, yPos in ipairs(yCoord) do
        for _, xPos in ipairs(xCoord) do
            local xColl, yColl, iTile = scene:getMap():collide(xPos, yPos)
            if (yColl) then return COLLISIONSIDEY[side], yColl, iTile, xColl end
        end
    end

    return false
end

function Player:collideObject()
    local colls = scene:getMap():collideObject(self)

    for i=1, #colls do
        local object, side = colls[i][1], colls[i][2]

        if (object.collisionType == 'rigid') then
            local map = scene:getMap()

            if (side == 'left') then
                self.x = object.x - map.tileWidth/2 - self.xOffset
                self.dx = 0
            elseif (side == 'right') then
                self.x = object.x + map.tileWidth/2 + self.xOffset
                self.dx = 0
            elseif (side == 'bottom') then 
                self.y = math.ceil(object.y/map.tileWidth) * map.tileHeight + self.yOffset
                self.dy = VERTICAL_BOUNCE 
            elseif (side == 'top') then
                self.y = (math.ceil(object.y/map.tileWidth) - 1) * map.tileHeight - 1
                self.dy = 0
                if (self.state == 'jump') then self:resetJump() end
            end            
        end

        --print(object)
        if (object.collisionType == 'trigger') then object:collect(side) end
    end
end

function Player:collisionCam()
    local camX, mapW = scene:getCamera().x, scene:getMap().mapWidthPixel 
    if (self.x - self.xOffset < camX) then
        self.x = camX + self.xOffset
        self.dx = 0
    elseif (self.x + self.xOffset > mapW) then
        self.x = mapW - self.xOffset
        self.dx = 0
    end
end

-- # ANCHOR Bonus Management
function Player:invicible(type) -- REVIEW 
    self.effectTimer = 0
    self.invincibility = type

    if (self.invincibility == 2) then 
        self.invincibilityTimer = 18
        MUSICS.STARMAN_SND:play()
        MUSICS.OVERWORLD_SND:stop()
    elseif (self.invincibility == 1) then
        self.invincibilityTimer = 4
    end
end

function Player:invincibilityUpdate(dt) -- REVIEW 
    if (self.invincibility) then
        self.effectTimer = self.effectTimer + dt * 10
        self.invincibilityTimer = self.invincibilityTimer - dt

        if (self.invincibility == 2) then
            local frame = math.floor(self.effectTimer)%4 + 1
            self.effectFrame = invincibilityEffect[math.min(2, self.life)][frame]
        elseif (self.invincibility == 1) then
            if (self.effectTimer > 2) then self.effectTimer = 0 end
            self.alpha = math.floor(self.effectTimer)
        end

        if (self.invincibilityTimer < 0) then 
            if (self.invincibility == 2) then 
                MUSICS.STARMAN_SND:stop()
                MUSICS.OVERWORLD_SND:play()
            end

            self.effectTimer = nil
            self.alpha = 1 
            self.invincibility = false

            if (self.life == 3) then self.effectFrame = 42
            else self.effectFrame = 0 end
        end
    end
end

function Player:shootFire()
    if (self.life == 3 and #self.fireball < 2) then
        self.animation:animate('shoot')
        table.insert(self.fireball, true)

        if (self.direction > 0) then
            scene:getMap():addWorld(Ball_OBJ(self.x + self.xOffset + 4, self.y - self.yOffset/2, 1))
        else
            scene:getMap():addWorld(Ball_OBJ(self.x - self.xOffset - 4, self.y - self.yOffset/2, -1))
        end
    end
end

-- FIXME 
function Player:powerUp()
     -- # Avoid multiple powerup
    if (self.life == 3 or self.state == 'powerup') then return end

    -- # Save last speed & state
    self.lastDx, self.lastDy = self.dx, self.dy
    self.dx, self.dy = 0, 0

    self.lastState = self.state



    self.life = math.min(3, self.life + 1)
    self:setBody(2)

    self.powerUpTimer = 0

    if (self.state == 'powerdown') then 
        self.lastState = 'walk'
        self.life = 2
    end

    if (self.life == 2) then 
        self.state = 'powerup'
    elseif (self.life == 3) then 
        self.animation:pause() 
        self.state = 'fireup' 
    end
end

function Player:powerDown()
    -- # Avoid multiple powerdown
    if (self.invincibility or self.state == 'powerdown') then return end

    -- # Save last speed & state
    self.lastDx, self.lastDy = self.dx, self.dy
    self.dx, self.dy = 0, 0

    if (self.state == 'fireup' or self.state == 'powerup') then self.lastState = 'jump'
    elseif (self.state == 'raise') then self.lastState = 'walk'
    else self.lastState = self.state end
    
    -- # Apply down life
    if (self.life - 1 > 0) then
        SND_POWERDOWN:stop()
        SND_POWERDOWN:play()
        self.life = 0
        self.powerDownTimer = 0
        self.state = 'powerdown'
        self:invicible(1)
        self.effectFrame = 0
    else self:die() end
end

-- # ANCHOR Combo Management
-- REVIEW All combos 
function Player:addCombo(type)
    --print('Combo add ' .. type)
    self.combos[#self.combos + 1] = type
end

function Player:resetCombo(dt)
    self.timerCombo = self.timerCombo + dt
    

    if (self.timerCombo > 0.75) then
        --printprint('combo reset')
        for i=#self.combos, 1, -1  do
            table.remove(self.combos, i)
        end
        self.timerCombo = 0
    end
end


-- # ANCHOR Stats Management
function Player:addUp()
    self.up = self.up + 1
end

function Player:addCoin(count)
    local count = count or 1
    self.coins = self.coins + count

    if (self.coins == 100) then
        self.coins = 0
        self.up = self.up + 1
        SFX.ONE_UP_SND:stop()
        SFX.ONE_UP_SND:play()
    end
end

function Player:addScore(score, source, type)
    if (source) then
        if (#self.combos > 0) then
            --print('combo gestion')
            local c = 0

            for i=1, #self.combos do
                if (self.combos[i] == type) then
                    c = c + 1
                end
            end

            if (c > 0) then 
                if (c > #COMBOS[type]) then c = #COMBOS[type] self.up = self.up + 1
                else self.score = self.score + COMBOS[type][c] end 
                self.timerCombo = 0
                --print('reset timer')
                scene:getHud():addScore(COMBOS[type][c], source.x, source.y - source.yOffset) 
            end
        else
            --print('no combo')
            self.score = self.score + score
            scene:getHud():addScore(score, source.x, source.y - source.yOffset) 
        end
    else
        self.score = self.score + score
    end
end

function Player:update(dt)
    if (Keyboard.press('a')) then self:powerUp()
    elseif (Keyboard.press('z')) then self:powerDown() 
    elseif (Keyboard.press('d')) then 
        local j = 0
        print('ACTUAL GLOBALS ENTRIES : \n')
        for k, v in pairs(_G) do
            j = j + 1
            print('\t', k, v)
        end    

        print('\n####### Total entries : ' .. j)
    elseif (Keyboard.press('t')) then scene:setEvent('gameEnd', {name='1-Titlescreen', lifescreen=false})
    end

    self.behaviours[self.state](dt)
end

function Player:render()
    if (self.debug) then 
        love.graphics.setColor(0,0,0, 0.5)
        love.graphics.rectangle('fill', math.floor(self.x - self.xOffset), math.floor(self.y - self.yOffset), self.w, self.h)
    end

    love.graphics.setColor(1,1,1,self.alpha)
    love.graphics.draw(self.atlas, self.spriteQuads[self.currentFrame + self.effectFrame], 
                       math.floor(self.x), math.floor(self.y),
                       self.r, self.sx * self.direction, self.sy,
                       self.xOffset + self.xMargin, self.yOffset + self.yMargin)
    love.graphics.setColor(1,1,1)

    if (self.state == 'titlescreen') then
        love.graphics.draw(HUD_ATLAS, HUD_QUADS[4], 60, 145 + (self.numberPlayer-1) * 16)

        love.graphics.print('1 PLAYER GAME', virtualWidth/2 - default_font:getWidth('1 PLAYER GAME')/2, 144)
        love.graphics.print('2 PLAYER GAME', virtualWidth/2 - default_font:getWidth('2 PLAYER GAME')/2, 160)

        love.graphics.print('TOP-', 84, 184)
        love.graphics.print(string.rep('0', 6 - tostring(self.highscore):len()) .. self.highscore, 124, 184)
    end

    if (self.debug) then 
        love.graphics.setColor(0,1,0,0.9)
        love.graphics.rectangle('fill', math.floor(self.x), math.floor(self.y - self.yOffset), 1, 1)
        love.graphics.rectangle('fill', math.floor(self.x - self.xOffset), math.floor(self.y - self.yOffset), 1, 1)
        love.graphics.rectangle('fill', math.floor(self.x + self.xOffset - 1), math.floor(self.y - self.yOffset), 1, 1)

        love.graphics.rectangle('fill', math.floor(self.x - self.xOffset), math.floor(self.y - self.yOffset/2), 1, 1)
        love.graphics.rectangle('fill', math.floor(self.x + self.xOffset - 1), math.floor(self.y - self.yOffset/2), 1, 1)

        love.graphics.rectangle('fill', math.floor(self.x - self.xOffset), math.floor(self.y), 1, 1)
        love.graphics.rectangle('fill', math.floor(self.x + self.xOffset - 1), math.floor(self.y), 1, 1)
        love.graphics.setColor(1,1,1,1)
    end
end

return Player
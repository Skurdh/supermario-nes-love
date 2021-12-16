--[[
TODO :
    - Push
    - Bug avec grand mario et collision
    - Bug détection collision

FIXME :
    - Creer des règles pour le pushable et le debugué
        - Push uniquement dans certaines conditions définir des règles de quand ça arrive
        - Push pas à droite si joueur se déplace vers la droite
        - push player to the left or right of the interactive tile
]]--

-- local Player = Class:extend('Player')

-- local Animation = require('lib.Animation')
-- local Ball_OBJ = require('lib.Objects.FireBall')

-- -- ## Constant
-- local WALK_SPEED, MAX_WALK_SPEED = 300, 116
-- local RUN_SPEED, MAX_RUN_SPEED = 400, 154
-- local BRAKE_SPEED = 220
-- local JUMP_STRENGTH, JUMP_SPRING_IDLE, JUMP_SPRING_WALK, JUMP_SPRING_RUN = 190, 1072, 1080, 1166
-- local PUSH_STRENGTH = 35
-- local MAX_LIFE = 2
-- local VERTICAL_BOUNCE = 35

-- local COMBOS = {
--     crush = {500, 800, 1000, 2000, 4000, 5000, 8000, 3679}
-- }

-- -- ## Audios
-- local SND_STARMAN = love.audio.newSource('assets/musics/starman.mp3', 'stream')
-- local SND_JUMP = love.audio.newSource('assets/sfx/jump_small.wav', 'static')
-- local SND_DEATH = love.audio.newSource('assets/sfx/mariodie.wav', 'static')
-- local SND_POWERDOWN = love.audio.newSource('assets/sfx/pipe.wav', 'static')

-- -- ## Graphics & Animation
-- -- # // [1]: small, [2]: big, [3]: fire
-- -- # // [4]: invincibility 1, [5]: invincibility 2 (OW), [6]: invincibility 3 (OW), [7]: invincibility 2 (UG), [8]: invivibility 2 (CASTEL)
-- -- # // [9]: invivibility 3 (UG/CASTEL), [10]: invivibility 2 (UW), [11]: invivibility 3 (UW)
-- local marioAttribute, spriteQuads, animations = {}, {}, {}, {}

-- -- # // Small
-- marioAttribute[1] = {
--     w = 12, h = 15, 
--     xOffset = 6, yOffset = 14,
--     xMargin = 2, yMargin = 0
-- }

-- animations[1] = Animation()
-- animations[1]:add('idle', 1, {1})
-- animations[1]:add('walk', 14, {2, 3, 4})
-- animations[1]:add('slide', 1, {5})
-- animations[1]:add('jump', 1, {6})
-- animations[1]:add('die', 1, {7})
-- animations[1]:add('hang', 1, {8})
-- animations[1]:add('flag-down', 4, {9, 8})
-- animations[1]:add('swim', 10, {10, 11, 12, 13, 14})
-- animations[1]:add('powerdown', 1, {11})
-- animations[1]:add('powerup', 1, {1})

-- -- # // Big
-- marioAttribute[2] = {
--     w = 12, h = 31, 
--     xOffset = 6, yOffset = 30,
--     xMargin = 2, yMargin = 0
-- }

-- animations[2] = Animation()
-- animations[2]:add('idle', 1, {1})
-- animations[2]:add('walk', 14, {2, 3, 4})
-- animations[2]:add('slide', 1, {5})
-- animations[2]:add('jump', 1, {6})
-- animations[2]:add('crouch', 1, {7})
-- animations[2]:add('shoot', 5, {2}, false)
-- animations[2]:add('hang', 1, {8})
-- animations[2]:add('flag-down', 4, {9, 8})
-- animations[2]:add('swim', 10, {10, 11, 12, 13, 14, 15})
-- animations[2]:add('powerdown', 3, {6, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11})
-- animations[2]:add('powerup', 7, {16, 16, 1, 1, 1})

-- local invincibilityEffect = {
--     {42, 56, 70, 0},
--     {63, 84, 105, 0}
-- }

-- local fireUpEffect = {
--     84, 42, 105, 63
-- }

-- function Player:new()
--     -- # Positions & Dimensions
--         self.x, self.y = 0, 0
--         self.w, self.h = 0, 0
--         self.sx, self.sy = 1, 1
--         self.xOffset, self.yOffset = 0, 0
--         self.xMargin, self.yMargin = 0, 0
--         self.r = 0
--     self.noCollision = {'Mushroom', 'FirePlant', 'Goomba', 'Koopa', 'FireBall'}

--     -- # Movements
--     self.dx, self.dy = 0, 0
--     self.lastDx, self.lastDy = 0, 0
--     self.direction = 1
--     self.speed = WALK_SPEED
--     self.maxSpeed = MAX_WALK_SPEED
--     self.spring = 0
--     self.canSpring = true
--     self.onGround = false
--     self.collisionType = 'trigger'

--     -- # Draw
--     self.atlas = nil
--     self.spriteQuads = nil
--     self.alpha = 1
--     self.depth = 5
--     self.animation = nil
--     self.currentFrame = 0
--     self.effectFrame = 0

--     -- # Stats
--     self.characterName = 'Mario'
--     self.life = 1
--     self.bonus = 0
--     self.up = 3
--     self.time = nil
--     self.score = 0
--     self.last_score = 0
--     self.coins = 0
--     self.state = 'idle'
--     self.lastState = 'idle'
--     self.invincibility = false
--     self.invincibilityTimer = 0
--     self.up = 3
--     self.numberPlayer = 1
--     self.fireball = {}
--     self.combos = {}
--     self.timerCombo = 0

--     -- # Timer
--     self.powerTimer = 0 -- TODO Se question sur mettre une variable pour les timers ou non ?
 
--     self.debug = 0


--     -- # Behaviours
--     self.behaviours = {
--         -- Template state
--         template = function(dt)
--             -- Animate 
--             -- Keybord entry
        
--             -- Gravity
--         end,

--         -- # Title screen
--         titlescreen = function(dt)
--             self.animation:animate('idle')

--             if (Keyboard.press('down')) then
--                 self.numberPlayer = math.min(2, self.numberPlayer + 1)
--             elseif (Keyboard.press('up')) then
--                 self.numberPlayer = math.max(1, self.numberPlayer - 1)
--             elseif (Keyboard.press('x')) then
--                 scene:setEvent('nextmap', {name='1-1', lifescreen=true})
--             end
--         end,
        
--         -- Debug state
--         debug = function(dt)
--             self.animation:animate('idle')
--             self.dx = 0
--             self.dy = 0

--             if (Keyboard.down('left')) then
--                 self.dx = -MAX_WALK_SPEED
--                 self.collision = 'left'
--             elseif Keyboard.down('right') then
--                 self.dx = MAX_WALK_SPEED
--                 self.collision = 'right'
--             end

--             if (Keyboard.down('up')) then
--                 self.dy = -MAX_WALK_SPEED
--                 self.collision = 'top'
--             elseif Keyboard.down('down') then
--                 self.collision = 'bot'
--                 self.dy =MAX_WALK_SPEED
--             end

--             if (Keyboard.press('kp+')) then
--                 MAX_WALK_SPEED = MAX_WALK_SPEED + 10
--             elseif (Keyboard.press('kp-')) then
--                 MAX_WALK_SPEED = MAX_WALK_SPEED - 10
--             end 
--         end,

        -- -- # Idle state
        -- idle = function(dt)
        --     self.animation:animate('idle')

        --     -- Will move
        --     if (Keyboard.down('left') or Keyboard.down('right')) then self.state = 'walk' end
            
        --     -- Will jump
        --     if (Keyboard.press('up')) then self:jump() end

        --     -- Shoot fire ball
        --     if (Keyboard.press('x')) then self:shootFire() end

        --     -- Gravity
        --     if (not self.onGround) then self.dy = self.dy + GRAVITY * dt end
        -- end, 

        -- -- # Walk state
        -- walk = function(dt)
        --     self.animation:animate('walk')
        --     if (self.dy > 10 or self.dy < -10) then 
        --         self.animation:pause()
        --     else self.animation:pause(true) end

        --     -- Shoot fire ball
        --     if (Keyboard.press('x')) then self:shootFire() end

        --     -- Walk / Run
        --     if (Keyboard.down('x') and self.maxSpeed ~= MAX_RUN_SPEED) then 
        --         self.speed, self.maxSpeed = RUN_SPEED, MAX_RUN_SPEED
        --         self.animation:slow(0.60)
        --     elseif (not Keyboard.down('x') and self.maxSpeed ~= MAX_WALK_SPEED) then
        --         self.speed, self.maxSpeed = WALK_SPEED, MAX_WALK_SPEED
        --         self.animation:slow(1)
        --     end

        --     if (Keyboard.down('left')) then
        --         self.direction = -1 
        --         self.dx = self.dx - self.speed * dt

        --         if (self.dx > self.maxSpeed*0.15) then self.animation:animate('slide')
        --         else self.animation:animate('walk') end

        --     elseif (Keyboard.down('right')) then
        --         self.direction = 1
        --         self.dx = self.dx + self.speed * dt

        --         if (self.dx < -self.maxSpeed*0.15) then self.animation:animate('slide')
        --         else self.animation:animate('walk') end
        --     end

        --     -- Will Jump
        --     if (Keyboard.press('up')) then self:jump() end

        --     -- Brake
        --     if (self.dx < 0) then 
        --         self.dx = self.dx + math.max(BRAKE_SPEED * dt, self.dx)
        --     elseif (self.dx > 0) then 
        --         self.dx = self.dx - math.min(BRAKE_SPEED * dt, self.dx)
        --     end

        --     -- Cap speed
        --     self.dx = math.max(math.min(self.dx, self.maxSpeed), -self.maxSpeed)

        --     -- Gravity
        --     if (not self.onGround) then self.dy = self.dy + GRAVITY * dt end
        
        --     if (self.dx == 0) then self.state = 'idle' end
        -- end,

        -- -- Jump state
        -- jump = function(dt)
        --     self.animation:animate('jump')

        --     if (Keyboard.release('up')) then self.canSpring = false end
        --     -- # Add spring to the jump until key release
        --     if (self.canSpring and Keyboard.down('up')) then
        --         self.spring = self.spring - GRAVITY * dt
        --         self.dy = self.dy - self.spring * dt
        --     end
            
        --     -- Shoot fire ball
        --     if (Keyboard.press('x')) then self:shootFire() end
            
        --     -- # Flying movement
        --     if (Keyboard.down('left')) then
        --         self.dx = self.dx - self.speed * dt
        --     elseif (Keyboard.down('right')) then
        --         self.dx = self.dx + self.speed * dt
        --     end

        --     -- # Brake
        --     if (self.dx < 0) then 
        --         self.dx = self.dx + math.max(BRAKE_SPEED * dt, self.dx)
        --     elseif (self.dx > 0) then 
        --         self.dx = self.dx - math.min(BRAKE_SPEED * dt, self.dx)
        --     end

        --     -- # Cap speed
        --     self.dx = math.max(math.min(self.dx, self.maxSpeed), -self.maxSpeed)

        --     -- # Gravity
        --     self.dy = self.dy + GRAVITY * dt
        -- end,
        
        -- -- Death state
        -- death = function(dt)
        --     self.dy = self.dy + GRAVITY/2 * dt

        --     -- FIXME 
        --     if (self.y > 2250) then
        --         scene:setEvent('nextmap', 
        --         {name=scene:getMap().worldlevel..'-'..scene:getMap().stage, lifescreen=true}
        --     )
        --     end
        -- end,

        -- -- Power down state
        -- powerdown = function(dt)
        --     self.animation:animate('powerdown')
        --     self.powerDownTimer = self.powerDownTimer + dt * 7

        --     if (self.powerDownTimer > 1) then
        --         self.life = math.floor(self.powerDownTimer)%2 + 1
        --         self:setBody()
        --     end

        --     if (self.powerDownTimer > 5.5) then
        --         if (self.life ~= 1) then self.life = 1 self:setBody() end
        --         self.state = self.lastState
        --         self.powerDownTimer = nil

        --         print('powerdown', self.lastDx, self.lastDy)

        --         self.dx, self.dy = self.lastDx, self.lastDy
        --     end
        -- end,

        -- -- Power up state 
        -- powerup = function(dt)
        --     self.animation:animate('powerup')
        --     self.powerUpTimer = self.powerUpTimer + dt * 10

        --     self.life = math.floor(self.powerUpTimer)%2 + 1
        --     self:setBody()

        --     if (self.powerUpTimer > 10) then
        --         if (self.life ~= 2) then 
        --             self.life = 2
        --             self:setBody() 
        --         end

        --         self.powerUpTimer = nil

        --         print('powerup', self.lastDx, self.lastDy)

        --         self.state = self.lastState
        --         self.dx, self.dy = self.lastDx, self.lastDy
        --     end
        -- end,

    --     -- Fire up state
    --     fireup = function(dt)
    --         self.powerUpTimer = self.powerUpTimer + dt * 10

    --         local frame = math.floor(self.powerUpTimer)%4 + 1
    --         self.effectFrame = fireUpEffect[frame]

    --         if (self.powerUpTimer > 10) then
    --             self.animation:pause(false)
    --             self.state = self.lastState
    --             self.powerUpTimer = nil
    --             self.effectFrame = 42

    --             print('fireup', self.lastDx, self.lastDy)

    --             self.dx, self.dy = self.lastDx, self.lastDy
    --         end
    --     end
    -- }

    -- self:setBody()
end

-- -- # Moving Management
-- function Player:move(map, x, y, state)
--     self:reset()
--     assert(map.spawn[1], 'Aucune coordonnée de spawn rentrer dans la map ' .. map.worldlevel .. '-' .. map.stage)

--     if (x and y) then self.x, self.y = x * map.tileWidth, y * map.tileHeight
--     else self.x, self.y = map.spawn[1] * map.tileWidth, map.spawn[2] * map.tileHeight - 1 end
--     scene:getCamera():centerTarget()

--     if (state) then
--         self.state = state
--     else
--         self.state = 'idle'
--     end
-- end

-- -- # ANCHOR State Management
-- function Player:reset()
--     -- Reset Life & Up when player dies
--     if (self.state == 'death') then
--         self.life = 1
        
--         if (self.up < 1) then
--             self.score = 0 
--             self.coins = 0        
--         end

--     end

--     self.dx, self.dy = 0, 0
--     self.sx, self.sy = 1, 1
--     self.direction = 1
--     self:setBody()
--     scene:getMap():updateDepth(self, 5)
--     self.currentFrame = 1
--     self.collisionType = 'trigger'
--     self.fireball = {}
-- end

-- TODO 
-- function Player:flagged(x, speed)
--     scene:getCamera():setType('nomove')
--     self.state = 'flag-down'
--     self.animation:animate('flag-down')
--     self.dx = 0
--     self.dy = speed
--     self.direction = 1

--     if (self.life == 1) then 
--         self.yOffset = 16 
--         self.x = x - 5
--     elseif (self.life > 1) then
--         self.yOffset = 32
--         self.x = x - 6
--     end
-- end

-- function Player:flagAnim()
--     self.direction = - 1
--     self.state = 'flag'
--     self.animation:slow(1.25)
--     self.flagTimer = 0

--     self.dy = 0
--     self.dx = -200

--     if (self.life == 1) then self.x = self.x + 10
--     elseif (self.life > 1) then self.x = self.x + 12 end
-- end

-- function Player:pipeTravel(map, direction)
--     self.state = 'pipe'
--     scene:getMap():updateDepth(self, 0)
--     self.pipeTimer = 0
--     self.direction = 1
--     self.destination = map

--     if (direction == 'v') then
--         self.dx = 0
--         self.dy = -20
--         self.animation:animate('idle')
--     elseif (direction == 'h') then
--         self.dx = -20
--         self.dy = 0
--         self.animation:animate('walk')
--     end
-- end

-- function Player:shootFire()
--     if (self.life == 3 and #self.fireball < 2) then
--         self.animation:animate('shoot')
--         table.insert(self.fireball, true)

--         if (self.direction > 0) then
--             scene:getMap():addWorld(Ball_OBJ(self.x + self.xOffset + 4, self.y - self.yOffset/2, 1))
--         else
--             scene:getMap():addWorld(Ball_OBJ(self.x - self.xOffset - 4, self.y - self.yOffset/2, -1))
--         end
--     end
-- end

-- function Player:jump()
--     if (self.onGround or self.onBlock) then
--         SND_JUMP:stop()
--         SND_JUMP:play()
--         if (self.maxSpeed == MAX_RUN_SPEED) then self.spring = JUMP_SPRING_RUN
--         elseif (self.maxSpeed == MAX_WALK_SPEED) then
--             if (self.dx == 0) then self.spring = JUMP_SPRING_IDLE
--             else self.spring = JUMP_SPRING_WALK end
--         end

--         self.debug = self.spring

--         self.dy = -JUMP_STRENGTH
--         self.state = 'jump'
--     end
-- end

-- function Player:resetJump()
--     if (self.dx ~= 0) then self.state = 'walk'
--     else self.state = 'idle' end
--     self.spring = nil
--     self.canSpring = true
-- end

-- --- # ANCHOR Collision Management
-- function Player:collisionX()
--     -- # Corners detection /!\ Depend on the object size
--     local xCoord, yCoord

--     if (self.h > 16) then xCoord, yCoord = {self.x - self.xOffset, self.x + self.xOffset - 1}, {self.y - self.yOffset, self.y - self.yOffset/2, self.y}
--     else xCoord, yCoord = {self.x - self.xOffset, self.x + self.xOffset - 1}, {self.y - self.yOffset, self.y} end

--     for side, xPos in ipairs(xCoord) do
--         for _, yPos in ipairs(yCoord) do
--             xColl = scene:getMap():collide(xPos, yPos)

--             if (xColl) then
--                     if (self.dx > 0) then
--                         self.x = (xColl-1) * scene:getMap().tileWidth - self.xOffset
--                     elseif (self.dx < 0) then
--                         self.x = xColl * scene:getMap().tileWidth + self.xOffset
--                     end

--                     self.dx = 0

--                 return COLLISIONSIDEX[side]
--             end

--         end
--     end
    
--     return false
-- end

-- function Player:collisionY()
--     -- # Corners detection /!\ Depend on the object size
--     local xCoord, yCoord

--     if (self.dy == 0) then 
--         xCoord, yCoord = {self.x, self.x - self.xOffset, self.x + self.xOffset - 1}, {self.y - self.yOffset, self.y + 1}
--     else
--         xCoord, yCoord = {self.x, self.x - self.xOffset, self.x + self.xOffset - 1}, {self.y - self.yOffset, self.y} 
--     end

--     for side, yPos in ipairs(yCoord) do
--         for _, xPos in ipairs(xCoord) do
--             _, yColl, iTile = scene:getMap():collide(xPos, yPos)

--             if (yColl) then
--                 if (self.dy > 0) then
--                     self.y = (yColl - 1) * scene:getMap().tileHeight - 1
--                 elseif (self.dy < 0) then
--                     self.y = yColl * scene:getMap().tileHeight + self.yOffset
--                 end

--                 self.dy = 0

--                 return COLLISIONSIDEY[side], iTile
--             end
--         end
--     end

--     return false
-- end

-- function Player:collideObject()
--     local colls = scene:getMap():collideObject(self)

--     for i=1, #colls do
--         local object, side = colls[i][1], colls[i][2]

--         if (object.collisionType == 'rigid') then
--             local map = scene:getMap()

--             if (side == 'left') then
--                 self.x = object.x - map.tileWidth/2 - self.xOffset
--                 self.dx = 0
--             elseif (side == 'right') then
--                 self.x = object.x + map.tileWidth/2 + self.xOffset
--                 self.dx = 0
--             elseif (side == 'bottom') then 
--                 self.y = math.ceil(object.y/map.tileWidth) * map.tileHeight + self.yOffset
--                 self.dy = VERTICAL_BOUNCE 
--             elseif (side == 'top') then
--                 self.y = (math.ceil(object.y/map.tileWidth) - 1) * map.tileHeight - 1
--                 self.dy = 0
--                 if (self.onBlock ~= true) then self.onBlock = true end
--                 if (self.state == 'jump') then self:resetJump() end
--             end            
--         end

--         --print(object)
--         if (object.collisionType ~= 'none') then object:collect(side) end
--     end
-- end

-- function Player:collisionCam()
--     local camX = scene:getCamera().x 
--     if (self.x - self.xOffset < camX) then
--         self.x = camX + self.xOffset
--         self.dx = 0
--     elseif (self.x + self.xOffset > scene:getMap().mapWidthPixel) then
--         self.x = scene:getMap().mapWidthPixel - self.xOffset
--         self.dx = 0
--     end
-- end

-- # ANCHOR Bonus Management
-- function Player:setBody(size)
--     local size = size or self.life

--     -- Switch mario size
--     if (marioAttribute[size] and marioAttribute[size].h ~= self.h) then
--         local marioSize = size
--         self.atlas = MARIO_ATLAS[marioSize]
--         self.spriteQuads = MARIO_QUADS[marioSize]
--         self.animation = animations[marioSize]

--         for k, v in pairs(marioAttribute[marioSize]) do
--             self[k] = v
--         end

--         self.effectFrame = 0
--     end

--     if (self.life == 3) then self.effectFrame = 42 end
-- end

-- function Player:invicible(type)
--     self.effectTimer = 0
--     self.invincibility = type

--     if (self.invincibility == 2) then 
--         self.invincibilityTimer = 18
--         MUSICS.STARMAN_SND:play()
--         MUSICS.OVERWORLD_SND:stop()
--     elseif (self.invincibility == 1) then
--         self.invincibilityTimer = 4
--     end
-- end

-- function Player:addUp()
--     self.up = self.up + 1
-- end

-- function Player:addCombo(type)
--     print('Combo add ' .. type)
--     self.combos[#self.combos + 1] = type
-- end

-- function Player:resetCombo(dt)
--     self.timerCombo = self.timerCombo + dt
    

--     if (self.timerCombo > 0.75) then
--         print('combo reset')
--         for i=#self.combos, 1, -1  do
--             table.remove(self.combos, i)
--         end
--         self.timerCombo = 0
--     end
-- end

-- function Player:addScore(score, source, type)
--     if (source) then
--         if (#self.combos > 0) then
--             print('combo gestion')
--             local c = 0

--             for i=1, #self.combos do
--                 if (self.combos[i] == type) then
--                     c = c + 1
--                 end
--             end

--             if (c > 0) then 
--                 if (c > #COMBOS[type]) then c = #COMBOS[type] self.up = self.up + 1
--                 else self.score = self.score + COMBOS[type][c] end 
--                 self.timerCombo = 0
--                 print('reset timer')
--                 scene:getHud():addScore(COMBOS[type][c], source.x, source.y - source.yOffset) 
--             end
--         else
--             print('no combo')
--             self.score = self.score + score
--             scene:getHud():addScore(score, source.x, source.y - source.yOffset) 
--         end
--     else
--         self.score = self.score + score
--     end
-- end

-- function Player:addCoin(count)
--     local count = count or 1
--     self.coins = self.coins + count
-- end

-- -- # ANCHOR Power Management
-- function Player:powerUp()
--     if (self.life == 3 or self.state == 'powerup') then return end

--     self.lastDx, self.lastDy = self.dx, self.dy
--     self.lastState = self.state
--     self.dx, self.dy = 0, 0

--     self.life = math.min(3, self.life + 1)
--     self:setBody()

--     self.powerUpTimer = 0

--     if (self.life == 2) then self.state = 'powerup'
--     elseif (self.life == 3) then 
--         self.animation:pause() 
--         self.state = 'fireup' 
--     end
-- end

-- function Player:powerDown()
--     if (self.invincibility or self.state == 'powerdown') then return end

--     self.lastDx, self.lastDy = self.dx, self.dy
--     if (self.state == 'fireup' or self.state == 'powerup') then self.lastState = 'jump'
--     else self.lastState = self.state end
--     self.dx, self.dy = 0, 0

--     if (self.life > 2) then 
--         self.life = 2 
--         self.effectFrame = 0
--     end

--     self.life = math.max(0, self.life - 1)

--     if (self.life > 0) then
--         SND_POWERDOWN:stop()
--         SND_POWERDOWN:play()
--         self.state = 'powerdown'
--         self.powerDownTimer = 0
--         self:invicible(1)
--     else self:die() end
-- end

-- function Player:die()
--     if (self.state == 'death') then return end 

--     if (self.life > 1) then
--         self:setBody()
--     end

--     self.life = 1
--     self.up = self.up - 1 
--     -- FIXME GAMEOVER

--     love.audio.stop()
--     SND_DEATH:play()
--     self.state = 'death'
--     self.collisionType = 'none'
--     self.dy = -200
--     self.deathTimer = 1
--     self.animation:animate('die')
--     self.currentFrame = self.animation:getFrame()
-- end

local Koopa_OBJ = require('lib.Ennemies.Koopa')

-- ANCHOR Update / Draw
function Player:update(dt)
    if (Keyboard.press('a')) then self:powerUp()
    elseif (Keyboard.press('z')) then self:powerDown()
    elseif (Keyboard.press('f1')) then self.onGround = false
    elseif (Keyboard.press('r')) then love.load()
    elseif (Keyboard.press('s')) then scene:setEvent('nextmap', {name=scene:getMap().nextmap, lifescreen=true})
    elseif (Keyboard.press('t')) then scene:setEvent('nextmap', {name='1-test', lifescreen=true})
    elseif (Keyboard.press('y')) then if (scene:getMap().stage == 'TEST') then scene:getMap():addWorld(Koopa_OBJ(9*16, 5*16 + 1)) end
    end

    -- # DEATH UPDATE
    if (self.state == 'death') then
        -- self.deathTimer = self.deathTimer - dt

        -- if (self.deathTimer < 0) then
        --     -- # Behaviour update
        --     self.behaviours[self.state](dt)

        --     -- # Physics update 
            
        --     self.y = self.y + self.dy * dt

        --     -- # Animation update
        --     self.animation:update(dt)
        --     self.currentFrame = self.animation:getFrame()
        -- end

    -- # AUTOWALK UPDATE
    -- elseif (self.state == 'autowalk') then
    --     self.animation:animate('walk')

    --     self.direction = 1
    --     self.dx = self.dx + WALK_SPEED * dt

    --     -- Brake
    --     if (self.dx < 0) then 
    --         self.dx = self.dx + math.max(BRAKE_SPEED * dt, self.dx)
    --     elseif (self.dx > 0) then 
    --         self.dx = self.dx - math.min(BRAKE_SPEED * dt, self.dx)
    --     end

    --     -- Cap speed
    --     self.dx = math.max(math.min(self.dx, self.maxSpeed), -self.maxSpeed)

    --     self.x = self.x + self.dx * dt
    --     self:collisionX()

    --     self:collideObject()

    --     self.animation:update(dt)
    --     self.currentFrame = self.animation:getFrame()
        
    -- -- # WAIT UPDATE
    -- elseif (self.state == 'wait') then


    -- -- # POWER UP UPDATE
    -- elseif (self.state == 'powerup') then
    --     -- # Invicibility
    --     if (self.invincibility) then
    --         self.effectTimer = self.effectTimer + dt * 10
    --         self.invincibilityTimer = self.invincibilityTimer - dt

    --         if (self.invincibility == 2) then
    --             local frame = math.floor(self.effectTimer)%4 + 1
    --             self.effectFrame = invincibilityEffect[math.min(2, self.life)][frame]
    --         elseif (self.invincibility == 1) then
    --             if (self.effectTimer > 2) then self.effectTimer = 0 end
    --             self.alpha = math.floor(self.effectTimer)
    --         end

    --         if (self.invincibilityTimer < 0) then 
    --             if (self.invincibility == 2) then 
    --                 MUSICS.STARMAN_SND:stop()
    --                 MUSICS.OVERWORLD_SND:play()
    --             end

    --             self.effectTimer = nil
    --             self.alpha = 1 
    --             self.invincibility = false

    --             if (self.life == 3) then self.effectFrame = 42
    --             else self.effectFrame = 0 end
    --         end
    --     end

    --     self.animation:animate('powerup')
    --     self.powerUpTimer = self.powerUpTimer + dt * 10

    --     self.life = math.floor(self.powerUpTimer)%2 + 1
    --     self:setBody()

    --     if (self.powerUpTimer > 10) then
    --         if (self.life ~= 2) then 
    --             self.life = 2
    --             self:setBody() 
    --         end

    --         self.powerUpTimer = nil

    --         print('powerup', self.lastDx, self.lastDy)

    --         self.state = self.lastState
    --         self.dx, self.dy = self.lastDx, self.lastDy
    --     end

    -- -- # TITLE SCREEN UPDATE
    -- elseif (self.state == 'titlescreen') then
    --     self.behaviours[self.state](dt)

    -- -- # FLAG UPDATE
    -- -- TODO
    -- elseif (self.state == 'flag-down' or self.state == 'flag') then
    --     -- # Invicibility
    --     if (self.invincibility) then
    --         self.effectTimer = self.effectTimer + dt * 10
    --         self.invincibilityTimer = self.invincibilityTimer - dt

    --         if (self.invincibility == 2) then
    --             local frame = math.floor(self.effectTimer)%4 + 1
    --             self.effectFrame = invincibilityEffect[math.min(2, self.life)][frame]
    --         elseif (self.invincibility == 1) then
    --             if (self.effectTimer > 2) then self.effectTimer = 0 end
    --             self.alpha = math.floor(self.effectTimer)
    --         end

    --         if (self.invincibilityTimer < 0) then 
    --             if (self.invincibility == 2) then 
    --                 MUSICS.STARMAN_SND:stop()
    --                 MUSICS.OVERWORLD_SND:play()
    --             end

    --             self.effectTimer = nil
    --             self.alpha = 1 
    --             self.invincibility = false

    --             if (self.life == 3) then self.effectFrame = 42
    --             else self.effectFrame = 0 end
    --         end
    --     end

    --     self.animation:update(dt)
    --     self.currentFrame = self.animation:getFrame()

    --     if (self.state == 'flag') then
    --         self.flagTimer = self.flagTimer + dt
    --         self.dx = self.dx + 100 * dt
    --         self.x = self.x + math.max(0, math.min(60, self.dx) * dt)
    --         self:collisionX()

    --         if (self.flagTimer > 1) then
    --             scene:getCamera():setType('classic')
    --             self.dy = -150
    --             self.dx = 35
    --             if (self.life == 1) then 
    --                 self.yOffset = marioAttribute[1].yOffset 
    --             elseif (self.life > 1) then
    --                 self.yOffset = marioAttribute[2].yOffset 
    --             end
    --             self.animation:animate('walk')
    --             self.animation:slow(20)
    --             self.flagTimer = -100
    --             MUSICS.STAGE_CLEAR_SND:play()
    --             if (self.invincibility) then self.invincibilityTimer = 0 end
    --         end

    --         if (self.dx > 50 and self.direction ~= 1) then
    --             self.direction = 1 
    --             self.animation:slow(1)
    --         end

    --         if (self.flagTimer < 0) then
    --             self.dy = self.dy + GRAVITY * dt
    --         end
    --     end

    --     self.y = self.y + self.dy * dt
    --     local collSideY, tile = self:collisionY()

    --     if (collSideY) then
    --         if (not self.onGround) then
    --             -- Add bounce effect when collide top
    --             if (collSideY == 'bottom') then
    --                 self.dy = VERTICAL_BOUNCE
                    
    --             -- Land player and reset jump if he's jumping
    --             elseif (collSideY == 'top') then 
    --                 self.onGround = true
    --                 if (self.state == 'flag-down') then self.animation:pause(true) end          
    --             end
    --         end
    --     else
    --         self.onGround = false
    --     end

    --     if (self.state == 'flag') then self:collideObject() end

    -- # PIPE UPDATE
    elseif (self.state == 'pipe') then
        self.pipeTimer = self.pipeTimer + dt

        self.animation:update(dt)
        self.currentFrame = self.animation:getFrame()

        if (self.dx ~= 0) then
            self.dx = self.dx + 125 * dt
            self.x = self.x + math.max(0, math.min(30, self.dx * dt))

            if (self.dx > 55 and self.dx < 60) then 
                self.y = self.y - 1 
                self.sy = 0.5
            end         
        elseif (self.dy ~= 0 ) then
            if (self.pipeTimer > 1) then self.dy = 0
            else self.dy = self.dy + 125 * dt end
            
            self.y = self.y + math.max(0, math.min(65, self.dy * dt))
        end


        if (self.pipeTimer > 2) then 
            self.pipeTimer = nil
            scene:setEvent('nextmap', 
            {name=self.destination.map, lifescreen=self.destination.screen or false, x=self.destination.x or nil, y=self.destination.y or nil})
            self.destination = nil
        end

    -- -- # NORMAL UPDATE
    -- else
    --     -- # Invicibility
    --     if (self.invincibility) then
    --         self.effectTimer = self.effectTimer + dt * 10
    --         self.invincibilityTimer = self.invincibilityTimer - dt

    --         if (self.invincibility == 2) then
    --             local frame = math.floor(self.effectTimer)%4 + 1
    --             self.effectFrame = invincibilityEffect[math.min(2, self.life)][frame]
    --         elseif (self.invincibility == 1) then
    --             if (self.effectTimer > 2) then self.effectTimer = 0 end
    --             self.alpha = math.floor(self.effectTimer)
    --         end

    --         if (self.invincibilityTimer < 0) then 
    --             if (self.invincibility == 2) then 
    --                 MUSICS.STARMAN_SND:stop()
    --                 MUSICS.OVERWORLD_SND:play()
    --             end

    --             self.effectTimer = nil
    --             self.alpha = 1 
    --             self.invincibility = false

    --             if (self.life == 3) then self.effectFrame = 42
    --             else self.effectFrame = 0 end
    --         end
    --     end

    --     -- # Death Check
    --     if (self.y > 400) then self:die() end

    --     -- # Time left
    --     self.time = math.max(0, self.time - dt)
    --     if (self.time <= 0) then self:die() end

    --     if (#self.combos > 0) then self:resetCombo(dt) end

    --     -- # Behaviour update
    --     self.behaviours[self.state](dt)

    --     -- # World Physics update 
    --     self.x = self.x + self.dx * dt
    --     self:collisionX()
    --     self:collisionCam()

    --     self.y = self.y + self.dy * dt
    --     local collSideY, tile = self:collisionY()

    --     -- # Collision Y response
    --     if (collSideY) then
    --         if (tile and collSideY == 'bottom') then tile:collect(collSideY) end

    --         if (not self.onGround) then
    --             -- Add bounce effect when collide top
    --             if (collSideY == 'bottom') then
    --                 self.dy = VERTICAL_BOUNCE
                    
    --             -- Land player and reset jump if he's jumping
    --             elseif (collSideY == 'top') then 
    --                 self.onGround = true
    --                 if (self.state == 'jump') then self:resetJump() end
    --             end
    --         end
    --     else
    --         self.onGround = false
    --     end

    --     -- # Objects Physic
    --     self:collideObject() 

    --     -- # Animation update
    --     self.animation:update(dt)
    --     self.currentFrame = self.animation:getFrame()
    end
end

function Player:render()
    -- love.graphics.setColor(0,0,0, 0.5)
    -- love.graphics.rectangle('fill', math.floor(self.x - self.xOffset), math.floor(self.y - self.yOffset), self.w, self.h)
    
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
        
        love.graphics.print('TOP- 000000', virtualWidth/2 - default_font:getWidth('TOP- 000000')/2, 184)
    end

    -- love.graphics.setColor(0,1,0,0.9)
    -- love.graphics.rectangle('fill', math.floor(self.x), math.floor(self.y - self.yOffset), 1, 1)
    -- love.graphics.rectangle('fill', math.floor(self.x - self.xOffset), math.floor(self.y - self.yOffset), 1, 1)
    -- love.graphics.rectangle('fill', math.floor(self.x + self.xOffset - 1), math.floor(self.y - self.yOffset), 1, 1)

    -- love.graphics.rectangle('fill', math.floor(self.x - self.xOffset), math.floor(self.y - self.yOffset/2), 1, 1)
    -- love.graphics.rectangle('fill', math.floor(self.x + self.xOffset - 1), math.floor(self.y - self.yOffset/2), 1, 1)

    -- love.graphics.rectangle('fill', math.floor(self.x - self.xOffset), math.floor(self.y), 1, 1)
    -- love.graphics.rectangle('fill', math.floor(self.x + self.xOffset - 1), math.floor(self.y), 1, 1)
    -- love.graphics.setColor(1,1,1,1)
end

return Player
local MapCreator = {}

-- # Import Objects
local MapReader_OBJ = require('lib.MapReader')
local Brick_OBJ = require('lib.Objects.Brick')
local Coin_OBJ = require('lib.Objects.Coin')
local Box_OBJ = require('lib.Objects.Box')
local InvisibleBox_OBJ = require('lib.Objects.InvisibleBox')
local PipeEnter_OBJ = require('lib.Objects.PipeEnter')
local Door_OBJ = require('lib.Objects.Door')
local Flag_OBJ = require('lib.Objects.Flag')
local PlatformV_OBJ = require('lib.Objects.PlatformV')
local PlatformBF_OBJ = require('lib.Objects.PlatformBF')
local Text_OBJ = require('lib.Objects.Text')
local BossAxe_OBJ = require('lib.Objects.BossAxe')
local NPC_OBJ = require('lib.Objects.Npc')
local HoverLink_OBJ = require('lib.Objects.HoverLink')


-- # Import Ennemies
local Goomba_OBJ = require('lib.Ennemies.Goomba')
local Koopa_OBJ = require('lib.Ennemies.Koopa')
local Plant_OBJ = require('lib.Ennemies.Plant')
local RedKoopa_OBJ = require('lib.Ennemies.RedKoopa')
local FlyRedKoopa_OBJ = require('lib.Ennemies.FlyRedKoopa')
local FireBall_OBJ = require('lib.Ennemies.FireBall')
local Bowser_OBJ = require('lib.Ennemies.Bowser')


-- # Data Reading Utilies
-- ## Load layers
local function getLayers(data)
    local t = {}

    for _, v in ipairs(data.layers) do
        t[v.name] = v.data
    end

    return t
end

-- ## Get Sky Color
local function getSky(sky)
    local color = {}

    for i, c in ipairs(sky) do
        color[i] = c/255
    end

    return color
end

-- ## Convert into number & Verify value
local function intVerif(str)
    if ((type(str) == 'string' and str:len() < 1) or tonumber(str) == -1) then return nil
    else return tonumber(str) end
end

-- ## Verify value of string
local function stringVerif(str)
    if (str:len() < 1) then return nil
    else return str end
end

-- ## Convert string into number/boolean
local function stringTo(str)
    if (tonumber(str)) then return tonumber(str)
    elseif (str == 'false') then return false
    elseif (str == 'true') then return true
    else return str end 
end

-- ## Convert specific string into table
local function stringToTable(str)
    local str, t = str or '', {}

    if (str:len() > 1) then
        for a in str:gmatch('[^;]+') do
            if (a:find(',') or a:find('=')) then table.insert(t, {}) end
            for b in a:gmatch('[^,]+') do
                local c, d = b:find('=')

                if (c and d) then 
                    t[#t][b:sub(1, c-1)] = stringTo(b:sub(d+1, -1))
                else
                    table.insert(t, stringTo(b))
                end
            end
        end
    end

    return t
end

-- # Map Creation Utilies
local collidablesTile = {
    -- Decoration
    1, 2, 3, 141, 205, 206, 274, 275, 409, 410, 412, 
    19, 20, 21, 159, 223, 224, 292, 293, 294, 427, 428, 430, 
    29, 30, 31, 169, 233, 234, 302, 303, 304, 437, 438, 440, 
    37, 38, 39, 177, 241, 242, 310, 311, 445, 446, 448, 

    -- Vegetation
    6, 7, 8, 9, 10, 74, 75, 76, 77, 78, 142, 143, 144, 210, 211, 212, 414, 416, 417, 418, 
    11, 12, 13, 14, 15, 79, 80, 81, 82, 83, 147, 148, 149, 215, 216, 217, 419, 421, 422, 423, 
    24, 25, 26, 27, 28, 92, 93, 94, 95, 96, 160, 161, 162, 228, 229, 230, 432, 434, 435, 436, 
    45, 46, 47, 48, 49, 113, 114, 115, 116, 117, 181, 182, 183, 249, 250, 251, 453, 455, 456, 457, 
    50, 51, 52, 53, 54, 118, 119, 120, 121, 122, 186, 187, 188, 254, 255, 256, 458, 460, 461, 462, 
    55, 56, 57, 58, 59, 123, 124, 125, 126, 127, 191, 192, 193, 259, 260, 261, 463, 465, 466, 467, 

    -- Cloud
    153, 154, 
    171, 172, 
    179, 180, 
    197, 198
}
local len_collidablesTile = #collidablesTile

local TileConverter = {
    [1] = 273, [5] = 291, [9] = 301, [13] = 309,
    [17] = 70, [21] = 88, [25] = 98, [29] = 106, [33] = 181, [37] = 190, [41] = 199, [45] = 208,
    [49] = 217, [53] = 226, [57] = 235, [61] = 244,
    [50] = 621, [54] = 339, [58] = 670, [62] = 660, [63] = 626, [64] = 665,
    [66] = 622, [70] = 340, [74] = 671, [78] = 661, [79] = 627, [80] = 666,
    [163] = 505, [164] = 506
}

-- # Map Creation Function
local function isObject(tile, t)
    for _, ref in ipairs(t) do
        if (tile >= ref and tile < ref + 4*4 and (tile%ref)%4 == 0) then return true end
    end

    return false
end

local function getBonus(tile)
    if (tile < 97 or tile >121) then return false end

    if (tile == 97 or tile == 98) then return 'powerup', 1
    elseif (tile == 99) then return 'star', 1
    elseif (tile == 100) then return '1up', 1
    elseif (tile == 101) then return 'creeper', 1
    elseif (tile > 112 and tile <= 121) then return 'coin', tile - 112 end
end

local function getGoal(x, y, limit, layer, dir)
    local limit = {limit, 0}
    local startCell = 0
    if (dir == 'h') then startCell = x
    elseif (dir == 'v') then startCell = y end

    for i, v in ipairs({1, -1}) do
        for j=startCell, limit[i], v do
            local tile
            if (dir == 'h') then tile = layer[(y - 1) * self.mapWidth + j]
            elseif (dir == 'v') then tile = layer[(j - 1) * self.mapWidth + x] end

            if (tile == 123) then return j end
        end
    end

    return false
end


local function getFlagPos(data, x)
    for cy=1, data.mapHeight do
        local tile = data:getTile(x, cy)
        if (tile == 72 or tile == 90 or tile == 108 or tile == 100) then return x, cy end
    end

    for cy=1, data.mapHeight do
        for cx=x - 10, x + 10 do
            local tile = data:getTile(cx, cy)
            if (tile == 72 or tile == 90 or tile == 108 or tile == 100) then return cx, cy end
        end
    end
end

function MapCreator.new(target, data)
    -- # Get layers
    local layers = getLayers(data)

    -- # Add Variables
    target.name = data.properties['name']
    target.stage = data.properties['stage'] or 0
    target.worldlevel = data.properties['worldlevel'] or 0
    target.startscreen = data.properties['worldlevel']
    target.time = intVerif(data.properties['time'])
    target.theme = data.properties['theme']
    target.playerstate = stringVerif(data.properties['playerstate'])
    target.camera = stringVerif(data.properties['camera'])

    target.undermaps = stringToTable(data.properties['undermaps'])
    target.spawn = stringToTable(data.properties['spawn'])
    target.pipeentries = stringToTable(data.properties['pipeentries'])
    target.flags = stringToTable(data.properties['flags'])
    target.nextmap = data.properties['nextmap']
    
    target.tileWidth = data.tilewidth
    target.tileHeight = data.tileheight
    target.mapWidth = data.width
    target.mapHeight = data.height
    target.mapWidthPixel, target.mapHeightPixel = target.mapWidth * target.tileWidth, target.mapHeight * target.tileHeight
    target.collidableTiles = {-1}

    target.playerlife = data.properties['playerlife'] or 3
    target.endtext = data.properties['endtext'] or 'Well done !'

    target.sky = getSky(data.backgroundcolor)
    target.data = layers.Decor

    local texts = stringToTable(data.properties['text'])

    local objectGID = data.tilesets[2].firstgid - 1

    -- # Create Batch
    local decor = {
        batch = love.graphics.newSpriteBatch(TILES_ATLAS, target.mapWidth * target.mapHeight),
        render = function(this) love.graphics.draw(this.batch) end,
        update = function() end,
        depth = 1,
        objectType = 'Decor',
        destroy = function(this) this.batch:clear() end
    }
    setmetatable(decor, {__tostring = function() return 'Batch' end})

    -- # Create Decor & Add Objects
    local exclude, door, pipeId, ennemy, textIndex, fireBar = {}, 0, 1, nil, 1, 0

    decor.batch:clear()

    for x=1, target.mapWidth do
        for y=1, target.mapHeight do
            local tile = target:getTile(x, y)

            if (tile ~= 0 and tile ~= -1) then
                -- # Batch
                decor.batch:add(TILES_QUADS[tile], (x - 1) * target.tileWidth, (y - 1) * target.tileHeight)

                -- # Generate Collision Tile
                local toExclude = false

                for i=1, #exclude do if (tile == exclude[i]) then toExclude = tile end end

                if (not toExclude) then 
                    for j=1, len_collidablesTile do 
                        if (tile == collidablesTile[j]) then
                            table.insert(target.collidableTiles, tile) 
                            table.insert(exclude, tile) 
                        end
                    end
                end
            end

            -- # Objects
            local tileObj = target:getTile(x, y, layers.Objects)

            if (tileObj ~= 0) then 
                -- # Variables
                tileObj = tileObj - objectGID
                local px, py = (x - 1) * target.tileWidth, (y-1) * target.tileHeight
                local object = nil

                -- # Brick
                if (isObject(tileObj, {1, 17})) then
                    local bonus, count = getBonus(target:getTile(x, y, layers.Bonus) - objectGID)

                    if (bonus) then object = Box_OBJ(px, py, 'brick', TileConverter[tileObj], bonus, count)
                    else object = Brick_OBJ(px, py, TileConverter[tileObj]) end

                    target:setTile(-1, x, y)            
                
                -- # Box
                elseif (isObject(tileObj, {33})) then
                    local bonus, count = getBonus(target:getTile(x, y, layers.Bonus) - objectGID)

                    if (bonus) then object = Box_OBJ(px, py, 'box', TileConverter[tileObj], bonus, count)
                    else object = Box_OBJ(px, py, 'box', TileConverter[tileObj], 'coin', 1) end

                    target:setTile(-1, x, y) 

                -- # Invisible Box
                elseif (tileObj == 105) then 
                    local bonus, count = getBonus(target:getTile(x, y, layers.Bonus) - objectGID)

                    if (bonus) then object = InvisibleBox_OBJ(px, py, target.theme, bonus)
                    else object = InvisibleBox_OBJ(px, py, target.theme, '') end

                -- # V Pipe
                elseif (tileObj == 106) then 
                    object = PipeEnter_OBJ(px, py - 16, 'v', target.pipeentries[pipeId]) pipeId = pipeId + 1
                
                -- # H Pipe
                elseif (tileObj == 108) then
                    object = PipeEnter_OBJ(px - 16, py, 'h', target.pipeentries[pipeId]) pipeId = pipeId + 1
            
                -- # Flag
                elseif (isObject(tileObj, {50}) or tileObj == 63 or tileObj == 64) then
                    local flagH = 0
                    for fy=y, target.mapHeight do
                        local flagId = math.max(0, target:getTile(x, fy, layers.Objects) - objectGID)
                        if (isObject(flagId, {66}) or flagId == 79 or flagId == 80) then flagH = flagH + 1 end
                    end

                    for fy=y-1, 1, -1 do
                        target:setTile(-1, x+1, fy)
                    end

                    decor.batch:add(TILES_QUADS[TileConverter[tileObj]], (x - 1) * target.tileWidth, (y - 1) * target.tileHeight)
                    for fy=y+1, y+flagH do
                        decor.batch:add(TILES_QUADS[TileConverter[tileObj+16]], (x - 1) * target.tileWidth, (fy - 1) * target.tileHeight)
                    end
                        
                    object = Flag_OBJ(px, py, flagH)

                -- # Coin
                elseif (isObject(tileObj, {49})) then
                    object = Coin_OBJ(px, py, TileConverter[tileObj])

                -- # Castle Door
                elseif (tileObj == 104) then 
                    local flagPosX, flagPosY = getFlagPos(target, x)
    
                    object = Door_OBJ(px + 16, py, flagPosX, flagPosY)
                    door = 1

                -- # Castle Door with no Flag & Firestar
                elseif (tileObj == 122) then    
                    object = Door_OBJ(px + 16, py, false, false)
                    door = 1

                -- # Platform Vertical
                elseif (tileObj == 109) then
                    object = PlatformV_OBJ(px, py, 3, 1)

                elseif (tileObj == 110) then
                    object = PlatformV_OBJ(px, py, 3, -1)

                -- # Platform Back and Forth
                -- # Horizontal
                elseif (tileObj == 125) then 
                    local goal, dir, limit = 0, 1, {target.mapWidth, 1}

                    for i, v in ipairs({1, -1}) do
                        for j=x, limit[i], v do
                            if (target:getTile(j, y, layers.Objects) - objectGID == 123) then 
                                goal = j 
                                dir = v                            
                            end
                        end
                    end

                    object = PlatformBF_OBJ(px, py, 3, 'h', goal*target.tileWidth, dir)
                
                -- # Vertical
                elseif (tileObj == 126) then 
                    local goal, dir, limit = 0, 1, {target.mapHeight, 1}

                    for i, v in ipairs({1, -1}) do
                        for j=y, limit[i], v do
                            if (target:getTile(x, j, layers.Objects) - objectGID == 123) then 
                                goal = j 
                                dir = v
                            end
                        end
                    end

                    object = PlatformBF_OBJ(px, py, 3, 'v', goal*target.tileHeight, dir)

                -- # Toad
                elseif (tileObj == 163) then
                    object = NPC_OBJ(px, py, TileConverter[tileObj], {{x=148*target.tileWidth, y=6*target.tileHeight, str='THANK YOU MARIO!', indent=0}, {x=147*target.tileWidth, y=8*target.tileHeight, str='BUT OUR PRINCESS IS \nIN ANOTHER CASTLE!', indent=8}})

                -- # Castle Boss Spawner
                elseif (isObject(tileObj, {65})) then
                    local chain, bridge = {}, {}

                    -- ## Chain
                    local chainTile = target:getTile(x - 1, y + 1)
                    if (chainTile == 638 or chainTile == 620 or chainTile == 625 or chainTile == 659 or chainTile == 664 or chainTile == 669) then  chain.x, chain.y = x - 1, y + 1
                    else chain.x, chain.y = nil, nil end  

                    -- # Bridge
                    bridge.y = y + 2
                    bridge.x = {}
                    for i=x, x-20, -1 do
                        local bridgeTile = target:getTile(i, y + 2)

                        if (bridgeTile == 153 or bridgeTile == 171 or bridgeTile == 179 or bridgeTile == 197) then  
                            table.insert(bridge.x, i)
                        end
                    end

                    -- # Platform
                    local platform = PlatformBF_OBJ(px - 2*16, py - 2*16, 2, 'h', 2152, -1)

                    -- -- # Bowser 
                    local bowser = Bowser_OBJ(px - 4*16, py + 16, target.theme, bridge.x[#bridge.x-1] * 16, bridge.x[2] * 16)

                    -- -- # Boss Attack
                    object = BossAxe_OBJ(px, py, tileObj, bowser, platform, chain, bridge)
                    target:addWorld(bowser)
                    target:addWorld(platform)

                -- # Ennemies
                elseif (tileObj == 145) then
                    local linked
                    if (ennemy and ennemy.x >= px - 48) then linked = ennemy end

                    object = Goomba_OBJ(px, py, target.theme, linked)
                    ennemy = object

                -- # Koopa
                elseif (tileObj == 146) then   
                    local linked = nil
                    if (ennemy and ennemy.x >= px - 48) then linked = ennemy end

                    object = Koopa_OBJ(px, py, target.theme, linked)
                    ennemy = object

                -- # Red Koopa
                elseif (tileObj == 149) then
                    local linked = nil
                    if (ennemy and ennemy.x >= px - 48) then linked = ennemy end

                    object = RedKoopa_OBJ(px, py, linked)
                    ennemy = object

                -- # Red Koopa Paratroopa
                elseif (tileObj == 150) then
                    local goal, dir, limit = 0, 1, {target.mapHeight, 1}

                    for i, v in ipairs({1, -1}) do
                        for j=y, limit[i], v do
                            if (target:getTile(x, j, layers.Objects) - objectGID == 123) then 
                                goal = j 
                                dir = v
                            end
                        end
                    end

                    --print(x, y, goal, dir)
                    object = FlyRedKoopa_OBJ(px, py, 'v', goal * target.tileHeight, dir)

                -- # Carnivorous Plant
                elseif (tileObj == 147) then
                    object = Plant_OBJ(px - 8, py, target.theme, 'bottom')

                -- # Fire Bar Rota Trigo
                elseif (tileObj == 111) then
                    local coll = true
                    for i=0, 5 do
                        if (i == 5) then coll = false end
                        target:addWorld(FireBall_OBJ(px, py, -1, i, coll,  math.rad(90 * fireBar)))
                    end

                    fireBar = fireBar + 1

                -- # Fire Bar Anti Rota Trigo
                elseif (tileObj == 112) then
                    local coll = true

                    for i=0, 5 do
                        if (i == 5) then coll = false end
                        target:addWorld(FireBall_OBJ(px, py, 1, i+1, coll, math.rad(90 * fireBar)))
                    end

                    fireBar = fireBar + 1

                -- # Map Reader
                elseif (tileObj == 103) then
                    object = MapReader_OBJ(px, py)

                -- # Open Folder
                elseif (tileObj == 81) then 
                    object = HoverLink_OBJ(px, py, 1, function() os.execute("%SystemRoot%\\explorer.exe \""..love.filesystem.getSaveDirectory():gsub('/', '\\')) end)

                -- # Copy directory
                elseif (tileObj == 83) then 
                    object = HoverLink_OBJ(px, py, 2, function() love.system.setClipboardText(love.filesystem.getSaveDirectory()) end)

                -- # Text
                elseif (tileObj == 127 and texts[textIndex]) then
                    object = Text_OBJ(px, py, texts[textIndex].txt, texts[textIndex].indent)
                    textIndex = textIndex + 2
                end

                -- Insert new object
                if (object) then
                    target:addWorld(object)
                end
            end
        end
    end
    decor.batch:flush()

    target:addWorld(decor)
end

-- function MapCreator.add(obj, target)
--     table.insert(target.objects, obj)
-- end

return MapCreator
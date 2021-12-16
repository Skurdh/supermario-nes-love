-- # Loading Ressources

-- ## Font
default_font = love.graphics.newFont('assets/fonts/font.ttf', 8) 
    
-- ## Graphics
TILES_ATLAS = love.graphics.newImage('assets/graphics/Tiles/atlas2.png')
TILES_QUADS = generateQuads(TILES_ATLAS, 16, 16)

OBJECTS_ATLAS = love.graphics.newImage('assets/graphics/Objects/atlas.png')
OBJECTS_QUADS = generateQuads(OBJECTS_ATLAS, 16, 16)

ENNEMIES_ATLAS = love.graphics.newImage('assets/graphics/Ennemies/atlas.png')
ENNEMIES_QUADS = generateQuads(ENNEMIES_ATLAS, 16, 16)

HUD_ATLAS = love.graphics.newImage('assets/graphics/HUD/atlas.png')
HUD_QUADS = generateQuads(HUD_ATLAS, 8, 8)

SCORE_ATLAS = love.graphics.newImage('assets/graphics/HUD/atlas_number.png')
SCORE_QUADS = generateQuads(SCORE_ATLAS, 4, 8)

MARIO_ATLAS = {
    love.graphics.newImage('assets/graphics/Mario/atlas_small.png'),
    love.graphics.newImage('assets/graphics/Mario/atlas_big.png')
}

MARIO_QUADS = {}
MARIO_QUADS[1] = generateQuads(MARIO_ATLAS[1], 16, 16)
MARIO_QUADS[2] = generateQuads(MARIO_ATLAS[2], 16, 32)

-- ## Musics
local musics = love.filesystem.getDirectoryItems('assets/musics')

MUSICS = {}
--print('# Chargement musiques')
for i=1, #musics do
    local file = musics[i]

    MUSICS[file:sub(1, -5) .. '_SND'] = love.audio.newSource('assets/musics/' .. file, 'stream')
end

-- ## SFX
local sfx = love.filesystem.getDirectoryItems('assets/sfx')

SFX = {}
--print('# Chargement sfx')
for i=1, #sfx do
    local file = sfx[i]

    --print(file:sub(1, -5):upper() .. '_SND')
    SFX[file:sub(1, -5):upper() .. '_SND'] = love.audio.newSource('assets/sfx/' .. file, 'static')
end 

-- # Constants
GRAVITY = 1155

COLLISIONSIDEX = {'right', 'left'}
COLLISIONSIDEY = {'bottom', 'top'}

-- SKY = {
--     OVERWORLD = {99/255, 173/255, 1, 1},
--     UNDERWORLD = {0, 0, 0, 1}
-- }

TILE = {
    SKY_1 = 697,
    COLLISION = -1,
    INVISIBLEBOX = -2,
    GROUND_1 = 1,
    BLOCK_1 = 34,

    -- ## Mountains
    --- # 1
    MOUNTAIN_L_SLOPE_1 = 273,
    MOUNTAIN_TOP_1 = 274,
    MOUNTAIN_R_SLOPE_1 = 275,
    MOUNTAIN_L_1 = 306,
    MOUNTAIN_CENTER_1 = 307,
    MOUNTAIN_R_1 = 308,


    -- ## Bushes
    --- # 1
    BUSH_L_1 = 309,
    BUSH_CENTER_1 = 310,
    BUSH_R_1 = 311,

    -- ## Clouds
    --- # 1
    CLOUD_TOP_L_1 = 661,
    CLOUD_TOP_CENTER_1 = 662,
    CLOUD_TOP_R_1 = 663,
    CLOUD_BOTTOM_L_1 = 694,
    CLOUD_BOTTOM_CENTER_1 = 695,
    CLOUD_BOTTOM_R_1 = 696,

    -- # Vertical Pipe
    --- # 1
    PIPE_V_TOP_L_1 = 265,
    PIPE_V_TOP_R_1 = 266,
    PIPE_V_BOTTOM_L_1 = 298,
    PIPE_V_BOTTOM_R_1 = 299,

    -- # Horizontal Pipe
    --- # 1
    PIPE_H_TOP_L_1 = 267,
    PIPE_H_TOP_M_1 = 268,
    PIPE_H_TOP_R_1 = 269,
    PIPE_H_BOTTOM_L_1 = 300,
    PIPE_H_BOTTOM_M_1 = 301,
    PIPE_H_BOTTOM_R_1 = 302,

    -- # Flag
    FLAG_TOP_1 = 281,
    FLAG_M_1 = 314,

    -- # Castle
    --- # 1
    CASTLE_REMPART_TOP_1 = 12,
    CASTLE_REMPART_BOTTOM_1 = 45,
    CASTLE_WALL_1 = 14,
    CASTLE_SLIT_L_1 = 13,
    CASTLE_SLIT_R_1 = 15,
    CASTLE_DOOR_TOP_1 = 46,
    CASTLE_DOOR_BOTTOM_1 = 47,


    VOID = 0
}
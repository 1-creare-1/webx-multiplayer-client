-- https://github.com/KashTheKing/webxdonut/blob/main/script.lua
local get, fetch, window, set_timeout = get, fetch, window, set_timeout

-- Debug Helpers
local outputLabel, errorLabel = get("output"), get("error")
function log(msg)
	outputLabel.set_content(tostring(msg) .. "\n" .. outputLabel.get_content())
end

function warn(msg)
	errorLabel.set_content(tostring(msg) .. "\n" .. errorLabel.get_content())
end

local INIT = os.clock()
function elapsed_time()
    return os.clock() - INIT
end
xpcall(function()
    


-- Constants
local VERSION = "v0.0.1"
local URL = window.link
local RAW_URL = "https://raw.githubusercontent.com/1-creare-1/webx-multiplayer-client/main/play"
local DOMAIN = "buss://raymarch.dev/play"
log(URL)
-- libs/vec3.lua
-- Libs
local Vec3 = require(`{URL}/libs/vec3.lua`)
local SDFs = require(`{URL}/libs/sdfs.lua`)

-- Setup types
type Vec3 = Vec3.Vec3

-- Rendering Constants
local RENDER_WINDOW = get("render_view")
local LIGHT_DIRECTION = Vec3.new(1, 1, 0):normalize()
local FPS = 60
local CHARACTERS_PER_UNIT = 0.5
local MAX_STEPS = 100
local MAX_DIST = 500
local SURFACE_DIST = 0.01
local CHARSET = {'.',',','-','~',':',';','=','!','*','#','$','@'}
-- local CHARSET = {'.','#'}

local TITLE_LABEL = get("title")

log(Vec3)
-- Init
get("version").set_content(VERSION)
log("Loaded")

-- World
local function WorldSDF(v: Vec3)
   return math.min(
        SDFs.SphereSDF(v - Vec3.new(30,0,0), 50),--math.sin(elapsed_time()*5) * 5 + 50),
        SDFs.SphereSDF(v - Vec3.new(-30,math.sin(elapsed_time()*5)*50,0), 50)--math.sin(elapsed_time()*10) * -5 + 50)
        -- SphereSDF(v - Vec3.new(0,0,0), 5)
    )
end

-- getNormal function
function GetNormal(p)
    local e = Vec3.new(0.01, 0)
    local thing = WorldSDF(p)
    local n = Vec3.new(
        WorldSDF(Vec3.new(p.x - e.x, p.y - e.y, p.z - e.y)) - thing,
        WorldSDF(Vec3.new(p.x - e.y, p.y - e.x, p.z - e.y)) - thing,
        WorldSDF(Vec3.new(p.x - e.y, p.y - e.y, p.z - e.x)) - thing
    )

    return n:normalize()
end

function SoftShadow(ro: Vec3, rd: Vec3, mint: number, maxt: number, k: number): number
    local res = 1
    local t = mint
    for i = 0, 256 do
        if not t < maxt then break end
        local h = WorldSDF(ro + rd*t)
        if h < 0.001 then
            return 0
        end
        res = math.min(res, k*h/t)
        t += h
    end
    return res
end

local function Raymarch(ro: Vec3, rd: Vec3)
    local dO = 0.0

    for _ = 0, MAX_STEPS do
        local p = ro + rd * dO
        local dS = WorldSDF(p)
        dO += dS

        if dO > MAX_DIST then
            break
        end

        if dS < SURFACE_DIST then
            return true, p
        end
    end

    return false
end

function calculateRayDirections(cameraPosition, lookVector, fieldOfView, imageWidth, imageHeight)
    local rayDirections = {}
    
    -- Convert field of view to radians
    local thetaFOV = math.rad(fieldOfView)
    
    -- Calculate d
    local d = 1 / math.tan(thetaFOV / 2)
    
    -- Iterate over each pixel
    for y = 0, imageHeight - 1 do
        for x = 0, imageWidth - 1 do
            -- Calculate normalized device coordinates
            local Px = x + 0.5
            local Py = y + 0.5
            local aspectRatio = imageWidth / imageHeight
            
            -- Calculate ray direction
            local rayDirX = aspectRatio * (2 * Px / imageWidth) - 1
            local rayDirY = (2 * Py / imageHeight) - 1
            local rayDirZ = d
            
            -- Adjust ray direction based on handedness of coordinate system
            -- For right-handed systems, rayDirZ should be negative
            -- For left-handed systems, rayDirZ should be positive
            -- Note: This can be adjusted based on the specific system used
            -- In this implementation, let's assume right-handed system
            rayDirZ = -rayDirZ
            
            -- Store the ray direction
            table.insert(rayDirections, {x = rayDirX, y = rayDirY, z = rayDirZ})
        end
    end
    
    return rayDirections
end

local function RaymarchCamera()
    local WIDTH = 200*CHARACTERS_PER_UNIT
    local HEIGHT = 100*CHARACTERS_PER_UNIT

    local r = os.clock()
    local CAM_POS = Vec3.new(math.cos(r) * 500, 5, math.sin(r) * 500)
    -- local CAM_DIR = Vec3.new(0, 0, 1)
    local CAM_DIR = CAM_POS:normalize() * -1
    local WORLD_UP = Vec3.new(0, 1, 0)
    local CAM_RIGHT = CAM_DIR:cross(WORLD_UP):normalize()
    local CAM_UP = CAM_DIR:cross(CAM_RIGHT):normalize()

    local rows = table.create(WIDTH)
    for y = HEIGHT, 0, -1 do
        local row = table.create(WIDTH)
        for x = WIDTH, 0, -1 do
            local wx = (x - (WIDTH / 2)) * 1/CHARACTERS_PER_UNIT
            local wy = (y - (HEIGHT / 2)) * 1/CHARACTERS_PER_UNIT
            wy *= 2 -- Account for vertical/horizontal gap between characters
            
            local cast_offset = CAM_UP * -wy + CAM_RIGHT * -wx
            local hit, pos = Raymarch(cast_offset+CAM_POS, CAM_DIR)

            if hit then
                local normal = GetNormal(pos)
                local diffuse = math.max(normal:dot(LIGHT_DIRECTION)+0.3, 0.0);
                local char = math.clamp(math.round(diffuse * (#CHARSET-1))+1, 1, #CHARSET)
                row[x] = CHARSET[char]
                -- row[x] = "#"
            else
                row[x] = " "
            end
            -- row[x] = if hit then "#" else " "
            -- row[x] = `[{math.round(hit * 10) / 10}]`
        end
        rows[y] = table.concat(row, "")
    end
    return table.concat(rows, "\n")
end

local function DrawWorld()
    local out = RaymarchCamera()
    RENDER_WINDOW.set_content(out)
end

local last_frame_time = os.clock()
local function Update(dt)
    DrawWorld()
    local spf = os.clock() - last_frame_time
    local fps = 1 / spf
    TITLE_LABEL.set_content(`Raymarching Test  {math.round(fps)} FPS`)
    last_frame_time = os.clock()
    set_timeout(Update, 1/FPS*1000)
end
Update()


end, warn)

--[[

[133.8][127.2][122.4][119.5][118.6][119.5][122.4][127.2][133.8][142.2]
[122.2][108.7][173.9][162.6][158.8][162.6][173.9][108.7][122.2][139.6]
[166.7][168][159.7][164.2][130.4][164.2][159.7][168][166.7][150.7]
[19.7][17.3][16.5][16.1][16][16.1][16.5][17.3][19.7][131]
[17][16][15.4][15.1][15][15.1][15.4][16][17][19.7]
[19.7][17.3][16.5][16.1][16][16.1][16.5][17.3][19.7][131]
[166.7][168][159.7][164.2][130.4][164.2][159.7][168][166.7][150.7]
[122.2][108.7][173.9][162.6][158.8][162.6][173.9][108.7][122.2][139.6]
[133.8][127.2][122.4][119.5][118.6][119.5][122.4][127.2][133.8][142.2]
[115.5][112.4][110.2][108.9][108.4][108.9][110.2][112.4][115.5][119.4]
]]
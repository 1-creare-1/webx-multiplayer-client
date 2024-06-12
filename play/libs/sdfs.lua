local RAW_URL = "https://raw.githubusercontent.com/1-creare-1/webx-multiplayer-client/main/play"

local Vec3 = require(`{RAW_URL}/libs/vec3.lua`)
-- Setup types
type Vec3 = Vec3.Vec3

local module = {}

-- Shapes
function module.SphereSDF(viewer: Vec3, radius: number)
    return viewer:length() - radius
end

return module
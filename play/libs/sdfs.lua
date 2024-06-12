local RAW_URL = "https://raw.githubusercontent.com/1-creare-1/webx-multiplayer-client/main/play"

local Vec3 = require(`{RAW_URL}/libs/vec3.lua`)
-- Setup types
type Vec3 = Vec3.Vec3

local sd = {}

-- Shapes
function sd.Sphere(viewer: Vec3, radius: number)
    return viewer:length() - radius
end

function sd.Plane(p: Vec3, n: Vec3, h: Vec3)
  -- n must be normalized
  return Vec3.splat(p:dot(n)) + h
end

return sd
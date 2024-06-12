local Vec3 = require(`{window.link}/libs/vec3.lua`)
-- Setup types
type Vec3 = Vec3.Vec3

local module = {}

-- Shapes
function module.SphereSDF(viewer: Vec3, radius: number)
    return viewer:length() - radius
end

return module
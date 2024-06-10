local Vec3 = require(`{window.link}/libs/vec3.lua`)
local module = {}

-- Shapes
function module.SphereSDF(viewer: Vec3, radius: number)
    return viewer:length() - radius
end

return module
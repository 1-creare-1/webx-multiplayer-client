-- Basic Vec3 Implementation
local Vec3 = {}
Vec3.__index = Vec3
function Vec3.new(x, y, z)
    return setmetatable({x=x, y=y, z=z}, Vec3)
end

function Vec3.splat(v)
    return Vec3.new(v, v, v)
end

-- Vector addition
function Vec3.__add(a, b)
    return Vec3.new(a.x + b.x, a.y + b.y, a.z + b.z)
end

-- Vector subtraction
function Vec3.__sub(a, b)
    return Vec3.new(a.x - b.x, a.y - b.y, a.z - b.z)
end

-- Scalar multiplication
function Vec3.__mul(a, b)
    if type(a) == "number" then
        return Vec3.new(a * b.x, a * b.y, a * b.z)
    elseif type(b) == "number" then
        return Vec3.new(a.x * b, a.y * b, a.z * b)
    else
        error("Multiplication is not defined for these operands")
    end
end

-- Dot product
function Vec3:dot(b)
    return self.x * b.x + self.y * b.y + self.z * b.z
end

-- Cross product
function Vec3:cross(b)
    return Vec3.new(
        self.y * b.z - self.z * b.y,
        self.z * b.x - self.x * b.z,
        self.x * b.y - self.y * b.x
    )
end

-- Length of the vector
function Vec3:length()
    return math.sqrt(self.x^2 + self.y^2 + self.z^2)
end

-- Normalize the vector
function Vec3:normalize()
    local len = self:length()
    if len > 0 then
        return Vec3.new(self.x / len, self.y / len, self.z / len)
    else
        return Vec3.new(0, 0, 0)  -- Return a zero vector if length is zero to avoid division by zero
    end
end

-- String representation
function Vec3:__tostring()
    return string.format("Vec3(%.2f, %.2f, %.2f)", self.x, self.y, self.z)
end

export type Vec3 = typeof(Vec3)
return Vec3
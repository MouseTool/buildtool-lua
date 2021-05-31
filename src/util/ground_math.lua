--- Transformice grounds collision/intersection math module
local ground_math = {}

local math_cos = math.cos
local math_sin = math.sin
local math_abs = math.abs
local math_rad = math.rad

--- Checks if a given point is within the specified circle
--- @param circleX number # The horizontal position of the circle's centre
--- @param circleY number # The vertical position of the circle's centre
--- @param circleRadius number # The radius of the circle
--- @param pointX number # The horizontal position of the point to check
--- @param pointY number # The vertical position of the point to check
--- @return boolean
ground_math.isPointInCircle = function(circleX, circleY, circleRadius, pointX, pointY)
    local dx, dy = circleX - pointX, circleY - pointY
    return dx * dx + dy * dy <= circleRadius * circleRadius
end

--- Checks if a given point is within the specified rectangle
--- @param groundWidth number # The width of the rectangle
--- @param groundHeight number # The height of the rectangle
--- @param groundX number # The horizontal position of the rectangle's centre
--- @param groundY number # The vertical position of the rectangle's centre
--- @param groundAngle number # The rotation (in degrees) of the rectangle
--- @param pointX number # The horizontal position of the point to check
--- @param pointY number # The vertical position of the point to check
--- @return boolean
ground_math.isPointInRect = function(groundWidth, groundHeight, groundX, groundY, groundAngle, pointX, pointY)
    if groundAngle ~= 0 then
        -- Borrowed from #utility
        local n_theta = -math_rad(groundAngle)
        local c, s = math_cos(n_theta), math_sin(n_theta)
        local cx, cy = groundX + c * (pointX - groundX) - s * (pointY - groundY),
                       groundY + s * (pointX - groundX) + c * (pointY - groundY)

        return math_abs(cx - groundX) < groundWidth / 2
            and math_abs(cy - groundY) < groundHeight / 2
    end
    return math_abs(groundX - groundWidth / 2) < pointX
        and math_abs(groundY - groundHeight / 2) < pointY
end

return ground_math
